#include "stdafx.h"
#include "NpcInfoMgr.h"
#include "NpcInfoDefs.h"
#include "CNpcServerBaseData.h"
#include "ExpHelper.h"
#include "CCharacterDictator.h"
#include "ServantType.h"

bool NpcInfoMgr::BeFightNpc(const TCHAR* szNpcName)
{
	const CNpcServerBaseData* pData = CNpcServerBaseDataMgr::GetInst()->GetEntity(szNpcName);
	if (NULL == pData)
	{
		const string& sName = szNpcName;
		const string& sErrorInfo = "Npc: ��" + sName + "����Npc_Common.dif�����Ѿ������ڣ�������NpcRes_Common.dif���л����ڣ���߻���ʱ�����";
		//	CfgErr(sErrorInfo.c_str());
		cout<<sErrorInfo<<endl;
		return true;
	}
	ENpcAIType eAIType = pData->m_eAIType;
	switch(eAIType)
	{
	case ENpcAIType_NormalPassivityPatrol:						//��ͨ�ֱ���֧��Ѳ��
	case ENpcAIType_NormalInitiativePatrolNoFefer:				//��ͨ������֧��Ѳ��
	case ENpcAIType_NormalInitiativePatrolNoFeferCanSeeNpc:		//��ͨ������֧��Ѳ�߿ɼ�Npc
	case ENpcAIType_Servant:									//�ٻ���
	case ENpcAIType_GroupMemberPassivity:						//Ⱥ���Ա������
	case ENpcAIType_GroupMemberInitiative:						//Ⱥ���Ա������
	case ENpcAIType_TowerAttack:								//����AI
	case ENpcAIType_BattleHorse:								//ս������
	case ENpcAIType_OrdnanceMonster:							//��е��
	case ENpcAIType_MagicBuilding:								//ħ����
	case ENpcAIType_Cannon:										//�ƶ���̨
	case ENpcAIType_MonsterCard:								//���￨
	case ENpcAIType_BossCortege:								//BossС��
	case ENpcAIType_BossActive:									//Boss����֧��Ѳ��
	case ENpcAIType_BossPassivity:								//Boss����֧��Ѳ��
		return true;
	default:
		return false;
	}
	return false;
}


bool NpcInfoMgr::BeActiveNpc(ENpcAIType eNpcAIType)
{
	switch(eNpcAIType)
	{
	case ENpcAIType_NormalInitiativePatrolNoFefer:
	case ENpcAIType_NormalInitiativePatrolNoFeferCanSeeNpc: 
	case ENpcAIType_MagicBuilding:
	case ENpcAIType_MonsterCard:
	case ENpcAIType_GroupMemberInitiative:
	case ENpcAIType_BossActive:
		return true;
	default:
		return false;
	}
}

const TCHAR* NpcInfoMgr::GetAINameByAIType(ENpcAIType eAIType)
{
	return sNpcAINameByNpcAIType.mapNpcAINameByNpcAIType[eAIType].c_str();
}

ENpcAIType NpcInfoMgr::GetAITypeByAIName(const TCHAR* szAIName)
{
	return sNpcAIType.mapNpcAIType[szAIName];
}

const TCHAR* NpcInfoMgr::GetTypeNameByType(ENpcType eNpcType)
{
	return sNpcTypeMapName.mNpcTypeMapName[eNpcType].c_str();
}

ENpcType NpcInfoMgr::GetTypeByTypeName(const TCHAR* szTypeName)
{
	return NpcType.mapNpcTypeMap[szTypeName];
}

bool NpcInfoMgr::CanTakeOnlyOne(ENpcType eNpcType)
{
	switch(eNpcType)
	{
	case ENpcType_Pet:					//����
	case ENpcType_Summon:				//���������ٻ���			
	case ENpcType_BattleHorse:			//ս������
	case ENpcType_OrdnanceMonster:		//��е��
	case ENpcType_Cannon:				//�ƶ���̨
		//case ENpcType_MonsterCard:			//���￨
	case ENpcType_Truck:			//���䳵
	case ENpcType_QuestBeckonNpc:		//�����ٻ�Npc	
	case ENpcType_LittlePet:
	case ENpcType_NotCtrlSummon:
		return true;
	default :
		return false;
	}
}

bool NpcInfoMgr::BeServantType(ENpcType eNpcType)
{
	return ServantType::BeServantType(eNpcType);
}

bool NpcInfoMgr::BeServantTypeNeedToSync(ENpcType eNpcType)
{
	switch(eNpcType)
	{
	case ENpcType_Pet:				//����
	case ENpcType_Summon:			//���������ٻ���			
	case ENpcType_BattleHorse:		//ս������
	case ENpcType_Truck:			//���䳵
		return true;
	default :
		return false;
	}
}

bool NpcInfoMgr::BeFollowMaster(ENpcType eNpcType)
{
	switch (eNpcType)
	{
	case ENpcType_Pet:				//����
	case ENpcType_Summon:			//���������ٻ���			
	case ENpcType_OrdnanceMonster:	//��е��
	case ENpcType_Cannon:			//�ƶ���̨
	case ENpcType_MonsterCard:		//���￨
	case ENpcType_Shadow:			//����	
		//case ENpcType_BossCortegeReBorn:	//BossС�ܱ���
	case ENpcType_BossCortege:		//BossС������
	case ENpcType_QuestBeckonNpc:	//�����ٻ�Npc	
	case ENpcType_NotCtrlSummon:
		return true;
	default :
		return false;
	}
}

//������������Ҫ��ɾ����Npc����
bool NpcInfoMgr::BeKillServantByMasterDestory(ENpcType eNpcType)
{
	switch(eNpcType)
	{
	case ENpcType_Totem:			//ͼ��
	case ENpcType_Pet:				//����
	case ENpcType_Summon:			//���������ٻ���			
	case ENpcType_BattleHorse:		//ս������
		//case ENpcType_OrdnanceMonster:	//��е��
	case ENpcType_MagicBuilding:	//ħ����
		//case ENpcType_Cannon:			//�ƶ���̨
	case ENpcType_MonsterCard:		//���￨
	case ENpcType_Shadow:			//����
	case ENpcType_QuestBeckonNpc:	//�����ٻ�Npc
	case ENpcType_LittlePet:		//С����
	case ENpcType_NotCtrlSummon:
		return true;
	default :
		return false;
	}
}

ENpcEnmityType NpcInfoMgr::GetEnmityMgrType(ENpcType eNpcType)
{
	switch(eNpcType)
	{
	case ENpcType_Normal:			//��ͨ����Npc������Npc�������֣������֣������ȵ�
		//case ENpcType_BossCortegeReBorn:		//BossС��ս������
	case ENpcType_BossCortege:	//BossС���˳�ս������
	case ENpcType_Truck:		//���䳵
	case ENpcType_AttackNearest:		//�������
	case ENpcType_Totem:				//ͼ��
	case ENpcType_Pet:				//����
	case ENpcType_QuestBeckonNpc:	//�����ٻ�Npc	
	case ENpcType_Summon:			//���������ٻ���			
	case ENpcType_BattleHorse:		//ս������
	case ENpcType_OrdnanceMonster:	//��е��
	case ENpcType_MagicBuilding:	//ħ����
	case ENpcType_Cannon:			//�ƶ���̨
	case ENpcType_MonsterCard:		//���￨
	case ENpcType_Shadow:			//����
	case ENpcType_LittlePet:		//С����
	case ENpcType_NotCtrlSummon:
		return ENpcEnmityType_Nomal;
	case ENpcType_Dummy:	
		return ENpcEnmityType_Dummy;
	case ENpcType_Member:
		return ENpcEnmityType_Member;
	default:
		return ENpcEnmityType_None;
	}
}

bool NpcInfoMgr::BeFightNpc(ENpcAIType eNpcAIType)
{
	switch(eNpcAIType)
	{
	case ENpcAIType_Task:										//����Npc
	case ENpcAIType_PassivityCopIt:								//���򲻷���
	case ENpcAIType_VirtualNpc:									//����Npc֧��Ѳ��
	case ENpcAIType_Building:									//���Npc(���������ӣ�ˢ�����ȵ�)
	case ENpcAIType_Pet:										//����
	case ENpcAIType_Theater:									//�糡Npc
	case ENpcAIType_NotFightNonTask:							//���򲻻��ֲ�ת�������Npc
	case ENpcAIType_Escape:										//����AI
		return false;
	default:
		return true;
	}
}

bool NpcInfoMgr::CanBeChangeAI(ENpcAIType eAIType, EClass eClass, ECamp eCamp)
{
	switch (eAIType)
	{
	case ENpcAIType_None:
	case ENpcAIType_Task:
	case ENpcAIType_Totem:
	case ENpcAIType_PassivityCopIt:
	case ENpcAIType_VirtualNpc:
	case ENpcAIType_GroupMemberPassivity:
	case ENpcAIType_GroupMemberInitiative:
	case ENpcAIType_TowerAttack:
	case ENpcAIType_BattleHorse:
	case ENpcAIType_Building:
	case ENpcAIType_OrdnanceMonster:
	case ENpcAIType_MagicBuilding:
	case ENpcAIType_Cannon:
	case ENpcAIType_MonsterCard:
	case ENpcAIType_Pet:
	case ENpcAIType_Theater:
	case ENpcAIType_NotFightNonTask:
		return false;
	default:
		break;
	}
	switch(eClass)
	{
	case eCL_006:
	case eCL_012:
	case eCL_014:
	case eCL_018:
	case eCL_032:
	case eCL_036:
	case eCL_037:
	case eCL_040:
	case eCL_041:
	case eCL_042:
	case eCL_043:
		return false;
	default:
		break;
	}

	//ֻ��1,2,3,5��Ӫ�Ĺ�����ܱ�ץ
	switch(eCamp)
	{
	case eCamp_Monster:
	case eCamp_AmyEmpire:
	case eCamp_WestEmpire:
	case eCamp_DevilIsland:
		break;

	default:
		return false;
	}

	return true;
}

bool NpcInfoMgr::CanChangeCamp(ENpcType eType)
{
	switch(eType)
	{
	case ENpcType_LittlePet:
		return false;
		break;
	default:
		return true;
	}
}

