--���ݿ����.ֻ������.���ݵĲ�ѯ.��Ҫ�ǲ�ѯ ���λ�� �������
local EAssignMode =
{
	eAM_FreePickup 		   = 0, --����ʰȡ
	eAM_AverageAssign 	 = 1, --ƽ������
	eAM_RespectivePickup = 2, --����ʰȡ
	eAM_AuctionAssign 	 = 3, --����ģʽ
	eAM_NeedAssign			 = 4, --�������
}
local CPos = CPos
local ShareArea = 38
local event_type_tbl = event_type_tbl
local ItemObjDB = CreateDbBox(...)

local function Get2PosDistance(pos1, pos2)
	return math.max( math.abs( pos1.x - pos2.x ), math.abs( pos1.y - pos2.y ) )
end

local function ClickItemObjAddItem(data)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local res1 = CharacterMediatorDB.AddItem(data)
	if IsNumber(res1) then
		CancelTran()
		return {false,res1}
	end
	local uCharId = data["char_id"]
	local uItemType = data["nType"]
	local uItemId = nil
	for j = 1,#(res1) do
		for n = 1,#(res1[j]) do
			uItemId = res1[j][n]
			break
		end
		if uItemId then
			break
		end
	end
	local DirectDB = RequireDbBox("DirectDB")
	local DirectTbl = DirectDB.AddPlayerItemDirect(uCharId, "ʰȡ�����Ʒ", data["nType"], data["sName"])
	return {true,res1,DirectTbl}
end
--ƽ������
local function AverageAssignOneItemObj(data)
	local PlayerId = data["char_id"]
	local AverageAssignOrder = data["AverageAssignOrder"]
	local CanSharePlayer = data["CanSharePlayer"]
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local AreaDB = RequireDbBox("AreaDB")
	
	local itemtype = data["nType"]
	local itemname = data["sName"]
	local itemnum = 1
	
	--����һ�¸���Ʒ��˳��
	if CanSharePlayer and AverageAssignOrder then
		for i=1, #(AverageAssignOrder) do
			if not CanSharePlayer[i] then
				break
			elseif AverageAssignOrder[i] ~= CanSharePlayer[i] then
				local Temp = CanSharePlayer[i]
				for k=i+1, #(CanSharePlayer) do
					if AverageAssignOrder[i] == CanSharePlayer[k] then
						CanSharePlayer[i] = CanSharePlayer[k]
						CanSharePlayer[k] = Temp
						break
					end
				end
			end
		end
	end
	
	local ordertbl = CanSharePlayer or AverageAssignOrder
	
	local function GiveItem(GainerId)
		local Param = {}
		Param["char_id"]	= GainerId
		Param["nType"]	= itemtype
		Param["sName"]	= itemname
		Param["nCount"]	= itemnum
		Param["createType"]	= event_type_tbl["ƽ������ʰȡ��Ʒ"]
		local ResTbl = ClickItemObjAddItem(Param)
		if ResTbl[1] then
			return {true,GainerId,ResTbl}
		elseif ResTbl[2] == 3 then --3����������������Ҳ�����ɹ�
			return {true,GainerId}  --������ʱ��û�������Ʒ�ķ��ؽ����ResTbl
		end
		return {false}
	end
	
	for i = 1, table.getn(ordertbl) do
		---��˳�������һ��������������Ʒ�����
		local res = nil
		local teammateid = ordertbl[i]
		if teammateid ~= PlayerId then
			data["char_id"] = teammateid
			if AreaDB.Check2PlayerInSameArea(PlayerId,teammateid) 
				and LoginServerSql.IsPlayerOnLine(teammateid) then
			--if InSameAreaPlayer[teammateid] then  --�ж��Ƿ���Ϲ���Χ
				res = GiveItem(teammateid)
			end
		else  --������˳���Լ�ʱ�����ټ���Ƿ����ߺͷ�Χ�ж�
			res = GiveItem(PlayerId)
		end
		
		if res and res[1] then  --�������ɹ�ֱ��Return
			return res
		end
	end
	return {false}  --�ﵽ��һ����ʾ������Ʒʱ�����˶�������Ҫ��
end


--����  ���ϲμ��������������е�ID  char_id
local function AuctionAssignOneItemObj(data)
	local PlayerId = data["char_id"]
	local AverageAssignOrder = data["AverageAssignOrder"]
	local CanSharePlayer = data["CanSharePlayer"]
	--local InSameAreaPlayer = data["InSameAreaPlayer"]
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local AreaDB = RequireDbBox("AreaDB")
	
	local itemtype = data["nType"]
	local itemname = data["sName"]
	local itemnum = 1	
	
	local ordertbl = AverageAssignOrder or CanSharePlayer
	local res = {}
	
	for i = 1, table.getn(ordertbl) do
		local teammateid = ordertbl[i]
		data["char_id"] = teammateid
		if AreaDB.Check2PlayerInSameArea(PlayerId,teammateid) 
			and LoginServerSql.IsPlayerOnLine(teammateid) then
		--if InSameAreaPlayer[teammateid] then  --�ж��Ƿ���ͬһ����
			table.insert( res, teammateid)
		end
	end
	return res
end

local function NeedAssignGiveItem(data)
	data["nCount"] = 1
	data["createType"]	= event_type_tbl["�������"]
	local ResTbl = ClickItemObjAddItem(data)
	if not ResTbl[1] then
		return {false,ResTbl[2]}
	end
	return {true,ResTbl[2],ResTbl[3]}
end

function ItemObjDB.PickUpOneItemObj(data)
	--��Ʒ��δ�����ȥ�����ҵ�ǰ������ƽ������ģʽ��������ģʽ
--	print("PickUpOneItemObj",data["AssignMode"])
	if data["AssignMode"] == EAssignMode.eAM_AverageAssign then  --ƽ������
		return AverageAssignOneItemObj(data)
	elseif data["AssignMode"] == EAssignMode.eAM_AuctionAssign then	 --��������
		return AuctionAssignOneItemObj(data)
	end
	local PlayerId = data["char_id"]
	data["nCount"] = 1
	data["createType"]	= event_type_tbl["����ʰȡ��Ʒ"]
	local ResTbl = ClickItemObjAddItem(data)
	if not ResTbl[1] then
		return {false,ResTbl[2]}
	end
	return {true,ResTbl[2],ResTbl[3]}
end

function ItemObjDB.NeedAssignGiveItem(data)
	return NeedAssignGiveItem(data)
end

function ItemObjDB.CollectOreObj(data)

	local GatherLiveSkillDB = RequireDbBox("GatherLiveSkillDB")
	local AddExp,SkillInfo = GatherLiveSkillDB.AddExperience(data["char_id"], "�ɿ�", data["AddOreExp"])

	data["createType"]	= event_type_tbl["����ʰȡ��Ʒ"]
	local res = ClickItemObjAddItem(data)
	if not res[1] then
		CancelTran()
		return {false,res[2]}
	else
		return {true,res[2],AddExp,SkillInfo,res[3]}
	end
end

return ItemObjDB