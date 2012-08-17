gac_gas_require "item/item_info_mgr/ItemInfoMgr"
local StmtContainer = class()
local g_ItemInfoMgr = CItemInfoMgr:new()
local PickOreItemDB = CreateDbBox(...)

--========================================================================
local StmtDef = {
			"_SelectPickOreItemDura",
			--��ѯ�ɿ󹤾ߵ��;ö�
			[[ 
				select ipd_uCurDura, ipd_uMaxDura from tbl_item_pickore_dura where is_uId = ?
			]]
}
DefineSql (StmtDef,StmtContainer)

--ͨ����ƷPOS��ѯ�ɿ󹤾ߵ��;ö�
function PickOreItemDB.QueryPickOreItemInfo(data)
	local nCharID = data["PlayerID"]
	local nRoom = data["RoomIndex"]
	local nPos = data["Pos"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local ItemType,ItemName,ItemId = g_RoomMgr.GetOneItemByPosition(nCharID,nRoom,nPos)
	if not g_ItemInfoMgr:IsPickOreItem(ItemType) then
		return
	end
	if data["ItemName"] ~= ItemName then
		return
	end
	local res = StmtContainer._SelectPickOreItemDura:ExecStat(ItemId)
	local tbl = nil
	if nil ~= res and res:GetRowNum()>0 then
		tbl= {
					ItemId,
					res:GetData(0,0),
					res:GetData(0,1),
					}
		res:Release()
	end
	return tbl
end

--ͨ����ƷID��ѯ�;ö�
function PickOreItemDB.QueryPickOreItemDura(ItemId)
	local result = StmtContainer._SelectPickOreItemDura:ExecStat(ItemId)
	if result:GetRowNum() ~= 0 then
		local CurDura,MaxDura = result:GetData(0,0),result:GetData(0,1)
		return MaxDura,CurDura
	end
end
--========================================================================
local StmtDef = {
			"_SaveDurability",
			--����ɿ󹤾ߵ��;ö�
			[[ 
				insert into tbl_item_pickore_dura(is_uId,ipd_uMaxDura,ipd_uCurDura) values(?,?,?)
			]]
}
DefineSql (StmtDef,StmtContainer)

--��Ӳɿ󹤾�ʱҲ������Ӧ���;ö���Ϣ
function PickOreItemDB.SaveDurabilityById(ItemId, DuraValue)
	if assert(IsNumber(ItemId)) then
		StmtContainer._SaveDurability:ExecStat(ItemId, DuraValue, DuraValue)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	end
	return false
end
--========================================================================
local StmtDef = {
			"_UpdateDuraValue",
			--�����;ö�(������ƷID)
			[[ 
				update tbl_item_pickore_dura set ipd_uCurDura = ipd_uCurDura - ? where is_uId = ?
			]]
}
DefineSql (StmtDef,StmtContainer)

--�����;ö�
function PickOreItemDB.UpdateDuraValue(data)
	local is_uId	= data["ItemId"]
	local DuraValue = data["DuraValue"] or 1
	if not is_uId then
		local nCharID = data["PlayerID"]
		local nRoom = data["RoomIndex"]
		local nPos = data["Pos"]
		local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
		local ItemType,ItemName,ItemId = g_RoomMgr.GetOneItemByPosition(nCharID,nRoom,nPos)
		is_uId = ItemId
	end
	if assert(IsNumber(is_uId)) then
		--print("DB ����"..DuraValue.."���;�")
		StmtContainer._UpdateDuraValue:ExecStat(DuraValue, is_uId)
		return g_DbChannelMgr:LastAffectedRowNum() > 0, {PickOreItemDB.QueryPickOreItemDura(is_uId)}
	end
	return false
end

return PickOreItemDB
