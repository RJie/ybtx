#pragma once
#include "CMagicServer.h"

namespace sqr
{
	class CCoreSceneServer;
}

class CBulletMagicCfgServerSharedPtr;
class CGenericTarget;

class CBulletMagicServer
	: public CMagicServer
{	
public:
	CBulletMagicServer(CSkillInstServer* pInst, const CBulletMagicCfgServerSharedPtr& pCfg, CFighterDictator* pFrom, CFighterDictator* pTo);
	CBulletMagicServer(CSkillInstServer* pInst, const CBulletMagicCfgServerSharedPtr& pCfg, CFighterDictator* pFrom, const CFPos& pos);
	~CBulletMagicServer();
	void OnCOREvent(CPtCORSubject* pSubject, uint32 uEvent,void* pArg);
	virtual void OnTraceEnded(ETraceEndedType eTEType);
	virtual void OnMoveEnded(EMoveEndedType eMoveEndedType, uint32 uMoveID);
	virtual void OnMovePathChanged();
	void BulletExplode();
	virtual EMagicGlobalType	GetMagicType() const		{return eMGT_Bullet;}
	CBulletMagicCfgServerSharedPtr&		GetCfgSharedPtr()const;
	void						DestoryBullet();
	void OnDestroy();
	const CFPos& GetBeginPos()const;

private:
	void BecomeDumbBullet();
	void CreatBullet(const CFPos& posFrom);
	void DoEffect();
	static uint32 GetCheckTimes();	// �ӵ����й����м����Ŀ��֮�����Ĵ���

	CBulletMagicCfgServerSharedPtr*		m_pCfg;
	CGenericTarget*				m_pTo;
	CCoreSceneServer*			m_pScene;
	bool						m_bIsDumbBullet;	//�ӵ��Ƿ���Ч, ���Ƿ�����˺�
	bool						m_bIsPos;
	CFPos						m_BeginPos;			//�ӵ���ʼλ��
};
