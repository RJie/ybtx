#pragma once
#include "CMoveMagicDefs.h"
#include "TConfigAllocator.h"
#include "TSqrAllocator.inl"

class CMoveMagicCfg : public CConfigMallocObject
{
public:
	typedef map<string, EMoveMagicArgLimit, less<string>, 
		TConfigAllocator<pair<string, EMoveMagicArgLimit > > >	MapMoveArgLimit;
	typedef map<string,	EMoveMagicArg, less<string>, 
		TConfigAllocator<pair<string, EMoveMagicArg > > >			MapMoveArg;
	typedef map<string, EMoveMagicType, less<string>, 
		TConfigAllocator<pair<string, EMoveMagicType > > >		MapMoveType;
	typedef map<string, EBarrierType, less<string>, 
		TConfigAllocator<pair<string, EBarrierType > > >			MapBarrierType;
	typedef map<string, EMoveActionType, less<string>, 
		TConfigAllocator<pair<string, EMoveActionType > > >		MapActionType;

	static MapMoveArgLimit						ms_mapMoveArgLimit;
	static MapMoveArg							ms_mapMoveArg;
	static MapMoveType							ms_mapMoveType;
	static MapBarrierType						ms_mapBarrierType;
	static MapActionType						ms_mapActionType;
	
	inline static bool							InitMapMoveArgLimit()
	{
		ms_mapMoveArgLimit[""]				= eMMAL_None;
		ms_mapMoveArgLimit["��������"]		= eMMAL_DistanceLimit;
		ms_mapMoveArgLimit["��Χ����"]		= eMMAL_AreaLimit;
		ms_mapMoveArgLimit["�ص�����"]		= eMMAL_PositionLimit;
		ms_mapMoveArgLimit["�����������"]	= eMMAL_DistanceLimitRandom;
		ms_mapMoveArgLimit["��Χ�������"]	= eMMAL_AreaLimitRandom;
		ms_mapMoveArgLimit["�ص��������"]	= eMMAL_PositonLimitRandom;
		ms_mapMoveArgLimit["ƫ��"]			= eMMAL_Offset;
		return true;
	}

	inline static bool								InitMapMoveArg()
	{
		ms_mapMoveArg[""]			= eMMA_None;
		ms_mapMoveArg["����λ��"]	= eMMA_SelfPosition;
		ms_mapMoveArg["Ŀ��λ��"]	= eMMA_TargetPosition;
		ms_mapMoveArg["������"]	= eMMA_Direction;
		ms_mapMoveArg["������"]	= eMMA_OppositeDirection;
		ms_mapMoveArg["�ص�"]		= eMMA_Position;
		ms_mapMoveArg["��Χ"]		= eMMA_Area;
		return true;
	}

	inline static bool								InitMapMoveType()
	{
		ms_mapMoveType["�ƶ�"]	= eMMT_Move;
		ms_mapMoveType["����"]	= eMMT_Direction;
		ms_mapMoveType["���"]	= eMMT_Random;
		ms_mapMoveType["��Χ�ƶ�"]	= eMMT_AreaMove;
		ms_mapMoveType["��Χ����"]	= eMMT_AreaDirection;
		ms_mapMoveType["��Χ���"]	= eMMT_AreaRandom;
		return true;
	}

	inline static bool								InitMapBarrierType()
	{
		ms_mapBarrierType["����"]	= eBT_LowBarrier;
		ms_mapBarrierType["����"]	= eBT_MidBarrier;
		return true;
	}

	inline static bool								InitMapActionType()
	{
		ms_mapActionType[""] = eMAT_None;
		ms_mapActionType["����"] = eMAT_HitFly;
		ms_mapActionType["����"] = eMAT_HitAway;
		ms_mapActionType["��Ծ"] = eMAT_Jump;
		ms_mapActionType["��ת"] = eMAT_Eddy;
		return true;
	}
};

