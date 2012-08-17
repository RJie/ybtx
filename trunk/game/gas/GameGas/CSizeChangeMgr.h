#pragma once
#include "CDistortedTick.h"
#include "TMagicStateAllocator.h"

class CFighterDictator;
class CBaseStateCfgServer;

class CSizeChangeMgr
	: public CDistortedTick
	, public CMagicStateMallocObject
{
public:
	CSizeChangeMgr(CFighterDictator* pOwner);
	~CSizeChangeMgr();
	void ChangeSizeRate(CBaseStateCfgServer* pCfg, int32 iChangeRateCount);
	void OnTick();
	double GetStateZoomRate();

private:
	double m_dFinalScale;
	double m_dCurScale;
	uint32 m_uScaleMaxCount;
	uint32 m_uScaleCurCount;

	CFighterDictator* m_pOwner;
};

//�ڿ���̨��ӡAOI SIZE��BARRIER SIZE��״̬ģ�ʹ�С�仯����Ϣ
//#define COUT_SIZE_CHANGE_INFO

