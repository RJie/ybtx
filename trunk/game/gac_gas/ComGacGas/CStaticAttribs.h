#pragma once

// �洢Fighter�����Ե�BaseValue
class CStaticAttribs
{
public:
	//--------------------------------------------------------------------------------//
	//		��������																  //
	//--------------------------------------------------------------------------------//
	uint32 m_MaxHealthPoint;				// ���Ѫ��
	uint32 m_MaxManaPoint;					// �������
	uint32 m_MaxEnergyPoint;				// �������
	uint32 m_MaxRagePoint;					// ���ŭ�� 
	uint32 m_MaxComboPoint;					// �������

	float m_HPUpdateRate;					// ��Ѫ��( N%*����/�� )
	float m_MPUpdateRate;					// ��ħ��( N%*����/�� )
	uint32 m_RPUpdateValue;					// ��ŭֵ( N/�� )
	uint32 m_EPUpdateValue;					// ����ֵ( N/�� )
	float m_RPProduceRate;					// ŭ������ϵ��

	float m_RevertPer;						// ս��״̬�ظ��ٶ� = m_RevertPer * ��ս��״̬�ظ��ٶ�

	float m_RunSpeed;						// �ƶ��ٶ�
	float m_WalkSpeed;						// �����ٶ�

	//--------------------------------------------------------------------------------//
	//		������Ч�����ԣ�δ���С������ܡ��мܡ��񵲡����������У�			  //
	//--------------------------------------------------------------------------------//
	int32 m_PhysicalDodgeValue;			// �����˺�����ֵ��������չ������ʵĶ���	
	int32 m_ParryValue;					// �м�ֵ������м��ʵĶ���
	uint32 m_StrikeValue;					// ����ֵ������������ʵĶ���
	uint32 m_AccuratenessValue;				// ��׼ֵ

	//--------------------------------------------------------------------------------//
	//		��������Ч�����ԣ�������ܡ���ȫ�ֿ����ֿ������������У�				  //
	//--------------------------------------------------------------------------------//
	int32 m_MagicDodgeValue;				// ��������ֵ�������ħ�������ʵĶ���	
	uint32 m_MagicHitValue;					// �������ķ�������ֵ�����ڵ����������ķ������ֵ

	//--------------------------------------------------------------------------------//
	//		�������˺�����														  //
	//--------------------------------------------------------------------------------//
	uint32 m_PhysicalDPS;					// ������

	int32  m_Defence;						// ����ֵ
	uint32 m_StrikeMultiValue;				// ��������ֵ������������˺�����ֵ�Ķ���
	int32 m_ResilienceValue;				// ����ֵ�����������˺������Ķ���
	int32 m_StrikeResistanceValue;		//�Ⱪֵ

	//--------------------------------------------------------------------------------//
	//		���������˺�����														  //
	//--------------------------------------------------------------------------------//
	uint32 m_MagicDamageValue;				// ȫϵ���ˣ����Է��˼ӳ�ϵ����ó��˺�ֵ

	int32 m_NatureResistanceValue;			// ��Ȼ����
	int32 m_DestructionResistanceValue;	// �ƻ�����
	int32 m_EvilResistanceValue;			// �ڰ�����

	uint32 m_ValidityCoefficient;			// ��Ч��ϵ��

	uint32 m_NatureSmashValue;				//��Ȼ��ѹֵ
	uint32 m_DestructionSmashValue;			//�ƻ���ѹֵ
	uint32 m_EvilSmashValue;				//������ѹֵ
	uint32 m_DefenceSmashValue;				//������ѹֵ
};
