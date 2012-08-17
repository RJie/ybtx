#include "stdafx.h"
#include "LoadSkillCommon.h"
#include "CMagicStateClient.h"
#include "CTplStateCfgClient.inl"
#include "CFighterFollower.h"
#include "ICharacterFollowerCallbackHandler.h"
#include "ErrLogHelper.h"
#include "BaseHelper.h"

CMagicStateClient::CMagicStateClient(uint32 uDynamicId, uint32 uCount, int32 iTime, int32 iRemainTime,
									 uint32 uSkillLevel, uint32 uInstallerID, int32 iCalcValue,
									 CMagicStateCategoryClient* pMSCategory, CAllStateMgrClient* pAllStateMgr)
: CBaseStateClient(uDynamicId, iTime, iRemainTime, uSkillLevel, uInstallerID, pAllStateMgr), 
  m_uCount(uCount),
  m_iCalcValue(iCalcValue),
  m_pMSCategory(pMSCategory)
{
}

CBaseStateCfg* CMagicStateClient::GetCfg()
{
	return m_pMSCategory->m_pCfg.get();
}

CFighterFollower* CMagicStateClient::GetOwner()
{
	return m_pMSCategory->m_pMgr->m_pOwner;
}





void CMagicStateCategoryClient::AddMS(uint32 uDynamicId, uint32 uCount, int32 iTime, int32 iRemainTime,
									  uint32 uSkillLevel, uint32 uInstallerID, int32 iCalcValue, CAllStateMgrClient* pAllStateMgr)
{
	//cout << "�ͻ��˴���DynamicIdΪ" << uDynamicId << "��" << uCount << "��ħ��״̬\n";
	CMagicStateClient* pMagicStateClient = new CMagicStateClient(uDynamicId, uCount, iTime, iRemainTime, uSkillLevel,uInstallerID, iCalcValue, this, pAllStateMgr);
	pAllStateMgr->m_mapSetupOrder[pMagicStateClient->GetSetupOrder()] = pMagicStateClient;
	m_mapMS.insert(make_pair(uDynamicId, pMagicStateClient));
	pMagicStateClient->m_uUpdateTime = m_pMgr->m_pOwner->GetDistortedProcessTime();
}

CMagicStateCategoryClient::~CMagicStateCategoryClient()
{
	ClearMap(m_mapMS);
}




 


bool CMagicStateMgrClient::SetState(uint32 uCategoryId, uint32 uDynamicId, uint32 uCount, int32 iTime,
									int32 iRemainTime, uint32 uSkillLevel,uint32 uInstallerID,int32 iCalcValue)
{
	if(uCount == 0)
	{
		DeleteState(uCategoryId, uDynamicId);
		return true;
	}
	MapMagicStateCategoryClient::iterator itrMSC = m_mapMSCategory.find(uCategoryId);

	CAllStateMgrClient* pAllStateMgr = m_pOwner->GetAllStateMgr();

	if(itrMSC == m_mapMSCategory.end())
	{
		//�½�һ��ħ��״̬����
		CTplStateCfgClient<CMagicStateClient>::SharedPtrType& pCfg = CTplStateCfgClient<CMagicStateClient>::GetById(uCategoryId);
		CMagicStateCategoryClient* pMSCategory = new CMagicStateCategoryClient(pCfg, this);


		//�½�һ��ħ��״̬����
		pMSCategory->AddMS(uDynamicId, uCount, iTime, iRemainTime, uSkillLevel,uInstallerID,iCalcValue, pAllStateMgr);
		//���ħ��״̬ͼ��
		pAllStateMgr->OnBuffUpdate(
			uDynamicId, pCfg->GetName(), uCount, iTime, (float)iRemainTime, pCfg->GetDecrease(), uSkillLevel,pCfg->GetDotInterval(),uInstallerID,iCalcValue);
		
		//ħ�����������������
		m_mapMSCategory.insert(make_pair(uCategoryId, pMSCategory));

		//���ħ��״̬�������Ч��ͼ���
		pAllStateMgr->OnStateCategoryBegin(uCategoryId, uDynamicId, uCount);
		return true;
	}
	else
	{
		//��ԭ��ħ��״̬����Ļ�����
		MapMagicStateClient::iterator itr = itrMSC->second->m_mapMS.find(uDynamicId);
		CTplStateCfgClient<CMagicStateClient>::SharedPtrType& pCfg = CTplStateCfgClient<CMagicStateClient>::GetById(uCategoryId);
		if(itr == itrMSC->second->m_mapMS.end())
		{
			//�½�һ��ħ��״̬����
			itrMSC->second->AddMS(uDynamicId, uCount, iTime, iRemainTime, uSkillLevel,uInstallerID,iCalcValue, pAllStateMgr);
			//���ħ��״̬ͼ��
			pAllStateMgr->OnBuffUpdate(
				uDynamicId, pCfg->GetName(), uCount, iTime, (float)iRemainTime, pCfg->GetDecrease(), uSkillLevel,pCfg->GetDotInterval(),uInstallerID,iCalcValue);

			if(pCfg->IsMultiCascadeFX() || pCfg->GetScale() != 1.0f)
			{
				pAllStateMgr->OnStateEntityAdd(uCategoryId, uDynamicId, uCount);
			}
		}
		else
		{
			uint32 uOldCount = itr->second->GetCount();
			//����ԭ����ħ��״̬����
			itr->second->UpdateCount(uCount);
			itr->second->UpdateTime(iTime);
			itr->second->UpdateRemainTime(iRemainTime);

			//����ħ��״̬ͼ��
			m_pOwner->GetAllStateMgr()->OnBuffUpdate(
				uDynamicId, pCfg->GetName(), uCount, iTime, (float)iRemainTime, pCfg->GetDecrease(), uSkillLevel,pCfg->GetDotInterval(),uInstallerID,iCalcValue);

			//������Ϊ���е���ʵ�֣���ʱû�취ʵ�ֶ����Ч����һ�����ֲ�ͬ�˰�װ�ĸ���״̬�ϣ����������������ֻ��ʾ���һ��״̬
			if(pCfg->IsMultiCascadeFX() || pCfg->GetScale() != 1.0f)
			{
				pAllStateMgr->OnStateCascadeChange(uCategoryId, uDynamicId, uCount, uOldCount);
			}
		}

		return true;
	}
	
	return true;

	//return false;
}



void CMagicStateMgrClient::DeleteState(uint32 uCategoryId, uint32 uDynamicId)
{
	MapMagicStateCategoryClient::iterator itrMSC = m_mapMSCategory.find(uCategoryId);
	if(itrMSC != m_mapMSCategory.end())
	{
		MapMagicStateClient& curMapMS = itrMSC->second->m_mapMS;
		MapMagicStateClient::iterator itr = curMapMS.find(uDynamicId);
		if(itr != curMapMS.end())
		{
			uint32 uOldCount = itr->second->GetCount();
			itr->second->m_iRemainTime = 0;
			//ȥ��ħ��״̬��ͼ���
			m_pOwner->GetAllStateMgr()->OnBuffUpdate(
				uDynamicId, itr->second->m_pMSCategory->m_pCfg->GetName(), 0, 0, 0.0f,
				itr->second->m_pMSCategory->m_pCfg->GetDecrease(), 1, 1, itr->second->GetInstallerID());
			
			//cout << "�ͻ���ɾ��DynamicIDΪ" << uDynamicId << "��ħ��״̬\n";
			EraseMapNode(curMapMS, itr);

			if(curMapMS.empty())
			{
				//ȥ��ħ��״̬�������Ч
				m_pOwner->GetAllStateMgr()->OnStateCategoryEnd(uCategoryId, uDynamicId, uOldCount);

				EraseMapNode(m_mapMSCategory, itrMSC);
			}
			else
			{
				CTplStateCfgClient<CMagicStateClient>::SharedPtrType& pCfg = CTplStateCfgClient<CMagicStateClient>::GetById(uCategoryId);
				if(pCfg->IsMultiCascadeFX() || pCfg->GetScale() != 1.0f)
				{
					CMagicStateClient* pLastState= curMapMS.rbegin()->second;
					m_pOwner->GetAllStateMgr()->OnStateEntityDelete(uCategoryId, uDynamicId, uOldCount, pLastState->GetDynamicID(), pLastState->GetCount());
				}
			}
		}
	}
}

bool CMagicStateMgrClient::ExistState(const string& name)
{
	MapMagicStateCategoryClient::iterator itr = m_mapMSCategory.find(CTplStateCfgClient<CMagicStateClient>::GetByName(name.c_str())->GetId());
	if(itr != m_mapMSCategory.end())
	{
		return !itr->second->m_mapMS.empty();
	}
	else
	{
		return false;
	}
}

uint32 CMagicStateMgrClient::StateCount(const string& name)
{
	MapMagicStateCategoryClient::iterator itr = m_mapMSCategory.find(CTplStateCfgClient<CMagicStateClient>::GetByName(name.c_str())->GetId());
	if(itr != m_mapMSCategory.end())
	{
		uint32 uTotalCount = 0;
		MapMagicStateClient& mapMS = itr->second->m_mapMS;
		for(MapMagicStateClient::iterator itrState = mapMS.begin(); itrState != mapMS.end(); ++itrState)
		{
			uTotalCount += itrState->second->m_uCount;
		}
		return uTotalCount;
	}
	else
	{
		return 0;
	}
}

int32 CMagicStateMgrClient::StateLeftTime(const string& name, CFighterFollower* pFrom)
{
	//MapMagicStateCategoryClient::iterator itr = m_mapMSCategory.find(CTplStateCfgClient<CMagicStateClient>::GetByName(name.c_str())->GetId());
	//if(itr != m_mapMSCategory.end())
	//{
	//	uint32 uLeftTime = 0;
	//	MapMagicStateClient& mapMS = itr->second->m_mapMS;
	//	for(MapMagicStateClient::iterator itrState = mapMS.begin(); itrState != mapMS.end(); ++itrState)
	//	{
	//		uLeftTime += itrState->second->GetRemainTime();
	//	}
	//	return uLeftTime;
	//}
	//else
	//{
		return 0;
	//}
}

float CMagicStateMgrClient::GetRemainTime(const TCHAR* sName, uint32 uDynamicId)
{
	MapMagicStateCategoryClient::iterator itrMSC = m_mapMSCategory.find(CTplStateCfgClient<CMagicStateClient>::GetByName(sName)->GetId());
	if(itrMSC != m_mapMSCategory.end())
	{
		MapMagicStateClient& curMapMS = itrMSC->second->m_mapMS;
		MapMagicStateClient::iterator itr = curMapMS.find(uDynamicId);
		if(itr != curMapMS.end())
		{
			return itr->second->GetRemainTime();
		}
	}
	return 0.0f;
}


void CMagicStateMgrClient::SetTargetBuff()
{
	//ȥ������ħ��״̬�������Ч��
	for(MapMagicStateCategoryClient::iterator itr = m_mapMSCategory.begin(); itr != m_mapMSCategory.end(); itr++)
	{
		MapMagicStateCategoryClient::iterator itrMSC = m_mapMSCategory.find(itr->second->m_pCfg->GetId());
		if(itrMSC != m_mapMSCategory.end())
		{
			MapMagicStateClient& curMapMS = itrMSC->second->m_mapMS;
			for(MapMagicStateClient::iterator itrms = curMapMS.begin(); itrms != curMapMS.end(); itrms++)
			{
				m_pOwner->GetAllStateMgr()->OnBuffUpdate(
				itrms->second->GetDynamicID(), itr->second->m_pCfg->GetName(),
				itrms->second->GetCount(), itrms->second->GetTime(),itrms->second->GetRemainTime(),
				itr->second->m_pCfg->GetDecrease(), itrms->second->GetSkillLevel(),itr->second->m_pCfg->GetDotInterval(),
				itrms->second->GetInstallerID(),itrms->second->m_iCalcValue);
			}
		}
	}
}


void CMagicStateMgrClient::ClearAll()
{
	//ȥ������ħ��״̬�������Ч��
	for(MapMagicStateCategoryClient::iterator itrMSC = m_mapMSCategory.begin();
		itrMSC != m_mapMSCategory.end(); itrMSC++)
	{
		MapMagicStateClient& curMapMS = itrMSC->second->m_mapMS;
		uint32 uDynamicId = 0, uCategoryId;
		uint32 uOldCount = 0;
		for(MapMagicStateClient::iterator itr = curMapMS.begin(); itr != curMapMS.end(); ++itr)
		{
			uDynamicId = itr->second->GetDynamicID();
			uCategoryId = itr->second->GetID();
			itr->second->m_iRemainTime = 0;
			uOldCount += itr->second->GetCount();
			//ȥ��ħ��״̬��ͼ���
			m_pOwner->GetAllStateMgr()->OnBuffUpdate(
				itr->second->GetDynamicID(), itr->second->m_pMSCategory->m_pCfg->GetName(), 0, 0, 0.0f,
				itr->second->m_pMSCategory->m_pCfg->GetDecrease(), 1, 1, itr->second->GetInstallerID());
			//EraseMapNode(curMapMS, itr);
		}

		if(uDynamicId != 0)
		{
			//ȥ��ħ��״̬�������Ч
			m_pOwner->GetAllStateMgr()->OnStateCategoryEnd(uCategoryId, uDynamicId, uOldCount);

		}
		//EraseMapNode(m_mapMSCategory, itrMSC);
	}

	ClearMap(m_mapMSCategory);
}

bool CMagicStateMgrClient::CanDecStateCascade(const string& name, uint32 uCascade)
{
	if(uCascade == 0) return true;
	uint32 uAllCascadeCount = 0;
	CTplStateCfgClient<CMagicStateClient>::SharedPtrType& pCfg = CTplStateCfgClient<CMagicStateClient>::GetByName(name.c_str());
	MapMagicStateCategoryClient::iterator itr = m_mapMSCategory.find(pCfg->GetId());
	if(itr != m_mapMSCategory.end())
	{
		MapMagicStateClient& mtmapMS = itr->second->m_mapMS;
		for(MapMagicStateClient::iterator itrMt = mtmapMS.begin(); itrMt != mtmapMS.end(); itrMt++)
		{
			uAllCascadeCount += itrMt->second->m_uCount;
			if(uAllCascadeCount >= uCascade) return true;
		}
	}

	return false;
}

