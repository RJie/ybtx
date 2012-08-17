#include "stdafx.h"
#include "CDummyEnmityMgr.h"
#include "CCharacterDictator.h"
#include "CNpcAI.h"
#include "CNpcEnmityMember.h"
#include "CEntityServerManager.h"
#include "CMemberAI.h"
#include "CDummyAI.h"
#include "CoreCommon.h"
#include "CRelationMgrServer.h"

CDummyEnmityMgr::CDummyEnmityMgr(CNpcAI *pOwner) : CEnmityMgr(pOwner)
{
}

CDummyEnmityMgr::~CDummyEnmityMgr()
{
}

bool CDummyEnmityMgr::AddEnemy(CCharacterDictator* pEnemy, bool bHurtEffect)
{
	CNpcAI* pOwnAI = GetOwner();
	Ast(pOwnAI);
	CCharacterDictator* pOwnCharacter = pOwnAI->GetCharacter();
	Ast(pOwnCharacter);
	if (pEnemy == NULL)
		return false;
	uint32 uEntityID = pEnemy->GetEntityID();
	if (IsInEnmityList(uEntityID))
		return true;
	if (!pOwnAI->IsInLockEnemyRange(pEnemy->GetFighter()))
	{
		RemoveFarawayEnemy(pEnemy);
		return false;
	}
	CNpcEnmityMember* pMember = new CNpcEnmityMember(pOwnCharacter, pEnemy, this,
														true, float(pOwnAI->GetAIBaseData()->m_uLockEnemyDis) * eGridSpan);
	EnemyListType& lstEnemy = GetEnemyList();
	lstEnemy.push_back(pMember);

	return true;
}

void CDummyEnmityMgr::ClearAllEnmity()
{
	if(IsEnemyListEmpty())
		return;
	CNpcAI* pOwnAI = GetOwner();
	Ast(pOwnAI);
	EnemyListType& enemyLst = GetEnemyList();

	do 
	{
		SQR_TRY
		{
			while(!enemyLst.empty())
			{
				CNpcEnmityMember* pMember = enemyLst.front();
				enemyLst.pop_front();
				delete pMember;
			}
			break;
		}
		SQR_CATCH(exp)
		{
			LogExp(exp);
		}
		SQR_TRY_END;
	} while(true);

	CDummyAI* pDummyAI = pOwnAI->CastToDummyAI();
	Ast(pDummyAI);
	pDummyAI->NotifyClearAllEnmity();
}

void CDummyEnmityMgr::RemoveFarawayEnemy(CCharacterDictator* pEnemy)
{
	CNpcAI* pOwnAI = GetOwner();
	Ast(pOwnAI);
	CEnmityMgr::RemoveFarawayEnemy(pEnemy);
	CDummyAI* pDummyAI = pOwnAI->CastToDummyAI();
	Ast(pDummyAI);
	pDummyAI->NotifyMemberRemoveEnemy(pEnemy);
}

void CDummyEnmityMgr::RemoveEnemy(CCharacterDictator* pEnemy)
{
	EnemyListType& lstEnemy = GetEnemyList();
	uint32 uEntityID = pEnemy->GetEntityID();
	for (EnemyListIter iter = lstEnemy.begin(); iter != lstEnemy.end();)
	{
		if ((*iter)->GetEnemyEntityID() == uEntityID)
		{
			delete (*iter);
			lstEnemy.erase(iter);
			return;
		}
		else
			++iter;
	}
}

void CDummyEnmityMgr::CopyEnmityListToMember(CMemberAI* pMemAI, CNpcEventMsg* pEvent)
{
	if(!pMemAI)
		return;
	if(IsEnemyListEmpty())
		return;
	EnemyListType& lstEnmity = GetEnemyList();
	EnemyListType :: iterator iter = lstEnmity.begin();
	for (; iter!= lstEnmity.end(); iter++)
	{
		CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter((*iter)->GetEnemyEntityID());
		CNpcAI* pOwnAI = GetOwner();
		CDummyAI* pDummyAI = pOwnAI->CastToDummyAI();
		if (pDummyAI && pCharacter)
		{
			CCharacterDictator* pMemCharacter = pMemAI->GetCharacter();
			if (!pMemCharacter)
				return;
			CRelationMgrServer& relationMgr = CRelationMgrServer::Inst();
			if(!relationMgr.IsEnemy(pMemCharacter->GetFighter(), pCharacter->GetFighter()))
			{
				ERelationType eRelation = relationMgr.GetRelationType(pMemCharacter->GetFighter(), pCharacter->GetFighter());
				ostringstream strm1;
				strm1 << "Ⱥ��Leader��: " << pDummyAI->m_pBaseData->GetName() << ", Ⱥ���Ա��: " << pMemAI->m_pBaseData->GetName() 
					<< ", ���ѹ�ϵΪ: " << eRelation;
				if (pEvent)
					strm1 << ", ��Ϣ:��"<<pEvent->GetName() << "����Ϣλ�� : " << pEvent->GetCodeIndex();
				strm1 << endl;
				LogErr("Ⱥ��CopyEnmityListToMemberʱ����б��в��ɹ���Ŀ��",strm1.str());
			}
			else if(!pDummyAI->IsInLockEnemyRange(pCharacter->GetFighter()))
			{
				ostringstream strm2;
				strm2 << "Ⱥ��Leader��: " << pDummyAI->m_pBaseData->GetName() << ", Ⱥ���Ա��: " << pMemAI->m_pBaseData->GetName();
				if (pEvent)
					strm2 << ", ��Ϣ:��"<<pEvent->GetName() << "����Ϣλ�� : " << pEvent->GetCodeIndex();
				strm2 << endl;
				LogErr("Ⱥ��CopyEnmityListToMemberʱ����б��г���LockEnemyDis����Ŀ��",strm2.str());
			}
			else
				pMemAI->OnBeAttacked(pCharacter);
		}
	}
}

