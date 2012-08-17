#pragma once
#include "CBaseStateCfgServer.h"

enum ETargetChange { eTC_Trigger, eTC_Installer, eTC_TargetOfTrigger, eTC_Self, eTC_TargetOfSelf, eTC_SelfCorpse, eTc_End };

class CTriggerableStateServer;
class CCfgCalc;
class CMagicEffServerSharedPtr;

class CTriggerableStateCfgServer
	: public CBaseStateCfgServer
	//��ʱ����Ҫ���������
{
	friend class CTriggerableStateServer;
	typedef map<string, ETargetChange, less<string>, 
		TConfigAllocator<pair<string, ETargetChange > > > MapTargetChange;

public:
	CTriggerableStateCfgServer(EStateGlobalType type);
	CTriggerableStateCfgServer(const CTriggerableStateCfgServer& cfg);
	virtual ~CTriggerableStateCfgServer();

	const CCfgCalc*			GetInitialValue()			{return m_calcInitialValue;}
	const CCfgCalc*			GetProbability()			{return m_calcProbability;}
	const uint32			GetTriggerEvent()			{return m_uTriggerEvent;}
	//virtual const CMagicEffServerSharedPtr& GetCancelableMagicEff()const=0;
protected:
	static MapTargetChange	m_mapTargetChange;

	CCfgCalc*				m_calcInitialValue;			//���ô�����ʼֵ���ʽ
	CCfgCalc*				m_calcProbability;			//���ü��ʱ��ʽ
	uint32					m_uTriggerEvent;			//�����¼�


};


