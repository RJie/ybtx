gac_gas_require "relation/tong/TongMgr"
gac_gas_require "relation/tong/TongMantleMgr"
gac_gas_require "relation/tong/TongProdItemMgr"
local BuildingItemMgr  = CTongProdItemInfoMgr:new()
local g_MantleMgr = CTongMantleInfoMgr:new()
local g_ItemInfoMgr = CItemInfoMgr:new()
local g_TongMgr = CTongMgr:new()
local StmtOperater = {}	
local event_type_tbl =  event_type_tbl
local ItemState = 
    {
     ["������"] 	= 1,
     ["�ȴ�����"] = 2,
    }
local CTongCreateBox = CreateDbBox(...)
--------------------------------------------------------------------------------
local StmtDef = {
    	"_DelCountBuildingItem",   
    	[[ 
    		delete 
    			from tbl_building_tong where bt_sBuildName = ?
    		and 
    			t_uId = (select t_uId from tbl_member_tong where cs_uId = ?)
    		limit ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

local StmtDef = {
    	"_DelCreatingItemByChar",   
    	[[ 
    		delete 
    			from tbl_tong_item_create where tic_uId = ?
    		and 
    			bt_uId = (select B.bt_uId from tbl_building_tong as B,tbl_member_tong as M where 
    									B.t_uId = M.t_uId and M.cs_uId = ? and B.bt_sBuildName like "%��������%" limit 1)
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

local StmtDef = {
    	"_AddCreatingItemInfo",   
    	[[ 
    		insert into tbl_tong_item_create(bt_uId,tic_uItemType,tic_sItemName,tic_dtStartTime,tic_uState,tic_nDepot) values(?,?,?,now(),?,?)
    	]]
}    
DefineSql ( StmtDef, StmtOperater )
local StmtDef = {
    	"_GetCreatingItemInfo",   
    	[[ 
    		select tic_uItemType,tic_sItemName,tic_uState from tbl_tong_item_create
    		where tic_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )
local StmtDef = {
    	"_DelCreatingItemByID",   
    	[[ 
    		delete from tbl_tong_item_create where tic_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )


local StmtDef = {
    	"_GetTongItemBuyID",   
    	[[ 
    		select tic_uId  from tbl_tong_item_create where bt_uId = ? and tic_uState = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

local StmtDef = 
{
		"_GetTongBuildID",
		[[
			select bt_uId,bt_uState from tbl_building_tong
			where  t_uId = ? and bt_sBuildName like "%��������%"
		]]
}
DefineSql ( StmtDef, StmtOperater )

local StmtDef = 
{
		"_GetCreatingItem",
		[[
			select tic_uId,tic_sItemName,unix_timestamp(now())-unix_timestamp(tic_dtStartTime),tic_uItemType,tic_nDepot,tic_dtStartTime
			from tbl_tong_item_create where tic_uState = ? and bt_uId = ? limit ?
		]]
}
DefineSql ( StmtDef, StmtOperater )

local StmtDef = 
{
		"_GetAllCreatingItemByDepot",
		[[
			select tic.tic_sItemName,tic.tic_uItemType,tic.tic_uId
			from tbl_tong_item_create as tic,tbl_building_tong as bt
			where tic.bt_uId = bt.bt_uId 
			 		and tic.tic_uState = ? and tic.tic_nDepot = ? and bt.t_uId = ?
		]]
}
DefineSql ( StmtDef, StmtOperater )

local StmtDef = 
{
		"_UpdateCreatingItemState1",
		[[
			update tbl_tong_item_create set tic_uState = ?,tic_dtStartTime = now() where bt_uId = ? 
			and tic_uState = ?
			order by tic_dtStartTime asc limit ?
		]]
}
DefineSql ( StmtDef, StmtOperater )
local StmtDef = 
{
		"_UpdateCreatingItemState2",
		[[
			update tbl_tong_item_create set tic_uState = ?,tic_dtStartTime = date_add(?,interval ? second)
			where bt_uId = ? 
			and tic_uState = ?
			order by tic_dtStartTime asc limit ?
		]]
}
DefineSql ( StmtDef, StmtOperater )

local StmtDef = 
{
		"_GetTongDepotByBuildId",
		[[
			select T.t_uDepotID,T.t_uId from tbl_tong as T,tbl_building_tong as B
			where T.t_uId = B.t_uId and B.bt_uId = ?
		]]
}
DefineSql ( StmtDef, StmtOperater )

--------------------------------------------
--�������������쵽ʱ�����Ʒ��
function CTongCreateBox.DealWithCreatingItem(build_id, charId,sceneName,uTongID) 
  local bFlag = true
	local nRetRes,nRetMoney = 0,0,0
	local tblRetRes = {}
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local tong_box = RequireDbBox("GasTongBasicDB")
	local build_box = RequireDbBox("GasTongbuildingDB")
  local function deal_with_info(order_id,item_name,pstime,item_type,ndepot,start_time)
   	if not order_id then
   		--��һ���ȴ������е���Ʒ��Ϊ����״̬
   		StmtOperater._UpdateCreatingItemState1:ExecSql('',ItemState["������"],build_id,ItemState["�ȴ�����"],1)
			bFlag = false
			return
		end
		local ItemInfo = g_ItemInfoMgr:GetItemFunInfo(item_type,item_name)	
		if item_type == g_ItemInfoMgr:GetStaticArmorBigID() then
			--����
			ItemInfo = g_MantleMgr:GetMantleInfo(item_name)
		end
		local NeedRes = ItemInfo("NeedRes") or 0
		local NeedTongMoney = ItemInfo("NeedTongMoney") or 0
		local NeedTime = ItemInfo("NeedTime") or 0
   	if (pstime >= NeedTime) then
   	  --ʱ�䵽
   	  --�����µİ�Ὠ����Ʒ
			local tbl = StmtOperater._GetTongDepotByBuildId:ExecSql('nn',build_id)
			if tbl:GetRowNum() > 0 then
					local g_RoomMgr = RequireDbBox("GasRoomMgrDB")	
   				local cdepotMgr = RequireDbBox("GasCDepotMgrDB")	
   				
					local params= {}
					params.m_nType = item_type
					params.m_sName = item_name
					params.m_nCharID = charId
					params.m_nBindingType = g_ItemInfoMgr:GetItemInfo(item_type,item_name,"BindingStyle")
					params.m_sCreateType = event_type_tbl["��Ὠ����Ʒ����"]
					local item_id = g_RoomMgr.CreateItem(params)
					if not item_id then return end
   				local nRes = cdepotMgr.AutoAddItems(tbl:GetData(0,0),item_type,item_name,{item_id},ndepot)
   				if IsNumber(nRes) then
   					--�ֿ����ˣ�������Դ
   					nRetRes = nRetRes + NeedRes
						nRetMoney = nRetMoney + NeedTongMoney
						local tblCreatingItem= StmtOperater._GetAllCreatingItemByDepot:ExecSql('s[32]nn',ItemState["�ȴ�����"],ndepot,uTongID)
   					local row = tblCreatingItem:GetRowNum()
   					for i =1,row do  
   						local sName,nType,ID = tblCreatingItem:GetData(i-1,0),tblCreatingItem:GetData(i-1,1),tblCreatingItem:GetData(i-1,2)			
							local ItemInfoi = g_ItemInfoMgr:GetItemFunInfo(nType,sName)	
							if nType == g_ItemInfoMgr:GetStaticArmorBigID() then
								--����
								ItemInfoi = g_MantleMgr:GetMantleInfo(sName)
							end
							local NeedResi = ItemInfoi("NeedRes") or 0
							local NeedTongMoneyi = ItemInfoi("NeedTongMoney") or 0
   						nRetRes = nRetRes + NeedResi
							nRetMoney = nRetMoney + NeedTongMoneyi
							
							StmtOperater._DelCreatingItemByID:ExecSql('',ID)
							g_LogMgr.TongItemProduceEventLog(uTongID,sName,2,0)
						end
						tblRetRes = build_box.GivebackResAndMoney(uTongID,nRetRes,nRetMoney)
   				end
   				--ɾ�����������Ʒ��Ϣ
   				StmtOperater._DelCreatingItemByID:ExecSql('',order_id)
   				StmtOperater._UpdateCreatingItemState2:ExecSql('',ItemState["������"],start_time,NeedTime,build_id,ItemState["�ȴ�����"],1)
					g_LogMgr.TongItemProduceEventLog(uTongID,item_name,3,0)
   		else
   			bFlag = false
   		end
   	else
   		bFlag = false
		end
	end
	while(bFlag) do
		local tblInfo = StmtOperater._GetCreatingItem:ExecSql('ns[32]nnns[32]',ItemState["������"],build_id,g_TongMgr:GetBuildWaitNum())
		if tblInfo:GetRowNum() > 0 then
			local order_id,item_name,pstime,item_type,ndepot,start_time = tblInfo:GetNumber(0,0),tblInfo:GetString(0,1),tblInfo:GetNumber(0,2),tblInfo:GetNumber(0,3),tblInfo:GetNumber(0,4),tblInfo:GetString(0,5)
			deal_with_info(order_id,item_name,pstime,item_type,ndepot,start_time)
		else
			deal_with_info()
		end
	end
	return tblRetRes
end

function CTongCreateBox.DeleteTongBuildItem(parameters)   	
	local uPlayerID = parameters.PlayerId
	local ItemType 	= parameters.ItemType
	local ItemName 	= parameters.ItemName
	local nCont 		= parameters.nCont
	if g_ItemInfoMgr:GetItemInfo(ItemType,ItemName,"Type") == 1 then
		StmtOperater._DelCountBuildingItem:ExecSql('',ItemName,uPlayerID,nCont)
	end
end

--------------------------------------------RPC�������-------------------------------------------------

-- �������������͵ȴ��������Ʒ��
function CTongCreateBox.GetCreatingItemInfo(parameters)
	local uPlayerID 	= parameters.uPlayerID
	local sceneName = parameters.sceneName
	local tong_box = RequireDbBox("GasTongBasicDB")
	local uTongID = tong_box.GetTongID(uPlayerID)
	--local tong_camp = tong_box.GetTongCampByID(uTongID)
	--local build_name = BuildingItemMgr:GetBuildNameByCamp(tong_camp,"��������")
	local res = StmtOperater._GetTongBuildID:ExecSql('nn',uTongID)
	if res:GetRowNum() == 0  then
		--û����������
		return {}
	end
	local build_id,state = res:GetData(0,0),res:GetData(0,1)
	if state == g_TongMgr:GetBuildingState("����") or state == g_TongMgr:GetBuildingState("�ȴ�����") 
		or state == g_TongMgr:GetBuildingState("ģ��") then
			--û����������
			return {}
	end
	--�ȴ�������ʱ�䵽����Ʒ
	local RetRes = CTongCreateBox.DealWithCreatingItem(build_id, uPlayerID, sceneName,uTongID)
	local tblCreatingInfo = StmtOperater._GetCreatingItem:ExecSql('ns[32]nnns[32]',ItemState["������"],build_id,g_TongMgr:GetBuildWaitNum())
	local tbl = {}
	if tblCreatingInfo:GetRowNum() == 0 then
		table.insert(tbl,"")
		table.insert(tbl,0)
		table.insert(tbl,0)
	else
		table.insert(tbl,tblCreatingInfo:GetData(0,1))
		table.insert(tbl,tblCreatingInfo:GetData(0,0))
		table.insert(tbl,tblCreatingInfo:GetData(0,2))
	end
	
	local tblWaitingInfo = StmtOperater._GetCreatingItem:ExecSql('ns[32]nnns[32]',ItemState["�ȴ�����"],build_id,g_TongMgr:GetBuildWaitNum())
	local row = tblWaitingInfo:GetRowNum()
	if row == 0 then
		for i =1,6 do
			table.insert(tbl,"")
			table.insert(tbl,0)
		end
	else
		for i =1,row do
			table.insert(tbl,tblWaitingInfo:GetData(i-1,1))
			table.insert(tbl,tblWaitingInfo:GetData(i-1,0))
		end
		if row < 6 then
			for j = 1,(6 - row) do
				table.insert(tbl,"")
				table.insert(tbl,0)
			end
		end
	end
	return tbl, RetRes
end

function CTongCreateBox.CanBuyMantle(sItemName,nCharID)
	local tong_box = RequireDbBox("GasTongBasicDB")
	local tong_id = tong_box.GetTongID(nCharID)
	local Flag = CTongCreateBox.CanMakeMantle(sItemName,tong_id)
	return Flag == true
end

function CTongCreateBox.CanMakeMantle(sItemName,tong_id)
	local nLevel = g_MantleMgr:GetMantleInfo(sItemName)("MantleLevel")
	local WarZoneDB = RequireDbBox("WarZoneDB")
	local stationLine = WarZoneDB.GetTongRelativeLine(tong_id)
	if nLevel > (stationLine +1) then
		return 9157
	end
	return true
end

--�����䳵�����硢��ը�����졿
function CTongCreateBox.CreateTongItem(parameters)
	local nDepot = parameters.nDepot
	local sItemName = parameters.sItemName
	local nItemType = parameters.nItemType
	local uPlayerID = parameters.uPlayerID
	local sceneName	= parameters.sceneName
	local tong_box = RequireDbBox("GasTongBasicDB")
	local build_box = RequireDbBox("GasTongbuildingDB")
	local uTongID = tong_box.GetTongID(uPlayerID)
	
	--�жϲֿ�ʹ��Ȩ��
  if not tong_box.JudgePurview(uPlayerID,g_TongMgr:GetDepotStrByPage(nDepot)) then
  	return 9305
  end
  if not tong_box.JudgePurview(uPlayerID, "CreateItem") then
  	return 9006
  end
  local cdepotMgr = RequireDbBox("GasCDepotMgrDB")
  if not cdepotMgr.HaveEnoughRoomPos(tong_box.GetTongDepotID(uTongID),nItemType,sItemName,nDepot,1) then
  	return 9309
  end
  local ItemInfo = g_ItemInfoMgr:GetItemFunInfo(nItemType,sItemName)	
	if nItemType == g_ItemInfoMgr:GetStaticArmorBigID() then
		--����
		local bFlag = CTongCreateBox.CanMakeMantle(sItemName,uTongID)
		if IsNumber(bFlag) then
			return bFlag
		end
		 ItemInfo = g_MantleMgr:GetMantleInfo(sItemName)	
	end
	local Type = ItemInfo("Type")
	local NeedTongLevel = ItemInfo("NeedTongLevel") 
	local NeedRes = ItemInfo("NeedRes")
	local NeedTongMoney = ItemInfo("NeedTongMoney")
	if (Type == 1) then
		return 9183
	end
	local tong_level = tong_box.GetTongLevel(uTongID)
	if NeedTongLevel and NeedTongLevel > tong_level then
		return 9173,NeedTongLevel
	end

	--������Դ
	if NeedRes and NeedRes > 0 then
		if not build_box.UpdateTongResource(-NeedRes,uTongID,event_type_tbl["Ӷ��С����Ʒ����"]) then
			return 9010
		end
	end
	--���Ľ�Ǯ
	if NeedTongMoney and NeedTongMoney > 0 then
		if not tong_box.UpdateTongMoney({["uTongID"]=uTongID,["uMoney"]= -NeedTongMoney,["nEventType"] = event_type_tbl["Ӷ��С����Ʒ����"]}) then
			CancelTran()
			return 9030
		end
	end
	--local tong_camp = tong_box.GetTongCampByID(uTongID)
	--local build_name = BuildingItemMgr:GetBuildNameByCamp(tong_camp,"��������")
	local res = StmtOperater._GetTongBuildID:ExecSql('nn',uTongID)
	if res:GetRowNum() == 0  then
		CancelTran()
		--û���������ģ�����������Ʒ
		return 9182
	end
	
	local build_id,state = res:GetData(0,0),res:GetData(0,1)
	local tblWaitingInfo = StmtOperater._GetCreatingItem:ExecSql('ns[32]nnns[32]',ItemState["�ȴ�����"],build_id,g_TongMgr:GetBuildWaitNum())
	if tblWaitingInfo:GetRowNum() >= g_TongMgr:GetBuildWaitNum() then
		CancelTran()
		--�ȴ���������
		return 9180
	end
	if state ~= g_TongMgr:GetBuildingState("����") and state ~= g_TongMgr:GetBuildingState("�ȴ�����") 
		and state ~= g_TongMgr:GetBuildingState("ģ��") then
		local tbl = StmtOperater._GetTongItemBuyID:ExecSql('n',build_id,ItemState["������"]) 
		local sState = "������"
		if tbl:GetRowNum() > 0 then
			sState = "�ȴ�����"
		end
		StmtOperater._AddCreatingItemInfo:ExecSql('',build_id,nItemType,sItemName,ItemState[sState],nDepot) 
	else
		--û���������ģ�����������Ʒ
		CancelTran()
		return 9182
	end
	--���log
	local ex = RequireDbBox("Exchanger")
	local player_name = ex.getPlayerNameById(uPlayerID)
	local sMsg = "2012_" .. player_name .. ",item:" .. nItemType .. "|" .. sItemName
  if not tong_box.AddTongLogs(uTongID,sMsg, g_TongMgr:GetLogType("����")) then
  	return 9017
  end
  local g_LogMgr = RequireDbBox("LogMgrDB")
	g_LogMgr.TongItemProduceEventLog(uTongID,sItemName,1,uPlayerID)
	return CTongCreateBox.GetCreatingItemInfo({["uPlayerID"] = uPlayerID,["sceneName"] = sceneName})
end

--��ȡ�����졿
function CTongCreateBox.CancelMakeItem(data)
	local nOrderID = data.nOrderID
	local uPlayerID = data.uPlayerID
	local sceneName = data.sceneName
	local tong_box = RequireDbBox("GasTongBasicDB")
	if not tong_box.JudgePurview(uPlayerID, "CancelCreateItem") then
  	return 9006
  end
	local uTongID = tong_box.GetTongID(uPlayerID)
	local item_info = StmtOperater._GetCreatingItemInfo:ExecSql('ns[32]n',nOrderID)
	if item_info:GetRowNum() == 0 then return end
	local item_type,item_name,state = item_info:GetData(0,0),item_info:GetData(0,1),item_info:GetData(0,2)
	
	local ItemInfo = g_ItemInfoMgr:GetItemFunInfo(item_type,item_name)	
	if item_type == g_ItemInfoMgr:GetStaticArmorBigID() then
		--����
		ItemInfo = g_MantleMgr:GetMantleInfo(item_name)
	end
	local NeedRes = ItemInfo("NeedRes") or 0
	local NeedTongMoney = ItemInfo("NeedTongMoney") or 0
	local NeedTime = ItemInfo("NeedTime")	or 0
	local nRes,nRetMoney,nPorp = 0,0,1
	nRetMoney = NeedTongMoney * nPorp
	nRes 			= NeedRes * nPorp
	local build_box = RequireDbBox("GasTongbuildingDB")
	local tblRetRes = build_box.GivebackResAndMoney(uTongID,nRes,nRetMoney)
	StmtOperater._DelCreatingItemByChar:ExecSql('',nOrderID,uPlayerID)
	--���log
	local ex = RequireDbBox("Exchanger")
	local player_name = ex.getPlayerNameById(uPlayerID)
	local sMsg = "2017_" .. player_name .. ",item:" .. item_type .. "|" .. item_name
  if not tong_box.AddTongLogs(uTongID,sMsg, g_TongMgr:GetLogType("����")) then
  	return 9017
  end
  local g_LogMgr = RequireDbBox("LogMgrDB")
	g_LogMgr.TongItemProduceEventLog(uTongID,item_name,2,uPlayerID)
  local Info = CTongCreateBox.GetCreatingItemInfo({["uPlayerID"] = uPlayerID,["sceneName"] = sceneName})
	return Info,tblRetRes
end

--���õ�����ս�ߡ�
function CTongCreateBox.GetTongRelativeLine(data)
	local uPlayerID		= data.uPlayerID
	local tong_box		= RequireDbBox("GasTongBasicDB")
	local uTongID		= tong_box.GetTongID(uPlayerID)
	local WarZoneDB		= RequireDbBox("WarZoneDB")
	local stationLine	= WarZoneDB.GetTongRelativeLine(uTongID) or 0 --��ǰս��
	return stationLine
end
---------------------------------
return CTongCreateBox
