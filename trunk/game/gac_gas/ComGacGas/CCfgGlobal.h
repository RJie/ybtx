#pragma once
//#include "LoadSkillCommon.h"
//#include "LoadSkillCommon.inl"
//
//class CCfgCalc;
//typedef map<string, CCfgCalc*>					MapGlobalSkillParam;
//
////ȫ�ֱ�����
//class CCfgGlobal
//{
//private:
//	static MapGlobalSkillParam					m_mapVar;
//
//public:
//	//											CCfgGlobal();
//	//											~CCfgGlobal();
//	static bool									LoadConfig(const char* cfgFile);	//�����ñ�
//	static void									UnloadConfig();						//ж�����ñ�
//	static CCfgCalc*							Get(const string& name);			//��ȡȫ�ֱ�����ֵ
//	static pair<bool, CCfgCalc*>				GetCfgValue(const string&name);		//��ȡȫ�ֱ����Ƿ�����Լ�ֵ
//
////private:
////	string										strVarName;
////	CCfgCalc*									pVarValue;
////
////public:
////	string&										GetName();
////	CCfgCalc*									GetValue();
//};
//
////��չ����
//extern int32 Rand(double fMin, double fMax);										//�����������������
//extern double Randf(double fMin, double fMax);										//������������ظ�����
//extern double IfElse(double fIf, double fThen, double fElse);						//����ȡֵ����