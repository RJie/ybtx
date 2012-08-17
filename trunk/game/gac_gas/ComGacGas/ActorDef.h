#pragma once

// ��ɫ�ƶ�״̬
enum EMoveState
{ 
	eMS_LockStop,		// 0	Die
	eMS_Stop,			// 1	Idle
	eMS_Move,			// 2	Walk��Run
	eMS_LockMove,		// 3	Channel��Jump��HitFly��HitMove
	eMS_Max				// Max
};

// ��ɫ��Ϊ״̬
enum EActionState
{ 
	eAS_Error,
	// ��һ���
	eAS_Die,				// ��������
	eAS_Dead,				// �����ɵ�
	eAS_Idle_BackWpn,		// ������վ
	eAS_Idle_HoldWpn,		// ������վ
	eAS_Idle_Battle,		// ս��վ��
	eAS_Walk_BackWpn,		// ��������
	eAS_Walk_HoldWpn,		// ��������
	eAS_Walk_Battle,		// ս������
	eAS_Run_BackWpn,		// ��������
	eAS_Run_HoldWpn,		// ��������
	eAS_Run_Battle,			// ս���ܶ�

	// ���ս��
	eAS_Attack_Right,		// ���ҹ���
	eAS_Attack_Left,		// ���󹥻�
	eAS_Attack_All,			// ȫ����
	eAS_Strike,				// ȫ����
	eAS_Attack_Assist,		// ���ֹ���
	eAS_Attack_Ride,		// ���﹥��
	eAS_Attack_Fist,		// ȭͷ����
	eAS_Suffer_Back,		// ��󱻻�
	eAS_Suffer_Left,		// ���󱻻�
	eAS_Suffer_Right,		// ���ұ���
	eAS_Dodge,				// ����
	eAS_Block,				// ��
	eAS_Parry,				// �м�
	eAS_Stun,				// ����
	eAS_HitDown,			// ����
	eAS_Sleep,				// ˯��
	eAS_Combo,				// ����
	eAS_Whirl,				// ������
	eAS_HoldStill,			// ��ֹ
	eAS_ResumeAni,			// �ָ�����
	eAS_HoldWeapon,			// ������
	eAS_BackWeapon,			// ������
	eAS_ReachUp,			// ����
	eAS_Channel,			// ����
	eAS_Sing,				// ����
	eAS_Cast,				// ����

	eAS_MoveStart,			// �ƶ���ʼ	
	eAS_MoveProcess,		// �ƶ�����	
	eAS_MoveEnd,			// �ƶ�����	

	// ��ҷ�ս��
	eAS_Take,				// ����
	eAS_Fire,				// �ӳ�
	eAS_Kick,				// ����
	eAS_Gather,				// �ɼ�
	eAS_PickUp,				// ʰȡ
	eAS_SitDown,			// ����
	eAS_Sitting,			// ����
	eAS_TakeFood,			// ��ʳ
	eAS_Item_Use,			// ��Ʒ˲��
	eAS_Item_Sing,			// ��Ʒ����
	eAS_Item_Cast,			// ��Ʒ����
	eAS_Item_Channel,		// ��Ʒ����
	eAS_Fun_Start,			// ������ʼ
	eAS_Fun_Keep,			// ���鱣��

	eAS_Throw,				// ˦������
	eAS_WaitBite,			// �ȴ�ҧ��
	eAS_Disturbed01,		// ����ʵ1
	eAS_Disturbed02,		// ����ʵ2
	eAS_Disturbed03,		// ����ʵ3
	eAS_Bite,				// ��ҧ��
	eAS_WaitPull,			// �ȴ�ק��
	eAS_Pull01,				// ק��1
	eAS_Pull02,				// ק��2
	eAS_Pull03,				// ק��3
	eAS_Succeed01,			// ����ɹ�1
	eAS_Succeed02,			// ����ɹ�2

	eAS_PickOre,			// �ɿ�

	// NPC ����
	eAS_Birth,				// NPC����
	eAS_Still_1,			// NPC��ʼ����һ
	eAS_Still_2,			// NPC��ʼ������
	eAS_Still_3,			// NPC��ʼ������
	eAS_Respond_Enter,		// NPC����ҽ�����ʼ
	eAS_Respond_Keep,		// NPC����ҽ�����
	eAS_Respond_Leave,		// NPC����ҽ�������
	eAS_Idle_Special,		// NPC�������
	eAS_Idle_Special_Loop,	// NPC�������ѭ��
	eAS_Die_Special,		// NPC���⵹��
	eAS_Dead_Special,		// NPC�����ɵ�
	eAS_Pace_Right,			// NPC�����ⲽ
	eAS_Pace_Left,			// NPC�����ⲽ
	eAS_Talk,

	eAS_Max
};

// ������������
enum EActionPlayMode
{
	eAPM_AllBodyLoop,		// ȫ��ѭ��
	eAPM_AllBodyOnce,		// ȫ��һ��
	eAPM_UpBodyOnce			// ����һ��
};

// �����������ȼ�
enum EActionPlayPriority
{
	eAPP_NULL	= 0,
	eAPP_DeathAction,		// ��������
	eAPP_CoerceAction,		// ǿ�ƶ���
	eAPP_SkillAction,		// ���ܶ���
	eAPP_AttackAction,		// ��������
	eAPP_SufferAction,		// ��������
	eAPP_MoveStopAction,	// �ƶ�����
	eAPP_SwitchAction,		// �л�����
	eAPP_SpecialAction,		// ���⶯��
	eAPP_Max,
};

enum EFxType
{
	eFT_None,
	eFT_Leading,			//������Ч
	eFT_Suffer,				//�ܻ���Ч
	eFT_Local,				//������Ч
	eFT_LineDirection,	//���߷�����Ч
};

enum EWeaponPlayType
{
	eWPT_None,				// �ޱ���
	eWPT_Always,			// һ������ѭ����
	eWPT_BattleChange,		// ����ս��ת�䶯��
};

// �ƶ���ʽ
enum EMoveMode
{
	eMM_Run,
	eMM_WalkBack,
};
