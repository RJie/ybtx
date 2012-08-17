#pragma once
#include "FightDef.h"
#include "CStaticObject.h"
#include "TCfgSharedPtr.h"
#include "TConfigAllocator.h"
#include "CConfigMallocObject.h"

DefineCfgSharedPtr(CAureMagicCfgClient)

class CAureMagicCfgClient
	: public virtual CStaticObject
	, public CConfigMallocObject
{
public:
	static	bool						LoadAureMagicConfig(const string& szFileName);
	static	void						UnloadAureMagicConfig();
	static	CAureMagicCfgClientSharedPtr&		GetAureMagicByID(uint32 uId);
	static	CAureMagicCfgClientSharedPtr&		GetAureMagicByName(const string& szName);
	uint32								GetAureMagicID()		{return m_uID;}
	const string&						GetAureMagicName()	{return m_strName;};	
	EStanceType							GetAureMagicType()	{return m_eType;};

	static CAureMagicCfgClientSharedPtr ms_NULL;
private:
	typedef map<uint32, CAureMagicCfgClientSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CAureMagicCfgClientSharedPtr*> > >		MapAureMagicCfgClientByID;
	static MapAureMagicCfgClientByID				ms_mapAureMagicClientByID;
	typedef map<string, CAureMagicCfgClientSharedPtr*, less<string>, TConfigAllocator<pair<string, CAureMagicCfgClientSharedPtr*> > >		MapAureMagicCfgClientByName;
	static MapAureMagicCfgClientByName				ms_mapAureMagicClientByName;
	typedef map<string, EStanceType, less<string>, TConfigAllocator<pair<string, EStanceType> > >				MapStanceType;
	static MapStanceType							ms_mapStanceType;

	inline static bool								InitMapStanceType()		
	{		
		ms_mapStanceType["��̬"]		= eSS_Stance;
		ms_mapStanceType["�⻷"]		= eSS_Aure;
		ms_mapStanceType["����"]		= eSS_Form;
		return true;
	}

	uint32			m_uID;			//���
	string			m_strName;		//��̬����
	EStanceType		m_eType;		//��̬����
};
