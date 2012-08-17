#pragma once
#include "CBaseStateServer.h"
#include "TMagicStateAllocator.h"

class CSpecialStateBase;
class CSpecialStateCfgServer;
class CSpecialStateCfgServerSharedPtr;

typedef list<CSpecialStateBase*, TMagicStateAllocator<CSpecialStateBase*> >
	ListPSpecialState;
typedef map<CSpecialStateCfgServer*, CSpecialStateBase*, less<CSpecialStateCfgServer*>,
	TMagicStateAllocator<pair<CSpecialStateCfgServer*, CSpecialStateBase*> > >	MapSpecialState;

class CSpecialStateMgrServer;
class CFighterDictator;
class CSkillInstServer;
class CSpecialStateTypeBundle;
class CAllStateMgrServer;

template<typename CfgType, typename StateType>
class TOtherStateMgrServer;
template<typename StateType>
class TStateBundleByEvent;

class CSpecialStateBase
	: public CBaseStateServer
{
	friend class TOtherStateMgrServer<CSpecialStateCfgServer, CSpecialStateBase>;
	friend class CSpecialStateMgrServer;
	friend class CAllStateMgrServer;

public:
	void							OnTick();				//��ʱ����Ϣ��Ӧ����
	virtual CFighterDictator*		GetOwner();				//��ȡӵ����
	virtual CBaseStateCfgServer*	GetCfg();
	CSpecialStateCfgServerSharedPtr& GetCfgSharedPtr()const;

	CAllStateMgrServer*				GetAllMgr();

	CSpecialStateBase(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller, CSpecialStateMgrServer* pMgr, 
		const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime = 0, int32 iRemainTime = 0);
	virtual ~CSpecialStateBase();

protected:
	void						Start(bool bFromDB = false);	//һ����map��ִ���������
	void						StartDo();					//����ÿ��ħ��״̬����һ��ʼ��ִ��Ч��
	void						StartTime(bool bFromDB = false);//��ʼ��ʱ����ʱ
	void						CancelDo() {}
	virtual void				DeleteSelf();				//ɾ���Լ��͹��������Լ���ָ��
	virtual void				DeleteSelfExceptItr();		//ɾ���Լ�����ɾ�����������Լ���ָ��
	void						PrepareDeleteSelf();		//ɾ���Լ�ǰ�����й���
	void						DeleteItr();				//ɾ�����������Լ���ָ��
	virtual pair<bool, bool>	MessageEvent(uint32 uEventID, CGenericTarget * pTrigger) {return make_pair(false,false);}	//��֪ͨ�¼�����
	virtual void				RegisterEvent();
	//uint32						GetDynamicId();

	MapSpecialState::iterator	m_mapSSItr;			//�Լ���״̬����SpecialState�б��λ��
	CSpecialStateMgrServer*		m_pMgr;				//����������ħ��״̬�����࣬�������������
	CSpecialStateCfgServerSharedPtr*		m_pCfg;				//����ħ��״̬���ñ����ָ��
	CSpecialStateTypeBundle*	m_pStateBundleByType;						//���ڵ�������SpecialStateTypeBundleָ��
	ListPSpecialState::iterator	m_listSSItr;		//�Լ���״̬������TypeBandleӳ���е�λ��
	TStateBundleByEvent<CSpecialStateBase>*			m_pStateEventBundle;	//���ڵ��¼�������EventBandleָ��
	ListPSpecialState::iterator				m_listStateItr;			//�Լ����¼�������EventBandleӳ���е�λ��
};





//����ħ��״̬
class CReflectStateServer
	: CSpecialStateBase
{
	CReflectStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller, CSpecialStateMgrServer* pMgr, 
		const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime, int32 iRemainTime = 0);
	virtual ~CReflectStateServer()					{};
	friend class CSpecialStateMgrServer;
private:
};

//�ط�ħ��״̬
class CRepeatStateServer
	: CSpecialStateBase
{
	CRepeatStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller, CSpecialStateMgrServer* pMgr, 
		const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime, int32 iRemainTime = 0);
	virtual ~CRepeatStateServer()					{};
	friend class CSpecialStateMgrServer;
private:
};


//��ʬ״̬
class CDeadBodyStateServer
	: CSpecialStateBase
{
	CDeadBodyStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller, CSpecialStateMgrServer* pMgr, 
		const CSpecialStateCfgServerSharedPtr& pCfg, int32 iTime, int32 iRemainTime = 0);
	virtual ~CDeadBodyStateServer()					{};
	friend class CSpecialStateMgrServer;
private:
};

