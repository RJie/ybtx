Db2Gas = {}
DbCallBack = {}


--local id = 0
--
--function Db2Gas:TestDbCall(data)
--	--print("TestDbCall")
--end

--local function testTick()
--	if g_CurServerId == 1 then
--		CallDbTrans("ServerMsgDB", "TestDbCall", nil, {1})
--	else
--		CallDbTrans("ServerMsgDB", "TestDbCall", nil, {2})
--	end
--end

local MinArgId = 0

function Gas2GasDef:GetDbCall(Conn, msgId)
	if (not g_App) or g_App.m_bCallDbHalted then --�ط�ʱ����ִ�����ݿ����
		return
	end

	local function CallBack(msgTbl, minArgId)

		--print("Msg����:", #msgTbl)

		for i, v in ipairs(msgTbl) do
			assert(IsFunction(Db2Gas[v[1]]), "δ�����function Db2Gas:" .. v[1])
			Db2Gas[v[1]](Db2Gas, v[2])
		end
		if minArgId then
			MinArgId = minArgId
		end
	end
	local data = {}
	data["msgId"] = msgId
	CallDbTrans("ServerMsgDB", "GetDbCall", CallBack, data, 666666)
	
--	if not g_TestTest then
--		if g_CurServerId == 1 then
--			g_TestTest = RegisterTick("TestTick", testTick, 1000)
--		else
--			g_TestTest = RegisterTick("TestTick", testTick, 20000)
--		end
--	end
end

local function OnClearArgTick()
	if MinArgId > 10000 then
		local data = {}
		data["MinArgId"] = MinArgId - 10000
		CallDbTrans("ServerMsgDB", "ClearArg", nil, data, 666666)
	end
end

g_ClearArgTick =  RegisterTick("ClearArgTick", OnClearArgTick, 5 * 60 * 1000) --5��������һ�β���arg

function FlushDbCall(data)
	for serverId, msgId in pairs(data) do
		Gas2GasAutoCall:GetDbCall(GetServerAutoConn(serverId), msgId)
	end
end


function Db2CallBack(data)
	for _, v in ipairs(data) do
		assert(DbCallBack[v[1]], "δ����� DbCallBack ���� : " .. v[1])
		local arg = v[2]
		DbCallBack[v[1]](DbCallBack, unpack(arg, 1, arg.n))
	end
end

