#include "stdafx.h"
#include "CServantAI.h"
#include "CFighterDictator.h"
#include "CoreCommon.h"
#include "CServantServerMgr.h"
#include "CCharacterDictator.h"
#include "CServantData.h"
#include "ICharacterDictatorCallbackHandler.h"
#include "CBattleStateManager.h"
#include "NpcInfoMgr.h"
#include "CAllStateMgr.h"
#include "BaseHelper.h"
#include "CDir.h"
#include "CCoreSceneServer.h"

class CServantBackToMaster 
	: public CDistortedTick
	, public CNpcAIMallocObject
{
public:
	CServantBackToMaster(CCharacterDictator* pServant);
	void OnTick();
private:
	CCharacterDictator* m_pServant;
};

CServantAI::CServantAI(CCharacterDictator* pCharacter, const CNpcServerBaseData* pBaseData, const CNpcStateTransit* pStateTransit, ENpcType eRealNpcType, ENpcAIType eRealAIType, EObjectAoiType eObjAoiType)
:CNpcAI(pCharacter, pBaseData, pStateTransit, eRealNpcType, eRealAIType, eObjAoiType)
,m_pBackToMaster(NULL)
,m_uAngle(-1)
,m_bFollowState(true)
,m_bCommandMoveState(false)
{
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	Ast(pMaster)
	CFighterDictator* pFighterMaster =pMaster->GetFighter();
	Ast(pFighterMaster);
	CFighterDictator* pFighterServant = pServant->GetFighter();
	Ast(pFighterServant);
	
	//��AI������������AI�����ģ�����Ҫ���³�ʼ������״̬
	pFighterServant->GetAllStateMgr()->EraseDecreaseState();

	pFighterMaster->Attach(this, eCE_BeAttacked);
	pFighterMaster->Attach(this, eCE_Attack);

	pFighterServant->Attach(this, eCE_Attack);
	pFighterServant->Attach(this, eCE_Die);

	pFighterServant->CppSetCamp(pFighterMaster->CppGetCamp());
	pFighterServant->CppSetPKState(pFighterMaster->CppGetPKState());
	//pFighterServant->CppSetZoneType(pFighterMaster->CppGetZoneType());

	if (pFighterMaster->GetCtrlState(eFCS_InDuel))
		pServant->CppSetCtrlState(eFCS_InDuel, true);

	ENpcType eType = pServant->GetNpcType();
	switch(eType)
	{
		case ENpcType_OrdnanceMonster:
		case ENpcType_Cannon:
			{
				//�������ϼ���
				ICharacterDictatorCallbackHandler* pCallbackHandler = GetCharacter()->GetCallbackHandler();
				pCallbackHandler->CreateServantSkillToMaster(pMaster, pBaseData->GetName().c_str());
				InitServantAttribute(pMaster, pServant);
			}
			break;
		default:
			{
				InitServantAttribute(pMaster, pServant);
			}
			break;
	}
	
	//�������˵Ķ��й�����
	if (NpcInfoMgr::BeFollowMaster(eType))
	{
		m_uAngle = pMaster->AddMemberToQueueMgr(pServant->GetEntityID());
		CreateFollowMasterTick();
	}
}

CServantAI::~CServantAI()
{
	ClearAllEnmity();
	DeleteNpcAIStateMachine();
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	CFighterDictator* pFighterServant = pServant->GetFighter();
	pFighterServant->Detach(this, eCE_Die);
	pFighterServant->Detach(this, eCE_Attack);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (pMaster)
	{
		pMaster->RemoveMemberFromQueueMgr(pServant->GetEntityID());
		CFighterDictator* pFighterMaster = pMaster->GetFighter();
		pFighterMaster->Detach(this, eCE_BeAttacked);
		pFighterMaster->Detach(this, eCE_Attack);
	}
		
	ENpcType eType = pServant->GetNpcType();
	switch(eType)
	{
		case ENpcType_OrdnanceMonster:
		case ENpcType_Cannon:
			{
				//ɾ���ٻ��޸������ϵļ���
				ICharacterDictatorCallbackHandler* pCallbackHandler = GetCharacter()->GetCallbackHandler();
				pCallbackHandler->DelServantSkillFromMaster(pMaster, m_pBaseData->GetName().c_str());
			}
			break;
		default:
			{
			}
			break;
	}
	DestoryFollowMasterTick();
	pServant->SetMaster(NULL);
}

void CServantAI::InitServantAttribute(CCharacterDictator* pMaster, CCharacterDictator* pServant)
{
	if (NULL == pMaster || NULL == pServant)
		return;
	CFighterDictator* pFighterMaster = pMaster->GetFighter();
	CFighterDictator* pFighterServant = pServant->GetFighter();
	if (NULL == pFighterMaster || NULL == pFighterServant)
		return;
	//�����ServantProperty_Server.ndf�������¶������ٻ��޵����ԣ�
	//�����¼�������ֵ��������ԭ��NPC�����Բ���
	SQR_TRY
	{
		const CServantData* pServantData = CServantDataMgr::GetInst()->GetEntity( m_pBaseData->GetName() );
		if (pServantData)
			pServantData->InitServantProperty(pFighterServant,pFighterMaster);
		/*pFighterServant->CppSetLevel(pFighterMaster->CppGetLevel());*/
		pFighterServant->CppSetCamp(pMaster->CppGetCamp());
		pFighterServant->CppSetGameCamp(pMaster->CppGetGameCamp());
		pFighterServant->m_HealthPoint.FullFill(pFighterServant);
	}
	SQR_CATCH(exp)
	{
		LogExp(exp);
	}
	SQR_TRY_END;
}

void CServantAI::UpdateMasterState(CPtCORSubject* pSubject, uint32 uEvent, void* pArg)
{
	if (uEvent != eCE_BeAttacked && uEvent != eCE_Attack)
		return;
	Ast (GetCharacter());
	CFighterDictator* pServantFighter = GetCharacter()->GetFighter();
	Ast(pServantFighter);
	CCharacterDictator* pMaster = GetCharacter()->GetMaster();  
	if (pMaster)
	{
		CFighterDictator* pFighterMaster = pMaster->GetFighter();
		Ast (pFighterMaster);
		if (pSubject == pServantFighter )
		{
			CFighterDictator* pEnemyFighter = NULL;
			if (uEvent == eCE_BeAttacked)
			{
				pEnemyFighter = reinterpret_cast<CFighterDictator*>(pArg);
			}
			if (uEvent == eCE_Attack)
			{
				pEnemyFighter = GetFirstEnenmyFighter();
			}
			if (!pEnemyFighter)
				return;
			CCharacterDictator* pEnemyCharacter = pEnemyFighter->GetCharacter();
			if (pEnemyCharacter && !pEnemyCharacter->GetNpcAIHandler()) //������˹����Լ����ٻ��޻����ٻ��޹������ˣ��������˵�ս��״̬
			{
				CBattleStateManager* pMasterBattleMgr = pFighterMaster->GetBattleStateMgr();
				Ast(pMasterBattleMgr);
				if(!pMaster->GetNpcAIHandler())
					pMasterBattleMgr->EnterBattleStateByPlayer();
			}
		}
	}
}

void CServantAI::OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg)
{
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	CFighterDictator* pFighterServant = pServant->GetFighter();
	Ast(pFighterServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (NULL == pMaster)
		return;
	CFighterDictator* pFighterMaster =pMaster?pMaster->GetFighter():NULL;
	UpdateMasterState(pSubject, uEvent, pArg);
	ENpcType eNpcType = pServant->GetNpcType();
	switch(eNpcType)
	{
	/************************************************************************/
	/*						�ٻ��޺�ս��������Ϣ��Ӧ����                                                                    */
	/************************************************************************/
		case ENpcType_Summon :						//���������ٻ���	
		case ENpcType_BattleHorse :					//ս������
		case ENpcType_NotCtrlSummon:
		{
			if(pMaster && pSubject == pFighterMaster)		//�ٻ��޽��յ���������Ϣ
			{
				switch( uEvent )
				{
					case eCE_BeAttacked:
					case eCE_Attack:
					{
						CFighterDictator* pEnemyFighter = reinterpret_cast<CFighterDictator*>(pArg);
						if(pEnemyFighter && pEnemyFighter->GetCharacter())
						{
							OnBeAttacked(pEnemyFighter->GetCharacter(), true);
						}
					}
					break;

					default:
						break;
				}
			}
			if(pSubject == pFighterServant)		//�ٻ����Լ�����Ϣ
			{
				switch(uEvent)
				{
					case eCE_BeAttacked:
					{
						CFighterDictator* pEnemyFighter = reinterpret_cast<CFighterDictator*>(pArg);
						if(pEnemyFighter && pEnemyFighter->GetCharacter())
						{
							OnBeAttacked(pEnemyFighter->GetCharacter(), true);
						}
					}
					break;

					case eCE_MoveEnd:
					{
						m_bCommandMoveState = false;
						pFighterServant->Detach(this, eCE_MoveEnd);
					}
					break;

					default:
						break;
				}
			}
		}		
	

	/************************************************************************/
	/*						���￨��Ϣ��Ӧ����                                                  */ 
	/************************************************************************/
		case ENpcType_MonsterCard : 
		{
			if(pSubject == pFighterServant)		
			{
				switch(uEvent)
				{
					case eCE_BeAttacked:
					{
						CFighterDictator* pFighter = (CFighterDictator*)pArg;	
						if (pFighter && pFighter->GetCharacter())
							OnBeAttacked(pFighter->GetCharacter(), true);
					}
					break;

					default:
						break;
				}
			}
		}
		break;
	
	/************************************************************************/
	/*					����Npc��Ϣ��Ӧ����                                                          */   
	/************************************************************************/
		case ENpcType_Shadow : 
		{
			if(pSubject == pFighterServant)		
			{
				switch(uEvent)
				{
					case eCE_BeAttacked:
					{
						CFighterDictator* pFighter = (CFighterDictator*)pArg;	
						if (pFighter && pFighter->GetCharacter())
							OnBeAttacked(pFighter->GetCharacter(), true);
					}
					break;
				}
			}
		}
		break;
	
	/************************************************************************/
	/*						 ��е����Ϣ��Ӧ����                                                   */         
	/************************************************************************/
		case ENpcType_OrdnanceMonster :				//��е��
			{
				if(pMaster && pSubject == pFighterMaster)		
				{
					switch( uEvent )
					{
					case eCE_BeAttacked:
					case eCE_Attack:
						{
							CFighterDictator* pEnemyFighter = reinterpret_cast<CFighterDictator*>(pArg);
							if(pEnemyFighter && pEnemyFighter->GetCharacter())
								OnBeAttacked(pEnemyFighter->GetCharacter(), true);
						}
						break;
					default:
						break;
					}
				}
				if(pSubject == pFighterServant)		
				{
					switch(uEvent)
					{
						case eCE_BeAttacked:
						{
							CFighterDictator* pFighter = (CFighterDictator*)pArg;	
							if (pFighter && pFighter->GetCharacter())
								OnBeAttacked(pFighter->GetCharacter(), true);
						}
						break;

						default:
							break;
					}
				}
			}
		break;

	/************************************************************************/
	/*						�ƶ���̨��3�����䳵��Ϣ��Ӧ����                                        */                          
	/************************************************************************/
		case ENpcType_Cannon :	
		{
		}	
		break;

	/************************************************************************/
	/*					������Ϣ��Ӧ����                                                                */  
	/************************************************************************/
		case ENpcType_Pet:
		case ENpcType_QuestBeckonNpc:
		{
		}	
		break;

	/************************************************************************/
	/*					BossС��	                                                          */ 
	/************************************************************************/
		case ENpcType_BossCortege :
		{
			if(pMaster && pSubject == pFighterMaster)	
			{
				switch( uEvent )
				{
				case eCE_BeAttacked:
				case eCE_Attack:
					{
						CFighterDictator* pEnemyFighter = reinterpret_cast<CFighterDictator*>(pArg);
						if(pEnemyFighter && pEnemyFighter->GetCharacter())
							OnBeAttacked(pEnemyFighter->GetCharacter(), true);			
					}
					break;

					default:
						break;
				}
			}
			if(pSubject == pFighterServant)	
			{
				switch(uEvent)
				{
					case eCE_Die:	//����ֻ������Npc
					{
						pMaster->GetCallbackHandler()->MasterReBornCortege(pMaster->GetEntityID(), pServant->GetEntityID());
					}
					break;
					case eCE_BeAttacked:
					{
						CFighterDictator* pFighter = (CFighterDictator*)pArg;	
						if (pFighter && pFighter->GetCharacter())
							OnBeAttacked(pFighter->GetCharacter(), true);
						if (pMaster &&pMaster->GetNpcAIHandler())
							pMaster->GetNpcAIHandler()->OnBeAttacked(pFighter->GetCharacter());
					}
					break;
				}
			}
		default:
			break;
		}		
	}
}


void CServantAI::Follow()
{
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	CFighterDictator* pServantFighter = pServant->GetFighter();
	Ast(pServantFighter);
	bool bInBattleState = pServantFighter->GetCtrlState(eFCS_InBattle);

	CCharacterDictator* pMaster = pServant->GetMaster();
	//���������Ѿ�������С�ܲ�û��ɾ��������ս��
	if (!pMaster)
		return;
	CFighterDictator* pMasterFighter = pMaster->GetFighter();
	Ast(pMasterFighter);

	CFPos servantpos;
	CFPos masterPos;
	pMaster->GetPixelPos(masterPos);
	pServant->GetPixelPos(servantpos);
	if (pServant->GetEntityDist(pMaster) <= 2.0*eGridSpanForObj) 
		return;

	float fSpeed;
	if (bInBattleState)
		fSpeed = pServantFighter->m_RunSpeed.Get(pServantFighter);
	else
		fSpeed = pMasterFighter->m_RunSpeed.Get(pMasterFighter);

	if(pMaster)
	{
		uint8 moveDir = pMaster->GetActionDir() + m_uAngle;
		CDir dirCur;
		dirCur.SetDir(moveDir);
		CVector2f vecDirf;
		dirCur.Get(vecDirf);
		CFPos DstPos;
		float fPixelDistAwayFromMaster = (pMaster->GetBottomSize() + pServant->GetBottomSize()) * eGridSpanForObj;
		DstPos.x = masterPos.x + int32(fPixelDistAwayFromMaster * vecDirf.x);
		DstPos.y = masterPos.y + int32(fPixelDistAwayFromMaster * vecDirf.y);

		CPos GDstPos;
		PixelPos2GridPos(GDstPos, DstPos);
		CCoreSceneServer* pScene = GetCharacter()->GetScene();
		EBarrierType eBarrierType = pScene->GetBarrier(GDstPos);
		if ( eBarrierType == eBT_NoBarrier || eBarrierType == eBT_LowBarrier)
			MoveToPixel(DstPos, fSpeed + 0.1f,false,0);
		else
			MoveToPixel(masterPos, fSpeed + 0.1f,false,0);
	}
}

void CServantAI::CreateFollowMasterTick()
{
	Follow();
	if (m_pBackToMaster)
	{
		GetCharacter()->UnRegistDistortedTick(m_pBackToMaster);
		SafeDelete(m_pBackToMaster);
	}
	m_pBackToMaster = new CServantBackToMaster(GetCharacter());
	GetCharacter()->RegistDistortedTick(m_pBackToMaster, 1500);
}

void CServantAI::DestoryFollowMasterTick()
{
	if (m_pBackToMaster)
	{
		GetCharacter()->UnRegistDistortedTick(m_pBackToMaster);
		SafeDelete(m_pBackToMaster);
	}
}

void CServantAI::SetFollowState(bool bFollow)
{
	m_bFollowState = bFollow;
}

bool CServantAI::GetFollowState()
{
	return m_bFollowState;
}

void CServantAI::OnMasterDestroyed()
{
	CCharacterDictator* pCharacter = GetCharacter();
	if (NULL == pCharacter)
		return;
	ENpcType eType = GetNpcType();
	switch(eType)
	{
		case ENpcType_OrdnanceMonster:
			{
				if (pCharacter->GetCallbackHandler())
				{
					pCharacter->GetCallbackHandler()->SetNpcCanBeTakeOver(pCharacter->GetEntityID(), GetRealAIType(), GetNpcType(), pCharacter->CppGetCamp());
					pCharacter->ChangeAIType( NULL, ENpcAIType_NormalInitiativePatrolNoFeferCanSeeNpc, ENpcType_Normal, pCharacter->CppGetCamp());
				}		
			}
			break;
		case ENpcType_Cannon:
			{
				if (pCharacter->GetCallbackHandler())
				{
					pCharacter->GetCallbackHandler()->SetNpcCanBeTakeOver(pCharacter->GetEntityID(), GetRealAIType(), GetNpcType(), pCharacter->CppGetCamp());
					pCharacter->ChangeAIType( NULL, ENpcAIType_Task, ENpcType_Normal, pCharacter->CppGetCamp());
				}	
			}
			break;
		case ENpcType_BossCortege:
			{
				pCharacter->SetDeadAfterBattle();
				StopFollowMaster();
				pCharacter->SetMaster(NULL);
			}
			break;
		default:
			{
			}
			break;
	}

	DestoryFollowMasterTick();
	pCharacter->SetMaster(NULL);
}

void CServantAI::StopFollowMaster()
{
	DestoryFollowMasterTick();
}

void CServantAI::OnBeAttacked(CCharacterDictator *pAttacker, bool bHurtEffect)
{
	if (!pAttacker)
		return;
	INpcAIHandler* pHandler = pAttacker->GetNpcAIHandler();
	CNpcAI* pNpcAI = pHandler ? pHandler->CastToNpcAI() : NULL;
	if (pNpcAI && !pNpcAI->GetSynToClient())
		return;
	if (!m_bCommandMoveState)
	{
		CNpcAI::OnBeAttacked(pAttacker, bHurtEffect);
	}
}

void CServantAI::Attack(CCharacterDictator* pTarget)
{
	uint32 uEntityID = 0;
	if (GetFirstEnmityEnemy())
		uEntityID = GetFirstEnmityEnemy()->GetEntityID();
	if (CanFight( pTarget))
	{
		m_bCommandMoveState = false;
		OnBeAttacked(pTarget);
		GetEnmityMgr()->ForceLock(pTarget);
		CancelCommandMove();
	}
}

void CServantAI::Retreat()
{
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	if (pServant && GetEnmityMgr())
	{
		CCharacterDictator* pMaster = pServant->GetMaster();
		if (pMaster)
		{
			if (pServant->GetEntityDist(pMaster) > 2.0*eGridSpanForObj )
			{
				CFighterDictator* pFighterServant = pServant->GetFighter();
				Ast (pFighterServant);
				m_bCommandMoveState = true;
				pFighterServant->Attach(this, eCE_MoveEnd);
			}
		}
		MasterNotifyLeaveBattle();
		Follow();
		CancelCommandMove();
		SetFollowState(true);
		//cout<<"���ˣ� "<<GetCharacter()->GetMaster()->GetEntityID()<<"  �����ٻ��ޣ� "<<GetCharacter()->GetEntityID()<<" �˳�ս����"<<endl;
	}
}

void CServantAI::Disband()
{
	//cout<<"���ˣ� "<< GetCharacter()->GetMaster()->GetEntityID()<<" �����ٻ��ޣ� "<<GetCharacter()->GetEntityID()<<" ��ɢ��"<<endl;
	//GetCharacter()->GetMaster()->RemoveServant(GetCharacter());
	GetCharacter()->SetOnDead(true);
}

void CServantAI::Spread()
{
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	Ast(pMaster);
	if (pServant && pMaster)
	{
		if (pServant->GetCallbackHandler())
		{
			pMaster->RemoveServantFromServantMgr(pServant->GetEntityID());
			pServant->ChangeAIType( pMaster, ENpcAIType_TowerAttack, ENpcType_Normal, pServant->CppGetCamp());
			//cout<<"���ˣ� "<< pMaster->GetEntityID()<<" �����ٻ��ޣ� "<<pServant->GetEntityID()<<" չ����"<<endl;
			return;	
		}
	}
}

bool CServantAI::Move(uint32 x, uint32 y)
{
	if ( x==0 && y==0)
		return false;
	CCharacterDictator* pServant = GetCharacter();
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (pMaster && pServant)
	{
		CFPos masterpos, targetpos;
		targetpos.x = (float)x;
		targetpos.y = (float)y;
		CCoreSceneServer* pScene = pServant->GetScene();
		CPos Pos;
		PixelPos2GridPos(Pos,targetpos);
		EBarrierType eBarrierType = pScene->GetBarrier(Pos);
		if ( eBarrierType != eBT_NoBarrier && eBarrierType != eBT_LowBarrier)
			return false;

		pMaster->GetPixelPos(masterpos);
		float dis = targetpos.Dist(masterpos);
		if (dis > 15.0f * eGridSpanForObj)
		{
			CancelCommandMove();
			SetFollowState(true);
			return false;
		}
		CFighterDictator* pFighterServant = pServant->GetFighter();
		Ast (pFighterServant);
		m_LastMoveCommanPos = targetpos;
		MasterNotifyLeaveBattle();
		SetFollowState(false);
		if (MoveToPixel(targetpos,false,0))
		{
			m_bCommandMoveState = true;
			pFighterServant->Attach(this, eCE_MoveEnd);
		}
	}
	return true;
}

bool CServantAI::BeInCommandMoveState()
{
	if (m_LastMoveCommanPos.x == 0 && m_LastMoveCommanPos.y == 0)
		return false;
	return true;
}

void CServantAI::MoveToLastMoveCommandPos()
{
	if (BeInCommandMoveState())
	{
		Move((uint32)m_LastMoveCommanPos.x, (uint32)m_LastMoveCommanPos.y);
	}
}

void CServantAI::CancelCommandMove()
{
	m_LastMoveCommanPos.x = 0;
	m_LastMoveCommanPos.y = 0;
}

void CServantAI::TellMasterFaceEnemy()
{
	CFighterDictator* pFighter = GetCharacter()->GetFighter();
	if (pFighter && pFighter->GetCtrlState(eFCS_ForbitTurnAround))
	{
		pFighter->RemoveFacingPair();
		return;
	}

	if(GetCharacter()->GetMaster() && GetCharacter()->CppIsLive() && GetFirstEnenmyFighter() && GetFirstEnenmyFighter()->CppIsAlive())
	{
		GetCharacter()->GetMaster()->SetAndSyncActionDirByPos(GetFirstEnenmyFighter()->GetPixelPos());
	}
}

void CServantAI::BeginChaseOriginTrace()
{
	CCharacterDictator* pServant = GetCharacter();
	Ast(pServant);
	CCharacterDictator* pMaster = pServant->GetMaster();
	if (!pMaster)
	{
		CNpcAI::BeginChaseOriginTrace();
	}
	else
	{
		float fChaseDst = static_cast<float>(GetNpcChaseEnemyDis()*eGridSpanForObj);
		pServant->Watch(this,pMaster,fChaseDst);
	}
}

CServantBackToMaster::CServantBackToMaster(CCharacterDictator* pServant)
:m_pServant(pServant)
{
}
void CServantBackToMaster::OnTick()
{
	if (!m_pServant)
	{
		m_pServant->UnRegistDistortedTick(this);
		delete this;
		return;
	}
	CCharacterDictator* pMaster = m_pServant->GetMaster();
	CServantAI* pServantAI = m_pServant->GetNpcAIHandler()->CastToServantAI();
	if (!pServantAI || !pMaster || !pMaster->CppIsLive())
	{
		m_pServant->UnRegistDistortedTick(this);
		pServantAI->m_pBackToMaster = NULL;
		delete this;
		return;
	}
	if (m_pServant->CppGetCtrlState(eFCS_ForbitMove))
		return;

	CPos masterpos, servantpos;
	pMaster->GetGridPos(masterpos);
	m_pServant->GetGridPos(servantpos);
	float dis = servantpos.Dist(masterpos);
	if (dis > 15.0f)		//����15�񣬲����ڸ�ʲô��ֱ�ӳ����������
	{
		m_pServant->StopMoving();
		m_pServant->SetGridPos(masterpos);	
		if (pServantAI->GetEnmityMgr())
			pServantAI->GetEnmityMgr()->ClearAllEnmity();
		pServantAI->CancelCommandMove();
		pServantAI->SetFollowState(true);
	}
	else
	{
		if (pServantAI->m_bFollowState)
			pServantAI->Follow();
	}
}
