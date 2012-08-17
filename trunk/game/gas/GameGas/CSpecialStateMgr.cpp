#include "stdafx.h"
#include "CSpecialStateMgr.h"
#include "CSpecialStateCfg.h"
#include "CAllStateMgr.h"
#include "CStateCondFunctor.h"
#include "CSkillInstServer.h"
#include "CStateDBData.h"
#include "BaseHelper.h"
#include "CFighterDictator.h"
#include "CDirMoveState.h"
#include "ErrLogHelper.h"
#include "CTriggerEvent.h"
#include "CConnServer.h"
#include "DebugHelper.h"
#include "TSqrAllocator.inl"
#include "COtherStateMgr.inl"

template class TOtherStateMgrServer<CSpecialStateCfgServer, CSpecialStateBase>;

//������CSpecialStateMgrServer����
bool CSpecialStateMgrServer::SetupState(CSkillInstServer* pSkillInst, const CSpecialStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller)
{
	if (!m_pOwner)
	{
		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
		//return false;
	}

	CAllStateMgrServer* pAllMgr = GetAllMgr();

	//���߼���
	if(pAllMgr->Immume(pCfg.get(), pSkillInst, pInstaller))
	{
		return false;
	}

	//�����Լ���
	if(pAllMgr->DecreaseStateResist(pCfg.get())) return false;

	//����״̬�滻����
	if(!pAllMgr->ReplaceModelState(pCfg.get())) return false;

	MapSpecialState::iterator itr = m_mapState.find(pCfg.get());
	if (itr == m_mapState.end())
	{
#ifdef COUT_STATE_INFO
		cout << "��װ����״̬��" << pCfg->GetName() << endl;
#endif

		//��װһ���µ�ħ��״̬ʱ�Ż��ӡս����Ϣ, ���ӻ��滻ʱ����ӡ
		pAllMgr->PrintFightInfo(true, pInstaller ? pInstaller->GetEntityID() : 0, pCfg.get());

		//����һ���µĴ�����ħ��״̬
		CSpecialStateBase* pSS = CreateSpecialState(pSkillInst, pInstaller, this, pCfg);
		pSS->m_uDynamicId = pAllMgr->AddStateByDId(pSS);

		//״̬Ԫ�ز����������SpecialStateӳ��
		pair<MapSpecialState::iterator, bool> pr = m_mapState.insert(make_pair(pCfg.get(), pSS));

		//����SpecialState������
		MapSpecialState::iterator mapPSSItr = pr.first;
		mapPSSItr->second->m_mapSSItr = mapPSSItr;

		MapSSTypeBandle::iterator mapSSTBItr = m_mapStateTypeBundle.find(pCfg->GetSSType());
		if (mapSSTBItr == m_mapStateTypeBundle.end())
		{
			//����һ���µĹ���������
			CSpecialStateTypeBundle tempSSTB;

			//״ָ̬����빦����������DamageChangeState�б�������EventBandle������
			mapPSSItr->second->m_listSSItr = tempSSTB.m_listState.insert(tempSSTB.m_listState.end(), mapPSSItr->second);

			//���������������������StateTypeBundleӳ��
			pair<MapSSTypeBandle::iterator, bool> prSSTB = m_mapStateTypeBundle.insert(make_pair(pCfg->GetSSType(), tempSSTB));

			//��¼�ղ����StateTypeBundleԪ���ڹ�������λ��
			mapSSTBItr = prSSTB.first;

			//����StateTypeBundle������
			mapPSSItr->second->m_listSSItr = mapSSTBItr->second.m_listState.begin();
		}
		else
		{
			//����϶�������mapStateBundleItr->second.m_listDS.find(mapPDSItr->second)) != second.m_listBS.end()�����
			//��ΪmapPDSItr == m_mapDS.end()�Ѿ��ų���
			//״ָ̬����빦����������TriggerState�б�������StateTypeBundle������
			mapPSSItr->second->m_listSSItr = mapSSTBItr->second.m_listState.insert(mapSSTBItr->second.m_listState.end(), mapPSSItr->second);
		}
		//����StateTypeBundle��ָ��
		mapPSSItr->second->m_pStateBundleByType = &mapSSTBItr->second;

		mapPSSItr->second->RegisterEvent();

		pSS->Start();

		//����ħ��״̬�����ģ�ͺ���Ч�ص�
		pAllMgr->OnSetState(pCfg->GetId(), pSS->m_uDynamicId, 1, pSS->m_iTime, pSS->m_iRemainTime, pSS->m_pSkillInst->GetSkillLevel(), pSS->GetInstallerID());

		return true;
	}
	else
	{
		//�Ѿ������������κβ���
	}
	return false;
}

bool CSpecialStateMgrServer::RestoreStateFromDB(CSkillInstServer* pSkillInst, const CSpecialStateCfgServerSharedPtr& pCfg,
													   CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime)
{
	if (!m_pOwner)
	{
		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
		//return false;
	}

	MapSpecialState::iterator itr = m_mapState.find(pCfg.get());
	if (itr == m_mapState.end())
	{
#ifdef COUT_STATE_INFO
		cout << "��װ����״̬��" << pCfg->GetName() << endl;
#endif

		//����һ���µĴ�����ħ��״̬
		CSpecialStateBase* pSS = CreateSpecialState(pSkillInst, pInstaller, this, pCfg, iTime, iRemainTime);
		pSS->m_uDynamicId = GetAllMgr()->AddStateByDId(pSS);

		//״̬Ԫ�ز����������SpecialStateӳ��
		pair<MapSpecialState::iterator, bool> pr = m_mapState.insert(make_pair(pCfg.get(), pSS));

		//����SpecialState������
		MapSpecialState::iterator mapPSSItr = pr.first;
		mapPSSItr->second->m_mapSSItr = mapPSSItr;

		MapSSTypeBandle::iterator mapSSTBItr = m_mapStateTypeBundle.find(pCfg->GetSSType());
		if (mapSSTBItr == m_mapStateTypeBundle.end())
		{
			//����һ���µĹ���������
			CSpecialStateTypeBundle tempSSTB;

			//״ָ̬����빦����������SpecialState�б�������StateTypeBundle������
			mapPSSItr->second->m_listSSItr = tempSSTB.m_listState.insert(tempSSTB.m_listState.end(), mapPSSItr->second);

			//���������������������StateTypeBundleӳ��
			pair<MapSSTypeBandle::iterator, bool> prSSTB = m_mapStateTypeBundle.insert(make_pair(pCfg->GetSSType(), tempSSTB));

			//��¼�ղ����StateTypeBundleԪ���ڹ�������λ��
			mapSSTBItr = prSSTB.first;

			//����StateTypeBundle������
			mapPSSItr->second->m_listSSItr = mapSSTBItr->second.m_listState.begin();
		}
		else
		{
			//����϶�������mapStateBundleItr->second.m_listDS.find(mapPDSItr->second)) != second.m_listBS.end()�����
			//��ΪmapPDSItr == m_mapDS.end()�Ѿ��ų���
			//״ָ̬����빦����������TriggerState�б�������StateTypeBundle������
			mapPSSItr->second->m_listSSItr = mapSSTBItr->second.m_listState.insert(mapSSTBItr->second.m_listState.end(), mapPSSItr->second);
		}
		//����EventBandle��ָ��
		mapPSSItr->second->m_pStateBundleByType = &mapSSTBItr->second;

		mapPSSItr->second->RegisterEvent();

		pSS->Start(true);

		//����ħ��״̬�����ģ�ͺ���Ч�ص�
		GetAllMgr()->OnSetState(pCfg->GetId(), pSS->m_uDynamicId, 1, pSS->m_iTime, pSS->m_iRemainTime, pSS->m_pSkillInst->GetSkillLevel(), pSS->GetInstallerID());

		return true;
	}
	else
	{
		//�Ѿ������������κβ���
	}
	return false;
}

CSpecialStateBase* CSpecialStateMgrServer::CreateSpecialState(CSkillInstServer* pSkillInst,
	CFighterDictator* pInstaller, CSpecialStateMgrServer* pMgr,
	const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime, int32 iRemainTime)
{
	CSpecialStateBase* pSS = NULL;
	switch(pCfg->GetSSType())
	{
	case eSST_Reflect:
		pSS = new CReflectStateServer(pSkillInst, pInstaller, pMgr, pCfg, iTime, iRemainTime);
		break;
	case eSST_DOTImmunity:
		pSS = new CSpecialStateBase(pSkillInst, pInstaller, pMgr, pCfg, iTime, iRemainTime);
		break;
	case eSST_DirMove:
		pSS = new CDirMoveStateServer(pSkillInst, pInstaller, pMgr, pCfg, iTime, iRemainTime);
		break;
	case eSST_DeadBody:
		pSS = new CDeadBodyStateServer(pSkillInst, pInstaller, pMgr, pCfg, iTime, iRemainTime);
		break;
	default:
		{
			stringstream ExpStr;
			ExpStr << "��������ħ��״̬����ʱ���ʹ���";
			GenErr(ExpStr.str());
			//return NULL;
		}
	}
	return pSS;
}

//bool CSpecialStateMgrServer::ExistState(const string& name)
//{
//	MapSpecialState::iterator itr = m_mapState.find(CSpecialStateCfgServer::Get(name));
//	return itr != m_mapState.end();
//}
//
//bool CSpecialStateMgrServer::ExistState(const string& name, const CFighterDictator* pInstaller)
//{
//	MapSpecialState::iterator itr = m_mapState.find(CSpecialStateCfgServer::Get(name));
//	if(itr != m_mapState.end())
//	{
//		return itr->second->m_pInstaller == pInstaller;
//	}
//	else
//	{
//		return false;
//	}
//}

bool CSpecialStateMgrServer::ExistStateByType(ESpecialStateType type)
{
	MapSSTypeBandle::iterator itr = m_mapStateTypeBundle.find(type);
	if(itr != m_mapStateTypeBundle.end())
	{
		return !itr->second.m_listState.empty();
	}
	else
	{
		return false;
	}
}

//void CSpecialStateMgrServer::ClearSpecialState(const string& name)
//{
//	CSpecialStateCfgServer* pCfg = CSpecialStateCfgServer::Get(name);
//	if(!pCfg) return;
//	MapSpecialState::iterator itrPSS = m_mapState.find(pCfg);
//	if(itrPSS != m_mapState.end())
//	{
//		itrPSS->second->DeleteSelf();
//	}
//}

void CSpecialStateMgrServer::ClearStateByType(ESpecialStateType type)
{
	MapSSTypeBandle::iterator itr = m_mapStateTypeBundle.find(type);
	if(itr != m_mapStateTypeBundle.end())
	{
		ListPSpecialState::iterator itrTB, itrTBBackup;
		for(itrTB = itr->second.m_listState.begin(); itrTB != itr->second.m_listState.end();)
		{
			itrTBBackup = itrTB;
			itrTBBackup++;
			//��������������״̬��CancelDo()�����ݣ����һ�ֱ�ӻ��Ӵ���ɾ����ǰ����������һ��״̬��
			//����Ҫ�ı�����������ο�TOtherStateMgrServer<CfgType, StateType>::MessageEvent(uint32 uEventID, CGenericTarget* pTrigger)
			(*itrTB)->CancelDo();
			(*itrTB)->DeleteSelf();
			itrTB = itrTBBackup;
		}
	}
}

//bool CSpecialStateMgrServer::ClearSpecialStateByCond(CStateCondBase* pStateCond, uint32 uId)
//{
//	CSpecialStateCfgServer::MapSpecialStateCfgById::iterator itr = CSpecialStateCfgServer::m_mapCfgById.find(uId);
//	if(itr != CSpecialStateCfgServer::m_mapCfgById.end())
//	{
//		MapSpecialState::iterator itrPSS = m_mapState.find(itr->second);
//		if(itrPSS != m_mapState.end())
//		{
//			if((*pStateCond)(itrPSS->second))
//				itrPSS->second->DeleteSelf();
//			else
//				return false;
//		}
//	}
//	return true;
//}
//
void CSpecialStateMgrServer::ClearAll()
{
	m_mapStateTypeBundle.clear();
	m_mapStateBundleByEvent.clear();
	CAllStateMgrServer* pAllMgr = GetAllMgr();
	for(MapSpecialState::iterator itr = m_mapState.begin(); itr != m_mapState.end(); ++itr)
	{
		//GetOwner()->UnRegistDistortedTick(itr->second);
		itr->second->CancelDo();
		//����״̬CancelDo()�����κ��£����Բ���Ҫ�ж�״̬�Ƿ����
		pAllMgr->OnDeleteState(itr->second->GetCfgSharedPtr()->GetId(), itr->second->m_uDynamicId);
		pAllMgr->DelStateByDId(itr->second->m_uDynamicId);

#ifdef COUT_STATE_INFO
		cout << "�ⲿ����ClearAll��ɾ������TriggerState��\n";
#endif
	}
	ClearMap(m_mapState);
}
//
//void CSpecialStateMgrServer::ClearAllByCond(CStateCondBase* pStateCond)
//{
//	MapSpecialState::iterator itrPSS = m_mapState.begin(), itrPSSBackup;
//	for(; itrPSS != m_mapState.end();)
//	{
//		itrPSSBackup = itrPSS;
//		itrPSSBackup++;
//		if ((*pStateCond)(itrPSS->second))
//		{		
//			itrPSS->second->DeleteSelf();
//		}
//		itrPSS = itrPSSBackup;
//	}
//}
//
//
//
//
//
//
//void CSpecialStateMgrServer::SyncAllState(CFighterDictator* pObserver, uint32 uNow)
//{
//	int32 iRemainTime;
//	for(MapSpecialState::iterator itr = m_mapState.begin(); itr != m_mapState.end(); itr++)
//	{
//		iRemainTime = itr->second->m_iRemainTime != -1 ?
//			itr->second->m_iRemainTime - (int32(uNow - itr->second->m_uStartTime) + 500) / 1000 : -1;
//
//		uint32 uId = itr->second->m_pCfg->GetId();
//		//m_pOwner->GetHandler()->OnSetState(uId, uId, 1, itr->second->m_iTime);
//		GetAllMgr()->OnSetState(uId, uId, 1, itr->second->m_iTime, itr->second->m_iRemainTime, pObserver);
//	}
//}
//
//bool CSpecialStateMgrServer::SerializeToDB(CStateDBDataSet* pRet, ICharacterMediatorCallbackHandler* pHandler, uint32 uFighterGlobalID, uint32 uNow)
//{
//	int32 iLeftTime;
//	for(MapSpecialState::iterator itr = m_mapState.begin(); itr != m_mapState.end(); ++itr)
//	{
//		if(!itr->second->m_pCfg->GetNeedSaveToDB()) continue;
//
//		if(itr->second->m_iRemainTime > -1)
//		{
//			iLeftTime = itr->second->m_iRemainTime * 1000 - int32(uNow - itr->second->m_uStartTime);
//		}
//		else
//		{
//			iLeftTime = -1;
//		}
//
//		CSkillInstServer*& pInst = itr->second->m_pSkillInst;
//
//		CStateDBData* pState = new CStateDBData(itr->second->m_pCfg->GetGlobalType(),
//			itr->second->m_pCfg->GetName(), iLeftTime, 0, 0.0f,
//			0, 0, 0, pInst->m_uSkillLevel,
//			pInst->m_strSkillName.c_str(),
//			pInst->m_eAttackType,							//���������ֱ�Ӹ���ָ��ģ�ҪС�ģ������Ƿ��Ƹ�����
//			pInst->GetInterval(),
//			itr->second->m_pInstaller == m_pOwner);
//
//		//pHandler->AddStateToDB(uFighterGlobalID, eSGT_SpecialState, &aData);	
//		pRet->m_pStateVec->PushBack(pState);
//
//		cout << "����״̬[" << itr->second->m_pCfg->GetName() << "]�������ݿ�\n";
//	}
//	return true;
//}
//
//bool CSpecialStateMgrServer::LoadFromDB(ICharacterMediatorCallbackHandler* pHandler, uint32 uFighterGlobalID)
//{
//	stringstream ExpStr;
//
//	ClearAll();
//
//	for(uint32 uStateCount = 0;; uStateCount++)
//	{
//		//CStateDBData aStateDBData;
//		//bool bRet = pHandler->ReadStateFromDB(uFighterGlobalID, eSGT_SpecialState, &aStateDBData);
//		CStateDBData* pStateDBData = NULL;
//		bool bRet = GetAllMgr()->ReadStateFromDB(pStateDBData, eSGT_SpecialState);
//
//		if(!bRet) break;
//
//		CStateDBData& aStateDBData = *pStateDBData;
//
//		CSpecialStateCfgServer* pCfg = CSpecialStateCfgServer::Get(aStateDBData.m_sName);
//		if(!pCfg)
//		{
//			ExpStr << "����״̬��ȡ��������״̬[" << aStateDBData.m_sName << "]�����������ñ�\n";
//			GenErr(ExpStr.str());
//			return false;
//		}
//
//		CSkillInstServer* pSkillInst = new CSkillInstServer(aStateDBData.m_uSkillLevel,
//			aStateDBData.m_sSkillName, aStateDBData.m_eAttackType, aStateDBData.m_bIsDot);
//
//		int32 iLeftSecond = aStateDBData.m_iRemainTime == -1 ? -1 : aStateDBData.m_iRemainTime / 1000 + 1; //�ָ�Ҫ���겻��ģ��������һ��DOT
//		RestoreSpecialStateFromDB(pSkillInst, pCfg, aStateDBData.m_bFromEqualsOwner ? m_pOwner : NULL,
//			iLeftSecond);
//		cout << "�����ݿ��������״̬[" << pCfg->GetName() << "]\n";
//	}
//
//	return true;
//}
//
//
//CAllStateMgrServer* CSpecialStateMgrServer::GetAllMgr()
//{
//	return m_pOwner->GetAllStateMgr();
//}


bool CSpecialStateMgrServer::RestoreStateFromDB(CSkillInstServer* pSkillInst, const CSpecialStateCfgServerSharedPtr& pCfg,
	CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime, uint32 uAccumulate, float fProbability)
{
	return RestoreStateFromDB(pSkillInst, pCfg, pInstaller, iTime, iRemainTime);
}

CStateDBData* CSpecialStateMgrServer::CreateStateDBData(CSpecialStateBase* pState, int32 iRemainTime, CSkillInstServer* pInst)
{
	return new CStateDBData(pState->GetCfgSharedPtr()->GetGlobalType(),
		pState->GetCfgSharedPtr()->GetName(), pState->m_iTime, iRemainTime, 0, 0.0f,
		0, 0, 0, pInst->GetSkillLevel(),
		pInst->GetSkillName().c_str(),
		pInst->GetAttackType(),							//���������ֱ�Ӹ���ָ��ģ�ҪС�ģ������Ƿ��Ƹ�����
		pInst->GetInterval(),
		pState->GetInstaller() == m_pOwner);
}

