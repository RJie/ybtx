#pragma once
#include "FightDef.h"
#include "TCfgSharedPtr.h"
#include "CConfigMallocObject.h"
#include "TConfigAllocator.h"

DefineCfgSharedPtr(CNormalAttackCfgClient)


class CCfgCalc;
class CFighterDirector;

class CNormalAttackCfgClient
	: public CConfigMallocObject
{
	typedef map<string, CNormalAttackCfgClientSharedPtr*, less<string>, TConfigAllocator<pair<string, CNormalAttackCfgClientSharedPtr*> > >	MapNormalAttack;
	typedef map<uint32, CNormalAttackCfgClientSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CNormalAttackCfgClientSharedPtr*> > >	MapNormalAttackById;
	typedef map<string, EWeaponType, less<string>, TConfigAllocator<pair<string, EWeaponType> > >				MapWeaponType;
	typedef map<string, EAttackType, less<string>, TConfigAllocator<pair<string, EAttackType> > >				MapAttackType;
public:
	static	MapWeaponType	ms_mapWeaponType;
	static	MapAttackType	ms_mapAttackType;
	static	bool LoadNormalAttackConfig(const string& szFileName);
	static	bool LoadNpcNormalAttackConfig(const string& szFileName);
	static	void UnloadNormalAttackConfig();
	static	CNormalAttackCfgClientSharedPtr& GetNormalAttack(const TCHAR* szName);
	static	CNormalAttackCfgClientSharedPtr& GetNormalAttackById(uint32 uID);
	inline static void InitMapAttackType()					
	{
		ms_mapAttackType[""]		= eATT_None;
		ms_mapAttackType["����"]	= eATT_Puncture;
		ms_mapAttackType["���"]	= eATT_Chop;
		ms_mapAttackType["�ۻ�"]	= eATT_BluntTrauma;
		ms_mapAttackType["��Ȼ"]	= eATT_Nature;
		ms_mapAttackType["�ƻ�"]	= eATT_Destroy;
		ms_mapAttackType["����"]	= eATT_Evil;
	}

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

	~CNormalAttackCfgClient();

	uint32				GetId()							{return m_uId;}
	const string&		GetName()const					{return m_strName;};	
	CCfgCalc*			GetMaxAttackDis()const			{return m_pMaxAttackDis;}

private:
	static MapNormalAttack		ms_mapNormalAttack;
	static MapNormalAttackById	ms_mapNormalAttackById;
	uint32		m_uId;				//���ܱ��
	string		m_strName;			//��ͨ������
	CCfgCalc*	m_pMaxAttackDis;	//��󹥻�����
};
