#pragma once
#include "FightDef.h"
#include "CDynamicObject.h"
#include "CPos.h"
#include "CConfigMallocObject.h"
#include "FindPathDefs.h"
#include "CMagicEffServer.h"
#include "CCastingProcessCfg.h"
#include "TCfgSharedPtr.h"
#include "TStringRef.h"
#include "TConfigAllocator.h"

#ifdef _WIN32
#include <hash_map>
using namespace stdext;
#else
#include <ext/hash_map>
using namespace __gnu_cxx;
#endif

class CGenericTarget;
class CCfgCalc;
class CCastingProcessCfgServerSharedPtr;
class CSkillInstServer;
class CFighterDictator;
class CFighterMediator;
class CAureMagicCfgServer;
class CheckSkill;
//class CMagicEffServerSharedPtr;

DefineCfgSharedPtr(CNormalSkillServer)

//ͨ�ü���
class CNormalSkillServer
	: public virtual CDynamicObject
	, public CConfigMallocObject
{
	friend class CSkillInstServer;
	friend class CheckSkill;
private:
	enum ESkillUser
	{
		eSU_Player,
		eSU_NPC,
		eSU_IntObj
	};

#ifndef _WIN32
	struct HashFunc
	{
		size_t operator()(const string& strName)const
		{
			return __stl_hash_string(strName.c_str());
		}

	};
	typedef hash_map<string, CNormalSkillServerSharedPtr*, HashFunc,equal_to<string>,  TConfigAllocator<pair<string, CNormalSkillServerSharedPtr* > > >					MapNormalSkillServer;
#else
	typedef hash_map<string, CNormalSkillServerSharedPtr*, hash_compare<string, less<string> >,  TConfigAllocator<pair<string, CNormalSkillServerSharedPtr* > > >					MapNormalSkillServer;
#endif
	typedef vector<CNormalSkillServerSharedPtr*,  TConfigAllocator<CNormalSkillServerSharedPtr*> >						MapNormalSkillServerById;
	typedef map<string, EAlterNormalAttackType, less<string>, 
		TConfigAllocator<pair<string, EAlterNormalAttackType > > > MapAlterNormalAttackType;
	typedef map<string, EBarrierType, less<string>, 
		TConfigAllocator<pair<string, EBarrierType > > > MapBarrierType;
	typedef TStringRefer<CNormalSkillServer, CMagicEffServer>			MagicEffServerStringRefer;
	typedef TStringRefer<CNormalSkillServer, CCastingProcessCfgServer>	CastingProcessCfgServerStringRefer;

	static MapAlterNormalAttackType			ms_mapAlterNormalAttackType;
	static MapNormalSkillServer				ms_mapSkill;
	static MapNormalSkillServerById			ms_mapSkillById;
	static MapBarrierType					ms_mapBarrierType;

public:
	static bool			LoadSkillConfig(const string& szFileName);
	static bool			LoadNPCSkillConfig(const string& szFileName);
	static bool			LoadIntObjSkillConfig(const string& szFileName);
	static void			UnloadSkillConfig();
	static CNormalSkillServerSharedPtr&	GetSkillByName(const string&);
	static CNormalSkillServerSharedPtr&	GetSkillByID(uint32 uID);
	static CNormalSkillServerSharedPtr&	GetNPCSkill(const string&);
	static CNormalSkillServerSharedPtr&	GetIntObjSkill(const string&);
	static uint32		GetCount()							{return ms_mapSkill.size();}
	static void			UpdateCfg(const string& strName);

	CNormalSkillServer();
	CNormalSkillServer(const CNormalSkillServer& cfg);
	~CNormalSkillServer();
	void				DoPassiveSkillEffect(CSkillInstServer* pInst, CFighterDictator* pFrom, CGenericTarget* pTo, uint8 uSkillLevel)const;
	void				DoEffect(CSkillInstServer* pInst, CFighterDictator* pFrom, CGenericTarget* pTo, uint8 uSkillLevel, bool bDoSkillRule = true)const;
	EDoSkillResult		DoPlayerSkill(CSkillInstServer* pInst, CFighterMediator* pFrom, CGenericTarget* pTo, uint8 uSkillLevel)const;
	EDoSkillResult		DoPlayerPassiveSkill(CSkillInstServer* pInst, CFighterMediator* pFrom, CGenericTarget* pTo, uint8 uSkillLevel)const;
	EDoSkillResult		PreDoSkill(CSkillInstServer* pInst, CFighterMediator* pFrom, CGenericTarget* pTo)const;
	bool				IsCastSkillDistance(CSkillInstServer* pInst, CFighterDictator* pFrom, CGenericTarget* pTo, float fExtraDistRatio = 1.0f);
	void				DoCoolDown(CFighterDictator* pFrom, uint8 uSkillLevel)const;

	uint32				GetId()const						{return m_uId;}
	const string&		GetName()const						{return m_sName;}
	bool				GetHorseLimit()const				{return m_bHorseLimit;}
	bool				GetIsStanceSkill()const				{return m_bIsStanceSkill;}
	bool				GetTargetIsCorpse()const			{return m_bTargetAliveCheckIsIgnored;}
	EAlterNormalAttackType GetStartNormalAttack()const		{return m_eAlterNormalAttackType;}
	EFSTargetType		GetSelectTargetType()const			{return m_eSelectTargetType;}
	float				GetDistance(const CFighterDictator* pFrom, uint8 uSkillLevel)const;
	CCfgCalc*			GetMinCastSkillDistance()const		{return	m_pMinCastSkillDistance;}
	CCfgCalc*			GetMaxCastSkillDistance()const		{return	m_pMaxCastSkillDistance;}
	ESkillCoolDownType	GetCoolDownType()const				{return m_eCoolDownType;}
	CCfgCalc*			GetCoolDownTime()const				{return m_pCoolDownTime;}
	float				GetActiveTime()const				{return m_fActiveTime;}
	uint32				GetActiveCount()const				{return m_uActiveCount;}
	const CMagicEffServerSharedPtr&	GetMagicEff()const;
	EAttackType			GetAttackType()const				{return m_eAttackType;}
	EBarrierType		GetBarrierType()const				{return m_eBarrierType;}
	const string&		GetCastAction() const				{return m_sCastAction;}
	const CCastingProcessCfgServerSharedPtr&	GetCastingProcess()const;
	ECastingProcessType GetCastingProcessType();
	ESkillType			GetSkillType()const;
	uint32				GetSkillLevelByLevel(uint8 uSkillLevel)const;	
	bool				CheckDoSkillRule() const			{return m_bIsDoSkillRule;}

	void StartOrRestartNADueToSkillFailure(CFighterMediator* pFrom)const;
private:
	bool IsInsideOfDistance(CFighterDictator* pFrom, const CGenericTarget* pTo, uint32 uLevel, float fExtraDistRatio = 1.0f);
	void PrintFightInfo(CSkillInstServer* pInst, CFighterDictator* pFrom, CGenericTarget* pTo)const;
	void TriggerMsgBeforeDoingEffect(CSkillInstServer* pInst, CFighterDictator* pFrom)const;

private:
	static CNormalSkillServerSharedPtr ms_NULL;
	CCfgCalc*	m_pMinCastSkillDistance;	//��Сʩ������
	CCfgCalc*	m_pMaxCastSkillDistance;	//���ʩ������
	CCfgCalc*	m_pCoolDownTime;			//��ȴʱ��
	CCfgCalc*	m_pSkillLevel2Level;		// ���ܵȼ�ӳ��
	CCfgCalc*	m_pDistance;							
	float		m_fActiveTime;				//����ʱ��
	uint32		m_uActiveCount;				//�������
	bool		m_bHorseLimit;				//�Ƿ������＼��
	bool		m_bIsStanceSkill;			//�Ƿ�Ϊ��̬����
	bool		m_bTargetAliveCheckIsIgnored;				//Ŀ���Ƿ�Ϊʬ��
	EAlterNormalAttackType		m_eAlterNormalAttackType;	//���չ���Ӱ��
	ESkillCoolDownType			m_eCoolDownType;			//������ȴ����
	uint32		m_uId;						//���ܱ��
	string 		m_sName;					//��������
	EFSTargetType	m_eSelectTargetType;	//ѡ��Ŀ������
	MagicEffServerStringRefer*	m_pMagicEff;				//ħ��Ч��
	EAttackType	m_eAttackType;					//��������, �����ܵĹ����������������������;���
	string		m_sCastAction;					//���ֶ���
	CastingProcessCfgServerStringRefer*	m_pCastingProcess;
	bool		m_bIsDoSkillRule;				//�Ƿ���npc���ܹ���
	EBarrierType	m_eBarrierType;				//�����ϰ��������
};
