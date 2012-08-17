#pragma once
#include "CBaseState.h"
#include "boost/shared_ptr.hpp"
#include "TConfigAllocator.h"

class CCfgCalc;

class CBaseStateCfgClient
	:public CBaseStateCfg
{
public:
	CBaseStateCfgClient(EStateGlobalType type = eSGT_Undefined);

	static bool LoadConfig();
	static void UnloadConfig();

	const TCHAR*		GetName()					{return m_sName.c_str();}
	const bool		GetDecrease()				{return m_bDecrease;}
	float			GetDotInterval()			{return m_fDotInterval;}

protected:
	string			m_sName;						//����
	bool			m_bDecrease;					//�Ƿ��Ǹ���Ч��
	float			m_fDotInterval;					//���ɳ������ħ��Ч���ļ��ʱ��
};

template <class StateType>
class CTplStateCfgClient
	: public CBaseStateCfgClient
{
	friend class CBaseStateCfgClient;
public:
	typedef boost::shared_ptr<CTplStateCfgClient<StateType> >	SharedPtrType;
	typedef map<uint32, SharedPtrType*, less<uint32>, TConfigAllocator<pair<uint32, SharedPtrType*> > >							MapTplStateCfgById;
	typedef map<string, SharedPtrType*, less<string>, TConfigAllocator<pair<string, SharedPtrType*> > >							MapTplStateCfgByName;
public:
	static bool					LoadConfig(const TCHAR* cfgFile);	//�����ñ�
	static void					UnloadConfig();						//ж�����ñ�
	static SharedPtrType&		GetById(uint32 uId);				//��ȡħ��״̬������
	static SharedPtrType&		GetByName(const TCHAR* name);		//��ȡħ��״̬������
	static EStateGlobalType		GetStateType();
	static uint32				GetStateTypeFloor();

private:
	static MapTplStateCfgById	m_mapCfgById;						//ħ��״̬����ӳ���
	static MapTplStateCfgByName	m_mapCfgByName;						//ħ��״̬����ӳ���

public:
	CTplStateCfgClient();
	~CTplStateCfgClient();
	uint32			GetId()						{return m_uId;}
	const TCHAR*		GetIcon()					{return m_sIcon.c_str();}
	const TCHAR*		GetModel()					{return m_sModel.c_str();}
	const TCHAR*		GetFX();
	const bool		IsMultiCascadeFX();
	const TCHAR*		GetFX(uint32 i);
	const string&	GetModelStr()				{return m_sModel;}
	const CCfgCalc*	GetTime()					{return m_calcTime;}
	//const bool	GetCancelable()				{return m_bCancelable;}
	const bool		GetCancelable()				{return m_eIconCancelCond == eICC_All;}
	const EIconCancelCond		GetIconCancelCond()			{return m_eIconCancelCond;}

private:

	uint32			m_uId;							//���
	EDecreaseStateType		m_eDecreaseType;		//����ħ��״̬����
	string			m_sIcon;						//��ӦСͼ��
	string			m_sModel;						//ģ��
	CCfgCalc*		m_calcFX;						//��Ӧ��Ч
	CCfgCalc*		m_calcTime;						//����ʱ��
	//string		m_sTime;						//����ʱ��
	EIconCancelCond	m_eIconCancelCond;				//ȡ������


	static bool		__init;
};
	