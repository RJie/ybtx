#pragma once
#include "CBaseState.h"
#include "CMagicStateMallocObject.h"
#include "TConfigAllocator.h"

class CCfgCalc;
class CSkillInstServer;
class CForceNoSaveStateCfgServer;

class CBaseStateCfgServer
	: public CBaseStateCfg
{
	friend class CForceNoSaveStateCfgServer;
	friend class CPersistentStateCfgServer;
public:
	CBaseStateCfgServer(EStateGlobalType type);
	CBaseStateCfgServer(const CBaseStateCfgServer& cfg);
	virtual ~CBaseStateCfgServer();

	static bool					ExistDecreaseType(const string& sTypeName)
	{
		return ms_mapDecreaseType.find(sTypeName) != ms_mapDecreaseType.end();
	}
	static EDecreaseStateType	GetDecreaseType(const string& sTypeName)
	{
		if(!ExistDecreaseType(sTypeName)) return eDST_Null;
		return ms_mapDecreaseType.find(sTypeName)->second;
	}

	uint32						GetId()						{return m_uId;}
	const TCHAR*				GetName()					{return m_sName.c_str();}
	const bool&					GetDecrease()				{return m_bDecrease;}
	const bool					GetTouchBattleState();
	const EDecreaseStateType	GetDecreaseType()			{return m_eDecreaseType;}
	const bool					GetDispellable()			{return m_bDispellable;}
	//const bool				GetCancelable()				{return m_bCancelable;}
	const EIconCancelCond		GetIconCancelCond()			{return m_eIconCancelCond;}
	const CCfgCalc*				GetTime()					{return m_calcTime;}
	//const uint32&				GetIconID()					{return m_uIconID;}
	const string&				GetModelStr()				{return m_sModel;}
	//const uint32&				GetEffectID()				{return m_uEffectID;}
	bool						GetPersistent()				{return m_bPersistent;}
	bool						GetNeedSync()				{return m_bNeedSync;}
	void						SetNeedSync();
	void						SetNeedSaveToDB(double dTime);
	bool						GetNeedSaveToDB()			{return m_eNeedSaveToDB != eFSOFNS_ForceNoSave;}
	EForceSaveOrForceNoSave		GetNeedSaveToDBType()		{return m_eNeedSaveToDB;}


	static bool LoadConfig();
	static void UnloadConfig();
	static bool					Init();
	static uint32				GetNeedSyncCount()			{return m_uNeedSyncCount;}
	static void					SetNeedSyncByName(TCHAR* sName);

protected:
	uint32						m_uId;						//���
	string						m_sName;					//ħ��״̬����
	bool						m_bDecrease;				//�Ƿ�Ϊ����ħ��״̬
	EDecreaseStateType			m_eDecreaseType;			//����ħ��״̬����
	bool						m_bDispellable;				//�Ƿ�ɱ���ɢ�򾻻�
	EIconCancelCond				m_eIconCancelCond;			//�Ƿ�����ɿͻ����Լ�����ͼ�꣩ȡ��
	CCfgCalc*					m_calcTime;					//����ʱ��
	string						m_sModel;					//ģ��
	EForceSaveOrForceNoSave		m_eNeedSaveToDB;			//�����Ƿ���Ҫ���浽���ݿ�
	bool						m_bPersistent;				//��������Ȼ������״
	bool						m_bNeedSync;				//��Ҫͬ��

private:
	static bool					__init;
	static uint32				m_uNeedSyncCount;
};
