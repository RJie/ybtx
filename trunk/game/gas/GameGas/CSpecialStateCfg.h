#pragma once
#include "CBaseStateCfgServer.h"
#include "TCfgSharedPtr.h"

class CCfgCalc;

class CSpecialStateBase;
template<typename CfgType, typename StateType>
class TOtherStateMgrServer;

DefineCfgSharedPtr(CSpecialStateCfgServer)

class CSpecialStateCfgServer
	: public CBaseStateCfgServer
{
	friend class CBaseStateCfgServer;
	friend class CSpecialStateBase;
	friend class CSpecialStateMgrServer;
	friend class TOtherStateMgrServer<CSpecialStateCfgServer, CSpecialStateBase>;
	typedef map<string, CSpecialStateCfgServerSharedPtr*, less<string>, TConfigAllocator<pair<string, CSpecialStateCfgServerSharedPtr*> > >	MapSpecialStateCfg;
	typedef map<uint32, CSpecialStateCfgServerSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CSpecialStateCfgServerSharedPtr*> > >	MapSpecialStateCfgById;
	typedef map<string, ESpecialStateType, less<string>, TConfigAllocator<pair<string, ESpecialStateType > > > MapSpecialStateType;

public:
	typedef CSpecialStateCfgServerSharedPtr SharedPtrType;

	CSpecialStateCfgServer();
	CSpecialStateCfgServer(const CSpecialStateCfgServer& cfg);
	~CSpecialStateCfgServer();
	static bool									LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void									UnloadConfig();
	static CSpecialStateCfgServerSharedPtr&		Get(const string& name);			//��ȡħ��״̬������
	static EStateGlobalType						GetStaticType()				{return eSGT_SpecialState;}

	static CSpecialStateCfgServerSharedPtr ms_NULL;

private:
	static bool									InitMapType();						//��������״̬�����ַ�������Ӧö�����͵�ӳ��
	static MapSpecialStateCfg					m_mapCfg;							//����״̬����ӳ���
	static MapSpecialStateCfgById				m_mapCfgById;						//�ñ�Ų��ҵ�ħ��״̬����ӳ���
	static MapSpecialStateType					m_mapSpecailStateType;				//����״̬����ӳ���
	static bool									__init;

public:

	const ESpecialStateType&	GetSSType()					{return m_eSSType;}

private:

	ESpecialStateType	m_eSSType;					//ħ��״̬������
};

