#pragma once
#include "CDistortedTick.h"
#include "CFighterDictator.h"
#include "CFighterMallocObject.h"

class CLeaveBattleTick;

class CBattleStateManager
	:public CFighterMallocObject
{
public:
	CBattleStateManager(CFighterDictator* pFighter);
	~CBattleStateManager();
	
	// ���ʹ�� by ��Ҵ���
	bool EnterBattleStateByPlayer();	// ��Ҵ�������ս��״̬����ҳ�����־ ��true
	void LeaveBattleStateByForce();			// ǿ���뿪ս��״̬(����)����Ҵ�����־ �� NPC�������� ����

	// ���ʹ�� by NPC ����
	void AddBattleRefByNpc();		// NPC��������ս��״̬,NPC��������+1
	void DelBattleRefByNpc();		// NPC�����뿪ս��״̬,NPC��������-1

	void EnterBattleState();
	void LeaveBattleState();

	void LeaveBattleStateOnTick();
	void LeaveBattleStateByDead();

private:
	bool GetFinalBattleState() const;
	void RegOutBattleTick();
	void UnRegOutBattleTick();
	void NotifyServantEnterBattle();
	void NotifyServantLeaveBattle();
private:
	CFighterDictator*	m_pFighter;
	CLeaveBattleTick*	m_pTick;

	bool				m_bBattleWithPlay;
	int16				m_nBattleStateCount;
};

// 6 ������ս�� Tick
class CLeaveBattleTick 
	: public CDistortedTick
	, public CFighterMallocObject
{
public:
	CLeaveBattleTick(CFighterDictator* pFighter) : m_pFighter(pFighter) {}
	void OnTick();

private:
	CFighterDictator* m_pFighter;
};

