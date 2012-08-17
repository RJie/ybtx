#include "stdafx.h"
#include "CNpcResServerData.h"
#include "CAniKeyFrameCfg.h"

CNpcResServerDataMgr::CNpcResServerDataMgr()
{
}

CNpcResServerDataMgr::~CNpcResServerDataMgr()
{
	DeleteAll();
}

CNpcResServerData::CNpcResServerData(const string& sNpcName, uint32 uID)
:m_sNpcName(sNpcName)
,m_uID(uID)
{
}

CNpcResServerData::~CNpcResServerData()
{
}

CNpcResServerData* CNpcResServerData::Create(const TCHAR* sNpcName, float fBaseSize, float fBottomSize, bool bAdhereTerrain, const TCHAR* sAniFileName)
{
	if (sNpcName == NULL)
	{
		ostringstream strm;
		strm<<"��NpcRes_Common�����С�NpcName�����Ϊ�գ����ʵ��";
		GenErr(strm.str());
	}

	if (fBaseSize <= 0)
	{
		ostringstream strm;
		strm<<"����Ϊ����"<< sNpcName<<"����Npc�ڡ�NpcRes_Common�����С�Scaling����BaseSize��������붼����0�����ʵ��";
		GenErr(strm.str());
	}

	CNpcResServerData* pData = new CNpcResServerData(sNpcName, CNpcResServerDataMgr::GetInst()->GetSize());
	if (!CNpcResServerDataMgr::GetInst()->AddEntity(pData))
	{
		ostringstream strm;
		strm<< "�ڱ�NpcRes_Common���нС�" << sNpcName <<"����Npc�ظ������ʵ��" ;
		GenErr(strm.str());
	}
	pData->m_fBaseSize = fBaseSize;
	pData->m_fBottomSize = fBottomSize;
	pData->m_bAdhereTerrain = bAdhereTerrain;
	CAniKeyFrameCfg::SetNpcName2AinMap(sNpcName, sAniFileName);		//����Npc���ƶ�Ӧ�Ķ�������
	return pData;
}


