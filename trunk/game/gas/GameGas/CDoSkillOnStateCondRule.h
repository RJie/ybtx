#pragma once
#include "CSkillRule.h"

class CDoSkillOnStateCondRule
	:public CSkillRule
{
	typedef list<string, TNpcAIDataAllocator<string> > SkillNameLst;
public:
	CDoSkillOnStateCondRule(CSkillRuleMgr* pRuleMgr,CSkillRuleData* pSkillRuleData);
	~CDoSkillOnStateCondRule();

	//virtual EDoSkillType CheckSkillDistance() { return EDoSkillType_DirectDo;} //��������ֱ���ͷ�
	virtual bool DoRuleSkill();
	virtual void DoNoRuleSkill();
private:
	string			m_strStateName;
};
