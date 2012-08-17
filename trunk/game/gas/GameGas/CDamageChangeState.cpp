#include "stdafx.h"
#include "CAllStateMgr.h"
#include "CMagicEffServer.h"
#include "CGenericTarget.h"
#include "CQuickRand.h"
#include "CFighterDictator.h"
#include "CTempVarServer.h"
#include "CSkillInstServer.h"
#include "CCfgCalc.inl"
#include "CStateCondFunctor.h"
#include "CDamageChangeState.h"
#include "CDamageChangeStateCfg.h"
#include "CDamageChangeStateMgr.h"
#include "ErrLogHelper.h"
#include "BaseHelper.h"
#include "CConnServer.h"
#include "DebugHelper.h"
#include "CMagicEffDataMgrServer.h"

using namespace std;

//inline int32 sgn(int32 value)
//{
//	if(value > 0)
//		return 1;
//	else if(value < 0)
//		return -1;
//	else
//		return 0;
//}









//������CDamageChangeStateServer�Ĳ���
CDamageChangeStateServer::CDamageChangeStateServer(CSkillInstServer *pSkillInst, CFighterDictator* pInstaller,
	TTriggerableStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>* pMgr,
	const CDamageChangeStateCfgServerSharedPtr& pCfg, uint32 uAccumulate, int32 iTime, int32 iRemainTime, 
	float fProbability)
: CTriggerableStateServer(pSkillInst, pInstaller, 0, iTime, iRemainTime, fProbability)
, m_pMgr(class_cast<CDamageChangeStateMgrServer*>(pMgr))
, m_pStateEventBundle(NULL)
, m_pCfg(new CDamageChangeStateCfgServerSharedPtr(pCfg))
{
	if(!GetCfgSharedPtr()->GetModelStr().empty()) GetAllMgr()->SetModelStateId(GetCfgSharedPtr()->GetId());
}


CDamageChangeStateServer::~CDamageChangeStateServer()
{
	//�Ƿ��ǰ�ClearSource()�ĵ������ȫ���������
	GetOwner()->UnRegistDistortedTick(this);

#ifdef COUT_STATE_INFO
	cout << "ɾ��DamageChangeState " << GetCfgSharedPtr()->GetName() << endl;
#endif

	if(!GetCfgSharedPtr()->GetModelStr().empty()) GetAllMgr()->ClearModelStateId();
	SafeDelete(m_pCfg);
}





pair<bool, bool> CDamageChangeStateServer::MessageEvent(uint32 uEventID, CGenericTarget * pTrigger)
{
	if(m_bEndByTime || m_bEndByCount) return make_pair(false, false);

	//cout << "�˺����״̬�����¼���" << uEventID << "\n";
	//�˺����յĴ����¼�ֻ��Ϊ���˺���14��
	//�������յĴ����¼�ֻ��Ϊ��������������������
	CDamageChangeStateCfgServerSharedPtr& pCfg = GetCfgSharedPtr(); 

	SQR_TRY
	{
		if (int32(m_uAccumulate) < m_iInitialValue || m_iInitialValue < 0)
		{
			//�����������ڴ���ʱȡֵ����ǰ�ǰ�װ״̬ʱȡֵ
			m_fProbability = float(GetCfgSharedPtr()->GetProbability()->GetDblValue(GetInstaller(), GetOwner(), m_pSkillInst->GetLevelIndex()));

			if (CQuickRand::Rand1(0.0f, 1.0f) < m_fProbability)
			{
				//AddValue(pSkillInst->GetDamaSetSetupge());

				//uint32 beDamaged = GetOwner()->GetTempVarMgr()->GetBeDamaged();
				int32 OldValue = GetOwner()->GetTempVarMgr()->GetVarValue(pCfg->GetTempVar());

				if(pTrigger->GetType() != eTT_Fighter)
				{
					stringstream str;
					str << "�����߲���һ���ˣ�������һ���ˣ�\n";
					GenErr(str.str());
					//return make_pair(false, false);
				}
				else if(pTrigger->GetFighter() && 
					pTrigger->GetFighter()->GetTempVarMgr()
					->GetVarValue(CTempVarMgrServer::GetPassVarName(pCfg->GetTempVar()))
					!= OldValue)
				{
					//����������쳣������Ҫ�����ϸ������ʱ�����������ڣ��������뼼�������߻��ݻ����Լ�����ʱ��������
					stringstream str;
					str << "��ʱ����[" << pCfg->GetTempVar() << "]����ֵ" << (pTrigger->GetFighter()->GetTempVarMgr()
						->GetVarValue(CTempVarMgrServer::GetPassVarName(pCfg->GetTempVar()))
						) << "�뱻��ֵ" << OldValue << "��ֵ��һ��\n";
					GenErr("��ʱ��������ֵ�뱻��ֵ��ֵ��һ��", str.str());
					//return make_pair(false, false);
				}

				int32 NewValue = pCfg->GetTempValue()->GetIntValue(GetInstaller(), GetOwner(), m_pSkillInst->GetLevelIndex());
				uint32 AbsValueChanged = abs(OldValue);// abs(NewValue - OldValue);

				AddValue(AbsValueChanged);

				//ע����������ڳ�����ʼֵ��ֻ��ʹ��һ��
				//pSkillInst->SetDamage(((int32)m_uAccumulate > m_iInitialValue && m_iInitialValue >= 0) ? m_uAccumulate - m_iInitialValue : 0);
				//int32 ProcessedNewValue = ((int32)m_uAccumulate > m_iInitialValue && m_iInitialValue >= 0) ? NewValue + sgn(OldValue/* - NewValue*/) * (m_uAccumulate - m_iInitialValue) : NewValue;
				int32 ProcessedNewValue;
				if((int32)m_uAccumulate > m_iInitialValue && m_iInitialValue >= 0)
				{
					if(AbsValueChanged == 0)
					{
						//��Ϊm_iInitialValue��ֵ�ڱ��������Ϲ����в��ᷢ���ı䣬
						//������if (int32(m_uAccumulate) < m_iInitialValue || m_iInitialValue < 0)
						//������if ((int32)m_uAccumulate > m_iInitialValue && m_iInitialValue >= 0)
						//��ʾm_uAccumulate��ֵ������if�ж�֮�䷢���˸ı䣬��Ψһ����m_uAccumulate�ı��AbsValueChanged������Ϊ0
						GenErr("��ϲ���ɹ���Խ����10��Ԫ���11��Ԫ����ļ�϶\n");
						return make_pair(false, false);
					}
					ProcessedNewValue = NewValue + int32(int64(OldValue - NewValue) * int64(m_uAccumulate - m_iInitialValue) / int64(AbsValueChanged));
				}
				else
				{
					ProcessedNewValue = NewValue;
				}
				//if(pCfg->GetApplyTempValue())
				//{
				GetOwner()->GetTempVarMgr()->SetVarValue(pCfg->GetTempVar(), ProcessedNewValue);
				if (pCfg->GetTempVar() == "���˺�")
				{
					if (GetOwner()->GetTempVarMgr()->GetDamageChangeStateName() == "")
					{
						GetOwner()->GetTempVarMgr()->SetDamageChangeStateName(pCfg->GetName());
					}
					else
					{
						GetOwner()->GetTempVarMgr()->SetDamageChangeStateName("*$");
					}
				}
				
				if(pTrigger->GetFighter()) 
					pTrigger->GetFighter()->GetTempVarMgr()
					->SetVarValue(CTempVarMgrServer::GetPassVarName(pCfg->GetTempVar()), ProcessedNewValue);
				//}

#ifdef COUT_STATE_INFO
			cout << "[" << pCfg->GetName() << "]��[ " << pCfg->GetTempVar().c_str() << " ]��" << OldValue << "���Ϊ" << ProcessedNewValue << endl;
#endif

				//if (pSkillInst->GetDamage() > 0)
				if (m_iInitialValue >= 0 && (int32)m_uAccumulate >= m_iInitialValue)
				{
#ifdef COUT_STATE_INFO
				cout << "���˺�������ֵ���˶�׼��ɾ���Լ�\n";
#endif

					//����� DoFinalMagicEff() == true ʱ��ʾ����Ч����Ŀ��ɱ���ˣ��򣨷����ã�״̬Ҳ��ʧ��
					//ע�⣺����״̬����m_pCfg->GetPersistent() == true����Ϊ�������Ϊ���޶����������ܽ�����������˲���Ҫ���ж�
					if (GetCfgSharedPtr()->GetCancelableMagicEff())
						Ast(!GetCfgSharedPtr()->GetPersistent());
					//if(!DoFinalMagicEff())
					//{
					//	//������дһ���Ǳ���DoFinalMagicEff���GetTempVarMgr()->SetVarValue���ǵ��˺���ʱ������ֵ
					//	//������������Ч���ĳ��첽������δ��������Ҫ���¿��Ƿ���!bRet���ж�֮��
					//	GetOwner()->GetTempVarMgr()->SetVarValue(pCfg->GetTempVar(), ProcessedNewValue);
					//	if(pTrigger->GetFighter()) 
					//		pTrigger->GetFighter()->GetTempVarMgr()
					//		->SetVarValue(CTempVarMgrServer::GetPassVarName(pCfg->GetTempVar()), ProcessedNewValue);

					//	//����ĳ�Ϊʵ����󴥷��Ĵ��������˺�Ч����ʹ�õ��첽����
					//	//DeleteSelf();
					//	//return make_pair(true, true);
					m_bEndByCount = true;
					GetOwner()->UnRegistDistortedTick(this);
					GetOwner()->RegistDistortedTick(this, 0);
					return make_pair(false, true);
					//}
				}
				else
				{
					return make_pair(false, true);
				}
			}
		}
	}
	SQR_CATCH(exp)
	{
		stringstream sErr;
		sErr << "�����˺����״̬[" << pCfg->GetName() << "]MessageEvent(" << uEventID << ")��"
			<< "���ڼ���[" << m_pSkillInst->GetSkillName() << "]��";
		exp.AppendMsg(sErr.str().c_str());
		//CConnServer* pConnServer = GetOwner()->GetConnection();
		//if (pConnServer)
		//	LogExp(exp, pConnServer);
		//else
		//	LogExp(exp);
		SQR_THROW(exp);
	}
	SQR_TRY_END;

	return make_pair(false, false);
}

void CDamageChangeStateServer::DeleteSelf()
{
	PrepareDeleteSelf();
	DeleteItr();
	//����Ϊɾ������Ĳ�����ע�������������ĩβ
	delete this;
}

void CDamageChangeStateServer::DeleteSelfExceptItr()
{
	PrepareDeleteSelf();
	//����Ϊɾ������Ĳ�����ע�������������ĩβ
	delete this;
}


void CDamageChangeStateServer::PrepareDeleteSelf()
{
	//GetOwner()->UnRegistDistortedTick(this);

	switch(GetCfgSharedPtr()->GetTriggerEvent())
	{
	case eSET_InstallerDie:
		{
			CFighterDictator* pFighter = GetInstaller();
			if(pFighter)
			{
				//��ΪitrPTS->second��Ҫɾ���ģ����Բ���Ҫ��ִ��һ��Detach�����򷴶����ܻ���Ϊm_pInstaller����������
				pFighter->Detach(this, eCE_Die);
			}
		}
		break;
	case eSET_KillByInstaller:
		if(m_pMgr && m_pMgr->m_pOwner)
		{
			m_pMgr->m_pOwner->Detach(this, eCE_Die);
		}
		break;
	default:
		//�Զ���۲���ģʽDetach
		if (m_listStateItr != m_pStateEventBundle->m_listState.end())
			m_pStateEventBundle->m_listState.erase(m_listStateItr);
	}

	//����ȡ��ħ��״̬�����ģ�ͺ���Ч�ص�
	uint32 uId = GetCfgSharedPtr()->GetId();
	CAllStateMgrServer* pAllMgr = GetAllMgr();
	pAllMgr->OnDeleteState(uId, m_uDynamicId);
	pAllMgr->DelStateByDId(m_uDynamicId);


	//ΪClearAll����;ExistState�Ⱥ���׼���ģ�ExistState�Ⱥ���Ҫ���itr->second != NULL��
	if (m_mapStateItr != m_pMgr->m_mapState.end()) m_mapStateItr->second = NULL;

	pAllMgr->PrintFightInfo(false, GetInstallerID(), GetCfgSharedPtr().get());

	SetInstaller(NULL);
}

void CDamageChangeStateServer::DeleteItr()
{
	if (m_mapStateItr != m_pMgr->m_mapState.end()) m_pMgr->m_mapState.erase(m_mapStateItr);
}




bool CDamageChangeStateServer::DoCancelableMagicEff(bool bFromDB)
{
	CDamageChangeStateMgrServer* pTempMgr = m_pMgr;
	CDamageChangeStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();
	const CMagicEffServerSharedPtr& pMagicEff = pCfg->GetCancelableMagicEff();
	if (pMagicEff)
	{
#ifdef COUT_STATE_INFO
		cout << "ִ�пɳ���ħ��Ч��һ�Σ�" << pMagicEff->GetName() << endl;
#endif

		if(bFromDB) m_pSkillInst->SetForbitSetupSavedState(true);
		m_pSkillInst->SetStateId(GetCfgSharedPtr()->GetId());
		m_pCancelEffData = new CMagicEffDataMgrServer(GetInstaller());
		pMagicEff->Do(m_pSkillInst, GetInstaller(), GetOwner(), m_pCancelEffData);
		//������������ϵ�Do���ܵ�����������ʱҪȡ���쳣��Ϊ��㺯������
		if(!pTempMgr->ExistState(pCfg->GetName())) 
		{
			//stringstream str;
			//str << "�˺����״̬ " << pCfg->GetName() << " ��ӵ������ִ�пɳ���ħ��Ч�� " << pMagicEff->GetName() << " ������";
			//GenErr("�˺����״̬��ӵ������ִ�пɳ���ħ��Ч��������", str.str());
			return true;
		}
		if(bFromDB) m_pSkillInst->SetForbitSetupSavedState(false);
		m_pSkillInst->SetStateId(0);
	}
	return false;
}

void CDamageChangeStateServer::CancelCancelableMagicEff()
{
	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	CDamageChangeStateMgrServer* pTempMgr = m_pMgr;
	CDamageChangeStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();

	const CMagicEffServerSharedPtr& pMagicEff = pCfg->GetCancelableMagicEff();
	if (pMagicEff)				//�ɳ���ħ��Ч��
	{
#ifdef COUT_STATE_INFO
		cout << "ȡ���ɳ���ħ��Ч��һ�Σ�" << pMagicEff->GetName() << endl;
#endif

		m_pSkillInst->SetStateId(GetCfgSharedPtr()->GetId());
		pMagicEff->Cancel(m_pSkillInst, GetOwner(), m_pCancelEffData);
		//������������ϵ�Do���ܵ�����������ʱҪȡ���쳣��Ϊ��㺯������
		if(!pTempMgr->ExistState(pCfg->GetName())) 
		{
			stringstream str;
			str << "�˺����״̬ " << pCfg->GetName() << " ��ӵ�����ڳ����ɳ���ħ��Ч�� " << pMagicEff->GetName() << " ������";
			GenErr("�˺����״̬��ӵ�����ڳ����ɳ���ħ��Ч��������", str.str());
		}
		m_pSkillInst->SetStateId(0);
	}
}

bool CDamageChangeStateServer::DoFinalMagicEff()
{
	CDamageChangeStateMgrServer* pTempMgr = m_pMgr;
	CDamageChangeStateCfgServerSharedPtr pCfg = GetCfgSharedPtr();
	const CMagicEffServerSharedPtr& pMagicEff = pCfg->GetFinalMagicEff();
	if (pMagicEff)
	{
#ifdef COUT_STATE_INFO
		cout << "ִ������ħ��Ч��һ�Σ�" << pMagicEff->GetName() << endl;
#endif

		pMagicEff->Do(m_pSkillInst, GetInstaller(), GetOwner());
		//������������ϵ�Do���ܵ�����������ʱҪȡ���쳣��Ϊ��㺯������
		if(!pTempMgr->ExistState(pCfg->GetName())) 
		{
			return true;
		}
	}
	return false;
}



CFighterDictator* CDamageChangeStateServer::GetOwner()
{
	return m_pMgr->m_pOwner;
}

CAllStateMgrServer* CDamageChangeStateServer::GetAllMgr()
{
	return m_pMgr->GetAllMgr();
}

CBaseStateCfgServer* CDamageChangeStateServer::GetCfg()
{
	return GetCfgSharedPtr().get();
}

CDamageChangeStateCfgServerSharedPtr& CDamageChangeStateServer::GetCfgSharedPtr()const
{
	return *m_pCfg;
}
