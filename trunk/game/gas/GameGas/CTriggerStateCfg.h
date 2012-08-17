#pragma once
#include "FightDef.h"
#include "CTriggerableState.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"


DefineCfgSharedPtr(CTriggerStateCfgServer)

class CTempVarMgrServer;

//������ħ��״̬������
class CTriggerStateCfgServer
	: public CTriggerableStateCfgServer
{
	friend class CBaseStateCfgServer;
	friend class CTriggerStateServer;
	friend class TOtherStateMgrServer<CTriggerStateCfgServer, CTriggerStateServer>;
	friend class CTriggerStateMgrServer;

	typedef map<string, CTriggerStateCfgServerSharedPtr*, less<string>, TConfigAllocator<pair<string, CTriggerStateCfgServerSharedPtr*> > >	MapTriggerStateCfg;
	typedef map<uint32, CTriggerStateCfgServerSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CTriggerStateCfgServerSharedPtr*> > >	MapTriggerStateCfgById;
	typedef map<string, ECascadeType, less<string>, TConfigAllocator<pair<string, ECascadeType > > > MapCascadeType;
	typedef TStringRefer<CTriggerStateCfgServer, CMagicEffServer>	MagicEffServerStringRefer;

public:
	typedef CTriggerStateCfgServerSharedPtr SharedPtrType;

	CTriggerStateCfgServer();
	CTriggerStateCfgServer(const CTriggerStateCfgServer& cfg);
	virtual ~CTriggerStateCfgServer();
	static bool									LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void									UnloadConfig();
	static CTriggerStateCfgServerSharedPtr&		Get(const string& triggerStateName);	//��ȡ������ħ��״̬������
	static EStateGlobalType						GetStaticType()				{return eSGT_TriggerState;}
	static void UpdateCfg(const string& strName);
	//static bool									InitMapCascadeType();				//����Ⱥ����������ַ�������Ӧö�����͵�ӳ��

	const CMagicEffServerSharedPtr&				GetTriggerEff()const;
	const CMagicEffServerSharedPtr&				GetCancelableMagicEff()const;
	ETargetChange								GetChangedTarget()			{return m_eTargetChange;}

	static CTriggerStateCfgServerSharedPtr ms_NULL;

private:
	static MapTriggerStateCfg					m_mapCfg;							//ħ��״̬����ӳ���
	static MapTriggerStateCfgById				m_mapCfgById;						//�ñ�Ų��ҵ�ħ��״̬����ӳ���
	static MapCascadeType						m_mapCascadeType;					//Ⱥ���������ӳ���

	MagicEffServerStringRefer*					m_pTriggerEff;				//���ɳ���������ħ��Ч��
	MagicEffServerStringRefer*					m_pCancelableMagicEff;		//�ɳ���ħ��Ч��
	ETargetChange								m_eTargetChange;			//�Ƿ����Ŀ��Ϊ������

};



