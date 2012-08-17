#include "stdafx.h"
#include "LoadSkillCommon.h"
#include "CSpecialStateCfg.h"
#include "CTxtTableFile.h"
#include "CCfgColChecker.inl"
#include "BaseHelper.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}


//��ʼ����̬��Ա
CSpecialStateCfgServer::MapSpecialStateCfg CSpecialStateCfgServer::m_mapCfg;
CSpecialStateCfgServer::MapSpecialStateCfgById CSpecialStateCfgServer::m_mapCfgById;
CSpecialStateCfgServer::MapSpecialStateType CSpecialStateCfgServer::m_mapSpecailStateType;
bool CSpecialStateCfgServer::__init = CSpecialStateCfgServer::InitMapType();
CSpecialStateCfgServerSharedPtr CSpecialStateCfgServer::ms_NULL;

CSpecialStateCfgServer::CSpecialStateCfgServer()
: CBaseStateCfgServer(eSGT_SpecialState)
{
}

CSpecialStateCfgServer::CSpecialStateCfgServer(const CSpecialStateCfgServer& cfg)
:CBaseStateCfgServer(cfg)
,m_eSSType(cfg.m_eSSType)
{
}

CSpecialStateCfgServer::~CSpecialStateCfgServer()
{
}

bool CSpecialStateCfgServer::LoadConfig(const TCHAR* cfgFile)
{
	using namespace CfgChk;

	InitMapType();

	CTxtTableFile TabFile;
	stringstream ExpStr;				//�����쳣���
	CSpecialStateCfgServer*	pCfgNode;

	SetTabFile(TabFile, "����״̬");
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), cfgFile)) return false;

	ClearMap(m_mapCfg);

	for(int32 i=1; i<TabFile.GetHeight(); ++i)
	{
		SetLineNo(i);
		pCfgNode = new CSpecialStateCfgServer;
		pCfgNode->m_eGlobalType = eSGT_SpecialState;
		pCfgNode->m_uId = eSIC_SpecialState + i;

		ReadItem(pCfgNode->m_sName,				szSpecialState_Name);
		ReadItem(pCfgNode->m_eDecreaseType,		szTplState_DecreateType,		CANEMPTY,	eDST_Increase,	ms_mapDecreaseType);
		ReadItem(pCfgNode->m_bDispellable,		szTplState_Dispellable,			CANEMPTY,	YES);
		ReadItem(pCfgNode->m_eIconCancelCond,	szBaseState_CancelCond,			CANEMPTY,	eICC_None,		ms_mapIconCancelCond);
		ReadItem(pCfgNode->m_calcTime,			szSpecialState_Time,			GE,			-1);
		ReadItem(pCfgNode->m_eSSType,			szSpecialState_Type,			m_mapSpecailStateType);
		ReadItem(pCfgNode->m_sModel,			szTplState_Model,				CANEMPTY);
		//ReadItem(pCfgNode->m_fScale,			szTplState_Scale,				CANEMPTY,	1.0f,			GT,		0.0f);

		CCfgCalc* pCalc = NULL;
		ReadMixedItem(pCalc,			szTplState_Scale,				CANEMPTY,	"");
		if(pCalc->GetTestString().empty())
		{
			pCfgNode->m_fScale = 1.0f;
			pCfgNode->m_fScaleTime = 0.0f;
		}
		else
		{
			int32 iValueCount = pCalc->GetValueCount();
			pCfgNode->m_fScale = (float)pCalc->GetDblValue(0);
			if(iValueCount > 1)
			{
				pCfgNode->m_fScaleTime = (float)pCalc->GetDblValue(1);
			}
			else
			{
				pCfgNode->m_fScaleTime = 0.0f;
			}
		}

		string sFx;
		ReadItem(sFx,				szTplState_FXID,		CANEMPTY,		"");
		if(!pCfgNode->m_sModel.empty() || !pCfgNode->m_sModel.empty() || !pCalc->GetTestString().empty()
			|| !sFx.empty())
		{
			pCfgNode->SetNeedSync();
		}

		delete pCalc;

		pCfgNode->m_bDecrease = pCfgNode->m_eDecreaseType <= eDST_IncreaseEnd ? false : true;

		if (pCfgNode->m_calcTime->IsSingleNumber())
		{
			pCfgNode->SetNeedSaveToDB(pCfgNode->m_calcTime->GetDblValue());
		}

		//pCfgNode->m_bPersistent = false;

		ReadItem(pCfgNode->m_bPersistent,			szState_Persistent,				CANEMPTY,		NO);

		CSpecialStateCfgServerSharedPtr* pCfgNodeSharedPtr = new CSpecialStateCfgServerSharedPtr(pCfgNode);
		InsertStringSharedPtrMap(m_mapCfg, pCfgNodeSharedPtr);
		InsertUint32SharedPtrMap(m_mapCfgById, pCfgNodeSharedPtr);
	}

	return true;
}

bool CSpecialStateCfgServer::InitMapType()					//��������״̬�����ַ�������Ӧö�����͵�ӳ��
{
	m_mapSpecailStateType["����"]	  = eSST_Reflect;
	m_mapSpecailStateType["DOT����"] = eSST_DOTImmunity;
	m_mapSpecailStateType["�����ƶ�"]	  = eSST_DirMove;
	m_mapSpecailStateType["��ʬ״̬"]	  = eSST_DeadBody;
	return true;
}

void CSpecialStateCfgServer::UnloadConfig()
{
	ClearMap(m_mapCfg);
}

CSpecialStateCfgServerSharedPtr& CSpecialStateCfgServer::Get(const string& name)
{
	MapSpecialStateCfg::iterator mapCfgItr;
	mapCfgItr = m_mapCfg.find(name);
	if (mapCfgItr == m_mapCfg.end())
	{
		stringstream ExpStr;
		ExpStr << "����״̬��������";
		CfgChk::GenExpInfo(ExpStr.str(), name);
		return ms_NULL;
	}
	return *(mapCfgItr->second);
}

