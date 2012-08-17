#pragma once
#include "CDynamicObject.h"
#include "CCoolDownInfo.h"
#include "TFighterAllocator.h"

typedef map<string, CCoolDownInfo*, less<string>, 
	TFighterAllocator<pair<const string, CCoolDownInfo*> > > CoolDownInfoMap_t;

template<typename App_t, typename Fight_t>
class TCoolDownMgr
	:public virtual CDynamicObject
	,public CFighterMallocObject
{
public:
	TCoolDownMgr(Fight_t* pFighter);
	~TCoolDownMgr(void);

	static uint32 ms_uFightSkillCommonCDTime;	// ���м��ܵĹ�����ȴʱ��
	static uint32 ms_uItemSkillCommonCDTime;	// ҩƷ��1���ܵĹ�����ȴʱ��

	//����һ���µļ��ܻ�����Ʒcooldown�����������
	//return true��ʾ�����ɹ�
	//return false��ʾ��cooldown���ͻ�û��cooldown��ϣ�����ʧ��
	CCoolDownInfo* IntNewCoolDown( const TCHAR* szName, ESkillCoolDownType eCoolDownType, uint32 uCoolDownTime, bool bSwitchEquipSkill = false);

	//���ĳ��cooldown���͵�ʣ��cooldownʱ�䣬uCoolDownTime�Ǽ��ܵ�cooldown��ʱ��
	uint32 GetCoolDownTime( const TCHAR* szName, ESkillCoolDownType eCoolDownType )const;

	//���ĳ�������Ƿ��Ѿ�cooldown
	bool IsCoolDown( const TCHAR* szName, ESkillCoolDownType eCoolDownType)const;

	void ClearCommonCD();
	bool IsInCommonCD( const TCHAR* szName, ESkillCoolDownType eCoolDownType );
	bool IsSwitchEquipSkill( const TCHAR* szName );
	// �����м���CoolDownTime����
	void ResetAllCoolDown();
	void ResetCoolDownByCoolDownType(ESkillCoolDownType eCoolDownType);

	CoolDownInfoMap_t& GetCoolDownInfoMap();
	Fight_t* GetFighter() {return m_pFighter;}

private:
	uint64 m_uComCoolDownBeginTime;			// ս�����ܹ�����ȴ��ʼʱ��
	uint64 m_uDrugItemSkillCDBeginTime;		// �ָ�����ȴ��ʼʱ��
	uint64 m_uSpecialItemSkillCDBeginTime;	// ��������Ʒ������ȴ��ʼʱ��
	

	CoolDownInfoMap_t	m_mapCoolDownInfo;
	Fight_t*			m_pFighter;
};
