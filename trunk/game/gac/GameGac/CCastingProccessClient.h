#pragma once
#include "CStaticObject.h"
#include "FightDef.h"
#include "TCfgSharedPtr.h"
#include "TConfigAllocator.h"
#include "CConfigMallocObject.h"

DefineCfgSharedPtr(CCastingProcessCfgClient)


class CCfgCalc;

class CCastingProcessCfgClient
	: public virtual CStaticObject
	, public CConfigMallocObject
{
public:
	typedef map<uint32, CCastingProcessCfgClientSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CCastingProcessCfgClientSharedPtr*> > >	MapCastingProcessCfgById;
	typedef map<string, CCastingProcessCfgClientSharedPtr*, less<string>, TConfigAllocator<pair<string, CCastingProcessCfgClientSharedPtr*> > >	MapCastingProcessCfgByName;

	~CCastingProcessCfgClient();

	static bool							LoadConfig(const TCHAR* cfgFile);	// �����ñ�
	static void							UnloadConfig();	
	static CCastingProcessCfgClientSharedPtr&	GetById(uint32 uId);				// ��ȡʩ������������
	static CCastingProcessCfgClientSharedPtr&	GetByName(const string &castingProcessName);

	uint32								GetId()						{return m_uId;}
	ECastingProcessType					GetCastingType()			{return m_eCastingType;}
	CCfgCalc*							GetCastingTime()			{return m_pCastingTime;}
	const TCHAR*						GetProcessEffect()			{return m_sProcessEffect.c_str();}
	const TCHAR*						GetProcessAction()			{return m_sProcessAction.c_str();}
	bool								GetMoveInterrupt()			{return m_eCastingInterruptType == eCIT_Move || m_eCastingInterruptType == eCIT_TurnAround;}
	bool								IsLinkEffect()				{return m_bLinkEffect;}
	const TCHAR*						GetName()					{return m_sName.c_str();}

	static CCastingProcessCfgClientSharedPtr ms_NULL;
private:
	static MapCastingProcessCfgById					m_mapCfgById;
	static MapCastingProcessCfgByName				m_mapCfgByName;
	uint32			m_uId;							// ���
	string			m_sName;						// ����
	string			m_sProcessAction;				// ʩ������
	string			m_sProcessEffect;				// ʩ����Ч
	ECastingProcessType		m_eCastingType;			// ʩ������
	CCfgCalc*		m_pCastingTime;					// ʩ��ʱ��
	ECastingInterruptType			m_eCastingInterruptType;		// �������
	bool			m_bLinkEffect;	
};
