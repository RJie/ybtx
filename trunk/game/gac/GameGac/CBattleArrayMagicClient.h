#pragma once
#include "CMagicClient.h"
#include "CPos.h"
#include "TCfgSharedPtr.h"
#include "TConfigAllocator.h"
#include "CConfigMallocObject.h"

DefineCfgSharedPtr(CBattleArrayMagicCfgClient)
class CCfgRelChecker;

class CBattleArrayMagicCfgClient
	: public CConfigMallocObject
{
	friend class CCfgRelChecker;

public:
	static bool LoadConfig(const string& szFileName);
	static void UnloadConfig();
	static CBattleArrayMagicCfgClientSharedPtr& GetById(const uint32 uId);
	const string& GetName()					{ return m_sName; }
	uint32 GetMaxAddUpValue()					{ return m_uMaxAddUpValue; }
	const string& GetPosFx()					{ return m_strPosFx; }
	const string& GetPosSucFx()					{ return m_strPosSucFx; }
	const string& GetAddUpSucFx()					{ return m_strAddUpSucFx; }

private:
	typedef map<uint32, CBattleArrayMagicCfgClientSharedPtr*, less<uint32>, TConfigAllocator<pair<uint32, CBattleArrayMagicCfgClientSharedPtr*> > >		MapBattleArrayMagicCfgClientById;
	static MapBattleArrayMagicCfgClientById				ms_mapBattleArrayMagicById;

	uint32 m_uId;					
	string m_sName;
	uint32 m_uMaxAddUpValue;		//����ֵ
	string m_strPosFx;				//��λ��Ч
	string m_strPosSucFx;			//������Ч
	string m_strAddUpSucFx;			//�����ɹ���Ч			
};	

class CBattleArrayMagicClient 
	: public CMagicClient
{
public:
	CBattleArrayMagicClient();
	typedef vector<pair<uint32,CPos>,TMagicAllocator<pair<uint32,CPos> > >			VecBattleArray;
	static void Transfer(const string& strPos,const string& strEntityID,VecBattleArray& vecBattleArray);
	static void PositionTransfer(VecBattleArray& vecBattleArray,const CPos& pos);
	void OnValueChanged(CCypherVariant *pVariant);
	virtual ~CBattleArrayMagicClient();
private:

};
