engine_require "server/thread/DbTransaction"
gas_require "dbtransaction/DbTransDef"
gas_require "dbtransaction/DbChannel"
gas_require "dbtransaction/CallDbTransDefInc"

local DbFuncTypeTbl = DbFuncTypeTbl
local DbFuncGlobalType = DbFuncGlobalType
local DbFuncLocalType = DbFuncLocalType
local LogErr = LogErr

--����dbbox�ĺ�����������
local function SetDbFuncType(dbFunction, func_type)
	if DbFuncTypeTbl[dbFunction] then
		error("������type�Ѿ��������ˣ��������ٴζ���")
	end
	DbFuncTypeTbl[dbFunction] = func_type
end

function SetDbGlobalFuncType(dbFunction)
	SetDbFuncType(dbFunction, DbFuncGlobalType)
end

function SetDbLocalFuncType(dbFunction)
	SetDbFuncType(dbFunction, DbFuncLocalType)
end


--���û�����ã���Ĭ����global��
local function GetDbFuncType(dbbox, func_name)
	local func = dbbox[func_name]
	
	local func_type = DbFuncTypeTbl[func]
	if not func_type then
		return DbFuncGlobalType
	end
	
	return func_type
end


local DbTransType = DbTransType
local DbProcessResult = DbProcessResult

local function HandleFuncResult(...)
	local funcResult = {...}
	funcResult.n = select("#", ...)
	return funcResult
end

--���Db2Gas����ʱ��ӵ� ��С����id �ı��
local function ClearFunc(isSucceed)
	local co = coroutine.running()
	local processResult = DbProcessResult[co]
	if processResult == nil then  --δ��ʼ����
		return
	end
	
	DbProcessResult[co] = nil  --DbProcessResult �ǹ���key��weak��, �������︴�ƿ�table Ҳ�����ڴ�й¶. �������Ƿ��㲻��Ҫ���ж�
	if processResult["FlushDbCall"] then
		local ServerMsgDB = RequireDbBox("ServerMsgDB")
		for serverId, minId in pairs(processResult["FlushDbCall"]) do
			ServerMsgDB.RemoveUnreadyMarkById(serverId, minId)
		end
	end
end

local function GlobalDbEntryFunc(func, data, funcname, channel)
	--���������ȫ�����Ļ�ȡ
	if not g_DbChannelMgr._m_WaitingGlobalChannel then
		g_DbChannelMgr._m_WaitingGlobalChannel = {}
	end
	if not g_DbChannelMgr._m_WaitingGlobalChannel[funcname] then
		g_DbChannelMgr._m_WaitingGlobalChannel[funcname] = {}
		g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_RequestTime = GetProcessTime()
		g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Channels = channel
		g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Count = 0
	end
	g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Count = g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Count + 1
	
	g_DbChannelMgr:RequestGlobalChannel(unpack(channel))
	
	g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Count = g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Count - 1
	if g_DbChannelMgr._m_WaitingGlobalChannel[funcname].m_Count == 0 then
		g_DbChannelMgr._m_WaitingGlobalChannel[funcname] = nil
	end

	local co = coroutine.running()
	
	DbTransEntryType[co] = DbFuncGlobalType
	DbProcessResult[co] = {}				--���ɼ�¼ �˴�callDbTransȫ������Ҫ��callback����⴦�������
	
	if not g_DbChannelMgr._m_ExecutingSql then
		g_DbChannelMgr._m_ExecutingSql = {}
	end
	if not g_DbChannelMgr._m_ExecutingSql[funcname] then
		g_DbChannelMgr._m_ExecutingSql[funcname] = {}
		g_DbChannelMgr._m_ExecutingSql[funcname].m_RequestTime = GetProcessTime()
		g_DbChannelMgr._m_ExecutingSql[funcname].m_Channels = channel
		g_DbChannelMgr._m_ExecutingSql[funcname].m_Count = 0
	end

	g_DbChannelMgr._m_ExecutingSql[funcname].m_Count = g_DbChannelMgr._m_ExecutingSql[funcname].m_Count + 1

	local funcResult = HandleFuncResult(func(data))		--ִ��Ҫ���ĺ���
	
	g_DbChannelMgr._m_ExecutingSql[funcname].m_Count = g_DbChannelMgr._m_ExecutingSql[funcname].m_Count - 1
	if g_DbChannelMgr._m_ExecutingSql[funcname].m_Count == 0 then
		g_DbChannelMgr._m_ExecutingSql[funcname] = nil
	end
	
	return DbProcessResult[co], funcResult
end


local function LocalDbEntryFunc(func, data, funcname, channel)
	local co = coroutine.running()
	
	DbTransEntryType[co] = DbFuncLocalType
	DbProcessResult[co] = {}				--���ɼ�¼ �˴�callDbTransȫ������Ҫ��callback����⴦�������
	
	if not g_DbChannelMgr._m_ExecutingSql then
		g_DbChannelMgr._m_ExecutingSql = {}
	end
	if not g_DbChannelMgr._m_ExecutingSql[funcname] then
		g_DbChannelMgr._m_ExecutingSql[funcname] = {}
		g_DbChannelMgr._m_ExecutingSql[funcname].m_RequestTime = GetProcessTime()
		g_DbChannelMgr._m_ExecutingSql[funcname].m_Channels = channel
		g_DbChannelMgr._m_ExecutingSql[funcname].m_Count = 0
	end

	g_DbChannelMgr._m_ExecutingSql[funcname].m_Count = g_DbChannelMgr._m_ExecutingSql[funcname].m_Count + 1

	local funcResult = HandleFuncResult(func(data))		--ִ��Ҫ���ĺ���
	
	g_DbChannelMgr._m_ExecutingSql[funcname].m_Count = g_DbChannelMgr._m_ExecutingSql[funcname].m_Count - 1
	if g_DbChannelMgr._m_ExecutingSql[funcname].m_Count == 0 then
		g_DbChannelMgr._m_ExecutingSql[funcname] = nil
	end
	
	return DbProcessResult[co], funcResult
end

function CheckDbFuncType(dbbox, func_name)
	local co = coroutine.running()
	local co_type = DbTransEntryType[co] 
	
	--�����ڵ�trans��global�ģ���ô��������������func���ܹ�����
	if co_type == DbFuncGlobalType then
		return
	end

	local func_type = GetDbFuncType(dbbox, func_name)
	if func_type ~= 	co_type then
		local err = "��db trans��ڵ���ΪLocalģʽ�������ڲ����ú���" .. func_name .. " ΪGlobalģʽ"
		error(err)
	end
end

function CallDbTransaction(dbbox_name, funcname, callback, data, errfunc, tickIndex, ...)
	local filename = g_DBTransDef[dbbox_name]
	
	local trans_type = ""
	
	local function CheckCallDbTrans(...)	
		if filename == nil or funcname == nil then
			error("CallDbTrans��filename����funcname��������Ϊ��")
		end
		
		local entry = RequireDbBox(dbbox_name)
			
		if entry == nil then
			local err = filename .. " ������"
			error(err)
		end
		
		local func = entry[funcname]
	
		if func == nil then
			local err = filename .. " ���溯�� " .. funcname .. " ������"
			error(err)
		end
		
		trans_type = GetDbFuncType(entry, funcname)
		
		if type(data) ~= "table" then
			local err = filename .. " ���溯�� " .. funcname .. " ���õ�ʱ�����ݲ���table"
			error(err)
		end
		local process_data = GetTblFromPool()
		process_data["data"] = data
		process_data["filename"] = filename
		process_data["funcname"] = funcname
		process_data["func"] = func
		process_data["callback"] = callback
		process_data["errfunc"] = errfunc
		process_data["tickIndex"] = tickIndex
		process_data["cleanfunc"] = ClearFunc
		process_data["channel"] = {...}
		
		return process_data
	end	
	
	local ret, process_data = pcall(CheckCallDbTrans, ...)
	if not ret then
		LogErr(process_data)
		if errfunc then
			OnHandleDbCallback(nil, false, callback, errfunc, ...)	
		end
			
		OnHandleVMCallback(nil, funcname, tick, ...)
		return
	end

	if trans_type == DbFuncGlobalType then
		process_data["entryfunc"] = GlobalDbEntryFunc
	else
		process_data["entryfunc"] = LocalDbEntryFunc
	end
	
	CoreCallDbTrans(process_data)
	
	ReturnTblToPool(process_data)
end

function CancelTran()
	g_DbChannelMgr:CancelTran()
	ClearFunc()
end
