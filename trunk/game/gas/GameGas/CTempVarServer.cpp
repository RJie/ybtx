#include "stdafx.h"
#include "CTempVarServer.h"
#include "ExpHelper.h"
#include "TSqrAllocator.inl"
#include "CCfgCalcOptrTable.h"
#include "CTempVarMgr.h"

CTempVarMgrServer::MapTempVar	CTempVarMgrServer::m_mapPVar;
CTempVarMgrServer::VecTempVar	CTempVarMgrServer::m_vecPVar;
set<string> CTempVarMgrServer::m_setImmuneTaskAttackName;
bool CTempVarMgrServer::__init = CTempVarMgrServer::Init();


CTempVarMgrServer::CTempVarMgrServer(const CFighterDictator* pHolder)
: m_iMopCalcValue(0)
, m_bLockIncreaseHP(false)
, m_bLockDecreaseHP(false)
, m_bLockIncreaseAgile(false)
, m_bLockDecreaseAgile(false)
, m_fDamageShareProportion(0)
, m_pLinkFighter(NULL)
, m_iDisTriggerEvent(0)
, m_iPrintInfoOff(0)
, m_uSubHP(0)
, m_uBeSubHP(0)
, m_uUnchangeSubHP(0)
, m_uBeUnchangeSubHP(0)
, m_uSubMP(0)
, m_uBeSubMP(0)
, m_uHeal(0)
, m_uGetHeal(0)
, m_uUnchangeHealHP(0)
, m_uBeUnchangeHealHP(0)
, m_iNoSingTime(0)
, m_strDamageChangeStateName("")
, m_pHolder(pHolder)
{
	for(set<string>::iterator itr = m_setImmuneTaskAttackName.begin(); itr != m_setImmuneTaskAttackName.end(); ++itr)
	{
		m_iImmuneTaskAttack[*itr] = 0;
	}
}


bool CTempVarMgrServer::Init()
{
	//ע�⣺�������������ĸ�������Сд
	
	//���Աָ������2010-12-21
	//m_mapPVar["�˺�"] = &CTempVarMgrServer::m_uSubHP;
	//m_mapPVar["���˺�"] = &CTempVarMgrServer::m_uBeSubHP;
	//m_mapPVar["δ����˺�"] = &CTempVarMgrServer::m_uUnchangeSubHP;
	//m_mapPVar["��δ����˺�"] = &CTempVarMgrServer::m_uBeUnchangeSubHP;
	//m_mapPVar["����"] = &CTempVarMgrServer::m_uSubMP;
	//m_mapPVar["������"] = &CTempVarMgrServer::m_uBeSubMP;
	//m_mapPVar["����"] = &CTempVarMgrServer::m_uHeal;
	//m_mapPVar["������"] = &CTempVarMgrServer::m_uGetHeal;
	//m_mapPVar["δ�������"] = &CTempVarMgrServer::m_uUnchangeHealHP;
	//m_mapPVar["��δ�������"] = &CTempVarMgrServer::m_uBeUnchangeHealHP;
	//m_mapPVar["ħ����������ֵ"] = &CTempVarMgrServer::m_iMopCalcValue;

	m_vecPVar.push_back(0);		//0��������

#define RegisterTempVar(KeyName, MemberVar)	\
	m_mapPVar[KeyName] = m_vecPVar.size(); m_vecPVar.push_back(&CTempVarMgrServer::MemberVar);

	RegisterTempVar("�˺�", m_uSubHP);
	RegisterTempVar("���˺�", m_uBeSubHP);
	RegisterTempVar("δ����˺�", m_uUnchangeSubHP);
	RegisterTempVar("��δ����˺�", m_uBeUnchangeSubHP);
	RegisterTempVar("����", m_uSubMP);
	RegisterTempVar("������", m_uBeSubMP);
	RegisterTempVar("����", m_uHeal);
	RegisterTempVar("������", m_uGetHeal);
	RegisterTempVar("δ�������", m_uUnchangeHealHP);
	RegisterTempVar("��δ�������", m_uBeUnchangeHealHP);
	RegisterTempVar("ħ����������ֵ", m_iMopCalcValue);

#undef RegisterTempVar

	m_setImmuneTaskAttackName.insert("�����ս��");
	m_setImmuneTaskAttackName.insert("����ը��");
	m_setImmuneTaskAttackName.insert("��������");
	m_setImmuneTaskAttackName.insert("�ǹ�ս����");

	CTempVarMgr::SetSetVarPtrFunc(CTempVarMgrServer::SetVarPtr);
	return true;
}

bool CTempVarMgrServer::SetVarPtr(UUnitValue* pVarPtr, const string& sVarName)
{
	//���Աָ������2010-12-21
	//if(m_mapPVar.find(sVarName) == m_mapPVar.end())
	//{
	//	pVarPtr->pOff = NULL;
	//	return false;
	//}
	//else
	//{
	//	pVarPtr->pOff = m_mapPVar[sVarName];
	//	return true;
	//}

	MapTempVar::iterator itr = m_mapPVar.find(sVarName);	
	if(itr == m_mapPVar.end())
	{
		pVarPtr->lng = 0;
		return false;
	}
	else
	{
		pVarPtr->lng = itr->second;
		return true;
	}
}

int32 CTempVarMgrServer::GetVarValue(const string& sVarName)
{
	//���Աָ������2010-12-21
	//if(m_mapPVar.find(sVarName) == m_mapPVar.end())
	//{
	//	stringstream str;
	//	str << sVarName << endl;
	//	GenErr("��ʱ����������", str.str());
	//	//return 0;
	//}
	//return this->*m_mapPVar[sVarName];

	MapTempVar::iterator itr = m_mapPVar.find(sVarName);	
	if(itr == m_mapPVar.end())
	{
		stringstream str;
		str << sVarName << endl;
		GenErr("��ʱ����������", str.str());
		//return 0;
	}
	else if (itr->second >= m_vecPVar.size())
	{
		stringstream str;
		str << itr->second << " >= " << m_vecPVar.size() << endl;
		GenErr("��ʱ�������ʳ�����������", str.str());
	}
	return this->*m_vecPVar[itr->second];
}

int32 CTempVarMgrServer::GetVarValue(UUnitValue pVarPtr)
{
	//���Աָ������2010-12-21
	//if(!pVarPtr.pOff)
	//{
	//	stringstream str;
	//	GenErr("ƫ��ֵΪ�գ���ʱ����������");
	//	//return 0;
	//}
	//return this->*pVarPtr.pOff;

	if(pVarPtr.lng == 0 || pVarPtr.lng >= m_vecPVar.size())
	{
		stringstream str;
		str << pVarPtr.lng << " >= " << m_vecPVar.size() << endl;
		GenErr("��ʱ������������Ϊ0�򳬳���������", str.str());
		//return 0;
	}
	return this->*m_vecPVar[pVarPtr.lng];
}

void CTempVarMgrServer::SetVarValue(const string& sVarName, int32 iValue)
{
	//���Աָ������2010-12-21
	//if(iValue < 0 && sVarName != "ħ����������ֵ")
	//{
	//	stringstream str;
	//	str << sVarName << " = " << iValue << endl;
	//	GenErr("��ʱ��������Ϊ��ֵ", str.str());
	//}
	//this->*m_mapPVar[sVarName] = iValue;

	//���Աָ������2010-12-21
	if(iValue < 0 && sVarName != "ħ����������ֵ")
	{
		stringstream str;
		str << sVarName << " = " << iValue << endl;
		GenErr("��ʱ��������Ϊ��ֵ", str.str());
	}
	this->*m_vecPVar[m_mapPVar[sVarName]] = iValue;
}

string CTempVarMgrServer::GetPassVarName(const string& sVarName)	
{
	string sPassVarName;
	if(sVarName.substr(0, 2) != "��")
	{
		sPassVarName = "��" + sVarName;
		//sPassVarName.insert(0, "��");
		return sPassVarName;
	}
	else
	{
		return sVarName.substr(2);
	}
}

void CTempVarMgrServer::SetDamage(int32 iValue)		
{
	if(iValue < 0)
	{
		stringstream str;
		str << "�˺� = " << iValue << endl;
		GenErr("��ʱ��������Ϊ��ֵ", str.str());
	}
	//SetVarValue(string("�˺�"), iValue);
	//SetVarValue(string("δ����˺�"), iValue);
	m_uSubHP = iValue;
	m_uUnchangeSubHP = iValue;
}
void CTempVarMgrServer::SetBeDamaged(int32 iValue)
{
	if(iValue < 0)
	{
		stringstream str;
		str << "���˺� = " << iValue << endl;
		GenErr("��ʱ��������Ϊ��ֵ", str.str());
	}
	//SetVarValue(string("���˺�"), iValue);
	//SetVarValue(string("��δ����˺�"), iValue);
	m_uBeSubHP = iValue;
	m_uBeUnchangeSubHP = iValue;
}

void CTempVarMgrServer::SetSubMP(int32 iValue)
{
	//SetVarValue(string("����"), iValue);
	m_uSubMP = iValue;
}

void CTempVarMgrServer::SetBeSubMP(int32 iValue)
{
	//SetVarValue(string("������"), iValue);
	m_uBeSubMP = iValue;
}


