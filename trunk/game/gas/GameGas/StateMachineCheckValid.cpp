#include "stdafx.h"
#include "StateMachineCheckValid.h"
#include "CCharacterDictator.h"
#include "CGameConfigServer.h"
#include "TimeHelper.h"
#include "CCoreSceneServer.h"

template class TPtRefer<StateMachineCheckValid, CNpcAI>;

StateMachineCheckValid::StateMachineCheckValid(CNpcAI* pAI)
:m_pAI(pAI)
,m_uLasteTime(GetHDProcessTime())
,m_uCycNum(0)
,m_bMayDeadCycState(false)
,m_sErrLog("")
{
	m_RefOfAI.SetHolder(this);
}

StateMachineCheckValid::~StateMachineCheckValid()
{
}

TPtRefee<StateMachineCheckValid, CNpcAI>& StateMachineCheckValid::GetRefByNpcAI()
{
	return m_RefOfAI;
}

void StateMachineCheckValid::CheckValid(CNpcEventMsg* pEvent)
{
	if(m_pAI && m_pAI->GetCharacter())
	{
		CCharacterDictator* pCharacter = m_pAI->GetCharacter();
		uint32 uStep = CGameConfigServer::Inst()->GetStateMachineCycCheckStep();
		uint32 uCheckTime =  CGameConfigServer::Inst()->GetStateMachineCycTimeLimit();
		bool bMayDeadCyc;	
		uint64 uCurTime = GetHDProcessTime();
		(uCurTime - m_uLasteTime) < uCheckTime ? bMayDeadCyc = true : bMayDeadCyc = false;
		if (m_bMayDeadCycState && bMayDeadCyc)
		{
			m_uCycNum ++;
			if (m_uCycNum > uStep && m_uCycNum <= (uStep + 20))
			{
				ostringstream strm;
				strm<<"���ò��裺��"<<m_uCycNum - uStep<<"�� "<<"ͨ����Ϣ:��"<<pEvent->GetName()<<"�� �л���״̬��"<<m_pAI->GetCurrentStateName()<<"��";
#ifdef NpcEventCheck
				strm<<"��Ϣ����λ��: ��" << (uint32)pEvent->GetCodeIndex() << "��" <<endl;
#else
				strm<<endl;
#endif
				m_sErrLog = m_sErrLog + strm.str();
			}
			if (m_uCycNum > (uStep + 21))
			{
				string strErrType = "Npc״̬�л���ѭ����";
				CFPos ownerpos = pCharacter->GetPixelPos();
				ostringstream strm1;
				strm1<<"������"<<pCharacter->GetScene()->GetSceneName()<<"������Ϊ��"<< pCharacter->GetNpcName() <<"����Npc״̬�л�����Ƶ��!���꡾"<<ownerpos.x<<"��"<<ownerpos.y<<"��"<<endl;
				LogErr(strErrType.c_str(), (strm1.str() + m_sErrLog).c_str());
				DoAction();
			}
		}
		else
		{
			m_uCycNum = 0;
			m_sErrLog.clear();
		}
		m_bMayDeadCycState = bMayDeadCyc;
		m_uLasteTime = uCurTime;
	}
}

void StateMachineCheckValid::DoAction()
{
	if(m_pAI && m_pAI->GetCharacter())
	{
		CCharacterDictator* pCharacter = m_pAI->GetCharacter();
		pCharacter->SetOnDead();
	}
}
