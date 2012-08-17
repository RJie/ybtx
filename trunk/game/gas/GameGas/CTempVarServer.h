#pragma once
#include <set>
#include "CFighterMallocObject.h"
#include "TFighterAllocator.h"

using namespace std;

class CFighterDictator;
union UUnitValue;

//��ʱ����������
class CTempVarMgrServer
	:public CFighterMallocObject
{
public:
	CTempVarMgrServer(const CFighterDictator* pHolder);
	typedef map<string, int32, less<string>, TFighterAllocator<pair<const string, int32> > >	MapImmuneTaskAttack;							//�������񹥻�����
	
	//���Աָ������2010-12-21
	//typedef map<string, int32 CTempVarMgrServer::* , less<string>, TFighterAllocator<pair<string, int32 CTempVarMgrServer::* > > > MapTempVar;
	typedef map<string, uint32> MapTempVar;
	typedef vector<int32 CTempVarMgrServer::*> VecTempVar;

	//�ױ�ֵ��غ���
	int32				GetVarValue(const string& sVarName); 		//�����ֻ�ȡ��ʱ����
	int32				GetVarValue(UUnitValue pVarPtr); 			//��ƫ�ƻ�ȡ��ʱ����
	void				SetVarValue(const string& sVarName, int32 iValue);//������ʱ������ֵ
	static string		GetPassVarName(const string& sVarName);			//ȡ�������������֣�����Ǳ���������ȡ���Ӧ�������������֣�
	static bool			ExistVar(const string& sVarName) {return m_mapPVar.find(sVarName) != m_mapPVar.end();}
	int32				GetDamage()					{return m_uSubHP;}
	int32				GetBeDamaged()				{return m_uBeSubHP;}
	void				SetDamage(int32 iValue);
	void				SetBeDamaged(int32 iValue);
	int32				GetSubMP()					{return m_uSubMP;}
	int32				GetBeSubMP()				{return m_uBeSubMP;}
	void				SetSubMP(int32 iValue);
	void				SetBeSubMP(int32 iValue);

	//����ʱ����غ���
	bool				GetNoSingTime()				{return m_iNoSingTime != 0;}
	void				SetNoSingTime(int32 iCount = 1)	{m_iNoSingTime = iCount;}
	void				SetEternalNoSingTime()		{m_iNoSingTime = -1;}
	void				CancelNoSingTime()			{m_iNoSingTime = 0;}
	void				CountNoSingTime()			{if(m_iNoSingTime > 0) m_iNoSingTime--;}
	bool				GetNoSingTimeSkill(const string & sSkill)	{return m_setNoSingTimeSkill.find(sSkill) != m_setNoSingTimeSkill.end();}
	void				SetNoSingTimeSkill(const string & sSkill)	{m_setNoSingTimeSkill.insert(sSkill);}
	const string&		GetDamageChangeStateName() {return m_strDamageChangeStateName;}
	void				SetDamageChangeStateName(const string & sName) {m_strDamageChangeStateName = sName;}
	void				ClearNoSingTimeSkill()	{m_setNoSingTimeSkill.clear();}
	void				CancelNoSingTimeSkill(const string & sSkill)	{m_setNoSingTimeSkill.erase(sSkill);}

	static bool			SetVarPtr(UUnitValue* pVarPtr, const string& sVarName);

	int32				m_iMopCalcValue;							//ħ����������ֵ
	bool				m_bLockIncreaseHP;
	bool				m_bLockDecreaseHP;
	bool				m_bLockIncreaseAgile;
	bool				m_bLockDecreaseAgile;
	float				m_fDamageShareProportion;   
	CFighterDictator* m_pLinkFighter;

	//ֹͣ���������������˺�����ģ��¼�
	bool				DisTriggerEvent()			{return m_iDisTriggerEvent > 0;}
	int32				m_iDisTriggerEvent;

private:
	static MapTempVar	m_mapPVar;			//��ʱ����������ӳ��f
	static VecTempVar	m_vecPVar;
	set<string>			m_setNoSingTimeSkill;							//��һ������ʱ��Ϊ0�ļ���

public:
	static set<string>	m_setImmuneTaskAttackName;
	MapImmuneTaskAttack m_iImmuneTaskAttack;
	int32				m_iPrintInfoOff;								// ����ʾ�����ʹ�ӡ��Ϣ

private:
	//�ױ�ֵ��ر���
	int32				m_uSubHP;										//��ʱ.�˺�
	int32				m_uBeSubHP;										//��ʱ.���˺�
	int32				m_uUnchangeSubHP;								//��ʱ.δ����˺�
	int32				m_uBeUnchangeSubHP;								//��ʱ.��δ����˺�
	int32				m_uSubMP;										//��ʱ.����
	int32				m_uBeSubMP;										//��ʱ.������
	int32				m_uHeal;										//��ʱ.����
	int32				m_uGetHeal;										//��ʱ.�ܵ�����
	int32				m_uUnchangeHealHP;								//��ʱ.δ�������
	int32				m_uBeUnchangeHealHP;							//��ʱ.��δ�������
	
	//����ʱ����ر���
	int32				m_iNoSingTime;									//��һ����������ʱ��Ϊ0

	string				m_strDamageChangeStateName;						//һ���˺����˺�������յ�״̬��



	const CFighterDictator*	m_pHolder;	//��ʱ������������ӵ����

	//��ʼ��ר��
public:
	static bool			Init();
	static bool			__init;

};
