#pragma once
#include "FightDef.h"
#include "CMagicMallocObject.h"
#include "TConfigAllocator.h"

namespace sqr
{
	class CCoreSceneServer;
	class CCoreObjectDictator;
}

class CCfgCalc;
class CAoiDimMgr;
struct FilterLimit;
class CMagicEffServer;
class CMagicEffServerSharedPtr;
class CSkillInstServer;
class CFighterDictator;

class CMagicCfgServer
	: public CMagicMallocObject
{
public:
	CMagicCfgServer();
	CMagicCfgServer(const CMagicCfgServer& cfg);
	virtual ~CMagicCfgServer();

	virtual uint32			GetId()					{return m_uId;}
	virtual const string&	GetName()const			{return m_sName;}
	CCfgCalc*				GetRadius()				{return m_pRadius;}
	CCfgCalc*				GetTime()				{return m_pTime;}
	float 					GetSpeed()				{return m_fSpeed;}
	CCfgCalc*				GetAmountLimit()		{return m_pAmountLimit;};
	EOperateObjectType		GetOperateObject()		{return m_eOperateObject;}
	//virtual const CMagicEffServerSharedPtr&		GetMagicEff()const=0;
	static		const vector<string> Split(const string& src, string delimit);

protected:
	CCfgCalc*				m_pRadius;
	CCfgCalc*				m_pAmountLimit;		//��������
	CCfgCalc*				m_pTime;			//����ʱ��
	string					m_sName;			//����
	float					m_fSpeed;			//�ٶ�
	EOperateObjectType		m_eOperateObject;	//���ö���
	uint32					m_uId;				//���
};

