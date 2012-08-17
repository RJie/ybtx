#include "stdafx.h"
#include "LoadSkillCommon.h"
#include "LoadSkillCommon.inl"
#include "CBaseStateCfgClient.h"
#include "CTableFile.h"
#include "FightDef.h"

template <class StateType>
map<uint32, CBaseStateCfgClient<StateType>*> CBaseStateCfgClient<StateType>::m_mapCfgById;

template <class StateType>
bool CBaseStateCfgClient<StateType>::LoadConfig(const char* cfgFile)
{
	CTabFile TabFile;
	stringstream ExpStr;				//�����쳣���
	CBaseStateCfgClient<StateType>*	pCfgNode;

	if (!TabFile.Load(cfgFile)) return false;

	ClearMap(m_mapCfgById);

	for(int32 i=1; i<TabFile.GetHeight(); i++)
	{
		pCfgNode = new CBaseStateCfgClient<StateType>;
		pCfgNode->m_uId = GetStateTypeFloor() + i;
		pCfgNode->m_sIcon = TabFile.GetString(i, szBaseState_IconID);
		pCfgNode->m_sModel = TabFile.GetString(i, szBaseState_Model);
		pCfgNode->m_sFX = TabFile.GetString(i, szBaseState_FXID);
		pair<MapBaseStateCfgById::iterator, bool> pr = m_mapCfgById.insert(make_pair(pCfgNode->m_uId, pCfgNode));
		if(!pr.second)
		{
			ExpStr << "��" << i << "�е�" << "ħ��״̬" << pCfgNode->m_uId << "�ظ�";
			GenExp(ExpStr.str());
			return false;
		}
	}
	return true;
}

template <class StateType>
void CBaseStateCfgClient<StateType>::UnloadConfig()
{
	ClearMap(m_mapCfgById);
}

template <class StateType>
CBaseStateCfgClient<StateType>* CBaseStateCfgClient<StateType>::GetById(uint32 uId)
{
	stringstream ExpStr;
	CBaseStateCfgClient<StateType>::MapBaseStateCfgById::iterator mapCfgItr;
	mapCfgItr = m_mapCfgById.find(uId);
	if (mapCfgItr == m_mapCfgById.end())
	{
		ExpStr << "ħ��״̬" << uId << "������";
		GenExp(ExpStr.str());
		return NULL;
	}
	return mapCfgItr->second;
}








