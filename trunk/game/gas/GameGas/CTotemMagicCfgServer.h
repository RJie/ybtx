#pragma once
#include "CMagicCfgServer.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

DefineCfgSharedPtr(CTotemMagicCfgServer)

class CTotemMagicCfgServer
	:public CMagicCfgServer
{
public:
	static		bool LoadTotemMagicConfig(const string& szFileName);
	static		void UnloadTotemMagicConfig();
	static		CTotemMagicCfgServerSharedPtr& GetTotemMagic(const string& szName);
	static		void UpdateCfg(const string& strName);

	CTotemMagicCfgServer();
	CTotemMagicCfgServer(const CTotemMagicCfgServer& cfg);
	virtual ~CTotemMagicCfgServer();

	const CMagicEffServerSharedPtr&	GetTouchMagicEff()const;
	const CMagicEffServerSharedPtr&	GetDotMagicEff()const;
	const CMagicEffServerSharedPtr&	GetFinalMagicEff()const;
	EOperateObjectType	GetOperateObject()			{return m_eOperateObject;}

	static CTotemMagicCfgServerSharedPtr ms_NULL;
private:
	typedef map<string, CTotemMagicCfgServerSharedPtr*, less<string>, 
		TConfigAllocator<pair<string, CTotemMagicCfgServerSharedPtr* > > >	MapTotemMagicCfgServer;
	typedef TStringRefer<CTotemMagicCfgServer, CMagicEffServer> MagicEffServerStringRefer;

	static MapTotemMagicCfgServer				ms_mapTotemMagic;

	static bool			__init;

	EOperateObjectType			m_eOperateObject;		// ���ö���
	MagicEffServerStringRefer*	m_pTouchMagicEff;		// ����ħ��Ч��
	MagicEffServerStringRefer*	m_pDotMagicEff;			// ���ɳ������ħ��Ч��
	MagicEffServerStringRefer*	m_pFinalMagicEff;		// ���ɳ�������ħ��Ч��
};
