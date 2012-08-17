#include "stdafx.h"
#include "CConnMgrClientHandler.h"
#include "TComMsgDispatcher.inl"
#include "CBaseConnMgrHandler.inl"
#include "CClientFighterMsgDispatcher.inl"
#include "CClientCharacterMsgDispatcher.inl"
#include "CClientApexMsgDispatcher.inl"

#include "TMsgDispatcher_inl.inl"
#include "TMsgHandler.inl"
#include "CBaseMsgDispatcher.inl"

#include "CCharacterDirector.h"
#include "ErrLogHelper.h"

CConnMgrClientHandler::CConnMgrClientHandler()
: m_pFighterMsgDispatcher(new CClientFighterMsgDispatcher)
, m_pCharacterMsgDispatcher(new CClientCharacterMsgDispatcher)
, m_pApexMsgDispatcher(new CClientApexMsgDispatcher)
{
	CClientFighterMsgDispatcher::InitMsgHandlerContainer();
	CClientFighterMsgDispatcher::RegisterMsgHandler();
	CClientCharacterMsgDispatcher::InitMsgHandlerContainer();
	CClientCharacterMsgDispatcher::RegisterMsgHandler();
	CClientApexMsgDispatcher::InitMsgHandlerContainer();
	CClientApexMsgDispatcher::RegisterMsgHandler();
}

CConnMgrClientHandler::~CConnMgrClientHandler()
{
	SafeDelete(m_pFighterMsgDispatcher);
	SafeDelete(m_pCharacterMsgDispatcher);
	SafeDelete(m_pApexMsgDispatcher);

	CClientFighterMsgDispatcher::UninitMsgHandlerContainer();
	CClientCharacterMsgDispatcher::UninitMsgHandlerContainer();
	CClientApexMsgDispatcher::UninitMsgHandlerContainer();
}

void CConnMgrClientHandler::OnDataReceived(CConnClient *pConn)
{		
	while(pConn->GetRecvDataSize() >= 2)
	{
		TCHAR *pBuf = reinterpret_cast<TCHAR *>(pConn->GetRecvData());
		size_t dataSize = pConn->GetRecvDataSize();

		uint16 id = *(uint16*)(pBuf);

		//���Э���С��32767������lua���͵�rpcЭ�飬ת�Ƶ�lua������������c++����ַ�
		if(id < eLua_CPP_Split_ID)
		{
			SQR_TRY
			{
				if( pConn->IsShuttingDown() )
					break;
				pConn->LogMsgRecvTrafficForScript(id, dataSize);
				GetScriptHandler()->OnDataReceived(pConn);
			}
			//�˴��ӵ����쳣ֻ�����ǵ���rpc����ʱ��������������⵼�µ�
			//�������쳣���������unpack��ʱ����Ѿ��Ͽ�������
			SQR_CATCH(exp){
				LogExp(exp);
				pConn->OnCaughtNetException();
			}
			SQR_TRY_END;
			//�����ȣ���֤�����ݳ��Ȳ�����������Ҫ�����ȴ�������������
			if(dataSize == pConn->GetRecvDataSize())
				break;
		}
		else
		{
			SQR_TRY
			{
				//pConn->LogMsgRecvTrafficForCpp(NULL, id, dataSize);
				if (id > eGas2GacCPP_Fighter_Begin && id < eGas2GacCPP_Fighter_End)
				{
					if (!DoDispatch(m_pFighterMsgDispatcher, pConn, pBuf))
						break;
				}
				else if (id > eGas2GacCPP_Character_Begin && id < eGas2GacCPP_Character_End)
				{
					if (!DoDispatch(m_pCharacterMsgDispatcher, pConn, pBuf))
						break;
				}
				else if (id > eGas2GacCpp_ApexProxyMsg_Begin && id < eGas2GacCpp_ApexProxyMsg_End) 
				{
					if (!DoDispatch(m_pApexMsgDispatcher, pConn, pBuf))
						break;
				}
				else
				{
					std::ostringstream oss;
					oss << "Invalid Msg ID:" << id;
					GenErr(oss.str());
				}
			}
			//��������Ϣ��λ��Щ�쳣��ʱ���ǲ����ܺ��Եģ���������ֱ�Ӷ���
			SQR_CATCH(exp)
			{
				LogExp(exp);
				pConn->ShutDown("DoDispatch �쳣 ");
				break;

			}
			SQR_TRY_END;
		}
	}
}

void CConnMgrClientHandler::OnConnected(CConnClient* pConn)
{
	GetScriptHandler()->OnConnected(pConn);
}

void CConnMgrClientHandler::OnConnectFailed(CConnClient* pConn,EConnConnectFailedReason eReason)
{
	GetScriptHandler()->OnConnectFailed(pConn,eReason);
}		

void CConnMgrClientHandler::OnDisconnect(CConnClient* pConn)
{
	GetScriptHandler()->OnDisconnect(pConn);
}		

void CConnMgrClientHandler::OnError(CConnClient* pConn, const TCHAR* szError)
{
	GetScriptHandler()->OnError(pConn, szError);
}
