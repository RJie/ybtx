#include "stdafx.h"
#include "CDamageChangeStateMgr.h"
#include "CSkillInstServer.h"
#include "CTriggerableStateMgr.inl"
#include "COtherStateMgr.inl"
#include "CStateDBData.h"

template class TOtherStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;
template class TTriggerableStateMgrServer<CDamageChangeStateCfgServer, CDamageChangeStateServer>;

//void CTriggerStateMgrServer::ClearDamageChangeState(const string& name)
//{
//	CDamageChangeStateCfgServer* pCfg = CDamageChangeStateCfgServer::Get(name);
//	if(!pCfg) return;
//	MapDamageChangeState::iterator itrPDS = m_mapDS.find(pCfg);
//	if(itrPDS != m_mapDS.end())
//	{
//		itrPDS->second->DeleteSelf();
//	}
//}
//
//bool CTriggerStateMgrServer::ClearDamageChangeStateByCond(CStateCondBase* pStateCond, uint32 uId)
//{
//	CDamageChangeStateCfgServer::MapDamageChangeStateCfgById::iterator itr = CDamageChangeStateCfgServer::m_mapCfgById.find(uId);
//	if(itr != CDamageChangeStateCfgServer::m_mapCfgById.end())
//	{
//		MapDamageChangeState::iterator itrPDS = m_mapDS.find(itr->second);
//		if(itrPDS != m_mapDS.end())
//		{
//			if((*pStateCond)(itrPDS->second))
//				itrPDS->second->DeleteSelf();
//			else
//				return false;
//		}
//	}
//	return true;
//}
//
//bool CTriggerStateMgrServer::ExistState(const string& name)
//{
//	MapDamageChangeState::iterator itr = m_mapDS.find(CDamageChangeStateCfgServer::Get(name));
//	return  itr != m_mapDS.end();
//}
//
//bool CTriggerStateMgrServer::ExistState(const string& name, const CFighterDictator* pInstaller)
//{
//	MapDamageChangeState::iterator itr = m_mapDS.find(CDamageChangeStateCfgServer::Get(name));
//	if(itr != m_mapDS.end())
//	{
//		return itr->second->m_pInstaller == pInstaller;
//	}
//	else
//	{
//		return false;
//	}
//}
//
//
//
//
//
//
//bool CTriggerStateMgrServer::SetupDamageChangeState(CSkillInstServer* pSkillInst, const string& name, CFighterDictator* pInstaller)
//{
//	if (!m_pOwner)
//	{
//		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
//		//return false;
//	}
//	CDamageChangeStateCfgServer* pCfg = CDamageChangeStateCfgServer::Get(name);
//
//	//���߼���
//	if(GetAllMgr()->Immume(pCfg, pSkillInst)) return false;
//
//	//�����Լ���
//	if(GetAllMgr()->DecreaseStateResist(pCfg)) return false;
//
//	//����״̬�滻����
//	if(!GetAllMgr()->ReplaceModelState(pCfg)) return false;
//
//	MapDamageChangeState::iterator mapPDSItr = m_mapDS.find(pCfg);
//	if (mapPDSItr == m_mapDS.end())
//	{
//		cout << m_pOwner->GetEntityID() << ": ��װ�˺����״̬��" << pCfg->GetName() << "\n";
//
//		//����һ���µ��˺����ħ��״̬
//		CDamageChangeStateServer* pTempDS = new CDamageChangeStateServer(pSkillInst, pInstaller, this, pCfg);
//
//		//״̬Ԫ�ز����������DamageChangeStateӳ��
//		pair<MapDamageChangeState::iterator, bool> pr = m_mapDS.insert(make_pair(pCfg, pTempDS));
//
//		//����DamageChangeState������ 
//		MapDamageChangeState::iterator mapPDSItr = pr.first;
//		mapPDSItr->second->m_mapStateItr = mapPDSItr;
//
//		if(pCfg->GetTriggerEvent() == eSET_InstallerDie)
//		{
//			pInstaller->Attach(mapPDSItr->second, eCE_Die);
//		}
//		else
//		{
//			//�Զ���۲���ģʽAttach
//			MapTSEventBandle::iterator mapStateBundleItr = m_mapBSEB.find(pCfg->GetTriggerEvent());
//			if (mapStateBundleItr == m_mapBSEB.end())
//			{
//				//����һ���µ��¼�������
//				TStateBundleByEvent tempBSEB;
//
//				//״ָ̬������¼���������DamageChangeState�б�������EventBandle������
//				mapPDSItr->second->m_listStateItr = tempBSEB.m_listDS.insert(tempBSEB.m_listDS.end(), mapPDSItr->second);
//
//				//�¼������������������EventBandleӳ��
//				pair<MapTSEventBandle::iterator, bool> prBSEB = m_mapBSEB.insert(make_pair(pCfg->GetTriggerEvent(), tempBSEB));
//
//				//��¼�ղ����EventBandleԪ���ڹ�������λ��
//				mapStateBundleItr = prBSEB.first;
//
//				//����EventBandle������
//				mapPDSItr->second->m_listStateItr = mapStateBundleItr->second.m_listDS.begin();
//			}
//			else
//			{
//				//����϶�������mapStateBundleItr->second.m_listDS.find(mapPDSItr->second)) != second.m_listBS.end()�����
//				//��ΪmapPDSItr == m_mapDS.end()�Ѿ��ų���
//				//״ָ̬������¼���������TriggerState�б�������EventBandle������
//				mapPDSItr->second->m_listStateItr = mapStateBundleItr->second.m_listDS.insert(mapStateBundleItr->second.m_listDS.end(), mapPDSItr->second);
//			}
//			//����EventBandle��ָ��
//			mapPDSItr->second->m_pStateEventBundle = &mapStateBundleItr->second;
//		}
//
//		mapPDSItr->second->Start();
//
//		//����ħ��״̬�����ģ�ͺ���Ч�ص�
//		GetAllMgr()->OnSetState(pCfg->GetId(), pCfg->GetId(), 1, mapPDSItr->second->m_iTime, mapPDSItr->second->m_iRemainTime);
//		return true;
//	}
//	else
//	{
//		//�ȼ�������ԭ��ħ��״̬�ĵȼ�������滻����
//		if (pSkillInst->GetSkillLevel() >= mapPDSItr->second->m_uGrade)
//		{
//			return mapPDSItr->second->Replace(pSkillInst, pInstaller);
//		}
//		else
//		{
//			return false;
//		}
//	}
//}
//
//bool CTriggerStateMgrServer::RestoreDamageChangeStateFromDB(CSkillInstServer* pSkillInst, CDamageChangeStateCfgServer* pCfg,
//															CFighterDictator* pInstaller, int32 iRemainTime, uint32 uAccumulate, float fProbability)	//�����ݿ�ָ�ĳ��״̬
//{
//	if (!m_pOwner)
//	{
//		GenErr("δ����SetOwner����ָ��Ŀ�걾���ָ��");
//		//return false;
//	}
//
//	MapDamageChangeState::iterator mapPDSItr = m_mapDS.find(pCfg);
//	if (mapPDSItr == m_mapDS.end())
//	{
//		cout << m_pOwner->GetEntityID() << ": ��װ�˺����״̬��" << pCfg->GetName() << "\n";
//
//		//����һ���µ��˺����ħ��״̬
//		CDamageChangeStateServer* pTempDS = new CDamageChangeStateServer(pSkillInst, pInstaller, this, pCfg, uAccumulate, iRemainTime, fProbability);
//
//		//״̬Ԫ�ز����������DamageChangeStateӳ��
//		pair<MapDamageChangeState::iterator, bool> pr = m_mapDS.insert(make_pair(pCfg, pTempDS));
//
//		//����DamageChangeState������ 
//		MapDamageChangeState::iterator mapPDSItr = pr.first;
//		mapPDSItr->second->m_mapStateItr = mapPDSItr;
//
//		if(pCfg->GetTriggerEvent() == eSET_InstallerDie)
//		{
//			pInstaller->Attach(mapPDSItr->second, eCE_Die);
//		}
//		else
//		{
//			//�Զ���۲���ģʽAttach
//			MapTSEventBandle::iterator mapStateBundleItr = m_mapBSEB.find(pCfg->GetTriggerEvent());
//			if (mapStateBundleItr == m_mapBSEB.end())
//			{
//				//����һ���µ��¼�������
//				TStateBundleByEvent tempBSEB;
//
//				//״ָ̬������¼���������DamageChangeState�б�������EventBandle������
//				mapPDSItr->second->m_listStateItr = tempBSEB.m_listDS.insert(tempBSEB.m_listDS.end(), mapPDSItr->second);
//
//				//�¼������������������EventBandleӳ��
//				pair<MapTSEventBandle::iterator, bool> prBSEB = m_mapBSEB.insert(make_pair(pCfg->GetTriggerEvent(), tempBSEB));
//
//				//��¼�ղ����EventBandleԪ���ڹ�������λ��
//				mapStateBundleItr = prBSEB.first;
//
//				//����EventBandle������
//				mapPDSItr->second->m_listStateItr = mapStateBundleItr->second.m_listDS.begin();
//			}
//			else
//			{
//				//����϶�������mapStateBundleItr->second.m_listDS.find(mapPDSItr->second)) != second.m_listBS.end()�����
//				//��ΪmapPDSItr == m_mapDS.end()�Ѿ��ų���
//				//״ָ̬������¼���������TriggerState�б�������EventBandle������
//				mapPDSItr->second->m_listStateItr = mapStateBundleItr->second.m_listDS.insert(mapStateBundleItr->second.m_listDS.end(), mapPDSItr->second);
//			}
//			//����EventBandle��ָ��
//			mapPDSItr->second->m_pStateEventBundle = &mapStateBundleItr->second;
//		}
//
//		mapPDSItr->second->Start(true);
//
//		//����ħ��״̬�����ģ�ͺ���Ч�ص�
//		GetAllMgr()->OnSetState(pCfg->GetId(), pCfg->GetId(), 1, mapPDSItr->second->m_iTime, mapPDSItr->second->m_iRemainTime);
//		return true;
//	}
//	else
//	{
//		//�ָ��˺����״̬���ܳ����ظ����ֵ�״̬
//		stringstream ExpStr;
//		ExpStr << "�ָ��˺����״̬<" << pCfg->GetName() << ">���ܳ����ظ����ֵ�״̬\n";
//		GenErr(ExpStr.str());
//		return false;
//	}
//}

