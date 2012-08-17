
Gas2GasDef = {}

local tblErrMap = {}
tblErrMap[-1] = "rpc����id����"
tblErrMap[-2] = "��֤��У��������ܳ���������Ϣ����"
tblErrMap[-3] = "���ݸ�ʽ����"
tblErrMap[-4] = "û���ҵ���rpc������"
tblErrMap[-5] = "û��Gac2Gas"

function Gas2GasDef:OnError(num, fun)
--[[
		-1 ����ʾid����
		-2 ����ʾ��֤�����
		-3 ����ʾ���ݸ�ʽ����
		-4 ����ʾû���ҵ�������
		-5 ����ʾ���صĴ���
		>0 ����ʾ�û��Լ����صĲ���
--]]
	if num > 0 then
		error(fun .. " rpc call error: " .. "rpc�����������з���ֵ" )
		return false
	end
			
	error(fun .. " rpc call error: " .. tblErrMap[num] )
	return false
end

Gas2GasCall = {}

g_MultiServerConnList = {}
g_OtherServerConnList = {}
g_StartConnTime = {}
g_OtherServerShutDownList = {}--��¼���������ط��ķ�����
g_ConnOtherServerTickTbl = {}
g_MultiServReConnTickTime = 5000 --��λ����

function Gas2GasDef:TestMultiRpc(conn, str)
	print("send from " .. str)
	local addr = CAddress:new()
	conn:GetLocalAddress(addr)
	print(addr:GetAddress(),addr:GetPort())
	--Gas2GasCall:TestMultiRpc(gpipe,"aaaaaaaaaa")
end

function Gas2GasDef:SendSuccConn(conn, ServerId)
	g_OtherServerConnList[ServerId] = conn
end

function Gas2GasDef:ShutDownNotifyOtherServer(conn, ServerId)
	g_OtherServerShutDownList[ServerId] = true
end

function IsServerShutDownState(ServerId)
	return g_OtherServerShutDownList[ServerId]
end

function ResetServerShutDownState(ServerId)
	g_OtherServerShutDownList[ServerId] = nil
end

function SetOtherServConnByServId(ServId,Conn)
	g_OtherServerConnList[ServId] = Conn
end

function GetServerConn(ServId)
	return g_OtherServerConnList[ServId]
end

--���������Ϊ����� Gas2GasAutoCall ʹ��
function GetServerAutoConn(ServId)
	if ServId == g_CurServerId then
		return g_CurServerId
	end
	return g_OtherServerConnList[ServId]
end

local gas_path = GetLoadPath("gas")
function CreateListenOfLocalAddr(ip,port)
	g_LocalAddrListen = CMultiServerConn:new(false)
	g_LocalAddrListen:Listen(ip,port)
	g_LocalAddrListen:RegistCall("gas", "multiserver/Gas2GasProList", "Gas2GasCall", "IPipe")
	g_LocalAddrListen:RegistDef("gas", "multiserver/Gas2GasProList", "Gas2GasDef", "IPipe")
end

function ClearListenOfLocalAddr()
	if g_LocalAddrListen then
		g_LocalAddrListen:ShutDown()
		g_LocalAddrListen = nil
	end
end

function CreateConnToTargetServer(targetserverid,ip,port)
	local MultiServerConn = CMultiServerConn:new(false)
	MultiServerConn.m_TargetServerId = targetserverid
	g_StartConnTime[targetserverid] = os.time()
	MultiServerConn:Connect(ip,port)
	MultiServerConn:RegistCall("gas", "multiserver/Gas2GasProList", "Gas2GasCall", "IPipe")
	MultiServerConn:RegistDef("gas", "multiserver/Gas2GasProList", "Gas2GasDef", "IPipe")
	g_MultiServerConnList[targetserverid] = MultiServerConn
end

function ClearConnOfOtherServer()
	if g_MultiServerConnList then
		for serverId, Conn in pairs(g_MultiServerConnList) do
			Conn:ShutDown()
		end
		g_MultiServerConnList = nil
	end
end

function ShutDownNotifyOtherServer()
	if g_OtherServerConnList then
		for serverId, Conn in pairs(g_OtherServerConnList) do
			Gas2GasCall:ShutDownNotifyOtherServer(Conn,g_CurServerId)
		end
	end
end

function ClearConnOtherServerTick()
	for servid, tick in pairs(g_ConnOtherServerTickTbl) do
		UnRegisterTick(tick)
		g_ConnOtherServerTickTbl[servid] = nil
	end
	g_ConnOtherServerTickTbl = {}
end






------------------------������һЩΪ��ʹ�÷������ķ�װ------------------------
Gas2GasAutoCall = {}

local mt = {__index = function(t, k)
		return function(autoTbl, conn, ...)
			if not (Gas2GasDef[k] and Gas2GasCall[k]) then
				LogErr("δ����Gas2Gas����", k)
			end
			if conn == g_CurServerId then
				Gas2GasDef[k](Gas2GasDef, conn, ...)
			else
				Gas2GasCall[k](Gas2GasCall, conn, ...)
			end
		end
	end
	}
setmetatable(Gas2GasAutoCall, mt)