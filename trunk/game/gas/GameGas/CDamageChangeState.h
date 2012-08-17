#pragma once
#include "CTriggerableState.h"
#include "TMagicStateAllocator.h"

class CDamageChangeStateServer;
class CDamageChangeStateMgrServer;
class CDamageChangeStateCfgServerSharedPtr;

typedef list<CDamageChangeStateServer*, TMagicStateAllocator<CDamageChangeStateServer*> >
	ListPDamageChangeState;
typedef map<CDamageChangeStateCfgServer*, CDamageChangeStateServer*, less<CDamageChangeStateCfgServer*>,
	TMagicStateAllocator<pair<CDamageChangeStateCfgServer*, CDamageChangeStateServer*> > >
	MapDamageChangeState;





template<typename CfgType, typename StateType>
class TTriggerableStateMgrServer;
template<typename StateType>
class TStateBundleByEvent;

//�˺��ı�״̬
class CDamageChangeStateServer
	: public CTriggerableStateServer
{
	friend class TOtherStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;
	friend class TTriggerableStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;
	friend class CDamageChangeStateMgrServer;

public:
	virtual CBaseStateCfgServer*	GetCfg();
	CDamageChangeStateCfgServerSharedPtr& GetCfgSharedPtr()const;
	virtual CFighterDictator*	GetOwner();								//��ȡӵ����
	virtual CAllStateMgrServer*	GetAllMgr();

	void						AddValue(const uint32& uAccumulate) {m_uAccumulate += uAccumulate;}
	const uint32				GetValue() {return m_uAccumulate;}
	~CDamageChangeStateServer();

private:
	CDamageChangeStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
		TTriggerableStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>* pMgr, 
		const CDamageChangeStateCfgServerSharedPtr& pCfg, uint32 uAccumulate = 0, int32 iTime = 0, int32 iRemainTime = 0, float fProbability = 0.0f);

	virtual bool				DoCancelableMagicEff(bool bFromDB);		//ִ�пɳ���ħ��Ч��
	virtual bool				DoFinalMagicEff();			//ִ������ħ��Ч��
	virtual void				CancelCancelableMagicEff();	//�����ɳ���ħ��Ч��
	virtual void				DeleteSelf();				//ɾ���Լ��͹��������Լ���ָ��
	virtual void				DeleteSelfExceptItr();		//ɾ���Լ�����ɾ�����������Լ���ָ��
	void						PrepareDeleteSelf();		//ɾ���Լ�ǰ�����й���
	void						DeleteItr();				//ɾ�����������Լ���ָ��
	virtual pair<bool, bool>	MessageEvent(uint32 uEventID, CGenericTarget * pTrigger);	//��֪ͨ�¼�����

	CDamageChangeStateMgrServer*		m_pMgr;				//������ħ��״̬�����࣬�������������
	TStateBundleByEvent<CDamageChangeStateServer>*				m_pStateEventBundle;//���ڵ��¼�������EventBandleָ��
	MapDamageChangeState::iterator		m_mapStateItr;		//�Լ���״̬����DamageChangeState�б��λ��
	ListPDamageChangeState::iterator	m_listStateItr;		//�Լ����¼�������EventBandleӳ���е�λ��
	CDamageChangeStateCfgServerSharedPtr*	m_pCfg;			//ħ��״̬���ñ����ָ��
};

