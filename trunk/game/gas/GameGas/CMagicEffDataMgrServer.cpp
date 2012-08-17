#include "stdafx.h"
#include "CMagicEffDataMgrServer.h"
#include "BaseHelper.h"
#include "ExpHelper.h"
#include "TSqrAllocator.inl"
#include "ErrLogHelper.h"

CEffDataByGlobalIDMgr::~CEffDataByGlobalIDMgr()
{
	Clear();
}

CMagicEffDataMgrServer* CEffDataByGlobalIDMgr::AddEffData(uint32 uGlobalID, CFighterDictator* pFrom)
{
	CMagicEffDataMgrServer *pCancelEffData = new CMagicEffDataMgrServer(pFrom);
	pair<MapEffDataMgrServer::iterator, bool> pr = m_pMapEffData.insert(make_pair(uGlobalID, pCancelEffData));
	if(!pr.second)
	{
		//stringstream str;
		//str << "uGlobalID = " << uGlobalID << ", pFrom = " << pFrom << ", ��EffData��";
		//CMagicEffDataMgrServer* pEffData = pr.first->second;
		//for(uint32 i = 1; i <= pEffData->GetArrayLen() ; ++i)
		//{
		//	CMagicOpStoredObj aStoredObj = pEffData->GetArrayMopData(i); 
		//	str << "([" << aStoredObj.m_MOPArg.GetInt32() << "|" << aStoredObj.m_MOPArg.GetFloat() << "|"
		//		<< aStoredObj.m_MOPArg.GetUInt32() << "]" << "," << aStoredObj.m_uMOPRet << ","
		//		<< aStoredObj.m_bValid << "), ";
		//}
		delete(pCancelEffData);
		pCancelEffData = NULL;
		//LogErr("CEffDataByGlobalIDMgr::AddEffData���в����ֵ", str.str());
	}
	return pCancelEffData;
}

CMagicEffDataMgrServer* CEffDataByGlobalIDMgr::GetEffData(uint32 uGlobalID)
{
	MapEffDataMgrServer::iterator itr = m_pMapEffData.find(uGlobalID);
	if(itr != m_pMapEffData.end())
	{
		return itr->second;
	}
	else
	{
		return NULL;
	}
}

uint32 CMagicEffDataMgrServer::GetFromID()
{
	return m_uFromID;
}

void CMagicEffDataMgrServer::SetFromID(uint32 uFromID)
{
	m_uFromID = uFromID;
}





void CEffDataByGlobalIDMgr::DelEffData(uint32 uGlobalID)
{
	MapEffDataMgrServer::iterator itr = m_pMapEffData.find(uGlobalID);
	if(itr != m_pMapEffData.end())
	{
		EraseMapNode(m_pMapEffData, itr);
	}
	//Ϊ���⳷��ʱpTo�����ڵ���δ����Cancel����������������������Ҫ����һ������������⵼���ڴ�й¶���������ﲻ�ܼ�log
	//else
	//{
	//	stringstream str;
	//	str << "uGlobalID = " << uGlobalID;
	//	LogErr("CEffDataByGlobalIDMgr::DelEffData��uGlobalID��������map��", str.str());
	//}
}

void CEffDataByGlobalIDMgr::Clear()
{
	ClearMap(m_pMapEffData);
	DelSelfEffData();
}

CMagicEffDataMgrServer* CEffDataByGlobalIDMgr::AddSelfEffData(CFighterDictator* pFrom)
{
	Ast(m_pSelfEffData);
	m_pSelfEffData = new CMagicEffDataMgrServer(pFrom);
	return m_pSelfEffData;
}

CMagicEffDataMgrServer* CEffDataByGlobalIDMgr::GetSelfEffData()
{
	return m_pSelfEffData;	
}

void CEffDataByGlobalIDMgr::DelSelfEffData()
{
	if(m_pSelfEffData)
	{
		delete m_pSelfEffData;
		m_pSelfEffData = NULL;
	}
}




