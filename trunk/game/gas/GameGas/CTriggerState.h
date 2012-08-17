#pragma once
#include "CTriggerableState.h"
#include "TMagicStateAllocator.h"

class CTriggerStateMgrServer;
class CFighterDictator;
class CTriggerStateServer;
class CDamageChangeStateServer;
class CSkillInstServer;
class CGenericTarget;
class CTriggerStateCfgServerSharedPtr;

typedef list<CTriggerStateServer*, TMagicStateAllocator<CTriggerStateServer*> >									ListPTriggerState;
typedef map<CTriggerStateCfgServer*, CTriggerStateServer*, less<CTriggerStateCfgServer*>,
	TMagicStateAllocator<pair<CTriggerStateCfgServer*, CTriggerStateServer*> > >
	MapTriggerState;

template<typename CfgType, typename StateType>
class TTriggerableStateMgrServer;
template<typename StateType>
class TStateBundleByEvent;

//������״̬
class CTriggerStateServer
	: public CTriggerableStateServer
{
friend class TOtherStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>;
friend class TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>;
friend class CTriggerStateMgrServer;

public:
	virtual CBaseStateCfgServer* GetCfg();
	CTriggerStateCfgServerSharedPtr& GetCfgSharedPtr()const;
	virtual CFighterDictator*	GetOwner();								//��ȡӵ����
	virtual CAllStateMgrServer*	GetAllMgr();
	virtual pair<bool, bool>	MessageEvent(uint32 uEventID, CGenericTarget * pTrigger);	//��֪ͨ�¼�����
	~CTriggerStateServer();

private:
	CTriggerStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
		TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>* pMgr, 
		const CTriggerStateCfgServerSharedPtr& pCfg, uint32 uAccumulate = 0, int32 iTime = 0, int32 iRemainTime = 0, float fProbability = 0.0f);

	virtual void				DeleteSelf();				//ɾ���Լ��͹��������Լ���ָ��
	virtual void				DeleteSelfExceptItr();		//ɾ���Լ�����ɾ�����������Լ���ָ��
	void						PrepareDeleteSelf();		//ɾ���Լ�ǰ�����й���
	void						DeleteItr();				//ɾ�����������Լ���ָ��
	virtual bool				DoCancelableMagicEff(bool bFromDB);		//ִ�пɳ���ħ��Ч��
	virtual void				CancelCancelableMagicEff();	//�����ɳ���ħ��Ч��

	CTriggerStateMgrServer*		m_pMgr;				//������ħ��״̬�����࣬�������������
	TStateBundleByEvent<CTriggerStateServer>*	m_pStateEventBundle;					//���ڵ��¼�������EventBandleָ��
	MapTriggerState::iterator	m_mapStateItr;				//�Լ���״̬����TriggerState�б��λ��
	ListPTriggerState::iterator	m_listStateItr;				//�Լ����¼�������EventBandleӳ���е�λ��
	CTriggerStateCfgServerSharedPtr* m_pCfg;
};



