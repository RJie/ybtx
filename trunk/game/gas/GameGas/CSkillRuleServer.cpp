#include "stdafx.h"
#include "CSkillRuleDef.h"
#include "CSkillRuleServer.h"
#include "CCfgColChecker.inl"
#include "CBaseRuleCondition.h"
#include "CSkillRuleBaseData.h"
#include "ErrLogHelper.h"
#include "TimeHelper.h"
#include "DebugHelper.h"
#include "CSkillServer.h"
#include "CMagicEffServer.h"
#include "CCastingProcess.h"
#include "CCastingProcessCfg.h"
#include "TSqrAllocator.inl"
#include "TypeName2SRTarget.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

CSkillRuleServer::MapSRTypeName		CSkillRuleServer::m_mapSkillTypeName;
CSkillRuleServer::MapSRDataType		CSkillRuleServer::m_mapRuleDataByName;
TypeName2SRTarget	CSkillRuleServer::m_mapSRTargetType;
string	CSkillRuleServer::m_strTempRuleName;
string	CSkillRuleServer::m_strTempSkillName;

bool CSkillRuleServer::LoadSkillRuleCfg(const string& strFileName)
{
	using namespace CfgChk;
	CreateMap<MapSRTypeName, ESkillRuleTypeName>(m_mapSkillTypeName, ESKRT_End, "", "��ͨ����", "�л��׶�", "����ı�Ŀ��", "����ı��NpcĿ��",
		"����", "���غ���", "��ѡһ", "��Χ�ص��ͷż���", "����Ч����", "���Ⱦ���", "���������ͷ�", "״̬�����ͷ�");

	CTxtTableFile TabFile;
	SetTabFile(TabFile, "SkillRuleBaseData_Server");
	if(!TabFile.Load(::PATH_ALIAS_CFG.c_str(), strFileName.c_str()))
		return false;
	uint64	uBeginTime = GetProcessTime();
	bool bNewNpc = true;
	for (int i = 1;i<TabFile.GetHeight();++i)
	{
		SetLineNo(i);
		string strNpcRuleName;
		ReadItem(strNpcRuleName,"����",	CANEMPTY);
		if (strNpcRuleName.empty())
		{
			bNewNpc = true;
			continue;
		}
		if(bNewNpc)
		{
			bNewNpc = false;
			LstRuleDataType* pLstRuleData = new LstRuleDataType;
			m_mapRuleDataByName[strNpcRuleName] = pLstRuleData;
			m_strTempRuleName = strNpcRuleName;
		}
		CSkillRuleData* pSkillRuleData = new CSkillRuleData;
		ReadItem(pSkillRuleData->m_iSkillPage,"�׶�");
		ReadItem(m_strTempSkillName, "��������");
		CreateSkillTypeName(pSkillRuleData, m_strTempSkillName);
		ReadItem(pSkillRuleData->m_uCoolDownTime, "��ȴʱ��", MUSTFILL, 0);
		string	strBeginCond;
		ReadItem(strBeginCond,"��ʼ����",CANEMPTY);
		string	strContinueCond;
		ReadItem(strContinueCond,"���з�ʽ",CANEMPTY);
		CreateRuleCondData(pSkillRuleData,strBeginCond,strContinueCond);
		string	strTarget;
		ReadItem(strTarget,"ʩ��Ŀ��",CANEMPTY);
		CreateRuleTargetType(pSkillRuleData,strTarget);
		string	strDistance;
		ReadItem(strDistance,"���ܾ���",CANEMPTY);
		CreateRuleDistance(pSkillRuleData,strDistance);
		if(IsHaveSkillArg(m_strTempSkillName))
		{
			string	strSkillArg;
			ReadItem(strSkillArg,"���ܲ���",MUSTFILL);
			CreateMultiSkill(pSkillRuleData,strSkillArg);
		}
		string sCheckDistanceAgain;
		ReadItem(sCheckDistanceAgain, "�ƶ����ٴ�У�����", CANEMPTY);
		pSkillRuleData->m_bCheckDistanceAgain = sCheckDistanceAgain.compare("��") == 0 ? true : false; 
		CreateRuleDataSkillCfg(pSkillRuleData);
		(m_mapRuleDataByName[strNpcRuleName])->push_back(pSkillRuleData);
	}

	uint64 uEndTime = GetProcessTime();
	cout << "��ȡ���ñ���SkillRuleBaseData_Server����ϣ�    ��ʱ��" << (uEndTime - uBeginTime) << " ���룡\n";
	return true;
}

void CSkillRuleServer::UnloadSkillRuleCfg()
{
	//m_mapSRTargetType.clear();
	for (MapSRDataType::iterator iter = m_mapRuleDataByName.begin();iter!=m_mapRuleDataByName.end();)
	{
		LstRuleDataType* lstRuleData = iter->second;
		for (LstRuleDataType::iterator RdIter = lstRuleData->begin();RdIter!= lstRuleData->end();)
		{
			RuleCondDataList lstRCond = (*RdIter)->m_lstRuleCond;
			for (RuleCondDataList::iterator RCIter = lstRCond.begin();RCIter!=lstRCond.end();)
			{
				delete (*RCIter);
				lstRCond.erase(RCIter++);
			}
			lstRCond.clear();
			delete (*RdIter)->m_pSkillServerCfg;
			delete (*RdIter);
			lstRuleData->erase(RdIter++);
		}
		lstRuleData->clear();
		delete lstRuleData;
		m_mapRuleDataByName.erase(iter++);
	}
}

void CSkillRuleServer::CreateRuleCondData(CSkillRuleData* pData,string &strBegin,string &strContiune)
{
	ParseRuleCond(pData,strBegin,eRCK_Begin);
	ParseRuleCond(pData,strContiune,eRCK_Continue);
}

void CSkillRuleServer::CreateRuleTargetType(CSkillRuleData* pData,string& strTarget)
{
	if(strTarget.empty())
	{
		ostringstream strm;
		strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">���ͷ�Ŀ��Ϊ�գ�������!"<< endl;
		cout<<strm.str()<<endl;
	}
	erase(strTarget, " ");
	erase(strTarget,"\"");
	replace(strTarget, "��", ",");
	replace(strTarget, "��", "(");
	replace(strTarget, "��", ")");
	int32 lbracketPos, rbracketPos, commaPos;
	lbracketPos = strTarget.find('(');
	commaPos = strTarget.find(',');
	rbracketPos = strTarget.find(')');
	if (-1 == lbracketPos)				//Ŀ������û�в���
	{
		pData->m_eSRTargetType = m_mapSRTargetType.mapTargetType[strTarget];
		pData->m_uTargetArg1 = 0;
		pData->m_uTargetArg2 = 0;
	}
	else								//Ŀ�������в���
	{
		string strName = strTarget.substr(0,lbracketPos);
		if (-1 == commaPos)				//ֻ��һ������
		{
			pData->m_eSRTargetType = m_mapSRTargetType.mapTargetType[strName];
			string strArg = strTarget.substr(lbracketPos+1, rbracketPos-lbracketPos-1);
			pData->m_uTargetArg1 = static_cast<uint32>(atoi(strArg.c_str()));
			pData->m_uTargetArg2 = 0;
		}
		else							//����������
		{

			pData->m_eSRTargetType = m_mapSRTargetType.mapTargetType[strName];
			string strArg1 = strTarget.substr(lbracketPos+1, commaPos-lbracketPos-1);
			string strArg2 = strTarget.substr(commaPos+1, rbracketPos-commaPos-1);
			pData->m_uTargetArg1 = static_cast<uint32>(atoi(strArg1.c_str()));
			pData->m_uTargetArg2 = static_cast<uint32>(atoi(strArg2.c_str()));
		}
	}

}

void CSkillRuleServer::CreateRuleDistance(CSkillRuleData* pData,string& strDistace)
{
	if (strDistace.empty())
	{
		ostringstream strm;
		strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">���ܾ��벻��Ϊ��!"<< endl;
		cout<<strm.str()<<endl;
	}
	erase(strDistace, " ");
	erase(strDistace,"\"");
	replace(strDistace, "��", ",");
	replace(strDistace, "��", "(");
	replace(strDistace, "��", ")");
	int32 lbracketPos,rbracketPos;
	int32 commaPos;
	lbracketPos = strDistace.find('(');
	rbracketPos = strDistace.find(')');
	commaPos = strDistace.find(',');
	if (-1 == lbracketPos || -1 == rbracketPos || -1 == commaPos)
	{
		ostringstream strm;
		strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">���ܾ����ʽ��д����!"<< endl;
		cout<<strm.str()<<endl;
	}
	string strOne = strDistace.substr(lbracketPos+1,commaPos-lbracketPos-1);
	string strTwo = strDistace.substr(commaPos+1,rbracketPos-commaPos-1);
	if (strOne.empty() || strTwo.empty())
	{
		ostringstream strm;
		strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">���ܾ���ȱ�ٲ���!"<< endl;
		cout<<strm.str()<<endl;
	}
	pData->m_uMinDistance = atoi(strOne.c_str());
	pData->m_uMaxDistance = atoi(strTwo.c_str());
}

void CSkillRuleServer::ParseRuleCond(CSkillRuleData* pData,string& strCond,ERuleCondKind eRuleKind)
{
	if(strCond.empty())
		return;
	erase(strCond, " ");
	erase(strCond,"\"");
	replace(strCond, "��", ",");
	replace(strCond, "��", "(");
	replace(strCond, "��", ")");
	int32 startPos = -1;
	string strNameTemp;
	string strArgTemp;
	string strTemp;
	while (true)
	{
		if(strCond.empty())
			return;
		startPos = strCond.find(',');
		if(-1 == startPos)
		{
			int32 lbracketPos,rbracketPos;
			lbracketPos = strCond.find('(');
			rbracketPos = strCond.find(')');
			if (-1 == lbracketPos || -1 == rbracketPos)
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">�ﴥ������������������ȱ�ٻ�ƥ��"<< endl;
				cout<<strm.str()<<endl;
			}
			strNameTemp = strCond.substr(0,lbracketPos);
			strArgTemp	= strCond.substr(lbracketPos+1,rbracketPos-lbracketPos-1);
			if(!m_mapSRTargetType.mapCondType.count(strNameTemp))
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">�Ĺ�������<"<<strNameTemp<<">������!"<<endl;;
				cout<<strm.str()<<endl;
			}
			CRuleCondData* pRuleCondData = new CRuleCondData;
			pRuleCondData->m_eRCKType = eRuleKind;
			pRuleCondData->m_eRCType	= m_mapSRTargetType.mapCondType[strNameTemp];
			ParseRuleCondArg(pRuleCondData,strArgTemp);
			pData->m_lstRuleCond.push_back(pRuleCondData);
			return;
		}
		strTemp = strCond.substr(0,startPos);
		if(strTemp.empty())
		{
			if(startPos < int32(strCond.length())-1)
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">�Ĺ�������<"<<strNameTemp<<">��ʽ���ԣ��������� ,, �����"<< endl;
				cout<<strm.str()<<endl;
			}
			else
				return;
		}
		else
		{
			int32 lbracketPos,rbracketPos;
			lbracketPos = strTemp.find('(');
			rbracketPos = strTemp.find(')');
			if (-1 == lbracketPos || -1 == rbracketPos)
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">�Ĺ�������<"<<strNameTemp<<">��������������ȱ�ٻ�ƥ��"<< endl;
				cout<<strm.str()<<endl;
			}
			strNameTemp = strTemp.substr(0,lbracketPos);
			strArgTemp	= strTemp.substr(lbracketPos+1,rbracketPos-lbracketPos-1);
			if(!m_mapSRTargetType.mapCondType.count(strNameTemp))
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">�Ĺ�������<"<<strNameTemp<<">����������!"<<endl;;
				cout<<strm.str()<<endl;
			}
			CRuleCondData* pRuleCondData = new CRuleCondData;
			pRuleCondData->m_eRCKType = eRuleKind;
			pRuleCondData->m_eRCType	= m_mapSRTargetType.mapCondType[strNameTemp];
			ParseRuleCondArg(pRuleCondData,strArgTemp);
			pData->m_lstRuleCond.push_back(pRuleCondData);
		}
		strCond = strCond.substr(startPos+1,strCond.length());
	}
}

void CSkillRuleServer::ParseRuleCondArg(CRuleCondData* pRuleCondData,string& strArgTemp)
{
	if(strArgTemp.empty())
	{
		if(eRCT_EnterBattle == pRuleCondData->m_eRCType || eRCT_EnterPhase == pRuleCondData->m_eRCType 
			|| eRCT_OnDeadCond == pRuleCondData->m_eRCType || eRCT_EnemyDead == pRuleCondData->m_eRCType)
		{
			pRuleCondData->m_fOneVal = 0;
			pRuleCondData->m_fTwoVal = 0;
		}
		else
		{
			ostringstream strm;
			strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">��������ȱ�ٲ���!"<<endl;;
			cout<<strm.str()<<endl;
		}
	}
	else
	{
		if (eRCT_RangeTimingCond == pRuleCondData->m_eRCType)
		{
			uint32 uArgPos = strArgTemp.find(',');
			if(-1 == uArgPos)
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">��Χ��ʱ������������Ӧ��Ϊ����!"<<endl;;
				cout<<strm.str()<<endl;
			}
			string strOne = strArgTemp.substr(0,uArgPos);
			string strTwo = strArgTemp.substr(uArgPos+1,strArgTemp.length());
			if (strOne.empty())
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">��Χ��ʱ����������һ������Ϊ��!"<<endl;;
				cout<<strm.str()<<endl;
			}
			if (strTwo.empty())
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">��Χ��ʱ���������ڶ�������Ϊ��!"<<endl;;
				cout<<strm.str()<<endl;
			}
			pRuleCondData->m_fOneVal = (float)(atof(strOne.c_str()));
			pRuleCondData->m_fTwoVal = (float)(atof(strTwo.c_str()));
		}
		else
		{
			pRuleCondData->m_fOneVal = (float)(atof(strArgTemp.c_str()));
			pRuleCondData->m_fTwoVal = 0;
		}
	}
}

bool CSkillRuleServer::IsHaveSkillArg(const string &strSkillName)
{
	if(strSkillName == "��ѡһ" || strSkillName == "��Χ�ص��ͷż���" || strSkillName == "����" 
		|| strSkillName == "���غ���" || strSkillName == "���������ͷ�" || strSkillName == "����Ч����"
		|| strSkillName == "���Ⱦ���" || strSkillName == "״̬�����ͷ�")
		return true;
	else
		return false;
}

void CSkillRuleServer::CreateSkillTypeName(CSkillRuleData* pData, string& strSkillRuleName)
{
	MapSRTypeNamrIter iter = m_mapSkillTypeName.find(strSkillRuleName);
	if (iter != m_mapSkillTypeName.end())
	{
		pData->m_eSRTypeName = iter->second;
	}
	else
	{	
		pData->m_eSRTypeName = eSKRT_Normal;
	}
	pData->m_strSkillName = strSkillRuleName;
}

void CSkillRuleServer::CreateMultiSkill(CSkillRuleData* pData,string &strMultiSkill)
{
	if(strMultiSkill.empty())
	{
		ostringstream strm;
		strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">Ϊ��ѡһ���ܣ�ȱ�ټ��ܲ���!"<<endl;;
		cout<<strm.str()<<endl;
	}
	erase(strMultiSkill, " ");
	erase(strMultiSkill,"\"");
	replace(strMultiSkill, "��", ",");
	replace(strMultiSkill, "��", "(");
	replace(strMultiSkill, "��", ")");
	strMultiSkill = strMultiSkill.substr(1, strMultiSkill.length()-2);
	int32 startPos = -1;
	string strTemp;
	while (true)
	{
		if(strMultiSkill.empty())
			return;
		startPos = strMultiSkill.find(',');
		if (-1 == startPos)
		{
			pData->m_lstMultiArgs.push_back(strMultiSkill);
			return;
		}
		strTemp = strMultiSkill.substr(0,startPos);
		if(strTemp.empty())
		{
			if(startPos < int32(strMultiSkill.length())-1)
			{
				ostringstream strm;
				strm<<"���ܹ���<"<<m_strTempRuleName<<">����<"<<m_strTempSkillName<<">�ļ��ܲ�����ʽ���ԣ��������� ,, �����"<< endl;
				cout<<strm.str()<<endl;
			}
			else
				return;
		}
		pData->m_lstMultiArgs.push_back(strTemp);
		strMultiSkill = strMultiSkill.substr(startPos+1,strMultiSkill.length());
	}
}

void CSkillRuleServer::CreateRuleDataSkillCfg(CSkillRuleData* pData)
{
	if ( pData->m_eSRTypeName == eSKRT_Normal )
	{
		pData->m_pSkillServerCfg = new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill(pData->m_strSkillName));
	}
	else if (pData->m_eSRTypeName == eSKRT_DoSceneSkill || pData->m_eSRTypeName == eSKRT_DoSkillOnStateCond)
	{
		SkillNameLst::const_iterator itr_skill = pData->m_lstMultiArgs.end();
		pData->m_pSkillServerCfg = new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill(*(--itr_skill)));
	}
	else
	{
		pData->m_pSkillServerCfg = NULL;
	}
}


bool CSkillRuleServer::IsHaveSkillRule(const string &strNpcName)
{
	if(m_mapRuleDataByName.count(strNpcName))
		return true;
	else
		return false;
}

template<class MapType, class EnumType>
void CSkillRuleServer::CreateMap(MapType& mapEnum, uint32 uCount, ...)
{
	va_list argList;
	va_start(argList, uCount);
	for(uint32 i = 0; i < uCount; i++)
	{
		mapEnum[va_arg(argList, TCHAR*)] = (EnumType) i;
	}
	va_end(argList);
}
