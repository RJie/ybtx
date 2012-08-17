#pragma once
#include "CDistortedTick.h"
#include "FighterProperty.inl"
#include "FightDef.h"
#include "CFighterMallocObject.h"

class CFighterDictator;

// Ĭ�ϻָ���˥��ʱ��
const uint32 RENEW_TIME = 1000;

// Ѫ���ָ�Tick
class CRenewHPTick
	:public CDistortedTick
	,public CFighterMallocObject
{
public:
	CRenewHPTick(CFighterDictator* pFighter):m_pFighter(pFighter){}
	void OnTick();
	CFighterDictator* GetFighter() const { return m_pFighter; }

private:
	CFighterDictator* m_pFighter;
};

// ��ֵ�ָ� Tick
class CRenewMPTick
	:public CDistortedTick
	,public CFighterMallocObject
{
public:
	CRenewMPTick(CFighterDictator* pFighter):m_pFighter(pFighter){}
	void OnTick();
	CFighterDictator* GetFighter() const { return m_pFighter; }

private:
	CFighterDictator* m_pFighter;
};

// ŭ��˥�� Tick
class CReduceRPTick
	:public CDistortedTick
	,public CFighterMallocObject
{
public:
	CReduceRPTick(CFighterDictator* pFighter):m_pFighter(pFighter){}
	void OnTick();
	CFighterDictator* GetFighter() const { return m_pFighter; }

private:
	CFighterDictator* m_pFighter;
};

// �����ָ� Tick
class CRenewEPTick
	:public CDistortedTick
	,public CFighterMallocObject
{
public:
	CRenewEPTick(CFighterDictator* pFighter):m_pFighter(pFighter){}
	void OnTick();
	CFighterDictator* GetFighter() const { return m_pFighter; }

private:
	CFighterDictator* m_pFighter;
};

// ����˽�ɫ�ױ�����
// Ѫ��
class CHealthPointServer
	:public TAgileProperty<CHealthPointServer,ePID_HealthPoint,TBaseIntegerAMBProperty,&CStaticAttribs::m_MaxHealthPoint>
	,public CFighterMallocObject
{
public:
	CHealthPointServer(void):m_pTick(NULL),m_bRenewHP(false),m_uPercentOfLostHP(0){}
	void Unit();
	void OnLimitSet(int32 iValue, const CFighterDictator* pFighter);
	void OnRenewAgileValue(const CFighterDictator* pFighter);
	void ResetRenewHP(const CFighterDictator* pFighter);
	void StopRenewHP();

private:
	CRenewHPTick*	m_pTick;
	bool			m_bRenewHP;
	uint8			m_uPercentOfLostHP;
};

// ��ֵ
class CManaPointServer
	:public TAgileProperty<CManaPointServer,ePID_ManaPoint,TBaseIntegerAMBProperty,&CStaticAttribs::m_MaxManaPoint>
	,public CFighterMallocObject
{
public:
	CManaPointServer(void):m_pTick(NULL),m_bRenewMP(false){}
	void Unit();
	void OnLimitSet(int32 iValue,const CFighterDictator* pFighter);
	void OnRenewAgileValue(const CFighterDictator* pFighter);
	void ResetRenewMP(const CFighterDictator* pFighter);
	void StopRenewMP();

private:
	CRenewMPTick*	m_pTick;
	bool			m_bRenewMP;
};

// ŭ�� 
class CRagePointServer
	:public TAgileProperty<CRagePointServer,ePID_RagePoint,TBaseIntegerAMBProperty,&CStaticAttribs::m_MaxRagePoint>
	,public CFighterMallocObject
{
public:
	CRagePointServer(void):m_pTick(NULL),m_bRenewRP(false){}
	void Unit();
	void OnLimitSet(int32 iValue,const CFighterDictator* pFighter);
	void ResetReduceRP(const CFighterDictator* pFighter);
	void StopReduceRP();
	
private:
	CReduceRPTick*	m_pTick;
	bool			m_bRenewRP;
};

// ����
class CEnergyPointServer
	:public TAgileProperty<CEnergyPointServer,ePID_EnergyPoint,TBaseIntegerAMBProperty,&CStaticAttribs::m_MaxEnergyPoint>
	,public CFighterMallocObject
{
public:
	CEnergyPointServer(void):m_pTick(NULL),m_bRenewEP(false){}
	void Unit();
	void OnLimitSet(int32 iValue,const CFighterDictator* pFighter);
	void ResetRenewEP(const CFighterDictator* pFighter);
	void StopRenewEP();
		
private:
	CRenewEPTick*	m_pTick;
	bool			m_bRenewEP;
};

// ������
class CComboPointServer
	:public TAgileProperty<CComboPointServer,ePID_ComboPoint,TBaseIntegerAMBProperty,&CStaticAttribs::m_MaxComboPoint>
	,public CFighterMallocObject
{
};

