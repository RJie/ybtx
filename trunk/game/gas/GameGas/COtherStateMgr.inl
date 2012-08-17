#pragma once
#include "COtherStateMgr.h"
#include "CAllStateMgr.h"
#include "CTriggerStateCfg.h"
#include "CDamageChangeStateCfg.h"
#include "CCumuliTriggerStateCfg.h"
#include "CStateCondFunctor.h"
#include "CStateDBData.h"
#include "CSkillInstServer.h"
#include "ErrLogHelper.h"
#include "CFighterDictator.h"
#include "CConnServer.h"
#include "BaseHelper.h"

template<typename CfgType, typename StateType>
CAllStateMgrServer* TOtherStateMgrServer<CfgType, StateType>::GetAllMgr()
{
	return m_pOwner->GetAllStateMgr();
}

template<typename CfgType, typename StateType>
StateType* TOtherStateMgrServer<CfgType, StateType>::FindState(const string& name)
{
	typename MapState::iterator itr = m_mapState.find(CfgType::Get(name).get());
	if(itr != m_mapState.end())
		return itr->second;
	else
		return NULL;
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::ExistState(const string& name)
{
	return ExistState(CfgType::Get(name));
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::ExistState(const SharedPtrType& pCfg)
{
	typename MapState::iterator itr = m_mapState.find(pCfg.get());
	return itr != m_mapState.end();
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::ExistState(const SharedPtrType& pCfg, const CFighterDictator* pInstaller)
{
	typename MapState::iterator itr = m_mapState.find(pCfg.get());
	if(itr != m_mapState.end())
	{
		return itr->second->GetInstaller() == pInstaller;
	}
	else
	{
		return false;
	}
}


template<typename CfgType, typename StateType>
int32 TOtherStateMgrServer<CfgType, StateType>::StateLeftTime(const string& name)
{
	typename MapState::iterator itr = m_mapState.find(CfgType::Get(name).get());
	if(itr != m_mapState.end())
	{
		return itr->second->GetLeftTime();
	}
	else
	{
		return 0;
	}
}

template<typename CfgType, typename StateType>
void TOtherStateMgrServer<CfgType, StateType>::ClearState(const SharedPtrType& pCfg)
{
	typename MapState::iterator itrState = m_mapState.find(pCfg.get());
	if(itrState != m_mapState.end())
	{
		itrState->second->CancelDo();
		itrState->second->DeleteSelf();
	}
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::ClearStateByCond(CStateCondBase* pStateCond, uint32 uId)
{
	bool bResult = false;
	typename map<uint32, typename CfgType::SharedPtrType*, less<uint32>,
		TConfigAllocator<pair<uint32,typename CfgType::SharedPtrType*> > >::iterator itr = CfgType::m_mapCfgById.find(uId);
	if(itr != CfgType::m_mapCfgById.end())
	{
		typename MapState::iterator itrState = m_mapState.find(itr->second->get());
		if(itrState != m_mapState.end())
		{
			if((*pStateCond)(itrState->second))
			{
				itrState->second->CancelDo();
				itrState->second->DeleteSelf();
				bResult = true;
			}
			else
				return false;
		}
	}
	return bResult;
}




template<typename CfgType, typename StateType>
void TOtherStateMgrServer<CfgType, StateType>::ClearAllByCond(CStateCondBase* pStateCond)
{
	typename MapState::iterator itrState = m_mapState.begin();
	for(; itrState != m_mapState.end();)
	{
		if ((*pStateCond)(itrState->second))
		{		
			itrState->second->CancelDo();
			itrState->second->DeleteSelfExceptItr();
			m_mapState.erase(itrState++);
		}
		else
		{
			++itrState;
		}
	}
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::ExistStateByCond(CStateCondBase* pStateCond)
{
	typename MapState::iterator itrState = m_mapState.begin();
	for(; itrState != m_mapState.end(); ++itrState)
	{
		if ((*pStateCond)(itrState->second))
		{		
			return true;
		}
	}
	return false;
}

template<typename CfgType, typename StateType>
void TOtherStateMgrServer<CfgType, StateType>::SyncAllState(CFighterDictator* pObserver, uint64 uNow)
{
	int32 iRemainTime;

	CAllStateMgrServer* pAllMgr = GetAllMgr();
	for(typename MapState::iterator itr = m_mapState.begin(); itr != m_mapState.end(); itr++)
	{
		StateType* pState = itr->second;

		iRemainTime = pState->m_iRemainTime != -1 ?
			pState->m_iRemainTime - (int32(uNow - pState->m_uStartTime) + 500) / 1000 : -1;

		uint32 uId = itr->second->GetCfgSharedPtr()->GetId();
		pAllMgr->OnSetState(uId, itr->second->m_uDynamicId, 1, pState->m_iTime, iRemainTime, pState->m_pSkillInst->GetSkillLevel(), pObserver);
	}
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::SerializeToDB(CStateDBDataSet* pRet, ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID, uint64 uNow, uint32 uGrade)
{
	int32 iLeftTime;
	for(typename MapState::iterator itr = m_mapState.begin(); itr != m_mapState.end(); ++itr)
	{
		SQR_TRY
		{
			StateType* pState = itr->second;
			if((uint32)pState->GetCfgSharedPtr()->GetNeedSaveToDBType() < uGrade) continue;

			if(pState->m_iRemainTime > -1)
			{
				iLeftTime = pState->m_iRemainTime * 1000 - int32(uNow - pState->m_uStartTime);
			}
			else
			{
				iLeftTime = -1;
			}

			CSkillInstServer*& pInst = pState->m_pSkillInst;

			CStateDBData* pStateData = CreateStateDBData(pState, iLeftTime, pInst);

			//pHandler->AddStateToDB(uFighterGlobalID, eSGT_TriggerState, &aData);	
			pRet->m_pStateVec->PushBack(pStateData);

#ifdef COUT_STATEDB_INFO
			cout << pState->m_pCfg->GetTypeName() << "[" << pState->m_pCfg->GetName() << "]�������ݿ�\n";
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
	}
	return true;
}

template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::LoadFromDB(ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID)
{

	for(uint32 uStateCount = 0;; uStateCount++)
	{
		CStateDBData* pStateDBData = NULL;
		bool bRet = GetAllMgr()->ReadStateFromDB(pStateDBData, CfgType::GetStaticType());

		if(!bRet) break;

		CStateDBData& aStateDBData = *pStateDBData;

		typename CfgType::SharedPtrType& pCfg = CfgType::Get(aStateDBData.m_sName);
		bool bCatched = false;
		SQR_TRY
		{
			if(!pCfg)
			{
				stringstream ExpStr;
				ExpStr << "������״̬��ȡ����[" << aStateDBData.m_sName << "]�����������ñ�\n";
				GenErr("������״̬���ݿ��ȡ����", ExpStr.str());
			}
		}
		SQR_CATCH(exp)
		{
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
			
			uint32 uCreatorID = 0;
			if (aStateDBData.m_bFromEqualsOwner)
			{
				uCreatorID = m_pOwner->GetEntityID();
			}
			CSkillInstServer* pSkillInst = CSkillInstServer::CreateOrigin(uCreatorID,aStateDBData.m_sSkillName,aStateDBData.m_uSkillLevel, aStateDBData.m_eAttackType);
			pSkillInst->SetInterval( aStateDBData.m_bIsDot);
			int32 iLeftSecond = aStateDBData.m_iRemainTime == -1 ? -1 : aStateDBData.m_iRemainTime / 1000 + 1; //�ָ�Ҫ���겻��ģ��������һ��DOT
			SQR_TRY
			{
				RestoreStateFromDB(pSkillInst, pCfg, aStateDBData.m_bFromEqualsOwner ? m_pOwner : NULL,
					aStateDBData.m_iTime, iLeftSecond, aStateDBData.m_iCount,
					aStateDBData.m_fProbability);
#ifdef COUT_STATEDB_INFO
				cout << "�����ݿ����" << pCfg->GetTypeName() << "[" << pCfg->GetName() << "]\n";
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





template<typename CfgType, typename StateType>
bool TOtherStateMgrServer<CfgType, StateType>::MessageEvent(uint32 uEventID, CGenericTarget* pTrigger)
{
	typename MapStateBundleByEvent::iterator mapBSEBIter = m_mapStateBundleByEvent.find(uEventID);
	if (mapBSEBIter == m_mapStateBundleByEvent.end())
	{
		return false;
	}
	else
	{
		//ListState& listState = mapBSEBIter->second.m_listState;
		//typename ListBundleByEventState::iterator itrBackup;
		//for (typename ListBundleByEventState::iterator itr = listState.begin(); itr != listState.end();)
		//{
		//	itrBackup = itr;
		//	++itrBackup;
		//	(*itr)->MessageEvent(uEventID, pTrigger);
		//	itr = itrBackup;
		//}

		//��ΪMessageEvent����Ϊ����Ԥ�ƣ����ܵ��µ�ǰ��֮��ĳ����itr��ɾ�������µ�����ʧЧ����˱���
		
		ListBundleByEventState& listState = mapBSEBIter->second.m_listState;
		vector<CfgType*> vecStateCfg;
		vecStateCfg.resize(listState.size());
		typename ListBundleByEventState::iterator itrBackup;
		uint32 i = 0;
		for (typename ListBundleByEventState::iterator itr = listState.begin(); itr != listState.end(); ++itr, ++i)
		{
			vecStateCfg[i] = ((*itr)->GetCfgSharedPtr().get());
		}

		for (typename vector<CfgType*>::iterator itr = vecStateCfg.begin(); itr != vecStateCfg.end(); ++itr)
		{
			typename MapState::iterator itrState = m_mapState.find(*itr);
			if(m_mapState.find(*itr) == m_mapState.end())
			{
				continue;
			}
			else
			{
				itrState->second->MessageEvent(uEventID,pTrigger);
			}
		}

	}

	return true;
}

template<typename CfgType, typename StateType>
void TOtherStateMgrServer<CfgType, StateType>::RegisterEvent(StateType* pState, uint32 uTriggerEvent)
{
	//�Զ���۲���ģʽAttach
	typename MapStateBundleByEvent::iterator mapStateBundleItr
		= m_mapStateBundleByEvent.find(uTriggerEvent);
	if (mapStateBundleItr == m_mapStateBundleByEvent.end())
	{
		//����һ���µ��¼�������
		TStateBundleByEvent<StateType> aStateBundle;

		//״ָ̬������¼���������TriggerState�б�������EventBundle������
		pState->m_listStateItr = aStateBundle.m_listState.insert(
			aStateBundle.m_listState.end(), pState);

		//�¼������������������EventBundleӳ��
		pair<typename MapStateBundleByEvent::iterator, bool> prStateBundle = 
			m_mapStateBundleByEvent.insert(make_pair(uTriggerEvent, aStateBundle));

		//��¼�ղ����EventBundleԪ���ڹ�������λ��
		mapStateBundleItr = prStateBundle.first;

		//����EventBundle������
		pState->m_listStateItr = mapStateBundleItr->second.m_listState.begin();
	}
	else
	{
		//����϶�������mapStateBundleItr->second.m_listState.find(mapStateItr->second) != second.m_listState.end()�����
		//��ΪmapStateItr == m_mapState.end()�Ѿ��ų���
		//״ָ̬������¼���������TriggerState�б�������EventBandle������
		pState->m_listStateItr = mapStateBundleItr->second.m_listState.insert(
			mapStateBundleItr->second.m_listState.end(), pState);
	}
	//����EventBandle��ָ��
	pState->m_pStateEventBundle = &mapStateBundleItr->second;
}


