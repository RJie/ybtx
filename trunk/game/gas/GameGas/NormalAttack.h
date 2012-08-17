#pragma once
#include "CDistortedTick.h"
#include "PatternCOR.h"
#include "FightDef.h"
#include "ActorDef.h"
#include "TimeHelper.h"
#include "IObjPosObserverHandler.h"
#include "CFighterMallocObject.h"

class CSkillInstServer;
class CFighterDictator;
class CSingleHandNATick;
class CNormalAttackMgr;
class CNormalAttackCfg;
class CNormalAttackCfgSharedPtr;

class CNormalAttackAniTick;
//���������ֹ�����������ʱ��̫�ӽ���Ҫ�Ѻ����һ�ι����Ӻ�
class CDelayedAttack;

class CSingleHandNATick
	:public CDistortedTick
	,public CFighterMallocObject
{
public:
	friend class CNormalAttackMgr;
	friend class CNormalSkillServer;
	friend class CNormalAttackAniTick;
	friend class CDelayedAttack;

	CSingleHandNATick(CFighterDictator* pAttacker, CNormalAttackMgr* pMgr, bool bIsMainHand);
	virtual ~CSingleHandNATick();

	void SetAttackType(EAttackType eAttackType)					{ m_eAttackType = eAttackType; }
	void SetWeaponType(EWeaponType eWeaponType)					{m_eWeaponType = eWeaponType;}
	void UnarmWeapon();
	void SetCfg(const TCHAR* szName);
	void SetWeaponInterval(float fWeaponInterval);
	void SetAttackScope(float fAttackScope);
	CNormalAttackAniTick* GetCurNormalAttack();
	void ClearCurNormalAttack();
	EWeaponType GetWeaponType()const{return m_eWeaponType;}
	EAttackType GetAttackType()const{return m_eAttackType;}
	EAttackType GetCfgAttackType()const;
	bool HasWeapon();

	uint8 DoNormalAttackOnce();
	virtual void OnTick();

	bool IsShortNormalAttack();
	CFighterDictator*	GetFighter()const{return m_pAttacker;}
	bool IsMainHand()const;

private:
	// ReferToPauseTime��ʾ���ϴ�pause�͵�ǰrestart��ʱ��ConsiderPauseTime��ʾ�Ƿ��ϴ�pause�͵�ǰrestart֮���ʱ���Ҳ�����չ���cdʱ��
	bool NextAttackRequireToBeWaited(uint32& uWaitingTime)const;
	void StopOwnTick();			//�����ӳٹ���,��Ҫ��ͣԭ�����չ�Tick
	void RestoreOwnTick();		//ִ�����ӳٹ���,��Ҫ�ָ�ԭ�����չ�Tick
	void RegisterTick(uint32 uTime);
	void UnRegisterTick();	

	void TickOnce();
	uint8 PlayAttackAni();
	EHurtResult PreDice();

	void SetNormalAttackLastStartTime();
	uint64 GetNormalAttackLastStartTime()const { return m_NormalAttackLastStartTime ; }
	void SetDelayedTime(uint32 uDelayedTime);
	bool IsDoingCurNormalAttack();
	void AddNoneCDTime(uint64 uAccumulatedNoneCDTime);
	void ClearNoneCDTime();
	void ClearDelayedAttack();
	CNormalAttackCfgSharedPtr& GetCfg()const;

private:
	CSkillInstServer*			m_pSkillInst;
	CFighterDictator*			m_pAttacker;
	CNormalAttackCfgSharedPtr*	m_pCfg;
	float						m_fWeaponInterval;		//�����������
	CNormalAttackAniTick*		m_pCurNormalAttack;		//һ����ͨ����
	EAttackType					m_eAttackType;			//������������
	EWeaponType					m_eWeaponType;			//��������
	uint64						m_uPausetime;			//��ͣһ����ͨ������ʱ��
	uint64						m_NormalAttackLastStartTime;
	uint64						m_NoneCDTime;			//�ڵ�ǰʱ�̺��ϴι���ʱ��֮�䲻�ܱ�����Ϊcd��ʱ����
	uint32						m_uDelayedTime;			//���ӳٵ�ʱ��
	uint32						m_uNextAttackTime;		//�´ι���Ԥ�Ʒ�����ʱ�䣬ֻ������Restart��ʱ���¼���ֵ��´ι�����ʱ��
	CDelayedAttack*				m_pDelayedAttack;		

	CNormalAttackMgr*			m_pMgr;

	uint64						m_uLastAniStartTime;
	bool						m_bIsMainHand;
	float						m_fAttackScope;			//��������,��Ҫ��npc���չ�ʹ��

	//���ڵ���
	uint64						m_uLastOnTickTime;
	uint64						m_uLastDelayAttackTime;
	uint64						m_uLastDelayTickOnceTime;

};

class CNormalAttackMgr
	:public CPtCORHandler
	,public IWatchHandler
	,public CDistortedTick
	,public CFighterMallocObject
{
public:
	friend class CNormalSkillServer;

	CNormalAttackMgr(CFighterDictator* pAttacker);
	~CNormalAttackMgr();

	void OnCOREvent(CPtCORSubject* pSubject,uint32 uEvent,void* pArg);

	void RegisterEvent(CFighterDictator* pTarget);
	void UnRegisterEvent();
	bool DoAttack(CFighterDictator* pTarget);
	void InitNPCNormalAttack(const TCHAR* szMHName); 
	void InitNormalAttack(const TCHAR* szMHName, EAttackType MHAttackType, EWeaponType MHWeaponType, 
						const TCHAR* szAHName, EAttackType AHAttackType, EWeaponType AHWeaponType);
	void InitMHNA(const TCHAR* szMHName, EAttackType MHAttackType, EWeaponType MHWeaponType);
	void InitAHNA(const TCHAR* szAHName, EAttackType AHAttackType, EWeaponType AHWeaponType);
	
	void CalDamageImmediately();

	bool Start();								//��ʼ�Զ�������ͨ����
	void Cancel(bool bCalDamageImmediately = false, bool bUnRegistEvent = true);				//ֹͣ�Զ�������ͨ����
	void Pause(bool bCalDamageImmediately = true);		//��ͣ�Զ�������ͨ����, ����Ŀ�곬��������Χ
	bool Restart();								//�ָ��Զ�������ͨ����, ����Ŀ���ٴν��빥����Χ
	void OnTargetChanged(CFighterDictator* pNewTarget);	//ת������Ŀ��, ֻ����һ��Start()��Cancel()֮�����
	bool IsPaused()const;
	bool IsAttacking()const								{ return m_bIsAttacking; }
	void SetIsForbitAutoNA(bool bIsForbitAutoNA)		{m_bIsForbitAutoNA = bIsForbitAutoNA;}

	bool IsTargetUnreachableInLine(const CFighterDictator* pTarget)const;
	bool IsTargetInAttackScope();
	float GetAttackDistance() const;
	CSingleHandNATick* GetMHNormalAttack()const	{ return m_pMainhand;}
	CSingleHandNATick* GetAHNormalAttack()const	{ return m_pAssistanthand;}

	EAttackType GetAttackType()				{ return m_pMainhand->GetAttackType(); }
	
	void SetCanBeRestarted(bool bCanBeRestarted) { m_bCanBeRestarted = bCanBeRestarted; }
	bool GetCanBeRestarted()const { return m_bCanBeRestarted;}
	CFighterDictator*	GetFighter()const{return m_pAttacker;}

	uint8 GetHitFrameByActionState(EActionState eActionState);
	uint8 GetEndFrameByActionState(EActionState eActionState);

	virtual void OnObserveeEntered();
	virtual void OnObserveeLeft();

	void AddNoneCDTime(uint64 uAccumulatedNoneCDTime);	//���·��չ�cdʱ��

private:
	void InitAutoAttacking(CFighterDictator* pTarget);	//��ʼ���Զ�����
	bool IsInAttackScope(CFighterDictator* pTarget);
	void ObserveTarget(CFighterDictator* pTarget);
	void HaltNormalAttack(bool bCalDamageImmediately);

	virtual void OnTick();	//�չ���ͣʱ�ø�tick���жϹ����ߺ�Ŀ��֮���Ƿ񲻴����ϰ���,���û���ϰ���restart�չ�

	CFighterDictator*		m_pAttacker;
	bool					m_bIsAttacking;		// �Ƿ������ͨ����
	bool					m_bIsPaused;		// �Ƿ�����ͣ��ͨ������������֮ǰ�Ѿ������չ�������
	//bool					m_bIsAuto;			// �Ƿ��Զ���ͨ����
	bool					m_bCanBeRestarted;	// �Ƿ���������ͨ����
	bool					m_bIsForbitAutoNA;	// �Ƿ��ֹ�Զ��չ�
	//bool					m_bIsAniDelayed;	//�Ƿ��ڲ��Ź�������ʱ��ͣ��ͨ��������ֹ�˶���, ��������Ҫ�ڻָ�ʱ���²��Ŷ���.
	CSingleHandNATick*		m_pMainhand;
	CSingleHandNATick*		m_pAssistanthand;
};
