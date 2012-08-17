#pragma once
#include "FightDef.h"
#include "CActorClient.h"

namespace sqr
{
	class CSyncVariantClient;
	class CRenderObject;
}

class CPlayerFX;
class CNPCGazedAtMgr;
class CActorFollower;
class CCharacterFollower;
class CActorAniCfg;
class IActorFollowerHandler;
class CMoveStateNode;
class CCharacterController;
class CWhiskSoundPlayer;
class CHitSoundPlayer;
class CMoveStateCallback;
class CMoveDirCallback;
class CActionStateCallback;
class CActionDirCallback;
class CWalkBackRadiusCallback;
class CNAActionRhythmCallback;

typedef void (CActorFollower::*MoveFunc)();

enum EWeaponPosAndBattleState
{
	eWPBS_BackWeapon,		// ������
	eWPBS_HoldWeapon,		// ������
	eWPBS_BattleState,		// ս��״̬
};

class CActorFollower
	: public CActorClient
{
	friend class CCharacterFollower;

public:
	CActorFollower();
	~CActorFollower();
	void ClearVariantCallbackFunc();
	void RegVariantCallbackFunc();

	uint32					GetEntityID() const;
	IActorFollowerHandler*	GetHandler() const;
	CCharacterFollower*		GetCharacter() const;

	// �ı�״̬ �� ���Ŷ��� �ӿ�
	bool DoMoveState(EMoveState eMoveState, bool bForce = false);
	void DoMoveAnimation();

	bool DoActionState(EActionState eActionState, int16 uActionDir = -1, bool bImmed = false, bool bForce = false, uint8 uActionIndex = 0);
	void DoActionSimplify(EActionState eActionState);
	void DoNowAni(bool bIsMoveAction = false);

	// ���鶯��
	bool DoFunActionState(EActionState eActionState, uint8 uActionIndex);
	void EndFunActionState();

	// ��ǰ��������
	EActionPlayPriority	GetCurOnceActionLevel()				{ return m_eCurOnceActionLevel; }
	void SetCurOnceActionLevel(EActionPlayPriority eLevel)	{ m_eCurOnceActionLevel = eLevel; }

	void PlayFxByActionState(EActionState eActionState, const string& strAniName);
	void SplitAttackFxFile(string &FxFile, string &FxName);
	void SplitSkillFxFile(const string &InFx, string &FxFile, string &FxName, bool bNeedSpliceName);
	void SplitSkillFxFile(const string &InFx, string &FxFile, string &FxName, uint32& uDeleyTime,bool bNeedSpliceName);

	void SetAttackFxFile(const string& strAttackFxFile)			{ m_strAttackFxFile = strAttackFxFile; }
	void SetActionFxFile(const string& strActionFxFile)			{ m_strActionFxFile	= strActionFxFile; }
	void SetSkillFxFile(const string& strSkillFxFile)			{ m_strSkillFxFile	= strSkillFxFile; }
	void SetSpliceName(const string& strSpliceName)			{ m_strSpliceName	= strSpliceName; }

	void	SetNAActionRhythm(float fActionRhythm)		{ m_fNAActionRhythm = fActionRhythm; }
	float	GetNAActionRhythm() const					{ return m_fNAActionRhythm; }
	void	SetNATempRhythm(float fTempRhythm)			{ m_fNATempRhythm = fTempRhythm; }
	float	GetNATempRhythm() const						{ return m_fNATempRhythm; }
	void	SetWalkBackRadius(uint8 uWalkBackRadius)	{ m_uWalkBackRadius = uWalkBackRadius; }
	uint8	GetWalkBackRadius()	const					{ return m_uWalkBackRadius; }

	// ����������������
	EActionState AdjustActionRhythm(EActionState eActState);

	void SetNeedMoveUpBodyAni(bool bNeed)		{ m_bNeedMoveUpBodyAni = bNeed; }
	bool GetNeedMoveUpBodyAni() const			{ return m_bNeedMoveUpBodyAni; }
	void SetComboSing(bool bComboSing)			{ m_bComboSing = bComboSing; }
	bool GetComboSing()							{ return m_bComboSing; }

	uint8	GetMoveDir() const  				{ return m_uMoveDir; }	
	uint8	GetActionDir() const  				{ return m_uActionDir; }
	uint8	GetActionIndex() const				{ return m_uActionIndex; }
	virtual void SetMoveDir(uint8 uMoveDir)		{ m_uMoveDir = uMoveDir; }
	void	SetActionDir(uint8 uActionDir)		{ m_uActionDir = uActionDir; }
	void	SetActionIndex(uint8 uActionIndex)	{ m_uActionIndex = uActionIndex; }
	void	SetAllBodyCastAni(bool bAllBody)	{ m_bIsAllBodyAni = bAllBody; }

	void	SetTargetArmorString(string strArmor)	{ m_strArmorString = strArmor; }
	string	GetTargetArmorString()					{ return m_strArmorString; }

	void	SetHurtResult(EHurtResult eHurtResult)	{ m_eHurtResult = eHurtResult; }
	EHurtResult GetHurtResult()						{ return m_eHurtResult; }

	void OnSepAnimationEnd(const TCHAR* szName);
	void OnAnimationEnd(const TCHAR* szName);
	void OnResLoaded();
	void OnSetVisable(bool isVisable);
	void OnKeyFrame( const TCHAR * szName );

private:
	typedef std::list<CMoveStateNode*>		MOVE_LIST;
	MOVE_LIST			m_lMoveList;

	// ��������
	bool				m_bIsAllBodyAni;
	bool				m_bNeedMoveUpBodyAni;
	EActionPlayPriority m_eCurOnceActionLevel;
	bool				m_bComboSing;
	bool				m_bNoHandlerActor;
	int					m_nUpperBodyID;

	// ������Ч
	string			m_strAttackFxName;
	string			m_strAttackFxFile;
	string			m_strActionFxFile;
	string			m_strSkillFxFile;
	string			m_strSpliceName;
	CPlayerFX*		m_pActionFX;

	// ������������
	float			m_fNAActionRhythm;
	float			m_fNATempRhythm;
	float			m_fCurAniRhythm;

	CMoveStateCallback*		m_pMoveStateCallback;
	CMoveDirCallback*		m_pMoveDirCallback;
	CActionStateCallback*	m_pActionStateCallback;
	CActionDirCallback*		m_pActionDirCallback;
	CWalkBackRadiusCallback*	m_pWalkBackRadiusCallback;
	CNAActionRhythmCallback*	m_pNAActionRhythmCallback;

	uint8			m_uWalkBackRadius;		// �����߰뾶
	uint8			m_uMoveDir;				// �ƶ�����
	uint8			m_uActionDir;			// ��������
	uint8			m_uActionIndex;			// ���鶯������

	string			m_strArmorString;
	EHurtResult		m_eHurtResult;

private:

	// MoveState���
	void RegisterMoveAnimation(MoveFunc func);	//�����������������ע�����������
	void DoStop();
	void DoMove();
	EActionState GetStopActState();
	EActionState GetMoveActState();

	bool SetActionDirection(EActionState EActionState, int16 nActionDir, bool bImmed, bool bForce, bool bIsSepMode);

	// ����
	bool PlayActionRule(CRenderObject* RenderObj, EActionState eActionState, bool bIsSepMode, EActionPlayPriority ePriorityLevel);
	void ExecuteSpecialRuleForAllBodyAni(EActionState eActionState);

	// �õ���������ս��״̬
	EWeaponPosAndBattleState GetWeaponPosAndBattleState();
};

