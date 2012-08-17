#pragma once
#include "CFunctionMagicOpServer.h"
#include "PatternCOR.h"
#include "CDistortedTick.h"
#include "MagicOps_ChangeValue.h"
#include "CCfgArg.h"

class CMagicEffServer;
class CBulletMagicCfgServerSharedPtr;

class CCreateNPCMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CDestoryNPCMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CCreatePassiveNPCMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
class CCreateNPCOnTargetPosMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};


//��װ�����������״̬
class CSetupOrEraseTriggerStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//��װ�����ħ��״̬
class CSetupOrEraseMagicStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool IsSetupNestedObj() const
	{
		return true;
	}
};

class CSetupMultiMagicStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool IsSetupNestedObj() const
	{
		return true;
	}
};

//��װ�������̬��ͬһ��̬�ظ�ʹ��ʱ��װһ����һ��
class CSetupOrEraseAureMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//��װ��̬���ɳ������ɶ�������綨ʱ��̬
class CSetupAureMagicMOP
	:public CFunctionCancelableMagicOp
{
public:
	virtual bool CanExecuteWithAttackerIsDead()const
	{
		return false;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	virtual bool IsSetupNestedObj() const
	{
		return true;
	}
};

//�л���̬���������������̬���ٰ�װ������
class CChangeAureMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//�����̬
class CEraseAureMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CEraseAureMagicOnCancellingMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//�������߰�װħ��״̬
class CIgnoreImmuneSetupSpecialStateMOP
	: public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	virtual void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool CanExecuteWithAttackerIsDead() const { return true; }
	virtual bool IsSetupNestedObj() const { return true; }	
};

//������װħ��״̬
class CPassiveSetupMagicStateMOP
	: public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	virtual void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool CanExecuteWithAttackerIsDead() const { return true; }
	virtual bool IsSetupNestedObj() const { return true; }	
};

//��װħ��״̬
class CSetupMagicStateMOP
	:public CPassiveSetupMagicStateMOP
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//��װ������״̬
class CSetupTriggerStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool IsSetupNestedObj() const
	{
		return true;
	}
};

//��װ�˺����״̬
class CSetupDamageChangeStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool IsSetupNestedObj() const
	{
		return true;
	}
};

//��װ���۴���״̬
class CSetupCumuliTriggerStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool IsSetupNestedObj() const
	{
		return true;
	}
};

//��װ����״̬
class CSetupSpecialStateMOP
	:public CFunctionCancelableMagicOp
{
public:
	virtual bool CanExecuteWithTargetIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//ֻ��װ������ħ��״̬
class CSetupUncancellableMagicStateMOP
	:public CSetupMagicStateMOP
{
public:
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo) {}
	bool Cancelable()const
	{
		return false;
	}
};

//����߼��ܵȼ���װħ��״̬
class CSetupMagicStateByMaxSkillLevelMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
	virtual bool CanExecuteWithAttackerIsDead() const { return true; }
	virtual bool IsSetupNestedObj() const { return true; }	
};

//����ħ��״̬���Ӳ���
class CCancelMagicStateCascadeMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//��Ч������ħ��״̬���Ӳ���
class CCancelMagicStateCascadeByEffectMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};




//����������״̬
class CTriggerStateMessageEventMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CResetMagicStateTimeMOP
	:public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CAddMagicStateTimeMOP
	:public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};


class CSetDamageChangeStateAccumulateMOP
	:public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetCumuliTriggerStateAccumulateMOP
	:public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};


//�ͷ�λ��ħ������
class CRelMoveMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//�ͷſɳ���λ��ħ������
class CCancelableRelMoveMagicMOP
	:public CFunctionCancelableMagicOp
{
public:
	virtual bool CanExecuteWithAttackerIsDead()const
	{
		return false;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//�ͷſɴ���ħ������
class CRelTransferMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//�ͷ��ӵ�ħ��
class CRelBulletMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//�ӳ�ʩ���ӵ�ħ��
class CDelayRelBulletMagicMOP
	:public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};


class CEraseMoveMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CErasePositionMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CEraseAllPositionMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CReplacePositionMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

// ������и���״̬
class CEraseAllDecreaseStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �������״̬
class CEraseMoveDecreaseStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
class CEraseSpeedDecreaseStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
// �������״̬
class CEraseIncreaseStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ���������и���״̬
class CRandEraseAllDecreaseStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ����������״̬
class CRandEraseIncreaseStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �������״̬
class CEraseRidingStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �������״̬
class CEraseAllBufferMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CEraseStateMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CEraseSelfStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CEraseStateOnCancellingMOP
	:public CFunctionCancelableMagicOp
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};



// ���ĳ�ָ������͵�״̬
class CEraseStateByDecreaseTypeMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

// ����ĳ�ָ�������״̬
class CReflectStateByDecreaseTypeMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ֿ�����
class CResistControlMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ֿ�����
class CResistPauseMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ֿ�����
class CResistCripplingMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ֿ�DOT
class CResistDOTMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ������ȴ��һ����ʱ��Ϊ��--��
class CResetSingleCoolDownTimeMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ���м�����ȴ����--������ʿ
class CAllSkillReadyMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CAllFightSkillReadyMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
// ------------------------------------------------------------------------------------------------------------
// CLEAN UP START
// ------------------------------------------------------------------------------------------------------------

// ����ȫ����
class CDoAllBodyActionMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ħ��״̬����ս��״̬ת��,����Ҫע��
class CMagicStateTouchBattleStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ������ս��״̬
class CTargetLeftBattleStateMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ���ֹ�ƶ�
class CTargetForbitMoveMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ���ֹ�ƶ�
class CForTestTargetCancelForbitMoveMOP
	:public CFunctionMagicOpServer
{
public:
		uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ���ֹת��
class CTargetForbitTurnAroundMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ�곷���չ�
class CTargetCancelNAMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ����ͣ�չ�
class CTargetSuspendNAMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ���ֹ��ͨ����
class CTargetForbitNormalAttackMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ���ֹʩ�ż���
class CTargetForbitUseSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// Ŀ���ֹʩ����Ȼϵ����
class CTargetForbitUseNatureSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
// Ŀ���ֹʩ���ƻ�ϵ����
class CTargetForbitUseDestructionSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
// Ŀ���ֹʩ�Ű���ϵ����
class CTargetForbitUseEvilSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
// Ŀ���ֹ�ͻ��˲���
class CTargetForbitClientOperateMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTargetForbitUseClassSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTargetForbitUseDrugItemSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTargetForbitUseNotFightSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTargetForbitUseMissionItemSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ����
class CFeignDeathMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ����
class CTauntMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ��������
class CRenascenceMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ԭ������
class CRebornWhereYouBeMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CPermitRebornMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ��������
class CContinueAddMPMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ֹͣ�˶�
class CStopMoveMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ����
class CBreakOutMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �������
class CSoulLinkMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ʩ�ű�������
class CRelPassiveSkillMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CRelNPCSkillMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CRelNPCDirSkillMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ��е
class CForbitUseWeaponMOP : public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �չ�����ŭ��
class CNormalAttackProduceRagePoint : public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ���˺�����ŭ��
class CBeDamagePreduceRagePoint : public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CBurstSoulPrizeToExpOwnerMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);

	virtual bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
};

class CTargetSetupMagicStateToSelfMOP
	:public CSetupMagicStateMOP
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CCBurstSoulExtraPrizeToExpOwnerMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);

	virtual bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
};

//Ŀ��Ծ���ӵ���߽����겢������Ч��
class CAddBurstSoulTimesToExpOwnerMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);

	virtual bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
};

class CTakeOverTRuckMop
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);

	virtual bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
};

class CTargetSetHiddenMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CMoveSelfToTargetPosMop
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ------------------------------------------------------------------------------------------------------------
// CLEAN UP END
// ------------------------------------------------------------------------------------------------------------

// ��һ����������ʱ��
class CSetNoSingTimeAboutNextSkill
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst,const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ����������ʱ�䣨�ɳ�����
class CSetNoSingTimeForever
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst,const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CLockAgileValueMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CChangeTargetToBarrierMOP
	:public CFunctionCancelableMagicOp
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CNonCombatBehaviorMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CChangeSceneMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

//�ٻ��� ����ص�
class CCreateServantMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CCreateServantWithTargetLevelFollowMasterMOP
	: public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CRemoveServantEnemyMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetMonsterCardSkillLevelByMasterSkillLevelMOP
	: public CFunctionMagicOpServer
{
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CControlServantMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetServantLeftTimeMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CDestroyServantMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CDestroyServantOnCancellingMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CRelTickMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

// ʹ����ͨ����
class CUseNormalHorseMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void ChangeRidingHorse(CFighterDictator* pFighter, const CCfgCalc& Arg);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ʹ��ս������
class CUseBattleHorseMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ٻ�ս������
class CCallBattleHorseMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ջ��������
class CTakeBackRidingHorseMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetServantTargetMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CLetServantAttackTargetMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CRemoveEnemyFromServantEnmityListMOP
	:public CFunctionMagicOpServer
{
public:	
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetServantAttackMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};


//ִ���ֲ�����
class CHandActionMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

//ִ�нŲ�����
class CFootActionMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

//������
class CBurstSoulPrizeMOP
	:public CFunctionMagicOpServer
{
public:
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTargetRelBulletMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CBurstSoulFXMOP
	: public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CBurstSoulBallFXMOP
	: public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CTargetBurstSoulFXMOP
	: public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CAddBurstSoulTimesMOP
	: public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CConsumeBurstSoulTimesMOP
	: public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CAddContinuousBurstTimesMOP
	: public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ����
class CReturnBattleArrayMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// �ı���Ӫ
class CChangeCampMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class COnlyPlayFX
	:public CFunctionCancelableMagicOp
{
	bool CanExecuteWithAttackerIsDead()const
	{
		return true;
	}
	bool CanExecuteWithTargetIsDead()const
	{
		return false;
	}
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

//class CUseMagaicEff
//	:public CFunctionCancelableMagicOp
//{
//	bool CanExecuteWithAttackerIsDead()const
//	{
//		return true;
//	}
//	bool CanExecuteWithTargetIsDead()const
//	{
//		return true;
//	}
//	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
//	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
//};
//
//class CCancelMagicEff
//	:public CFunctionCancelableMagicOp
//{
//	bool CanExecuteWithAttackerIsDead()const
//	{
//		return true;
//	}
//	bool CanExecuteWithTargetIsDead()const
//	{
//		return true;
//	}
//	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
//	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
//};

// �ı��չ���������
class CChangeNAActionRhythmMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

// ���ͬ��--��ʦ
class CSelfMurderBlastMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CDisTriggerEventMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetSameTargetMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetTargetSelfMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CSetTargetNULLMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CReplaceSkillMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

template<typename PropertyType>
class TImmuneMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

#define DefineImmuneMOP(Name) \
	typedef TImmuneMOP<CChange##Name##ImmuneRateMultiplierMOP> CImmune##Name##MOP;

DefineImmuneMOP(PunctureDamage);
DefineImmuneMOP(ChopDamage);
DefineImmuneMOP(BluntDamage);
DefineImmuneMOP(NatureDamage);
DefineImmuneMOP(DestructionDamage);
DefineImmuneMOP(EvilDamage);
DefineImmuneMOP(ControlDecrease);
DefineImmuneMOP(PauseDecrease);
DefineImmuneMOP(CripplingDecrease);
DefineImmuneMOP(DebuffDecrease);
DefineImmuneMOP(DOTDecrease);
DefineImmuneMOP(SpecialDecrease);
DefineImmuneMOP(Cure);
DefineImmuneMOP(MoveMagic);
DefineImmuneMOP(NonTypePhysicsDamage);
DefineImmuneMOP(NonTypeDamage);
DefineImmuneMOP(NonTypeCure);
DefineImmuneMOP(InterruptCastingProcess);

#undef DefineImmuneMOP

class CImmuneTaskTypeDamageMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CClosePrintInfoMOP
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class  CSwapPositionMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CInterruptCastingProcessMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CFillHPMPMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTalentChangeManaPointMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CRelMoveMagicAtShockwaveMagicPosMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CRelPositionMagicAtTargetPosMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CRelShockWaveMagicAtTargetPosMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CNonCombatStateMagicOp
	:public CFunctionCancelableMagicOp
{
public:
	uint32 Do(CSkillInstServer* pSkillInst,const CCfgArg* pArg,CFighterDictator* pFrom,CFighterDictator* pTo);
	void Cancel(CSkillInstServer* pSkillInst,const CCfgArg* pArg,CFighterDictator* pFrom,CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CBecomeTargetShadowMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};
class CForceSetDOTDamageMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CBindTargetObjToSelfMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CTestTargetMoveMagicMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};

class CDisplayMsgMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CDebaseEnmityMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgCalc& Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
};


class CDoWorldSkillMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};


class CDoCampSkillMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};


class CDoArmyCorpsSkillMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};

class CDoTongSkillMOP
	:public CFunctionMagicOpServer
{
public:
	uint32 Do(CSkillInstServer* pSkillInst, const CCfgArg* pArg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CCfgArg* InitArg(const string& szArg);
};
