#include "stdafx.h"
#include "CMagicStateMgr.h"
#include "CAllStateMgr.h"
#include "CStateCondFunctor.h"
#include "CFighterDictator.h"
#include "CSkillInstServer.h"
#include "CStateDBData.h"
#include "CMagicStateInstServer.h"
#include "CMagicEffServer.h"
#include "ICharacterMediatorCallbackHandler.h"
#include "ErrLogHelper.h"
#include "BaseHelper.h"
#include "CoreCommon.h"
#include "CTriggerEvent.h"
#include "CConnServer.h"
#include "DebugHelper.h"
#include "TSqrAllocator.inl"
#include "CRivalStateMgr.h"
	

//������CMagicStateCategoryServer����
pair<bool, MultiMapMagicState::iterator> CMagicStateCategoryServer::AddMS(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller)			//��������һ��ħ��״̬Ԫ�ص���ħ��״̬�����map
{
#ifdef COUT_STATE_INFO
	cout << m_pMgr->m_pOwner->GetEntityID() << ": ��װħ��״̬��" << GetCfg()->GetName() << endl;
#endif

	CMagicStateServer *pMS = new CMagicStateServer(pSkillInst, pInstaller, this);
	MultiMapMagicState::iterator mtmapMSItr = m_mtmapMS.insert(make_pair(GetFighterEntityID(pInstaller), pMS));
	mtmapMSItr->second->m_mtmapMSItr = mtmapMSItr;
	//m_pMgr->m_mapMSByDynamicId.insert(make_pair(mtmapMSItr->second->m_uDynamicId, mtmapMSItr->second));
	mtmapMSItr->second->m_uDynamicId = m_pMgr->GetAllMgr()->AddStateByDId(mtmapMSItr->second);
	//cout << "����������DynamicIDΪ" << m_uDynamicId << "��ħ��״̬\n";
	//bool selfHasBeenDeleted = mtmapMSItr->second->Start();
	return make_pair(false, mtmapMSItr);
}

pair<bool, MultiMapMagicState::iterator> CMagicStateCategoryServer::AddMSFromDB(CSkillInstServer* pSkillInst, CMagicStateCascadeDataMgr* pCancelableDataMgr,
																				CMagicStateCascadeDataMgr* pDotDataMgr, CMagicStateCascadeDataMgr* pFinalDataMgr, CFighterDictator* pInstaller,  
																				uint32 uCount, int32 iTime, int32 iRemainTime)			//��������һ��ħ��״̬Ԫ�ص���ħ��״̬�����map
{
#ifdef COUT_STATE_INFO
	cout << m_pMgr->m_pOwner->GetEntityID() << ": �ָ�ħ��״̬��" << GetCfg()->GetName() << endl;
#endif

	CMagicStateServer *pMS = new CMagicStateServer(pSkillInst, pCancelableDataMgr, pDotDataMgr, pFinalDataMgr, uCount, pInstaller, this, iTime, iRemainTime);
	MultiMapMagicState::iterator mtmapMSItr = m_mtmapMS.insert(make_pair(GetFighterEntityID(pInstaller), pMS));
	mtmapMSItr->second->m_mtmapMSItr = mtmapMSItr;
	//m_pMgr->m_mapMSByDynamicId.insert(make_pair(mtmapMSItr->second->m_uDynamicId, mtmapMSItr->second));
	mtmapMSItr->second->m_uDynamicId = m_pMgr->GetAllMgr()->AddStateByDId(mtmapMSItr->second);
	//cout << "����������DynamicIDΪ" << m_uDynamicId << "��ħ��״̬\n";
	//bool selfHasBeenDeleted = mtmapMSItr->second->Start(true);
	return make_pair(false, mtmapMSItr);
}

CMagicStateCategoryServer::CMagicStateCategoryServer(const CMagicStateCfgServerSharedPtr& pCfg, CMagicStateMgrServer* pMgr)
:m_pCfg(new CMagicStateCfgServerSharedPtr(pCfg))
,m_pMgr(pMgr)
{
}

CMagicStateCategoryServer::~CMagicStateCategoryServer()
{
	ClearMap(m_mtmapMS);
	SafeDelete(m_pCfg);
}

CMagicStateCfgServerSharedPtr& CMagicStateCategoryServer::GetCfg()const
{
	return *m_pCfg;
}










//������CMagicStateMgrServer����
bool CMagicStateMgrServer::SerializeToDB(CStateDBDataSet* pRet, ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID, uint64 uNow, uint32 uGrade)
{
	int32 iLeftTime;
	for(MapMagicStateCategory::iterator itr = m_mapMSCategory.begin(); itr != m_mapMSCategory.end(); ++itr)
	{
		SQR_TRY 
		{
			CMagicStateCfgServerSharedPtr& pCfg = itr->second->GetCfg();
			if((uint32)pCfg->GetNeedSaveToDBType() < uGrade) continue;
			MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
			for(MultiMapMagicState::iterator itrMt = mtmapMS.begin(); itrMt != mtmapMS.end(); itrMt++)
			{
				CMagicStateServer* pMS = itrMt->second;
				if(itrMt->second->m_iRemainTime > -1)
				{
					iLeftTime = itrMt->second->m_iRemainTime * 1000 - int32(uNow - itrMt->second->m_uStartTime);
				}
				else
				{
					iLeftTime = -1;
				}
				uint32 uIDBase = pMS->m_uDynamicId * 3;

				CStateDBData* pState = new CStateDBData(pCfg->GetGlobalType(), pCfg->GetName(),				//���������ֱ�Ӹ���ָ��ģ�ҪС�ģ������Ƿ��Ƹ�����
					pMS->m_iTime, iLeftTime, pMS->m_uCount, 0.0f, 
					pCfg->GetCancelableMagicEff() ? uIDBase + 1 : 0,
					pCfg->GetDotMagicEff() ? uIDBase + 2 : 0,
					pCfg->GetFinalMagicEff() ? uIDBase + 3 : 0,
					pMS->m_pSkillInst->GetSkillLevel(),
					pMS->m_pSkillInst->GetSkillName().c_str(),		//���������ֱ�Ӹ���ָ��ģ�ҪС�ģ������Ƿ��Ƹ�����
					pMS->m_pSkillInst->GetAttackType(),
					pMS->m_pSkillInst->GetInterval(),
					pMS->GetInstaller() == m_pOwner);

				//pHandler->AddStateToDB(uFighterGlobalID, eSGT_MagicState, &aState);
				pRet->m_pStateVec->PushBack(pState);

#ifdef COUT_STATEDB_INFO
				cout << "ħ��״̬[" << pCfg->GetName() << "]�������ݿ�\n";
#endif

				if(pCfg->GetCancelableMagicEff())
					pMS->m_pCancelableDataMgr->SerializeToDB(pRet->m_pStoredObjVec, pHandler, uFighterGlobalID, uIDBase + 1);

				if(pCfg->GetDotMagicEff())
					pMS->m_pDotDataMgr->SerializeToDB(pRet->m_pStoredObjVec, pHandler, uFighterGlobalID, uIDBase + 2);

				if(pCfg->GetFinalMagicEff())
					pMS->m_pFinalDataMgr->SerializeToDB(pRet->m_pStoredObjVec, pHandler, uFighterGlobalID, uIDBase + 3);
			}
		}
		SQR_CATCH(exp)
		{
			CConnServer* pConnServer = m_pOwner->GetConnection();
			if (pConnServer)
				LogExp(exp, pConnServer);
			else
				LogExp(exp);
		}
		SQR_TRY_END;
	}
	return true;
}

bool CMagicStateMgrServer::LoadFromDB(ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID)
{
	//CStateDBDataSet* pRet = GetAllMgr()->GetStateDataMgrRet();



	//TCHAR sName[256];
	//int32 iRemainTime, iCount;
	//uint32 uSkillInstID, uCancelableInstID, uDotInstID, uFinalInstID;
	for(uint32 uStateCount = 0;; uStateCount++)
	{
		CSkillInstServer* pSkillInst = NULL;
		CMagicStateCascadeDataMgr *pCancelableDataMgr = NULL, *pDotDataMgr = NULL, *pFinalDataMgr = NULL;
		bool bCatched = false;
		//CStateDBData aStateDBData;
		CStateDBData* pStateDBData = NULL;
		//bool bRet = pHandler->ReadStateFromDB(uFighterGlobalID, eSGT_MagicState, &aStateDBData);
		bool bRet = GetAllMgr()->ReadStateFromDB(pStateDBData, eSGT_MagicState);

		if(!bRet) break;

		CStateDBData& aStateDBData = *pStateDBData;

		CMagicStateCfgServerSharedPtr pCfg;

		uint32 uCascadeMax = uint32(aStateDBData.m_iCount);

		CFighterDictator* pInstaller = aStateDBData.m_bFromEqualsOwner ? m_pOwner : NULL;

		SQR_TRY
		{
			if(aStateDBData.m_iCount <= 0)
			{
				stringstream ExpStr;
				ExpStr << "ħ��״̬[" << aStateDBData.m_sName << "]���Ӳ����������0\n";
				GenErr("ħ��״̬���ݿ��ȡ����", ExpStr.str());
				return false;
			}
			pCfg = CMagicStateCfgServer::Get(aStateDBData.m_sName);
			if(!pCfg)
			{
				stringstream ExpStr;
				ExpStr << "ħ��״̬[" << aStateDBData.m_sName << "]�����������ñ�\n";
				GenErr("ħ��״̬���ݿ��ȡ����", ExpStr.str());
				return false;
			}

			//uint8 uSkillLevel;
			//TCHAR sSkillName[256];
			//EAttackType eAttackType;
			//bool bIsDot;

			//bRet = pHandler->ReadSkillInstFromDB(uSkillInstID, uSkillLevel, sSkillName, eAttackType, bIsDot);

			//if(!bRet)
			//{
			//	ExpStr << "ħ��״̬��ȡ����ħ��״̬[" << aStateDBData.m_sName << "]û��IDΪ" << aStateDBData.m_uSkillInstID << "�ļ�������������\n";
			//	GenErr(ExpStr.str());
			//	return false;
			//}

			uint32 uCreatorID = 0;
			if (aStateDBData.m_bFromEqualsOwner)
			{
				uCreatorID = m_pOwner->GetEntityID();
			}
			pSkillInst = CSkillInstServer::CreateOrigin(uCreatorID,aStateDBData.m_sSkillName,aStateDBData.m_uSkillLevel, aStateDBData.m_eAttackType);
			pSkillInst->SetInterval( aStateDBData.m_bIsDot);
			//CMagicStateCascadeDataMgr *pCancelableInst = NULL, *pDotInst = NULL, *pFinalInst = NULL;
			CreateDataMgrFromDB(pHandler, uFighterGlobalID, pCancelableDataMgr, pSkillInst, aStateDBData.m_uCancelableInstID,
				"�ɳ���", uCascadeMax, pInstaller, pCfg->GetCancelableMagicEff(), pCfg);
			CreateDataMgrFromDB(pHandler, uFighterGlobalID, pDotDataMgr, pSkillInst, aStateDBData.m_uDotInstID, "���", uCascadeMax,
				pInstaller, pCfg->GetDotMagicEff(), pCfg);
			CreateDataMgrFromDB(pHandler, uFighterGlobalID, pFinalDataMgr, pSkillInst, aStateDBData.m_uFinalInstID, "����",
				uCascadeMax, pInstaller, pCfg->GetFinalMagicEff(), pCfg);

		}
		SQR_CATCH(exp)
		{
			if(pSkillInst)
				pSkillInst->DestroyOrigin();
			delete pCancelableDataMgr;
			delete pDotDataMgr;
			delete pFinalDataMgr;

			exp.AppendMsg("�����ñ��޸Ķ����ݿ�δ��յ��£�����bug��");

			CConnServer* pConnServer = m_pOwner->GetConnection();
			if (pConnServer)
				LogExp(exp, pConnServer);
			else
				LogExp(exp);

			bCatched = true;
		}
		SQR_TRY_END;
		if(!bCatched)
		{
			int32 iLeftSecond = aStateDBData.m_iRemainTime == -1 ? -1 : aStateDBData.m_iRemainTime / 1000 + 1; //�ָ�Ҫ���겻��ģ��������һ��DOT
			SQR_TRY
			{
				RestoreStateFromDB(pSkillInst, pCfg, aStateDBData.m_bFromEqualsOwner ? m_pOwner : NULL,
					aStateDBData.m_iTime, iLeftSecond, uCascadeMax,
					pCancelableDataMgr, pDotDataMgr, pFinalDataMgr);
#ifdef COUT_STATEDB_INFO
				cout << "�����ݿ����ħ��״̬[" << pCfg->GetName() << "]\n";
#endif
			}
			SQR_CATCH(exp)
			{
				CConnServer* pConnServer = m_pOwner->GetConnection();
				if (pConnServer)
					LogExp(exp, pConnServer);
				else
					LogExp(exp);
			}
			SQR_TRY_END;
			if(pSkillInst)
				pSkillInst->DestroyOrigin();
		}
		SafeDelete(pStateDBData);
	}

	return true;
}

bool CMagicStateMgrServer::CreateDataMgrFromDB(ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID,
		CMagicStateCascadeDataMgr*& pCascadeDataMgr, CSkillInstServer* pSkillInst, uint32 uInstID, const string& sEffTitle,
		uint32 uCascadeMax, CFighterDictator* pInstaller, const CMagicEffServerSharedPtr& pMagicEff, const CMagicStateCfgServerSharedPtr& pCfg)
{
	bool bRet;

	if(pMagicEff)
	{
		pCascadeDataMgr = new CMagicStateCascadeDataMgr();

		uint32 uMopMax;
		SQR_TRY 
		{
			uMopMax = pMagicEff->GetMOPCount();
		}
		SQR_CATCH(exp)
		{
			string str = exp.ErrorMsg();
			str += " uMopMax = pMagicEff->GetMOPCount()";
			GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
			return false;
		}
		SQR_TRY_END;

		CStoredObjDBData* pData = NULL;
		for(uint32 uCascadeIndex = 0, uMopIndex = uMopMax; ;)
		{
			SQR_TRY 
			{
				bRet = GetAllMgr()->ReadStoredObjFromDB(pData, uInstID);
			}
			SQR_CATCH(exp)
			{
				string str = exp.ErrorMsg();
				str += "bRet = GetAllMgr()->ReadStoredObjFromDB(pData, uInstID);";
				GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
				return false;
			}
			SQR_TRY_END;

			if(bRet)
			{
				if(++uMopIndex > uMopMax)
				{
					if(++uCascadeIndex > uCascadeMax)
					{
						SQR_TRY 
						{
							SafeDelete(pData);
						}
						SQR_CATCH(exp)
						{
							string str = exp.ErrorMsg();
							str += "SafeDelete(pData)[1]";
							GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
							return false;
						}
						SQR_TRY_END;
						stringstream ExpStr;
						SQR_TRY
						{
							ExpStr << "ħ��״̬[" << pCfg->GetName() << "]" << sEffTitle << "Ч���Ĵ洢�����ȡ���󣺵�ǰ�����ĵ��Ӳ���" << uCascadeIndex << "���������ݿ��ȡ��������" << uCascadeMax << "\n";
						}
						SQR_CATCH(exp)
						{
							string str = exp.ErrorMsg();
							str += "ExpStr << [1]";
							GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
							return false;
						}
						SQR_TRY_END;
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", ExpStr.str());
						return false;
					}

					if(uCascadeIndex != pData->m_uCascadeID)
					{
						SQR_TRY
						{
							SafeDelete(pData);
						}
						SQR_CATCH(exp)
						{
							string str = exp.ErrorMsg();
							str += "SafeDelete(pData)[2]";
							GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
							return false;
						}
						SQR_TRY_END;
						stringstream ExpStr;
						SQR_TRY
						{
							ExpStr << "ħ��״̬[" << pCfg->GetName() << "]" << sEffTitle << "Ч���Ĵ洢�����ȡ���󣺴����ݿ��ȡ�ĵ��Ӳ���" <<  pData->m_uCascadeID << "�����ڵ�ǰ�����ĵ��Ӳ���" << uCascadeIndex << "\n";
						}
						SQR_CATCH(exp)
						{
							string str = exp.ErrorMsg();
							str += " ExpStr << [2]";
							GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
							return false;
						}
						SQR_TRY_END;
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", ExpStr.str());
						return false;
					}

					uMopIndex = 1;
					SQR_TRY 
					{
						pCascadeDataMgr->AddCascade(pInstaller);
					}
					SQR_CATCH(exp)
					{
						string str = exp.ErrorMsg();
						str += "pCascadeDataMgr->AddCascade(pInstaller);";
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
						return false;
					}
					SQR_TRY_END;
					SQR_TRY 
					{
						pCascadeDataMgr->SetItrLast();
					}
					SQR_CATCH(exp)
					{
						string str = exp.ErrorMsg();
						str += "pCascadeDataMgr->SetItrLast();";
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
						return false;
					}
					SQR_TRY_END;
				}

				if(uMopIndex != pData->m_uMOPID)
				{	
					SQR_TRY
					{
						SafeDelete(pData);
					}
					SQR_CATCH(exp)
					{
						string str = exp.ErrorMsg();
						str += "SafeDelete(pData)[3]";
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
					}
					SQR_TRY_END;
					stringstream ExpStr;
					SQR_TRY 
					{
						ExpStr << "ħ��״̬[" << pCfg->GetName() << "]" << sEffTitle << "Ч���Ĵ洢�����ȡ���󣺴����ݿ��ȡ��ħ�������±�" << pData->m_uMOPID << "�����ڵ�ǰ������ħ�������±�" << uMopIndex << "\n";
					}
					SQR_CATCH(exp)
					{
						string str = exp.ErrorMsg();
						str += "ExpStr << [3]";
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
					}
					SQR_TRY_END;
					GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", ExpStr.str());
					return false;
				}

				CMagicEffDataMgrServer* pDataMgr = NULL;
				SQR_TRY 
				{
					pDataMgr = pCascadeDataMgr->GetLastEffDataMgr();
				}
				SQR_CATCH(exp)
				{
					string str = exp.ErrorMsg();
					str += "pDataMgr = pCascadeDataMgr->GetLastEffDataMgr();";
					GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
					return false;
				}
				SQR_TRY_END;
				SQR_TRY 
				{
					pDataMgr->AddMopData(CMagicOpStoredObj(pData->m_iMOPArg, pData->m_uMOPRet));
				}
				SQR_CATCH(exp)
				{
					string str = exp.ErrorMsg();
					str += "pDataMgr->AddMopData(CMagicOpStoredObj(pData->m_iMOPArg, pData->m_uMOPRet));";
					GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
					return false;
				}
				SQR_TRY_END;

#ifdef COUT_STATEDB_INFO
				cout << "�����ݿ����ħ��״̬" << sEffTitle << "Ч����" << uCascadeIndex << "��״̬��" << uMopIndex << "��ħ�������Ĵ洢����\n";
#endif
				SQR_TRY
				{
					SafeDelete(pData);
				}
				SQR_CATCH(exp)
				{
					string str = exp.ErrorMsg();
					str += "SafeDelete(pData)[4]";
					GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
					return false;
				}
				SQR_TRY_END;
			}
			else
			{
				//������0ħ����������ʱ�������Ҫ��
				if(uCascadeIndex < uCascadeMax || uMopIndex < uMopMax)
				{
					stringstream ExpStr;
					SQR_TRY
					{
						//ExpStr << "ħ��״̬[" << pCfg->GetName() << "]" << sEffTitle << "Ч���Ĵ洢�����ȡ���󣺴����ݿ��ȡ�������Ӳ�����ħ�������±�" << pData->m_uCascadeID << "," << pData->m_uMOPID << "�����ڵ�ǰ������" << uCascadeIndex << "," << uMopIndex << "\n";
						ExpStr << "ħ��״̬[" << pCfg->GetName() << "]" << sEffTitle 
							<< "Ч���Ĵ洢�����ȡ���󣺴����ݿ��ȡ�������Ӳ�����ħ�������±�" << pData->m_uCascadeID << ","
							<< pData->m_uMOPID << "�����ڵ�ǰ������" << uCascadeIndex << "(<" << uCascadeMax << ")," 
							<< uMopIndex << "(<" << uMopMax << ")\n";
					}
					SQR_CATCH(exp)
					{
						string str = exp.ErrorMsg();
						str += "ExpStr << [4]";
						GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", str);
						return false;
					}
					SQR_TRY_END;
					GenErr("ħ��״̬Ч���Ĵ洢�������ݿ��ȡ����", ExpStr.str());
					return false;
				}
				break;
			}
		}

		//pInst->SetIsCalc(false);
	}
	return true;
}

bool CMagicStateMgrServer::RestoreStateFromDB(CSkillInstServer* pSkillInst, const CMagicStateCfgServerSharedPtr& pCfg,
												   CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime, uint32 uCount,
												   CMagicStateCascadeDataMgr* pCancelableDataMgr, CMagicStateCascadeDataMgr* pDotDataMgr, CMagicStateCascadeDataMgr* pFinalDataMgr)
{
	if (!m_pOwner)
	{
		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
		//return false;
	}

	//����������ң���ֵ��ħ��״̬���ñ�ָ��
	MapMagicStateCategory::iterator map2dimMSItr = m_mapMSCategory.find(pCfg.get());
	if (map2dimMSItr == m_mapMSCategory.end())
	{
		//�½�һ��ħ��״̬����
		CMagicStateCategoryServer* pMSCategory = new CMagicStateCategoryServer(pCfg, this);

		//�½�һ��ħ��״̬����
		pair<bool, MultiMapMagicState::iterator> pr = pMSCategory->AddMSFromDB(pSkillInst, pCancelableDataMgr, pDotDataMgr, pFinalDataMgr, pInstaller, uCount, iTime, iRemainTime);

		if(pr.first) return true;
		MultiMapMagicState::iterator itrMS = pr.second;

		m_mapMSCategory.insert(make_pair(pCfg.get(), pMSCategory));

		itrMS->second->StartTime(true);

		//����ħ��״̬�����ģ�ͺ���Ч�ص�
		GetAllMgr()->OnSetState(pCfg->GetId(), itrMS->second->m_uDynamicId, itrMS->second->m_uCount,
			itrMS->second->m_iTime, itrMS->second->m_iRemainTime, itrMS->second->m_pSkillInst->GetSkillLevel(),
			itrMS->second->GetInstallerID(),itrMS->second->GetCalcValue());

		itrMS->second->StartDoFromDB();

		return true;
	}
	else
	{
		switch(pCfg->GetCascadeType())
		{
		case eCT_Unique:
		case eCT_Central:
		case eCT_Share:
			{
				//Ψһ�ͼ���״̬���ܳ����ظ����ֵ�ħ��״̬
				stringstream ExpStr;
				ExpStr << "��������Ϊ" << pCfg->GetCascadeType() << "��ħ��״̬[" << pCfg->GetName() << "]�����ظ��ָ�\n";
				GenErr("�����ݿ�ָ���װ״̬����", ExpStr.str());
				//return false;
			}
			break;
		case eCT_Decentral:
			{
				//�½�һ��ħ��״̬����
				pair<bool, MultiMapMagicState::iterator> pr = map2dimMSItr->second->AddMSFromDB(pSkillInst, pCancelableDataMgr, pDotDataMgr, pFinalDataMgr, pInstaller, uCount, iTime, iRemainTime);
				if(pr.first) return true;
				MultiMapMagicState::iterator itrMS = pr.second;

				itrMS->second->StartTime(true);

				//����ħ��״̬�����ģ�ͺ���Ч�ص�
				GetAllMgr()->OnSetState(pCfg->GetId(), itrMS->second->m_uDynamicId,  itrMS->second->m_uCount,
					itrMS->second->m_iTime, itrMS->second->m_iRemainTime, itrMS->second->m_pSkillInst->GetSkillLevel(),
					itrMS->second->GetInstallerID(),itrMS->second->GetCalcValue());

				//���Ϲ��캯������ִ��ħ��״̬�����������������ü�ʱ��
				itrMS->second->StartDoFromDB();
				return true;
			}
			break;
		default:
			break;
		}
	}
	return false;
}

bool CMagicStateMgrServer::IgnoreImmuneSetupState(CSkillInstServer* pSkillInst, const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller)
{
	CAllStateMgrServer* pAllMgr = GetAllMgr();

	//�����Լ���
	if(pAllMgr->DecreaseStateResist(pCfg.get())) return false;

	//����״̬�滻����
	if(!pAllMgr->ReplaceModelState(pCfg.get())) return false;

	//����������ң���ֵ��ħ��״̬���ñ�ָ��
	MapMagicStateCategory::iterator map2dimMSItr = m_mapMSCategory.find(pCfg.get());
	if (map2dimMSItr == m_mapMSCategory.end())
	{
		//�½�һ��ħ��״̬����
		CMagicStateCategoryServer* pMSCategory = new CMagicStateCategoryServer(pCfg, this);

		//��װһ���µ�ħ��״̬ʱ�Ż��ӡս����Ϣ, ���ӻ��滻ʱ����ӡ
		pAllMgr->PrintFightInfo(true, pInstaller ? pInstaller->GetEntityID() : 0, pCfg.get());

		//�½�һ��ħ��״̬����
		pair<bool, MultiMapMagicState::iterator> pr = pMSCategory->AddMS(pSkillInst,pInstaller);
		if(pr.first) return true;
		MultiMapMagicState::iterator itrMS = pr.second;

		m_mapMSCategory.insert(make_pair(pCfg.get(), pMSCategory));

		itrMS->second->StartTime();

		itrMS->second->CalculateMagicOpArg(itrMS->second->GetInstaller());

		//����ħ��״̬�����ģ�ͺ���Ч�ص�
		//m_pOwner->GetHandler()->OnSetState(pCfg->GetId(), itrMS->second->m_uDynamicId, 1, itrMS->second->m_iTime);
		pAllMgr->OnSetState(pCfg->GetId(), itrMS->second->m_uDynamicId, 1, itrMS->second->m_iTime,
			itrMS->second->m_iRemainTime, itrMS->second->m_pSkillInst->GetSkillLevel(),
			itrMS->second->GetInstallerID(),itrMS->second->GetCalcValue());
		itrMS->second->StartDo();

		return true;
	}
	else
	{
		switch(pCfg->GetCascadeType())
		{
		case eCT_Unique:
			{
				////�ȼ�������ԭ��ħ��״̬�ĵȼ�������滻����
				//if (pSkillInst->GetSkillLevel() >= map2dimMSItr->second->m_mtmapMS.begin()->second->m_uGrade)
				//{
				//	return map2dimMSItr->second->m_mtmapMS.begin()->second->Replace(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
				//}
				CMagicStateServer* pState = map2dimMSItr->second->m_mtmapMS.begin()->second;
				if(pState->m_bCancellationDone)
				{
					//����ѳ�����ֱ���滻
					return pState->Replace(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
				}
				else if(pInstaller && pState->GetInstallerID() == pInstaller->GetEntityID())
				{
					//������Ҫ���ǰ�װ��ʼ��ΪNULL����������������eCT_Unique�޷�����
					return pState->Cascade(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
				}
			}
			break;
		case eCT_Central:
		case eCT_Share:
			{
				CMagicStateServer* pState = map2dimMSItr->second->m_mtmapMS.begin()->second;
				if(pState->m_bCancellationDone)
				{
					//����ѳ�����ֱ���滻
					return pState->Replace(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
				}
				else
				{
					//������Ӳ���
					return pState->Cascade(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
				}
			}
			break;
		case eCT_Decentral:
			{
				//���к�����ң���ֵ��ʩ����Fighterָ��
				MultiMapMagicState& curMtmapMS = map2dimMSItr->second->m_mtmapMS;
				MultiMapMagicState::iterator mtmapMSItr = curMtmapMS.end();
				if(pInstaller)
				{
					mtmapMSItr = curMtmapMS.find(pInstaller->GetEntityID());
				}
				if (mtmapMSItr == curMtmapMS.end())
				{

					//��װһ���µ�ħ��״̬ʱ�Ż��ӡս����Ϣ, ���ӻ��滻ʱ����ӡ
					pAllMgr->PrintFightInfo(true, pInstaller ? pInstaller->GetEntityID() : 0, pCfg.get());

					//�½�һ��ħ��״̬����
					pair<bool, MultiMapMagicState::iterator> pr = map2dimMSItr->second->AddMS(pSkillInst,pInstaller);
					if(pr.first) return true;
					MultiMapMagicState::iterator itrMS = pr.second;

					itrMS->second->StartTime();

					itrMS->second->CalculateMagicOpArg(itrMS->second->GetInstaller());

					//����ħ��״̬�����ģ�ͺ���Ч�ص�
					//m_pOwner->GetHandler()->OnSetState(pCfg->GetId(), itrMS->second->m_uDynamicId, 1, itrMS->second->m_iTime);
					pAllMgr->OnSetState(pCfg->GetId(), itrMS->second->m_uDynamicId, 1, itrMS->second->m_iTime,
						itrMS->second->m_iRemainTime, itrMS->second->m_pSkillInst->GetSkillLevel(), 
						itrMS->second->GetInstallerID(),itrMS->second->GetCalcValue());

					//���Ϲ��캯������ִ��ħ��״̬�����������������ü�ʱ��
					itrMS->second->StartDo();
					return true;
				}
				else
				{
					CMagicStateServer* pState = mtmapMSItr->second;
					if(pState->m_bCancellationDone)
					{
						//����ѳ�����ֱ���滻
						return pState->Replace(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
					}
					else
					{
						//������Ӳ���
						return pState->Cascade(pSkillInst, pSkillInst->GetSkillLevel(), pInstaller).second;
					}
				}
			}
			break;
		default:
			break;
		}
	}

	return false;
}

bool CMagicStateMgrServer::SetupState(CSkillInstServer* pSkillInst, const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller)
{
	if (!m_pOwner)
	{
		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
		//return false;
	}

	//���߼���
	CAllStateMgrServer* pAllMgr = GetAllMgr();
	if(pAllMgr->Immume(pCfg.get(), pSkillInst, pInstaller))
	{
		return false;
	}
	
	return IgnoreImmuneSetupState(pSkillInst, pCfg, pInstaller);
}

bool CMagicStateMgrServer::ResetTime(const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller)
{
	//����������ң���ֵ��ħ��״̬���ñ�ָ��
	MapMagicStateCategory::iterator map2dimMSItr = m_mapMSCategory.find(pCfg.get());
	if (map2dimMSItr == m_mapMSCategory.end())
	{
		//���������״̬��ֱ�ӷ���
		return false;
	}
	else
	{
		switch(pCfg->GetCascadeType())
		{
		case eCT_Unique:
			{
				CMagicStateServer* pState = map2dimMSItr->second->m_mtmapMS.begin()->second;
				if(pState->m_bCancellationDone)
				{
					//����ѳ�����ֱ�ӷ���
					return false;
				}
				else if(pInstaller && pState->GetInstallerID() == pInstaller->GetEntityID())
				{
					//������Ҫ���ǰ�װ��ʼ��ΪNULL����������������eCT_Unique�޷�����ʱ��
					return pState->ResetTime();
				}
			}
			break;
		case eCT_Decentral:
			{
				//���к�����ң���ֵ��ʩ����Fighterָ��
				MultiMapMagicState& curMtmapMS = map2dimMSItr->second->m_mtmapMS;
				MultiMapMagicState::iterator mtmapMSItr = curMtmapMS.end();
				if(pInstaller)
				{
					mtmapMSItr = curMtmapMS.find(pInstaller->GetEntityID());
				}
				if (mtmapMSItr == curMtmapMS.end())
				{
					//���Ҳ���pInstaller��״̬��ֱ�ӷ���
					return false;
				}
				else
				{
					CMagicStateServer* pState = mtmapMSItr->second;
					if(pState->m_bCancellationDone)
					{
						//����ѳ�����ֱ�ӷ���
						return false;
					}
					else
					{
						//����ʱ��
						return pState->ResetTime();
					}
				}
			}
			break;
		default:
			{
				CMagicStateServer* pState = map2dimMSItr->second->m_mtmapMS.begin()->second;
				if(pState->m_bCancellationDone)
				{
					//����ѳ�����ֱ�ӷ���
					return false;
				}
				else
				{
					//����ʱ��
					return pState->ResetTime();
				}
			}
		}
	}
	return false;
}

bool CMagicStateMgrServer::AddTime(const CMagicStateCfgServerSharedPtr& pCfg, int32 iTime)
{
	//����������ң���ֵ��ħ��״̬���ñ�ָ��
	MapMagicStateCategory::iterator map2dimMSItr = m_mapMSCategory.find(pCfg.get());
	if (map2dimMSItr == m_mapMSCategory.end())
	{
		//���������״̬��ֱ�ӷ���
		return false;
	}
	else
	{
		MultiMapMagicState& curMtmapMS = map2dimMSItr->second->m_mtmapMS;
		for(MultiMapMagicState::iterator mtmapMSItr = curMtmapMS.begin(); mtmapMSItr != curMtmapMS.end(); ++mtmapMSItr)
		{
			CMagicStateServer* pState = mtmapMSItr->second;
			if(pState->m_bCancellationDone)
			{
				//����ѳ�����ֱ�ӷ���
				return false;
			}
			else
			{
				//����ʱ��
				return pState->AddTime(iTime);
			}
		}
	}
	return false;
}




bool CMagicStateMgrServer::ExistState(const string& name)
{
	return ExistState(CMagicStateCfgServer::Get(name));
}

bool CMagicStateMgrServer::ExistState(const CMagicStateCfgServerSharedPtr& pCfg)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(pCfg.get());
	if(itr != m_mapMSCategory.end())
	{
		return !itr->second->m_mtmapMS.empty();
	}
	else
	{
		return false;
	}
}

bool CMagicStateMgrServer::ExistState(const CMagicStateCfgServerSharedPtr& pCfg, const CFighterDictator* pInstaller)
{
	if(!pInstaller) return false;
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(pCfg.get());
	if(itr != m_mapMSCategory.end())
	{
		return itr->second->m_mtmapMS.find(pInstaller->GetEntityID()) != itr->second->m_mtmapMS.end();
	}
	else
	{
		return false;
	}
}

//bool CMagicStateMgrServer::EraseState(const string& name, const CFighterDictator* pInstaller)
//{
//	if(!pInstaller) return false;
//	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(CMagicStateCfgServer::Get(name));
//	if(itr != m_mapMSCategory.end())
//	{
//		MultiMapMagicState iterator itrMt = itr->second->m_mtmapMS.find(pInstaller->GetEntityID());
//		if(itrMt!= itr->second->m_mtmapMS.end())
//		{
//			Erase
//		}
//	}
//	else
//	{
//		return false;
//	}
//}

uint32 CMagicStateMgrServer::MagicStateCount(const string& name)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(CMagicStateCfgServer::Get(name).get());
	if(itr != m_mapMSCategory.end())
	{
		uint32 uTotalCount = 0;
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		for(MultiMapMagicState::iterator itrMt = mtmapMS.begin(); itrMt != mtmapMS.end(); ++itrMt)
		{
			uTotalCount += itrMt->second->m_uCount;
		}
		return uTotalCount;
	}
	else
	{
		return 0;
	}
}

uint32 CMagicStateMgrServer::MagicStateCountOfInstaller(const string& name, const CFighterDictator* pInstaller)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(CMagicStateCfgServer::Get(name).get());
	if(itr != m_mapMSCategory.end())
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.find(pInstaller->GetEntityID());
		if(itrMt != mtmapMS.end())
		{
			return itrMt->second->m_uCount;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

int32 CMagicStateMgrServer::StateLeftTime(const string& name, const CFighterDictator* pInstaller)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(CMagicStateCfgServer::Get(name).get());
	if(itr != m_mapMSCategory.end())
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		switch(itr->second->GetCfg()->GetCascadeType())
		{
		case eCT_Central:
		case eCT_Unique:
		case eCT_Share:
			if(!mtmapMS.empty())
			{
				return mtmapMS.begin()->second->GetLeftTime();
			}
			else
			{
				return 0;
			}
			break;
		case eCT_Decentral:
			{
				if(pInstaller)
				{
					MultiMapMagicState::iterator itrMt = mtmapMS.find(pInstaller->GetEntityID());
					if(itrMt != mtmapMS.end())
					{
						return itrMt->second->GetLeftTime();
					}
					else
					{
						return 0;
					}
				}
				else
				{
					stringstream str;
					str << "��ɢ����ħ��״̬[" << name << "]��StateLeftTime()������pInstaller��������Ϊ��\n";
					GenErr("��ɢ����ħ��״̬��StateLeftTime()������pInstaller��������Ϊ��", str.str());
					return 0;
				}
			}
			break;
		default:
			{
				stringstream str;
				str << "ħ��״̬[" << name << "]��StateLeftTime()������������[" << itr->second->GetCfg()->GetCascadeType() << "����";
				GenErr("ħ��״̬��StateLeftTime()�����������ʹ���", str.str());
				return 0;
			}
		}
	}
	else
	{
		return 0;
	}
}



//void CMagicStateMgrServer::AddStateTarget(CFighterDictator* pTarget)
//{
//	m_setTarget.insert(pTarget);
//}
//
//void CMagicStateMgrServer::DelStateTarget(CFighterDictator* pTarget)
//{
//	if (pTarget) m_setTarget.erase(pTarget);
//}
//
//
//void CMagicStateMgrServer::Offline()
//{
//	for (SetStateTarget::iterator itr = m_setTarget.begin(); itr != m_setTarget.end(); itr++)
//	{
//		(*itr)->GetAllStateMgr()->GetMagicStateMgrServer().Offline(m_pOwner);
//	}
//}

void CMagicStateMgrServer::OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg)
{
	switch(uEvent)
	{
	case eCE_Offline:
		InstallerOffline(class_cast<CFighterDictator *>(pSubject));
		break;
	case eCE_Attack:
	case eCE_MoveBegan:
		{
			CAllStateMgrServer* pStateMgr = GetAllMgr();
			Ast(pStateMgr);
			pStateMgr->EraseState(eDST_FeignDeath);
			break;
		}
	default:
		break;
	}
}

void CMagicStateMgrServer::InstallerOffline(CFighterDictator * pInstaller)
{
	uint32 uInstallerID = 0;
	if (!pInstaller)
	{
		GenErr("CMagicStateMgrServer::Offline�Ĳ���ָ��Ϊ��");
		return;
	}
	else
	{
		uInstallerID = pInstaller->GetEntityID();
	}

	MapMagicStateCategory::iterator map2dimMSItr;

	for (map2dimMSItr = m_mapMSCategory.begin(); map2dimMSItr != m_mapMSCategory.end(); ++map2dimMSItr)
	{
		MultiMapMagicState& curMtmapMS = map2dimMSItr->second->m_mtmapMS;
		MtMapMagicStatePairItr mtmapMSPairItr = curMtmapMS.equal_range(uInstallerID);
		if (mtmapMSPairItr.first != curMtmapMS.end())
		{
			MultiMapMagicState::const_iterator itr = mtmapMSPairItr.first; 
			if(itr != mtmapMSPairItr.second)
			{
				//ʩ��������������NULLָ���滻map�е����и���ʩ���߲���ħ��״̬�ļ�ֵ
				MultiMapMagicState::iterator mtmapMSItr = curMtmapMS.insert(make_pair(0, itr->second));
				mtmapMSItr->second->m_mtmapMSItr = mtmapMSItr;
				mtmapMSItr->second->SetInstaller(NULL);
				itr->second->DetachInstaller();
				curMtmapMS.erase(itr->first);

				//pInstaller->GetAllStateMgr()->GetMagicStateMgrServer().DelStateTarget(m_pOwner);

			}
		}
	}
}



void CMagicStateMgrServer::ClearState(const CMagicStateCfgServerSharedPtr& pCfg)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(pCfg.get());
	if(itr != m_mapMSCategory.end())
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin(), itrBackup;

		if(itrMt != mtmapMS.end())
			GetAllMgr()->PrintFightInfo(false, itrMt->second->GetInstallerID(), pCfg.get());
		
		for(;itrMt != mtmapMS.end();)
		{
			itrBackup = itrMt;
			itrBackup++;
			CMagicStateServer* pMagicState = itrMt->second;
			uint32 uDynamicId = pMagicState->m_uDynamicId;
			bool selfHasBeenDeleted = pMagicState->CancelDo();
			if(selfHasBeenDeleted) return;				//��������Ϊ����CancelDo()���ܰ�m_pOwnerŪ������itrMt����
			//if(itrMt->second.DeleteSelf()) break;
			//m_mapMSByDynamicId.erase(pMagicState->m_uDynamicId);
			GetAllMgr()->DelStateByDId(uDynamicId);
			pMagicState->DetachInstaller();
			//GetOwner()->UnRegistDistortedTick(pMagicState);
			itrMt = itrBackup;
		}

#ifdef COUT_STATE_INFO
		cout << "�ⲿ����ClearState��ɾ���Լ���" << pCfg->GetName() << endl;
#endif

		EraseMapNode(m_mapMSCategory, itr);
	}
}

void CMagicStateMgrServer::ClearAll()
{
	//״̬��CancelDo()�����ﲻ����ֱ�ӻ��ӵ����Լ�״̬��ص�InstallerOffline�������������Ϊ������õ��µ�����ʧЧ���޷�����������һ�����
	for(MapMagicStateCategory::iterator itr = m_mapMSCategory.begin(); itr != m_mapMSCategory.end(); ++itr)
	{
		//�����ǰitr��CancelDo()��DeleteSelf()��ǰitr��MagicState�����е��µ�ǰitrʧЧ��Σ�գ�������Σ���޷������ȱ���itr��һ��λ�õĸ����İ취�ų�����ΪCancelDo()�����Ѿ����Գ���ɾ����һ��λ�õ�MagicState������������п��ܵ������ȱ����itr��һ��λ�õĸ���ҲʧЧ��
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin();
		for(; itrMt != mtmapMS.end(); itrMt++)
		{
			uint32 uDynamicId = itrMt->second->m_uDynamicId;
			itrMt->second->CancelDo();			
			itrMt->second->DetachInstaller();
			GetAllMgr()->DelStateByDId(uDynamicId);

			//GetOwner()->UnRegistDistortedTick(itrMt->second);


			//itrBackup = itrMt;
			//itrBackup++;
			//if(itrMt->second.DeleteSelf()) break;
			//itrMt = itrBackup;

			//���������Ҫ������һ��CancelDo����õ�ExistState���ܻ��õ������Ƿ�������ж������ѱ�ɾ����״̬�Ƿ���ڣ�
			//��������ж��ڵ�ǰ״����Ҫ����뷶ΧΪfalse����������Ҫ�޸ĵ�������־����дExistState���жϷ�ʽΪ�жϵ�������־��ֱ��ɾ��������
		}
	}
	//cout << "�ⲿ����ClearAll��ɾ������MagicState��\n";
	//m_mapMSByDynamicId.clear();
	ClearMap(m_mapMSCategory);
	m_pRivalStateMgr->ClearAll();
}

void CMagicStateMgrServer::ClearAllByCond(CStateCondBase * pStateCond)
{
	//״̬��CancelDo()�����ﲻ����ֱ�ӻ��ӵ����Լ�״̬��ص�InstallerOffline�������������Ϊ������õ��µ�����ʧЧ���޷�����������һ�����
	MapMagicStateCategory::iterator itr = m_mapMSCategory.begin();//, itrBackup;
	for(; itr != m_mapMSCategory.end(); )
	{
		//�����и��޽�����⣬���DeleteSelf()��ǰitr��MagicState��������DeleteSelf()���µ���������map���µ�ǰitrʧЧ��
		//��CancelDo()�����õ�������map�ڵ���һ��MagicStateɾ����������һ��MagicState���ɵ�ǰ��MagicState�Ŀɳ���ħ��Ч����װ�ģ�
		//��ʹ��itrBackup����itr����һ��λ�õĵ����������������ҲʧЧ�ˣ������޷�Ԥ֪itr֮�����������MagicState�ᱻɾ����
		//���Գ��ǽ�MagicState����ɾ����map���ɾ������������ѭ����

		MapMagicStateCategory::iterator itrBackup = itr;
		itrBackup++;
		bool bSelfCategoryDeleted = false;

		CMagicStateCfgServerSharedPtr& uTempStateCfg = itr->second->GetCfg();

		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin();//, itrMtBackup;
		for(; itrMt != mtmapMS.end();)
		{
			//itrMtBackup = itrMt;
			//itrMtBackup++;
			CMagicStateServer* pState = itrMt->second;
			if((*pStateCond)(pState))
			{
				//�����CancelDo������ֱ�ӻ��ӣ����紥���¼����µģ�ɾ����Category�б��˵�״̬������ᵼ��itr������ʧЧ
				MultiMapMagicState::iterator itrMtBackup;
				itrMtBackup = itrMt;
				++itrMtBackup;
				if(pState->CancelDo())
				{
					if(m_mapMSCategory.find(uTempStateCfg.get()) == m_mapMSCategory.end())
					{
						itr = itrBackup;
						bSelfCategoryDeleted = true;
						break;
					}
					itrMt = itrMtBackup;
					continue;
				}
				pState->PrepareDeleteSelf();
				if(itrMt != itr->second->m_mtmapMS.end())
				{
					itr->second->m_mtmapMS.erase(itrMt++);
				}
				delete pState;	//���Ҫ��Ҫ�����Ƶ�ifǰ�棿
			}
			else
			{
				++itrMt;
			}
			//itrMt = itrMtBackup;
		}
		if(!bSelfCategoryDeleted)
		{
			if(itr->second->m_mtmapMS.empty())
			{
				delete itr->second;
				m_mapMSCategory.erase(itr++);
			}
			else
			{
				++itr;
			}
		}

		//itr = itrBackup;
	}
}

bool CMagicStateMgrServer::ExistStateByCond(CStateCondBase* pStateCond)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.begin();//, itrBackup;
	for(; itr != m_mapMSCategory.end(); ++itr)
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin();//, itrMtBackup;
		for(; itrMt != mtmapMS.end(); ++itrMt)
		{
			CMagicStateServer* pState = itrMt->second;
			if((*pStateCond)(pState))
			{
				return true;
			}
		}
	}
	return false;
}

void CMagicStateMgrServer::ReflectAllByCond(CStateCondBase * pStateCond)
{
	MapMagicStateCategory::iterator itr = m_mapMSCategory.begin();
	for(; itr != m_mapMSCategory.end(); ++itr)
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin();
		for(; itrMt != mtmapMS.end();++itrMt)
		{
			CMagicStateServer* pState = itrMt->second;
			if((*pStateCond)(pState))
			{
				CFighterDictator* pInstaller = pState->GetInstaller();
				CFighterDictator* pOwner = pState->GetOwner();
				if (pInstaller && pOwner && pInstaller->CppIsAlive() && pInstaller != pOwner)
				{
					//CFPos posOwner		= pState->GetOwner()->GetPixelPos();
					//CFPos posInstaller	= pInstaller->GetPixelPos();
					//float x = posOwner.x - posInstaller.x;
					//float y = posOwner.y - posInstaller.y;
					//float fDistance = sqrt(x*x + y*y)/eGridSpanForObj;
					
					float fDistance = pOwner->GetFighterDistInGrid(pInstaller);

					if (fDistance <= 20)	// 20���ڷ���
					{		
						//pState->m_pSkillInst->ChangeToSkillInst();
						pInstaller->GetAllStateMgr()->GetMagicStateMgrServer()->SetupState(pState->m_pSkillInst, pState->GetCfgSharedPtr(), pState->GetOwner());
						//pState->m_pSkillInst->RevertInstType();
					}			
				}
			}
		}
	}
}

//bool CMagicStateMgrServer::ClearStateByCondAndDynamicId(CStateCondBase* pStateCond, uint32 uDynamicId)
//{
//	MapMagicStateByDynamicId::iterator itr = m_mapMSByDynamicId.find(uDynamicId);
//	if(itr!=m_mapMSByDynamicId.end())
//	{
//		CMagicStateServer* pState = itr->second;
//		if(itr != m_mapMSByDynamicId.end())
//		{
//			if((*pStateCond)(pState))
//			{
//				if(pState->CancelDo()) return true;
//				pState->DeleteSelf();
//				//m_mapMSByDynamicId.erase(DynamicId);
//				return false;
//			}
//		}
//	}
//	return false;
//}

bool CMagicStateMgrServer::ClearStateByCond(CStateCondBase* pStateCond, uint32 uId)
{
	bool bEraseDSRSuccess = false;
	CMagicStateCfgServerSharedPtr& pCfg = CMagicStateCfgServer::GetById(uId);
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(pCfg.get());
	if(itr != m_mapMSCategory.end())
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin(), itrBackup;
		
		if(itrMt != mtmapMS.end())
			GetAllMgr()->PrintFightInfo(false, itrMt->second->GetInstallerID(), pCfg.get());
		
		for(;itrMt != mtmapMS.end();)
		{
			//itrBackup = itrMt;
			//itrBackup++;
			CMagicStateServer* pState = itrMt->second;
			if((*pStateCond)(pState))
			{
				bEraseDSRSuccess = true;
				uint32 uDynamicId = pState->m_uDynamicId;
				bool selfHasBeenDeleted = pState->CancelDo();
				if(selfHasBeenDeleted) return bEraseDSRSuccess;				//��������Ϊ����CancelDo()���ܰ�m_pOwnerŪ������itrMt����
				//if(pState.DeleteSelf()) break;
				//m_mapMSByDynamicId.erase(pState->m_uDynamicId);
				GetAllMgr()->DelStateByDId(uDynamicId);
				pState->DetachInstaller();
				//GetOwner()->UnRegistDistortedTick(pState);
				delete pState;
				mtmapMS.erase(itrMt++);
			}
			else
			{
				++itrMt;
			}	
			//itrMt = itrBackup;
		}
		if(mtmapMS.empty()) 
		{
#ifdef COUT_STATE_INFO
			cout << "�ⲿ����ClearStateByCond��ɾ���Լ���" << pCfg->GetName() << endl;
#endif

			EraseMapNode(m_mapMSCategory, itr);
		}
	}
	return bEraseDSRSuccess;
}

//bool CMagicStateMgrServer::ExistState(uint32 DynamicId)
//{
//	MapMagicStateByDynamicId::iterator itr = m_mapMSByDynamicId.find(DynamicId);
//	if(itr == m_mapMSByDynamicId.end())
//	{
//		return false;
//	}
//	else
//	{
//		return true;
//	}
//}

//void CMagicStateMgrServer::SetOwner(CFighterDictator* pOwner)
//{
//	m_pOwner = pOwner;
//	//m_pOwner->Attach(this, eCE_Die);
//}

void CMagicStateMgrServer::UnloadFighter()
{
	m_pOwner = NULL;
	//m_pOwner->Detach(this, eCE_Die);
}

//void CMagicStateMgrServer::SyncAllState(CFighterDictator* pObserver, uint64 uNow)
//{
//	int32 iRemainTime;
//	//��������MagicStateMap
//	CAllStateMgrServer* pAllMgr = GetAllMgr();
//	for(MapMagicStateByDynamicId::iterator itr = m_mapMSByDynamicId.begin();
//		itr != m_mapMSByDynamicId.end(); itr++)
//	{
//		CMagicStateServer* pMagicState = itr->second;
//		Ast(pMagicState);
//		iRemainTime = pMagicState->m_iRemainTime != -1 ?
//			pMagicState->m_iRemainTime - (int32(uNow - pMagicState->m_uStartTime) + 500) / 1000 : -1;
//
//		Ast(iRemainTime >= -1);
//		if(iRemainTime < -1) continue;
//		pAllMgr->OnSetState(pMagicState->m_pMSCategory->m_pCfg->GetId(), 
//			pMagicState, pMagicState->m_uCount, pMagicState->m_iTime, iRemainTime, pObserver);
//	}
//}

void CMagicStateMgrServer::SyncAllState(CFighterDictator* pObserver, uint64 uNow)
{
	int32 iRemainTime;
	CAllStateMgrServer* pAllMgr = GetAllMgr();
	for(MapMagicStateCategory::iterator itr = m_mapMSCategory.begin(); itr != m_mapMSCategory.end(); ++itr)
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin();
		for(; itrMt != mtmapMS.end(); itrMt++)
		{
			CMagicStateServer* pMagicState = itrMt->second;
			Ast(pMagicState);
			iRemainTime = pMagicState->m_iRemainTime != -1 ?
				pMagicState->m_iRemainTime - (int32(uNow - pMagicState->m_uStartTime) + 500) / 1000 : -1;

			pAllMgr->OnSetState(pMagicState->m_pMSCategory->GetCfg()->GetId(), 
				pMagicState->m_uDynamicId, pMagicState->m_uCount, pMagicState->m_iTime, iRemainTime,
				pMagicState->m_pSkillInst->GetSkillLevel(), pObserver);
		}
	}
}

CAllStateMgrServer* CMagicStateMgrServer::GetAllMgr()
{
	return m_pOwner->GetAllStateMgr();
}

bool CMagicStateMgrServer::CanDecStateCascade(const CMagicStateCfgServerSharedPtr& pCfg, uint32 uCascade)
{
	if(uCascade == 0) return true;
	uint32 uAllCascadeCount = 0;
	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(pCfg.get());
	if(itr != m_mapMSCategory.end())
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		for(MultiMapMagicState::iterator itrMt = mtmapMS.begin(); itrMt != mtmapMS.end(); itrMt++)
		{
			uAllCascadeCount += itrMt->second->m_uCount;
			if(uAllCascadeCount >= uCascade) return true;
		}
	}

	return false;
}

bool CMagicStateMgrServer::DecStateCascade(const CMagicStateCfgServerSharedPtr& pCfg, uint32 uCascade, bool bInCancel)
{
	if(uCascade == 0) return true;

	MapMagicStateCategory::iterator itr = m_mapMSCategory.find(pCfg.get());
	if(itr != m_mapMSCategory.end())
	{
		MultiMapMagicState& mtmapMS = itr->second->m_mtmapMS;
		MultiMapMagicState::iterator itrMt = mtmapMS.begin(), itrBackup;
		for(;itrMt != mtmapMS.end();)
		{
			itrBackup = itrMt;
			itrBackup++;
			pair<bool, bool> bPairStatus = itrMt->second->CancelCascade(uCascade, bInCancel);
			if(bPairStatus.first) return true;				//��������Ϊ����CancelCascade()���ܰ�m_pOwnerŪ������itrMt����
			itrMt = itrBackup;
		}
	}

	return false;
}


CMagicStateMgrServer::CMagicStateMgrServer(CFighterDictator* pOwner)
:m_pOwner(pOwner)/*, m_uMaxDynamicId(eSIC_DynamicMagicState)*/
{
	m_pRivalStateMgr = new CRivalStateMgr();
	//m_setTarget.clear();
}

CMagicStateMgrServer::~CMagicStateMgrServer()
{
	ClearAll();
	UnloadFighter();
	delete m_pRivalStateMgr;
}
