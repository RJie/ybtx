#pragma once
#include "CTriggerableState.h"
#include "COtherStateMgr.h"

template<typename CfgType, typename StateType>
class TTriggerableStateMgrServer
	: public TOtherStateMgrServer<CfgType, StateType>
{
	typedef typename CfgType::SharedPtrType SharedPtrType;
public:
	typedef typename TOtherStateMgrServer<CfgType, StateType>::MapState MapState;
	TTriggerableStateMgrServer(CFighterDictator* pOwner)
		: TOtherStateMgrServer<CfgType, StateType>(pOwner)
	{

	}
	virtual ~TTriggerableStateMgrServer()
	{
		ClearAll();
	}
	virtual void				ClearAll();						//��������ʱ�������״̬
	bool						SetupState(CSkillInstServer* pSkillInst, const SharedPtrType& pCfg, CFighterDictator* pInstaller);		//��װħ��״̬
	virtual CStateDBData*		CreateStateDBData(StateType* pState, int32 iRemainTime, CSkillInstServer* pInst);
	virtual bool				RestoreStateFromDB(CSkillInstServer* pSkillInst, const SharedPtrType& pCfg,
		CFighterDictator* pInstaller, int32 iTime, int32 iRemainTime, uint32 uAccumulate, float fProbability);	//�����ݿ�ָ�ĳ��״̬
	uint32						TriggerCount(const string& name);					//��ȡ����Ϊname��״̬ʣ��ʱ��
	bool						SetAccumulate(const string& name, uint32 uValue);
};
