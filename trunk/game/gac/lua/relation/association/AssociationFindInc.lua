CAssociationFindWnd					= class(SQRDialog)

CAssociationFindPlayerWnd			= class(SQRDialog)
CAssociationRetFindPlayerWnd		= class(SQRDialog)

CAssociationFindGroupWnd			= class(SQRDialog)
CAssociationRetFindGroupWnd			= class(SQRDialog)

CAssociationRetFindListItem			= class(SQRDialog)

--[[
// ְҵ����
enum EClass
{
	eCL_NoneClass = 0,	//��ְҵ
	eCL_Warrior,		//��ʿ
	eCL_MagicWarrior,	//ħ��ʿ
	eCL_Paladin,		//��ʿ
	eCL_NatureElf,		//��ʦ
	eCL_EvilElf,		//аħ
	eCL_Priest,			//��ʦ
	eCL_DwarfPaladin,	//������ʿ
	eCL_ElfHunter,		//���鹭����
	eCL_OrcWarrior,		//����սʿ
	eCL_Npc,			//NPC
	eCL_Wizard,			//��ʦ
	eCL_Assassin,		//�̿�
	eCL_Warlock,		//а��ʦ	
	eCL_WarPriest,		//ս��  
	eCL_Archer,			//������
	eCL_Soldier,		//��սʿ
	eCL_Summoner,		//�ٻ�ʦ
	eCL_Beast,			//Ұ��
	eCL_Summon,			//�ٻ�����
	eCL_Lancer,			//������ʿ
	eCL_Knight,			//������ʿ
	eCL_NatureElement,	//��ȻԪ��
	eCL_EvilElement,	//����Ԫ��
	eCL_DestructionElement,	//�ƻ�Ԫ��
	eCL_Special,		//����
	eCL_AllClass,		//����ְҵ
	eCL_Count
};
--]]