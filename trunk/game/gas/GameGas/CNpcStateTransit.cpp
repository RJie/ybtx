#include "stdafx.h"
#include "CNpcStateTransit.h"
#include "CNpcStateMetaData.h"
#include "CNpcEventMetaData.h"
#include "ErrLogHelper.h"
#include "PkgStream.h"
#include "CXmlConfig.inl"

CNpcStateTransit::CNpcStateTransit(uint32 uID, const string& strName)
	: CNpcStateMachine::TransitTableType((uint32)-1, NULL)
	, m_uID(uID)
	, m_strName(strName)
{
}

CNpcStateTransit::~CNpcStateTransit()
{
	DeleteAll();
}

bool CNpcStateTransitMgr::LoadConfig(const string& sFileName)
{
	ipkgstream file(L"", sFileName.c_str(), ios::binary);
	if( !file)
	{
		ostringstream strm;
		strm<<"Can't open file \""<<sFileName<<"\"";
		GenErr(strm.str());
	}

	CXmlConfig *pNpcAIServerCfg = new CXmlConfig( "root" , file );
	file.close();

	TiXmlNode *pRoot = pNpcAIServerCfg->GetRootNode();

	map<string, CNpcStateTransit*> mapSubMachine;
	for (TiXmlNode* pChild = pRoot->FirstChild(); pChild; pChild=pChild->NextSibling())
	{
		TiXmlElement* pElemet = pChild->ToElement();
		if (!pElemet || pElemet->ValueStr() != "SubMachine")
			continue;

		const string& sName = pElemet->Attribute("Name");
		if (CNpcStateMetaDataMgr::GetInst()->GetEntity(sName) != NULL)
		{
			std::ostringstream oss;
			oss << "Npc״̬��" << sName << "�Ѵ��ڣ�����ע��ͬ������״̬��";
			GenErr(oss.str());
		}

		CNpcStateTransit* pTransitTable = new CNpcStateTransit(GetSize(), sName); 
		CNpcSubMachineCreator* pCreator = new CNpcSubMachineCreator(pTransitTable);
		CNpcStateMetaData* pMetaData = new CNpcStateMetaData(CNpcStateMetaDataMgr::GetInst()->GetSize(), sName, pCreator);
		if (!CNpcStateMetaDataMgr::GetInst()->AddEntity(pMetaData))
		{
			std::ostringstream oss;
			oss << "״̬��" << sName << "�Ѵ��ڣ�����ע��ͬ������״̬��";
			GenErr(oss.str());
		}

		if (mapSubMachine[sName] != NULL)
		{
			std::ostringstream oss;
			oss << "Npc��״̬����" << sName << "�Ѵ��ڣ�����ע��ͬ������״̬��";
			GenErr(oss.str());
		}

		mapSubMachine[sName] = pTransitTable;
	}

	//��֯��ת��
	for (TiXmlNode* pChild = pRoot->FirstChild(); pChild; pChild=pChild->NextSibling())
	{
		TiXmlElement* pElement = pChild->ToElement();
		if (!pElement || !(pElement->ValueStr() == "AI" || pElement->ValueStr() == "SubMachine"))
		{
			std::ostringstream oss;
			oss << "����Ľ��:" << pElement->ValueStr() << endl;
			GenErr(oss.str());
		}

		if (!(pChild->FirstChild()->ToElement()->ValueStr() == "Item"))
		{
			std::ostringstream oss;
			oss << "����Ľ��:" << pChild->FirstChild()->ToElement()->ValueStr() << endl;
			GenErr(oss.str());
		}

		const string& sTransitName = pElement->Attribute("Name");
		CNpcStateTransit* pTransitTable = NULL;

		if (pElement->ValueStr() == "AI")
		{
			pTransitTable = new CNpcStateTransit(GetSize(), sTransitName); 
		}		
		else if(pElement->ValueStr() == "SubMachine")
		{
			pTransitTable = mapSubMachine[sTransitName];
			pTransitTable->SetID(GetSize());
		}
		else
		{
			std::ostringstream oss;
			oss<<" ����Ľڵ㣺"<<pElement->ValueStr()<<endl;
			GenErr(oss.str());
		}

		if (!CNpcStateTransitMgr::GetInst()->AddEntity(pTransitTable))
		{
			std::ostringstream oss;
			oss << "NameΪ" << sTransitName << "��AI�����Ѵ���" ;
			GenErr(oss.str());
		}

		//����һ��״̬���óɳ�ʼ��״̬
		const string& strEntryName = pChild->FirstChild()->ToElement()->Attribute("Current");
		CNpcStateMetaData *pStateMetaData = CNpcStateMetaDataMgr::GetInst()->GetEntity(strEntryName);
		if (pStateMetaData == NULL)
		{
			std::ostringstream oss;
			oss << "Npc״̬��" << strEntryName << "�����ڣ�����״̬ע�ắ����NpcAI���ñ�";
			GenErr(oss.str());
		}

		pTransitTable->SetEntryCreator(pStateMetaData->GetID(), pStateMetaData->GetCreator());

		for (TiXmlNode* pSubChild = pChild->FirstChild(); pSubChild; pSubChild=pSubChild->NextSibling())
		{
			TiXmlElement* pSubElement = pSubChild->ToElement();
			if (!pSubElement)
				continue;
			Ast(pSubElement->ValueStr() == "Item");
			const string& strCurrentName = pSubElement->Attribute("Current");
			if (CNpcStateMetaDataMgr::GetInst()->GetEntity(strCurrentName) == NULL)
			{
				std::ostringstream oss;
				oss << "NameΪ" << strCurrentName << "��״̬������" ;
				GenErr(oss.str());
			}
			uint32 uItemID = CNpcStateMetaDataMgr::GetInst()->GetEntity(strCurrentName)->GetID();
			CNpcStateTransit::ItemType* pItem = pTransitTable->GetEntity(uItemID);
			if (pItem == NULL)
			{
				pItem = new CNpcStateTransit::ItemType(uItemID);
				pTransitTable->AddEntity(pItem);
			}
			for (TiXmlNode* pSubSubChild = pSubChild->FirstChild(); pSubSubChild; pSubSubChild=pSubSubChild->NextSibling())
			{
				TiXmlElement* pSubSubElement = pSubSubChild->ToElement();
				if (!pSubSubElement)
					continue;
				Ast(pSubSubElement->ValueStr() == "Transit");
				const string& strEventName = pSubSubElement->Attribute("Event");
				const string& strNextName = pSubSubElement->Attribute("Next");
				CNpcEventMetaData *pEventMetaData = CNpcEventMetaDataMgr::GetInst()->GetEntity(strEventName);
				CNpcStateMetaData *pNextMetaData = CNpcStateMetaDataMgr::GetInst()->GetEntity(strNextName);
				if (pEventMetaData == NULL)
				{
					std::ostringstream oss;
					oss << "Npc�¼���" << strEventName << "�����ڣ������¼�ע�ắ����NpcAI���ñ�";
					GenErr(oss.str());
				}
				if (pNextMetaData == NULL)
				{
					std::ostringstream oss;
					oss << "Npc״̬��" << strNextName << "�����ڣ�����״̬ע�ắ����NpcAI���ñ�";
					GenErr(oss.str());
				}
				if (!pItem->AddTransit(pEventMetaData->GetID(), pNextMetaData->GetID(), pNextMetaData->GetCreator()))
				{
					std::ostringstream oss;
					oss << "NameΪ" << pElement->Attribute("Name") << "��״̬" << strCurrentName << "����Ӧ���¼�" << strEventName << "�Ѵ���";
					GenErr(oss.str());
				}
			}
		}
		try
		{
			pTransitTable->CheckValid();
		}
		catch(uint32& uStateID)
		{
			std::ostringstream oss;
			oss << "��AI���� " << pElement->Attribute("Name") << " ��NameΪ " << CNpcStateMetaDataMgr::GetInst()->GetEntity(uStateID)->GetName() << " ��״̬û����Ӧ��������";
			LogErr(oss.str().c_str());
			GenErr(oss.str());
		}
	}
	delete pNpcAIServerCfg;
	pNpcAIServerCfg = NULL;

	return true;
}

void CNpcStateTransitMgr::UnloadConfig()
{
	DeleteAll();
}

