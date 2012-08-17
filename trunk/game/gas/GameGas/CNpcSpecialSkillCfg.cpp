#include "stdafx.h"
#include "CNpcSpecialSkillCfg.h"
#include "CSkillServer.h"
#include "BaseHelper.h"

CNpcSpecialSkillCfg::VecNpcSpecialSkill CNpcSpecialSkillCfg::ms_vecNpcSpecialSkill;

bool CNpcSpecialSkillCfg::LoadNpcSpecialSkill()
{
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("NPC�帺��״̬")) );
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("NPC��װȫ����")) );
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("NPC����ȫ����")) );
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("��������")) );
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("��ͨ��������")) );
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("NPC����״̬")) );
	ms_vecNpcSpecialSkill.push_back( new CNormalSkillServerSharedPtr(CNormalSkillServer::GetNPCSkill("NPC������״̬")) );

	return true;
}

void CNpcSpecialSkillCfg::UnLoadNpcSpecialSkill()
{
	ClearVector(ms_vecNpcSpecialSkill);
}

