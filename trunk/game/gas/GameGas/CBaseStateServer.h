#pragma once
#include "CBaseStateCfgServer.h"
#include "CDistortedTick.h"


namespace sqr
{
	class CSyncVariantServer;
}
class CAllStateMgrServer;

class CStateVaraintPointerHolder
	: public CMagicStateMallocObject
{
	friend class CAllStateMgrServer;
private:
	CSyncVariantServer* m_pStateSubTree;
	CSyncVariantServer* m_pCategoryId;
	CSyncVariantServer* m_pDynamicId;
	CSyncVariantServer* m_pCount;
	CSyncVariantServer* m_pTime;
	CSyncVariantServer* m_pGuessStartTime;
	CSyncVariantServer* m_pSkillLevel;
	CSyncVariantServer* m_pStateIsSync;
	CSyncVariantServer* m_pStateIsFinish;
	CSyncVariantServer* m_pInstallerID;
	CSyncVariantServer* m_pCalcValue;
};


class CFighterDictator;
class CGenericTarget;

class CBaseStateServer
	: public CDistortedTick
	, public CMagicStateMallocObject
{
public:
	uint32							GetDynamicId()		{return m_uDynamicId;}
	CFighterDictator*				GetInstaller();											//��ȡʩ����
	uint32							GetInstallerID() {return m_uInstallerID;}					//��ȡʩ����EntityID
	virtual CFighterDictator*		GetOwner() {return NULL;}								//��ȡӵ����
	virtual CBaseStateCfgServer*	GetCfg() {return NULL;}									//��ȡ���ñ����
	//virtual uint32					GetDynamicId()	{return 0;}								//��ȡ��̬ID
	CStateVaraintPointerHolder*		GetVaraintPointerHolder()	{return m_pVariantPointerHolder;}
	void							SetVaraintPointerHolder(CStateVaraintPointerHolder* pPointer) {m_pVariantPointerHolder = pPointer;}
	void							DeleteVaraintPointerHolder();
	int32							GetLeftTime();

protected:
	explicit CBaseStateServer(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller = NULL);
	explicit CBaseStateServer(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller, 
		int32 iTime, int32 iRemainTime);
	~CBaseStateServer();

	uint32							m_uDynamicId;

	//CFighterDictator*				m_pInstaller;							//ʩ����
	uint32							m_uInstallerID;							//ʩ����EntityID

	int32					m_iTime;			//��ʱ��
	int32					m_iRemainTime;		//ʣ��ʱ��
	uint64					m_uStartTime;		//��ʼʱ��

	CSkillInstServer*		m_pSkillInst;		//���ڱ��浽���ݿ��CSkillInstServerָ�룬��ʱ�������������зǿյ�����һ��

	CStateVaraintPointerHolder*		m_pVariantPointerHolder;
};

//�ڿ���̨��ӡ״̬��Ϣ
//#define COUT_STATE_INFO

