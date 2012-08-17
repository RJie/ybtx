#include "stdafx.h"
#include "CTriggerEvent.h"

uint32 CTriggerEvent::GetID(EHurtResult eArg1, bool bArg2, ESkillType eArg3, EAttackType eArg4)
{
	return eSET_End * 2
		+ eArg1 * 2 * eST_End * eATT_End
		+ bArg2 * eST_End * eATT_End
		+ eArg3 * eATT_End
		+ eArg4;
}

uint32 CTriggerEvent::GetID(ESpecialEventType eArg1, bool bArg2)
{
	return eArg1 + bArg2 * eSET_End;
}

CTriggerEvent::MapHurtResult		CTriggerEvent::m_smapEHurtResult;
CTriggerEvent::MapSkillType			CTriggerEvent::m_smapESkillType;
CTriggerEvent::MapAttackType		CTriggerEvent::m_smapAttackType;
CTriggerEvent::MapSpecialEventType	CTriggerEvent::m_smapESpecialEventType;
bool CTriggerEvent::__init = CTriggerEvent::BuildMap();

bool CTriggerEvent::BuildMap()
{
	//�˺��������
	AddEvent("ʧ��", eHR_Fail);
	AddEvent("�ɹ�", eHR_Success);
	AddEvent("δ����", eHR_Miss);
	AddEvent("��������", eHR_PhyDodge);
	AddEvent("ħ������", eHR_MagDodge);
	AddEvent("�м�", eHR_Parry);
	AddEvent("��", eHR_Block);
	AddEvent("��ȫ�ֿ�", eHR_ComResist);
	AddEvent("�ֿ�", eHR_Resist);
	AddEvent("����", eHR_Strike);
	AddEvent("����", eHR_Hit);
	AddEvent("�˺�", eHR_Hurt);
	AddEvent("��DOT�˺�", eHR_HurtExptDOT);
	AddEvent("����", eSET_Attack);
	AddEvent("����", eHR_Immune);
	AddEvent("����ǰ�˺�", eSET_BeforeChangeHurt);

	//��������
	AddEvent("", eST_None);
	AddEvent("����", eST_Physical);
	AddEvent("ħ��", eST_Magic);

	//��������
	AddEvent("", eATT_None);
	AddEvent("����", eATT_Puncture);
	AddEvent("���", eATT_Chop);
	AddEvent("�ۻ�", eATT_BluntTrauma);
	AddEvent("��Ȼ", eATT_Nature);
	AddEvent("�ƻ�", eATT_Destroy);
	AddEvent("����", eATT_Evil);

	//��������
	AddEvent("����", eSET_SubMP);
	AddEvent("������", eSET_SubEP);
	AddEvent("��ŭ��", eSET_SubRP);
	AddEvent("������", eSET_SubCP);
	AddEvent("����", eSET_Heal);
	AddEvent("��Ѫ", eSET_SuckBlood);
	AddEvent("����ǰ����", eSET_BeforeChangeHeal);
	AddEvent("ʩ�ż���", eSET_DoSkill);
	AddEvent("ʩ��ս������", eSET_DoFightSkill);
	AddEvent("ʩ����Ȼϵ����", eSET_DoNatureMagic);
	AddEvent("ʩ���ƻ�ϵ����", eSET_DoDestructionMagic);
	AddEvent("ʩ�Ű���ϵ����", eSET_DoEvilMagic);
	AddEvent("����ֵ�ı�", eSET_HPChanged);
	AddEvent("������ͨ����", eSET_ShortNormalAttack);
	AddEvent("������ͨ�����˺�", eSET_ShortNormalAttackDamage);
	AddEvent("��ͨ��������", eSET_NormalAttackStrike);
	AddEvent("������ͨ���������˺�", eSET_ShortNormalAttackSingletonDamage);
	AddEvent("Զ����ͨ�����˺�", eSET_LongNormalAttackDamage);
	AddEvent("������ͨ�����˺�", eSET_MainHandNADamage);
	AddEvent("��װ������", eSET_InstallerDie);
	AddEvent("ɱ��ǰ", eSET_Kill);
	AddEvent("ɱ����", eSET_Killed);
	AddEvent("ɱ��NPC", eSET_KillNPC);
	AddEvent("ɱ��Player", eSET_KillPlayer);
	AddEvent("����װ��ɱ��", eSET_KillByInstaller);
	AddEvent("�뿪ս��", eSET_LeftBattle);
	AddEvent("����ս��", eSET_EnterBattle);
	AddEvent("ָ����������ʱ������", eSET_CancelSpecifiedNoSingTime);
	AddEvent("�κ�������ʱ������", eSET_CancelAnyNoSingTime);
	AddEvent("��ŭ��", eSET_RagePointIsFull);
	AddEvent("�����˺�", eSET_DeadlyHurt);
	AddEvent("��ʧǰ", eSET_Clear);
	AddEvent("�����˽����ϵ", eSET_RemoveFromMaster);
	AddEvent("�������ܹ���", eSET_AttackByEnemyObjectSkill);
	AddEvent("��ʼ�ƶ�", eSET_MoveBegin);
	AddEvent("ֹͣ�ƶ�", eSET_MoveEnd);
	AddEvent("����ģ�͸ı�", eSET_WeaponModChange);
	AddEvent("װ������", eSET_SetupWeapon);
	AddEvent("��������", eSET_RemoveWeapon);
	AddEvent("����װ��", eSET_ChangeEquip);
	AddEvent("��װ����״̬", eSET_SetupControlState);
	AddEvent("��װ����״̬", eSET_SetupPauseState);
	AddEvent("��װ����״̬", eSET_SetupCripplingState);
	AddEvent("��װ����״̬", eSET_SetupSpecialState);
	AddEvent("��ϼ�����", eSET_InterruptMopHit);

	return true;
}

