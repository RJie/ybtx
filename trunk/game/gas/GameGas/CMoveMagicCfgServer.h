#pragma once
#include "CMagicCfgServer.h"
#include "FindPathDefs.h"
#include "CMoveMagicDefs.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

class CCfgCalc;

DefineCfgSharedPtr(CMoveMagicCfgServer)

class CMoveMagicCfgServer : public CMagicCfgServer
{
public:
	static bool LoadMoveMagicConfig(const string& szFileName);
	static void UnloadMoveMagicConfig();
	static CMoveMagicCfgServerSharedPtr& GetMoveMagic(const string& szName);
	static void UpdateCfg(const string& strName);

	CMoveMagicCfgServer();
	CMoveMagicCfgServer(const CMoveMagicCfgServer& cfg);
	virtual ~CMoveMagicCfgServer();

	EMoveMagicType		GetMoveType()			{return m_eMoveType;}
	EBarrierType		GetBarrierType()		{return m_eBarrierType;}
	EOperateObjectType	GetAreaOperateObject()	{return m_eAreaOperateObject;}
	EMoveMagicArg 		GetMoveArgType()		{return m_eMoveArgType;}
	EMoveMagicArgLimit 	GetMoveArgTypeLimit()		{return m_eMoveArgLimit;}
	CCfgCalc* 			GetMoveArgValue()			{return m_pMoveArgValue;}
	EMoveActionType		GetActionType()				{return m_eActionType;}
	const CMagicEffServerSharedPtr& GetCancelableMagicEff()const;
	virtual const CMagicEffServerSharedPtr& GetMagicEff()const;

	static CMoveMagicCfgServerSharedPtr ms_NULL;

private:
	typedef map<string, CMoveMagicCfgServerSharedPtr* ,less<string>, 
		TConfigAllocator<pair<string, CMoveMagicCfgServerSharedPtr* > > >		MapMoveMagicCfgServer;
	typedef TStringRefer<CMoveMagicCfgServer, CMagicEffServer> MagicEffServerStringRefer;

	static MapMoveMagicCfgServer		ms_mapMoveMagic;
	EMoveMagicType		m_eMoveType;			//�ƶ���ʽ
	EMoveMagicArg		m_eMoveArgType;			//�ƶ�����
	EMoveMagicArgLimit	m_eMoveArgLimit;		//�ƶ���������
	CCfgCalc*			m_pMoveArgValue;		//�ƶ�����ֵ
	EOperateObjectType	m_eAreaOperateObject;	//���ö���
	EBarrierType		m_eBarrierType;			//�ϰ�����
	EMoveActionType		m_eActionType;			//����
	MagicEffServerStringRefer*		m_pMagicEff;
	MagicEffServerStringRefer*		m_pCancelableMagicEff;		//�ɳ���ħ��Ч��
};

