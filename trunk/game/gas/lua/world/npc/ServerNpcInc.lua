gas_require "framework/main_frame/ItemHolderInc"

CNpcServerMgr = class()

-- NPC �Ƿ���������
ENpcIsReborn = 
{
	eNT_NoReborn 	= 0,	-- ������������������Ҫ���������NPC
	eNT_Reborn 			= 1,	-- ��ͨ
}

ENpcColonyType = 
{
	eNCT_Null				= 0,	--���͵ģ�ɶ������
	eNCT_Boss				= 1,	--����Ⱥ�е��ϴ�
	eNCT_Servant		= 2,	--����Ⱥ�е�С��
}

MapMoveType2Name = 
{
	[ENpcMoveType.ENpcMove_None] 				= "�̶�",
	[ENpcMoveType.ENpcMove_Cycle]				= "ѭ��Ѳ��",
	[ENpcMoveType.ENpcMove_Trip]				= "����Ѳ��",
	[ENpcMoveType.ENpcMove_Random]				= "�漴�ƶ�",
	[ENpcMoveType.ENpcMove_SingleLine]			= "����Ѳ��",
	[ENpcMoveType.ENpcMove_Single2Random]		= "�ȵ��ߺ����",
	[ENpcMoveType.ENpcMove_MoveInPath]			= "���·��Ѳ��",
}

