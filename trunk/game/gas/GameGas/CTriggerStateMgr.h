#pragma once
#include "CTriggerState.h"
#include "CTriggerableStateMgr.h"



class CTriggerStateMgrServer
	: public TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>
{
public:
	CTriggerStateMgrServer(CFighterDictator* pOwner)
		: TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>(pOwner)
	{

	}
};

//class CAllStateMgrServer;
//
//namespace sqr
//{
//	class ICharacterMediatorCallbackHandler;
//};
//
//class CStateCondBase;
//class CStateDBDataSet;

////������״̬����
//class CTriggerStateMgrServer :
//	public TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>,
//	public CPtCORHandler
//{
//	friend class CTriggerableStateServer;
//	friend class CTriggerStateServer;
//	friend class CDamageChangeStateServer;
//
//public:
//	CTriggerStateMgrServer():m_pOwner(NULL)
//	{
//	}
//	~CTriggerStateMgrServer()
//	{
//		ClearAll();
//	}
//	void						SetOwner(CFighterDictator* pOwner) {m_pOwner = pOwner;}			//��ʼ��Ŀ�����ָ��
//	bool						SetupTriggerState(CSkillInstServer* pSkillInst, const string& name, CFighterDictator* pInstaller);		//��װħ��״̬
//	bool						RestoreTriggerStateFromDB(CSkillInstServer* pSkillInst, CTriggerStateCfgServer* pCfg,
//		CFighterDictator* pInstaller, int32 iRemainTime, uint32 uAccumulate, float fProbability);	//�����ݿ�ָ�ĳ��״̬
//	CTriggerStateServer*		FindTriggerState(const string& name);						//����Ƿ��������Ϊname�Ĵ�����״̬
//	bool						ExistState(const string& name);						//����Ƿ��������Ϊname�Ĵ�����״̬
//	bool						ExistState(const string& name, const CFighterDictator* pInstaller);						//����Ƿ����pInstaller��װ������Ϊname�Ĵ�����״̬
//	//bool						EraseTriggerState(uint32 uId);	//ɾ��ĳ��ID��״̬
//	void						ClearTriggerState(const string& name);
//	bool						ClearTriggerStateByCond(CStateCondBase* pStateCond, uint32 uId);
//	bool						SetupDamageChangeState(CSkillInstServer* pSkillInst, const string& name, CFighterDictator* pInstaller);		//��װħ��״̬
//	bool						RestoreDamageChangeStateFromDB(CSkillInstServer* pSkillInst, CDamageChangeStateCfgServer* pCfg,
//		CFighterDictator* pInstaller, int32 iRemainTime, uint32 uAccumulate, float fProbability);	//�����ݿ�ָ�ĳ��״̬
//	bool						ExistState(const string& name);						//����Ƿ��������Ϊname�Ĵ�����״̬
//	bool						ExistState(const string& name, const CFighterDictator* pInstaller);						//����Ƿ����pInstaller��װ������Ϊname�Ĵ�����״̬
//	//bool						EraseDamageChangeState(uint32 uId);
//	void						ClearDamageChangeState(const string& name);
//	bool						ClearDamageChangeStateByCond(CStateCondBase* pStateCond, uint32 uId);
//	bool						MessageEvent(uint32 uEventID, CFighterDictator* pTrigger, ETriggerStateType eType = eTST_All);	
//	bool						MessageEvent(uint32 uEventID, const CPos& pTrigger, ETriggerStateType eType = eTST_All);	
//	bool						MessageEvent(uint32 uEventID, CGenericTarget* pTrigger, ETriggerStateType eType = eTST_All);	
//	//��֪ͨ�¼�����
//	void						ClearAll();						//��������ʱ�������״̬
//	void						ClearAllByCond(CStateCondBase* pStateCond);
//	bool						CountSub(const string& name);	//���ڴ��ⲿ�ֶ������¼�ʱ����һ�����ô���
//	void						SyncAllState(CFighterDictator* pObserver, uint32 uNow);					//����ͬ�����д�����״̬���˺����״̬
//	CAllStateMgrServer*			GetAllMgr();					//��ȡ��ħ��״̬������
//	bool						SerializeToDB(CStateDBDataSet* pRet,
//		ICharacterMediatorCallbackHandler* pHandler, uint32 uFighterGlobalID, uint32 uNow);						//�����ݿ�дħ��״̬
//	bool						LoadFromDB(ICharacterMediatorCallbackHandler* pHandler, uint32 uFighterGlobalID);					//�����ݿ��ȡħ��״̬
//
//private:
//	MapTriggerState				m_mapTS;						//������״̬���ൽ������״̬�����ӳ���
//	MapDamageChangeState		m_mapDS;						//�˺����״̬���ൽ�˺����״̬�����ӳ���
//	MapTSEventBandle			m_mapBSEB;						//�¼����͵�״̬����ָ������ӳ���
//	CFighterDictator*			m_pOwner;						//Ŀ���������󣬼��������ӵ����
//
//};
