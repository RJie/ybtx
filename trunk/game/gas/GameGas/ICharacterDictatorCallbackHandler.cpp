#include "stdafx.h"
#include "ICharacterDictatorCallbackHandler.h"
#include "CCharacterDictator.h"
#include "CallBackX.h"
#include "CCoreSceneServer.h"

void ICharacterDictatorCallbackHandler::OnCreateServant( uint32 uObjID,const TCHAR* szServantName,uint32 uLevel,float fPosX, float fPosY,bool bNormalAI) 
{
	CALL_CLASS_CALLBACK_6(uObjID, szServantName, uLevel, fPosX, fPosY, bNormalAI)
}

void ICharacterDictatorCallbackHandler::OnCreateServantWithTarget( uint32 uObjID,const TCHAR* szServantName,uint32 uLevel, uint32 uTargetID,float fPosX, float fPosY,bool bNormalAI) 
{
	CALL_CLASS_CALLBACK_7(uObjID, szServantName, uLevel, uTargetID, fPosX, fPosY, bNormalAI)
}

void ICharacterDictatorCallbackHandler::OnCreateBattleHorse( uint32 uObjID, const TCHAR* szServantName, const TCHAR* szServantType, uint32 uLevel, float fPosX, float fPosY) 
{
	CALL_CLASS_CALLBACK_6(uObjID, szServantName, szServantType, uLevel, fPosX, fPosY)
}

void ICharacterDictatorCallbackHandler::OnCreateNPCWithTarget( uint32 uObjID, uint32 uTargetID, uint32 uMasterID, const TCHAR* szNPCName,
															  uint32 uLevel,float fPosX,float fPosY) 
{
	CALL_CLASS_CALLBACK_7(uObjID, uTargetID, uMasterID, szNPCName, uLevel, fPosX, fPosY)
}

void ICharacterDictatorCallbackHandler::OnCreateDeadNPC( uint32 uObjID, uint32 uLevel, float fPosX, float fPosY) 
{
	CALL_CLASS_CALLBACK_4(uObjID, uLevel, fPosX, fPosY)
}

void ICharacterDictatorCallbackHandler::OnDestroyNpc(CCharacterDictator* pObject)
{
	CALL_CLASS_CALLBACK_1(pObject)
}

void ICharacterDictatorCallbackHandler::OnCreateShadow( uint32 uObjID,const TCHAR* szServantName,uint32 uLevel,
													   float fPosX,float fPosY,bool bNormalAI) 
{
	CALL_CLASS_CALLBACK_6(uObjID, szServantName, uLevel, fPosX, fPosY, bNormalAI)
}

//ע���lua�õĻ�
void ICharacterDictatorCallbackHandler::OnNPCDead(CCharacterDictator* self, uint32 uExpOwnerID, uint32 KillerID, bool bNormalDead)
{
	CALL_CLASS_CALLBACK_4( self, uExpOwnerID, KillerID, bNormalDead)
}

//npc����֮��֪ͨ����ϵͳ
void ICharacterDictatorCallbackHandler::OnDeadToQuest(CCharacterDictator* self,const TCHAR* szSkillName,uint32 uKillerID,uint32 uExpOwnerID)
{
	CALL_CLASS_CALLBACK_4(self, szSkillName, uKillerID, uExpOwnerID)	
}

//npc����֮�� �����������ʵ�� �ͷ���������� ����Ϊ ���Ѿ�����һ��OnDead() ��������Ϊ BeDead()
void ICharacterDictatorCallbackHandler::OnDead(CCharacterDictator* self,const TCHAR* szSkillName,uint32 uKillerID,uint32 uExpOwnerID, bool bNormalDead)
{
	CALL_CLASS_CALLBACK_5(self, szSkillName, uKillerID, uExpOwnerID, bNormalDead)
}

void ICharacterDictatorCallbackHandler::OnDeadByTick(CCharacterDictator* pObject)
{
	CALL_CLASS_CALLBACK_1(pObject)	
}

void ICharacterDictatorCallbackHandler::OnLeaveBattleState(CCharacterDictator* pObject)
{
	CALL_CLASS_CALLBACK_1(pObject)
}

void ICharacterDictatorCallbackHandler::OnEnterBattleState(CCharacterDictator* pObject)
{
	CALL_CLASS_CALLBACK_1(pObject)
}

void ICharacterDictatorCallbackHandler::OnDisappear(CCharacterDictator* self, bool bNotReborn)
{
	CALL_CLASS_CALLBACK_2(self, bNotReborn)
};

//������Ӧ
bool ICharacterDictatorCallbackHandler::OnReaction2Facial(uint32 uEntityID, const TCHAR* uActionName, uint32 uPlayerEntityID)
{
	CALL_CLASS_CALLBACK_3_RET(bool, uEntityID, uActionName, uPlayerEntityID)	
	return true;
}

bool ICharacterDictatorCallbackHandler::DoFacialReaction(uint32 uEntityID, const TCHAR* uActionName, uint32 uPlayerEntityID){
	CALL_CLASS_CALLBACK_3_RET(bool, uEntityID, uActionName, uPlayerEntityID)	
	return true;
}

//��������
bool ICharacterDictatorCallbackHandler::HaveNature(uint32 uEntityID) 
{
	CALL_CLASS_CALLBACK_1_RET(bool, uEntityID)
	return true;
};

void ICharacterDictatorCallbackHandler::InitNatureData(uint32 uEntityID)
{
	CALL_CLASS_CALLBACK_1(uEntityID)
};

//�����ڸ����в��Ŷ���
void ICharacterDictatorCallbackHandler::DoNatureAction(uint32 uEntityID, const TCHAR* szActionName)
{
	CALL_CLASS_CALLBACK_2(uEntityID, szActionName)
};

// �������רΪ�糡����ʵ�֣�by : super_xiang
void ICharacterDictatorCallbackHandler::SendNpcRpcMessage(uint32 uObjID, uint32 NpcId, uint32 uMessageId)
{
	CALL_CLASS_CALLBACK_3(uObjID, NpcId, uMessageId)
}

void ICharacterDictatorCallbackHandler::MoveEndMessage(CCharacterDictator* pObject) 
{
	CALL_CLASS_CALLBACK_1(pObject)
}

void ICharacterDictatorCallbackHandler::ChangeDir(uint32 NpcId, uint32 uX, uint32 uY) 
{
	CALL_CLASS_CALLBACK_3(NpcId, uX, uY)
}

void ICharacterDictatorCallbackHandler::ReplaceNpc(CCharacterDictator* pServant, CCharacterDictator* pMaster, const TCHAR* sAIName, const TCHAR* sNpcType, const TCHAR* szServantRealName, ECamp eCamp) 
{
	CALL_CLASS_CALLBACK_6(pServant, pMaster, sAIName, sNpcType, szServantRealName, eCamp)
}

//Ϊ��С��ʵ���ں���
void ICharacterDictatorCallbackHandler::SetDrivePig(uint32 uObjId, uint32 uEntityId)
{
	CALL_CLASS_CALLBACK_2(uObjId, uEntityId)
}

void ICharacterDictatorCallbackHandler::DestoryObj(uint32 ObjId){
	CALL_CLASS_CALLBACK_1(ObjId)
};

//����Npc��Ӱ��״̬
void ICharacterDictatorCallbackHandler::SetNpcAlphaValue(uint32 uEntityID, uint8 cValue)
{
	CALL_CLASS_CALLBACK_2(uEntityID, cValue)
};

void ICharacterDictatorCallbackHandler::SetNpcCanBeTakeOver(uint32 uEntityID, ENpcAIType eNpcAIType, ENpcType eNpcType, ECamp eCamp)
{
	CALL_CLASS_CALLBACK_4(uEntityID, eNpcAIType, eNpcType, eCamp);
}

//�ٻ��޸������ϼ��ܵ������ӿ�
void ICharacterDictatorCallbackHandler::CreateServantSkillToMaster(CCharacterDictator* pMaster, const TCHAR* sServantName)
{
	CALL_CLASS_CALLBACK_2(pMaster, sServantName);
}

void ICharacterDictatorCallbackHandler::DelServantSkillFromMaster(CCharacterDictator* pMaster, const TCHAR* sServantName)
{
	CALL_CLASS_CALLBACK_2(pMaster, sServantName)
}

//�ٻ���С��������Npc�����Լ�
void ICharacterDictatorCallbackHandler::MasterReBornCortege(uint32 uMasterID, uint32 uCortegeID)
{
	CALL_CLASS_CALLBACK_2(uMasterID, uCortegeID);
}

//�ٻ������˻ָ��Լ���С��
void ICharacterDictatorCallbackHandler::MasterRevertNpcGroup(uint32 uMasterID)
{
	CALL_CLASS_CALLBACK_1(uMasterID)
}

//Npc�ͷż���ͬʱ˵��
void ICharacterDictatorCallbackHandler::NpcShowContentBySkill(CCharacterDictator* pNpc, const TCHAR* sSkillName, uint32 uTargetID)
{
	CALL_CLASS_CALLBACK_3(pNpc, sSkillName, uTargetID)
}

void ICharacterDictatorCallbackHandler::BecomeTargetShadow(CCharacterDictator* pCharacter, CCharacterDictator* pTarget)
{
	CALL_CLASS_CALLBACK_2(pCharacter, pTarget);
}

void ICharacterDictatorCallbackHandler::TakeOverTruckByNewMaster(CCharacterDictator* pTruck, CCharacterDictator* pNewMaster)
{
	CALL_CLASS_CALLBACK_2(pTruck, pNewMaster)
}

void ICharacterDictatorCallbackHandler::ClearNpcAlertEffect( CCharacterDictator* pAlertNpc)
{
	CALL_CLASS_CALLBACK_1(pAlertNpc)
}

void ICharacterDictatorCallbackHandler::ReplaceTruck(CCharacterDictator* pOldTruck, CCharacterDictator* pNewTruck)
{
	CALL_CLASS_CALLBACK_2(pOldTruck, pNewTruck)
}

void ICharacterDictatorCallbackHandler::PosCreateNpcWithMaster(uint32 uMasterID, const TCHAR* szNPCName, float fPosX, float fPosY) 
{
	CALL_CLASS_CALLBACK_4(uMasterID, szNPCName, fPosX, fPosY)
}


