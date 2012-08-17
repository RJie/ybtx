#pragma once
#include "CCfgCalc.h"
#include "FightDef.h"
#include "ActorDef.h"
#include "CPos.h"
#include "CTxtTableFile.h"
#include "CSkillRuleDef.h"
#include "TConfigAllocator.h"
#include "TCfgSharedPtr.h"
#include "TStringRef.h"

class CMagicOpTreeServer;

typedef bool (*MOP_MATCH_CHECKER)(CMagicOpTreeServer*);

class CMagicCondServer;
class CBaseMagicOpServer;
class CGenericTarget;
class CFighterDictator;
class CMagicOpServer;
class CValueMagicOpServer;
class CFunctionMagicOpServer;
class CPosMagicOpServer;
class CSkillInstServer;
class CMagicEffDataMgrServer;
struct FilterLimit;
class CCfgArg;

struct MagicOpValue
	:public CConfigMallocObject
{
	MagicOpValue():uMagicOpResult(0),iMagicOpValue(0){}
	uint32 uMagicOpResult;
	int32 iMagicOpValue;
};

struct MagicEffFilter 
	:public CConfigMallocObject
{
	MagicEffFilter():m_eObjectFilter(eOF_None),m_FilterPara(NULL) {}
	~MagicEffFilter()	{delete m_FilterPara;}
	EObjFilterType	m_eObjectFilter;	// Ŀ��ɸѡ����
	CCfgCalc*		m_FilterPara;		// ɸѡ����
};

class CMagicOpTreeServer
	:public CConfigMallocObject
{
	friend class CMagicEffServer;
	friend class CCfgRelationDeal;
public:
	typedef vector<uint32, TConfigAllocator<uint32> > VecEntityID;

private:
	CMagicOpTreeServer(CTxtTableFile& MagicEffFile, uint32 uNum, uint32 uLineNum);
	~CMagicOpTreeServer(void);

	typedef map<uint32, uint32, less<uint32>, TConfigAllocator<pair<uint32,uint32> > >	MapCond;
	typedef list<CMagicOpTreeServer*, TConfigAllocator<CMagicOpTreeServer*> > ListChild;
	typedef vector<MagicOpValue*,TConfigAllocator<MagicOpValue*> > VecResult;
	
	typedef map<string, CBaseMagicOpServer*, less<string>, TConfigAllocator<pair<string, CBaseMagicOpServer*> > >	MapMagicOp;
	typedef map<string, EHurtResult, less<string>, TConfigAllocator<pair<string, EHurtResult> > >			MapMOPResultType;
	typedef map<string, EFxType, less<string>, TConfigAllocator<pair<string, EFxType> > >				MapFxType;
	static void BuildMOPMap();
	static void BuildMOPResultMap();
	static void BuildFxTypeMap();

	void AddChild(CMagicOpTreeServer* pChild);
	bool HasChild();
	CMagicOpTreeServer* FindNode(uint32 uNum);
	bool CanDo(const VecResult& vecResult);
	uint32 FilterTargetAndExec(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecResult& vecResult,VecEntityID& vecEntityID,CMagicEffDataMgrServer* pCancelDataMgr, uint32& eHurtResult);
	void ExecWithNoFilterTarget(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CMagicEffDataMgrServer* pCancelDataMgr, uint32& eHurtResult);
	uint32 Do(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecResult& vecResult,VecEntityID& vecEntityID,CMagicEffDataMgrServer* pCancelDataMgr);
	EDoSkillResult DoMagicCond(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecEntityID& vecEntityID);		// ִ��ħ������
	void CancelTempMOP(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecResult& vecResult, CMagicEffDataMgrServer* pCancelDataMgr/* = NULL*/);
	void Cancel(CSkillInstServer* pSkillInst, CFighterDictator* pOwner, CMagicEffDataMgrServer* pCancelDataMgr/* = NULL*/);
	void PreDoMagicCond(CSkillInstServer* pSkillInst);
	bool PreDoMagicOp(CSkillInstServer* pSkillInst);
	uint32 DoMagicOp(CFunctionMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, CFighterDictator* pTo);
	uint32 DoMagicOp(CValueMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, CFighterDictator* pTo, int32* pTempValue, size_t iTargetIndex, CMagicEffDataMgrServer* pCancelDataMgr/* = NULL*/);
	uint32 DoMagicOp(CPosMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, const CFPos& pTo);
	void CancelMagicOp(CBaseMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pTo, CMagicEffDataMgrServer* pCancelDataMgr);
	int32 GetLineNo()				{return (int32)m_uId;} //��ȡ�кţ���ʱ��ID��
	static void MakeFilterLimit(FilterLimit& filterLimit,CSkillInstServer* pInst,CMagicOpTreeServer* pMagicOpTree,CFighterDictator* pFrom);
	bool StateMopNeedForceCalc(CSkillInstServer* pSkillInst);
	
public:

	static VecEntityID& GetEntityIdVec();
	static VecResult& GetVecResult();
	static void ReleaseEntityIdVec(VecEntityID& vecEntityID);
	static void ReleaseVecResult(VecResult& vecResult);
	static void DeleteAll();
	void InitMagicOpArg();
private:
	static MapMagicOp			ms_mapMagicOp;
	static MapMOPResultType		ms_mapMOPResultType;
	static MapFxType			ms_mapFxType;
	MapCond						m_mapCond;
	ListChild					m_listChild;
	CMagicOpTreeServer*			m_pParent;
	uint32						m_uIndex;			// ���
	uint32						m_uId;				// ���кű�ʾ��ID
	CBaseMagicOpServer*			m_pMagicOp;			// ħ������
	string						m_strMagicOpName;	// ħ����������
	string						m_strMOPType;		// ħ���������ͼ����
	string						m_strMagicOpArg;	// ħ����������
	CCfgArg*					m_MagicOpArg;		// ħ����������
	vector<MagicEffFilter*>		m_vecFilterPipe;	// ɸѡ�ܵ�
	string						m_strFX;			// ��Ч
	EFxType						m_eFxType;			// ��Ч����
	static vector<VecEntityID*, TConfigAllocator<VecEntityID*> >		ms_vecEntityID;
	static vector<VecResult*, TConfigAllocator<VecResult*> >			ms_vecResult;

public:
	static uint32 GetMagicOpExecNum();
private:
	static uint32 ms_uExecNum;

};

DefineCfgSharedPtr(CMagicEffServer)

class CMagicEffServer
	:public TStringRefee<CMagicEffServer, CMagicEffServerSharedPtr>
{
	friend class CMagicOpTreeServer;
public:
	CMagicEffServer();
	~CMagicEffServer();
	static bool LoadMagicEff(const string& fileName, bool bReload = false, bool bFirstFile = false);
	static void	UnloadMagicEff();
	static void InitMagicOpArg();	
	static CMagicEffServerSharedPtr&		GetMagicEff(const string& name);
	static CMagicEffServerSharedPtr&		GetMagicEff(uint32 id);
	EDoSkillResult DoMagicCond(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo);		// ִ��ħ������	
	void Do(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo, CMagicEffDataMgrServer* pCancelDataMgr = NULL);				// ִ��ħ��Ч��
	void Do(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CFighterDictator* pTo, CMagicEffDataMgrServer* pCancelDataMgr = NULL);				// ִ��ħ��Ч��, ��Ҫ�ṩ��ħ��״̬����
	void Cancel(CSkillInstServer* pSkillInst, CFighterDictator* pOwner, CMagicEffDataMgrServer* pCancelDataMgr/* = NULL*/);
	uint32 GetId()				{return m_uId;}
	const string&		GetName()const							{return m_strName;}
	uint32				GetMOPCount()						{return m_uCount;}
private:
	typedef TStringRefee<CMagicEffServer, CMagicEffServerSharedPtr>	ParentType;
	typedef ParentType::MapImpClass							MapMagicEffServerByName;
	typedef map<uint32, CMagicEffServerSharedPtr*>			MapMagicEffServerById;

	void CreateStoredObjArray(CSkillInstServer* pSkillInst, CMagicEffDataMgrServer* pCancelDataMgr);

	static MapMagicEffServerByName&					GetStringKeyMap();
	static MapMagicEffServerById					ms_mapMagicEffServerById;
	static uint32		ms_uMaxLineNum;				//����к�
	uint32				m_uId;						// ���
	uint32				m_uCount;
	string				m_strName;					// ħ��Ч����
	CMagicOpTreeServer* m_pRoot;

public:
	static uint32 GetMagicEffExecNum();
private:
	static uint32 ms_uExecNum;
	static CMagicEffServerSharedPtr ms_NULL;
};

