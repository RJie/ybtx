#pragma once
#include "PatternCOR.h"
#include "PatternRef.h"
#include "CNpcAIMallocObject.h"
#include "TNpcAIAllocator.h"
#include "TFighterAllocator.h"

class CCharacterDictator;
class CNpcAI;
class CNpcEnmityMember;
class CFighterDictator;
class CEnmityMemberCheckTickl;

/*
* =====================================================================================
*        Class:  CEnmityMgr
*  Description:  ��޹���������
* =====================================================================================
*/
class CEnmityMgr 
	: public CPtCORHandler
	, public CNpcAIMallocObject
{
public:
	friend class CEnmityMemberCheckTick;
	friend class CNpcEnmityMember;
	friend class CNpcEnmityMgr;
	typedef list<CNpcEnmityMember*, TNpcAIAllocator<CNpcEnmityMember*> >		EnemyListType;
	typedef EnemyListType::iterator		EnemyListIter;
	typedef set<uint32, less<uint32>, TFighterAllocator<uint32> >					ESetType;	
	typedef ESetType::const_iterator	ESetTypeIter;
	typedef map<uint32, CNpcEnmityMember*>													MapEnmityMember;
	typedef MapEnmityMember::iterator														MapEnmityMemberIter;
public:
	CEnmityMgr(CNpcAI* pOwner);                /* constructor */
	virtual ~CEnmityMgr();                             /* destructor */

	TPtRefee<CEnmityMgr, CNpcAI>& GetRefsByNpcAI() {return m_RefsByNpcAI;}

	//��¶���ⲿʹ�õ�ǿ�������ӿ�
	void ForceLock(CCharacterDictator* pEnemy, uint32 uChaosTime = 0);			
	virtual bool AddEnemy(CCharacterDictator* pEnemy, bool bHurtEffect);
	virtual void RemoveEnemy(CCharacterDictator* pEnemy);
	EnemyListType& GetEnemyList() { return m_lstEnemy;}
	virtual bool IsInEnmityList(uint32 uEntityID);
	virtual bool IsEnemyListEmpty();
	CCharacterDictator* GetRandomEnemy();
	CCharacterDictator* GetRandomNotNpcEnemy();
	bool IsInEnmityDist(CCharacterDictator* pEnmey);
	virtual void RemoveFarawayEnemy(CCharacterDictator* pEnemy);
	virtual bool JudgeIsEnemy(CCharacterDictator* pTarget) = 0;
	virtual void ClearAllEnmity() = 0;
	void ShareEnmityWithFriend(CNpcAI* pFriendAI);			//������ͬ��ӪNPC������
	CCharacterDictator* GetFirstEnemy();					//�õ�����б����һλ�ĵ���
	void GetNearestEnemy();
	void GetOtherNearstEnemy();
	bool CanChangeEnemy();
protected:
	CNpcAI* GetOwner();
	void UpDateNpcBattleState();
private:
	bool AddOnEnemyToEnmityList(CCharacterDictator* pEnemy, bool bHurtEffect);
	void PushFrontEnemy(CCharacterDictator* pEnemy, bool bHurtEffect);
	void PushBackEnemy(CCharacterDictator* pEnemy, bool bHurtEffect);
	inline uint32 GetEnemyNumber() {return m_lstEnemy.size();}
	CNpcEnmityMember* GetFirstMember();
	CNpcEnmityMember* GetMemberByID(uint32 uEntityID);
	void CheckEnmityMember();
	void AddEnmityMember(uint32 uEmenyID, CNpcEnmityMember* pMember);
	void DelEnmityMember(uint32 uEnemyID, CNpcEnmityMember* pMember);
	void OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg);
	virtual bool BeTargetOutOfLockEnemyDis(CCharacterDictator* pCharacter);
	bool ForceAddFrontEnemy(CCharacterDictator* pEnemy);	//Npc�Լ�����
	bool ForceAddBackEnemy(CCharacterDictator* pEnemy);
private:
	CNpcAI*	m_pOwner;												//��޹��������õ�CNpcAI����ָ��
	TPtRefee<CEnmityMgr, CNpcAI>		m_RefsByNpcAI;
	EnemyListType						m_lstEnemy;
	uint32								m_uLockEnemyDis;
	MapEnmityMember						m_mapEnmityMemeber;
}; 

