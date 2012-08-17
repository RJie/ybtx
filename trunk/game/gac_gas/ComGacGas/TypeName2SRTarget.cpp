#include "stdafx.h"
#include "TypeName2SRTarget.h"

TypeName2SRTarget::TypeName2SRTarget()
{
	InitTargetTypeMap();
	InitCondTypeMap();
}
void TypeName2SRTarget::InitTargetTypeMap()
{
	mapTargetType["���Ŀ��"]						= eSRTT_T_EnemyObject;
	mapTargetType["Ŀ��λ��"]						= eSRTT_P_EnemyPostion;
	mapTargetType["����"]							= eSRTT_T_Self;
	mapTargetType["����λ��"]						= eSRTT_P_SelfPosition;
	mapTargetType["���Ŀ��λ��"]					= eSRTT_P_RandomEnemyPostion;
	mapTargetType["������"]						= eSRTT_P_SelfDirection;
	mapTargetType["������"]						= eSRTT_P_SelfReverseDirection;
	mapTargetType["���Ŀ��"]						= eSRTT_T_RandomEnemy;
	mapTargetType["����ѷ�Ŀ��"]					= eSRTT_T_RandomFriend;
	mapTargetType["���Ѫ�����Ŀ��"]				= eSRTT_T_MaxHpEnemy;
	mapTargetType["���Ѫ�����Ŀ��λ��"]			= eSRTT_P_MaxHpEnemyPos;
	mapTargetType["���Ѫ�����Ŀ��"]				= eSRTT_T_MinHpEnemy;
	mapTargetType["���Ѫ�����Ŀ��λ��"]			= eSRTT_P_MinHpEnemyPos;
	mapTargetType["���ħ�����Ŀ��"]				= eSRTT_T_MaxMpEnemy;
	mapTargetType["���ħ�����Ŀ��λ��"]			= eSRTT_P_MaxMpEnemyPos;
	mapTargetType["���ħ�����Ŀ��"]				= eSRTT_T_MinMpEnemy;
	mapTargetType["���ħ�����Ŀ��λ��"]			= eSRTT_P_MinMpEnemyPos;
	mapTargetType["�������"]						= eSRTT_P_RandomDirection;
	mapTargetType["�������"]						= eSRTT_T_NearestEnemy;
	mapTargetType["�������λ��"]					= eSRTT_P_NearestEnemyPos;
	mapTargetType["��Զ����"]						= eSRTT_T_FarthestEnemy;
	mapTargetType["��Զ����λ��"]					= eSRTT_P_FarthestEnemyPos;
	mapTargetType["����ѷ�"]						= eSRTT_T_NearestFriend;
	mapTargetType["����ѷ�λ��"]					= eSRTT_P_NearestFriendPos;
	mapTargetType["��Զ�ѷ�"]						= eSRTT_T_FarthestFriend;
	mapTargetType["��Զ�ѷ�λ��"]					= eSRTT_P_FarthestFriendPos;
	mapTargetType["�ǳ��Ŀ�����Ŀ��"]				= eSRTT_T_RandomUnEnmity;
	mapTargetType["�ǳ��Ŀ�����Ŀ��λ��"]			= eSRTT_P_RandomUnEnmityPos;
	mapTargetType["���ٻ������Ŀ��"]				= eSRTT_T_RandomUnServant;
	mapTargetType["���ٻ������Ŀ��λ��"]			= eSRTT_P_RandomUnServantPos;
	mapTargetType["�ǳ��Ŀ����ٻ������Ŀ��"]		= eSRTT_T_RamdomUnEnmityUnServant;
	mapTargetType["�ǳ��Ŀ����ٻ������Ŀ��λ��"]	= eSRTT_P_RamdomUnEnmityUnServantPos;
	mapTargetType["���Ѫ���ѷ�"]					= eSRTT_T_MaxHpFriend;
	mapTargetType["���Ѫ���ѷ�λ��"]				= eSRTT_P_MaxHpFriendPos;
	mapTargetType["���Ѫ���ѷ�"]					= eSRTT_T_MinHpFriend;
	mapTargetType["���Ѫ���ѷ�λ��"]				= eSRTT_P_MinHpFriendPos;
	mapTargetType["���ħ���ѷ�"]					= eSRTT_T_MaxMpFriend;
	mapTargetType["���ħ���ѷ�λ��"]				= eSRTT_P_MaxMpFriendPos;
	mapTargetType["���ħ���ѷ�"]					= eSRTT_T_MinMpFriend;
	mapTargetType["���ħ���ѷ�λ��"]				= eSRTT_P_MinMpFriendPos;
	mapTargetType["��Χ�ص�"]						= eSRTT_P_AroundPos;
	mapTargetType["���λ��"]						= eSRTT_P_RandomPos;
}

void TypeName2SRTarget::InitCondTypeMap()
{
	mapCondType["��������"]		= eRCT_HpGreater;
	mapCondType["��������"]		= eRCT_HpLesser;
	mapCondType["�����״θ���"] = eRCT_HpFirstGreater;
	mapCondType["�����״ε���"] = eRCT_HpFirstLesser;
	mapCondType["ħ������"]		= eRCT_MpGreater;
	mapCondType["ħ������"]		= eRCT_MpLesser;
	mapCondType["ħ���״θ���"] = eRCT_MpFirstGreater;
	mapCondType["ħ���״ε���"] = eRCT_MpFirstLesser;
	mapCondType["����ս��"]		= eRCT_EnterBattle;
	mapCondType["�˺�����"]		= eRCT_BeHurtValueGreater;
	mapCondType["���"]			= eRCT_RandomRate;
	mapCondType["ս��ʱ�䳬��"] = eRCT_BattleTimeGreater;
	mapCondType["�����ͷ�"]		= eRCT_OnDeadCond;
	mapCondType["��ʱ"]			= eRCT_OnTimingCond;
	mapCondType["��Χ��ʱ"]		= eRCT_RangeTimingCond;
	mapCondType["�׶�ʱ�䳬��"] = eRCT_PhaseTimeGreater;
	mapCondType["����׶�"]		= eRCT_EnterPhase;
	mapCondType["�������״̬"] = eRCT_EnterWander;
	mapCondType["����ʱ�䳬��"] = eRCT_WanderTimeGreater;
	mapCondType["��������"]		= eRCT_EnemyDead;
}

