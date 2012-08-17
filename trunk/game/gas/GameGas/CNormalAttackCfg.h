#pragma once
#include "FightDef.h"
#include "CCfgCalc.h"
#include "TConfigAllocator.h"
#include "CMagicEffServer.h"
#include "TCfgSharedPtr.h"
#include "TStringRef.h"

class CCfgCalc;
class CMagicEffServer;

DefineCfgSharedPtr(CNormalAttackCfg)

class CNormalAttackCfg
	:public CConfigMallocObject
{
	friend class CNormalAttackAniTick;
	friend class CNormalAttackMgr;
	friend class CSingleHandNATick;

	typedef map<string, CNormalAttackCfgSharedPtr*, less<string>, TConfigAllocator<pair<string, CNormalAttackCfgSharedPtr*> > >			MapNormalAttack;
	typedef map<string, EWeaponType, less<string>, TConfigAllocator<pair<string, EWeaponType> > >						MapWeaponType;
	typedef TStringRefer<CNormalAttackCfg, CMagicEffServer>	MagicEffServerStringRefer;

public:
	static	MapNormalAttack& GetNormalAttackMap();
	static	MapNormalAttack& GetNPCNormalAttackMap();

	static	bool LoadNormalAttackConfig(const string& szFileName);
	static	bool LoadNPCNormalAttackConfig(const string& szFileName);
	static	void UnloadNormalAttackConfig();

	static	CNormalAttackCfgSharedPtr& GetNormalAttack(const TCHAR* szName);
	static	CNormalAttackCfgSharedPtr& GetNPCNormalAttack(const TCHAR* szName);
	static	void UpdateCfg(const string& strName);

	static	MapWeaponType	ms_mapWeaponType;
	inline static void InitMapWeaponType()					
	{
		ms_mapWeaponType[""]			= eWT_None;

		ms_mapWeaponType["����"]		= eWT_Shield;

		ms_mapWeaponType["���ֽ�"]		= eWT_SHSword;
		ms_mapWeaponType["���ָ�"]		= eWT_SHAxe;
		ms_mapWeaponType["���ִ�"]		= eWT_SHHammer;
		ms_mapWeaponType["���ֵ�"]		= eWT_SHKnife;

		ms_mapWeaponType["���ֽ�"]		= eWT_SHSword;
		ms_mapWeaponType["���ָ�"]		= eWT_SHAxe;
		ms_mapWeaponType["���ִ�"]		= eWT_SHHammer;
		ms_mapWeaponType["������Ȼ��"]	= eWT_SHWand;
		ms_mapWeaponType["���ְ�����"]	= eWT_SHWand;
		ms_mapWeaponType["�����ƻ���"]	= eWT_SHWand;

		ms_mapWeaponType["���ֽ�"]		= eWT_SHSword;
		ms_mapWeaponType["���ָ�"]		= eWT_SHAxe;
		ms_mapWeaponType["���ִ�"]		= eWT_SHHammer;

		ms_mapWeaponType["˫�ֽ�"]		= eWT_THSword;
		ms_mapWeaponType["˫�ָ�"]		= eWT_THAxe;
		ms_mapWeaponType["˫�ִ�"]		= eWT_THHammer;
		ms_mapWeaponType["˫�ֹ�"]		= eWT_Bow;
		ms_mapWeaponType["˫����"]		= eWT_CrossBow;
		ms_mapWeaponType["˫����Ȼ��"]	= eWT_THWand;
		ms_mapWeaponType["˫�ְ�����"]	= eWT_THWand;
		ms_mapWeaponType["˫���ƻ���"]	= eWT_THWand;

		ms_mapWeaponType["��ʿǹ"]		= eWT_PaladinGun;
		ms_mapWeaponType["����ì"]		= eWT_Lance;
		ms_mapWeaponType["������"]		= eWT_LongKnife;
		ms_mapWeaponType["������"]		= eWT_LongStick;
	}

	CNormalAttackCfg();
	CNormalAttackCfg(const CNormalAttackCfg& cfg);
	~CNormalAttackCfg();
	string&			GetName()					{return m_strName;}
	uint32			GetId()	const				{return m_uId;}
	EAttackType		GetAttackType()const		{return m_eAttackType;}

	const string&	GetKFrameFileMan() 			{return m_strKFrameFileMan;}
	const string&	GetKFrameFileWoman() 		{return m_strKFrameFileWoman;}

	const CMagicEffServerSharedPtr&		GetMagicEff()		{return m_pMagicEff->Get();}

private:
	uint32					m_uId;				//���ܱ��
	string					m_strName;			//��ͨ������
	CCfgCalc*				m_pMaxAttackDis;	//��󹥻�����
	MagicEffServerStringRefer*	m_pMagicEff;		//ħ��Ч����
	EAttackType				m_eAttackType;		//��������, ����npc�չ���
	string					m_strKFrameFileMan;
	string					m_strKFrameFileWoman;
};

