#include "stdafx.h"
#include "CCfgCalcFunction.h"
#include "CTxtTableFile.h"
#include "LoadSkillCommon.h"
#include "CCfgCalc.h"
#include "FightDef.h"
#include <cmath>
#include "BaseHelper.h"
#include "CCfgColChecker.inl"
#include "CQuickRand.h"
#include "StringHelper.h"

using namespace std;
using namespace CfgChk;

#define MAX_INDEX_SIZE 150

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

inline static void CreateExpStr(stringstream& ExpStr, const int32& Row, TCHAR* ColumeName)
{
	ExpStr << "��" << Row << "��" << ColumeName << "��ֵ����";
}

//bool CCfgGlobal::__init = CCfgGlobal::Init();
CCfgGlobal::MapGlobalSkillParam CCfgGlobal::m_mapVar;
CCfgGlobal::VecGlobalSkillParam CCfgGlobal::m_vecVar;
bool CCfgGlobal::m_bRandValueIsFixed = false;
int32 CCfgGlobal::m_iRandFixedValue = 0;
bool CCfgGlobal::m_bRandfValueIsFixed = false;
double CCfgGlobal::m_dRandfFixedValue = 0.0;




//������CCfgGlobal������
//bool CCfgGlobal::Init()
//{
//	m_dVecResult.resize(MAX_INDEX_SIZE);
//	for(size_t i = 0; i < MAX_INDEX_SIZE; ++i)
//	{
//		m_bCalculated[i] = false;
//	}
//	return true;
//}


bool CCfgGlobal::LoadConfig(const TCHAR* cfgFile)
{
	CTxtTableFile TabFile;

	CfgChk::SetTabFile(TabFile, "ȫ�ֲ���");
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), cfgFile)) return false;
	UnloadConfig();
	m_vecVar.resize(TabFile.GetHeight());

	for(int32 i=1; i<TabFile.GetHeight(); i++)
	{
		stringstream strName;
		string strName1 = TabFile.GetString(i, szGlobalParam_Name1);
		tolower(strName1);
		trimend(strName1);
		string strName2 = TabFile.GetString(i, szGlobalParam_Name2);
		tolower(strName2);
		trimend(strName2);
		strName << strName1 << "." << strName2;

		if(strName.str() == ".")
		{
			continue;
		}

		CCfgCalc* pCfgCalc = new CCfgCalc(TabFile.GetString(i, szGlobalParam_CfgCalc));
		pCfgCalc->SetTypeExpression();

		CCfgGlobal* pCfg = new CCfgGlobal;
		pCfg->m_pCfgCalc = pCfgCalc;

		SetLineNo(i);
		ReadItem(pCfg->m_bIsArrayConst, szGlobalParam_IsArrayConst, CANEMPTY);
		if(pCfg->m_bIsArrayConst)
		{
			pCfg->m_bDeqCalculated.assign(MAX_INDEX_SIZE, false);
			pCfg->m_dVecResult.assign(MAX_INDEX_SIZE, 0.0);
		}
			
		pair<MapGlobalSkillParam::iterator, bool> pr = m_mapVar.insert(make_pair(strName.str(), pCfg));
		pCfg->m_uId = i;
		m_vecVar[i] = pCfg;
		if(!pr.second)
		{
			SafeDelete(pCfg);
			stringstream ExpStr;
			ExpStr << "��" << i << "�е�" << "ȫ�ּ��ܲ��� " << strName.str() << " �ظ�";
			GenErr(ExpStr.str());
			//return false;
		}
	}
	return true;
}

void CCfgGlobal::UnloadConfig()
{
	ClearMap(m_mapVar);
	m_vecVar.clear();
}

CCfgGlobal::~CCfgGlobal()
{
	delete m_pCfgCalc;
	m_dVecResult.clear();
	m_bDeqCalculated.clear();
}


template<>
double CCfgGlobal::Get<CFighterNull>(const CFighterNull* pFrom, const CFighterNull* pTo, uint32 index)
{
	if(m_bIsArrayConst)
	{
		if(m_bDeqCalculated[index])
		{
			return m_dVecResult[index];
		}
		else
		{
			m_bDeqCalculated[index] = true;
			return m_dVecResult[index] = m_pCfgCalc->GetDblValue(pFrom, pTo, index);
		}
	}
	else
	{
		return m_pCfgCalc->GetDblValue(pFrom, pTo, index);
	}
}

pair<bool, CCfgGlobal*> CCfgGlobal::GetCfgValue(const string& name)
{
	MapGlobalSkillParam::iterator itr = m_mapVar.find(name);
	if(itr != m_mapVar.end())
	{
		return make_pair(true, itr->second);
	}
	else
	{
		return make_pair(false, (CCfgGlobal*)(NULL));
	}
}

bool CCfgGlobal::ExistCfgGlobal(const string& name)
{
	return m_mapVar.find(name) != m_mapVar.end();
}

const TCHAR* CCfgGlobal::GetCalcChars(const TCHAR* sName)
{
	static string sEmpty = "";
	MapGlobalSkillParam::iterator itr = m_mapVar.find(sName);
	if(itr != m_mapVar.end())
	{
		if(itr->second->m_pCfgCalc)
			return itr->second->m_pCfgCalc->GetTestString().c_str();
	}
	return sEmpty.c_str();
}

uint32 CCfgGlobal::GetVarId(const string& name)
{
	MapGlobalSkillParam::iterator itr = m_mapVar.find(name);
	if(itr != m_mapVar.end())
	{
		return itr->second->m_uId;
	}
	else
	{
		return 0;
	}
}

pair<bool, CCfgGlobal*> CCfgGlobal::GetCfgValue(uint32 uId)
{
	if(uId >= m_vecVar.size())
	{
		stringstream str;
		str << "ȫ�ֱ����±�" << uId << "������������" << m_vecVar.size();
		GenExpInfo(str.str());
		return make_pair(false, (CCfgGlobal*)(NULL));
	}
	
	return make_pair(true, m_vecVar[uId]);
}



void CCfgGlobal::SetRandFixedValue(int32 iValue)
{
	m_bRandValueIsFixed = true;
	m_iRandFixedValue = iValue;
}

void CCfgGlobal::SetRandfFixedValue(double dValue)
{
	m_bRandfValueIsFixed = true;
	m_dRandfFixedValue = dValue;
}

void CCfgGlobal::ClearRandFixedValue()
{
	m_bRandValueIsFixed = false;
}

void CCfgGlobal::ClearRandfFixedValue()
{
	m_bRandfValueIsFixed = false;
}






//������CAttrVarMap������
CAttrVarMap::MapAttrVarName2Id CAttrVarMap::m_mapVarId;
bool CAttrVarMap::__init = CAttrVarMap::InitMapVarId();

bool CAttrVarMap::InitMapVarId()
{
	//ע�⣺�������������ĸ�������Сд
	m_mapVarId["��ǰ����ֵ"]	= ePID_HealthPoint * ePFT_Count + ePFT_Agile;
	m_mapVarId["����ֵ����"]	= ePID_HealthPoint * ePFT_Count + ePFT_Value;
	m_mapVarId["��ǰħ��ֵ"]	= ePID_ManaPoint * ePFT_Count + ePFT_Agile;
	m_mapVarId["ħ��ֵ����"]	= ePID_ManaPoint * ePFT_Count + ePFT_Value;
	m_mapVarId["��ǰŭ��ֵ"]	= ePID_RagePoint * ePFT_Count + ePFT_Agile;

	m_mapVarId["������"]		= ePID_MagicDamageValue*ePFT_Count + ePFT_Value;

	m_mapVarId["�񵲼���ֵ"]	= ePID_BlockDamage * ePFT_Count + ePFT_Value;
	m_mapVarId["����"]		= ePID_BlockRate * ePFT_Count + ePFT_Value;
	
	m_mapVarId["������������˺�"]	= ePID_MainHandMaxWeaponDamage * ePFT_Count + ePFT_Value;
	m_mapVarId["����������С�˺�"]	= ePID_MainHandMinWeaponDamage * ePFT_Count + ePFT_Value;
	m_mapVarId["���������������"]	= ePID_MainHandWeaponInterval * ePFT_Count + ePFT_Value;
	m_mapVarId["����������������˺�����ϵ��"]	= ePID_MHWeaponIntervalExtraDamageRate * ePFT_Count + ePFT_Value;
	m_mapVarId["����������������˺�����ϵ��"]	= ePID_AHWeaponIntervalExtraDamageRate * ePFT_Count + ePFT_Value;
	m_mapVarId["���������������"]	= ePID_AssistantWeaponInterval * ePFT_Count + ePFT_Value;

	m_mapVarId["�ƶ��ٶ�"] = ePID_RunSpeed * ePFT_Count + ePFT_Value;

	m_mapVarId["������"] = ePID_PhysicalDPS * ePFT_Count + ePFT_Value;

	m_mapVarId["����"] = ePID_MagicDamageValue * ePFT_Count + ePFT_Value;

	m_mapVarId["����ֵ�ָ��ٶ�"] = ePID_HPUpdateRate * ePFT_Count + ePFT_Value;
	m_mapVarId["ħ��ֵ�ָ��ٶ�"] = ePID_MPUpdateRate * ePFT_Count + ePFT_Value;
	m_mapVarId["����ֵ"] = ePID_Defence * ePFT_Count + ePFT_Value;
	m_mapVarId["�м�ֵ"] = ePID_ParryValue * ePFT_Count + ePFT_Value;
	m_mapVarId["������ֵ"] = ePID_PhysicalDodgeValue * ePFT_Count + ePFT_Value;
	m_mapVarId["����ֵ"] = ePID_StrikeValue * ePFT_Count + ePFT_Value;
	m_mapVarId["��������ֵ"] = ePID_StrikeMultiValue * ePFT_Count + ePFT_Value;
	m_mapVarId["����ֵ"] = ePID_ResilienceValue * ePFT_Count + ePFT_Value;
	m_mapVarId["�Ⱪֵ"] = ePID_StrikeResistanceValue * ePFT_Count + ePFT_Value;
	m_mapVarId["��׼ֵ"] = ePID_AccuratenessValue * ePFT_Count + ePFT_Value;
	m_mapVarId["��������ֵ"] = ePID_MagicHitValue * ePFT_Count + ePFT_Value;
	m_mapVarId["�������ֵ"] = ePID_MagicDodgeValue * ePFT_Count + ePFT_Value;
	m_mapVarId["��Ȼϵ����ֵ"] = ePID_NatureResistanceValue * ePFT_Count + ePFT_Value;
	m_mapVarId["�ƻ�ϵ����ֵ"] = ePID_DestructionResistanceValue * ePFT_Count + ePFT_Value;
	m_mapVarId["����ϵ����ֵ"] = ePID_EvilResistanceValue * ePFT_Count + ePFT_Value;
	m_mapVarId["�ƻ�ϵ����ֵ�ٷֱ�"] = ePID_DestructionResistanceValue * ePFT_Count + ePFT_Multiplier;
	
	m_mapVarId["�չ��˺�"] = eMAID_NADamage;
	m_mapVarId["����ȼ�"] = eMAID_FighterLevel;
	m_mapVarId["�����Ƿ�"] = eMAID_MainHandWeaponIsSingle;

	return true;
}

pair<bool, uint32> CAttrVarMap::GetVarId(const string& name)
{
	MapAttrVarName2Id::iterator itr = m_mapVarId.find(name);
	if(itr == m_mapVarId.end())
	{
		return make_pair(false, eMAID_Undefined);
	}
	else
	{
		return make_pair(true, itr->second);
	}
}

//�����Ǿ�̬������
int32 CCfgGlobal::Rand(double fStart, double fEnd)
{
	if(m_bRandValueIsFixed && fStart <= m_iRandFixedValue && fEnd >= m_iRandFixedValue)
	{
		return m_iRandFixedValue;
	}
	double fMin = min(fStart, fEnd);
	double fMax = max(fStart, fEnd);
	double fFixMin = ceil(fMin);
	Ast(fFixMin == (int32)fFixMin);
	double fFixMax = floor(fMax + 1.0);
	Ast(fFixMax == (int32)fFixMax);
	//int32 iResult = (int32)(fFixMin + rand() / (double)(RAND_MAX + 1) * (fFixMax - fFixMin));
	int32 iResult = CQuickRand::Rand2((int32)fFixMin, (int32)fFixMax);
	if(iResult > fMax || iResult < fMin)
	{
		stringstream sExp;
		sExp << "�������" << iResult << "���ڱ��ʽRand(" << fStart << "," << fEnd << ") ��������Χ��\n";
		cout << sExp.str();
	}
	return iResult;
}






double CCfgGlobal::Randf(double fStart, double fEnd)
{
	if(m_bRandfValueIsFixed && fStart <= m_dRandfFixedValue && fEnd >= m_dRandfFixedValue)
	{
		return m_dRandfFixedValue;
	}
	return rand() / (double)RAND_MAX * (fEnd - fStart) + fStart;
}	

double CCfgGlobal::IfElse(double fIf, double fThen, double fElse)
{
	if(fIf)
	{
		return fThen;
	}
	else
	{
		return fElse;
	}
}

template<>
bool CCfgGlobal::ExistMagicState<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return false;
}

template<>
bool CCfgGlobal::ExistTriggerState<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return false;
}

template<>
bool CCfgGlobal::ExistDamageChangeState<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return false;
}

template<>
bool CCfgGlobal::ExistSpecialState<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return false;
}

template<>
bool CCfgGlobal::ExistState<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return false;
}

template<>
uint32 CCfgGlobal::StateCount<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return 0;
}

template<>
uint32 CCfgGlobal::CurRlserStateCount<CFighterNull>(string& name, const CFighterNull* pFrom, const CFighterNull* pFighter)
{
	return 0;
}

template<>
uint32 CCfgGlobal::TriggerCount<CFighterNull>(string& name, const CFighterNull* pFighter)
{
	return 0;
}

template<>
int32 CCfgGlobal::StateLeftTime<CFighterNull>(string& name, const CFighterNull* pFrom, const CFighterNull* pTo)
{
	return 0;
}

template<>
double CCfgGlobal::Distance<CFighterNull>(const CFighterNull* pFrom, const CFighterNull* pTo)
{
	return 0.0;
}

template<>
bool CCfgGlobal::TargetIsNPC<CFighterNull>(const CFighterNull* pTo)
{
	return 0.0;
}

bool CCfgGlobal::IsActiveSkill(string& name, const CFighterNull* pFighter)
{
	return true;
}

