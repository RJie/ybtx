#include "stdafx.h"
#include "CAniKeyFrameCfg.h"
#include "LoadSkillCommon.h"
#include "CCfgColChecker.inl"
#include "CIniFile.h"
#include "NpcInfoMgr.h"
#include "CNpcFightBaseData.h"
#include "BaseHelper.h"
#include "DebugHelper.h"
#include "TimeHelper.h"

bool CAniKeyFrameCfg::CheckNpcMapAniKeyFrameCfg()
{
	uint64 uBeginTime = GetProcessTime();
	map<string, string> mAniLostMap; //map<��������������Ϣ>

	MapAniKeyFrameCfg::iterator iter = ms_mapAniKeyFrameCfg.begin();
	for (; iter != ms_mapAniKeyFrameCfg.end(); iter++)
	{
		string sName = (*iter).first;
		const CNpcFightBaseData* pFighterData = CNpcFightBaseDataMgr::GetInst()->GetEntity(sName);
		if (!pFighterData || pFighterData->m_fAttackScope >= 3.0f)		//�����������3������Զ�̵ģ�����ֻ�����̹���
			continue;
		MapNpcName2AniFileName::iterator iter2 = m_mapNpcName2AniFileName.find(sName);	//Ŀǰֻ���Npc��
		if (iter2 != m_mapNpcName2AniFileName.end() && NpcInfoMgr::BeFightNpc(sName.c_str()))
		{
			string sAniName = (*iter2).second;
			CIniFile* pIniFile = (*iter).second;
			string sAniLostInfo = "";
			if (pIniFile->GetValue("attack01", "k", 0) == 0)
			{
				sAniLostInfo = "ȱ�ٹ����ؼ�֡��Ϣ��";
			}
			if (pIniFile->GetValue("attack01", "e", 0) == 0)
			{
				sAniLostInfo = sAniLostInfo + "ȱ�ٹ���ȫ֡��Ϣ��";
			}
			map<string, string>::iterator iter3 = mAniLostMap.find(sAniName);
			if (sAniLostInfo != "" && iter3 == mAniLostMap.end() )
			{
				mAniLostMap[sAniName] = sAniLostInfo;
			}
		}
	}

	//���������Ϣ�������Ĵ���log����ȥ
	map<string, string>::iterator iter3 = mAniLostMap.begin();
	//cout<<"�ܹ��У���"<<mAniLostMap.size()<<"��������"<<endl;
	for (; iter3 != mAniLostMap.end(); iter3++)
	{
		string sErrorInfo = "keyframeinfo: ��" + (*iter3).first + "�� " + (*iter3).second;
		//ArtErr(sErrorInfo.c_str());
	}
	uint64 uEndTime = GetProcessTime();
	cout << "�������Npcģ�ͱߺ������ؽ�֡��Ϣ��ϣ���ʱ��" << (uEndTime - uBeginTime) << "  ���룡\n";
	return true;
}

