#pragma once
#include "CTplStateCfgClient.h"
#include "CStaticObject.h"
#include "CAllStateMgrClient.h"
#include "TMagicStateAllocator.h"

class CMagicStateMgrClient;
class CMagicStateCategoryClient;
class CMagicStateClient;
class CFighterFollower;

typedef map<uint32, CMagicStateClient*, less<uint32>, TMagicStateAllocator<pair<uint32, CMagicStateClient*> > >			MapMagicStateClient;
typedef map<uint32, CMagicStateCategoryClient*, less<uint32>, TMagicStateAllocator<pair<uint32, CMagicStateCategoryClient*> > >	MapMagicStateCategoryClient;

//ħ��״̬
class CMagicStateClient
	: public CBaseStateClient
{
	friend class CMagicStateCategoryClient;
	friend class CMagicStateMgrClient;
public:
	virtual CBaseStateCfg*		GetCfg();
	virtual CFighterFollower*	GetOwner();
	//virtual uint32				GetDynamicID() {return m_uDynamicId;}
	virtual uint32				GetID() {return GetCfg()->GetId();}
	virtual uint32				GetCount()	{return m_uCount;}
private:
	CMagicStateClient(uint32 uDynamicId, uint32 uCount, int32 iTime, int32 iRemainTime,
		uint32 uSkillLevel, uint32 uInstallerID, int32 iCalcValue, CMagicStateCategoryClient* pMSCategory, CAllStateMgrClient* pAllStateMgr);
	void						UpdateCount(uint32 uCount)		{m_uCount = uCount;}
	//uint32						m_uDynamicId;					
	uint32						m_uCount;						//���ӵĴ���
	int32							m_iCalcValue;
	CMagicStateCategoryClient*	m_pMSCategory;					//������ħ�����࣬����ħ��״̬��ֱ�����������ڻ�ȡ���ñ�ָ��
};

//ħ��״̬����
class CMagicStateCategoryClient
	: public CMagicStateMallocObject
{
	friend class CMagicStateClient;
	friend class CMagicStateMgrClient;
public:
	CMagicStateCategoryClient(const CTplStateCfgClient<CMagicStateClient>::SharedPtrType& pCfg, CMagicStateMgrClient* pMgr)
		: m_pCfg(pCfg),
		m_pMgr(pMgr)
	{}
	~CMagicStateCategoryClient();

private:
	void AddMS(uint32 uCategoryId, uint32 uCount, int32 iTime, int32 iRemainTime, uint32 uSkillLevel,
		uint32 uInstallerID, int32 iCalcValue, CAllStateMgrClient* pAllStateMgr);	//���һ��ħ��״̬����
	MapMagicStateClient		m_mapMS;							//��ͬħ��״̬��ӳ���
	CTplStateCfgClient<CMagicStateClient>::SharedPtrType	m_pCfg;				//ħ��״̬���ñ����ָ��
	CMagicStateMgrClient*	m_pMgr;								//������ħ��״̬�����࣬�������������
};

//ħ��״̬������
class CMagicStateMgrClient
	: public virtual CStaticObject
	, public CMagicStateMallocObject
{
	friend class CMagicStateClient;
	friend class CMagicStateCategoryClient;
public:
	CMagicStateMgrClient(CFighterFollower* pOwner)
	{
		m_pOwner = pOwner;
	}
	~CMagicStateMgrClient()
	{
		ClearAll();
	}
	bool						SetState(uint32 uCategoryId, uint32 uDynamicId, uint32 uCount, int32 iTime, int32 iRemainTime, uint32 uSkillLevel,uint32 uInstallerID,int32 iCalcValue);			//����һ��״̬�����ڲ�ȷ���¼ӻ��Ǹ���״̬ʱ��
	//void						AddNewState(uint32 uCategoryId, uint32 uDynamicId);			//�¼�һ��״̬
	//void						UpdateState(uint32 uCategoryId, uint32 uDynamicId, uint32 uCount);			//����һ��״̬
	void						DeleteState(uint32 uCategoryId, uint32 uDynamicId);			//ɾ��һ��״̬
	bool						ExistState(const string& name);
	uint32						StateCount(const string& name);
	int32						StateLeftTime(const string& name, CFighterFollower* pFrom);
	//void						SetupStateList({uCategoryId, uDynamicId, uCount}[]);				//����һ��״̬����
	void						ClearAll();
	void						SetTargetBuff();
	bool						CanDecStateCascade(const string& name, uint32 uCascade);		//nameħ��״̬���Ӳ����Ƿ���ڵ���uCascade
	float						GetRemainTime(const TCHAR* sName, uint32 uDynamicId);
	
private:
	MapMagicStateCategoryClient	m_mapMSCategory;
	CFighterFollower*			m_pOwner;
};

