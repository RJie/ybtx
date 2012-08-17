#include "stdafx.h"
#include "CTriggerableState.h"
#include "CSkillInstServer.h"
#include "CAllStateMgr.h"
#include "CFighterDictator.h"
#include "CCfgCalc.inl"
#include "CTriggerEvent.h"
#include "COtherStateMgr.inl"
#include "BaseHelper.h"
#include "FighterProperty.inl"
#include "DebugHelper.h"
#include "CGenericTarget.h"
#include "CMagicEffDataMgrServer.h"









CTriggerableStateServer::CTriggerableStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
	uint32 uAccumulate, int32 iTime, int32 iRemainTime, float fProbability)
:CBaseStateServer(pSkillInst, pInstaller, iTime, iRemainTime)
, m_uGrade(pSkillInst->GetSkillLevel())
, m_uAccumulate(uAccumulate)
, m_fProbability(fProbability)
, m_bEndByCount(false)
, m_bEndByTime(false)
, m_bCancellationDone(false)
, m_bTriggering(false)
, m_pCancelEffData(NULL)
{
	CreateInst(pSkillInst);
	m_pSkillInst->AddRef();			//�ɴ���״̬�����ϲ�����ı��ֵ��������ﲻ��ҪCreateTransfer()����������Ҫ
	SetInstaller(pInstaller);
}




bool CTriggerableStateServer::Replace(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller)
{
	m_uAccumulate = 0;						//uAccumulate�ĸ���

#ifdef COUT_STATE_INFO
	cout << "״̬�滻\n";
#endif

	CancelDo();

	if(class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetTriggerEvent() == eSET_InstallerDie)
	{
		//��ΪitrPTS->second��Ҫɾ���ģ����Բ���Ҫ��ִ��һ��Detach�����򷴶����ܻ���Ϊm_pInstaller����������
		CFighterDictator* pFighter = GetInstaller();
		if(pFighter)
		{
			pFighter->Detach(this, eCE_Die);
		}
		pInstaller->Attach(this, eCE_Die);
	}

	m_pSkillInst->DelRef();
	DeleteInst();							//����m_pCancelableInst


	//ԭ����������Ҫִ�й��캯�����һ�й��ܣ����˾�̬����Ĳ��֣����绻ģ�͡����ñ��Լ�һЩ���Լ򻯵Ĳ��裨����ɾ���ٰ�װ��Ч���Լ򻯳�һ�θı���Ч��


	m_pSkillInst = pSkillInst;
	CreateInst(pSkillInst);					//����m_pCancelableInst

	m_pSkillInst->AddRef();					//m_pSkillInst�ĸ���
	ChangeInstaller(pInstaller);			//m_pInstaller�ĸ���
	m_uGrade = pSkillInst->GetSkillLevel();	//m_uGrade�ĸ���
	m_bEndByCount = false;					//m_bEndByCount�ĸ���
	m_bEndByTime = false;					//m_bEndByTime�ĸ���
	m_bCancellationDone = false;			//m_bCancellationDone�ĸ���
	m_bTriggering = false;


	//StartDo();								//m_fProbability�ĸ���
	RefreshTime();							//m_iTime��m_iRemainTime�ĸ���
	GetAllMgr()->OnSetState(class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetId(), m_uDynamicId, 1, m_iTime,
		m_iRemainTime, m_pSkillInst->GetSkillLevel(), GetInstallerID());

	StartDo();								//m_fProbability�ĸ���
	return true;
}

//void CTriggerableStateServer::Start(bool bFromDB)			//ֻ���½�ħ��״̬����ʱִ��һ��
//{
//#ifdef COUT_STATE_INFO
//	cout << "�½�ħ��״̬����ʼ��ʱ\n";
//#endif
//
//	StartTime(bFromDB);
//	StartDo(bFromDB);
//}

void CTriggerableStateServer::StartDo(bool bFromDB)
{
	GetAllMgr()->ChangeSizeRate(GetCfg(), 1);
	if(!bFromDB)
	{
		m_fProbability = float(class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetProbability()->GetDblValue(GetInstaller(), m_pSkillInst->GetLevelIndex()));
	}
	DoCancelableMagicEff(bFromDB);
}

void CTriggerableStateServer::CancelDo()
{
	if(m_bCancellationDone) return;
	m_bCancellationDone = true;

	GetAllMgr()->ChangeSizeRate(GetCfg(), -1);
	CancelCancelableMagicEff();
}

void CTriggerableStateServer::StartTime(bool bFromDB)
{
	if(!bFromDB)
	{
		m_iTime = class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetTime()->GetIntValue(GetInstaller(), GetOwner(), m_pSkillInst->GetLevelIndex());

		if (GetInstaller() != GetOwner() && (m_iTime != -1))
		{
			switch(class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetDecreaseType())
			{
			case eDST_Control:
				m_iTime = uint32(m_iTime * GetOwner()->m_ControlDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			case eDST_Pause:
				m_iTime = uint32(m_iTime * GetOwner()->m_PauseDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			case eDST_Crippling:
				m_iTime = uint32(m_iTime * GetOwner()->m_CripplingDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			case eDST_Special:
				m_iTime = uint32(m_iTime * GetOwner()->m_SpecialDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			default:
				break;
			}
		}
	}

	if(m_iTime < -1)
	{
		stringstream ExpStr;
		ExpStr << "������״̬������ʱ�䲻��С��-1��" << m_iTime << endl;
		GenErr("������״̬������ʱ�䲻��С��-1", ExpStr.str());
		return;
	}
	if(!bFromDB)
	{
		m_iRemainTime = m_iTime;
	}

	m_uStartTime = GetOwner()->GetDistortedFrameTime();

	m_iInitialValue = class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetInitialValue()->GetIntValue(GetInstaller(), m_pSkillInst->GetLevelIndex());
	if(m_iInitialValue < -1)
	{
		stringstream ExpStr;
		ExpStr << "������״̬�����ô�������С��-1��" << m_iInitialValue << endl;
		GenErr("������״̬������ʱ�䲻��С��-1", ExpStr.str());
	}

	if (m_iRemainTime >= 0)
	{
#ifdef COUT_STATE_INFO
		cout << "����ʱ��Ϊ" << m_iRemainTime << "��ļ�ʱ��\n";
#endif 

		GetOwner()->RegistDistortedTick(this, m_iRemainTime * 1000);
	}
};



void CTriggerableStateServer::RefreshTime()
{
#ifdef COUT_STATE_INFO
	cout << "ˢ��ʱ��\n";
#endif

	GetOwner()->UnRegistDistortedTick(this);
	StartTime();
}

void CTriggerableStateServer::OnTick()
{
	CancelDo();

	if(m_bEndByCount)
	{
#ifdef COUT_STATE_INFO
		cout << "�򴥷����޵��˶�ɾ���Լ�\n";
#endif
	}
	else
	{
#ifdef COUT_STATE_INFO
		cout << "��ʱ�䵽�˶�ɾ���Լ�\n";
#endif

		m_bEndByTime = true;
	}


	//�����DoFinalMagicEff() == true ʱ��ʾ����Ч����Ŀ��ɱ���ˣ��򣨷����ã�״̬Ҳ��ʧ��
	//ע�⣬����״̬����class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetPersistent() == true����Ϊʱ��Ϊ���޶����������ܽ�����������˲���Ҫ���ж�
	//CTriggerableStateCfgServer* pCfg = class_cast<CTriggerableStateCfgServer*>(GetCfg());
	//if (pCfg->GetCancelableMagicEff())
	//	Ast(!pCfg->GetPersistent());
	if(DoFinalMagicEff()) return;

	//m_bEndByCount��ֵ��m_bEndByTime��ֵ��DoFinalMagicEff()�п��ܷ����仯��������Ҫ���ж�һ��
	if(m_bEndByCount || m_bEndByTime)
	{
		DeleteSelf();
	}
}

pair<bool, bool> CTriggerableStateServer::MessageEvent(uint32 uEventID, CFighterDictator * pTrigger)
{
	CGenericTarget GenTrigger(pTrigger);
	return MessageEvent(uEventID, &GenTrigger);
}

CTriggerableStateServer::~CTriggerableStateServer()
{
	SafeDelete(m_pCancelEffData);

	DeleteInst();
	m_pSkillInst->DelRef();
	//��Ҫ��������Ƿ��ܽ���
}

void CTriggerableStateServer::OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg)
{
	switch (uEvent) 
	{
	case eCE_Die:
		{
			CFighterDictator* pTrigger = class_cast<CFighterDictator *>(pSubject);
			if(pTrigger == GetInstaller())
			{
				CGenericTarget GenTrigger(pTrigger);
				MessageEvent(CTriggerEvent::GetID(eSET_InstallerDie, false), &GenTrigger);
			}
			else if(pTrigger == GetOwner())
			{
				if(static_cast<CFighterDictator *>(pArg) == GetInstaller())
				{
					CGenericTarget GenTrigger(pTrigger);
					MessageEvent(CTriggerEvent::GetID(eSET_KillByInstaller, false), &GenTrigger);
				}
			}
			break;
		}
	case eCE_Offline:
		//ClearSource();
		//m_pInstaller = NULL;
		SetInstaller(NULL);
		break;
	}
}

void CTriggerableStateServer::SetInstaller(CFighterDictator* pInstaller)
{
	//m_pInstaller = pInstaller;
	if(pInstaller)
	{
		m_uInstallerID = pInstaller->GetEntityID();
		pInstaller->Attach(this, eCE_Offline);
	}
	else
	{
		m_uInstallerID = 0;
	}
}

void CTriggerableStateServer::ChangeInstaller(CFighterDictator* pInstaller)
{
	if (pInstaller != GetInstaller())
	{
		ClearInstaller();
		SetInstaller(pInstaller);
	}
}

void CTriggerableStateServer::ClearInstaller()
{
	CFighterDictator* pInstaller = GetInstaller();
	if(pInstaller)
	{
		pInstaller->Detach(this, eCE_Offline);
		SetInstaller(NULL);
	}
}



void CTriggerableStateServer::CreateInst(CSkillInstServer* pSkillInst)
{
	//if (class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetCancelableMagicEff())
	//{
	//	m_pCancelableInst = new CMagicStateCascadeDataMgr(pSkillInst, this->GetCfg(), eMSET_TriggerableCancellable);
	//	m_pCancelableInst->SetIsCalc(false);
	//}
}

void CTriggerableStateServer::DeleteInst()
{
	//if(m_pCancelableInst)
	//{
	//	m_pCancelableInst->DelRef();
	//	m_pCancelableInst = NULL;
	//}
}

//uint32 CTriggerableStateServer::GetDynamicId()
//{
//	return class_cast<CTriggerableStateCfgServer*>(GetCfg())->GetId();
//}

void CTriggerableStateServer::SetAccumulate(uint32 uValue)
{
	m_uAccumulate = uValue;
}



