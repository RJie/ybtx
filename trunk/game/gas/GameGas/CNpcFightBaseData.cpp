#include "stdafx.h"
#include "CTxtTableFile.h"
#include "CNpcFightBaseData.h"
#include "CCfgColChecker.inl"
#include "TimeHelper.h"
#include "TSqrAllocator.inl"
#include "Random.h"
#include "CSkillServer.h"
#include "BaseHelper.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

CNpcFightBaseData::CNpcFightBaseData( const string& sName)
:m_sName(sName)
{

}

CNpcFightBaseData::~CNpcFightBaseData()
{
	ClearVector(m_lstBornSkill);
}

void CNpcFightBaseData::GetSkillRuleName(string& strSkillRuleName) const
{

	uint32 uRandomNum = Random::Rand(0,100);
	LstSkillRule::const_iterator iter = m_lSkillRule.begin();
	for (; iter != m_lSkillRule.end(); iter++)
	{
		if ((*iter).second >= uRandomNum)
		{
			strSkillRuleName = (*iter).first;
			return;
		}
	}
}

void CNpcFightBaseData::CreateNpcBornSkill(string &strSkill)
{
	if(strSkill.empty())
		return;
	erase(strSkill, " ");
	erase(strSkill,"\"");
	replace(strSkill, "��", ",");
	int32 startPos = -1;
	string strTemp;
	while (true)
	{
		if(strSkill.empty())
			return;
		startPos = strSkill.find(',');
		if(-1 == startPos)
		{
			const CNormalSkillServerSharedPtr* pSkillServer = new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill(strSkill));
			m_lstBornSkill.push_back(pSkillServer);
			return;
		}
		strTemp = strSkill.substr(0,startPos);
		if(strTemp.empty())
		{
			if(startPos < int32(strSkill.length())-1)
			{
				ostringstream strm;
				strm<<"Npc��"<< GetName() <<" �ĳ����ͷż����и�ʽ���ԣ��������� ,, �����"<< endl;
				GenErr(strm.str());
			}
			else
				return;
		}
		const CNormalSkillServerSharedPtr* pSkillServer = new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill(strTemp));
		m_lstBornSkill.push_back(pSkillServer);
		strSkill = strSkill.substr(startPos+1,strSkill.length());
	}
}

void CNpcFightBaseData::CreateNpcSkillRule(string& strSkillRule)
{
	if(strSkillRule.empty())
		return;
	erase(strSkillRule, " ");
	erase(strSkillRule,"\"");
	replace(strSkillRule, "��", ",");
	replace(strSkillRule, "��","(");
	replace(strSkillRule, "��", ")");
	if (strSkillRule.find(",") == -1) //˵��ֻ��һ�����ܹ����Npc
	{
		m_lSkillRule.push_back(make_pair(strSkillRule, 100));
		return;
	}

	uint32 uNumber = 0;
	//�������ж�����ܹ�������
	while (true)
	{
		if(strSkillRule.empty())
			return;
		string strSkillRuleNode;
		int32 uNext = strSkillRule.find(",");
		if (uNext != -1)
		{
			strSkillRuleNode = strSkillRule.substr(0, uNext);
			strSkillRule = strSkillRule.substr(uNext+1, strSkillRule.length());
		}
		else
		{
			strSkillRuleNode = strSkillRule;
			strSkillRule.clear();
		}
		Ast (!strSkillRuleNode.empty());
		int32 uStatrt = strSkillRuleNode.find("(");
		int32 uEnd = strSkillRuleNode.find(")");
		if (uStatrt == -1 || uEnd ==-1)
		{
			ostringstream strm;
			strm<<"NpcFightBaseData_Server���� Npc��"<< GetName() <<" �ļ��ܹ�����д����"<< endl;
			GenErr(strm.str());
		}
		string strSkillRuleName = strSkillRuleNode.substr(0, uStatrt);
		string strNum = strSkillRuleNode.substr(uStatrt+1, uEnd-uStatrt-1);
		uNumber = uNumber + static_cast<uint32>(atoi(strNum.c_str()));
		m_lSkillRule.push_back(make_pair(strSkillRuleName, uNumber));
	}
	if (uNumber != 100)
	{
		ostringstream strm;
		strm<<"NpcFightBaseData_Server���� Npc��"<< GetName() <<" �ļ��ܹ����ܸ��ʲ�Ϊ100�����ʵ��"<< endl;
		GenErr(strm.str());
	}
}



CNpcFightBaseDataMgr::CNpcFightBaseDataMgr()
{
}

CNpcFightBaseDataMgr::~CNpcFightBaseDataMgr()
{
	DeleteAll();
}

const CNpcFightBaseData* CNpcFightBaseDataMgr::GetEntity( const string& sName)
{
	IndexMapType::const_iterator it = m_mapIndex.find(sName);
	return it == m_mapIndex.end()  ? NULL : it->second;
}
bool CNpcFightBaseDataMgr::AddEntity( CNpcFightBaseData* pEntity )
{
	if( GetEntity( pEntity->GetName()) != NULL )
		return false;
	m_mapIndex[pEntity->GetName()] = pEntity;
	return true;
}
void CNpcFightBaseDataMgr::DeleteAll()
{
	for ( IndexMapType::const_iterator it = m_mapIndex.begin(); it != m_mapIndex.end(); ++it)
	{
		delete(it->second);
	}
	m_mapIndex.clear();
}
bool CNpcFightBaseDataMgr::LoadConfig( const string& sFileName )
{
	using namespace CfgChk;
	CTxtTableFile TabFile;
	CNpcFightBaseData*  pValue;
	string   sLimit = "";
	string	 sCondition = "";
	string	 sSkill = "";
	string	sBornSkill;
	string	strSkillRule;
	SetTabFile(TabFile, "NpcFightBaseData_Server");
	uint64	uBeginTime = GetProcessTime();
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), sFileName.c_str())) 
		return false;

	DeleteAll();

	for(int32 i=1; i<TabFile.GetHeight(); ++i)
	{
		SetLineNo(i);
		string sName = TabFile.GetString(i, "����");
		if (sName.empty())
			continue;
		pValue = new CNpcFightBaseData(sName);
		ReadItem(pValue->m_sNormalAttack, "��ͨ����",MUSTFILL);
		ReadItem(pValue->m_fAttackSpeed,"�����ٶ�",GE,0.0f);
		ReadItem(pValue->m_fAttackScope,"�չ�����", 1.f);
		ReadItem(strSkillRule,"���ܹ���",CANEMPTY);
		ReadItem(pValue->m_uBornTriggerType,"�������괥��������",CANEMPTY,0);
		ReadItem(pValue->m_bOpenTargetPKState, "�Ƿ��Ŀ��PK����",CANEMPTY,NO);
		ReadItem(pValue->m_bLevelPress, "�ȼ�ѹ��", CANEMPTY, NO);
		ReadItem(pValue->m_bChaosEnmity, "�ҳ��˳��",CANEMPTY, NO);
		ReadItem(pValue->m_bRegulate, "�Ƿ��Ŷ�",CANEMPTY, NO);
		ReadItem(pValue->m_bExclaimAlert, "�Ƿ��ܺ��о���", CANEMPTY, YES);
		ReadItem(sBornSkill,"�����ͷż���",CANEMPTY);
		ReadItem(pValue->m_uRandMaxAttackSpeed, "�����������ٶ�", 0);
		pValue->CreateNpcBornSkill(sBornSkill);
		pValue->CreateNpcSkillRule(strSkillRule);
		AddEntity(pValue);
	}
	SetTabNull();
	uint64 uEndTime = GetProcessTime();
	cout << "��ȡ���ñ���NpcFightBaseData_Server����ϣ�    ��ʱ��" << (uEndTime - uBeginTime) << " ���룡\n";
	return true;
}

