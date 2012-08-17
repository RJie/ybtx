#pragma once
#include "FightDef.h"
#include "CTriggerableState.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

DefineCfgSharedPtr(CCumuliTriggerStateCfgServer);

//�˺����ħ��״̬������
class CCumuliTriggerStateCfgServer
	: public CTriggerableStateCfgServer
{
	friend class CBaseStateCfgServer;
	friend class CCumuliTriggerStateServer;
	friend class CCumuliTriggerStateMgrServer; 
	friend class TOtherStateMgrServer<CCumuliTriggerStateCfgServer, CCumuliTriggerStateServer>;

	typedef map<string, CCumuliTriggerStateCfgServerSharedPtr*, less<string>, TConfigAllocator<pair<string, CCumuliTriggerStateCfgServerSharedPtr*> > >	MapCumuliTriggerStateCfg;
	typedef map<uint32, CCumuliTriggerStateCfgServerSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CCumuliTriggerStateCfgServerSharedPtr*> > >	MapCumuliTriggerStateCfgById;
	typedef TStringRefer<CCumuliTriggerStateCfgServer, CMagicEffServer>	MagicEffServerStringRefer;

public:
	typedef CCumuliTriggerStateCfgServerSharedPtr SharedPtrType;

	CCumuliTriggerStateCfgServer();
	CCumuliTriggerStateCfgServer(const CCumuliTriggerStateCfgServer& cfg);
	virtual ~CCumuliTriggerStateCfgServer();
	static bool									LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void									UnloadConfig();
	static CCumuliTriggerStateCfgServerSharedPtr& Get(const string& damageChangeStateName);	//��ȡ�˺��ı�ħ��״̬������
	static EStateGlobalType						GetStaticType()				{return eSGT_CumuliTriggerState;}
	static void UpdateCfg(const string& strName);

	const string&								GetTempVar() {return m_sTempVar;}			//��ȡ��ı����ʱ����
	const CMagicEffServerSharedPtr&				GetTriggerEff()const;
	ETargetChange								GetChangedTarget()			{return m_eTargetChange;}
	const CCfgCalc*								GetMaxNumInSingleEvent()	{return m_calcMaxNumInSingleEvent;}

	static CCumuliTriggerStateCfgServerSharedPtr ms_NULL;
private:
	static MapCumuliTriggerStateCfg				m_mapCfg;							//ħ��״̬����ӳ���
	static MapCumuliTriggerStateCfgById			m_mapCfgById;						//�ñ�Ų��ҵ�ħ��״̬����ӳ���

	string										m_sTempVar;							//��Ҫ�ı����ʱ����
	MagicEffServerStringRefer*					m_pTriggerEff;						//���ɳ���������ħ��Ч��
	ETargetChange								m_eTargetChange;					//�Ƿ����Ŀ��Ϊ������
	CCfgCalc*									m_calcMaxNumInSingleEvent;			//���δ���������

};

