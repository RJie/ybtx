#include "stdafx.h"
#include "CBattleStateManager.h"
#include "IFighterServerHandler.h"
#include "CCharacterDictator.h"
#include "CTriggerEvent.h"
#include "CServantServerMgr.h"
#include "BaseHelper.h"
#include "CFighterMediator.h"

CBattleStateManager::CBattleStateManager(CFighterDictator* pFighter)
:m_pFighter(pFighter)
,m_pTick(NULL)
,m_bBattleWithPlay(false)
,m_nBattleStateCount(0)
{
	m_pTick = new CLeaveBattleTick(pFighter);
}

CBattleStateManager::~CBattleStateManager()
{
	UnRegOutBattleTick();
	SafeDelete(m_pTick);
}

bool CBattleStateManager::EnterBattleStateByPlayer()
{
	if (!m_pFighter->GetCtrlState(eFCS_InBattle))
	{
		EnterBattleState();
		m_bBattleWithPlay = true;
		RegOutBattleTick();
		return true;
	}
	else
	{
		RegOutBattleTick();
		return false;
	}	
}

void CBattleStateManager::LeaveBattleStateByForce()
{
	UnRegOutBattleTick();
	m_bBattleWithPlay = false;
	m_nBattleStateCount = 0;
	LeaveBattleState();
}

void CBattleStateManager::AddBattleRefByNpc()
{
	++m_nBattleStateCount;
	if (!m_pFighter->GetCtrlState(eFCS_InBattle))
		EnterBattleState();
}

void CBattleStateManager::DelBattleRefByNpc()
{
	if (!m_pFighter->CppIsAlive())
		return;
	--m_nBattleStateCount;
	if (!GetFinalBattleState())
		LeaveBattleState();
}

void CBattleStateManager::LeaveBattleStateOnTick()
{
	UnRegOutBattleTick();
	m_bBattleWithPlay = false;

	if (!GetFinalBattleState())
	{
		LeaveBattleState();
		NotifyServantLeaveBattle();
	}
}

void CBattleStateManager::LeaveBattleStateByDead()
{
	if(m_pFighter->GetCtrlState(eFCS_InBattle))
	{
		//cout << "�ɹ�";
		m_pFighter->CppSetCtrlState(eFCS_InBattle, false);
		if (m_pFighter->CastToFighterMediator())
		{
			m_pFighter->CastToFighterMediator()->OnBattleStateChanged(false);
		}
		m_pFighter->GetHandler()->OnLeaveBattleState();

		if(m_pFighter->IsAttacking())
			m_pFighter->CancelAttack(true);

		CTriggerEvent::MessageEvent(eTST_Trigger, m_pFighter, NULL, eSET_LeftBattle);
	}
}

bool CBattleStateManager::GetFinalBattleState() const
{
	if (!m_bBattleWithPlay && m_nBattleStateCount == 0)
	{
		return false;
	}
	else
	{
		//if (m_nBattleStateCount < 0)
			//��ʱ�ر�ս��״̬���������ڵ�ս��״̬��������֧���ٻ��ޣ����ع�
			//cout << "~~~~~~~~~ NPCս��״̬�������� Count:" << m_nBattleStateCount << endl;
		return true;
	}
}

void CBattleStateManager::EnterBattleState()
{
	//cout << m_pFighter->GetEntityID() << "����ս��״̬"<<endl;
	if(!m_pFighter->GetCtrlState(eFCS_InBattle))
	{
		m_pFighter->CppSetCtrlState(eFCS_InBattle, true);
		if (m_pFighter->CastToFighterMediator())
		{
			m_pFighter->CastToFighterMediator()->OnBattleStateChanged(true);
		}
		m_pFighter->GetHandler()->OnEnterBattleState();

		NotifyServantEnterBattle();
		CTriggerEvent::MessageEvent(eTST_Trigger, m_pFighter, NULL, eSET_EnterBattle);	
	}
}

void CBattleStateManager::LeaveBattleState()
{
	//cout << m_pFighter->GetEntityID() << "�뿪ս��״̬"<<endl;
	if(m_pFighter->GetCtrlState(eFCS_InBattle))
	{
		//cout << "�ɹ�";
		m_pFighter->CppSetCtrlState(eFCS_InBattle, false);
		if (m_pFighter->CastToFighterMediator())
		{
			m_pFighter->CastToFighterMediator()->OnBattleStateChanged(false);
		}
		m_pFighter->GetHandler()->OnLeaveBattleState();

		if(m_pFighter->IsAttacking())
			m_pFighter->CancelAttack(false);

		NotifyServantLeaveBattle();
		CTriggerEvent::MessageEvent(eTST_Trigger, m_pFighter, NULL, eSET_LeftBattle);	
	}

	if (m_pFighter->CppIsAlive())
	{
		m_pFighter->m_HealthPoint.ResetRenewHP(m_pFighter);

		if (eCL_Warrior == m_pFighter->CppGetClass() || eCL_OrcWarrior == m_pFighter->CppGetClass())
			m_pFighter->m_RagePoint.ResetReduceRP(m_pFighter);
		else
			m_pFighter->m_ManaPoint.ResetRenewMP(m_pFighter);		
	}
}

void CBattleStateManager::RegOutBattleTick()
{
	UnRegOutBattleTick();
	m_pFighter->RegistDistortedTick(m_pTick, 6000);
}

void CBattleStateManager::UnRegOutBattleTick()
{
	m_pFighter->UnRegistDistortedTick(m_pTick);
}

void CLeaveBattleTick::OnTick()
{
	m_pFighter->GetBattleStateMgr()->LeaveBattleStateOnTick();
}

void CBattleStateManager::NotifyServantEnterBattle()
{
	CCharacterDictator* pCharacter = m_pFighter->GetCharacter();
	if (!pCharacter)
		return;
	CServantServerMgr* pServantMgr = pCharacter->GetServantMgr();
	if(pServantMgr)	
	{
		const CServantServerMgr::ServantIDMapType& ServantMap = pServantMgr->GetServantIDMapType();
		CServantServerMgr::ServantIDMapType::const_iterator it = ServantMap.begin();
		for(;it!=ServantMap.end();)
		{
			CCharacterDictator* pServant = (*it).second;
			++it;
			{
				if (pServant && pServant->GetNpcAIHandler())
				{
					CFighterDictator* pServantFighter = pServant->GetFighter();
					CBattleStateManager* pServantBattleStateMgr = pServantFighter->GetBattleStateMgr();
					pServantBattleStateMgr->EnterBattleState();
				}
			}
		}
	}
}

void CBattleStateManager::NotifyServantLeaveBattle()
{
	CCharacterDictator* pCharacter = m_pFighter->GetCharacter();
	if (!pCharacter)
		return;
	CServantServerMgr* pServantMgr = pCharacter->GetServantMgr();
	if(pServantMgr)	
	{
		const CServantServerMgr::ServantIDMapType& ServantMap = pServantMgr->GetServantIDMapType();
		CServantServerMgr::ServantIDMapType::const_iterator it = ServantMap.begin();
		for(;it!=ServantMap.end();)
		{
			CCharacterDictator* pServant = (*it).second;
			++it;
			{
				if (pServant && pServant->GetNpcAIHandler())
				{
					//�������첽֪ͨ���̣���ֹ�ѳ���б�д��
					pServant->GetNpcAIHandler()->MasterNotifyLeaveBattle();	
					CFighterDictator* pServantFighter = pServant->GetFighter();
					CBattleStateManager* pServantBattleStateMgr = pServantFighter->GetBattleStateMgr();
					pServantBattleStateMgr->LeaveBattleState();
				}
			}
		}
	}
}

