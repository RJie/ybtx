#pragma once
#include "TServantMgr.h"

class CCharacterDictator;

/************************************************************************/
/*					������ٻ��޹�������ְ��
*	1���洢�����ٻ����������������ٻ���
*	2����������ٻ��޵ĺ����˵Ĵ��ڹ�ϵ�����ɾ���Ȳ���
*	3������ͬ������˺Ϳͻ���֮���ϵ���룺���˺��ٻ���ͼ���ʱ��ʾ�ȵȣ�
*	4�����������������ߺ�֪ͨ�ٻ�������ض������Լ������Ƿ�ɾ�����ٻ���
*/
/************************************************************************/

class CServantServerMgr : public TServantMgr<CCharacterDictator>
{
public:
	CServantServerMgr(CCharacterDictator* pOwner);
	void OnRemoveServant( CCharacterDictator* pServant );
	void ClearAllServantByMasterDie();
	void ClearAllServant();

	//��Ҫ����ִ��������������Լ����ٻ��޵Ĳ��������磺�ɵ��ٻ��ޣ�
	void ServantResByMasterDie(CCharacterDictator* pServant);

	//�����г������������ȱ������ݿ�����������ٻ���
	void SaveAndClearAllServant(bool bSaveServant);
	void SaveAllServantInfo();

	virtual void OnServantChanged();
public:
	~CServantServerMgr();
};
