#pragma once
#include "CTriggerableStateMgr.h"
#include "CTriggerStateCfg.h"
#include "CCumuliTriggerStateCfg.h"
#include "CFighterDictator.h"
#include "CSkillInstServer.h"
#include "ErrLogHelper.h"
#include "CTriggerEvent.h"
#include "CAllStateMgr.h"
#include "CConnServer.h"
#include "DebugHelper.h"
#include "BaseHelper.h"

template<typename CfgType, typename StateType>
bool TTriggerableStateMgrServer<CfgType, StateType>::SetupState(CSkillInstServer* pSkillInst, const SharedPtrType& pCfg, CFighterDictator* pInstaller)
{
	if (!this->m_pOwner)
	{
		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
		//return false;
	}
	//typename CfgType::SharedPtrType& pCfg = CfgType::Get(name);

	//���߼���
	CAllStateMgrServer* pAllMgr = this->GetAllMgr();
	if(pAllMgr->Immume(pCfg.get(), pSkillInst, pInstaller))
	{
		return false;
	}

	//�����Լ���
	if(pAllMgr->DecreaseStateResist(pCfg.get())) return false;

	//����״̬�滻����
	if(!pAllMgr->ReplaceModelState(pCfg.get())) return false;

	typename MapState::iterator mapStateItr = this->m_mapState.find(pCfg.get());

	if (mapStateItr == this->m_mapState.end())
	{
#ifdef COUT_STATE_INFO
		cout << this->m_pOwner->GetEntityID() << " ��װ" << pCfg->GetTypeName() << "��" << pCfg->GetName() << endl;
#endif

		//��װһ���µ�ħ��״̬ʱ�Ż��ӡս����Ϣ, ���ӻ��滻ʱ����ӡ
		pAllMgr->PrintFightInfo(true, pInstaller ? pInstaller->GetEntityID() : 0, pCfg.get());

		//����һ���µĴ�����ħ��״̬
		StateType* pNewState = new StateType(pSkillInst, pInstaller, this, pCfg);
		pNewState->m_uDynamicId = pAllMgr->AddStateByDId(pNewState);

		//״̬Ԫ�ز����������TriggerStateӳ��
		pair<typename MapState::iterator, bool> pr = this->m_mapState.insert(make_pair(pCfg.get(), pNewState));

		//����TriggerState������
		typename MapState::iterator mapStateItr = pr.first;
		StateType* pState = mapStateItr->second; 
		pState->m_mapStateItr = mapStateItr;

		switch(pCfg->GetTriggerEvent())
		{
		case eSET_InstallerDie:
			pInstaller->Attach(pState, eCE_Die);
			break;
		case eSET_KillByInstaller:
			this->m_pOwner->Attach(pState, eCE_Die);
			break;
		default:
			{
				this->RegisterEvent(pState, pCfg->GetTriggerEvent());
			}
		}

		//pState->Start();
		pState->StartTime();

		//����ħ��״̬�����ģ�ͺ���Ч�ص�
		uint32 uId = pCfg->GetId();
		pAllMgr->OnSetState(uId, pState->m_uDynamicId, 1, pState->m_iTime,
			pState->m_iRemainTime, pState->m_pSkillInst->GetSkillLevel(), pState->GetInstallerID());

		pState->StartDo();

		return true;
	}
	else
	{
		//�ȼ�������ԭ��ħ��״̬�ĵȼ�������滻����
		StateType* pState = mapStateItr->second;
		if (pSkillInst->GetSkillLevel() >= pState->m_uGrade)
		{
			return pState->Replace(pSkillInst, pInstaller);
		}
		else
		{
			return false;
		}
	}
}

template<typename CfgType, typename StateType>
bool TTriggerableStateMgrServer<CfgType, StateType>::RestoreStateFromDB(CSkillInstServer* pSkillInst, const SharedPtrType& pCfg,
	CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime, uint32 uAccumulate, float fProbability)
{
	if (!this->m_pOwner)
	{
		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
		//return false;
	}

	typename MapState::iterator mapStateItr = this->m_mapState.find(pCfg.get());
	if (mapStateItr == this->m_mapState.end())
	{
#ifdef COUT_STATE_INFO
		cout << "��װ������״̬��" << pCfg->GetName() << endl;
#endif

		//����һ���µĴ�����ħ��״̬
#ifdef COUT_STATE_INFO
		cout << this->m_pOwner->GetEntityID() << ": �ָ���" << pCfg->GetTypeName() << " : " << pCfg->GetName() << endl;
#endif

		StateType* pNewState = new StateType(pSkillInst, pInstaller, this, pCfg, uAccumulate, iTime, iRemainTime, fProbability);
		pNewState->m_uDynamicId = this->GetAllMgr()->AddStateByDId(pNewState);

		//״̬Ԫ�ز����������TriggerStateӳ��
		pair<typename MapState::iterator, bool> pr = this->m_mapState.insert(make_pair(pCfg.get(), pNewState));

		//����TriggerState������
		typename MapState::iterator mapStateItr = pr.first;
		StateType* pState = mapStateItr->second;
		pState->m_mapStateItr = mapStateItr;

		switch(pCfg->GetTriggerEvent())
		{
		case eSET_InstallerDie:
			Ast(pInstaller);
			pInstaller->Attach(pState, eCE_Die);
			break;
		case eSET_KillByInstaller:
			this->m_pOwner->Attach(pState, eCE_Die);
			break;
		default:
			{
				this->RegisterEvent(pState, pCfg->GetTriggerEvent());
			}
		}

		//pState->Start(true);
		pState->StartTime(true);

		//����ħ��״̬�����ģ�ͺ���Ч�ص�
		uint32 uId = pCfg->GetId();
		this->GetAllMgr()->OnSetState(uId, pState->m_uDynamicId, 1, pState->m_iTime, pState->m_iRemainTime,
			pState->m_pSkillInst->GetSkillLevel(), pState->GetInstallerID());

		pState->StartDo(true);
		return true;
	}
	else
	{
		//�ָ�������״̬���ܳ����ظ����ֵ�״̬
		stringstream ExpStr;
		ExpStr << "�ָ�������״̬[" << pCfg->GetName() << "]���ܳ����ظ����ֵ�״̬\n";
		GenErr("�ָ�������״̬���ܳ����ظ����ֵ�״̬", ExpStr.str());
		return false;
	}
}

template<typename CfgType, typename StateType>
void TTriggerableStateMgrServer<CfgType, StateType>::ClearAll()
{
	this->m_mapStateBundleByEvent.clear();
	CAllStateMgrServer* pAllMgr = this->GetAllMgr();
	for(typename MapState::iterator itrState = this->m_mapState.begin(); itrState != this->m_mapState.end(); ++itrState)
	{
		StateType* pState = itrState->second;
		SharedPtrType& pCfg = pState->GetCfgSharedPtr();
		uint32 uDynamicId = pState->m_uDynamicId;
		pState->CancelDo();
		//����Ҫ�����Ƿ���pState����Ч��
		this->GetOwner()->UnRegistDistortedTick(pState);

		if(pCfg->GetTriggerEvent() == eSET_InstallerDie)
		{
			CFighterDictator* pFighter = pState->GetInstaller();
			if(pFighter)
			{
				//��ΪitrState->second��Ҫɾ���ģ����Բ���Ҫ��ִ��һ��Detach�����򷴶����ܻ���Ϊm_pInstaller����������
				pFighter->Detach(pState, eCE_Die);
			}
		}

		uint32 uId = pCfg->GetId();
		pAllMgr->OnDeleteState(uId, uDynamicId);
		pAllMgr->DelStateByDId(uDynamicId);

		////ΪClearAll����;CancelDo����õ�ExistState�Ⱥ���׼���ģ�ExistState�Ⱥ���Ҫ���itr->second != NULL��
		//if (pState->m_mapStateItr != m_mapState.end()) pState->m_mapStateItr->second = NULL;

#ifdef COUT_STATE_INFO
		cout << "�ⲿ����ClearAll��ɾ������" << pCfg->GetTypeName() << endl;
#endif
	}
	ClearMap(this->m_mapState);
}

template<typename CfgType, typename StateType>
CStateDBData* TTriggerableStateMgrServer<CfgType, StateType>::CreateStateDBData(StateType* pState, int32 iRemainTime, CSkillInstServer* pInst)
{
	return new CStateDBData(pState->GetCfgSharedPtr()->GetGlobalType(),
		pState->GetCfgSharedPtr()->GetName(),			//���������ֱ�Ӹ���ָ��ģ�ҪС�ģ������Ƿ��Ƹ�����
		pState->m_iTime, iRemainTime, pState->m_uAccumulate, pState->m_fProbability, 
		0, 0, 0, pInst->GetSkillLevel(),
		pInst->GetSkillName().c_str(),			//���������ֱ�Ӹ���ָ��ģ�ҪС�ģ������Ƿ��Ƹ�����
		pInst->GetAttackType(),
		pInst->GetInterval(),
		pState->GetInstaller() == this->m_pOwner);
}

template<typename CfgType, typename StateType>
uint32 TTriggerableStateMgrServer<CfgType, StateType>::TriggerCount(const string& name)
{
	typename MapState::iterator itr = this->m_mapState.find(CfgType::Get(name).get());
	if(itr != this->m_mapState.end())
	{
		return itr->second->GetValue();
	}
	else
	{
		return 0;
	}
}

template<typename CfgType, typename StateType>
bool TTriggerableStateMgrServer<CfgType, StateType>::SetAccumulate(const string& name, uint32 uValue)
{
	typename MapState::iterator itr = this->m_mapState.find(CfgType::Get(name).get());
	if(itr != this->m_mapState.end())
	{
		itr->second->SetAccumulate(uValue);
		return true;
	}
	else
	{
		return false;
	}
}
