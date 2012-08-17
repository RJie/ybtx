#include "stdafx.h"
#include "CNpcServerBaseData.h"
#include "CNpcStateTransit.h"
#include "CNpcFightBaseData.h"
#include "CNpcAIBaseData.h"
#include "NpcInfoDefs.h"
#include "CNpcResServerData.h"
#include "CNpcEnmityTargetFilterData.h"

CNpcServerBaseData* CNpcServerBaseData::Create(const TCHAR* szName, const TCHAR* szNpcType, const TCHAR* szAIType, const TCHAR* szAIData
											   , uint32 uCamp, uint32 uClass, uint32 uSex, uint32 uLevel)
{
	bool bSuccess = true;
	if (szNpcType == NULL)
	{
		bSuccess = false;
		cout << "Npc����Ϊ��\n";
	}

	if (szName == NULL)
	{
		bSuccess = false;
		cout << "Npc��Ϊ��\n";
	}

	if (szAIType == NULL)
	{
		bSuccess = false;
		cout << "Npc " << szName << " AI����Ϊ��\n";
	}

	if (szAIData == NULL)
	{
		bSuccess = false;
		cout << "Npc " << szName << " AI����Ϊ��\n";
	}

	CNpcServerBaseData* pData = new CNpcServerBaseData(CNpcServerBaseDataMgr::GetInst()->GetSize(), szName);

	if (!CNpcServerBaseDataMgr::GetInst()->AddEntity(pData))
	{
		bSuccess = false;
		cout << "Npc�ܱ��� " << szName << " �ظ���\n";
	}

	pData->m_pFightBaseData = CNpcFightBaseDataMgr::GetInst()->GetEntity( pData->GetName() );

	if (pData->m_pFightBaseData == NULL)
	{
		bSuccess = false;
		cout << "Npc " << szName <<" ս����Ϣ�����ڣ�\n";
	}

	pData->m_pStateTransitOne = CNpcStateTransitMgr::GetInst()->GetEntity( szAIType );
	if (pData->m_pStateTransitOne == NULL)
	{
		bSuccess = false;
		cout << "Npc " << szName << "  AI���ͣ� " << szAIType << " �����ڣ�\n";
	}

	pData->m_pAIBaseDataOne = CNpcAIBaseDataMgr::GetInst()->GetEntity( szAIData );
	if (pData->m_pAIBaseDataOne == NULL)
	{
		bSuccess = false;
		cout << "Npc " << szName << " AI���� " << szAIData << " �����ڣ�\n";
	}

	pData->m_pResBaseData = CNpcResServerDataMgr::GetInst()->GetEntity( pData->GetName());
	if (pData->m_pResBaseData == NULL)
	{
		bSuccess = false;
		cout << "Npc  " << szName << "�ڡ�NpcRes_Common�����в����ڣ����ʵ��\n";
	}

	//���ָ�������Ϊ�յ�
	pData->m_pEnmityTargetFilter = CNpcEnmityTargetFilterDataMgr::GetInst()->GetEntity(pData->GetName());

	//����Npc����
	TypeMapRgst::mapNpcType_itr iter1 = NpcType.mapNpcTypeMap.find(szNpcType);
	if (iter1 == NpcType.mapNpcTypeMap.end())
	{
		bSuccess = false;
		cout << "Npc " << szName << "  Type�� " << szNpcType << " ��δע��\n";
	}
	pData->m_eType = NpcType.mapNpcTypeMap[szNpcType];

	//����Aoi����
	AITypeAoiRgst::mapObjectAoi_itr iter2 = sObjectAoiType.mapObjectAoiType.find(szAIType);
	if (iter2 == sObjectAoiType.mapObjectAoiType.end())
	{
		bSuccess = false;
		cout << "Npc " << szName << "  AIType�� " << szAIType << " ��δע��AOI���ͣ�\n";
	}
	pData->m_eAoiType = sObjectAoiType.mapObjectAoiType[szAIType];

	//����AIType����
	AITypeMap::mapNpcAIType_itr iter3 = sNpcAIType.mapNpcAIType.find( szAIType);
	if (iter3 == sNpcAIType.mapNpcAIType.end())
	{
		bSuccess = false;
		cout << "Npc " << szName << "  AIType��" << szAIType << " ��δע��AI���ͣ�\n";
	}
	pData->m_eAIType = sNpcAIType.mapNpcAIType[szAIType];

	pData->m_uCamp = uCamp;
	pData->m_uClass = uClass;
	pData->m_uSex = uSex;
	pData->m_uLevel = uLevel;

	if (!bSuccess)
	{
		delete pData;
		string str1;
		str1 = "����Npc�Ļ�����Ϣʧ�ܣ�";
		GenErr(str1, szName);
	}
	return pData;
}

void CNpcServerBaseData::SetCanBeChangeAI(bool bCanChangeAI)
{
	m_bCanBeChangeAI = bCanChangeAI;
}

void CNpcServerBaseData::SetBeSleep(bool bSleep)
{
	m_bSleep = bSleep;
}

void CNpcServerBaseData::SetBeSynToClient(bool bSynToClient)
{
	m_bSynToClient = bSynToClient;
}
void CNpcServerBaseData::SetCanBeSelected(bool bCanBeSelected)
{
	m_bCanBeSelected = bCanBeSelected;
}
void CNpcServerBaseData::SetCanBeRavin(bool bCanBeRavin)
{
	m_bCanBeRavin = bCanBeRavin;
}

CNpcServerBaseData::CNpcServerBaseData(uint32 uID, const string& sName)
: m_uID( uID )
, m_sName( sName )
{
}

CNpcServerBaseDataMgr::CNpcServerBaseDataMgr()
{

}

CNpcServerBaseDataMgr::~CNpcServerBaseDataMgr()
{
	DeleteAll();
}

