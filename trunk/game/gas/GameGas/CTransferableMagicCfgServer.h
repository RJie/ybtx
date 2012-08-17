#pragma once
#include "CMagicCfgServer.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

class CCfgCalc;

// ���ݷ�ʽ����
enum ETransMagicType
{
	eTMT_OneOff,			// һ����
	eTMT_Iteration,			// ����
};

DefineCfgSharedPtr(CTransferableMagicCfgServer)

class CTransferableMagicCfgServer
	:public CMagicCfgServer
{
public:
	CTransferableMagicCfgServer();
	CTransferableMagicCfgServer(const CTransferableMagicCfgServer& cfg);
	virtual ~CTransferableMagicCfgServer();

	static bool LoadTransferableMagicConfig(const string& szFileName);
	static void UnloadTransferableMagicConfig();
	static CTransferableMagicCfgServerSharedPtr& GetTransferableMagic(const string& szName);
	static		void UpdateCfg(const string& strName);

	ETransMagicType			GetTransType()					{return m_eTransType;}
	const CMagicEffServerSharedPtr&		GetMainMagicEff()const;
	const CMagicEffServerSharedPtr&		GetSecondMagicEff()const;

	static CTransferableMagicCfgServerSharedPtr ms_NULL;

private:
	typedef map<string, CTransferableMagicCfgServerSharedPtr*, less<string>, 
		TConfigAllocator<pair<string, CTransferableMagicCfgServerSharedPtr* > > >	MapTransferableMagicCfgServer;
	typedef map<string, ETransMagicType, less<string>, TConfigAllocator<pair<string, ETransMagicType > > > MapTransType;
	typedef TStringRefer<CTransferableMagicCfgServer, CMagicEffServer> MagicEffServerStringRefer;

	inline static bool								InitMapTransType()
	{
		ms_mapTransType["һ����"]	= eTMT_OneOff;
		ms_mapTransType["����"]		= eTMT_Iteration;
		return true;
	}

	static MapTransferableMagicCfgServer	ms_mapTransferableMagic;	// �ɴ���ħ��MAP
	static MapTransType						ms_mapTransType;			// ���ݷ�ʽMAP

	ETransMagicType			m_eTransType;				// ���ݷ�ʽ
	MagicEffServerStringRefer*		m_pMainMagicEff;			// ��ħ��Ч��
	MagicEffServerStringRefer*		m_pSecondMagicEff;			// ��ħ��Ч��	
};

