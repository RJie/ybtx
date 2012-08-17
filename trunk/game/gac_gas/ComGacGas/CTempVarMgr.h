#pragma once
#include <set>

union UUnitValue;

class CTempVarMgr
{
public:
	static bool			ExistVar(const string& sVarName) {return m_setName.find(sVarName) != m_setName.end();}
	static bool			SetVarPtr(UUnitValue* pVarPtr, const string& sName);
	typedef bool (*SET_VAR_PTR_FUNC)(UUnitValue* pVar, const string& sName);
	static void			SetSetVarPtrFunc(SET_VAR_PTR_FUNC pSetFuncVarPtr) {m_pFuncSetVarPtr = pSetFuncVarPtr;}


private:
	//��ʼ��ר��
	static bool			Init();
	static bool			__init;
	static set<string>	m_setName;			//��ʱ����������ӳ��
	static SET_VAR_PTR_FUNC				m_pFuncSetVarPtr;
};

