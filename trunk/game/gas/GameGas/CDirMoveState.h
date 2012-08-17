#pragma once
#include "CSpecialState.h"

//�����ƶ�״̬�������պ������
class CMoveServerManager;
class CDirMoveStateServer
	: CSpecialStateBase
{
	friend class CSpecialStateMgrServer;
public:

	CDirMoveStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller, CSpecialStateMgrServer* pMgr, 
		const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime, int32 iRemainTime = 0);
	virtual ~CDirMoveStateServer();
	pair<bool, bool> MessageEvent(uint32 uEventID, CGenericTarget * pTrigger);

private:
	CMoveServerManager*	m_pMoveMgr;
	void					MoveByChangeDir();
	void					RegisterEvent();
};

