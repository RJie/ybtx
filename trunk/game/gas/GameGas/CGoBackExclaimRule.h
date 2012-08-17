#pragma once
#include "CSkillRule.h"

class CGoBackExclaimRule : public CSkillRule
{
public:
	CGoBackExclaimRule(CSkillRuleMgr* pRuleMgr,CSkillRuleData* pSkillRuleData);
	virtual void OnSkillCondSatify(bool bRepeat = true);
	virtual bool DoRuleSkill();
	virtual EDoSkillType CheckSkillDistance();
private:
	typedef list<string, TNpcAIDataAllocator<string> > SkillNameLst;
	SkillNameLst m_lstSkillArgs;
	float		m_fSize;						//���ȷ�Χ
	uint32		m_uNum;							//���ȵ���Ŀ
};

