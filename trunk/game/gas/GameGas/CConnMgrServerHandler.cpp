#include "stdafx.h"
#include "CConnMgrServerHandler.h"
#include "PtrlGac2GasCPPDcl.h"
#include "IRpcCommon.h"
#include "CBaseMsgDispatcher.inl"
#include "CBaseConnMgrHandler.inl"
#include "CServerFighterMsgDispatcher.h"
#include "CServerCharacterMsgDispatcher.h"
#include "CServerApexProxyMsgDispatcher.h"
#include "TMsgDispatcher.inl"
#include "ExpHelper.h"
#include "ErrLogHelper.h"
#include "CExpCounter.h"

CConnMgrServerHandler::CConnMgrServerHandler()
	: m_pFighterMsgDispatcher(new CServerFighterMsgDispatcher)
	, m_pCharacterMsgDispatcher(new CServerCharacterMsgDispatcher)
	, m_pApexproxyMsgDispatcher(new CServerApexProxyMsgDispatcher)
{
	CServerFighterMsgDispatcher::InitMsgHandlerContainer();
	CServerFighterMsgDispatcher::RegisterMsgHandler();
	CServerCharacterMsgDispatcher::InitMsgHandlerContainer();
	CServerCharacterMsgDispatcher::RegisterMsgHandler();
	CServerApexProxyMsgDispatcher::InitMsgHandlerContainer();
	CServerApexProxyMsgDispatcher::RegisterMsgHandler();
}

CConnMgrServerHandler::~CConnMgrServerHandler()
{
	SafeDelete(m_pFighterMsgDispatcher);
	SafeDelete(m_pCharacterMsgDispatcher);
	SafeDelete(m_pApexproxyMsgDispatcher);

	CServerFighterMsgDispatcher::UninitMsgHandlerContainer();
	CServerCharacterMsgDispatcher::UninitMsgHandlerContainer();
	CServerApexProxyMsgDispatcher::UninitMsgHandlerContainer();
}


void CConnMgrServerHandler::OnDataReceived(CConnServer *pConn)
{
	while ( pConn->GetRecvDataSize() >= 2 )
	{
		char *pBuf = reinterpret_cast<char *>(pConn->GetRecvData());
		size_t dataSize = pConn->GetRecvDataSize();

		uint16 id = *(uint16*)(pBuf);

		//���Э���С��32767������lua���͵�rpcЭ�飬ת�Ƶ�lua������������c++����ַ�
		if ( id < eLua_CPP_Split_ID )
		{
			SQR_TRY
			{
				if( pConn->IsShuttingDown() )
					break;

				GetScriptHandler()->OnDataReceived(pConn);
			}
			//�˴��ӵ����쳣ֻ�����ǵ���rpc����ʱ��������������⵼�µ�
			//�������쳣���������unpack��ʱ����Ѿ��Ͽ�������
			SQR_CATCH(exp)
			{
				LogExp(exp, pConn);
			}
			SQR_TRY_END;
			//�����ȣ���֤�����ݳ��Ȳ�����������Ҫ�����ȴ�������������
			if (dataSize == pConn->GetRecvDataSize())
				break;
		}
		else
		{
			if (id > eGac2GasCPP_Fighter_Begin && id < eGac2GasCPP_Fighter_End)
			{
				if (!DoDispatch(m_pFighterMsgDispatcher, pConn, pBuf))
					break;
			}
			else if (id > eGac2GasCPP_Character_Begin && id < eGac2GasCPP_Character_End)
			{
				if (!DoDispatch(m_pCharacterMsgDispatcher, pConn, pBuf))
					break;
			}
			else if (id > eGac2GasCPP_ApexProxy_Begin && id < eGac2GasCPP_ApexProxy_End)
			{
				if (!DoDispatch(m_pApexproxyMsgDispatcher, pConn, pBuf))
					break;
			}
			else
			{
				std::ostringstream oss;
				oss << id;
				GenErr("Invalid Msg ID", oss.str());
			}			
		}
	}
}

void CConnMgrServerHandler::OnAccepted(CConnServer* pConn)
{
	GetScriptHandler()->OnAccepted(pConn);
}

void CConnMgrServerHandler::OnDisconnect(CConnServer* pConn)
{
	GetScriptHandler()->OnDisconnect(pConn);
}

void CConnMgrServerHandler::OnError(CConnServer* pConn,const char* szError)
{
	GetScriptHandler()->OnError(pConn, szError);
}

void CConnMgrServerHandler::OnBeginServiceSucceeded()
{
	GetScriptHandler()->OnBeginServiceSucceeded();
}

void CConnMgrServerHandler::OnBeginServiceFailed(const char* szErrMsg)
{
	GetScriptHandler()->OnBeginServiceFailed(szErrMsg);
}

void CConnMgrServerHandler::OnServiceEnded()
{
	GetScriptHandler()->OnServiceEnded();
}

void CConnMgrServerHandler::OnCheat(CConnServer* pConn)
{
	GetScriptHandler()->OnCheat(pConn);
}
