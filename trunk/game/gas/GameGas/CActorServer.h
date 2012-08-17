#pragma once
#include "CActor.h"
#include "CSyncVariantServer.h"
#include "CEntityMallocObject.h"
#include "TEntityAllocator.h"
#include "TActorAllocator.h"
#include "CIniFile.h"

class IActorServerHandler;
class CEntityServer;
class CAniKeyFrameCfg;
class CCharacterDictator;

class CActorServer 
	: public CActor
{
public:
	CActorServer();
	virtual ~CActorServer();

	void InitActorVariant();

	inline void SetHandler(IActorServerHandler* pHandler) { m_pHandler = pHandler; }
	inline IActorServerHandler* GetHandler() const { return m_pHandler; }

	uint32 GetEntityID() const;
	CEntityServer* GetEntity() const;
	CCharacterDictator* GetCharacter() const;

	void AddCascadeCount()		{++m_uCascadeActionCount;}
	void SubCascadeCount()		{--m_uCascadeActionCount;}
	int32 GetCascadeCount()		{return m_uCascadeActionCount;}
	void SetServerDir(uint8 uDir)	{ m_uServerActionDir = uDir; }
	uint8 GetSeverDir()	const	{ return m_uServerActionDir; }

	void OnMoveBegan();
	void OnMoveEnded();
	
	void OnChangeNAAniKeyFrame(const TCHAR* szAniFileName);
	void OnChangeWFAniKeyFrame(const TCHAR* szAniFileName);

	uint8 GetHitFrameByActionState(EActionState eActionState);
	uint8 GetEndFrameByActionState(EActionState eActionState);

	uint8 GetCastKeyFrameByAniName(const string& strAniName);

	CSyncVariantServer* GetVariantStateForce();
	CSyncVariantServer* GetVariantMoveState();
	CSyncVariantServer* GetVariantMoveDir();
	CSyncVariantServer* GetVariantActionRhythm();
	CSyncVariantServer* GetVariantActionIndex();
	CSyncVariantServer* GetVariantHurtResult();
	CSyncVariantServer* GetVariantActionState();
	CSyncVariantServer* GetVariantDirForce();
	CSyncVariantServer* GetVariantDirGac2Gas();
	CSyncVariantServer* GetVariantActionDir();
	CSyncVariantServer* GetVariantWalkBackRadius();
	CSyncVariantServer* GetVariantNAActionRhythm();

private:
	IActorServerHandler*	m_pHandler;
	sqr::CIniFile*			m_pKeyFrameIniFile;		// �����ؼ�֡
	sqr::CIniFile*			m_pWFKeyFrameIniFile;	// �淨�ؼ�֡

	int32 m_uCascadeActionCount;			// �����������
	uint8 m_uServerActionDir;				// ����˶����򣬲���Ҫͬ��

	CSyncVariantServer* m_pVariantStateForce;
	CSyncVariantServer* m_pVariantMoveState;
	CSyncVariantServer* m_pVariantMoveDir;
	CSyncVariantServer* m_pVariantActionRhythm;
	CSyncVariantServer* m_pVariantActionIndex;
	CSyncVariantServer* m_pVariantHurtResult;
	CSyncVariantServer* m_pVariantActionState;
	CSyncVariantServer* m_pVariantDirForce;
	CSyncVariantServer* m_pVariantDirGac2Gas;
	CSyncVariantServer* m_pVariantActionDir;
	CSyncVariantServer* m_pVariantWalkBackRadius;
	CSyncVariantServer* m_pVariantNAActionRhythm;
};
