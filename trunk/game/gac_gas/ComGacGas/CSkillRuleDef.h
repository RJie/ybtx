#pragma once

enum ESRTargetType
{
	eSRTT_None,
	eSRTT_NoArg,							//�޲���	--------------	
	eSRTT_T_EnemyObject,					//���Ŀ��
	eSRTT_P_EnemyPostion,					//Ŀ��λ��
	eSRTT_T_Self,							//����
	eSRTT_P_SelfPosition,					//����λ��
	eSRTT_P_RandomEnemyPostion,				//���Ŀ��λ��
	eSRTT_T_NearestEnemy,					//�������
	eSRTT_P_NearestEnemyPos,				//�������λ��
	eSRTT_T_FarthestEnemy,					//��Զ����
	eSRTT_P_FarthestEnemyPos,				//��Զ����λ��
	eSRTT_T_RandomEnemy,					//���Ŀ��
	eSRTT_T_MaxHpEnemy,						//���Ѫ�����Ŀ��
	eSRTT_P_MaxHpEnemyPos,					//���Ѫ�����Ŀ��λ��
	eSRTT_T_MinHpEnemy,						//���Ѫ�����Ŀ��
	eSRTT_P_MinHpEnemyPos,					//���Ѫ�����Ŀ��λ��
	eSRTT_T_MaxMpEnemy,						//���ħ�����Ŀ��
	eSRTT_P_MaxMpEnemyPos,					//���ħ�����Ŀ��λ��
	eSRTT_T_MinMpEnemy,						//���ħ�����Ŀ��
	eSRTT_P_MinMpEnemyPos,					//���ħ�����Ŀ��λ��
	eSRRT_OneArg,							//һ������  ----------------
	eSRTT_P_SelfDirection,					//������
	eSRTT_P_SelfReverseDirection,			//������
	eSRTT_T_RandomFriend,					//����ѷ�Ŀ��
	eSRTT_P_RandomFriendPos,				//����ѷ�Ŀ��λ��
	eSRTT_P_RandomDirection,				//�������
	eSRTT_T_NearestFriend,					//����ѷ�
	eSRTT_P_NearestFriendPos,				//����ѷ�λ��
	eSRTT_T_FarthestFriend,					//��Զ�ѷ�
	eSRTT_P_FarthestFriendPos,				//��Զ�ѷ�λ��
	eSRTT_T_RandomUnEnmity,					//�ǳ��Ŀ�����Ŀ��
	eSRTT_P_RandomUnEnmityPos,				//�ǳ��Ŀ�����Ŀ��λ��
	eSRTT_T_RandomUnServant,				//���ٻ������Ŀ��
	eSRTT_P_RandomUnServantPos,				//���ٻ������Ŀ��λ��
	eSRTT_T_RamdomUnEnmityUnServant,		//�ǳ��Ŀ����ٻ������Ŀ��
	eSRTT_P_RamdomUnEnmityUnServantPos,		//�ǳ��Ŀ����ٻ������Ŀ��λ��
	eSRTT_T_MaxHpFriend,					//���Ѫ���ѷ�
	eSRTT_P_MaxHpFriendPos,					//���Ѫ���ѷ�λ��
	eSRTT_T_MinHpFriend,					//���Ѫ���ѷ�
	eSRTT_P_MinHpFriendPos,					//���Ѫ���ѷ�λ��
	eSRTT_T_MaxMpFriend,					//���ħ���ѷ�
	eSRTT_P_MaxMpFriendPos,					//���ħ���ѷ�λ��
	eSRTT_T_MinMpFriend,					//���ħ���ѷ�
	eSRTT_P_MinMpFriendPos,					//���ħ���ѷ�λ��
	eSRTT_TwoArg,							//��������		-----------------------
	eSRTT_P_AroundPos,						//��Χ�ص�
	eSRTT_P_RandomPos,						//���λ��
	eSRTT_End,								//				-----------------------
};

enum ERCondType
{
	eRCT_None,
	eRCT_HpGreater,						//��������
	eRCT_HpLesser,						//��������
	eRCT_HpFirstGreater,				//�����״θ���
	eRCT_HpFirstLesser,					//�����״ε���
	eRCT_MpGreater,						//ħ������
	eRCT_MpLesser,						//ħ������
	eRCT_MpFirstGreater,				//ħ���״θ���
	eRCT_MpFirstLesser,					//ħ���״ε���
	eRCT_EnterBattle,					//����ս��
	eRCT_BeHurtValueGreater,			//�˺�����
	eRCT_RandomRate,					//���
	eRCT_BattleTimeGreater,				//ս��ʱ�䳬��
	eRCT_OnDeadCond,					//�����ͷ�
	eRCT_OnTimingCond,					//��ʱ
	eRCT_RangeTimingCond,				//��Χ��ʱ
	eRCT_PhaseTimeGreater,				//�׶�ʱ�䳬��
	eRCT_EnterPhase,					//����׶�
	eRCT_EnterWander,					//�������״̬
	eRCT_WanderTimeGreater,				//����ʱ�䳬��
	eRCT_EnemyDead,						//��������

	eRCT_End,
};

enum ESkillRuleTypeName
{
	eSKRT_None,
	eSKRT_Normal,				//��ͨ����
	eSKRT_PhaseChange,			//�л��׶�
	eSKRT_TargetChange,			//����ı�Ŀ��
	eSKRT_NotNpcTargetChange,	//����ı��npcĿ��
	eSKRT_Exclaim,				//����
	eSKRT_GoBackExclaim,		//���غ���
	eSKRT_CMultiSkill,			//��ѡһ
	eSKRT_SkillAround,			//��Χ�ص��ͷż���
	eSKRT_Exclaim_NoEffect,		//����Ч����
	eSKRT_AlertExclaim,			//���Ⱦ���
	eSKRT_DoSceneSkill,			//���������ͷ�
	eSKRT_DoSkillOnStateCond,	//״̬����ʩ��

	ESKRT_End,
};

enum ERuleCondKind
{
	eRCK_Begin,
	eRCK_Continue,
};

enum ESkillRuleKind
{
	eSRK_Wander,
	eSRK_FightPhase,
	eSRK_Fight,
	eSRK_Dead,
};

enum ERuleSkillType
{
	ERuleSkillType_None,
	ERuleSkillType_Target,
	ERuleSkillType_Pos,
};

enum EDoSkillType
{
	EDoSkillType_None,
	EDoSkillType_DirectDo,
	EDoSkillType_MoveDo,
	EDoSkillType_BackDo,
};

