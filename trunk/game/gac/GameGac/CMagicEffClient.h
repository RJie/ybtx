#pragma once
#include "CFighterAgileInfoClient.h"
#include "CCfgCalc.h"
#include "TCfgSharedPtr.h"
#include "CConfigMallocObject.h"
#include "TConfigAllocator.h"

DefineCfgSharedPtr(CMagicEffClient)


class CMagicCondClient;
class CFighterFollower;

struct MagicOpData
	:public CConfigMallocObject
{
	uint32						m_uId;				// ���
	string						m_strMagicOpName;	// ħ��������
	CCfgCalc*					m_pMagicOpArg;		// ħ����������
	~MagicOpData()
	{
		delete m_pMagicOpArg; 
		m_pMagicOpArg = NULL;
	}
};

class CFighterDirector;

class CMagicEffClient
	:public CConfigMallocObject
{
private:
	typedef map<string, CMagicCondClient*, less<string>, TConfigAllocator<pair<string, CMagicCondClient*> > >		MapMagicCond;
	typedef map<string, CMagicEffClientSharedPtr*, less<string>, TConfigAllocator<pair<string, CMagicEffClientSharedPtr*> > >		MapMagicEffClient;
	typedef map<uint32, CMagicEffClientSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CMagicEffClientSharedPtr*> > >		MapMagicEffClientById;
	typedef vector<MagicOpData*, TConfigAllocator<MagicOpData*> >				VecMagicCondData;

public:
	CMagicEffClient(void);
	~CMagicEffClient(void);

	static bool LoadMagicEff(const string& fileName, bool bFirstFile);
	static void	UnloadMagicEff();

	static CMagicEffClientSharedPtr&	GetMagicEff(const string& name);
	static CMagicEffClientSharedPtr&	GetMagicEffById(uint32 uId);
	static CMagicCondClient* GetMagicCond(const string& name);

	uint32 DoMagicCond(uint32 SkillLevel,const CFighterDirector* pFight);	//ִ��ħ������
	uint32 GetId()								{return m_uId;}
	EConsumeType GetEConsumeType();
	CCfgCalc* GetMagicOpArg(const string& name);

	static CMagicEffClientSharedPtr ms_NULL;

private:
	static MapMagicCond				ms_mapMagicCond;
	static MapMagicEffClient		ms_mapMagicEffClient;
	static MapMagicEffClientById	ms_mapMagicEffClientById;
	static void BuildMCondMap();
	static void ClearMCondMap();
	uint32							m_uId;						// ���
	string							m_strName;					// ħ��Ч����
	VecMagicCondData				m_vecMagicCondData;			// ����ħ������
	static uint32					ms_uMaxLineNum;				// ����к�
};


