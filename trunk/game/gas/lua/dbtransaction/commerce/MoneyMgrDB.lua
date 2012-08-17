
gac_gas_require "framework/common/CMoney"
local g_MoneyMgr = CMoney:new()
local SkipGBSAuth = GasConfig.SkipGBSAuth
local event_type_tbl = event_type_tbl
local g_ItemInfoMgr = g_ItemInfoMgr or CItemInfoMgr:new()
local MoneyManagerDB	=	CreateDbBox(...)
local MoneyManager		=	{}

local function GetUpperlimitByLevel(nLevel)
	if nLevel >= 1 and nLevel <= 20 then
		return 1000000
	elseif nLevel <= 40 then
		return 5000000
	elseif nLevel <= 80 then
		return 100000000
	end
end

function MoneyManagerDB.BeOverUpperLimit(nCharID,addnum)
	local now_money = MoneyManagerDB.GetMoneyByType(nCharID,1) or 0
	
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local player_level = CharacterMediatorDB.GetPlayerLevel(nCharID)
	
	local DepotDB = RequireDbBox("DepotDB")
	local depot_money = DepotDB.GetDepotMoney(nCharID)
	
	return (now_money + depot_money + addnum) > GetUpperlimitByLevel(player_level)

end

-----------------------------------------------------------------------------
local StmtDef = {
	"_GetMoney",
	[[
		select cm_uMoney from tbl_char_money where cs_uId=?
	]]
}
DefineSql(StmtDef, MoneyManager)
--- @brief �õ�������ҵ�money����
--- @return ʧ�ܷ���nil
function MoneyManagerDB.GetMoney(player_id)
	local tbl = MoneyManager._GetMoney:ExecStat(player_id)
	if tbl:GetRowNum() == 0 then
		return nil
	else
		return tbl:GetData(0, 0)
	end
end
------------------------------------------------------------------------------------
local StmtDef = {
	"_GetBindingMoney",
	[[
		select cm_uBindingMoney from tbl_char_money where cs_uId=?
	]]
}
DefineSql(StmtDef, MoneyManager)

function MoneyManagerDB.CostMoneyByTrans(data)
	local flag = data["isBind"]
	local money = data["money"]
	local player_id = data["playerId"]
	if flag then
		local fun_info = g_MoneyMgr:GetFuncInfo("SpecialTransport")
		local bFlag, uMsgID = MoneyManagerDB.AddMoneyByType(fun_info["FunName"],fun_info["SpecialNpc"],player_id, 2, money,nil,event_type_tbl["����NPC����"])
		return bFlag, uMsgID
	else
		local fun_info = g_MoneyMgr:GetFuncInfo("SpecialTransportUnBind")
		local bFlag, uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["SpecialTransportUnBind"], player_id, money, nil, event_type_tbl["����NPC���ͷǰ󶨽��"])  --log����
		return bFlag, uMsgID
	end
end

function MoneyManagerDB.GetBindingMoney(player_id)
	local tbl = MoneyManager._GetBindingMoney:ExecSql("n", player_id)
	if tbl:GetRowNum() == 0 then
		return 0
	else
		return tbl:GetData(0, 0)
	end
end
------------------------------------------------------------------------------------
local StmtDef = {
	"_GetBindingTicket",
	[[
		select cm_uBindingTicket from tbl_char_money where cs_uId=?
	]]
}
DefineSql(StmtDef, MoneyManager)
--- @brief �õ���ɫ�İ�Ӷ��������
--- @return ʧ�ܷ���nil
function MoneyManagerDB.GetBindingTicket(player_id)
	local tbl = MoneyManager._GetBindingTicket:ExecSql("n", player_id)
	if tbl:GetRowNum() == 0 then
		return nil
	else
		return tbl:GetData(0, 0)
	end
end
------------------------------------------------------------------------------------
local StmtDef = {
	"_AddMoney",
	[[
		update tbl_char_money set cm_uMoney = cm_uMoney+? where cs_uId=? and cm_uMoney + ? >= 0 
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_CountFunAndMod",
	[[
		select count(*) from tbl_money_corrency_limit where mcl_sFunName = ? and mcl_sModule = ?
	]]
}
DefineSql(StmtDef, MoneyManager)


function MoneyManagerDB.CountFunAndMod(sFunction,sModule)
	local res = MoneyManager._CountFunAndMod:ExecSql("n",sFunction,sModule)
	return res:GetNumber(0,0)
end

local StmtDef = {
	"_GetRmbMoney",
	[[
		select cm_uRmbMoney from tbl_char_money where cs_uId = ?
	]]
}
DefineSql(StmtDef, MoneyManager)
local StmtDef = {
	"_UpdateRmbMoney",
	[[
		update tbl_char_money set cm_uRmbMoney = cm_uRmbMoney + ? where cm_uRmbMoney + ? >= 0 and cs_uId = ?
	]]
}
DefineSql(StmtDef, MoneyManager)

function MoneyManagerDB.GetRmbMoney(char_id)
	local res = MoneyManager._GetRmbMoney:ExecStat(char_id)
	if res:GetRowNum() == 0 then return 0 end
	return res(1,1)
end

function MoneyManagerDB.AddRmbMoney(char_id,up_rmb)
	MoneyManager._UpdateRmbMoney:ExecStat(up_rmb,up_rmb,char_id)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
			error("�޸�rmb��Ǯʧ��")
	end
	return true
end

local tblOutputMoneyFunc = {
	["Quest"] = true,
	["GMcmd"] = true,
	["RobResourceAward"] = true,
	["Trap"] = true,
}
--���˽ӿ���������erating����Ǯ���ĺͽ�Ǯ��ͨ��Ϣ�ġ�
function MoneyManagerDB.UpdateRmbMoney(char_id,addnum,IB_Code,addType,EventID,target_id,target_money,ItemType,ItemName,ItemCount)
	local AgiotageDB = RequireDbBox("AgiotageDB")
	if addnum > 0 and tblOutputMoneyFunc[IB_Code] then
		if not AgiotageDB.AddEverydayOutput(char_id,6,addnum) then return end
	end
	if addnum > 0 then return true end
	--if SkipGBSAuth == 1 then return true end
	if char_id == target_id then return true end
	local fun_info = g_MoneyMgr:GetFuncInfo(IB_Code)
	local Chinese_Func = fun_info["Description"]
	local IBCodeType = 0
	addnum = -addnum
	local every_price = addnum
	if ItemCount and ItemCount > 0 then
			IBCodeType = 1
			every_price = addnum/ItemCount
			Chinese_Func = g_ItemInfoMgr:GetItemLanInfo(ItemType,ItemName,"DisplayName")
	end
	local LogMgr = RequireDbBox("LogMgrDB")
	local ex = RequireDbBox("Exchanger")
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local char_level = CharacterMediatorDB.GetPlayerLevel(char_id)
	local char_ip = ex.getPlayerIp(char_id)
	local argTbl = {}
	argTbl.char_id 				= char_id
	argTbl.char_ip 				= char_ip
	argTbl.char_level 		= char_level
	argTbl.IB_Code 				= Chinese_Func
	argTbl.IBCodeType 		= IBCodeType
	argTbl.uPrice 				= every_price
	local bDestroyMoney 	= false
	local bExchangeMoney 	= false
	local rmb_money = MoneyManagerDB.GetRmbMoney(char_id)
	local up_rmb 		= 0
	local	up_money 	= 0
	if 	rmb_money 	>= addnum then
		up_rmb 		= addnum
	else
		up_rmb 		= rmb_money
		up_money 	= addnum - up_rmb
	end
	local FoldLimit = 1
	if ItemType and ItemName then
		FoldLimit =  g_ItemInfoMgr:GetItemInfo(ItemType,ItemName,"FoldLimit") or 1
	end
	if not ItemCount or FoldLimit > 1 then
			--��npc�̵������Ʒ�ɵ���
			local target_add_rmb = 0
			local destroy_rmb = up_rmb
			local destroy_money = up_money
			if target_id and target_money and target_money > 0 then
					--������ͨ��targetid��Ǯ
					if target_money <= up_rmb then
							target_add_rmb 	= target_money
							destroy_rmb 		= up_rmb - target_money
					else
							target_add_rmb 	= up_rmb
							destroy_rmb 		= 0
							destroy_money 	=  up_money - (target_money - target_add_rmb)
					end
					if target_add_rmb >0 then
						if not MoneyManagerDB.AddRmbMoney(target_id,target_add_rmb) then return end
					end
					if ex.GetUserIDByCharId(char_id) ~= ex.GetUserIDByCharId(target_id) and target_add_rmb > 0 then
						if not AgiotageDB.AddMoneyExchangeInfo(char_id,target_id,5,target_add_rmb) then return end
					end
					local target_level = CharacterMediatorDB.GetPlayerLevel(target_id)
					local succ,uEventId 		= LogMgr.PlayerMoneyModify( EventID, 3,target_add_rmb,target_id,MoneyManagerDB.GetRmbMoney(target_id),addType,target_level)
					if not succ then 
						error("��¼�޸������logʧ��")
					end
					EventID = uEventId
			end
			
			ItemCount 						= ItemCount or 1
			if destroy_rmb%every_price > 0 or destroy_money%every_price > 0 then
				--����һ��subjectΪ5��6��ϵ�
				argTbl.buy_count 		= 1
				local detail_id = nil
				if destroy_rmb%every_price > 0 then
					argTbl.subject_id 	= 5 
					argTbl.uPrice 			= destroy_rmb%every_price
					detail_id 		= AgiotageDB.AddIBPayInfo(argTbl)
					if not detail_id then return end
				end
				if destroy_money%every_price > 0 then
					argTbl.subject_id 	= 6 
					argTbl.uPrice 			= destroy_money%every_price
					argTbl.detail_id 		= detail_id 
					local detail_id 		= AgiotageDB.AddIBPayInfo(argTbl)
					if not detail_id then return end
				end
				ItemCount = ItemCount -1
			end
			local RMB_buy_count 	= math.floor(destroy_rmb/every_price)
			local money_buy_count = math.floor(destroy_money/every_price)
			if destroy_rmb  >= ItemCount*every_price then
				RMB_buy_count 	= ItemCount
			end
			if RMB_buy_count > 0 then
				argTbl.buy_count 		= RMB_buy_count
				argTbl.subject_id 	= 5 --�һ���
				argTbl.detail_id 		= nil
				argTbl.uPrice 			=	every_price
				if not AgiotageDB.AddIBPayInfo(argTbl) then return end
			end
			if money_buy_count > 0 then
				argTbl.buy_count 		= money_buy_count
				argTbl.subject_id 	= 6 --��Ϸ������
				argTbl.detail_id 		= nil
				argTbl.uPrice 			=	every_price
				if not AgiotageDB.AddIBPayInfo(argTbl) then return end
			end
			if up_rmb > 0 then
				if not MoneyManagerDB.AddRmbMoney(char_id,-up_rmb) then return end
			end
			if target_add_rmb > 0 then
				bExchangeMoney 	= true
			end
			if destroy_rmb + destroy_money > 0 then
				bDestroyMoney 	= true
			end
	else
		--���ɵ�����Ʒ�ִη�
		argTbl.buy_count 	= 1
		bDestroyMoney 		= true
		for i =1,ItemCount do
			local rmb_money = MoneyManagerDB.GetRmbMoney(char_id)
			local up_rmb 		= 0
			if rmb_money >= every_price then
			 		up_rmb = every_price
			else
					up_rmb = rmb_money
			end
			local detail_id = nil
			if up_rmb > 0 then
					if not MoneyManagerDB.AddRmbMoney(char_id,-up_rmb) then return end
					argTbl.uPrice 		= up_rmb
					argTbl.subject_id = 5 --�һ���
					detail_id 				= AgiotageDB.AddIBPayInfo(argTbl)
					if not detail_id then return end
			end
			local up_money = every_price - up_rmb
			if up_money > 0 then
					argTbl.uPrice 		= up_money
					argTbl.subject_id = 6
					argTbl.detail_id 	= detail_id
					detail_id 				= AgiotageDB.AddIBPayInfo(argTbl)
					if not detail_id then return end
			end
		end
	end
	local totalRmb 			= MoneyManagerDB.GetRmbMoney(char_id)
	local succ,uEventId = LogMgr.PlayerMoneyModify( EventID, 3,-up_rmb,char_id,totalRmb,addType,char_level)
	if not succ then
		error("��¼�޸������logʧ��")
	end
	if bDestroyMoney then
			Db2CallBack("SendIBPayInfo")
	end
	if bExchangeMoney then
			Db2CallBack("SendMoneyExchangeInfo")
	end
	return true
end

--- @brief ��ָ����������money
--- @return ʧ�ܷ���false
--[[
	0��ע�������
	1��sFunction��sModule�����ĸ�ϵͳ���ĸ����ܵ��õģ���gm�����������ƽ�Ǯ��ͨ�õ�
	2��player_id��Ǯ���޸ĵĽ�ɫid
	3��addmoney�����޸ĵĽ�Ǯ��Ŀ������������۳���Ǯ
	4��uEventId��addType�ֱ�����¼�id���¼����ͣ����ڼ�¼log��
	5��target_id��target_money�ֱ����money�����ж���Ǯ��player_id����target_id�ģ����Ǯ�Ȳ�����ͨ��Ҳ���Ǳ�ϵͳ���գ����Ƿŵ��������ط�����ôplayer_id��target_id��һ���ģ�����erating��ƽ�Ǯ��ͨ�ģ����ס��ʼĽ�Ǯ��������Ҫ������������
	6��uEventId��addType��target_id��target_money�ĸ��������Դ�nil��Ҫ�������
	7��ItemName��ItemCount�Ǹ�npc�̵�������־����ʲô��Ʒ��
--]]
function MoneyManagerDB.AddMoney(sFunction,sModule,player_id,addmoney,uEventId,addType,target_id,target_money,ItemType,ItemName,ItemCount)
	if addmoney < 0 then
  	local ItemBagLockDB = RequireDbBox("ItemBagLockDB")
  	--����ʻ��Ƿ�����
  	if ItemBagLockDB.HaveItemBagLock(player_id) then
  		return false,160027
  	end
  end
  
	if MoneyManagerDB.CountFunAndMod(sFunction,sModule) > 0 then
		return false,304
	end
	local addnum = math.floor(addmoney)
	if addnum == 0 then
		return true
	end
	
	if addnum < 0 then
		if not MoneyManagerDB.EnoughMoney(player_id, -addnum) then
			return false,305
		end
	else
		if sFunction ~= "Depot" and MoneyManagerDB.BeOverUpperLimit(player_id,addnum) then
			return false,309
		end
	end
	if not MoneyManagerDB.UpdateRmbMoney(player_id,addnum,sFunction,addType,uEventId,target_id,target_money,ItemType,ItemName,ItemCount) then
		CancelTran()
		return 
	end
	MoneyManager._AddMoney:ExecSql("", addnum, player_id, addnum)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		error("�޸Ľ�Ǯʧ��")
	end
	local LogMgr = RequireDbBox("LogMgrDB")
	local totalMoney = MoneyManagerDB.GetMoneyByType(player_id,1)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local player_level = CharacterMediatorDB.GetPlayerLevel(player_id)
	local succ,uEventId = LogMgr.PlayerMoneyModify( uEventId, 1, addnum,player_id,totalMoney,addType,player_level)
	if not succ then
		error("��¼�޸Ľ�Ǯlogʧ��")
	end
	Db2CallBack("ReturnAddMoney",player_id,1,totalMoney)
	return true,uEventId
end

--�����������ӣ�ɾ��������
--[[
	0��ע�������
	1��sFunction��sModule�����ĸ�ϵͳ���ĸ����ܵ��õģ���gm�����������ƽ�Ǯ��ͨ�õ�
	2��player_id��Ǯ���޸ĵĽ�ɫid��type��Ǯ���ͣ�1������(�������)��2����󶨽�ң�3����Ӷ����
	3��money�����޸ĵĽ�Ǯ��Ŀ������������۳���Ǯ
	4��uEventId�¼�id�����ڼ�¼log�ģ�addType�¼�����
	5��target_id��target_money�ֱ����money�����ж���Ǯ��player_id����target_id�ģ�����erating��ƽ�Ǯ��ͨ�ģ����ס��ʼĽ�Ǯ��������Ҫ������������
	6��uEventId��addType��target_id��target_money�ĸ��������Դ�nil��Ҫ�������
--]]

function MoneyManagerDB.AddMoneyByType(sFunction,sModule,player_id, type, money,uEventId,addType,target_id,target_money,ItemType,ItemName,ItemCount)
	
  if money < 0 then
  	local ItemBagLockDB = RequireDbBox("ItemBagLockDB")
  	--����ʻ��Ƿ�����
  	if ItemBagLockDB.HaveItemBagLock(player_id) then
  		return false,160027
  	end
  end
  
	if MoneyManagerDB.CountFunAndMod(sFunction,sModule) > 0 then
		return false,304
	end
	local nType = tonumber(type)
	if money == 0 then
		return true
	end
	local money = math.floor(money)
	if money < 0 then
		--��Ǯ��ʱ�����ж�Ǯ�Ƿ��㹻
		local bFlag,MsgID = MoneyManagerDB.EnoughMoneyByType(player_id, type, -money)
		if not bFlag then
			return false,MsgID
		end
	end
	if nType == 1 then
		if money > 0 and MoneyManagerDB.BeOverUpperLimit(player_id,money) then
			return false,309
		end
		if not MoneyManagerDB.UpdateRmbMoney(player_id,money,sFunction,addType,uEventId,target_id,target_money,ItemType,ItemName,ItemCount) then
			CancelTran()
			return
		end
		--˵���ǽ��
		MoneyManager._AddMoney:ExecSql("", money, player_id, money)
	elseif nType == 2 then
		--˵���ǰ󶨽��
		MoneyManager._AddBindingMoney:ExecSql("", money, player_id, money, money)
	elseif nType == 3 then
		--˵���ǰ�Ӷ����
		MoneyManager._AddBindingTicket:ExecSql("", money, player_id, money, money)
	else
		return false
	end
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		error("�޸Ľ�Ǯʧ��")
	end
	
	local LogMgr = RequireDbBox("LogMgrDB")
	local totalMoney = MoneyManagerDB.GetMoneyByType(player_id,nType)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local player_level = CharacterMediatorDB.GetPlayerLevel(player_id)
	local succ,uEventId = LogMgr.PlayerMoneyModify( uEventId, nType, money,player_id,totalMoney,addType,player_level)
	if not succ then
		error("��¼�޸Ľ�Ǯlogʧ��")
	end
	Db2CallBack("ReturnAddMoney",player_id,nType,totalMoney)
	return true,uEventId
end

--�������ͻ����Ƿ��㹻
--[[
	1�����(�������)
	2���󶨽��
	3��Ӷ����(��Ӷ����)
--]]
function MoneyManagerDB.EnoughMoneyByType(player_id, type, money)
	local nType = tonumber(type)
	if nType == 1 then
		--˵���ǽ��
		local money_num = MoneyManagerDB.GetMoney(player_id)
		if money_num == nil or  money_num < money then
			return false,305
		end
	elseif nType == 2 then
		--˵���ǰ󶨽��
		local binding_money = MoneyManagerDB.GetBindingMoney(player_id)
		if binding_money == nil or  binding_money < money then
			return false,306
		end
	elseif nType == 3 then
		--˵���ǰ�Ӷ����
		local binding_ticket = MoneyManagerDB.GetBindingTicket(player_id)
		if binding_ticket == nil or  binding_ticket < money then
			return false,308
		end
	end
	return true
end

------------------------------------------------------------------------------------
local StmtDef = {
	--���Ӱ󶨽��
	"_AddBindingMoney",
	[[
		update tbl_char_money set cm_uBindingMoney = cm_uBindingMoney + ? where cs_uId = ? and (? > 0 or cm_uBindingMoney >= -(?))
	]]
}
DefineSql(StmtDef, MoneyManager)
local StmtDef = {
	--���Ӱ�Ӷ���ң�Ӷ����
	"_AddBindingTicket",
	[[
		update tbl_char_money set cm_uBindingTicket = cm_uBindingTicket + ? where cs_uId = ? and (? > 0 or cm_uBindingTicket >= -(?))
	]]
}
DefineSql(StmtDef, MoneyManager)

------------------------------------------------------------------------------------
--- @brief ��ҵĽ�Ǯת��
--- @param [from_cess] �ӷ������۵�˰�ʣ�С����һ��Ϊ��ֵ��Ĭ��nil��ʾ����˰
--- @param [to_cess] �ӽ��շ��۵�˰�ʣ�С����һ��Ϊ��ֵ��Ĭ��nil��ʾ����˰
--- @return ʧ�ܷ���false
function MoneyManagerDB.MoveMoney(from_pid, to_pid, delta, from_cess, to_cess)
	if delta == 0 then
		return true
	end
	-- ��֤Ϊ��from��to�����򽻻�
	if delta < 0 then
		from_pid, to_pid = to_pid, from_pid
		delta = -delta
	end
	-- ����˰��
	if from_cess == nil then
		from_cess = 0
	end
	if to_cess == nil then
		to_cess = 0
	end
	-- ����˫���Ľ��׶�
	local from_add = delta + math.ceil(delta * from_cess)
	local to_add = delta - math.floor(delta * to_cess)
	-- ȷ�Ϸ��������㹻�Ľ�Ǯ
	if MoneyManagerDB.EnoughMoney(from_pid, from_add) then
		-- ��Ǯ����
		if MoneyManagerDB.AddMoney(from_pid, -from_add) then
			if MoneyManagerDB.AddMoney(to_pid, to_add) then
				return true
			else
				MoneyManagerDB.AddMoney(from_pid, from_add)
			end
		end
	end
	return false
end
------------------------------------------------------------------------------------
--- @brief ȷ��������������㹻�Ľ�Ǯ
function MoneyManagerDB.EnoughMoney(player_id, money)
	local money_have = MoneyManagerDB.GetMoney(player_id)
	if money_have == nil or money_have < money then
		return false
	else
		return true
	end
end

function MoneyManagerDB.IsMoneyEnough(data)
	local player_id = data.PlayerId
	local money = data.MoneyNum
	local Func = data.Func
	local FuncName = data.FuncName
	local ModName = data.ModName
	local money_have = MoneyManagerDB.GetMoney(player_id)
	if money_have == nil or money_have < money then
		return false
	else
		local fun_info = g_MoneyMgr:GetFuncInfo(Func)
		local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info[ModName],player_id, -money,nil,event_type_tbl["�Ⱦƿ�Ǯ"])
		return  bFlag,uMsgID
	end
end



function MoneyManagerDB.PlayerAddMoney(data)
	local player_id = data["playerId"]
	local delta = data["nMoney"]
	local fun_info = g_MoneyMgr:GetFuncInfo("GMcmd")
	local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["AddMoney"],player_id, delta,nil,event_type_tbl["GMָ���Ǯ"])
	if not bFlag then
		CancelTran()
		return bFlag,uMsgID
	end
	return bFlag
end

function MoneyManagerDB.GetMoneyByType(player_id,nType)
	if nType == 1 then
		--˵���ǽ��
		return MoneyManagerDB.GetMoney(player_id)
	elseif nType == 2 then
		--˵���ǰ󶨽��
		return MoneyManagerDB.GetBindingMoney(player_id)
	elseif nType == 3 then
		--˵���ǰ�Ӷ����
		return MoneyManagerDB.GetBindingTicket(player_id)
	else
		return 0
	end
end

---------------------------------���˺Ű󶨵�money-----------
local StmtDef = {
	"_GetTicket",
	[[
		select ub_uYuanBao from tbl_user_basic where us_uId=?
	]]
}
DefineSql(StmtDef, MoneyManager)
--- @brief �õ��˺ŵ�Ӷ��������
--- @return ʧ�ܷ���nil
function MoneyManagerDB.GetTicket(user_id)
	local tbl = MoneyManager._GetTicket:ExecStat(user_id)
	if tbl:GetRowNum() == 0 then
		return nil
	else
		return tbl:GetData(0, 0)
	end
end

function MoneyManagerDB.HaveEnoughTicket(user_id,nTicket)
	local total_ticket = MoneyManagerDB.GetTicket(user_id)
	
	return  total_ticket >= nTicket
end

local StmtDef = {
	"_AddTicket",	
	[[
		update tbl_user_basic set ub_uYuanBao = ub_uYuanBao + ? where us_uId = ? and (? > 0 or ub_uYuanBao >= -(?))
	]]
}
DefineSql(StmtDef, MoneyManager)
function MoneyManagerDB.AddTicket(user_id,nTicket,sFunction,sModule,nEventType)
	if MoneyManagerDB.CountFunAndMod(sFunction,sModule) > 0 then
		return false,304
	end
	local tbl = MoneyManager._AddTicket:ExecStat(nTicket,user_id,nTicket,nTicket)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		error("�޸Ľ�Ǯʧ��")
	end
	return true
end
	
local MoneyType = {
			Money = 1,						--���(�������)
			BindingMoney = 2,			--�󶨽��
			Ticket = 3,						--Ӷ����
			BindingTicket = 4			--Ӷ����(��Ӷ����)
}
--ϵͳ��ȡ������ã����������С������ʼ��ĵط��������ȿ۳���ҵİ󶨽�ң��󶨽�Ҳ����ģ���ʣ���Ǯͨ����ͨ��ҿ۳�
--������sFunction��sModule�����ĸ�ϵͳ���ĸ����ܵ��õģ���gm�����������ƽ�Ǯ��ͨ�õ�
function MoneyManagerDB.SubtractMoneyBySysFee(money_count, PlayerId, sFunction, sModule,uLogType)
	local add_Money ,add_bMoney = 0,0
	local uBindingMoney = MoneyManagerDB.GetBindingMoney(PlayerId)
	if uBindingMoney <= money_count then 
		add_bMoney = uBindingMoney
		add_Money = money_count - add_bMoney 
	else
		add_bMoney = money_count
	end

	if add_bMoney > 0  then
		local bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(sFunction["FunName"],sModule,PlayerId,MoneyType.BindingMoney, -add_bMoney,nil,uLogType)
		if not bFlag then
			CancelTran()
			if IsNumber(uMsgID) then
				return false,uMsgID
			else
				return false,8032
			end
		end	
	end
	
	if add_Money > 0 then
		local bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(sFunction["FunName"],sModule,PlayerId,MoneyType.Money, -add_Money,nil,uLogType)
		if not bFlag then
			CancelTran()
			if IsNumber(uMsgID) then
				return false,uMsgID
			else
				return false,8032
			end
		end
	end	
    return true, add_bMoney, add_Money
end

--------------------------------------------------------------
--@brief ͨ��rpc��Ǯ�ӿ�
--@param char_id:���id
--@param money_count:��Ǯ����
--@param money_type:��Ǯ���� 1-��ͨ��2-��
--@param addType:�޸Ľ�Ǯ��log����(���ڼ�¼log)
function MoneyManagerDB.AddMoneyForRpc(data)
	local char_id		= data["char_id"]
	local money_count	= data["money_count"]
	local addType = data["addType"]
	local money_type = data["money_type"]
	
	local fun_info = g_MoneyMgr:GetFuncInfo("Trap")
	local MoneyManagerDB = RequireDbBox("MoneyMgrDB")
	local bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(fun_info["FunName"],fun_info["TrapAddMoney"],char_id, money_type, money_count,nil,addType)
	if not bFlag then
		return false,uMsgID
	end
	return true
end


------------------------------------------��ͨ����˰���------------------------
local StmtDef = {
	"_AddWMEInfo",	
	[[
		insert into tbl_week_money_exchange 
		set cs_uId = ?,wme_uMoney = ?,wme_dtExchangeTime = now()
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_DelWMEInfo",	
	[[
		delete from tbl_week_money_exchange
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_AddWMELogInfo",	
	[[
		insert into tbl_week_money_exchange_log 
		select * from tbl_week_money_exchange
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_GetTotalWMEInfo",	
	[[
		select ifnull(sum(wme_uMoney),0) from tbl_week_money_exchange 
		where cs_uId = ? and unix_timestamp(now()) - unix_timestamp(wme_dtExchangeTime) <= 604800
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_GetMECCess",	
	[[
		select mec_uCess,unix_timestamp(now()) - unix_timestamp(mec_dtUpdateTime) from tbl_money_exchange_cess 
		where cs_uId = ?
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_AddMECCess",	
	[[
		replace into tbl_money_exchange_cess 
		set  cs_uId = ?,mec_uCess = ?,mec_dtUpdateTime = now()
	]]
}
DefineSql(StmtDef, MoneyManager)

local StmtDef = {
	"_DelMECCess",	
	[[
		delete from tbl_money_exchange_cess 
	]]
}
DefineSql(StmtDef, MoneyManager)

local function GetCess(total_exchange)	
	if total_exchange < 1000000 then
		return 0.03
	elseif total_exchange < 2000000 then
		return 0.05
	elseif total_exchange < 5000000 then
		return 0.10
	else
		return 0.20
	end
end

function MoneyManagerDB.ClearWMXAndCessGM(data)
	MoneyManager._DelWMEInfo:ExecStat()
	MoneyManager._DelMECCess:ExecStat()
end

function MoneyManagerDB.ClearWMXInfo(data)
	MoneyManager._AddWMELogInfo:ExecStat()
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		MoneyManager._DelWMEInfo:ExecStat()
		if g_DbChannelMgr:LastAffectedRowNum() == 0 then
			CancelTran()
			return
		end
	end
end

function MoneyManagerDB.GetMoneyExchangeCess(data)
	local char_id,exchange_money = data.char_id,data.exchange_money
	
	local tbl_total_exchange = MoneyManager._GetTotalWMEInfo:ExecStat(char_id)
	local tbl_exchange_cess = MoneyManager._GetMECCess:ExecStat(char_id)
	
	local now_cess = (tbl_exchange_cess:GetRowNum() > 0 and tbl_exchange_cess(1,1) or 3)/100
	local new_cess = GetCess(tbl_total_exchange(1,1) + exchange_money)
	
	if new_cess > now_cess or (tbl_exchange_cess:GetRowNum() > 0 and tbl_exchange_cess(1,2) > 604800) then
		now_cess = new_cess
	end
	
	return now_cess
end

function MoneyManagerDB.SetNewCess(char_id,exchange_money)
	MoneyManager._AddWMEInfo:ExecStat(char_id,exchange_money)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		error("�����ͨ�����Ϣʧ��")
	end
	local tbl_total_exchange = MoneyManager._GetTotalWMEInfo:ExecStat(char_id)
	local tbl_exchange_cess = MoneyManager._GetMECCess:ExecStat(char_id)
	local now_cess = (tbl_exchange_cess:GetRowNum() > 0 and tbl_exchange_cess(1,1) or 3)/100
	local new_cess = GetCess(tbl_total_exchange(1,1))
	if new_cess == now_cess then
		return math.ceil(exchange_money*(1-now_cess))
	end
	if new_cess > now_cess or (tbl_exchange_cess:GetRowNum() > 0 and tbl_exchange_cess(1,2) > 604800) then
		MoneyManager._AddMECCess:ExecStat(char_id,new_cess*100)
		if g_DbChannelMgr:LastAffectedRowNum() == 0 then
			error("�޸Ľ���˰ʧ��")
		end
		now_cess = new_cess
	end
	return math.ceil(exchange_money*(1-now_cess))
end

SetDbLocalFuncType(MoneyManagerDB.IsMoneyEnough)
return MoneyManagerDB
