#include "stdafx.h"
#include "CAllStateMgr.h"
#include "CMagicEffServer.h"
#include "CGenericTarget.h"
#include "CQuickRand.h"
#include "CFighterDictator.h"
#include "CTempVarServer.h"
#include "CSkillInstServer.h"
#include "CCfgCalc.inl"
#include "CStateCondFunctor.h"
#include "CCumuliTriggerState.h"
#include "CCumuliTriggerStateCfg.h"
#include "CCumuliTriggerStateMgr.h"
#include "ErrLogHelper.h"
#include "BaseHelper.h"
#include "CConnServer.h"
#include "DebugHelper.h"
#include "CMagicEffDataMgrServer.h"

using namespace std;


pair<bool, bool> CCumuliTriggerStateServer::MessageEvent(uint32 uEventID, CGenericTarget * pTrigger)
{
	if(m_bEndByTime || m_bEndByCount || m_bTriggering) return make_pair(false, false);

	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	CCumuliTriggerStateMgrServer* pTempMgr = m_pMgr;
	CCumuliTriggerStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();

	CSkillInstServer * pInst = NULL;
	SQR_TRY
	{
		if(m_iInitialValue <= 0)
		{
			GenErr("���۴���״̬��m_iInitialValue����Ϊ����0");
		}

		CMagicEffServerSharedPtr pMagicEff;
		if (int32(m_uAccumulate) < m_iInitialValue)
		{
			//�����������ڴ���ʱȡֵ����ǰ�ǰ�װ״̬ʱȡֵ
			m_fProbability = float(GetCfgSharedPtr()->GetProbability()->GetDblValue(GetInstaller(), m_pSkillInst->GetLevelIndex()));

			if (CQuickRand::Rand1(0.0f, 1.0f) < m_fProbability)
			{
				int32 OldValue = GetOwner()->GetTempVarMgr()->GetVarValue(pCfg->GetTempVar());
				uint32 AbsValueChanged = abs(OldValue);// abs(NewValue - OldValue);
				m_uAccumulate += AbsValueChanged;
				uint32 uTriggerCount = m_uAccumulate / (uint32)m_iInitialValue;
				int32 iMaxNumInSingleEvent = GetCfgSharedPtr()->GetMaxNumInSingleEvent()->GetIntValue(GetInstaller(), m_pSkillInst->GetLevelIndex());

				//cout << "cu " << m_uAccumulate << " threshold " << (uint32)m_iInitialValue << endl;
				if(iMaxNumInSingleEvent > 0)
					uTriggerCount = min(uint32(iMaxNumInSingleEvent), uTriggerCount);

				m_uAccumulate %= (uint32)m_iInitialValue; 

				pMagicEff = pCfg->GetTriggerEff();
				if(pMagicEff && uTriggerCount > 0)
				{
					//CGenericTarget target; 
					//switch(pCfg->GetChangedTarget())
					//{
					//case eTC_Trigger:
					//	if(pTrigger->GetType() == eTT_Fighter)
					//		target.SetFighter(pTrigger->GetFighter());
					//	else if(pTrigger->GetType() == eTT_Position)
					//		target.SetPos(pTrigger->GetPos());				
					//	break;
					//case eTC_TargetOfTrigger:
					//	target.SetFighter(class_cast<CFighterDictator*>(pTrigger->GetFighter()->GetLockingTarget()));
					//	break;
					//case eTC_Installer:
					//	target.SetFighter(GetInstaller());
					//	break;
					//case eTC_Self:
					//	target.SetFighter(GetOwner());
					//	break;
					//case eTC_TargetOfSelf:
					//	target.SetFighter(class_cast<CFighterDictator*>(GetOwner()->GetTarget()));
					//	break;
					//case eTC_SelfCorpse:
					//	target.SetFighter(GetOwner());
					//	break;
					//default:
					//	break;
					//}

					//if(target.GetType() == eTT_Position 
					//	|| (target.GetType() == eTT_Fighter && target.GetFighter() != NULL))	// �����ߵ�Ŀ���п���ΪNULL���������ж�һ��
					//{
#ifdef COUT_STATE_INFO
						cout << "[ << pCfg->GetName() << ]����Ч��[" << pMagicEff->GetName() << "]\n";
#endif
						m_bTriggering = true;

						for(uint i = 0; i < uTriggerCount; ++i)
						{
							pInst = CSkillInstServer::CreatePartition(m_pSkillInst);
							if(pCfg->GetChangedTarget() == eTC_SelfCorpse)
								pInst->SetTargetAliveCheckIsIgnored(true);
							else
								pInst->SetTargetAliveCheckIsIgnored(false);		//��ʱ���ɴ�������������Ŀ�겻���ã�Ŀ��������ִ�еĲ������⣩

							pInst->SetTrigger(true);
							//pMagicEff->Do(pInst, GetOwner(), &target);
							pMagicEff->Do(pInst, GetInstaller(), GetOwner());

							pInst->DestroyPartition();
							pInst = NULL;

							if(pTempMgr->m_mapState.find(pCfg.get()) == pTempMgr->m_mapState.end()) 
							{
								return make_pair(true, true);
							}
						}
						m_bTriggering = false;
					//}
				}

				return make_pair(false, true);
			}
		}
	}
	SQR_CATCH(exp)
	{
		m_bTriggering = false;
		if(pInst)
		{
			pInst->DestroyPartition();
			pInst = NULL;
		}
		stringstream sErr;
		sErr << "���ڴ�����״̬[" << pCfg->GetName() << "]MessageEvent(" << uEventID << ")��";
		if(pTempMgr->m_mapState.find(pCfg.get()) == pTempMgr->m_mapState.end())
		{
			sErr << "���ڼ���[" << m_pSkillInst->GetSkillName() << "]��";
			exp.AppendMsg(sErr.str().c_str());
			//CConnServer* pConnServer = GetOwner()->GetConnection();
			//if (pConnServer)
			//	LogExp(exp, pConnServer);
			//else
			//	LogExp(exp);
		}
		else
		{
			sErr << "��״̬��������ʧ��";
			exp.AppendMsg(sErr.str().c_str());
			//LogExp(exp);
		}
		SQR_THROW(exp);
	}
	SQR_TRY_END;

	return make_pair(false, false);
}




//������CCumuliTriggerStateServer�Ĳ���
CCumuliTriggerStateServer::CCumuliTriggerStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
	TTriggerableStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>* pMgr,
	const CCumuliTriggerStateCfgServerSharedPtr& pCfg, uint32 uAccumulate, int32 iTime, int32 iRemainTime, 
	float fProbability)
: CTriggerableStateServer(pSkillInst, pInstaller, 0, iTime, iRemainTime, fProbability)
, m_pMgr(class_cast<CCumuliTriggerStateMgrServer*>(pMgr))
, m_pStateEventBundle(NULL)
, m_pCfg(new CCumuliTriggerStateCfgServerSharedPtr(pCfg))
{
	if(!GetCfgSharedPtr()->GetModelStr().empty()) GetAllMgr()->SetModelStateId(GetCfgSharedPtr()->GetId());
	if(pInstaller)
		pInstaller->Attach(this, eCE_LevelChanged);
}


CCumuliTriggerStateServer::~CCumuliTriggerStateServer()
{
	CFighterDictator* pInstaller = GetInstaller();
	if(pInstaller)
		pInstaller->Detach(this, eCE_LevelChanged);
	//�Ƿ��ǰ�ClearSource()�ĵ������ȫ���������
	GetOwner()->UnRegistDistortedTick(this);

#ifdef COUT_STATE_INFO
	cout << "ɾ��CumuliTriggerState " << GetCfgSharedPtr()->GetName() << endl;
#endif

	if(!GetCfgSharedPtr()->GetModelStr().empty()) GetAllMgr()->ClearModelStateId();
	SafeDelete(m_pCfg);
}

void CCumuliTriggerStateServer::ChangeInstaller(CFighterDictator* pInstaller)
{
	CFighterDictator* pOrinInstaller = GetInstaller();
	if(pOrinInstaller)
		pOrinInstaller->Detach(this, eCE_LevelChanged);
	if(pInstaller)
		pInstaller->Attach(this, eCE_LevelChanged);
	CTriggerableStateServer::ChangeInstaller(pInstaller);
}

void CCumuliTriggerStateServer::OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg)
{
	switch (uEvent) 
	{
	case eCE_LevelChanged:
	{
		CFighterDictator* pInstaller = GetInstaller();
		if(pInstaller)
		{
			m_pSkillInst->InitSkillLevel(pInstaller->CppGetLevel());
			m_iInitialValue = class_cast<CCumuliTriggerStateCfgServer*>(GetCfg())->GetInitialValue()->GetIntValue(pInstaller, m_pSkillInst->GetLevelIndex());
		}
		break;
	}
	default:
		break;
	}
	CTriggerableStateServer::OnCOREvent(pSubject, uEvent, pArg);
}


void CCumuliTriggerStateServer::DeleteSelf()
{
	PrepareDeleteSelf();
	DeleteItr();
	//����Ϊɾ������Ĳ�����ע�������������ĩβ
	delete this;
}

void CCumuliTriggerStateServer::DeleteSelfExceptItr()
{
	PrepareDeleteSelf();
	//����Ϊɾ������Ĳ�����ע�������������ĩβ
	delete this;
}


void CCumuliTriggerStateServer::PrepareDeleteSelf()
{
	//GetOwner()->UnRegistDistortedTick(this);

	switch(GetCfgSharedPtr()->GetTriggerEvent())
	{
	case eSET_InstallerDie:
		{
			CFighterDictator* pFighter = GetInstaller();
			if(pFighter)
			{
				//��ΪitrPTS->second��Ҫɾ���ģ����Բ���Ҫ��ִ��һ��Detach�����򷴶����ܻ���Ϊm_pInstaller����������
				pFighter->Detach(this, eCE_Die);
			}
		}
		break;
	case eSET_KillByInstaller:
		if(m_pMgr && m_pMgr->m_pOwner)
		{
			m_pMgr->m_pOwner->Detach(this, eCE_Die);
		}
		break;
	default:
		//�Զ���۲���ģʽDetach
		if (m_listStateItr != m_pStateEventBundle->m_listState.end())
			m_pStateEventBundle->m_listState.erase(m_listStateItr);
	}

	//����ȡ��ħ��״̬�����ģ�ͺ���Ч�ص�
	uint32 uId = GetCfgSharedPtr()->GetId();
	CAllStateMgrServer* pAllMgr = GetAllMgr();
	pAllMgr->OnDeleteState(uId, m_uDynamicId);
	pAllMgr->DelStateByDId(m_uDynamicId);


	//ΪClearAll����;ExistState�Ⱥ���׼���ģ�ExistState�Ⱥ���Ҫ���itr->second != NULL��
	if (m_mapStateItr != m_pMgr->m_mapState.end()) m_mapStateItr->second = NULL;

	pAllMgr->PrintFightInfo(false, GetInstallerID(), GetCfgSharedPtr().get());

	SetInstaller(NULL);
}

void CCumuliTriggerStateServer::DeleteItr()
{
	if (m_mapStateItr != m_pMgr->m_mapState.end()) m_pMgr->m_mapState.erase(m_mapStateItr);
}







CFighterDictator* CCumuliTriggerStateServer::GetOwner()
{
	return m_pMgr->m_pOwner;
}

CAllStateMgrServer* CCumuliTriggerStateServer::GetAllMgr()
{
	return m_pMgr->GetAllMgr();
}

CBaseStateCfgServer* CCumuliTriggerStateServer::GetCfg()
{
	return GetCfgSharedPtr().get();
}

CCumuliTriggerStateCfgServerSharedPtr& CCumuliTriggerStateServer::GetCfgSharedPtr()const
{
	return *m_pCfg;
}
