#pragma once

#include "GameDef.h"

struct TypeMapRgst
{
	TypeMapRgst()
	{
		mapNpcTypeMap["��ͨ"]			= ENpcType_Normal;
		mapNpcTypeMap["ͼ��"]			= ENpcType_Totem;
		mapNpcTypeMap["����"]			= ENpcType_Pet;
		mapNpcTypeMap["�ٻ���"]			= ENpcType_Summon;
		mapNpcTypeMap["ս������"]		= ENpcType_BattleHorse;
		mapNpcTypeMap["����Npc"]		= ENpcType_Dummy;
		mapNpcTypeMap["�Ŷӳ�Ա"]		= ENpcType_Member;
		mapNpcTypeMap["��е��"]			= ENpcType_OrdnanceMonster;
		mapNpcTypeMap["ħ����"]			= ENpcType_MagicBuilding;
		mapNpcTypeMap["�ƶ���̨"]		= ENpcType_Cannon;
		mapNpcTypeMap["���￨"]			= ENpcType_MonsterCard;
		mapNpcTypeMap["����"]			= ENpcType_Shadow;
		mapNpcTypeMap["���䳵"]			= ENpcType_Truck;
		mapNpcTypeMap["BossС��"]		= ENpcType_BossCortege;
		mapNpcTypeMap["�����ٻ�Npc"]	= ENpcType_QuestBeckonNpc;
		mapNpcTypeMap["�������"]		= ENpcType_AttackNearest;
		mapNpcTypeMap["�������"]		= ENpcType_LittlePet;
		mapNpcTypeMap["���ܿ��ٻ���"]	= ENpcType_NotCtrlSummon;
	}
	typedef map<string, ENpcType> mapNpcType_T;
	typedef mapNpcType_T::const_iterator  mapNpcType_itr;
	mapNpcType_T mapNpcTypeMap;
};
static TypeMapRgst NpcType;

struct NpcTypeMapName
{
	NpcTypeMapName()
	{
		mNpcTypeMapName[ENpcType_Normal]			= "��ͨ";
		mNpcTypeMapName[ENpcType_Totem]				= "ͼ��";
		mNpcTypeMapName[ENpcType_Pet]				= "����";
		mNpcTypeMapName[ENpcType_Summon]			= "�ٻ���";
		mNpcTypeMapName[ENpcType_BattleHorse]		= "ս������";
		mNpcTypeMapName[ENpcType_Dummy]				= "����Npc";
		mNpcTypeMapName[ENpcType_Member]			= "�Ŷӳ�Ա";
		mNpcTypeMapName[ENpcType_OrdnanceMonster]	= "��е��";
		mNpcTypeMapName[ENpcType_MagicBuilding]		= "ħ����";
		mNpcTypeMapName[ENpcType_Cannon]			= "�ƶ���̨";
		mNpcTypeMapName[ENpcType_MonsterCard]		= "���￨";
		mNpcTypeMapName[ENpcType_Shadow]			= "����";
		mNpcTypeMapName[ENpcType_Truck]				= "���䳵";
		mNpcTypeMapName[ENpcType_BossCortege]		= "BossС��";
		mNpcTypeMapName[ENpcType_QuestBeckonNpc]	= "�����ٻ�Npc";
		mNpcTypeMapName[ENpcType_AttackNearest]		= "�������";
		mNpcTypeMapName[ENpcType_LittlePet]			= "�������";
		mNpcTypeMapName[ENpcType_NotCtrlSummon]		= "���ܿ��ٻ���";
	}
	typedef map<ENpcType, string> mapNpcType_T;
	typedef mapNpcType_T::const_iterator  mapNpcType_itr;
	mapNpcType_T mNpcTypeMapName;
};
static NpcTypeMapName sNpcTypeMapName; 

struct AITypeAoiRgst
{
	AITypeAoiRgst()
	{
		mapObjectAoiType["��ͨ�ֱ���֧��Ѳ��"]						= EAoi_PassiveNpc;
		mapObjectAoiType["�°���������AI"]						= EAoi_PassiveNpc;
		mapObjectAoiType["��ͨ������֧��Ѳ��"]						= EAoi_ActiveNpc;
		mapObjectAoiType["��ͨ������֧��Ѳ�߿ɼ�Npc"]				= EAoi_ActiveServant;
		mapObjectAoiType["����NPC֧��Ѳ��"]							= EAoi_PassiveNpc;		//����Npc��Ҫ�������ħ�����������Ըĳɱ�����AOI
		mapObjectAoiType["���Npc"]									= EAoi_PassiveNpc;		//���������ʲô��ҲҪ��ħ��������
		mapObjectAoiType["���򲻷���"]								= EAoi_PassiveNpc;
		mapObjectAoiType["ͼ��"]									= EAoi_ActiveServant;
		mapObjectAoiType["�ٻ���"]									= EAoi_PassiveServant;
		mapObjectAoiType["����Npc֧��Ѳ��"]							= EAoi_SleepNPC;	
		mapObjectAoiType["Ⱥ���Ա������"]							= EAoi_PassiveNpc;
		mapObjectAoiType["Ⱥ���Ա������"]							= EAoi_ActiveNpc;
		mapObjectAoiType["����AI"]									= EAoi_ActiveServant;
		mapObjectAoiType["ս������"]								= EAoi_BattleHorse;
		mapObjectAoiType["��е��"]									= EAoi_PassiveNpc;
		mapObjectAoiType["ħ����"]									= EAoi_ActiveServant;			//��Ҫ�������Ǻ�Npc����������
		mapObjectAoiType["�ƶ���̨"]								= EAoi_PassiveNpc;
		mapObjectAoiType["���￨"]									= EAoi_ActiveServant;
		mapObjectAoiType["����"]									= EAoi_PassiveNpc;
		mapObjectAoiType["BossС��"]								= EAoi_ActiveServant;
		mapObjectAoiType["Boss����֧��Ѳ��"]						= EAoi_ActiveServant;
		mapObjectAoiType["Boss����֧��Ѳ��"]						= EAoi_PassiveNpc;
		mapObjectAoiType["�糡Npc"]									= EAoi_TaskNpc;
		mapObjectAoiType["ս������"]								= EAoi_BattleHorse;
		mapObjectAoiType["���򲻻��ֲ�ת�������Npc"]				= EAoi_PassiveNpc;
		mapObjectAoiType["���䳵"]									= EAoi_PassiveNpc;
		mapObjectAoiType["����AI"]									= EAoi_ActiveNpc;
		mapObjectAoiType["�������"]								= EAoi_TaskNpc;
	}	
	typedef map<string, EObjectAoiType> mapObjectAoi_T;
	typedef mapObjectAoi_T::const_iterator  mapObjectAoi_itr;
	mapObjectAoi_T mapObjectAoiType;
};
static AITypeAoiRgst sObjectAoiType; 

struct AITypeMap
{
	AITypeMap()
	{
		mapNpcAIType["��ͨ�ֱ���֧��Ѳ��"]						= ENpcAIType_NormalPassivityPatrol;
		mapNpcAIType["��ͨ������֧��Ѳ��"]						= ENpcAIType_NormalInitiativePatrolNoFefer;
		mapNpcAIType["��ͨ������֧��Ѳ�߿ɼ�Npc"]				= ENpcAIType_NormalInitiativePatrolNoFeferCanSeeNpc;
		mapNpcAIType["����NPC֧��Ѳ��"]							= ENpcAIType_Task;
		mapNpcAIType["���򲻷���"]								= ENpcAIType_PassivityCopIt;
		mapNpcAIType["ͼ��"]									= ENpcAIType_Totem;
		mapNpcAIType["�ٻ���"]									= ENpcAIType_Servant;
		mapNpcAIType["����Npc֧��Ѳ��"]							= ENpcAIType_VirtualNpc;	
		mapNpcAIType["Ⱥ���Ա������"]							= ENpcAIType_GroupMemberPassivity;
		mapNpcAIType["Ⱥ���Ա������"]							= ENpcAIType_GroupMemberInitiative;
		mapNpcAIType["����AI"]									= ENpcAIType_TowerAttack;
		mapNpcAIType["ս������"]								= ENpcAIType_BattleHorse;
		mapNpcAIType["���Npc"]									= ENpcAIType_Building;
		mapNpcAIType["��е��"]									= ENpcAIType_OrdnanceMonster;
		mapNpcAIType["ħ����"]									= ENpcAIType_MagicBuilding;
		mapNpcAIType["�ƶ���̨"]								= ENpcAIType_Cannon;
		mapNpcAIType["���￨"]									= ENpcAIType_MonsterCard;
		mapNpcAIType["����"]									= ENpcAIType_Pet;
		mapNpcAIType["BossС��"]								= ENpcAIType_BossCortege;
		mapNpcAIType["Boss����֧��Ѳ��"]						= ENpcAIType_BossActive;
		mapNpcAIType["Boss����֧��Ѳ��"]						= ENpcAIType_BossPassivity;
		mapNpcAIType["�糡Npc"]									= ENpcAIType_Theater;
		mapNpcAIType["���򲻻��ֲ�ת�������Npc"]				= ENpcAIType_NotFightNonTask;
		mapNpcAIType["���䳵"]									= ENpcAIType_Truck;
		mapNpcAIType["����AI"]									= ENpcAIType_Escape;
		mapNpcAIType["�������"]								= ENpcAIType_LittlePet;
	}
	typedef map<string, ENpcAIType> AITypeMapped_T;
	typedef AITypeMapped_T::const_iterator  mapNpcAIType_itr;
	AITypeMapped_T mapNpcAIType;
};
static AITypeMap sNpcAIType; 

struct AINameByTypeMap
{
	AINameByTypeMap()
	{
		mapNpcAINameByNpcAIType[ENpcAIType_NormalPassivityPatrol]					= "��ͨ�ֱ���֧��Ѳ��";
		mapNpcAINameByNpcAIType[ENpcAIType_NormalInitiativePatrolNoFefer]			= "��ͨ������֧��Ѳ��";
		mapNpcAINameByNpcAIType[ENpcAIType_NormalInitiativePatrolNoFeferCanSeeNpc]	= "��ͨ������֧��Ѳ�߿ɼ�Npc";
		mapNpcAINameByNpcAIType[ENpcAIType_Task]									= "����NPC֧��Ѳ��";
		mapNpcAINameByNpcAIType[ENpcAIType_PassivityCopIt]							= "���򲻷���";
		mapNpcAINameByNpcAIType[ENpcAIType_Totem]									= "ͼ��";
		mapNpcAINameByNpcAIType[ENpcAIType_Servant]									= "�ٻ���";
		mapNpcAINameByNpcAIType[ENpcAIType_VirtualNpc]								= "����Npc֧��Ѳ��";	
		mapNpcAINameByNpcAIType[ENpcAIType_GroupMemberPassivity]					= "Ⱥ���Ա������";
		mapNpcAINameByNpcAIType[ENpcAIType_GroupMemberInitiative]					= "Ⱥ���Ա������";
		mapNpcAINameByNpcAIType[ENpcAIType_TowerAttack]								= "����AI";
		mapNpcAINameByNpcAIType[ENpcAIType_BattleHorse]								= "ս������";
		mapNpcAINameByNpcAIType[ENpcAIType_Building]								= "���Npc";
		mapNpcAINameByNpcAIType[ENpcAIType_OrdnanceMonster]							= "��е��";
		mapNpcAINameByNpcAIType[ENpcAIType_MagicBuilding]							= "ħ����";
		mapNpcAINameByNpcAIType[ENpcAIType_Cannon]									= "�ƶ���̨";
		mapNpcAINameByNpcAIType[ENpcAIType_MonsterCard]								= "���￨";
		mapNpcAINameByNpcAIType[ENpcAIType_Pet]										= "����";
		mapNpcAINameByNpcAIType[ENpcAIType_BossCortege]								= "BossС��";
		mapNpcAINameByNpcAIType[ENpcAIType_BossActive]								= "Boss����֧��Ѳ��";
		mapNpcAINameByNpcAIType[ENpcAIType_BossPassivity]							= "Boss����֧��Ѳ��";
		mapNpcAINameByNpcAIType[ENpcAIType_Theater]									= "�糡Npc";
		mapNpcAINameByNpcAIType[ENpcAIType_NotFightNonTask]							= "���򲻻��ֲ�ת�������Npc";
		mapNpcAINameByNpcAIType[ENpcAIType_Truck]									= "���䳵";
		mapNpcAINameByNpcAIType[ENpcAIType_Escape]									= "����AI";
		mapNpcAINameByNpcAIType[ENpcAIType_LittlePet]								= "�������";
	}
	typedef map<ENpcAIType, string> AITypeMapped_T;
	typedef AITypeMapped_T::const_iterator  mapNpcAIType_itr;
	AITypeMapped_T mapNpcAINameByNpcAIType;
};
static AINameByTypeMap sNpcAINameByNpcAIType; 
