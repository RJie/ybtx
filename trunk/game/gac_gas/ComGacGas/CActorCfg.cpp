#include "stdafx.h"
#include "CActorCfg.h"

CActorCfg::MapActionState CActorCfg::ms_mapActionState;

void CActorCfg::BuildMapString2Enum()
{
	ms_mapActionState["��������"]	=	eAS_Die;
	ms_mapActionState["�����ɵ�"]	=	eAS_Dead;
	ms_mapActionState["������վ"]	=	eAS_Idle_BackWpn;
	ms_mapActionState["������վ"]	=	eAS_Idle_HoldWpn;
	ms_mapActionState["ս��վ��"]	=	eAS_Idle_Battle;
	ms_mapActionState["��������"]	=	eAS_Walk_BackWpn;
	ms_mapActionState["��������"]	=	eAS_Walk_HoldWpn;
	ms_mapActionState["ս������"]	=	eAS_Walk_Battle;
	ms_mapActionState["��������"]	=	eAS_Run_BackWpn;
	ms_mapActionState["��������"]	=	eAS_Run_HoldWpn;
	ms_mapActionState["ս���ܶ�"]	=	eAS_Run_Battle;

	ms_mapActionState["���ҹ���"]	=	eAS_Attack_Right;
	ms_mapActionState["���󹥻�"]	=	eAS_Attack_Left;
	ms_mapActionState["ȫ����"]	=	eAS_Attack_All;
	ms_mapActionState["ȫ����"]	=	eAS_Strike;
	ms_mapActionState["���﹥��"]	=	eAS_Attack_Ride;
	ms_mapActionState["���ֹ���"]	=	eAS_Attack_Assist;
	ms_mapActionState["ȭͷ����"]	=	eAS_Attack_Fist;
	ms_mapActionState["��󱻻�"]	=	eAS_Suffer_Back;
	ms_mapActionState["���󱻻�"]	=	eAS_Suffer_Left;
	ms_mapActionState["���ұ���"]	=	eAS_Suffer_Right;
	ms_mapActionState["����"]		=	eAS_Dodge;
	ms_mapActionState["��"]		=	eAS_Block;
	ms_mapActionState["�м�"]		=	eAS_Parry;
	ms_mapActionState["����"]		=	eAS_Stun;
	ms_mapActionState["����"]		=	eAS_HitDown;
	ms_mapActionState["˯��"]		=	eAS_Sleep;
	ms_mapActionState["����"]		=	eAS_Combo;
	ms_mapActionState["������"]		=	eAS_Whirl;
	ms_mapActionState["������"]		=	eAS_HoldWeapon;
	ms_mapActionState["������"]		=	eAS_BackWeapon;
	ms_mapActionState["����"]		=	eAS_ReachUp;
	ms_mapActionState["����"]		=	eAS_Channel;
	ms_mapActionState["����"]		=	eAS_Sing;
	ms_mapActionState["����"]		=	eAS_Cast;
	ms_mapActionState["�ƶ���ʼ"]	=	eAS_MoveStart;
	ms_mapActionState["�ƶ�����"]	=	eAS_MoveProcess;
	ms_mapActionState["�ƶ�����"]	=	eAS_MoveEnd;

	ms_mapActionState["����"]		=	eAS_Take;
	ms_mapActionState["�ӳ�"]		=	eAS_Fire;
	ms_mapActionState["����"]		=	eAS_Kick;
	ms_mapActionState["�ɼ�"]		=	eAS_Gather;
	ms_mapActionState["ʰȡ"]		=	eAS_PickUp;
	ms_mapActionState["����"]		=	eAS_SitDown;
	ms_mapActionState["����"]		=	eAS_Sitting;
	ms_mapActionState["��ʳ"]		=	eAS_TakeFood;
	ms_mapActionState["��Ʒ˲��"]	=	eAS_Item_Use;
	ms_mapActionState["��Ʒ����"]	=	eAS_Item_Sing;
	ms_mapActionState["��Ʒ����"]	=	eAS_Item_Cast;
	ms_mapActionState["��Ʒ����"]	=	eAS_Item_Channel;
	ms_mapActionState["������ʼ"]	=	eAS_Fun_Start;
	ms_mapActionState["���鱣��"]	=	eAS_Fun_Keep;

	ms_mapActionState["˦������"]	=	eAS_Throw;
	ms_mapActionState["�ȴ�ҧ��"]	=	eAS_WaitBite;
	ms_mapActionState["����ʵ1"]	=	eAS_Disturbed01;
	ms_mapActionState["����ʵ2"]	=	eAS_Disturbed02;
	ms_mapActionState["����ʵ3"]	=	eAS_Disturbed03;
	ms_mapActionState["��ҧ��"]		=	eAS_Bite;
	ms_mapActionState["�ȴ�ק��"]	=	eAS_WaitPull;
	ms_mapActionState["ק��1"]		=	eAS_Pull01;
	ms_mapActionState["ק��2"]		=	eAS_Pull02;
	ms_mapActionState["ק��3"]		=	eAS_Pull03;
	ms_mapActionState["����ɹ�1"]	=	eAS_Succeed01;
	ms_mapActionState["����ɹ�2"]	=	eAS_Succeed02;

	ms_mapActionState["�ɿ�"]		=	eAS_PickOre;

	ms_mapActionState["��������"]	=	eAS_Birth;
	ms_mapActionState["��ʼ����һ"]	=	eAS_Still_1;
	ms_mapActionState["��ʼ������"]	=	eAS_Still_2;
	ms_mapActionState["��ʼ������"]	=	eAS_Still_3;
	ms_mapActionState["������ʼ"]	=	eAS_Respond_Enter;
	ms_mapActionState["��������"]	=	eAS_Respond_Keep;
	ms_mapActionState["��������"]	=	eAS_Respond_Leave;
	ms_mapActionState["�������"]	=	eAS_Idle_Special;
	ms_mapActionState["�������ѭ��"]	=	eAS_Idle_Special_Loop;
	ms_mapActionState["���⵹��"]	=	eAS_Die_Special;
	ms_mapActionState["�����ɵ�"]	=	eAS_Dead_Special;
	ms_mapActionState["�����ⲽ"]	=	eAS_Pace_Right;
	ms_mapActionState["�����ⲽ"]	=	eAS_Pace_Left;
	ms_mapActionState["̸��"]		=	eAS_Talk;

	ms_mapActionState["����"]		= eAS_Die;
	ms_mapActionState["��ֹ"]		= eAS_HoldStill;
}

void CActorCfg::CleanMap()
{
	ms_mapActionState.clear();
}

EActionState CActorCfg::GetEnumByString(const TCHAR* strAct)
{
	MapActionState::iterator it = ms_mapActionState.find(strAct);
	if (it != ms_mapActionState.end())
	{
		return it->second;
	}
	return eAS_Error;
}
