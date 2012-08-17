#pragma once

#include "TEntityManager.h"
#include "TSingleton.h"
#include "GameDef.h"
#include "CStaticObject.h"
#include "CNpcAIDataMallocObject.h"

class CNpcStateTransit;
class CNpcAIBaseData;
class CNpcFightBaseData;
class CNpcFacialData;
class CNpcResServerData;
class CNpcEnmityTargetFilterData;

class CNpcServerBaseData 
	: public virtual CStaticObject
	, public CNpcAIDataMallocObject
{
	friend class CNpcServerBaseDataMgr;
	CNpcServerBaseData(uint32 uID, const string& sName);
public:
	static CNpcServerBaseData* Create(const TCHAR* szName, const TCHAR* szNpcType, const TCHAR* szAIType, const TCHAR* szAIData
				, uint32 uCamp, uint32 uClass, uint32 uSex, uint32 uLevel);
	inline uint32 GetID() const { return m_uID; }
	inline const string& GetName() const{ return m_sName; }
public:
	void SetCanBeChangeAI(bool bCanChangeAI);
	void SetBeSleep(bool bSleep);
	void SetBeSynToClient(bool bSynToClient);
	void SetCanBeSelected(bool bCanBeSelected);
	void SetCanBeRavin(bool bCanBeRavin);
public:
	const CNpcStateTransit*					m_pStateTransitOne;
	const CNpcAIBaseData*					m_pAIBaseDataOne;
	const CNpcFightBaseData*				m_pFightBaseData;
	const CNpcResServerData*				m_pResBaseData;
	const CNpcEnmityTargetFilterData*		m_pEnmityTargetFilter;
	uint32									m_uCamp;
	uint32									m_uClass;
	uint32									m_uSex;
	uint32									m_uLevel;		//Npc���ñ�����д�ĵȼ������ܺ���ʵֵ��ͬ
	bool									m_bCanBeChangeAI;
	bool									m_bSleep;		//�Ƿ�����
	bool									m_bSynToClient;	//�Ƿ���Ҫͬ�����ͻ���
	bool									m_bCanBeSelected; // �ɱ�ѡ��
	bool									m_bCanBeRavin;	//�ɱ���ʳ

	//�������������Ǵ�Npc_Common���ж�ȡ�ĳ�ʼ���ԣ�������Ϊ�л�AI���ı�
	ENpcType								m_eType;						
	ENpcAIType								m_eAIType;					
	EObjectAoiType							m_eAoiType;	
private:
	uint32	m_uID;
	string	m_sName;
};

class CNpcServerBaseDataMgr
	: public TEntityManager< const CNpcServerBaseData, TIDIndex< const CNpcServerBaseData >, TNameIndex< const CNpcServerBaseData > >
	, public TSingleton< CNpcServerBaseDataMgr >
	, public CNpcAIDataMallocObject
{
	friend class TSingleton< CNpcServerBaseDataMgr >;
private:
	CNpcServerBaseDataMgr();
	~CNpcServerBaseDataMgr();
};
