#pragma once
#include "CCfgCalcOptrTable.h"
#include "CDynamicObject.h"
#include "TCfgCalcMallocAllocator.h"

#ifdef _WIN32
#pragma warning (push)
#pragma warning (disable:4996)
#endif


//��������

//CExprUnit���ʽԪ����
class CExpression;
class CCfgCalc;
class CCfgRelationDeal;
class CExprUnit
	: public CCfgCalcMallocObject
{
	friend class CExpression;
	friend class CCfgCalc;
	friend class CCfgRelationDeal;
public:
	~CExprUnit()								{}
private:
	CExprUnit():m_eType(eUT_Null),m_eFunType(eVT_Unknow)			{}
	CExprUnit(double value)						{Set(value, eUT_Number);}
	CExprUnit(uint32 value)						{Set(value);}
	CExprUnit(uint32 value, EUnitType type)		{Set(value, type);}

	CExprUnit& operator =(double value)	{Set(value, eUT_Number); return *this;}
	CExprUnit& operator =(uint32 value)	{Set(value); return *this;}
	void Set(double value);
	void Set(uint32 value);
	void Set(string* value);
	void Set(double value, EUnitType type);
	void Set(uint32 value, EUnitType type);
	void Set(string* value, EUnitType type);
	void SetType(EUnitType type);
	void SetFunType(EFunType type = eVT_Unknow);					//���ù�������
	void SetTargetType(ECalcTargetType type);
	//void GetFloat();
	//void GetInt();

	UUnitValue	m_Value;
	EUnitType	m_eType;
	EFunType	m_eFunType;
	ECalcTargetType	m_eTargetType;
};



//CPreUnitԤ������ʽԪ����
class CPreUnit
	: public CCfgCalcMallocObject
{
	friend class CExpression;
	friend class CCfgCalc;
private:
	string		str;
	EUnitType	type;
	inline void	clear()							{str.clear(); type = eUT_Null;}
	inline bool	empty()							{return type == eUT_Null;}
	CPreUnit():type(eUT_Null)					{str.clear();}
	inline void Set(const string& s, EUnitType t)		{str = s;	type = t;}
};

//VecPreUnitԤ������ʽ��
typedef vector<CPreUnit*, TCfgCalcMallocAllocator<CPreUnit*> >		VecPreUnit;
typedef vector<double, TCfgCalcMallocAllocator<double> >			VecArgs;

//enum EFighterTypeIndex{eFTI_Gift, eFTI_Attr, eFTI_Temp};

//Expression���ʽ��
class CTalentHolder;
//class CFighterDictator;
//class CFighterDirector;
class CFighterNull;
class CFighterClient;
class CSkillInstServer;
class CSkillInstNull;
class CCfgCalc;
class CExpression
	: public CCfgCalcMallocObject
{
	friend class CCfgCalc;
	friend class CCfgRelationDeal;
private:
	typedef vector<CExprUnit, TCfgCalcMallocAllocator<CExprUnit> >		VecExprUnit;
	typedef vector<VecOpnd*, TCfgCalcMallocAllocator<VecOpnd*> >			VecVecOpnd;
	typedef vector<COptrUnit, TCfgCalcMallocAllocator<COptrUnit> >		VecOptrUnit;
	typedef vector<COpndUnit, TCfgCalcMallocAllocator<COpndUnit> >		VecOpndUnit;

public:
	~CExpression();

private:
	CExpression(const string& str, const CCfgCalc* pCfgCalc);
	CExpression(double dblValue, const CCfgCalc* pCfgCalc);
	CExpression(const CExpression& srcExpr, const CCfgCalc* pCfgCalc);

	template<typename FighterType>
	double			Eval(const FighterType* pFighter[], uint32 index = 0);

	double			Eval(uint32 index = 0)
	{
		const CFighterNull* pFighter[] = {(CFighterNull*)NULL, (CFighterNull*)NULL};
		Eval(pFighter, index);
		return 0;
	}

	void			Test();

private:
	void			Input(const string& str, VecArgs* pVecArgs);		//������ʽ���ַ���
	void			Input(double dblValue);								//ֱ����һ����ֵ����һ�����ʽ
	void			GetCharType(TCHAR c, EUnitType &type);				//��ȡ�����ַ�����
	uint32			Separate();											//���ʽԤ�����һ���������ַ���Ԫ��
	void			Combine(stringstream& str);							//�ϲ��ַ���Ԫ�أ�Separate()�������
	void			Convert();											//���ʽԤ����ڶ��������ַ���Ԫ������ת���ɱ��ʽ
	string&			GetVarName(uint32 index);							//���±��ȡ����������ʱ���ã�
	EFunType		GetVarType(string& varName);						//��ȡ��������
	ECalcTargetType	GetTargetType(string& varName);						//��ȡĿ������

	template<typename FighterType>
	double			GetVarValue(UUnitValue varHandle, EFunType& vartype, const FighterType* pFighter[],
		ECalcTargetType eTargetType, uint32 index);
	//��ȡ������ֵ

	pair<bool, double>	GetArgValue(uint32 index);						//��ȡ������ֵ

	template<typename FighterType>
	pair<bool, double>	GetTalentValue(const string& varName, const FighterType* pFighter);		//��ȡ�츳��ֵ

	template<typename FighterType>
	pair<bool, double>	GetMasterTalentValue(const string& varName, const FighterType* pFighter);		//��ȡ�����츳��ֵ

	template<typename FighterType>
	pair<bool, double>	GetAttrValue(uint32 uVarID, const FighterType* pFighter);				//��ȡ�������Ե�ֵ

	template<typename FighterType>
	pair<bool, double>	GetMasterAttrValue(uint32 uVarID, const FighterType* pFighter);				//��ȡ�������Ե�ֵ

	template<typename FighterType>
	pair<bool, double>	GetServantAttrValue(uint32 uVarID, const FighterType* pFighter);				//��ȡ�������Ե�ֵ

	template<typename FighterType>
	pair<bool, double>	GetTempValue(UUnitValue uVarPtr, const FighterType* pFighter);		//��ȡ��ʱ��ֵ������û�з��������������ĵ������һ�ɷ���<false, 0.0>��

	template<typename FighterType>
	pair<bool, double>	GetMasterTempValue(UUnitValue uVarPtr, const FighterType* pFighter);		//��ȡ��ʱ��ֵ������û�з��������������ĵ������һ�ɷ���<false, 0.0>��

	template<typename FighterType>
	double			Operate0Eyes(uint32 theta, const FighterType* pFighter[], ECalcTargetType eTargetType);

	template<typename FighterType>
	double			Operate1Eyes(uint32 theta, const COpndUnit& opnd_b, const FighterType* pFighter[],
		ECalcTargetType eTargetType, uint32 index);
	//����һԪ����������Ĳ�������ͨ�ĺ���Ҳ��һԪ���ӣ�

	COpndUnit		Operate2Eyes(const COpndUnit& opnd_a, uint32 theta, const COpndUnit& opnd_b);
	//�����Ԫ������Ĳ���

	bool			SetVarHandle(string& sName, CExprUnit& exprunit);

	template<typename FighterType>
	const FighterType*	GetCalcFighter(const FighterType* pFighter[], ECalcTargetType eTargetType);

	string			m_sExprStr;											//���ڱ�������ı��ʽ�ַ���
	VecPreUnit		m_vecPreExpr;										//���ڱ��������ַ���Ԫ�����еı��ʽ
	VecExprUnit		m_vecExpr;											//���ڱ������л������ͻ��ı��ʽ
	VecArgs*		m_pVecArgs;											//���ڱ���������ʽ�Ĳ�������
	VecVecOpnd		m_vecOpndArray;										//���ڱ��涺�Ų�������������в�����ֵ������
	//CTalentHolder*	m_pTalentHolder;
	const CCfgCalc*				m_pCfgCalc;

	//ֻ��Eval���õĳ�Ա
	VecOptrUnit Optr;
	VecOpndUnit Opnd;
};


//CCfgCalc�������
typedef vector<CExpression*, TCfgCalcMallocAllocator<CExpression*> >			VecExprs;
typedef vector<string*, TCfgCalcMallocAllocator<string*> >					VecString;
//class CFighterMediator;
class CCfgCalc
	: public virtual CDynamicObject
	, public CCfgCalcMallocObject
{
	friend class CExpression;
	friend class CCfgRelationDeal;
public:
	CCfgCalc();
	~CCfgCalc();
	CCfgCalc(int32 intValue);
	CCfgCalc(double dblValue);
	CCfgCalc(const string& str);
	CCfgCalc(const CCfgCalc& srcCfgCalc);
	void					InputString(const string& str);					//����������ʽ�ַ���

	//��ȡ���ʽ�ĸ�����ֵ
	template <typename FighterType>
	double					GetDblValue(const FighterType* pFighter, uint32 index = 0) const
	{
		return GetDblValue(pFighter, pFighter, index);
	}

	template <typename FighterType>
	double					GetDblValue(const FighterType* pFighterSelf, const FighterType* pFighterTarget, uint32 index = 0) const;

	//��ȡ���ʽ�����ͽ��ֵ
	template <typename FighterType>
	int32					GetIntValue(const FighterType* pFighter, uint32 index = 0) const
	{
		return GetIntValue(pFighter, pFighter, index);
	}

	template <typename FighterType>
	int32					GetIntValue(const FighterType* pFighterSelf, const FighterType* pFighterTarget, uint32 index = 0) const;

	double GetDblValue(uint32 index = 0) const
	{
		return GetDblValue((CFighterNull*)NULL, index);
	}

	int32 GetIntValue(uint32 index = 0) const
	{
		return GetIntValue((CFighterNull*)NULL, index);
	}



	const string&			GetString() const;								//��ȡ���ַ������ʱ�������ַ���
	const string&			GetString(uint32 index) const;					//��ȡ���ַ������ʱ�ĵ�index+1���ַ���
	const TCHAR*				GetChars(uint32 index) const	{return GetString(index).c_str();}	//��ȡ���ַ������ʱ�ĵ�index+1���ַ������ַ�����

	const uint32			GetStringCount() const;							//��ȡ���ַ������ʱ���ַ���������
	const uint32			GetValueCount() const;							//��ȡ���ʽ���ʱ�Ľ��ֵ������

	void					SetTypeExpression() const;						//ǿ����������Ϊ���ʽ
	void					SetTypeSingleString() const;					//ǿ����������Ϊ���ַ���
	void					SetTypeMultiString() const;						//ǿ����������Ϊ���ַ���

	inline EExprType		GetExprType() const		{return m_eExprType;}	//��ȡ���ʽ������
	inline EStrType			GetStrType() const		{return m_eStrType;}	//��ȡ�ַ���������
	const bool				ExprIsEmpty() const		{return m_eExprType == eET_Empty;}
	const bool				StrIsEmpty() const		{return m_eStrType == eST_String && m_sString.empty();}
	const bool				IsEmpty() const			{return m_eExprType == eET_Empty || m_eExprType != eET_Empty && m_sString.empty();}

	bool					IsSingleNumber() const;								//�����ж��Ƿ�Ϊ�����֡���������������ܸ��ӣ�������Ҫ�ڳ�ʼ���Ͷ����ñ�����ĵط���

	void					Test();

	const string&			GetTestString()	const	{return m_sString;}		//�����ã����ڻ�ȡ�κ�����µ�m_sString

	void					SetStringSplitter(TCHAR cSplitter = ',') const	{m_cStringSplitter = cSplitter;}

	bool					CalcNeedTarget() const	{return m_bCalcNeedTarget;}
	bool					IsConstValue() const	{return m_bIsConstValue;}

private:
	void					Exuviate(const string& str);					//ȥ���ַ�������Excel�����txt�ļ�ʱ������ӵ�˫����
	void					Parse() const;									//������ÿ�����ʽ
	void					ParseString() const;							//������ÿ���ַ���
	void					GenPermitChangeExprTypeExp() const;				//�׳���ֹ�ı����͵Ĵ���

	mutable EExprType		m_eExprType;
	mutable EStrType		m_eStrType;
	mutable VecExprs		m_vecExprs;
	mutable string			m_sString;
	mutable VecString		m_vecString;
	mutable VecArgs			m_vecArgs;
	mutable TCHAR			m_cStringSplitter;
	mutable bool			m_bCalcNeedTarget;
	mutable bool			m_bIsConstValue;
};











class CFighterNull
	: public CCfgCalcMallocObject
{
	friend class CExpression;
	friend class CCfgCalc;
private:
	CTalentHolder* GetTalentHolder() const 	{return NULL;}
	uint32 CppGetLevel() const	{return 0;}
};

#ifdef _WIN32
#pragma warning (pop)
#endif 

