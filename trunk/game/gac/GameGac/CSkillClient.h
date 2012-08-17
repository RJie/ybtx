#pragma once
#include "FightDef.h"
#include "CMagicEffClient.h"
#include "CStaticObject.h"
#include "TCfgSharedPtr.h"
#include "CConfigMallocObject.h"
#include "TConfigAllocator.h"

DefineCfgSharedPtr(CSkillClient)


class CCfgCalc;
class CCastingProcessCfgClientSharedPtr;

class CSkillClient
	: public virtual CStaticObject
	, public CConfigMallocObject
{
public:
	CSkillClient();
	~CSkillClient();

	static					bool LoadSkillConfig(const string& szFileName);
	static					bool LoadNPCSkillConfig(const string& szFileName);
	static					bool LoadIntObjSkillConfig(const string& szFileName);
	static					void UnloadSkillConfig();

	static					CSkillClient* GetSkillByNameForLua(const TCHAR* szName);	//ע���lua�õ�
	static					CSkillClientSharedPtr& GetSkillByName(const TCHAR* szName);
	static					CSkillClientSharedPtr& GetSkillByID(uint32 uId);

	uint32					GetId()								{return m_uId;}
	const TCHAR*			GetName()							{return m_sName.c_str();}
	bool					GetIsUpdateDirection()				{return m_bIsUpdateDirection;}
	bool					GetHorseLimit()						{return m_bHorseLimit;}
	bool					GetIsStanceSkill()					{return m_bIsStanceSkill;}
	bool					GetTargetIsCorpse()					{return m_bTargetIsCorpse;}
	EFSTargetType			GetSelectTargetType()				{return m_eSelectTargetType;}
	EAttackType				GetAttackType()						{return m_eAttackType;}
	EAlterNormalAttackType	GetStartNormalAttack()const			{return m_eAlterNormalAttackType;}
	CCfgCalc*				GetMinCastSkillDistance()			{return	m_pMinCastSkillDistance;}
	CCfgCalc*				GetMaxCastSkillDistance()			{return	m_pMaxCastSkillDistance;}
	ESkillCoolDownType		GetCoolDownType()					{return m_eCoolDownType;}
	CCfgCalc*				GetCoolDownTime()					{return m_pCoolDownTime;}
	const TCHAR*			GetCastAction()						{return	m_sCastAction.c_str();}
	bool					IsAllBodyCastAni()					{return m_bAllBodyCastAni;}
	const TCHAR*			GetCastEffect()						{return m_sCastEffect.c_str();}
	CMagicEffClientSharedPtr&		GetMagicEff();
	uint32					GetPositionArea(CFighterDirector* pFrom, uint8 uSkillLevel);
	bool					MustIdle();	
	bool					HasCastingProcess()const;

	EConsumeType			GetConsumeType();
	CCfgCalc*				GetConsumeValue();
	ECastingProcessType     GetCastingProcessType();
	CCfgCalc*				GetCastingProcessTime();

private:
	typedef map<string, EAlterNormalAttackType, less<string>, 
		TConfigAllocator<pair<string, EAlterNormalAttackType > > > MapAlterNormalAttackType;
	typedef map<string, CSkillClientSharedPtr*, less<string>, TConfigAllocator<pair<string, CSkillClientSharedPtr*> > >	MapSkillClientByName;
	typedef vector<CSkillClientSharedPtr*, TConfigAllocator<CSkillClientSharedPtr*> >		MapSkillClientByID;
	void InitCastingProcess(const CCastingProcessCfgClientSharedPtr& cfg);

	static MapSkillClientByName		ms_mapSkillByName;
	static MapSkillClientByID		ms_mapSkillByID;
	static MapAlterNormalAttackType	ms_mapAlterNormalAttackType;

	uint32							m_uId;								//���ܱ��
	string 							m_sName;							//��������
	bool							m_bIsUpdateDirection;				//�Ƿ���·���
	bool							m_bHorseLimit;						//�Ƿ������＼��
	bool							m_bIsStanceSkill;					//�Ƿ�Ϊ��̬����
	bool							m_bTargetIsCorpse;					//Ŀ���Ƿ�Ϊʬ��
	EFSTargetType					m_eSelectTargetType;				//ѡ��Ŀ������
	EAttackType						m_eAttackType;						//��������
	CCfgCalc*						m_pMinCastSkillDistance;			//��Сʩ������
	CCfgCalc*						m_pMaxCastSkillDistance;			//���ʩ������
	ESkillCoolDownType				m_eCoolDownType;					//������ȴ����
	CCfgCalc*						m_pCoolDownTime;					//��ȴʱ��
	CCfgCalc*						m_pSkillLevel2Level;				//�ȼ�ӳ��
	string							m_sReachUpAction;					//���ֶ���
	string							m_sReachUpEffect;					//������Ч
	string							m_sCastAction;						//���ֶ���
	bool							m_bAllBodyCastAni;					//ȫ����ֶ���
	string							m_sCastEffect;						//������Ч
	string							m_sMagicEff;
	CCfgCalc*						m_pPositionArea;	
	CCfgCalc*						m_pCastingProcessTime;
	ECastingProcessType				m_eCastingProcessType;
	bool							m_bMustIdle;
	bool							m_bHasCastingProcess;
	EAlterNormalAttackType			m_eAlterNormalAttackType;		//���չ���Ӱ��
};
