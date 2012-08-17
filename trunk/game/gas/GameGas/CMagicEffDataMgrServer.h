#pragma once
#include "CValueData.h"
#include "TFighterAllocator.h"

struct CMagicOpStoredObj												//���ս�㣺�洢����struct
	:public CFighterMallocObject
{
	CMagicOpStoredObj() : m_MOPArg(int32(0)), m_uMOPRet(0), m_bValid(false) {}
	CMagicOpStoredObj(int32 iValue1, uint32 uValue2)
		: m_MOPArg(iValue1), m_uMOPRet(uValue2), m_bValid(true)
	{

	}
	CMagicOpStoredObj(CValueData Value1, uint32 uValue2)
		: m_MOPArg(Value1), m_uMOPRet(uValue2), m_bValid(true)
	{

	}
	CValueData	m_MOPArg;		//ħ����������
	uint32		m_uMOPRet;		//ħ����������ֵ
	bool		m_bValid;		//ħ�����������Ƿ���Ч������ֵ��
};

//typedef vector<CMagicOpStoredObj> VecMopStoredObj;						//һά��ͬ����ħ�������ĸ�����vector

class CFighterDictator;
class CSkillInstServer;

class CMagicEffDataMgrServer
	:public CFighterMallocObject
{
public:
	CMagicEffDataMgrServer(CFighterDictator* pFrom);
	~CMagicEffDataMgrServer();

	void Clear();
	void CreateArrayMopData(uint32 uCount);
	const CMagicOpStoredObj& GetArrayMopData(uint32 uIndex)const;
	const CMagicOpStoredObj& GetArrayMopDataForMagicState(uint32 uIndex, CSkillInstServer* pSkillInst)const;
	const CMagicOpStoredObj& GetArrayMopDataForOther(uint32 uIndex, CSkillInstServer* pSkillInst)const;
	void SetArrayMopDataForMagicState(uint32 uIndex, const CMagicOpStoredObj& pMopData);
	void SetArrayMopDataForOther(uint32 uIndex, const CMagicOpStoredObj& pMopData);
	void CopyDataWithRatioFrom(const CMagicEffDataMgrServer* pSrc, float fRatio);
	uint32 GetArrayLen()const { /*return m_uArrayLen;*/ return m_vecMopData.size(); }
	void AddMopData(const CMagicOpStoredObj& pMopData) {m_vecMopData.push_back(pMopData);}

	//	CMagicEffDataMgrServer()
	//	{
	//		for(uint32 i = 0; i < eEMT_StoredObjEnd; i++)
	//		{
	//			ArrayVecMopData[i].clear();
	//		}
	//	}
	//VecMopStoredObj ArrayVecMopData[eEMT_StoredObjEnd];					//��ά��ħ���������͵�������array

	uint32 GetFromID();
	void SetFromID(uint32 uFromID);

private:
	//uint32				m_uArrayLen;
	//CMagicOpStoredObj*	m_pArrayMopData;									//��ά��ħ���������͵�������array
	vector<CMagicOpStoredObj,TFighterAllocator<CMagicOpStoredObj> > m_vecMopData;
	uint32				m_uFromID;

	static uint32		m_uOrder;
};

typedef map<uint32, CMagicEffDataMgrServer*, less<uint32>, TFighterAllocator<pair<uint32, CMagicEffDataMgrServer*> > >	MapEffDataMgrServer;

class CEffDataByGlobalIDMgr
	:public CFighterMallocObject
{
public:
	CEffDataByGlobalIDMgr(): m_pSelfEffData(NULL)		{}
	~CEffDataByGlobalIDMgr();

	CMagicEffDataMgrServer*		AddEffData(uint32 uGlobalID, CFighterDictator* pFrom);
	CMagicEffDataMgrServer*		GetEffData(uint32 uGlobalID);
	void						DelEffData(uint32 uGlobalID);
	void						Clear();
	CMagicEffDataMgrServer*		AddSelfEffData(CFighterDictator* pFrom);
	CMagicEffDataMgrServer*		GetSelfEffData();
	void						DelSelfEffData();
private:
	CMagicEffDataMgrServer*		m_pSelfEffData;
	MapEffDataMgrServer			m_pMapEffData;
};

