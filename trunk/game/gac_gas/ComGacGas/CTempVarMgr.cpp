#include "stdafx.h"
#include "CTempVarMgr.h"
#include "CCfgCalcOptrTable.h"

set<string>	CTempVarMgr::m_setName;				
CTempVarMgr::SET_VAR_PTR_FUNC CTempVarMgr::m_pFuncSetVarPtr = NULL;

bool CTempVarMgr::__init = CTempVarMgr::Init();

bool CTempVarMgr::Init()
{
	//ע�⣺�������������ĸ�������Сд
	m_setName.insert("�˺�");
	m_setName.insert("���˺�");
	m_setName.insert("δ����˺�");
	m_setName.insert("��δ����˺�");
	m_setName.insert("����");
	m_setName.insert("������");
	m_setName.insert("����");
	m_setName.insert("������");
	m_setName.insert("δ�������");
	m_setName.insert("��δ�������");
	m_setName.insert("ħ����������ֵ");
	return true;
}

bool CTempVarMgr::SetVarPtr(UUnitValue* pVarPtr, const string& sName)
{
	if(m_pFuncSetVarPtr)
	{
		return m_pFuncSetVarPtr(pVarPtr, sName);
	}
	else
	{
		//���Աָ������2010-12-21
		//pVarPtr->pOff = NULL;
		pVarPtr->lng = 0;
		return false;
	}
}



