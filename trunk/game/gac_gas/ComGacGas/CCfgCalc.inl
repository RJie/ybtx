#pragma once
#include "stdafx.h"
#include "CCfgCalc.h"
#include "CTalent.h"
#include "CCfgCalcFunction.h"
#include "ExpHelper.h"
#include <iostream>
#include <cmath>
#include <iostream>
#include "BaseHelper.h"
//#include "TSqrAllocator.inl"

//template <typename FighterType>
//pair<bool, double> CExpression::GetAttrValue(const string& varName, FighterType* pFighter)
//{
//	pair<bool, uint32> pr = CAttrVarMap::GetVarId(varName);
//	if(pr.first)
//	{
//		return make_pair(true, double(pFighter->CppGetPropertyValue(pr.second)));
//	}
//	else
//	{
//		return make_pair(false, 0.0);
//	}
//}



template<typename FighterType>
double CExpression::GetVarValue(UUnitValue varHandle, EFunType& vartype, const FighterType* pFighter[],
	ECalcTargetType eTargetType, uint32 index)
{
	//����ȡ������ֵ
	switch(vartype)
	{
	case eVT_Arg:
		if(m_pVecArgs == NULL)
		{
			stringstream ExpStr;
			Combine(ExpStr);
			ExpStr << "ָ��VecArgs��ָ��Ϊ�գ����д������X�ı��ʽȱ�ٴ������\n";
			cout << ExpStr.str();
			//GenErr(ExpStr.str());
			return 0.0;
		}
		else if(index >= m_pVecArgs->size())
		{
			if(m_pVecArgs->size() == 0)
			{
				return double(index+1);
			}
			else
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "�±�" << index << "������������VecArgs������" << m_pVecArgs->size() << "\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
		}
		return GetArgValue(index).second;
	case eVT_Talent:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��Talent pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetTalentValue(*varHandle.pStr, pCalcFighter).second;

		}
	case eVT_MasterTalent:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��MasterTalent pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetMasterTalentValue(*varHandle.pStr, pCalcFighter).second;
		}
	case eVT_Attr:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��Attr pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetAttrValue(varHandle.lng, pCalcFighter).second;
		}
	case eVT_MasterAttr:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��MasterAttr pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetMasterAttrValue(varHandle.lng, pCalcFighter).second;
		}
	case eVT_ServantAttr:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��ServantAttr pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetServantAttrValue(varHandle.lng, pCalcFighter).second;
		}
	case eVT_Temp:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��Temp pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetTempValue(varHandle, pCalcFighter).second;
		}
	case eVT_MasterTemp:
		{
			const FighterType* pCalcFighter = GetCalcFighter(pFighter, eTargetType);
			if(pCalcFighter == NULL)
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "ָ��MasterTemp pFighter��ָ��Ϊ��\n";
				cout << ExpStr.str();

				//GenErr(ExpStr.str());
				return 0.0;
			}
			return GetMasterTempValue(varHandle, pCalcFighter).second;
		}
	case eVT_Cfg:
		{
			pair<bool, CCfgGlobal*> resultCfgGlobal = CCfgGlobal::GetCfgValue(varHandle.lng);
			if(resultCfgGlobal.first) return resultCfgGlobal.second->Get(pFighter[eCTT_Self], pFighter[eCTT_Target], index);		//ȫ�ֱ�����eTargetTypeû��ϵ
			else return 0.0;
		}
	case eVT_Unknow:
		{
			//pair<bool, CCfgCalc*> resultCfgCalc = CCfgGlobal::GetCfgValue(varName);
			//if(resultCfgCalc.first) return resultCfgCalc.second->GetDblValue(pFighter, index);
			//pair<bool, double> result;
			//result = GetTalentValue(varName, pFighter->GetTalentHolder());
			//if(result.first) return result.second;
			//result = GetAttrValue(varName, pFighter);
			//if(result.first) return result.second;
			//result = GetTempValue(varName, pFighter);
			//if(result.first) return result.second;
			stringstream ExpStr;
			Combine(ExpStr);
			ExpStr << "����������" << *varHandle.pStr;
			GenErr(ExpStr.str());
			return 0.0;
		}
	default:
		{
			stringstream ExpStr;
			Combine(ExpStr);
			ExpStr << "GetVarValue�����ڱ������ʹ���" << vartype << "\n";
			GenErr(ExpStr.str());
			return 0.0;
		}
	}
}

template<typename FighterType>
double CExpression::Operate0Eyes(uint32 theta, const FighterType* pFighter[], ECalcTargetType eTargetType)
{
	switch(theta)
	{
	case eOI_Distance:
		return (double)CCfgGlobal::Distance(pFighter[eCTT_Self], pFighter[eCTT_Target]);
	case eOI_TargetIsNPC:
		return (double)CCfgGlobal::TargetIsNPC(pFighter[eCTT_Target]);
	case eOI_CharaLevel:
		{
			const FighterType* pFighterGet = GetCalcFighter(pFighter, eTargetType);
			if(pFighterGet)
			{
				//return 0.0;
				return pFighterGet->CppGetLevel();
			}
			else
			{
				return 0.0;
			}
		}
	default:
		{
			stringstream ExpStr;
			Combine(ExpStr);
			ExpStr << "���ʽ���в�֧�ֵ���Ŀ�������" << g_sOptrStr[theta].c_str() << "\n";
			GenErr(ExpStr.str());
			return 0.0;
		}
	}
}

template<typename FighterType>
double CExpression::Operate1Eyes(uint32 theta, const COpndUnit& opnd_b, const  FighterType* pFighter[],
	ECalcTargetType eTargetType, uint32 index)
{
	switch(theta)
	{
	case eOI_Add:
		Ast(opnd_b.type == eUT_Number);
		return opnd_b.value.flt;
	case eOI_Sub:
		Ast(opnd_b.type == eUT_Number);
		return -opnd_b.value.flt;
	case eOI_Not:
		Ast(opnd_b.type == eUT_Number);
		return !opnd_b.value.flt;
	//case eOI_VarCfg:
	//	return CCfgGlobal::GetCfgValue(*opnd_b.value.pStr).second->Get(pFighter[eCTT_Self], pFighter[eCTT_Target], index);
	//case eOI_VarGift:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
	//	return GetTalentValue(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType)).second;
	//case eOI_VarMasterGift:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
	//	return GetMasterTalentValue(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType)).second;
	//case eOI_VarTemp:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
	//	return GetTempValue(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType)).second;
	//case eOI_VarMasterTemp:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
	//	return GetMasterTempValue(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType)).second;
	//case eOI_VarAttr:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
	//	return GetAttrValue(opnd_b.value.lng, GetCalcFighter(pFighter, eTargetType)).second;
	//case eOI_VarMasterAttr:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
	//	return GetMasterAttrValue(opnd_b.value.lng, GetCalcFighter(pFighter, eTargetType)).second;
	//case eOI_VarServantAttr:
	//	Ast(opnd_b.type == eUT_String && GetCalcFighter(pFighter, eTargetType) != NULL);
		return GetServantAttrValue(opnd_b.value.lng, GetCalcFighter(pFighter, eTargetType)).second;
	case eOI_Rand:
		Ast(opnd_b.type == eUT_Array);
		return CCfgGlobal::Rand((*opnd_b.value.pArr)[0].value.flt, (*opnd_b.value.pArr)[1].value.flt);
	case eOI_Randf:
		Ast(opnd_b.type == eUT_Array);
		return CCfgGlobal::Randf((*opnd_b.value.pArr)[0].value.flt, (*opnd_b.value.pArr)[1].value.flt);
	case eOI_IfElse:
		Ast(opnd_b.type == eUT_Array && opnd_b.value.pArr->size() == 3);
		return CCfgGlobal::IfElse((*opnd_b.value.pArr)[0].value.flt, (*opnd_b.value.pArr)[1].value.flt, (*opnd_b.value.pArr)[2].value.flt);
	case eOI_ExistState:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::ExistState(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	case eOI_ExistMagicState:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::ExistMagicState(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	case eOI_ExistTriggerState:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::ExistTriggerState(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	case eOI_ExistDamageChangeState:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::ExistDamageChangeState(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	case eOI_ExistSpecialState:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::ExistSpecialState(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	case eOI_StateCount:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::StateCount(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	case eOI_CurRlserStateCount:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::CurRlserStateCount(*opnd_b.value.pStr, pFighter[eCTT_Self], GetCalcFighter(pFighter, eTargetType));
	case eOI_TriggerCount:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::TriggerCount(*opnd_b.value.pStr, pFighter[eTargetType]);
	case eOI_StateLeftTime:
		Ast(opnd_b.type == eUT_String);
		//����ע�⣬���StateLeftTimeҪ��ȡ���˰�װ�Ŀɵ���ħ��״̬����ڶ�������Ҫ���ɰ�װ�ߣ���Ҫ���ǰ�װ���ڱ��ʽ��ı�ʾ��ʽ
		return (double)CCfgGlobal::StateLeftTime(*opnd_b.value.pStr, pFighter[eCTT_Self], GetCalcFighter(pFighter, eTargetType));
	case eOI_Floor:
		Ast(opnd_b.type == eUT_Number);
		return (double)floor(opnd_b.value.flt);
	case eOI_Ceil:
		Ast(opnd_b.type == eUT_Number);
		return (double)ceil(opnd_b.value.flt);
	case eOI_Distance:
		Ast(opnd_b.type == eUT_Number);
		return (double)(CCfgGlobal::Distance(pFighter[eCTT_Self], pFighter[eCTT_Target]) <= opnd_b.value.flt);
	case eOI_IsActiveSkill:
		Ast(opnd_b.type == eUT_String);
		return (double)CCfgGlobal::IsActiveSkill(*opnd_b.value.pStr, GetCalcFighter(pFighter, eTargetType));
	default:
		{
			stringstream ExpStr;
			Combine(ExpStr);
			ExpStr << "���ʽ���в�֧�ֵĵ�Ŀ�������" << g_sOptrStr[theta].c_str() << "\n";
			GenErr(ExpStr.str());
			return 0.0;
		}
	}
}

template <typename FighterType>
double CExpression::Eval(const FighterType* pFighter[], uint32 index)
{
	if(m_vecExpr.size() == 2)
	{
		switch (m_vecExpr[0].m_eType)
		{
		case eUT_Number:
			return m_vecExpr[0].m_Value.flt;
		case eUT_Ltword:
			//m_pTalentHolder = pTalentHolder;
			return GetVarValue(m_vecExpr[0].m_Value, m_vecExpr[0].m_eFunType, pFighter, 
				m_vecExpr[0].m_eTargetType, index);
		default:
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "���ʽԪ�����ʹ���";
				GenErr(ExpStr.str());
				return 0.0;
			}
		}
	}

	//m_pTalentHolder = pTalentHolder;
	//m_pSkillInst = pSkillInst;

	//stack<COptrUnit> Optr;
	//stack<COpndUnit> Opnd;
	if(!Optr.empty())
		Optr.clear();
	if(!Opnd.empty())
		Opnd.clear();
	CExprUnit cUnit, prev_cUnit;
	COpndUnit a, b;
	UUnitValue c;
	COpndUnit OpndUnit;
	size_t i = 0;
	uint32 grade = 0;
	uint32 curOptrEyes;
	VecExprUnit& expr = m_vecExpr;

	COptrUnit OptrUnit(eOI_Shell, 2, grade);
	Optr.push_back(OptrUnit);


	prev_cUnit.Set(uint32(eOI_Shell), eUT_Symbol);			//����ǰ�÷�
	cUnit = expr[i++];
	c = cUnit.m_Value;

	while (!(cUnit.m_eType == eUT_Symbol && c.lng == eOI_Shell) || Optr.back().theta != eOI_Shell)
	{ 
		switch(cUnit.m_eType)
		{
		case eUT_Number:										//���������
			OpndUnit.Set(c, eUT_Number);
			Opnd.push_back(OpndUnit);
			prev_cUnit = cUnit;
			//prev_cUnit.SetFunType();							//Ŀǰ��ֵ����δ���ָ��������
			cUnit = expr[i++];
			c = cUnit.m_Value;
			break;
		case eUT_String:										//������ַ���
			OpndUnit.Set(c, eUT_String);
			Opnd.push_back(OpndUnit);
			prev_cUnit = cUnit;
			cUnit = expr[i++];
			c = cUnit.m_Value;
			break;
		case eUT_Ltword:										//�������ĸ���
			if(cUnit.m_eFunType != eVT_Operator)
			{													//����Ǳ���
				curOptrEyes = 0;

				//ע1
				prev_cUnit.Set(GetVarValue(c, cUnit.m_eFunType, pFighter, cUnit.m_eTargetType, index));	//������Կ����ڵ�һ�μ���ʱ����eVT_Unknow�ı�������
				OpndUnit.Set(prev_cUnit.m_Value.flt, eUT_Number);
				Opnd.push_back(OpndUnit);

				prev_cUnit.m_eType = eUT_Number;
				prev_cUnit.SetFunType();						//Ŀǰ��ֵ����δ���ָ����С��
				cUnit = expr[i++];
				c = cUnit.m_Value;
				continue;
				break;
			}
			curOptrEyes = COptrTbl::m_uOptrEyes[c.lng];
			{
				uint32 exprValue = expr[i].m_Value.lng;
				if(curOptrEyes == 0 || curOptrEyes == 1 &&
					(expr[i].m_eType == eUT_Symbol && exprValue != eOI_LPBr && exprValue != eOI_LSBr) ||
					(expr[i].m_eType == eUT_Ltword && expr[i].m_eFunType == eVT_Operator && COptrTbl::m_uOptrEyes[exprValue] == 2))
				{	//��Ŀ��ĸ������ӵ���һ����Ԫ��Ϊ�������ŷ��Ż�˫Ŀ��ĸ������ӣ���תΪ��Ŀ����
					//��Ŀ��ĸ������ӣ�ֻ����ĸ���������Ŀ�����Ų�������Ŀ��
					curOptrEyes = 0;

					//ע2�������д����ע1������д�������ԣ���Ϊprev_cUnit.m_cUnit���ᱻ�õ�������ᱻ�õ�����Ӧ�ø���ʹ����Ҫ��������ֵ��������ǰ����Ϣ������������д��
					OpndUnit.Set(Operate0Eyes(c.lng, pFighter, cUnit.m_eTargetType), eUT_Number);
					Opnd.push_back(OpndUnit);
					prev_cUnit = cUnit;

					prev_cUnit.m_eType = eUT_Number;
					prev_cUnit.SetFunType();						//Ŀǰ��ֵ����δ���ָ����С��
					cUnit = expr[i++];
					c = cUnit.m_Value;
					continue;
				}
			}
		case eUT_Symbol:										//����ǲ������ӣ����������ͷ��ţ�
			switch(c.lng)
			{
			case eOI_LPBr:
			case eOI_LSBr:										//�����������
				grade += BRACKET_GRADE;
				cUnit = expr[i++];
				c = cUnit.m_Value;
				break;
			case eOI_RPBr:										//�����������
			case eOI_RSBr:
				grade -= BRACKET_GRADE;
				if(grade < 0)
				{
					stringstream ExpStr;
					Combine(ExpStr);
					ExpStr << "���ʽ���Ų�ƥ��\n";
					if(!m_vecOpndArray.empty())
						ClearVector(m_vecOpndArray);
					Optr.clear();
					Opnd.clear();
					GenErr(ExpStr.str());
					return 0.0;
				}
				cUnit = expr[i++];
				c = cUnit.m_Value;
				break;
			default:
				curOptrEyes = COptrTbl::m_uOptrEyes[c.lng];

				if(curOptrEyes == 1 || (prev_cUnit.m_eType != eUT_Number && prev_cUnit.m_eType != eUT_String))		//��һ�������ŵ�Ԫ�Ƿ��Ż���ʼ�ţ���ǰ�����Ϊ��Ŀ������� ��Ŀ�������һ��
				{
					if (c.lng == eOI_Shell)
					{
						stringstream ExpStr;
						Combine(ExpStr);
						ExpStr << "���ʽδ����������Ԫ�ز���Ϊ����\n";
						if(!m_vecOpndArray.empty())
							ClearVector(m_vecOpndArray);
						Optr.clear();
						Opnd.clear();
						GenErr(ExpStr.str());
						return 0.0;
					}
					curOptrEyes = 1;			//����������curOptrEyes��ʱûʲô���ã��Ժ���ܻ��õ�
					OptrUnit.Set(c.lng, 1, grade, cUnit.m_eTargetType);				//��ǰ�����Ϊ��Ŀ�������ֱ����ջ
					Optr.push_back(OptrUnit);
					prev_cUnit = cUnit;
					cUnit = expr[i++];
					c = cUnit.m_Value;
				}
				else
				{
					switch(COptrTbl::OptrPrecede(Optr.back(), c.lng, grade))
					{
					case 1:			//��������ȼ� ǰ��<����
						OptrUnit.Set(c.lng, 2, grade, cUnit.m_eTargetType);
						Optr.push_back(OptrUnit);
						prev_cUnit=cUnit;
						cUnit=expr[i++];
						c=cUnit.m_Value;
						break;
					case 2:			//��������ȼ� ǰ��>����
						OptrUnit=Optr.back();
						Optr.pop_back();
						switch(OptrUnit.eyes)
						{
						case 1:		//����ǵ�Ŀ�����	��Ŀ������ڶ���
							b = Opnd.back();
							Opnd.pop_back();
							//fResult = Operate1Eyes(OptrUnit.theta, b);
							OpndUnit.Set(Operate1Eyes(OptrUnit.theta, b, pFighter, OptrUnit.targettype,
								index), eUT_Number);
							Opnd.push_back(OpndUnit);
							break;
						case 2:		//�����˫Ŀ�����
							b=Opnd.back();		
							Opnd.pop_back(); 
							a=Opnd.back();		
							Opnd.pop_back();
							//OpndUnit.Set(Operate2Eyes(a, OptrUnit.theta, b), eUT_Number);
							Opnd.push_back(Operate2Eyes(a, OptrUnit.theta, b));
							break;
						}
						break;
					}//switch
				}//if
			}//switch
			break;
		default:
			{
				stringstream ExpStr;
				Combine(ExpStr);
				ExpStr << "�����ı��ʽ��Ԫ����" << cUnit.m_eType << "\n";
				if(!m_vecOpndArray.empty())
					ClearVector(m_vecOpndArray);
				Optr.clear();
				Opnd.clear();
				GenErr(ExpStr.str());
				return 0.0;
			}
		}//switch
	}
	if(!m_vecOpndArray.empty())
		ClearVector(m_vecOpndArray);
	if(Opnd.empty())
	{
		Optr.clear();
		Opnd.clear();
		return 0.0;
	}
	else
	{
		double fRet = Opnd.back().value.flt;
		Optr.clear();
		Opnd.clear();
		return fRet;
	}
}



template <typename FighterType>
double CCfgCalc::GetDblValue(const FighterType* pFighterSelf, const FighterType* pFighterTarget, uint32 index) const
{
	const FighterType* pFighter[] = {pFighterSelf, pFighterTarget};
	switch(m_eStrType)
	{
	case eST_Null:
		m_eStrType = eST_Expression;
		Parse();
	case eST_Expression:
		{
			size_t exprsCount = m_vecExprs.size();
			if(m_eExprType == eET_Empty)
			{
				stringstream ExpStr;
				ExpStr << "�ձ������GetValue��ȡֵ\n";
				GenErr(ExpStr.str());
				//return 0.0;
			}
			else if(exprsCount != 1 && index >= exprsCount)
			{
				//stringstream ExpStr;
				//ExpStr << "GetValue�±�" << index << "�������ʽ������" << exprsCount << "\n";
				//GenErr(ExpStr.str());
				////return 0.0;
				return m_vecExprs[exprsCount - 1]->Eval(pFighter, index);
			}
			else if(exprsCount == 1)
			{
				if(m_eExprType == eET_Args)
				{
					if(index >= m_vecArgs.size())
					{
						if(m_vecArgs.size() > 0)
						{
							stringstream ExpStr;
							ExpStr << "GetValue�±�" << index << "��������������" << m_vecArgs.size() << "\n";
							GenErr(ExpStr.str());
							//return 0.0;
						}
					}
					return m_vecExprs[0]->Eval(pFighter, index);
				}
				else
				{
					return m_vecExprs[0]->Eval(pFighter, index);
				}
			}
			else
			{
				return m_vecExprs[index]->Eval(pFighter, index);
			}
		}
	default:
		GenPermitChangeExprTypeExp();
		return 0.0;
	}
}

template <typename FighterType>
int32 CCfgCalc::GetIntValue(const FighterType* pFighterSelf,const FighterType* pFighterTarget, uint32 index) const
{
	return int32(floor(GetDblValue(pFighterSelf, pFighterTarget, index) + 0.5));
}


