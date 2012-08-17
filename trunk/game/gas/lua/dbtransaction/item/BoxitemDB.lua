cfg_load "int_obj/ObjRandomDropItem_Server"
cfg_load "int_obj/ObjDropItemTeam_Server"

local LogErr = LogErr
local ObjRandomDropItem_Server	=	ObjRandomDropItem_Server
local ObjDropItemTeam_Server	=	ObjDropItemTeam_Server
local g_ItemInfoMgr 			= CItemInfoMgr:new()
local EClass = EClass
local ECamp = ECamp
local g_ObjDropNum = g_ObjDropNum
local g_ObjTeamNum = g_ObjTeamNum
local GetCfgTransformValue = GetCfgTransformValue
local event_type_tbl = event_type_tbl

local BoxitemDB					=	CreateDbBox(...)
local CBoxitemPickup			=	{}
--�õ�ĳһ�������Ʒ�������Ϣ
--���������id��������Ʒ���ƣ�ĳһ���index����Ӧ���ñ�ObjDropItemTeam_Server��TeamIndex��
--���ص������Ʒ��Ϣ��type��name��count
local function GetTeamItemIndex(PlayerId, ObjName, TeamIndex)
	--assert(IsNumber(TeamIndex))
	assert(TeamIndex~= nil)
	local g_RoomMgr		= RequireDbBox("GasRoomMgrDB")	
	local AllRateSum=0
	local ClassNameTbl = {
		[EClass.eCL_Warrior]				= "��",
		[EClass.eCL_MagicWarrior]		= "ħ��",
		[EClass.eCL_Paladin]				= "��ʿ",
		[EClass.eCL_NatureElf]			= "��ʦ",
		[EClass.eCL_EvilElf]				= "аħ",
		[EClass.eCL_Priest]					= "��ʦ",
		[EClass.eCL_DwarfPaladin]		= "����",
		[EClass.eCL_ElfHunter]			= "���鹭",
		[EClass.eCL_OrcWarrior]			= "��ս",
	}
	local CampNameTbl = {
		[ECamp.eCamp_AmyEmpire]			= "����",
		[ECamp.eCamp_WestEmpire]		= "��ʥ",
		[ECamp.eCamp_DevilIsland]		= "��˹",
	}
	if string.find(TeamIndex, "#class#") then	
		local FightSkillDB = RequireDbBox("FightSkillDB")
		local ClassID = FightSkillDB.Dbs_SelectPlayerClass(PlayerId)
		TeamIndex = string.gsub(TeamIndex, "#class#", ClassNameTbl[ClassID])
	end
	if string.find(TeamIndex, "#camp#") then
		local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
		local Camp = CharacterMediatorDB.GetCamp(PlayerId)
		TeamIndex = string.gsub(TeamIndex, "#camp#", CampNameTbl[Camp])
	end
	local ObjDropItemTeam=ObjDropItemTeam_Server(TeamIndex)
	if ObjDropItemTeam==nil then
		return
	end
	local randomDropItem = {}
	
	for i=1,g_ObjTeamNum do
		local DropRate="Rate"..i
		local Rate = ObjDropItemTeam(DropRate)
		if Rate == "" or Rate == nil then
			Rate = 0
		else
			Rate = tonumber(Rate)
		end
		AllRateSum = AllRateSum + Rate
	end
	local RandomItemRate=math.random(1,AllRateSum)
	local ItemRateIndex=0
	local droprate1=ObjDropItemTeam("Rate1")
	if droprate1 == "" or droprate1 == nil then
		droprate1 = 0
	else
		droprate1 = tonumber(droprate1)
	end
	if RandomItemRate>0 and RandomItemRate<=droprate1 then
		ItemRateIndex=1
	else
		local droprate1 = 0
		local droprate2 = ObjDropItemTeam("Rate1")
		if droprate2 == nil or droprate2 == "" then
			droprate2 = 0 
		else
			droprate2 = tonumber(droprate2)
		end
		for i=2,g_ObjTeamNum do	
			local AddRate2=ObjDropItemTeam("Rate"..i)
			if AddRate2 == nil or AddRate2 == "" then
				AddRate2 = 0 
			else
				AddRate2 = tonumber(AddRate2)
			end
			
			local AddRate1=ObjDropItemTeam("Rate"..(i-1))
			if AddRate1 == nil or AddRate1 == "" then
				AddRate1 = 0 
			else
				AddRate1 = tonumber(AddRate1)
			end
			
			droprate2 = AddRate2 + droprate2
			droprate1 = AddRate1 + droprate1
			
			if RandomItemRate>droprate1 and RandomItemRate<=droprate2 then
				ItemRateIndex=i
				break
			end
		end
	end
	if ItemRateIndex>0 and ItemRateIndex<=g_ObjTeamNum then
		local ItemType=ObjDropItemTeam("ItemType"..ItemRateIndex)
		if IsNumber(tonumber(ItemType)) then
			local ItemNameIndex="ItemName"..ItemRateIndex
			local ItemName=ObjDropItemTeam(ItemNameIndex)
			local ItemBindingType = ObjDropItemTeam("BindingType" .. ItemRateIndex)
			local ItemNum=math.random(ObjDropItemTeam("MinNum"),ObjDropItemTeam("MaxNum"))
			local Only = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"Only" )
			local havenum = g_RoomMgr.GetItemCount(PlayerId,ItemType,ItemName)		
			if Only ~= 1 or (Only == 1 and havenum == 0) then
				local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
				if FoldLimit == 1 then
					for i = 1, ItemNum do
						table.insert(randomDropItem, {ItemType,ItemName,1,ItemBindingType})
					end
				else
					table.insert(randomDropItem, {ItemType,ItemName,ItemNum,ItemBindingType})
				end
			end
		end
	end
	return randomDropItem
end

--������Ʒ����������Ʒ�󣬽��������Ʒ��Ϣ����������
local StmtDef = {
	"_InsertToBoxitemPickupTbl",
	[[ insert into tbl_item_boxitem_pickup (cs_uId, ibp_uBoxitemId, ibp_uType, ibp_sName, ibp_uCount, ibp_uBindingType) values(?,?,?,?,?,?) ]]
}
DefineSql(StmtDef,CBoxitemPickup)
--���ݺ�����Ʒ���ƣ��õ�������һ�����Ʒ
function BoxitemDB.GetDropTeamIndexByCfg(uCharId, boxitemName, boxitemID)
	local RandomItemTbl = {}
	local CollObjInfo=ObjRandomDropItem_Server(boxitemName)
	if CollObjInfo == nil then
	   LogErr("BoxItem����, ������Ʒ���ƣ�", boxitemName) 
	end
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local PlayerLevel = CharacterMediatorDB.GetPlayerLevel(uCharId)
	for i=1, g_ObjDropNum do --ѭ����С�����߻���
--		local dropLevel = CollObjInfo("DropTeamLevel"..i)
		local dropLevel = GetCfgTransformValue(false, "ObjRandomDropItem_Server", boxitemName, "DropTeamLevel"..i)
		if dropLevel == nil or dropLevel == "" or (dropLevel[1] <= PlayerLevel and dropLevel[2] >= PlayerLevel) then
			local TeamRate="TeamRate"..i  --TeamRate1��ֵ��ʾObjRandomDropItem_Server���в���������Ʒ�ļ���
			local GetItemTeam="GetItemTeam"..i  --GetItemTeam1��ֵ��ʾ���Index����ӦObjDropItemTeam_Server��Index
			if CollObjInfo ~= nil then	
				local Rate=CollObjInfo(TeamRate)
				if Rate~="" and Rate~=0 and Rate ~= nil then
					if math.random(1,1000)<=(Rate*1000) then
						local TeamIndex=CollObjInfo(GetItemTeam) --TeamIndex��ӦObjDropItemTeam_Server��Index
						if TeamIndex~="" and TeamIndex~=0 then
							local randomDropItem = GetTeamItemIndex(uCharId, boxitemName, TeamIndex)
							if randomDropItem ~= nil  then
								for j=1, # randomDropItem do
									table.insert(RandomItemTbl, randomDropItem[j] )
								end
							end
						end
					end
				end
			end
		end
	end
	for i=1, table.getn(RandomItemTbl) do
		local itemType,itemName,itemCount,itemBindingType = RandomItemTbl[i][1],RandomItemTbl[i][2],RandomItemTbl[i][3],RandomItemTbl[i][4]
		--�������Ʒ�������ݿ���в���������Ʒ��Ϣ
		if(not itemBindingType or "" == itemBindingType) then
			CBoxitemPickup._InsertToBoxitemPickupTbl:ExecStat(uCharId, boxitemID, tonumber(itemType), itemName, itemCount)
		else
			CBoxitemPickup._InsertToBoxitemPickupTbl:ExecStat(uCharId, boxitemID, tonumber(itemType), itemName, itemCount, tonumber(itemBindingType))
		end
		
		local lastInsertId = g_DbChannelMgr:LastInsertId()
		if (g_DbChannelMgr:LastAffectedRowNum() < 1) then
			LogErr("������ƷInsertAffectedRow0", "1:" .. (uCharId or "-") .. "2:" .. (boxitemID or "-") .. "3:" .. (itemType or "-") .. "4:" .. (itemName or "-") .. "5:" .. (itemCount or "-") .. "6:" .. (lastInsertId or "-"))
			CancelTran()
			return nil
		end
		
		table.insert(RandomItemTbl[i], lastInsertId)
	end
	return RandomItemTbl
end

--ͨ�����id�ͺ�����Ʒid���õ��������Ʒ���͡���Ʒ���ơ���Ʒ��Ŀ����Ʒ��ˮ��
local StmtDef = {
	"_GetOnePageBoxitemInfo",
	[[ select ibp_uType, ibp_sName, ibp_uCount, ibp_uId, ibp_uBindingType from tbl_item_boxitem_pickup where cs_uId=? and ibp_uBoxitemId=? limit ?, ? ]]
}
DefineSql(StmtDef,CBoxitemPickup)

function BoxitemDB.GetDropTeamIndexByDB(uCharId, itemID, curPageNo)
	assert(IsNumber(uCharId))
	assert(IsNumber(itemID))
	assert(IsNumber(curPageNo))
	local itemBeginNo = (curPageNo-1)*4  
	local checkItemCount	  =  4
	local boxitemDropRet = CBoxitemPickup._GetOnePageBoxitemInfo:ExecStat(uCharId, itemID, itemBeginNo, checkItemCount )
	return boxitemDropRet
end

local StmtDef = {
	"_GetBoxitemDropCount",
	[[select count(*) from tbl_item_boxitem_pickup where cs_uId=? and ibp_uBoxitemId=? group by ibp_uBoxitemId]]
}
DefineSql(StmtDef, CBoxitemPickup)

local function AddActionCount(CharID, bigID, itemName)
	if g_ItemInfoMgr:IsTurntableItem(bigID) then
		local ActionName = g_ItemInfoMgr:GetItemInfo(bigID, itemName,"ActionName")
		local Count = g_ItemInfoMgr:GetItemInfo(bigID, itemName,"Count")
		local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
		if ActionName and ActionName ~= "" then
			local data = {["PlayerId"] = CharID, ["ActivityName"] = ActionName}
			if Count == 1 then
				local IsAllow = ActivityCountDbBox.CheckActionLimitCount(data)
				if not IsAllow then
					return false
				end
				ActivityCountDbBox.AddAreaFbExtraCount(CharID, ActionName)
			elseif Count > 1 then
				for i = 1, Count do
					local IsAllow = ActivityCountDbBox.CheckActionLimitCount(data)
					if IsAllow then
						ActivityCountDbBox.AddAreaFbExtraCount(CharID, ActionName)
					else
						CancelTran()
						return false
					end
				end
			end
		end
	end
end
--�Ҽ����������Ʒ,����Ʒʰȡ���
function BoxitemDB.BoxitemDropInfo(data)
	local uCharId			=	data["CharID"]
	local nRoomIndex		=	data["RoomIndex"]
	local nPos				=	data["Pos"]
	local uCharLevel 	    =   data["CharLevel"]
	local boxItemType       =   data["ItemType"]
	local boxItemName       =   data["ItemName"]
	
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")	
	
	local itemType, itemName, itemID = g_RoomMgr.GetOneItemByPosition(uCharId, nRoomIndex, nPos)	--���ݺ�����Ʒ����λ�ã��õ�������Ʒ��type��name��id
	if itemType == nil or itemName == nil or itemID == nil then
		--, "�˸���û�к�����Ʒ���޷���ʰȡ���"
		return false, 6501
	end
	local bigID = tonumber(itemType)
	if boxItemType ~= bigID or boxItemName ~= itemName then
	    return false, 6501
	end
	

	local BaseLevel = g_ItemInfoMgr:GetItemInfo(bigID, itemName,"BaseLevel")
	if uCharLevel < BaseLevel then
		--,"����ǰ�ȼ�����ʹ�ø���Ʒ��"
		return false,6500
	end
	
	local boxitemDropCount = CBoxitemPickup._GetBoxitemDropCount:ExecSql("n", uCharId, itemID)
	local randomDropItem = {}
	local totalPageNo = 0 
	local curPageNo = 1
	local bTblResultFlag = false
	if  boxitemDropCount:GetRowNum() == 0 then										--�����δ�򿪹�������Ʒ,���ݿ���δ�洢�����Ϣ
		local res = AddActionCount(uCharId, bigID, itemName)
		if res == false then
			return false, 843
		end
		randomDropItem = BoxitemDB.GetDropTeamIndexByCfg(uCharId, itemName, itemID)	--�õ�������Ʒ�����������Ʒ��Ϣ��
		totalPageNo = math.ceil(# randomDropItem/4)
		bTblResultFlag = true  --�����ñ��ж�����
	else												
		randomDropItem =  BoxitemDB.GetDropTeamIndexByDB(uCharId, itemID, curPageNo)--ͨ�����ݿ�õ�������Ʒ�������Ʒ��Ϣ	
		totalPageNo = math.ceil(boxitemDropCount:GetData(0, 0)/4)
		bTblResultFlag = false --�����ݿ��в�ѯ����
	end
	
	local result = {["RandomItemTbl"] =randomDropItem, ["TotalPageNo"]=totalPageNo, 
					["CurPageNo"]=curPageNo, ["BoxitemID"]=itemID, ["TblResultFlag"] = bTblResultFlag }
	return true, result
end

--��ѯ��Ʒ�Ƿ���tbl_item_boxitem_pickup ���С�   
--��ѯ������Ʒ�Ĵ�״̬
function BoxitemDB.SelectItemByID(data)
	local uCharId			=	data["CharID"]
	local nRoomIndex		=	data["RoomIndex"]
	local nPos				=	data["Pos"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")	
	local itemType, itemName, itemID = g_RoomMgr.GetOneItemByPosition(uCharId, nRoomIndex, nPos)	--���ݺ�����Ʒ����λ�ã��õ�������Ʒ��type��name��id
	if itemType == nil or itemName == nil or itemID == nil then
		--, "�˸���û�к�����Ʒ���޷���ʰȡ���"
		return false, 6501
	end
	local boxitemDropCount = CBoxitemPickup._GetBoxitemDropCount:ExecSql("n", uCharId, itemID)
	if boxitemDropCount:GetRowNum() == 0 then
		return false
	end
	return true
end

--��ȡ��Ʒ������Ʒ����item_store_room���ݿ�����Ҽӵ�������
--������������Ʒ�������Ʒ�����������������ݿ���д洢��������
function BoxitemDB.AddDropItemToBag(uCharId, row, dropItem)
	local taker_info = {}
	local g_RoomMgr		= RequireDbBox("GasRoomMgrDB")
	local item_bag_box	= RequireDbBox("CPutItemToBagDB")
	for i=1, row do
		local sType = dropItem:GetData(i-1,0)
		local sName = dropItem:GetData(i-1,1)
		local itemCount = dropItem:GetData(i-1,2)		--�õ������ĳһ����Ʒ������
		local itemBindingType = dropItem:GetData(i-1,3)
		local dropItemIdTbl = {}						--��ʱ����ĳһ����Ʒ�и�����Ʒ��Ӧ��id
		local params= {}
		params.m_nType = sType
		params.m_sName = sName
		params.m_nBindingType = itemBindingType or (g_ItemInfoMgr:GetItemInfo( tonumber(sType),sName,"BindingStyle" ) or 0)
		params.m_nCharID = uCharId
		params.m_sCreateType = event_type_tbl["������Ʒ����"]
		for j=1, itemCount do
			--��ʰȡ����Ʒ�Ӻ�����Ʒʰȡ��ת�Ƶ�tbl_item_static
			local insertItemID	= g_RoomMgr.CreateItem(params)
			if not insertItemID then
				CancelTran()
				return false
			end
			table.insert(dropItemIdTbl, {insertItemID} )
		end
		local param = {}
		param.m_nCharID = uCharId
		param.m_nItemType = sType
		param.m_sItemName = sName
		param.m_tblItemID = dropItemIdTbl
		local bFlag, ret_info =item_bag_box.AddCountItem(param)
		if bFlag == false then
			CancelTran()
		    return false
		end
		table.insert(taker_info, ret_info)
	end
	
	return true, taker_info
end

local StmtDef ={
	"_GetBoxitemDropByBoxitemID",
	[[ select ibp_uType, ibp_sName, ibp_uCount, ibp_uBindingType from tbl_item_boxitem_pickup where cs_uId=? and ibp_uBoxitemId=? ]]
}
DefineSql(StmtDef, CBoxitemPickup)
--���ݺ�����Ʒ��idɾ��������Ʒ��Ӧ����Ʒ��Ϣ
local StmtDef = {
	"_DelAllBoxitemDroped",
	[[ delete from tbl_item_boxitem_pickup where  cs_uId=? and ibp_uBoxitemId=? ]]
}
DefineSql(StmtDef,CBoxitemPickup)

--��ȡ������Ʒ�е�������Ʒ
function BoxitemDB.TakeAllBoxitemDrop(data)
	local uCharId		=	data["CharID"]
	local itemID		=	data["BoxitemID"]
	assert(uCharId)
	assert(itemID)
	
	local g_RoomMgr		= RequireDbBox("GasRoomMgrDB")	
	local posRet = g_RoomMgr.GetRoomIndexAndPosByItemId(uCharId, itemID)
	if posRet == nil then
		--, "û�ж�Ӧ��Ʒ��Ϣ!"
		return false, 6502
	end
	
	local dropItem	= CBoxitemPickup._GetBoxitemDropByBoxitemID:ExecStat(uCharId, itemID)
	local row = dropItem:GetRowNum()
	if row == 0 then
		CancelTran()
		return false
	end
	
	local nRoomIndex, nPos = posRet(1,1), posRet(1,2)
	if g_RoomMgr.DelItemByID(uCharId, itemID,event_type_tbl["������Ʒɾ��"]) == false then  --ɾ�����ݿ��еĺ�����Ʒ
		CancelTran()
		--, "ɾ��������Ʒʧ�ܣ�"
		return false, 6503
	end
	
	local addItemToBagSuc,taker_info = BoxitemDB.AddDropItemToBag(uCharId, row, dropItem)
	if addItemToBagSuc == false then
		--, "�����Ʒʧ�ܣ�"
		return false, 6504
	end
	local result = {["RoomIndex"] =nRoomIndex, ["Pos"]=nPos, ["taker_info"]=taker_info}
	
	return true, result
end

local StmtDef ={
	"_GetBoxitemDropByIndex",
	[[ select ibp_uType, ibp_sName, ibp_uCount, ibp_uBindingType from tbl_item_boxitem_pickup where ibp_uId=? ]]
}
DefineSql(StmtDef, CBoxitemPickup)

--����ʰȡ����Ʒ��ˮ��ɾ����Ʒ
local StmtDef = {
	"_DelBoxitemDropedItem",
	[[ delete from tbl_item_boxitem_pickup where  ibp_uId=? ]]
}
DefineSql(StmtDef,CBoxitemPickup)

--��ȡĳ���������Ʒ
function BoxitemDB.TakeOneDropItemByIndex(data)
	local uCharId		=	data["CharID"]
	local curPageNo		=	data["CurPageNo"]
	local index			=	data["Index"]
	local itemID		=	data["BoxitemID"]
	assert(curPageNo and itemID and index)

	local ret = CBoxitemPickup._GetBoxitemDropByIndex:ExecStat(index)
	local row  = ret:GetRowNum()
	if row == 0 then
		return false
	end
	
	CBoxitemPickup._DelBoxitemDropedItem:ExecSql("", index)		--���ݵ�����Ʒ����ˮ�ţ���������Ʒ
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		--, "ɾ����Ʒ���ɹ���"
		return false, 6503
	end
	
	local addSuc,taker_info = BoxitemDB.AddDropItemToBag(uCharId, row, ret) 
	if addSuc == false then
		CancelTran()
		--, "�����Ʒ���ɹ���"
		return false, 6504
	end
	local totalCountRet = CBoxitemPickup._GetBoxitemDropCount:ExecSql("n", uCharId, itemID)
	local totalCount = 0
	if totalCountRet:GetRowNum() > 0 then
		totalCount = totalCountRet:GetData(0,0)
	end
	local totalPageNo = math.ceil(totalCount/4)	
	local itemNo = math.ceil(totalCount%4)
	if itemNo == 0 and curPageNo == math.ceil((totalCount+1)/4)	 then
		curPageNo = curPageNo - 1 
	end
	
	local g_RoomMgr		= RequireDbBox("GasRoomMgrDB")
	local result = {}
	if totalCount == 0 and addSuc then
		local posRet = g_RoomMgr.GetRoomIndexAndPosByItemId(uCharId, itemID)
		if posRet == nil then
			CancelTran()
			--, "�����Ʒ���ɹ���"
			return false, 6504
		end
		local nRoomIndex, nPos = posRet(1,1), posRet(1,2)
		
		if g_RoomMgr.DelItemByID(uCharId, itemID,event_type_tbl["������Ʒɾ��"]) == false then  --ɾ�����ݿ��еĺ�����Ʒ
			CancelTran()
			--, "��ȡʧ�ܣ�"
			return false, 6505
		end
		result = {["DropedItemLeft"]= false, ["RoomIndex"]= nRoomIndex, ["Pos"]=nPos, ["taker_info"]=taker_info}
		return true, result
	
	elseif addSuc then
		local randItemTbl = BoxitemDB.GetDropTeamIndexByDB(uCharId, itemID, curPageNo)
		local bTblResultFlag = false --���ݿ�����
		result = {["DropedItemLeft"] = true, ["RandItemTbl"]=randItemTbl, ["TotalPageNo"]=totalPageNo, ["taker_info"]=taker_info,
		            ["TblResultFlag"] =bTblResultFlag }
		return true, result
	end
end

--������Ʒʰȡ������·�ҳ
function BoxitemDB.GetOnePageDropItem(data)
	local uCharId		=	data["CharID"]
	local itemID		=	data["BoxitemID"]
	local curPageNo		=	data["CurPageNo"]
	local randomItemTbl =  BoxitemDB.GetDropTeamIndexByDB(uCharId, itemID, curPageNo)
	return true, randomItemTbl
end

--������׵��Ǻ�����Ʒ������Ҫ��tbl_item_boxitem_pickup���еĽ��׵ĺ�����Ʒ��������ص���Ʒ��������Ҹ���
local StmtDef = {
	"_UpdateBoxitemRelatedCharID",
	[[
		update tbl_item_boxitem_pickup
		set cs_uId = ? where  ibp_uBoxitemId = ?
	]]
}
DefineSql(StmtDef, CBoxitemPickup)

--�鿴������Ʒ�Ƿ�򿪹���tbl_item_boxitem_pickup�Ƿ��й��ں�����Ʒ����Ϣ
local StmtDef = {
	"_SelectBoxitemInfoByBoxitemID",
	[[
		select count(*) from tbl_item_boxitem_pickup
		where ibp_uBoxitemId = ?
	]]
}
DefineSql(StmtDef, CBoxitemPickup)

local StmtDef = {
    "_SelectBoxitemBelonging",
    [[
        select cs_uId from tbl_item_boxitem_pickup where ibp_uBoxitemId = ?
    ]]

}DefineSql(StmtDef, CBoxitemPickup)

function BoxitemDB.UpdateBoxitemBelonging(stype, playerID, boxitemId)
	if g_ItemInfoMgr:IsBoxitem(stype) or g_ItemInfoMgr:IsTurntableItem(stype) then
	    local bBoxitemOpenedRet  =  CBoxitemPickup._SelectBoxitemInfoByBoxitemID:ExecSql("n", boxitemId)
		if bBoxitemOpenedRet:GetData(0, 0) > 0 then   --����������Ʒ���򿪹���tbl_item_boxitem_pickup�����м�¼
			local boxitemBelongingRet = CBoxitemPickup._SelectBoxitemBelonging:ExecStat(boxitemId)
			local boxitemBelonging = boxitemBelongingRet:GetData(0,0)
			if boxitemBelonging ~= playerID then
    			CBoxitemPickup._UpdateBoxitemRelatedCharID:ExecSql("",  playerID, boxitemId)  --��Ҫ�޸ĺ�����Ʒ�а�������Ʒ���������Ϣ
    			if g_DbChannelMgr:LastAffectedRowNum()< 1 then
    				CancelTran()
    				--, "���º�����Ʒ������Ҵ���"
    				return false
    			end
    	    else
    	       return true 
    	    end
		end
	end
end

function BoxitemDB.IsBoxitemOpened(boxitemIdTbl, charID) 
    local itemIDTbl = {}
    if type(boxitemIdTbl) == "userdata" then
        local boxitemCount = boxitemIdTbl:GetRowNum()
        for i=1, boxitemCount do
             local itemID = boxitemIdTbl(i, 1)
             table.insert(itemIDTbl, itemID)
        end
    else
        itemIDTbl = boxitemIdTbl     
    end
    local stmt = "select count(distinct(ibp_uBoxitemId)) from tbl_item_boxitem_pickup where cs_uId = " .. charID .. " and ibp_uBoxitemId in "
    stmt = stmt .. "(" .. table.concat(itemIDTbl, ", ") .. ")"
    local _, query_result = g_DbChannelMgr:TextExecute(stmt)
    local openedBoxItemCount = query_result:GetData(0, 0)
    
    if openedBoxItemCount > 0 then
        return true
    else
        return false
    end   
end

SetDbLocalFuncType(BoxitemDB.BoxitemDropInfo)
SetDbLocalFuncType(BoxitemDB.SelectItemByID)
SetDbLocalFuncType(BoxitemDB.TakeOneDropItemByIndex)
SetDbLocalFuncType(BoxitemDB.TakeAllBoxitemDrop)
SetDbLocalFuncType(BoxitemDB.GetOnePageDropItem)
SetDbLocalFuncType(BoxitemDB.UpdateBoxitemBelonging)
return BoxitemDB
