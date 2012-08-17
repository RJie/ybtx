#include "stdafx.h"
#include "CMagicEffClient.h"
#include "LoadSkillCommon.h"
#include "CCfgCalc.h"
#include "CCfgCalc.inl"
#include "CTxtTableFile.h"
#include "MagicConds_TestValue.inl"
#include "MagicConds_Function.h"
#include "CFighterDirector.h"
#include "IFighterDirectorHandler.h"
#include "BaseHelper.h"
#include "DebugHelper.h"
#include "StringHelper.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

CMagicEffClient::MapMagicEffClient	CMagicEffClient::ms_mapMagicEffClient;
CMagicEffClient::MapMagicEffClientById	CMagicEffClient::ms_mapMagicEffClientById;
CMagicEffClient::MapMagicCond		CMagicEffClient::ms_mapMagicCond;
uint32 CMagicEffClient::ms_uMaxLineNum = 0;
CMagicEffClientSharedPtr CMagicEffClient::ms_NULL;

CMagicEffClient::CMagicEffClient(void)
{
}

CMagicEffClient::~CMagicEffClient(void)
{
	ClearVector(m_vecMagicCondData);
}

void CMagicEffClient::BuildMCondMap()
{
	ClearMap(ms_mapMagicCond);

	ms_mapMagicCond["����ֵС��"]		= new CHealthPointLesserMCOND;
	ms_mapMagicCond["����ֵ���ڵ���"]	= new CHealthPointGreaterOrEqualMCOND;
	ms_mapMagicCond["ħ��ֵС��"]		= new CManaPointLesserMCOND;
	ms_mapMagicCond["ħ��ֵ���ڵ���"]	= new CManaPointGreaterOrEqualMCOND;
	ms_mapMagicCond["����ֵ���ڵ���"]	= new CEnergyPointGreaterOrEqualMCOND;
	ms_mapMagicCond["ŭ��ֵ���ڵ���"]	= new CRagePointGreaterOrEqualMCOND;
	ms_mapMagicCond["��������ڵ���"]	= new CComboPointGreaterOrEqualMCOND;
	ms_mapMagicCond["����С��"]			= new CProbabilityLesserCond;

	ms_mapMagicCond["����ħ��״̬"]		= new CTestMagicStateMCOND;
	ms_mapMagicCond["������ħ��״̬"]	= new CTestNotInMagicStateMCOND;
	ms_mapMagicCond["�����ڲ����ظ�ħ��״̬"]	= new CTestNotInRepeatedMagicStateMCOND;
	ms_mapMagicCond["���ڴ�����״̬"]	= new CTestTriggerStateMCOND;
	ms_mapMagicCond["�����˺����״̬"] = new CTestDamageChangeStateMCOND;
	ms_mapMagicCond["�������˺����״̬"]	= new CTestNotInDamageChangeStateMCOND;
	ms_mapMagicCond["��������״̬"]		= new CTestSpecialStateMCOND;
	ms_mapMagicCond["ħ��״̬���Ӳ������ڵ���"]	= new CTestMagicStateCascadeGreaterOrEqualMCOND;
	ms_mapMagicCond["������̬����"]		= new CTestAureMagicMCOND;
	ms_mapMagicCond["װ���˶���"]		= new CTestShieldEquipMCOND;
	ms_mapMagicCond["����װ����"]		= new CTestMainHandEquipMCOND;
	ms_mapMagicCond["����װ��������"]	= new CTestAssistHandEquipMCOND;
	ms_mapMagicCond["�������"]			= new CTestIsExistHorseMCOND;
	ms_mapMagicCond["���ﲻ����"]		= new CTestIsNotExistHorseMCOND;
	ms_mapMagicCond["Ŀ���Ƿ�Ϊ���"]			= new CTestTargetIsPlayerMCOND;
	ms_mapMagicCond["Ŀ���Ƿ�ΪNPC"]			= new CTestTargetIsNPCMCOND;
	ms_mapMagicCond["Ŀ���Ƿ�Ϊ�ٻ���"]			= new CTestTargetIsSummonMCOND;
	ms_mapMagicCond["Ŀ��ȼ�С�ڵ�������ȼ�"] = new CTestTargetLevelLesserOrEqualMCOND;
	ms_mapMagicCond["������ս��״̬"]			= new CTestNotInBattleMCOND;
	ms_mapMagicCond["�������淨״̬"]			= new CTestNotOnMissionMCOND;
	ms_mapMagicCond["Ŀ���Ƿ�ɱ�����"]			= new CTestTargetCanBeControlledMCOND;
	ms_mapMagicCond["���������ȼ����ڵ���"]		= new CTestBurstSoulTimesGreaterOrEqualMCOND;
	ms_mapMagicCond["�������"]					= new CTestIsExistPetMCOND;
}

CMagicCondClient* CMagicEffClient::GetMagicCond(const string& name)
{
	MapMagicCond::iterator it = ms_mapMagicCond.find(name);
	if(it == ms_mapMagicCond.end())
	{
		return NULL;
	}

	return it->second;
}

CMagicEffClientSharedPtr& CMagicEffClient::GetMagicEff(const string& name)
{
	MapMagicEffClient::iterator it = ms_mapMagicEffClient.find(name);

	if(it == ms_mapMagicEffClient.end())
	{
		stringstream str;
		str << "û��ħ��Ч��: " << name;
		GenErr(str.str().c_str());
	}

	return *(it->second);
}

CMagicEffClientSharedPtr& CMagicEffClient::GetMagicEffById(uint32 uId)
{
	stringstream ExpStr;
	CMagicEffClient::MapMagicEffClientById::iterator mapCfgItr;
	mapCfgItr = ms_mapMagicEffClientById.find(uId);
	if (mapCfgItr == ms_mapMagicEffClientById.end())
	{
		ExpStr << "û��ħ��Ч��: " << uId;
		GenErr(ExpStr.str());
		//return NULL;
	}

	return *(mapCfgItr->second);
}

bool CMagicEffClient::LoadMagicEff(const string& fileName, bool bFirstFile)
{
	if (bFirstFile)
	{
		UnloadMagicEff();
		BuildMCondMap();
	}

	CTxtTableFile MagicEffFile;
	if(!MagicEffFile.Load(PATH_ALIAS_CFG.c_str(), fileName.c_str()))
		return false;

	string curMagicEffName = "", lastMagicEffName;
	CMagicEffClient* pCurMagicEffCfg = NULL;
	MagicOpData* pCurMOPData = NULL;
	bool bNewSec = true;

	for( uint32 i = ms_uMaxLineNum+1; i < MagicEffFile.GetHeight()+ms_uMaxLineNum; ++i )
	{
		uint32 uLineNum = i-ms_uMaxLineNum;
		string name	= MagicEffFile.GetString( uLineNum, szMagicEff_Name);
		trimend(name);

		if( name.empty() )
		{
			bNewSec = true;
			continue;
		}

		if( bNewSec )
		{
			bNewSec = false;
			lastMagicEffName = curMagicEffName;
			curMagicEffName = name;
			pCurMagicEffCfg = new CMagicEffClient;
			pCurMagicEffCfg->m_uId = i;
			pCurMagicEffCfg->m_strName = name;
			if(curMagicEffName.compare(lastMagicEffName) != 0)	// ��ʼ����һ��ħ��Ч��
			{
				CMagicEffClientSharedPtr* pCurMagicEffCfgSharedPtr = new CMagicEffClientSharedPtr(pCurMagicEffCfg);
				ms_mapMagicEffClient.insert(pair<string, CMagicEffClientSharedPtr*>(name, pCurMagicEffCfgSharedPtr));	
				ms_mapMagicEffClientById.insert(make_pair(pCurMagicEffCfg->m_uId, pCurMagicEffCfgSharedPtr));
			}
			else
			{
				continue;
			}
		}

		//��ʼ��ÿ��ħ������������
		pCurMOPData = new MagicOpData;	
		pCurMOPData->m_uId				= i;
		pCurMOPData->m_strMagicOpName	= MagicEffFile.GetString(uLineNum, szMagicEff_MagicOp);
		trimend(pCurMOPData->m_strMagicOpName);
		string strObjFilter				= MagicEffFile.GetString(uLineNum, szMagicEff_FilterPipe);
		trimend(strObjFilter);
		pCurMOPData->m_pMagicOpArg		= new CCfgCalc();
		string sArg = MagicEffFile.GetString(uLineNum, szMagicEff_MOPParam);
		trimend(sArg);
		pCurMOPData->m_pMagicOpArg->InputString(sArg);	
		string strMOPType				= MagicEffFile.GetString(uLineNum, szMagicEff_MOPType);
		trimend(strMOPType);
		string strExecCond				= MagicEffFile.GetString(uLineNum, szMagicEff_MOPExecCond);
		trimend(strExecCond);
		if ( strMOPType.find("����") != -1 && strExecCond.compare("")==0 && strObjFilter=="����" )
		{
			pCurMagicEffCfg->m_vecMagicCondData.push_back(pCurMOPData);
		}
		else
		{
			delete pCurMOPData;
		}
	}
	ms_uMaxLineNum = ms_uMaxLineNum + MagicEffFile.GetHeight();
	return true;
}

uint32 CMagicEffClient::DoMagicCond(uint32 SkillLevel, const CFighterDirector* pFighter)
{
	uint32 uResult = eDSR_Success;

	if(m_vecMagicCondData.empty())
		return uResult;

	VecMagicCondData::iterator it = m_vecMagicCondData.begin();
	for(; it != m_vecMagicCondData.end(); ++it)
	{
		if (CMagicEffClient::GetMagicCond((*it)->m_strMagicOpName) == NULL)
			continue;
		uResult = CMagicEffClient::GetMagicCond((*it)->m_strMagicOpName)->Test(SkillLevel, *((*it)->m_pMagicOpArg), pFighter);
		if (uResult != eDSR_Success)
			return uResult;
	}

	return uResult;
}

EConsumeType CMagicEffClient::GetEConsumeType()
{
	EConsumeType eConsumeType = eCT_None;

	if (m_vecMagicCondData.empty())
		return eConsumeType;

	VecMagicCondData::iterator it = m_vecMagicCondData.begin();
	for(; it != m_vecMagicCondData.end(); ++it)
	{
		if ((*it)->m_strMagicOpName == "ħ��ֵ���ڵ���")
		{
			eConsumeType = eCT_MP;
		}
		else if ((*it)->m_strMagicOpName == "ŭ��ֵ���ڵ���")
		{
			eConsumeType = eCT_RG;
		}
		else if ((*it)->m_strMagicOpName == "����ֵ���ڵ���")
		{
			eConsumeType = eCT_EG;
		}
		else if ((*it)->m_strMagicOpName == "��������ڵ���")
		{
			eConsumeType = eCT_CP;
		}
		else if ((*it)->m_strMagicOpName == "����ֵ���ڵ���")
		{
			eConsumeType = eCT_HP;
		}
	}

	return eConsumeType;
}

CCfgCalc* CMagicEffClient::GetMagicOpArg(const string& name)
{
	if (m_vecMagicCondData.empty())
		return NULL;

	VecMagicCondData::iterator it = m_vecMagicCondData.begin();
	for(; it != m_vecMagicCondData.end(); ++it)
	{
		if ((*it)->m_strMagicOpName == name)
			return (*it)->m_pMagicOpArg;	
	}

	return NULL;
}

void CMagicEffClient::UnloadMagicEff()
{
	ClearMap(ms_mapMagicCond);
	ClearMap(ms_mapMagicEffClient);
	ms_mapMagicEffClientById.clear();
}
