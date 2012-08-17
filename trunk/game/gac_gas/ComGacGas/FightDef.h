#pragma once

/*
* =======================================================
*						��ɫ���
* =======================================================
*/

#if !defined _FightSkillCounter
	//#define _FightSkillCounter
#endif

enum EBroadcastArea{ eSyncSight = 0, eViewSight, eOnlyToDirector};

enum ETeamType
{
	eTT_Team=1,
	eTT_Raid
};

// ��ɫ�¼�
enum ECharacterEvent			
{
	eCE_BeAttacked,	
	eCE_Attack,
	eCE_MoveBegan,				// ��ɫ��ʼ�ƶ�
	eCE_MoveEnd,
	eCE_MoveSuccess,
	eCE_MoveStop,
	eCE_Die,
	eCE_Offline,
	eCE_LevelChanged,			//��ɫ�ȼ��仯
	eCE_ChangeMapBegin,				//�л���ͼ��ʼ
	eCE_ChangeMapEnd,				// ��ɫ�л���ͼ
	eCE_Reborn,
	eCE_CancelCoerceMove,		// �ͻ���ȡ�������ǿ�Ƚ�ɫ�ƶ�			
	eCE_BeAttackedFromNotDot,
	eCE_EntryEnmity,			// �������б�
	eCE_BeInterrupted, 
	eCE_MovePathChange,
	eCE_CoreEvent,
	eCE_BeHurtFirstTime,		// ��һ�α��˺�(��Ѫ)
	eCE_Transport,				// ����
	eCE_BeforeDie,				// ����ǰ
	eCE_OnAniEnd,
	eCE_FinishDuel,
	eCE_BattleRelationChange,	//ս����ϵ�ı�
	eCE_DebaseEnmity,			//���ͳ��
	eCE_Max,                    // ö�����ֵ
};

/*
* =======================================================
*						�������
* =======================================================
*/

// ����Ԫ��
enum EPropertyFactorType
{
	ePFT_Value,
	ePFT_Adder,
	ePFT_Multiplier,
	ePFT_Agile,
	ePFT_Count
};

// ����ID
enum EPropertyID
{
	// HealthPoint = 0, HealthPointAdder = 0 + 1, HealthPointMultiplier = 0 + 2, HealthPointAgile = 0 + 3
	ePID_HealthPoint,					// ���Ѫ��
	ePID_ManaPoint,						// �������
	ePID_ComboPoint,					// �������
	ePID_RagePoint,						// ���ŭ��
	ePID_EnergyPoint,					// �������

	ePID_AgileValueCount,				// AgileValue��CalcValue�Դ�Ϊ�ֽ���

	ePID_HPUpdateRate,					// ��Ѫ��
	ePID_MPUpdateRate,					// ��ħ��
	ePID_RPUpdateValue,					// ��ŭֵ
	ePID_EPUpdateValue,					// ����ֵ
	ePID_RevertPer,						// ս��״̬�ظ��ٶ� = RevertPer * ��ս��״̬�ظ��ٶ�
	ePID_MPConsumeRate,					// ħ������ϵ��
	ePID_RPConsumeRate,					// ŭ������ϵ��
	ePID_EPConsumeRate,					// ��������ϵ��

	ePID_NatureMPConsumeRate,			// ��Ȼϵħ������ϵ��
	ePID_DestructionMPConsumeRate,		// �ƻ�ϵħ������ϵ��
	ePID_EvilMPConsumeRate,				// �ڰ�ϵħ������ϵ��

	ePID_RPProduceRate,					// ŭ������ϵ��

	ePID_RunSpeed,						// �ƶ��ٶ�
	ePID_WalkSpeed,						// �����ٶ�

	ePID_StrikeMultiValue,				//�������ޣ������˺�����ֵ��
	ePID_StrikeValue,					//����ֵ�����ڼ��㱬���ʣ�

	ePID_Defence,						//���ף�����ֵ��
	ePID_BlockRate,						//���Ƹ��ʣ��޶���ʱΪ0
	ePID_BlockDamage,					//�������ܸ񵲵����˺�
	ePID_PhysicalDodgeValue,			//���������ֵ�����ڼ�������������ʣ�
	ePID_MagicDodgeValue,				//�������ֵ�����ڼ��㷨������ʣ�
	ePID_MagicHitValue,					//ħ������ֵ�����ڼ���ħ�������ʣ�
	ePID_MissRate,						//δ�����ʣ��κι�������һ�������޷����У�

	ePID_ImmuneRate,					//�����ʣ������޵�Ч����
	ePID_PunctureDamageImmuneRate,		//�����˺�������
	ePID_ChopDamageImmuneRate,			//����˺�������
	ePID_BluntDamageImmuneRate,			//�ۻ��˺�������
	ePID_NatureDamageImmuneRate,		//��Ȼ�˺�������
	ePID_DestructionDamageImmuneRate,	//�ƻ��˺�������
	ePID_EvilDamageImmuneRate,			//�����˺�������
	ePID_ControlDecreaseImmuneRate,		//����״̬������
	ePID_PauseDecreaseImmuneRate,		//����״̬������
	ePID_CripplingDecreaseImmuneRate,	//����״̬������
	ePID_DebuffDecreaseImmuneRate,		//����״̬������
	ePID_DOTDecreaseImmuneRate,			//�˺�״̬������
	ePID_SpecialDecreaseImmuneRate,		//����״̬������
	ePID_CureImmuneRate,				//����������
	ePID_MoveMagicImmuneRate,			//λ��ħ��������
	ePID_NonTypePhysicsDamageImmuneRate,	//�����������˺�������
	ePID_NonTypeDamageImmuneRate,			//�������˺�������
	ePID_NonTypeCureImmuneRate,			//����������������
	ePID_InterruptCastingProcessImmuneRate,			//�������������

	ePID_ParryValue,					//�м�ֵ�����ڼ����м��ʣ�
	ePID_ResilienceValue,				//����ֵ
	ePID_StrikeResistanceValue,					//�ⱬֵ
	ePID_AccuratenessValue,				//��ȷֵ
	ePID_PhysicalDPS,					//������������DPS��
	ePID_PunctureDamage,				//�����˺���ÿ�ν��д��̹���ʱ���ӵ��˺�ֵ��
	ePID_ChopDamage,					//�����˺���ÿ�ν��п��乥��ʱ���ӵ��˺�ֵ��
	ePID_BluntDamage,					//�ۻ��˺���ÿ�ν��ж�������ʱ���ӵ��˺�ֵ��

	ePID_MagicDamageValue,				//���˼ӳɣ����ڼ��㷨�������˺�ֵ��
	ePID_NatureDamageValue,				//��Ȼ�������˼ӳɣ����ڼ�����Ȼ���������˺�ֵ��
	ePID_DestructionDamageValue,		//�ƻ��������˼ӳɣ����ڼ����ƻ����������˺�ֵ��
	ePID_EvilDamageValue,				//�ڰ��������˼ӳɣ����ڼ���ڰ����������˺�ֵ��

	ePID_NatureResistanceValue,			//��Ȼ�����ֿ�ֵ�����ڼ�����Ȼ�����ֿ��ʣ�
	ePID_DestructionResistanceValue,	//�ƻ������ֿ�ֵ�����ڼ����ƻ������ֿ��ʣ�
	ePID_EvilResistanceValue,			//�ڰ������ֿ�ֵ�����ڼ���ڰ������ֿ��ʣ�

	ePID_NatureDecreaseResistanceValue,			//��Ȼ����ֵ�����ڴ�͸���ձ������㣩
	ePID_DestructionDecreaseResistanceValue,	//�ƻ�����ֵ�����ڴ�͸���ձ������㣩
	ePID_EvilDecreaseResistanceValue,			//�ڰ�����ֵ�����ڴ�͸���ձ������㣩
	ePID_DefencePenetrationValue,				//���״�͸ֵ�����ڴ�͸���ձ������㣩
	ePID_ValidityCoefficient,					//��Ч��ϵ�������ڴ�͸���ձ������㣩
	ePID_PenetrationFinalRate,			//��͸���ձ���

	ePID_PhysicalDamage,				//���ܸ��������˺������������߼�����װ���ṩ��
	ePID_AssistPhysicalDamage,			//���ܸ��������˺������������߼�����װ���ṩ��
	ePID_MagicDamage,					//���ܸ��ӷ����˺����ɷ������߼�����װ���ṩ��
	ePID_DOTDamage,						//���ܸ���DOT�˺�

	ePID_MainHandMinWeaponDamage,		//����������С�˺����������ṩ��
	ePID_MainHandMaxWeaponDamage,		//������������˺����������ṩ��

	ePID_AssistantMinWeaponDamage,		//����������С�˺����������ṩ��
	ePID_AssistantMaxWeaponDamage,		//������������˺����������ṩ��

	ePID_MainHandWeaponInterval,		//������������������������ṩ��
	ePID_AssistantWeaponInterval,		//������������������������ṩ��
	ePID_MHWeaponIntervalExtraDamageRate,		//����������������˺�����ϵ�����������ṩ��
	ePID_AHWeaponIntervalExtraDamageRate,		//����������������˺�����ϵ�����������ṩ��

	ePID_ResistCastingInterruptionRate,	//ʩ�����̿��ж���
	
	ePID_PenetrationValue,				//��͸ֵ,��е&����ר��
	ePID_ProtectionValue,				//����ֵ,��е&����ר��

	ePID_PunctureDamageResistanceRate,	//�����˺��������
	ePID_ChopDamageResistanceRate,		//����˺��������
	ePID_BluntDamageResistanceRate,		//�ۻ��˺��������

	ePID_ExtraDOTDamageRate,			//���ո���DOT�˺��ӳɱ���
	ePID_ExtraPunctureDamageRate,		//���ո��Ӵ����˺��ӳɱ���
	ePID_ExtraChopDamageRate,			//���ո��ӿ���˺��ӳɱ���
	ePID_ExtraBluntDamageRate,			//���ո��Ӷۻ��˺��ӳɱ���
	ePID_ExtraNatureDamageRate,			//���ո�����Ȼ�˺��ӳɱ���
	ePID_ExtraEvilDamageRate,			//���ո��Ӱ����˺��ӳɱ���
	ePID_ExtraDestructionDamageRate,	//���ո����ƻ��˺��ӳɱ���
	ePID_ExtraBowDamageRate,			//���ո��ӹ������˺��ӳɱ���
	ePID_ExtraCrossBowDamageRate,		//���ո����������˺��ӳɱ���
	ePID_ExtraTwohandWeaponDamageRate,	//���ո���˫�������˺��ӳɱ���
	ePID_ExtraPolearmDamageRate,		//���ո��ӳ��������˺��ӳɱ���
	ePID_ExtraPaladinWeaponDamageRate,	//���ո�����ʿ�����˺��ӳɱ���
	ePID_ExtraAssistWeaponDamageRate,	//���ո��Ӹ��������˺��ӳɱ���
	ePID_ExtraLongDistDamageRate,		//���ո���Զ�������˺��ӳɱ���
	ePID_ExtraShortDistDamageRate,		//���ո��ӽ��������˺��ӳɱ���
	ePID_DamageDecsRate,				//�����˺��������
	ePID_ExtraCureValueRate,			//��������ֵ�ӳɱ���
	ePID_ExtraBeCuredValueRate,			//���ձ�����ֵ�ӳɱ���
	ePID_ExtraPhysicDefenceRate,		//������������ʼӳɱ���
	ePID_ExtraPhysicDodgeRate,			//�����������ʼӳɱ���
	ePID_ExtraParryRate,				//�����м��ʼӳɱ���
	ePID_ExtraStrikeRate,				//���ձ����ʼӳɱ���
	ePID_ExtraMagicDodgeRate,			//���շ�����ܼӳɱ���
	ePID_ExtraMagicResistanceRate,		//���շ����ֿ��ʼӳɱ���
	ePID_ExtraNatureResistanceRate,		//������Ȼ�����ֿ��ʼӳɱ���
	ePID_ExtraDestructionResistanceRate,//�����ƻ������ֿ��ʼӳɱ���
	ePID_ExtraEvilResistanceRate,		//���հ��ڷ����ֿ��ʼӳɱ���
	ePID_ExtraCompleteResistanceRate,	//���շ�����ȫ�ֿ��ʼӳɱ���
	ePID_LongDistWeaponDamageRate,		//Զ�����������˺���������

	ePID_ControlDecreaseResistRate,		//���ƿ���
	ePID_PauseDecreaseResistRate,		//������
	ePID_CripplingDecreaseResistRate,	//���ٿ���
	ePID_DebuffDecreaseResistRate,		//Debuff����
	ePID_DOTDecreaseResistRate,			//DOT����
	ePID_SpecialDecreaseResistRate,		//���⿹��

	ePID_ControlDecreaseTimeRate,		//����ʱ��ϵ��
	ePID_PauseDecreaseTimeRate,			//����ʱ��ϵ��
	ePID_CripplingDecreaseTimeRate,		//����ʱ��ϵ��
	ePID_SpecialDecreaseTimeRate,		//����ʱ��ϵ��
	
	ePID_CastingProcessTimeRatio,		//ʩ������ʱ��ϵ��
	ePID_NatureSmashValue,				//��Ȼ��ѹֵ
	ePID_DestructionSmashValue,			//�ƻ���ѹֵ
	ePID_EvilSmashValue,				//������ѹֵ
	ePID_DefenceSmashValue,				//������ѹֵ
	ePID_ExtraSmashRate,				//���ո�����ѹ����

	ePID_Count							//���Ը���
};

// ��չ��������ID
enum EMethodAttrID
{
	eMAID_Begin = ePID_Count * ePFT_Count,
	eMAID_NADamage,						//�չ��˺�
	eMAID_FighterLevel,					//����ȼ�
	eMAID_MainHandWeaponIsSingle,		//���������Ƿ���
	eMAID_End,
	eMAID_Undefined,					//δ����
};



// �ױ���������
enum EAgileType
{
	eAT_HP=1,	//����
	eAT_MP,		//ħ��	
	eAT_RP,		//ŭ��
	eAT_EP,		//����
	eAT_CP,		//������
};

// ��������
enum EAttackType
{
	eATT_None,			// �޹�������
	eATT_FollowWeapon,	// ������������
	eATT_Puncture,		// ����
	eATT_Chop,			// ���
	eATT_BluntTrauma,	// �ۻ�	
	eATT_Nature,		// ��Ȼ
	eATT_Destroy,		// �ƻ�
	eATT_Evil,			// ����
	eATT_TaskNonBattle,	// �����ս��
	eATT_TaskBomb,		// ����ը��
	eATT_TaskSpecial,	// ��������
	eATT_TaskNonNationBattleBuild,		//�ǹ�ս�����˺�
	eATT_End			// ����
};

//������ȴ����
enum ESkillCoolDownType
{
	eSCDT_FightSkill,		//ս������,����1�빫����ȴʱ��	
	eSCDT_NoComCDFightSkill,//�޹���CDս������
	eSCDT_PublicSkill,		//��������,û����ȴʱ��,��������ͨ����ʹ��
	eSCDT_DrugItemSkill,	//ҩƷ����,�ظ������С�๫����ȴʱ��,��������ͨ����ʹ��
	eSCDT_SpecialItemSkill,	//��������Ʒ����, �����������Ĺ�����ȴʱ��,��������ͨ����ʹ��
	eSCDT_OtherItemSkill,	//������Ʒ����, ֻ����1�빫����ȴʱ��,��������ͨ����ʹ��
	eSCDT_TempSkill,		//��ʱ����,û����ȴʱ��
	eSCDT_UnrestrainedSkill,//�����Ƽ���,����ȴ,��ֹʹ�ü�����Ч
	eSCDT_OtherSkill,		//��������,û�й�����ȴʱ��,�����������Ĺ�����ȴʱ��
	eSCDT_NonFightSkill,	// ��ս������,��������
	eSCDT_EquipSkill,		//װ������
	eSCDT_UnrestrainedFightSkill,	//������ս������
	eSCDT_End
};
// ��������
//����ö��ֵ��λ��ʱ��ͬʱ�޸������ȫ�ֺ���
enum EWeaponType
{
	eWT_None,

	eWT_Shield,			//����

	eWT_SHSword,		//���ֽ�
	eWT_SHAxe,			//���ָ�
	eWT_SHHammer,		//���ִ�
	eWT_SHKnife,		//���ֵ�	

	eWT_THSword,		//˫�ֽ�
	eWT_THAxe,			//˫�ָ�
	eWT_THHammer,		//˫�ִ�

	eWT_PaladinGun,		//��ʿǹ
	eWT_Lance,			//��ì
	eWT_LongKnife,		//����
	eWT_LongStick,		//����

	// ����ź��棬����eWeaponType > eWT_LongStick���ж��Ƿ���Զ������
	eWT_Bow,			//˫�ֹ�
	eWT_CrossBow,		//˫����
	eWT_SHWand,			//������
	eWT_THWand,			//˫����

	eWT_End,
};

inline bool IsLongDistWeapon(EWeaponType eWeaponType)
{
	if(eWeaponType >= eWT_Bow && eWeaponType <= eWT_THWand)
		return true;
	return false;
}

inline bool IsPolearmWeapon(EWeaponType eWeaponType)
{
	if(eWeaponType >= eWT_PaladinGun && eWeaponType <= eWT_LongStick)
		return true;
	return false;
}

//�Ƿ�Ϊ˫������
inline bool IsShortDistTwoHandsWeapon(EWeaponType eWeaponType)
{
	if(eWeaponType == eWT_THSword || eWeaponType == eWT_THAxe || eWeaponType == eWT_THHammer)
		return true;
	return false;
}

//bool IsSingleHandWeapon(EWeaponType eWeaponType)
//{
//}

inline bool IsSingleHandsWeapon(EWeaponType eWeaponType)
{
	switch(eWeaponType)
	{
	case eWT_Shield:
	case eWT_SHSword:
	case eWT_SHAxe:
	case eWT_SHHammer:
	case eWT_SHKnife:
	case eWT_SHWand:
		return true;
	default:
		break;
	}
	return false;
}

inline bool IsTwoHandsWeapon(EWeaponType eWeaponType)
{
	if(eWeaponType == eWT_None)
		return false;
	return !IsSingleHandsWeapon(eWeaponType);
}

// ս������״̬
enum EFighterCtrlState
{
	eFCS_None					= 0x00000000,

	eFCS_InNormalHorse			= 0x00000001,		// �����ͨ����
	eFCS_InBattleHorse			= 0x00000002,		// ���ս������	
	eFCS_FeignDeath				= 0x00000004,		// ����
	eFCS_InBattle				= 0x00000008,		// ս��״̬
	eFCS_OnMission				= 0x00000010,		// �淨״̬��
	eFCS_InDuel					= 0x00000020,		// ����״̬
	eFCS_InWalkState			= 0x00000040,		// ��·״̬		,���߶���״̬
	eFCS_InDrawWeaponMode		= 0x00000080,		// �հ�����״̬	,���߶���״̬
	eFCS_AllowChangeDirection	= 0x00000100,		// ��ֹ��ͽ�ֹ�ƶ�������ı䷽��
	eFCS_InNormalAttacking		= 0x00000200,		// �����չ�׷��
	eFCS_ForbitAutoTrack		= 0x00000400,		// ��ֹ�ͻ����Զ�׷��

	eFCS_CountCtrlValueBegin	= 0x00010000,	
	eFCS_ForbitNormalAttack		= 0x00020000,		// ��ֹ��ͨ����
	eFCS_ForbitMove				= 0x00040000,		// ��ֹ�ƶ�
	eFCS_ForbitTurnAround		= 0x00080000,		// ��ֹת��
	eFCS_ForbitUseWeapon		= 0x00100000,		// ��е
	eFCS_Max					= 0x40000000,
};

/*
* =======================================================
*						�������
* =======================================================
*/

//����ʹ��״̬(InDoingSkill && ������)
enum EDoSkillCtrlState
{
	eDSCS_None,
	eDSCS_InDoingSkill,					// ����ʹ�ü���

	eDSCS_CountBegin,
	eDSCS_ForbitUseSkill,				// ��ֹʹ�ü���
	eDSCS_ForbitNatureMagic,			// ��ֹʹ����Ȼϵ����
	eDSCS_ForbitDestructionMagic,		// ��ֹʹ���ƻ�ϵ����
	eDSCS_ForbitEvilMagic,				// ��ֹʹ�ð���ϵ����
	eDSCS_ForbitUseClassSkill,			// ��ְֹҵ����
	eDSCS_ForbitUseDrugItemSkill,		// ��ֹҩƷ��Ʒ����
	eDSCS_ForbitUseNonFightSkill,		// ��ֹ��ս������
	eDSCS_ForbitUseMissionItemSkill,	// ��ֹ�淨��Ʒ����
	eDSCS_Max,
};

// ��������
enum ESkillType
{
	eST_None,			// ������
	eST_Physical,		// ������
	eST_Magic,			// ħ������
	eST_DOT,			// DOT����
	eST_End,			// ����
};

// Inst���
enum EInstType
{
	eIT_None,
	eIT_SkillInst,
	eIT_StateInst,
	eIT_MagicStateInst,
	eIT_NormalAttackInst
};

enum ETalentType
{
	eTT_Class,
	eTT_Camp,
	eTT_Level,
	eTT_Skill,
	eTT_Equip,
};

enum ETalentRuleType
{
	eTRT_Stackup,	//����
	eTRT_Unique,	//Ψһ
	eTRT_Decentral, //��ɢ
};

// ����ʩ�Ž������ֵ
enum EDoSkillResult
{	
	eDSR_None		= 0,		// ʧ������ʾ
	eDSR_Success		= 1800,		// �����ͷųɹ�
	eDSR_Fail,						// �����ͷ�ʧ��
	eDSR_CharacterHasDead,			// ��ɫ����
	eDSR_NoSkill,					// �޴˼���
	eDSR_InCDTime,					// CDʱ��δ��
	eDSR_DoingOtherSkill,			// ����ʩ����������
	eDSR_ForbitUseSkill,			// ��ֹʩ�ż���
	eDSR_TargetNotExist,			// Ŀ�겻����
	eDSR_TargetIsDead,				// Ŀ��������
	eDSR_TargetIsAlive,				// Ŀ�겻��ʬ��
	eDSR_TargetIsFriend,			// ���ܹ����ѷ�
	eDSR_TargetIsSelf,				// ���ܹ����Լ�
	eDSR_TargetIsEnemy,				// ����Э������
	eDSR_TargetIsNeutral,			// ����Ŀ�겻����ս��
	eDSR_SelfUnderPKLevel,			// �Լ��ȼ�����PK���ߵȼ�����������
	eDSR_TargetUnderPKLevel,		// Ŀ��ȼ�����PK���ߵȼ��������ո�
	eDSR_SelfBeyondLv,				// Ŀ��ȼ�����
	eDSR_TargetBeyondLv,			// Ŀ��ȼ�����
	eDSR_SelfSafetyState,			// �Լ����ڰ�ȫ״̬���޷�����
	eDSR_TargetSafetyState,			// Ŀ�괦�ڰ�ȫ״̬���޷�����
	eDSR_CanNotAssist,				// �Լ����ڰ�ȫ״̬���޷�Э���Կ�״̬Ŀ��
	eDSR_TargetInDuel,				// Ŀ�괦�ھ���״̬�����ܽ��иò���
	eDSR_DuelTargetWrong,			// �㴦����ս״̬�У�Ŀ��ѡ�����
	eDSR_ToTargetHaveBarrier,		// ����Ŀ�����ϰ�
	eDSR_OutOfDistance,				// ����ʩ������
	eDSR_NotEnoughDistance,			// ����ʩ������
	eDSR_HealthPointIsGreater,		// ����ֵ���ߣ�����������	
	eDSR_HealthPointIsLesser,		// ����ֵ���ͣ�����������		
	eDSR_ManaPointIsLesser,			// ħ��ֵ���ͣ�����������
	eDSR_EnergyPointIsLesser,		// ����ֵ���ͣ�����������
	eDSR_RagePointIsLesser,			// ŭ��ֵ���ͣ�����������
	eDSR_ComboPointIsLesser,		// ��������ͣ�����������	
	eDSR_NotInTheMagicState,		// �����㴦��ħ��״̬����
	eDSR_NotInTheTriggerState,		// �����㴦�ڴ�����״̬����
	eDSR_NotInTheDamageChangeState,	// �����㴦���˺����״̬����
	eDSR_NotInTheSpecialState,		// �����㴦������״̬����
	eDSR_NotInTheStanceSkill,		// �����㴦����̬��������
	eDSR_HaveNotShieldEquip,		// ������װ����������
	eDSR_HaveNotMainHandEquip,		// ������װ��������������
	eDSR_IsNotExistItem,			// ��������Ʒ��������
	eDSR_IsNotExistPet,				// �����������ڵ�����
	eDSR_IsNotExistTotem,			// ������ͼ�ڴ��ڵ�����
	eDSR_IsNotExistHorse,			// ������������ڵ�����
	eDSR_IsExistHorse,				// �����������ȡ��
	eDSR_IsNotInBattleSkill,		// �ü���ֻ���ڷ�ս��״̬ʹ��
	eDSR_NotEnoughMagicStateCascade,// û���㹻��ħ��״̬���Ӳ���
	eDSR_NormalAttackNotAllowed,	// ����ʩ�ż��ܣ����ܽ����չ�
	eDSR_ForbitUseClassSkill,		// ��ֹʹ��ְҵ����
	eDSR_ForbitUseNonFightSkill,	// ��ֹʹ�÷�ս������
	eDSR_SkillEndWithOutSing,
	eDSR_InDecreaseState,			// ���ڸ���״̬
	eDSR_CannotBeControll,			// Ŀ�겻�ܱ�����
	eDSR_IsNotNPC,					// Ŀ�겻��NPC
	eDSR_TargetLevelIsbigger,		// Ŀ��ȼ���������ȼ�
	eDSR_NotInNormalHorseState,		// ս������״̬
	eDSR_TargetIsNotRaidmates,		// Ŀ�겻���Ŷӳ�Ա
	eDSR_InSkillItemCDTime,			// ������Ʒδ��ȴ
	eDSR_UseSkillItemFail,			// ������Ʒʹ��ʧ��
	eDSR_InTheMagicState,			// �����㲻����ħ��״̬����
	eDSR_InTheDamageChangeState,	// �����㲻�����˺����״̬����
	eDSR_InTheSpecialState,			// �����㲻��������״̬����
	eDSR_AlreadyInTheMagicState,	// �����ظ�״̬,����ӵ�д�״̬�����ظ�ʹ��
	eDSR_SkillBeInterrupted,		// ���̼��ܱ����
	eDSR_CannotDoSkillToRivalry,	// ���ܶԶԿ�״̬�ѷ�ʹ�ô˼���
	eDSR_CannotBeRavin,				// Ŀ�겻�ܱ���ʳ
	eDSR_TargetIsFriendType,		// Ŀ�����ѷ������ͷŴ˼���
	eDSR_NowSceneForbidUse,			// ��ǰ�����������ͷ�
	eDSR_HaveNotAssistHandEquip,	// ������װ��������������
	eDSR_TargetNotTeammatesOrEnemy,	// Ŀ�겻�Ƕ��ѻ�з�Ŀ��
};

// ���ѹ�ϵ
enum ESimpleRelation
{
	eSR_None			= 0x0,		//   0 
	eSR_PlayerFriend	= 0x2,		//	10
	eSR_PlayerEnemy		= 0x3,		//	11
	eSR_NPCFriend		= 0x4,		// 100
	eSR_NPCEnemy		= 0x5,		// 101
	eSR_MonsterFriend	= 0x8,		//1000,  ����򱻿��ƵĹ���
	eSR_MonsterEnemy	= 0x9,		//1001,  ����
};

// Ŀ������
enum ETargetType
{
	eTT_None,
	eTT_Fighter,
	eTT_Position,
};

// �ͷż���Ŀ������
enum EFSTargetType
{
	eFSTT_None,					// ��Ŀ�꣬���ڳ�ʼ��
	eFSTT_Position,				// �յ�
	eFSTT_PositionOrFriend,		// �յػ��ѷ�Ŀ��
	eFSTT_PositionOrEnemy,		// �յػ�з�Ŀ��
	eFSTT_EnemyObject,			// �з�Ŀ��
	eFSTT_FriendObject,			// �ѷ�Ŀ��
	eFSTT_NeutralObject,		// ����Ŀ��
	eFSTT_ObjectPosition,		// Ŀ��λ��
	eFSTT_Self,					// ����
	eFSTT_SelfPosition,			// ����λ��
	eFSTT_SelfDirection,		// ������
	eFSTT_FriendandSelf,		// �ѷ�������
	eFSTT_AllObject,			// ����Ŀ��
	eFSTT_FriendAndEnemy,		// ����Ŀ��
	eFSTT_NotNeutral,			// ����������
	eFSTT_SelectFriendObject,	// ѡ���ѷ�Ŀ��
	eFSTT_PositionOrLockedTarget, // �յػ�����Ŀ��
	eFSTT_NotFriendObject,		//���ѷ�Ŀ��
	eFSTT_TeammatesOrEnemy,		//���ѻ�з�Ŀ��
	eFSTT_End,
};

// ѡ��ص�����
enum ESelectGroundType
{
	eSGT_GroundSelector,	//��Ȧѡ������
	eSGT_MouseSelector,		//���ѡ������
	eSGT_TargetSelector,	//Ŀ��ѡ������
};

// Ŀ��ɸѡ����
enum EObjFilterType
{
	eOF_None,
	// ������(��ʼ)
	eOF_Self,			// ����
	eOF_Target,			// Ŀ��
	eOF_Position,		// �ص�

	// �޲���ɸѡ
	eOF_Pet,			// ����
	eOF_NotCtrlSummon,	// �ǿ�������
	eOF_Master,			// ����
	eOF_DeadBody,		// ʬ��
	eOF_ExceptSelf,		// �Լ�����
	eOF_ExceptTarget,	// Ŀ�����
	eOF_IsVestInSelf,	// ��������
	eOF_ExpIsVestInSelf,// �����������
	eOF_LatestTarget,	// ���Ŀ��
	eOF_LeastHP,		// ����ֵ��С
	eOF_FilterPlayer,	// ɸѡ���
	eOF_ExpOwner,		// ȡĿ��ľ���ӵ����
	eOF_LockedEnemyTarget,	// ��ǰ�����з�Ŀ��

	// ����Χ����ɸѡ
	eOF_Teammates,		// С�ӳ�Ա
	eOF_Raidmates,		// �Ŷӳ�Ա
	eOF_Tongmates,		// Ӷ��С�ӳ�Ա
	eOF_AroundFriend,	// ��Χ�ѷ�
	eOF_AroundEnemy,	// ��Χ�з�

	// ����������ɸѡ
	eOF_Amount,			// ����
	eOF_FilterRandom,	// ���ɸѡ

	// ���ַ�������ɸѡ
	eOF_InTriggerState,	// ���ڴ�����״̬
	eOF_InMagicState,	// ����ħ��״̬
	eOF_NotInMagicState,// ������ħ��״̬
	eOF_OutSpecialState,// ����������״̬
	eOF_PosMagicTarget,	// �ص�ħ��Ŀ��
	eOF_Class,			// ְҵ

	// ���вο��޲�
	eOF_FilterNPC,		// ɸѡNPC
	eOF_ExceptDeadBoby,	// ʬ�����

	eOF_ShockWaveEff1,		// �����1
	eOF_ShockWaveEff2,		// �����2
	eOF_ShockWaveEff3,		// �����3
	eOF_ShockWaveEff4,		// �����4
	eOF_ShockWaveEff5,		// �����5

	// ������ͬ�����Ч��
	eOF_FilterResult,	// �ϴ�Ŀ��ɸѡ���
};

// ħ�����ö�������
enum EOperateObjectType
{
	eOOT_None,
	eOOT_Releaser,			// �ͷ���
	eOOT_Self,				// ����
	eOOT_Target,			// Ŀ��
	eOOT_Friend,			// �ѷ�
	eOOT_Enemy,				// �з�
	eOOT_FriendAndEnemy,	// ����Ŀ��
	eOOT_Teammates,			// С�ӳ�Ա
	eOOT_Raidmates,			// �Ŷӳ�Ա
	eOOT_Tongmates,			// Ӷ��С�ӳ�Ա
	eOOT_SelfMaster,		// ��������
	eOOT_TargetAroundEnemy,	// Ŀ����Χ�з�
	eOOT_SelfAndRaidmates,	// �ͷ��߼��Ŷӳ�Ա
};

// �˺����ͣ���Ҫ���ڿͻ��˽�ɫ��ͷ����ʾ��Ѫ����Ч����
enum EHurtResult
{
	eHR_Fail=0,		// ʧ��
	eHR_Success,	// �ɹ�
	eHR_Hit,		// ����--(����ħ�������ơ�Ч��)
	eHR_Miss,		// δ����--(����Ч��)
	eHR_Strike,		// ����--(����ħ��������)
	eHR_PhyDodge,	// ��������--(����)
	eHR_MagDodge,	// ħ������--(ħ��)
	eHR_Immune,		// ����(����ħ����DOT)
	eHR_Resist,		// �ֿ�--(ħ��)
	eHR_ComResist,	// ��ȫ�ֿ�--(ħ��)
	eHR_Parry,		// �м�--(����)
	eHR_Block,		// ��--(����)
	eHR_Hurt,		// �˺�
	eHR_SuckBlood,	// ��Ѫ
	eHR_EmptyAni,	// �չ������ӿ�
	eHR_HurtExptDOT,		//��DOT�˺�
	eSET_Attack,	// ����
	eSET_BeforeChangeHurt,			// ����ǰ�˺�
	eHR_End,
};

// ��������
enum EConsumeType	
{
	eCT_None,		// ������	
	eCT_HP,			// Ѫ��ֵ
	eCT_MP,			// ħ��ֵ
	eCT_RG,			// ŭ��ֵ
	eCT_EG,			// ����ֵ		
	eCT_CP			// ������
};

// ��������
enum ECastingProcessType
{
	eCPT_Wink,				// ˲��
	eCPT_Sing,				// ����	
	eCPT_Channel,			// ����
	eCPT_GradeSing,			// ��������
	eCPT_ImmovableSing		// Ӳֱ����
};

enum ECastingInterruptType
{
	eCIT_None,
	eCIT_Move,
	eCIT_TurnAround
};

// ��̬����
enum EStanceType
{
	eSS_Stance	=	1,	//��̬	
	eSS_MutexStance,	//������̬   
	eSS_Aure,			//�⻷
	eSS_Form,			//����
	eSS_Shield,			//��
	eSS_CascadeAure,	//���ӹ⻷
	eSS_InvisibleAure,	//���ι⻷

};

// ħ��״̬�����
enum EStateGlobalType
{
	eSGT_Undefined,
	eSGT_MagicState,
	eSGT_TriggerState,
	eSGT_DamageChangeState,
	eSGT_CumuliTriggerState,
	eSGT_SpecialState,
	eSGT_End
};

//����״̬����
enum ETriggerStateType
{
	eTST_All,
	eTST_Trigger,
	eTST_DamageChange,
	eTST_Special,
};

// ħ��״̬�����ʼֵ
enum EStateIdFloor
{
	eSIC_TriggerState		= 1,
	eSIC_DamageChangeState	= 10001,
	eSIC_CumuliTriggerState = 19001,
	eSIC_SpecialState		= 20001,
	eSIC_MagicState			= 30001,
	eSIC_DynamicMagicState	= 100001
};

// ״̬�ĸ���Ч������
enum EDecreaseStateType
{
	eDST_Null,					//������
	eDST_Riding,				//����
	eDST_FeignDeath,			//����
	eDST_Increase,				//����
	eDST_TouchBattleStateBegin,	//����ս��״̬�жϿ�ʼ�ֽ���
	//eDST_IncreaseTouchBattleState,	//�����ս��
	eDST_IncreaseEnd,			//�������ͽ����жϷֽ���
	eDST_Control,				//����
	eDST_Pause,					//����
	eDST_Crippling,				//����
	eDST_Debuff,				//����
	eDST_DOT,					//�˺�
	eDST_Special,				//����
};

// ħ��״̬���ӹ���
enum EReplaceRuler
{
	eRR_KeepCurState	= 0,	// ���ӵ����޲��ٵ��Ӻ���Ч��
	eRR_Refresh		= 1,		// ���ӹ����ۼ�Ч����ˢ��ʱ�䣬������ֻˢ��ʱ��
};

// ������ͨħ��״̬��Ⱥ���������
enum ECascadeType
{
	eCT_Central = 1,			// ����
	eCT_Decentral = 2,			// ��ɢ
	eCT_Unique = 3,				// Ψһ
	eCT_Share = 4,				// ���������ڼ��У������빲ͬ������

};

// ����ħ��״̬������
enum ESpecialStateType
{
	eSST_Reflect,				//����ħ��
	eSST_DOTImmunity,			//DOT����
	eSST_DirMove,				//�����ƶ�
	eSST_DeadBody
};

// ���ⴥ���¼�����
enum ESpecialEventType
{
	eSET_Start			= 0,		//ö�ٿ�ʼ����
	eSET_SubMP,						//����
	eSET_SubEP,						//������
	eSET_SubRP,						//��ŭ��
	eSET_SubCP,						//������
	eSET_Heal,						//����
	eSET_SuckBlood,					//��Ѫ
	eSET_HPChanged,					//����ֵ�ı�

	eSET_DoSkill,					// ʩ�ż���
	eSET_DoFightSkill,			//ʩ��ս������
	eSET_DoNatureMagic,				// ʩ����Ȼϵ����
	eSET_DoDestructionMagic,		// ʩ���ƻ�ϵ����
	eSET_DoEvilMagic,				// ʩ�Ű���ϵ����
	//eSET_Attack,					// ����
	eSET_ShortNormalAttack,			// ��ͨ����
	eSET_ShortNormalAttackDamage,
	eSET_NormalAttackStrike,
	eSET_ShortNormalAttackSingletonDamage,
	eSET_LongNormalAttackDamage,
	eSET_MainHandNADamage,
	eSET_InstallerDie,				//��װ������
	eSET_Kill,						//ɱ��ǰ
	eSET_Killed,					//ɱ����
	eSET_KillNPC,
	eSET_KillPlayer,
	eSET_KillByInstaller,			//����װ��ɱ��
	eSET_CancelSpecifiedNoSingTime,	//ָ����������ʱ������
	eSET_CancelAnyNoSingTime,		//�κ�������ʱ������
	eSET_LeftBattle,				//�뿪ս��
	eSET_EnterBattle,				//����ս��
	eSET_RagePointIsFull,			//��ŭ��
	eSET_DeadlyHurt,				//�����˺�����ǰ��
	eSET_Clear,						//��ʧǰ
	eSET_RemoveFromMaster,			//�����˽����ϵ
	eSET_AttackByEnemyObjectSkill,	//�������ܹ���,��������
	eSET_MoveBegin,					//��ʼ�ƶ�
	eSET_MoveEnd,					//ֹͣ�ƶ�
	eSET_WeaponModChange,			//����ģ�͸ı�
	eSET_SetupWeapon,				//װ������
	eSET_RemoveWeapon,				//��������
	eSET_ChangeEquip,				//����װ��
	eSET_SetupControlState,			
	eSET_SetupCripplingState,		
	eSET_SetupPauseState,	
	eSET_SetupSpecialState,		
	eSET_InterruptMopHit,					//���ʩ��(����)������
	//�����Ǹ�����״̬�õ�
	eSET_DirectionOrMoveSpeedChange,
	eSET_BeforeChangeHeal,			// ����ǰ����

	eSET_End			= 5000,		//ö�ٽ���������ʾö�ٵ�����
};

//״̬�ģ���ͼ�꣩ȡ������
enum EIconCancelCond
{
	eICC_None,				//�����˰�װ��״̬�����ɳ���
	eICC_Self,				//ֻ���Լ���װ״̬�Ŀ��Գ���
	eICC_All,				//�����˰�װ��״̬���ܳ���
	eICC_End
};

// ħ�������
enum EMagicGlobalType
{
	eMGT_Bullet,
	eMGT_ShockWave,
	eMGT_Transferable,
	eMGT_Position,
	eMGT_Move,
	eMGT_Aure,
	eMGT_BattleArray,
	eMGT_Barrier
};

//��״̬
enum EBattleArrayState
{
	eBAS_None=0,
	eBAS_InArray,
	eBAS_OutArray,
	eBAS_ReturnArray,
	eBAS_FinishArray
};


// �ӵ��켣����
enum EBulletTrackType			
{
	eBTT_Line		=1,			// ƽ��
	eBTT_Random,				// ����ƶ�
	eBTT_Parabola,				// ������
	eBTT_MarblesSoul,			// ���򱬻�
};


// ��������
enum EBurstSoulType
{
	eBST_Normal=1,
	eBST_Skill,
	eBST_Quest,
};
/*
* =======================================================
*					�����ٻ������
* =======================================================
*/

// ��������
enum EPetType
{
	EPT_SUMMON= 1,
	EPT_PET, 
	EPT_GUARDIAN,          
	EPT_MINI      
};

// ����״̬
enum EPetState
{
	EPS_Attack= 1,
	EPS_Defense,   
	EPS_Passivity 
};

// �����ƶ�״̬
enum EPetMoveState
{
	EPMS_Attack= 1,
	EPMS_Follow,   
	EPMS_Stay 
};

// ս����ϢIndex
enum EFightInfoIndex
{
	EFII_Hurt = 1,
	EFII_StrikeHurt,
	EFII_Miss,
	EFII_Resist,
	EFII_Parry,
	EFII_Dodge,
	EFII_SetUpState,
	EFII_ClearState,
	EFII_Block,
	EFII_ComResist,
	EFII_Immune,
	EFII_NonTypeAttackHit,
	EFII_StateEffectHit,
	EFII_MultiAbsorb,
	EFII_Heal,
	EFII_StrikeHeal,
	EFII_DoSkill,
	EFII_DoPosSkill,
	EFII_RenewMP,
	EFII_ConsumeMP,
	EFII_LostMP,
	EFII_ConsumeHP,
	EFII_SuccessDoCasting,
	EFII_InterruptCasting,
	EFII_RenewRP,
	EFII_Die,
	EFII_ConsumeRP,
	EFII_AddBurstSoulTimes,
	EFII_LostRP,
	EFII_StateEffectStrikeHit,
};

//״̬ǿ�ƴ�����
enum EForceSaveOrForceNoSave
{
	eFSOFNS_ForceNoSave,
	eFSOFNS_ForceOfflineSave,
	eFSOFNS_ForceOnTickSave
};

/*
* =======================================================
*					��ս����Ϊ���
* =======================================================
*/
enum NonCombatBehavior
{
	nCB_ItemSkill= 1,
	nCB_ExpModulusChange,
	nCB_ExpModulusInFBChange,
	nCB_FetchModulusChange,
	nCB_Max
};

enum EAlterNormalAttackType
{ 
	eANAT_NoChange, 
	eANAT_StartAndAutoTrack, 
	eANAT_Start, 
	eANAT_AbsolutelyStartAndAutoTrack, 
	eANAT_AbsolutelyStart, 
	eANAT_Cancel,
	eANAT_End
};
