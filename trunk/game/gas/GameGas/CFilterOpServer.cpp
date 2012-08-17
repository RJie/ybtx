#include "stdafx.h"
#include "CFilterOpServer.h"
#include "MagicConds_Function.h"
#include "CCharacterDictator.h"
#include "CEntityServerManager.h"
#include "CAllStateMgr.h"
#include "CMagicStateMgr.h"
#include "CTriggerStateMgr.h"
#include "CSpecialStateMgr.h"
#include "CRelationMgrServer.h"
#include "CGenericTarget.h"
#include "CCoreSceneServer.h"
#include "CSkillInstServer.h"
#include "Random.h"
#include "CMagicMgrServer.h"
#include "CPositionMagicServer.h"
#include "CPositionMagicCfgServer.h"
#include "CFighterDictator.h"
#include "CServantServerMgr.h"

void CFilterOpServer::FilterByPipe(CSkillInstServer* pSkillInst, CMagicOpTreeServer::VecEntityID& vecEntityID, vector<MagicEffFilter*> vecFilterPipe, const FilterLimit& pFilterLimit, CFighterDictator* pFrom, CGenericTarget* pTo)
{
	vector<MagicEffFilter*>::iterator it = vecFilterPipe.begin();
	if (eOF_FilterResult != (*it)->m_eObjectFilter)
	{
		pSkillInst->SetIsArea(false);
		vecEntityID.clear();
		pSkillInst->SetIsScopeTargetMop(false);
	}

	for (; it != vecFilterPipe.end(); ++it)
	{
		CFilterOpServer::FilterEntity(pSkillInst, vecEntityID, (*it), pFilterLimit, pFrom, pTo);	
	}

	// �Ƕ�ʬ�弼�����Ҫ������Ŀ�����
	if (!pFilterLimit.bTargetAliveCheckIsIgnored)
	{
		CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
		for(; it != vecEntityID.end();)
		{
			CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
			if (pCharacter && pCharacter->CppIsLive())
			{
				++it;
			}
			else
			{
				it = vecEntityID.erase(it);
			}
		}
	}
}

void CFilterOpServer::FilterEntity(CSkillInstServer* pSkillInst, CMagicOpTreeServer::VecEntityID& vecEntityID, MagicEffFilter* pMagicEffFilter, const FilterLimit& pFilterLimit, CFighterDictator* pFrom, CGenericTarget* pTo)
{
	SQR_TRY
	{
		EObjFilterType eFilterType = pMagicEffFilter->m_eObjectFilter;
		switch(eFilterType)
		{
		case eOF_Self:				// ����
			if(pFrom)
			{
				vecEntityID.push_back(pFrom->GetEntityID());
			}
			break;
		case eOF_Target:			// Ŀ��
			{
				if(pTo->GetType() != eTT_Fighter)
				{
					GenErr("Ŀ���ٴ�ɸѡ����");
				}
				CFighterDictator* pFighterTo = pTo->GetFighter();
				if(pFighterTo)
				{
					vecEntityID.push_back(pFighterTo->GetEntityID());
				}
			}
			break;
		case eOF_Position:			// �ص�
			{
				if(pTo->GetType() != eTT_Position)
				{
					GenErr("Ŀ���ٴ�ɸѡ����");
				}
			}
			break;
		case eOF_Pet:				// ����
			{
				CCharacterDictator* pMasterCharacter;
				CFighterDictator* pPet;
				CMagicOpTreeServer::VecEntityID vecMaster = vecEntityID;
				vecEntityID.clear();
				CMagicOpTreeServer::VecEntityID::iterator it = vecMaster.begin();
				for (; it != vecMaster.end(); ++it)
				{
					pMasterCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pMasterCharacter)
					{
						pPet = pMasterCharacter->GetFighter()->GetPet();
						if(pPet)
							vecEntityID.push_back(pPet->GetEntityID());
					}
				}
			}
			break;
		case eOF_NotCtrlSummon:		//�ǿ�������
			{
				CCharacterDictator* pMasterCharacter;
				CCharacterDictator* pNotCtrlSummon;
				CMagicOpTreeServer::VecEntityID vecMaster = vecEntityID;
				vecEntityID.clear();
				CMagicOpTreeServer::VecEntityID::iterator it = vecMaster.begin();
				for (; it != vecMaster.end(); ++it)
				{
					pMasterCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pMasterCharacter)
					{
						pNotCtrlSummon = pMasterCharacter->GetServantByType(ENpcType_NotCtrlSummon);
						if(pNotCtrlSummon)
							vecEntityID.push_back(pNotCtrlSummon->GetEntityID());
					}
				}
			}
			break;
		case eOF_Master:			// ����
			{
				CCharacterDictator* pPetCharacter;
				CCharacterDictator* pMasterCharacter;
				CMagicOpTreeServer::VecEntityID vecPet = vecEntityID;
				vecEntityID.clear();
				CMagicOpTreeServer::VecEntityID::iterator it = vecPet.begin();
				for (; it != vecPet.end(); ++it)
				{
					pPetCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pPetCharacter)
					{
						pMasterCharacter = pPetCharacter->GetMaster();
						if(pMasterCharacter)
							vecEntityID.push_back(pMasterCharacter->GetEntityID());
					}
				}
			}
			break;
		case eOF_Teammates:			// С�ӳ�Ա
			{
				pSkillInst->SetIsArea(true);
				pSkillInst->SetIsScopeTargetMop(true);
				float fFilterRadius = float(pMagicEffFilter->m_FilterPara->GetDblValue(pFrom, pSkillInst->GetSkillLevel() - 1));
				if(pTo->GetType() == eTT_Position)
				{
					vecEntityID.clear();
					if (pFrom && pFrom->CastToFighterMediator())
					{
						CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
						vector<CFighterDictator*>vecFighter;
						QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFrom, pTo, eSR_PlayerFriend);
						vector<CFighterDictator*>::iterator iter= vecFighter.begin();
						for(; iter!= vecFighter.end(); ++iter)
						{
							if ((*iter))
							{
								if (relationMgr.IsNotJoinTeam(pFrom))
								{
									if ((*iter) == pFrom)
									{
										vecEntityID.push_back(pFrom->GetEntityID());
									}
								}
								else
								{
									if (relationMgr.InTheSameTeam(pFrom, (*iter)))
									{
										vecEntityID.push_back((*iter)->GetEntityID());
									}
									else
									{
										CCharacterDictator* pDictator = (*iter)->GetCharacter();
										if (pDictator)
										{
											pDictator = pDictator->GetMaster();
											if (pDictator && relationMgr.InTheSameTeam(pFrom, pDictator->GetFighter()))
											{
												vecEntityID.push_back((*iter)->GetEntityID());
											}
										}
									}
								}
							}
						}
					}
				}
				else
				{
					if (vecEntityID.empty())
						break;
					if(vecEntityID.size() != 1)
					{
						GenErr(pSkillInst->GetSkillName(), " ɸѡС�ӳ�Ա֮ǰ�Ľ�����󣬷ǵ�һĿ��");
					}
			
					CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
					CCharacterDictator* pCharacterWho = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacterWho)
					{
						CCharacterDictator* pCharacterMaster = NULL;
						if (!pCharacterWho->CastToCharacterMediator())
							pCharacterMaster = pCharacterWho->GetMaster();
						else
							pCharacterMaster = pCharacterWho;

						if (pCharacterMaster && pCharacterMaster->GetFighter())
						{
							CFighterDictator* pFighterMaster = pCharacterMaster->GetFighter();
							vecEntityID.clear();
							CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
							if(relationMgr.IsNotJoinTeam(pFighterMaster))
							{
								vecEntityID.push_back(pFighterMaster->GetEntityID());
								CServantServerMgr* pServantMgr = pCharacterMaster->GetServantMgr();
								if(pServantMgr)	
								{
									const CServantServerMgr::ServantIDMapType& ServantMap = pServantMgr->GetServantIDMapType();
									CServantServerMgr::ServantIDMapType::const_iterator it = ServantMap.begin();
									for(;it!=ServantMap.end();++it)
									{
										CCharacterDictator* pServant = (*it).second;
										vecEntityID.push_back(pServant->GetEntityID());
									}
								}
							}
							else
							{
								CFPos posWho;
								CFighterDictator* pFighterWho = pCharacterWho->GetFighter();
								pFighterWho->GetPixelPos(posWho);
								CGenericTarget selfPosition(posWho);
								vector<CFighterDictator*>vecFighter;
								vecEntityID.clear();
								QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFighterMaster, &selfPosition, eSR_PlayerFriend);
								vector<CFighterDictator*>::iterator iter= vecFighter.begin();
								for(; iter!= vecFighter.end(); ++iter)
								{	
									if ((*iter))
									{
										if (relationMgr.InTheSameTeam(pFighterMaster, (*iter)))
										{
											vecEntityID.push_back((*iter)->GetEntityID());
										}
										else
										{
											CCharacterDictator* pDictator = (*iter)->GetCharacter();
											if (pDictator)
											{
												pDictator = pDictator->GetMaster();
												if (pDictator && relationMgr.InTheSameTeam(pFighterMaster, pDictator->GetFighter()))
												{
													vecEntityID.push_back((*iter)->GetEntityID());
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			break;
		case eOF_Raidmates:			// �Ŷӳ�Ա
			{
				pSkillInst->SetIsArea(true);
				pSkillInst->SetIsScopeTargetMop(true);
				float fFilterRadius = float(pMagicEffFilter->m_FilterPara->GetDblValue(pFrom, pSkillInst->GetSkillLevel() - 1));
				if(pTo->GetType() == eTT_Position)
				{
					vecEntityID.clear();
					if (pFrom && pFrom->CastToFighterMediator())
					{
						CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
						vector<CFighterDictator*>vecFighter;
						QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFrom, pTo, eSR_PlayerFriend);
						vector<CFighterDictator*>::iterator iter= vecFighter.begin();
						for(; iter!= vecFighter.end(); ++iter)
						{
							if ((*iter))
							{
								if (relationMgr.IsNotJoinTeam(pFrom))
								{
									if ((*iter) == pFrom)
									{
										vecEntityID.push_back(pFrom->GetEntityID());
									}
								}
								else
								{
									if (relationMgr.InTheSameTroop(pFrom, (*iter)))
									{
										vecEntityID.push_back((*iter)->GetEntityID());
									}
									else
									{
										CCharacterDictator* pDictator = (*iter)->GetCharacter();
										pDictator = pDictator->GetMaster();
										if (pDictator && relationMgr.InTheSameTroop(pFrom, pDictator->GetFighter()))
										{
											vecEntityID.push_back((*iter)->GetEntityID());
										}
									}
								}
							}
						}
					}
				}
				else
				{
					if (vecEntityID.empty())
						break;
					if(vecEntityID.size() != 1)
					{
						GenErr(pSkillInst->GetSkillName(), " ɸѡ�Ŷӳ�Ա֮ǰ�Ľ�����󣬷ǵ�һĿ��");
					}

					CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
					CCharacterDictator* pCharacterWho = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacterWho)
					{
						CCharacterDictator* pCharacterMaster = NULL;
						if (!pCharacterWho->CastToCharacterMediator())
							pCharacterMaster = pCharacterWho->GetMaster();
						else
							pCharacterMaster = pCharacterWho;
				
						if (pCharacterMaster && pCharacterMaster->GetFighter())
						{
							CFighterDictator* pFighterMaster = pCharacterMaster->GetFighter();
							vecEntityID.clear();
							CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
							if(relationMgr.IsNotJoinTeam(pFighterMaster))
							{
								vecEntityID.push_back(pFighterMaster->GetEntityID());
								CServantServerMgr* pServantMgr = pCharacterMaster->GetServantMgr();
								if(pServantMgr)	
								{
									const CServantServerMgr::ServantIDMapType& ServantMap = pServantMgr->GetServantIDMapType();
									CServantServerMgr::ServantIDMapType::const_iterator it = ServantMap.begin();
									for(;it!=ServantMap.end();++it)
									{
										CCharacterDictator* pServant = (*it).second;
										vecEntityID.push_back(pServant->GetEntityID());
									}
								}
							}
							else
							{
								CFPos posWho;
								CFighterDictator* pFighterWho = pCharacterWho->GetFighter();
								pFighterWho->GetPixelPos(posWho);
								CGenericTarget selfPosition(posWho);
								vector<CFighterDictator*>vecFighter;
								vecEntityID.clear();
								QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFighterMaster, &selfPosition, eSR_PlayerFriend);
								vector<CFighterDictator*>::iterator iter= vecFighter.begin();
								for(; iter!= vecFighter.end(); ++iter)
								{	
									if (relationMgr.InTheSameTroop(pFighterMaster, (*iter)))
									{
										vecEntityID.push_back((*iter)->GetEntityID());
									}
									else
									{
										CCharacterDictator* pDictator = (*iter)->GetCharacter();
										pDictator = pDictator->GetMaster();
										if (pDictator && relationMgr.InTheSameTroop(pFighterMaster, pDictator->GetFighter()))
										{
											vecEntityID.push_back((*iter)->GetEntityID());
										}
									}
								}
							}
						}
					}
				}
			}
			break;
		case eOF_Tongmates:
			{
				pSkillInst->SetIsArea(true);
				pSkillInst->SetIsScopeTargetMop(true);
				float fFilterRadius = float(pMagicEffFilter->m_FilterPara->GetDblValue(pFrom, pSkillInst->GetSkillLevel() - 1));
				if(pTo->GetType() == eTT_Position)
				{
					vecEntityID.clear();
					if (pFrom)
					{
						CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
						vector<CFighterDictator*>vecFighter;
						QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFrom, pTo, eSR_PlayerFriend);
						vector<CFighterDictator*>::iterator iter= vecFighter.begin();
						for(; iter!= vecFighter.end(); ++iter)
						{
							if ((*iter))
							{
								if (relationMgr.InTheSameToon(pFrom, (*iter)))
								{
									vecEntityID.push_back((*iter)->GetEntityID());
								}
								else
								{
									CCharacterDictator* pDictator = (*iter)->GetCharacter();
									pDictator = pDictator->GetMaster();
									if (pDictator && relationMgr.InTheSameToon(pFrom, pDictator->GetFighter()))
									{
										vecEntityID.push_back((*iter)->GetEntityID());
									}
								}
							}
						}
					}
				}
				else
				{
					if (vecEntityID.empty())
						break;
					if(vecEntityID.size() != 1)
					{
						GenErr(pSkillInst->GetSkillName(), " ɸѡӶ��С�ӳ�Ա֮ǰ�Ľ�����󣬷ǵ�һĿ��");
					}

					CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
					CCharacterDictator* pCharacterWho = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacterWho)
					{
						CCharacterDictator* pCharacterMaster = NULL;
						if (!pCharacterWho->CastToCharacterMediator())
							pCharacterMaster = pCharacterWho->GetMaster();
						else
							pCharacterMaster = pCharacterWho;

						if (pCharacterMaster && pCharacterMaster->GetFighter())
						{
							CFighterDictator* pFighterMaster = pCharacterMaster->GetFighter();
							vecEntityID.clear();
							CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
						
							CFPos posWho;
							CFighterDictator* pFighterWho = pCharacterWho->GetFighter();
							pFighterWho->GetPixelPos(posWho);
							CGenericTarget selfPosition(posWho);
							vector<CFighterDictator*>vecFighter;
							vecEntityID.clear();
							QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFighterMaster, &selfPosition, eSR_PlayerFriend);
							vector<CFighterDictator*>::iterator iter= vecFighter.begin();
							for(; iter!= vecFighter.end(); ++iter)
							{	
								if (relationMgr.InTheSameToon(pFighterMaster, (*iter)))
								{
									vecEntityID.push_back((*iter)->GetEntityID());
								}
								else
								{
									CCharacterDictator* pDictator = (*iter)->GetCharacter();
									pDictator = pDictator->GetMaster();
									if (pDictator && relationMgr.InTheSameToon(pFighterMaster, pDictator->GetFighter()))
									{
										vecEntityID.push_back((*iter)->GetEntityID());
									}
								}
							}
						
						}
					}
				}





				if (pFrom)
				{
					CFighterDictator* pFighterTo=pTo->GetFighter();
					CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
					if (pFighterTo && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
					{
						if (relationMgr.InTheSameTroop(pFrom, pFighterTo))
						{
							vecEntityID.push_back(pFighterTo->GetEntityID());
						}
						else
						{
							CCharacterDictator* pDictator = pFighterTo->GetCharacter();
							pDictator = pDictator->GetMaster();
							if (pDictator && relationMgr.InTheSameTroop(pFrom, pDictator->GetFighter()))
							{
								vecEntityID.push_back(pFighterTo->GetEntityID());
							}
						}
					}
				}
			}
			break;
		case eOF_AroundFriend:		// ��Χ�ѷ�
			{
				pSkillInst->SetIsArea(true);
				pSkillInst->SetIsScopeTargetMop(true);
				float fFilterRadius = float(pMagicEffFilter->m_FilterPara->GetDblValue(pFrom, pSkillInst->GetSkillLevel() - 1));
				if(pTo->GetType() == eTT_Position)
				{
					vecEntityID.clear();
					QueryObj(vecEntityID, pFilterLimit, fFilterRadius, pFrom, pTo, eSR_PlayerFriend);
				}
				else
				{
					if (vecEntityID.empty())
						break;
					if(vecEntityID.size() != 1)
					{
						GenErr(pSkillInst->GetSkillName(), " ɸѡ��Χ�з�֮ǰ�Ľ�����󣬷ǵ�һĿ��");
					}
					CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
					CCharacterDictator* pCharacterWho = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacterWho)
					{
						CFighterDictator* pFighterWho = pCharacterWho->GetFighter();
						if (pFighterWho)
						{
							CFPos posWho;
							pFighterWho->GetPixelPos(posWho);
							CGenericTarget position(posWho);
							vecEntityID.clear();
							QueryObj( vecEntityID, pFilterLimit, fFilterRadius, pFrom, &position, eSR_PlayerFriend);
						}
					}
				}
			}
			break;
		case eOF_AroundEnemy:		// ��Χ�з�
			{
				pSkillInst->SetIsArea(true);
				pSkillInst->SetIsScopeTargetMop(true);
				float fFilterRadius = float(pMagicEffFilter->m_FilterPara->GetDblValue(pFrom, pSkillInst->GetSkillLevel() - 1));
				if(pTo->GetType() == eTT_Position)
				{
					vecEntityID.clear();
					QueryObj(vecEntityID, pFilterLimit, fFilterRadius, pFrom, pTo, eSR_PlayerEnemy);
				}
				else
				{
					if (vecEntityID.empty())
						break;
					if(vecEntityID.size() != 1)
					{
						GenErr(pSkillInst->GetSkillName(), " ɸѡ��Χ�з�֮ǰ�Ľ�����󣬷ǵ�һĿ��");
					}
					CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
					CCharacterDictator* pCharacterWho = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacterWho)
					{
						CFighterDictator* pFighterWho = pCharacterWho->GetFighter();
						if (pFighterWho)
						{
							CFPos posWho;
							pFighterWho->GetPixelPos(posWho);
							CGenericTarget position(posWho);
							vecEntityID.clear();
							QueryObj( vecEntityID, pFilterLimit, fFilterRadius, pFrom, &position, eSR_PlayerEnemy);
						}
					}
				}
			}
			break;
		case eOF_Amount:			// ����
			{
				uint32 uMaxCount = pMagicEffFilter->m_FilterPara->GetIntValue(pFrom, pSkillInst->GetSkillLevel() - 1);
				if (pFilterLimit.bIsValueMagicOp)
				{
					if (!vecEntityID.empty())
					{
						pSkillInst->SetValueScale(min(float(uMaxCount)/float(vecEntityID.size()), 1.0f));
					}
				}
				else
				{
					uint32 uCount = vecEntityID.size();
					for (; uCount > uMaxCount; --uCount)
					{
						vecEntityID.erase(vecEntityID.begin() + (uCount-1));
					}
				}
			}
			break;
		case eOF_DeadBody:			// ʬ��
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter && !pCharacter->CppIsLive())
					{
						++it;
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_ExceptSelf:		// �Լ�����
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (!pCharacter || pFrom == pCharacter->GetFighter())
					{
						it = vecEntityID.erase(it);
					}
					else
					{
						++it;
					}
				}
			}
			break;
		case eOF_ExceptTarget:		// Ŀ�����
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (!pCharacter || (pTo && (pTo->GetFighter() == pCharacter->GetFighter())))
					{
						it = vecEntityID.erase(it);
					}
					else
					{
						++it;
					}
				}
			}
			break;
		case eOF_InTriggerState:	// ���ڴ�����״̬
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter && pCharacter->GetFighter())
					{
						CAllStateMgrServer* pStateMgr = pCharacter->GetFighter()->GetAllStateMgr();
						CTriggerStateMgrServer* pTriggerStateMgr = pStateMgr ? pStateMgr->GetTriggerStateMgrServer() : NULL;
						if (pTriggerStateMgr && pTriggerStateMgr->ExistState(pMagicEffFilter->m_FilterPara->GetString()))
						{
							++it;	
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_InMagicState:		// ����ħ��״̬
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter && pCharacter->GetFighter())
					{
						CAllStateMgrServer* pStateMgr = pCharacter->GetFighter()->GetAllStateMgr();
						CMagicStateMgrServer* pMagicStateMgr = pStateMgr ? pStateMgr->GetMagicStateMgrServer() : NULL;
						if (pMagicStateMgr && pMagicStateMgr->ExistState(pMagicEffFilter->m_FilterPara->GetString()))
						{
							++it;	
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_NotInMagicState:		// ������ħ��״̬
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter && pCharacter->GetFighter())
					{
						CAllStateMgrServer* pStateMgr = pCharacter->GetFighter()->GetAllStateMgr();
						CMagicStateMgrServer* pMagicStateMgr = pStateMgr ? pStateMgr->GetMagicStateMgrServer() : NULL;
						if (pMagicStateMgr && !pMagicStateMgr->ExistState(pMagicEffFilter->m_FilterPara->GetString()))
						{
							++it;	
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_OutSpecialState:
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter && pCharacter->GetFighter())
					{
						CAllStateMgrServer* pStateMgr = pCharacter->GetFighter()->GetAllStateMgr();
						CSpecialStateMgrServer* pSpecialStateMgr = pStateMgr ? pStateMgr->GetSpecialStateMgrServer() : NULL;
						if (pSpecialStateMgr && pSpecialStateMgr->ExistState(pMagicEffFilter->m_FilterPara->GetString()))
						{
							++it;	
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_IsVestInSelf:		// ��������
			{
				if(pFrom == NULL)
				{
					return;
				}

				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter && pCharacter->GetMaster() && pCharacter->GetMaster()->GetEntityID() == pFrom->GetEntityID())
					{
						++it;
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_ExpIsVestInSelf:	// �����������
			{
				if(pFrom == NULL)
				{
					return;
				}

				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter)
					{
						uint32 uExpOwnerID = pCharacter->GetExpOwnerID();
						CFighterDictator* pFighter = NULL;
						CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
						if(!relationMgr.IsNotJoinTeam(pFrom))
						{
							CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(uExpOwnerID);
							pFighter = pCharacter?pCharacter->GetFighter():NULL;
						}
						if (uExpOwnerID == pFrom->GetEntityID() || (pFighter && relationMgr.InTheSameTeam(pFrom, pFighter)))
						{
							++it;	
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_FilterNPC:			// ɸѡNPC
			{
				if(pFrom == NULL)
				{
					return;
				}

				const string& strNPCName = pMagicEffFilter->m_FilterPara ? pMagicEffFilter->m_FilterPara->GetString() : "";
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter)
					{
						if((!strNPCName.empty() && pCharacter->GetNpcName() == strNPCName) || (strNPCName.empty() && !pCharacter->CastToCharacterMediator()))
						{
							++it;
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_FilterPlayer:		// ɸѡ���
			{
				if(pFrom == NULL)
				{
					return;
				}

				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if(pCharacter)
					{
						if(pCharacter->CastToCharacterMediator())
						{
							++it;
						}
						else
						{
							it = vecEntityID.erase(it);
						}
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_FilterRandom:		// ���ɸѡ
			{
				if(pFrom == NULL)
				{
					return;
				}
				uint32 uRandomCount = pMagicEffFilter->m_FilterPara->GetIntValue();
				if (uRandomCount > vecEntityID.size())
				{
					return;
				}
				CMagicOpTreeServer::VecEntityID vecTempID = vecEntityID;
				vecEntityID.clear();
				while (uRandomCount > 0)
				{
					uint32 uIndex = Random::Rand(0, vecTempID.size()-1);
					vecEntityID.push_back(vecTempID[uIndex]);
					vecTempID.erase(vecTempID.begin()+uIndex);
					uRandomCount--;
				}
			}
			break;
		case eOF_PosMagicTarget:	// �ص�ħ��Ŀ��
			{
				vecEntityID.clear();
				CFighterDictator* pToFighter = pTo->GetFighter();
				if(pToFighter)
				{
					CMagicMgrServer* pMagicMgr= pToFighter->GetMagicMgr();
					if(pMagicMgr)
					{
						CPositionMagicServer* pPosMagic = pMagicMgr->GetPositionMagic();
						if(pPosMagic && pPosMagic->GetCfgSharedPtr()->GetName() == pMagicEffFilter->m_FilterPara->GetString())	//���������ID�жϣ�����SkillInst�������ID��
						{
							pPosMagic->GetTargetVector(vecEntityID);
						}
						//ע�⣬����ص�ħ�����ڿɵ��ӵ��������һ����ʧ����һ�������ڣ���ħ��������Ҫ�ṩ�������ڵ�û�����õ��Ǹ�λ��ħ���������ﳷ��
					}
				}
			}
			break;
		case eOF_LatestTarget:		// ���Ŀ��
			{
				if(pFrom == NULL)
				{
					return;
				}
				float fDistance = -1.0f;
				uint32 uEntityID = 0;
				CMagicOpTreeServer::VecEntityID::iterator itr = vecEntityID.begin();
				for (; itr!=vecEntityID.end(); ++itr)
				{
					CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter(*itr);
					if (pCharacter)
					{
						CFighterDictator* pFighter = pCharacter->GetFighter();
						float fFighterDistance = pFrom->GetFighterDist(pFighter);
						if (fDistance > fFighterDistance || fDistance == -1.0f)
						{
							fDistance = fFighterDistance;
							uEntityID = pCharacter->GetEntityID();
						}
					}
				}
				vecEntityID.clear();
				if (uEntityID != 0)
					vecEntityID.push_back(uEntityID);
			}
			break;
		case eOF_LeastHP:			// ����ֵ��С
			{
				if(pFrom == NULL)
				{
					return;
				}

				uint32 uEntityID=0;
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end(); ++it)
				{
					CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter(*it);
					CCharacterDictator* pMinHPCharacter = CEntityServerManager::GetInst()->GetCharacter(uEntityID);
					if (NULL==pCharacter || pCharacter->GetEntityID() == pFrom->GetEntityID())
					{
						continue;
					}
					if (NULL==pMinHPCharacter)
					{
						uEntityID=*it;
						continue;
					}
					CFighterDictator* pCharacterFighter = pCharacter->GetFighter();
					CFighterDictator* pMinHPCharacterFighter = pMinHPCharacter->GetFighter();
					float pCharacterHealth = float(pCharacterFighter->m_HealthPoint.LimitGet()/pCharacterFighter->m_HealthPoint.Get(pCharacterFighter));
					float pMinHPCharacterHealth = float(pMinHPCharacterFighter->m_HealthPoint.LimitGet()/pMinHPCharacterFighter->m_HealthPoint.Get(pMinHPCharacterFighter));
					if (pCharacterHealth < pMinHPCharacterHealth)
					{
						uEntityID=*it;
					}
				}
				vecEntityID.clear();
				vecEntityID.push_back(uEntityID);
			}
			break;
		case eOF_Class:				// ְҵ
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				CTestTargetClassMCOND TestTargetClass;
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter(*it);
					if (NULL==pCharacter || eDSR_Fail==TestTargetClass.Test(pSkillInst,*pMagicEffFilter->m_FilterPara,pFrom,pCharacter->GetFighter()))
					{
						vecEntityID.erase(it);
					}
					else
					{
						++it;
					}
				}
			}
			break;
		case eOF_ExceptDeadBoby:
			{
				CMagicOpTreeServer::VecEntityID::iterator it = vecEntityID.begin();
				for(; it != vecEntityID.end();)
				{
					CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter(*it);
					if (pCharacter && pCharacter->GetFighter() && pCharacter->GetFighter()->CppIsAlive())
					{
						++it;
					}
					else
					{
						it = vecEntityID.erase(it);
					}
				}
			}
			break;
		case eOF_ShockWaveEff1:
			{
				if (pSkillInst->GetShockWaveCounter() != 1)
				{
					vecEntityID.clear();
				}			
			}
			break;
		case eOF_ShockWaveEff2:
			{
				if (pSkillInst->GetShockWaveCounter() != 2)
				{
					vecEntityID.clear();
				}	
			}
			break;
		case eOF_ShockWaveEff3:
			{
				if (pSkillInst->GetShockWaveCounter() != 3)
				{
					vecEntityID.clear();
				}	
			}
			break;
		case eOF_ShockWaveEff4:
			{
				if (pSkillInst->GetShockWaveCounter() != 4)
				{
					vecEntityID.clear();
				}	
			}
			break;
		case eOF_ShockWaveEff5:
			{
				if (pSkillInst->GetShockWaveCounter() != 5)
				{
					vecEntityID.clear();
				}	
			}
			break;
		case eOF_ExpOwner:
			{
				CMagicOpTreeServer::VecEntityID vecNpc = vecEntityID;
				vecEntityID.clear();

				CCharacterDictator* pCharacter = NULL;
				CCharacterDictator* pTargetChar = NULL;
				CFighterDictator* pTarget = NULL;
				CMagicOpTreeServer::VecEntityID::iterator it = vecNpc.begin();
				for(; it != vecNpc.end(); ++it)
				{
					pCharacter = CEntityServerManager::GetInst()->GetCharacter(*it);
					if (pCharacter == NULL)
						continue;
					uint32 uTargetID = pCharacter->GetExpOwnerID();
					pTargetChar = CCharacterDictator::GetCharacterByID(uTargetID);
					pTarget = pTargetChar ? pTargetChar->GetFighter() : NULL;
					if (pTarget == NULL)
						continue;
					vecEntityID.push_back(uTargetID);
				}
			}
			break;
		case eOF_LockedEnemyTarget:
			{
				CCharacterDictator* pCharacter;
				CFighterDictator* pLockedTarget;
				CMagicOpTreeServer::VecEntityID vecChar = vecEntityID;
				vecEntityID.clear();
				CMagicOpTreeServer::VecEntityID::iterator it = vecChar.begin();
				for (; it != vecChar.end(); ++it)
				{
					pCharacter = CCharacterDictator::GetCharacterByID(*it);
					if (pCharacter)
					{
						pLockedTarget = pCharacter->GetFighter()->GetTarget();
						CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
						if(pLockedTarget && relationMgr.IsEnemy(pFrom, pLockedTarget)&&(pLockedTarget->CppIsAlive()||pFilterLimit.bTargetAliveCheckIsIgnored))
						{
							vecEntityID.push_back(pLockedTarget->GetEntityID());
						}
					}
				}
				break;
			}
		default:
			break;
		}
	}
	SQR_CATCH(exp)
	{
		CCharacterDictator* pCharFrom = pFrom->GetCharacter();
		ostringstream strm;
		if(pCharFrom)
		{
			strm << pCharFrom->GetRealName() << "\t";
		}
		if(pSkillInst)
		{
			strm << pSkillInst->GetSkillName() << "\t";
		}

		exp.AppendMsg(strm.str().c_str());
		LogExp(exp);
	}
	SQR_TRY_END;
}

void CFilterOpServer::FilterOperateObject(CSkillInstServer* pSkillInst, CMagicOpTreeServer::VecEntityID& vecEntityID, EOperateObjectType eOperaterObjectType,const FilterLimit& pFilterLimit, CFighterDictator* pFrom, CGenericTarget* pTo)
{
	SQR_TRY
	{
		switch(eOperaterObjectType)
		{
		case eOOT_Releaser:				// �ͷ���
			if(pFrom && pTo->GetType() == eTT_Fighter && pFrom == pTo->GetFighter() 
				&& (pFrom->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
			{
				vecEntityID.push_back(pFrom->GetEntityID());
			}
			break;
		case eOOT_Self:				// ����
			//����ɸѡ������ʵ�ַ�ʽ�ı���Ŀ�꣨pTo����pFrom�������ˣ�����ͬ�ڱ�����������case��ɸѡ��ʽ��ȡ��Ҫ��ҪpTo��û���ˣ���
			//�����ħ����OnCaughtViewSightOf�е��û������Ϊɸѡ����ظ������¶�ͬһ��Ŀ��ִ�ж�οɳ���Ч��������ֻ�᳷��һ�Σ�
			//��ˣ�1����ð����case�ڵ�����ɸѡȥ����ֱ�ӷ��ؿ�vecEntityID����Ϊ�����õ�����ɸѡ��ħ��ֻ�й⻷��
			//���⻷������ִ��Ч����ֱ��д�ڹ��캯���ڣ�δ����ɸѡ��������case�ڵĴ������ã�
			//�����κ�ʱ�򶼲�Ӧ�ñ�����������������˷���Ҫ��д���붪�������ɸѡ�������
			//���ߣ�2���ı�⻷������ִ�еķ�ʽΪ���������ö���һ��������OnCaughtViewSightOf��ɸѡ��
			//��������Ҫ������ɸѡ�ķ�ʽ�ĳɸ��ͷ���caseһ������pTo������pFrom������ȥ���⻷���캯�������еĶ�����ִ�пɳ���Ч���Ĵ���
			if(pFrom && (pFrom->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
			{
				vecEntityID.push_back(pFrom->GetEntityID());
			}
			break;
		case eOOT_Target:			// Ŀ��
			{
				if(pTo->GetType() != eTT_Fighter)
				{
					GenErr("Ŀ���ٴ�ɸѡ����");
				}
				CFighterDictator* pFighterTo = pTo->GetFighter();
				if(pFighterTo && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
				{
					vecEntityID.push_back(pFighterTo->GetEntityID());
				}
			}
			break;
		case eOOT_Friend:		
			if (pFrom)
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if(pFighterTo && relationMgr.IsFriend(pFrom, pFighterTo)&&(pFighterTo->CppIsAlive()||pFilterLimit.bTargetAliveCheckIsIgnored))
				{	
					vecEntityID.push_back(pFighterTo->GetEntityID());
				}
			}
			break;
		case eOOT_Enemy:			
			if (pFrom)
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if(pFighterTo && relationMgr.IsEnemy(pFrom, pFighterTo)&&(pFighterTo->CppIsAlive()||pFilterLimit.bTargetAliveCheckIsIgnored))
				{	
					vecEntityID.push_back(pFighterTo->GetEntityID());
				}
			}
			break;
		case eOOT_FriendAndEnemy:
			if (pFrom)
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if(pFighterTo && (relationMgr.IsFriend(pFrom, pFighterTo) || relationMgr.IsEnemy(pFrom, pFighterTo)) && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
				{	
					vecEntityID.push_back(pFighterTo->GetEntityID());
				}
			}
			break;
		case eOOT_Teammates:		
			if (pFrom)
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if (pFighterTo && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
				{
					if (relationMgr.InTheSameTeam(pFrom, pFighterTo))
					{
						vecEntityID.push_back(pFighterTo->GetEntityID());
					}
					else
					{
						CCharacterDictator* pDictator = pFighterTo->GetCharacter();
						pDictator = pDictator->GetMaster();
						if (pDictator && relationMgr.InTheSameTeam(pFrom, pDictator->GetFighter()))
						{
							vecEntityID.push_back(pFighterTo->GetEntityID());
						}
					}
				}
			}
			break;
		case eOOT_Raidmates:			
			if (pFrom)
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if (pFighterTo && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
				{
					if (relationMgr.InTheSameTroop(pFrom, pFighterTo))
					{
						vecEntityID.push_back(pFighterTo->GetEntityID());
					}
					else
					{
						CCharacterDictator* pDictator = pFighterTo->GetCharacter();
						pDictator = pDictator->GetMaster();
						if (pDictator && relationMgr.InTheSameTroop(pFrom, pDictator->GetFighter()))
						{
							vecEntityID.push_back(pFighterTo->GetEntityID());
						}
					}
				}
			}
			break;
		case eOOT_Tongmates:
			if (pFrom)
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if (pFighterTo && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
				{
					if (relationMgr.InTheSameToon(pFrom, pFighterTo))
					{
						vecEntityID.push_back(pFighterTo->GetEntityID());
					}
					else
					{
						CCharacterDictator* pDictator = pFighterTo->GetCharacter();
						pDictator = pDictator->GetMaster();
						if (pDictator && relationMgr.InTheSameToon(pFrom, pDictator->GetFighter()))
						{
							vecEntityID.push_back(pFighterTo->GetEntityID());
						}
					}
				}
			}
			break;
		case eOOT_SelfMaster:
			if(pFrom != NULL)
			{
				CCharacterDictator* pFH = pFrom?pFrom->GetCharacter():NULL;
				CCharacterDictator* pMaster = pFH?pFH->GetMaster():NULL;
				CFighterDictator* pMasterFighter = pMaster?pMaster->GetFighter():NULL;
				if(pMasterFighter && (pMasterFighter == pTo->GetFighter())
					&& (pMasterFighter->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
					vecEntityID.push_back(pMaster->GetEntityID());
			}
			break;
		case eOOT_TargetAroundEnemy:
			{
				QueryObj( vecEntityID, pFilterLimit, pFilterLimit.fFilterRadius, pFrom, pTo, eSR_PlayerEnemy);
				break;
			}
			break;
		case eOOT_SelfAndRaidmates:
			{
				CFighterDictator* pFighterTo=pTo->GetFighter();
				CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
				if(pFighterTo && (pFrom == pFighterTo || relationMgr.InTheSameTroop(pFrom, pFighterTo)) && (pFighterTo->CppIsAlive() || pFilterLimit.bTargetAliveCheckIsIgnored))
				{	
					vecEntityID.push_back(pFighterTo->GetEntityID());
				}
			}
		default:
			break;
		}
	}
	SQR_CATCH(exp)
	{
		CCharacterDictator* pCharFrom = pFrom->GetCharacter();
		ostringstream strm;
		if(pCharFrom)
		{
			strm << pCharFrom->GetRealName() << "\t";
		}
		if(pSkillInst)
		{
			strm << pSkillInst->GetSkillName() << "\t";
		}

		exp.AppendMsg(strm.str().c_str());
		LogExp(exp);
	}
	SQR_TRY_END;
}

void CFilterOpServer::QueryObj(vector<CFighterDictator*>& vecEntityID, const FilterLimit& pFilterLimit, float fFilterRadius, CFighterDictator* pFrom, CGenericTarget* pTo, ESimpleRelation eRelation)
{
	if(!pFrom) return;
	CRelationMgrServer& RelationWithFrom = CRelationMgrServer::Inst();
	CCoreSceneServer* pScene;
	vector<CCoreObjectServer*> vecCoreObj;
	CFPos	 pos;
	if (pTo->GetType()==eTT_Fighter)
	{
		CFighterDictator* pToFighter = pTo->GetFighter();
		if(!pToFighter)
			return;
		pScene = pToFighter->GetScene();
		pos = pToFighter->GetPixelPos();
	}
	else
	{
		pScene = pFrom->GetScene();
		pos = pTo->GetPos();
	}

	pScene->QueryObject(vecCoreObj, pos, fFilterRadius);
	vector<CCoreObjectServer*>::reverse_iterator it_coreObj = vecCoreObj.rbegin();
	for(; it_coreObj != vecCoreObj.rend(); ++it_coreObj)
	{
		CCharacterDictator* pCharacterDictator = CCharacterDictator::GetCharacterByCoreObj(*it_coreObj);
		if(pCharacterDictator == NULL)
			continue;

		if(((*it_coreObj)->GetType() == eSOT_Mediator||(*it_coreObj)->GetType() ==eSOT_Dictator))
		{
			CFighterDictator* pTarget = pCharacterDictator->GetFighter();
			if (!pTarget->CppIsAlive() && !pFilterLimit.bTargetAliveCheckIsIgnored)	//��ʬ��ʩ�ŵļ��ܽ��з�Χɸѡʱ��Ҫɸ��ʬ��
				continue;

			if (eSR_PlayerFriend == eRelation)
			{
				if(RelationWithFrom.IsFriend(pFrom, pTarget))
					vecEntityID.push_back(pTarget);
			}
			else if (eSR_PlayerEnemy == eRelation)
			{
				if (RelationWithFrom.IsEnemy(pFrom, pTarget))
					vecEntityID.push_back(pTarget);
			}
		}
	}
}

void CFilterOpServer::QueryObj(CMagicOpTreeServer::VecEntityID& vecEntityID,const FilterLimit& pFilterLimit, float fFilterRadius, CFighterDictator* pFrom, CGenericTarget* pTo, ESimpleRelation eRelation)
{
	vector<CFighterDictator*>vecFighter;
	QueryObj( vecFighter, pFilterLimit, fFilterRadius, pFrom, pTo, eRelation);
	vector<CFighterDictator*>::iterator iter= vecFighter.begin();
	for(; iter!= vecFighter.end(); ++iter)
	{	
		CCharacterDictator* pQueryCharacter = (*iter)->GetCharacter();
		vecEntityID.push_back(pQueryCharacter->GetEntityID());
	}
}
