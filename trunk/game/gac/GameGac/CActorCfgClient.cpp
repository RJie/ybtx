#include "stdafx.h"
#include "CActorCfgClient.h"
#include "CTxtTableFile.h"
#include "LoadSkillCommon.h"
#include "CActorCfg.h"
#include "ExpHelper.h"
#include "BaseHelper.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

CActorCfgClient::MapActorPlayMode			CActorCfgClient::ms_mapActorPlayMode;
CActorCfgClient::MapActorPlayPriority		CActorCfgClient::ms_mapActorPlayPriority;
CActorCfgClient::MapActorActorCfgByState	CActorCfgClient::ms_mapActorAniCfgByState;

bool CActorCfgClient::LoadConfig(const string& szFileName)
{
	stringstream ExpStr;

	CTxtTableFile TabFile;
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), szFileName.c_str())) 
		return false;

	CActorCfg::BuildMapString2Enum();

	BuildActorPlayMode();
	BuildActionPlayPriority();

	ClearMap(ms_mapActorAniCfgByState);

	for( int i = 1; i < TabFile.GetHeight(); ++i )
	{
		CActorCfgClient* pActorAniCfg		= new CActorCfgClient;
		pActorAniCfg->m_strActorName		= TabFile.GetString(i, szActor_Name);
		pActorAniCfg->m_eActionState		= CActorCfg::GetEnumByString(pActorAniCfg->m_strActorName.c_str());
		pActorAniCfg->m_ePriorityLevel		= ms_mapActorPlayPriority[TabFile.GetString(i, szActor_PriorityLevel)];
		pActorAniCfg->m_eActorPlayMode		= ms_mapActorPlayMode[TabFile.GetString(i, szActor_PlayMode)];
		pActorAniCfg->m_strPlayerAniName	= TabFile.GetString(i, szActor_PlayerAniName);
		pActorAniCfg->m_strNPCAniName		= TabFile.GetString(i, szActor_NPCAniName);
		pActorAniCfg->m_eNPCReplaceState	= CActorCfg::GetEnumByString(TabFile.GetString(i, szActor_NPCReplace));
		pActorAniCfg->m_bFxFollowAni		= strcmp(TabFile.GetString(i, szActor_FxFollowAni), "��") == 0 ? true : false;
		pActorAniCfg->m_strFxPartPath		= TabFile.GetString(i, szActor_FxPartPath);

		pair<MapActorActorCfgByState::iterator, bool> prByState = ms_mapActorAniCfgByState.insert(make_pair(pActorAniCfg->m_eActionState, pActorAniCfg));
		if(!prByState.second)
		{
			ExpStr << "��" << i << "�еĶ��� " << pActorAniCfg->m_strActorName << " ����";
			GenErr(ExpStr.str());
		}
	}
	return true;
}

void CActorCfgClient::UnloadConfig()
{
	ClearMap(ms_mapActorAniCfgByState);
}

CActorCfgClient* CActorCfgClient::GetActorCfgByActionState(EActionState eActionState)
{
	stringstream ExpStr;
	MapActorActorCfgByState::iterator itActorCfg;
	itActorCfg = ms_mapActorAniCfgByState.find(eActionState);

	if (itActorCfg == ms_mapActorAniCfgByState.end())
	{
		ExpStr << "����״̬" << eActionState << "������";
		GenErr(ExpStr.str());
	}

	return itActorCfg->second;
}

void CActorCfgClient::ChangeAniName(EActionState eActionState, string strAniName)
{
	CActorCfgClient* pAniCfg = CActorCfgClient::GetActorCfgByActionState(eActionState);
	pAniCfg->m_strPlayerAniName = strAniName;
	pAniCfg->m_strNPCAniName = strAniName;
}

void CActorCfgClient::BuildActionPlayPriority()
{
	ms_mapActorPlayPriority["��������"]	=	eAPP_DeathAction;
	ms_mapActorPlayPriority["ǿ�ƶ���"]	=	eAPP_CoerceAction;
	ms_mapActorPlayPriority["���ܶ���"]	=	eAPP_SkillAction;
	ms_mapActorPlayPriority["��������"]	=	eAPP_AttackAction;
	ms_mapActorPlayPriority["��������"]	=	eAPP_SufferAction;
	ms_mapActorPlayPriority["�ƶ�����"]	=	eAPP_MoveStopAction;
	ms_mapActorPlayPriority["�л�����"]	=	eAPP_SwitchAction;
	ms_mapActorPlayPriority["���⶯��"]	=	eAPP_SpecialAction;
}

void CActorCfgClient::BuildActorPlayMode()
{
	ms_mapActorPlayMode["ȫ��ѭ��"]		=	eAPM_AllBodyLoop;
	ms_mapActorPlayMode["ȫ��һ��"]		=	eAPM_AllBodyOnce;
	ms_mapActorPlayMode["����һ��"]		=	eAPM_UpBodyOnce;
}
