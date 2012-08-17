#pragma once
#include "CMagicState.h"

class CMagicEffServer;
class CMagicStateCfgServer;
class CMagicStateCfgServerSharedPtr;


//ħ��״̬���࣬����ͬFighter���ӵĶ��ͬ��ħ��״̬
class CMagicStateCategoryServer
	: public CMagicStateMallocObject
{
	friend class CMagicStateServer;
	friend class CMagicStateMgrServer;
public:
	CMagicStateCategoryServer(const CMagicStateCfgServerSharedPtr& pCfg, CMagicStateMgrServer* pMgr);
	~CMagicStateCategoryServer();

	CMagicStateCfgServerSharedPtr& GetCfg()const;

private:
	pair<bool, MultiMapMagicState::iterator> AddMS(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller);			//��������һ��ħ��״̬Ԫ�ص���ħ��״̬�����map
	pair<bool, MultiMapMagicState::iterator> AddMSFromDB(CSkillInstServer* pSkillInst, CMagicStateCascadeDataMgr* pCancelableDataMgr,
		CMagicStateCascadeDataMgr* pDotDataMgr, CMagicStateCascadeDataMgr* pFinaDataMgr, CFighterDictator* pInstaller, 
		uint32 uCount, int32 iTime, int32 iRemainTime);	//���ڴ����ݿ�ָ�һ��ħ��״̬Ԫ�ص���ħ��״̬�����map
	MultiMapMagicState		m_mtmapMS;	//��ͬ�˵�ħ��״̬��ӳ���
	CMagicStateCfgServerSharedPtr*	m_pCfg;		//ħ��״̬���ñ����ָ��
	CMagicStateMgrServer*	m_pMgr;		//������ħ��״̬�����࣬�������������
};

class CSkillInstServer;

class CAllStateMgrServer;
class ICharacterDictatorCallbackHandler;
class CStateCondBase;
class CStateDBDataSet;
class CRivalStateMgr;

//ħ��״̬����
//ÿ��CFighterDictator��Ҫ����һ�������Ա��������Ϸ��ʼ����������ʱ��ʼ����
//��Ҫ����ΪCFighterDictator��ָ�룬��Ŀ�ꡣ
class CMagicStateMgrServer 
	: public CPtCORHandler
	, public CMagicStateMallocObject
{
	friend class CMagicStateServer;
	friend class CMagicStateCategoryServer;

public:
	CMagicStateMgrServer(CFighterDictator* pOwner);
	~CMagicStateMgrServer();
	//void						SetOwner(CFighterDictator* pOwner);				//��ʼ��Ŀ�����ָ��
	void						UnloadFighter();
	bool						IgnoreImmuneSetupState(CSkillInstServer* pSkillInst, const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller);					// �������߰�װħ��״̬
	bool						SetupState(CSkillInstServer* pSkillInst, const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller);		//��װħ��״̬
	bool						ExistState(const string& name);
	bool						ExistState(const CMagicStateCfgServerSharedPtr& pCfg);
	bool						ExistState(const CMagicStateCfgServerSharedPtr& pCfg, const CFighterDictator *pInstaller);
	//bool						ExistState(uint32 DynamicId);
	uint32						MagicStateCount(const string& name);
	uint32						MagicStateCountOfInstaller(const string& name, const CFighterDictator* pInstaller);
	int32						StateLeftTime(const string& name, const CFighterDictator* pInstaller);
	void						ClearState(const CMagicStateCfgServerSharedPtr& pCfg);				//ɾ��һ��ħ��״̬��ǿ�ƣ�
	//void						ClearState(const string& name, CFighterDictator* pInstaller);					//ɾ��һ��ħ��״̬��ǿ�ƣ�
	void						InstallerOffline(CFighterDictator * pInstaller);			//ĳ��ʩ��������ʱ�����������
	virtual void				OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg);
	void						ClearAll();						//��������ʱ�������״̬��ֻ����ɾ��Fighter����ʱʹ�ã����ƣ�
	bool						ExistStateByCond(CStateCondBase* pStateCond);
	void						ClearAllByCond(CStateCondBase * pStateCond);
	bool						ClearStateByCond(CStateCondBase* pStateCond, uint32 uId);
	void						ReflectAllByCond(CStateCondBase * pStateCond);
	//bool						ClearStateByCondAndDynamicId(CStateCondBase* pStateCond, uint32 uDynamicId);
	void						SyncAllState(CFighterDictator* pObserver, uint64 uNow);					//�������ÿͻ�������״̬
	CAllStateMgrServer*			GetAllMgr();					//��ȡ��ħ��״̬������
	bool						CanDecStateCascade(const CMagicStateCfgServerSharedPtr& pCfg, uint32 uCascade);					//�ж�nameħ��״̬�ܲ����Ƿ���ڻ����uCasecade
	bool						DecStateCascade(const CMagicStateCfgServerSharedPtr& pCfg, uint32 uCascade, bool bInCancel = false);						//nameħ��״̬����uCascade��
	bool						SerializeToDB(CStateDBDataSet* pRet,	
		ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID, uint64 uNow, uint32 uGrade);				//�����ݿ�д״̬
	bool						LoadFromDB(ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID);						//�����ݿ��ȡ״̬
	bool						CreateDataMgrFromDB(ICharacterDictatorCallbackHandler* pHandler, uint32 uFighterGlobalID,
		CMagicStateCascadeDataMgr*& pCascadeDataMgr, CSkillInstServer* pSkillInst, uint32 uInstID, const string& sEffTitle,
		uint32 uCascadeMax, CFighterDictator* pInstaller, const CMagicEffServerSharedPtr& pMagicEff, const CMagicStateCfgServerSharedPtr& pCfg);	//�����ݿ��ȡ״̬������
	bool						RestoreStateFromDB(CSkillInstServer* pSkillInst, const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller, 
		int32 iTime, int32 iRemainTime, uint32 uCount, CMagicStateCascadeDataMgr* pCancelableDataMgr, 
		CMagicStateCascadeDataMgr* pDotDataMgr, CMagicStateCascadeDataMgr* pFinalDataMgr);		//�����ݿ�ָ�һ��״̬
	bool						ResetTime(const CMagicStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller = NULL);		//ֻˢ��״̬ʱ��
	bool						AddTime(const CMagicStateCfgServerSharedPtr& pCfg, int32 iTime);
	CRivalStateMgr*				GetRivalStateMgr()	{return m_pRivalStateMgr;}
private:
	//void						AddStateTarget(CFighterDictator* pTarget);
	//void						DelStateTarget(CFighterDictator* pTarget);
	//bool						SetupMagicState(CSkillInstServer* pSkillInst,CMagicStateCfgServer* pCfg, const uint32& grade, CFighterDictator* pInstaller);

	//��װħ��״̬

	MapMagicStateCategory		m_mapMSCategory;				//״̬�����
	CFighterDictator*			m_pOwner;						//�������󣬼��������ӵ����
	//SetStateTarget			m_setTarget;					//����������װ״̬�Ķ���

	//uint32						m_uMaxDynamicId;				//��ǰ����ħ��״̬ID
	//MapMagicStateByDynamicId	m_mapMSByDynamicId;				//����̬ID�ŵ�ħ��״̬����

	CRivalStateMgr*				m_pRivalStateMgr;

};

