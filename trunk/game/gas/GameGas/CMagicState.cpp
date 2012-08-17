#include "stdafx.h"
#include "CMagicState.h"
#include "CMagicStateCfg.h"
#include "CMagicEffServer.h"
#include "CFighterDictator.h"
#include "CCfgCalc.inl"
#include "CMagicStateInstServer.h"
#include "CMagicStateMgr.h"
#include "CAllStateMgr.h"
#include "ErrLogHelper.h"
#include "BaseHelper.h"
#include "CConnServer.h"
#include "FighterProperty.inl"
#include "DebugHelper.h"
#include "TSqrAllocator.inl"

//������CMagicStateServer����
pair<bool, bool> CMagicStateServer::Cascade(CSkillInstServer* pSkillInst, const uint32& grade, CFighterDictator* pInstaller)
{
	//�����滻���ǵ��ӣ���Ҫ����m_uShareCount
	//cout << "/Cascade(" << m_uShareCount << ")\n";
	if(m_pMSCategory->GetCfg()->m_eCascadeType == eCT_Share)
	{
		++m_uShareCount;
		//cout << "\\Cascade(" << m_uShareCount << ")\n";
	}

	if(m_pMSCategory->GetCfg()->GetCascadeGradation())			//����еȼ����ƣ�û�еȼ�������ֱ�ӽ�����ӣ�
	{
		if (grade > m_uGrade)				//�ߵȼ����滻
		{
			return Replace(pSkillInst,grade, pInstaller);
		}
		else if (grade < m_uGrade)			//�͵ȼ��򲻱�
		{
			return make_pair(false, false);
		}									//ͬ�ȼ������
	}

	bool tempReturnValue = false;			//Ĭ�ϲ�ˢ��ʩ����
	int32 tempTime = -2;						//Ĭ�ϲ��ı�ʱ��
	bool bCascadeFull;
	if (!CascadeFull())								//δ�����
	{
		bCascadeFull = false;
		++m_uCount;			//���Ӽ�������1�������ֵ������
#ifdef COUT_STATE_INFO
		cout << "���ӵ�" << m_uCount << "%u��\n";
#endif
		tempReturnValue = true;
		ChangeInstaller(pInstaller);
		//bool selfHasBeenDeleted = StartDo();
		//if(selfHasBeenDeleted) return make_pair(true, tempReturnValue);
	}
	else											//�������
	{
		bCascadeFull = true;
		if(m_iCascadeMax == 1)		//������ֻ��һ��
		{
			return Replace(pSkillInst,grade, pInstaller);
		}
		else if(m_iTime == -1)		//�������ж����ʱ��Ϊ������ʲô������
		{
			return make_pair(false, false);
		}
		else						//�������ж����ʱ�������򳷵�����ٰ�װһ��
		{
			//bool selfHasBeenDeleted = CancelDo(1);
			//if(selfHasBeenDeleted) return make_pair(true, true);

			//++m_uCount;			//���Ӽ�������1�������ֵ������
#ifdef COUT_STATE_INFO
			cout << "�滻���ϲ�\n";
#endif
			tempReturnValue = true;
			ChangeInstaller(pInstaller);
			//selfHasBeenDeleted = StartDo();
			//if(selfHasBeenDeleted) return make_pair(true, tempReturnValue);
			RefreshTime();
		}
	}
	switch (m_pMSCategory->GetCfg()->GetReplaceType())
	{
	case eRR_KeepCurState:					//�滻������0��ˢ��ʱ��
		//�����������滻����Ӧ�ò������
		if(m_uCount > 1)
		{
			GenErr("���Ӳ�������1��״̬�滻���������");
		}
		break;
	case eRR_Refresh:					//�滻������1��ˢ��ʱ�䣨Ҳˢ��ʩ���ߣ�
		if (!tempReturnValue)
		{
			tempReturnValue = true;
			ChangeInstaller(pInstaller);
		}
		RefreshTime();
		tempTime = m_iTime;
		break;
	default:
		GenErr("CMagicStateServer::Cascade�ڵĵ��ӹ���ö��ֵ����");
		//tempReturnValue = false;
	}
	if(tempReturnValue)
	{
		//����Ҫע��m_pSkillInst�Ƿ���Ҫ�滻�����Ǹ�״̬���ӵ�SkillInst�滻���������
		//���SkillInst�ϵ���Ϣ�Ե��Ӻ��״̬��Ӱ�죬����Ҫ���¿��ǵ��ӹ�������
		if(!bCascadeFull)
		{
			CalculateMagicOpArg(GetInstaller());
		}
		GetAllMgr()->OnSetState(m_pMSCategory->GetCfg()->GetId(), m_uDynamicId, m_uCount, m_iTime, tempTime, m_pSkillInst->GetSkillLevel(), GetInstallerID(),GetCalcValue());
		if(!bCascadeFull)
		{
			bool selfHasBeenDeleted = StartDo();
			if(selfHasBeenDeleted) return make_pair(true, tempReturnValue);
		}
	}
	return make_pair(false, tempReturnValue);
}

pair<bool, bool> CMagicStateServer::CancelCascade(uint32& count, bool bInCancel)
{
	if(m_pMSCategory->GetCfg()->m_eCascadeType == eCT_Share)
	{
		//cout << "/CancelCascade(" << m_uShareCount << ")\n";
		if(bInCancel)
		{
			if(m_uShareCount > m_uCount)
			{
				uint32 uOverCount= m_uShareCount - m_uCount;
				if(count <= uOverCount)
				{
					m_uShareCount -= count;
					count = 0;
					//cout << "\\1\\CancelCascade(" << m_uShareCount << ")\n";
					return make_pair(false,false);
				}
				else
				{
					if(count <= m_uShareCount)
					{
						m_uShareCount -= count;
					}
					else
					{
						m_uShareCount = 0;
					}
					count -= uOverCount;
				}
			}
			else
			{
				if(count <= m_uShareCount)
				{
					m_uShareCount -= count;
				}
				else
				{
					m_uShareCount = 0;
				}
			}
		}
		else
		{
			m_uShareCount -= min(count, m_uCount);
			if(m_uShareCount < 0)
				m_uShareCount = 0;
		}
	}

	//cout << "\\CancelCascade(" << m_uShareCount << ")\n";
	if(count >= m_uCount)
	{
		count -= m_uCount;
		bool selfHasBeenDeleted = CancelDo();
		if(selfHasBeenDeleted) return make_pair(true, true);				//��������Ϊ����CancelDo()���ܰ�m_pOwnerŪ������itrMt����
		if(DeleteSelf()) return make_pair(true, true);
		else return make_pair(false, true);
	}
	else
	{
		bool selfHasBeenDeleted = CancelDo(count);
		count = 0;
		if(selfHasBeenDeleted) return make_pair(true, true);				//��������Ϊ����CancelDo()���ܰ�m_pOwnerŪ������itrMt����
		return make_pair(false, false);
	}
}



pair<bool, bool> CMagicStateServer::Replace(CSkillInstServer* pSkillInst,const uint32& grade, CFighterDictator* pInstaller)			//��ν���滻��ʵҲ�����ж��Ƿ�ˢ��ʱ��
{
	switch (m_pMSCategory->GetCfg()->GetReplaceType())
	{
		case eRR_KeepCurState:			//�滻������0�򲻱䣨Ҳ��ˢ��ʩ���ߣ�
			return make_pair(false, false);
		case eRR_Refresh:			//�滻������1���ʼ��������ˢ��ʱ�䣨Ҳˢ��ʩ���ߣ�
			{
#ifdef COUT_STATE_INFO
				cout << "״̬�滻\n";
#endif
				bool selfHasBeenDeleted = CancelDo(true);
				if(selfHasBeenDeleted) return make_pair(true, true);
				DeleteInst();					//����m_pCancelableInst��m_pDotInst��m_pFinalInst

				m_uGrade = grade;				//����m_uGrade
				m_uCount = 1;					//����m_uCount
				m_bCancellationDone = false;	//����m_bCancellationDone
				CreateInst(pSkillInst);			//����m_pSkillInst
				ChangeInstaller(pInstaller);	//����m_pInstaller
				//selfHasBeenDeleted = StartDo();	//����m_iCascadeMax��m_pMSCategory��m_mtmapMSItr��m_uDynamicId����Ҫ����
				//if(selfHasBeenDeleted) return make_pair(true, true);
				RefreshTime();					//����m_iCascadeMax��m_uStartTime��m_iRemainTime��m_iTime��m_uTickCount��m_uTickStep
				CalculateMagicOpArg(GetInstaller());
				GetAllMgr()->OnSetState(m_pMSCategory->GetCfg()->GetId(), m_uDynamicId, m_uCount, m_iTime,
					m_iRemainTime, m_pSkillInst->GetSkillLevel(),GetInstallerID(),GetCalcValue());
				selfHasBeenDeleted = StartDo();	//����m_iCascadeMax��m_pMSCategory��m_mtmapMSItr��m_uDynamicId����Ҫ����
				if(selfHasBeenDeleted)
					return make_pair(true, true);
				else
					return make_pair(false, true);

			}
		default:
			{
				GenErr("CMagicStateServer::Replace�ڵ��滻����ö��ֵ����");
				return make_pair(true, false);
			}
	}
}




void CMagicStateServer::StartTime(bool bTimeSet)
{
	//cout << "[" << GetProcessTime() << "][" << m_pMSCategory->GetCfg()->GetName() << "]CMagicStateServer::StartTime()\n";
	if(!bTimeSet)
	{
		m_iTime = m_pMSCategory->GetCfg()->GetTime()->GetIntValue(GetInstaller(), GetOwner(), m_pSkillInst->GetLevelIndex());

		if (GetInstaller() != GetOwner() && (m_iTime != -1))
		{
			switch(m_pMSCategory->GetCfg()->GetDecreaseType())
			{
			case eDST_Control:
				m_iTime = uint32(m_iTime * GetOwner()->m_ControlDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			case eDST_Pause:
				m_iTime = uint32(m_iTime * GetOwner()->m_PauseDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			case eDST_Crippling:
				m_iTime = uint32(m_iTime * GetOwner()->m_CripplingDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			case eDST_Special:
				m_iTime = uint32(m_iTime * GetOwner()->m_SpecialDecreaseTimeRate.Get(GetOwner()) + 0.5f);
				break;
			default:
				break;
			}
		}
	}

	if(m_iTime < -1)
	{
		stringstream ExpStr;
		ExpStr << "ħ��״̬������ʱ�䲻��С��-1��" << m_iTime << endl;
		GenErr("ħ��״̬������ʱ�䲻��С��-1", ExpStr.str());
		return;
	}
	if(!bTimeSet)
	{
		m_iRemainTime = m_iTime;
	}
	m_iCascadeMax = m_pMSCategory->GetCfg()->GetCascadeMax()->GetIntValue(GetInstaller(), GetOwner(), m_pSkillInst->GetLevelIndex());
	if(m_iCascadeMax < -1)
	{
		stringstream ExpStr;
		ExpStr << "ħ��״̬�ĵ������޲���С��-1��" << m_iCascadeMax << endl;
		GenErr("ħ��״̬�ĵ������޲���С��-1", ExpStr.str());
		return;
	}

	m_uStartTime = GetOwner()->GetDistortedFrameTime();

	if(TickLengthStrategy())				//���ȼ�ʱ����
	{
		m_fTickCount = 0.0f;
		m_fTickStep = (float)m_iRemainTime;
		//if(bTimeSet)
		//{
		//	if(m_iTime >-1 && m_iRemainTime > -1)
		//	{
		//		m_fTickCount = float(m_iTime - m_iRemainTime);
		//		if(m_fTickCount < 0.0f)
		//			m_fTickCount = 0.0f;
		//		m_fTickStep = float(m_iTime);
		//	}
		//	else
		//	{
		//		m_fTickCount = 0.0f;
		//		m_fTickStep = 0.0f;
		//	}
		//}
		//else
		//{
		//	m_fTickCount = 0.0f;
		//	if(m_iTime >-1 && m_iRemainTime > -1)
		//	{
		//		m_fTickStep = float(m_iTime);
		//	}
		//	else
		//	{
		//		m_fTickStep = 0.0f;
		//	}
		//}
		if(m_iRemainTime < -1)
		{
			stringstream ExpStr;
			ExpStr << "����ʱ�䲻��С��-1��" << m_iRemainTime << "\n";
			GenErr("����ʱ�䲻��С��-1", ExpStr.str());
			return;
		}
		else
		{
			GetOwner()->RegistDistortedTick(this, int32(m_fTickStep * 1000));
		}
	}
	else									//�����ʱ����
	{
		//if(bTimeSet && m_iTime >-1 && m_iRemainTime >-1)
		//{
		//	m_fTickCount = float(m_iTime - m_iRemainTime);
		//	if(m_fTickCount < 0.0)
		//		m_fTickCount = 0.0;
		//	//cout << "�����ݿ��ʼħ��״̬[" << m_pMSCategory->GetCfg()->GetName() << "] m_fTickCount = " << 
		//	//	m_fTickCount << ", m_iTime = " << m_iTime << ", m_iRemainTime = " << m_iRemainTime << "\n";

		//}
		//else
		//{
			m_fTickCount = 0.0f;
		//}

		if(m_pMSCategory->GetCfg()->GetDotInterval() == 0.5f)
		{
			m_fTickStep = 0.5f;
		}
		else
		{
			m_fTickStep = 1.0f;
		}
		GetOwner()->RegistDistortedTick(this, int32(m_fTickStep * 1000));
	}
}

void CMagicStateServer::RefreshTime()
{
#ifdef COUT_STATE_INFO
	cout << "ˢ��ʱ��\n";
#endif

	GetOwner()->UnRegistDistortedTick(this);
	StartTime();
}

bool CMagicStateServer::ResetTime()
{
#ifdef COUT_STATE_INFO
	cout << "����ʱ��\n";
#endif

	GetOwner()->UnRegistDistortedTick(this);
	StartTime();

	GetAllMgr()->OnSetState(m_pMSCategory->GetCfg()->GetId(), m_uDynamicId, m_uCount, m_iTime,
		m_iRemainTime, m_pSkillInst->GetSkillLevel(),GetInstallerID(),0);

	return true;
}

bool CMagicStateServer::AddTime(int32 iTime)
{
#ifdef COUT_STATE_INFO
	cout << "����ʱ��\n";
#endif

	GetOwner()->UnRegistDistortedTick(this);
	if(m_iTime != -1)
	{
		m_iTime += iTime;
		if(m_iTime < 0)
		{
			m_iTime = 0;
		}
	}
	if(m_iRemainTime != -1)
	{
		m_iRemainTime = GetLeftTime() + iTime;
		if(m_iRemainTime < 0)
		{
			m_iRemainTime = 0;
		}
	}
	StartTime(true);

	GetAllMgr()->OnSetState(m_pMSCategory->GetCfg()->GetId(), m_uDynamicId, m_uCount, m_iTime, m_iRemainTime, m_pSkillInst->GetSkillLevel(),GetInstallerID(),GetCalcValue());

	return true;
}

void CMagicStateServer::CalculateMagicOpArg(CFighterDictator* pInstaller)
{
	const CMagicEffServerSharedPtr& pCancelableMagicEff = m_pMSCategory->GetCfg()->GetCancelableMagicEff();
	if (pCancelableMagicEff)
	{
		m_pCancelableDataMgr->AddCascade(pInstaller);
		m_pCancelableInst->SetIsCalc(true);
		pCancelableMagicEff->Do(m_pCancelableInst, pInstaller, GetOwner(), m_pCancelableDataMgr->GetLastEffDataMgr());
		m_pCancelableInst->SetInterval(false);
		m_pCancelableInst->SetIsCalc(false);
	}
	
	const CMagicEffServerSharedPtr& pDotpMagicEff = m_pMSCategory->GetCfg()->GetDotMagicEff();
	if(pDotpMagicEff)
	{
		m_pDotDataMgr->AddCascade(pInstaller);
		m_pDotInst->SetIsCalc(true);
		m_pDotInst->SetInterval(true);
		pDotpMagicEff->Do(m_pDotInst, pInstaller, GetOwner(), m_pDotDataMgr->GetLastEffDataMgr());
		m_pDotInst->SetInterval(false);
		m_pDotInst->SetIsCalc(false);
	}

	const CMagicEffServerSharedPtr& pFinalMagicEff = m_pMSCategory->GetCfg()->GetFinalMagicEff();
	if(pFinalMagicEff)
	{
		m_pFinalDataMgr->AddCascade(pInstaller);
		m_pFinalInst->SetIsCalc(true);

		//if(abs(m_pMSCategory->GetCfg()->GetFMAssociateDotM()->GetDblValue(pInstaller) - 0.0f) < 0.0000001f) // �������ħ��Ч��û�кͼ��Ч������ϵ
		{
			pFinalMagicEff->Do(m_pFinalInst, pInstaller, GetOwner(), m_pFinalDataMgr->GetLastEffDataMgr());
		}
		//else
		//{
		//	m_pFinalInst->CopyDataWithRatioFrom(m_pDotInst, float(m_pMSCategory->GetCfg()->GetFMAssociateDotM()->GetDblValue(pInstaller)));
		//}

		m_pFinalInst->SetInterval(false);
		m_pFinalInst->SetIsCalc(false);
	}
}


bool CMagicStateServer::StartDo()
{
	GetAllMgr()->ChangeSizeRate(m_pMSCategory->GetCfg().get(), 1);

	CAllStateMgrServer* pTempMgr = m_pMSCategory->m_pMgr->GetAllMgr();
	uint32 uTempDynamicId = m_uDynamicId;
	CFighterDictator* pInstaller = (m_pMSCategory->GetCfg()->InstallerOughtToBeNull()) ? NULL : GetInstaller();


	const CMagicEffServerSharedPtr& pMagicEff = m_pMSCategory->GetCfg()->GetCancelableMagicEff();
	if (pMagicEff)
	{
		//�ɳ���ħ��Ч�����ﻹ������

#ifdef COUT_STATE_INFO
		cout << "ִ�пɳ���ħ��Ч��1�Σ�" << pMagicEff->GetName() << endl;
#endif

		m_pCancelableDataMgr->SetItrLast();
		m_pCancelableInst->SetStateId(m_pMSCategory->GetCfg()->GetId());
		pMagicEff->Do(m_pCancelableInst, pInstaller, GetOwner(), m_pCancelableDataMgr->GetCurEffDataMgr());
		if(!pTempMgr->ExistState(uTempDynamicId)) //���ǰ���ħ��Ч����״̬�Լ���delete��
			return true;
		m_pCancelableInst->SetInterval(false);
		m_pCancelableInst->SetStateId(0);
	}

	return false;
}

bool CMagicStateServer::StartDoFromDB()
{
	GetAllMgr()->ChangeSizeRate(m_pMSCategory->GetCfg().get(), (int32)m_uCount);

	const CMagicEffServerSharedPtr& pMagicEff = m_pMSCategory->GetCfg()->GetCancelableMagicEff();
	if (pMagicEff)
	{
		CAllStateMgrServer* pTempMgr = m_pMSCategory->m_pMgr->GetAllMgr();
		uint32 uTempDynamicId = m_uDynamicId;
		CFighterDictator* pInstaller = (m_pMSCategory->GetCfg()->InstallerOughtToBeNull()) ? NULL : GetInstaller();

		m_pCancelableInst->SetForbitSetupSavedState(true);

		uint32 uRealCount = m_uCount;

#ifdef COUT_STATE_INFO
		cout << "�ָ��ɳ���ħ��Ч��" << uRealCount << "�Σ�" << pMagicEff->GetName() << endl;
#endif

		uint32 i;
		for (i = 0, m_pCancelableDataMgr->SetItrBegin(); i < uRealCount; ++i, m_pCancelableDataMgr->DoItrStep())
		{
			//����ά����
			m_pCancelableDataMgr->AssertItrEnd();
			m_pCancelableInst->SetStateId(m_pMSCategory->GetCfg()->GetId());
			pMagicEff->Do(m_pCancelableInst, pInstaller, GetOwner(), m_pCancelableDataMgr->GetCurEffDataMgr());
			if(!pTempMgr->ExistState(uTempDynamicId))
			{
				return true;
			}
		}
		m_pCancelableInst->SetInterval(false);
		m_pCancelableInst->SetStateId(0);
		m_pCancelableInst->SetForbitSetupSavedState(false);
	}
	return false;
}

//bool CMagicStateServer::Start(bool bFromDB)								//ֻ���½�ħ��״̬����ʱִ��һ�Σ����Ӻ��滻ʱ��ִ��
//{
//#ifdef COUT_STATE_INFO
//	cout << "��ʼ��ʱ\n";
//#endif
//	StartTime(bFromDB);
//
//	bool selfHasBeenDeleted;
//	
//	if(bFromDB)
//	{
//		selfHasBeenDeleted = StartDoFromDB();
//	}
//	else
//	{
//		selfHasBeenDeleted = StartDo();
//	}
//
//	if(selfHasBeenDeleted) 
//	{
//#ifdef COUT_STATE_INFO
//		cout << "ħ��״̬�Ѿ���ɾ��\n";
//#endif
//		return true;
//	}
//	//StartTime(bFromDB);
//	return false;
//}

void CMagicStateServer::OnTick()
{
	m_fTickCount += m_fTickStep;

	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	CAllStateMgrServer* pTempMgr = m_pMSCategory->m_pMgr->GetAllMgr();
	uint32 uTempDynamicId = m_uDynamicId;
	CMagicStateCfgServerSharedPtr& pCfg = m_pMSCategory->GetCfg();

	//cout << "[" <<  GetProcessTime() << "][" << pCfg->GetName() << "]CMagicStateServer::OnTick()\n";

	SQR_TRY
	{

		CMagicEffServerSharedPtr pMagicEff;

		//cout << "ħ��״̬[" << m_pMSCategory->GetCfg()->GetName() << "]OnTick()\n";
		//cout << "m_fTickCount = " << m_fTickCount << ", GetDotInterval() = " << m_pMSCategory->GetCfg()->GetDotInterval() << "\n";
		pMagicEff = pCfg->GetDotMagicEff();
		if(pMagicEff)						//���ħ��Ч��
		{
			//if(m_pMSCategory->GetCfg()->GetDotInterval() == 0.5f || (int32)(m_fTickCount+0.5) % (int32)(m_pMSCategory->GetCfg()->GetDotInterval() + 0.5) == 0)
			if(pCfg->GetDotInterval() == 0.5f || (int32)m_fTickCount % (int32)pCfg->GetDotInterval() == 0)
			{
				uint32 uRealCount = m_uCount;
				//cout << "ִ�м��ħ��Ч��" << uRealCount << "�Σ�" << pMagicEff->GetName() << "\n";
				uint32 i;
				m_pDotInst->SetInterval(true);
				for (i = 0, m_pDotDataMgr->SetItrBegin(); i < uRealCount; ++i, m_pDotDataMgr->DoItrStep())
				{
					//��һά����
					m_pDotDataMgr->AssertItrEnd();
					CFighterDictator* pInstaller = (pCfg->InstallerOughtToBeNull()) ? NULL : GetInstaller();			
					m_pDotInst->SetStateId(pCfg->GetId());
					pMagicEff->Do(m_pDotInst, pInstaller, GetOwner(), m_pDotDataMgr->GetCurEffDataMgr());
					if(!pTempMgr->ExistState(uTempDynamicId))
						return;
					m_pDotInst->SetStateId(0);
				}
				m_pDotInst->SetInterval(false);
			}
		}

		if(TickLengthStrategy() || TickEnd())
		{
			bool selfHasBeenDeleted = EndDo();
			if(selfHasBeenDeleted)
				return;
		}
		//cout << "OnTickʱ�䣺" << m_fTickCount << "\n";
		if(TickEnd())
		{
#ifdef COUT_STATE_INFO
		cout << "ʱ�䵽�ˣ�ɾ���Լ�\n";
#endif

			DeleteSelf();
		}
	}
	SQR_CATCH(exp)
	{
		stringstream sErr;
		sErr << "����ħ��״̬[" << pCfg->GetName() << "]OnTick()��";
		if(pTempMgr->ExistState(uTempDynamicId))
		{
			sErr << "���ڼ���[" << m_pSkillInst->GetSkillName() << "]��";
			exp.AppendMsg(sErr.str().c_str());
			CConnServer* pConnServer = GetOwner()->GetConnection();
			if (pConnServer)
				LogExp(exp, pConnServer);
			else
				LogExp(exp);
		}
		else
		{
			sErr << "��״̬��������ʧ��";
			exp.AppendMsg(sErr.str().c_str());
			LogExp(exp);
		}
	}
	SQR_TRY_END;
}

bool CMagicStateServer::EndDo()
{
	//CMagicStateCfgServer* pCfg = m_pMSCategory->m_pCfg;

	//if(strcmp(m_pMSCategory->GetCfg()->GetName(), "����ħ��Ӳֱ״̬") == 0)
	//{
	//	int32 i = 0;
	//}

	bool selfHasBeenDeleted = CancelDo();
	if(selfHasBeenDeleted) return true;
	const CMagicEffServerSharedPtr& pMagicEff = m_pMSCategory->GetCfg()->GetFinalMagicEff();
	if (pMagicEff)					//����ħ��Ч��
	{
		//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
		CAllStateMgrServer* pTempMgr = m_pMSCategory->m_pMgr->GetAllMgr();
		uint32 uTempDynamicId = m_uDynamicId;
		uint32 uRealCount = m_uCount;

#ifdef COUT_STATE_INFO
		cout << "ִ������ħ��Ч��" << uRealCount << "�Σ�" << pMagicEff->GetName() << endl;
#endif

		uint32 i;
		for (i = 0, m_pFinalDataMgr->SetItrBegin(); i < uRealCount; ++i, m_pFinalDataMgr->DoItrStep())
		{
			//����ά����
			m_pFinalDataMgr->AssertItrEnd();
			CFighterDictator* pInstaller = (m_pMSCategory->GetCfg()->InstallerOughtToBeNull()) ? NULL : GetInstaller();
			pMagicEff->Do(m_pFinalInst, pInstaller, GetOwner(), m_pFinalDataMgr->GetCurEffDataMgr());
			if(!pTempMgr->ExistState(uTempDynamicId)) return true;
		}
		m_pFinalInst->SetInterval(false);
	}
	return false;
}

bool CMagicStateServer::CancelDo(bool bIgnoreSync)
{
	if(m_bCancellationDone) return false;
	m_bCancellationDone = true;

	CAllStateMgrServer* pAllMgr = GetAllMgr();
	pAllMgr->ChangeSizeRate(m_pMSCategory->GetCfg().get(), -(int32)m_uCount);

	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	CAllStateMgrServer* pTempMgr = m_pMSCategory->m_pMgr->GetAllMgr();

	const CMagicEffServerSharedPtr& pMagicEff = m_pMSCategory->GetCfg()->GetCancelableMagicEff();
	if (pMagicEff)				//�ɳ���ħ��Ч��
	{
		uint32 uRealCount = m_uCount;
		uint32 uTempDynamicId = m_uDynamicId;

#ifdef COUT_STATE_INFO
		cout << "ȡ���ɳ���ħ��Ч��" << uRealCount << "�Σ�" << pMagicEff->GetName() << endl;
#endif

		uint32 i;
		for (i = 0, m_pCancelableDataMgr->SetItrBegin(); i < uRealCount; ++i, m_pCancelableDataMgr->DoItrStep())
		{
			//����ά����
			m_pCancelableDataMgr->AssertItrEnd();
			m_pCancelableInst->SetStateId(m_pMSCategory->GetCfg()->GetId());
			pMagicEff->Cancel(m_pCancelableInst, GetOwner(), m_pCancelableDataMgr->GetCurEffDataMgr());
			if(!pTempMgr->ExistState(uTempDynamicId))
				return true;
			m_pCancelableInst->SetStateId(0);
			//���ÿ�γ�����Ҫ��ȡ��ǰ����������Ҫm_uCount--�����Ұ�EndDo()λ�õ�����CancelDo()֮ǰ����������������ƣ�״̬������Ч���Ϳɳ���Ч��������ֹ��ȡ�Լ�״̬�Ĳ���
		}
	}

	//���ÿ�γ�����Ҫ��ȡ����������Ҫ��m_uCount = 0����Ҫ��EndDo()λ�õ�����CancelDo()֮ǰ����������������ƣ�״̬������Ч���Ϳɳ���Ч��������ֹ��ȡ�Լ�״̬�Ĳ���

	//����ȡ��ħ��״̬�����ģ�ͺ���Ч�ص�
	if(!bIgnoreSync)
		pAllMgr->OnDeleteState(m_pMSCategory->GetCfg()->GetId(), m_uDynamicId);
	
	return false;
}

bool CMagicStateServer::CancelDo(uint32 grade)
{
	if(m_bCancellationDone) return false;
	//��ΪCancelDo(uint32 grade)�������Լ�״̬����ʱֱ��ִ�У����Բ���Ҫ��	m_bCancellationDone = true;
	//������Ҫ��������Ч����ɳ���Ч�����õļ��״̬�Ĳ���������ͻ���⡣���磬�����ڵ�������ɳ���Ч���ĳ���������Ч��֮ǰִ�У�
	//��CancelDo()��ӵ��õ���ĳ��״̬��CancelDo(uint32 grade)�������״̬��һ�㣬�������ӳ�����״̬������ڵ�ǰ״ִ̬������Ч��ʱ���ᱻ����

	Ast(grade < m_uCount);

	CAllStateMgrServer* pAllMgr = GetAllMgr();
	pAllMgr->ChangeSizeRate(m_pMSCategory->GetCfg().get(), -(int32)grade);

	//�����Լ���ɾ���޷��ҵ��Լ���Ԥ���ľֲ�����
	//CMagicStateMgrServer* pTempMgr = m_pMSCategory->m_pMgr;
	uint32 uTempDynamicId = m_uDynamicId;

	CMagicStateCfgServerSharedPtr& pCfg = m_pMSCategory->GetCfg();
	const CMagicEffServerSharedPtr& pMagicEff = m_pMSCategory->GetCfg()->GetCancelableMagicEff();
	if ( pMagicEff )
	{

#ifdef COUT_STATE_INFO
		cout << "ȡ���ɳ���ħ��Ч��" << grade << "��\n";
#endif

		uint32 i;
		for (i = 0, m_pCancelableDataMgr->SetItrLast(); i < grade; ++i, m_uCount--)
		{
			//����ά����
			m_pCancelableDataMgr->AssertItrEnd();
			pMagicEff->Cancel(m_pCancelableInst, GetOwner(), m_pCancelableDataMgr->GetCurEffDataMgr());
			if(!pAllMgr->ExistState(uTempDynamicId)) return true;
			m_pCancelableDataMgr->DecCascadeLast();
			m_pCancelableDataMgr->SetItrLast();
		}
	}
	else
	{
		m_uCount -= grade;
	}

	//����ħ��״̬�����ģ�ͺ���Ч�ص�
	pAllMgr->OnSetState(pCfg->GetId(), m_uDynamicId, m_uCount, m_iTime, -2, m_pSkillInst->GetSkillLevel(),GetInstallerID(),GetCalcValue());

	return false;
}

bool CMagicStateServer::DeleteSelf()
{
	PrepareDeleteSelf();

	if (m_mtmapMSItr != m_pMSCategory->m_mtmapMS.end()) 
	{
		if (m_pMSCategory->m_mtmapMS.size() == 1)										//������mapΪ����ɾ����map��ħ��״̬���༶map�Ľ��
		{
			MapMagicStateCategory& mapMSCategory = m_pMSCategory->m_pMgr->m_mapMSCategory;
			MapMagicStateCategory::iterator itrMSCategory = mapMSCategory.find(m_pMSCategory->GetCfg().get());
			if (itrMSCategory != mapMSCategory.end())
			{
				//delete (itrMSCategory->second);
				//mapMSCategory.erase(itrMSCategory);
				EraseMapNode(mapMSCategory, itrMSCategory);
			}
			return true;
		}
		else
		{
			MultiMapMagicState::iterator mtmapMSItr = m_mtmapMSItr;
			//m_pMSCategory->m_mtmapMS.erase(m_mtmapMSItr);
			EraseMapNode(m_pMSCategory->m_mtmapMS, mtmapMSItr);
			return false;
		}
	}
	return false;

}

void CMagicStateServer::PrepareDeleteSelf()
{
#ifdef COUT_STATE_INFO
	cout<<"Delete m_uDynamicId = " << m_uDynamicId << "\n";
#endif

	//m_pMSCategory->m_pMgr->m_mapMSByDynamicId.erase(m_uDynamicId);
	GetAllMgr()->DelStateByDId(m_uDynamicId);

	uint32 uInstallerID = GetInstallerID();

	DetachInstaller();

	//GetOwner()->UnRegistDistortedTick(this);
	GetAllMgr()->PrintFightInfo(false, uInstallerID, m_pMSCategory->GetCfg().get());
}


bool CMagicStateServer::CascadeFull()
{
	//return m_uCount >= m_pMSCategory->GetCfg()->GetCascadeMax().GetIntValue(m_pInstaller);
	return (int32)m_uCount >= m_iCascadeMax && m_iCascadeMax >= 0;
}

bool CMagicStateServer::TickLengthStrategy()
{
	return !m_pMSCategory->GetCfg()->GetDotMagicEff();
}

bool CMagicStateServer::TickEnd()
{
	//return m_uTickCount >= m_pMSCategory->GetCfg()->GetTime().GetIntValue(m_pInstaller);
	//return int32(m_fTickCount + 0.5) >= m_iRemainTime && m_iRemainTime >= 0;
	return (int32)m_fTickCount >= m_iRemainTime && m_iRemainTime >= 0;
}


CMagicStateServer::CMagicStateServer(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller, CMagicStateCategoryServer* pMSCategory)
:CBaseStateServer(pSkillInst, pInstaller),
m_uCount(1), 
m_uShareCount(1),
m_uGrade(pSkillInst->GetSkillLevel()),
m_pMSCategory(pMSCategory),
m_pCancelableInst(NULL),
m_pDotInst(NULL),
m_pFinalInst(NULL),
m_pCancelableDataMgr(NULL),
m_pDotDataMgr(NULL),
m_pFinalDataMgr(NULL),
m_bCancellationDone(false)
{
	//cout << "CMagicStateServer(" << m_uShareCount << ")\n";

	//++pMSCategory->m_pMgr->m_uMaxDynamicId;
	//m_uDynamicId = pMSCategory->m_pMgr->m_uMaxDynamicId;
	////cout << "����������DynamicIDΪ" << m_uDynamicId << "��ħ��״̬\n";
	m_mtmapMSItr = m_pMSCategory->m_mtmapMS.end();
	CreateInst(pSkillInst);
	if(!m_pMSCategory->GetCfg()->GetModelStr().empty()) 
		GetAllMgr()->AddModelStateId(m_pMSCategory->GetCfg()->GetId());
	SetInstaller(pInstaller);
}

CMagicStateServer::CMagicStateServer(CSkillInstServer* pSkillInst, CMagicStateCascadeDataMgr* pCancelableDataMgr,
	CMagicStateCascadeDataMgr* pDotDataMgr, CMagicStateCascadeDataMgr* pFinalDataMgr, 
	uint32 uCount, CFighterDictator* pInstaller, CMagicStateCategoryServer* pMSCategory, int32 iTime, int32 iRemainTime)
:CBaseStateServer(pSkillInst, pInstaller, iTime, iRemainTime),
m_uCount(uCount), 
m_uShareCount(1),
m_uGrade(pSkillInst->GetSkillLevel()),
m_pMSCategory(pMSCategory),
m_pCancelableInst(NULL),
m_pDotInst(NULL),
m_pFinalInst(NULL),
m_pCancelableDataMgr(pCancelableDataMgr),
m_pDotDataMgr(pDotDataMgr),
m_pFinalDataMgr(pFinalDataMgr),
m_bCancellationDone(false)
{
	//cout << "CMagicStateServer(" << m_uShareCount << ")\n";

	//++pMSCategory->m_pMgr->m_uMaxDynamicId;
	//m_uDynamicId = pMSCategory->m_pMgr->m_uMaxDynamicId;
	////cout << "����������DynamicIDΪ" << m_uDynamicId << "��ħ��״̬\n";
	m_mtmapMSItr = m_pMSCategory->m_mtmapMS.end();

	//m_

	CreateInst(pSkillInst, true);
	if(!m_pMSCategory->GetCfg()->GetModelStr().empty()) 
		GetAllMgr()->AddModelStateId(m_pMSCategory->GetCfg()->GetId());
	SetInstaller(pInstaller);
}

CMagicStateServer::~CMagicStateServer()
{
	GetOwner()->UnRegistDistortedTick(this);

	//cout << "������ɾ��DynamicIDΪ" << m_uDynamicId << "��ħ��״̬\n";
	//�Ƿ��ǰ�DetachInstaller()�ĵ������ȫ���������
	if(!m_pMSCategory->GetCfg()->GetModelStr().empty()) 
		GetAllMgr()->SubModelStateId();

	DeleteInst();
}

void CMagicStateServer::CreateInst(CSkillInstServer* pSkillInst, bool bFromDB)
{
	pSkillInst->AddRef();
	m_pSkillInst = pSkillInst;
	CMagicStateCfgServerSharedPtr& aCfg = *(m_pMSCategory->m_pCfg);
	if (m_pMSCategory->GetCfg()->GetCancelableMagicEff())
	{
		m_pCancelableInst = CSkillInstServer::CreateLocal(pSkillInst, new CSkillMagicStateInstServer(aCfg, eMSET_Cancellable));
		if(bFromDB)
			m_pCancelableInst->SetTargetAliveCheckIsIgnored(m_pMSCategory->GetCfg()->GetPersistent());
		else
			m_pCancelableDataMgr = new CMagicStateCascadeDataMgr();
		m_pCancelableInst->SetTargetAliveCheckIsIgnored(this->GetCfg()->GetPersistent());
	}
	if (m_pMSCategory->GetCfg()->GetDotMagicEff())
	{
		m_pDotInst = CSkillInstServer::CreateLocal(pSkillInst, new CSkillMagicStateInstServer(aCfg, eMSET_Dot));
		if(!bFromDB)
			m_pDotDataMgr = new CMagicStateCascadeDataMgr();
	}
	//cout << pSkillInst->m_strSkillName << "\tSetDOT(true)" << endl;
	//m_pDotInst->SetInterval(true);
	if (m_pMSCategory->GetCfg()->GetFinalMagicEff())
	{
		m_pFinalInst = CSkillInstServer::CreateLocal(pSkillInst, new CSkillMagicStateInstServer(aCfg, eMSET_Final));
		if(!bFromDB)
			m_pFinalDataMgr = new CMagicStateCascadeDataMgr();
	}
}
void CMagicStateServer::DeleteInst()
{
	if(m_pCancelableInst)
	{
		m_pCancelableInst->DestroyLocal();
		m_pCancelableInst = NULL;
		delete m_pCancelableDataMgr;
		m_pCancelableDataMgr = NULL;
	}
	if(m_pDotInst)
	{
		m_pDotInst->DestroyLocal();
		m_pDotInst = NULL;
		delete m_pDotDataMgr;
		m_pDotDataMgr = NULL;
	}
	if(m_pFinalInst)
	{
		m_pFinalInst->DestroyLocal();
		m_pFinalInst = NULL;
		delete m_pFinalDataMgr;
		m_pFinalDataMgr = NULL;
	}
	if(m_pSkillInst)
	{
		m_pSkillInst->DelRef();
		m_pSkillInst = NULL;
	}
}

void CMagicStateServer::SetInstaller(CFighterDictator* pInstaller)
{
	//m_pInstaller = pInstaller;
	if(pInstaller)
	{
		m_uInstallerID = pInstaller->GetEntityID();
		if (!m_pMSCategory->GetCfg()->InstallerOughtToBeNull()) 
		{
			pInstaller->Attach(m_pMSCategory->m_pMgr, eCE_Offline);
		}
	}
	else
	{
		m_uInstallerID = 0;
	}
}


void CMagicStateServer::ChangeInstaller(CFighterDictator* pInstaller)
{
	if (pInstaller != GetInstaller()) {
		DetachInstaller();
		SetInstaller(pInstaller);
	}
}

void CMagicStateServer::DetachInstaller()
{
	CFighterDictator* pInstaller = GetInstaller();
	if(!pInstaller) return;
	bool bExistAnotherSource = false;
	if (m_pMSCategory->GetCfg()->GetCascadeType() == eCT_Decentral) 
	{
		for (MapMagicStateCategory::iterator itrMSCategory = m_pMSCategory->m_pMgr->m_mapMSCategory.begin(); 
			itrMSCategory != m_pMSCategory->m_pMgr->m_mapMSCategory.end(); ++itrMSCategory)
		{
			if (itrMSCategory->second != m_pMSCategory && itrMSCategory->second->GetCfg()->GetCascadeType() == eCT_Decentral)
			{
				MultiMapMagicState& curMtmapMS = itrMSCategory->second->m_mtmapMS;
				MtMapMagicStatePairItr mtmapMSPairItr = curMtmapMS.equal_range(GetInstallerID());
				if (mtmapMSPairItr.first != curMtmapMS.end())
				{
					bExistAnotherSource = true;
					break;
				}
			}
		}
		if (!bExistAnotherSource && !m_pMSCategory->GetCfg()->InstallerOughtToBeNull()) 
		{
			pInstaller->Detach(m_pMSCategory->m_pMgr, eCE_Offline);
		}
	}
	SetInstaller(NULL);
}

CFighterDictator* CMagicStateServer::GetOwner()
{
	return m_pMSCategory->m_pMgr->m_pOwner;
}

CAllStateMgrServer* CMagicStateServer::GetAllMgr()
{
	return m_pMSCategory->m_pMgr->GetAllMgr();
}

CBaseStateCfgServer* CMagicStateServer::GetCfg()
{
	return m_pMSCategory->m_pCfg->get();
}

CMagicStateCfgServerSharedPtr&	CMagicStateServer::GetCfgSharedPtr()
{
	return *m_pMSCategory->m_pCfg;
}

int32 CMagicStateServer::GetCalcValue()
{
	return m_pDotDataMgr?m_pDotDataMgr->CalcAllEffData():0;
}





