#pragma once
#include "CBaseStateServer.h"
#include "CTriggerableStateCfg.h"
#include "PatternCOR.h"

class CGenericTarget;
class CAllStateMgrServer;
class CTriggerStateCfgServer;
class CTriggerStateServer;
class CDamageChangeStateCfgServer;
class CDamageChangeStateServer;
class CCumuliTriggerStateCfgServer;
class CCumuliTriggerStateServer;
template<typename CfgType, typename StateType>
class TOtherStateMgrServer;
template<typename CfgType, typename StateType>
class TTriggerableStateMgrServer;
class CMagicEffDataMgrServer;

class CTriggerableStateServer
	: public CBaseStateServer
	, public CPtCORHandler
{
	friend class CTriggerStateMgrServer;
	friend class TOtherStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>;
	friend class TOtherStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;
	friend class TOtherStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>;
	friend class TTriggerableStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>;
	friend class TTriggerableStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;
	friend class TTriggerableStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>;
	friend class CAllStateMgrServer;

public:
	void							OnTick();								//��ʱ����Ϣ��Ӧ����
	virtual CFighterDictator*		GetOwner() = 0;							//��ȡӵ����
	virtual CAllStateMgrServer*		GetAllMgr() = 0;
	virtual CBaseStateCfgServer*	GetCfg() {return NULL;}				//��ȡ���ñ����
	const uint32				GetValue() {return m_uAccumulate;}

protected:
	CTriggerableStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
		uint32 uAccumulate, int32 iTime = 0, int32 iRemainTime = 0, float fProbability = 0.0f);
	virtual ~CTriggerableStateServer();

	//void					Start(bool bFromDB = false);			//һ����map��ִ���������
	void					StartDo(bool bFromDB = false);			//����ÿ��ħ��״̬����һ��ʼ��ִ��Ч��
	void					CancelDo();								//����ʱִ�е�Ч��
	void					StartTime(bool bFromDB = false);		//��ʼ��ʱ����ʱ
	void					RefreshTime();							//ˢ��ʱ��
	virtual void			OnCOREvent(CPtCORSubject* pSubject,uint32 uEvent,void* pArg);
	void					SetInstaller(CFighterDictator* pInstaller);	//����ʩ����
	virtual void			ChangeInstaller(CFighterDictator* pInstaller);//�ı�ʩ����
	void					ClearInstaller();							//���ʩ����
	pair<bool, bool>		MessageEvent(uint32 uEventID, CFighterDictator * pTrigger);	//��֪ͨ�¼�����

	virtual bool			Replace(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller);			//�滻����
	virtual void			DeleteSelf() = 0;						//ɾ���Լ��͹��������Լ���ָ��
	virtual void			DeleteSelfExceptItr() = 0;				//ɾ���Լ�����ɾ�����������Լ���ָ��
	virtual bool			DoCancelableMagicEff(bool bFromDB) {return false;}				//ִ�пɳ���ħ��Ч��
	virtual bool			DoFinalMagicEff() { return false; }					//ִ������ħ��Ч��
	virtual void			CancelCancelableMagicEff() {}			//�����ɳ���ħ��Ч��
	virtual pair<bool, bool>	MessageEvent(uint32 uEventID, CGenericTarget * pTrigger) = 0;	//��֪ͨ�¼�����
	void					CreateInst(CSkillInstServer* pSkillInst);
	void					DeleteInst();
	//uint32					GetDynamicId();
	void					SetAccumulate(uint32 uValue);

	uint32					m_uGrade;			//ħ��״̬��Ӧ���ܵĵȼ�

	uint32					m_uAccumulate;		//���ô������˺���ֵ�ۼ�ֵ
	int32					m_iInitialValue;	//���ô������˺���ֵ��ʼֵ
	float					m_fProbability;		//���ü���
	bool					m_bEndByCount;		//��ʾ�ɴ����ﵽ���޶�����
	bool					m_bEndByTime;		//��ʾ��ʱ��ﵽ���޶�����
	bool					m_bCancellationDone;		//��ʾ������ִ��
	bool					m_bTriggering;				//ͬ��������
	CMagicEffDataMgrServer* m_pCancelEffData;
	//CMagicStateCascadeDataMgr*	m_pCancelableInst;		//���ڴ洢�ɳ���ħ��Ч���м�����MagicStateInst

};

