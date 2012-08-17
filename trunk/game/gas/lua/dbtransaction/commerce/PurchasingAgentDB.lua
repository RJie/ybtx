cfg_load "commerce/PurchasingAgent_Common"
cfg_load "item/Equip_Armor_Common"
cfg_load "item/Equip_Weapon_Common"
cfg_load "item/Equip_Jewelry_Common"
cfg_load "item/Equip_Shield_Common"
cfg_load "item/Stone_Common"
cfg_load "item/SkillItem_Common"
cfg_load "item/BasicItem_Common"
cfg_load "item/Equip_Ring_Common"
gac_gas_require "framework/common/CMoney"
gac_gas_require "commerce/consignment/Consignment"


local g_MoneyMgr = CMoney:new()
local g_ItemInfoMgr			=	CItemInfoMgr:new()
local event_type_tbl = event_type_tbl
local CMarket				=	{}
local PurchasingAgent_Common = PurchasingAgent_Common
local Equip_Armor_Common = Equip_Armor_Common
local Equip_Weapon_Common = Equip_Weapon_Common
local Equip_Jewelry_Common = Equip_Jewelry_Common
local Equip_Shield_Common = Equip_Shield_Common
local Stone_Common = Stone_Common
local SkillItem_Common = SkillItem_Common
local BasicItem_Common = BasicItem_Common
local Equip_Ring_Common= Equip_Ring_Common
local AttrNameMapIndexTbl = CConsignment.AttrNameMapIndexTbl
local PurchasingAgentDB			=	CreateDbBox(...)

local RememberPriceState = true

--����չ�����
local StmtDef = 
{
	"_AddOrderStatic",
	"insert into tbl_market_order_static(mos_tCreateTime) values ( now() )"
}
DefineSql(StmtDef, CMarket)

--------------------------------------------����չ�����----------------------------------
local StmtDef = 
{
	"_AddBuyOrder",
	[[
	insert into tbl_market_buy_order (mos_uId, cs_uId, mbo_sItemName, mbo_uCount, mbo_uPrice, mbo_tEndTime) values (?, ?, ?, ?, ?, DATE_ADD(now(), INTERVAL ? hour))
	]]
}
DefineSql(StmtDef, CMarket)


function PurchasingAgentDB.CSMAddBuyOrder(data)
	local uCharId				=	data["CharID"]
	local uCount				=	data["ItemCount"]
	local uPrice				=	data["ItemPrice"]
	local uTime					=	data["Time"]
	local sItemName					= data["ItemName"]
	local needFee               =   data["NeedFee"]
	
	local uAveragePrice = PurchasingAgentDB:CSMGetAveragePriceByItemName({sItemName})
	
	if uAveragePrice > 0 and (uPrice < uAveragePrice/10 or  uPrice >  uAveragePrice*2) then 
		return false, 8311
	end
		
	if not RememberPriceState then
		local buy_price_ret = CMarket.GetCSMBuyPriceByTypeName:ExecSql("n", uCharId, sItemType, sItemName)
		if buy_price_ret:GetRowNum() == 0 then
			CMarket.SetRememberBuyPrice:ExecSql("", uCharId, sItemType, sItemName, uPrice)
		else
			if buy_price_ret:GetData(0,0) ~= uPrice then
				CMarket.UpdateRememberBuyPrice:ExecSql("", uPrice, uCharId, sItemType, sItemName)
			end
		end
		if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
			CancelTran()
			--, "���¼�ס�۸����"
			return false, 8016
		end
		buy_price_ret:Release()
	end
	CMarket._AddOrderStatic:ExecSql("")
	local order_id = g_DbChannelMgr:LastInsertId()

	CMarket._AddBuyOrder:ExecSql("", order_id, uCharId, sItemName, uCount, uPrice, uTime)

	if g_DbChannelMgr:LastAffectedRowNum() <=0 then
		CancelTran()
		--, "�����ʧ�ܣ�"
		return false, 8017
	end
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local uEventId = g_LogMgr.LogConsignmentAddBuyOrder( uCharId,order_id,sItemName,uCount,uPrice)
	--�ɷ�
	local MoneyManagerDB =	RequireDbBox("MoneyMgrDB")
	local account = uCount * uPrice
	local fun_info = g_MoneyMgr:GetFuncInfo("PurchasingAgent")
	local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["AddBuyOrder"],uCharId, -needFee,event_type_tbl["�չ����������"])
	if not bFlag then
		CancelTran()
		--, "�������ѳ���" 
		if IsNumber(uMsgID) then
			return false,uMsgID
		else
			return false, 8023
		end
	end

	local bFlag1,uMsgID1 = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["AddBuyOrder"],uCharId, -account,uEventId,nil,uCharId)
	if not bFlag1 then
		CancelTran()
		--, "�������ѳ���" 
		if IsNumber(uMsgID1) then
			return false,uMsgID1
		else
			return false, 8023
		end
	end
	return true, order_id
end

---------------------------------------------ȡ���չ�����---------------------------------
--��ȡĳ���չ�����
local StmtDef = 
{
	"_GetBuyOrder",
	[[
	select mbo.cs_uId, mbo.mbo_sItemName, mbo.mbo_uCount, mbo.mbo_uPrice, unix_timestamp(mbo.mbo_tEndTime)
	from tbl_market_buy_order mbo
	where mbo.mos_uId = ? and (unix_timestamp(mbo.mbo_tEndTime) - unix_timestamp(now())) > 0 
	]]
}
DefineSql(StmtDef, CMarket)
function PurchasingAgentDB.GetBuyOrderInfo(uOrderId)
	assert(IsNumber(uOrderId))
	local ret = CMarket._GetBuyOrder:ExecSql("ns[32]nnn", uOrderId)
	if ret:GetRowNum() == 0 then
		ret:Release()
		return nil
	end
	local buyOrder  = {}
	for i =1, ret:GetColNum() do
		buyOrder[i] = ret:GetData( 0 ,i-1 )
	end
	ret:Release()
	return buyOrder
end

--ȡ���չ�����
local StmtDef = 
{
	"_CancelBuyOrder",
	[[
	delete from tbl_market_buy_order
	where mos_uId = ?
	]]
}
DefineSql(StmtDef, CMarket)
--ȡ���չ�����
function PurchasingAgentDB.CSMCancelBuyOrder(data)
	local uCharId			=	data["CharID"]
	local uOrderId			=	data["OrderID"]
	assert(IsNumber(uCharId))
	assert(IsNumber(uOrderId))
	
	local info = PurchasingAgentDB.GetBuyOrderInfo(uOrderId)
	if info == nil or info[1] ~= uCharId then
		--, "��������"
		return false, 8008
	end
	
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local uEventId = g_LogMgr.LogConsignmentCancelBuyOrder( uCharId,uOrderId,event_type_tbl["�ֶ�ɾ���չ�����"])
	
	local MoneyManagerDB=	RequireDbBox("MoneyMgrDB")
	local fun_info = g_MoneyMgr:GetFuncInfo("PurchasingAgent")
	local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["CancelBuyOrder"],uCharId, info[3] * info[4],uEventId)
	if not bFlag then
		CancelTran()
		--, "�������ѳ���" 
		if IsNumber(uMsgID) then
			return false,uMsgID
		else
			return false, 8009
		end
	end
	
	CMarket._CancelBuyOrder:ExecSql("", uOrderId) 
	if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
		CancelTran()
		--, "ȡ������ʧ�ܣ�"
		return false, 8010
	end
	
	return true
end

-----------------------------------------��ѯ����-----------------------------------------
--һ������ӳ�����������͵ı�
local MapCfgType ={}
MapCfgType[1] = {2,24,25,27,28,30,32,37,40}			--{}�������Ʒtype
MapCfgType[2] = {8, 9}			--StaticJewelry_Common\StaticRing_Common
MapCfgType[3] = {14, 15}   --Stone_Common\HoleMaterial_Common
MapCfgType[4] = {46}				--����Ʒ��SkillItem_Common��BasicItem_Common
MapCfgType[5] = {34, 38, 43, 50,49}	--װ��ǿ����أ�AdvanceStone_Common��ArmorPieceEnactment_Common				
MapCfgType[6] = {10,17,18,19,23,26,29,31,36,39} --�����������б�����ʾ����Ʒ���������
MapCfgType[7] = {1} --basicItem
MapCfgType[8] = {6,7}--���ߺͶ���
MapCfgType[9] = {27,28}--���졢��������Ʒ

--��������������
local AttrIndexMapTbl = {}
AttrIndexMapTbl[1] = {27} -- ǿ��ʯ������ʯ
AttrIndexMapTbl[2] = {29, 30, 31} --ҩ����ʳƷ��ħ����Ʒ
AttrIndexMapTbl[3] = {32, 33, 34} --�����ҩ���ϡ���ͨ��Ʒ������

local SearchType = {}
SearchType["ByOneItemType"] = 1     --��ѯĳһ����Ʒ
SearchType["BySomeItemType"] = 2    --��ѯĳ������Ʒ
SearchType["ByItemTypeAndAttr"] = 3 --����ĳ����Ʒ��ĳ�������в�ѯ
SearchType["ByItemTypeOrAttr"] = 4  --����ĳ������Ʒ����ĳ����Ʒ��ĳ��������

--��ѯ�չ�����
function PurchasingAgentDB.SearchCommonBuyOrder(uSearchType,uParentArg,uChildArg,sName, uBeginLevel, uEndLevel,uQuality, uOrderBy, Page)
	local query_sql = "select "
	local ret_sql = " mbo.mos_uId, mbo.mbo_sItemName, mbo.mbo_uPrice, mbo.mbo_uCount, ((unix_timestamp(mbo.mbo_tEndTime) - unix_timestamp(now()))/3600), cfg.mpci_uCanUseLevel,c.c_sName "
	local query_from_sql = "from tbl_char c, tbl_market_order_static mos, tbl_market_buy_order mbo, tbl_market_purchasing_cfg_info cfg "
  local where_sql = " where " 
  local ret_constraint_sql = "mbo.mbo_sItemName = cfg.mpci_sName and unix_timestamp(mbo.mbo_tEndTime) >0 and  mbo.mos_uId = mos.mos_uId and mbo.mbo_uCount > 0 and mbo.cs_uId = c.cs_uId and (unix_timestamp(mbo.mbo_tEndTime) - unix_timestamp(now())) > 0 "
  local ret_group_sql = " group by mbo.mos_uId"
  local ret_order_sql = " order by mbo.mbo_uPrice desc"
  local ret_limit_sql = " "
  	--�ȼ�����
	if (uBeginLevel ~= nil and uBeginLevel ~= 0) then
		ret_constraint_sql = ret_constraint_sql .." and cfg.mpci_uCanUseLevel >= " .. uBeginLevel
	end

	--�ȼ�����
	if (uEndLevel ~= nil and uEndLevel ~= 0) then
		ret_constraint_sql = ret_constraint_sql .." and cfg.mpci_uCanUseLevel <= " .. uEndLevel
	end
	
	if uQuality > -1 then
	    ret_constraint_sql= ret_constraint_sql .. " and cfg.mpci_uQuality = " .. uQuality
	end
	
	
	if SearchType["ByOneItemType"]  == uSearchType then
		ret_constraint_sql = ret_constraint_sql .. " and  cfg.mpci_uType = " .. uParentArg .." "
	
	elseif SearchType["BySomeItemType"] == uSearchType then
    local cfgTypeMapTbl = MapCfgType[uParentArg]
		if #cfgTypeMapTbl > 0 then
			ret_constraint_sql = ret_constraint_sql .. " and cfg.mpci_uType in (" .. table.concat(cfgTypeMapTbl, ',') .. ") "
		end
	
	elseif SearchType["ByItemTypeAndAttr"] == uSearchType then
	  ret_constraint_sql = ret_constraint_sql .. "  and cfg.mpci_uType = " .. uParentArg .. " and cfg.mpci_uChildType = " ..  uChildArg

	elseif SearchType["ByItemTypeOrAttr"] == uSearchType then
    local cfgTypeMapTbl = MapCfgType[uParentArg]
    local addMark = ""
	  if #cfgTypeMapTbl > 0 then
		  ret_constraint_sql = ret_constraint_sql .. " and ( cfg.mpci_uType  in (" .. table.concat(cfgTypeMapTbl, ',') .. ") or "
			addMark = " ) "
		else 
			ret_constraint_sql = ret_constraint_sql.." and "
		end
		
		ret_constraint_sql = ret_constraint_sql .. " cfg.mpci_uChildType in (" .. table.concat(AttrIndexMapTbl[uChildArg], ',') ..") "..addMark
	end
	
	if sName ~= nil and sName~="" then
		ret_constraint_sql = ret_constraint_sql .. " and cfg.mpci_sItemDisplayName  like '" .. "\%"..sName .."\%".. "' "
	end
    
	if (uOrderBy == 1) then
		ret_order_sql = " order by mbo.mbo_sItemName "
	elseif (uOrderBy == 2) then
		ret_order_sql = " order by cfg.mpci_uCanUseLevel desc "
	elseif (uOrderBy == 3) then
		ret_order_sql = " order by mbo.mbo_uCount desc "
	elseif (uOrderBy == 4) then
		ret_order_sql = " order by mbo.mbo_uPrice desc "
	elseif (uOrderBy == 6) then
		ret_order_sql = " order by mbo.mbo_tEndTime "
	elseif (uOrderBy == 7) then
		ret_order_sql = " order by c.c_sName "
	end
	
	if Page ~= nil and  Page ~= 0 then
	    local page = Page or 1
	    local begin_record = page * 50 - 50
	    ret_limit_sql = " limit " .. begin_record .. " , 50 "
	end
	
	local countsqlstr = query_sql.."count(*) "..query_from_sql..where_sql..ret_constraint_sql
	local temp2, query_count = g_DbChannelMgr:TextExecute(countsqlstr)
	
	if query_count == nil then
		return 0, {}
	end
	
	if query_count:GetRowNum() == 0 then
		query_count:Release()
		return 0, {}
	end
	
	local count=query_count:GetData( 0 ,0 )

	local retsqlstr = query_sql..ret_sql..query_from_sql..where_sql..ret_constraint_sql..ret_group_sql..ret_order_sql..ret_limit_sql
	local temp, query_result
	temp, query_result = g_DbChannelMgr:TextExecute(retsqlstr)
	
	if query_count == nil then
		return 0, {}
	end
	if query_result:GetRowNum() == 0 then
		query_result:Release()
		return 0, {}
	end
	local buyOrderRet  = {}
	for i =1, query_result:GetRowNum() do
		local buyOrder  = {}
		buyOrder["OrderId"] = query_result:GetData( i-1 ,0 )
		buyOrder["ItemName"] = query_result:GetData( i-1 ,1 )
		buyOrder["Price"] = query_result:GetData( i-1 ,2 )
		buyOrder["Count"] = query_result:GetData( i-1 ,3 )
		buyOrder["Time"] = query_result:GetData( i-1 ,4 )
		buyOrder["Level"]=query_result:GetData( i-1 ,5 )
		buyOrder["CharName"] = query_result:GetData( i-1 ,6 )
		table.insert(buyOrderRet, buyOrder)
	end
	query_result:Release()

	return count, buyOrderRet
end

--��ѯ�չ�����
function PurchasingAgentDB.CSMSearchBuyOrder(data)
	local uSearchType = data["SearchType"] 
	local	uParentArg	= data["ParentArg"]
	local	uChildArg		= data["ChildArg"]
	local sName				=	data["Name"]
	local uBeginLevel		=	data["BeginLevel"]
	local uEndLevel			=	data["EndLevel"]
	local uQuality = data["Quality"]
	local OrderBy			=	data["OrderBy"]
	local Page				=	data["Page"]
	
	local count, ret= PurchasingAgentDB.SearchCommonBuyOrder(uSearchType,uParentArg,uChildArg, sName, uBeginLevel, uEndLevel, uQuality, OrderBy, Page)
	local result = {["Count"]=count , ["Ret"]=ret}
	
	return true, result
end

local StmtDef = 
{
	"_SearchUserBuyOrder",
	[[
	select mbo.mos_uId, mbo.mbo_sItemName, mbo.mbo_uPrice, mbo.mbo_uCount, ((unix_timestamp(mbo.mbo_tEndTime) - unix_timestamp(now()))/3600)
	from tbl_market_buy_order mbo
	where unix_timestamp(mbo.mbo_tEndTime) >0 and mbo.cs_uId = ? and (unix_timestamp(mbo.mbo_tEndTime) - unix_timestamp(now())) > 0
	]]
}
DefineSql(StmtDef, CMarket)

--��ɫ��ѯ�����չ��б�
function PurchasingAgentDB.SearchUserBuyOrder(uCharId)
	assert(IsNumber(uCharId))
	local ret = CMarket._SearchUserBuyOrder:ExecSql('ns[32]nnn',uCharId)
	if ret == nil then
		return nil
	end
	if ret:GetRowNum() == 0 then
		ret:Release()
		return nil
	end
	local buyOrderRet  = {}
	for i =1, ret:GetRowNum() do
		local buyOrder  = {}
		buyOrder["OrderId"] = ret:GetData( i-1 ,0 )
		buyOrder["ItemName"] = ret:GetData( i-1 ,1 )
		buyOrder["Price"] = ret:GetData( i-1 ,2 )
		buyOrder["Count"] = ret:GetData( i-1 ,3 )
		buyOrder["Time"] = ret:GetData( i-1 ,4 )
		table.insert(buyOrderRet, buyOrder)
	end
	ret:Release()
	return buyOrderRet
end

function PurchasingAgentDB.CSMSearchCharBuyOrder(data)
	local uCharId	=	data["CharId"]
	local result = PurchasingAgentDB.SearchUserBuyOrder(uCharId)
	return true, result
end

local StmtDef =
{
	"_UpdateBuyOrderCount",
	[[
	update tbl_market_buy_order 
	set mbo_uCount = mbo_uCount - ?
	where mos_uId = ? and mbo_uCount >= ?
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef =
{
	"_SelectMarketCounts",
	[[
	select mbo_uCount from tbl_market_buy_order where mos_uId=? 
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef = 
{	
	"_AddItemToOrder",
	[[
	insert into tbl_item_market (is_uId, mos_uId) values (?, ?)
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef = 
{
	"_GetItemPos",
	[[
	select gir_uRoomIndex, gir_uPos
	from tbl_item_in_grid as iip,tbl_grid_in_room as igp
	where iip.gir_uGridID = igp.gir_uGridID and iip.is_uId = ?
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef =
{
	"_SelectorderItems",
	[[
	select is_uId from tbl_item_market where mos_uId=? 
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef = 
{
	"_DeleteOrderItem",
	[[
	delete
	from tbl_item_market
	where mos_uId = ?
	]]
}
DefineSql(StmtDef, CMarket)

function PurchasingAgentDB.CSMSellGoods2Order(data)
	local uCharId	=	data["CharID"]
	local uOrderId	=	data["OrderID"]
	local nRoomIndex	=	data["RoomIndex"]
	local nPos	=	data["Pos"]
	assert(IsNumber(uOrderId))
	
	local info = PurchasingAgentDB.GetBuyOrderInfo(uOrderId)
	if info == nil then
		--,'�ö����Ѿ������ڣ�'
		return false, 8310
	end

	if info[1] == uCharId then
		--, '���ܳ����Լ����չ�Ʒ��'
		return  false, 8026
	end
	
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")	
	local sItemType, sItemName, uCount = g_RoomMgr.GetTypeCountByPosition(uCharId, nRoomIndex, nPos)
	if sItemType == nil or sItemName == nil or sItemName ~= info[2] then
		--, "�Ƿ�������"
		return false, 8012
	end
	
	if uCount == 0 then
		--, '��û�и���Ʒ���Գ��ۣ�'
		return false, 8027
	end
	if g_ItemInfoMgr:IsSoulPearl(sItemType) then
		--������Ʒ�Ļ�ֵ��һ�������ܳ���
		if g_RoomMgr.CountSoulNumByPos(uCharId, nRoomIndex, nPos) > 1 then
			return false,6123
		end
	end
	local tbl_item_id = g_RoomMgr.GetAllItemFromPosition(uCharId, nRoomIndex, nPos)
	
	local itemBindingType = g_RoomMgr.GetItemBindingTypeByID(tbl_item_id(1,1))	
	if itemBindingType == 2  or 3 == itemBindingType then --��Ʒ������Ϊ����
		--, "���ܳ��۰���Ʒ��"
		return false, 8015
	end
	
	local BoxitemDB = RequireDbBox("BoxitemDB")
	local openedFlag = BoxitemDB.IsBoxitemOpened(tbl_item_id, uCharId)

	if openedFlag then 
		--,"���ܳ��۴򿪵ĺ�����Ʒ"
		return false, 8312
	end	
	
	if uCount > info[3] then
		uCount = info[3]
	end
	local uNeedCount = info[3]
	
	
	CMarket._UpdateBuyOrderCount:ExecSql("", uCount, uOrderId, uCount)
	if g_DbChannelMgr:LastAffectedRowNum() <=0 then
		CancelTran()
		return false
	end
	
	local ItemData = {}

	for i = 1, uCount do
		--����һ�ű��������
		local nItemID =  tbl_item_id(i,1)
		CMarket._AddItemToOrder:ExecSql("",nItemID, uOrderId)
		if g_DbChannelMgr:LastAffectedRowNum() <=0   then
			CancelTran()
			--, '��Ӷ������ɹ���'
			return false, 8029
		end
		local pos = CMarket._GetItemPos:ExecSql('nn',nItemID)
		if pos == nil then
			return false,8030
		end
		if pos:GetRowNum() == 0 then
			pos:Release()
			CancelTran()
			--, '��Ʒλ�ô���'
			return false, 8030
		end
		
		if not g_RoomMgr.MoveItemFromPackage(uCharId, nItemID) then
			CancelTran()
			--, 'ɾ����Ʒ����'
			return false, 8019
		end
		table.insert( ItemData, nItemID )
		pos:Release()
	end
	--�����չ�����дlog
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local uEventId = g_LogMgr.LogConsignmentSellBuyOrderItem( uCharId,ItemData,uOrderId)
	
	--�������߷��ͽ�Ǯ
	local moneySellerGot = g_MoneyMgr:GetAftertaxMoney(uCount * info[4]) 
	local sysFee = uCount * info[4] - moneySellerGot
	local lSysMailExecutor = RequireDbBox("SysMailDB")
	local succ2=lSysMailExecutor.SendSysMail(1001,uCharId,1002,
	"1005_item:" .. sItemType .. "|" .. sItemName,nil,moneySellerGot,event_type_tbl["�����չ�����"],5002)
	if not succ2 then
		CancelTran()
		--, '���ͽ�Ǯ���ɹ���'
		return  false, 8031
	end
	local MoneyManagerDB =	RequireDbBox("MoneyMgrDB")
	local fun_info = g_MoneyMgr:GetFuncInfo("PurchasingAgent")
	if not MoneyManagerDB.UpdateRmbMoney(info[1],-(uCount * info[4]),fun_info["FunName"],event_type_tbl["�����չ�����"],uEventId,uCharId,moneySellerGot) then
		return
	end
	
	g_LogMgr.SaveTaxLog(sysFee, uCharId, event_type_tbl["���۽�������˰"])
	local order_item_ids = CMarket._SelectorderItems:ExecSql('n',uOrderId)
	if order_item_ids:GetRowNum() ~= 0 then
		local order_item_ids_tbl = order_item_ids:ToTable(true)
		local succ=lSysMailExecutor.SendSysMail(1001,info[1] ,1002,
		"1006_item:" .. sItemType .. "|" .. sItemName,order_item_ids_tbl,0,event_type_tbl["�չ������ɹ��ʼ�"],5003)
		if not succ then
			query_Count:Release()
			CancelTran()
			--, '������Ʒʧ�ܣ�'
			return  false, 8031
		end
		CMarket._DeleteOrderItem:ExecSql('',uOrderId)
		if g_DbChannelMgr:LastAffectedRowNum() <=0 then
			query_Count:Release()
			CancelTran()
			--, 'ɾ����Ʒʧ�ܣ�'
			return false, 8031
		end
	end
	--�չ������ѹ������͵��չ�������
	local query_Count = CMarket._SelectMarketCounts:ExecSql('n',uOrderId)
	
	if query_Count == nil then
		return false
	end
	if query_Count:GetRowNum() == 0 then
		query_Count:Release()
		return false
	end

	if query_Count:GetData(0,0)<=0 then 
		CMarket._CancelBuyOrder:ExecSql("", uOrderId)
		if g_DbChannelMgr:LastAffectedRowNum() <=0 then
			query_Count:Release()
			CancelTran()
			--, 'ȡ������ʧ�ܣ�'
			return false, 8031
		end
		local g_LogMgr = RequireDbBox("LogMgrDB")
		g_LogMgr.LogConsignmentCancelBuyOrder( info[1],uOrderId,event_type_tbl["�չ��������ɾ��"])
	end
	
	query_Count:Release()
	
	return true
end

local StmtDef=
{
	"_SelectFastSearchBuyOrderItemByCharID",
	[[
	select
			mbo.mbo_sItemName, igp.gir_uRoomIndex, igp.gir_uPos,ifnull(binding.isb_bIsbind,0)
	from 
			tbl_market_buy_order as mbo,tbl_grid_in_room as igp,tbl_item_in_grid as isr
			left join tbl_item_static as item
			on isr.is_uId = item.is_uId 
			left join tbl_item_is_binding as binding
			on item.is_uId = binding.is_uId 
	where igp.gir_uGridID = isr.gir_uGridID and igp.cs_uId = ? and item.is_sName = mbo.mbo_sItemName and mbo.cs_uId <> igp.cs_uId and unix_timestamp(mbo.mbo_tEndTime) >0 and mbo.mbo_uCount > 0 and (unix_timestamp(mbo.mbo_tEndTime) - unix_timestamp(now())) > 0
	group by mbo.mos_uId
	]]
}
DefineSql( StmtDef , CMarket )


function PurchasingAgentDB.CSMFastSearchBuyOrderItem(data)
	local uCharId	=	data["CharID"]
	local query_result = CMarket._SelectFastSearchBuyOrderItemByCharID:ExecSql("s[32]nn", uCharId)
	
	if query_result == nil then
		return false,{}
	end
	if query_result:GetRowNum() == 0 then
		query_result:Release()
		return	false,{}
	end
	local ItemInfoRet  = {}
	for i =1, query_result:GetRowNum() do
		local	 uBindingType = query_result:GetData( i-1 ,3)
		if uBindingType ~=2 and uBindingType ~=3 then
			local ItemInfo  = {}
			ItemInfo["RoomIndex"] = query_result:GetData( i-1 ,1 )
			ItemInfo["Pos"] = query_result:GetData( i-1 ,2 )
			ItemInfo["ItemName"] = query_result:GetData( i-1 ,0 )
			table.insert(ItemInfoRet, ItemInfo)
		end
	end
	query_result:Release()
	return true, ItemInfoRet
end

local StmtDef=
{
	"_SelectTopPriceBuyOrderByItemName",
	[[
	select mos_uId, mbo_uPrice, mbo_uCount
	from tbl_market_buy_order
	where mbo_sItemName = ? and cs_uId <> ? and unix_timestamp(mbo_tEndTime) > 0 and mbo_uCount > 0 and (unix_timestamp(mbo_tEndTime) - unix_timestamp(now())) > 0
	order by mbo_uPrice desc
	limit 0,1
	]]
}
DefineSql( StmtDef , CMarket )

function PurchasingAgentDB.CSMGetTopPriceBuyOrderByItemName(data)
	local uCharId	=	data["CharID"]
	local sItemName	=	data["ItemName"]
	local query_result = CMarket._SelectTopPriceBuyOrderByItemName:ExecSql("nnn", sItemName,uCharId)
	
	if query_result == nil then
		return false,8310
	end
	if query_result:GetRowNum() == 0 then
		query_result:Release()
		return	false,8310
	end
	local buyOrder  = {}
	for i =1, query_result:GetRowNum() do
		buyOrder["Price"] = query_result:GetData( i-1 ,1 )
		buyOrder["Count"] = query_result:GetData( i-1 ,2 )
		buyOrder["OrderId"] = query_result:GetData( i-1 ,0 )
	end
	query_result:Release()
	return true, buyOrder
end

local StmtDef=
{
	"_SelectBuyOrderAveragePriceByItemName",
	[[
	select mbo_uPrice
	from tbl_market_buy_order
	where mbo_sItemName = ? and unix_timestamp(mbo_tEndTime) > 0 and mbo_uCount > 0 and (unix_timestamp(mbo_tEndTime) - unix_timestamp(now())) > 0
	]]
}
DefineSql( StmtDef , CMarket )

local StmtDef=
{
	"_SelectSellOrderAveragePriceByItemName",
	[[
	select mso_uPrice/mso_uCount
	from tbl_market_sell_order
	where mso_sItemName = ? and unix_timestamp(mso_tEndTime) > 0 and mso_uCount > 0 and (unix_timestamp(mso_tEndTime) - unix_timestamp(now())) > 0
	]]
}
DefineSql( StmtDef , CMarket )

function PurchasingAgentDB.CSMGetAveragePriceByItemName(data)
	return 0,0 --��ʱ����ƽ���۹���
	--[[
	local sItemName	=	data["ItemName"]
	local query_result = CMarket._SelectSellOrderAveragePriceByItemName:ExecSql("n", sItemName)
	
	if query_result == nil or  query_result:GetRowNum() < 5 then
		query_result = CMarket._SelectBuyOrderAveragePriceByItemName:ExecSql("n", sItemName)
	end

	if query_result == nil then
		return 0,0
	end
	if query_result:GetRowNum() <5  then
		query_result:Release()
		return	0,0
	end
	local uPrice  = 0
	local uCount = query_result:GetRowNum()  
	for i =1, query_result:GetRowNum() do
		uPrice = uPrice+query_result:GetData( i-1 ,0 )
	end
	query_result:Release()
	return uPrice/uCount,uCount
	--]]
end

--�ж��չ�ʣ��ʱ���Ƿ�<=0
--<=0������չ�����Ʒ��ʣ��moneyһ���͵��չ�������
--��������ʼ���к���ˢ�´˷�
local StmtDef = 
{
	"_SelectBuyOrderItem",
	[[
	select is_uId 
	from tbl_item_market
	where mos_uId = ?
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef = 
{
	"_SelectAllOrder",
	[[
	select mbo.mos_uId,mbo.cs_uId,mbo.mbo_uCount,mbo.mbo_uPrice
	from tbl_market_buy_order as mbo
	where mbo.mbo_tEndTime+60 <= now() 
	]]
}
DefineSql(StmtDef, CMarket)
function  PurchasingAgentDB.OrderIsOrNotOuttime()
	local all_orders = CMarket._SelectAllOrder:ExecSql('nnns[32]nn')
	if all_orders:GetRowNum() == nil then
		return	false
	end
	if all_orders:GetRowNum() == 0 then
		all_orders:Release()
		return	false
	end
	local lSysMailExecutor = RequireDbBox("SysMailDB")
	for i=1, all_orders:GetRowNum() do
		local order_id = all_orders:GetData(i-1,0)
		local char_id = all_orders:GetData(i-1,1)
		local succ2=lSysMailExecutor.SendSysMail(1001,char_id,1002,1004 ,nil,all_orders:GetData(i-1,2) *all_orders:GetData(i-1,3),event_type_tbl["�չ�������ʱ�ʼ�"],5005)
		if not succ2 then
			LogErr("����ɾ����ʱ�������ʼĳ���", "OrderID:" .. order_id)
			CancelTran()
			return  false
		end

		CMarket._CancelBuyOrder:ExecSql("", order_id) 
		if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
			all_orders:Release()
			CancelTran()
			return false
		end
		local g_LogMgr = RequireDbBox("LogMgrDB")
		g_LogMgr.LogConsignmentCancelBuyOrder( char_id,order_id,event_type_tbl["�չ�������ʱɾ��"])
	end
	
	all_orders:Release()
	return true
end

local StmtDef = 
{
	"_AddCfgInfo",
	[[
	insert into tbl_market_purchasing_cfg_info (mpci_sName, mpci_uType, mpci_uChildType,mpci_sItemDisplayName, mpci_uCanUseLevel, mpci_uQuality) values (?, ?, ?, ?, ?,?)
	]]
}
DefineSql(StmtDef, CMarket)

local StmtDef = 
{
	"_deleteCfgInfo",
	[[
	    delete from tbl_market_purchasing_cfg_info
	]]
}
DefineSql(StmtDef, CMarket)


function PurchasingAgentDB.ReadCfgToCSMDBTable()
    CMarket._deleteCfgInfo:ExecStat()
    local CfgInfo = {}
	CfgInfo[5] = {Equip_Weapon_Common, "EquipType"}
    CfgInfo[6] = {Equip_Armor_Common,  "EquipPart"}
    CfgInfo[7]	= {Equip_Shield_Common, "EquipType"}
    CfgInfo[8] = {Equip_Ring_Common, "EquipType"}
    CfgInfo[9] = {Equip_Jewelry_Common,"EquipPart"}
    CfgInfo[g_ItemInfoMgr:GetStoneBigID()] =  {Stone_Common, "StoneType"}
    CfgInfo[g_ItemInfoMgr:GetSkillItemBigID()] = {SkillItem_Common, "ItemType"}
    CfgInfo[g_ItemInfoMgr:GetBasicItemBigID()] = {BasicItem_Common, "CSMSortType"}
	local keys = PurchasingAgent_Common:GetKeys()
	for i,v in pairs( keys ) do
		local ChildType
		local ItemName = PurchasingAgent_Common(v,"ItemName")
		local ItemBigID = PurchasingAgent_Common(v,"BigID")
		local itemDisplayName = g_ItemInfoMgr:GetItemLanInfo(ItemBigID, ItemName,"DisplayName")
		local	cfgitem =	CfgInfo[ItemBigID]
		if cfgitem then 
			local cfg = cfgitem[1]
     		local cfgItemTypeStr = cfgitem[2]
      		local type =cfg(ItemName,cfgItemTypeStr)
			ChildType = AttrNameMapIndexTbl[type]
		end
		local itemInfo =  g_ItemInfoMgr:GetItemInfo( ItemBigID, ItemName)
	  	local uLevel = 0
    	local	quality = 0
		if itemInfo then 
			uLevel = itemInfo("BaseLevel")
    		quality = itemInfo("Quality" )
    	end
		CMarket._AddCfgInfo:ExecSql("", ItemName, ItemBigID, ChildType,itemDisplayName ,uLevel, quality)
	end
end

SetDbLocalFuncType(PurchasingAgentDB.CSMSearchCharBuyOrder)
SetDbLocalFuncType(PurchasingAgentDB.CSMSearchBuyOrder)
SetDbLocalFuncType(PurchasingAgentDB.CSMFastSearchBuyOrderItem)
SetDbLocalFuncType(PurchasingAgentDB.CSMGetAveragePriceByItemName)
SetDbLocalFuncType(PurchasingAgentDB.CSMGetTopPriceBuyOrderByItemName)
SetDbLocalFuncType(PurchasingAgentDB.ReadCfgToCSMDBTable)

return PurchasingAgentDB
