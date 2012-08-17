#pragma once

//ά�����ͣ��������̶���
enum EAoiDimType
{
	eADT_Player,						//��Ҳ�								��Ҫ����
	eADT_Magic,							//ħ�����ӵ����⻷�����������
	eADT_RefMagic,						//����ħ��������ħ����ħ������
	eADT_Servant,						//�ٻ��޲�								��Ҫ����
	eADT_Trap,							//�����
	eADT_TrapSeePlayer,					//ֻ�ܿ�����ҵ������
	eADT_TrapSeeNpc,					//ֻ�ܿ���Npc�������
	eADT_InteractObj,					//����NPC/IntObj��ս����				��Ҫ����
	eADT_VisiPlayerObj,					//�ɿ�����ҵ�NPC/IntObj��ս����		��Ҫ����
	eADT_VisiPlayerObjInterested,		//�ɿ�����ҵ�NPC/IntObj����Ȥ��		��Ҫ�[��
	eADT_InvisiPlayerObj,				//���ɿ�����ҵ�NPC/IntObj��ս����
	eADT_InvisiPlayerObjInterested,		//���ɿ�����ҵ�NPC/IntObj����Ȥ��
	eADT_Count,							//��������
	eADT_Undefined						//δ����
};

//�������ͣ����ĿǰҲҪ�̶�������Ϊʵ��������ά������
enum EAoiItemEyeSightType
{
	eAIET_Player,						//���
	eAIET_Magic,						//��ͨħ��
	eAIET_RefMagic,						//����ħ��
	eAIET_Servant,						//�ٻ���
	eAIET_Trap,							//���忴��������Һ�Npc
	eAIET_TrapSeePlayer,				//����ֻ�ܿ������
	eAIET_TrapSeeNpc,					//����ֻ�ܿ���Npc
	eAIET_InteractObj,					//����NPC/IntObj
	eAIET_VisiPlayerObj,				//�ɿ�����ҵ�NPC/IntObj��ֻ�е�һ��EyeSight���������֡�����ҵ�����IntObj����Ҫ����ҵľ糡NPC��
	eAIET_DoubleEyeSightVisiPlayerObj,	//�ɿ�����ҵ�NPC/IntObj����������ͬ��EyeSight��������Ȥ�趨�������֣�
	eAIET_InvisiPlayerObj,				//���ɿ�����ҵ�NPC/IntObj��ֻ�е�һ��EyeSight���������֡���NPC������IntObj������Ҫ����ҵľ糡NPC��
	eAIET_DoubleEyeSightInvisiPlayerObj,//���ɿ�����ҵ�NPC/IntObj����������ͬ��EyeSight��������Ȥ�趨�ı����֣�
	eAIET_InterestedObj,				//����ȤNPC/IntObj��ֻ�еڶ���EyeSight��������Ȥ�趨������NPC��
	eAIET_BlindObj,						//�������κζ�����NPC/IntObj��������NPC����ͨIntObj��
	eAIET_Count,						//��������
	eAIET_Undefined						//δ����
};

//���������ͣ���������������ñ����
enum EAoiItemSizeType
{
	eAIST_PlayerOrServant,				//���
	eAIST_Magic,						//��ͨħ��
	eAIST_TaskNPC,						//����NPC��ֻ�ܱ���Һ����忴����
	eAIST_IntObj,						//��ͨ��Ʒ��ֻ�ܱ���ҿ�����
	eAIST_Monster,						//��ͨ�֣�ֻ�ܱ���ҡ��ٻ��ޡ�ħ��������
	eAIST_InteractObj,					//����NPC/IntObj
	eAIST_InterestingMonster,			//�����Թ�ע����ͨ��
	eAIST_InterestingNPC,				//�����Թ�ע��NPC�������߽��ᱻ���к�������NPC��
	eAIST_InterestingIntObj,			//�����Թ�ע��IntObj�����������������⣩
	eAIST_DeadPlayer,					//����������
	eAIST_SleepNPC,						//����NPC�����ܱ��κζ���������
	eAIST_Count,						//��������
	eAIST_Undefined						//δ����
};

