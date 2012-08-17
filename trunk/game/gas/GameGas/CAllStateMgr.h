#pragma once
#include "FightDef.h"
#include "CPos.h"
#include "TMagicStateAllocator.h"
#include "TIDPtrMap.h"

class CFighterDictator;
class CMagicStateMgrServer;
class CTriggerStateMgrServer;
class CDamageChangeStateMgrServer;
class CCumuliTriggerStateMgrServer;
class CSpecialStateMgrServer;
class CBaseStateCfgServer;
class CSkillInstServer;
class CStateCondBase;
class CStateDBDataSet;
class CStateDBData;
class CStoredObjDBData;
class CGenericTarget;
class CSizeChangeMgr;
class CBaseStateServer;
class CBaseStateCfg;

typedef TIDPtrMap<CBaseStateServer>	IDMapStateByDynamicId;

class CStateCtrlCount
	: public CMagicStateMallocObject
{
public:
	CStateCtrlCount() :m_iNonStateCount(0)		{}
	typedef map<uint32, int32, less<uint32>, TMagicStateAllocator<pair<uint32,uint32> > > MapStateIdCount;
	MapStateIdCount m_mapStateIdCount;
	int32 m_iNonStateCount;
};

namespace sqr
{
	class CError;
}

class CAllStateMgrServer
	: public CMagicStateMallocObject
{
public:
	CAllStateMgrServer(CFighterDictator* pOwner);
	~CAllStateMgrServer();

	CMagicStateMgrServer*	GetMagicStateMgrServer()const			{return m_pMagicStateMgrServer;}
	CTriggerStateMgrServer* GetTriggerStateMgrServer()const			{return m_pTriggerStateMgrServer;}
	CDamageChangeStateMgrServer* GetDamageChangeStateMgrServer()const			{return m_pDamageChangeStateMgrServer;}
	CCumuliTriggerStateMgrServer* GetCumuliTriggerStateMgrServer()const			{return m_pCumuliTriggerStateMgrServer;}
	CSpecialStateMgrServer* GetSpecialStateMgrServer()const			{return m_pSpecialStateMgrServer;}

	//ħ��״̬�ص�
	void					OnClearState( CFighterDictator* pObserver );
	void					OnDeleteState( uint32 uCategoryId, uint32 uDynamicId );
	void					OnSetState( uint32 uCategoryId, uint32 uDynamicId, uint32 uCount, int32 iTime,
		int32 iRemainTime, uint32 uSkillLevel, CFighterDictator* pObserver);

	void					OnSetState( uint32 uCategoryId, uint32 uDynamicId, uint32 uCount, int32 iTime,
		int32 iRemainTime, uint32 uSkillLevel,uint32 uInstallerID, int32 iCalcValue = 0);

	void					SetModelStateId(uint32 uId);
	void					ClearModelStateId();
	void					AddModelStateId(uint32 uId);
	void					SubModelStateId();
	uint32					GetModelStateId() const					{return m_uModelStateId;}
	bool					ReplaceModelRuler(CBaseStateCfgServer* pCfgNew,CBaseStateCfgServer* pCfgOld);
	bool					ReplaceModelState(CBaseStateCfgServer* pCfg);

	void					SyncClearState(CFighterDictator* pObserver);						//ͬ�����״̬��Ϣ���ͻ���
	void					SyncAllState(CFighterDictator* pObserver);							//ͬ��״̬��Ϣ���ͻ���

	bool					ExistDecreaseState();		//���ڸ���״̬
	bool					ExistStateByDecreaseType(EDecreaseStateType eDecreaseType);					//����״̬����
	bool					ExistState(const string& strName);
	bool					ExistState(uint32 uDynamicId);
	bool					ExistStateByCond(CStateCondBase* pStateCond);	
	uint32					GetStateCascade(const string& strName);

	bool					CancelState(uint32 uId);
	bool					CancelStateByDynamicId(uint32 uDynamicId);
	void					ClearAll();
	void					ClearAllByCond(CStateCondBase* pCond);
	void					ClearAllNonpersistentState();
	void					EraseAllState();				// �������״̬����ǿ�ƣ�
	void					EraseDecreaseState(int32 iCount = -1);			// ������и���״̬����ǿ�ƣ�
	void					EraseIncreaseState(int32 iCount = -1);			// �����������״̬����ǿ�ƣ�
	void					EraseState(EDecreaseStateType eDecreaseType, int32 iCount = -1, bool bDelEqual = true);			// ������и���״̬����ǿ�ƣ�
	void					EraseDispellableDecreaseState(int32 iCount = -1);			// ������и���״̬����ǿ�ƣ�
	void					EraseDispellableDecreaseStateRand(int32 iCount = -1);			// ������и���״̬����ǿ�ƣ�
	void					EraseDispellableIncreaseState(int32 iCount = -1);			// �����������״̬����ǿ�ƣ�
	void					EraseDispellableIncreaseStateRand(int32 iCount = -1);			// ������и���״̬����ǿ�ƣ�
	void					EraseDispellableState(EDecreaseStateType eDecreaseType, int32 iCount = -1, bool bDelEqual = true);			// ������и���״̬����ǿ�ƣ�
	bool					EraseErasableState(const string& strName);
	void					EraseState(const string& strName);										// ���״̬����ǿ�ƣ�
	void					EraseState(CBaseStateCfg* pCfg);
	void					EraseSelfState();
	void					EraseState(CBaseStateCfg* pCfg, CFighterDictator* pInstaller);
	bool					ClearStateByCond(CStateCondBase* pStateCond, uint32 uId);
	bool					ClearStateByCondAndDynamicId(CStateCondBase* pStateCond, uint32 uDynamicId);

	bool					DecreaseStateResist(CBaseStateCfgServer* pCfg);							//�����Լ���ֿ���װ״̬
	bool					Immume(CBaseStateCfgServer* pCfg, CSkillInstServer* pSkillInst, CFighterDictator* pFrom);		//�Ƿ����߰�װ״̬
	void					ReflectState(EDecreaseStateType eDecreaseType);							// ����ĳ�ָ���״̬
	void					ReflectStateByCond(CStateCondBase* pCond);

	CStateDBDataSet*		SerializeToDB(uint32 uGrade);														// �浽���ݿ�
	void					SaveStateToDBEnd();														// �����ݿ����
	bool					LoadFromDB(CStateDBDataSet* pRet);										// �����ݿ��
	CStateDBDataSet*		GetStateDataMgrRet()			{return m_pRet;}
	bool					ReadStateFromDB(CStateDBData*& pStateDBData, EStateGlobalType eType);
	bool					ReadStoredObjFromDB(CStoredObjDBData*& pStored, uint32 uInstID);

	bool					MessageEvent(uint32 uEventID, CFighterDictator* pTrigger, ETriggerStateType eType = eTST_All);	
	bool					MessageEvent(uint32 uEventID, const CFPos& pTrigger, ETriggerStateType eType = eTST_All);	
	bool					MessageEvent(uint32 uEventID, CGenericTarget* pTrigger, ETriggerStateType eType = eTST_All);	

	void					PrintFightInfo(bool bSetupOrDelete, uint32 uObjInstallerID, CBaseStateCfgServer* pCfg);

	void					ChangeSizeRate(CBaseStateCfgServer* pCfg, int32 iChangeCount);
	double					GetStateZoomRate();

	bool					GetStateByDId(const CBaseStateServer*& pValue,uint32 uID) const;
	uint32					AddStateByDId(CBaseStateServer* const & Value);
	bool					DelStateByDId(uint32 uID);

	void					CountCtrlState(EFighterCtrlState eState, bool bSet, uint32 uStateId, sqr::CError* pExp = NULL);
	void					ClearCtrlStateCount();



private:
	CMagicStateMgrServer*			m_pMagicStateMgrServer;			// ħ��״̬������
	CTriggerStateMgrServer*			m_pTriggerStateMgrServer;		// ������״̬������
	CDamageChangeStateMgrServer*	m_pDamageChangeStateMgrServer;	// �˺����״̬������
	CCumuliTriggerStateMgrServer*	m_pCumuliTriggerStateMgrServer;		// ������״̬������
	CSpecialStateMgrServer*			m_pSpecialStateMgrServer;		// ����״̬������

	uint32							m_uModelStateId;		//����״̬ID
	uint32							m_uModelStateCascde;	//����״̬ģ�Ͳ���

	CFighterDictator*				m_pOwner;				//ӵ����
	CStateDBDataSet*				m_pRet;					//��ȡ���ݿ⴫���õ�״̬�����ܼ�
	CSizeChangeMgr*					m_pSizeChangeMgr;		//AOISIZE��BARRIERSIZE���������

	IDMapStateByDynamicId			m_idmapStateByDId;
	
	typedef map<EFighterCtrlState, CStateCtrlCount, less<EFighterCtrlState>, TMagicStateAllocator<pair<EFighterCtrlState,CStateCtrlCount> > > MapStateCtrlCount;
	MapStateCtrlCount m_mapStateCtrlCount;
};

