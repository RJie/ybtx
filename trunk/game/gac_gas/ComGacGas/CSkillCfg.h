#pragma once
#include "FightDef.h"
#include "CConfigMallocObject.h"
#include "TConfigAllocator.h"

class CSkillCfg : public CConfigMallocObject
{
public:
	typedef map<string, ETalentType, less<string>, 
		TConfigAllocator<pair<string, ETalentType > > >			MapTalentType;
	typedef map<string, ETalentRuleType, less<string>, 
		TConfigAllocator<pair<string, ETalentRuleType > > >		MapTalentRuleType;
	typedef map<string, EFSTargetType, less<string>, 
		TConfigAllocator<pair<string, EFSTargetType > > >			MapTargetType;
	typedef map<string, ESkillCoolDownType, less<string>, 
		TConfigAllocator<pair<string, ESkillCoolDownType > > >	MapCoolDownType;
	typedef map<string, EAttackType, less<string>, 
		TConfigAllocator<pair<string, EAttackType > > >			MapAttackType;
	typedef map<string, ECastingProcessType, less<string>, 
		TConfigAllocator<pair<string, ECastingProcessType > > >	MapCastingType;
	typedef map<string, EOperateObjectType, less<string>, 
		TConfigAllocator<pair<string, EOperateObjectType > > >	MapOperateObjectType;
	typedef map<string, EObjFilterType, less<string>, 
		TConfigAllocator<pair<string, EObjFilterType > > >		MapObjFilterType;
	typedef map<string, ECastingInterruptType, less<string>, 
		TConfigAllocator<pair<string, ECastingInterruptType > > >	MapCastingInterruptType;
	typedef map<string, string, less<string>,
		TConfigAllocator<pair<string, string > > >	 MapTempVarType;
	typedef map<string, string, less<string>,
		TConfigAllocator<pair<string, string > > >	 MapPassivityTempVarType;
	
	static MapTalentType						ms_mapTalentType;
	static MapTalentRuleType					ms_mapTalentRuleType;
	static MapTargetType						ms_mapTargetType;
	static MapCoolDownType						ms_mapCoolDownType;
	static MapAttackType						ms_mapAttackType;
	static MapCastingType						ms_mapCastingType;
	static MapCastingInterruptType				ms_mapCastingInterruptType;
	static MapOperateObjectType					ms_mapOperateObjectType;
	static MapObjFilterType						ms_mapObjFilterType;
	static MapTempVarType						ms_mapTempVarType;
	static MapPassivityTempVarType				ms_mapPassivityTempVarType;

	inline static void			InitMapTalentType()
	{
		ms_mapTalentType["ְҵ�츳"]		= eTT_Class;
		ms_mapTalentType["��Ӫ�츳"]		= eTT_Camp;
		ms_mapTalentType["�ȼ��츳"]		= eTT_Level;
		ms_mapTalentType["�����츳"]		= eTT_Skill;
		ms_mapTalentType["װ���츳"]		= eTT_Equip;
	}

	inline static void			InitMapTalentRuleType()
	{
		ms_mapTalentRuleType["����"]		= eTRT_Stackup;
		ms_mapTalentRuleType["��ɢ"]		= eTRT_Decentral;
		ms_mapTalentRuleType["Ψһ"]		= eTRT_Unique;
	}

	inline static bool			InitMapTargetType()				
	{
		ms_mapTargetType["�յ�"]				= eFSTT_Position;
		ms_mapTargetType["�з�Ŀ��"]			= eFSTT_EnemyObject;
		ms_mapTargetType["�ѷ�Ŀ��"]			= eFSTT_FriendObject;
		ms_mapTargetType["����Ŀ��"]			= eFSTT_NeutralObject;
		ms_mapTargetType["Ŀ��λ��"]			= eFSTT_ObjectPosition;
		ms_mapTargetType["����"]				= eFSTT_Self;
		ms_mapTargetType["����λ��"]			= eFSTT_SelfPosition;
		ms_mapTargetType["������"]			= eFSTT_SelfDirection;
		ms_mapTargetType["�յػ�з�Ŀ��"]		= eFSTT_PositionOrEnemy;
		ms_mapTargetType["�յػ��ѷ�Ŀ��"]		= eFSTT_PositionOrFriend;
		ms_mapTargetType["�ѷ�������"]			= eFSTT_FriendandSelf;
		ms_mapTargetType["����Ŀ��"]			= eFSTT_AllObject;
		ms_mapTargetType["����Ŀ��"]			= eFSTT_FriendAndEnemy;
		ms_mapTargetType["����Ŀ�������"]		= eFSTT_NotNeutral;
		ms_mapTargetType["ѡ���ѷ�Ŀ��"]		= eFSTT_SelectFriendObject;
		ms_mapTargetType["�յػ�����Ŀ��"]		= eFSTT_PositionOrLockedTarget;
		ms_mapTargetType["���ѷ�Ŀ��"]			= eFSTT_NotFriendObject;
		ms_mapTargetType["���ѻ�з�Ŀ��"]		= eFSTT_TeammatesOrEnemy;
		return true;
	}

	inline static bool			InitMapCoolDownType()
	{
		ms_mapCoolDownType["ս������"]			= eSCDT_FightSkill;
		ms_mapCoolDownType["�޹���CDս������"]	= eSCDT_NoComCDFightSkill;
		ms_mapCoolDownType["��������"]			= eSCDT_PublicSkill;
		ms_mapCoolDownType["�ָ���Ʒ����"]		= eSCDT_DrugItemSkill;
		ms_mapCoolDownType["������Ʒ����"]		= eSCDT_SpecialItemSkill;
		ms_mapCoolDownType["������Ʒ����"]		= eSCDT_OtherItemSkill;
		ms_mapCoolDownType["��ʱ����"]			= eSCDT_TempSkill;
		ms_mapCoolDownType["�����Ƽ���"]		= eSCDT_UnrestrainedSkill;
		ms_mapCoolDownType["��������"]			= eSCDT_OtherSkill;
		ms_mapCoolDownType["��ս������"]		= eSCDT_NonFightSkill;
		ms_mapCoolDownType["װ������"]			= eSCDT_EquipSkill;
		ms_mapCoolDownType["������ս������"]	= eSCDT_UnrestrainedFightSkill;
		return true;
	}

	inline static void InitMapAttackType()					
	{
		ms_mapAttackType["������"]	= eATT_None;
		ms_mapAttackType["����"]	= eATT_Puncture;
		ms_mapAttackType["���"]	= eATT_Chop;
		ms_mapAttackType["�ۻ�"]	= eATT_BluntTrauma;
		ms_mapAttackType["��Ȼ"]	= eATT_Nature;
		ms_mapAttackType["�ƻ�"]	= eATT_Destroy;
		ms_mapAttackType["����"]	= eATT_Evil;
		ms_mapAttackType["������������"]	= eATT_FollowWeapon;
	}

	inline static bool					InitMapCastingType()		//�Ժ���Ҫ��ϸ����			
	{
		ms_mapCastingType["����"]		= eCPT_Sing;
		ms_mapCastingType["����"]		= eCPT_Channel;
		ms_mapCastingType["��������"]	= eCPT_GradeSing;
		ms_mapCastingType["Ӳֱ����"]	= eCPT_ImmovableSing;
		return true;
	}

	inline static bool					InitMapCastingInterruptType()
	{
		ms_mapCastingInterruptType["��"]	= eCIT_None;
		ms_mapCastingInterruptType["�ƶ�"]	= eCIT_Move;
		ms_mapCastingInterruptType["ת��"]	= eCIT_TurnAround;

		return true;
	}

	inline static bool					InitMapOperateObjectType()	
	{	
		ms_mapOperateObjectType["�ͷ���"]		= eOOT_Releaser;
		ms_mapOperateObjectType["����"]			= eOOT_Self;
		ms_mapOperateObjectType["Ŀ��"]			= eOOT_Target;
		ms_mapOperateObjectType["�ѷ�"]			= eOOT_Friend;
		ms_mapOperateObjectType["�з�"]			= eOOT_Enemy;
		ms_mapOperateObjectType["����Ŀ��"]		= eOOT_FriendAndEnemy;
		ms_mapOperateObjectType["С�ӳ�Ա"]		= eOOT_Teammates;
		ms_mapOperateObjectType["�Ŷӳ�Ա"]		= eOOT_Raidmates;
		ms_mapOperateObjectType["Ӷ��С�ӳ�Ա"]	= eOOT_Tongmates;
		ms_mapOperateObjectType["��������"]		= eOOT_SelfMaster;
		ms_mapOperateObjectType["Ŀ����Χ�з�"]	= eOOT_TargetAroundEnemy;
		ms_mapOperateObjectType["�ͷ��߼��Ŷӳ�Ա"]	= eOOT_SelfAndRaidmates;

		return true;
	}

	inline static bool					BuildObjFilterMap()
	{
		ms_mapObjFilterType["����"]				= eOF_Self;
		ms_mapObjFilterType["Ŀ��"]				= eOF_Target;
		ms_mapObjFilterType["�ص�"]				= eOF_Position;
		ms_mapObjFilterType["����"]				= eOF_Pet;
		ms_mapObjFilterType["�ǿ�������"]		= eOF_NotCtrlSummon;
		ms_mapObjFilterType["����"]				= eOF_Master;
		ms_mapObjFilterType["С�ӳ�Ա"]			= eOF_Teammates;
		ms_mapObjFilterType["�Ŷӳ�Ա"]			= eOF_Raidmates;
		ms_mapObjFilterType["Ӷ��С�ӳ�Ա"]		= eOF_Tongmates;
		ms_mapObjFilterType["��Χ�ѷ�"]			= eOF_AroundFriend;
		ms_mapObjFilterType["��Χ�з�"]			= eOF_AroundEnemy;
		ms_mapObjFilterType["�ϴ�Ŀ��ɸѡ���"]	= eOF_FilterResult;

		ms_mapObjFilterType["����"]				= eOF_Amount;
		ms_mapObjFilterType["ʬ��"]				= eOF_DeadBody;
		ms_mapObjFilterType["�Լ�����"]			= eOF_ExceptSelf;
		ms_mapObjFilterType["Ŀ�����"]			= eOF_ExceptTarget;
		ms_mapObjFilterType["���ڴ�����״̬"]	= eOF_InTriggerState;
		ms_mapObjFilterType["����ħ��״̬"]		= eOF_InMagicState;
		ms_mapObjFilterType["������ħ��״̬"]	= eOF_NotInMagicState;
		ms_mapObjFilterType["����������״̬"]	= eOF_OutSpecialState;
		ms_mapObjFilterType["��������"]			= eOF_IsVestInSelf;
		ms_mapObjFilterType["�����������"]		= eOF_ExpIsVestInSelf;
		ms_mapObjFilterType["ɸѡNPC"]			= eOF_FilterNPC;
		ms_mapObjFilterType["ɸѡ���"]			= eOF_FilterPlayer;
		ms_mapObjFilterType["���ɸѡ"]			= eOF_FilterRandom;
		ms_mapObjFilterType["�ص�ħ��Ŀ��"]		= eOF_PosMagicTarget;
		ms_mapObjFilterType["���Ŀ��"]			= eOF_LatestTarget;
		ms_mapObjFilterType["����ֵ��С"]		= eOF_LeastHP;			// û�õ�
		ms_mapObjFilterType["ְҵ"]				= eOF_Class;			// û�õ�
		ms_mapObjFilterType["����ӵ����"]		= eOF_ExpOwner;
		ms_mapObjFilterType["��ǰ�����з�Ŀ��"]	= eOF_LockedEnemyTarget;
		ms_mapObjFilterType["ʬ�����"]			= eOF_ExceptDeadBoby;
		ms_mapObjFilterType["�����1"]			= eOF_ShockWaveEff1;
		ms_mapObjFilterType["�����2"]			= eOF_ShockWaveEff2;
		ms_mapObjFilterType["�����3"]			= eOF_ShockWaveEff3;
		ms_mapObjFilterType["�����4"]			= eOF_ShockWaveEff4;
		ms_mapObjFilterType["�����5"]			= eOF_ShockWaveEff5;

		return true;
	}

	inline static bool InitDCStateTempVarMap()
	{
		ms_mapTempVarType["������ͨ�����˺�"] = "�˺�";
		ms_mapTempVarType["������ͨ���������˺�"] = "�˺�";
		ms_mapTempVarType["Զ����ͨ�����˺�"] = "�˺�";
		ms_mapTempVarType["������ͨ�����˺�"] = "�˺�";
		ms_mapTempVarType["�˺�"]		= "�˺�";
		ms_mapTempVarType["��DOT�˺�"]	= "�˺�";
		ms_mapTempVarType["�����˺�"]	= "�˺�";
		ms_mapTempVarType["��Ѫ"]		= "����";
		ms_mapTempVarType["����"]		= "����";
		return true;
	}
	
	inline static bool InitPassivityDCStateTempVarMap()
	{
		ms_mapPassivityTempVarType["������ͨ�����˺�"] = "���˺�";
		ms_mapPassivityTempVarType["������ͨ���������˺�"] = "���˺�";
		ms_mapPassivityTempVarType["Զ����ͨ�����˺�"] = "���˺�";
		ms_mapPassivityTempVarType["������ͨ�����˺�"] = "���˺�";
		ms_mapPassivityTempVarType["�˺�"]		= "���˺�";
		ms_mapPassivityTempVarType["��DOT�˺�"]	= "���˺�";
		ms_mapPassivityTempVarType["�����˺�"]	= "���˺�";
		ms_mapPassivityTempVarType["��Ѫ"]		= "������";
		ms_mapPassivityTempVarType["����"]		= "������";
		return true;
	}
};
