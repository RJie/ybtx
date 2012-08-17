#include "stdafx.h"
#include "CServantData.h"
#include "CTxtTableFile.h"
#include "TimeHelper.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

CServantData::CServantData(sqr::uint32 uID, const std::string &sName)
:m_uID(uID)
,m_sName(sName)
{

}

CServantDataMgr::CServantDataMgr()
{

}

CServantDataMgr::~CServantDataMgr()
{
	DeleteAll();
}

bool CServantDataMgr::LoadConfig( const string& sFileName )
{
	CTxtTableFile TabFile;
	CServantData*  pValue;
	uint64 uBeginTime = GetProcessTime();
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), sFileName.c_str())) return false;

	DeleteAll();

	for(int32 i=1; i<TabFile.GetHeight(); ++i)
	{   
		pValue = new CServantData(GetSize(), TabFile.GetString(i, "Name"));
		pValue->m_MaxHealthPoint	= TabFile.GetFloat(i, "��������", 0.0f);
		pValue->m_MaxManaPoint		= TabFile.GetFloat(i, "ħ������", 0.0f);
		pValue->m_PhysicalDodgeValue 	= TabFile.GetFloat(i, "������ֵ", 0.0f);
		pValue->m_StrikeValue					= TabFile.GetFloat(i, "����ֵ", 0.0f);
		pValue->m_StrikeMultiValue		= TabFile.GetFloat(i, "��������", 0.0f);		
		pValue->m_MagicDodgeValue	= TabFile.GetFloat(i, "�������ֵ", 0.0f);
		pValue->m_MagicHitValue			= TabFile.GetFloat(i, "��������", 0.0f);			
		pValue->m_PhysicalDPS				= TabFile.GetFloat(i, "������", 0.0f);				
		pValue->m_MagicDamageValue	= TabFile.GetFloat(i, "����", 0.0f);	
		pValue->m_Defence					= TabFile.GetFloat(i, "����ֵ", 0.0f);				
		pValue->m_NatureResistanceValue= TabFile.GetFloat(i, "��Ȼ����", 0.0f);		
		pValue->m_DestructionResistanceValue= TabFile.GetFloat(i, "�ƻ�����", 0.0f);
		pValue->m_EvilResistanceValue= TabFile.GetFloat(i, "���ڿ���", 0.0f);	
		pValue->m_ParryValue= TabFile.GetFloat(i, "�м�ֵ", 0.0f);	
		pValue->m_ResilienceValue= TabFile.GetFloat(i, "����ֵ", 0.0f);	
		pValue->m_StrikeResistanceValue= TabFile.GetFloat(i, "�Ⱪֵ", 0.0f);	
		pValue->m_AccuratenessValue= TabFile.GetFloat(i, "��׼ֵ", 0.0f);	
		AddEntity(pValue);
	}   
	uint64 uEndTime = GetProcessTime();
	cout << "��ȡ���ñ���ServantProperty_Server����ϣ�    ��ʱ��" << (uEndTime - uBeginTime) << " ���룡\n";
	return true;
}

