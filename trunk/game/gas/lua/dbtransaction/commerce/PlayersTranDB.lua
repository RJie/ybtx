gac_gas_require "framework/common/CMoney"
local g_MoneyMgr = CMoney:new()
local g_ItemInfoMgr		=	CItemInfoMgr:new()
local event_type_tbl = event_type_tbl
local PlayersTranDB		=	CreateDbBox(...)
local CPlayerTran		=	{}


--����Ƿ��ں���������
local StmtDef = {
		"Friend_Kind",
		[[
			select fc_uId from tbl_player_friends where cs_uId = ? and pf_uFriendId = ? 
		]]
}
DefineSql( StmtDef, CPlayerTran )

function PlayersTranDB.SendTradeInvitation(data)
	local inviteeid		=	data["InviteeID"]
	local invitorid		=	data["InvitorID"]
	local ItemBagLockDB = RequireDbBox("ItemBagLockDB")
  if ItemBagLockDB.HaveItemBagLock(invitorid) then
  	return false,160015
  end
  if ItemBagLockDB.HaveItemBagLock(inviteeid) then
  	return false,160016
  end
	local isInBlackList1 = 	CPlayerTran.Friend_Kind:ExecSql('n', inviteeid, invitorid )
	local isInBlackList2 = CPlayerTran.Friend_Kind:ExecSql('n', invitorid , inviteeid )
	
	local setting_box = RequireDbBox("GameSettingDB")
 	if setting_box.GetOneSettingInfo(inviteeid,2) ~= 1 then
 		--"���ϵͳ����Ϊ�������ѣ������Ըı�ϵͳ����!"
 		return false, 168,""
 	end
 	
	if isInBlackList1:GetRowNum() > 0 then
		if isInBlackList1:GetData(0,0) == 2 then
			return false,  6028
		end
	end

	if isInBlackList2:GetRowNum() > 0 then
		if isInBlackList2:GetData(0,0) == 2 then
			return false,  6029
		end
	end

	return true
end

--��ȡ��ҵ�ӵ�еĽ�Ǯ��
local StmtDef = {
	"_GetPlayerMoneyNum",
	[[ select cm_uMoney from tbl_char_money where cs_uId=?]]
}
DefineSql(StmtDef,CPlayerTran)
function PlayersTranDB.GetPlayerMoneyNum(uCharId)
	local money = CPlayerTran._GetPlayerMoneyNum:ExecStat(uCharId)
	if( money:GetRowNum() == 0 ) then
		return 0
	end
	local ret = money:GetDataByName(0, "cm_uMoney")
	return ret
end
--ѡ���׽�Ǯʱ����ѯ�����еĽ�Ǯ��Ŀ
function PlayersTranDB.ChoosedTradeMoney(data)
	local uCharId		=	data["CharID"]
	
	local haveMoneyCount = PlayersTranDB.GetPlayerMoneyNum(uCharId)
	return haveMoneyCount
end

--��ӽ�����Ʒʱ
function PlayersTranDB.ChoosedTradeItem(data)
	local uCharId		=	data["CharID"]
	local roomIndex		=	data["RoomIndex"]
	local pos			=	data["Pos"]
	local itemCount		=	data["ItemCount"]
	local recieverid = data["recieverid"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local tbl_item_id = g_RoomMgr.GetAllItemFromPosition(uCharId, roomIndex, pos)
	--local stype, name, is_UId = g_RoomMgr.GetOneItemByPosition(uCharId, roomIndex, pos)
	local stype, name, count = g_RoomMgr.GetTypeCountByPosition(uCharId, roomIndex, pos)
	local is_UId = tbl_item_id(1,1)
	if stype == nil or name == nil  then
		-- "�Ƿ�������"
		return false, 6002, roomIndex, pos
	end
	
	--local count  = g_RoomMgr.GetCountByPosition(uCharId, roomIndex, pos)
	if itemCount > count then
		--, "������Ʒ��Ŀ����ʵ�ʳ�����Ŀ��"
		return false, 6003, roomIndex, pos
	end

	local nBigID = tonumber(stype)
	local itemBindingType = g_RoomMgr.GetItemBindingTypeByID(is_UId)
	if itemBindingType == 2  then --��Ʒ������Ϊ����
		--, "���ܽ��װ���Ʒ��"
		return false, 6004, roomIndex, pos
	end
	if itemBindingType == 3  then 
  	local tong_box = RequireDbBox("GasTongBasicDB")
  	if tong_box.GetTongID(uCharId) ~= tong_box.GetTongID(recieverid) then
  		return false,6031,roomIndex, pos
  	end
  end
	if g_ItemInfoMgr:IsQuestItem(stype) then		--���ܳ���������Ʒ
		--, "������Ʒ���ܱ����ף�"
		return false, 6005, roomIndex, pos
	end
	if g_ItemInfoMgr:IsSoulPearl(sType) then
		--������Ʒ�Ļ�ֵ��һ�������ܳ���
		if g_RoomMgr.CountSoulNumByPos(uCharId, roomIndex, pos) > 1 then
			return false,6035
		end
	end
	local itemDynInfoDB = RequireDbBox("GetItemDynInfoDB")	
	local itemInfoTbl = itemDynInfoDB.GetItemDynInfo(is_UId, nBigID, uCharId, recieverid, tbl_item_id)

	local result = {["ItemType"]= nBigID, ["ItemName"]=name, ["ItemInfoTbl"] = itemInfoTbl,
	["RoomIndex"] =roomIndex, ["Pos"] =pos, ["ItemCount"] = itemCount, ["ItemID"] = is_UId }
	return  true, result
end

--�滻����ӵ�ĳ��Ҫ���׵���Ʒ
function PlayersTranDB.ReplaceItem(data)
	local uCharId		=	data["CharID"]
	local roomIndex		=	data["RoomIndex"]
	local pos			=	data["Pos"]
	local itemCount		=	data["ItemCount"]
	local slot          =   data["Slot"]
	local replacedRoomIndex = data["ReplacedRoomIndex"]
	local replacedPos = data["ReplacedPos"]
	
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	--local stype, name, is_UId = g_RoomMgr.GetOneItemByPosition(uCharId, roomIndex, pos)
    local tbl_item_id = g_RoomMgr.GetAllItemFromPosition(uCharId, roomIndex, pos)
	local stype, name, count = g_RoomMgr.GetTypeCountByPosition(uCharId, roomIndex, pos)
	local is_UId = tbl_item_id(1,1)
	local nBigID  = tonumber(stype)
	if stype == nil or name == nil or is_UId == nil then
		--, "�Ƿ�������"
		local result = {["MsgID"] =6002, ["RoomIndex"] =roomIndex, ["Pos"] = pos}
		return false, result
	end
	
	local count  = g_RoomMgr.GetCountByPosition(uCharId, roomIndex, pos)
	if itemCount > count then
		--, "������Ʒ��Ŀ����ʵ�ʳ�����Ŀ��"
		local result = {["MsgID"] =6003, ["RoomIndex"] =roomIndex, ["Pos"] = pos}
		return false, result
	end
	local itemBindingType = g_RoomMgr.GetItemBindingTypeByID(is_UId)
	if itemBindingType == 2  then --��Ʒ������Ϊ����
		--, "���ܽ��װ���Ʒ��"
		local result = {["MsgID"] =6004, ["RoomIndex"] =roomIndex, ["Pos"] = pos}
		return false, result
	end
	if itemBindingType == 3  then 
  	local tong_box = RequireDbBox("GasTongBasicDB")
  	if tong_box.GetTongID(uCharId) ~= tong_box.GetTongID(data["recieverid"]) then
  		local result = {["MsgID"] =6031, ["RoomIndex"] =roomIndex, ["Pos"] = pos}
			return false, result
  	end
  end
	local itemDynInfoDB = RequireDbBox("GetItemDynInfoDB")	
	local itemInfoTbl = itemDynInfoDB.GetItemDynInfo(is_UId, nBigID, uCharId, data["recieverid"], tbl_item_id)
	
	local result = {["ItemType"] =nBigID, ["ItemName"]=name, ["ItemInfoTbl"]= itemInfoTbl,
	                ["RoomIndex"] =roomIndex, ["Pos"] = pos, ["ItemCount"]= itemCount,
	                ["ItemID"]=is_UId, ["Slot"] = slot, ["ReplacedRoomIndex"] = replacedRoomIndex, 
	                ["ReplacedPos"] = replacedPos }
	return true, result
end

--ִ�н���
local StmtDef = {
	"_GetItemsIdByRoomPos",
	[[ 
		select is_uId from tbl_item_in_grid as iip,tbl_grid_in_room as igp
		where iip.gir_uGridID = igp.gir_uGridID and cs_uId=? and gir_uRoomIndex=? and gir_uPos=?
	]]
}
DefineSql(StmtDef, CPlayerTran)

--ִ�н�������
function PlayersTranDB.ExcuteTrade(data)
	local invitorId				=	data["InvitorID"]
	local inviteeId				=	data["InviteeID"]
	local invitor_trade_items	=	data["InvitorTradeInfoTbl"]
	local invitee_trade_items	=	data["InviteeTradeInfoTbl"]
	--��¼invitorҪ���׵�������Ʒ��id
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local sender_itemids={}
	if(invitor_trade_items) then
		for i=1,table.getn(invitor_trade_items) do
			local ids 	= 	{}			--���ڴ洢ĳ�������е���Ʒ��id
			local room 	=	invitor_trade_items[i][1]
			local pos	=	invitor_trade_items[i][2]
			local count	=	invitor_trade_items[i][3]
			local items	=	CPlayerTran._GetItemsIdByRoomPos:ExecSql('n', invitorId, room, pos)
			local row 	= 	items:GetRowNum()
			if(row == 0 or row < count) then
				items:Release()
				return false, 6003
			end
			for j=1, count do
				local irp=	{}
				irp[1]	 =	items:GetData(j-1, 0) --items[j][1] ��Ʒid�����֣�
				table.insert(ids, irp)		--����Ҫ���׵���Ʒid
			end
			local type, name, itemCount = g_RoomMgr.GetTypeCountByPosition(invitorId, room, pos)
			local itemType = invitor_trade_items[i][4]
			local itemName = invitor_trade_items[i][5]
			if itemType ~= type or itemName ~= name or count ~= itemCount then
                return false , 6003
			end
			ids.room	=	room
			ids.pos		=	pos
			table.insert(sender_itemids,ids)
			items:Release()
		end
	end
	--��¼invitee��ҽ��׵�������Ʒid
	local reciever_itemids={}
	if(invitee_trade_items) then
		for i=1,table.getn(invitee_trade_items) do
			local ids={}		--���ڴ洢ĳ�������е���Ʒ��id
			local room	=	invitee_trade_items[i][1]
			local pos	=	invitee_trade_items[i][2]
			local count	=	invitee_trade_items[i][3]
			local items	=	CPlayerTran._GetItemsIdByRoomPos:ExecSql('n', inviteeId, room, pos)
			local row = items:GetRowNum()
			if(row == 0 or row < count) then
				items:Release()
				return false, 6003
			end
			for j=1,count do
				local irp={}
				irp[1]=items:GetData(j-1, 0)
				table.insert(ids, irp)
			end
            local type, name, itemCount = g_RoomMgr.GetTypeCountByPosition(inviteeId, room, pos)
			local itemType = invitee_trade_items[i][4]
			local itemName = invitee_trade_items[i][5]
			if itemType ~= type or itemName ~= name or count ~= itemCount then
                return false , 6003
			end
			ids.room	=	room
			ids.pos		=	pos	
			table.insert(reciever_itemids, ids)	--����Ҫ���׵���Ʒid
			items:Release()
		end
	end
	
	local tong_box = RequireDbBox("GasTongBasicDB")
	
	local sender_infos={}
	local reciever_infos={}
	local sender_item_info = {}					--��¼sender������Ʒ��type��name��
	local reciever_item_info = {}				--��¼reciever������Ʒ��type��name��
    local BoxitemDB = RequireDbBox("BoxitemDB")
	for i=1, table.getn(sender_itemids) do
		local stype, name = g_RoomMgr.GetItemType(sender_itemids[i][1][1])
		if g_RoomMgr.CountItemLimitByName(stype, name) > 0 then
			CancelTran()
			return false,21
		end
		table.insert(sender_item_info,{stype, name})	--��¼���׸�����Ʒ��type��name
		for j=1,table.getn(sender_itemids[i]) do
			local nBindType = g_RoomMgr.GetItemBindingTypeByID(sender_itemids[i][j][1])
			if 3 == nBindType then
  			if tong_box.GetTongID(inviteeId) ~= tong_box.GetTongID(invitorId) then
  				CancelTran()
  				return false,6031
  			end
			end
			
			if not g_RoomMgr.MoveItemFromPackage(invitorId, sender_itemids[i][j][1]) then
				CancelTran()
				--, "ɾ����Ʒδ�ɹ���"
				return false, 6006
			end
			--update boxitem tbl
			local ret = BoxitemDB.UpdateBoxitemBelonging(stype, inviteeId, sender_itemids[i][j][1])
            if ret == false then
                CancelTran()
                return  false, 6007
			end
		end
	end
	for i=1,table.getn(reciever_itemids) do
		local stype, name = g_RoomMgr.GetItemType(reciever_itemids[i][1][1])
		if g_RoomMgr.CountItemLimitByName(stype, name) > 0 then
			CancelTran()
			return false,21
		end
		table.insert(reciever_item_info, {stype, name})
		for j=1,table.getn(reciever_itemids[i]) do
			local nBindType = g_RoomMgr.GetItemBindingTypeByID(reciever_itemids[i][j][1])
			if 3 == nBindType then
  			if tong_box.GetTongID(inviteeId) ~= tong_box.GetTongID(invitorId) then
  				CancelTran()
  				return false,6031
  			end
			end
			if not g_RoomMgr.MoveItemFromPackage(inviteeId, reciever_itemids[i][j][1]) then
				CancelTran()
				--, "��Ʒ����ʹ��, ���ܽ��� !"
				return false, 6008
			end
			--update boxitem tbl
			local ret = BoxitemDB.UpdateBoxitemBelonging(stype, invitorId, reciever_itemids[i][j][1])
			if ret == false then
                CancelTran()
                return  false, 6007
			end
		end
	end

	local ItemData_R2S = {}  
	local ItemData_S2R = {}
	local R2S_Money = 0
	local S2R_Money = 0 
	local item_bag_box = RequireDbBox("CPutItemToBagDB")
	for i=1, table.getn(reciever_itemids) do
		local stype, name = reciever_item_info[i][1], reciever_item_info[i][2]
		local itemtype    = tonumber(stype)
		local params = {}
		params.m_nCharID = invitorId
		params.m_nItemType = itemtype
		params.m_sItemName = name
		params.m_tblItemID = reciever_itemids[i]
		local succ,info   = item_bag_box.AddCountItem(params)
		if(not succ) then
			CancelTran()
			return false,info
		end
		table.insert(sender_infos, info)
		for j=1, table.getn(reciever_itemids[i]) do			--���ڼ�¼logʱ����Ʒid
			table.insert( ItemData_R2S, reciever_itemids[i][j][1] )
		end
	end
	for i=1, table.getn(sender_itemids) do
		local stype, name = sender_item_info[i][1], sender_item_info[i][2]
		local itemtype    = tonumber(stype)
		local params = {}
		params.m_nCharID = inviteeId
		params.m_nItemType = itemtype
		params.m_sItemName = name
		params.m_tblItemID = sender_itemids[i]
		local succ, info  = item_bag_box.AddCountItem(params)
		if(not succ) then
			CancelTran()
			return false,info
		end
		table.insert(reciever_infos, info)
		for j=1,table.getn(sender_itemids[i]) do	--���ڼ�¼logʱ����Ʒid
			table.insert( ItemData_S2R, sender_itemids[i][j][1] )
		end
	end
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local MoneyManagerDB=	RequireDbBox("MoneyMgrDB")
	if ( invitor_trade_items ) then
        --��invitor��Ǯ����invitee������Ӧ��Ǯ
        if(invitor_trade_items.money and invitor_trade_items.money>0) then
            if  MoneyManagerDB.EnoughMoney(invitorId, invitor_trade_items.money) then
				local fun_info = g_MoneyMgr:GetFuncInfo("PlayerTran")
				local money = MoneyManagerDB.SetNewCess(invitorId,invitor_trade_items.money)
				local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["PlayerTran"],invitorId, -invitor_trade_items.money,nil,event_type_tbl["��ҽ���"],inviteeId,money)
				if not bFlag then
					CancelTran()
					if IsNumber(uMsgID) then
						return false,uMsgID
					else
						return false, 6009
					end
				end

                local bFlag2,uMsgID2 = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["PlayerTran"],inviteeId, money,nil,event_type_tbl["��ҽ���"])
				if not bFlag2 then
					CancelTran()
					if IsNumber(uMsgID2) then
						return false,uMsgID2
					else
						return false, 6009
					end
				end
        	    R2S_Money = invitor_trade_items.money
        	    g_LogMgr.SaveTaxLog(invitor_trade_items.money - money, inviteeId, event_type_tbl["��ҽ��׿�˰"])
            else
                CancelTran()
                return  false, 6009
		    end
        end
    end
    if (invitee_trade_items) then
    	if(invitee_trade_items.money and invitee_trade_items.money>0) then
    	    if ( MoneyManagerDB.EnoughMoney(inviteeId, invitee_trade_items.money)) then
				local money = MoneyManagerDB.SetNewCess(inviteeId,invitee_trade_items.money)
    		    local fun_info = g_MoneyMgr:GetFuncInfo("PlayerTran")
				local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["PlayerTran"],inviteeId,-invitee_trade_items.money,nil,event_type_tbl["��ҽ���"],invitorId,money)
				if not bFlag then
					CancelTran()
					if IsNumber(uMsgID) then
						return false,uMsgID
					else
						return false, 6009
					end
				end
    		    local bFlag2,uMsgID2 = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["PlayerTran"],invitorId,money,nil,event_type_tbl["��ҽ���"])
				if not bFlag2 then
					CancelTran()
					if IsNumber(uMsgID2) then
						return false,uMsgID2
					else
						return false, 6009
					end
				end
   			    S2R_Money = invitee_trade_items.money
   			    g_LogMgr.SaveTaxLog(invitee_trade_items.money - money, invitorId, event_type_tbl["��ҽ��׿�˰"])
   		    else
   		        CancelTran()
   		        return false, 6009
   		    end
        end
    end
	
	--��¼��ҽ��������ߵõ�����Ʒ�ͽ�Ǯ��Ŀ
	g_LogMgr.LogPlayerTrade(invitorId,inviteeId, ItemData_R2S, R2S_Money,ItemData_S2R, S2R_Money)
	local result={["Sender_ItemIDs"]=sender_itemids, ["Reciever_ItemIDs"]=reciever_itemids, 
					["Sender_Infos"]=sender_infos, ["Reciever_Infos"]=reciever_infos,
					 ["Sender_Money"] = R2S_Money, ["Reciever_Money"] = S2R_Money}
	return true, result
end

SetDbLocalFuncType(PlayersTranDB.SendTradeInvitation)
SetDbLocalFuncType(PlayersTranDB.ChoosedTradeItem)
SetDbLocalFuncType(PlayersTranDB.ReplaceItem)
SetDbLocalFuncType(PlayersTranDB.ChoosedTradeMoney)
SetDbLocalFuncType(PlayersTranDB.ExcuteTrade)
return PlayersTranDB