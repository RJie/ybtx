#include "stdafx.h"
#include "CPropertyCfg.h"
#include "CTxtTableFile.h"
#include "LoadSkillCommon.h"
#include "CCfgCalc.h"
#include "CCfgColChecker.inl"
#include "CStaticAttribMgr.h"
#include "BaseHelper.h"
#include "ExpHelper.h"
#include "StringHelper.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

CPropertyCfg::MultimapPropertyCfg	CPropertyCfg::ms_MultimapProperty;
CPropertyCfg::MapClassType			CPropertyCfg::ms_mapClassType;

bool CPropertyCfg::LoadConfig(const TCHAR* cfgFile)
{
	InitMapClassType();
	CTxtTableFile TabFile;
	CfgChk::SetTabFile(TabFile, "�������Ա�");
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), cfgFile)) 
		return false;

	for (int32 i = 1; i < TabFile.GetHeight(); ++i)
	{
		CPropertyCfg* pPropertyCfg = new CPropertyCfg;
		string strClass = TabFile.GetString(i, "ְҵ");
		trimend(strClass);
		MapClassType::iterator it = ms_mapClassType.find(strClass);
		pPropertyCfg->m_eClass = it->second;
		pPropertyCfg->m_pLevel					= new CCfgCalc(TabFile.GetString(i, "�ȼ�"));
		pPropertyCfg->m_pMaxHP					= new CCfgCalc(TabFile.GetString(i, "��������"));
		pPropertyCfg->m_pMaxMP					= new CCfgCalc(TabFile.GetString(i, "ħ������"));
		pPropertyCfg->m_pDPS					= new CCfgCalc(TabFile.GetString(i, "DPS"));
		pPropertyCfg->m_pMagicDamage			= new CCfgCalc(TabFile.GetString(i, "����"));
		pPropertyCfg->m_pDefence				= new CCfgCalc(TabFile.GetString(i, "����ֵ"));
		pPropertyCfg->m_pPhysicalDodge			= new CCfgCalc(TabFile.GetString(i, "������ֵ"));
		pPropertyCfg->m_pStrikeValue			= new CCfgCalc(TabFile.GetString(i, "����ֵ"));
		pPropertyCfg->m_pMagicDodge				= new CCfgCalc(TabFile.GetString(i, "�������ֵ"));
		pPropertyCfg->m_pNatureResistance		= new CCfgCalc(TabFile.GetString(i, "��Ȼ��ֵ"));
		pPropertyCfg->m_pDestructionResistance	= new CCfgCalc(TabFile.GetString(i, "�ƻ�����"));
		pPropertyCfg->m_pEvilResistance			= new CCfgCalc(TabFile.GetString(i, "���ڿ���"));
		pPropertyCfg->m_pAccuratenessValue		= new CCfgCalc(TabFile.GetString(i, "��׼ֵ"));			
		pPropertyCfg->m_pMagicHitValue			= new CCfgCalc(TabFile.GetString(i, "��������"));
		pPropertyCfg->m_pStrikeMultiValue		= new CCfgCalc(TabFile.GetString(i, "��������"));			
		pPropertyCfg->m_pResilienceValue		= new CCfgCalc(TabFile.GetString(i, "����ֵ"));	
		pPropertyCfg->m_pStrikeResistanceValue		= new CCfgCalc(TabFile.GetString(i, "�Ⱪֵ"));	
		pPropertyCfg->m_pHPUpdateRate			= TabFile.GetFloat(i, "��Ѫ��", 0.0f);
		pPropertyCfg->m_pMPUpdateRate			= TabFile.GetFloat(i, "��ħ��", 0.0f);
		pPropertyCfg->m_pParryValue				= new CCfgCalc(TabFile.GetString(i, "�м�ֵ"));
		pPropertyCfg->m_pRevertPer				= TabFile.GetFloat(i, "ս��״̬�ظ��ٶ�", 0.0f);
		pPropertyCfg->m_pValidityCoefficient	= TabFile.GetInteger(i, "��Ч��ϵ��", 0);
		pPropertyCfg->m_NatureSmashValue		= new CCfgCalc(TabFile.GetString(i, "��Ȼ��ѹֵ"));
		pPropertyCfg->m_DestructionSmashValue	= new CCfgCalc(TabFile.GetString(i, "�ƻ���ѹֵ"));
		pPropertyCfg->m_EvilSmashValue			= new CCfgCalc(TabFile.GetString(i, "������ѹֵ"));
		pPropertyCfg->m_DefenceSmashValue		= new CCfgCalc(TabFile.GetString(i, "������ѹֵ"));

		ms_MultimapProperty.insert(pair<EClass, CPropertyCfg*>(pPropertyCfg->m_eClass, pPropertyCfg));
	}

	//CStaticAttribMgr::Inst().InitAllClassStaticAttrib();

	return true;
}

CPropertyCfg::~CPropertyCfg()
{
	SafeDelete(m_pLevel);
	SafeDelete(m_pMaxHP);
	SafeDelete(m_pMaxMP);
	SafeDelete(m_pDPS);
	SafeDelete(m_pMagicDamage);
	SafeDelete(m_pDefence);
	SafeDelete(m_pPhysicalDodge);
	SafeDelete(m_pStrikeValue);
	SafeDelete(m_pMagicDodge);
	SafeDelete(m_pNatureResistance);
	SafeDelete(m_pDestructionResistance);
	SafeDelete(m_pEvilResistance);
	SafeDelete(m_pAccuratenessValue);		
	SafeDelete(m_pMagicHitValue);						
	SafeDelete(m_pStrikeMultiValue);	
	SafeDelete(m_pResilienceValue);
	SafeDelete(m_pStrikeResistanceValue);
	SafeDelete(m_pParryValue);
	SafeDelete(m_NatureSmashValue);
	SafeDelete(m_DestructionSmashValue);
	SafeDelete(m_EvilSmashValue);
	SafeDelete(m_DefenceSmashValue);
}

void CPropertyCfg::UnloadConfig()
{
	ClearMap(ms_MultimapProperty);
}

bool CPropertyCfg::IsClassInTable(EClass eClass)
{
	typedef MultimapPropertyCfg::iterator it_PropertyCfg;
	pair<it_PropertyCfg, it_PropertyCfg> pos = ms_MultimapProperty.equal_range(eClass);
	if (pos.first != pos.second)
		return true;

	return false;
}

CPropertyCfg* CPropertyCfg::GetPropertyCfg(EClass eClass, uint32 uLevel)
{
	typedef MultimapPropertyCfg::iterator it_PropertyCfg;
	pair<it_PropertyCfg,it_PropertyCfg> pos = ms_MultimapProperty.equal_range(eClass);
	for (; pos.first != pos.second; ++pos.first)
	{
		if (pos.first->second->IsAccordwithLevelLimit(uLevel))
		{
			return pos.first->second;
		}	
		
	}
	return NULL;
}

const string& CPropertyCfg::GetClassNameString(EClass eClass)
{
	static string str;
	MapClassType::iterator it = ms_mapClassType.begin();
	for (;it!=ms_mapClassType.end();++it)
	{
		if (it->second == eClass)
		{
			return it->first;
		}
	}
	return str;
}

bool CPropertyCfg::IsAccordwithLevelLimit(uint32 uLevel)
{
	string strLeftLevel = m_pLevel->GetString(0);
	uint32 uLeftLevel = atoi(strLeftLevel.c_str());
	if (m_pLevel->GetStringCount() > 1)
	{
		string strRightLevel = m_pLevel->GetString(1);
		uint32 uRightLevel = atoi(strRightLevel.c_str());
		return (uLeftLevel <= uLevel && uLevel <= uRightLevel) ? true : false;
	}
	else
	{
		return uLeftLevel == uLevel ? true : false;
	}
	return false;
}
