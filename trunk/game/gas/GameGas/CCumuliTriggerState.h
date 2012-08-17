#pragma once
#include "CTriggerableState.h"
#include "TMagicStateAllocator.h"

class CCumuliTriggerStateServer;
class CCumuliTriggerStateMgrServer;
class CCumuliTriggerStateCfgServerSharedPtr;

typedef list<CCumuliTriggerStateServer*, TMagicStateAllocator<CCumuliTriggerStateServer*> >
ListPCumuliTriggerState;
typedef map<CCumuliTriggerStateCfgServer*, CCumuliTriggerStateServer*, less<CCumuliTriggerStateCfgServer*>,
TMagicStateAllocator<pair<CCumuliTriggerStateCfgServer*, CCumuliTriggerStateServer*> > >
MapCumuliTriggerState;





template<typename CfgType, typename StateType>
class TTriggerableStateMgrServer;
template<typename StateType>
class TStateBundleByEvent;

//�˺��ı�״̬
class CCumuliTriggerStateServer
	: public CTriggerableStateServer
{
	friend class TOtherStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>;
	friend class TTriggerableStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>;
	friend class CCumuliTriggerStateMgrServer;

public:
	virtual CBaseStateCfgServer*	GetCfg();
	CCumuliTriggerStateCfgServerSharedPtr& GetCfgSharedPtr()const;
	virtual CFighterDictator*	GetOwner();								//��ȡӵ����
	virtual CAllStateMgrServer*	GetAllMgr();

	~CCumuliTriggerStateServer();

private:
	CCumuliTriggerStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
		TTriggerableStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>* pMgr, 
		const CCumuliTriggerStateCfgServerSharedPtr& pCfg, uint32 uAccumulate = 0, int32 iTime = 0, int32 iRemainTime = 0, float fProbability = 0.0f);

	virtual void				DeleteSelf();				//ɾ���Լ��͹��������Լ���ָ��
	virtual void				DeleteSelfExceptItr();		//ɾ���Լ�����ɾ�����������Լ���ָ��
	void						PrepareDeleteSelf();		//ɾ���Լ�ǰ�����й���
	void						DeleteItr();				//ɾ�����������Լ���ָ��
	virtual pair<bool, bool>	MessageEvent(uint32 uEventID, CGenericTarget * pTrigger);	//��֪ͨ�¼�����
	virtual void				OnCOREvent(CPtCORSubject* pSubject,uint32 uEvent,void* pArg);
	virtual void				ChangeInstaller(CFighterDictator* pInstaller);

	CCumuliTriggerStateMgrServer*		m_pMgr;				//������ħ��״̬�����࣬�������������
	TStateBundleByEvent<CCumuliTriggerStateServer>*				m_pStateEventBundle;//���ڵ��¼�������EventBandleָ��
	MapCumuliTriggerState::iterator		m_mapStateItr;		//�Լ���״̬����CumuliTriggerState�б��λ��
	ListPCumuliTriggerState::iterator	m_listStateItr;		//�Լ����¼�������EventBandleӳ���е�λ��
	CCumuliTriggerStateCfgServerSharedPtr*	m_pCfg;			//ħ��״̬���ñ����ָ��
};

