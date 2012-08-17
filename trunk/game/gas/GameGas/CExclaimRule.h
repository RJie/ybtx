#pragma once
#include "CSkillRule.h"

class CExclaimRule : public CSkillRule
{
public:
	CExclaimRule(CSkillRuleMgr* pRuleMgr,CSkillRuleData* pSkillRuleData, bool bShowEffect);
	virtual void OnSkillCondSatify(bool bRepeat = true);
	virtual bool DoRuleSkill();
	virtual EDoSkillType CheckSkillDistance() { return EDoSkillType_DirectDo;}
private:
	typedef list<string, TNpcAIDataAllocator<string> > SkillNameLst;
	SkillNameLst m_lstSkillArgs;
	float		m_fSize;						//���ȷ�Χ
	uint32		m_uNum;							//���ȵ���Ŀ
	bool		m_bShowEffect;
};

