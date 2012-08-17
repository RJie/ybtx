#include "stdafx.h"
#include "CAllStateMgr.h"
#include "CTriggerState.h"
#include "CTriggerStateCfg.h"
#include "CMagicEffServer.h"
#include "CSkillInstServer.h"
#include "CQuickRand.h"
#include "CFighterDictator.h"
#include "CTriggerEvent.h"
#include "CGenericTarget.h"
#include "CCfgCalc.inl"
#include "CTriggerStateMgr.h"
#include "ErrLogHelper.h"
#include "BaseHelper.h"
#include "CConnServer.h"
#include "DebugHelper.h"
#include "CMagicEffDataMgrServer.h"

using namespace std;














bool CTriggerStateServer::DoCancelableMagicEff(bool bFromDB)
{
	CTriggerStateMgrServer* pTempMgr = m_pMgr;
	CTriggerStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();
	const CMagicEffServerSharedPtr& pMagicEff = pCfg->GetCancelableMagicEff();
	if (pMagicEff)
	{
#ifdef COUT_STATE_INFO
		cout << "ִ�пɳ���ħ��Ч��һ�Σ�" << pMagicEff->GetName() << endl;
#endif

		if(bFromDB) m_pSkillInst->SetForbitSetupSavedState(true);
		m_pSkillInst->SetStateId(GetCfgSharedPtr()->GetId());
		m_pCancelEffData = new CMagicEffDataMgrServer(GetInstaller());
		pMagicEff->Do(m_pSkillInst, GetInstaller(), GetOwner(), m_pCancelEffData);
		//������������ϵ�Do���ܵ�����������ʱҪȡ���쳣��Ϊ��㺯������
		if(!pTempMgr->ExistState(pCfg->GetName())) 
		{
			//stringstream str;
			//str << "������ħ��״̬ " << pCfg->GetName() << " ��ӵ������ִ�пɳ���ħ��Ч�� " << pMagicEff->GetName() << " ������";
			//GenErr("������ħ��״̬��ӵ������ִ�пɳ���ħ��Ч��������", str.str());
			return true;
		}
		if(bFromDB) m_pSkillInst->SetForbitSetupSavedState(false);
		m_pSkillInst->SetStateId(0);
	}
	return false; 
}

void CTriggerStateServer::CancelCancelableMagicEff()
{
	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	CTriggerStateMgrServer* pTempMgr = m_pMgr;
	CTriggerStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();

	const CMagicEffServerSharedPtr& pMagicEff = pCfg->GetCancelableMagicEff();
	if (pMagicEff)				//�ɳ���ħ��Ч��
	{
#ifdef COUT_STATE_INFO
		cout << "ȡ���ɳ���ħ��Ч��һ�Σ�" << pMagicEff->GetName() << endl;
#endif

		m_pSkillInst->SetStateId(GetCfgSharedPtr()->GetId());
		pMagicEff->Cancel(m_pSkillInst, GetOwner(), m_pCancelEffData);
		//������������ϵ�Do���ܵ�����������ʱҪȡ���쳣��Ϊ��㺯������
		if(!pTempMgr->ExistState(pCfg->GetName())) 
		{
			stringstream str;
			str << "������ħ��״̬ " << pCfg->GetName() << " ��ӵ�����ڳ����ɳ���ħ��Ч�� " << pMagicEff->GetName() << " ������";
			GenErr("������ħ��״̬��ӵ�����ڳ����ɳ���ħ��Ч��������", str.str());
		}
		m_pSkillInst->SetStateId(0);
	}
}









//������CTriggerStateServer�Ĳ���
CTriggerStateServer::CTriggerStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
	TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>* pMgr,
	const CTriggerStateCfgServerSharedPtr&	pCfg, uint32 uAccumulate, int32 iTime, int32 iRemainTime, float fProbability)
: CTriggerableStateServer(pSkillInst, pInstaller, uAccumulate, iTime, iRemainTime, fProbability)
, m_pMgr(class_cast<CTriggerStateMgrServer*>(pMgr))
, m_pStateEventBundle(NULL)
, m_pCfg(new CTriggerStateCfgServerSharedPtr(pCfg))
{
	if(!GetCfgSharedPtr()->GetModelStr().empty()) GetAllMgr()->SetModelStateId(GetCfgSharedPtr()->GetId());
}

CTriggerStateServer::~CTriggerStateServer()
{
	//�Ƿ��ǰ�ClearSource()�ĵ������ȫ���������

	GetOwner()->UnRegistDistortedTick(this);

#ifdef COUT_STATE_INFO
	cout << "ɾ��TriggerState " << GetCfgSharedPtr()->GetName() << endl;
#endif

	if(!GetCfgSharedPtr()->GetModelStr().empty()) GetAllMgr()->ClearModelStateId();
	SafeDelete(m_pCfg);
}

pair<bool, bool> CTriggerStateServer::MessageEvent(uint32 uEventID, CGenericTarget * pTrigger)
{
	if(m_bEndByTime || m_bEndByCount || m_bTriggering) return make_pair(false, false);

	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	CTriggerStateMgrServer* pTempMgr = m_pMgr;
	CTriggerStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();

	CSkillInstServer * pInst = NULL;
	SQR_TRY
	{
		CMagicEffServerSharedPtr pMagicEff;

		if (int32(m_uAccumulate) < m_iInitialValue || m_iInitialValue < 0)
		{
			//�����������ڴ���ʱȡֵ����ǰ�ǰ�װ״̬ʱȡֵ
			m_fProbability = float(GetCfgSharedPtr()->GetProbability()->GetDblValue(GetInstaller(), m_pSkillInst->GetLevelIndex()));

			if (CQuickRand::Rand1(0.0f, 1.0f) < m_fProbability)
			{
				pMagicEff = pCfg->GetTriggerEff();

				if(pMagicEff)
				{
					CGenericTarget target; 
					switch(pCfg->GetChangedTarget())
					{
					case eTC_Trigger:
						if(pTrigger->GetType() == eTT_Fighter)
							target.SetFighter(pTrigger->GetFighter());
						else if(pTrigger->GetType() == eTT_Position)
							target.SetPos(pTrigger->GetPos());				
						break;
					case eTC_TargetOfTrigger:
						target.SetFighter(class_cast<CFighterDictator*>(pTrigger->GetFighter()->GetLockingTarget()));
						break;
					case eTC_Installer:
						target.SetFighter(GetInstaller());
						break;
					case eTC_Self:
						target.SetFighter(GetOwner());
						break;
					case eTC_TargetOfSelf:
						target.SetFighter(class_cast<CFighterDictator*>(GetOwner()->GetTarget()));
						break;
					case eTC_SelfCorpse:
						target.SetFighter(GetOwner());
						break;
					default:
						break;
					}

					if(target.GetType() == eTT_Position 
						|| (target.GetType() == eTT_Fighter && target.GetFighter() != NULL))	// �����ߵ�Ŀ���п���ΪNULL���������ж�һ��
					{
#ifdef COUT_STATE_INFO
						cout << "[ << pCfg->GetName() << ]����Ч��[" << pMagicEff->GetName() << "]\n";
#endif
						pInst = CSkillInstServer::CreatePartition(m_pSkillInst);
						if(pCfg->GetChangedTarget() == eTC_SelfCorpse)
							pInst->SetTargetAliveCheckIsIgnored(true);
						else
							pInst->SetTargetAliveCheckIsIgnored(false);		//��ʱ���ɴ�������������Ŀ�겻���ã�Ŀ��������ִ�еĲ������⣩

						pInst->SetTrigger(true);
						m_bTriggering = true;
						pMagicEff->Do(pInst, GetOwner(), &target);

						pInst->DestroyPartition();
						pInst = NULL;

						if(pTempMgr->m_mapState.find(pCfg.get()) == pTempMgr->m_mapState.end()) 
						{
							return make_pair(true, true);
						}
						m_bTriggering = false;
					}
				}

				++m_uAccumulate;
				if ((int32)m_uAccumulate >= m_iInitialValue && m_iInitialValue >= 0)
				{
#ifdef COUT_STATE_INFO
				cout << "�򴥷��������˶�׼��ɾ���Լ�\n";
#endif

					//����ĳ�Ϊʵ����󴥷��Ĵ��������˺�Ч����ʹ�õ��첽����
					//DeleteSelf();
					//return make_pair(true, true);
					m_bEndByCount = true;
					GetOwner()->RegistDistortedTick(this, 0);
					return make_pair(false, true);
				}
				else
				{
					return make_pair(false, true);
				}
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

void CTriggerStateServer::DeleteSelf()
{
	PrepareDeleteSelf();
	DeleteItr();
	//����Ϊɾ������Ĳ�����ע�������������ĩβ
	delete this;
}

void CTriggerStateServer::DeleteSelfExceptItr()
{
	PrepareDeleteSelf();
	//����Ϊɾ������Ĳ�����ע�������������ĩβ
	delete this;
}


void CTriggerStateServer::PrepareDeleteSelf()
{
	//CancelDo();

	//GetOwner()->UnRegistDistortedTick(this);

	if(GetCfgSharedPtr()->GetTriggerEvent() == eSET_InstallerDie)
	{
		CFighterDictator* pFighter = GetInstaller();
		if(pFighter)
		{
			//��ΪitrPTS->second��Ҫɾ���ģ����Բ���Ҫ��ִ��һ��Detach�����򷴶����ܻ���Ϊm_pInstaller����������
			pFighter->Detach(this, eCE_Die);
		}
	}
	else if(GetCfgSharedPtr()->GetTriggerEvent() == eSET_KillByInstaller)
	{
		if(m_pMgr && m_pMgr->m_pOwner)
		{
			m_pMgr->m_pOwner->Detach(this, eCE_Die);
		}
	}
	else
	{
		//�Զ���۲���ģʽDetach
		SQR_TRY
		{
			if (m_listStateItr != m_pStateEventBundle->m_listState.end()) m_pStateEventBundle->m_listState.erase(m_listStateItr);
		}
		SQR_CATCH(exp)
		{
			stringstream sErr;
			sErr << "��m_pStateEventBundle->m_listState.erase(m_listStateItr)ʧ�ܣ�m_pStateEventBundle->m_listState.size() = " << m_pStateEventBundle->m_listState.size()
				<< "���ڴ�����״̬[" << GetCfgSharedPtr()->GetName() << "]��";
				exp.AppendMsg(sErr.str().c_str());
			SQR_THROW(exp);
		}
		SQR_TRY_END;
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

void CTriggerStateServer::DeleteItr()
{
	if (m_mapStateItr != m_pMgr->m_mapState.end()) m_pMgr->m_mapState.erase(m_mapStateItr);
}







CFighterDictator* CTriggerStateServer::GetOwner()
{
	return m_pMgr->m_pOwner;
}

CAllStateMgrServer* CTriggerStateServer::GetAllMgr()
{
	return m_pMgr->GetAllMgr();
}

CBaseStateCfgServer* CTriggerStateServer::GetCfg()
{
	return GetCfgSharedPtr().get();
}

CTriggerStateCfgServerSharedPtr& CTriggerStateServer::GetCfgSharedPtr()const
{
	return *m_pCfg;
}

