#pragma once

class CFighterDirector;
class CCfgCalc;

// ħ������
class CMagicCondClient
{
public:
	virtual uint32 Test(uint32 SkillLevel, const CCfgCalc& Arg,const CFighterDirector* pFighter) const = 0;
};
