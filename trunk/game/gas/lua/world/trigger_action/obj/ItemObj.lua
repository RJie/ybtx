gas_require "world/int_obj/IntObjServer"
gas_require "activity/quest/RoleQuest"
gas_require "world/trigger_action/obj/AssignObj"
gas_require "world/trigger_action/obj/assign_mode/NeedAssign"
gas_require "world/trigger_action/obj/assign_mode/AcutionAssign"
gac_gas_require "item/item_info_mgr/ItemInfoMgr"



local g_GetDistance = g_GetDistance
local os = os
local MsgToConn = MsgToConn
local g_ObjActionArgTbl = g_ObjActionArgTbl
local DropItemProtectTime = DropItemProtectTime
local IsCppBound = IsCppBound
local EAssignMode = EAssignMode
local g_AverageAssignOrder = g_AverageAssignOrder
local NpcDropObjTbl = NpcDropObjTbl
local NeedAssignOneObj = NeedAssignOneObj
local GetQuestAddItemErrorMsgID = GetQuestAddItemErrorMsgID
local BreakPlayerActionLoading = BreakPlayerActionLoading
local g_AreaMgr = g_AreaMgr
local LogErr = LogErr
local AllotObj = AllotObj
local AuctionAssignOneObj = AuctionAssignOneObj

local g_ItemInfoMgr = CItemInfoMgr:new()

local g_GetPlayerInfo = g_GetPlayerInfo
local Entry  = CreateSandBox(...)

function Entry.GetPackData(Conn, ItemObj, ObjName, ObjID) 
	local PlayerId = Conn.m_Player.m_uID
	
	if g_GetDistance(Conn.m_Player,ItemObj)>6 then --�жϾ���
		return
	end

	local ItemType = g_ObjActionArgTbl[ObjName][1]
	local data = {}
	data["char_id"]		= PlayerId
	data["nType"]		= ItemType
	data["sName"] 		= ObjName
	
	local IsProTime = true
	if ItemObj.m_Scene.m_SceneAttr.SceneType == 5 then
		local DropNpcID = ItemObj.m_BelongToNpc
		local DropObjTbl = NpcDropObjTbl[DropNpcID]
		if DropNpcID and not DropObjTbl then
			return
		end
		local Sharertbl = DropObjTbl.m_CanSharePlayer
		local IsInShare = false
		if not IsTable(Sharertbl) then
			IsInShare = true
		else
			--5����³Ǹ��� ֻ���ڷ����б��е���ҿ���ʰȡ
			for i = 1, table.getn(Sharertbl) do
				if Sharertbl[i] == PlayerId then   
					IsInShare = true
					break
				end
			end
		end
		if not IsInShare then
			MsgToConn(Conn, 3034)
			return
		end
		IsProTime = false
	end
--	local WaitTime = 20
	if ItemObj.m_QuestObjOwnner then
		if ItemObj.m_QuestObjOwnner ~= PlayerId then
			MsgToConn(Conn, 3034)
			return
		else
			data["CheckQuestNeed"] = true
			return data
		end
	elseif ItemObj.m_FreePickup then
		data["AssignMode"] = EAssignMode.eAM_FreePickup
		return data
	elseif ItemObj.m_NeedMaster then
		return data
	else
		local DropNpcID = ItemObj.m_BelongToNpc
		local DropObjTbl = NpcDropObjTbl[DropNpcID]
		if DropNpcID and not DropObjTbl then
			return
		end
		
		local BelongTeam = ItemObj.m_Properties:GetBelongToTeam()
		local DropOwnerId = ItemObj.m_Properties:GetDropOwnerId()
		local DropTime = ItemObj.m_Properties:GetDropTime()
		if BelongTeam ~= 0 then  --��npc�������Ʒ�Ѿ�ָ���������ĸ�����
			local TeamID = Conn.m_Player.m_Properties:GetTeamID()
			local IsInSharertbl = false 
--			if TeamID == BelongTeam then
--				IsInSharertbl = true
--			else
				local Sharertbl = DropObjTbl.m_CanSharePlayer
				for i = 1, table.getn(Sharertbl) do
					--��ҵĶ����Ѿ���ɢ������Npc����Ȼ��¼�ſ��Է�����Ʒ������б���������ڴ��б���
					if Sharertbl[i] == PlayerId then   
						IsInSharertbl = true
						break
					end
				end
--			end
			
			if IsInSharertbl then   --�������Ʒ�����ߵ��б���
				local AssignMode = DropObjTbl.m_AssignMode				--��Ʒ ������ģʽ
				local AuctionStandard = DropObjTbl.m_AuctionStandard   --   ����ģʽ Ʒ���趨	
				if AssignMode == EAssignMode.eAM_RespectivePickup then    --����ʰȡ
					if PlayerId == DropOwnerId  --�����Ա����ʰȡ�Լ�������npc�������Ʒ
						or (DropTime ~= 0 and IsProTime and (os.time()-DropTime) >= DropItemProtectTime) then 
						return data
					end
				elseif AssignMode == EAssignMode.eAM_FreePickup then  --�����Ա����ʰȡ���������˴������Ʒ  ����ʰȡ
					return data
				elseif AssignMode == EAssignMode.eAM_AverageAssign then  --�����Աƽ��������������˴������Ʒ  ƽ������
					--��ƽ�������ʰȡ���
					data["AssignMode"] = EAssignMode.eAM_AverageAssign
					if g_AverageAssignOrder[BelongTeam] then
						data["AverageAssignOrder"] = g_AverageAssignOrder[BelongTeam]
					end
					data["CanSharePlayer"] = DropObjTbl.m_CanSharePlayer
					return data
				elseif AssignMode == EAssignMode.eAM_AuctionAssign then  --�ڶ����ڶԶ��������˴������Ʒ��������  ����ģʽ
					--������ģʽ�����(��ʱ�ø��˵�ģʽ,��Ϊû��ʵ��)
					data["AssignMode"] = EAssignMode.eAM_AuctionAssign
					local Quality = g_ItemInfoMgr:GetItemInfo( ItemType, ObjName,"Quality" )
--					print("��Ʒ+=+=+=+=Ʒ��", Quality)
					if AuctionStandard > Quality then  --��Ʒ��Ʒ�ʼ�
						data["AssignMode"] = EAssignMode.eAM_AverageAssign
						if g_AverageAssignOrder[BelongTeam] then
							data["AverageAssignOrder"] = g_AverageAssignOrder[BelongTeam]
						end
						data["CanSharePlayer"] = DropObjTbl.m_CanSharePlayer
						return data
					end
					ItemObj.m_AssignPlayer = DropObjTbl.m_CanSharePlayer
					data["AuctionStandard"] = AuctionStandard
					data["AuctionBasePrice"] = DropObjTbl.m_AuctionBasePrice
					AuctionAssignOneObj(Conn, data, ItemObj, ObjID)
				elseif AssignMode == EAssignMode.eAM_NeedAssign then --�������ģʽ
					local Quality = g_ItemInfoMgr:GetItemInfo( ItemType, ObjName,"Quality" )
					if AuctionStandard > Quality then  --��Ʒ��Ʒ�ʼ�
						data["AssignMode"] = EAssignMode.eAM_AverageAssign
						if g_AverageAssignOrder[BelongTeam] then
							data["AverageAssignOrder"] = g_AverageAssignOrder[BelongTeam]
						end
						data["CanSharePlayer"] = DropObjTbl.m_CanSharePlayer
						return data
					end
					ItemObj.m_AssignPlayer = DropObjTbl.m_CanSharePlayer
					NeedAssignOneObj(Conn, data, ItemObj, ObjID)
				end
			elseif DropTime ~= 0 and IsProTime and (os.time()-DropTime)>=DropItemProtectTime then
				return data
			else
				MsgToConn(Conn, 3034)
			end
		--��Ʒû��ָ�������ĸ�����,�������Ʒ���ڸ����
		else
			if DropOwnerId ~= 0 then
				if PlayerId == DropOwnerId
					or (DropTime ~= 0 and IsProTime and (os.time()-DropTime)>=DropItemProtectTime) then
					return data
				else
					MsgToConn(Conn, 3034)
				end
			else
				return data
			end
		end
	end
	return
end

function Entry.Exec(Conn, ItemObj, ObjName, ObjID)
	if ItemObj.m_IsClick then
		return
	end
	
	local data = Entry.GetPackData(Conn, ItemObj, ObjName, ObjID)
	if data == nil then
		return
	end
	
	if Conn.m_Player.m_ActionLoadingTick then
		BreakPlayerActionLoading(Conn.m_Player)
	end
	
--	Conn.m_Player:IsFirstTimeAndSendMsg("ʰȡ", 2005, sMsg)
	
	data["sceneName"] = Conn.m_Player.m_Scene.m_SceneName
	AllotObj( Conn, ItemObj, ObjName, ObjID, data)
end

return Entry
