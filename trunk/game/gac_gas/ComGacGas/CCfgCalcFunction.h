#pragma once
#include "CDynamicObject.h"
#include "TCfgCalcMallocAllocator.h"

class CCfgCalc;
class CCfgRelationDeal;
class CFighterDirector;
class CFighterDictator;
class CFighterNull;

//ȫ�ֱ�����
class CCfgGlobal
	: public virtual CDynamicObject
	, public CCfgCalcMallocObject
{
	friend class CCfgRelationDeal;
public:
	typedef map<string, CCfgGlobal*, less<string>, TCfgCalcMallocAllocator<pair<string, CCfgGlobal*> > >					MapGlobalSkillParam;
	typedef vector<CCfgGlobal*, TCfgCalcMallocAllocator<CCfgGlobal*> >							VecGlobalSkillParam;

private:
	static MapGlobalSkillParam					m_mapVar;
	static VecGlobalSkillParam					m_vecVar;
	static bool									m_bRandValueIsFixed;
	static int32								m_iRandFixedValue;
	static bool									m_bRandfValueIsFixed;
	static double								m_dRandfFixedValue;

public:
	CCfgGlobal() : m_pCfgCalc(NULL)
	{

	}
	~CCfgGlobal();
	static bool									LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void									UnloadConfig();						//ж�����ñ�
	static pair<bool, CCfgGlobal*>				GetCfgValue(const string&name);		//��ȡȫ�ֱ����Ƿ�����Լ�ֵ
	static bool									ExistCfgGlobal(const string& name);
	static const TCHAR*							GetCalcChars(const TCHAR* sName);
	static uint32								GetVarId(const string& name);
	static pair<bool, CCfgGlobal*>				GetCfgValue(uint32 uId);

	static void									SetRandFixedValue(int32 iValue);
	static void									SetRandfFixedValue(double dValue);
	static void									ClearRandFixedValue();
	static void									ClearRandfFixedValue();

	template<typename FighterType>
	double										Get(const FighterType* pFrom,const FighterType* pTo, uint32 index);			//��ȡȫ�ֱ�����ֵ

	uint32										GetId()		{return m_uId;}

private:
	//static bool									Init();
	//static bool									__init;

	CCfgCalc*									m_pCfgCalc;
	bool										m_bIsArrayConst;
	vector<double>								m_dVecResult;
	deque<bool>									m_bDeqCalculated;
	uint32										m_uId;

public:

	//private:
	//	string										strVarName;
	//	CCfgCalc*									pVarValue;
	//
	//public:
	//	string&										GetName();
	//	CCfgCalc*									GetValue();

	//��չ����
	static int32 Rand(double fStart, double fEnd);										//�����������������
	static double Randf(double fStart, double fEnd);										//������������ظ�����
	static double IfElse(double fIf, double fThen, double fElse);						//����ȡֵ����

	template<typename FighterType>
	static bool ExistMagicState(string& name, const FighterType* pFighter);				//����Ƿ����ĳ����ͨħ��״̬���ͻ��ˣ�

	template<typename FighterType>
	static bool ExistTriggerState(string& name, const FighterType* pFighter);			//����Ƿ����ĳ��������ħ��״̬���ͻ��ˣ�

	template<typename FighterType>
	static bool ExistDamageChangeState(string& name, const FighterType* pFighter);		//����Ƿ����ĳ���˺����ħ��״̬���ͻ��ˣ�

	template<typename FighterType>
	static bool ExistSpecialState(string& name, const FighterType* pFighter);			//����Ƿ����ĳ������ħ��״̬���ͻ��ˣ�

	template<typename FighterType>
	static bool ExistState(string& name, const FighterType* pFighter);			//����Ƿ����ĳ��ħ��״̬���ͻ��ˣ�

	template<typename FighterType>
	static uint32 StateCount(string& name, const FighterType* pFighter);			//��ȡĳ��ħ��״̬�Ĳ������ͻ��ˣ�

	template<typename FighterType>
	static uint32 CurRlserStateCount(string& name, const FighterType* pFrom, const FighterType* pFighter);			//��ȡĳ��ħ��״̬�Ĳ������ͻ��ˣ�

	template<typename FighterType>
	static uint32 TriggerCount(string& name, const FighterType* pFighter);			//��ȡĳ��ħ��״̬�����ô������˺���ֵ�ۼ�ֵ���ͻ��ˣ�

	template<typename FighterType>
	static int32 StateLeftTime(string& name, const FighterType* pFrom, const FighterType* pTo);				//��ȡĳ��ħ��״̬��ʣ��ʱ�䣨�ͻ��ˣ�

	template<typename FighterType>
	static double Distance(const FighterType* pFrom, const FighterType* pTo);						//��pFrom��pTo��ľ���

	template<typename FighterType>
	static bool TargetIsNPC(const FighterType* pTo);

	static bool IsActiveSkill(string& name, const CFighterDirector* pFighter);				//����Ƿ����ĳ����ͨħ��״̬���ͻ��ˣ�
	static bool IsActiveSkill(string& name, const CFighterDictator* pFighter);		//����Ƿ����ĳ����ͨħ��״̬����������
	static bool IsActiveSkill(string& name, const CFighterNull* pFighter);					//����Ƿ����ĳ����ͨħ��״̬���գ�

};

class CAttrVarMap
	: public CCfgCalcMallocObject
{
public:
	typedef map<string, uint32, less<string>, TCfgCalcMallocAllocator<pair<string, uint32> > >					MapAttrVarName2Id;

private:
	static MapAttrVarName2Id					m_mapVarId;
	static bool									InitMapVarId();
	static bool									__init;

public:
	static pair<bool, uint32>					GetVarId(const string& name);
};





