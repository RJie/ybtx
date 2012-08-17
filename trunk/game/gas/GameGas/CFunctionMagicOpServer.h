#pragma once
#include "CMagicOpServer.h"
#include "CCfgCalc.h"

class CSkillInstServer;
class CMagicOpArg;
class CFighterDictator;
class CCfgArg;

class CFunctionMagicOpServer
	:public CMagicOpServer
{
public:	
	virtual uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	virtual uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	virtual bool Cancelable()const
	{
		return false;
	}
	virtual ~CFunctionMagicOpServer(){}
	virtual EMagicOpClassType GetMagicOpType()const
	{
		return eMOT_Function;
	}
};

//�ɳ���������ħ��������������pFrom��Ӱ��pTo��ԭ�򣬼�pFromΪ��ʱ��pFromΪ��ʱ��ɵ�Ч��������Do��Cancel����pToû������
//������Щħ���������pFrom�Ĳ�����pFromΪ��ʱ��ִ�С�
class CFunctionCancelableMagicOp
	:public CFunctionMagicOpServer
{
public:
	virtual void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	virtual void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo){};
	virtual bool Cancelable()const
	{ 
		return true;
	}
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	virtual bool IsSetupNestedObj() const
	{
		return false;
	}
};
