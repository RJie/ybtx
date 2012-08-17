#pragma once
#include "FightDef.h"
#include "CBaseStateCfgServer.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"

class CCfgCalc;

DefineCfgSharedPtr(CMagicStateCfgServer)

//ħ��״̬������
class CMagicStateCfgServer	
	: public CBaseStateCfgServer
{
	friend class CBaseStateCfgServer;
	friend class CMagicStateServer;
	typedef map<string, CMagicStateCfgServerSharedPtr*, less<string>, TConfigAllocator<pair<string, CMagicStateCfgServerSharedPtr*> > >	MapMagicStateCfg;
	typedef map<uint32, CMagicStateCfgServerSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CMagicStateCfgServerSharedPtr*> > >	MapMagicStateCfgById;
	typedef map<string, ECascadeType, less<string>, TConfigAllocator<pair<string, ECascadeType > > > MapCascadeType;
	typedef map<string, EReplaceRuler, less<string>, TConfigAllocator<pair<string, EReplaceRuler > > > MapReplaceRuler;
	typedef TStringRefer<CMagicStateCfgServer, CMagicEffServer>	MagicEffServerStringRefer;

public:
	CMagicStateCfgServer();
	CMagicStateCfgServer(const CMagicStateCfgServer& cfg);
	virtual ~CMagicStateCfgServer();

	static bool									LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void									UnloadConfig();
	static CMagicStateCfgServerSharedPtr&		Get(const string& magicStateName);	//��ȡħ��״̬������
	static CMagicStateCfgServerSharedPtr&		GetById(uint32);					//�ñ�Ż�ȡħ��״̬������
	static EStateGlobalType						GetStaticType()				{return eSGT_MagicState;}
	static void UpdateCfg(const string& strName);
	static CMagicStateCfgServerSharedPtr ms_NULL;

private:
	static bool									InitMapCascadeType();				//����Ⱥ����������ַ�������Ӧö�����͵�ӳ��
	static MapMagicStateCfg						m_mapCfg;							//ħ��״̬����ӳ���
	static MapMagicStateCfgById					m_mapCfgById;						//ħ��״̬����ӳ���
	static MapCascadeType						m_mapCascadeType;					//Ⱥ���������ӳ���
	static MapReplaceRuler						m_mapReplaceRuler;

public:
	const EReplaceRuler&	GetReplaceType()			{return m_eReplaceType;}
	const ECascadeType&		GetCascadeType()			{return m_eCascadeType;}
	const bool				GetCascadeGradation()		{return m_bCascadeGradation;}
	const CCfgCalc*			GetCascadeMax()				{return m_calcCascadeMax;}
	const CMagicEffServerSharedPtr&		GetCancelableMagicEff()const;
	const CMagicEffServerSharedPtr&		GetDotMagicEff()const;
	const CMagicEffServerSharedPtr&		GetFinalMagicEff()const;
	//const CCfgCalc*			GetFMAssociateDotM()		{return m_pFMAssociateDotM;}
	float					GetDotInterval()			{return m_fDotInterval;}//���ɳ������ħ��Ч���ļ��ʱ��
	bool					InstallerOughtToBeNull();

private:

	EReplaceRuler				m_eReplaceType;				//ħ��״̬�滻����
	ECascadeType				m_eCascadeType;				//Ⱥ���������
	bool						m_bCascadeGradation;		//�滻�͵����Ƿ����Ƶȼ�
	CCfgCalc*					m_calcCascadeMax;			//��������
	MagicEffServerStringRefer*	m_pCancelableMagicEff;		//�ɳ���ħ��Ч��
	MagicEffServerStringRefer*	m_pDotMagicEff;				//���ɳ������ħ��Ч��
	MagicEffServerStringRefer*	m_pFinalMagicEff;			//���ɳ�������ħ��Ч��
	float						m_fDotInterval;				//���ɳ������ħ��Ч���ļ��ʱ��

};

