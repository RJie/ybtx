#pragma once
#include "CPos.h"
#include "FindPathDefs.h"
#include "CFighterMallocObject.h"

// �ƶ���ʽ����
enum EMoveMagicType
{
	eMMT_Move,				// ƽ��
	eMMT_Direction,			// ����
	eMMT_Random,			// ���
	eMMT_AreaMove,			// ��Χƽ��
	eMMT_AreaDirection,		// ��Χ����
	eMMT_AreaRandom,		// ��Χ���
};

enum EMoveMagicArg
{
	eMMA_None,				// ��
	eMMA_SelfPosition,		// ����λ��
	eMMA_TargetPosition,	// Ŀ��λ��
	eMMA_Direction,
	eMMA_OppositeDirection,
	eMMA_Position,			// �ص�
	eMMA_Area,				// ��Χ
	eMMA_Distance,			// ����
};

enum EMoveMagicArgLimit
{
	eMMAL_None,				// ��
	eMMAL_DistanceLimit,
	eMMAL_AreaLimit,
	eMMAL_PositionLimit,
	eMMAL_DistanceLimitRandom,
	eMMAL_AreaLimitRandom,
	eMMAL_PositonLimitRandom,
	eMMAL_Offset,
};

enum EMoveActionType
{
	eMAT_None,
	eMAT_HitFly,
	eMAT_HitAway,
	eMAT_Jump,
	eMAT_Eddy,
};

enum EMoveType
{
	eMT_Move,			// ƽ��
	eMT_Direction,		// ����
	eMT_Random,			// ���
	eMT_Teleport,		// ����
};

struct MoveInfo : public CFighterMallocObject
{
	EMoveType eMoveType;
	EBarrierType eBarrierType;
	EMoveActionType	eAction;
	CFPos DesPixelPos;
	float fSpeed;
	float fDistance;
	uint8 uDir;
};
