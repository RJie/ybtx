#pragma once
#include "FightDef.h"
#include "TCastingProcessAllocator.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"
#include "TStringRef.h"

class CCfgCalc;

DefineCfgSharedPtr(CCastingProcessCfgServer)

class CCastingProcessCfgServer
	:public CCastingProcessMallocObject
	,public TStringRefee<CCastingProcessCfgServer, CCastingProcessCfgServerSharedPtr>
{
public:
	static bool							LoadConfig(const TCHAR* cfgFile, bool bReload = false);		//�����ñ�
	static void							UnloadConfig();	
	static CCastingProcessCfgServerSharedPtr&	Get(const string& castingProcessName);	//��ȡʩ������������
	static void UpdateCfg(const string& strName);

	static CCastingProcessCfgServerSharedPtr ms_NULL;

	CCastingProcessCfgServer();
	CCastingProcessCfgServer(const CCastingProcessCfgServer& cfg);
	~CCastingProcessCfgServer();
	uint32								GetId()						{return m_uId;}
	const string&						GetName()					{return m_sName;}
	ECastingProcessType					GetCastingType()			{return m_eCastingType;}
	bool								GetMoveInterrupt();
	bool								GetTurnAroundInterrupt()	{return m_eMoveInterrupt == eCIT_TurnAround;}
	CCfgCalc*							GetCastingTime()			{return m_pCastingTime;}
	CCfgCalc*							GetInterruptPercent()		{return m_pInterruptPercent;}
	const CMagicEffServerSharedPtr&		GetMagicEff(uint32 uIndex = 1)const;
	float								GetChannelInterval()		{return m_fChannelInterval;}
	const CMagicEffServerSharedPtr&		GetSelfCancelableMagicEff()const;
	const CMagicEffServerSharedPtr&		GetObjCancelableMagicEff()const;
	const CMagicEffServerSharedPtr&		GetFinalMagicEff()const;

private:
	typedef TStringRefee<CCastingProcessCfgServer, CCastingProcessCfgServerSharedPtr>	ParentType;
	typedef TStringRefer<CCastingProcessCfgServer, CMagicEffServer>	MagicEffServerStringRefer;
	typedef ParentType::MapImpClass	MapCastingProcessCfg;
	typedef vector<MagicEffServerStringRefer*>		VecMagicEff;

	static MapCastingProcessCfg&					GetStringKeyMap();

	uint32					m_uId;						//���
	string					m_sName;					//����	
	ECastingProcessType		m_eCastingType;				//ʩ������
	ECastingInterruptType	m_eMoveInterrupt;			//�ƶ��Ƿ���
	CCfgCalc*				m_pCastingTime;				//ʩ��ʱ��
	float					m_fChannelInterval;			//�������ʱ��
	CCfgCalc*				m_pInterruptPercent;		//�жϼ���
	MagicEffServerStringRefer*		m_pSelfCancelableMagicEff;		//�ɳ���ħ��Ч������
	MagicEffServerStringRefer*		m_pObjCancelableMagicEff;		//�ɳ���ħ��Ч������
	MagicEffServerStringRefer*		m_pFinalMagicEff;			//���ɳ�������ħ��Ч��
	VecMagicEff				m_vecMagicEff;				//ħ��Ч��
};

