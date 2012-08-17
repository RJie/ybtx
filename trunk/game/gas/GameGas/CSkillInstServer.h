#pragma once
#include "FightDef.h"
#include "CPos.h"
#include "PropertyType.h"
#include "CFighterMallocObject.h"

//#define TRACE_SKILLINST_COUNTER

class CFighterDictator;
class CPropertyHolder : public CBasePropertyHolder
{
public: 
	virtual ~CPropertyHolder(){}
	virtual void RevertPropertyValue(CFighterDictator* pFighter)=0;
	virtual void GetValueToStr(ostringstream& str) = 0;
};

class CSkillInstServer;
class CNormalSkillServerSharedPtr;

//ȫ��Inst�������¶�ջ���ݣ���ǰ��Ӱ�����
class CSkillGlobalInstServer
	:public CFighterMallocObject
{
	friend class CSkillInstServer;
public:
	void AddRef();
	void DelRef();
	ESkillType GetSkillType();

	const string&		GetSkillName()					{return m_strSkillName;}
	bool				GetForbitSetupState()			{return m_bForbitSetupState;}
	void				SetForbitSetupSavedState(bool bForbitSetupState)	{m_bForbitSetupState = bForbitSetupState;}
	uint8				GetLevelIndex()						{return m_uSkillLevel - 1;}

	uint32				m_uCreatorID;		// ���ܷ�����
	uint8               m_uSkillLevel;      // ���ܵȼ�
	string				m_strSkillName;		// ������
	EAttackType			m_eAttackType;		// ��������
	CFPos				m_SkillPos;			// ���ܵĳ�ʼλ��
	uint8				m_uDir;				// ʩ���ߵ��ص㷶Χ���ܵĳ���
	uint8				m_uMagicDir;		// �ص���ħ������ĳ���, ���ͷ�ǰ�����ʹ�ÿո�����趨
	CFPos				m_MagicBeginPos;	// ħ���ĳ�ʼλ��
	float				m_fValueScale;
	bool				m_bProcessLocked;	// ����������Ŀ��

private:
	CSkillGlobalInstServer(uint32 uCreatorID,const string& sSkillName, const CNormalSkillServerSharedPtr& pSkill, uint8 uSkillLevel, EAttackType eAttackType);
	CSkillGlobalInstServer();
	~CSkillGlobalInstServer();
	CSkillInstServer& operator=(const CSkillInstServer& other);


	bool				m_bForbitSetupState;// �Ƿ��ֹ��װ״̬����������ݿ�ָ�״̬ʱ�Ŀɳ���Ч���ﲻ�����ٸ��Լ���װ״̬��
	uint32				m_uCounter;
	CNormalSkillServerSharedPtr*	m_pSkill;

	//���²��Ը�����
#ifdef TRACE_SKILLINST_COUNTER
	uint32									m_uID;
#endif
};

//����Inst�����¶�ջ���ݣ������϶�ջ���ݣ����Ӱ����󣬲���ǰӰ�����
class CSkillDupliInstServer
	:public CFighterMallocObject
{
	friend class CSkillInstServer;
public:
	void AddRef();
	void DelRef();

	static CSkillDupliInstServer* CreateBranch(CSkillDupliInstServer* pSkillDupliInst);

	//bool				GetTrigger()						{return m_bIsTrigger;}
	//void 				SetTrigger(bool bIsTrigger)			{m_bIsTrigger = bIsTrigger;}

private:
	CSkillDupliInstServer();
	CSkillDupliInstServer(CSkillDupliInstServer* pSkillInst);
	//void Release(CSkillInstServer* pSkillInst);
	~CSkillDupliInstServer();
	CSkillInstServer& operator=(const CSkillInstServer& other);



	bool				m_bTargetAliveCheckIsIgnored;

	bool				m_bIsTrigger;

	bool				m_bIsScopeTargetMop;

	uint32				m_uCounter;

	//���²��Ը�����
#ifdef TRACE_SKILLINST_COUNTER
	uint32									m_uID;
#endif
};

//�ֲ�Inst����ԭ���ϣ�ֻ�ڱ����ջ�ڻ�������ݵ��²��ջ������ǰ��Ӱ�����
class CSkillLocalInstServer
	:public CFighterMallocObject
{
	friend class CSkillInstServer;
public:
	virtual uint32		GetStateId()					{return 0;}
	virtual void		SetStateId(uint32 uStateId);
	virtual bool		GetInterval()						{return false;}
	virtual void 		SetInterval(bool bIsDOT);
	virtual EInstType	GetType() = 0;
	virtual bool		GetIsCalc()						{return false;}
	virtual void		SetIsCalc(bool bIsCalc);
	//EInstType			m_eInstType;
	void				AddRef();
	bool				DelRef();
	uint32				GetRef()	{return m_uCounter;}
	bool				GetContainerExist() {return m_bContainerExist;}
	void				SetContainerExist(bool bExist) {m_bContainerExist = bExist;}
protected:
	CSkillLocalInstServer();
	virtual				~CSkillLocalInstServer();

	uint32				m_uCounter;
	bool				m_bContainerExist;
	//���²��Ը�����
	uint32									m_uID;
};

//״̬ר�þֲ�Inst
class CSkillStateInstServer
	:public CSkillLocalInstServer
{
	friend class CSkillInstServer;
public:
	uint32				GetStateId()					{return m_uStateId;}
	void				SetStateId(uint32 uStateId)		{m_uStateId = uStateId;}
	EInstType			GetType()						{return eIT_StateInst;}

	uint32				m_uStateId;

protected:
	CSkillStateInstServer() : m_uStateId(0)			{}
	~CSkillStateInstServer() {};
};

class CMagicStateCfgServerSharedPtr;

enum EMagicStateEffType
{
	eMSET_Undefined,
	eMSET_Cancellable,
	eMSET_Dot,
	eMSET_Final
};

//ħ��״̬ר�þֲ�Inst
class CSkillMagicStateInstServer
	:public CSkillStateInstServer
{
	friend class CSkillInstServer;
public:
	CSkillMagicStateInstServer(CMagicStateCfgServerSharedPtr& pCfg, EMagicStateEffType eMagicStateEffType);
	virtual ~CSkillMagicStateInstServer();
	bool				GetInterval()						{return m_bIsInterval;}
	void 				SetInterval(bool bIsDOT)				{m_bIsInterval = bIsDOT;}
	bool				GetIsCalc()						{return m_bIsCalc;}
	void				SetIsCalc(bool bIsCalc)			{m_bIsCalc = bIsCalc;}
	EMagicStateEffType	GetMagicStateEffType()			{return m_eMagicStateEffType;}
	EInstType			GetType()						{return eIT_MagicStateInst;}
	CMagicStateCfgServerSharedPtr& GetCfg();

	static EMagicStateEffType GetMagicStateEffTypeByTitle(const string& sTitle);

private:
	static bool		InitMap()
	{
		m_mapMagicStateEffType["�ɳ���"] = eMSET_Cancellable;
		m_mapMagicStateEffType["���"] = eMSET_Dot;
		m_mapMagicStateEffType["����"] = eMSET_Final;
		return true;
	}
	static bool		m_bInit;

	static map<string, EMagicStateEffType>	m_mapMagicStateEffType;
	EMagicStateEffType	m_eMagicStateEffType;
	CMagicStateCfgServerSharedPtr*	m_pCfg;
	bool				m_bIsInterval;			// ��DOT�˺�
	bool				m_bIsCalc;						//�����־λ
};


//�չ�ר�þֲ�Inst
class CNAInstServer : public CSkillLocalInstServer
{
	friend class CSkillInstServer;
public:
	CNAInstServer()
		: m_eHurtResult(eHR_Fail)
		, m_uAniIndex(0)
		, m_bIsMainHandNA(false)
	{
		//m_eInstType=eIT_NormalAttackInst;
	}
	virtual EInstType	GetType()							{return eIT_NormalAttackInst;}
	EHurtResult			GetHurtResult()const				{return m_eHurtResult;}
	void				SetHurtResult(EHurtResult eHurtResult)	{ m_eHurtResult = eHurtResult; }
	void				SetAniIndex(uint32 uIndex)				{m_uAniIndex = uIndex;}
	uint32				GetAniIndex()const						{return m_uAniIndex;}
	void				SetMainHandNA(bool bIsMainHandNA)		{m_bIsMainHandNA = bIsMainHandNA;}
	bool				IsMainHandNA()const						{return m_bIsMainHandNA;}
	void				SetNACfgId(uint32 uNACfgId)				{m_uNACfgId  = uNACfgId;}
	uint32				GetNACfgId()							{return m_uNACfgId;}
private:
	virtual				~CNAInstServer(){}
	EHurtResult			m_eHurtResult;
	uint32				m_uAniIndex;		// �չ�������������ı��0,1,2
	bool				m_bIsMainHandNA;	// �Ƿ��������չ�
	uint32				m_uNACfgId;			// �չ����ñ�Id

};

//���ܹ����е������ı���
//������ֵ�����������С�������ڣ��Ķ�����λ
class CSkillInstServer
	:public CFighterMallocObject
{
	friend class CSkillGlobalInstServer;
	friend class CSkillDupliInstServer;
	friend class CSkillLocalInstServer;
public:
	void				AddRef();
	void				DelRef();


	//����������Ƿ�װ�ɴ����ݺ���
	//static CSkillInstServer*	CopyByRef(CSkillInstServer* pSkillInst);
	//����ԴͷSkillInst
	static CSkillInstServer*	CreateOrigin(uint32 uCreatorID,const string& sSkillName, uint8 uSkillLevel, EAttackType eAttackType);			//�Զ�����CSkillGlobalInstServer,CSkillLocalInstServer
	static CSkillInstServer*	CreateOrigin(uint32 uCreatorID, const string& sSkillName, const CNormalSkillServerSharedPtr& pSkill, uint8 uSkillLevel, EAttackType eAttackType);			//�Զ�����CSkillGlobalInstServer,CSkillLocalInstServer
	void						DestroyOrigin();
	//������Ҫ�չ��ֲ���Ա��SkillInst
	static CSkillInstServer*	CreateNAOrigin();
	void						DestroyNAOrigin();
	//����ֻ��Ҫ����ֵ��������SkillInst
	static CSkillInstServer*	CreateTransfer(CSkillInstServer* pSkillInst);
	void						DestroyTransfer();
	//������Ҫ���ϳ�Ա��SkillInst
	static CSkillInstServer*	CreatePartition(CSkillInstServer* pSkillInst);
	void						DestroyPartition();
	//������Ҫ�ֲ���Ա��SkillInst�����������ɲ�������
	//static CSkillInstServer*	CreateLocal(CSkillInstServer* pSkillInst, EInstType eInstType = eIT_None);
	static CSkillInstServer*	CreateLocal(CSkillInstServer* pSkillInst, CSkillLocalInstServer* pLocalInst);
	void						DestroyLocal();
	CSkillLocalInstServer*		GetLocalInst()					{return m_pLocal;}
						//static CSkillInstServer* CreateBranch(CSkillInstServer* SkillInst);
	typedef map<pair<string,uint32> , CPropertyHolder*, less<pair<string,uint32> >, TFighterAllocator<pair<pair<string,uint32>, CPropertyHolder* > > > MapPropertyChange;

	ESkillType			GetSkillType()							{return m_pGlobal->GetSkillType();}
	uint32				GetCreatorID()							{return m_pGlobal->m_uCreatorID;}
	void				SetCreatorID(uint32 uCreatorID)			{m_pGlobal->m_uCreatorID = uCreatorID;}
	const CNormalSkillServerSharedPtr& GetSkillCfg()const;
	const string&		GetSkillName()							{return m_pGlobal->GetSkillName();}
	void				SetSkillName(const string& sSkillName)	{m_pGlobal->m_strSkillName = sSkillName;}
	bool				GetForbitSetupState()					{return m_pGlobal->m_bForbitSetupState;}
	void				SetForbitSetupSavedState(bool bForbitSetupState)
																{m_pGlobal->m_bForbitSetupState = bForbitSetupState;}
	uint8				GetLevelIndex()							{return m_pGlobal->GetLevelIndex();}
	uint8				GetSkillLevel()							{return m_pGlobal->m_uSkillLevel;}
	void				InitSkillLevel(uint8 uSkillLevel);
	EAttackType			GetAttackType()							{return m_pGlobal->m_eAttackType;}
	void				SetAttackType(EAttackType eType)		{m_pGlobal->m_eAttackType = eType;}
	const CFPos&		GetSkillPos()							{return m_pGlobal->m_SkillPos;}
	void				SetSkillPos(const CFPos& pos)			{m_pGlobal->m_SkillPos = pos;}
	uint8				GetDir()								{return m_pGlobal->m_uDir;}
	void				SetDir(uint8 uDir)						{m_pGlobal->m_uDir = uDir;}
	uint8				GetMagicDir()							{return m_pGlobal->m_uMagicDir;}
	void				SetMagicDir(uint8 uMagicDir)			{m_pGlobal->m_uMagicDir = uMagicDir;}
	const CFPos&		GetMagicBeginPos()						{return m_pGlobal->m_MagicBeginPos;}
	void				SetMagicBeginPos(const CFPos& pos)		{m_pGlobal->m_MagicBeginPos = pos;}
	float				GetValueScale()							{return m_pGlobal->m_fValueScale;}
	void				SetValueScale(float fValueScale)		{m_pGlobal->m_fValueScale = fValueScale;}
	bool				GetProcessLocked()						{return m_pGlobal->m_bProcessLocked;}
	void				SetProcessLocked(bool bLock)			{m_pGlobal->m_bProcessLocked = bLock;}
	
	bool				GetTrigger()							{return m_pDupli->m_bIsTrigger;}
	void				SetTrigger(bool bIsTrigger)				{m_pDupli->m_bIsTrigger = bIsTrigger;}
	bool				GetTargetAliveCheckIsIgnored()			{return m_pDupli->m_bTargetAliveCheckIsIgnored;}
	void				SetTargetAliveCheckIsIgnored(bool bTargetAliveCheckIsIgnored)
																{m_pDupli->m_bTargetAliveCheckIsIgnored = bTargetAliveCheckIsIgnored;}
	bool				GetIsScopeTargetMop()					{return m_pDupli->m_bIsScopeTargetMop;}
	void				SetIsScopeTargetMop(bool bIsScopeTargetMop)
																{m_pDupli->m_bIsScopeTargetMop = bIsScopeTargetMop;}

	EInstType			GetType();
	uint32				GetStateId();
	void				SetStateId(uint32 uStateId);
	bool				GetInterval();
	void				SetInterval(bool bIsDOT);
	bool				GetIsCalc();
	void				SetIsCalc(bool bIsCalc);



	CSkillMagicStateInstServer*		GetMagicStateInst();
	CNAInstServer*		GetNAInstServer();

	template<typename PropertyType>
	void				SetPropertyAdderChange(PropertyType& pProperty,uint32 uOwnerID,int32 iValue);
	template<typename PropertyType>
	void				SetPropertyMultiplierChange(PropertyType& pProperty,uint32 uOwnerID,float fValue);

	void				RevertPropertyMap(MapPropertyChange& mapProperty);

	void				SetShockWaveCounter(uint32 uCount) { m_uShockWaveCounter = uCount; }
	uint32				GetShockWaveCounter() { return m_uShockWaveCounter; }

	void				SetIsMagic(bool bIsMagic) { m_bIsMagic = bIsMagic; }
	bool				GetIsMagic() { return m_bIsMagic; }

	void				SetIsArea(bool bArea) { m_bIsArea = bArea; }
	bool				GetIsArea() { return m_bIsArea; }

	void				SetIsTalent(bool bIsTalent) { m_bIsTalent = bIsTalent; }
	bool				GetIsTalent() { return m_bIsTalent; }

	void				SetBeLastEffect(bool bLastEffect) { m_bLastEffect = bLastEffect; }
	bool				BeLastEffect()	{ return m_bLastEffect; }

	void				AddEffectHPChangeValue(uint32 uHPChange) { m_uOneEffectHPChangeValue += uHPChange; }
	void				SetEffectHPChangeValue(uint32 uHPChange) { m_uOneEffectHPChangeValue = uHPChange; }
	uint32				GetEffectHPChangeValue()	{ return m_uOneEffectHPChangeValue; }


	void				SetIsPassive(bool bPassive) { m_bPassive = bPassive; }
	bool				GetIsPassive()	{ return m_bPassive; }

	uint32				GetRef() {return m_uCounter;}

	CSkillGlobalInstServer*					m_pGlobal;
	CSkillDupliInstServer*					m_pDupli;
	CSkillLocalInstServer*					m_pLocal;

private:
	CSkillInstServer();
	~CSkillInstServer();
	uint32				m_uCounter;

	MapPropertyChange	m_mapPropertyAdderChange;
	MapPropertyChange	m_mapPropertyMultiplierChange;
	uint32				m_uShockWaveCounter;		
	bool				m_bIsMagic;
	bool				m_bIsTalent;
	bool				m_bIsArea;
	bool				m_bLastEffect;
	uint32				m_uOneEffectHPChangeValue;
	bool				m_bPassive;

	//���²��Ը�����
#ifdef TRACE_SKILLINST_COUNTER
	static uint32							CreateInstID()	{return ++m_uMaxAllInstID;}
	static uint32							m_uMaxAllInstID;
	uint32									m_uID;
#endif
};


