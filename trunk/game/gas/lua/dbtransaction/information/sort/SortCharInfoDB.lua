
local SortCharInfoSql = class()

local SortCharInfoDB = CreateDbBox(...)
------------------------------------------------------------------------------------------
--@brief ���а���ֵ��
--[[
	["�������"]				= 1��
	["�ȼ�����"]				= 2��
	["��ѽ�����"]				= 3��
	["�Ƹ���"]					= 4��
	["��ѫ��"]					= 5��
	["������"]					= 6��
	["�����"]					= 7��
	["�ۼ�ɱ�ְ�"]				= 8��
	["����ɱ�ְ�"]				= 9��
	["����ʱ���"]				= 10
	["�淨���ְ�"]				= 11
	["Ӷ�������"]				= 12
	["����ɱ�ܲ�����������"]	= 13
	["ɱ�˰�"] 					= 14
	["����ɱ��ʤ��������"]		= 18
	["�������ܲ���������5v5"]	= 21
	["����ɱ�ܻ��ְ�"]	= 22
	["ս�������ְ�"]	= 23
	["Ӷ��С�ӵȼ�����"] = 24
	["Ӷ��С����������"] = 25
	["Ӷ��С�Ӿ�������"] = 26
	["Ӷ��С���ʽ�����"] = 27
	["������������"] = 28
	["����ʤ��������"] = 29
	["����ɱ��������"] = 30
	["��Դ������ɱ�˰�"] = 31
	["��Դ��ռ�������"] = 32
	["��Դ������ɱ�˰�"] = 31
	["��Դ��ռ�������"] = 32
	["Ӷ��С�ӻ�ɱ����������"] = 33
	["��һ�ɱ����������"] = 34
	CampType�� --4:ȫ��;1:����;2��˹;3��ʥ
--]]
------------------------------------------------------------------------------------------
--@brief ���ݴ��������ֶ�����ѯ��ǰ���а��е�����
--@param field_name:�ֶ���
local function CurrentSortByParam(table_name,field_name,LastMinValue,field2,field3)
	local query_string = "select a.cs_uId,b."  .. field_name .. " from tbl_char a," .. table_name .. " b where a.cs_uId = b.cs_uId "
	if field2 and field3 then
		query_string = query_string .. " and b." .. field2 .. " = " .. field3
	end
	query_string = query_string .. " and " .. field_name .. " >= " .. LastMinValue .." order by b." .. field_name .. " desc limit 200 "
	local _, resObj = g_DbChannelMgr:TextExecute(query_string)--Ŀǰ������
	return resObj
end
------------------------------------------------------------------------------------------
--@brief ���ݴ������ı������ֶ�����ѯԭ�����а��е�����
--@param table_name:Ҫ��ѯ�ı���
--@param order_field:�����ֶ�
--@param updown_field:���������ֶ�
--@param sort_field:Ҫ�������е��ֶ���
local function OldSortByParam(table_name,order_field,updown_field,sort_field)
	local query_string = "select a." .. order_field .. ",a." .. updown_field .. ",b.c_sName,c.cs_uClass,a." .. sort_field .. " ,a.cs_uId from " ..  table_name .. " a,tbl_char b,tbl_char_static c where a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId "
	query_string = query_string .. " order by a." .. order_field
	local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)--ԭ�����а��е�����
	return res_oldObj
end
------------------------------------------------------------------------------------------
--@brief ���������������ֶΰ������������Ӫ��Ŀǰ��������������
--@param table_name:Ҫ��ѯ�ı���
--@param field_name:�ֶ���
--@param campType:Ҫ��ѯ����ӪId
local function CurrentSortByCamp(table_name,field_name,campType,sort_order)
	local query_string = "select a.cs_uId,a." .. field_name .. " from " .. table_name .. " a,tbl_char_static b,tbl_char c where a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId and b.cs_uCamp = " .. campType
	query_string = query_string .. " order by a." .. sort_order
	local _, resObj = g_DbChannelMgr:TextExecute(query_string)--Ŀǰ������
	return resObj
end
------------------------------------------------------------------------------------------
--@brief ���������������ֶΰ������������Ӫ��ԭ�е���������������
--@param table_name:Ҫ��ѯ�ı���
--@param camptable_name:������Ӫ���еĴ洢��
--@param camp_order_field:��Ӫ���б�����������ֶ�
--@param camp_updown_field:��Ӫ���б���������������ֶ�
--@param sort_field:Ҫ�������е��ֶ���
--@param campType:Ҫ��ѯ����ӪId
local function OldSortByCamp(table_name,camptable_name,camp_order_field,camp_updown_field,sort_field,campType)
	local query_string = "select a." .. camp_order_field .. ",a." .. camp_updown_field .. ",c.c_sName,d.cs_uClass,b." .. sort_field .. ",a.cs_uId from " .. camptable_name .. " a," .. table_name .. " b,tbl_char c,tbl_char_static d where a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId and c.cs_uId = d.cs_uId and d.cs_uCamp = "  .. campType 
	query_string = query_string .. " order by a." .. camp_order_field
	local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)--ԭ�����а��е�����
	return res_oldObj
end
------------------------------------------------------------------------------------------
--@brief �Ը�������Ĵ���ɱ���߻�������ؽ�������
--@param field1:�ֶ�1
--@param field2:�ֶ�2
--@param field3:�ֶ�3
local function CurrentSortFBByParam(table_name,field1,field2,field3,jifenfield)
	local query_string = "select a.cs_uId,b." .. field1 .. " + b." .. field2 .. "+ b." .. field3 .. " as sum from tbl_char a," .. table_name .. " b where a.cs_uId = b.cs_uId "
	if jifenfield ~= 0 then
		query_string = query_string .. " and b." .. jifenfield .. " = 2" 
	end
	query_string = query_string .. " order by sum desc limit 200 "
	local _, resObj = g_DbChannelMgr:TextExecute(query_string)--Ŀǰ������
	return resObj
end
------------------------------------------------------------------------------------------
--@brief ����ϴε��������
--@param tablename:Ҫɾ���ı���
local function DeleteOldInfo(tablename,campType)
	local delete_string 
	if IsNumber(campType) then
		delete_string = "delete a from " .. tablename .. " as a,tbl_char_static as b where a.cs_uId = b.cs_uId and b.cs_uCamp = " .. campType
	else
		delete_string = "delete from " .. tablename
	end
	local _, res_oldObj = g_DbChannelMgr:TextExecute(delete_string)
end
------------------------------------------------------------------------------------------
local function GetLastMinValue(table_name,field_name)
	local query_str = "select ifnull(min(" .. field_name .. "),0) from " .. table_name
	local _,res = g_DbChannelMgr:TextExecute(query_str)
	return res:GetData(0,0)
end
------------------------------------------------------------------------------------------
local StmtDef=
{
	"_SortByMoney",
	[[
		select  cm.cs_uId, cm.cm_uMoney + ifnull(dm.dm_uMoney,0) as money from tbl_char_money as cm 
		left join tbl_depot_money as dm on(cm.cs_uId = dm.cs_uId) 
		left join tbl_char c on(cm.cs_uId = c.cs_uId) 
		where cm.cs_uId = c.cs_uId  order by money desc limit 200
	]]
}
DefineSql(StmtDef,SortCharInfoSql)

--@brief ���մ������Ĳ����ڹ̶�ʱ��������
--@param table_name:Ҫ��ѯ�ı���
--@param order_field:ÿ��������������ֶ�
--@param updown_field:ÿ������������������ֶ�
--@param sort_field:Ҫ�������е��ֶ���
--@param basic_sort_field:tbl_char_basic��������ֶ�
--@param field2:�п����Ǵ���ɱҪ�����ܲ������������ֶ��е�һ�����п����ǻ������������е�����1��2��3(2v2��3v3��5v5),���������
local function CreateSortByParam(table_name,order_field,updown_field,sort_field,basic_table,basic_sort_field,field2,field3,jifenfield)
	local res_new_tbl ,res_new_set
	if field2 and field3 and jifenfield then
		res_new_set = CurrentSortFBByParam(basic_table,basic_sort_field,field2,field3,jifenfield)				--����ɱ�ܲ�������Ŀǰ������
	elseif basic_sort_field == "cm_uMoney" then
		res_new_set = SortCharInfoSql._SortByMoney:ExecStat()
	else
		local LastMinValue
		if basic_sort_field == "cfe_uPoint" then
			LastMinValue = 0
		else
			LastMinValue = GetLastMinValue(table_name,sort_field)
		end 
		res_new_set = CurrentSortByParam(basic_table,basic_sort_field,LastMinValue,field2,field3)								--Ŀǰ������
	end
	
	if res_new_set:GetRowNum() == 0 then
		return
	end
	res_new_tbl = res_new_set:GetTableSet()
	
	local res_old_set = OldSortByParam(table_name,order_field,updown_field,sort_field) --ԭ�����а��е�����
	local res_old_tbl = res_old_set:GetTableSet()
	
	local orderTbl = {}
	orderTbl[1] = {}
	orderTbl[1][1] = 1
	for i = 2, res_new_set:GetRowNum() do
		orderTbl[i] = {}
		orderTbl[i][1] = i --�����ֶ�Ϊorder
		if res_new_tbl(i,2) == res_new_tbl(i-1,2) then
			orderTbl[i][1] = orderTbl[i-1][1]
		end
	end
	
	local playerinto = {}
	for i = 1,res_new_set:GetRowNum() do
		local bool = true
		for j = 1,res_old_set:GetRowNum() do
			if(res_new_tbl(i,1) == res_old_tbl(j,6)) then --�ж�����ǲ�����ԭ�е����а�������ֹ�
				table.insert(playerinto,{res_new_tbl(i,1),res_old_tbl(j,1) - orderTbl[i][1]})
				bool = false
			end
		end
		if bool then
			table.insert(playerinto,{res_new_tbl(i,1),0})
		end
	end
	
	DeleteOldInfo(table_name)
	
	for i = 1,res_new_set:GetRowNum() do
		for j = 1,#playerinto do
			if res_new_tbl(i,1) == playerinto[j][1] then
				local query_string = "insert ignore into " ..  table_name .. " values(" .. orderTbl[i][1] .. "," .. playerinto[j][2] .. "," .. res_new_tbl(i,1) .. "," .. res_new_tbl(i,2) .. ")"
				local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)
				break
			end
		end
	end
end
------------------------------------------------------------------------------------------
--@brief ���մ������Ĳ����ڹ̶�ʱ���ڸ��ݲ�ͬ��Ӫ��������
--@param table_name:Ҫ��ѯ�ı���
--@param camptable_name:������Ӫ���еĴ洢��
--@param camp_order_field:��Ӫ���б�����������ֶ�
--@param camp_updown_field:��Ӫ���б���������������ֶ�
--@param sort_field:Ҫ�������е��ֶ���
--@param campType:Ҫ��ѯ����ӪId
local function CreateSortByCamp(table_name,camptable_name,camp_order_field,camp_updown_field,sort_field,sort_order,campType)
	local res_new_set = CurrentSortByCamp(table_name,sort_field,campType,sort_order)			--Ŀǰ������
	local res_old_set = OldSortByCamp(table_name,camptable_name,camp_order_field,camp_updown_field,sort_field,campType)		--ԭ�����а��е�����
	
	if res_new_set:GetRowNum() == 0 then
		return
	end
	
	local res_new_tbl = res_new_set:GetTableSet()
	local res_old_tbl = res_old_set:GetTableSet() 
	local orderTbl = {}
	orderTbl[1] = {}
	orderTbl[1][1] = 1
	for i = 2, res_new_set:GetRowNum() do
		orderTbl[i] = {}
		orderTbl[i][1] = i --�����ֶ�Ϊorder
		if res_new_tbl(i,2) == res_new_tbl(i-1,2) then
			orderTbl[i][1] = orderTbl[i-1][1]
		end
	end
	
	local playerinto = {}
	for i = 1,res_new_set:GetRowNum() do
		local bool = true 
		for j = 1,res_old_set:GetRowNum() do
			if(res_new_tbl(i,1) == res_old_tbl(j,6)) then --�ж�����ǲ�����ԭ�е����а�������ֹ�
				table.insert(playerinto,{res_new_tbl(i,1),res_old_tbl(j,1)-orderTbl[i][1]})
				bool = false
			end
		end
		if bool then
			table.insert(playerinto,{res_new_tbl(i,1),0})
		end
	end
	
	DeleteOldInfo(camptable_name,campType)
	for i = 1,res_new_set:GetRowNum() do
		for j = 1,table.maxn(playerinto) do
			if res_new_tbl(i,1) == playerinto[j][1] then
				local query_string = "insert ignore into " ..  camptable_name .. " values(" .. orderTbl[i][1] .. "," .. playerinto[j][2] .. "," .. res_new_tbl(i,1) .. ")"
				local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)
				break
			end
		end
	end
end
------------------------------------------------------------------------------------------
local StmtDef=
{
	--������ҵȼ���������
	"SortByLevelAndExp",
	[[
	select
		a.cs_uId,
		b.cb_uLevel,
		c.cs_uLevelExp
	from
		tbl_char a,
		tbl_char_basic b,
		tbl_char_experience c
	where
		a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId and b.cb_uLevel >= ?
		order by b.cb_uLevel desc,c.cs_uLevelExp desc limit 200
	]]
}
DefineSql(StmtDef,SortCharInfoSql)

--@brief ������ҵȼ���������
local function SortByLevelAndExp(uLevel)
	local resObj = SortCharInfoSql.SortByLevelAndExp:ExecStat(uLevel)--Ŀǰ������
	return resObj
end
--------------------------------------------------------------------------------------------
local StmtDef=
{
	--������ҵȼ���������
	"_SelectLastMinLevel",
	[[
		select ifnull(min(sl_uLevel),0) from tbl_sort_level;
	]]
}
DefineSql(StmtDef,SortCharInfoSql)

--@brief �����ϴεȼ�����͵ĵȼ�
local function GetLastMinLevel()
	local resObj = SortCharInfoSql._SelectLastMinLevel:ExecStat()
	return resObj:GetData(0,0)
end
--------------------------------------------------------------------------------------------
--@brief ���յȼ�����
local function CreateSortByLevel()
	local last_low_level = GetLastMinLevel()
	local res_new_set = SortByLevelAndExp(last_low_level)				--Ŀǰ������
	local res_old_set = OldSortByParam("tbl_sort_level","sl_uOrder","sl_uUpdown","sl_uLevel")	--ԭ�����а��е�����
	if res_new_set:GetRowNum() == 0 then
		return
	end
	local res_new_tbl = res_new_set:GetTableSet()
	local res_old_tbl = res_old_set:GetTableSet()
	
	local orderTbl = {}
	orderTbl[1] = {}
	orderTbl[1][1] = 1
	for i = 2, res_new_set:GetRowNum() do
		orderTbl[i] = {}
		orderTbl[i][1] = i --�����ֶ�Ϊorder
		if res_new_tbl(i,2) == res_new_tbl(i-1,2) and res_new_tbl(i,3) == res_new_tbl(i-1,3) then
			orderTbl[i][1] = orderTbl[i-1][1]
		end
	end
	
	local playerinto = {}
	for i = 1,res_new_set:GetRowNum() do
		local bool = true 
		for j = 1,res_old_set:GetRowNum() do
			if(res_new_tbl(i,1) == res_old_tbl(j,6)) then --�ж�����ǲ�����ԭ�е����а�������ֹ�
				table.insert(playerinto,{res_new_tbl(i,1),res_old_tbl(j,1)-orderTbl[i][1]})
				bool = false
			end
		end
		if bool then
			table.insert(playerinto,{res_new_tbl(i,1),0})
		end
	end
	DeleteOldInfo("tbl_sort_level")
	for i = 1,res_new_set:GetRowNum() do
		for j = 1,#playerinto do
			if res_new_tbl(i,1) == playerinto[j][1] then
				local query_string = "insert ignore into tbl_sort_level values(" .. orderTbl[i][1] .. "," .. playerinto[j][2] .. "," .. res_new_tbl(i,1) .. "," .. res_new_tbl(i,2) .. "," .. res_new_tbl(i,3) .. ")"
				local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)
				break
			end
		end
	end
end
------------------------------------------------------------------------------------------
local StmtDef=
{
	--��ѯ�������������Ӫ�Եȼ���������
	"_SortLevelByCamp",
	[[
		select
			a.cs_uId,
			a.sl_uLevel,
			a.sl_uLevelExp
		from
			tbl_sort_level a,
			tbl_char_static b
		where
			a.cs_uId = b.cs_uId and b.cs_uCamp = ?
			order by sl_uOrder
	]]
}
DefineSql(StmtDef,SortCharInfoSql)

--@brief �������������Ӫ�Եȼ���������
--@param campType:Ҫ��ѯ����ӪId
local function SortLevelByCamp(campType)
	local resObj = SortCharInfoSql._SortLevelByCamp:ExecStat(campType)--Ŀǰ������
	return resObj
end
------------------------------------------------------------------------------------------
--@brief ������Ӫ�Եȼ�����
--@param campType:Ҫ��ѯ����ӪId
local function CreateSortLevelByCamp(campType)
	local res_new_set = SortLevelByCamp(campType)--Ŀǰ������
	local res_old_set = OldSortByCamp("tbl_sort_level","tbl_sort_level_by_camp","slbc_uOrder","slbc_uUpdown","sl_uLevel",campType)--ԭ�����а��е�����
	if res_new_set:GetRowNum() == 0 then
		return
	end
	local res_new_tbl = res_new_set:GetTableSet()
	local res_old_tbl = res_old_set:GetTableSet()
	
	local orderTbl = {}
	orderTbl[1] = {}
	orderTbl[1][1] = 1
	for i = 2, res_new_set:GetRowNum() do
		orderTbl[i] = {}
		orderTbl[i][1] = i --�����ֶ�Ϊorder
		if res_new_tbl(i,2) == res_new_tbl(i-1,2) and res_new_tbl(i,3) == res_new_tbl(i-1,3) then
			orderTbl[i][1] = orderTbl[i-1][1]
		end
	end
	
	local playerinto = {}
	for i = 1,res_new_set:GetRowNum() do
		local bool = true 
		for j = 1,res_old_set:GetRowNum() do
			if(res_new_tbl(i,1) == res_old_tbl(j,6)) then --�ж�����ǲ�����ԭ�е����а�������ֹ�
				table.insert(playerinto,{res_new_tbl(i,1),res_old_tbl(j,1)-orderTbl[i][1]})
				bool = false 
			end
		end
		if bool then
			table.insert(playerinto,{res_new_tbl(i,1),0})
		end
	end

	DeleteOldInfo("tbl_sort_level_by_camp",campType)
	for i = 1,res_new_set:GetRowNum() do
		for j = 1,table.maxn(playerinto) do
			if res_new_tbl(i,1) == playerinto[j][1] then
				local query_string = "insert ignore into tbl_sort_level_by_camp values(" .. orderTbl[i][1] .. "," .. playerinto[j][2] .. "," .. res_new_tbl(i,1) .. ")"
				local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)
				break
			end
		end
	end
end
---------------------------------------[������Ϣ]---------------------------------------------------
--@brief ͨ���������ı������ֶ����鿴����������ҽ�ɫId������
--@param playerId:Ҫ��ѯ�����Id
--@param table_name:Ҫ��ѯ�ı���
--@param order_field:�����ֶ�
--@param updown_field:���������ֶ�
--@param sort_field:Ҫ�������е��ֶ���
local function PlayerSortByParam(playerId,table_name,order_field,updown_field,sort_field)
	local query_string = "select a." .. order_field .. ",a." .. updown_field .. ",c.cs_uClass,a." .. sort_field .. " from " .. table_name .. " a,tbl_char b,tbl_char_static c where a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId and a.cs_uId = " .. playerId
	local _, res_oldObj = g_DbChannelMgr:TextExecute(query_string)
	return res_oldObj
end
------------------------------------------------------------------------------------------------------
--@brief ��������鿴
--@param playerId��Ҫ�鿴�����Id
local function PlayerSortInfo(playerId)
	local PlayerSortInfo = {}
	--��ҵȼ����а�
	local PlayerSortByLevel = PlayerSortByParam(playerId,"tbl_sort_level","sl_uOrder","sl_uUpdown","sl_uLevel")
	--��Ҳ��󶨽�Ǯ���а�
	local PlayerSortByMoney = PlayerSortByParam(playerId,"tbl_sort_money","sm_uOrder","sm_uUpdown","sm_uMoney")
	--��ɫ�����������а�
	local PlayerSortByDeadTimes = PlayerSortByParam(playerId,"tbl_sort_deadtimes","sd_uOrder","sd_uUpdown","sd_uDeadTimes")
	--��ɫɱ���޸������а�
	local PlayerSortByKillNpcCount = PlayerSortByParam(playerId,"tbl_sort_kill_npc_count","sknc_uOrder","sknc_uUpdown","sknc_uKillNpcCount")
	--��ɫɱ�˸������а�
	local PlayerSortByKillPlayerCount = PlayerSortByParam(playerId,"tbl_sort_kill_player_count","skpc_uOrder","skpc_uUpdown","skpc_uKillPlayerCount")
	--��ɫ����ʱ���ۻ����а�
	local PlayerSortOnTimeTotal = PlayerSortByParam(playerId,"tbl_sort_player_onlinetime","spo_uOrder","spo_uUpdown","spo_uPlayerOnTimeTotal")
	--����ɱ�ܲ�����������
	local PlayerSortDaTaoJoinTimes = PlayerSortByParam(playerId,"tbl_sort_dataosha_all_jointimes","sdaj_uOrder","sdaj_uUpdown","sdaj_uJoinTimes")
	--����ɱ��ʤ����������
	local PlayerSortDaTaoWinTimes = PlayerSortByParam(playerId,"tbl_sort_dataosha_all_wintimes","sdaw_uOrder","sdaw_uUpdown","sdaw_uWinTimes")
	--ս�������а�
	local PlayerFightEvaluation = PlayerSortByParam(playerId,"tbl_sort_fight_evaluation","sfe_uOrder","sfe_uUpdown","sfe_uPoint")	
	
	--����ɱ�ܻ�������
	local PlayerSortDaTaoShaPoint = PlayerSortByParam(playerId,"tbl_sort_dataosha_point","sdp_uOrder","sdp_uUpdown","sdp_uPoint")
	--��ҵȼ����а�
	if nil ~= PlayerSortByLevel and PlayerSortByLevel:GetRowNum() > 0 then
		for i = 1,PlayerSortByLevel:GetRowNum() do
			table.insert(PlayerSortInfo,{PlayerSortByLevel:GetData(i-1,0),PlayerSortByLevel:GetData(i-1,1),"�ȼ�",PlayerSortByLevel:GetData(i-1,2),PlayerSortByLevel:GetData(i-1,3)})
		end
	end
	--��Ҳ��󶨽�Ǯ���а�
	if nil ~= PlayerSortByMoney and PlayerSortByMoney:GetRowNum() > 0 then
		for i = 1,PlayerSortByMoney:GetRowNum() do
			table.insert(PlayerSortInfo,{PlayerSortByMoney:GetData(i-1,0),PlayerSortByMoney:GetData(i-1,1),"�Ƹ�",PlayerSortByMoney:GetData(i-1,2),PlayerSortByMoney:GetData(i-1,3)})
		end
	end
	--��������������а�
	if nil ~= PlayerSortByDeadTimes and PlayerSortByDeadTimes:GetRowNum() > 0 then
		for i = 1,PlayerSortByDeadTimes:GetRowNum() do
			table.insert(PlayerSortInfo,{PlayerSortByDeadTimes:GetData(i-1,0),PlayerSortByDeadTimes:GetData(i-1,1),"����",PlayerSortByDeadTimes:GetData(i-1,2),PlayerSortByDeadTimes:GetData(i-1,3)})
		end
	end
	--���ɱ�����а�
	if nil ~= PlayerSortByKillNpcCount and PlayerSortByKillNpcCount:GetRowNum() > 0 then
		for i = 1,PlayerSortByKillNpcCount:GetRowNum() do
			table.insert(PlayerSortInfo,{PlayerSortByKillNpcCount:GetData(i-1,0),PlayerSortByKillNpcCount:GetData(i-1,1),"�ۼ�ɱ��",PlayerSortByKillNpcCount:GetData(i-1,2),PlayerSortByKillNpcCount:GetData(i-1,3)})
		end
	end
	--���ɱ�����а�
	if nil ~= PlayerSortByKillPlayerCount and PlayerSortByKillPlayerCount:GetRowNum() > 0 then
		for i = 1,PlayerSortByKillPlayerCount:GetRowNum() do
			table.insert(PlayerSortInfo,{PlayerSortByKillPlayerCount:GetData(i-1,0),PlayerSortByKillPlayerCount:GetData(i-1,1),"ɱ��",PlayerSortByKillPlayerCount:GetData(i-1,2),PlayerSortByKillPlayerCount:GetData(i-1,3)})
		end
	end
	--�������ʱ���ۻ����а�
	if nil ~= PlayerSortOnTimeTotal and PlayerSortOnTimeTotal:GetRowNum() > 0 then
		for i = 1,PlayerSortOnTimeTotal:GetRowNum() do
			table.insert(PlayerSortInfo, {PlayerSortOnTimeTotal:GetData(i-1,0),PlayerSortOnTimeTotal:GetData(i-1,1),"����ʱ��",PlayerSortOnTimeTotal:GetData(i-1,2),PlayerSortOnTimeTotal:GetData(i-1,3)})
		end
	end
	--����ɱ��������
	if nil ~= PlayerSortDaTaoShaPoint and PlayerSortDaTaoShaPoint:GetRowNum() > 0 then
		for i = 1,PlayerSortDaTaoShaPoint:GetRowNum() do
			table.insert(PlayerSortInfo, {PlayerSortDaTaoShaPoint:GetData(i-1,0),PlayerSortDaTaoShaPoint:GetData(i-1,1),"�Ƕ����ܻ���",PlayerSortDaTaoShaPoint:GetData(i-1,2),PlayerSortDaTaoShaPoint:GetData(i-1,3)})
		end
	end
	--����ɱ�ܲ�����������
	if nil ~= PlayerSortDaTaoJoinTimes and PlayerSortDaTaoJoinTimes:GetRowNum() > 0 then
		for i = 1,PlayerSortDaTaoJoinTimes:GetRowNum() do
			table.insert(PlayerSortInfo, {PlayerSortDaTaoJoinTimes:GetData(i-1,0),PlayerSortDaTaoJoinTimes:GetData(i-1,1),"�Ƕ����ܲ�������",PlayerSortDaTaoJoinTimes:GetData(i-1,2),PlayerSortDaTaoJoinTimes:GetData(i-1,3)})
		end
	end
	--����ɱ��ʤ����������
	if nil ~= PlayerSortDaTaoWinTimes and PlayerSortDaTaoWinTimes:GetRowNum() > 0 then
		for i = 1,PlayerSortDaTaoWinTimes:GetRowNum() do
			table.insert(PlayerSortInfo, {PlayerSortDaTaoWinTimes:GetData(i-1,0),PlayerSortDaTaoWinTimes:GetData(i-1,1),"�Ƕ�����ʤ������",PlayerSortDaTaoWinTimes:GetData(i-1,2),PlayerSortDaTaoWinTimes:GetData(i-1,3)})
		end
	end
	
	--ս��������
	if nil ~= PlayerFightEvaluation and PlayerFightEvaluation:GetRowNum() > 0 then
		for i = 1,PlayerFightEvaluation:GetRowNum() do
			table.insert(PlayerSortInfo, {PlayerFightEvaluation:GetData(i-1,0),PlayerFightEvaluation:GetData(i-1,1),"ս����������",PlayerFightEvaluation:GetData(i-1,2),string.format("%.2f",PlayerFightEvaluation:GetData(i-1,3))})
		end
	end
	
	return PlayerSortInfo
end
------------------------------------------------------------------------------------------
--@brief ���ݿͻ��˴�����������������ȼ����ͽ�������
function SortCharInfoDB.GetSortList(data)
	local sType = data["sType"]
	local sName = data["sName"]
	local campType = data["campType"]
	local playerId = data["playerId"]
	local SortTongInfoDB = RequireDbBox("SortTongInfoDB")
	
	if("����" == sType) then
		if("�������" == sName) then
			return PlayerSortInfo(playerId)
		elseif("�ȼ���" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_level","sl_uOrder","sl_uUpdown","sl_uLevel")
			else
				return OldSortByCamp("tbl_sort_level","tbl_sort_level_by_camp","slbc_uOrder","slbc_uUpdown","sl_uLevel",campType)
			end
		elseif("�Ƹ���" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_money","sm_uOrder","sm_uUpdown","sm_uMoney")
			else
				return OldSortByCamp("tbl_sort_money","tbl_sort_money_by_camp","smbc_uOrder","smbc_uUpdown","sm_uMoney",campType)
			end
		elseif("������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_deadtimes","sd_uOrder","sd_uUpdown","sd_uDeadTimes")
			else
				return OldSortByCamp("tbl_sort_deadtimes","tbl_sort_deadtimes_by_camp","sdbc_uOrder","sdbc_uUpdown","sd_uDeadTimes",campType)
			end
		elseif("ɱ�˰�" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_kill_player_count","skpc_uOrder","skpc_uUpdown","skpc_uKillPlayerCount")
			else
				return OldSortByCamp("tbl_sort_kill_player_count","tbl_sort_kill_player_count_by_camp","skpcbc_uOrder","skpcbc_uUpdown","skpc_uKillPlayerCount",campType)
			end
		elseif("�ۼ�ɱ�ְ�" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_kill_npc_count","sknc_uOrder","sknc_uUpdown","sknc_uKillNpcCount")
			else
				return OldSortByCamp("tbl_sort_kill_npc_count","tbl_sort_kill_npc_count_by_camp","skncbc_uOrder","skncbc_uUpdown","sknc_uKillNpcCount",campType)
			end
		elseif("����ʱ���" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_player_onlinetime","spo_uOrder","spo_uUpdown","spo_uPlayerOnTimeTotal")
			else
				return OldSortByCamp("tbl_sort_player_onlinetime","tbl_sort_player_onlinetime_by_camp","spobc_uOrder","spobc_uUpdown","spo_uPlayerOnTimeTotal",campType)
			end
		elseif("ս�������ְ�" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_fight_evaluation","sfe_uOrder","sfe_uUpdown","sfe_uPoint")
			else
				return OldSortByCamp("tbl_sort_fight_evaluation","tbl_sort_fight_evaluation_by_camp","sfebc_uOrder","sfebc_uUpdown","sfe_uPoint",campType)
			end
		elseif("���������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_char_resource","scr_uOrder","scr_uUpdown","scr_uResource")
			else
				return OldSortByCamp("tbl_sort_char_resource","tbl_sort_char_resource_by_camp","scrbc_uOrder","scrbc_uUpdown","scr_uResource",campType)
			end
		elseif("��Դ������ɱ�˰�" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_resource_kill_num","srkn_uOrder","srkn_uUpdown","srkn_uKillNum")
			else
				return OldSortByCamp("tbl_sort_resource_kill_num","tbl_sort_resource_kill_num_by_camp","srknbc_uOrder","srknbc_uUpdown","srkn_uKillNum",campType)
			end
		elseif("��һ�ɱ����������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_char_kill_boss_num","sckbn_uOrder","sckbn_uUpdown","sckbn_uKillNum")
			else
				return OldSortByCamp("tbl_sort_char_kill_boss_num","tbl_sort_char_kill_boss_num_by_camp","sckbnbc_uOrder","sckbnbc_uUpdown","sckbn_uKillNum",campType)
			end
		end
	elseif("�淨" == sType) then
		if("�����ܲ���������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_jifensai_join_times","sjjt_uOrder","sjjt_uUpdown","sjjt_uJoinTimes")
			else
				return OldSortByCamp("tbl_sort_jifensai_join_times","tbl_sort_jifensai_join_times_by_camp","sjjtbc_uOrder","sjjtbc_uUpdown","sjjt_uJoinTimes",campType)
			end
		elseif("������ʤ��������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_jifensai_wintimes","sjw_uOrder","sjw_uUpdown","sjw_uWinTimes")
			else
				return OldSortByCamp("tbl_sort_jifensai_wintimes","tbl_sort_jifensai_wintimes_by_camp","sjwbc_uOrder","sjwbc_uUpdown","sjw_uWinTimes",campType)
			end
		elseif("����ɱ��������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_tong_kill_num","stkn_uOrder","stkn_uUpdown","stkn_uKillNum")
			else
				return OldSortByCamp("tbl_sort_tong_kill_num","tbl_sort_tong_kill_num_by_camp","stknbc_uOrder","stknbc_uUpdown","stkn_uKillNum",campType)
			end
		elseif("����ɱ�ܲ���������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_dataosha_all_jointimes","sdaj_uOrder","sdaj_uUpdown","sdaj_uJoinTimes")
			else
				return OldSortByCamp("tbl_sort_dataosha_all_jointimes","tbl_sort_dataosha_all_jointimes_by_camp","sdajbc_uOrder","sdajbc_uUpdown","sdaj_uJoinTimes",campType) 
			end
		elseif("����ɱ��ʤ��������" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_dataosha_all_wintimes","sdaw_uOrder","sdaw_uUpdown","sdaw_uWinTimes")
			else
				return OldSortByCamp("tbl_sort_dataosha_all_wintimes","tbl_sort_dataosha_all_wintimes_by_camp","sdawbc_uOrder","sdawbc_uUpdown","sdaw_uWinTimes",campType)
			end
		elseif("����ɱ�ܻ��ְ�" == sName) then
			if(4 == campType) then
				return OldSortByParam("tbl_sort_dataosha_point","sdp_uOrder","sdp_uUpdown","sdp_uPoint")
			else
				return OldSortByCamp("tbl_sort_dataosha_point","tbl_sort_dataosha_point_by_camp","sdpbc_uOrder","sdpbc_uUpdown","sdp_uPoint",campType)
			end
		end
	elseif("Ӷ��С��" == sType) then
		if("Ӷ��С�ӵȼ���" == sName) then
			if(4 == campType) then
				return SortTongInfoDB.OldSortTongByParam("tbl_sort_tong_level","stl_uOrder","stl_uUpdown","stl_uLevel")
			else
				return SortTongInfoDB.OldTongSortByCamp("tbl_sort_tong_level","tbl_sort_tong_level_by_camp","stlbc_uOrder","stlbc_uUpdown","stl_uLevel",campType)
			end
		elseif("Ӷ��С��������" == sName) then
			if(4 == campType) then
				return SortTongInfoDB.OldSortTongByParam("tbl_sort_tong_exploit","ste_uOrder","ste_uUpdown","ste_uExploit")
			else
				return SortTongInfoDB.OldTongSortByCamp("tbl_sort_tong_exploit","tbl_sort_tong_exploit_by_camp","stebc_uOrder","stebc_uUpdown","ste_uExploit",campType)
			end
		elseif("Ӷ��С�Ӿ��ʰ�" == sName) then
			if(4 == campType) then
				return SortTongInfoDB.OldSortTongByParam("tbl_sort_tong_resource","str_uOrder","str_uUpdown","str_uResource")
			else
				return SortTongInfoDB.OldTongSortByCamp("tbl_sort_tong_resource","tbl_sort_tong_resource_by_camp","strbc_uOrder","strbc_uUpdown","str_uResource",campType)
			end
		elseif("Ӷ��С���ʽ��" == sName) then
			if(4 == campType) then
				return SortTongInfoDB.OldSortTongByParam("tbl_sort_tong_money","stm_uOrder","stm_uUpdown","stm_uMoney")
			else
				return SortTongInfoDB.OldTongSortByCamp("tbl_sort_tong_money","tbl_sort_tong_money_by_camp","stmbc_uOrder","stmbc_uUpdown","stm_uMoney",campType)	
			end
		elseif("Ӷ��С�ӻ�ɱ����������" == sName) then
			if(4 == campType) then
				return SortTongInfoDB.OldSortTongByParam("tbl_sort_tong_kill_boss_num","stkbn_uOrder","stkbn_uUpdown","stkbn_uKillNum")
			else
				return SortTongInfoDB.OldTongSortByCamp("tbl_sort_tong_kill_boss_num","tbl_sort_tong_kill_boss_num_by_camp","stkbnbc_uOrder","stkbnbc_uUpdown","stkbn_uKillNum",campType)
			end
		elseif("��Դ��ռ�������" == sName) then
			if(4 == campType) then
				return SortTongInfoDB.OldSortTongByParam("tbl_sort_tong_resource_occupy_times","strot_uOrder","strot_uUpdown","strot_uOccupyTimes")
			else
				return SortTongInfoDB.OldTongSortByCamp("tbl_sort_tong_resource_occupy_times","tbl_sort_tong_resource_occupy_times_by_camp","strotbc_uOrder","strotbc_uUpdown","strot_uOccupyTimes",campType)
			end
		end
	end
end
------------------------------------------------------------------------------------------
function SortCharInfoDB.CreateSortCharInfoFunc1(data)
	--�����ȼ�����
	CreateSortByLevel()
	--�����Բ��󶨽�Ǯ����
	CreateSortByParam("tbl_sort_money","sm_uOrder","sm_uUpdown","sm_uMoney","tbl_char_money","cm_uMoney")
	--������ɫ�����������а�
	CreateSortByParam("tbl_sort_deadtimes","sd_uOrder","sd_uUpdown","sd_uDeadTimes","tbl_char_fight_info","cfi_uDeadTimes")
	--����ɱ�������а�
	CreateSortByParam("tbl_sort_kill_npc_count","sknc_uOrder","sknc_uUpdown","sknc_uKillNpcCount","tbl_char_fight_info","cfi_uKillNpcCount")
end
------------------------------------------------------------------------------------------
function SortCharInfoDB.CreateSortCharInfoFunc2(data)
	--����ɱ�����а�
	CreateSortByParam("tbl_sort_kill_player_count","skpc_uOrder","skpc_uUpdown","skpc_uKillPlayerCount","tbl_char_fight_info","cfi_uKillPlayerCount")
	--������ɫ����ʱ���ۻ����а�
	CreateSortByParam("tbl_sort_player_onlinetime","spo_uOrder","spo_uUpdown","spo_uPlayerOnTimeTotal","tbl_char_fight_info","cfi_uPlayerOnTimeTotal")
	--�����Ƕ����ܲ������������а�
	CreateSortByParam("tbl_sort_dataosha_all_jointimes","sdaj_uOrder","sdaj_uUpdown","sdaj_uJoinTimes","tbl_char_dataoshapoint","cs_uWinNum","cs_uLoseNum","cs_uRunNum",0)
	--�����Ƕ�����ʤ���������а�
	CreateSortByParam("tbl_sort_dataosha_all_wintimes","sdaw_uOrder","sdaw_uUpdown","sdaw_uWinTimes","tbl_char_dataoshapoint","cs_uWinNum")
end
------------------------------------------------------------------------------------------
function SortCharInfoDB.CreateSortCharInfoFunc3(data)
	--�����Ƕ����������а�
	CreateSortByParam("tbl_sort_dataosha_point","sdp_uOrder","sdp_uUpdown","sdp_uPoint","tbl_char_dataoshapoint","cs_udataoshapoint")
	--����ս�������а�
	CreateSortByParam("tbl_sort_fight_evaluation","sfe_uOrder","sfe_uUpdown","sfe_uPoint","tbl_char_fighting_evaluation","cfe_uPoint")	
	--�������ɱ��������
	CreateSortByParam("tbl_sort_tong_kill_num","stkn_uOrder","stkn_uUpdown","stkn_uKillNum","tbl_tong_jfs","tj_uNum")
	--��Ҿ����������а�
	CreateSortByParam("tbl_sort_char_resource","scr_uOrder","scr_uUpdown","scr_uResource","tbl_tong_char_other","tco_uNum","tco_uTypeId",1)
end
------------------------------------------------------------------------------------------
function SortCharInfoDB.CreateSortCharInfoFunc4(data)
	--����������ܲ����������а�
	CreateSortByParam("tbl_sort_jifensai_join_times","sjjt_uOrder","sjjt_uUpdown","sjjt_uJoinTimes","tbl_char_jifensaipoint","cs_uWinNum","cs_uLoseNum","cs_uRunNum","cs_uType")
	--�������ʤ��������
	CreateSortByParam("tbl_sort_jifensai_wintimes","sjw_uOrder","sjw_uUpdown","sjw_uWinTimes","tbl_char_jifensaipoint","cs_uWinNum","cs_uType",2)
	--�����Դ����ɱ�����а�
	CreateSortByParam("tbl_sort_resource_kill_num","srkn_uOrder","srkn_uUpdown","srkn_uKillNum","tbl_tong_char_other","tco_uNum","tco_uTypeId",2)
	--��һ�ɱ�����������а�
	CreateSortByParam("tbl_sort_char_kill_boss_num","sckbn_uOrder","sckbn_uUpdown","sckbn_uKillNum","tbl_tong_char_boss","tcb_uNum")
end
------------------------------------------------------------------------------------------
function SortCharInfoDB.CreateSortCharInfoFunc5(data)
	local uCamp = data["uCamp"]
	--������ӪΪuCamp�ĵȼ�����
	CreateSortLevelByCamp(uCamp)
	--������ӪΪuCamp�Ĳ��󶨽�Ǯ���а�
	CreateSortByCamp("tbl_sort_money","tbl_sort_money_by_camp","smbc_uOrder","smbc_uUpdown","sm_uMoney","sm_uOrder",uCamp) 
	--������ӪΪuCamp�Ľ�ɫ������������
	CreateSortByCamp("tbl_sort_deadtimes","tbl_sort_deadtimes_by_camp","sdbc_uOrder","sdbc_uUpdown","sd_uDeadTimes","sd_uOrder",uCamp)
	--������ӪΪuCamp��ɱ���ް�
	CreateSortByCamp("tbl_sort_kill_npc_count","tbl_sort_kill_npc_count_by_camp","skncbc_uOrder","skncbc_uUpdown","sknc_uKillNpcCount","sknc_uOrder",uCamp)
	--������ӪΪuCamp��ɱ�˰�
	CreateSortByCamp("tbl_sort_kill_player_count","tbl_sort_kill_player_count_by_camp","skpcbc_uOrder","skpcbc_uUpdown","skpc_uKillPlayerCount","skpc_uOrder",uCamp)
	--������ӪΪuCamp�Ľ�ɫ����ʱ���ۻ����а�
	CreateSortByCamp("tbl_sort_player_onlinetime","tbl_sort_player_onlinetime_by_camp","spobc_uOrder","spobc_uUpdown","spo_uPlayerOnTimeTotal","spo_uOrder",uCamp)
end
------------------------------------------------------------------------------------------
function SortCharInfoDB.CreateSortCharInfoFunc6(data)
	local uCamp = data["uCamp"]
	--������ӪΪuCamp�ĽǶ����ܲ������������а�
	CreateSortByCamp("tbl_sort_dataosha_all_jointimes","tbl_sort_dataosha_all_jointimes_by_camp","sdajbc_uOrder","sdajbc_uUpdown","sdaj_uJoinTimes","sdaj_uOrder",uCamp)
	--������ӪΪuCamp�ĽǶ�����ʤ�����������а�
	CreateSortByCamp("tbl_sort_dataosha_all_wintimes","tbl_sort_dataosha_all_wintimes_by_camp","sdawbc_uOrder","sdawbc_uUpdown","sdaw_uWinTimes","sdaw_uOrder",uCamp)		
	--������ӪΪuCamp��������Ϊ3v3�İ���������ܲ����������а�
	CreateSortByCamp("tbl_sort_jifensai_join_times","tbl_sort_jifensai_join_times_by_camp","sjjtbc_uOrder","sjjtbc_uUpdown","sjjt_uJoinTimes","sjjt_uOrder",uCamp)
	--������ӪΪuCamp�ĽǶ������ְ����а�
	CreateSortByCamp("tbl_sort_dataosha_point","tbl_sort_dataosha_point_by_camp","sdpbc_uOrder","sdpbc_uUpdown","sdp_uPoint","sdp_uOrder",uCamp)		
	--������ӪΪuCamp��ս���������а�
	CreateSortByCamp("tbl_sort_fight_evaluation","tbl_sort_fight_evaluation_by_camp","sfebc_uOrder","sfebc_uUpdown","sfe_uPoint","sfe_uOrder",uCamp)	
	--������ӪΪuCamp�ľ����������а�
	CreateSortByCamp("tbl_sort_char_resource","tbl_sort_char_resource_by_camp","scrbc_uOrder","scrbc_uUpdown","scr_uResource","scr_uOrder",uCamp)	
	--������ӪΪuCamp������ʤ���������а�
	CreateSortByCamp("tbl_sort_jifensai_wintimes","tbl_sort_jifensai_wintimes_by_camp","sjwbc_uOrder","sjwbc_uUpdown","sjw_uWinTimes","sjw_uOrder",uCamp)	
	--������ӪΪuCamp������ɱ���������а�
	CreateSortByCamp("tbl_sort_tong_kill_num","tbl_sort_tong_kill_num_by_camp","stknbc_uOrder","stknbc_uUpdown","stkn_uKillNum","stkn_uOrder",uCamp)	
	--������ӪΪuCamp����Դ����ɱ�����а�
	CreateSortByCamp("tbl_sort_resource_kill_num","tbl_sort_resource_kill_num_by_camp","srknbc_uOrder","srknbc_uUpdown","srkn_uKillNum","srkn_uOrder",uCamp)	
	--������ӪΪuCamp�Ļ�ɱ�����������а�
	CreateSortByCamp("tbl_sort_char_kill_boss_num","tbl_sort_char_kill_boss_num_by_camp","sckbnbc_uOrder","sckbnbc_uUpdown","sckbn_uKillNum","sckbn_uOrder",uCamp)	
end


SetDbLocalFuncType(SortCharInfoDB.GetSortList)

return SortCharInfoDB


