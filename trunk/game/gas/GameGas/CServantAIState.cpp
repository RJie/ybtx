/*
*===============================================================================================
*		
*				Author: xuyuxiang
*		
*		   Description: �ٻ���AI��Ҫ��ǿ�����԰��ٻ���״̬���庯�����������	
*
*				  ��ע����Ϊ�ٻ������Ǻ��ٻ����Լ�����һ��ɾ������������Կ��ܳ�������ָ��Ϊ�յ��������ʱӦֱ�ӷ���		
*
*===============================================================================================
*/


#include "stdafx.h"
#include "CServantAI.h"
#include "CCharacterDictator.h"
#include "NpcInfoMgr.h"

//-------------------------- Servant״̬�������� -------------------------

CServantAI* CNpcAI::CNpcStateServantBase::GetOwner() const
{
	return class_cast<CServantAI*>(CNpcStateBase::GetOwner());
}

/************************************************************************/
//			״̬��ServantDefenseState          
//			�������ٻ��ޱ�������״̬����ս���������ˣ�ս���������չ�״̬��
//		�������ͣ��ٻ���(ENpcType_Summon),��е��(ENpcType_OrdnanceMonster)
/************************************************************************/
DEFINE_NPCSTATE_METHOD(ServantDefenseState, EnterState)
{
	Ast (GetOwner());
	if (!GetOwner()->BeInCommandMoveState())
		GetOwner()->SetFollowState(true);
	CCharacterDictator* pServant = GetOwner()->GetCharacter();
	if(NULL == pServant)
		return pEvent;
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (NULL == pMaster)
		return pEvent;
}
END_DEFINE_NPCSTATE_METHOD

DEFINE_NPCSTATE_METHOD(ServantDefenseState, OnEvent)
{
	Ast (GetOwner());
	CCharacterDictator* pServant = GetOwner()->GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (!pMaster)
		return pEvent;

	switch (pEvent->GetID())
	{
	case eNpcEvent_OnMoveEnded :
		{
			pServant->SetAndSyncActionDir(pMaster->GetActionDir());
		}
		break;
	default:
		break;
	}
}
END_DEFINE_NPCSTATE_METHOD

DEFINE_NPCSTATE_METHOD(ServantDefenseState, LeaveState)
{
	GetOwner()->SetFollowState(false);
}
END_DEFINE_NPCSTATE_METHOD

/************************************************************************/
//			״̬�� ServantActiveState
//			������ �ٻ�������״̬���е��˳��������ս���������������
//		�������ͣ� ���￨(ENpcType_MonsterCard),����(ENpcType_Shadow)
/************************************************************************/
DEFINE_NPCSTATE_METHOD(ServantActiveState, EnterState)
{
	Ast (GetOwner());
	if (!GetOwner()->BeInCommandMoveState())
		GetOwner()->SetFollowState(true);
	CCharacterDictator* pServant = GetOwner()->GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (!pMaster)
		return pEvent;
	CCharacterDictator* pEnemy = GetOwner()->GetNearestVisionEnemy();
	if (!pEnemy)
		return pEvent;
	CEnmityMgr* pEnmityMgr = GetOwner()->GetEnmityMgr();
	Ast(pEnmityMgr);
	if (pEnmityMgr->AddEnemy(pEnemy, false))
	{
		uint32 uEnemyID = pEnemy->GetEntityID();
		CNpcEventMsg::Create(GetOwner(), eNpcEvent_OnServantDoAttack, eNECI_Zero, reinterpret_cast<void*>(uEnemyID));
	}	
}
END_DEFINE_NPCSTATE_METHOD

DEFINE_NPCSTATE_METHOD(ServantActiveState, OnEvent)
{
	Ast (GetOwner());
	CCharacterDictator* pServant = GetOwner()->GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (NULL == pMaster)
		return pEvent;

	switch (pEvent->GetID())
	{
		case eNpcEvent_OnMoveEnded :
			{
				pServant->SetAndSyncActionDir(pMaster->GetActionDir());
			}
			break;

		case eNpcEvent_OnCharacterInSight :
		{
			CCharacterDictator* pEnemy = CCharacterDictator::GetCharacterByID((size_t)pEvent->GetTag());
			if (NULL == pEnemy)
				return pEvent;
			INpcAIHandler* pHandler = pEnemy->GetNpcAIHandler();
			CNpcAI* pNpcAI = pHandler ? pHandler->CastToNpcAI() : NULL;
			if (pNpcAI && !pNpcAI->GetSynToClient())
				return pEvent;
			if (GetOwner()->CanFight(pEnemy) && GetOwner()->IsInLockEnemyRange(pEnemy->GetFighter()))
			{
				CEnmityMgr* pEnmityMgr = GetOwner()->GetEnmityMgr();
				Ast(pEnmityMgr);
				if (pEnmityMgr->AddEnemy(pEnemy, false))
				{
					uint32 uEnemyID = pEnemy->GetEntityID();
					CNpcEventMsg::Create(GetOwner(), eNpcEvent_OnServantDoAttack, eNECI_Zero, reinterpret_cast<void*>(uEnemyID));
				}
			}
		}	
			break;
		default:
			break;
	}
}
END_DEFINE_NPCSTATE_METHOD

DEFINE_NPCSTATE_METHOD(ServantActiveState, LeaveState)
{
	GetOwner()->SetFollowState(false);
}
END_DEFINE_NPCSTATE_METHOD

/************************************************************************/
//			״̬�� ServantPassivityState
//			������ �ٻ��ޱ���״̬��֮�������ˣ�������ս��
//		�������ͣ� ����(ENpcType_Pet),δչ�����ƶ���̨(ENpcType_Cannon)
/************************************************************************/
DEFINE_NPCSTATE_METHOD(ServantPassivityState, EnterState)
{
	Ast (GetOwner());
	if (!GetOwner()->BeInCommandMoveState())
		GetOwner()->SetFollowState(true);
}
END_DEFINE_NPCSTATE_METHOD

DEFINE_NPCSTATE_METHOD(ServantPassivityState, OnEvent)
{
	Ast (GetOwner());
	CCharacterDictator* pServant = GetOwner()->GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (NULL == pMaster)
		return pEvent;

	switch (pEvent->GetID())
	{
		case eNpcEvent_OnMoveEnded :
			{
				pServant->SetAndSyncActionDir(pMaster->GetActionDir());
			}
		default:
			break;
	}	
}
END_DEFINE_NPCSTATE_METHOD

DEFINE_NPCSTATE_METHOD(ServantPassivityState, LeaveState)
{
	GetOwner()->SetFollowState(false);
}
END_DEFINE_NPCSTATE_METHOD

