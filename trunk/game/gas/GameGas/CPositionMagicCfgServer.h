#pragma once
#include "CMagicCfgServer.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

DefineCfgSharedPtr(CPositionMagicCfgServer)

class CPositionMagicCfgServer
	:public CMagicCfgServer
{
public:
	static		bool LoadPositionMagicConfig(const string& szFileName);
	static		void UnloadPositionMagicConfig();
	static		CPositionMagicCfgServerSharedPtr& GetPositionMagic(const string& szName);
	static		void UpdateCfg(const string& strName);

	CPositionMagicCfgServer();
	CPositionMagicCfgServer(const CPositionMagicCfgServer& cfg);
	virtual ~CPositionMagicCfgServer();

	bool				GetMutexType()				{return m_bMutexType;}
	bool				GetSingleObject()			{return m_bSingleObject;}
	const CMagicEffServerSharedPtr&	GetTouchMagicEff()const;
	const CMagicEffServerSharedPtr&	GetDotMagicEff()const;
	int32				GetDotInterval()			{return m_iDotInterval;}
	const CMagicEffServerSharedPtr&	GetFinalMagicEff()const;

	static CPositionMagicCfgServerSharedPtr ms_NULL;

private:
	typedef map<string, CPositionMagicCfgServerSharedPtr*, less<string>, 
		TConfigAllocator<pair<string, CPositionMagicCfgServerSharedPtr* > > >	MapPositionMagicCfgServer;
	typedef TStringRefer<CPositionMagicCfgServer, CMagicEffServer> MagicEffServerStringRefer;

	static MapPositionMagicCfgServer				ms_mapPositionMagic;

	bool			m_bMutexType;			// ��������
	bool			m_bSingleObject;				// ����Ŀ��
	MagicEffServerStringRefer*	m_pTouchMagicEff;		// ����ħ��Ч��
	MagicEffServerStringRefer*	m_pDotMagicEff;			// ���ɳ������ħ��Ч��
	int32						m_iDotInterval;
	MagicEffServerStringRefer*	m_pFinalMagicEff;		// ���ɳ�������ħ��Ч��"
};

