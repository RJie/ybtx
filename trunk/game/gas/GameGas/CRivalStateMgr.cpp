#include "stdafx.h"
#include "CRivalStateMgr.h"
#include "TSqrAllocator.inl"
#include "BaseHelper.h"
#include "MagicOps_Function.h"
#include "CMagicOpCfgArg.h"
#include "CMagicStateCfg.h"
#include "CSkillInstServer.h"

void CRivalStateCategory::AddState(uint32 uLevel, CStateFuncArg& aStateFuncArg)
{
	if(m_mapRivalLevel.empty())
	{
		aStateFuncArg.m_pSkillInst->AddRef();
		m_mapRivalLevel.insert(make_pair(uLevel, make_pair(1, aStateFuncArg.m_pSkillInst)));
		//Setup New;
		SetupState(aStateFuncArg.m_pSkillInst, aStateFuncArg);
		return;
	}
	uint32 uMaxLevel = m_mapRivalLevel.begin()->first;
	MapRivalLevel::iterator itr = m_mapRivalLevel.find(uLevel);
	if(itr == m_mapRivalLevel.end())
	{
		aStateFuncArg.m_pSkillInst->AddRef();
		m_mapRivalLevel.insert(make_pair(uLevel, make_pair(1, aStateFuncArg.m_pSkillInst)));
	}
	else
	{
		//�����Ҫ����ͬ�ȼ���ͬ�˵��滻��������Ҫ����pSkillInst->AddRef()
		++itr->second.first;
	}

	if(uLevel > uMaxLevel)
	{
		//Cancel Max
		CancelState(m_mapRivalLevel.begin()->second.second, aStateFuncArg);
		//Setup Level
		SetupState(aStateFuncArg.m_pSkillInst, aStateFuncArg);
	}
	else if(uLevel == uMaxLevel)
	{
		//�����Ҫ����ͬ�ȼ���ͬ�˵��滻��������Ҫ�������ϵ�Cancel Setup�߼�
	}
}

bool CRivalStateCategory::DelState(uint32 uLevel, CStateFuncArg& aStateFuncArg)
{
	MapRivalLevel::iterator itr = m_mapRivalLevel.find(uLevel);
	if(itr == m_mapRivalLevel.end())
	{
		//stringstream str;
		//str << uLevel;
		//LogErr("���ȼ��������ھ���״̬��������", str.str());
		return false;
	}

	if(itr->second.first > 1)
	{
		//�����Ҫ����ͬ�ȼ���ͬ�˵��滻��������Ҫ���ж�uLevel == uMaxLevel�����pSkillInst->DelRef()��Cancel�߼�
		--itr->second.first;
	}
	else
	{
		CSkillInstServer* pSkillInst = itr->second.second;
		m_mapRivalLevel.erase(itr);
		if(m_mapRivalLevel.empty())
		{
			//Cancel Level
			CancelState(pSkillInst, aStateFuncArg);
			pSkillInst->DelRef();
			return true;
		}
		uint32 uMaxLevel = m_mapRivalLevel.begin()->first;
		if(uLevel > uMaxLevel)
		{
			//Cancel Level
			CancelState(pSkillInst, aStateFuncArg);
			pSkillInst->DelRef();
			//Setup Max
			SetupState(m_mapRivalLevel.begin()->second.second, aStateFuncArg);
		}
		else if(uLevel == uMaxLevel)
		{
			//���ﲻ�������ΪuLevel�Ľ���Ѿ�ɾ�ˣ�ʣ�µ�uMaxLevelһ����С��uLevel��
			//�����Ҫ����ͬ�ȼ���ͬ�˵��滻��������Ҫ�������ϵ�Cancel Setup�߼�
		}
	}
	return false;
}

CRivalStateCategory::~CRivalStateCategory()
{
	Clear();
}

void CRivalStateCategory::Clear()
{
	for(MapRivalLevel::iterator itr = m_mapRivalLevel.begin(); itr != m_mapRivalLevel.end(); ++itr)
	{
		itr->second.second->DelRef();
	}
	m_mapRivalLevel.clear();
}

void CRivalStateCategory::SetupState(CSkillInstServer* pSkillInst, CStateFuncArg& aStateFuncArg)
{
	CSetupMagicStateMOP aMop;
	aMop.Do(pSkillInst, aStateFuncArg.m_pArg, aStateFuncArg.m_pFrom, aStateFuncArg.m_pTo);
}

void CRivalStateCategory::CancelState(CSkillInstServer* pSkillInst, CStateFuncArg& aStateFuncArg)
{
	CSetupMagicStateMOP aMop;
	aMop.Cancel(pSkillInst, aStateFuncArg.m_pArg, aStateFuncArg.m_pFrom, aStateFuncArg.m_pTo);
}






void CRivalStateMgr::AddState(const string& name, CStateFuncArg& aStateFuncArg)
{
	uint32 uLevel = aStateFuncArg.m_pSkillInst->GetSkillLevel();
	MapRivalCategory::iterator itr = m_mapRivalCategory.find(name);
	if(itr == m_mapRivalCategory.end())
	{
		CRivalStateCategory* pRivalStateCategory = new CRivalStateCategory;
		m_mapRivalCategory.insert(make_pair(name, pRivalStateCategory));
		pRivalStateCategory->AddState(uLevel, aStateFuncArg);
	}
	else
	{
		itr->second->AddState(uLevel, aStateFuncArg);	
	}
}

void CRivalStateMgr::DelState(const string& name, CStateFuncArg& aStateFuncArg)
{
	uint32 uLevel = aStateFuncArg.m_pSkillInst->GetSkillLevel();
	MapRivalCategory::iterator itr = m_mapRivalCategory.find(name);
	if(itr == m_mapRivalCategory.end())
	{
		//stringstream str;
		//str << "[" << sName << "], " << uLevel;
		//LogErr("���ȼ��������ھ���״̬��������", str.str());
		return;
	}
	bool bRet = itr->second->DelState(uLevel, aStateFuncArg);
	if(bRet)
	{
		MapRivalCategory::iterator itr2 = m_mapRivalCategory.find(name);
		if(itr2 == m_mapRivalCategory.end())
			EraseMapNode(m_mapRivalCategory, itr);
	}
}

void CRivalStateMgr::ClearAll()
{
	ClearMap(m_mapRivalCategory);
}

CRivalStateMgr::~CRivalStateMgr()
{
	ClearAll();
}

