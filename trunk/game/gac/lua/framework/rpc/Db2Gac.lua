local MsgList = {}  --ʹ��lastId ������ ��ʽ���� (�м���̺ܿ�����һ���ϵ�����)
local MsgBuffer = {} --����ͬid ��msg, ����Db2GacEnd ��ʾ��� Ȼ���ٲ��� MsgList ��
local WaitingIdTbl = {} --��¼�ϴ�ִ�����id

local function CheckReady(typeName)
	local waitId = WaitingIdTbl[typeName]  or 0
	local node = MsgList[typeName][waitId]
	if not node then
		return
	end
	
	for _, v in ipairs(node.MsgTbl) do
		local funName = v[1]
		local arg = v[2]
		Gas2Gac[funName](Gas2Gac, g_Conn, unpack(arg, 1, arg.n))
	end
	if node.Tick then
		UnRegisterTick(node.Tick)
		node.Tick = nil
	end
	WaitingIdTbl[typeName] = waitId + 1
	MsgList[typeName][waitId] = nil
	CheckReady(typeName)
end

local function InsertMsg(typeName, msgId, node)
	local tbl = MsgList[typeName]
	if not tbl then
		tbl = {}
		MsgList[typeName] = tbl
	end
	assert(tbl[msgId] == nil, "�ظ���ǰ����Ϣid")
	tbl[msgId] = node
	
	local function OnTick()
		UnRegisterTick(node.Tick)
		node.Tick = nil
		local waitingId = WaitingIdTbl[typeName] or 0
		local msg = "����: %s, �ȴ���ϢId: %d, ��ǰ��ʱ��Ϣ: [id: %d,  ������: %s]"
		local funcName = ""
		for _,v in ipairs(node.MsgTbl) do
			funcName = funcName .. v[1] .. ", "
		end
		msg = string.format(msg, typeName, waitingId, msgId, funcName)
		--LogErr("Db2Gac��Ϣ��ʱ, �����Ƿ������Ͽ�����, �򳬼���,  �ͻ�����������", msg)
		ClearDb2GacTimeOutTick()
		if IsCppBound(g_Conn) then
			g_Conn:ShutDownByMsg("Db2Gac��Ϣ��ʱ, �����Ƿ������Ͽ�����, �򳬼���,  �ͻ�����������")
		end
	end
	node.Tick = RegisterTick("CheckDb2GacTimeOutTick", OnTick, 60000)
	CheckReady(typeName)
end


function TransactDb2Gac(funName, typeName, msgId, isEnd,...)
	local arg = {...}
	arg.n = select("#", ...)
	
	if not MsgBuffer[typeName] then
		MsgBuffer[typeName] = {}
	end
	local tbl = MsgBuffer[typeName][msgId]
	if not tbl then
		tbl = {}
		tbl.MsgTbl = {}
		MsgBuffer[typeName][msgId] = tbl
	end
	table.insert(tbl.MsgTbl, {funName, arg})
	
	if isEnd then
		InsertMsg(typeName, msgId, tbl)
		MsgBuffer[typeName][msgId] = nil
	end
end


local function AutoDefDb2GacFunction(funName)
	local str = [[
		function Gas2Gac:_Db2%s(conn, ...)
			TransactDb2Gac("%s", ...)
		end
	]]
	str = string.format(str, funName, funName)
	loadstring(str)()
end


--�Զ�����Db2Gac�İ�װ����
AliasDoFile("gac_gas", "framework/rpc/Gas2GacProList")

for funName in pairs(Db2GacFunList) do
	AutoDefDb2GacFunction(funName)
end



function Gas2Gac:TestDb2Gac(conn, n, s)
	print("ԭ---------",  n, s, "      ",WaitingIdTbl["a"])
end



local function  ReStartMsg(typeName) --����С����Ϣid, ��������
	local minId = nil
	for msgId in pairs(MsgList[typeName]) do
		if minId ==nil or msgId < minId then
			minId = msgId
		end
	end
	WaitingIdTbl[typeName] = msgId
	CheckReady(typeName)
end

function ClearDb2GacTimeOutTick()
	for _, list in pairs(MsgList) do
		for _, node in pairs(list) do
			if node.Tick then
				UnRegisterTick(node.Tick)
				node.Tick = nil
			end
		end
	end
end

function ResetDb2GacData()
	ClearDb2GacTimeOutTick()

	MsgList = {} 
	MsgBuffer = {}
	WaitingIdTbl = {}
end


function Gas2Gac:ClearDb2GacMsg()
	ResetDb2GacData()
end