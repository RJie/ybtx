#pragma once
#include "CMagicCfgServer.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

class CEffDataByGlobalIDMgr;
class CCharacterDictator;

DefineCfgSharedPtr(CAureMagicCfgServer)

class CAureMagicCfgServer
	:public CMagicCfgServer
{
public:
	static		bool LoadAureMagicConfig(const string& szFileName);
	static		void UnloadAureMagicConfig();
	static		CAureMagicCfgServerSharedPtr& GetAureMagic(const string& szName);
	static		void UpdateCfg(const string& strName);

	CAureMagicCfgServer();
	CAureMagicCfgServer(const CAureMagicCfgServer& cfg);
	~CAureMagicCfgServer();

	EStanceType	GetStanceType()	{ return m_eStanceType; }
	EAgileType	GetAgileType()	{ return m_eAgileType; }
	bool		GetNeedSaveToDB()	{ return m_bNeedSaveToDB; }
	bool		GetPersistent() { return m_eStanceType <= eSS_MutexStance; }		//�ж��Ƿ����������
	virtual const CMagicEffServerSharedPtr& GetMagicEff()const;

	static CAureMagicCfgServerSharedPtr ms_NULL;

private:
	typedef map<string, CAureMagicCfgServerSharedPtr*, less<string>, 
		TConfigAllocator<pair<string, CAureMagicCfgServerSharedPtr* > > >	MapAureMagicCfgServer;
	typedef map<string, EStanceType, less<string>, 
		TConfigAllocator<pair<string, EStanceType > > > MapStanceType;
	typedef map<string, EAgileType, less<string>, 
		TConfigAllocator<pair<string, EAgileType > > > MapAgileType;
	typedef TStringRefer<CAureMagicCfgServer, CMagicEffServer> MagicEffServerStringRefer;

	static MapAureMagicCfgServer				ms_mapAureMagicServer;
	static MapStanceType						ms_mapStanceType;
	static MapAgileType							ms_mapAgileType;
	inline static bool					InitMapStanceType()
	{
		ms_mapStanceType["��̬"]		= eSS_Stance;
		ms_mapStanceType["������̬"]	= eSS_MutexStance;
		ms_mapStanceType["�⻷"]		= eSS_Aure;
		ms_mapStanceType["����"]		= eSS_Form;
		ms_mapStanceType["����"]		= eSS_Shield;
		ms_mapStanceType["���ӹ⻷"]	= eSS_CascadeAure;
		ms_mapStanceType["���ι⻷"]	= eSS_InvisibleAure;
		return true;
	}
	inline static bool					InitMapAgileType()
	{
		ms_mapAgileType["ħ��ֵ"]		= eAT_MP;
		ms_mapAgileType["����ֵ"]		= eAT_EP;
		ms_mapAgileType["ŭ��ֵ"]		= eAT_RP;
		return true;
	}

	bool						m_bNeedSaveToDB;	////�����Ƿ���Ҫ���浽���ݿ�
	EStanceType					m_eStanceType;		//��̬����
	EAgileType					m_eAgileType;		//�ױ�ֵ����
	MagicEffServerStringRefer*	m_pMagicEff;

};

