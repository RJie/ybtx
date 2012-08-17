#pragma once
#include "FightDef.h"
#include "CDynamicObject.h"
#include "TConfigAllocator.h"

class CCfgRelationDeal;

typedef vector<string, TConfigAllocator<uint32> > MapStringVector;
typedef map<string, EIconCancelCond, less<string>, 
		TConfigAllocator<pair<string, EIconCancelCond > > > MapIconCancelCond;
typedef map<string, EDecreaseStateType, less<string>, 
		TConfigAllocator<pair<string, EDecreaseStateType > > > MapDecreaseStateType;

class CBaseStateCfg
	: public virtual CDynamicObject
	, public CConfigMallocObject
{
	friend class CCfgRelationDeal;
	friend class CCfgAllStateCheck;
public:
	typedef map<string, CBaseStateCfg*, less<string>, 
		TConfigAllocator<pair<string, CBaseStateCfg* > > > MapBaseStateCfgByName;
	typedef map<uint32, CBaseStateCfg*, less<uint32>, 
		TConfigAllocator<pair<uint32, CBaseStateCfg* > > > MapBaseStateCfgById;

public:
	CBaseStateCfg(EStateGlobalType type = eSGT_Undefined);
	CBaseStateCfg(const CBaseStateCfg& cfg);

	static CBaseStateCfg*					GetByGlobalName(const string& name);	//��ȡħ��״̬������
	static CBaseStateCfg*					GetByGlobalNameNoExp(const string& name);	//��ȡħ��״̬������
	static CBaseStateCfg*					GetByGlobalId(uint32 uId);				//��ȡħ��״̬������
	static EStateGlobalType					GetStaticType()				{return eSGT_Undefined;}
	EStateGlobalType						GetGlobalType()				{return m_eGlobalType;}	//��ȡħ��״̬�������
	const string&							GetTypeName()				{return ms_vecTypeName[m_eGlobalType];}
	static bool								InitMap();

protected:
	static MapBaseStateCfgByName				m_mapGlobalCfgByName;					//ħ��״̬����ӳ���
	static MapBaseStateCfgById					m_mapGlobalCfgById;						//ħ��״̬����ӳ���
	static MapIconCancelCond					ms_mapIconCancelCond;					//ȡ����������MAP
	static MapDecreaseStateType					ms_mapDecreaseType;						//����ħ��״̬����MAP
	static MapStringVector						ms_vecTypeName;
	static bool									__init;

	EStateGlobalType							m_eGlobalType;							//ħ��״̬���������ͨħ��״̬��������״̬���˺����״̬������״̬
	float										m_fScale;								//��ɫ���ű���
	float										m_fScaleTime;							//���Ź���ʱ��

public:
	virtual uint32				GetId() = 0;
	virtual const TCHAR*		GetName() = 0;
	virtual const TCHAR*		GetIcon()					{return "";}
	virtual const TCHAR*		GetModel()					{return "";}
	virtual const TCHAR*		GetFX()						{return "";}
	virtual const bool			IsMultiCascadeFX()			{return false;}
	virtual const TCHAR*		GetFX(uint32 i)				{return "";}
	virtual const string&		GetModelStr() = 0;
	float						GetScale()					{return m_fScale;}
	uint64						GetScaleTime()				{return uint64(m_fScaleTime * 1000 + 0.5);}
	virtual const bool			GetCancelable()				{return false;}
};

#define STATE_TIME_INT64_MIN_VALUE 0x8000000000000000


