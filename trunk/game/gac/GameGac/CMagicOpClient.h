#pragma once
#include "FXPlayer.h"
#include "CConfigMallocObject.h"
#include "TConfigAllocator.h"

class CMagicOpCfgClient
	: public CConfigMallocObject
{
public:
	typedef map<uint32, CMagicOpCfgClient*, less<uint32>, TConfigAllocator<pair<uint32, CMagicOpCfgClient*> > >		MapMagicOpCfgClient;
	typedef map<string, EFxType, less<string>, TConfigAllocator<pair<string, EFxType> > >		MapFxType;
	static bool									LoadConfig(const TCHAR* cfgFile, bool bFirstFile);
	static void									UnloadConfig();
	static CMagicOpCfgClient*					GetById(uint32 uId);				
	uint32	GetId()								{return m_uId;}
	string	GetFX()								{return m_sFX;}
	EFxType GetFxType()					{return m_eFxType;}
	static 	MapFxType	ms_mapFxType;
	static void							InitMapFxType()					
	{
		ms_mapFxType[""]	= eFT_None;
		ms_mapFxType["����"]		= eFT_Leading;
		ms_mapFxType["�ܻ�"]		= eFT_Suffer;
		ms_mapFxType["����"]		= eFT_Local;
		ms_mapFxType["���߷���"]		= eFT_LineDirection;
	}

private:
	static MapMagicOpCfgClient					m_mapCfgById;
	static uint32		ms_uMaxLineNum;
	uint32				m_uId;					//���
	string				m_sName;				//����
	string				m_sFX;					//��Ч
	EFxType				m_eFxType;		//�Ƿ񲥷��ܻ���Ч
};