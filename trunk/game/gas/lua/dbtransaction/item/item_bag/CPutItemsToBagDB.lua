
gac_gas_require "item/item_info_mgr/ItemInfoMgr"
gac_gas_require "item/store_room_cfg/StoreRoomCfg"

local LogErr = LogErr
local g_ItemInfoMgr = CItemInfoMgr:new()															
local g_StoreRoomIndex = g_StoreRoomIndex  							
local g_GetSlotRange = g_GetSlotRange  										
local g_GetMainRoomSize = g_GetMainRoomSize								
local StmtOperater = {}	
local CPutItemsToBagBox = CreateDbBox(...)
--------------------------------------------------------------------------
--��������Ʒid�жϸ���Ʒ��ĳλ���ϵ���Ʒ��ֵ��Ϣ�Ƿ���ͬ��
function CPutItemsToBagBox.HaveTheSameSoulNumByID(nCharID,nItemID,nBRoom, nBPos)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local nASoulNum = g_RoomMgr.GetSoulPearlInfoByID(nItemID)
	local nBSoulNum = g_RoomMgr.GetSoulPearlInfoByPos(nCharID,nBRoom,nBPos)
	return (nASoulNum == nBSoulNum)	
end

function CPutItemsToBagBox.AddItemByPos(nCharID, ItemType,ItemName,nRoomIndex,nPos,tbl_ItemIDs,BindingType)
	local nCount=table.getn(tbl_ItemIDs)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	if g_ItemInfoMgr:IsSoulPearl(ItemType) then
		ItemName = g_ItemInfoMgr:GetSoulpearlInfo(ItemName)
	end
	if not g_RoomMgr.CheckRoomAndPos(nCharID,nRoomIndex,nPos) then
		LogErr("AddCountItem:��Ʒ����λ�ô���","nCharID:" .. nCharID .. "nRoomIndex:" .. nRoomIndex .. "Pos:" .. nPos)
		return 39
	end
	
	if nCount <= 0 then
		LogErr("AddCountItem:��Ʒ��������","nCount:" .. nCount)
		return 40
	end

	if not g_ItemInfoMgr:CheckType( ItemType,ItemName ) then
		return 41
	end
	
	local nHaveCount = g_RoomMgr.GetCountByPosition(nCharID,nRoomIndex,nPos)
	
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
	if nHaveCount + nCount > FoldLimit then
		return 42
	end
	
	local OnlyLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"Only" )
	if OnlyLimit and OnlyLimit > 0 then
		local havenum = g_RoomMgr.GetAllItemCount(nCharID, ItemType, ItemName)
		if havenum + nCount > OnlyLimit then
			return 43
		end
	end
	local nBType = g_RoomMgr.GetItemBindingTypeByID(tbl_ItemIDs[1])
	if nHaveCount ~= 0 then
		local sItemType,sItemName,_,nBindingType = g_RoomMgr.GetOneItemByPosition(nCharID,nRoomIndex,nPos)
		if  sItemName ~= ItemName or tonumber(ItemType) ~= tonumber(sItemType) or (nBindingType ~= nBType) then
			return 44
		end
	end
	return g_RoomMgr.AddItem2RoomAndCallBack(tbl_ItemIDs,nCharID,nRoomIndex,nPos,ItemType,ItemName,nBType)
end
-----------------------------------------------------------------------------------------------
function CPutItemsToBagBox.AddItemsToBag(data)
	local nCharID = data.m_nCharID
	local ItemType,ItemName = data.m_nItemType,data.m_sItemName
	local itemids = data.m_tblItemID
	local nStoreMain = data.nStoreRoom
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local nFirstSlot,nLastSlot = g_GetSlotRange(nStoreMain)
	
	local nCount=table.getn(itemids)
	
	local nMainRoomSize = g_GetMainRoomSize(nStoreMain)
	
	if nCount <= 0 then
		return 40
	end
	if not g_ItemInfoMgr:CheckType( ItemType,ItemName ) then
		return 41
	end

	local OnlyLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"Only" )
	if OnlyLimit and OnlyLimit > 0 then
		local havenum = g_RoomMgr.GetAllItemCount(nCharID, ItemType, ItemName)
		if havenum + nCount > OnlyLimit then
			return 43
		end
	end
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
	local nBindingType = g_RoomMgr.GetItemBindingTypeByID(itemids[1][1])
	
	--��ѯ�ÿռ����д���Ʒ���ڵ�λ�ü�ÿ��λ���ϵĸ���
	local real_name,soulPearl = g_ItemInfoMgr:GetSoulpearlInfo(ItemName)
	local RoomPosCount = g_RoomMgr.GetPosAndCountByType(nCharID, ItemType, real_name, nStoreMain, FoldLimit,nBindingType )
	local nSum,OtherNeedGrid= 0,0
	local AllItem,SetResult={},{}
	--������Ҫ�յĸ�����
	if RoomPosCount[1] == nil then
		--˵���ÿռ仹û��δ�ﵽ�������޵���Ʒ
		OtherNeedGrid = math.ceil(nCount / FoldLimit)
	else
		for n=1, #RoomPosCount do
			if CPutItemsToBagBox.HaveTheSameSoulNumByID(nCharID,itemids[1][1],RoomPosCount[n][1], RoomPosCount[n][2]) then
				--���ǻ��飬���ǻ����һ�ֵ��ͬ
				--�����Ѿ��и���Ʒ��λ�û��ܵ��Ŷ��ٸ���Ʒ
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

	--�����Ҫ��ĸ��ӣ���Ҫ�����Ƿ���ô��յĸ���
	if OtherNeedGrid ~= 0 then
		--����ʹ�ÿյĸ��������
		local BagIndex = g_RoomMgr.GetAllBagTypeAndBagRoom(nCharID,nStoreMain)
		table.insert(tblBagGridNum,{nStoreMain,nMainRoomSize})  	--���������ռ��źͿռ��С����tblBagGridNum����
		for n=1, BagIndex:GetRowNum() do
			--��ÿһ�����ӱ����Ŀռ�λ�úʹ�С
			table.insert(tblBagGridNum,{BagIndex(n,1),g_ItemInfoMgr:GetItemInfo(BagIndex(n,2),BagIndex(n,3),"BagRoom")}) --BagRoom��ָ�ñ������Դ�ŵ���Ʒ����
		end
		--��ѯ�Ѿ�����Ʒ�ĸ���
		local HaveItemRoomCount = g_RoomMgr.WhichPositionHaveItem(nCharID,nStoreMain)

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
	--û���㹻�Ŀռ�
	if #UseEmptyRoom ~= OtherNeedGrid then
		return 47 
	end
	local start_index=1
	--�����Ʒ������ͬ����Ʒ�ĸ�������ӣ����������˾�ֱ�ӷ���
	for n=1, #RoomPosCount do
		local nRoom,nPos,nFoldCount = RoomPosCount[n][1],RoomPosCount[n][2],RoomPosCount[n][3]
		if nSum <= 0 then
			return AllItem
		end
		if CPutItemsToBagBox.HaveTheSameSoulNumByID(nCharID,itemids[1][1],RoomPosCount[n][1], RoomPosCount[n][2]) then
			--���ǻ��飬���ǻ����һ�ֵ��ͬ
			if nSum - (FoldLimit - nFoldCount) >= 0 then
				nSum = nSum - (FoldLimit - nFoldCount)
				local tbl_items={}
				for i=start_index,start_index+FoldLimit - nFoldCount-1 do
					table.insert(tbl_items,itemids[i][1])
				end
				start_index=start_index+FoldLimit - nFoldCount
				if table.getn(tbl_items)>0 then
					SetResult=CPutItemsToBagBox.AddItemByPos(nCharID, ItemType,ItemName,nRoom,nPos,tbl_items,nBindingType)
				end
				nFoldCount = FoldLimit - nFoldCount
			else
				local tbl_items={}
				for i=start_index,start_index+nSum-1 do
					table.insert(tbl_items,itemids[i][1])
				end
				if table.getn(tbl_items)>0 then
					SetResult=CPutItemsToBagBox.AddItemByPos(nCharID, ItemType,ItemName,nRoom,nPos,tbl_items,nBindingType)
				end
				nFoldCount = nSum
				nSum = 0
			end
			if not SetResult or IsNumber(SetResult) then
				return SetResult
			end
			table.insert(AllItem,SetResult)
		end
	end
	--�ڿյĸ��������
	for n=1, OtherNeedGrid do
		local nRoom,nPos,nFoldCount = UseEmptyRoom[n][1],UseEmptyRoom[n][2],0
		if nSum <= 0 then
			return AllItem
		elseif nSum - FoldLimit  >= 0 then
			nSum = nSum - FoldLimit
			local tbl_items={}
			for i=start_index,start_index+FoldLimit-1  do
				table.insert(tbl_items,itemids[i][1])
			end
			start_index = start_index+FoldLimit - nFoldCount
			SetResult = CPutItemsToBagBox.AddItemByPos(nCharID, ItemType,ItemName,nRoom,nPos,tbl_items,nBindingType)
			nFoldCount = FoldLimit
		else
			local tbl_items = {}
			for i=start_index,start_index+nSum-1 do
				table.insert(tbl_items,itemids[i][1])
			end
			if table.getn(tbl_items)>0 then
				SetResult=CPutItemsToBagBox.AddItemByPos(nCharID, ItemType,ItemName,nRoom,nPos,tbl_items,nBindingType)
			end
			nFoldCount = nSum
			nSum = 0
		end
		if not SetResult or IsNumber(SetResult) then
			return SetResult
		end
		table.insert(AllItem,SetResult)
	end
	Db2CallBack("RetRefreshBag",nCharID)
	return AllItem
end

--[[
		�����һ����������Ʒ��������
		��������ɫid����Ʒ���͡���Ʒ���ơ���Ʒid[����άtable]
--]]
function CPutItemsToBagBox.AddCountItem(data)
	data.nStoreRoom = g_StoreRoomIndex.PlayerBag
	local res = CPutItemsToBagBox.AddItemsToBag(data)
	if not res or IsNumber(res) then
		return false, res
	else
		return true,res
	end
end 

------------------------------------------������ʼ������---------------------------------------------
------------------װ�����
local StmtDef = {
	"_GetWeaponDynInfoByCharID",
	[[
		select 
			room.is_uId,weapon.iw_sName, ifnull(binding.isb_bIsbind,0), weapon.iw_uBaseLevel, weapon.iw_uCurLevel, weapon.iw_uDPS, iw_uAttackSpeed,iw_uDPSFloorRate,
			weapon.iw_uIntensifyQuality, dura.ied_uMaxDuraValue, dura.ied_uCurDuraValue, weapon.iw_sIntenSoul
		from 
			tbl_grid_in_room as igp,tbl_item_in_grid as room, tbl_item_equip_durability as dura,tbl_item_weapon as weapon
		left join tbl_item_is_binding as binding
			on(weapon.is_uId = binding.is_uId)
		where 
			igp.gir_uGridID = room.gir_uGridID
		and
			room.is_uId = weapon.is_uId
		and
		    weapon.is_uId= dura.is_uId 
		and
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetWeaponDynInfoByCharID(nCharID)
	--����
	local ret = StmtOperater._GetWeaponDynInfoByCharID:ExecStat(nCharID)
	return ret
end
local StmtDef = {
	"_GetArmorDynInfoByCharID",
	[[
		select 
			room.is_uId,armor.ia_sName, ifnull(binding.isb_bIsbind,0), armor.ia_uBaseLevel, armor.ia_uCurLevel, 
			armor.ia_uUpgradeAtrrValue1,armor.ia_uUpgradeAtrrValue2,armor.ia_uUpgradeAtrrValue3,ia_uStaticProValue,
		    armor.ia_uIntensifyQuality, dura.ied_uMaxDuraValue, dura.ied_uCurDuraValue, armor.ia_sIntenSoul
		from 
			tbl_grid_in_room as igp,tbl_item_in_grid as room, tbl_item_equip_durability as dura,tbl_item_armor as armor
		left join tbl_item_is_binding as binding
			on(armor.is_uId = binding.is_uId)
		where 
			igp.gir_uGridID = room.gir_uGridID
		and
			room.is_uId = armor.is_uId
		and
		    armor.is_uId = dura.is_uId 
		and
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetArmorDynInfoByCharID(nCharID)
--����
	local ret = StmtOperater._GetArmorDynInfoByCharID:ExecStat(nCharID)
	return ret
end
local StmtDef = {
	"_GetShieldDynInfoByCharID",
	[[
		select 
			room.is_uId,shield.is_sName, binding.isb_bIsbind, shield.is_uBaseLevel, shield.is_uCurLevel,
			shield.is_uIntensifyQuality,
			ifnull(shieldAttr.isa_uAttrValue1, 0),ifnull(shieldAttr.isa_uAttrValue2,0),ifnull(shieldAttr.isa_uAttrValue3, 0), ifnull(shieldAttr.isa_uAttrValue4,0),
			dura.ied_uMaxDuraValue, dura.ied_uCurDuraValue, shield.is_sIntenSoul
		from 
			tbl_item_is_binding as binding
		right join tbl_item_in_grid as room
			on(room.is_uId = binding.is_uId )
		join tbl_grid_in_room as igp
			on(igp.gir_uGridID = room.gir_uGridID)
		join tbl_item_equip_durability as dura
			on(room.is_uId = dura.is_uId )
		join tbl_item_shield as shield
			on(dura.is_uId = shield.is_uId)
		left outer join
			tbl_item_shield_Attr as shieldAttr
			on (shield.is_uId = shieldAttr.is_uId)
		where 
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetShieldDynInfoByCharID(nCharID)
	--����
	local ret = StmtOperater._GetShieldDynInfoByCharID:ExecStat(nCharID)
	return ret
end

local StmtDef = {
	"_GetRingDynInfoByCharID",
	[[
		select 
			room.is_uId,ring.ir_sName, binding.isb_bIsbind, ring.ir_uBaseLevel,ring.ir_uCurLevel, ring.ir_uDPS,ring.ir_uStaticProValue,
			ring.ir_uIntensifyQuality, dura.ied_uMaxDuraValue, dura.ied_uCurDuraValue, ring.ir_sIntenSoul
		from 
			tbl_grid_in_room as igp,tbl_item_in_grid as room, tbl_item_equip_durability as dura,tbl_item_ring as ring
		left join tbl_item_is_binding as binding
			on(ring.is_uId = binding.is_uId)
		where 
			igp.gir_uGridID = room.gir_uGridID
		and
			room.is_uId = ring.is_uId
		and 
		    ring.is_uId = dura.is_uId
		and
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetRingDynInfoByCharID(nCharID)
	--��ָ
	local ret = StmtOperater._GetRingDynInfoByCharID:ExecStat(nCharID)
	return ret
end

local StmtDef = {
	"_GetEquipAddAttrInfo",
	[[
		select room.is_uId,ifnull(iei_sAddAttr4,""),ifnull(iei_uAddAttr4Value,0),ifnull(iei_sAddAttr5,""),ifnull(iei_uAddAttr5Value,0),
			ifnull(iei_sAddAttr6,""),ifnull(iei_uAddAttr6Value,0),ifnull(iei_sAddAttr7,""),ifnull(iei_uAddAttr7Value,0),
			ifnull(iei_sAddAttr8,""),ifnull(iei_uAddAttr8Value,0),ifnull(iei_sAddAttr9,""),ifnull(iei_uAddAttr9Value,0)
		from 
			tbl_item_static, tbl_grid_in_room as igp,tbl_item_in_grid as room left outer join tbl_item_equip_intensifyAddAttr as equipIntenAdd on room.is_uId = equipIntenAdd.is_uId 
		where
			tbl_item_static.is_uId= room.is_uId and room.gir_uGridID = igp.gir_uGridID and tbl_item_static.is_uType >= 5 and tbl_item_static.is_uType <=9 and igp.cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetEquipAddAttrInfoByCharID(nCharID)
	--4��9�׶�ǿ������
	local ret = StmtOperater._GetEquipAddAttrInfo:ExecStat(nCharID)
	return ret
end

local StmtDef = 
{
    "_GetEquipIntensifyInfo",
    [[
        select 
			room.is_uId, ifnull(equip.iei_uIntensifySoulNum, 0), ifnull(equip.iei_uAddAttr1, ""), ifnull(equip.iei_uAddAttrValue1,0), ifnull(equip.iei_uAddAttr2, ""), ifnull(equip.iei_uAddAttrValue2,0),
			ifnull(equip.iei_uIntensifyPhase, 0), ifnull(equip.iei_sSuitName, ""),  ifnull(equip.iei_uIntensifyTimes, 0), 
			ifnull(equip.iei_uIntensifyBackTimes, 0), ifnull(equip.iei_uIntenTalentIndex,0)
		from 
			 tbl_item_static, tbl_grid_in_room as igp, tbl_item_in_grid as room left outer join tbl_item_equip_intensify as equip  on room.is_uId = equip.is_uId
		where 
			 tbl_item_static.is_uId= room.is_uId and room.gir_uGridID = igp.gir_uGridID and tbl_item_static.is_uType >= 5 and tbl_item_static.is_uType <=9 and igp.cs_uId = ? 

    ]]
}
DefineSql(StmtDef, StmtOperater)

---��ѯװ��ǿ����1~3�׶Σ�������Ϣ
function CPutItemsToBagBox.GetEquipIntenInfo(nCharID)
    --4��9�׶�ǿ������
	local ret = StmtOperater._GetEquipIntensifyInfo:ExecStat(nCharID)
	return ret
end

local StmtDef = {
    "_GetEquipAdvanceInfo",
    [[
        select
            room.is_uId, equip.iea_uCurAdvancePhase, equip.iea_uTotalAdvancedTimes, ifnull(equip.iea_uSkillPieceIndex1, 0), ifnull(equip.iea_uSkillPieceIndex2,0),
            ifnull(equip.iea_uSkillPieceIndex3,0) ,ifnull(equip.iea_uSkillPieceIndex4,0), ifnull(equip.iea_uChoosedSkillPieceIndex,0),
            equip.iea_sJingLingType, ifnull(equip.iea_uAdvanceSoulNum, 0), equip.iea_uAdvancedTimes,
            ifnull(equip.iea_uAdvancedAttrValue1,0),ifnull(equip.iea_uAdvancedAttrValue2,0),
            ifnull(equip.iea_uAdvancedAttrValue3,0),ifnull(equip.iea_uAdvancedAttrValue4,0),
            equip.iea_sAdvancedSoulRoot, 
            ifnull(equip.iea_sAdvancedAttr1, ""), 
            ifnull(equip.iea_sAdvancedAttr2, ""), 
            ifnull(equip.iea_sAdvancedAttr3, ""), 
            ifnull(equip.iea_sAdvancedAttr4, "")
        from 
            tbl_item_static, tbl_grid_in_room as igp, tbl_item_in_grid as room left outer join tbl_item_equip_advance as equip  on room.is_uId = equip.is_uId
		where 
			tbl_item_static.is_uId= room.is_uId and room.gir_uGridID = igp.gir_uGridID and tbl_item_static.is_uType >= 5 and tbl_item_static.is_uType <=9 and igp.cs_uId = ?
    ]]
}
DefineSql(StmtDef, StmtOperater)

--�õ�װ������������Ϣ
function CPutItemsToBagBox.GetEquipAdvancefoByCharID(nCharID)
    local ret = StmtOperater._GetEquipAdvanceInfo:ExecStat(nCharID)
    return ret
end
local StmtDef = {
    "_GetEquipArmorPieceEnactment",
    [[
	    select
	        room.is_uId
	    from 
	        tbl_item_static, tbl_grid_in_room as igp, tbl_item_in_grid as room left outer join tbl_item_equip_armor as equip  on room.is_uId = equip.is_uId
			where 
				tbl_item_static.is_uId= room.is_uId and room.gir_uGridID = igp.gir_uGridID and tbl_item_static.is_uType >= 5 and tbl_item_static.is_uType <=9 and igp.cs_uId = ?
    ]]
}
DefineSql(StmtDef, StmtOperater)

--װ��������Ϣ
function CPutItemsToBagBox.GetArmorPieceEnactmentAttr(nCharID)
	local ret = {}
  local item_res = StmtOperater._GetEquipArmorPieceEnactment:ExecStat(nCharID)
  local num = item_res:GetRowNum()
  if num > 0 then
  	local EquipEnactmentDB = RequireDbBox("GasArmorPieceEnactmentDB")
  	for i = 1,num do
  		local itemId = item_res:GetData(i-1,0)
    	local EnactmentInfo = EquipEnactmentDB.GetArmorPieceEnactmentAttr(itemId)
    	table.insert(ret,{itemId,EnactmentInfo})
    end
  end
  return ret
end

local StmtDef = {
    "_GetEquipSuperaddInfoInBag",
    [[
        select room.is_uId, ies_uCurSuperaddPhase
        	    from 
	        tbl_item_static, tbl_grid_in_room as igp,  tbl_item_in_grid as room left outer join tbl_item_equip_superaddation as equip  on room.is_uId = equip.is_uId
			where 
				tbl_item_static.is_uType >= 5 and tbl_item_static.is_uType <=9 and tbl_item_static.is_uId= room.is_uId and room.gir_uGridID = igp.gir_uGridID and  igp.cs_uId = ?
    ]]
}DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetEquipSuperaddInfo(nCharID)
    local ret = StmtOperater._GetEquipSuperaddInfoInBag:ExecStat(nCharID)
    local EquipSuperaddDB = RequireDbBox("EquipSuperaddDB")
    local rowNum = ret:GetRowNum()
    local tbl  = {}
    for i=1, rowNum do
        local equipID = ret:GetData(i-1, 0)
        local curSuperaddPhase = ret:GetData(i-1, 1) or 0
        local equipSuperaddRate = EquipSuperaddDB.GetEquipSuperaddRate(curSuperaddPhase)
        local node = {equipID, curSuperaddPhase, equipSuperaddRate}
        table.insert(tbl, node)
    end
    return tbl
end

--������ҽ�ɫid�õ��������������װ����Ϣ
function CPutItemsToBagBox.GetAllEquipBaseInfoByCharID( nCharID )
	local WeaponDynInfo = CPutItemsToBagBox.GetWeaponDynInfoByCharID(nCharID)
	local ArmorDynInfo = CPutItemsToBagBox.GetArmorDynInfoByCharID(nCharID)
	local ShieldDynInfo = CPutItemsToBagBox.GetShieldDynInfoByCharID(nCharID)
	local RingDynInfo = CPutItemsToBagBox.GetRingDynInfoByCharID(nCharID)
	
	local EquipIntenInfo = CPutItemsToBagBox.GetEquipIntenInfo(nCharID)
	local EquipIntenAddInfo = CPutItemsToBagBox.GetEquipAddAttrInfoByCharID(nCharID) 
	local EquipAdvanceInfo = CPutItemsToBagBox.GetEquipAdvancefoByCharID(nCharID)
	local EnactmentInfo = CPutItemsToBagBox.GetArmorPieceEnactmentAttr(nCharID)
	
	local EquipSuperaddInfo = CPutItemsToBagBox.GetEquipSuperaddInfo(nCharID)
	
	return {["WeaponDynInfo"] = WeaponDynInfo,["ArmorDynInfo"] = ArmorDynInfo,["ShieldDynInfo"] = ShieldDynInfo,
					["RingDynInfo"] = RingDynInfo,["EquipIntenInfo"] = EquipIntenInfo,
					["EquipIntenAddInfo"] = EquipIntenAddInfo, ["EquipAdvanceInfo"]=EquipAdvanceInfo,["EnactmentInfo"] = EnactmentInfo,
					["EquipSuperaddInfo"] =EquipSuperaddInfo }
end

------------------����
local StmtDef = {
			"_SelectArrayBook",
			[[ 
				select 	room.is_uId,ifnull(ib_uPos1,0),ifnull(ib_uPos2,0),ifnull(ib_uPos3,0),ifnull(ib_uPos4,0),ifnull(ib_uPos5,0)
				from 		tbl_item_battlebook as bk,tbl_item_in_grid as room, tbl_grid_in_room as igp
				where 	room.is_uId = bk.is_uId
				and room.gir_uGridID = igp.gir_uGridID
				and 		igp.cs_uId = ?
			]]
}
DefineSql (StmtDef,StmtOperater)
function CPutItemsToBagBox.SelectBattleBookByID(nCharID)
	local res = StmtOperater._SelectArrayBook:ExecSql("nnnnnn",nCharID)
	return res
end
------------------�ʼ��ı���Ʒ
local StmtDef = {
	"_GetMailTextAttachmentByID",
	[[
		select 
			is_uId, iml_sTitle,cs_uSenderName
		from 
			tbl_item_mail_letter as ml,tbl_char as tc
		where 
			ml.cs_uRecieverName = tc.c_sName
		and 
			tc.cs_uId = ?		
	]]
}
DefineSql(StmtDef, StmtOperater)
function CPutItemsToBagBox.GetMailTextAttachmentByID(nCharID)
	local query_result = StmtOperater._GetMailTextAttachmentByID:ExecSql("ns[128]s[32]", nCharID)
	return query_result
end
------------------����
local StmtDef = 
{
	"_GetSoulPearlInfoByChar",
	[[
		select pearl.is_uId,ip_uSoulNum from tbl_item_pearl as pearl,tbl_item_in_grid as room,tbl_grid_in_room as igp
		where 
			room.is_uId = pearl.is_uId
		and
			igp.gir_uGridID = room.gir_uGridID
		and		 
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CPutItemsToBagBox.GetSoulPearlInfoByChar(nCharID)
	local ret = StmtOperater._GetSoulPearlInfoByChar:ExecSql("nn",nCharID)
	return ret
end
------------------���ͼ
local StmtDef = 
{
	"_GetOreMapInfoByChar",
	[[
		select oremap.is_uId,io_sName from tbl_item_oremap as oremap,tbl_item_in_grid as room,tbl_grid_in_room as igp
		where 
			room.is_uId = oremap.is_uId
		and
			igp.gir_uGridID = room.gir_uGridID
		and		 
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CPutItemsToBagBox.GetOreMapInfoByChar(nCharID)
	local ret = StmtOperater._GetOreMapInfoByChar:ExecStat(nCharID)
	return ret
end
------------------�ɿ󹤾�
local StmtDef = 
{
	"_GetPickOreInfoByChar",
	[[
		select pickore.is_uId,ipd_uMaxDura,ipd_uCurDura from tbl_item_pickore_dura as pickore,tbl_item_in_grid as room,tbl_grid_in_room as igp
		where 
			room.is_uId = pickore.is_uId
		and
			igp.gir_uGridID = room.gir_uGridID
		and		 
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CPutItemsToBagBox.GetPickOreInfoByChar(nCharID)
	local ret = StmtOperater._GetPickOreInfoByChar:ExecStat(nCharID)
	return ret
end
-----------------����ƿ����ƿ
local StmtDef = 
{
	"_GetExpAndSoulBottleInfo",
	[[
		select is_uId,isb_uState,isb_uStorageNum from tbl_item_soul_bottle where cs_uId = ?
		union
		select is_uId,ieb_uState,ieb_uStorageNum from tbl_item_exp_bottle where cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CPutItemsToBagBox.GetExpAndSoulBottleInfo(nCharID)
	local ret = StmtOperater._GetExpAndSoulBottleInfo:ExecStat(nCharID,nCharID)
	return ret
end

--������Ʒ�����
local StmtDef = 
{
	"_GetOpenBoxitemInfoByChar",
	[[
		select ibp_uBoxitemId from tbl_item_boxitem_pickup as box,tbl_item_in_grid as room,tbl_grid_in_room as igp
		where 
			room.is_uId = box.ibp_uBoxitemId
		and
			igp.gir_uGridID = room.gir_uGridID
		and		 
			igp.cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtOperater)
function CPutItemsToBagBox.GetBoxitemOpenedFlag(nCharID)
    local ret = StmtOperater._GetOpenBoxitemInfoByChar:ExecStat(nCharID)
    return ret
end

--[[
		��ѯ��ĳ��ɫ��������Ʒ��Ϣ(��Ʒ����name������type����Ʒ���ڿռ�index����Ʒ����λ��pos)
		��������ɫid
--]]
local StmtDef=
{
	"_SelectAllItemInfoByCharID",
	[[
	select
			a.is_uId, igp.gir_uRoomIndex, igp.gir_uPos,b.is_uType, b.is_sName,ifnull(c.isb_bIsbind,0),a.gir_uGridID
	from 
	tbl_grid_in_room as igp
	join tbl_item_in_grid as a 
		on(igp.gir_uGridID = a.gir_uGridID)
	left join
			tbl_item_static as b
	on	 a.is_uId = b.is_uId
	left join tbl_item_is_binding as c
	on 	b.is_uId = c.is_uId 
	where 	igp.cs_uId = ?
	order by igp.gir_uRoomIndex, igp.gir_uPos
	]]
}
DefineSql( StmtDef , StmtOperater )
function CPutItemsToBagBox.InitBagItem(nCharID)
	local res = StmtOperater._SelectAllItemInfoByCharID:ExecStat(nCharID)
	local function RetRes(resi,nBigID,sName,nIndex,nPos,nBind,nGridID)
		resi.m_nBigID = nBigID
		resi.m_sName = sName
		resi.m_nIdex = nIndex
		resi.m_nPos = nPos
		resi.m_nBind = nBind
		resi.m_nGridID = nGridID
		return resi
	end
	local tbl_res,tbl_resi = {},{}	
	local row = res:GetRowNum()
	for i = 1,row do
		if i ==1 then
			table.insert(tbl_resi,res(1,1))
			if row == 1 then
				tbl_resi = RetRes(tbl_resi,res(1,4),res(1,5),res(1,2),res(1,3),res(1,6),res(1,7))
				tbl_res[res(1,2)] = tbl_res[res(1,2)] or {}
				table.insert(tbl_res[res(1,2)],tbl_resi)
				break
			end
		else
			if res(i-1,2) == res(i,2) and res(i-1,3) == res(i,3) then
				table.insert(tbl_resi,res(i,1))
			else
				tbl_resi = RetRes(tbl_resi,res(i-1,4),res(i-1,5),res(i-1,2),res(i-1,3),res(i-1,6),res(i-1,7))
				tbl_res[res(i-1,2)] = tbl_res[res(i-1,2)] or {}
				table.insert(tbl_res[res(i-1,2)],tbl_resi)
				tbl_resi = {}
				table.insert(tbl_resi,res(i,1))
			end
			if i == row then
				--�����һ����Ʒ
				tbl_resi = RetRes(tbl_resi,res(i,4),res(i,5),res(i,2),res(i,3),res(i,6),res(i,7))
				tbl_res[res(i,2)] = tbl_res[res(i,2)] or {}
				table.insert(tbl_res[res(i,2)],tbl_resi)
			end
		end
	end
	local equip_info = CPutItemsToBagBox.GetAllEquipBaseInfoByCharID( nCharID )
	local bf_book = CPutItemsToBagBox.SelectBattleBookByID(nCharID)
	local mail_item = CPutItemsToBagBox.GetMailTextAttachmentByID(nCharID)
	local spearl_info = CPutItemsToBagBox.GetSoulPearlInfoByChar(nCharID)
	local oremap_info = CPutItemsToBagBox.GetOreMapInfoByChar(nCharID)
	local ItemMakerMgrDB = RequireDbBox("ItemMakerMgrDB")
	local item_maker = ItemMakerMgrDB.GetItemMakerByChar(nCharID)
	local ItemLifeMgrDB = RequireDbBox("ItemLifeMgrDB")
	local item_life = ItemLifeMgrDB.GetItemLeftTimeByChar(nCharID)
	local pickore_info = CPutItemsToBagBox.GetPickOreInfoByChar(nCharID)
	local ExpAndSoulBottleInfo = CPutItemsToBagBox.GetExpAndSoulBottleInfo(nCharID)
	local opendBoxitemInfo = CPutItemsToBagBox.GetBoxitemOpenedFlag(nCharID)
	local BreakItemDB = RequireDbBox("BreakItemDB")
	local BreakExp = BreakItemDB.GetBreakExpByChar(nCharID) or 0
	return {["item_life"] = item_life,["item_maker"] = item_maker,["ItemBaseInfo"] = tbl_res,["equip_info"] = equip_info,["bf_book"] = bf_book,
					["mail_item"] = mail_item,["BreakExp"] = BreakExp,["spearl_info"] = spearl_info,["oremap_info"] = oremap_info,
					["pickore_info"] = pickore_info, ["opendBoxitemInfo"] = opendBoxitemInfo,["ExpAndSoulBottleInfo"] = ExpAndSoulBottleInfo}
end

return CPutItemsToBagBox
