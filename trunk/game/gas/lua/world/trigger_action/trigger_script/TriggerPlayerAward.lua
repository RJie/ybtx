local function AddMoneyAward(Arg, Trigger, Player)
	if not IsCppBound(Player) then
		return
	end
	if Player.m_Properties:GetType() == ECharacterType.Player then
		local AddMoneyFun = g_TriggerMgr:GetExpressions(Arg[1])
		local nMoney = AddMoneyFun(Player:CppGetLevel())
		local type = 2
		if Arg[2] == "�ǰ�" then
			type = 1
		end
		local function callback(result,uMsgID)
			if IsNumber(uMsgID) then
				MsgToConn(Player.m_Conn,uMsgID)
			end
			if IsCppBound(Player) then
				if result then
					MsgToConn(Player.m_Conn, 3602, nMoney)
				end
			end
		end
		local data = {}
		data["char_id"] = Player.m_uID
		data["money_count"] = nMoney
		data["addType"]	= event_type_tbl["��Ҳ�trap��Ǯ"]
		data["money_type"] = type
		CallAccountAutoTrans(Player.m_Conn.m_Account, "MoneyMgrDB", "AddMoneyForRpc", callback, data)
	end
end


local function AddExpAward(Arg, Trigger, Player)
	if not IsCppBound(Player) then
		return
	end
	if Player.m_Properties:GetType() == ECharacterType.Player then
		local AddExpFun = g_TriggerMgr:GetExpressions(Arg[1])
		local addExp = AddExpFun(Player:CppGetLevel())
		local function callback(CurLevel,LevelExp)
			if IsCppBound(Player) and CurLevel then
				if CurLevel then
					local AddExpTbl = {}
					AddExpTbl["Level"] = CurLevel
					AddExpTbl["Exp"] = LevelExp
					AddExpTbl["AddExp"] = addExp
					AddExpTbl["uInspirationExp"] = 0
					CRoleQuest.AddPlayerExp_DB_Ret(Player, AddExpTbl)
				end
			end
		end
		local data = {}
		data["char_id"] = Player.m_uID
		data["addExp"] = addExp
		data["addExpType"] = event_type_tbl["��Ҳ�Trap������"]
		
		OnSavePlayerExpFunc({Player})
		CallAccountManualTrans(Player.m_Conn.m_Account, "RoleQuestDB", "AddExp", callback, data)
	end
end


local function AddItem(Arg, Trigger, Player)
	local PlayerID = Player.m_uID;	--���ID]
	local TaskName = Arg[1]--��������	
	local ItemType = Arg[2]--��Ʒ����
	local ItemName = Arg[3]--��Ʒ����
	local ItemNum = Arg[4]--��Ʒ����
	local questneed				--�������

	local parameter = {}
	parameter["sQuestName"] = TaskName
	parameter["char_id"]		= PlayerID
	parameter["nType"]		= ItemType
	parameter["sName"] 		= ItemName
	parameter["nCount"]		= ItemNum
	parameter["sceneName"]		= Player.m_Scene.m_SceneName
	local Conn = Player.m_Conn
	local function CallBack(result)
		if IsNumber(result) then
			if result == 3 then
				if IsCppBound(Conn) then
					MsgToConn(Conn,160000)
				end
			end
			return
		end
		CRoleQuest.add_item_DB_Ret_By_Id(PlayerID,ItemType,ItemName,ItemNum,result)
	end
	if IsCppBound(Conn) and Conn.m_Account then
		CallAccountAutoTrans(Conn.m_Account, "RoleQuestDB","IntoTrapAddItem", CallBack, parameter)
	end
end


local function AddItemAward(Arg, Trigger, Player)
	if Player.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	if Player.m_Properties:GetType() == ECharacterType.Npc then
		local PlayerID = Trigger.m_OwnerId   --�ڷ�
		if PlayerID == nil then
			PlayerID = Player.m_OwnerId   --��Ȼ
			if PlayerID == nil then
				return
			end
		end
		Player = g_GetPlayerInfo(PlayerID)
		if not Player then
			return
		end
	end
	AddItem(Arg, Trigger, Player)
end


local funcTbl = {

	["��Ʒ"]		= AddItemAward,
	["Ǯ"]		= AddMoneyAward,
	["����"]		= AddExpAward,
}

local function Script(Arg, Trigger, Player)
	local type = Arg[1]
	if IsFunction (funcTbl[type]) then
		funcTbl[type](Arg[2], Trigger, Player)
	end
end

return Script