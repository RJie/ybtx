#pragma once

enum ENpcMoveType
{
	ENpcMove_None,				//�̶�
	ENpcMove_Cycle,				//ѭ��Ѳ��
	ENpcMove_Trip,				//����Ѳ��
	ENpcMove_Random,			//�漴�ƶ�
	ENpcMove_SingleLine,		//����Ѳ��
	ENpcMove_Single2Random,		//�ȵ��ߺ����
	ENpcMove_MoveInPath,		//���·��Ѳ��
};

enum ENpcEnmityType
{
	ENpcEnmityType_None,			
	ENpcEnmityType_Nomal,			//��ͨNpc
	ENpcEnmityType_Dummy,			//Ⱥ�������
	ENpcEnmityType_Member,			//Ⱥ���Ա
};

enum ENpcAIDestructEsg
{
	ENpcAIDestructEsg_False,
	ENpcAIDestructEsg_True,		//����NpcAI��AOI�ص���Ϣ
};

enum ENpcTargetType
{
	ENpcTargetType_AllTarget,			//����Ŀ��
	ENpcTargetType_AllPlayer,			//�������
	ENpcTargetType_AllNpc,				//����Npc
	ENpcTargetType_AppointNpc,			//ָ��Npc
};
