--���Կ����ͷ��˷���Ϣ,
--����Gas2GacProList ��ע���rpc����, �����Ҫ�õ��������Ϣ��ȥ Gas2GasProList ��ע��
Gas2GacById = {}


--��ʼ���ֵΪ�˱��ⵥ��������������Id�������(ֻҪ��֤msgId�ǵ����ľ���)
--100���� os.time() < 5.0e9  ���� os.time() * 10000 < 5.0e13  ��lua�ڲ�����1.0e14���ܾ�ȷ��ʾ����
--ÿ���ӵ���Ϣ���ᳬ��10000��,���������ǲ���������� ^_^


--����һ����ʼʱ��,ʹ�ܱ���ʱ���Զ,֧�ֵ���ϢƵ�ʸ���(����10��/��)
local StartDate = {year = 2010, month = 1, day =1}
local MsgSequenceId = (os.time() - os.time(StartDate)) * 100000
PlayerInServerCache = {}
PlayerMessageList = {}

local CharOnlineTbl = {}
local CharNameOnlineTbl = {}

local function InitPlayerLastMsgIdTbl(player, lastMsgIdStr)
	if lastMsgIdStr == nil or lastMsgIdStr == "" then
		local temp = {}
		for serverId in pairs(g_ServerList) do
			temp[serverId] = 0
		end
		player.m_LastCacheMsgId = temp 
	else
		player.m_LastCacheMsgId = loadstring("return {" .. lastMsgIdStr .. "}")()
	end
end

local function RemoveReceivedMsg(charMsgQueue, lastMsgId)
	--ɾ�����չ�����Ϣ
	while charMsgQueue._begin do
		if charMsgQueue._begin._value[4] <=  lastMsgId then
			charMsgQueue:pop()
		else
			break
		end
	end
end



local function SendCurServerMsg(player)
	local charId = player.m_uID
	local charMsgQueue = PlayerMessageList[charId]
	if not charMsgQueue then
		return
	end
	local lastMsgIdTbl = player.m_LastCacheMsgId
	RemoveReceivedMsg(charMsgQueue, lastMsgIdTbl[g_CurServerId])
	
	local iter = charMsgQueue._begin
	while iter do
		local v = iter._value
		--print("�����Լ�ȡ����Ϣ " ,v[4], unpack(v[2], 1, v[3]))
		Gas2Gac[v[1]](Gas2Gac, player.m_Conn, unpack(v[2], 1, v[3]))
		lastMsgIdTbl[g_CurServerId] = v[4]
		iter = iter._next
	end
	
	PlayerMessageList[charId] = nil
end

function PlayerLoginGetMessage(player, ChangeType, lastMsgIdStr)
	InitPlayerLastMsgIdTbl(player, lastMsgIdStr)
	local lastMsgIdTbl = player.m_LastCacheMsgId
	local charId = player.m_uID
	if ChangeType == 1 then --�г�����¼,	ȥ��������������Ϣ
		--print"��¼ȡ��Ϣ----------------------------��ʼ "
		for serverId, otherConn in pairs(g_OtherServerConnList) do
			Gas2GasCall:GetCacheMsg(otherConn, g_CurServerId, charId, lastMsgIdTbl[serverId])
		end
		--�����Լ�������Ϣ
		SendCurServerMsg(player)

		--print"��¼ȡ��Ϣ----------------------------����"
		--�г���ֻɾ������Ϣ
		Gas2GasAutoCall:ClearCacheMsg(GetServerAutoConn(g_CurServerId), charId)
	else
		for serverId in pairs(g_ServerList) do
			Gas2GasAutoCall:ClearCacheMsg(GetServerAutoConn(serverId), charId)
		end
	end
end

local function InsertMessage(charId, msgId, funName, ...)
	--print("InsertMessage", msgId)
	local charMsgQueue = PlayerMessageList[charId]
	if not charMsgQueue then
		charMsgQueue = CQueue:new()
		charMsgQueue.LastSendCount = 0
		PlayerMessageList[charId] = charMsgQueue
	end
	local now = os.time()
	local n = select("#", ...)
	charMsgQueue:push({funName,{...}, n, msgId, now})
	if charMsgQueue:size() - charMsgQueue.LastSendCount >= 2 and now - charMsgQueue:front()[5] < 10 then
		--print("����Ҫ֪ͨ��ȡ" , msgId)
		return false
	end
	return true
end

--����ӵ����跢���ͷ��˵���Ϣ()
function ReceiveServerToClientMsg(funName, Conn, charId, serverId, msgId, ...)
	local player = g_GetPlayerInfo(charId)
	if not (IsCppBound(player) and IsCppBound(player.m_Conn) ) or (player.m_Conn.m_ChangeToServer ~= nil)  then
		return
	end
	if msgId <= player.m_LastCacheMsgId[serverId] then
		return
	end
	--print("�յ���Ϣ " , msgId,  ...)
	Gas2Gac[funName](Gas2Gac, player.m_Conn, ...)
	player.m_LastCacheMsgId[serverId] = msgId
end

function Gas2GasDef:ClearCacheMsg(Conn, charId)
	--print("�����Ϣ!!!!")
	PlayerMessageList[charId] = nil
end

function Gas2GasDef:GetCacheMsg(Conn, serverId, charId, lastMsgId)
	--print ("������ " .. serverId .. " ��ȡ " .. lastMsgId .. " ���ϵ���Ϣ")
	PlayerInServerCache[charId] = serverId --���������λ��
	local charMsgQueue = PlayerMessageList[charId]
	if not charMsgQueue then
		return
	end
	
	RemoveReceivedMsg(charMsgQueue, lastMsgId)
	
	local iter = charMsgQueue._begin
	while iter do
		local v = iter._value
		--print("������ " .. serverId  .. "ȡ����Ϣ  " .. v[4])
		Gas2GasAutoCall[v[1]](Gas2GasAutoCall, Conn, charId, g_CurServerId, v[4], unpack(v[2], 1, v[3]))
		iter = iter._next
	end
	charMsgQueue.LastSendCount = charMsgQueue:size()
	--print("ȡ��" ,charMsgQueue:size(), "����Ϣ")
end


function Gas2GasDef:NotifyPlayerGetMsg(Conn, isSrcMsg, srcServerId, charId)
	--print ("Gas2GasDef:NotifyPlayerGetMsg ", srcServerId)
	local player = g_GetPlayerInfo(charId)
	if IsCppBound(player) and IsCppBound(player.m_Conn) then
		if isSrcMsg then
			--print("cache����")
		end
		if player.m_Conn.m_ChangeToServer == nil then
			--print("������ɫ����,ȥ������ " .. srcServerId .. " ȡ " .. player.m_LastCacheMsgId[srcServerId] .. " ���ϵ���Ϣ")
			Gas2GasCall:GetCacheMsg(GetServerConn(srcServerId), g_CurServerId, charId, player.m_LastCacheMsgId[srcServerId])
		end
		return
	end
	if isSrcMsg then --ԭ��Ϣ��ת����������
		--print("cacheδ����, ת��������")
		for id, otherConn in pairs(g_OtherServerConnList) do
			if id ~= srcServerId then
				Gas2GasCall:NotifyPlayerGetMsg(otherConn, false, srcServerId, charId)
			end
		end
	end
end



function Gas2GacByIdAllFunDo(funName, charId, ...)

	if not IsNumber(charId) or charId == 0 then
		LogErr("����Gas2GacById:" .. funName .. "   ����charId ����ȷ",  "charId = " .. tostring(charId))
		return
	end
	--print ("���� Gas2GacById ����Ϣ", funName)
	local player = g_GetPlayerInfo(charId)
	if IsCppBound(player) and IsCppBound(player.m_Conn) and player.m_Conn.m_ChangeToServer == nil then
		--print("��ɫ�ڱ���ֱ�ӷ�", MsgSequenceId ," ��Ϣ:", ...)
		if PlayerMessageList[charId] then
			SendCurServerMsg(player)
			PlayerMessageList[charId] = nil
		end
		local ret, msg = apcall(Gas2Gac[funName],Gas2Gac, player.m_Conn, ...)
		if not ret then
			LogErr("����Gas2GasById:" .. funName .. "  ����" .. tostring(msg))
		end
		return
	end 
	
	if not CharOnlineTbl[charId] then --���߽�ɫ��������Ϣ
		return
	end
	--��ɫ���� �ŵ���Ϣ�б���,�ȴ���ɫ���ڵķ�������ȡ
	local mustNotify = InsertMessage(charId, MsgSequenceId, funName, ...)
	
	if mustNotify then
		--֪ͨ��ҹ���ȡ��Ϣ
		local cacheServerId = PlayerInServerCache[charId]
		if cacheServerId and cacheServerId ~= g_CurServerId then
			--print("��ɫ���ڱ��� ������� " .. cacheServerId .. "����ȡ��Ϣ֪ͨ  msdId:", MsgSequenceId)
			Gas2GasCall:NotifyPlayerGetMsg(g_OtherServerConnList[cacheServerId], true, g_CurServerId, charId)
		else
			--print("��ɫ���ڱ���    Ҳû�н�ɫ���ڷ�������cache, ֱ�ӹ㲥  msdId:", MsgSequenceId)
			for id, otherConn in pairs(g_OtherServerConnList) do
				Gas2GasCall:NotifyPlayerGetMsg(otherConn, false, g_CurServerId, charId)
			end
		end
	end
	MsgSequenceId = MsgSequenceId + 1
end

local function AutoDefGas2GasFun(funName)
	local str = 
	[[
		function Gas2GasDef:%s(serverConn, charId, serverId, msgId, ...)
			--print("�յ��Զ��������Ϣ")
			ReceiveServerToClientMsg("%s", serverConn, charId, serverId, msgId, ...)
		end 
	]]
	str = string.format(str, funName, funName)
	loadstring(str)()
end

local function AutoDefGas2GacByIdFun(funName)
	local str = 
	[[
		function Gas2GacById:%s(charId, ...)
			--print("�յ��Զ��������Ϣ")
			Gas2GacByIdAllFunDo("%s", charId, ...)
		end 
	]]
	str = string.format(str, funName, funName)
	loadstring(str)()
end

--������Ҫ�����ͷ��˷���Rpc���� �ķ�������ͨ�ź���
local function DefCrossServerToGacFun ()
	for funName in pairs(CrossServerToGacList) do
		AutoDefGas2GasFun(funName)
		AutoDefGas2GacByIdFun(funName)
	end
end


DefCrossServerToGacFun()



function Db2Gas:CharLogout(data)
	local charId = data[1]
	local charName = data[2]
	CharOnlineTbl[charId] = nil
	CharNameOnlineTbl[charName] = nil
	
	PlayerInServerCache[charId] = nil
	PlayerMessageList[charId] = nil
	ClearPlayerLastServerData(charId)
end

function Db2Gas:CharLogin(data)
	local charId = data[1]
	local charName = data[2]
	CharOnlineTbl[charId] = true
	CharNameOnlineTbl[charName] = true
end

local function ResetOnlineInfo(onlineInfo)
	CharOnlineTbl = {}
	CharNameOnlineTbl = {}
	for i = 0, onlineInfo:GetRowNum() -1 do
		CharOnlineTbl[onlineInfo:GetData(i,0)] = true
		CharNameOnlineTbl[onlineInfo:GetData(i,1)] = true
	end
end

function Db2Gas:UpdateOnlineInfo(data)
	local function CallBack(onlineInfo)
		ResetOnlineInfo(onlineInfo)
	end
	CallDbTrans("MultiServerDB", "GetOnlineInfo", CallBack, {})
end

function DbCallBack:SetOnlineInfo(onlineInfo)
	ResetOnlineInfo(onlineInfo)
end



--ֻ������Ԥ�ж�.   ������Ҫ�߼�Ҫ�����ݿ�Ϊ׼
function CheckPlayerIsOnline(charId)
	return CharOnlineTbl[charId]
end

function CheckPlayerIsOnlineByName(charName)
	return CharNameOnlineTbl[charName]
end