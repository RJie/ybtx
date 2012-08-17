#pragma once
#include "TCfgCalcMallocAllocator.h"

#define EYES1_GRADE		50
#define BRACKET_GRADE	100
//#define VARIABLE_X		4294967295

//��������ö�ٱ��
enum EOptrID
{
	//�߽�
	eOI_Shell,
	//����
	eOI_LPBr,		eOI_LSBr,		eOI_RPBr,		eOI_RSBr,
	//��Ԫ����
	eOI_Start2Eyes,
	eOI_Add,		eOI_Sub,		eOI_Mul,		eOI_Div,		eOI_Pow,
	eOI_EQ,			eOI_UE,			eOI_GT,			eOI_GE,			eOI_LT,
	eOI_LE,			eOI_And,		eOI_Xor,		eOI_Or,			eOI_Comma,
	eOI_DivSptZero,
	//һԪ����
	eOI_Start1Eyes,
	eOI_Not,
	eOI_Rand,
	eOI_Randf,		eOI_IfElse,		eOI_ExistState,	eOI_ExistMagicState,	eOI_ExistTriggerState,
	eOI_ExistDamageChangeState,	eOI_ExistSpecialState,eOI_StateCount,eOI_TriggerCount,eOI_StateLeftTime,
	eOI_Floor,		eOI_Ceil,		eOI_Distance,	eOI_TargetIsNPC,	eOI_CharaLevel,
	eOI_IsActiveSkill,eOI_CurRlserStateCount,
	//����
	eOI_End
};

//ȡ�������º�����֧�֣���ͬ�ȹ��ܵı���
/*eOI_VarCfg,		eOI_VarGift,	eOI_VarMasterGift,eOI_VarTemp,	eOI_VarMasterTemp,
eOI_VarAttr,	eOI_VarMasterAttr,eOI_VarServantAttr,*/

//���������ַ���
const string g_sOptrStr[] =
{
	"#",
	"(",			"[",			")",			"]",
	"#2",
	"+",			"-",			"*",			"/",			"^",
	"==",			"!=",			">",			">=",			"<",
	"<=",			"&&",			"^^",			"||",			",",
	"//",			
	"#1",
	"!",
	"rand",
	"randf",		"ifelse",		"existstate",	"existmagicstate",		"existtriggerstate",
	"existdamagechangestate",	"existspecialstate","statecount","triggercount","statelefttime",
	"floor",		"ceil",			"distance",		"targetisnpc",	"fighterlevel",
	"isactiveskill","currlserstatecount",
	"#e"
};

//ȡ�������º�����֧�֣���ͬ�ȹ��ܵı���
/*"varcfg",		"vargift",		"varmastergift","vartemp",		"varmastertemp",
"varattr",		"varmasterattr","varservantattr",*/


//�����������ȼ�
const int32 g_uOptrGrade[] =
{
	0,		
	BRACKET_GRADE,	BRACKET_GRADE,	BRACKET_GRADE,	BRACKET_GRADE,			
	0,		
	12,				12,				13,				13,				14,
	10,				10,				11,				11,				11,
	11,				5,				4,				3,				2,
	13,
	0
};

//���ʽ����
enum EExprType
{
	eET_Empty,
	eET_Single,
	eET_Multiple,
	eET_Args,
};

//�ַ�������
enum EStrType
{
	eST_Null,
	eST_Expression,
	eST_String,
	eST_MutliString,
};

//�ʷ���������
enum EUnitType
{
	eUT_Null,		//��ʼֵ
	eUT_Number,		//����
	eUT_Ltword,		//��ĸ���
	eUT_Symbol,		//����
	eUT_String,		//�ַ���
	eUT_Array,		//�ö��Ÿ����Ĳ�����
	eUT_Other,		//����
};

//ִ�й�������
enum EFunType
{
	eVT_Unknow,		//δ֪
	eVT_Float,		//������
	eVT_Integer,	//����
	eVT_Operator,	//��������
	eVT_Arg,		//��������	
	eVT_Talent,		//�츳����
	eVT_MasterTalent,	//�����츳����
	eVT_Attr,		//���Ա���
	eVT_MasterAttr,	//�������Ա���
	eVT_ServantAttr,//�������Ա���
	eVT_Temp,		//��ʱ����
	eVT_MasterTemp,	//������ʱ����
	eVT_Cfg,		//ȫ�ֱ���
	eVT_End,		//��mapѭ��������־��������
};

//�����ʽԪ�����ͱ�ʾ��ʽ
/*			�ʷ���������	ִ�й�������
����		eUT_Number		eVT_Integer
������		eUT_Number		eVT_Float
�ַ���		eUT_String
�����		eUT_Symbol		eVT_Operate
����		eUT_Ltword		eVT_Operate
��������	eUT_Ltword		eVT_Talent
�츳����	eUT_Ltword		eVT_Talent
�����츳����	eUT_Ltword		eVT_MasterTalent
���Ա���	eUT_Ltword		eVT_Attr
��ʱ����	eUT_Ltword		eVT_Temp
ȫ�ֱ���	eUT_Ltword		eVT_Cfg
����������	eUT_Array
*/

//���������ַ���
const string g_sVarTypeStr[] =
{
	"",
	"",
	"",
	"",
	"����",
	"�츳",
	"�����츳",
	"����",
	"��������",
	"��������",
	"��ʱ",
	"������ʱ",
	"ȫ��",
	"#e"
};

enum ECalcTargetType
{
	eCTT_Self,			//����
	eCTT_Target,		//Ŀ��
	eCTT_Master,		//����
	eCTT_End,			//������־
};

const string g_sCalcTargetTypeStr[] = 
{
	"����",
	"Ŀ��",
	"����",
	"#e"
};

//��������Ԫ��
class COptrUnit			//��������
	: public CCfgCalcMallocObject
{
public:
	uint32	theta;
	uint32	eyes;
	uint32	grade;
	ECalcTargetType	targettype;
	COptrUnit(uint32 t, uint32 e, uint32 g = 0, ECalcTargetType target = ECalcTargetType(0));
	void Set(uint32 t, uint32 e, uint32 g, ECalcTargetType target = ECalcTargetType(0)) {
		theta = t; eyes = e; grade = g; targettype = target;}

};

class COpndUnit;
class VecOpnd : public vector<COpndUnit, TCfgCalcMallocAllocator<COpndUnit> >		
	, public CCfgCalcMallocObject
{

};

class CTempVarMgrServer;

//����ֵ����������
union UUnitValue
{
	double		flt;
	uint32		lng;
	string*		pStr;
	VecOpnd*	pArr;
	//���Աָ������2010-12-21
	//int32 CTempVarMgrServer::*		pOff;

};

//����ֵԪ��
class COpndUnit			
	: public CCfgCalcMallocObject
{
public:
	UUnitValue	value;
	EUnitType	type;
	COpndUnit();
	COpndUnit(double v, EUnitType t = eUT_Null) {Set(v,t);}
	COpndUnit(VecOpnd* v, EUnitType t = eUT_Null) {Set(v,t);}
	void Set(double v, EUnitType t = eUT_Null) {value.flt = v; type = t; }
	void Set(uint32 v, EUnitType t = eUT_Null) {value.lng = v; type = t; }
	void Set(string* v, EUnitType t = eUT_Null) {value.pStr = v; type = t; }
	void Set(VecOpnd* v, EUnitType t = eUT_Null) {value.pArr = v; type = t; }
	void Set(UUnitValue v, EUnitType t = eUT_Null) {value = v; type = t; }
	void Set(const COpndUnit& v) {value = v.value; type = v.type;}
};

typedef map<string, EOptrID, less<string>, TCfgCalcMallocAllocator<pair<string, EOptrID> > >			MapStr2Optr;
typedef map<string, EFunType, less<string>, TCfgCalcMallocAllocator<pair<string, EFunType> > >			MapStr2VarType;
typedef map<string, ECalcTargetType, less<string>, TCfgCalcMallocAllocator<pair<string, ECalcTargetType> > >	MapStr2CalcTargetType;

//���ʽ�õľ�̬ӳ���
class COptrTbl
	: public CCfgCalcMallocObject
{
public:
	static uint32				OptrPrecede(const COptrUnit& optr_a, uint32 b, uint32 grade_b);
	//�����������ȼ��Ƚ�
	static EOptrID				GetOptrID(const string& str) {return m_mapOptrNo[str];}
	//��ȡ��������ID
	static MapStr2Optr			m_mapOptrNo;						//��������map
	static uint32				m_uOptrEyes[eOI_End];				//��������Ŀ������
	static MapStr2VarType		m_mapVarTypeNo;						//��������map
	static MapStr2CalcTargetType m_mapCalcTargetTypeNo;				//Ŀ������map
private:
	static bool					Init();
	static bool					__init;
};

