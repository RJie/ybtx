#include "stdafx.h"
#include "CPersistentState.h"
#include "CCfgColChecker.inl"
#include "LoadSkillCommon.h"
#include "CBaseStateServer.h"
#include "CMagicStateCfg.h"
#include "CTriggerStateCfg.h"
#include "CDamageChangeStateCfg.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

//CForceNoSaveStateCfgServer::MapForceNoSaveStateCfgServer CForceNoSaveStateCfgServer::m_mapCfg;

bool CPersistentStateCfgServer::LoadConfig(const TCHAR* cfgFile)
{
	using namespace CfgChk;

	CTxtTableFile TabFile;
	//CPersistentStateCfgServer*	pCfgNode;
	SetTabFile(TabFile, "����״̬");
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), cfgFile)) return false;

	UnloadConfig();

	string sName;

	bool bRet = true;

	for(int32 i=1; i<TabFile.GetHeight(); ++i)
	{
		SetLineNo(i);
		//pCfgNode = new CPersistentStateCfgServer;
		ReadItem(sName,					szGlobalState_Name);


		CBaseStateCfgServer* pGlobalCfg = class_cast<CBaseStateCfgServer*>(CBaseStateCfgServer::GetByGlobalName(sName));
		if(pGlobalCfg)
		{
			const CCfgCalc* pCalcTime = pGlobalCfg->GetTime();
			pCalcTime->SetTypeExpression();
			if(pCalcTime->IsConstValue() && pCalcTime->GetIntValue() != -1)
			{
				switch(pGlobalCfg->GetGlobalType())
				{
				case eSGT_MagicState:
					{
						SetTabName("ħ��״̬");
						CMagicStateCfgServer* pCfg = class_cast<CMagicStateCfgServer*>(pGlobalCfg);
						Ast(pCfg);
						if(pCfg->GetCancelableMagicEff())
						{
							//bRet = pCfg->GetCancelableMagicEff()->CheckMagicOpRelationAvail(CMagicOpTreeServer::CheckCanExecuteWithTargetIsDead);
							ResetTab(TabFile, "����״̬");
						}
					}
					break;
				case eSGT_TriggerState:
					{
						SetTabName("������״̬");
						CTriggerStateCfgServer* pCfg = class_cast<CTriggerStateCfgServer*>(pGlobalCfg);
						Ast(pCfg);
						if(pCfg->GetCancelableMagicEff())
						{
							//bRet = pCfg->GetCancelableMagicEff()->CheckMagicOpRelationAvail(CMagicOpTreeServer::CheckCanExecuteWithTargetIsDead);
							ResetTab(TabFile, "����״̬");
						}
					}
					break;
				case eSGT_DamageChangeState:
					{
						SetTabName("�˺����״̬");
						CDamageChangeStateCfgServer* pCfg = class_cast<CDamageChangeStateCfgServer*>(pGlobalCfg);
						if(pCfg->GetCancelableMagicEff())
						{
							//bRet = pCfg->GetCancelableMagicEff()->CheckMagicOpRelationAvail(CMagicOpTreeServer::CheckCanExecuteWithTargetIsDead);
							ResetTab(TabFile, "����״̬");
						}
					}
					break;
				case eSGT_CumuliTriggerState:
					{
						SetTabName("���۴�����״̬");
						CTriggerStateCfgServer* pCfg = class_cast<CTriggerStateCfgServer*>(pGlobalCfg);
						Ast(pCfg);
						if(pCfg->GetCancelableMagicEff())
						{
							//bRet = pCfg->GetCancelableMagicEff()->CheckMagicOpRelationAvail(CMagicOpTreeServer::CheckCanExecuteWithTargetIsDead);
							ResetTab(TabFile, "����״̬");
						}
					}				case eSGT_SpecialState:
					break;
				default:
					{
						stringstream str;
						str << "״̬[" << pGlobalCfg->GetName() << "]���಻��\n";
						CfgChk::GenExpInfo(str.str());
					}
				}
			}
			pGlobalCfg->m_bPersistent = true;
		}


		//InsertMap(m_mapCfg, pCfgNode);
	}

	return bRet;
}

void CPersistentStateCfgServer::UnloadConfig()
{
	//ClearMap(m_mapCfg);
}

