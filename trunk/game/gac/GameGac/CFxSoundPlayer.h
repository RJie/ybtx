#pragma once
//------------------------------------------------------------------------------
/**
@class CFxSoundPlayer

��Ч��Ч���Żص�����.
�����߼����Ʋ��Ų�ͬ��Ч.

ʹ�÷���: pRenderObj->SetNoneActEffectUnitHandler(index, player, player->GetUnitName());
(C) 2010 ThreeOGCMan
*/
#include "CEffectUnitHandler.h"
#include "ActorDef.h"

class CActorFollower;

class CFxSoundPlayer : public CEffectUnitHandler
{
public:
	CFxSoundPlayer();

	bool RenderCallback( IEffectUnit* pUnit, CMatrix& matWorld, uint32 uCurTime, RenderObjStyle* pRORS );
	/// ����, �Ա㲥���µ�����
	void Reset();

	/// ����Ҫ���ŵ�cue����
	virtual string GetCueName() const = 0;
	/// ������Ч������Զ�������
	const TCHAR* GetUnitName() const;

protected:
	bool	m_bHasPlayed;
	string	m_strUnitName;
};

//------------------------------------------------------------------------------
inline void
CFxSoundPlayer::Reset()
{
	m_bHasPlayed = false;
}

//------------------------------------------------------------------------------
inline const TCHAR*
CFxSoundPlayer::GetUnitName() const
{
	return m_strUnitName.c_str();
}

/// �Ӷ���Ч
class CWhiskSoundPlayer : public CFxSoundPlayer
{
public:
	CWhiskSoundPlayer(uint32 uEntityID);
	void SetActionState(EActionState eActionState)		{m_eActionState = eActionState;}

private:
	string GetCueName() const;
	uint32				m_uEntityID;
	EActionState		m_eActionState;
};

/// �����Ч
class CHitSoundPlayer : public CFxSoundPlayer
{
public:
	CHitSoundPlayer(uint32 uEntityID);
	void SetActionState(EActionState eActionState)	{m_eActionState = eActionState;}

private:
	string GetCueName() const;
	uint32				m_uEntityID;
	EActionState		m_eActionState;
};
