#include "stdafx.h"
#include "CBaseState.h"
#include "CCfgColChecker.inl"
#include "TSqrAllocator.inl"

CBaseStateCfg::MapBaseStateCfgByName CBaseStateCfg::m_mapGlobalCfgByName;
CBaseStateCfg::MapBaseStateCfgById CBaseStateCfg::m_mapGlobalCfgById;
MapIconCancelCond CBaseStateCfg::ms_mapIconCancelCond;
MapDecreaseStateType CBaseStateCfg::ms_mapDecreaseType;
MapStringVector CBaseStateCfg::ms_vecTypeName;
bool CBaseStateCfg::__init = CBaseStateCfg::InitMap();

bool CBaseStateCfg::InitMap()
{
	using namespace CfgChk;
	CreateMap(ms_mapIconCancelCond, eICC_End, ("����"), ("�Լ�"), ("����"));
	CreateVector(ms_vecTypeName, eSGT_End, ("����״̬"), ("ħ��״̬"), ("������״̬"), ("�˺����״̬"), ("���۴���״̬"), ("����״̬"));

	ms_mapDecreaseType["����"] = eDST_Riding;
	ms_mapDecreaseType["����"] = eDST_Increase;
	ms_mapDecreaseType["����"] = eDST_FeignDeath;
	//ms_mapDecreaseType["�����ս��"] = eDST_IncreaseTouchBattleState;
	ms_mapDecreaseType["����"] = eDST_Control;
	ms_mapDecreaseType["����"] = eDST_Pause;
	ms_mapDecreaseType["����"] = eDST_Crippling;
	ms_mapDecreaseType["����"] = eDST_Debuff;
	ms_mapDecreaseType["�˺�"] = eDST_DOT;
	ms_mapDecreaseType["����"] = eDST_Special;

	return true;
}

CBaseStateCfg*	CBaseStateCfg::GetByGlobalName(const string& name)
{
	CBaseStateCfg::MapBaseStateCfgByName::iterator mapCfgItr;
	mapCfgItr = m_mapGlobalCfgByName.find(name);
	if (mapCfgItr == m_mapGlobalCfgByName.end())
	{
		stringstream ExpStr;
		ExpStr << "״̬��������";
		CfgChk::GenExpInfo(ExpStr.str(), name);
		return NULL;
	}
	return mapCfgItr->second;
}

CBaseStateCfg*	CBaseStateCfg::GetByGlobalNameNoExp(const string& name)
{
	CBaseStateCfg::MapBaseStateCfgByName::iterator mapCfgItr;
	mapCfgItr = m_mapGlobalCfgByName.find(name);
	if (mapCfgItr == m_mapGlobalCfgByName.end())
	{
		stringstream ExpStr;
		ExpStr << "״̬��������";
		return NULL;
	}
	return mapCfgItr->second;
}


CBaseStateCfg*	CBaseStateCfg::GetByGlobalId(uint32 uId)
{
	CBaseStateCfg::MapBaseStateCfgById::iterator mapCfgItr;
	mapCfgItr = m_mapGlobalCfgById.find(uId);
	if (mapCfgItr == m_mapGlobalCfgById.end())
	{
		stringstream ExpStr;
		ExpStr << "״̬ID������";
		CfgChk::GenExpInfo(ExpStr.str(), uId);
		//return NULL;
	}
	return mapCfgItr->second;
}

CBaseStateCfg::CBaseStateCfg(EStateGlobalType type)
:m_eGlobalType(type)
{
}

CBaseStateCfg::CBaseStateCfg(const CBaseStateCfg& cfg)
:m_eGlobalType(cfg.m_eGlobalType)
,m_fScale(cfg.m_fScale)
,m_fScaleTime(cfg.m_fScaleTime)
{
}

