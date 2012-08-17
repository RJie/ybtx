#pragma once
#include "CTick.h"
#include "PatternCOR.h"

class CCharacterFollower;

class CDirectionMgr 
	: public CTick
	, public CPtCORHandler
{
public:
	CDirectionMgr(CCharacterFollower* pCharacter);
	~CDirectionMgr();

	void SetDirection( uint8 uDir, bool bAtOnce);
	void OnTick();
	void CancelTick();
	void OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg);
	void SetFirstDexterity(float fValue);
	void InitDirection() {m_bInitDirection = true;}

	// FOR LUA
	bool IsStopBeforeTurn(uint8 uDesDirection);			// �Ƿ���תǰ��վ�� (Ŀ�곬��90��)
	bool IsTurnOver();									// �Ƿ�ת����Ƕ� (��תǰ��Ŀ��)

private:
	CCharacterFollower*	m_pCharacter;
	bool			m_bInitDirection;	// �Ƿ��ʼ�Ƕ�
	uint8			m_uCurDirection;	// ��ǰ�ĽǶ�
	uint8			m_uDesDirection;	// ��Ҫ��ת���ĽǶ� (����Ƕ��������°���Ҳ����վ��ʱ��ĽǶ�)
	uint8			m_uStartUpSpeed;	// ����ʱת�� (����/��λʱ��)
	float			m_fFirstDexterity;	// �������ݶ� (Ӱ��ת����ٶ�)
	float			m_fDexterity;		// ���ݶ� (������ʱ�����ƶ��ٶȼ���)
	uint8			m_uTurnCount;		// ��ǰ��ת��������
};
