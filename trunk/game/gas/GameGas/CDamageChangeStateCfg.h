#pragma once
#include "FightDef.h"
#include "CTriggerableState.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

DefineCfgSharedPtr(CDamageChangeStateCfgServer);

//�˺����ħ��״̬������
class CDamageChangeStateCfgServer
	: public CTriggerableStateCfgServer
{
	friend class CBaseStateCfgServer;
	friend class CDamageChangeStateServer;
	friend class CDamageChangeStateMgrServer; 
	friend class TOtherStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;

	typedef map<string, CDamageChangeStateCfgServerSharedPtr*, less<string>, TConfigAllocator<pair<string, CDamageChangeStateCfgServerSharedPtr*> > >	MapDamageChangeStateCfg;
	typedef map<uint32, CDamageChangeStateCfgServerSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CDamageChangeStateCfgServerSharedPtr*> > >	MapDamageChangeStateCfgById;
	typedef TStringRefer<CDamageChangeStateCfgServer, CMagicEffServer>	MagicEffServerStringRefer;

public:
	typedef CDamageChangeStateCfgServerSharedPtr SharedPtrType;

	CDamageChangeStateCfgServer();
	CDamageChangeStateCfgServer(const CDamageChangeStateCfgServer& cfg);
	virtual ~CDamageChangeStateCfgServer();
	static bool									LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void									UnloadConfig();
	static CDamageChangeStateCfgServerSharedPtr& Get(const string& damageChangeStateName);	//��ȡ�˺��ı�ħ��״̬������
	static EStateGlobalType						GetStaticType()				{return eSGT_DamageChangeState;}
	static void UpdateCfg(const string& strName);

	const string&								GetTempVar() {return m_sTempVar;}			//��ȡ��ı����ʱ����
	const CCfgCalc*								GetTempValue() {return m_calcTempValue;}	//��ȡҪ�ñ��ֵ�ı��ʽ
	const CMagicEffServerSharedPtr&				GetFinalMagicEff()const;							//��ȡ���ɳ�������ħ��Ч
	const CMagicEffServerSharedPtr&				GetCancelableMagicEff()const;

	static CDamageChangeStateCfgServerSharedPtr ms_NULL;
private:
	static MapDamageChangeStateCfg				m_mapCfg;							//ħ��״̬����ӳ���
	static MapDamageChangeStateCfgById			m_mapCfgById;						//�ñ�Ų��ҵ�ħ��״̬����ӳ���

	string										m_sTempVar;							//��Ҫ�ı����ʱ����
	CCfgCalc*									m_calcTempValue;					//�ı�ɱ��ʽ��ֵ
	bool										m_bApplyTempValue;					//�Ƿ������ʱ������ֵ
	MagicEffServerStringRefer*					m_pFinalMagicEff;			//���ɳ�������ħ��Ч��
	MagicEffServerStringRefer*					m_pCancelableMagicEff;		//�ɳ���ħ��Ч��

};

