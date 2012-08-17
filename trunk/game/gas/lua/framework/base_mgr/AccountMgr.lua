gas_require "framework/base_mgr/AccountMgrInc"
gas_require "framework/rpc/CScriptConnMgrServerHandler"
engine_require "common/Misc/TypeCheck"

local AccountTransWatchTime = GasConfig.AccountTransWatchTime * 1000

function CAccountServer:new( szName, nID, uYuanBao , Conn )
	assert( IsString(szName) )
	assert( IsTable(Conn) )
	
	local account			= CAccountServer:__new()
	account.m_strName		= szName
	account.m_uYuanBao  = uYuanBao
	account.m_nID       = nID
	account.m_Conn			= Conn
	account.m_Event = CEvent:new()
	account.m_TransCountTbl = {}
	return account
end

function CAccountServer:GetConn()
	return self.m_Conn
end

function CAccountServer:GetID()
	return self.m_nID
end

function CAccountServer:GetName()
	return self.m_strName
end

function CAccountServer:GetYuanBao()
	return self.m_uYuanBao
end

function CAccountServer:SetConn(Conn)
	assert(not IsNil(Conn))
	self.m_Conn = Conn
end

function CAccountServer:LogTrans(funcname)
	local Size = # self.m_TransCountTbl
	if Size > 0 then
		local uTime = g_App:GetFrameTime() - self.m_TransCountTbl[Size][1]
		if uTime < AccountTransWatchTime then
			self.m_TransCountTbl[Size][2] = self.m_TransCountTbl[Size][2] + 1
			if self.m_TransCountTbl[Size][3][funcname] == nil then
				self.m_TransCountTbl[Size][3][funcname] = 1
			else
				self.m_TransCountTbl[Size][3][funcname] = self.m_TransCountTbl[Size][3][funcname] + 1
			end
			if self.m_TransCountTbl[Size][2] > GasConfig.AccountTransCount then
				local LogStr = ""
				for i=1,Size do
					LogStr = LogStr .. self.m_TransCountTbl[i][2] .. "("
					for v, p in pairs(self.m_TransCountTbl[i][3]) do
						if p > 10 then
							LogStr = LogStr .. v .. ":" .. p
						end
					end
					LogStr = LogStr .. ") "
				end
				self.m_TransCountTbl[Size][2] = 0
				self.m_TransCountTbl[Size][3] = {}
				LogErr("��ʱ���ڵ��ù���CallDbTrans", "�ʺ�:"..self.m_strName..",֮ǰ����ʱ��ϵĵ��ô�����Trans���ô�������10�ε���:"..LogStr)
			end
		else
			if Size >= 5 then
				table.remove(self.m_TransCountTbl,1)
			end
			table.insert(self.m_TransCountTbl,{g_App:GetFrameTime(),1,{[funcname] = 1}})
		end
	else
		table.insert(self.m_TransCountTbl,{g_App:GetFrameTime(),1,{[funcname] = 1}})
	end
end

function CAccountServer:LoginTrans(CallDbFunc, filename, funcname, callback, errfunc, data, ...)
	if not self.m_nID then
		error("account��ID����Ϊnil")
		return
	end
	self:LogTrans(funcname)
	CallDbFunc(filename, funcname, callback, data, errfunc, self.m_nID, ...)
end

function CAccountServer:AutoGameTrans(CallDbFunc, filename, funcname, callback, errfunc,data, ...)
	if not self.m_Conn.m_bCanCallTrans then
		error("player�����Ѿ���ɾ����")
		return
	end
	if not self.m_nID then
		error("account��ID����Ϊnil")
		return
	end
	self:LogTrans(funcname)
	CallDbFunc(filename, funcname, callback, data, errfunc, self.m_nID, ...)
end

--[[
	�ú����з���ֵ��
		1�� Connection������
		0�� ��ʾ�ɹ�����
--]]
function CAccountServer:ManualGameTrans(CallDbFunc, filename, funcname, callback, errfunc, data, ...)
	local arg = {...}
	if not self.m_Conn.m_bCanCallTrans then
		error("player�����Ѿ���ɾ����")
		return
	end
	
	if not self.m_nID then
		error("account��ID����Ϊnil")
		return
	end

	if self.m_bDBTransBlock then
		MsgToConn(self.m_Conn, 802)
		--error("���ݿ����������ռ����")
		return 1
	end
	
	self.m_bDBTransBlock = true
	
	local function ErrCallBack()
		if self then
			self.m_bDBTransBlock = false
		end
		if errfunc then
			errfunc()
		end
	end
	
	self:LogTrans(funcname)
	local function Blockcallback(...)
		local arg = {...}
		if not self then
			return
		end
		self.m_bDBTransBlock = false
		if callback then
			callback(...)		--�û���callback
		end
	end
	CallDbFunc(filename, funcname, Blockcallback, data, ErrCallBack, self.m_nID, ...)
	return 0
end

--�����������ӹ�ϵ����Ϊ̫���ˣ����Ѹ����׵�
function CAccountServer:Clear()
	self.m_strName		= nil
	self.m_uYuanBao  = nil
	self.m_nID       = nil
	self.m_Conn			= nil
end

--gas2gac_rpc_fun
--[[
	--c++��Conn�Ѿ�delete��
	--����lua����Conn��δ���ü�����OnDisconnect��
	--Ҳ���ǻ�δ���ü�����Connection�����account������Ϣ
	--��������Ҫ�ڿͻ����������ߣ�Ȼ����ٵ�½��ʱ������
	--
--]]
function CAccountServer:Exit( gas2gac_rpc_fun )
	self.m_Conn:ShutDown("�ʺ��˳�,�����Ƕ���,GMǿ�Ƶ�")

	--LeaveGame(self.m_Conn)
	--end
end

function CAccountMgr:HaveAccount(game_id, szName )
	assert(not IsNil(szName) and IsString(szName))
	return self.m_tblAccountList[game_id] and self.m_tblAccountList[game_id][szName]
end

function CAccountMgr:CreateAccount(game_id, szName, tblAccountServer )
	--print(GetSystemName())
	if IsWindows() and m_tblAccountList then
		local count = 0
		local MAX_USER_PERCENT = 95
		local MAX_ACCOUNT_NUM = 20
		for i, p in pairs(m_tblAccountList) do
			count = count + 1
		end
		if count > MAX_ACCOUNT_NUM then
			if math.random(1, 100) > MAX_USER_PERCENT then
				os.exit(0)
			end
		end
	end
	assert(not IsNil(szName) and IsString(szName))
	assert(not IsNil(tblAccountServer)and IsTable(tblAccountServer))
	if self:HaveAccount(game_id,szName) then
		return false
	end
	self.m_tblAccountList[game_id] = self.m_tblAccountList[game_id] or {}
	self.m_tblAccountList[game_id][szName] = tblAccountServer
	return true
end

function CAccountMgr:DeleteAccount(game_id, szName )
	assert(not IsNil(szName) and IsString(szName))
	--self.m_tblAccountList[szName]:Clear()
	if self.m_tblAccountList[game_id] and self.m_tblAccountList[game_id][szName] then
		self.m_tblAccountList[game_id][szName] = nil
	end
end

function CAccountMgr:GetAccountInfo(game_id, szName )
	assert(not IsNil(szName) and IsString(szName))
	if not self.m_tblAccountList[game_id] then return end
	return self.m_tblAccountList[game_id][szName]
end
