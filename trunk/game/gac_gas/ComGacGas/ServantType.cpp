#include "stdafx.h"
#include "ServantType.h"

bool ServantType::BeServantType(ENpcType eNpcType)
{
	switch(eNpcType)
	{
	case ENpcType_Totem:			//ͼ��
	case ENpcType_Pet:				//����
	case ENpcType_Summon:			//���������ٻ���			
	case ENpcType_BattleHorse:		//ս������
	case ENpcType_OrdnanceMonster:	//��е��
	case ENpcType_MagicBuilding:	//ħ����
	case ENpcType_Cannon:			//�ƶ���̨
	case ENpcType_MonsterCard:		//���￨
	case ENpcType_Shadow:			//����
	case ENpcType_Truck:			//���䳵
	case ENpcType_BossCortege:		//BossС������
	case ENpcType_QuestBeckonNpc:	//�����ٻ�Npc	
	case ENpcType_LittlePet:		//�������
	case ENpcType_NotCtrlSummon:	//���ܿ��ٻ���
		return true;
	default :
		return false;
	}
}
