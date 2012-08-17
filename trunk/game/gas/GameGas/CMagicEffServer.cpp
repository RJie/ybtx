#include "stdafx.h"
#include "CMagicEffServer.h"
#include "LoadSkillCommon.h"
#include "CCfgCalc.inl"
#include "CTxtTableFile.h"
#include "CGenericTarget.h"
#include "CFighterDictator.h"
#include "MagicOpPoss_Function.h"
#include "MagicOps_ChangeValue.h"
#include "MagicOps_Damage.h"
#include "MagicOps_Function.h"
#include "MagicConds_TestValue.inl"
#include "MagicConds_Function.h"
#include "CFilterOpServer.h"
#include "CMagicStateInstServer.h"
#include "CMagicStateCfg.h"
#include "CTempVarServer.h"
#include "CSkillInstServer.h"
#include "CCharacterDictator.h"
#include "CSkillMgrServer.h"
#include "CEntityServerManager.h"
#include "ErrLogHelper.h"
#include "CBaseStateServer.h"
#include "BaseHelper.h"
#include "CCoreSceneServer.h"
#include "CIntObjServer.h"
#include "TSqrAllocator.inl"
#include "TStringRef.inl"

template class TStringRefee<CMagicEffServer, CMagicEffServerSharedPtr>;

uint32 CMagicEffServer::ms_uExecNum = 0;

vector<CMagicOpTreeServer::VecResult*, TConfigAllocator<CMagicOpTreeServer::VecResult*> >	CMagicOpTreeServer::ms_vecResult;
vector<CMagicOpTreeServer::VecEntityID*, TConfigAllocator<CMagicOpTreeServer::VecEntityID*> >	CMagicOpTreeServer::ms_vecEntityID;
uint32 CMagicOpTreeServer::ms_uExecNum = 0;



void CMagicOpTreeServer::DeleteAll()
{
	uint32 uCount = ms_vecResult.size();
	for(size_t i = 0; i < uCount; ++i)
	{
		ClearVector(*ms_vecResult[i]);
		SafeDelete(ms_vecResult[i]);
	}
	ms_vecResult.clear();
	ClearVector(ms_vecEntityID);
}

CMagicOpTreeServer::VecEntityID& CMagicOpTreeServer::GetEntityIdVec()
{
	if (ms_vecEntityID.empty())
	{
		return *(new VecEntityID);
	}
	VecEntityID* uEntityID = ms_vecEntityID.back();
	ms_vecEntityID.pop_back();
	return *uEntityID;
}

void CMagicOpTreeServer::ReleaseEntityIdVec(VecEntityID& vecEntityID)
{
	vecEntityID.clear();
	ms_vecEntityID.push_back(&vecEntityID);
}

CMagicOpTreeServer::VecResult& CMagicOpTreeServer::GetVecResult()
{
	if(ms_vecResult.empty())
	{
		return *(new VecResult);
	}
	VecResult* vecResult = ms_vecResult.back();
	ms_vecResult.pop_back();
	return *vecResult;
}

void CMagicOpTreeServer::ReleaseVecResult(VecResult& vecResult)
{
	//SafeDelCtn1(vecResult);
	uint32 uCount = vecResult.size();
	for(size_t i = 0; i < uCount; ++i)
	{
		vecResult[i]->uMagicOpResult = 0;
		vecResult[i]->iMagicOpValue = 0;
	}
	ms_vecResult.push_back(&vecResult);
}


void CMagicEffServer::Do(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo, CMagicEffDataMgrServer* pCancelDataMgr)
{
	CGenericTarget Target(*pTo);
	pSkillInst->AddRef();
	CMagicOpTreeServer::VecResult& vecResult = CMagicOpTreeServer::GetVecResult();
	
	for(size_t i = vecResult.size(); i < m_uCount; ++i)
	{
		vecResult.push_back(new MagicOpValue);
	}
	
	CreateStoredObjArray(pSkillInst, pCancelDataMgr);

	CMagicOpTreeServer::VecEntityID& vecEntityID = CMagicOpTreeServer::GetEntityIdVec();

	SQR_TRY
	{
		m_pRoot->Do(pSkillInst, pFrom, &Target, vecResult,vecEntityID, pCancelDataMgr);
	}
	SQR_CATCH(exp)	//Ϊ�˱����ⲿ�����ڵ���ħ��Ч���������쳣������µ������߼�����Ҫ�ڴ˼����ݴ�
	{
		string strErrMsg(exp.ErrorMsg());
		ostringstream strm;		
		strm << " CMagicEffServer::Do m_pRoot->Do " << GetName() << " skillname " << pSkillInst->GetSkillName()<<endl;

		//�����Npc���ӡNpc���������ڲ�bug
		if(pFrom && pFrom->GetCharacter() && !pFrom->CastToFighterMediator())
		{
			strm<<"ValidityCoefficient("<<pFrom->m_ValidityCoefficient.Get(pFrom)<<")";
			strm<<"NatureSmashValue("<<pFrom->m_NatureSmashValue.Get(pFrom)<<")";
			strm<<"DestructionSmashValue("<<pFrom->m_DestructionSmashValue.Get(pFrom)<<")";
			strm<<"EvilSmashValue("<<pFrom->m_EvilSmashValue.Get(pFrom)<<")";
			strm<<"DefenceSmashValue("<<pFrom->m_DefenceSmashValue.Get(pFrom)<<")";
			strm<<"self npc name :"<<pFrom->GetCharacter()->GetNpcName()<<endl;
		}
		CFighterDictator* pToFighter = pTo->GetFighter();
		if (pToFighter && pToFighter->GetCharacter() && !pToFighter->CastToFighterMediator())
		{
			strm<<"NatureResistanceValue("<<pToFighter->m_NatureResistanceValue.Get(pToFighter)<<")";
			strm<<"DestructionResistanceValue("<<pToFighter->m_DestructionResistanceValue.Get(pToFighter)<<")";
			strm<<"EvilResistanceValue("<<pToFighter->m_EvilResistanceValue.Get(pToFighter)<<")";
			strm<<"m_Defence("<<pToFighter->m_Defence.Get(pToFighter)<<")";
			strm<<"target npc name :"<<pTo->GetFighter()->GetCharacter()->GetNpcName()<<endl;
		}

		exp.AppendMsg(strm.str().c_str());

		if(pFrom)
		{
			CConnServer* pConn = pFrom->GetConnection();
			if(pConn)
				LogExp(exp, pConn);
		}
		LogExp(exp);
	}
	SQR_TRY_END;

	CMagicOpTreeServer::ReleaseEntityIdVec(vecEntityID);

	SQR_TRY
	{
		if(pSkillInst->GetType() == eIT_MagicStateInst)
		{
			if(!pSkillInst->GetIsCalc())
			{
				//��ʱ��Ϊ��ʹpFrom����ҲҪִ�г���
				m_pRoot->CancelTempMOP(pSkillInst, pFrom, &Target, vecResult, pCancelDataMgr);
			}
		}
		else
		{
			//��ʱ��Ϊ��ʹpFrom����ҲҪִ�г���
			m_pRoot->CancelTempMOP(pSkillInst, pFrom, &Target, vecResult, pCancelDataMgr);
		}
	}
	SQR_CATCH(exp)	//Ϊ�˱����ⲿ�����ڵ���ħ��Ч���������쳣������µ������߼�����Ҫ�ڴ˼����ݴ�
	{
		string strErrMsg(exp.ErrorMsg());
		ostringstream strm;		
		strm << " CMagicEffServer::Do m_pRoot->CancelTempMOP " << GetName() << " skillname " << pSkillInst->GetSkillName() << endl;
		exp.AppendMsg(strm.str().c_str());

		if(pFrom)
		{
			CConnServer* pConn = pFrom->GetConnection();
			if(pConn)
				LogExp(exp, pConn);
		}
		LogExp(exp);
	}
	SQR_TRY_END;

	CMagicOpTreeServer::ReleaseVecResult(vecResult);
	pSkillInst->DelRef();

#if defined _FightSkillCounter
	++ms_uExecNum;
#endif
}

void CMagicEffServer::Do(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CFighterDictator* pTo, CMagicEffDataMgrServer* pCancelDataMgr)
{
	CGenericTarget Target(pTo);
	Do(pSkillInst, pFrom, &Target, pCancelDataMgr);
}

EDoSkillResult CMagicEffServer::DoMagicCond(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo)
{
	CMagicOpTreeServer::VecEntityID& vecEntityID = CMagicOpTreeServer::GetEntityIdVec();
	EDoSkillResult eDoSkillRet = m_pRoot->DoMagicCond(pSkillInst,pFrom,pTo,vecEntityID);
	CMagicOpTreeServer::ReleaseEntityIdVec(vecEntityID);
	return eDoSkillRet;
}

void CMagicEffServer::Cancel(CSkillInstServer* pSkillInst, CFighterDictator* pOwner, CMagicEffDataMgrServer* pCancelDataMgr)
{
	SQR_TRY
	{
		m_pRoot->Cancel(pSkillInst, pOwner, pCancelDataMgr);
	}
	SQR_CATCH(exp)
	{
		if(pOwner)
		{
			CConnServer* pConn = pOwner->GetConnection();
			if(pConn)
			{
				LogExp(exp, pConn);
			}
			else
			{
				LogExp(exp);
			}
		}
	}
	SQR_TRY_END;
}

uint32 CMagicEffServer::GetMagicEffExecNum()
{
	return ms_uExecNum;
}

bool CMagicOpTreeServer::CanDo(const VecResult& vecResult)
{
	MapCond::iterator it = m_mapCond.begin();
	for(; it != m_mapCond.end(); ++it)
	{
		int32 iNodeNum = it->first;
		int32 iRet = it->second;

		if(vecResult[iNodeNum-1]->uMagicOpResult != uint32(iRet))
		{
			return false;
		}
	}
	return true;
}

uint32 CMagicOpTreeServer::FilterTargetAndExec(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecResult& vecResult,VecEntityID& vecEntityID,CMagicEffDataMgrServer* pCancelDataMgr, uint32& eHurtResult)
{
	FilterLimit filterLimit;
	MakeFilterLimit(filterLimit, pSkillInst, this, pFrom);
	CFilterOpServer::FilterByPipe(pSkillInst, vecEntityID, m_vecFilterPipe, filterLimit, pFrom, pTo);

	VecEntityID::iterator it_obj = vecEntityID.begin();
	uint32 uObjCount = 0;
	uint32 uCount = vecEntityID.size();
	bool bAnyoneIsSuccess = false;	//�ò���ֻҪ��һ��Ŀ���ִ�н��Ϊ�ɹ������������ķ���ֵΪ�ɹ���Ŀǰ�ù���ֻ������ħ��������ħ�������ķ���ֵ���ǵ������������һ��Ŀ��ķ���ֵ
	for(; it_obj != vecEntityID.end(); ++it_obj)
	{
		--uCount;
		if (uCount == 0)
			pSkillInst->SetBeLastEffect(true);
		CEntityServer* pCharacter = CEntityServerManager::GetInst()->GetEntityByID(*it_obj);			
		if (!pCharacter ||
			(!pCharacter->GetFighter()->CppIsAlive() && !pSkillInst->GetTargetAliveCheckIsIgnored() &&
			 !m_pMagicOp->CanExecuteWithTargetIsDead()))
			/*|| (pTo->CppIsAlive() && pSkillInst->m_bTargetAliveCheckIsIgnored))*/	//!(*it_obj)���ж�����ΪĿ������Ϊ�Լ�ʱ(*it_obj)ֵΪpFrom����ʩ�������ߣ�������pFromΪNULL����(*it_obj)ΪNULL
			//֮���԰������������ε�����Ϊit_obj�п���Ϊ����������������Ƕ�ʬ��ʩ�ŵģ���������»������ЩɸѡĿ��Ϊ��������ħ���������ᱻִ��
		{
			continue;
		}
		CFighterDictator* pTarget=pCharacter->GetFighter();
		if(!pTarget)	//û��fighter��entity...
		{
			ostringstream strm;
			EGameEntityType type = pCharacter->GetGameEntityType();
			switch(type)
			{
			case eGET_CharacterDictator:
				strm << class_cast<CCharacterDictator*>(pCharacter)->m_sNpcName;
				break;
			case eGET_IntObject:
				strm << class_cast<CIntObjServer*>(pCharacter)->GetObjName();
				break;
			default:
				break;
			}

			strm << pCharacter->GetGameEntityType() << pCharacter->GetObjValidState() << endl;
			GenErr("����û��fighter��entity... entity_type,ObjValidState = ", strm.str());
		}
		uObjCount++;

		if (m_pMagicOp->GetType() == eMOPCT_MagicCondition)
		{		
			uint32 eResult;
			CMagicCondServer* pMagicCondOp = class_cast<CMagicCondServer*>(m_pMagicOp);

			if (pMagicCondOp->GetMagicCondType() == eMCT_Function)
			{
				CFunctionMagicCondServer* pMagicCondOp = class_cast<CFunctionMagicCondServer*>(m_pMagicOp);
				eResult = pMagicCondOp->Test(pSkillInst, m_MagicOpArg, pFrom, pTarget);
			}
			else
			{
				CValueMagicCondServer* pMagicCondOp = class_cast<CValueMagicCondServer*>(m_pMagicOp);
				eResult = pMagicCondOp->Test(pSkillInst, m_MagicOpArg, pFrom, pTarget);
			}
			
			if (eResult != eDSR_Success)
			{
				if(!bAnyoneIsSuccess)	//����Ѿ���һ��Ŀ���ִ�н��Ϊ�ɹ�������Ҫ����eHurtResult����
				{
					eHurtResult = eHR_Fail;
				}
			}
			else
			{
				bAnyoneIsSuccess = true;
				eHurtResult = eHR_Success;
			}
		}
		else if(m_pMagicOp->GetType() == eMOPCT_MagicOP)
		{
			CMagicOpServer * pMagicOp = class_cast<CMagicOpServer*>(m_pMagicOp);

			if (pMagicOp->GetMagicOpType()==eMOT_Function)
			{
				CFunctionMagicOpServer * pMagicOp = class_cast<CFunctionMagicOpServer*>(m_pMagicOp);
				eHurtResult = DoMagicOp(pMagicOp, pSkillInst, m_MagicOpArg, pFrom, pTarget);
			}
			else if(pMagicOp->GetMagicOpType() == eMOT_PosFunction)
			{
				CPosMagicOpServer * pMagicOp = class_cast<CPosMagicOpServer*>(m_pMagicOp);
				CFPos pos;
				pTarget->GetPixelPos(pos);
				eHurtResult = DoMagicOp(pMagicOp, pSkillInst, m_MagicOpArg, pFrom, pos);
			}
			else
			{
				CValueMagicOpServer* pMagicOp = class_cast<CValueMagicOpServer*>(m_pMagicOp);

				if (pFrom)
				{
					eHurtResult = DoMagicOp(pMagicOp, pSkillInst, m_MagicOpArg, pFrom, pTarget, &(pFrom->GetTempVarMgr()->m_iMopCalcValue), it_obj - vecEntityID.begin(), pCancelDataMgr);
					vecResult[m_uIndex-1]->iMagicOpValue = pFrom->GetTempVarMgr()->m_iMopCalcValue;
				}
				else
				{
					eHurtResult = DoMagicOp(pMagicOp, pSkillInst, m_MagicOpArg, pFrom, pTarget, &(vecResult[m_uIndex-1]->iMagicOpValue), it_obj - vecEntityID.begin(), pCancelDataMgr);
				}
			}

			if(!(pSkillInst->GetType() == eIT_MagicStateInst && pSkillInst->GetIsCalc()))
			{
				if (m_strFX != "" || m_eFxType == eFT_Suffer)
				{
					bool bPlayFx = true;
					vector<MagicEffFilter*>::iterator it = m_vecFilterPipe.begin();
					if ((*it)->m_eObjectFilter == eOF_Position)
						bPlayFx = false;
					pTarget->GetSkillMgr()->OnDoMagicOp(m_uId, true, pFrom?pFrom->GetEntityID():0, pTarget?pTarget->GetEntityID():0, CFPos(0,0), eHurtResult, bPlayFx);
				}
			}
		}
	}

	return uObjCount;
}

void CMagicOpTreeServer::ExecWithNoFilterTarget(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CMagicEffDataMgrServer* pCancelDataMgr, uint32& eHurtResult)
{
	eHurtResult = eHR_Fail;

	if(m_pMagicOp->GetType()==eMOPCT_MagicOP && class_cast<CMagicOpServer*>(m_pMagicOp)->GetMagicOpType()==eMOT_Value &&
	   pSkillInst->GetType() == eIT_MagicStateInst && pSkillInst->GetIsCalc())
	{
		//ħ��״̬�����ٴ�ɸѡĿ��Ϊ��Χѡ���ħ������ʱ������ЧĿ�꼯��Ϊ�գ����������ִ��һ��DoMagicOp()����calc�Ա�֤֮����ܳ��ֵĵ�exec�м���������
		//��������ʱ����ִ��ħ��״̬�ı�ֵЧ���ļ��㣬�������Ҫ����ʱ��װ��ħ��״̬���ֲ�ִ��״̬���е��κθı�ֵЧ������������Ҫ�ų���Ϊ��������uObjCount=0�������
		//����������˵����������ô��̬��Ҫ����������쳣���ӻ�
		//����ħ��״̬֮���״̬����Ҫ����ֵ�����Ҳ����������֧��������Ҫע�⳷���밲װ��Ч����һ�µ����
		CValueMagicOpServer* pMagicOp = class_cast<CValueMagicOpServer*>(m_pMagicOp);
		if(pMagicOp->CalcNeedTarget(m_MagicOpArg))
		{
			stringstream sExp;
			sExp << ((class_cast<CSkillMagicStateInstServer*>(pSkillInst->GetLocalInst()))->GetCfg()->GetName()) << endl;
			GenErr("��װ״̬ʱ����Ŀ���ٴ�ɸѡ���Ϊ�յĸı�ֵħ���������㲿�ֲ�����Ŀ��Ϊ��", sExp.str());
		}
		else
		{
			eHurtResult = DoMagicOp(pMagicOp, pSkillInst, m_MagicOpArg, pFrom, NULL, &(pFrom->GetTempVarMgr()->m_iMopCalcValue), 0, pCancelDataMgr);
		}
	}
}

uint32 CMagicOpTreeServer::Do(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,
	VecResult& vecResult, VecEntityID& vecEntityID, CMagicEffDataMgrServer* pCancelDataMgr)
{
	pSkillInst->SetValueScale(0);
	uint32 eHurtResult = eHR_Success;
	CEntityServer* pEntity = CEntityServerManager::GetEntityByID(pSkillInst->GetCreatorID());
	CFighterDictator* pFighterCreator = pEntity?pEntity->GetFighter():NULL;

	pSkillInst->SetBeLastEffect(false);
	pSkillInst->SetEffectHPChangeValue(0);
	//���������ʱ��װ�������Ҫִ�м��������Ч����״̬������Ҫ��StateMopNeedForceCalc�����������������㣬����֮�������жϽ�ɫ�����ĵط����ϸ�StateMopNeedForceCalc�Ļ�����
	if( (StateMopNeedForceCalc(pSkillInst) || CanDo(vecResult)) && (pFrom == NULL || pFrom->CppIsAlive() || m_pMagicOp->CanExecuteWithAttackerIsDead()) )
	{
		vector<MagicEffFilter*>::iterator it = m_vecFilterPipe.begin();
		if ((*it)->m_eObjectFilter == eOF_Position && m_vecFilterPipe.size() == 1)
		{
			if (pFrom)
			{
				CFPos pos=pTo->GetPos();
				if (pFighterCreator && (m_strFX != "" || m_eFxType == eFT_Suffer))
					pFighterCreator->GetSkillMgr()->OnDoMagicOp(m_uId, false, pFighterCreator->GetEntityID(), 0, pos);
				CPosMagicOpServer* pMagicOp = class_cast<CPosMagicOpServer*>(m_pMagicOp);
				eHurtResult = DoMagicOp(pMagicOp, pSkillInst, m_MagicOpArg, pFrom, pTo->GetPos());
			}
		}
		else
		{
			if ((*it)->m_eObjectFilter == eOF_Position)
			{
				CFPos pos;
				if (eTT_Position==pTo->GetType())
				{
					pos=pTo->GetPos();
				}
				else
				{
					GenErr("Ŀ�����ʹ���");
				}
				CFighterDictator* pFighter=pFighterCreator?pFighterCreator:pFrom;
				if (pFighter && (m_strFX != "" || m_eFxType == eFT_Suffer))
				{
					pFighter->GetSkillMgr()->OnDoMagicOp(m_uId, false, pFighterCreator->GetEntityID(), 0, pos);
				}
			}

			if(FilterTargetAndExec(pSkillInst, pFrom, pTo, vecResult, vecEntityID, pCancelDataMgr, eHurtResult) == 0)
			{
				ExecWithNoFilterTarget(pSkillInst, pFrom, pCancelDataMgr, eHurtResult);
			}
		}
		vecResult[m_uIndex-1]->uMagicOpResult = eHurtResult;
	}
	else
	{
		vecResult[m_uIndex-1]->uMagicOpResult = eHR_Fail;
	}

	ListChild::iterator it_list = m_listChild.begin();
	ListChild::iterator it_End= m_listChild.end();
	
	for(; it_list != it_End; ++it_list)
	{
		class_cast<CMagicOpTreeServer*>(*it_list)->Do(pSkillInst, pFrom, pTo, vecResult, vecEntityID,pCancelDataMgr);
	}

#if defined _FightSkillCounter
	++ms_uExecNum;
#endif
	return eHurtResult;
}

EDoSkillResult CMagicOpTreeServer::DoMagicCond(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecEntityID& vecEntityID)
{
	if (!m_pMagicOp->GetType() == eMOPCT_MagicCondition|| !m_mapCond.empty())
		return eDSR_Success;

	PreDoMagicCond(pSkillInst);

	CMagicCondServer* pMagicCond = class_cast<CMagicCondServer*>(m_pMagicOp);
	EDoSkillResult eResult = eDSR_Fail;

	FilterLimit filterLimit;
	MakeFilterLimit(filterLimit, pSkillInst, this, pFrom);
	CFilterOpServer::FilterByPipe(pSkillInst, vecEntityID, m_vecFilterPipe, filterLimit, pFrom, pTo);

	VecEntityID::iterator it_obj = vecEntityID.begin();
	for(; it_obj != vecEntityID.end(); ++it_obj)
	{
		CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter(*it_obj);
		if (NULL==pCharacter)
		{
			continue;
		}
		CFighterDictator* pTo=pCharacter->GetFighter();
		if (pMagicCond->GetMagicCondType() == eMCT_Value)
		{
			CValueMagicCondServer* pMagicCond = class_cast<CValueMagicCondServer*>(m_pMagicOp);
			eResult = EDoSkillResult(pMagicCond->Test(pSkillInst, m_MagicOpArg, pFrom, pTo));
		}
		else
		{
			CFunctionMagicCondServer* pMagicCond = class_cast<CFunctionMagicCondServer*>(m_pMagicOp);
			eResult = EDoSkillResult(pMagicCond->Test(pSkillInst, m_MagicOpArg, pFrom, pTo));
		}

		//if (eResult != eDSR_Success)
			//return eResult;
		if(eResult == eDSR_Success)
		{
			break;
		}
	}

	ListChild::iterator it_list = m_listChild.begin();
	for(; it_list != m_listChild.end(); ++it_list)
	{
		EDoSkillResult eChildResult = class_cast<CMagicOpTreeServer*>(*it_list)->DoMagicCond(pSkillInst, pFrom, pTo,vecEntityID);
		if (eChildResult!= eDSR_Success)
			return eChildResult;
	}

	return eResult;
}


void CMagicOpTreeServer::CancelTempMOP(CSkillInstServer* pSkillInst, CFighterDictator* pFrom, CGenericTarget* pTo,VecResult& vecResult, CMagicEffDataMgrServer* pCancelDataMgr)
{
	//pCancelDataMgr�����������������ʱ����
	if (m_strMOPType=="��ʱ"&&m_pMagicOp->GetType()==eMOPCT_MagicOP)
	{
		if(CanDo(vecResult))
		{
			CMagicOpServer * pMagicOp = class_cast<CMagicOpServer*>(m_pMagicOp);	
			CEntityServer* pEntity = CEntityServerManager::GetEntityByID(pSkillInst->GetCreatorID());
			CFighterDictator* pFighterCreator = pEntity?pEntity->GetFighter():NULL;
			CFighterDictator*	pTarget=0;
			vector<MagicEffFilter*>::iterator it = m_vecFilterPipe.begin();
			if ((*it)->m_eObjectFilter==eOF_Target && pTo->GetType()==eTT_Fighter)
			{
				pTarget=pTo->GetFighter();
			}
			else
			{
				pTarget=pFrom;
			}
			
			if(pTarget != NULL&&pMagicOp->Cancelable())
			{
				if ((int32)pMagicOp->GetMagicOpType()==(int32)eMCT_Function)
				{
					CFunctionCancelableMagicOp * pMagicOp = class_cast<CFunctionCancelableMagicOp*>(m_pMagicOp);
					pMagicOp->Cancel(pSkillInst, m_MagicOpArg, pFighterCreator, pTarget);
				} 
				else
				{
					CValueCancelableMagicOp* pMagicOp = class_cast<CValueCancelableMagicOp*>(m_pMagicOp);
					pMagicOp->CancelExec(pSkillInst, pFighterCreator, pTarget,
						CValueData(vecResult[m_uIndex-1]->iMagicOpValue));
				}	
			}
		}
	}
	ListChild::iterator it_list = m_listChild.begin();
	for(; it_list != m_listChild.end(); ++it_list)
	{
		class_cast<CMagicOpTreeServer*>(*it_list)->CancelTempMOP(pSkillInst,pFrom,pTo,vecResult, pCancelDataMgr);
	}
}

void CMagicOpTreeServer::Cancel(CSkillInstServer* pSkillInst, CFighterDictator* pOwner, CMagicEffDataMgrServer* pCancelDataMgr)
{
	if(pOwner && (pOwner->CppIsAlive() || pSkillInst->GetTargetAliveCheckIsIgnored() || m_pMagicOp->CanExecuteWithTargetIsDead()))
	{
		CGenericTarget Target(pOwner);
		VecEntityID& vecEntityID = CMagicOpTreeServer::GetEntityIdVec();
		FilterLimit filterLimit;
		MakeFilterLimit(filterLimit, pSkillInst, this, pOwner);
		CFilterOpServer::FilterByPipe(pSkillInst, vecEntityID, m_vecFilterPipe, filterLimit, pOwner, &Target);

		if (vecEntityID.empty())
		{
			CMagicOpTreeServer::ReleaseEntityIdVec(vecEntityID);
			return;
		}
		VecEntityID::iterator it_obj = vecEntityID.begin();
		CCharacterDictator* pCharacter = CEntityServerManager::GetInst()->GetCharacter(*it_obj);
		if (NULL==pCharacter)
		{
			CMagicOpTreeServer::ReleaseEntityIdVec(vecEntityID);
			return;
		}
		CFighterDictator* pTo=pCharacter->GetFighter();
		if (m_pMagicOp->GetType()==eMOPCT_MagicOP)
		{
			CMagicOpServer * pMagicOp = class_cast<CMagicOpServer*>(m_pMagicOp);
			if (pMagicOp->Cancelable())
			{
				//CEntityServer* pEntity = CEntityServerManager::GetEntityByID(pSkillInst->GetCreatorID());
				//CFighterDictator* pFighterCreator = pEntity?pEntity->GetFighter():NULL;
				CancelMagicOp(m_pMagicOp, pSkillInst, m_MagicOpArg, pTo, pCancelDataMgr);
			}
		}
		CMagicOpTreeServer::ReleaseEntityIdVec(vecEntityID);
		ListChild::iterator it_list = m_listChild.begin();
		for(; it_list != m_listChild.end(); ++it_list)
		{
			//uint32 uID = pSkillInst->GetID();
			class_cast<CMagicOpTreeServer*>(*it_list)->Cancel(pSkillInst,pOwner, pCancelDataMgr);
			//if(!CSkillInstServer::ExistSkillInst(uID))
			//	return;
		}
	}
}

//ħ��������Ԥ��
void CMagicOpTreeServer::PreDoMagicCond(CSkillInstServer* pSkillInst)
{
	//if(pSkillInst->GetType() == eIT_MagicStateInst)
	//{
	//	GenErr("ħ��״̬���õ�ħ��Ч�����ܺ���ħ������\n");
	//}
	
	//״̬Ч�����ܺ���ħ�����������ƽ����������ֻ���������Ľ��Ϊ��װ������״̬����װ�˺����״̬
	//�Ժ���Ҫ��StateInst����ħ��������ִ�����̣����ڳ���ʱ��������̳�����ħ������
}

//ħ�����������Ԥ��
bool CMagicOpTreeServer::PreDoMagicOp(CSkillInstServer* pSkillInst)
{
	if(pSkillInst->GetType() == eIT_MagicStateInst)
	{
		stringstream str;
		str << "ħ��״̬���ܵ�����ʱħ������\n";
		GenErr(str.str());
		//return false;
	}
	return true;
}


void CMagicEffServer::CreateStoredObjArray(CSkillInstServer* pSkillInst, CMagicEffDataMgrServer* pCancelDataMgr)
{
	if(pSkillInst->GetType() == eIT_MagicStateInst)
	{
		if(pSkillInst->GetIsCalc())
		{
			Ast(pCancelDataMgr);
			pCancelDataMgr->CreateArrayMopData(m_uCount);
		}
	}
	else if(pCancelDataMgr)
	{
		pCancelDataMgr->CreateArrayMopData(m_uCount);
	}
}

//������ħ����������
uint32 CMagicOpTreeServer::DoMagicOp(CFunctionMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, CFighterDictator* pTo)
{
	if(pFrom == NULL || pFrom->CppIsAlive() || m_pMagicOp->CanExecuteWithAttackerIsDead())
	{
		if(pSkillInst->GetType() == eIT_MagicStateInst)
		{
			if(pSkillInst->GetIsCalc())
			{
				return eHR_Fail;
			}
			//pSkillInst->ChangeToSkillInst();
			uint32 uRet = pMagicOp->Do(pSkillInst, Arg, pFrom, pTo);
			//pSkillInst->RevertInstType();
			return uRet; 
		}
		else
		{
			return pMagicOp->Do(pSkillInst, Arg, pFrom, pTo);
		}
	}
	else
	{
		return eHR_Fail;
	}
}

//�ı���ħ����������
uint32 CMagicOpTreeServer::DoMagicOp(CValueMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst,
	const CCfgArg* Arg, CFighterDictator* pFrom, CFighterDictator* pTo, int32* iMopCalcValue,
	size_t iTargetIndex, CMagicEffDataMgrServer* pCancelDataMgr)
{
	CValueData TempValue;
	if(pFrom == NULL || pFrom->CppIsAlive() || m_pMagicOp->CanExecuteWithAttackerIsDead())
	{
		EInstType eInstType = pSkillInst->GetType();

		if(eInstType == eIT_MagicStateInst)				//��ħ��״̬���ö���
		{
			if(pSkillInst->GetIsCalc())									//��ħ��״̬�ļ������
			{
				if(pMagicOp->GetMagicOpType() == eMOT_Value)						//ħ�������Ǹı���
				{
					if(iTargetIndex == 0)										//�µ�ħ�������У���Ŀ��Ϊ��һ���ˣ�
					{
						uint32 uMOPRetValue = 0;

						uint32 iExtraValue = 0;	// ���ֵ����ħ��������ʱֻ��Ϊ�˱��⴫��ָ�룬��û��������;
						uMOPRetValue = pMagicOp->MagicOpCalc(pSkillInst, Arg, pFrom, pTo, &TempValue, &iExtraValue);
						if (iMopCalcValue)
						{
							*iMopCalcValue=TempValue.GetInt32();
						}		
						Ast(pCancelDataMgr && "״̬���øı�ֵDoMagicOp���㲿�ֵ�pCancelDataMgr����Ϊ��");
						pCancelDataMgr->SetArrayMopDataForMagicState(m_uIndex, CMagicOpStoredObj(TempValue, uMOPRetValue));//�����ƺ��е����⣬����һ���ֲ���CMagicOpStoredObj���� 
						return uMOPRetValue;
					}
				}
				else	//���������֧�����Ѿ���ħ��Ч�����ñ��������жϣ������Ժ�ͳһħ��Ч�����ñ����������жϷ�֧����������ͱ���������
				{
					//ħ��״̬�ļ��㲿�ֵ��øı������⣨Ŀǰ�������ͺ͵ص��ͣ���ħ��������ֱ�ӷ���
					return eHR_Fail;
				}
			}
			else														//��ħ��״̬��ִ�е���
			{
				CSkillLocalInstServer* pLocalInst = pSkillInst->GetLocalInst();
				if(pLocalInst && pLocalInst->GetContainerExist())
				{
					if(pMagicOp->GetMagicOpType() == eMOT_Value)
					{
						//CMagicEffDataMgrServer* pDataMgr = pStateInst->GetCurEffDataMgr();

						Ast(pCancelDataMgr && "״̬���øı�ֵDoMagicOp���㲿�ֵ�pCancelDataMgr����Ϊ��");
						const CMagicOpStoredObj& StoredObj = pCancelDataMgr->GetArrayMopDataForMagicState(m_uIndex, pSkillInst);
						if(!StoredObj.m_bValid)
						{
							stringstream str;
							str << "[" << class_cast<CSkillMagicStateInstServer*>(pSkillInst->GetLocalInst())->GetCfg()->GetName() << "]��[" <<
								GetLineNo() << "]��[" << m_strMagicOpName << "]\n";
							GenErr("״̬�ı�ֵ��ħ������δ��������", str.str());
						}
						//pSkillInst->ChangeToSkillInst();
						pMagicOp->MagicOpExec(pSkillInst, pFrom, pTo, StoredObj.m_MOPArg, (EHurtResult)StoredObj.m_uMOPRet);
						*iMopCalcValue = StoredObj.m_MOPArg.GetInt32();
						//pSkillInst->RevertInstType();
						//ע������ķ���ֵԼ��ΪMagicOpExec����Ҫ�ĵڶ�����ֵ������������Ҫ��StoredObj�ﱣ���������ֵ
						return (uint32)StoredObj.m_uMOPRet;//��ʱħ��״̬�п����ѱ�ɾ����������Inst�п��ܻ�δ��ɾ��������StoredObj�п��ܻ�����
					}
					else	//���������֧�����Ѿ���ħ��Ч�����ñ��������жϣ������Ժ�ͳһħ��Ч�����ñ����������жϷ�֧����������ͱ���������
					{
						uint32 uRet;
						//ħ��״̬��ִ�в��ֵ��øı������⣨Ŀǰ�������ͺ͵ص��ͣ���ħ���������뼼��ֱ�ӵ��ø�ħ�������Ĺ���һ��
						//pSkillInst->ChangeToSkillInst();
						uRet = pMagicOp->Do(pSkillInst, Arg, pFrom, pTo, iMopCalcValue);
						//pSkillInst->RevertInstType();
						return uRet;
					}
				}
			}
		}
		else if(eInstType != eIT_None)				//�ɼ���ֱ�ӵ��ö���
		{
			if(pCancelDataMgr)		//����ǵ��ÿɳ���Ч����״̬���⣩
			{
				uint32 uMOPRetValue = 0;

				uint32 iExtraValue = 0;	// ���ֵ����ħ��������ʱֻ��Ϊ�˱��⴫��ָ�룬��û��������;
				uMOPRetValue = pMagicOp->MagicOpCalc(pSkillInst, Arg, pFrom, pTo, &TempValue, &iExtraValue);
				if (iMopCalcValue)
				{
					*iMopCalcValue=TempValue.GetInt32();
				}		
				pCancelDataMgr->SetArrayMopDataForOther(m_uIndex, CMagicOpStoredObj(TempValue, uMOPRetValue));
				
				const CMagicOpStoredObj& StoredObj = pCancelDataMgr->GetArrayMopDataForOther(m_uIndex, pSkillInst);
				pMagicOp->MagicOpExec(pSkillInst, pFrom, pTo, StoredObj.m_MOPArg, (EHurtResult)StoredObj.m_uMOPRet);
				//*iMopCalcValue = StoredObj.m_MOPArg.GetInt32();
			}
			else
			{
				return pMagicOp->Do(pSkillInst, Arg, pFrom, pTo,iMopCalcValue);
			}
		}
	}
	return eHR_Fail;
}

//�ص���ħ����������
uint32 CMagicOpTreeServer::DoMagicOp(CPosMagicOpServer* pMagicOp, CSkillInstServer* pSkillInst, const CCfgArg* Arg, CFighterDictator* pFrom, const CFPos& pTo)
{
	if(pFrom)
	{
		CCoreSceneServer* pScene = pFrom->GetScene();
		if(!pScene->IsPixelValid(pTo))
			return eHR_Fail;
	}

	if(pFrom == NULL || pFrom->CppIsAlive() || m_pMagicOp->CanExecuteWithAttackerIsDead())
	{
		//if(pSkillInst->GetType() == eIT_MagicStateInst)
		//{
		//	GenErr("ħ��״̬���ܵ���Ŀ��Ϊ�ص��ħ������\n");
		//	return eHR_Fail;
		//}
		//else
		if(pSkillInst->GetType() == eIT_MagicStateInst)
		{
			if(pSkillInst->GetIsCalc())
			{
				return eHR_Fail;
			}
			//pSkillInst->ChangeToSkillInst();
			uint32 uRet = pMagicOp->Do(pSkillInst, Arg, pFrom, pTo);
			//pSkillInst->RevertInstType();
			return uRet;
		}
		else
		{
			return pMagicOp->Do(pSkillInst, Arg, pFrom, pTo);
		}
	}
	else
	{
		return eHR_Fail;
	}
}

//�ɳ���ħ��Ч���ĳ���
void CMagicOpTreeServer::CancelMagicOp(CBaseMagicOpServer* pBaseMagicOp,
	CSkillInstServer* pSkillInst, const CCfgArg* Arg,
	CFighterDictator* pTo, CMagicEffDataMgrServer* pCancelDataMgr)
{
	CMagicOpServer* pMagicOp = class_cast<CMagicOpServer*>(pBaseMagicOp);
	if (m_strMOPType=="��ʱ")
	{
		//��ʱ����ֻ����CancelTempMOP()�������������ظ�����
		return;
	}

	//CEntityServer* pEntity = CEntityServerManager::GetEntityByID(pSkillInst->GetCreatorID());
	//CFighterDictator* pFrom = pEntity?pEntity->GetFighter():NULL;

	CFighterDictator* pFrom = NULL;
	if(pCancelDataMgr)
	{
		CEntityServer* pEntityFrom = CEntityServerManager::GetEntityByID(pCancelDataMgr->GetFromID());
		if(pEntityFrom)
			pFrom = pEntityFrom->GetFighter();
	}
	switch(pMagicOp->GetMagicOpType())
	{
	case eMOT_Function:
		{
			CFunctionCancelableMagicOp* pFCMagicOp = class_cast<CFunctionCancelableMagicOp*>(pMagicOp);
			if(pSkillInst->GetType() == eIT_MagicStateInst)				//��ħ��״̬���ö���
			{
				//pSkillInst->ChangeToSkillInst();
				pFCMagicOp->Cancel(pSkillInst, Arg, pFrom, pTo);
				//pSkillInst->RevertInstType();
			}
			else
			{
				pFCMagicOp->Cancel(pSkillInst, Arg, pFrom, pTo);
			}
		}
		return;
	case eMOT_Value:
		{
			if(pSkillInst->GetType() == eIT_MagicStateInst)				//��ħ��״̬���ö���
			{
				//CMagicStateCascadeDataMgr *pStateInst = class_cast<CMagicStateCascadeDataMgr*>(pSkillInst);

				//CMagicEffDataMgrServer* pDataMgr = pStateInst->GetCurEffDataMgr();

				Ast(pCancelDataMgr && "״̬���øı�ֵCancelMagicOp��pCancelDataMgr����Ϊ��");
				const CMagicOpStoredObj& StoredObj = pCancelDataMgr->GetArrayMopData(m_uIndex);
				//�����쳣�׵�û�����壻��Ϊ����������ķ�֧ħ����������ֵĬ����0������ʱ��ȫ��ִ�е�
				//if(!StoredObj.m_bValid)
				//{
				//	stringstream str;
				//	str << "״̬[" << pStateInst->GetCfg()->GetName() << "]�����ĵ�[" <<
				//		GetLineNo() << "]�иı�ֵ��ħ������[" << m_strMagicOpName << "]δ��������\n";
				//	GenErr(str.str());
				//}

				CValueCancelableMagicOp* pVCMagicOp = class_cast<CValueCancelableMagicOp*>(pMagicOp);
				pVCMagicOp->CancelExec(pSkillInst, pFrom, pTo, StoredObj.m_MOPArg);
			}
			else //�ɼ���ֱ�ӵ��ö���
			{
				if(pCancelDataMgr)
				{
					const CMagicOpStoredObj& StoredObj = pCancelDataMgr->GetArrayMopData(m_uIndex);

					CValueCancelableMagicOp* pVCMagicOp = class_cast<CValueCancelableMagicOp*>(pMagicOp);
					pVCMagicOp->CancelExec(pSkillInst, pFrom, pTo, StoredObj.m_MOPArg);
				}
				else
				{
					CValueCancelableMagicOp* pVCMagicOp = class_cast<CValueCancelableMagicOp*>(pMagicOp);
					pVCMagicOp->Cancel(pSkillInst, Arg, pFrom, pTo);
				}
			}
		}
		return;
	default:
		{
			GenErr("�����ͺ͸ı��������ħ���������ܵ���Cancel����\n");
			return;
		}
	}
}


uint32 CMagicOpTreeServer::GetMagicOpExecNum()
{
	return ms_uExecNum;
}

void CMagicOpTreeServer::MakeFilterLimit(FilterLimit& filterLimit, CSkillInstServer* pInst, CMagicOpTreeServer* pMagicOpTree, CFighterDictator* pFrom)
{
	filterLimit.bIsValueMagicOp=false;
	if(pMagicOpTree->m_pMagicOp->GetType()==eMOPCT_MagicOP)
	{
		CMagicOpServer * pMagicOp = class_cast<CMagicOpServer*>(pMagicOpTree->m_pMagicOp);
		if((int32)pMagicOp->GetMagicOpType()==(int32)eMCT_Value)
		{
			filterLimit.bIsValueMagicOp=true;
		}
	}
	filterLimit.bTargetAliveCheckIsIgnored=pInst->GetTargetAliveCheckIsIgnored() || pMagicOpTree->m_pMagicOp->CanExecuteWithTargetIsDead();
}

bool CMagicOpTreeServer::StateMopNeedForceCalc(CSkillInstServer* pSkillInst)
{
	//ħ��״̬�ļ��������Ч���ĸı�ֵħ�������Լ�֮ǰ��Ŀ��ɸѡ���������ڼ����ʱ��ִ��һ�μ���
	if(pSkillInst->GetType() == eIT_MagicStateInst)
	{
		CSkillMagicStateInstServer* pStateInst = class_cast<CSkillMagicStateInstServer*>(pSkillInst->GetLocalInst());
		if(pStateInst->GetIsCalc() && pStateInst->GetMagicStateEffType() != eMSET_Cancellable)
		{
			switch(m_pMagicOp->GetType())
			{
			case eMOPCT_MagicOP:
				{
					CMagicOpServer* pMagicOp = class_cast<CMagicOpServer*>(m_pMagicOp);
					if(pMagicOp->GetMagicOpType() == eMOT_Value)
					{
						return true;
					}
				}
			default:
				break;
			}
		}
	}
	return false;
}

