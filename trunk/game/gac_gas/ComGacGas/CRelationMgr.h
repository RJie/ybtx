#pragma once
#include "GameDef.h"

enum ERelationType
{
	eRT_Friend,				// �ѷ�
	eRT_Enemy,				// �з�
	eRT_Neutral,			// ������
	eRT_SelfUnderPKLevel,	// �Լ��ȼ�����PK���ߵȼ�����������
	eRT_TargetUnderPKLevel,	// Ŀ��ȼ�����PK���ߵȼ��������ո�
	eRT_SelfBeyondLv,		// Ŀ��ȼ�����
	eRT_TargetBeyondLv,		// Ŀ��ȼ�����
	eRT_SelfSafetyState,	// �Լ����ڰ�ȫ״̬���޷�����
	eRT_TargetSafetyState,	// Ŀ�괦�ڰ�ȫ״̬���޷�����
	eRT_FriendInRivalry,	// �Լ����ڰ�ȫ״̬���ѷ����ڶԿ�״̬
	eRT_TargetInDuel,		// Ŀ�괦�ھ���״̬�����ܽ��иò���
	eRT_DuelTargetWrong,	// �㴦����ս״̬�У�Ŀ��ѡ�����
	eRT_Error,
};

class CFighterBaseInfo;

class CRelationMgr
{
public:
	static CRelationMgr& Inst();
	static ERelationType GetRelationType(CFighterBaseInfo* pOne, CFighterBaseInfo* pAnother);

//private:
//	static ERelationType TestOfLevelLimit(uint32 uOneLevel, uint32 uAnotherLevel);
};
