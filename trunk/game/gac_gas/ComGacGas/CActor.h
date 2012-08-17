#pragma once
#include "ActorDef.h"
#include "CDynamicObject.h"
#include "CDir.h"
#include "CActorMallocObject.h"

class CActor 
	: public virtual CDynamicObject
	, public CActorMallocObject
{
public:
	CActor();

	bool ChangeMoveState(EMoveState eMoveState, bool bForce = false);
	bool ChangeActionState(EActionState eActionState);
	
	EMoveState		GetPreMoveState() const				{ return m_ePreMoveState; }
	EMoveState		GetMoveState() const				{ return m_eMoveState; }
	EActionState	GetPreActionState() const			{ return m_ePreActionState; }
	EActionState	GetActionState() const 				{ return m_eActionState; }

	// ����ö��ֵ��ѯ����, ����CONSOLE��ӡ
	const TCHAR* GetMoveStateStr(EMoveState eMoveState) const;
	const TCHAR* GetActionStateStr(EActionState eActionState) const;

private:
	bool CheckMoveState(EMoveState eMoveState);
	bool CheckActionState(EActionState eActionState);

	EMoveState		m_ePreMoveState;		// �ϸ��ƶ�״̬
	EMoveState		m_eMoveState;			// �ƶ�״̬
	EActionState	m_ePreActionState;		// �ϸ�����״̬
	EActionState	m_eActionState;			// ����״̬
};
