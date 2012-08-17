#pragma once
#include "CSpecialState.h"
#include "COtherStateMgr.h"

//����״̬��������
class CSpecialStateTypeBundle
	: public CMagicStateMallocObject
{
public:
	CSpecialStateTypeBundle() {}
	ListPSpecialState		m_listState;
};

class CSkillInstServer;
class CAllStateMgrServer;
class ICharacterMediatorCallbackHandler;
class CStateCondBase;
class CStateDBDataSet;

typedef map<ESpecialStateType, CSpecialStateTypeBundle>		MapSSTypeBandle;

class CSpecialStateMgrServer
	: public TOtherStateMgrServer<CSpecialStateCfgServer, CSpecialStateBase>
{
	friend class CSpecialStateBase;
	friend class CReflectStateServer;
	friend class CRepeatStateServer;
public:
	CSpecialStateMgrServer(CFighterDictator* pOwner)
		: TOtherStateMgrServer<CSpecialStateCfgServer, CSpecialStateBase>(pOwner)
	{

	}
	virtual ~CSpecialStateMgrServer()
	{
		ClearAll();
	}
	bool						SetupState(CSkillInstServer* pSkillInst, const CSpecialStateCfgServerSharedPtr& pCfg, CFighterDictator* pInstaller);		//��װ����ħ��״̬
	bool						RestoreStateFromDB(CSkillInstServer* pSkillInst, const CSpecialStateCfgServerSharedPtr& pCfg,
			CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime);
	bool						ExistStateByType(ESpecialStateType type);				//��ĳ������״̬
	void						ClearStateByType(ESpecialStateType type);
	virtual void				ClearAll();
	virtual CStateDBData*		CreateStateDBData(CSpecialStateBase* pState, int32 iRemainTime, CSkillInstServer* pInst);
	virtual bool				RestoreStateFromDB(CSkillInstServer* pSkillInst, const CSpecialStateCfgServerSharedPtr& pCfg,
		CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime, uint32 uAccumulate, float fProbability);	//�����ݿ�ָ�ĳ��״̬
	
private:
	CSpecialStateBase*			CreateSpecialState(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller,
		CSpecialStateMgrServer* pMgr, const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime = 0, int32 iRemainTime = 0);

	MapSSTypeBandle				m_mapStateTypeBundle;						//���͵�����ָ������ӳ���
};
//class CSpecialStateMgrServer
//{
//	friend class CSpecialStateBase;
//	friend class CReflectStateServer;
//	friend class CRepeatStateServer;
//public:
//	CSpecialStateMgrServer(CFighterDictator* pOwner=NULL);
//	~CSpecialStateMgrServer();
//	void						SetOwner(CFighterDictator* pOwner) {m_pOwner = pOwner;}			//��ʼ��Ŀ�����ָ��
//	bool						SetupSpecialState(CSkillInstServer* pSkillInst, const string& name, CFighterDictator* pInstaller);		//��װ����ħ��״̬
//	bool						RestoreSpecialStateFromDB(CSkillInstServer* pSkillInst, CSpecialStateCfgServer* pCfg,
//	bool						ExistSpecialState(const string& name);					//��ĳ������״̬
//	bool						ExistSpecialState(const string& name, const CFighterDictator* pInstaller);					//��ĳ�˰�װ��ĳ������״̬
//	bool						ExistSpecialState(ESpecialStateType type);				//��ĳ������״̬
//	void						ClearSpecialState(ESpecialStateType type);
//	void						ClearSpecialState(const string& name);
//	bool						ClearSpecialStateByCond(CStateCondBase* pStateCond, uint32 uId);
//	void						ClearAll();						//��������ʱ�������״̬
//	void						ClearAllByCond(CStateCondBase* pStateCond);
//	void						SyncAllState(CFighterDictator* pObserver, uint32 uNow);					//����ͬ����������״̬
//	CAllStateMgrServer*			GetAllMgr();					//��ȡ��ħ��״̬������
//	bool						SerializeToDB(CStateDBDataSet* pRet,
//		ICharacterMediatorCallbackHandler* pHandler, uint32 uFighterGlobalID, uint32 uNow);						//�����ݿ�дħ��״̬
//	bool						LoadFromDB(ICharacterMediatorCallbackHandler* pHandler, uint32 uFighterGlobalID);					//�����ݿ��ȡħ��״̬
//
//private:
//	CSpecialStateBase*			CreateSpecialState(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller,
//		CSpecialStateMgrServer* pMgr, CSpecialStateCfgServer* pCfg, int32 iTime = 0);
//
//private:
//	MapSpecialState				m_mapSS;						//����ħ��״̬���ൽ����ħ��״̬�����ӳ���
//	MapSSTypeBandle				m_mapSSTB;						//���͵�����ָ������ӳ���
//
//	CFighterDictator*			m_pOwner;						//Ŀ���������󣬼������������
//};

