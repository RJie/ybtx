gac_gas_require "item/item_info_mgr/ItemInfoMgr"

gac_gas_require "item/store_room_cfg/StoreRoomCfg"
cfg_load "item/ItemNumLimit_Common"
local ItemNumLimit_Common = ItemNumLimit_Common
local StmtOperater = {}	
local LogDBName = DeployConfig.MySqlDatabase .. "_log"
local g_ItemInfoMgr = CItemInfoMgr:new()		
local g_GetSlotRange = g_GetSlotRange 				
local g_GetMainRoomSize = g_GetMainRoomSize 	
local g_IsInStaticRoom = g_IsInStaticRoom 		
local g_IsPosIsRight = g_IsPosIsRight     		
local g_StoreRoomIndex = g_StoreRoomIndex  		
local g_GetRoomRange = g_GetRoomRange
local g_GetRoomSize = g_GetRoomSize
local g_SlotIndex = g_SlotIndex
local os = os
local LogErr = LogErr
local event_type_tbl = event_type_tbl

local CGasRoomDbBox = CreateDbBox(...)

--------------------------------------------------------------------------------------------------
local StmtDef=
{
    "_AddItemPosCount",
    [[
    	insert into tbl_grid_info 
    	set gir_uGridID = ?,gi_uCount = ?,is_uType= ? ,is_sName = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_UpdateItemPosCount",
    [[
    	update tbl_grid_info 
    	set gi_uCount = gi_uCount + ?
    	where gir_uGridID = ? and gi_uCount + ? >= 0
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_UpdateItemPosCountAndType",
    [[
    	update tbl_grid_info 
    	set gi_uCount = gi_uCount + ?,is_uType = ?, is_sName = ?
    	where gir_uGridID = ? and gi_uCount + ? >= 0 
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_GetGridID",
    [[
    	select gir_uGridID from tbl_grid_in_room
    	where cs_uId = ? and gir_uRoomIndex = ? and gir_uPos = ? 
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_AddGridID",
    [[
    	insert into tbl_grid_in_room
    	set cs_uId = ?,gir_uRoomIndex = ?,gir_uPos = ? 
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_GetCountByGridID",
    [[
    	select gi_uCount from tbl_grid_info
    	where  gir_uGridID = ?
    ]] 
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_DelGridID",
    [[
    	delete from tbl_grid_in_room
    	where  gir_uGridID = ?
    ]] 
}
DefineSql(StmtDef,StmtOperater)

function CGasRoomDbBox.GetGridID(nCharID,nRoomIndex,nPos)
	local tbl_index = StmtOperater._GetGridID:ExecStat(nCharID,nRoomIndex,nPos)
	if tbl_index:GetRowNum() == 0 then
		StmtOperater._AddGridID:ExecStat(nCharID,nRoomIndex,nPos)
		return g_DbChannelMgr:LastInsertId()
	end
	return tbl_index(1,1)
end

function CGasRoomDbBox.AddPosCountByGridID(nGridID,nCount,nItemID)
	local tbl_count = StmtOperater._GetCountByGridID:ExecStat(nGridID)
	local row = tbl_count:GetRowNum()
	if nCount > 0 and nItemID then
		local item_type,item_name = CGasRoomDbBox.GetItemType(nItemID)
		if item_type and item_name then
			if row > 0 then
				StmtOperater._UpdateItemPosCountAndType:ExecStat(nCount,item_type,item_name,nGridID,nCount)
				if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
					error("���tbl_item_count��Ϣʧ��" .. tbl_count(1,1))
				end
			else
				StmtOperater._AddItemPosCount:ExecStat(nGridID,nCount,item_type,item_name)
				if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
					error("���tbl_item_count��Ϣʧ��")
				end
			end
		end
	elseif nCount < 0 and row > 0 and tbl_count(1,1) > 0 then
		StmtOperater._UpdateItemPosCount:ExecStat(nCount,nGridID,nCount)
		if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
			error("����tbl_item_count����ʧ��nCount:" .. nCount .. "tbl_count:" .. (row > 0 and tbl_count(1,1) or ""))
		end
	end
	local tbl_count2 = StmtOperater._GetCountByGridID:ExecStat(nGridID)
	if tbl_count2:GetRowNum() > 0 and tbl_count2(1,1) <= 0 then
		StmtOperater._DelGridID:ExecStat(nGridID)
		if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
			error("ɾ��tbl_item_grid_posʧ��")
		end
	end
end

function CGasRoomDbBox.AddItemPosCountByPos(nCharID,nRoomIndex,nPos,nCount,nItemID)
	local nGridID = CGasRoomDbBox.GetGridID(nCharID,nRoomIndex,nPos)
	CGasRoomDbBox.AddPosCountByGridID(nGridID,nCount,nItemID)
end
-------------------------------------------------------------------------------
function CGasRoomDbBox.UpdateItemBindingType(BindingType, item_ids,charId)
	local g_LogMgr = RequireDbBox("LogMgrDB")
	for i =1,#item_ids do
		local item_id = item_ids[i]
		StmtOperater._InsertIntoBinding:ExecStat(item_id,BindingType)
		g_LogMgr.LogItemBindInfo(charId,item_id,BindingType)
	end
end
--------------------------------------------------------------------------------
--���ĳλ��������Ʒid
local StmtDef=
{
	"_SelectAllItemIDByPos",
	[[
	select  a.is_uId
	from 
			tbl_grid_in_room as igp
	join tbl_item_in_grid as a 
		on(igp.gir_uGridID = a.gir_uGridID)
	where 	cs_uId = ?
		and  gir_uRoomIndex = ?
		and  gir_uPos = ?;
	]]
}
DefineSql( StmtDef , StmtOperater )
function CGasRoomDbBox.SelectAllItemIDByPos(nCharID,room,pos)
	local query_result = StmtOperater._SelectAllItemIDByPos:ExecSql('n',nCharID,room,pos)
	return query_result
end
-------------------------------------------------------------------------------------------------
--[[
    	��ѯ��ĳ�ռ�����б��������ƺ�����
    	��������ɫid�Ϳռ�id
--]]
local StmtDef=
{
    "_GetBagTypeByRoomIndex",
    [[
    	select 
    		item.is_uType,item.is_sName 
    	from 
    		tbl_item_bag_in_use as bag 
    		join 
    		tbl_item_static as item 
    			on bag.is_uId = item.is_uId 
    	where bag.cs_uId = ? 
    		and bag.ibiu_uRoomIndex = ?;
    ]]
}
DefineSql(StmtDef,StmtOperater)
-------------------------------------------------------------------------------------------
--���õ�ĳ��չ���������͡�
function CGasRoomDbBox.GetBagTypeByRoom(nCharID,nRoom)
	local RoomType = StmtOperater._GetBagTypeByRoomIndex:ExecSql("ns[32]",nCharID,nRoom)
	if RoomType:GetRowNum() == 0 then
		RoomType:Release()
		return nil,nil
	else
		local res1 = RoomType:GetData(0,0)
		local res2 = RoomType:GetData(0,1)
		RoomType:Release()
		return res1, res2
	end
end
--------------------------------------------------------------------------------------------
local StmtDef=
{
    "_GetRoomIDBySlotRange",
    [[
     select ibiu_uRoomIndex from tbl_item_bag_in_use
     where cs_uId = ? and ibiu_uBagSlotIndex >= ? and ibiu_uBagSlotIndex <= ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

--��ͨ��slot range �����room�ռ䡿
function CGasRoomDbBox.GetRoomIDBySlotRange(nCharID,nFirstSlot,nLastSlot)
	local query_list = StmtOperater._GetRoomIDBySlotRange:ExecSql("n",nCharID,nFirstSlot,nLastSlot)

	return query_list
end

----------------------------------------------------------------------------------------------
--[[
			������ɸ�ĳ����Ʒ��id���ռ�id���ռ�λ�õ���Ϣ
			��������Ʒ���͡����ơ���ɫid������Ҫ��ѯ������
	--]]
local StmtDef = 
{
	"_SelectNCountItem",
	[[
		select
     			item.is_uId,gir_uRoomIndex,gir_uPos
     from
     	 		tbl_item_static as item 
     join 
     			tbl_item_in_grid as room 
     	on 	
     			(room.is_uId = item.is_uId)
     	join tbl_grid_in_room as igp
     		on(igp.gir_uGridID = room.gir_uGridID)
     where
     		cs_uId = ?
     		and item.is_uType = ?
     		and item.is_sName = ? 
     		and 
        ( 
          (igp.gir_uRoomIndex >= ? and igp.gir_uRoomIndex <= ?)
          or igp.gir_uRoomIndex = ?
        )
        limit 0, ?
	]]
}
DefineSql(StmtDef, StmtOperater)
function CGasRoomDbBox.GetNCountItemIdByName(nCharId, sItemType, sItemName, uCount)
	local nStoreRoom = g_StoreRoomIndex.PlayerBag
	local nFirstRoom,nLastRoom = g_GetRoomRange(nStoreRoom)
	local query_result = StmtOperater._SelectNCountItem:ExecStat(nCharId,sItemType, sItemName,nFirstRoom,nLastRoom,nStoreRoom, uCount)
	
	return query_result
end
-----------------------------------------------------------------------------------------------
local StmtDef=
{
    "_GetCountFromPos",
    [[
    	select gi_uCount from tbl_grid_info iiig,tbl_grid_in_room igp
    	where  iiig.gir_uGridID = igp.gir_uGridID 
    	and cs_uId = ?
    	and gir_uRoomIndex = ?
    	and gir_uPos = ?
    ]] 
}
DefineSql(StmtDef,StmtOperater)

--���ĳλ����Ʒ������
--û����Ʒ����0
function CGasRoomDbBox.GetCountByPosition(nCharID,nRoomIndex,nPos)
	local res = StmtOperater._GetCountFromPos:ExecStat(nCharID,nRoomIndex,nPos)
	
	if res:GetRowNum() == 0 then
		res:Release()
		return 0
	end
	local result = res:GetData(0,0)
	res:Release()
	return result
end
-----------------------------------------------------------------------------------------------
--ͨ��item id��ø���Ʒ����room_index��position
local StmtDef =
{
	"_GetRoomIndexAndPosByItemId",
	[[
		select 
			gir_uRoomIndex, gir_uPos
		from
			tbl_item_in_grid as iip,tbl_grid_in_room as igp
		where 
			igp.gir_uGridID = iip.gir_uGridID
		and
			iip.is_uId = ? and igp.cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.GetRoomIndexAndPosByItemId(uCharId, uItemId)

	local res = StmtOperater._GetRoomIndexAndPosByItemId:ExecSql("nn", uItemId, uCharId)
	if res:GetRowNum() == 0 then
		res:Release()
		return
	end
	return res
end
-----------------------------------------------------------------------------------------------
local StmtDef=
{
    "_GetItemTypeAndNameByPos",
    [[
    	select 
    		is_uType,is_sName,gi_uCount from tbl_grid_info as iiig,tbl_grid_in_room as igp
    	where 
    		iiig.gir_uGridID = igp.gir_uGridID
    		and cs_uId = ?
    		and gir_uRoomIndex = ?
    		and gir_uPos = ?
    		and gi_uCount > 0
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.GetTypeCountByPosition(nCharID,nRoom,nPos)
	local TypeCount = StmtOperater._GetItemTypeAndNameByPos:ExecStat(nCharID,nRoom,nPos)
	if TypeCount:GetRowNum() == 0 then
		TypeCount:Release()
		return 
	end
	local item_type = TypeCount(1,1)
	local item_name = TypeCount(1,2)
	local item_count = TypeCount(1,3)
	return item_type,item_name,item_count
end

------------------------------------------------------------------
local StmtDef=
{
    "_GetItemBindingTypeByPos",
    [[
    	select 
    		ifnull(binding.isb_bIsbind,0)
    	from 
    		tbl_grid_in_room igp 
    	join
    		tbl_item_in_grid as iig
    			on(igp.gir_uGridID = iig.gir_uGridID)
    	left join tbl_item_is_binding as binding
    		on iig.is_uId = binding.is_uId
    	where 
    		cs_uId = ?
    		and gir_uRoomIndex = ?
    		and gir_uPos = ?
    	limit 1
    ]]
}
DefineSql(StmtDef,StmtOperater)

function CGasRoomDbBox.GetBindingTypeByPos(nCharID,nRoom,nPos)
	local tbl_type = StmtOperater._GetItemBindingTypeByPos:ExecStat(nCharID,nRoom,nPos)
	if tbl_type:GetRowNum() == 0 then
		tbl_type:Release()
		return 
	end
	return tbl_type(1,1)
end
----------------------------------------------------------------------------------------------
--ֻ�ܵ���һ����Ʒ�ģ��Ϳ���ͨ�����sqlֱ�ӻ����Ʒ���ͺ�id
local StmtDef=
{
    "_SelectTypeFromRoom",
    [[
    	select 
    		item.is_uType,item.is_sName,item.is_uId,ifnull(binding.isb_bIsbind,0)
    	from tbl_grid_in_room as igp join tbl_item_in_grid as room 
    		on(igp.gir_uGridID = room.gir_uGridID)
    	join tbl_item_static as item
    		on room.is_uId = item.is_uId 
    	left join tbl_item_is_binding as binding
    		on item.is_uId = binding.is_uId
    	where cs_uId =?
    		and gir_uRoomIndex = ?
    		and gir_uPos = ? LIMIT 1;
    ]]
}
DefineSql(StmtDef,StmtOperater)
-- 1�� ��øø��ӵ���Ʒ����
-- 2�� ��øø��ӵ���Ʒ���ͺ͵�һ����Ʒid�����Ϊ�����Ե��Ӿ���ֱ����������������Ʒid
-- 3�� ȷ�ϸø����Ƿ�Ϊ��
function CGasRoomDbBox.GetOneItemByPosition(nCharID,nRoom,nPos)
	local res = StmtOperater._SelectTypeFromRoom:ExecSql("ns[32]nn",nCharID,nRoom,nPos)
	if res:GetRowNum() == 0 then
		res:Release()
		return 
	end
	local ret1 = res:GetData(0,0)
	local ret2 = res:GetData(0,1)
	local ret3 = res:GetData(0,2)
	local ret4 = res:GetData(0,3)
	res:Release()
	return ret1, ret2, ret3,ret4
end

---------------------------------------------------------------------------------------------
--���õ����ĳ��Ʒ����������
function CGasRoomDbBox.GetItemCount(nCharID, nBigId, sItemName)
	return CGasRoomDbBox.GetItemCountBySpace(g_StoreRoomIndex.PlayerBag,nCharID, nBigId, sItemName)
end

local StmtDef = 
{
	"_GetSpaceItemCountByName",
	[[
		select ifnull(sum(gi_uCount),0) from tbl_grid_info iiig,tbl_grid_in_room igp
		where 
		igp.gir_uGridID = iiig.gir_uGridID
		and cs_uId = ? and is_uType = ? and is_sName = ?
		and 
        ( 
         	(gir_uRoomIndex >= ? and gir_uRoomIndex <= ?)
         	or gir_uRoomIndex =?
        )
	]]
}
DefineSql(StmtDef,StmtOperater)

--���õ�ĳ�ռ���ĳ��Ʒ��������
--��һ����������������߸��˲ֿ�
function CGasRoomDbBox.GetItemCountBySpace(nSpaceIndex,nCharID, nBigId, sItemName)
	local nFirstIndex,nLastIndex = g_GetRoomRange(nSpaceIndex)
	local ret = StmtOperater._GetSpaceItemCountByName:ExecStat(nCharID, nBigId, sItemName,nFirstIndex,nLastIndex,nSpaceIndex)
	if ret:GetRowNum() == 0 then
		ret:Release()
		return 0
	end
	local res = ret:GetData(0,0)
	ret:Release()
	return res
end
----------------------------------------------------------------------------
local StmtDef = 
{
	"_GetAllItemCountByName",
	--�������ֿ⡢�ʼ���������������װ��
	[[
		select 
		(select ifnull(sum(gi_uCount),0) from tbl_grid_info iiig,tbl_grid_in_room igp
		where 
		igp.gir_uGridID = iiig.gir_uGridID
		and cs_uId = ? and is_uType = ? and is_sName = ?)
		+
		(select count(item.is_uId) from tbl_item_equip as equip,tbl_item_static as item 
		where equip.is_uId = item.is_uId and equip.cs_uId = ? and item.is_uType = ?
		and item.is_sName = ?)
	]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.GetAllItemCount(nCharID, nBigId, sItemName)
	local query_result = StmtOperater._GetAllItemCountByName:ExecStat(nCharID, nBigId, sItemName, nCharID, nBigId, sItemName)
	return query_result(1,1)
end

--�����Ʒ�ڱ������������
function CGasRoomDbBox.GetItemNum(data)
	local nCharID = data["nCharId"]
	local ItemType = data["ItemType"]
	local ItemName = data["ItemName"]
	return CGasRoomDbBox.GetItemCount(nCharID, ItemType, ItemName)
end
------------------------------------------------------------------------------------------
local StmtDef=
{
    "_GetPosCountByTypeStore",
    [[ 
     select
     		gir_uRoomIndex,gir_uPos,gi_uCount from tbl_grid_info iiig,tbl_grid_in_room igp
     where
     		igp.gir_uGridID = iiig.gir_uGridID
     		and cs_uId = ?
     		and is_uType = ?
     		and is_sName = ?
     		and 
        ( 
          (gir_uRoomIndex >= ? and gir_uRoomIndex <= ?)
          or gir_uRoomIndex = ?
        )
     and gi_uCount < ? and gi_uCount > 0
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.GetPosAndCountByType(nCharID,nBigID,nIndex,nStoreMain,FoldLimit,nBindingType)
	local nFirstRoom,nLastRoom = g_GetRoomRange(nStoreMain)
	local query_result = StmtOperater._GetPosCountByTypeStore:ExecStat(nCharID,nBigID,nIndex,nFirstRoom,nLastRoom,nStoreMain,FoldLimit)
	local result = {}
	for i =1,query_result:GetRowNum() do
		local Index,Pos = query_result(i,1),query_result(i,2)
		local count = query_result(i,3)
		if not nBindingType or nBindingType == CGasRoomDbBox.GetBindingTypeByPos(nCharID,Index,Pos) then
			table.insert(result,{Index,Pos,count})
		end
	end
	local ItemLifeMgrDB = RequireDbBox("ItemLifeMgrDB")
	for j = #result,1,-1 do
		if result[j] then
			if g_ItemInfoMgr:GetItemLifeInfo(nBigID,nIndex) then
				local tblLifeInfo = ItemLifeMgrDB.GetItemLifeByPos(nCharID,result[j][1],result[j][2])
				if  tblLifeInfo:GetRowNum() > 0 then
					local nTimeLeft,nTimeStyle,nLoadTime = tblLifeInfo(1,3),tblLifeInfo(1,4),tblLifeInfo(1,5)
					if not ItemLifeMgrDB.JudgeItemTime(nBigID,nIndex,nTimeLeft,nTimeStyle,nLoadTime) then
						table.remove(result,j)
					end
				end
			end
		end
	end
	return result
end
-------------------------------------------------------------------------------------------
local StmtDef = 
{
	"_GetSoulPearlNum",
	[[
		select ip_uSoulNum
		from tbl_item_pearl
		where is_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
--���õ������������
function CGasRoomDbBox.GetSoulPearlNum(nItemId)
	local ret = StmtOperater._GetSoulPearlNum:ExecSql("n", nItemId)
	if ret:GetRowNum() == 0 then
		ret:Release()
		return 0
	end
	local res = ret:GetData(0,0)
	ret:Release()
	return res
end

--------------------------------------------------------------------------------------------
local StmtDef = 
{
	"_GetSoulPearlInfoByPos",
	[[
		select 	pearl.ip_uSoulNum
		from 		tbl_item_pearl as pearl,tbl_item_in_grid as room,tbl_grid_in_room igp
		where 	pearl.is_uId = room.is_uId 
		and 		igp.gir_uGridID = room.gir_uGridID
		and			cs_uId = ? and gir_uRoomIndex = ?  and gir_uPos = ?
		limit 1
	]]
}
DefineSql(StmtDef,StmtOperater)
--���õ�ĳλ������Ʒ�Ļ�ֵ��Ϣ��
function CGasRoomDbBox.GetSoulPearlInfoByPos(nCharID,nRoomIndex, nPos)
	local ret = StmtOperater._GetSoulPearlInfoByPos:ExecSql("n",nCharID, nRoomIndex,nPos)
	if ret:GetRowNum() == 0 then
		ret:Release()
		return 0
	end
	local res1 = ret:GetData(0,0)
	ret:Release()
	return res1
end

local StmtDef = 
{
	"_CountSoulNumByPos",
	[[
		select count(distinct(soulp.ip_uSoulNum)) 
		from tbl_item_pearl as soulp,tbl_item_in_grid as room,tbl_grid_in_room igp
		where soulp.is_uId = room.is_uId 
		and 		igp.gir_uGridID = room.gir_uGridID
		and			cs_uId = ? and gir_uRoomIndex = ?  and gir_uPos = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.CountSoulNumByPos(nCharID,nRoomIndex, nPos)
	local ret = StmtOperater._CountSoulNumByPos:ExecStat(nCharID, nRoomIndex,nPos)
	return ret(1,1)
end

local StmtDef = 
{
	"_GetSoulPearlInfoByGrid",
	[[
		select 	pearl.ip_uSoulNum
		from 		tbl_item_pearl as pearl,tbl_item_in_grid as room
		where 	pearl.is_uId = room.is_uId 
		and 		room.gir_uGridID = ?
		limit 1
	]]
}
DefineSql(StmtDef,StmtOperater)
--���õ�ĳλ������Ʒ�Ļ�ֵ��Ϣ��
function CGasRoomDbBox.GetSoulPearlInfoByGrid(nGridID)
	local ret = StmtOperater._GetSoulPearlInfoByGrid:ExecStat(nGridID)
	if ret:GetRowNum() == 0 then
		return 0
	end
	return ret(1,1)
end

---------------------------------------------------------------------------------------------
local StmtDef = 
{
	"_GetSoulPearlInfoByID",
	[[
		select ip_uSoulNum from tbl_item_pearl where is_uId = ? 
	]]
}
DefineSql(StmtDef,StmtOperater)
--��������Ʒid�õ�������Ϣ��
function CGasRoomDbBox.GetSoulPearlInfoByID(nItemID)
	local ret = StmtOperater._GetSoulPearlInfoByID:ExecSql("n",nItemID)
	if ret:GetRowNum() == 0 then
		ret:Release()
		return 0
	end
	local res1 = ret:GetData(0,0)
	ret:Release()
	return res1
end
---------------------------------------------------------------------------------------------
local StmtDef=
{
    "_SelectWhichRoomHaveItem",
    [[
    	select 
    		gir_uRoomIndex,gir_uPos 
    	from 
    		tbl_grid_info as iiig,tbl_grid_in_room igp
    	where 
    		iiig.gir_uGridID = igp.gir_uGridID
    		and
    		cs_uId = ? and
    		 ( 
	          (gir_uRoomIndex >= ? and gir_uRoomIndex <= ?)
          or gir_uRoomIndex = ?
         )
    		and gi_uCount > 0;
    ]]
}
DefineSql(StmtDef,StmtOperater)
--���ĸ��ռ��ж�����
function CGasRoomDbBox.WhichPositionHaveItem(nCharID,nStoreMain)
	local nFirstRoom,nLastRoom = g_GetRoomRange(nStoreMain)
	local query_result = StmtOperater._SelectWhichRoomHaveItem:ExecStat(nCharID,nFirstRoom,nLastRoom,nStoreMain)
	return query_result
end
---------------------------------------------------------------------------------------------
local StmtDef=
{
    "_SelectRoomItem",
    [[
    	select iip.is_uId,isb_bIsbind 
    	from tbl_grid_in_room igp join tbl_item_in_grid as iip
    			on(igp.gir_uGridID = iip.gir_uGridID)
    	left join tbl_item_is_binding as bind 
    		on(iip.is_uId = bind.is_uId)
    	where cs_uId = ? and gir_uRoomIndex = ? and gir_uPos = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--����ѯĳλ���ϵ�������Ʒid��
function CGasRoomDbBox.GetAllItemFromPosition(nCharID,nRoomIndex,nPos)
	local query_result = StmtOperater._SelectRoomItem:ExecStat(nCharID,nRoomIndex,nPos)
	
	return query_result
end
------------------------------------------------------------------------------------------------

local StmtDef=
{
    "_SelectBagTypeAndRoom",
    [[
    	select 	bag.ibiu_uRoomIndex,item.is_uType,item.is_sName 
    		from 	tbl_item_static as item 
    	join 		tbl_item_bag_in_use as bag 
    	on 			bag.is_uId = item.is_uId 
    	where 	bag.cs_uId = ? 
    	and bag.ibiu_uRoomIndex >= ?
    	and bag.ibiu_uRoomIndex <= ?
    	order by bag.ibiu_uBagSlotIndex;
    ]]
}
DefineSql(StmtDef,StmtOperater)
--����ѯĳ��ɫ��������չ��������Ϣ��
function CGasRoomDbBox.GetAllBagTypeAndBagRoom(nCharID,nStoreMain)
	local FirstRoom,LastRoom = g_GetRoomRange( nStoreMain )
	local query_result = StmtOperater._SelectBagTypeAndRoom:ExecStat(nCharID,FirstRoom,LastRoom)
	
	return query_result
end

-----------------------------------------------------------------------------------------------
--ͨ����Ʒid�������Ʒ����
local StmtDef=
{
    "_SelectItemType",
    [[
    	select is_uType,is_sName from tbl_item_static
    	where is_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--��������Ʒid���ĳ��Ʒ�����ƺ�������Ϣ��
--�������ھͷ���nil��
function CGasRoomDbBox.GetItemType(nItemID)
	local res = StmtOperater._SelectItemType:ExecStat(nItemID)
	if res:GetRowNum() == 0 then
		res:Release()
		return 
	end
	local ret1 = res:GetData(0,0)
	local ret2 = res:GetData(0,1)
	return ret1, ret2
end
------------------------------------------------------------------------------------

local StmtDef=
{
    "_GetBindTypeByID",
    "select isb_bIsbind from tbl_item_is_binding where is_uId = ?;" 
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.GetItemBindingTypeByID(nItemID)
	local res = StmtOperater._GetBindTypeByID:ExecStat(nItemID)
	if res:GetRowNum() == 0 then
		return 0
	end
	return res:GetData(0,0)
end

function CGasRoomDbBox.HaveBindingInfo(nItemID)
	local res = StmtOperater._GetBindTypeByID:ExecStat(nItemID)
	return res:GetRowNum() > 0
end

---------------------------------------------------------------------------------------
local StmtDef=
{
    "_CountItemLimitByName",
    [[
    	select count(*) from tbl_item_use_limit where iul_sItemName = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.CountItemLimitByName(item_type,sItemName)
	local res = StmtOperater._CountItemLimitByName:ExecSql("n",sItemName)
	return res:GetData(0,0),item_type
end

------------------------------------------------------------------------------------
local StmtDef=
{
    "_GetItemNameByID",
    [[
    	select is_uType,is_sName from tbl_item_static where is_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.CountItemLimitByID(nItemID)
	local res = StmtOperater._GetItemNameByID:ExecStat(nItemID)
	if res:GetRowNum() == 0 then return 0,res(1,1) end
		
	return CGasRoomDbBox.CountItemLimitByName(res(1,1),res(1,2))
end

--------------------------------------------------------------------------

local StmtDef=
{
    "_UpdateGridIDByID",
    [[
    	update tbl_item_in_grid
    	set gir_uGridID = ? where is_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

function CGasRoomDbBox.UpdateGridIDByItemID(nGridID,nItemID)
	StmtOperater._UpdateGridIDByID:ExecStat(nGridID,nItemID)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		error("�޸���Ʒ������ʧ��")
	end
end

--------------------------------------�����ּ��ӿڡ�----------------------------------------------
local StmtDef=
{
    "_GetSlotByRoom",
    "select ibiu_uBagSlotIndex from tbl_item_bag_in_use where cs_uId = ? and ibiu_uRoomIndex = ?;" 
}
DefineSql(StmtDef,StmtOperater)

--�жϲ۵ķ�Χ�Ƿ���ȷ
function CGasRoomDbBox.CheckBySlot(nSlot)
	if (nSlot >= g_SlotIndex.FirstBagSlot and nSlot <= g_SlotIndex.LastBagSlot) then
		return true
	end
	if (nSlot >= g_SlotIndex.FirstDepotSlot and nSlot <= g_SlotIndex.LastDepotSlot) then
		return true
	end
	return false
end

function CGasRoomDbBox.CheckByRIndex(nRoomIndex, nCharID)
	if nRoomIndex == g_StoreRoomIndex.PlayerBag then
		--˵���ǰ���
		return true
	end
	if nRoomIndex == g_StoreRoomIndex.PlayerDepot then
		--˵���ǲֿ�
		return true
	end
	if nRoomIndex>= g_StoreRoomIndex.SlotRoomBegin and nRoomIndex < g_StoreRoomIndex.SlotRoomLast then
		--˵������չ����
		local nSlot = StmtOperater._GetSlotByRoom:ExecSql("n",nCharID,nRoomIndex)
		if nSlot  then
			if nSlot:GetRowNum() ~= 0 then
				local flag = CGasRoomDbBox.CheckBySlot(nSlot:GetData(0,0))
				nSlot:Release()
				return flag
			end
			nSlot:Release()
		end
	end
	return false
end

--���жϿռ����ͺ�λ���Ƿ񳬳���Χ��
function CGasRoomDbBox.CheckRoomAndPos(nCharID,nRoom,nPos)
	if not g_IsInStaticRoom(nRoom) then
		--�����ռ�,��Ҫ��ѯĿ�걳���Ƿ�����,nCharID,nRoom��Ψһ��
		local nRoomBigID,nRoomIndex = CGasRoomDbBox.GetBagTypeByRoom(nCharID,nRoom)
		if nRoomBigID == nil then
			return false
		end
		--�ж�Ŀ��pos�Ƿ񳬳���Χ
		local BagRoom = g_ItemInfoMgr:GetItemInfo(nRoomBigID,nRoomIndex,"BagRoom")
		if BagRoom < nPos or nPos < 1 then
			return false
		end
	else
		--���ռ��ж�
		if g_IsPosIsRight(nRoom,nPos) == false then
			return false
		end
	end
	return true
end

--���ڲ��������Ƚ�nRoom���Ƿ���tblRooms�С�
function CGasRoomDbBox.CheckRoomInTblRoom(nRoom,tblRooms)
	if tblRooms == nil then
		return false
	end
	for n=1,tblRooms:GetRowNum() do
		if nRoom == tblRooms(n,1) then
			return true
		end
	end
	return false
end

--���ñ����Ƿ���������ϡ�
function CGasRoomDbBox.IsInPlayerBag(nCharID,nRoom)
	if nRoom == g_StoreRoomIndex.PlayerBag then
		return true
	else 
		local nFirstSlot,nLastSlot = g_GetSlotRange(g_StoreRoomIndex.PlayerBag)
		local AllRoomId = CGasRoomDbBox.GetRoomIDBySlotRange(nCharID,nFirstSlot,nLastSlot)
		return CGasRoomDbBox.CheckRoomInTblRoom(nRoom,AllRoomId)
	end
end

-------------------------------------��������Ʒ��ء�--------------------------------------------
--��ӻ���
local StmtDef = 
{
	"_CreateSoulPearl",
	[[
		insert into tbl_item_pearl (is_uId,ip_uSoulNum) values (?,?)
	]]
}
DefineSql(StmtDef, StmtOperater)

function CGasRoomDbBox.CreateSoulpearl(uItemId,UnusedSoulNum)
	StmtOperater._CreateSoulPearl:ExecSql("", uItemId, UnusedSoulNum)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

--���ĳ�����͵���Ʒ
local StmtDef=
{
    "_InsertIntoItem",
    "insert into tbl_item_static (is_uId,is_uType,is_sName) values(?,?,?);" 
}
DefineSql(StmtDef,StmtOperater)

--��ѯ��Ʒ���к�
local StmtDef=
{
    "_QueryItemCode",
    "select si_sCode from " .. LogDBName .. ".tbl_serial_item where lcs_uId = ?"
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_SaveItemCode",
    "replace into " .. LogDBName .. ".tbl_serial_item(lcs_uId,si_sCode) values(?,md5(?))"
}
DefineSql(StmtDef,StmtOperater)


local StmtDef=
{
    "_AddItemAmountInfo",
    "insert into tbl_item_amount_limit(cs_uId,is_sName) values(?,?);" 
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_CountItemAmountInfo",
    "select count(*) from tbl_item_amount_limit where cs_uId = ? and is_sName = ?;" 
}
DefineSql(StmtDef,StmtOperater)

--��Ӱ���Ϣ����Ʒ�󶨱�
local StmtDef=
{
    "_InsertIntoBinding",
    "replace into tbl_item_is_binding (is_uId,isb_bIsbind) values(?,?);" 
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_CreateItemId",
    "insert into " ..  LogDBName .. ".tbl_item_id values();" 
}
DefineSql(StmtDef,StmtOperater)

function CGasRoomDbBox.CountItemAmountByName(char_id,ItemName)
	if ItemNumLimit_Common(ItemName) then
		local tbl_count = StmtOperater._CountItemAmountInfo:ExecStat(char_id,ItemName)
		if tbl_count(1,1) >= ItemNumLimit_Common(ItemName,"Amount") then
			return
		end
		StmtOperater._AddItemAmountInfo:ExecStat(char_id,ItemName)
		if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
			error("��ӵ�������Ʒ����ʧ��")
		end
	end
	return true
end

--��������Ʒ���ýӿڡ�
function CGasRoomDbBox.CreateItem(data)
	local sBigID,sIndex = data.m_nType,data.m_sName --��Ʒ���ࡢ����
	local nBindingType = data.m_nBindingType	--������
	local charId = data.m_nCharID 		
	local createType = data.m_sCreateType
	local uEventId = data.m_nEventID
	local uLevel = data.m_nLevel
	
	assert(sBigID) 
	assert(sIndex)
	assert(charId)
	local soulpearlCount
	local g_LogMgr = RequireDbBox("LogMgrDB")
	if g_ItemInfoMgr:IsSoulPearl(sBigID) then
        sIndex, soulpearlCount = g_ItemInfoMgr:GetSoulpearlInfo(sIndex)
	end
	if not g_ItemInfoMgr:HaveItem(sBigID,sIndex) then
		LogErr("����Ʒ�����ñ��в�����","sBigID:" .. sBigID .. "sIndex:" .. sIndex)
		return false,23
	end
	if CGasRoomDbBox.CountItemLimitByName(sBigID,sIndex) > 0 then
		LogErr("����Ʒ����ֹʹ��","sBigID:" .. sBigID .. "sIndex:" .. sIndex)
		return false,21
	end
	if not CGasRoomDbBox.CountItemAmountByName(charId,sIndex) then
		return false,55
	end

	StmtOperater._CreateItemId:ExecStat()
	local ItemID = g_DbChannelMgr:LastInsertId()
	if ItemID == nil then
		error("��Ʒ����ʧ��")
	end
	
	local code_res = StmtOperater._QueryItemCode:ExecStat(charId)
	local code
	if code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_item_static"
	end
	
	StmtOperater._SaveItemCode:ExecStat(charId,code)
	if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
		error("��Ʒ����ʧ��")
	end
	
	g_LogMgr.CopyItemInfo(ItemID,tonumber(sBigID),sIndex,charId,code)
	if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
		error("����Ʒ���log��Ϣʧ��")
	end
	
	StmtOperater._InsertIntoItem:ExecSql("",ItemID,tonumber(sBigID),sIndex)
	if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
		error("�����Ʒ��Ϣʧ��")
	end
	
	--���ͼ��Ϣ��
	if g_ItemInfoMgr:IsOreAreaMap(sBigID) then
		local OreMapItemDB = RequireDbBox("OreMapItemDB")
		local result = OreMapItemDB.SaveOreMapById(ItemID,sIndex,charId)
		if not result then
			LogErr("�����Ʒ���ͼʧ��","sBigID:" .. sBigID .. "sIndex:" .. sIndex  .. "ID:" .. ItemID)
			return false
		end
	elseif g_ItemInfoMgr:IsPickOreItem(sBigID) then
		local DuraValue = g_ItemInfoMgr:GetItemInfo(sBigID,sIndex,"MaxDurabilityValue")
		local PickOreItemDB = RequireDbBox("PickOreItemDB")
		local result = PickOreItemDB.SaveDurabilityById(ItemID, DuraValue)
		if not result then
			LogErr("�����Ʒ�ɿ󹤾�ʧ��","sBigID:" .. sBigID .. "sIndex:" .. sIndex  .. "ID:" .. ItemID)
			return false
		end
	end
	--������
	nBindingType = nBindingType or g_ItemInfoMgr:GetItemInfo( sBigID, sIndex,"BindingStyle" )
	if nBindingType and nBindingType > 0 then
		StmtOperater._InsertIntoBinding:ExecSql("",ItemID,nBindingType)
		if  g_DbChannelMgr:LastAffectedRowNum() < 1 then
			LogErr("��Ӱ���Ϣʧ��","��Ӱ���Ϣʧ��" .. "sBigID:" .. sBigID .. "sIndex:" .. sIndex  .. "ID:" .. ItemID)
			CancelTran()
			return false
		end
		g_LogMgr.LogItemBindInfo(charId,ItemID,nBindingType)
	end
	--������
	local ItemLifeMgrDB = RequireDbBox("ItemLifeMgrDB")
	if not ItemLifeMgrDB.AddItemLifeInfo(sBigID,sIndex,ItemID,0) then
		LogErr("�����Ʒ������ʧ��","sBigID:" .. sBigID .. "sIndex:" .. sIndex  .. "ID:" .. ItemID)
		CancelTran()
		return false
	end
	--�ж��Ƿ���װ�����ǵĻ���ӵ�װ����
	if g_ItemInfoMgr:IsStaticEquip(sBigID) then 
		local g_EquipDbMgr = RequireDbBox("EquipMgrDB")
		g_EquipDbMgr.CreateEquip(ItemID,uLevel,charId) 
	elseif (g_ItemInfoMgr:IsSoulPearl(sBigID)) then
		if CGasRoomDbBox.CreateSoulpearl(ItemID,soulpearlCount) == false then	
			LogErr("��ӻ�����Ϣʧ��","��ӻ�����Ϣʧ��" .. "sBigID:" .. sBigID .. "sIndex:" .. sIndex  .. "ID:" .. ItemID)
			CancelTran()
			return false
		end
	elseif (g_ItemInfoMgr:IsExpOrSoulBottle(sBigID)) then
		local ExpOrSoulStorageDB = RequireDbBox("ExpOrSoulStorageDB")
		ExpOrSoulStorageDB.CreateExpOrSoulBottle(charId,ItemID,sIndex)
	end
	--����дlog
	local g_LogMgr = RequireDbBox("LogMgrDB")
	g_LogMgr.LogCreateItem(charId,ItemID,createType,uEventId)
	return ItemID
end

--------------------------------�������Ʒ��ء�-------------------------------------
--����Ʒ�ŵ�ĳ���ռ��ĳ��λ��
local StmtDef=
{
    "_InsertIntoRoom",
    "insert into tbl_item_in_grid (is_uId,gir_uGridID) values(?,?)" 
}
DefineSql(StmtDef,StmtOperater)

function CGasRoomDbBox.PutIntoRoom(nCharID,nGridID,nItemID,bCallback)
	StmtOperater._InsertIntoRoom:ExecStat(nItemID,nGridID)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		error("�����Ʒλ����Ϣʧ��")
	end
	CGasRoomDbBox.AddPosCountByGridID(nGridID,1,nItemID)
	if "notCallBack" ~= bCallback then
		Db2CallBack("RetAddItemID",nCharID,nItemID)
	end
	return true
end

local function SetResult(OneRet,nRoom,nPos,nCount,nBigID,nIndex)
	assert(IsTable(OneRet))
	OneRet.m_nRoomIndex = nRoom
	OneRet.m_nPos = nPos
	OneRet.m_nCount = nCount
	OneRet.m_nBigID = nBigID
	OneRet.m_nIndex = nIndex
	return OneRet
end

function CGasRoomDbBox.AddItem2RoomAndCallBack(AllItem,nCharID,nRoomIndex,nPos,nBigID,nIndex,nBType)
	local DynaInfo = {}
	if g_ItemInfoMgr:IsStaticEquip(nBigID) then
		local EquipMgrDB = RequireDbBox("EquipMgrDB")
		DynaInfo = EquipMgrDB.GetEquipAllInfo(AllItem[1])
	elseif g_ItemInfoMgr:IsMailTextAttachment(nBigID) then
		local mail_item = RequireDbBox("MailItemDB")
		DynaInfo = mail_item.GetMailTextAttachmentByID(AllItem[1],nCharID)
	elseif g_ItemInfoMgr:IsSoulPearl(nBigID) then
		local nASoulNum = CGasRoomDbBox.GetSoulPearlInfoByID(AllItem[1])
		DynaInfo = {nASoulNum}
	elseif g_ItemInfoMgr:IsBoxitem(nBigID) then
    local BoxitemDB = RequireDbBox("BoxitemDB")
    local openedFlag = BoxitemDB.IsBoxitemOpened(AllItem, nCharID)
    DynaInfo = {openedFlag}
	end
	local ItemLifeMgrDB = RequireDbBox("ItemLifeMgrDB")
	local ItemMakerMgrDB = RequireDbBox("ItemMakerMgrDB")
	local life = ItemLifeMgrDB.GetOneItemLife(AllItem[1],nBigID,nIndex)
	ItemMakerMgrDB.SendItemMakerByTblIDs(nCharID,{AllItem[1]})
	
	Db2CallBack("RetItemRoom",nCharID,nRoomIndex)
	local nGridID = CGasRoomDbBox.GetGridID(nCharID,nRoomIndex,nPos)
	local GridSoul = CGasRoomDbBox.GetSoulPearlInfoByGrid(nGridID)
	for i =1,# AllItem do
		if GridSoul > 0 and GridSoul ~= CGasRoomDbBox.GetSoulPearlInfoByID(AllItem[i]) then
			CancelTran()
		  return 63
		end
		if not CGasRoomDbBox.PutIntoRoom(nCharID,nGridID,AllItem[i],"notCallBack") then
		  	CancelTran()
		  	return 57
		 end
	end
	
	AllItem.m_nLeftTime = life
	AllItem.m_nBindType 	= nBType
	AllItem.m_nPos				=	nPos
	AllItem.m_nBigID			=	nBigID
	AllItem.m_nIndex			=	nIndex
	AllItem.m_tblDynaInfo = DynaInfo
	AllItem.m_nGridID			=	nGridID
	Db2CallBack("RetAddItemInfoEnd",nCharID,AllItem)
	Db2CallBack("RetRefreshBag",nCharID)
	return AllItem
end

function CGasRoomDbBox.AddItemByPos(nCharID,nBigID,nIndex,nRoomIndex,nPos,nCount,BindingType,createType,uEventId)
	local ItemName = nIndex
	if g_ItemInfoMgr:IsSoulPearl(nBigID) then
		ItemName = nIndex
		nIndex = g_ItemInfoMgr:GetSoulpearlInfo(nIndex)
	end
	
	if not CGasRoomDbBox.CheckRoomAndPos(nCharID,nRoomIndex,nPos) then
		return 39
	end
	
	if nCount <= 0 then
		return 40
	end
	if not g_ItemInfoMgr:CheckType( nBigID,nIndex ) then
		return 23
	end
	
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"FoldLimit" ) or 1
	local nHaveCount = CGasRoomDbBox.GetCountByPosition(nCharID,nRoomIndex,nPos)
	if nHaveCount + nCount > FoldLimit then
		return 42
	end
	
	local OnlyLimit =  g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"Only" )
	if OnlyLimit and OnlyLimit > 0 then
		local havenum = CGasRoomDbBox.GetAllItemCount(nCharID, nBigID, nIndex)
		if havenum + nCount > OnlyLimit then
			return 43
		end
	end
	local nBType = BindingType or g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"BindingStyle" )
	if nHaveCount ~= 0 then
		local sItemType,sItemName,_,nBindingType = CGasRoomDbBox.GetOneItemByPosition(nCharID,nRoomIndex,nPos)
		if  sItemName ~= nIndex or tonumber(nBigID) ~= tonumber(sItemType) or (nBindingType ~= nBType) then
			return 44
		end
	end
	
	local params= {}
	params.m_nType = nBigID
	params.m_sName =  ItemName
	params.m_nBindingType = nBType or 0
	params.m_nCharID = nCharID
	params.m_sCreateType = createType
	params.m_nEventID = uEventId
	
	local AllItem = {}
	for n=1, nCount do
		local nID,uMsgID = CGasRoomDbBox.CreateItem(params)
		if not nID then
			return IsNumber(uMsgID) and uMsgID or 56
		end
		if IsNumber(nID) then
			table.insert(AllItem,nID)
		end
	end
	
	return CGasRoomDbBox.AddItem2RoomAndCallBack(AllItem,nCharID,nRoomIndex,nPos,nBigID,nIndex,nBType)
end

--�жϱ����ռ��Ƿ��㹻
function CGasRoomDbBox.HaveEnoughRoomPos(nCharID,ItemType,ItemName,nCount)
	local ItemName,SoulpearlCount = g_ItemInfoMgr:GetSoulpearlInfo(ItemName)
	
	local nMainRoomSize = g_GetMainRoomSize(g_StoreRoomIndex.PlayerBag)
	local OnlyLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"Only" )
	if OnlyLimit and OnlyLimit > 0 then
		local havenum = CGasRoomDbBox.GetAllItemCount(nCharID, ItemType, ItemName)
		if havenum + nCount > OnlyLimit then
			return false
		end
	end
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
	local nBindingType = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"BindingStyle" ) or 0
	local RoomPosCount = CGasRoomDbBox.GetPosAndCountByType(nCharID, ItemType, ItemName, g_StoreRoomIndex.PlayerBag, FoldLimit,nBindingType )
	
	local nSum,OtherNeedGrid= 0,0
	local AllItem,SetResult={},{}
	
	--������Ҫ�յĸ�����
	if RoomPosCount[1] == nil then
		--˵���ÿռ仹û��δ�ﵽ�������޵���Ʒ
		OtherNeedGrid = math.ceil(nCount / FoldLimit)
	else
		for n=1, #RoomPosCount do
			--�����Ѿ��и���Ʒ��λ��һ�����ܵ��Ŷ��ٸ���Ʒ
			local nSoulNum = CGasRoomDbBox.GetSoulPearlInfoByPos(nCharID,RoomPosCount[n][1], RoomPosCount[n][2])
			if SoulpearlCount == nSoulNum then
				--���ǻ��飬���ǻ����һ�ֵ��ͬ
				nSum = FoldLimit - RoomPosCount[n][3] + nSum
			end
		end
		if nSum - nCount < 0 then
			--���ܵ��ŵ���Ʒ����С��Ҫ���ŵ���Ʒ����
			OtherNeedGrid = math.ceil((nCount - nSum) / FoldLimit)
		else
			OtherNeedGrid = 0
		end
	end
	
	nSum = nCount
	local tblRoomPos,tblBagGridNum,UseEmptyRoom = {},{},{}

	--��Ҫ��ĸ��ӣ������Ƿ���ô��յĸ���
	if OtherNeedGrid ~= 0 then
		--����ʹ�ÿյĸ��������
		local BagIndex = CGasRoomDbBox.GetAllBagTypeAndBagRoom(nCharID,g_StoreRoomIndex.PlayerBag)
		table.insert(tblBagGridNum,{g_StoreRoomIndex.PlayerBag,nMainRoomSize})  	--���������ռ��źͿռ��С����tblBagGridNum����
		for n=1, BagIndex:GetRowNum() do
			--��ÿһ�����ӱ����Ŀռ�λ�úʹ�С
			table.insert(tblBagGridNum,{BagIndex(n,1),g_ItemInfoMgr:GetItemInfo(BagIndex(n,2),BagIndex(n,3),"BagRoom")}) --BagRoom��ָ�ñ������Դ�ŵ���Ʒ����
		end
		--��ѯ�Ѿ�����Ʒ�ĸ���
		local HaveItemRoomCount = CGasRoomDbBox.WhichPositionHaveItem(nCharID,g_StoreRoomIndex.PlayerBag)

		--�����Ѿ�����Ʒ�ĸ��Ӳ��ұ�,���HaveItemRoomCountΪ�մ���Ҳһ��
		for n=1, HaveItemRoomCount:GetRowNum() do
			--��Ҫ�ж��Ƿ�Ϊnil����Ȼ����Ļ��ǰ������
			if tblRoomPos[HaveItemRoomCount(n,1)] == nil then
				tblRoomPos[HaveItemRoomCount(n,1)] = {}
			end	
			tblRoomPos[HaveItemRoomCount(n,1)][HaveItemRoomCount(n,2)] = {}
		end
		for i=1, #tblBagGridNum do
			if #UseEmptyRoom >= OtherNeedGrid then 
				break
			end
			for j=1, tblBagGridNum[i][2] do
				--���������Ʒ�Ľ�������Ҳ�����˵���������û��ʹ�ù�
				if tblRoomPos[tblBagGridNum[i][1]] == nil or tblRoomPos[tblBagGridNum[i][1]][j] == nil then 
					--������õĿյĸ���λ��
					table.insert(UseEmptyRoom,{tblBagGridNum[i][1],j}) 
					--�ҵ��㹻�Ŀո��ӣ�����
					if #UseEmptyRoom >= OtherNeedGrid then 
						break
					end
				end
			end
		end
	end
	return #UseEmptyRoom == OtherNeedGrid 
end

--�������Ʒ��
function CGasRoomDbBox.AddItem(data)
	local params = data
	params.nARoom = 0
	params.nAPos = 0
	return CGasRoomDbBox.GetItem(params)
end

--�����������Ʒ��ĳ��λ�ã������λ�ò��ܷţ����Զ���������λ�á�
function CGasRoomDbBox.PriAddItemByPos(nCharID,nBigID,nIndex,nRoomIndex,nPos,nCount,BindingType,createType,uEventId)
	local result = CGasRoomDbBox.AddItemByPos(nCharID,nBigID,nIndex,nRoomIndex,nPos,nCount,BindingType,createType,uEventId)
	if IsNumber(result) then
			local params= {}
			params.nCharID = nCharID
			params.nStoreMain = nRoomIndex
			params.nBigID = nBigID
			params.nIndex = nIndex
			params.nCount = nCount
			params.createType = createType
			return CGasRoomDbBox.AddItem(params)
	end
	return result
end

--���ж�����λ���ϵ���Ʒ����Ϣ�Ƿ���ͬ��
function CGasRoomDbBox.HaveTheSameSoulNumByPos(nCharID,nARoom,nAPos,nBRoom, nBPos)
    local itemAType, itemAName, itemAID  = CGasRoomDbBox.GetOneItemByPosition(nCharID,nARoom,nAPos)
    local itemBType, itemBName, itemBID = CGasRoomDbBox.GetOneItemByPosition(nCharID,nBRoom,nBPos)
    local nASoulNum,nBSoulNum = 0,0
    if g_ItemInfoMgr:IsSoulPearl(itemAType)then
	    nASoulNum = CGasRoomDbBox.GetSoulPearlInfoByPos(nCharID,nARoom,nAPos)
		end
		if g_ItemInfoMgr:IsSoulPearl(itemBType) then
			nBSoulNum = CGasRoomDbBox.GetSoulPearlInfoByPos(nCharID,nBRoom,nBPos)
		end
		return (nASoulNum == nBSoulNum)
end

--��������ȡ������Ʒ���Ǹ��ռ伯�У����nARoom,nAPos = 0��ʾ�����Ʒ��
function CGasRoomDbBox.GetItem(data)
	local nCharID = data.nCharID
	local nARoom = data.nARoom
	local nAPos = data.nAPos
	local nStoreMain = data.nStoreMain
	local nBigID = data.nBigID
	local nIndex = data.nIndex
	local nCount = data.nCount
	local BindingType = data.BindingType
	local createType = data.createType
	local uEventId = data.uEventId
	--�ж���ȡ��Ʒ�����������Ʒ
	local ItemName = nIndex
	local soul_count = 0
	if g_ItemInfoMgr:IsSoulPearl(nBigID) then
		ItemName = nIndex
		nIndex,soul_count = g_ItemInfoMgr:GetSoulpearlInfo(nIndex)
	end
	local sType = "Add"
	if nARoom ~= 0 or nAPos ~= 0 then
		if not CGasRoomDbBox.CheckRoomAndPos(nCharID,nARoom,nAPos) then
			return 39
		end
		sType = "Get"
	end	

	if nCount <= 0 then
		return 40
	end
	--����Ǳ���ģ������server�ж���
	if not g_ItemInfoMgr:CheckType( nBigID,nIndex ) then
		return 23
	end
	local nMainRoomSize = g_GetMainRoomSize(nStoreMain)
	local OnlyLimit = g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"Only" )
	if OnlyLimit and OnlyLimit > 0 then
		local havenum = CGasRoomDbBox.GetAllItemCount(nCharID, nBigID, nIndex)
		if havenum + nCount > OnlyLimit then
			return 43
		end
	end
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"FoldLimit" ) or 1
	--��øÿռ����Ʒ�Ŀռ�λ�ü���λ���ϵ���Ʒ����
	local RoomPosCount = CGasRoomDbBox.GetPosAndCountByType(nCharID,nBigID,nIndex,nStoreMain,FoldLimit,BindingType or g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"BindingStyle" ) or 0)

	local nSum,OtherNeedGrid= 0,0
	local AllItem,OneAddRet = {},{}
	--������Ҫ�յĸ�����
	if RoomPosCount[1] == nil then
		--�ÿռ仹û�д���Ʒ��ֱ������Ҫ�ĸ�����
		--math.ceil������ȡ��������С����
		OtherNeedGrid = math.ceil(nCount / FoldLimit)
	else
		for n=1, #RoomPosCount do
			--�����Ѿ��и���Ʒ��λ��һ�����ܵ��Ŷ��ٸ���Ʒ
			if ((nARoom == 0 or nAPos == 0) and (soul_count == CGasRoomDbBox.GetSoulPearlInfoByPos(nCharID,RoomPosCount[n][1], RoomPosCount[n][2])))
				or (nARoom ~= 0 and nAPos ~= 0 and CGasRoomDbBox.HaveTheSameSoulNumByPos(nCharID,nARoom,nAPos,RoomPosCount[n][1], RoomPosCount[n][2])) then
				--���ǻ��飬���ǻ����һ�ֵ��ͬ
				nSum = FoldLimit - RoomPosCount[n][3] + nSum
			end
		end
		if nSum - nCount < 0 then
			--���ܵ��ŵ���Ʒ����С��Ҫ����Ʒ����
			OtherNeedGrid = math.ceil((nCount - nSum) / FoldLimit)
		else
			OtherNeedGrid = 0
		end
	end
	
	nSum = nCount
	local tblRoomPos,tblBagGridNum,UseEmptyRoom = {},{},{}

	--�����Ҫ��ĸ��ӣ���Ҫ�����Ƿ���ô��յĸ���
	if OtherNeedGrid ~= 0 then
		--����ʹ�ÿյĸ��������
		local BagIndex = CGasRoomDbBox.GetAllBagTypeAndBagRoom(nCharID,nStoreMain)
		table.insert(tblBagGridNum,{nStoreMain,nMainRoomSize})
		--���챳���ͱ�����С��Ӧ��ϵ��
		for n=1, BagIndex:GetRowNum() do
			table.insert(tblBagGridNum,{BagIndex(n,1),g_ItemInfoMgr:GetItemInfo(BagIndex(n,2),BagIndex(n,3),"BagRoom")})
		end
		--��ѯ�Ѿ�����Ʒ�ĸ���
		local HaveItemRoomCount = CGasRoomDbBox.WhichPositionHaveItem(nCharID,nStoreMain)

		--�����Ѿ�����Ʒ�ĸ��Ӳ��ұ�,���HaveItemRoomCountΪ�մ���Ҳһ��
		for n=1, HaveItemRoomCount:GetRowNum() do
			--��Ҫ�ж��Ƿ�Ϊnil����Ȼ����Ļ��ǰ������
			if tblRoomPos[HaveItemRoomCount(n,1)] == nil then
				tblRoomPos[HaveItemRoomCount(n,1)] = {}
			end	
			tblRoomPos[HaveItemRoomCount(n,1)][HaveItemRoomCount(n,2)] = {}
		end
		for i=1, #tblBagGridNum do
			if #UseEmptyRoom >= OtherNeedGrid then 
				break
			end
			for j=1,tblBagGridNum[i][2] do
				--���������Ʒ�Ľ�������Ҳ�����˵���������û��ʹ�ù�
				if tblRoomPos[tblBagGridNum[i][1]] == nil or tblRoomPos[tblBagGridNum[i][1]][j] == nil then 
					--������õĿյĸ���λ��
					table.insert(UseEmptyRoom,{tblBagGridNum[i][1],j}) 
					--�ҵ��㹻�Ŀո��ӣ�����
					if #UseEmptyRoom >= OtherNeedGrid then 
						break
					end
				end
			end
		end
	end
	
	--û���㹻�Ŀռ�
	if #UseEmptyRoom ~= OtherNeedGrid then
		return 47 
	end
	
	--�����Ʒ������ͬ����Ʒ�ĸ�������ӣ����������˾�ֱ�ӷ���
	for n=1, #RoomPosCount do
		local nRoom,nPos,nFoldCount = RoomPosCount[n][1],RoomPosCount[n][2],RoomPosCount[n][3]
		if nSum <= 0 then
			return AllItem
		end
		if ((nARoom == 0 or nAPos == 0) and (soul_count == CGasRoomDbBox.GetSoulPearlInfoByPos(nCharID,RoomPosCount[n][1], RoomPosCount[n][2])))
			or (nARoom ~= 0 and nAPos ~= 0 and CGasRoomDbBox.HaveTheSameSoulNumByPos(nCharID,nARoom,nAPos,RoomPosCount[n][1], RoomPosCount[n][2])) then
			--����ǻ���,����λ���ϻ���Ļ�ֵ��ȣ����߲��ǻ��飬��ʱ��Ʒ��ֵΪ0��Ҳ���Ե���
			if nSum - (FoldLimit - nFoldCount) >= 0 then
				--�����Ѿ��и���Ʒ��λ��һ�����ܵ��Ŷ��ٸ���Ʒ
				nSum = nSum - (FoldLimit - nFoldCount)
				if sType == "Add" then
					OneAddRet = CGasRoomDbBox.AddItemByPos(nCharID,nBigID,ItemName,nRoom,nPos,FoldLimit - nFoldCount,BindingType,createType,uEventId)
				else
					OneAddRet = CGasRoomDbBox.GetItemFromA2B(nCharID,nARoom,nAPos,nCharID,nRoom,nPos,FoldLimit - nFoldCount)
				end
				nFoldCount = FoldLimit - nFoldCount
			else
				if sType == "Add" then
					OneAddRet = CGasRoomDbBox.AddItemByPos(nCharID,nBigID,ItemName,nRoom,nPos,nSum,BindingType,createType,uEventId)
				else
					OneAddRet = CGasRoomDbBox.GetItemFromA2B(nCharID,nARoom,nAPos,nCharID,nRoom,nPos,nSum)
				end
				nFoldCount = nSum
				nSum = 0
			end
			if IsTable(OneAddRet) then
				table.insert(AllItem,SetResult(OneAddRet,nRoom,nPos,nFoldCount,nBigID,nIndex))
			elseif IsNumber(OneAddRet) then
				return OneAddRet
			end
		end
	end
	--�ڿյĸ��������
	
	for n=1, OtherNeedGrid do
		local nRoom,nPos,nFoldCount = UseEmptyRoom[n][1],UseEmptyRoom[n][2],0
		if nSum - FoldLimit  >= 0 then
			nSum = nSum - FoldLimit
			if sType == "Add" then
				OneAddRet = CGasRoomDbBox.AddItemByPos(nCharID,nBigID,ItemName,nRoom,nPos,FoldLimit,BindingType,createType,uEventId)
			else
				OneAddRet = CGasRoomDbBox.GetItemFromA2B(nCharID,nARoom,nAPos,nCharID,nRoom,nPos,FoldLimit)
			end
			nFoldCount = FoldLimit
		else
			if sType == "Add" then
				OneAddRet = CGasRoomDbBox.AddItemByPos(nCharID,nBigID,ItemName,nRoom,nPos,nSum,BindingType,createType,uEventId)
			else
				OneAddRet = CGasRoomDbBox.GetItemFromA2B(nCharID,nARoom,nAPos,nCharID,nRoom,nPos,nSum)
			end
			nFoldCount = nSum
			nSum = 0
		end
		if IsTable(OneAddRet) then
			table.insert(AllItem,SetResult(OneAddRet,nRoom,nPos,nFoldCount,nBigID,nIndex))
		elseif IsNumber(OneAddRet) then
				return OneAddRet
		end
	end
	return AllItem
end
----------------------------------��ɾ����Ʒ��ء�--------------------------------------------------------
local StmtDef=
{
    "_DelItemByIDFromRoom",
    "delete from tbl_item_in_grid where is_uId = ?;" 
}
DefineSql(StmtDef,StmtOperater)
--��������Ʒidɾ����Ʒ��
function CGasRoomDbBox.DelItemByID(nCharID,nItemID,delType,uEventId,bCallback)
	local num,uType =  CGasRoomDbBox.CountItemLimitByID(nItemID)
	local ItemBagLockDB = RequireDbBox("ItemBagLockDB")
	--�ʻ�����������ɾ����������Ʒ��������Ʒ
	if ItemBagLockDB.HaveItemBagLock(nCharID) then
		--��������״̬�¿��������񡢲μ���Ҫ���ĵ��ߵĸ����
		if uType ~= 16 and delType ~= event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"] then
			return false,160031
		end
	end
	if num > 0 then
		--����ƷĿǰ��ֹʹ��
		return false,21
	end
	local succ,eventId = CGasRoomDbBox.DelItemFromStaticTable(nItemID,nCharID,delType,uEventId,bCallback)
	return true,eventId
end

--������λ��ɾ��һ����������Ʒ��
function CGasRoomDbBox.DelItemByPos(nCharID,nRoomIndex,nPos,nCount,delType,bCallback)	
	--�жϿռ��λ���Ƿ���ȷ
	if CGasRoomDbBox.CheckRoomAndPos(nCharID,nRoomIndex,nPos) == false then
		return 39
	end
	
	if nCount <= 0 then
		return 	41
	end
	--�õ���λ��������Ʒid
	local nRoomItem = CGasRoomDbBox.GetAllItemFromPosition(nCharID,nRoomIndex,nPos)
	--ɾ������Ŀ������Ʒ��ʵ����Ŀ
	if nRoomItem:GetRowNum() < nCount then
		return 48
	end
	local AllItem = {}
	for y=1, nRoomItem:GetRowNum() do
		local bFlag,uMsgID = CGasRoomDbBox.DelItemByID(nCharID,nRoomItem(y,1),delType,nil,bCallback)
		if (not bFlag) and IsNumber(uMsgID) then
			return uMsgID
		end
		table.insert(AllItem,nRoomItem(y,1))
		if #AllItem == nCount then
			break
		end
	end 
	if #AllItem < nCount then
		return 59
	end
	--�������б�ɾ����Ʒid
	return AllItem
end

--���Ӱ���������Ʒ��������ɾ����
function CGasRoomDbBox.MoveItemFromPackage(nCharID,nItemID,bCallback)
	if CGasRoomDbBox.CountItemLimitByID(nItemID) > 0 then
		--����ƷĿǰ��ֹʹ��
		return false,21
	end
	local pos_info = CGasRoomDbBox.GetRoomIndexAndPosByItemId(nCharID, nItemID)
	local item_type,item_name = CGasRoomDbBox.GetItemType(nItemID)
	StmtOperater._DelItemByIDFromRoom:ExecStat(nItemID)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then return end
		
	if pos_info then
		CGasRoomDbBox.AddItemPosCountByPos(nCharID,pos_info(1,1),pos_info(1,2),-1)
		Db2CallBack("RetDelPet",nCharID,item_name,item_type)
		if "notCallBack" ~= bCallback then
			--ֻ�дӱ���ɾ���ŵ���
			Db2CallBack("RetDelItemByPos",nCharID,nItemID,pos_info(1,1),pos_info(1,2),false)
		end
	end
	return true
end

--������λ��ɾ��һ���������������Ʒ(������ɾ��)��
function CGasRoomDbBox.MoveItemFromPackageByPos(nCharID,nRoomIndex,nPos,nCount,bCallback)	
	if CGasRoomDbBox.CheckRoomAndPos(nCharID,nRoomIndex,nPos) == false then
		return 39
	end
	
	if nCount <= 0 then
		return 	41
	end
	local nRoomItem = CGasRoomDbBox.GetAllItemFromPosition(nCharID,nRoomIndex,nPos)
	if nRoomItem:GetRowNum() < nCount then
		return 48 
	end
	local AllItem = {}
	local db_count = nRoomItem:GetRowNum()
	for y=1, db_count do
		local bFlag,uMsgID = CGasRoomDbBox.MoveItemFromPackage(nCharID,nRoomItem(y,1),bCallback)
		if (not bFlag) and IsNumber(uMsgID) then
			return uMsgID
		end
		table.insert(AllItem,nRoomItem(y,1))
		if #AllItem == nCount then
			break
		end
	end 
	if #AllItem < nCount then
		return 59
	end
	return AllItem
end

local StmtDef = {
	"_QueryItemType",
	[[ 
		select is_uType from tbl_item_static where is_uId = ?
	]]
}
DefineSql (StmtDef,StmtOperater)

--����Ʒ��̬���ﳹ��ɾ��
local StmtDef = {
	"_DeleteItemFromStaticTable",
	[[ 
		delete from	tbl_item_static where is_uId = ?
	]]
}
DefineSql (StmtDef,StmtOperater)

--������ɾ����Ʒ��
function CGasRoomDbBox.DelItemFromStaticTable(itemId,charId,delType,uEventId,bCallback)
	assert(charId,"ɾ����Ʒû�����Id")
	assert(IsNumber(itemId))
	if delType == nil and uEventId == nil then
		LogErr("ɾ����Ʒû�м�¼log����")
	end
	local res = StmtOperater._QueryItemType:ExecStat(itemId)
	local pos_info = CGasRoomDbBox.GetRoomIndexAndPosByItemId(charId, itemId)
	local item_type,item_name = CGasRoomDbBox.GetItemType(itemId)
	local uBigId = res:GetData(0,0)
	--װ��ɾ��ǰ�����ж�̬��Ϣ�ٴ�һ��log
	if uBigId >= 5 and uBigId <= 9 then
		local g_EquipDbMgr = RequireDbBox("EquipMgrDB")
		g_EquipDbMgr.DelEquipDynamicInfoSaveLog(charId,itemId,uBigId)
	end
	StmtOperater._DeleteItemFromStaticTable:ExecSql("",itemId)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		error("ɾ����Ʒʧ��")
	end
	local g_LogMgr = RequireDbBox("LogMgrDB")  	--��־������
	local succ,eventId = g_LogMgr.LogDelAndUseItem(uEventId,charId,itemId,delType,item_type,item_name)
	if not succ then
		error("��¼ɾ����Ʒlogʧ��")
	end
	if pos_info then
		CGasRoomDbBox.AddItemPosCountByPos(charId,pos_info(1,1),pos_info(1,2),-1)
		Db2CallBack("RetDelPet",charId,item_name,uBigId)
		if "notCallBack" ~= bCallback then
			--ֻ�дӱ���ɾ���ŵ���
			Db2CallBack("RetDelItemByPos",charId,itemId,pos_info(1,1),pos_info(1,2),true)
		end
	end
	return true,eventId
end

function CGasRoomDbBox.DelItem(nCharID,nBigID,nIndex,nCount,FromRoom,delType)	
	if nCount <= 0 then
		return 	41
	end
	if not g_ItemInfoMgr:CheckType( nBigID,nIndex ) then
		return 23
	end
	
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"FoldLimit" ) or 1 
	local FromRoom = FromRoom or g_StoreRoomIndex.PlayerBag
	local RoomPosCount = CGasRoomDbBox.GetPosAndCountByType(nCharID,nBigID,nIndex,FromRoom,FoldLimit+1)
	
	local nSum = 0
	local AllItem,DelRet = {},{}
	
	--�����ж��ٸ�����Ʒ
	if RoomPosCount[1] ~= nil then
		for n=1, #RoomPosCount do
			nSum = RoomPosCount[n][3] + nSum
		end
	end
	
	if nSum < nCount then
		return 48
	end
	
  nSum = nCount
	for n=1, #RoomPosCount do
		local nRoom,nPos,nFoldCount = RoomPosCount[n][1],RoomPosCount[n][2],RoomPosCount[n][3]
		if nSum <= 0 then
			break
		elseif nSum - nFoldCount >= 0 then
			nSum = nSum - nFoldCount
			DelRet = CGasRoomDbBox.DelItemByPos(nCharID,nRoom,nPos,nFoldCount,delType)
		else
			DelRet = CGasRoomDbBox.DelItemByPos(nCharID,nRoom,nPos,nSum,delType)
			nFoldCount = nSum
			nSum = 0
		end
		if IsTable(DelRet) then
			table.insert(AllItem,SetResult(DelRet,nRoom,nPos,nFoldCount,nBigID,nIndex))
		elseif IsNumber(DelRet) then
			return DelRet
		end
	end
	
	return AllItem
end

---------------------------------------���ƶ���Ʒ��ء�-------------------------------------------------
--[[
	���²���ĳ����Ʒ��id,��ĳ�������У��ڽ���װ����ʱ��Ҫ��.
--]]
function CGasRoomDbBox.RenewItemRoomPos(nCharID,nItemID,nRoomIndex,nPos)	

	if not CGasRoomDbBox.CheckRoomAndPos(nCharID,nRoomIndex,nPos) then
		return 39
	end
	
	local nHaveCount = CGasRoomDbBox.GetCountByPosition(nCharID,nRoomIndex,nPos)
	if nHaveCount ~= 0 then
		return 57
	end
	Db2CallBack("RetItemRoom",nCharID,nRoomIndex)
	local nGridID = CGasRoomDbBox.GetGridID(nCharID,nRoomIndex,nPos)	
	if not CGasRoomDbBox.PutIntoRoom(nCharID,nGridID,nItemID) then
		CancelTran()
		return 57
	end
	Db2CallBack("RetAddItemToGridEndEx",nCharID,nGridID,nPos)
	Db2CallBack("RetRefreshBag",nCharID)
	return {}
end

--[[
	˵����
		�������������ӵ���ƷReplaceRoomA2B��
--]]
local StmtDef=
{
    "_UpdateRoomPosByGridID",
    "update tbl_grid_in_room set gir_uRoomIndex = ?,gir_uPos = ? where gir_uGridID = ?;"
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.UpdateRoomPosByGridID(nCharID,nRoom,nPos,nGridID)
	StmtOperater._UpdateRoomPosByGridID:ExecStat(nRoom,nPos,nGridID)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		error("����gridid�޸�room and pos ʧ��")
	end
	Db2CallBack("ResetRoomPosByGridID",nCharID,nGridID,nRoom,nPos)
end

function CGasRoomDbBox.ReplaceRoomA2B(nACharID,nARoom,nAPos,nBCharID,nBRoom,nBPos)
	local nBCount = CGasRoomDbBox.GetCountByPosition(nBCharID,nBRoom,nBPos)
	local nACount = CGasRoomDbBox.GetCountByPosition(nACharID,nARoom,nAPos)
	
	if nACount == 0 and nBCount == 0 then
		--a��b��Ϊ��
		return 
	elseif nBCount == 0 then
		--b����û����Ʒ�����a���ӵ��ƶ���b
		local nAGridID = CGasRoomDbBox.GetGridID(nACharID,nARoom,nAPos)
		CGasRoomDbBox.UpdateRoomPosByGridID(nACharID,nBRoom,nBPos,nAGridID)
	elseif nACount == 0 then
		--���A����û����Ʒ����� b���ӵ��ƶ���a
		local nBGridID = CGasRoomDbBox.GetGridID(nBCharID,nBRoom,nBPos)
		CGasRoomDbBox.UpdateRoomPosByGridID(nACharID,nARoom,nAPos,nBGridID)
	else
		--A,b���Ӷ�����Ʒ����a,b��Ʒ����λ��
		local nAGridID = CGasRoomDbBox.GetGridID(nACharID,nARoom,nAPos)
		local nBGridID = CGasRoomDbBox.GetGridID(nBCharID,nBRoom,nBPos)
		CGasRoomDbBox.UpdateRoomPosByGridID(nACharID,nARoom,nAPos,nBGridID)
		CGasRoomDbBox.UpdateRoomPosByGridID(nACharID,nBRoom,nBPos,nAGridID)
	end
end

--����һ��������count����Ʒ����һ�����ӡ�
function CGasRoomDbBox.GetItemFromA2B(nACharID,nARoom,nAPos,nBCharID,nBRoom,nBPos,nCount)
	if CGasRoomDbBox.CheckRoomAndPos(nACharID,nARoom,nAPos) == false or CGasRoomDbBox.CheckRoomAndPos(nBCharID,nBRoom,nBPos) == false then
		return 39
	end
	
	if nCount <= 0 then
		return 	41
	end
	if nACharID == nBCharID and nARoom == nBRoom and nAPos == nBPos then
		return 58
	end

	local nARoomItem = CGasRoomDbBox.GetAllItemFromPosition(nACharID,nARoom,nAPos)
	
	local nACount = nARoomItem:GetRowNum()
	if nACount < nCount then
		return 48
	end
	local nABigID,nAIndex,_,nABindingType = CGasRoomDbBox.GetOneItemByPosition(nACharID,nARoom,nAPos)
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( nABigID,nAIndex,"FoldLimit" ) or 1
	
	local nBBigID,nBIndex,_,nBBindingType = CGasRoomDbBox.GetOneItemByPosition(nBCharID,nBRoom,nBPos)
	local nBCount = CGasRoomDbBox.GetCountByPosition(nBCharID,nBRoom,nBPos)
	if nBCount == 0 then  
		if nCount > FoldLimit then
			return 42
		end
	else 
		--�ڶ�����������Ʒ
		if  nBBigID ~= nABigID or nBIndex ~= nAIndex or (not CGasRoomDbBox.HaveTheSameSoulNumByPos(nACharID,nARoom,nAPos,nBRoom, nBPos)) then
			return 60
		else
			if nBCount + nCount > FoldLimit then
				return 42
			end
		end
	end
	
	local nAGridID = CGasRoomDbBox.GetGridID(nACharID,nARoom,nAPos)
	local nBGridID = CGasRoomDbBox.GetGridID(nBCharID,nBRoom,nBPos)
	local AllItem = {}
	for n=1, nACount do
		if n > nCount then
			break
		end
		CGasRoomDbBox.UpdateGridIDByItemID(nBGridID,nARoomItem(n,1))
		table.insert(AllItem,nARoomItem(n,1))
	end
	
	CGasRoomDbBox.AddPosCountByGridID(nAGridID,-nCount)
	CGasRoomDbBox.AddPosCountByGridID(nBGridID,nCount,AllItem[1])
	
	local nItems = {} 
	--�����Ͳ�һ������ת���ɰ󶨵�
	if nBBindingType and nABindingType ~= nBBindingType then
		local res1 = CGasRoomDbBox.SelectAllItemIDByPos(nBCharID,nBRoom,nBPos)
		local nItem = {}
		for i=1,res1:GetRowNum() do
			table.insert(nItem,res1(i,1))
		end
		CGasRoomDbBox.UpdateItemBindingType(2, nItem,nACharID)
		CGasRoomDbBox.UpdateItemBindingType(2, AllItem,nACharID)
		for j=1,#AllItem do
			table.insert(nItem,AllItem[i])
		end
		table.insert(nItems,nItem)
		table.insert(nItems,nABigID)
		table.insert(nItems,nAIndex)
		Db2CallBack("UpdateItemBindingType",nACharID,nItems)
	end
	AllItem.nBigID = nABigID
	AllItem.nIndex = nAIndex
	AllItem.nBindingType = nABindingType
	Db2CallBack("GetItemFromA2B",nACharID,AllItem,nARoom,nAPos,nBGridID,nBRoom,nBPos)
	return AllItem
end

--������ƶ���Ʒ��
function CGasRoomDbBox.MoveItem(nCharID,nARoom,nAPos,nBRoom,nBPos)
	local nACount,nBCount = {},{}
	if CGasRoomDbBox.CheckRoomAndPos(nCharID,nARoom,nAPos) == false or CGasRoomDbBox.CheckRoomAndPos(nCharID,nBRoom,nBPos) == false then
		return 39
	end
	
	if nARoom == nBRoom and nAPos == nBPos then
		return 58
	end
	nACount = CGasRoomDbBox.GetCountByPosition(nCharID,nARoom,nAPos)
	if nACount <= 0 then
		return 40
	end

	nBCount = CGasRoomDbBox.GetCountByPosition(nCharID,nBRoom,nBPos)
	if nARoom == 1 and nBRoom == 2 then
		local nABigID,nAIndex,_,nABindingType = CGasRoomDbBox.GetOneItemByPosition(nCharID,nARoom,nAPos)
		Db2CallBack("RetDelPet",nCharID,nAIndex,nABigID)
	end
	if nBCount == 0 then
		CGasRoomDbBox.ReplaceRoomA2B(nCharID,nARoom,nAPos,nCharID,nBRoom,nBPos)
		return {},"Replace"
	else
		local nABigID,nAIndex,_,nABindingType = CGasRoomDbBox.GetOneItemByPosition(nCharID,nARoom,nAPos)
		if nABigID == nil or nAIndex == nil then 
			return 41
		end
		local FoldLimit = g_ItemInfoMgr:GetItemInfo( nABigID,nAIndex,"FoldLimit" ) or 1
		local nBBigID,nBIndex,_,nBBindingType = CGasRoomDbBox.GetOneItemByPosition(nCharID,nBRoom,nBPos)
		if nABigID == nBBigID and nAIndex == nBIndex  then
			local nMoveCount = 0
			if (nBCount ~= FoldLimit) and (nBCount + nACount >  FoldLimit) then
				nMoveCount = FoldLimit - nBCount
			else
				nMoveCount = nACount
			end
			if nBCount == FoldLimit then
				--B������Ʒ����������ޣ���a��bλ����Ʒֱ�ӽ���
				CGasRoomDbBox.ReplaceRoomA2B(nCharID,nARoom,nAPos,nCharID,nBRoom,nBPos)
				return {},"Replace"
			end
      if CGasRoomDbBox.HaveTheSameSoulNumByPos(nCharID,nARoom,nAPos,nBRoom, nBPos) == false then
				--B������Ʒ����������ޣ���a��bλ����Ʒֱ�ӽ���
				CGasRoomDbBox.ReplaceRoomA2B(nCharID,nARoom,nAPos,nCharID,nBRoom,nBPos)
				return {},"Replace"
			end
			--��a�ƶ�nMoveCount��Ʒ��bλ��
			local res = CGasRoomDbBox.GetItemFromA2B(nCharID,nARoom,nAPos,nCharID,nBRoom,nBPos,nMoveCount)
			return res,"Move"
		else
			--a��bλ����Ʒ��ͬ�࣬����λ����Ʒ����
			CGasRoomDbBox.ReplaceRoomA2B(nCharID,nARoom,nAPos,nCharID,nBRoom,nBPos)
			return {},"Replace"
		end
	end
end

--��ͨ���Ҽ�����ڱ����Ͳֿ���н�����Ʒ��
function CGasRoomDbBox.QuickMoveItem(nCharID,nARoom,nAPos,nStoreMain)

	if not CGasRoomDbBox.CheckRoomAndPos(nCharID,nARoom,nAPos) then
		return 39
	end
	if not g_IsInStaticRoom(nStoreMain) then
		return 39
	end

	local nBigID,nIndex,nCount = CGasRoomDbBox.GetTypeCountByPosition(nCharID,nARoom,nAPos)
	if nCount == nil or nCount == 0 then
		return 41
	end
	if nARoom == 1 and nStoreMain == 2 then
		Db2CallBack("RetDelPet",nCharID,nIndex,nBigID)
	end
	local nBindingType = CGasRoomDbBox.GetBindingTypeByPos(nCharID,nARoom,nAPos)
	local data = {}
	data.nCharID = nCharID
	data.nARoom = nARoom
	data.nAPos = nAPos
	data.nStoreMain = nStoreMain
	data.nBigID = nBigID
	data.nIndex = nIndex
	data.nCount = nCount
	data.BindingType = nBindingType
	data.createType = 0
	return CGasRoomDbBox.GetItem(data)
end

-------------------------------����������---------------------------------------------------
local StmtDef=
{
    "_GetPosCountByType",
    [[ 
     select
     		iiig.gir_uGridID,gi_uCount 
     		from tbl_grid_info iiig,tbl_grid_in_room igp
     where
     		igp.gir_uGridID = iiig.gir_uGridID
     		and cs_uId = ?
     		and is_uType = ?
     		and is_sName = ?
     		and 
        ( 
          (gir_uRoomIndex >= ? and gir_uRoomIndex <= ?)
          or gir_uRoomIndex = ?
        )
     and gi_uCount < ? and gi_uCount > 0
     order by gi_uCount DESC
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_UpdateItemPosByID",
    "update tbl_item_in_grid set gir_uGridID = ? where is_uId = ?;" 
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_GetAllTypeAndCountInfo",
    [[ 
     select
     		is_uType,is_sName,iiig.gir_uGridID,gi_uCount 
     		from tbl_grid_info iiig,tbl_grid_in_room igp
     where
     		igp.gir_uGridID = iiig.gir_uGridID
     		and cs_uId = ?
     		and 
        ( 
          (gir_uRoomIndex >= ? and gir_uRoomIndex <= ?)
          or gir_uRoomIndex = ?
        )
     and gi_uCount > 0
     order by is_uType,is_sName,gi_uCount DESC
    ]]
}
DefineSql(StmtDef,StmtOperater)
local StmtDef=
{
    "_GetSomeItemIDByGridID",
    [[ 
     select is_uId from tbl_item_in_grid 
     where gir_uGridID = ? 
   	limit ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_GetBindingTypeByGridID",
    [[
    	select 
    		ifnull(binding.isb_bIsbind,0)
    	from 
    		tbl_item_in_grid as iip
    	left join tbl_item_is_binding as binding
    		on iip.is_uId = binding.is_uId
    	where 
    		iip.gir_uGridID = ?
    	limit 1
    ]]
}
DefineSql(StmtDef,StmtOperater)
StmtDef=
{
    "_GetAllItemOrderInfo",
    [[
    	select  iiig.is_sName,iiig.is_uType,gir_uRoomIndex,gir_uPos,iiig.gi_uCount,iiig.gir_uGridID,ifnull(iso_uSmallType,1000) as SmallType,ifnull(iso_uBaseLevel,0) as BaseLevel,ifnull(ito.is_uOrder,100) as TypeOrder
    	from 	tbl_grid_in_room igp
    				join tbl_grid_info as iiig
    					on(igp.gir_uGridID = iiig.gir_uGridID) 
    				left join tbl_item_type_order as ito
    				 on(iiig.is_uType = ito.is_uType)
    				left join tbl_item_smalltype_order as ist
    				 on(iiig.is_sName = ist.is_sName and iiig.is_uType = ist.is_uType)
    	where 
    		igp.cs_uId = ?
    	and	
    		( 
          (gir_uRoomIndex >= ? and gir_uRoomIndex <= ?)
          or gir_uRoomIndex = ?
        )
      and iiig.gi_uCount > 0
      group by gir_uRoomIndex,gir_uPos
       order by TypeOrder ASC,SmallType ASC,BaseLevel DESC,iiig.is_sName ASC,iiig.gi_uCount DESC,gir_uRoomIndex DESC,gir_uPos DESC
    ]]
}
DefineSql(StmtDef,StmtOperater)


local StmtDef=
{
    "_GetPosByGridID",
    [[
    	select gir_uRoomIndex,gir_uPos from tbl_grid_in_room
    	where gir_uGridID = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CGasRoomDbBox.GetBindingTypeByGridID(nGridID)
	local tbl_type = StmtOperater._GetBindingTypeByGridID:ExecStat(nGridID)
	if tbl_type:GetRowNum() == 0 then
		tbl_type:Release()
		return 
	end
	return tbl_type(1,1)
end

function CGasRoomDbBox.GetPosByGridID(nGridID)
	local tbl_pos = StmtOperater._GetPosByGridID:ExecStat(nGridID)
	if tbl_pos:GetRowNum() == 0 then return end
	return {tbl_pos(1,1),tbl_pos(1,2)}
end

local function GetTheSameItem(nCharID,nBigID,nIndex,nStoreMain,FoldLimit,nBindingType,grid_id,tblBeMoved)
	local nFirstRoom,nLastRoom = g_GetRoomRange(nStoreMain)
	local query_result = StmtOperater._GetPosCountByType:ExecStat(nCharID,nBigID,nIndex,nFirstRoom,nLastRoom,nStoreMain,FoldLimit)
	local result = {}
	for i =1,query_result:GetRowNum() do
		local grid_id,count = query_result(i,1),query_result(i,2)
		if not nBindingType or nBindingType == CGasRoomDbBox.GetBindingTypeByGridID(grid_id) then
				table.insert(result,{grid_id,count})
		end
	end
	local soul_res = result
	if g_ItemInfoMgr:IsSoulPearl(nBigID) then
		local nSoulNum = CGasRoomDbBox.GetSoulPearlInfoByGrid(grid_id)
		soul_res = {}
		for i =1,#result do
			local SoulNumi = CGasRoomDbBox.GetSoulPearlInfoByGrid(result[i][1])
			if nSoulNum == SoulNumi then
				table.insert(soul_res,result[i])
			end
		end
	end
	local ret_res = {}
	for j = 1,#soul_res do
		if not tblBeMoved[soul_res[j][1]] then
				table.insert(ret_res,soul_res[j])
				tblBeMoved[soul_res[j][1]] = true
		end
	end
	return ret_res,tblBeMoved
end

function CGasRoomDbBox.ResetAllItemPos(nCharID,nStoreRoom)
	if not (nStoreRoom == g_StoreRoomIndex.PlayerBag or nStoreRoom == g_StoreRoomIndex.PlayerDepot) then
		LogErr("�������������Ϣ", "nStoreMain:" .. nStoreMain)
		return {}
	end
	
	local tbl_old_res = {}
	local tbl_new_res = {}
	
	local function SetMoveRes(res,old_grid_id,new_grid_id,item_type,item_name,binding_type)
		if old_grid_id == new_grid_id then return end
		local tbl_old_resi = {}
		local tbl_new_resi = {}
		local move_count = res:GetRowNum()
		for i = 1, move_count do
			local nItemID = res(i,1)
			table.insert(tbl_old_resi,nItemID)
			table.insert(tbl_new_resi,nItemID)
			StmtOperater._UpdateItemPosByID:ExecStat(new_grid_id,nItemID)
			if g_DbChannelMgr:LastAffectedRowNum() < 1 then
				error("�޸���Ʒ������ʧ��")
			end
		end
		local old_pos = CGasRoomDbBox.GetPosByGridID(old_grid_id)
		CGasRoomDbBox.AddPosCountByGridID(old_grid_id,-move_count)
		CGasRoomDbBox.AddPosCountByGridID(new_grid_id,move_count,res(1,1))
		tbl_old_resi.old_pos 			= old_pos
		tbl_new_resi.new_pos			= CGasRoomDbBox.GetPosByGridID(new_grid_id)
		tbl_new_resi.grid_id 			= new_grid_id
		tbl_new_resi.item_type 		= item_type
		tbl_new_resi.item_name 		= item_name
		tbl_new_resi.binding_type = binding_type
		table.insert(tbl_old_res,tbl_old_resi)
		table.insert(tbl_new_res,tbl_new_resi)
	end
	
	local function FoldItem(tblAllPosCount,item_type,item_name,binding_type,FoldLimit)
			local pos_row = #tblAllPosCount
			if pos_row > 1 then
				local now_point,have_count = pos_row,0
				for j =1,pos_row do
					local move_count = 0
					local countj = tblAllPosCount[j][2]
					if now_point <= j then
							break
					end
					for k = now_point,1,-1 do
						if k == j or countj >= FoldLimit then
							break
						end
						if have_count == 0 then
							have_count= tblAllPosCount[k][2]
						end
						if countj + have_count >= FoldLimit then
							move_count = FoldLimit - countj
							have_count = have_count - move_count
						else
							move_count = have_count
							have_count = 0
						end
						countj = countj + move_count
						if have_count == 0 then
							now_point = k - 1
						else
							now_point = k
						end
						if move_count > 0 then
							local tbl_id = StmtOperater._GetSomeItemIDByGridID:ExecStat(tblAllPosCount[k][1],move_count)
							SetMoveRes(tbl_id,tblAllPosCount[k][1],tblAllPosCount[j][1],item_type,item_name,binding_type)
						end
					end
				end
			end
	end
	
	--����
	local nFirstRoom,nLastRoom = g_GetRoomRange(nStoreRoom)
	local tbl_res = StmtOperater._GetAllTypeAndCountInfo:ExecStat(nCharID,nFirstRoom,nLastRoom,nStoreRoom)
	local row = tbl_res:GetRowNum()
	local tblBeMoved = {}
	if row > 1 then
		for i = 1, row do
			local item_type,item_name,grid_id = tbl_res(i,1),tbl_res(i,2),tbl_res(i,3)
			local FoldLimit = g_ItemInfoMgr:GetItemInfo(item_type,item_name,"FoldLimit") or 1 
			if (not tblBeMoved[grid_id]) and FoldLimit > tbl_res(i,4) then
				if i < row and item_type == tbl_res(i+1,1) and item_name == tbl_res(i+1,2) then
					local binding_type = CGasRoomDbBox.GetBindingTypeByGridID(grid_id) or 0
					local tblAllPosCount = {}
					tblAllPosCount,tblBeMoved = GetTheSameItem(nCharID,item_type,item_name,nStoreRoom,FoldLimit,binding_type,grid_id,tblBeMoved)
					if #tblAllPosCount > 1 then
						FoldItem(tblAllPosCount,item_type,item_name,binding_type,FoldLimit)
					end
				end
			end
		end
	end
	--�ƶ�
	local tblOrderRes = StmtOperater._GetAllItemOrderInfo:ExecStat(nCharID,nFirstRoom,nLastRoom,nStoreRoom)
	local BagIndex = CGasRoomDbBox.GetAllBagTypeAndBagRoom(nCharID,nStoreRoom)
	
	local RoomSize  = g_GetRoomSize( nStoreRoom ) 
	local NowRoom,NowPos,BagNumber = nStoreRoom,1,0
	local tblChangedPos,NoChangedPos,BeChangedPos = {},{},{}
	local move_point = 0

	NoChangedPos[NowRoom] = {}
	BeChangedPos[NowRoom]  = {}
	
	local function MovePos()
		if(NowPos == RoomSize)then
			NowPos = 0
			BagNumber = BagNumber + 1
			if BagNumber <= BagIndex:GetRowNum()  then
				NowRoom = BagIndex(BagNumber,1)
				NoChangedPos[NowRoom] = NoChangedPos[NowRoom] or {}
				BeChangedPos[NowRoom]  = BeChangedPos[NowRoom] or {}
				RoomSize = g_ItemInfoMgr:GetItemInfo(BagIndex(BagNumber,2),BagIndex(BagNumber,3),"BagRoom")
			end
		end
		NowPos = NowPos + 1
		move_point = move_point + 1 
	end
	local Row = tblOrderRes:GetRowNum()
	for i = 1,Row do	
		if move_point > Row then
			break
		end
		local FromRoom,FromPos,FromGridID = tblOrderRes(i,3),tblOrderRes(i,4),tblOrderRes(i,6)
		if not (NoChangedPos[FromRoom] and NoChangedPos[FromRoom][FromPos]) then
			if not(FromRoom == NowRoom and FromPos == NowPos) then
				local FromType,FromName,FromCount = tblOrderRes(i,2),tblOrderRes(i,1),tblOrderRes(i,5)
				local NowType,NowName,NowCount
				while (true) do
						if (FromRoom == NowRoom and FromPos == NowPos) then
							break
						end
						if not BeChangedPos[NowRoom][NowPos] then
							NowType,NowName,NowCount = CGasRoomDbBox.GetTypeCountByPosition(nCharID,NowRoom,NowPos)
						else
							NowType,NowName,NowCount = nil,nil,nil
						end
						if NowType == FromType and NowName == FromName and FromCount <= NowCount then
							NoChangedPos[NowRoom][NowPos] = true  --��־��λ�õ���Ʒ�����ƶ�
							MovePos()  --�����ƶ�һ������
						else
							break
						end
				end
				if NowType ~= FromType or NowName ~= FromName or FromCount > NowCount then
					tblChangedPos[1] = tblChangedPos[1] or {}
					if #(tblChangedPos[1]) < 61 then
						table.insert(tblChangedPos[1],{FromGridID,NowRoom,NowPos})
					else
						tblChangedPos[2] = tblChangedPos[2] or {}
						table.insert(tblChangedPos[2],{FromGridID,NowRoom,NowPos})
					end
					BeChangedPos[FromRoom] = BeChangedPos[FromRoom] or {}
					BeChangedPos[FromRoom][FromPos] = true
				end
			end
			MovePos()
		end
	end
	for i = 1,2 do
		local ChangedPosi = tblChangedPos[i]
		if ChangedPosi and next(ChangedPosi) then
			local query_string = "update "
			for m =1,#ChangedPosi do
				query_string = query_string .. "tbl_grid_in_room as grid" .. ChangedPosi[m][1] .. ","
			end
			query_string = string.sub(query_string,1,string.len(query_string)-1) .. " set"
			for m =1,#ChangedPosi do
				query_string = query_string .. " grid" .. ChangedPosi[m][1] .. ".gir_uRoomIndex = ".. ChangedPosi[m][2] .. ",grid" .. ChangedPosi[m][1] ..".gir_uPos = " .. ChangedPosi[m][3] .. ","
			end
			query_string = string.sub(query_string,1,string.len(query_string)-1) .. " where "
			for m =1,#ChangedPosi do
				query_string = query_string .. " grid" .. ChangedPosi[m][1] .. ".gir_uGridID = " .. ChangedPosi[m][1] .. " and"
			end
			query_string = string.sub(query_string,1,string.len(query_string)-3)
			g_DbChannelMgr:TextExecute(query_string)
			if g_DbChannelMgr:LastAffectedRowNum() == 0 then 
				CancelTran()
			end
		end
	end
	local tblRetRes = {}
	tblRetRes.tbl_old_res 		= tbl_old_res
	tblRetRes.tbl_new_res 		= tbl_new_res
	tblRetRes.tbl_changed_pos = tblChangedPos
	return tblRetRes
end

-----------------------------------------------------------------------------
--�����رհ���
return CGasRoomDbBox
 
