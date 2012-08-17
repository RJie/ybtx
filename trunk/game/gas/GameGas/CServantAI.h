#pragma once
#include "CNpcAI.h"

class CServantBackToMaster;
class CCharacterDictator;

class CServantAI
	:public CNpcAI
{
friend class CServantBackToMaster;
public:
	CServantAI(CCharacterDictator* pCharacter, const CNpcServerBaseData* pBaseData, const CNpcStateTransit* pStateTransit, ENpcType eRealNpcType, ENpcAIType eRealAIType, EObjectAoiType eObjAoiType);
	void Follow();
	virtual void OnMasterDestroyed();	//���������������ߺ���������������ٻ�������Ӧ�Ĳ���
	void StopFollowMaster();
	virtual void Attack(CCharacterDictator* pTarget);	//����
	virtual void Retreat();								//����
	virtual void Disband();								//��ɢ
	virtual void Spread();								//չ��
	virtual bool Move(uint32 x, uint32 y);				//�ƶ�
	//ר�Ÿ�ս�������õģ������ط���Ҫ��
	void TellMasterFaceEnemy();

	void BeginChaseOriginTrace();

	void CreateFollowMasterTick();
	void DestoryFollowMasterTick();

	void SetFollowState(bool bFollow);
	bool GetFollowState();
	bool BeInCommandMoveState();
	void MoveToLastMoveCommandPos();
	void CancelCommandMove();
	
	virtual void OnBeAttacked(CCharacterDictator* pAttacker, bool bHurtEffect = true);

public:
	CDistortedTick*						m_pBackToMaster;
private:
	int32						m_uAngle;
	bool						m_bFollowState;
	bool 						m_bCommandMoveState;
	CFPos						m_LastMoveCommanPos;
private:
	void UpdateMasterState(CPtCORSubject* pSubject, uint32 uEvent,void* pArg);	
	void InitServantAttribute(CCharacterDictator* pMaster, CCharacterDictator* pServant);
	void OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent, void* pArg);
	virtual ~CServantAI();
};

