gac_gas_require "activity/quest/QuestMgrInc"
gas_require "world/player/CreateServerPlayerInc"
gac_gas_require "item/store_room_cfg/StoreRoomCfg"
gas_require "message/ServerMsg"
cfg_load "item/Mercenary_Quest_Server"
--cfg_load "player/MercenaryLevel_Common"
cfg_load "player/LevelExp_Common"
cfg_load "tong/TongLevelModulus_Server"
cfg_load "tong/TongStationLevelModulus_Server"
cfg_load "skill/SkillPart_Common"
cfg_load "item/TongProdItem_Common"
gac_gas_require "scene_mgr/SceneCfg"
gac_gas_require "relation/tong/TongMgr"
gac_gas_require "framework/common/CMoney"
gac_gas_require "activity/quest/MercenaryLevelCfg"
gac_gas_require "skill/SkillCommon"

local Scene_Common = Scene_Common
local SkillPart_Common = SkillPart_Common
local Quest_Common = Quest_Common
local g_MercenaryLevelTbl = g_MercenaryLevelTbl
local g_QuestNeedMgr = g_QuestNeedMgr
local g_QuestPropMgr = g_QuestPropMgr
local g_AreaQuestMgr = g_AreaQuestMgr
local g_RepeatQuestMgr = g_RepeatQuestMgr
local g_MasterStrokeQuestMgr = g_MasterStrokeQuestMgr
local g_LoopQuestMgr = g_LoopQuestMgr
local LevelExp_Common = LevelExp_Common
--local MercenaryLevel_Common = MercenaryLevel_Common
local Mercenary_Quest_Server = Mercenary_Quest_Server
local g_ItemInfoMgr = CItemInfoMgr:new()
local g_WhereGiveQuestMgr = g_WhereGiveQuestMgr
local g_MoneyMgr = CMoney:new()
local TongLevelModulus_Server = TongLevelModulus_Server
local TongStationLevelModulus_Server = TongStationLevelModulus_Server
local event_type_tbl = event_type_tbl
local QuestState = {
	init	= 1,
	failure	= 2,
	finish	= 3
}

local stateTbl = {
	["��װ����һ������״̬"] = {3, "all"},
	["���������buff"] = {3, "exp"},
	["��װ���һ��״̬"] = {5, "all"},
	["˫�����߷�"] = {2, "item"},
}

local g_ItemQuestMgr = g_ItemQuestMgr
--local g_QuestAwardMgr = g_QuestAwardMgr
local g_VarQuestMgr = g_VarQuestMgr
local os = os
local g_StoreRoomIndex = g_StoreRoomIndex
local CPos = CPos
local g_KillNpcQuestMgr = g_KillNpcQuestMgr
local loadstring = loadstring
local ECamp = ECamp
local LogErr = LogErr
local g_AllMercenaryQuestMgr = g_AllMercenaryQuestMgr
local g_DareMercenaryQuestMgr = g_DareMercenaryQuestMgr
local g_DareQuestMgr = g_DareQuestMgr
local g_ActionQuestMgr = g_ActionQuestMgr
--local GetHDProcessTime = GetHDProcessTime
--Renton:�����������ͱ���
local g_TongMgr = g_TongMgr or CTongMgr:new()
local FightSkillKind = FightSkillKind
--local FightSkill = CreateDbBox(...)
local GetCfgTransformValue = GetCfgTransformValue
local GetStaticTextServer = GetStaticTextServer
local TongProdItem_Common = TongProdItem_Common


local g_TestRevisionMaxLevel = g_TestRevisionMaxLevel --���԰汾���ȼ�

local StmtContainer = class()

local ShareArea = 38    -- ����������������Χ  2009-7-16

local StmtDef = 
{
	"_AddNewQuest",
	[[
		insert ignore into tbl_quest(q_sName,cs_uId,q_state,q_tAcceptTime,q_uExpMultiple) values ( ?, ?, 1, ?, ? )
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = {
	"_AddNewQuestVar",
	[[
		insert ignore into tbl_quest_var (q_sName,cs_uId,qv_name) values(?,?,?)
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef = 
{
	"_ClearQuest",
	[[
		delete from tbl_quest where q_sName = ? and cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = {
	"_DeleteAllQuestVar",
	[[
		delete from tbl_quest_var where q_sName = ? and cs_uId = ? 
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef = {
	"_GetQuestAcceptTime",
	[[
		select q_tAcceptTime from tbl_quest where q_sName=? and cs_uId=?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_GetQuestState",
	[[
		select
			q_state,q_uLimitTime
		from
			tbl_quest
		where
			cs_uId = ? and q_sName = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_GetQuestStateFinishTime",
	[[
		select
			q_state,q_tFinishTime
		from
			tbl_quest
		where
			cs_uId = ? and q_sName = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_GetDoingQuests",
	[[
		select q_sName 
		from tbl_quest
		where cs_uId = ? and q_state = 1
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_GetDoingQuestNum",
	[[
		select q_sName 
		from tbl_quest
		where cs_uId = ? and (q_state=1 or q_state=2)
	]]
}
DefineSql( StmtDef, StmtContainer )
 
local StmtDef = {
	"_GetQuestExpMultiple",
	[[
		select q_uExpMultiple from tbl_quest where cs_uId = ? and q_sName = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_UpdateQuestState",
	[[
		update tbl_quest set q_state = ?,q_tFinishTime = ? where cs_uId = ? and q_sName = ?  
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_AddCharFinishQuestNum",
	[[
		update tbl_char_quest_finish_num set cqfn_uFinishNum = cqfn_uFinishNum+? where cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_InsertCharFinishQuestNum",
	[[
		insert into tbl_char_quest_finish_num (cs_uId,cqfn_uFinishNum) values(?,?)
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_SelectCharFinishQuestNum",
	[[
		select cqfn_uFinishNum from tbl_char_quest_finish_num where cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_UpdateQuestTime",
	[[
		update tbl_quest set q_tAcceptTime = ?, q_uLimitTime = 0 where cs_uId = ? and q_sName = ?  
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_SelectQuestVarNum",
	[[
		select qv_num from tbl_quest_var where q_sName = ? and qv_name = ? and cs_uId = ? 
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef = {
	"_SelectQNameVNameVNum",
	[[
		select qv_name,qv_num from tbl_quest_var where  q_sName=? and cs_uId = ? 
	]]
}
DefineSql( StmtDef, StmtContainer)

--update tbl_quest_var set qv_num = qv_num + ? where q_sName = ? and qv_name = ? and cs_uId = ? and qv_num + ? <= ?
local StmtDef = {
	"_AddQuestVarNum",
	[[
		update 
			tbl_quest_var as qv,tbl_quest as qs 
		set 
			qv.qv_num = qv.qv_num + ?
		where
			qv.q_sName = qs.q_sName and qv.cs_uId = qs.cs_uId and qs.q_state = 1 and qv.cs_uId = ? and qv.q_sName = ?  and qv.qv_name = ? and qv.qv_num + ? <= ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef = {
	"_SetQuestVarNum",
	[[
		update 
			tbl_quest_var as qv,tbl_quest as qs 
		set 
			qv.qv_num = ?
		where
			qv.q_sName = qs.q_sName and qv.cs_uId = qs.cs_uId and qs.q_state = 1 and qv.cs_uId = ? and qv.q_sName = ?  and qv.qv_name = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef = {
	"_DeleteQuestVar",
	[[
		delete from tbl_quest_var where q_sName = ? and cs_uId = ? and qv_name = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef = {
	"_GiveUpQuestSql",
	[[
		delete from tbl_quest where q_sName = ? and cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef =
{
	"_GetPlayerLevel",
	"select cb_uLevel from tbl_char_basic where cs_uId = ? "
}
DefineSql( StmtDef , StmtContainer )
------------------------------------------

local StmtDef = {
	"_GetAllQuestVar",
	[[
		select q_sName, qv_name, qv_num 
		from tbl_quest_var
		where cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_GetAllQuestSql",
	[[
		select q_sName, q_tAcceptTime, q_state, q_uLimitTime from tbl_quest where cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"_GetNowQuestSql",
	[[
		select 
			s.q_sName, v.qv_name, v.qv_num
		from 
			tbl_quest as s, tbl_quest_var as v
		where 
			s.cs_uId = v.cs_uId and s.q_sName = v.q_sName
			and s.cs_uId = ? and s.q_state= 1
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = 
{
	"_GetPlayerDoingQstNameByState",
	[[
		select q_sName from tbl_quest where q_state = ? and cs_uId = ?
	]]
	
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = 
{
	"GetQuestLimit",
	[[
		select
			ql_Count, unix_timestamp(ql_CountTime), unix_timestamp(ql_CDTime)
		from tbl_quest_limit
		where q_sName = ? and cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = 
{
	"UpdateQuestLimit",
	[[
		update
			tbl_quest_limit
		set
			ql_Count = ?,
			ql_CountTime = from_unixtime(?),
			ql_CDTime = from_unixtime(?)
		where
			q_sName = ? and cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = 
{
	"InsertQuestLimit",
	[[
		insert into tbl_quest_limit
			(q_sName, cs_uId, ql_Count, ql_CountTime, ql_CDTime)
		values
			(?, ?, ?, from_unixtime(?), from_unixtime(?))
	]]
}
DefineSql( StmtDef, StmtContainer )

local StmtDef = {
	"DeleteQuestLimit",
	[[
		delete from tbl_quest_limit where q_sName = ? and cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef=
{
	"_CountQuestLimitByName",
	[[
		select count(*) from tbl_quest_finish_limit where qfl_sQuestName = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef=
{
	"_CountObjDropLimitByName",
	[[
		select count(*) from tbl_obj_drop_limit where odl_sObjName = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef=
{
	"_GetAllQuestLoop",
	[[
		select ql_sLoopName, ql_uLoopNum from tbl_quest_loop where cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef=
{
	"_GetQuestLoop",
	[[
		select ql_uLoopNum from tbl_quest_loop where cs_uId = ? and ql_sLoopName = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef=
{
	"_UpdateQuestLoop",
	[[
		replace into tbl_quest_loop (cs_uId, ql_sLoopName, ql_uLoopNum) values (?,?,?)
	]]
}
DefineSql( StmtDef, StmtContainer)

local StmtDef=
{
	"_DeleteQuestLoop",
	[[
		delete from tbl_quest_loop where cs_uId = ? and ql_sLoopName = ?
	]]
}
DefineSql( StmtDef, StmtContainer)

----------------------------------------------

local RoleQuestDB = CreateDbBox(...)

-----------------------------------------------------------------------------------
local function SetResult(OneRet,nRoom,nPos,nCount,nBigID,nIndex)
	assert(IsTable(OneRet))
	OneRet.m_nRoomIndex = nRoom
	OneRet.m_nPos = nPos
	OneRet.m_nCount = nCount
	OneRet.m_nBigID = nBigID
	OneRet.m_nIndex = nIndex
	return OneRet
end

local function Get2PosDistance(pos1, pos2)
	return math.max( math.abs( pos1.x - pos2.x ), math.abs( pos1.y - pos2.y ) )
end

local function IfAcceptQuestMinLev(PlayerLevel, QuestName)
	local minlevel = Quest_Common(QuestName, "��������С�ȼ�")
	if (minlevel and minlevel ~= 0 and PlayerLevel < minlevel) then
		return
	end
	return true
end

local function IfAcceptQuestMaxLev(PlayerLevel, QuestName)
	local maxlevel = Quest_Common(QuestName, "��������ߵȼ�")
	if (maxlevel and maxlevel ~= 0 and PlayerLevel > maxlevel) then
		return false
	end
	return true
end

local function CmpMercenaryLevel(PlayerLevel, QuestName)
	--local Level = Quest_Common(QuestName, "��������СӶ���ȼ�")
	--if Level and Level~="" then
		--local iLevel = Quest
		--for i=1, #(MercenaryLevel_Common) do
		--	if MercenaryLevel_Common[i].MercenaryLevel == iLevel then
		--		iLevel = i
		--		break
		--	end
		--end
		--if (iLevel - PlayerLevel) > 5 then
		--	return false
		--end
	--end
	return true
end

local function IfAcceptQuestCamp(PlayerCamp, QuestName)
	local CampLimit = Quest_Common(QuestName, "��Ӫ����")
	if CampLimit and CampLimit ~= 0 and CampLimit ~= PlayerCamp then
		return false
	end
	return true
end

local function CheckQuestTimeCount(QuestName, PlayerId, TimeTbl, FinishCount)
	local nowTime = os.time()
	local sDate = TimeTbl[1]
	local sTime = TimeTbl[2]
	local oDate = TimeTbl[4]
	local oTime = TimeTbl[5]
	local startTime, overTime
	
	local j = string.find(sDate, "/")
	local k = string.find(sDate, "/", j+1)
	local tbl = {}
	tbl.month = tonumber( string.sub(sDate, 1, j-1) )
	tbl.day   = tonumber( string.sub(sDate, j+1, k-1) )
	tbl.year  = tonumber( string.sub(sDate, k+1) )
	j = string.find(sTime, ":")
	tbl.hour  = tonumber( string.sub(sTime, 1, j-1) )
	tbl.min   = tonumber( string.sub(sTime, j+1) )
	startTime = os.time(tbl)
	
	if oDate and oTime then
		j = string.find(oDate, "/")
		k = string.find(oDate, "/", j+1)
		tbl.month = tonumber( string.sub(oDate, 1, j-1) )
		tbl.day   = tonumber( string.sub(oDate, j+1, k-1) )
		tbl.year  = tonumber( string.sub(oDate, k+1) )
		j = string.find(oTime, ":")
		tbl.hour  = tonumber( string.sub(oTime, 1, j-1) )
		tbl.min   = tonumber( string.sub(oTime, j+1) )
		overTime = os.time(tbl)
	end
	
	if nowTime < startTime then
		return false, true	--û�������ȡʱ��
	end
	if overTime and nowTime > overTime then
		return nil, true	--�����ѽ���
	end
	
	local res = StmtContainer.GetQuestLimit:ExecStat(QuestName, PlayerId)
	if res:GetRowNum() == 0 then
		StmtContainer.InsertQuestLimit:ExecStat(QuestName, PlayerId, 0, nowTime, 0)
		res:Release()
		return true, true		--���ݿ�û�У����Խ�ȡ����
	else
		local count     = res:GetData(0,0)
		local countTime = res:GetData(0,1)
		local cdTime    = res:GetData(0,2)
		local cycle = TimeTbl[3]*3600
		local sign1, sign2 = false, false
		if math.floor((nowTime-startTime)/cycle) ~= math.floor((countTime-startTime)/cycle) then
			count = 0
			StmtContainer.UpdateQuestLimit:ExecStat(count, nowTime, cdTime, QuestName, PlayerId)
			sign2 = true
		end
		if count < FinishCount then
			sign1 = true
		end
		res:Release()
		return sign1, sign2
	end
end

local function AddQuestTimeCount(questName, playerId)
	local res = StmtContainer.GetQuestLimit:ExecStat(questName, playerId)
	if res:GetRowNum() ~= 0 then
		local	count     = res:GetData(0,0)
		local countTime = res:GetData(0,1)
		local	cdTime    = res:GetData(0,2)
		StmtContainer.UpdateQuestLimit:ExecStat(count+1, countTime, cdTime, questName, playerId)
	end
	res:Release()
end

local function CheckQuestCD(questName, playerId, CDTime)
	local nowTime = os.time()
	local res = StmtContainer.GetQuestLimit:ExecStat(questName, playerId)
	if res:GetRowNum() == 0 then
		StmtContainer.InsertQuestLimit:ExecStat(questName, playerId, 0, 0, nowTime)
		res:Release()
		return true		--���ݿ�û�У����Խ�ȡ����
	else
		local count     = res:GetData(0,0)
		local countTime = res:GetData(0,1)
		local cdTime    = res:GetData(0,2)
		if nowTime-cdTime >= CDTime*3600 then
			StmtContainer.UpdateQuestLimit:ExecStat(count, countTime, nowTime, questName, playerId)
			res:Release()
			return true
		else
			local date = os.date("*t", CDTime*3600-(nowTime-cdTime))
			local defDate = os.date("*t", 0)
			local str = (date.hour-defDate.hour)..GetStaticTextServer(1121)..(date.min-defDate.min)..GetStaticTextServer(1120)
			res:Release()
			return false, str
		end
	end
end

local function RefreshQuestCD(questName, playerId)
	local res = StmtContainer.GetQuestLimit:ExecStat(questName, playerId)
	if res:GetRowNum() ~= 0 then
		local	count     = res:GetData(0,0)
		local countTime = res:GetData(0,1)
		StmtContainer.UpdateQuestLimit:ExecStat(count, countTime, 0, questName, playerId)
	end
	res:Release()
end

local function CheckStartTime(sQuestName)
	local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����ȡʱ��", "Subject")
	local WDayTbl = tbl.wday
	local StartTimeTbl = tbl.time
	local LastTime = Quest_Common(sQuestName, "�����ȡʱ��", "Arg")
	local Date = os.date("*t")
	WDayTbl = WDayTbl or {1,2,3,4,5,6,7}
	for i=1,#WDayTbl do
		local wday = (WDayTbl[i]==7 and 1) or WDayTbl[i]+1
		if wday == Date.wday then
			for j=1,#StartTimeTbl do
				local k = string.find(StartTimeTbl[j], ":")
				local hour = tonumber( string.sub(StartTimeTbl[j], 1, k-1) )
				local min = tonumber( string.sub(StartTimeTbl[j], k+1, -1) )
				local dif = (Date.hour*60+Date.min) - (hour*60+min)
				if dif>=0 and dif<=LastTime then
					return true
				end
			end
		end
	end
	return false
end


-------------------------------------------------------------------------------------

--------------��ҽ���������ʱ��Ҫ�����ݿ����  begin

local function AddNewQuest(sQuestName,uCharId,TakeQestTime,uExpMultiple)
	if not uExpMultiple or not IsNumber(uExpMultiple) or uExpMultiple <= 0 then
		uExpMultiple = 1
	end
	StmtContainer._AddNewQuest:ExecSql("", sQuestName, uCharId,TakeQestTime,uExpMultiple)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

--���������
function RoleQuestDB.AddNewQuest(sQuestName,uCharId,TakeQestTime,uExpMultiple)
	return AddNewQuest(sQuestName,uCharId,TakeQestTime,uExpMultiple)
end

local function AddNewQuestVar(sQuestName,uCharId,sVarName)
	StmtContainer._AddNewQuestVar:ExecSql("", sQuestName, uCharId, sVarName)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

--�����������������
function RoleQuestDB.AddNewQuestVar(sQuestName,uCharId,sVarName)
	return AddNewQuestVar(sQuestName,uCharId,sVarName)
end

local function ClearQuest(sQuestName,uCharId)
	StmtContainer._ClearQuest:ExecSql("", sQuestName, uCharId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

--���DB�е�����
function RoleQuestDB.ClearQuest(sQuestName,uCharId)
	return ClearQuest(sQuestName,uCharId)
end

local function DeleteAllQuestVar(sQuestName,uCharId)
	if #(RoleQuestDB.SelectQuestVarList(sQuestName,uCharId)) > 0 then
		StmtContainer._DeleteAllQuestVar:ExecSql("", sQuestName,uCharId)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	else
		return true
	end
end

--���DB����������б���
function RoleQuestDB.DeleteAllQuestVar(sQuestName,uCharId)
	return DeleteAllQuestVar(sQuestName,uCharId)		
end
--------------��ҷ�������ʱ��Ҫ�����ݿ����  end

local function GetQuestAcceptTime(sQuestName,uCharId)
	local ret = StmtContainer._GetQuestAcceptTime:ExecSql("n",sQuestName,uCharId)
	if(ret:GetRowNum() == 0) then
		ret:Release()
		return nil
	end
	local res = ret:GetData(0,0)
	ret:Release()
	return res
end

--��ȡ����ʼʱ��
function RoleQuestDB.GetQuestAcceptTime(sQuestName,uCharId)
	return GetQuestAcceptTime(sQuestName,uCharId)
end

local function GetQuestState(data)
	local ret = StmtContainer._GetQuestState:ExecSql("n", data[1],data[2])
	if(ret:GetRowNum() == 0) then
		ret:Release()
		return nil
	end
	local res1,res2 = ret:GetData(0,0),ret:GetData(0,1)
	ret:Release()
	return res1,res2
end

--��ȡ�����״̬
function RoleQuestDB.GetQuestState(data)
	return GetQuestState(data)
end

local function GetQuestStateFinishTime(char_id,QuestName)
	local ret = StmtContainer._GetQuestStateFinishTime:ExecSql("n", char_id,QuestName)
	if(ret:GetRowNum() == 0) then
		ret:Release()
		return nil
	end
	local res1,res2 = ret:GetData(0,0),ret:GetData(0,1)
	ret:Release()
	return res1,res2
end

local function UpdateQuestState(QuestState,finishTime,uCharId,sQuestName)
	StmtContainer._UpdateQuestState:ExecSql("", QuestState,finishTime,uCharId,sQuestName)
	return g_DbChannelMgr:LastAffectedRowNum() > 0 
end

--��������״̬
function RoleQuestDB.UpdateQuestState(iQuestState,uCharId,sQuestName)
	local finishTime = 0
	if iQuestState == QuestState.finish then
		finishTime = os.time()
	end
	return UpdateQuestState(iQuestState,finishTime,uCharId,sQuestName)
end

local function UpdateQuestTime(TakeTime,uCharId,sQuestName)
	StmtContainer._UpdateQuestTime:ExecSql("", TakeTime,uCharId,sQuestName)
	return g_DbChannelMgr:LastAffectedRowNum() > 0 
end

--��������ʱ��
function RoleQuestDB.UpdateQuestTime(TakeTime,uCharId,sQuestName)
	return UpdateQuestTime(TakeTime,uCharId,sQuestName)
end

local StmtDef = {
	"_UpdateQuestLimitTime",
	[[
		update
			tbl_quest
		set
			q_uLimitTime = 1
		where
			q_uLimitTime = 0 and cs_uId = ? and q_sName = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local function QuestIsLimitTime(uCharId,sQuestName)
	StmtContainer._UpdateQuestLimitTime:ExecSql("", uCharId,sQuestName)
	return g_DbChannelMgr:LastAffectedRowNum() > 0 
end

--���������ʱ������
function RoleQuestDB.QuestIsLimitTime(data)
	local uCharId,QuestName = data["PlayerId"],data["QuestName"]
	return QuestIsLimitTime(uCharId,QuestName)
end

local function InsertCharFinishQuestNum(uCharId,Num)
	StmtContainer._InsertCharFinishQuestNum:ExecSql("", uCharId,Num)
	return g_DbChannelMgr:LastAffectedRowNum() > 0 
end

--������������������
function RoleQuestDB.InsertCharFinishQuestNum(uCharId,Num)
	return InsertCharFinishQuestNum(uCharId,Num)
end

local function SelectCharFinishQuestNum(uCharId)
	local ret = StmtContainer._SelectCharFinishQuestNum:ExecSql("n", uCharId)
	local num = 0
	if(ret:GetRowNum() ~= 0) then
		num = ret:GetData(0,0)
	end
	ret:Release()
	return num
end

--��ѯ��������������
function RoleQuestDB.SelectCharFinishQuestNum(uCharId)
	return SelectCharFinishQuestNum(uCharId)
end

local function UpdateCharFinishQuestNum(uCharId,AddNum)
	StmtContainer._AddCharFinishQuestNum:ExecSql("", AddNum,uCharId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0 
end

--������������������
function RoleQuestDB.UpdateCharFinishQuestNum(uCharId,AddNum)
	return UpdateCharFinishQuestNum(uCharId,AddNum)
end

local function GetQuestExpMultiple(uCharId,sQuestName)
	local ret = StmtContainer._GetQuestExpMultiple:ExecSql("n", uCharId,sQuestName)
	if(ret:GetRowNum() == 0) then
		ret:Release()
		return 1
	end
	local res = ret:GetData(0,0)
	ret:Release()
	return res
end

--��ȡ�������ı���
function RoleQuestDB.GetQuestExpMultiple(uCharId,sQuestName)
	return GetQuestExpMultiple(uCharId,sQuestName)
end

local function SelectQuestVarNum(sQuestName,sVarName,uCharId)
	local ret = StmtContainer._SelectQuestVarNum:ExecSql("n", sQuestName, sVarName, uCharId)
	if(ret:GetRowNum() == 0) then
		ret:Release()
		return nil
	end
	local res = ret:GetData(0,0)
	ret:Release()
	return res
end

local function CheckQuestVarNeedNum(data)
	local sQuestName = data["sQuestName"]
	local sVarName = data["sVarName"]
	local uCharId = data["uCharId"]
	if g_QuestNeedMgr[sQuestName] then
		local NeedNum = g_QuestNeedMgr[sQuestName][sVarName].Num
		local DoNum = SelectQuestVarNum(sQuestName, sVarName, uCharId)
		if DoNum and DoNum < NeedNum then
			return NeedNum-DoNum
		end
	end
	return nil
end

--��ȡָ�����������Ŀ
function RoleQuestDB.CheckQuestVarNeedNum(data)
	return CheckQuestVarNeedNum(data)
end

local function CheckQuestItemNeedNum(data)
	local sQuestName = data["sQuestName"]
	local iItemType = data["iItemType"]
	local sItemName = data["sItemName"]
	local uCharId = data["uCharId"]
	local NeedNum = g_QuestNeedMgr[sQuestName][sItemName].Num
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local iState = RoleQuestDB.GetQuestState({uCharId,sQuestName})
	if iState ~= QuestState.init then
		return nil
	end
	local HaveNum = g_RoomMgr.GetItemCount(uCharId, iItemType, sItemName)
	--local HaveNum = SelectQuestVarNum(sQuestName, sVarName, uCharId)
	if HaveNum and HaveNum < NeedNum then
		return NeedNum-HaveNum
	end
	return nil
end

--��ȡ������Ʒ��Ҫ�ı�����Ŀ
function RoleQuestDB.CheckQuestItemNeedNum(data)
	return CheckQuestItemNeedNum(data)
end

local function CheckQuestSatisfy(data)
	local sQuestName = data["sQuestName"]
	local uCharId = data["uCharId"]
	
	local iState = RoleQuestDB.GetQuestState({uCharId,sQuestName})
	if iState ~= QuestState.init then
		return false
	end
	
	local vartbl = RoleQuestDB.SelectQuestVarList(sQuestName,uCharId)
	local num1 = table.getn(vartbl)
	for i = 1, num1 do
		local sVarName = vartbl[i][1]
		local DoNum = vartbl[i][2]
		local NeedNum = g_QuestNeedMgr[sQuestName][sVarName].Num
		if DoNum < NeedNum then
			return true
		end
	end
	
	if Quest_Common(sQuestName, "��Ʒ����") then
		local Keys = Quest_Common:GetKeys(sQuestName, "��Ʒ����")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", Keys[k], "Arg")
			local needtype = Arg[1]
			local needname = Arg[2]		--�������Ʒ��
			local neednum = Arg[3]
			local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
			local have_num = g_RoomMgr.GetItemCount(uCharId,needtype,needname)
			if have_num < neednum then
				return true
			end
		end
	end
	return false
end

--��������Ƿ����,������û����ɵ�״̬
function RoleQuestDB.CheckQuestSatisfy(data)
	return CheckQuestSatisfy(data)
end

local function GetDoingQuestSql(uCharId)
	local DbQuestAll = {}
	local Ret = StmtContainer._GetDoingQuests:ExecStat(uCharId)
	for i=1, Ret:GetRowNum() do
		local questname = Ret:GetData(i-1, 0)
		if Quest_Common(questname) then
			table.insert(DbQuestAll, {questname})
		end
	end
	Ret:Release()
	
	return DbQuestAll
end

--�õ�ĳ����ҵ���������
function RoleQuestDB.GetDoingQuestSql(uCharId)
	return GetDoingQuestSql(uCharId)
end

local StmtDef = {
	"_InsertAwardItemIndex",
	[[
		replace into tbl_quest_tempitem (q_sName,cs_uId,qt_ItemIndex) values(?,?,?)
	]]
}
DefineSql( StmtDef, StmtContainer )
--�������������Եõ�����ƷID(Ӷ����ս������)
local ItemLevelTbl = {
	[1]={1,30},
	[2]={31,40},
	[3]={41,50},
	[4]={51,60},
	[5]={61,70},
	[6]={71,80},
}
local function InsertAwardItemIndex(charId, QuestName)
	if g_AllMercenaryQuestMgr[QuestName] then
		local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
		local Level = CharacterMediatorDB.GetPlayerLevel(charId)
		local ItemIndex = nil
		for i=1, #(ItemLevelTbl) do
			if ItemLevelTbl[i][1] <= Level and ItemLevelTbl[i][2] >= Level then
				ItemIndex = i
				break
			end
		end
		
		local AwardItem = GetCfgTransformValue(true, "Quest_Common", QuestName, "��Ʒ����", "Subject")
		if Quest_Common(QuestName, "��Ʒ����") and AwardItem[1] then
			if AwardItem[ItemIndex] then
				StmtContainer._InsertAwardItemIndex:ExecSql("", QuestName, charId, ItemIndex)
				return g_DbChannelMgr:LastAffectedRowNum() > 0, ItemIndex
			end
		end
	end
	return true, 0
end

local StmtDef = {
	"_GetAwardItemFromQuest",
	[[
		select
			qt_ItemIndex
		from
			tbl_quest_tempitem
		where
			cs_uId = ? and q_sName = ?
	]]
}
DefineSql( StmtDef, StmtContainer )
--�õ�����ɵõ���ƷID(Ӷ����ս������)
local function GetAwardItemFromQuest(charId, QuestName)
	local ret = StmtContainer._GetAwardItemFromQuest:ExecSql("n", charId, QuestName)
	if(ret:GetRowNum() == 0) then
		ret:Release()
		return
	end
	local res = ret:GetData(0,0)
	ret:Release()
	return res
end

function RoleQuestDB.GetAwardItemFromQuest(data)
	local charId = data["char_Id"]
	local QuestName = data["QuestName"]
	return GetAwardItemFromQuest(charId, QuestName)
end

local function CheckQuestIsInArea(QuestName,AreaName)
	if not Quest_Common(QuestName, "��������") then
		return false
	end
	local Keys = Quest_Common:GetKeys(QuestName, "��������")
	for n = 1, table.getn(Keys) do
		if AreaName == Quest_Common(QuestName, "��������", Keys[n]) then
			return true
		end
	end
	return false
end

local function CheckQuestIsKillNpc(QuestName)
	if Quest_Common(QuestName, "ɱ������") then
		return false
	end
	return true
end

local function Is2CharHaveSameKillNpcQuest(AreaName,uCharId1,uCharId2)
	if g_AreaQuestMgr[AreaName] == nil then
		return false
	end
	local ret1 = StmtContainer._GetDoingQuests:ExecSql("s[32]", uCharId1)
	local num1 = ret1:GetRowNum()
	if num1 == 0 then
		ret1:Release()
		return false
	end
	
	local ret2 = StmtContainer._GetDoingQuests:ExecSql("s[32]", uCharId2)
	local num2 = ret2:GetRowNum()
	if num2 == 0 then
		ret2:Release()
		return false
	end
	
	for i = 1, num1 do
		local QuestName1 = ret1:GetData(i-1,0)
		for j = 1,num2 do
			local QuestName2 = ret2:GetData(j-1,0)
			if QuestName1 == QuestName2 
				and CheckQuestIsKillNpc(QuestName1)
				and CheckQuestIsInArea(QuestName1,AreaName) then
				
				return true
			end
		end
	end
	ret1:Release()
	ret2:Release()
	return false
end

function RoleQuestDB.Is2CharHaveSameKillNpcQuest(AreaName,uCharId1,uCharId2)
	return Is2CharHaveSameKillNpcQuest(AreaName,uCharId1,uCharId2)
end

--��ȡ��ǰ�������ƣ���������Ŀ
local function SelectQuestVarList(sQuestName,uCharId)
	local tbl = {}
	local ret = StmtContainer._SelectQNameVNameVNum:ExecSql("s[128]n", sQuestName,uCharId)
	for i = 1, ret:GetRowNum() do
		tbl[i] = {ret:GetData(i-1,0),ret:GetData(i-1,1)}
	end
	ret:Release()
	return tbl
end

--��ȡ��ǰ�������ƣ���������Ŀ
function RoleQuestDB.SelectQuestVarList(sQuestName,uCharId)
	return SelectQuestVarList(sQuestName,uCharId)
end

local function AddQuestVarNum(data)
	local iNum = data["iNum"]
	local sQuestName = data["sQuestName"]
	local sVarName = data["sVarName"]
	local uCharId = data["char_id"]
	local NeedDoNum = g_QuestNeedMgr[sQuestName][sVarName].Num
	StmtContainer._AddQuestVarNum:ExecSql("", iNum, uCharId, sQuestName, sVarName, iNum, NeedDoNum)
--	print("RoleQuestDB.AddQuestVarNum,g_DbChannelMgr:LastAffectedRowNum() > 0",g_DbChannelMgr:LastAffectedRowNum() > 0)
	local IsFinish = g_DbChannelMgr:LastAffectedRowNum() > 0
	return IsFinish
end

--������֪�������֪����������
function RoleQuestDB.AddQuestVarNum(data)
	return AddQuestVarNum(data)
end

local function AddVarNumForQuest(sQuestName,sVarName,uCharId,iNum)
	local NeedDoNum = g_QuestNeedMgr[sQuestName][sVarName].Num
	local DoNum = SelectQuestVarNum(sQuestName,sVarName,uCharId)
	if DoNum ~= nil and DoNum < NeedDoNum then
		local ResNum = DoNum+iNum
		if DoNum+iNum > NeedDoNum then
			iNum = NeedDoNum - DoNum
			ResNum = NeedDoNum
		end
		StmtContainer._SetQuestVarNum:ExecSql("", ResNum, uCharId, sQuestName, sVarName)
		if g_DbChannelMgr:LastAffectedRowNum() > 0 then
			return iNum
		else
			return false
		end
	end
	return nil
end

local function AddVarNumForTeamQuests(data)
	local uCharId = data["char_id"]
	local sVarName = data["sVarName"]
	local iNum = data["iNum"]
	local CanShareTeamMateTbl = data["CanShareTeamMateTbl"]
	
	local PlayerAddQuestVarTbl = {}
	for i = 1,table.getn(g_VarQuestMgr[sVarName]) do
		local sQuestName = g_VarQuestMgr[sVarName][i]
		local ResNum = AddVarNumForQuest(sQuestName,sVarName,uCharId,iNum)
		if ResNum ~= nil then
			if PlayerAddQuestVarTbl[uCharId] == nil then
				PlayerAddQuestVarTbl[uCharId] = {}
			end
			table.insert(PlayerAddQuestVarTbl[uCharId],{sQuestName,sVarName,ResNum})
		end
	end
	
	for i = 1,table.getn(CanShareTeamMateTbl) do
		data["char_id"] = CanShareTeamMateTbl[i]
		for j = 1,table.getn(g_VarQuestMgr[sVarName]) do
			local sQuestName = g_VarQuestMgr[sVarName][j]
			local bNotShare = g_QuestNeedMgr[sQuestName][sVarName].bNotShare
			if not bNotShare then
				local ResNum = AddVarNumForQuest(sQuestName,sVarName,CanShareTeamMateTbl[i],iNum)
				if ResNum then
					if PlayerAddQuestVarTbl[CanShareTeamMateTbl[i]] == nil then
						PlayerAddQuestVarTbl[CanShareTeamMateTbl[i]] = {}
					end
					table.insert(PlayerAddQuestVarTbl[CanShareTeamMateTbl[i]],{sQuestName,sVarName,ResNum})
				end
			end
		end
	end
	return PlayerAddQuestVarTbl
end

--���ӶӶ�����������Ϊ��sVarName������������ļ���
function RoleQuestDB.AddVarNumForTeamQuests(data)
	return AddVarNumForTeamQuests(data)
end

local function LevelQuestFail(data)
	local charId = data["char_id"]
	local Level = data["Level"]
	local FailQuestTbl = {}
	local QuestNumRes = StmtContainer._GetDoingQuests:ExecStat(charId)
	if QuestNumRes:GetRowNum() > 0 then
		for i=1, QuestNumRes:GetRowNum() do
			local sQuestName = QuestNumRes:GetData(i-1,0)
			if Quest_Common(sQuestName) then
				local MaxLevel = Quest_Common(sQuestName, "����������ߵȼ�")
				if MaxLevel and MaxLevel~=0 and Level > MaxLevel then
					local param = {}
					param["PlayerId"] = charId
					param["QuestName"] = sQuestName
					table.insert(FailQuestTbl,{RoleQuestDB.QuestFailure(param),sQuestName})
				end
			end
		end
		QuestNumRes:Release()
	end
	return FailQuestTbl
end

--���Ӹ��ȼ��йص��������,���ó����ȼ�������ʧ��
function RoleQuestDB.AddVarNumForLevelQuests(data)
	local param = {}
	if data["sVarName"] then
		param["PlayerAddQuestInfo"] = AddVarNumForTeamQuests(data)
	end
	param["PlayerFailQuestInfo"] = LevelQuestFail(data)
	return param
end

local function AddQuestVarNumForTeam(data)
	local tbl = {}
	tbl[data["char_id"]] = RoleQuestDB.AddQuestVarNum(data)
	local CanShareTeamMateTbl = data["CanShareTeamMateTbl"]
	for i = 1, #(CanShareTeamMateTbl) do
		data["char_id"] = CanShareTeamMateTbl[i]
		tbl[CanShareTeamMateTbl[i]] = RoleQuestDB.AddQuestVarNum(data)
	end
	return tbl
end

-- ���Ӷ���ָ������sQuestName��ָ������sVarName�ļ���
function RoleQuestDB.AddQuestVarNumForTeam(data)
	return AddQuestVarNumForTeam(data)
end 

local function SetQuestVarNum(data)
	local sQuestName = data["sQuestName"]
	local sVarName = data["sVarName"]
	local DoNum = data["DoNum"]
	local uCharId = data["char_id"]
	StmtContainer._SetQuestVarNum:ExecSql("", DoNum + 1, uCharId, sQuestName, sVarName)
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return DoNum + 1
	else
		return nil
	end
	return nil
end

--�������������
function RoleQuestDB.SetQuestVarNum(data)
	return SetQuestVarNum(data)
end

--����Ӷ������ֵ
local function CalculateSingleIntegral(MonsterLevel,CharacterLevel)
	local uLevelDiff = MonsterLevel - CharacterLevel;
	local Exp=0

	if uLevelDiff <= -20 then
		return Exp
	end

	if uLevelDiff > 5 then
		uLevelDiff = 5
	end

	Exp = ((CharacterLevel*3)+50) * (1 + uLevelDiff*4 / (CharacterLevel+60))
	return Exp
end

--ɱ�ֺ�,����͵ȼ��ı仯
local function AddPlayerExp(PlayerLevel,AddExpNum,DBExp,PlayerId)
	--Ӷ���ȼ���������ȼ����Ӿ���ϵ��
	--local MercenaryLevelDB = RequireDbBox("MercenaryLevelDB")
	--local data = {}
	--data["CharId"] = PlayerId
	--local MercenaryLevel = MercenaryLevelDB.GetMercenaryLevelInfo(data)
	--local FinishAwards = MercenaryLevelDB.GetMercenaryLevelAward(data)
	--MercenaryLevel = MercenaryLevel or 0
	--local LimitLevel = nil
	--if FinishAwards["���ŵȼ�"] then
	--	if g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"]["���ŵȼ�"] then
	--		LimitLevel = g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"]["���ŵȼ�"].Arg
	--	else
	--		LimitLevel = g_TestRevisionMaxLevel
	--	end
	--else
	--	if MercenaryLevel==0 or g_MercenaryLevelTbl[MercenaryLevel-1]["��Ȩ"]["���ŵȼ�"] then
	--		LimitLevel = (MercenaryLevel==0 and 10) or g_MercenaryLevelTbl[MercenaryLevel-1]["��Ȩ"]["���ŵȼ�"].Arg
	--	else
	--		LimitLevel = g_TestRevisionMaxLevel
	--	end
	--end
	--if FinishAwards["��������"] then
	--	AddExpNum = AddExpNum * (1+ g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"]["��������"].Arg)
	--elseif MercenaryLevel~=0 and g_MercenaryLevelTbl[MercenaryLevel-1]["��Ȩ"]["��������"] then
	--	AddExpNum = AddExpNum * (1+ g_MercenaryLevelTbl[MercenaryLevel-1]["��Ȩ"]["��������"].Arg)
	--end
	
	local LevelExp = DBExp + AddExpNum
	local nCurlevel = PlayerLevel
	local LimitLevel = g_TestRevisionMaxLevel	--math.min(LimitLevel, g_TestRevisionMaxLevel)
	if nCurlevel == LimitLevel then
		return nil
	end
	if nCurlevel == LevelExp_Common.GetHeight() then
		return nil
	end
	
	while LevelExp >= LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") do
		--���������������ǰ����Ϊ0
		if LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") == 0 then
			LevelExp = 0
			break
		end
		--��ȥ�������飬��������һ��
		LevelExp = LevelExp - LevelExp_Common(nCurlevel, "ExpOfCurLevelUp")

		nCurlevel = nCurlevel + 1
		if nCurlevel >= LimitLevel then
			LevelExp = 0
			break
		end
		if nCurlevel >= LevelExp_Common.GetHeight() then
			LevelExp = 0
			break
		end
	end
	return nCurlevel,LevelExp
end

--Ӷ��������ɺ󣬼�Ӷ������
local function AddPlayerMercenaryIntegral(PlayerMercenaryLevel,AddIntegral,DBIntegral)
	local LevelIntegral = DBIntegral + AddIntegral
	local Currlevel = PlayerMercenaryLevel

	--if Currlevel == #(MercenaryLevel_Common) then
	--	return nil
	--end
	
--	local iQuestLevel = 1
--	for i=1, #(MercenaryLevel_Common) do
--		if MercenaryLevel_Common[i].MercenaryLevel == QuestLevel then
--			iQuestLevel = i
--			break
--		end
--	end
--	
--	if iQuestLevel > PlayerMercenaryLevel then
--		return iQuestLevel,0
--	end
--	
--	while LevelIntegral >= MercenaryLevel_Common[Currlevel].IntegralOfCurLevelUp do
--		--���������������ǰ����Ϊ0
--		if MercenaryLevel_Common[Currlevel].IntegralOfCurLevelUp == 0 
--			or MercenaryLevel_Common[Currlevel].IntegralOfCurLevelUp == "" then
--			LevelIntegral = 0
--			break
--		end
--		--��ȥ�������飬��������һ��
--		LevelIntegral = LevelIntegral - MercenaryLevel_Common[Currlevel].IntegralOfCurLevelUp
--
--		Currlevel = Currlevel + 1
--		if Currlevel >= #(MercenaryLevel_Common) then
--			LevelIntegral = 0
--			break
--		end
--	end
	return Currlevel,LevelIntegral
end

--��ѯ���ѱ�  QuestName ��������    �����Ƿ���ظ�
--���ؿ��Խ�������Ķ��� tbl
--yy
function RoleQuestDB.QuestTeamPlayer(data)
	local TeamID = data["TeamID"]
	local QuestName = data["HideQuestName"]
	local reTbl = {}
	--if TeamID ~= 0 then
	local team = RequireDbBox("GasTeamDB")
	local tblMembers = team.GetTeamMembers(TeamID)

	for k = 1, #(tblMembers)do
--		print("tblMembers[k]",tblMembers[k])
		local state=RoleQuestDB.GetQuestState({tblMembers[k][1], QuestName})
		if state ~= nil then
			if state == QuestState.finish then
				if g_RepeatQuestMgr[QuestName] then
					table.insert( reTbl, tblMembers[k][1])
				end
			end
		else
			table.insert( reTbl, tblMembers[k][1])
		end
	end
	return reTbl
end	

--ɱ���ֺ�������ҵ��������
local function AddPlayerKillNpcVarNum(data)
	local NpcName = data["NpcName"]
	local ShowName = data["ShowName"]
	local PlayerId = data["char_id"]
	
	if data["QuestNpc"][PlayerId] then
		local isAddQuestNum = false
		for _,Tbl in pairs(data["QuestNpc"][PlayerId]) do
			for i=1, #(Tbl) do
				if Tbl[i] == NpcName or Tbl[i] == ShowName then
					isAddQuestNum = true
					break
				end
			end
			if isAddQuestNum then
				break
			end
		end
		
		if isAddQuestNum then
			
			local statetbl = data["DeadStateTbl"]
			
			local RecordName = {} 
			if g_KillNpcQuestMgr[NpcName] then
				RecordName[1] = NpcName
			end
			if g_KillNpcQuestMgr[ShowName] then
				RecordName[2] = ShowName
			end
			
			local QuestTbl = {}
			for index = 1, 2 do
				if RecordName[index] and statetbl[index] then
					for i = 1, table.getn(statetbl[index]) do
						local statename = statetbl[index][i]
						local varName = statename.."ɱ"..RecordName[index]
						if g_KillNpcQuestMgr[RecordName[index]][statename] then
							for j = 1, table.getn(g_KillNpcQuestMgr[RecordName[index]][statename]) do
								local questname = g_KillNpcQuestMgr[RecordName[index]][statename][j]
								data["sQuestName"] = questname
								data["sVarName"] = varName
								data["iNum"] = 1
								local IsTure = RoleQuestDB.AddQuestVarNum(data)
								if IsTure then
									local cQuestTbl = {}
									cQuestTbl["QuestName"] = data["sQuestName"]
									cQuestTbl["VarName"] = varName
									cQuestTbl["AddNum"] = 1
									table.insert(QuestTbl,cQuestTbl)
								end
							end
						end
					end
					
				end
			end
			return QuestTbl
			
		end
	end
end

--ɱ�ֺ�,���������ص���Ϣ�������ȼ�,����е���,�����������Ʒ��tal��
--������Ʒ
--(ע��:���ֱ����CallDbTrans�е��ô˷����᷵��4������,�൱����,�����ĵ��䷽ʽ)
--(ע��:������õ��������,��RoleQuestDB.KillNpcAddQuestDropObj()���ô˷����᷵��5������)
local function KillNpcAddQuestDropObj(data)
	local AddQuestResTbl = {}
	local PlayerId = data["char_id"]
	
	local CanShareTeamMateTbl = data["TeamMemberID"]
	--local TeamMemberID = data["TeamMemberID"]
	--local AreaDB = RequireDbBox("AreaDB")
	
--	for i=1, #(TeamMemberID) do
--		local teammateid = TeamMemberID[i]
--		if AreaDB.Check2PlayerInSameArea(PlayerId,teammateid) then
--			table.insert(CanShareTeamMateTbl,teammateid)
--		end
--	end
	
	--��һ���˵��������
	local AddQuestRes = AddPlayerKillNpcVarNum(data)
	if AddQuestRes and next(AddQuestRes) then
		table.insert(AddQuestResTbl,{PlayerId,AddQuestRes})
	end
	
	for i=1, table.getn(CanShareTeamMateTbl) do		
		data["char_id"] = CanShareTeamMateTbl[i]
		
		AddQuestRes = AddPlayerKillNpcVarNum(data)
		if AddQuestRes and next(AddQuestRes) then
			table.insert(AddQuestResTbl,{CanShareTeamMateTbl[i],AddQuestRes})
		end
		
	end
	
	local NpcDropItemDB = RequireDbBox("NpcDropItemDB")
	local DropObjTbl,DropItemTbl,AddItemResTbl = NpcDropItemDB.NpcDeadDrop(PlayerId,data,CanShareTeamMateTbl,data["sceneName"])
	if data["IsBoss"] then
		local LogMgr = RequireDbBox("LogMgrDB")
		LogMgr.SaveNpcDeadInfo( PlayerId, data["NpcName"],data["PlayerLevel"])
	end
	return {AddQuestResTbl,AddItemResTbl,DropItemTbl,DropObjTbl}
end

function RoleQuestDB.KillNpcAddQuestDropObj(data)
	return KillNpcAddQuestDropObj(data)
end

--��ӿ��Դ�������ľ糡
function RoleQuestDB.AddQuestTheater(data)
	local PlayerTbl = data["PlayerTbl"]
	local TheaterName = data["TheaterName"]
	local PlayerQuestTbl = {}
	if g_VarQuestMgr[TheaterName] == nil then
		return PlayerQuestTbl
	end
	
	data["sVarName"] = TheaterName
	data["iNum"] = 1
	for i = 1, table.getn(PlayerTbl) do
		data["char_id"] = PlayerTbl[i]
		for j = 1, table.getn(g_VarQuestMgr[TheaterName]) do
			data["sQuestName"] = g_VarQuestMgr[TheaterName][j]
			local IsTrue = RoleQuestDB.AddQuestVarNum(data)
			if IsTrue then
				PlayerQuestTbl[PlayerTbl[i]] = {}
				PlayerQuestTbl[PlayerTbl[i]]["questname"] = g_VarQuestMgr[TheaterName][j]
				PlayerQuestTbl[PlayerTbl[i]]["VarName"] = TheaterName
				PlayerQuestTbl[PlayerTbl[i]]["AddNum"] = 1
			end
		end
	end
	return PlayerQuestTbl
end

--��ո�����ĳ���������
function RoleQuestDB.DeleteQuestVar(sQuestName, uCharId, sVarName)
	StmtContainer._DeleteQuestVar:ExecSql("", sQuestName, uCharId, sVarName)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

--��������
function RoleQuestDB.GiveUpQuestSql(sQuestName, uCharId)
	StmtContainer._GiveUpQuestSql:ExecSql("", sQuestName, uCharId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

local function GetAllQuestVar(uCharId)
	local vartbl = {}
	local delQuestTbl = {}
	local res = StmtContainer._GetAllQuestVar:ExecSql("s[32]s[128]n", uCharId)
 	for i = 1, res:GetRowNum() do
 		local questname = res:GetData(i-1, 0)
 		local varname = res:GetData(i-1, 1)
 		local varnum = res:GetData(i-1, 2)
 		if g_QuestNeedMgr[questname] and g_QuestNeedMgr[questname][varname] then
	 		if vartbl[questname] == nil then
				vartbl[questname] = {}
			end
	 		table.insert(vartbl[questname],{varname, varnum})
	 	else
	 		table.insert(delQuestTbl,questname)
	 	end
 	end
 	res:Release()
 	
 	for i=1, #(delQuestTbl) do
 		StmtContainer._GiveUpQuestSql:ExecStat(delQuestTbl[i], uCharId)
 	end
 	
 	return vartbl
end

--��ȡĳ���������������� ����
function RoleQuestDB.GetAllQuestVar(uCharId)
	return GetAllQuestVar(uCharId)
end

local function GetAllQuestSql(uCharId)
	local DbQuestAll = {}
	local delQuestTbl = {}
	local Ret = StmtContainer._GetAllQuestSql:ExecStat(uCharId)
	for i=1, Ret:GetRowNum() do
		local questname = Ret:GetData(i-1, 0)
		if Quest_Common(questname) then
			table.insert(DbQuestAll, {questname, Ret:GetData(i-1, 1), Ret:GetData(i-1, 2), Ret:GetData(i-1, 3)})
		else
			table.insert(delQuestTbl,questname)
		end
	end
	Ret:Release()
	
	--����߻��Ѿ�ȥ�����������,�ʹ����ݿ��а���ɾ����
	for i=1, #(delQuestTbl) do
		StmtContainer._GiveUpQuestSql:ExecStat(delQuestTbl[i], uCharId)
	end
	
	return DbQuestAll
end

--�õ�ĳ����ҵ���������
function RoleQuestDB.GetAllQuestSql(uCharId)
	return GetAllQuestSql(uCharId)
end

local StmtDef = {
	"_GetAllAwardItemFromQuest",
	[[
		select
			q_sName,qt_ItemIndex
		from
			tbl_quest_tempitem
		where
			cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

--�õ�����Ӷ������,��ȡʱ,Ҫ��������ҵ���Ʒ
local function GetAllQuestAwardItemSql(uCharId)
	local QusetAwardItem = {}
	local Ret = StmtContainer._GetAllAwardItemFromQuest:ExecStat(uCharId)
	for i=1, Ret:GetRowNum() do
		local QuestName = Ret:GetData(i-1, 0)
		local AwardItemIndex = Ret:GetData(i-1, 1)
		QusetAwardItem[QuestName] = AwardItemIndex
	end
	Ret:Release()
	return QusetAwardItem
end

function RoleQuestDB.GetAllQuestAwardItemSql(uCharId)
	return GetAllQuestAwardItemSql(uCharId)
end

local StmtDef = {
	"_GetAllFinishQuest",
	[[
		select q_sName, q_tAcceptTime, q_tFinishTime from tbl_quest where q_state = 3 and cs_uId = ?
	]]
}
DefineSql( StmtDef, StmtContainer )

local function GetAllYbFinishQuest(uCharId)
	local DbQuestAll = {}
	local Ret = StmtContainer._GetAllFinishQuest:ExecSql("s[32]nn",uCharId)
	for i=1, Ret:GetRowNum() do
		local QuestName = Ret:GetData(i-1, 0)
		if g_AllMercenaryQuestMgr[QuestName] then--��Ӷ������
			DbQuestAll[QuestName] = {Ret:GetData(i-1, 1), Ret:GetData(i-1, 2)}
		end
	end
	Ret:Release()
	return DbQuestAll
end

function RoleQuestDB.GetAllYbFinishQuest(data)
	local uCharId = data["PlayerId"]
	return GetAllYbFinishQuest(uCharId)
end

local function GetNowQuestSql(uCharId)
	local DbNowQuest = {}
	local res = StmtContainer._GetNowQuestSql:ExecSql("s[32]s[128]n", uCharId)
 	for i = 1, res:GetRowNum() do
 		local questname = res:GetData(i-1, 0)
 		DbNowQuest[questname] = DbNowQuest[questname] or {}
 		local varname, varnum = res:GetData(i-1, 1), res:GetData(i-1, 2)
 		DbNowQuest[questname][varname] = varnum
 	end
 	res:Release()
 	return DbNowQuest
end

--�õ�������ڽ����е�����
function RoleQuestDB.GetNowQuestSql(uCharId)
	return GetNowQuestSql(uCharId)
end

local function GetItemVarNum(PlayerId,sQuestName,ItemType, ItemName)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local inbagnum = g_RoomMgr.GetItemCount(PlayerId, ItemType, ItemName)
	local neednum = g_QuestNeedMgr[sQuestName][ItemName].Num
	local ItemTbl = {}
	ItemTbl["QuestName"] = sQuestName
	ItemTbl["ItemType"] = ItemType
	ItemTbl["ItemName"] = ItemName
	if inbagnum > neednum then
		ItemTbl["DoNum"] = neednum
	else
		ItemTbl["DoNum"] = inbagnum
	end
	StmtContainer._SetQuestVarNum:ExecSql("", ItemTbl["DoNum"], PlayerId, sQuestName, ItemName)
--	print("StmtContainer._SetQuestVarNum,g_DbChannelMgr:LastAffectedRowNum() > 0",g_DbChannelMgr:LastAffectedRowNum() > 0)
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return ItemTbl
	else
		return nil
	end
end

local function check_quest_var_full(sVarName, sQuestName, nCount)
	--[[
	�鿴������Ʒ�Ƿ��Ѿ����� ����Ϊ����������������������Ʒ��Ŀ
	--]]
	for varname, p in pairs(g_QuestNeedMgr[sQuestName]) do
		if varname == sVarName then
			return p.Num == nCount
		end
	end
	return false
end

local function IncreQuestItemVar(PlayerId,ItemType, ItemName, nCount)
	local QuestItemTbl = {}
	if g_ItemQuestMgr[ItemName] then
		for i = 1, table.getn(g_ItemQuestMgr[ItemName]) do
			if ItemType == g_ItemQuestMgr[ItemName][i][1] then
				local sQuestName = g_ItemQuestMgr[ItemName][i][2]
				local ItemTbl = GetItemVarNum(PlayerId,sQuestName, ItemType, ItemName)
				table.insert(QuestItemTbl,ItemTbl)
			end
		end
	end
	return QuestItemTbl
end

--local function add_item(PlayerId,ItemType, ItemName,nCount, res)
--	if not IsTable(res) then
--		return {}
--	end
--	return IncreQuestItemVar(PlayerId,ItemType, ItemName, nCount)
--end

----------------�¼Ӻ���-----------------
local function CountReturn(DBLevel,PlayerYbLevel,LoopNum,str)
	str = string.gsub( str, "yblevel", PlayerYbLevel or 0)
	str = string.gsub( str, "level", DBLevel)
	str = string.gsub( str, "loop", LoopNum)
	local count = assert(loadstring( "return " .. str))()
	count = math.floor(count)
	return count
end

local function CountReturnSoulPearl(DBLevel,PlayerYbLevel,LoopNum,str)
	local i = string.find(str, ":")
	return string.sub(str, 1, i) .. CountReturn(DBLevel,PlayerYbLevel,LoopNum,string.sub(str, i+1))
end

--���ر�����ģ�����ֵ�ͻ�ֵ��
local function CountAddExpAndSoulNum(PlayerLevel,PlayerYbLevel,LoopNum,QuestName)
	local questExp   = 0
	local questSoul  = 0
	
	if Quest_Common(QuestName, "���齱��") then
		local str = Quest_Common(QuestName, "���齱��", "Subject")
		if str and str ~= "" then
			questExp = CountReturn(PlayerLevel,PlayerYbLevel,LoopNum,str)
		end
		
		str = Quest_Common(QuestName, "���齱��", "Arg")
		if str and str ~= "" then
			questSoul = CountReturn(PlayerLevel,PlayerYbLevel,LoopNum,str)
		end
		
		if g_MasterStrokeQuestMgr[QuestName] then
			local str = Quest_Common(QuestName, "����ȼ�")
			local QuestLevel = CountReturn(PlayerLevel,PlayerYbLevel,LoopNum,str)
			QuestLevel = (QuestLevel~=0 and QuestLevel) or 1
			
			--������ȼ��������ȡ�ȼ�ʱ�����100%���飬����ö����ֵ
			--������ȼ��������ȡ�ȼ���1ʱ�����100%���飬����ö����ֵ
			
			if PlayerLevel - QuestLevel >= 3 then
				--������ȼ��������ȡ�ȼ���2ʱ�����50%���飬��ö���50%��ֵ
			--	questSoul = questSoul+Coefficient*questExp*0.5
				questExp = questExp*0.5
			--elseif PlayerLevel - QuestLevel >= 3 then
			--	--������ȼ��������ȡ�ȼ���3ʱ������þ��飬��ö���100%��ֵ
			--	questSoul = questSoul+Coefficient*questExp
			--	questExp = 0
			end
			
		end
	end
	questExp = math.floor(questExp)
	questSoul = math.floor(questSoul)
	return questExp,questSoul
end

--��ÿ��Եõ���Ӷ������ֵ
local function GetMercenaryIntegralNum(PlayerLevel,PlayerYbLevel,LoopNum,QuestName)
	local questMercenaryIntegral = 0
	local strIntegral = Quest_Common(QuestName, "Ӷ�����ֽ���")
	if strIntegral then
		if strIntegral ~= "" then
			questMercenaryIntegral = CountReturn(PlayerLevel,PlayerYbLevel,LoopNum,strIntegral)
		end
		
		--local MinLevel = nil
		--if questInfo["��������СӶ���ȼ�"] and questInfo["��������СӶ���ȼ�"][1].Subject then
		--	MinLevel = questInfo["��������СӶ���ȼ�"][1].Subject
		--	for i=1, #(MercenaryLevel_Common) do
		--		if MercenaryLevel_Common[i].MercenaryLevel == MinLevel then
		--			MinLevel = i
		--			break
		--		end
		--	end
		--end
		
		--if MinLevel and (PlayerYbLevel - MinLevel) >= 2 then
		--	questMercenaryIntegral = 0
		--end
	end
	return questMercenaryIntegral
end

local function AddQuest(data)
	local PlayerId = data["PlayerId"]
	local sQuestName = data["QuestName"]
	local uExpMultiple = data["ExpMultiple"]
	local skillNeedQuestInfoTbl = data["skillNeedQuestInfoTbl"]
	local LoopNum = data["LoopNum"]
	
	--���Ӷ���ȼ�״̬�����ȫ�����������������ܽ�
	--local MercenaryLevelDB = RequireDbBox("MercenaryLevelDB")
	--local param = {}
	--param["CharId"] = PlayerId
	--local MercenaryLevel, Status = MercenaryLevelDB.GetMercenaryLevelInfo(param)
	--if MercenaryLevel and MercenaryLevel<g_MercenaryLevelTbl.MaxLevel then
	--	local tbl = g_MercenaryLevelTbl[MercenaryLevel]["��ս����"]
	--	if tbl.Subject=="��ս����" and ( sQuestName==tbl.Arg[1] or sQuestName==tbl.Arg[2] or sQuestName==tbl.Arg[3] ) then
	--		if Status ~= 2 then
	--			CancelTran()
	--			return {false,"δ���ȫ�������������"}
	--		end
	--	end
	--end
	
	local state=RoleQuestDB.GetQuestState({PlayerId, sQuestName})
	if(state~=nil) then
		--�����Ѿ���ȡ��
		if state==QuestState.finish then
			if g_RepeatQuestMgr[sQuestName] then
			--�ж��Ƿ��Ѿ���ɸ������Ƿ��ǿ��ظ�����
				if not RoleQuestDB.UpdateQuestTime(os.time(),PlayerId,sQuestName) then
					CancelTran()
					return {false,3075} --"��������ʱ��ʧ��"
				end
				if not RoleQuestDB.UpdateQuestState(QuestState.init,PlayerId,sQuestName) then
					CancelTran()
					return {false,3076} --"��������״̬ʧ��"
				end
			else
				CancelTran()
				return {false,3077} --"���񲻿��ظ�"
			end
		elseif state==QuestState.failure then
				--�����Ѿ�ʧ�ܣ����½�ȡ����������״̬
			if not RoleQuestDB.UpdateQuestState(QuestState.init,PlayerId,sQuestName) then
				CancelTran()
				return {false,3076} --"��������״̬ʧ��"
			end
		else
			CancelTran()
			return {false, 3078} --"�����Ѿ���ȡ"
		end
	else
		if not RoleQuestDB.AddNewQuest(sQuestName,PlayerId,os.time(),uExpMultiple) then
			CancelTran()
			return {false,3079} --"�������ʧ��"
		end
	end		
	
	--�����������
	if g_QuestNeedMgr[sQuestName] then
		for i,p in pairs(g_QuestNeedMgr[sQuestName]) do
			if p.NeedType ~= "��Ʒ����" and not RoleQuestDB.AddNewQuestVar(sQuestName,PlayerId,i) then
				CancelTran()
				return {false,3080} --"����������ʧ��"
			end
		end
	end
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
		--�����������
	local give_items={}
	if Quest_Common(sQuestName, "�����Ʒ") then
		local Keys = Quest_Common:GetKeys(sQuestName, "�����Ʒ")
		for i = 1,table.getn(Keys) do
			local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����Ʒ", Keys[i])
			if tbl[3] then
				local give_type = tbl[1]
				local give_name = tbl[2]
				local give_num = tonumber(tbl[3])
				local add_num = give_num-g_RoomMgr.GetItemCount(PlayerId, give_type, give_name)
				if(add_num>0) then
					local params= {}
					params.nCharID = PlayerId
					params.nStoreMain = g_StoreRoomIndex.PlayerBag
					params.nBigID = give_type
					params.nIndex = give_name
					params.nCount = add_num
					params.createType = event_type_tbl["����Ʒ���ߵ��߸���"]
					local res = g_RoomMgr.AddItem(params)
					if IsNumber(res) then
						CancelTran()
						return {false,res}
					end
					table.insert(give_items,{give_type,give_name,add_num, res})
				end
			end
		end
	end
	
	--��Ҫ�õ���Ӷ����ƷID
	local IsSucc, YbItemIndex = InsertAwardItemIndex(PlayerId, sQuestName)
	if not IsSucc then
		CancelTran()
		return {false, 3082} --"���ݴ洢Ӷ��������Ʒʧ��"
	end
	
	--���Ǻ���תְ�¼�����������ж��Ƿ��Ѿ�תְ���Ѿ�תְ�Ļ�ֱ�ӼӼ���
	local QuestVarTbl = {}
	if g_VarQuestMgr["���תְ"] then
		for i=0,#g_VarQuestMgr["���תְ"] do
			if g_VarQuestMgr["���תְ"][i] == sQuestName then
				local FightSkillDB = RequireDbBox("FightSkillDB")
				local IsSeries = FightSkillDB.IsSeries(PlayerId)
				if IsSeries then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "���תְ"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
					if QuestVarTbl[1][PlayerId][1][3] == false then
						CancelTran()
						return {false, 22222}
					end
				end
			end
		end
	end
	
	--���Ǻ���Ӷ������ս�¼�����������ж��Ƿ��Ѿ���ɣ��Ѿ���ɵĻ�ֱ�ӼӼ���
	if g_VarQuestMgr["���Ӷ������ս"] then
		for i=0,#g_VarQuestMgr["���Ӷ������ս"] do
			if g_VarQuestMgr["���Ӷ������ս"][i] == sQuestName then
				local GasTongWarDB = RequireDbBox("GasTongWarDB")
				local IsSendChallenge = GasTongWarDB.IsSendChallenge(PlayerId)
				if IsSendChallenge then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "���Ӷ������ս"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
				end
			end
		end
	end
	
	--���Ǻ����������¼�����������ж��Ƿ��Ѿ���ɣ��Ѿ���ɵĻ�ֱ�ӼӼ���
	if g_VarQuestMgr["���������"] then
		for i=0,#g_VarQuestMgr["���������"] do
			if g_VarQuestMgr["���������"][i] == sQuestName then
				local ActivityCountDB = RequireDbBox("ActivityCountDB")
				local Count = ActivityCountDB.GetActivityHistoryTimes(PlayerId, "Ӷ��ѵ���")
				if Count and Count>0 then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "���������"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
				end
			end
		end
	end
	
	--���Ǻ��������¼�����������ж��Ƿ��Ѿ���ɣ��Ѿ���ɵĻ�ֱ�ӼӼ���
	if g_VarQuestMgr["�������"] then
		for i=0,#g_VarQuestMgr["�������"] do
			if g_VarQuestMgr["�������"][i] == sQuestName then
				local ActivityCountDB = RequireDbBox("ActivityCountDB")
				local Count = ActivityCountDB.GetActivityHistoryTimes(PlayerId, "����ػ�������")
				if Count and Count>0 then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "�������"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
				end
			end
		end
	end
	
	if g_VarQuestMgr["��ɱ�С��ѡ�������˰�"] then
		for i=0,#g_VarQuestMgr["��ɱ�С��ѡ�������˰�"] do
			if g_VarQuestMgr["��ɱ�С��ѡ�������˰�"][i] == sQuestName then
				local ActivityCountDB = RequireDbBox("ActivityCountDB")
				local Count = ActivityCountDB.GetActivityHistoryTimes(PlayerId, "��С��ѡ�������˰�")
				if Count and Count>0 then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "��ɱ�С��ѡ�������˰�"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
				end
			end
		end
	end
	
	if g_VarQuestMgr["�������"] then
		for i=0,#g_VarQuestMgr["�������"] do
			if g_VarQuestMgr["�������"][i] == sQuestName then
				local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
				local TongID = GasTongBasicDB.GetTongID(PlayerId)
				if TongID>0 then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "�������"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
				end
			end
		end
	end
	
	if g_VarQuestMgr["��ɽ���"] then
		for i=0,#g_VarQuestMgr["��ɽ���"] do
			if g_VarQuestMgr["��ɽ���"][i] == sQuestName then
				local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
				local InitiatorId = GasTongBasicDB.GetTongInitiator( GasTongBasicDB.GetTongID(PlayerId) )
				if InitiatorId == PlayerId then
					local param = {}
					param["char_id"] = PlayerId
					param["sVarName"] = "��ɽ���"
					param["iNum"] = 1
					param["CanShareTeamMateTbl"] = {}
					table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
				end
			end
		end
	end
	
	for _, BuildingName in pairs(TongProdItem_Common:GetKeys()) do
		local VarName = "���"..BuildingName
		if TongProdItem_Common(BuildingName, "Type") == 1 and g_VarQuestMgr[VarName] then
			for i=0,#g_VarQuestMgr[VarName] do
				if g_VarQuestMgr[VarName][i] == sQuestName then
					local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
					local GasTongbuildingDB = RequireDbBox("GasTongbuildingDB")
					local TongID = GasTongBasicDB.GetTongID(PlayerId)
					local Count = GasTongbuildingDB.CountBuildByName(TongID, BuildingName)
					if Count and Count>0 then
						local param = {}
						param["char_id"] = PlayerId
						param["sVarName"] = VarName
						param["iNum"] = Count
						param["CanShareTeamMateTbl"] = {}
						table.insert(QuestVarTbl, AddVarNumForTeamQuests(param))
					end
				end
			end
		end
	end
	
	local LoopQuestTbl = {"", 0}
	if Quest_Common(sQuestName, "��������") == 10 then
		local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "������", "1")
		local loopname = tbl[1]
		local loopnum = 0
		local res = StmtContainer._GetQuestLoop:ExecStat(PlayerId, loopname)
		local isfirstquest = false
		if not LoopNum then
			if g_LoopQuestMgr[loopname][1][1].QuestName == sQuestName then
				isfirstquest = true		--Ϊ��ֹĳЩԭ����������ݿ���Ϣ�쳣����������ٴν�ȡ��һ������ˢ�����ݿ��¼
			end
			if res and res:GetRowNum()>0 and not isfirstquest then
				loopnum = res:GetData(0, 0) + 1
			else
				loopnum = 1
			end
		else
			loopnum = LoopNum
		end
		StmtContainer._UpdateQuestLoop:ExecStat(PlayerId, loopname, loopnum)
		LoopQuestTbl = {loopname, loopnum}
	end
	
--	local QuestNeedVarTbl = {}
--	if Quest_Common(sQuestName, "��Ʒ����") then
--		local Keys = Quest_Common:GetKeys(sQuestName, "��Ʒ����")
--		for k = 1, table.getn(Keys) do
--			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", Keys[k], "Arg")
--			local needtype = Arg[1]
--			local needname = Arg[2]	--�������Ʒ��
--			if not g_QuestPropMgr[needname] 
--				or g_QuestPropMgr[needname][1] ~= needtype 
--				or g_QuestPropMgr[needname][2] ~= sQuestName then
--				local NeedVarTbl = GetItemVarNum(PlayerId,sQuestName, needtype, needname)
--				table.insert(QuestNeedVarTbl,NeedVarTbl)
--				--CancelTran()
--				--return false,"�ı������Ŀʧ��"
--			end
--		end
--	end
--	local IncreQuestItemVarTbl = {}
--	for i=1, table.getn(give_items) do
--		local give_type,give_name,num,res=give_items[i][1],give_items[i][2],give_items[i][3],give_items[i][4]
--		local itemTbl = add_item(PlayerId,give_type, give_name,num, res)
--		table.insert(IncreQuestItemVarTbl,itemTbl)
--	end
	
	--Renton����ӵ���һ��ѧϰ���ܵ�������ô���������ж����еļ��ܵĵȼ��Ƿ���ڵ������������ȼ�
	--�ֲ�����skillLevelNeed �洢���
	local skillQuestTbl = {}
	if skillNeedQuestInfoTbl then
		local skillname = ""
		local skilllevel = 0
		local nowskilllevel = 0
		local nowskilllevel_value = -1
		local result = false
		local varname = ""
		local skillQuestTbl_i = 0
		local skillLevelMatchNeed = false
		for _,v in pairs(skillNeedQuestInfoTbl) do
			if v.NeedType == "��������" then
				local FightSkillDB = RequireDbBox("FightSkillDB") 
				skillname = v.SkillName
				skilllevel = v.SkillLevel
				local datatbl = {}
				datatbl["PlayerId"] = PlayerId
				datatbl["SkillName"] = skillname
				datatbl["fs_kind"] = FightSkillKind.Skill
				result,nowskilllevel_value = FightSkillDB.Lua_SelectFightSkill(datatbl)
				
				--�ȼ���ת������ֵ�ȼ�ת��Ϊ���ܵȼ�
				local now_skill_level = -1
				if not SkillPart_Common(skillname,"PlayerLevelToSkillLevel") then
					LogErr(skillname.."������ȷ�ļ��ܵ���ʵ�����ߣ�SkillPart_Common�������ű���һ������������")
					CancelTran()
					return {false, 33333}
				else
					local temptbl = loadstring("return "..SkillPart_Common(skillname,"PlayerLevelToSkillLevel"))()
					for i,v in ipairs(temptbl) do
						if v[3] == nowskilllevel_value then
							now_skill_level = i
						end
					end
					skillLevelMatchNeed = false
					if result and (temptbl[1][3]=="l" or now_skill_level >= v.SkillLevel) then
						skillLevelMatchNeed = true
					end
				--�Ӽ���
					local temp_varname = _
					local addnum_tbl= {}
					if skillLevelMatchNeed then
						addnum_tbl["iNum"] = 1
						addnum_tbl["char_id"] = PlayerId
						addnum_tbl["sQuestName"] = sQuestName
						addnum_tbl["sVarName"] = temp_varname
						local RoleQuestDB = RequireDbBox("RoleQuestDB")
						local IsTrue = RoleQuestDB.AddQuestVarNum(addnum_tbl)					
							if IsTrue then
							skillQuestTbl_i = skillQuestTbl_i + 1
							skillQuestTbl[skillQuestTbl_i] = {}
							skillQuestTbl[skillQuestTbl_i]["iNum"] = 1
							skillQuestTbl[skillQuestTbl_i]["char_id"] = PlayerId
							skillQuestTbl[skillQuestTbl_i]["sQuestName"] = sQuestName
							skillQuestTbl[skillQuestTbl_i]["sVarName"] = temp_varname
							skillQuestTbl[skillQuestTbl_i].IsTrue = IsTrue
						else
							CancelTran()
							return {false, 44444}
						end
					end
				end
			end
		end
	end
	
	local DirectDB = RequireDbBox("DirectDB")
	local DirectTbl = DirectDB.AddPlayerQuestDirect(PlayerId, "��ȡ����", sQuestName)
	return {true,give_items,YbItemIndex,QuestVarTbl,DirectTbl,skillQuestTbl,LoopQuestTbl}
end

--�������
function RoleQuestDB.AddQuest(data)
	return AddQuest(data)
end

--GMָ�����������Ʒ
--function RoleQuestDB.GMAddQuestVar(data)
--	local lGMDBExecutor = RequireDbBox("GMDB")
--	local result = lGMDBExecutor.AddItem(data)
--	if result[1] then
--		local itemTbl = IncreQuestItemVar(data["player_id"],data["itemtype"], data["itemname"], data["count"])
--		return {result[1],result[2],itemTbl}
--	else
--		return result
--	end
--end

--�������ITEM,���ҷ�����ӵ�ITEM��Ϣ
--function RoleQuestDB.AddQuestItemVar(data)
--	if IsNumber(data["itemTbl"]) then
--		return {}
--	else
--		return add_item(data["char_id"],data["nType"], data["sName"], data["nCount"],data["itemTbl"])
--	end
--end

local function GMAddQuest(data)
	local QuestName = data["QuestName"]
	if not Quest_Common(QuestName) then
		return {false,3083} --"û�д�����"
	end
	local PlayerId = data["PlayerId"]
	local state = RoleQuestDB.GetQuestState({PlayerId, QuestName})
	if state ~= nil then
		if state == QuestState.init then
			if not RoleQuestDB.DeleteAllQuestVar(QuestName, PlayerId) then
				CancelTran()
				return {false,3084} --"����������ʧ��"
			end
		end
		if not RoleQuestDB.ClearQuest(QuestName,PlayerId) then
			CancelTran()
			return {false,3085} --"�������ʧ��"
		end
	end
	
	local RoleQuestTbl = RoleQuestDB.AddQuest(data)
	if RoleQuestTbl[1] then
		return {true,state,RoleQuestTbl[2],RoleQuestTbl[3],RoleQuestTbl[4],RoleQuestTbl[5],RoleQuestTbl[6],RoleQuestTbl[7]}
	else
		return RoleQuestTbl
	end
end

--GMָ���������
function RoleQuestDB.GMAddQuest(data)
	return GMAddQuest(data)
end

--GMָ���������
local function GMFinishQuest(data)
	local QuestName = data["QuestName"]
	local sceneName = data["sceneName"]
	if not Quest_Common(QuestName) then
		return {false,3086} --"���񲻴���"
	end
	
	local PlayerId = data["PlayerId"]
	local state = RoleQuestDB.GetQuestState({PlayerId, QuestName})
	if state == nil then
		return {false,3087} --"û�н�ȡ������"
	end
	if state == QuestState.finish then
		return {false,3088} --"���������"
	end
	
	local del_items={}
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	
	if Quest_Common(QuestName, "��Ʒ����") then
		local Keys = Quest_Common:GetKeys(QuestName, "��Ʒ����")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", QuestName, "��Ʒ����", Keys[k], "Arg")
			local needtype = Arg[1]
			local needname = Arg[2]		--�������Ʒ��
			local neednum = Arg[3]
			local have_num = g_RoomMgr.GetItemCount(PlayerId,needtype,needname)
			if needtype ~= 16 and have_num>=neednum then
				local res = g_RoomMgr.DelItem(PlayerId, needtype,needname,neednum,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false,3089} --"������Ʒɾ��ʧ��"
				end
				table.insert(del_items,{needtype,needname,neednum,res})
			elseif have_num>0 then
				local res = g_RoomMgr.DelItem(PlayerId, needtype,needname,have_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false,3089} --"������Ʒɾ��ʧ��"
				end
				table.insert(del_items,{needtype,needname,have_num,res})
			end
		end
	end
	
	--����������
	if not RoleQuestDB.DeleteAllQuestVar(QuestName,PlayerId) then
		CancelTran()
		return {false,3090} --"����������ʧ��"
	end
	--��������״̬
	if not RoleQuestDB.UpdateQuestState(QuestState.finish,PlayerId,QuestName) then
		CancelTran()
		return {false,300005} --"��������״̬ʧ��"
	end
	
	if not RoleQuestDB.UpdateCharFinishQuestNum(PlayerId,1) then
		CancelTran()
		return {false,3091} --"���������������ʧ��"
	end
	
	--����������
	if Quest_Common(QuestName, "�����Ʒ") then
		local Keys = Quest_Common:GetKeys(QuestName, "�����Ʒ")
		for i = 1,table.getn(Keys) do
			local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "�����Ʒ", Keys[i])
			if tbl[3] then
				local give_type = tbl[1]
				local give_name = tbl[2]
				local del_num = g_RoomMgr.GetItemCount(PlayerId,give_type,give_name)
				if(del_num>0) then
					local res = g_RoomMgr.DelItem(PlayerId, give_type, give_name,del_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
					if IsNumber(res) then
						CancelTran()
						return {false,res}
					end
					table.insert(del_items,{give_type,give_name,del_num, res})
				end
			end
		end
	end
	
	local LoopQuestTbl = {"", 0}
	local loopname, loopnum = "", 0
	if Quest_Common(QuestName, "��������") == 10 then
		local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������", "1")
		local res = StmtContainer._GetQuestLoop:ExecStat(PlayerId, tbl[1])
		if res and res:GetRowNum()>0 then
			local PlayerLevel = data["PlayerLevel"]
			loopname = tbl[1]
			loopnum = res:GetData(0, 0)
			local loopmgr = g_LoopQuestMgr[loopname][loopnum+1]
			local n = 0
			local temptbl = {}
			if loopmgr then
				for i=1, table.getn(loopmgr) do
					if sQuestName ~= loopmgr[i].QuestName
						and PlayerLevel >= loopmgr[i].MinLevel and PlayerLevel <= loopmgr[i].MaxLevel then
						table.insert(temptbl, loopmgr[i].QuestName)
					end
				end
				n = table.getn(temptbl)
				if n > 0 then
					LoopQuestTbl[1] = temptbl[math.random(1, n)]
					LoopQuestTbl[2] = loopnum+1
				end
			end
			if n <= 0 then
				StmtContainer._DeleteQuestLoop:ExecStat(PlayerId, loopname)
				LoopQuestTbl[1] = "LoopOver"
				LoopQuestTbl[2] = 0
			end
		end
	end
	
	local uExpMultiple = RoleQuestDB.GetQuestExpMultiple(PlayerId,QuestName)
	local succ,add_items,AddExpTbl,SoulRet,MercenaryLevelTbl,uAddSoul = RoleQuestDB.GiveQuestAward(data,uExpMultiple,sceneName,loopnum)
	if not succ then
		return {false,add_items}
	end
	--ȥ��ˢ�����ܣ������򸱱���ʽ����
--	local AreaDB = RequireDbBox("AreaDB")
--	local IsFinish, AreaName = AreaDB.FinishAreaQuest(PlayerId, QuestName)
--	if not IsFinish then
--		retun {false,nil}
--	end
	
	local delItemTbl = {}
	for i=1,table.getn(del_items) do
		local type,name,num,res=del_items[i][1],del_items[i][2],del_items[i][3],del_items[i][4]
		local Tbl = {}
		Tbl["nType"] = type
		Tbl["sName"] = name
		Tbl["nCount"] = num
		Tbl["res"] = res
		table.insert(delItemTbl, Tbl)
	end
	
	local DirectDB = RequireDbBox("DirectDB")
	local DirectTbl = DirectDB.AddPlayerQuestDirect(PlayerId, "�������", QuestName)
	
	local addItemTbl = {}
--	local param = {}
--	param["char_id"] = PlayerId
	for i=1, table.getn(add_items) do
--		param["nType"] = add_items[i][1]
--		param["sName"] = add_items[i][2]
--		param["nCount"] = add_items[i][3]
--		param["itemTbl"] = add_items[i][4]
		local Tbl = {}
		--Tbl["QuestItemVar"] = RoleQuestDB.AddQuestItemVar(param)
		Tbl["nType"] = add_items[i][1]
		Tbl["sName"] = add_items[i][2]
		Tbl["nCount"] = add_items[i][3]
		Tbl["res"] = add_items[i][4]
		Tbl["msgType"] = add_items[i][5]
		DirectDB.AddPlayerItemDirect(PlayerId, "��������Ʒ", Tbl["nType"], Tbl["sName"], DirectTbl)
		table.insert(addItemTbl, Tbl)
	end
	
	local AddLoopQuestResult = nil
	if LoopQuestTbl[1] ~= "" and LoopQuestTbl[1] ~= "LoopOver" then
		local param = {}
		param["PlayerId"] = PlayerId
		param["QuestName"] = LoopQuestTbl[1]
		param["sceneName"] = sceneName
		param["LoopNum"] = LoopQuestTbl[2]
		AddLoopQuestResult = AddQuest(param)
	end
	
	return {true,delItemTbl,addItemTbl,AddExpTbl,SoulRet,MercenaryLevelTbl,DirectTbl,LoopQuestTbl,uAddSoul,AddLoopQuestResult}
end

function RoleQuestDB.GMFinishQuest(data)
	return GMFinishQuest(data)
end

local function CanAcceptQuest(data)
	local PlayerId = data["PlayerId"]
	local JoinActionDB = RequireDbBox("JoinActionDB")
	if not JoinActionDB.CheckWarnValue(PlayerId) then
		return false
	end
	
	local sQuestName = data["QuestName"]
	local QuestNode = Quest_Common(sQuestName)
	local state = RoleQuestDB.GetQuestState({PlayerId,sQuestName})
	if state == QuestState.init then
		return false,3063 --"�������Ѿ��д�����"
	end
	if(state~=nil and state==QuestState.finish and 
		not g_RepeatQuestMgr[sQuestName]) then
		--�ж��Ƿ��Ѿ���ɸ������Ƿ��ǿ��ظ�����
		return false,3064 --"���ǿ��ظ�����"
	end
	
	--�жϽ���������ǲ��ǳ���10��
	local QuestNumRes = StmtContainer._GetDoingQuestNum:ExecSql("s[32]", PlayerId)
	if(QuestNumRes:GetRowNum() >= 10) then
		local iQuestNum = {0,0,0,0}
		for i=1, QuestNumRes:GetRowNum() do
			local QuestName = QuestNumRes:GetData(i-1, 0)
			if g_AllMercenaryQuestMgr[QuestName] then--��Ӷ������
				iQuestNum[1] = iQuestNum[1] + 1
			elseif g_DareQuestMgr[QuestName] then
				iQuestNum[2] = iQuestNum[2] + 1
			elseif g_ActionQuestMgr[QuestName] then
				iQuestNum[3] = iQuestNum[3] + 1
			else
				iQuestNum[4] = iQuestNum[4] + 1
			end
		end
		QuestNumRes:Release()
		local CheckNum = 4
		if g_AllMercenaryQuestMgr[sQuestName] then--��Ӷ������
			CheckNum = 1
		elseif g_DareQuestMgr[sQuestName] then
			CheckNum = 2
		elseif g_ActionQuestMgr[sQuestName] then
			CheckNum = 3
		end
		if iQuestNum[CheckNum] >= 10 then
			return false,3065 --"���������Ѿ���������,��������ͬʱ��10������"
		end
	end
	
	
	--����������,�ǲ��ǿ��Խ�
	if sQuestName == "��˹�ֿ˵�ף��" then
		local param = {}
		param["PlayerId"] = PlayerId
		param["ActivityName"] = sQuestName
		local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
		if not ActivityCountDbBox.CheckSinglePlayerActivityCount(param) then
			return false,3066 --"������һ��,�Ѿ�����һ��ί����,��������ս��,Ӷ��"
		end
	end
	
	--�ж�ǰ������(�����,������)
	if QuestNode("ǰ������") then
		local Keys = QuestNode:GetKeys("ǰ������")
		local IsAvailable = true
		local IsEffective = false
		for i = 1,table.getn(Keys) do
			local Subject = QuestNode("ǰ������", Keys[i], "Subject")
			local Arg = QuestNode("ǰ������", Keys[i], "Arg")
			if Subject ~= "" then
				IsEffective = true
				local pre_state = RoleQuestDB.GetQuestState{PlayerId, Subject}
				if Arg == "�����" and pre_state ~= QuestState.finish then
					IsAvailable = false
				elseif Arg == "������" and pre_state ~= QuestState.finish and pre_state ~= QuestState.init then
					IsAvailable = false
				end
			end
		end
		if IsEffective and not IsAvailable then
			return false,3068 --"ǰ��������δ���"
		end
	end
	
	--�ж�ǰ������(����һ������״̬����,����)
	if QuestNode("����ǰ��������һ") then
		local Keys = QuestNode:GetKeys("����ǰ��������һ")
		local IsAvailable = false
		local IsEffective = false
		for i = 1,table.getn(Keys) do
			local Subject = QuestNode("����ǰ��������һ", Keys[i], "Subject")
			local Arg = QuestNode("����ǰ��������һ", Keys[i], "Arg")
			if Subject ~= "" then
				IsEffective = true
				local pre_state = RoleQuestDB.GetQuestState{PlayerId, Subject}
				if Arg == "�����" and pre_state == QuestState.finish then
					IsAvailable = true
					break
				elseif Arg == "������" and pre_state ~= QuestState.failure then
					IsAvailable = true
					break
				end
			end
		end
		if IsEffective and not IsAvailable then
			return false,3068 --"ǰ��������δ���"
		end
	end
	
	local PlayerCamp = data["PlayerCamp"]
	local PlayerLev = data["PlayerLevel"]
	local PlayerYbLev = data["PlayerYbLevel"]
	
	if not IfAcceptQuestCamp(PlayerCamp, sQuestName) then     --��Ӫ�ж�
		return false,3069 --"�����Ӫ������"
	end
	
	if not IfAcceptQuestMinLev(PlayerLev, sQuestName) then    --�ȼ��ж�
		return false,3070 --"��ĵȼ�����"
	end
	
	if not IfAcceptQuestMaxLev(PlayerLev, sQuestName) then    --�ȼ��ж�
		return false,300023 --"��ĵȼ�����"
	end
	
	if g_AllMercenaryQuestMgr[sQuestName] then
		if not CmpMercenaryLevel(PlayerYbLev, sQuestName) then
			return false,3071 --"���Ӷ���ȼ�����"
		end
	end
	
	local TongLevLimit = QuestNode("Ӷ��������")
	if TongLevLimit and TongLevLimit ~= 0 then
		local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
		local TongLev = GasTongBasicDB.GetTongLevel(GasTongBasicDB.GetTongID(PlayerId))
		if TongLev < TongLevLimit then
			return false, 300024, {TongLevLimit}
		end
	end
	
	--ʱ���޴μ��
	local GMTimeCountLimit = data["GMTimeCountLimit"]
	local TimeCountNode = QuestNode("ʱ���޴�")
	if TimeCountNode and GMTimeCountLimit == 1 then
		local TimeTbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "ʱ���޴�", "Subject")
		local Cycle = TimeTbl[3]
		local Count = TimeCountNode("Arg")
		local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
		local TongId = GasTongBasicDB.GetTongID(PlayerId)
		local TongType = GasTongBasicDB.GetTongType(TongId)
		if TongId~=0 and (sQuestName == "������ί�С���ʼ����" or sQuestName == "��ʥ��ί�С���ʼ����" or sQuestName == "��˹��ί�С���ʼ����")
			and (TongType == g_TongMgr:GetTongTypeByName("����") or TongType == g_TongMgr:GetTongTypeByName("��Ӣ����")) then
			Count = Count + 1
		end
		local secc1, secc2 = CheckQuestTimeCount(sQuestName, PlayerId, TimeTbl, Count)
		if not secc1 then
			if secc2 then
				if secc1 == false then
					return false, 300006 --"û����ȡʱ�䣬���ڻ����ܽ�ȡ������"
				else
					return false, 300025 --"û����ȡʱ�䣬���ڻ����ܽ�ȡ������"
				end
			else
				if Cycle >= 1 then
					return false, 300007, {Cycle, Count} --"Cycle.."Сʱ֮����ֻ�����"..Count.."�θ�����"
				else
					return false, 300019, {Cycle*60, Count}
				end
			end
		end
	end
	
	local mutexQuestTbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����ϵ")
	if mutexQuestTbl then
		if QuestNode("ʱ���޴�") then
			for _, name in pairs(mutexQuestTbl) do
				if name ~= sQuestName then
					local q_state = RoleQuestDB.GetQuestState{PlayerId, name}
					if q_state and q_state ~= QuestState.finish then 
						return false, 300027
					end
				end
			end
			local TimeTbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "ʱ���޴�", "Subject")
			local Cycle = TimeTbl[3]
			local Count = TimeCountNode("Arg")
			for _, name in pairs(mutexQuestTbl) do
				if name ~= sQuestName then
					local secc1, secc2 = CheckQuestTimeCount(name, PlayerId, TimeTbl, Count)
					if not secc1 then
						if Cycle >= 1 then
							return false, 300028, {Cycle, Count} --"Cycle.."Сʱ֮����ֻ�����"..Count.."�θ�����"
						else
							return false, 300029, {Cycle*60, Count}
						end
					end
				end
			end
		else
			for _, name in pairs(mutexQuestTbl) do
				local q_state = RoleQuestDB.GetQuestState{PlayerId, name}
				if q_state ~= nil then 
					return false,3067 --"���񻥳�"
				end
			end
		end
	end
	
	--��ȴʱ����
	local CDTime = QuestNode("��ȴʱ��")
	if CDTime and CDTime~=0 then
		local secc, str = CheckQuestCD(sQuestName, PlayerId, CDTime)
		if not secc then
			return false, 300008, {CDTime, str} --"������"..CDTime.."Сʱ��ֻ�ܽ�ȡһ��, ����"..str.."������"
		end
	end
	
	--�����ȡʱ����
	if QuestNode("�����ȡʱ��") then
		local secc = CheckStartTime(sQuestName)
		if not secc then
			return false, 300013	--"��û��������Ľ�ȡʱ��, ���һ�������"
		end
	end
	
	return true
end

--�ж��Ƿ���Խ�ȡ����
function RoleQuestDB.CanAcceptQuest(data)
	return CanAcceptQuest(data)
end

local function AcceptQuestNumLimit(PlayerId, TypeTbl, ActivityName)
	local mercParam = {}
	mercParam["PlayerId"] = PlayerId
	mercParam["ActivityName"] = ActivityName
	local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
	local IsAllow, FinishTimes = ActivityCountDbBox.CheckSinglePlayerActivityCount(mercParam)
	if not IsAllow then
		return false , FinishTimes
	else
		--print("1.......", FinishTimes)
		--�жϽ���������ǲ��ǳ���10��
		local QuestNumRes = StmtContainer._GetDoingQuestNum:ExecSql("s[32]", PlayerId)
		if QuestNumRes:GetRowNum() > 0 then
			for i=1, QuestNumRes:GetRowNum() do
				local sQuestName = QuestNumRes:GetData(i-1,0)
				if g_AllMercenaryQuestMgr[sQuestName] then
					local MercenaryType = Quest_Common(sQuestName, "Ӷ����������")
					--�����Ӷ���ճ�����,��������Ƿ��Ѿ������10��
					if TypeTbl[MercenaryType] then
						FinishTimes = FinishTimes + 1
					end
				end
			end
			QuestNumRes:Release()
		end
		--print("2.......", FinishTimes)
		if FinishTimes >= ActivityCountDbBox.GetActivityCount(ActivityName) then
			return false, FinishTimes
		end
	end
	return true
end

local function AcceptQuest(data)
	local PlayerId = data["PlayerId"]
	local QuestName = data["QuestName"]
	--�ȼ��һ�½��˼���Ӷ������,���ҽ�������˼�����
	if g_AllMercenaryQuestMgr[QuestName] then
		local MercenaryType = Quest_Common(QuestName, "Ӷ����������")
		--�����Ӷ���ճ����������С������,��������Ƿ��Ѿ������10��
		local ActivityName = nil
		if MercenaryType == 1 then
			local res1, msgInfo = AcceptQuestNumLimit(PlayerId, {[1]=true}, "Ӷ���ճ�����")
			if not res1 then
				return {false, 300009, {msgInfo}}--"�������ȡ����ɵ�Ӷ���ճ�����ĸ����Ѿ���10���������ٽ�ȡӶ���ճ�������"
			end
		elseif MercenaryType == 6 then
			local res,DBTime = GetQuestStateFinishTime(PlayerId,QuestName)
			if res and res == QuestState.finish then
				local nowDate = os.date("*t",os.time())
				local dbDate = os.date("*t",DBTime)
				if (nowDate.year == dbDate.year)
					and (nowDate.month == dbDate.month)
					and (nowDate.day == dbDate.day) then
					return {false, 300020}--�����ͬһ��Ļ�,�Ͳ��ý����������,ͬһ������,1��ֻ����һ��
				end
			end
		elseif MercenaryType == 7 then
			local res1, msgInfo = AcceptQuestNumLimit(PlayerId, {[7]=true}, "Ӷ��С������")
			if not res1 then
				return {false, 300014, {msgInfo}}--"�������ȡ����ɵ�Ӷ���ճ�����ĸ����Ѿ���10���������ٽ�ȡӶ���ճ�������"
			end
		end
	end
	
	local succ,id,arg = RoleQuestDB.CanAcceptQuest(data)
	if not succ then
		return {false,id,arg}
	else
		local result = RoleQuestDB.AddQuest(data)
		if result[1] then
			if data["QuestName"] == "��˹�ֿ˵�ף��" then
				local param = {}
				param["PlayerId"] = data["PlayerId"]
				param["ActivityName"] = data["QuestName"]
				local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
				ActivityCountDbBox.AddActivityCount(param)
			end
		end
		return result
	end
end

--��һ���µ�����
function RoleQuestDB.AcceptQuest(data)
	return AcceptQuest(data)
end

local function ItemRequestQuest(data)
	local sQuestName = data["QuestName"]
	local PlayerId = data["PlayerId"]
	local sceneName = data["sceneName"]
	local ItemName = data["ItemName"]
	local ItemType = 1
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local del_num = g_RoomMgr.GetItemCount(PlayerId, 1, ItemName)
	if del_num < 1 then
		ItemType = 16
		del_num = g_RoomMgr.GetItemCount(PlayerId, 16, ItemName)
		if del_num < 1 then
			return {false, 3072} --"�����������Ʒ������Ҫ��"
		end
	end
	
	--���������Ʒ
	local del_items = {}
	local res = g_RoomMgr.DelItem(PlayerId, ItemType,ItemName,1,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
	if IsNumber(res) then
		CancelTran()
		return {false, 3073} --"���������Ʒʧ��"
	end
	table.insert(del_items,{ItemType,ItemName,1,res})

	local succ,id,arg = RoleQuestDB.CanAcceptQuest(data)
	if not succ then
		CancelTran()
		return {false,id,arg}
	else
		return RoleQuestDB.AddQuest(data),del_items
	end
end

--��Ʒ��������
function RoleQuestDB.ItemRequestQuest(data)
	local PlayerId = data["PlayerId"]
	local PlayerQuestInfo,DelItem = ItemRequestQuest(data)
	
	local TeamMemberQuestInfo = {}
	if PlayerQuestInfo[1] and data["IsYbQuestItem"] then
		local GasTeamDB =  RequireDbBox("GasTeamDB")
		local TeamID = GasTeamDB.GetTeamID(PlayerId)
		if TeamID and TeamID ~= 0 then
			local tblMembers = GasTeamDB.GetTeamMembers(TeamID)
			
			local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
			
			local param = {}
			param["QuestName"] = data["QuestName"]
			param["PlayerCamp"] = data["PlayerCamp"]
			param["sceneName"] = data["sceneName"]
			for i=1, #(tblMembers) do
				local id = tblMembers[i][1]--�õ���ɫ��ID
				if PlayerId ~= id then
					param["PlayerId"] = id
					local Lev_Exp = CharacterMediatorDB.GetCharLevelExpDB({["char_id"] = id})
					local DBLevel = Lev_Exp:GetData(0,0)
					local DBYbLevel = Lev_Exp:GetData(0,2)
					param["PlayerLevel"] = DBLevel
					param["PlayerYbLevel"] = DBYbLevel
					local succ,id,arg = RoleQuestDB.CanAcceptQuest(param)
					if not succ then
						CancelTran()
						return {false,3074} --"������ʧ��,������,���˽����������������"
					end
				end
			end
		end
	end
	
	return PlayerQuestInfo,DelItem,TeamMemberQuestInfo
end

local function ShareQuest(data)
	local PlayerId = data["PlayerId"]
	local QuestName = data["QuestName"]
	local TeamId = data["TeamID"]
	local team = RequireDbBox("GasTeamDB")
	local tblMembers = team.GetTeamMembers(TeamId)
	if table.getn(tblMembers) == 0 then
		return {false,3007}
	end
	if RoleQuestDB.GetQuestState({PlayerId,QuestName}) ~= QuestState.init then
		return {false,3006}
	end
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local TeamQuestInfoTbl = {}
	for i=1, table.getn(tblMembers) do
		local teammateid = tblMembers[i][1]
		data["PlayerId"] = teammateid
		if PlayerId ~= teammateid and LoginServerSql.IsPlayerOnLine(teammateid) then
			data["char_id"] = teammateid
			local Lev_Exp = CharacterMediatorDB.GetCharLevelExpDB(data)
			local DBLevel = Lev_Exp:GetData(0,0)
			local DBYbLevel = Lev_Exp:GetData(0,2)
			Lev_Exp:Release()
			data["PlayerLevel"] = DBLevel
			data["PlayerYbLevel"] = DBYbLevel
 			local succ,id,arg = RoleQuestDB.CanAcceptQuest(data)
			local teamQuestTbl = {}
			teamQuestTbl["PlayerId"] = teammateid
			if succ then
				teamQuestTbl["IsCanShare"] = true
				teamQuestTbl["QuestName"] = QuestName
			else
				teamQuestTbl["IsCanShare"] = false
				teamQuestTbl["MsgID"] = id
				teamQuestTbl["Arg"] = arg or {}
			end
			table.insert(TeamQuestInfoTbl,teamQuestTbl)
 		end
 	end
 	return {true,TeamQuestInfoTbl}
end

--������
function RoleQuestDB.ShareQuest(data)
	return ShareQuest(data)
end

local function CheckNeedItemNum(PlayerId, ItemType, ItemName, CheckQuestNeed)
	local questmgr = g_WhereGiveQuestMgr["Goods"][ItemName]
	if questmgr and ItemType == 16 then
		local questname = questmgr[1]
		local queststate = RoleQuestDB.GetQuestState({PlayerId,questname})
		if queststate == nil or (queststate == QuestState.finish and g_RepeatQuestMgr[questname]) then
			return {true,1}
		end
	end
	if CheckQuestNeed and g_ItemQuestMgr[ItemName] then
		for i = 1, table.getn(g_ItemQuestMgr[ItemName]) do
			if ItemType == g_ItemQuestMgr[ItemName][i][1] then
				local parm = 
				{
					["sQuestName"] = g_ItemQuestMgr[ItemName][i][2],
					["iItemType"] = ItemType,
					["sItemName"] = ItemName,
					["uCharId"] = PlayerId
				}
				local NeedNum = RoleQuestDB.CheckQuestItemNeedNum(parm)				
				if NeedNum then
					return {true,NeedNum}
				end
			end
		end
		return {false,5}
	else
		local Only = g_ItemInfoMgr:GetItemInfo( ItemType, ItemName,"Only" )
		if Only == 1 then
			local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
			local havenum = g_RoomMgr.GetItemCount(PlayerId, ItemType, ItemName)
			if havenum >= 1 then
				return {false,4}
			else
				return {true,1}
			end
		end
		return {true,0}  --0������������������
	end
end

--����������Ʒ�Ƿ��Ѿ����㣬�����������Ʒ����
function RoleQuestDB.CheckNeedItemNum(PlayerId, ItemType, ItemName, CheckQuestNeed)
	return CheckNeedItemNum(PlayerId, ItemType, ItemName, CheckQuestNeed)
end

local function IntoTrapAddItem(data)
	local sQuestName = data["sQuestName"]
	local PlayerId = data["char_id"]
	if sQuestName and sQuestName ~= "" then
		if RoleQuestDB.GetQuestState({PlayerId,sQuestName}) ~= QuestState.init then
			return 5,nil
		end
	end
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	data["createType"] = event_type_tbl["��trap����Ʒ"]
	return CharacterMediatorDB.AddItem(data)
end

--��Trap,����Ҽ���Ʒ
function RoleQuestDB.IntoTrapAddItem(data)
	return IntoTrapAddItem(data)
end

local function SingleGridItem(data,IsTran)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local res1= CharacterMediatorDB.AddItem(data)
	if IsNumber(res1) then
		if not IsTran then
			CancelTran()
		end
		local RoomMgr = RequireDbBox("GasRoomMgrDB")
		return {false,res1}
	end
	return {true,res1}
end

--�����Ʒ,����1
function RoleQuestDB.SingleGridItem(data,IsTran)
	return SingleGridItem(data,IsTran)
end

--��ɵ�2���ճ�Ӷ������,����ʯ(10-19)
local function RandomGetStone()
	local tbl = {"�ֲڵĻ���ʯ","�ֲڵķ��ʯ","�ֲڵ�����ʯ","�ֲڵı���ʯ","�ֲڵĺ�ħʯ"}
	local num = math.random(1,#(tbl))
	return tbl[num]
end

--��ɵ�2���ճ�Ӷ������,���������Ʒ(20����)
local function RandomGetMercItem(DBPlayerYbLevel, PlayerCamp)
	if not PlayerCamp then
		--�����ҵ���ӪΪNIL,˵��1,����GM��ɵ�����,������Ʒ;2,������bug(����GM,��Ӧ�û�NIL)
		return
	end
	local ItemTbl = {}--Ŀǰ��2��,1��ʾ��׼����;2��ʾϡ������
	for _,ItemName in pairs(Mercenary_Quest_Server:GetKeys()) do
		local Tbl = Mercenary_Quest_Server(ItemName)
		local Camp = Tbl("Camp")
		local Type = Tbl("Type")
		if (Camp == 0 or Camp == PlayerCamp) and (Type == 1 or Type == 2) then--Ҫ��һ����Ӫ����Ʒ
			if not ItemTbl[Type] then
				ItemTbl[Type] = {}
			end
			table.insert(ItemTbl[Type],ItemName)
		end
	end
	
	if not ItemTbl[1] then
		return
	end
	
	
	local LenTbl = {0,0}
	
	for i,_ in pairs(ItemTbl) do
		if ItemTbl[i] then
			LenTbl[i] = #(ItemTbl[i])
		end
	end
	
	local Coef = 0
	if DBPlayerYbLevel >= 3 then
		Coef = DBPlayerYbLevel - 2
	end
	
	local MaxRandomNum = LenTbl[1]
	if ItemTbl[2] then
		MaxRandomNum = MaxRandomNum + LenTbl[2]*Coef
	end
	if MaxRandomNum == 0 then
		return
	end
	
	local num = math.random(1,MaxRandomNum)
	if num <= LenTbl[1] then
		return ItemTbl[1][num]
	else
		local iNum = math.random(1,LenTbl[2])
		return ItemTbl[2][iNum]
	end
end

--��ɵ�2���ճ�Ӷ������,�������Ʒ(�����͵���Ʒ)(55����)
local function RandomGetScopesItem(PlayerCamp)
	if not PlayerCamp then
		--�����ҵ���ӪΪNIL,˵��1,����GM��ɵ�����,������Ʒ;2,������bug(����GM,��Ӧ�û�NIL)
		return
	end
	local ItemTbl = {}--Ŀǰ��2��,1��ʾ��׼����;2��ʾϡ������
	for ItemName,Tbl in pairs(Mercenary_Quest_Server) do
		local Camp = Tbl.Camp
		local Type = Tbl.Type
		if (Camp == 0 or Camp == PlayerCamp) and (Type == 3 or Type == 4) then--Ҫ��һ����Ӫ����Ʒ
			if not ItemTbl[Type-2] then
				ItemTbl[Type-2] = {}
			end
			table.insert(ItemTbl[Type-2],ItemName)
		end
	end
	
	local LenTbl = {0,0}
	
	for i,_ in pairs(ItemTbl) do
		if ItemTbl[i] then
			LenTbl[i] = #(ItemTbl[i])
		end
	end
	
	local num = math.random(1,100)
	if num < 90 then
		if LenTbl[1] > 0 then
			local iNum = math.random(1,LenTbl[1])
			return ItemTbl[1][iNum]
		end
	else
		if LenTbl[2] > 0 then
			local iNum = math.random(1,LenTbl[2])
			return ItemTbl[2][iNum]
		end
	end
end

local vipBuffTbl = {
		["G��Ӷ������"] = true,
		["F��Ӷ������"] = true,
		["E��Ӷ������"] = true,
		["D��Ӷ������"] = true,
}

local function GiveQuestAward(data,uExpMultiple,sceneName,LoopNum)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local PlayerId = data["PlayerId"]
	local sQuestName = data["QuestName"]
	local QuestNode = Quest_Common(sQuestName)
	local SelectIndex = data["SelectIndex"]
	local TongId = data["PlayerTongID"]
	--local PlayerLevel = data["PlayerLevel"]
	data["char_id"] 		= PlayerId
	
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
	local MoneyManagerDB = RequireDbBox("MoneyMgrDB")
	local AreaFbPointDB = RequireDbBox("AreaFbPointDB")
	local LogMgr = RequireDbBox("LogMgrDB")
	local EquipMgrDB = RequireDbBox("EquipMgrDB")
	
	local Lev_Exp = CharacterMediatorDB.GetCharLevelExpDB(data)
	local DBLevel = Lev_Exp:GetData(0,0)
	local DBExp = Lev_Exp:GetData(0,1)
	local DBPlayerYbLevel = Lev_Exp:GetData(0,2)
	local DBIntegral = Lev_Exp:GetData(0,3)
	Lev_Exp:Release()
	
	local uEventId = LogMgr.FinishQuest(PlayerId, sQuestName)
	local res_tbl={}
	
	if g_DareMercenaryQuestMgr[sQuestName] then
		--Ӷ����ս������Ʒ�����ظ��Ľ���
		if Quest_Common(sQuestName, "��Ʒ����") then
			local Must_give = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", "Subject")
			local ItemIndex = GetAwardItemFromQuest(PlayerId, sQuestName)
			
			if ItemIndex and Must_give[ItemIndex] then
				local itemtype,name,num, BindingStyle=Must_give[ItemIndex][1],Must_give[ItemIndex][2],Must_give[ItemIndex][3],Must_give[ItemIndex][4]
				if g_ItemInfoMgr:IsSoulPearl(itemtype) then
					name = CountReturnSoulPearl(DBLevel,PlayerYbLevel,LoopNum,name)
				end
				local params= {}
				params.nCharID = PlayerId
				params.nStoreMain = g_StoreRoomIndex.PlayerBag
				params.nBigID = itemtype
				params.nIndex = name
				params.nCount = num
				params.BindingType = BindingStyle
				params.uEventId = uEventId
				local res = g_RoomMgr.AddItem(params)
				if IsNumber(res) then
					CancelTran()
					return false,res
				end
				table.insert(res_tbl,{itemtype,name,num,res})
			end
		end
		
	else
		if Quest_Common(sQuestName, "��Ʒ����") then
			--��Ʒ�����ظ��Ľ���
			local Must_give = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", "Subject")
			for i=1,table.getn(Must_give) do
				local itemtype,name,num, BindingStyle=Must_give[i][1],Must_give[i][2],Must_give[i][3],Must_give[i][4]
				if g_ItemInfoMgr:IsSoulPearl(itemtype) then
					name = CountReturnSoulPearl(DBLevel,PlayerYbLevel,LoopNum,name)
				end
				local params= {}
				params.nCharID = PlayerId
				params.nStoreMain = g_StoreRoomIndex.PlayerBag
				params.nBigID = itemtype
				params.nIndex = name
				params.nCount = num
				params.BindingType = BindingStyle
				params.uEventId = uEventId
				local res = g_RoomMgr.AddItem(params)
				if IsNumber(res) then
					CancelTran()
					return false,res
				end
				table.insert(res_tbl,{itemtype,name,num,res})
			end
			--��Ʒ������ѡ�Ľ���
			if SelectIndex~=nil and SelectIndex~=0 then
				local select_award = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", "Arg")
				if (select_award == nil or not select_award[SelectIndex]) then
					CancelTran()
					return false, 3093 --"�����ڿ�ѡ��Ʒ������"
				end
				local itemtype,name,num, BindingStyle = select_award[SelectIndex][1], select_award[SelectIndex][2], select_award[SelectIndex][3], select_award[SelectIndex][4]
				if g_ItemInfoMgr:IsSoulPearl(itemtype) then
					name = CountReturnSoulPearl(DBLevel,PlayerYbLevel,LoopNum,name)
				end
				local params= {}
				params.nCharID = PlayerId
				params.nStoreMain = g_StoreRoomIndex.PlayerBag
				params.nBigID = itemtype
				params.nIndex = name
				params.nCount = num
				params.BindingType = BindingStyle
				params.uEventId = uEventId
				local res = g_RoomMgr.AddItem(params)
				if IsNumber(res) then
					CancelTran()
					return false,res
				end
				table.insert(res_tbl, {itemtype,name,num,res})
			end
		end
		
	end
	
	------------------------------------------------------------
	--Ӷ����ս��Ʒ����
	local MercItemTbl = {}
	if data["IsGiveMercItem"] then
--		if DBLevel >= 10 and DBLevel < 20 then
--			local ItemName = RandomGetStone()
--			if ItemName then
--				table.insert(MercItemTbl, {38,ItemName,1})
--			end
--		elseif DBLevel >= 20 then--20�������
--			local ItemName = RandomGetMercItem(DBPlayerYbLevel,data["PlayerCamp"])
--			if ItemName then
--				table.insert(MercItemTbl, {1,ItemName,2})
--			end
--		end
		if DBLevel >= 20 then
			table.insert(MercItemTbl,{24,"Ӷ��������",5})
		end
	end
	if data["IsGiveScopesItem"] then
		if DBLevel >= 55 then--55�������
			local ItemName = RandomGetScopesItem(data["PlayerCamp"])
			if ItemName then
				table.insert(MercItemTbl, {1,ItemName,3})
			end
		end
	end
	
	for i=1, #(MercItemTbl) do
		local OtherItemType = MercItemTbl[i][1]
		local OtherItemName = MercItemTbl[i][2]
		local MsgID = MercItemTbl[i][3]
		
		local params= {}
			params.nCharID = PlayerId
			params.nStoreMain = g_StoreRoomIndex.PlayerBag
			params.nBigID = OtherItemType
			params.nIndex = OtherItemName
			params.nCount = 1
			params.uEventId = uEventId
		
		local res = g_RoomMgr.AddItem(params)
		if IsNumber(res) then
			CancelTran()
			return false,res
		end
		table.insert(res_tbl, {OtherItemType,OtherItemName,1,res,MsgID})
	end
	---------------------------------------------------------------
	
	--Ӷ�����ƽ���
	if g_AllMercenaryQuestMgr[sQuestName] and QuestNode("Ӷ�����ƽ���") then
		local MercenaryType = QuestNode("Ӷ����������")
		if MercenaryType >= 2 and MercenaryType <= 4 then
			local Merc_give = GetCfgTransformValue(true, "Quest_Common", sQuestName, "Ӷ�����ƽ���")
			for i=1,table.getn(Merc_give) do
				local itemtype,name,num, BindingStyle, Rate=Merc_give[i][1],Merc_give[i][2],Merc_give[i][3],Merc_give[i][4],Merc_give[i][5]
				local randnum = math.random(1,100)
				if randnum <= (Rate*100) then
					local params= {}
					params.nCharID = PlayerId
					params.nStoreMain = g_StoreRoomIndex.PlayerBag
					params.nBigID = itemtype
					params.nIndex = name
					params.nCount = num
					params.BindingType = BindingStyle
					params.uEventId = uEventId
					local res = g_RoomMgr.AddItem(params)
					if IsNumber(res) then
						CancelTran()
						return false,res
					end
					table.insert(res_tbl,{itemtype,name,num,res,4})
				end
			end
		end
	end
	
	local countstr = QuestNode("��Ǯ����")
	local money_info = {}
	--��Ǯ����
	--��������  ����
	if countstr and countstr~="" then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		local fun_info = g_MoneyMgr:GetFuncInfo("Quest")
		local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["MoneyAward"],PlayerId,count,uEventId)
		if not bFlag then
			CancelTran()
			if IsNumber(uMsgID) then
				return false, uMsgID
			else
				return false, 3094 --"��Ǯ����ʧ��"
			end
		end
		table.insert(money_info, {count, 1})
	end
	
	--�󶨵Ľ�Ǯ����
	countstr = QuestNode("�󶨵Ľ�Ǯ����")
	if countstr and countstr~="" then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		local fun_info = g_MoneyMgr:GetFuncInfo("Quest")
		local bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(fun_info["FunName"],fun_info["AddBindingMoney"],PlayerId, 2, count,uEventId)
		if not bFlag then
			CancelTran()
			if IsNumber(uMsgID) then
				return false,uMsgID
			else
				return false,3095
			end
		end
		table.insert(money_info, {count, 2})
	end
	
	--�󶨵�Ԫ������
	countstr = QuestNode("�󶨵�Ԫ������")
	if countstr and countstr~="" then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		local fun_info = g_MoneyMgr:GetFuncInfo("Quest")
		local bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(fun_info["FunName"],fun_info["AddBindingTicket"],PlayerId, 4, count,uEventId)
		if not bFlag then
			CancelTran()
			if IsNumber(uMsgID) then
				return false,uMsgID
			else
				return false,3096
			end
		end
		table.insert(money_info, {count, 3})
	end 
	
	--��������
	countstr = QuestNode("��������")
	if countstr and countstr~="" then
		local honor_count = 0
		honor_count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		--������ɼ�����
		LogMgr.AddHonorByEventId(uEventId,honor_count)
	end
	
	--�����������
	countstr = QuestNode("�����������")
	if TongId ~= 0 and countstr and countstr~="" then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		--������ɼ�����
		local parameters = {}
		parameters["uTongID"] = TongId
--		parameters["uHonor"] = count
		parameters["uExploit"] = count
		parameters["nEventType"] = 144
--		GasTongBasicDB.UpdateHonor(parameters)
		--GasTongBasicDB.UpdateExploit(parameters)
	end
	
	--����Ź�����
	countstr = QuestNode("����Ź�����")
	if countstr and countstr~="" then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		AreaFbPointDB.AddAreaFbPointByType(PlayerId,count,10,sceneName,nil,event_type_tbl["�������Ź�����"])
	end
	
	--�󶨵�Ӷ��ȯ����
	countstr = QuestNode("�󶨵�Ӷ��ȯ����")
	if countstr and countstr~="" then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		local fun_info = g_MoneyMgr:GetFuncInfo("Quest")
		local bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(fun_info["FunName"],fun_info["AddBindingTicket"],PlayerId, 3, count,uEventId)
		if not bFlag then
			CancelTran()
			if IsNumber(uMsgID) then
				return false,uMsgID
			else
				return false,3105
			end
		end
	end 
	
	--��չ�Ƚ���
	countstr = QuestNode("��չ�Ƚ���")
	if countstr and countstr~="" and TongId~=0 then
		local count = CountReturn(DBLevel,DBPlayerYbLevel,LoopNum,countstr)
		local bFlag = GasTongBasicDB.AddTongDevelopDegree{["uTongID"] = TongId, ["uPoint"] = count, ["uEventType"] = event_type_tbl["����ӷ�չ�Ƚ���"]}
		if not bFlag then
			CancelTran()
			return false,3107
		end
	end
	
	--���齱��
	local NowLevel = DBLevel
	
	local AddExp,AddSoul = CountAddExpAndSoulNum(DBLevel,DBPlayerYbLevel,LoopNum,sQuestName)

--	print("AddExp,AddSoul",AddExp,AddSoul)
	AddExp = AddExp * uExpMultiple
	local CurLevel,LevelExp = AddPlayerExp(DBLevel,AddExp,DBExp,PlayerId)
	local AddExpTbl = nil
	if CurLevel then
		NowLevel = CurLevel
		data["char_level"]	= CurLevel
		data["char_exp"]	= LevelExp
		data["nAddExp"] = AddExp
		data["uEventId"] = uEventId
		CharacterMediatorDB.AddLevel(data)
		
		AddExpTbl = {}
		AddExpTbl["Level"] = CurLevel
		AddExpTbl["Exp"] = LevelExp
		AddExpTbl["AddExp"] = AddExp
		AddExpTbl["uInspirationExp"] = 0
	end
	
	local MercenaryLevelTbl = nil
	if g_AllMercenaryQuestMgr[sQuestName] then
		local AddIntegral = GetMercenaryIntegralNum(DBLevel,DBPlayerYbLevel,LoopNum,sQuestName)
		local CurrMercenaryLevel,CurrIntegral = AddPlayerMercenaryIntegral(DBPlayerYbLevel,AddIntegral,DBIntegral)
		if CurrMercenaryLevel then
			local AddLevelParam = {}
			AddLevelParam["char_id"] = PlayerId
			AddLevelParam["char_mercLevel"]	= CurrMercenaryLevel
			AddLevelParam["char_mercIntegral"]	= CurrIntegral
			CharacterMediatorDB.AddMercenaryLevel(AddLevelParam)
			MercenaryLevelTbl = {CurrMercenaryLevel,CurrIntegral,AddIntegral}
		end
--	else		--����������,��4������
--		
--		local AddLevelParam = {}
--		AddLevelParam["char_id"] = PlayerId
--		AddLevelParam["char_mercLevel"]	= DBPlayerYbLevel
--		AddLevelParam["char_mercIntegral"]	= DBIntegral+4
--		CharacterMediatorDB.AddMercenaryLevel(AddLevelParam)
--		MercenaryLevelTbl = {DBPlayerYbLevel,DBIntegral+4,4}
		
	end
	
	local parm = {}
	parm["soulCount"] = AddSoul
	parm["PlayerId"] = PlayerId
	parm["eventId"] = uEventId
	local resSucc,SoulRet = EquipMgrDB.ModifyPlayerSoul(parm)
	if not resSucc then
		CancelTran()
		return false
	end
	if not NowLevel and NowLevel < DBLevel then
		NowLevel = DBLevel
	end
	--���ؿͻ���
	--g_MoneyMgr:Flush()
	return true,res_tbl,AddExpTbl,SoulRet,MercenaryLevelTbl,AddSoul
end

--����������
function RoleQuestDB.GiveQuestAward(data,uExpMultiple,sceneName,LoopNum)
	return GiveQuestAward(data,uExpMultiple,sceneName,LoopNum)
end

local function FinishQuest(data)
	local PlayerId = data["PlayerId"]
	local sQuestName = data["QuestName"]
	local sceneName = data["sceneName"]
	local QuestNode = Quest_Common(sQuestName)
	
	if RoleQuestDB.CountQuestLimitByName(sQuestName) > 0 then
		return {false, 3103}
	end
	
	--���������˸�����״̬
	local state, IsLimitTime=RoleQuestDB.GetQuestState({PlayerId,sQuestName})
	if(state ~= QuestState.init) then
		return {false, 3097} --"���ǽ���������"
	end
--	if(state == QuestState.finish) then
--		return {false,"�����Ѿ����"}
--	end
	
	--���ʱ�������Ƿ�ʱ
	if IsLimitTime ~= 1 then
		local limit_time = QuestNode("��ʱ")
		if limit_time and limit_time~=0 then
			local start_time = RoleQuestDB.GetQuestAcceptTime(sQuestName,PlayerId)
	--		if(start_time == nil) then
	--			return {false,"û�п�ʼʱ��,û�н�������"}
	--		end
			local finish_time = os.time()
			local dtime = (finish_time-start_time)
			if(dtime > limit_time) then
				return {false, 3098} --"����ʱ"
			end
		end
	end
	
	--��������Ƿ���������
	if g_QuestNeedMgr[sQuestName] then
		local vartbl = RoleQuestDB.SelectQuestVarList(sQuestName,PlayerId)
		for i = 1, table.getn(vartbl) do
			local varname = vartbl[i][1]
			local donum = vartbl[i][2]
			local neednum = g_QuestNeedMgr[sQuestName][varname].Num
			if donum < neednum then
				return {false, 3099} --"����������δ����"
			end
		end
	end
	
	if QuestNode("Ӷ�����ų�����") and QuestNode("Ӷ�����ų�����") == 1 then
		local GasTongBasicDB = RequireDbBox("GasTongBasicDB")
		local TongId = GasTongBasicDB.GetTongID(PlayerId)
		if TongId == 0 or PlayerId ~= GasTongBasicDB.GetTongLeaderId(TongId) then
			return {false, 300026}
		end
	end
	
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local Lev_Exp = CharacterMediatorDB.GetCharLevelExpDB({["char_id"] = PlayerId})
	local DBLevel = Lev_Exp:GetData(0,0)
	--local MercenaryLevelDB = RequireDbBox("MercenaryLevelDB")
	--MercenaryLevelDB.SlowAddMercenaryLevelCount(PlayerId, "��ս����", sQuestName)
	--�����Ӷ������
	local FinishTimesTbl = {}
	if g_AllMercenaryQuestMgr[sQuestName] then
		local MercenaryType = QuestNode("Ӷ����������")
		
		if MercenaryType == 7 and DBLevel >= 15 then
			local mercParam = {}
			mercParam["PlayerId"] = PlayerId
			mercParam["ActivityName"] = "Ӷ��С������"
			local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
			local IsAllow, FinishTimes = ActivityCountDbBox.CheckSinglePlayerActivityCount(mercParam)
			
			FinishTimesTbl[1] = FinishTimes + 1
			if IsAllow then
				ActivityCountDbBox.AddActivityCount(mercParam)
			end
		end
		
		--�����Ӷ���ճ�����,��������Ƿ��Ѿ������10��
		if MercenaryType == 1 and DBLevel >= 20 then
			local mercParam = {}
			mercParam["PlayerId"] = PlayerId
			mercParam["ActivityName"] = "Ӷ���ճ�����"
			local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
			local IsAllow, FinishTimes = ActivityCountDbBox.CheckSinglePlayerActivityCount(mercParam)
			
			FinishTimesTbl[2] = FinishTimes + 1
			--if not IsAllow then
				--�Ѿ�����10����,�����ٽ�Ӷ���ճ�����
				--return {false,"���Ѿ�����10����,�����ٽ�Ӷ���ճ�����"}
			if IsAllow then
				ActivityCountDbBox.AddActivityCount(mercParam)
				--�������Ʒ����(��2�ε�ʱ�������)
				FinishTimes = FinishTimes + 1
				
				if FinishTimes == 10 or FinishTimes == 20 then
					data["IsGiveMercItem"] = true
				end
				if FinishTimes/2 == math.floor(FinishTimes/2) then
					--data["IsGiveMercItem"] = true
					--data["IsGiveScopesItem"] = true
				end
			end
		end
		--���ټ�Ӷ���ȼ�ָ������
		--MercenaryLevelDB.SlowAddMercenaryLevelCount(PlayerId, "Ӷ������")
	end
	
	local del_items={}
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	
	if QuestNode("��Ʒ����") then
		local Keys = QuestNode:GetKeys("��Ʒ����")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", Keys[k], "Arg")
			local needtype = Arg[1]
			local needname = Arg[2]		--�������Ʒ��
			local neednum = Arg[3]
			local have_num = g_RoomMgr.GetItemCount(PlayerId,needtype,needname)
			if have_num < neednum then
				CancelTran()
				return {false, 3099} --"����������δ����"
			elseif needtype ~=16 and have_num>=neednum then
				local res = g_RoomMgr.DelItem(PlayerId, needtype,needname,neednum,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false,3089} --"������Ʒɾ��ʧ��"
				end
				table.insert(del_items,{needtype,needname,neednum,res})
			else
				local res = g_RoomMgr.DelItem(PlayerId, needtype,needname,have_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false,3089} --"������Ʒɾ��ʧ��"
				end
				table.insert(del_items,{needtype,needname,have_num,res})
			end
		end
	end
	
	if QuestNode("��������") then
		local Keys = QuestNode:GetKeys("��������")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��������", Keys[k], "Arg")
			local droptype = Arg[1]
			local dropname = Arg[2]		--�������Ʒ��
			local havenum = g_RoomMgr.GetItemCount(PlayerId,droptype,dropname)
			if havenum > 0 then
				local res = g_RoomMgr.DelItem(PlayerId, droptype,dropname,havenum,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false,3089} --"������Ʒɾ��ʧ��"
				end
				table.insert(del_items,{droptype,dropname,havenum,res})
			end
		end
	end
	
	--��ʱ���޴μ���
	local GMTimeCountLimit = data["GMTimeCountLimit"]
	if QuestNode("ʱ���޴�") and GMTimeCountLimit == 1 then
		AddQuestTimeCount(sQuestName,PlayerId)
	end
	--����������
	if not RoleQuestDB.DeleteAllQuestVar(sQuestName,PlayerId) then
		CancelTran()
		return {false,3090} --"����������ʧ��"
	end
	--��������״̬
	if not RoleQuestDB.UpdateQuestState(QuestState.finish,PlayerId,sQuestName) then
		CancelTran()
		return {false,300005} --"��������״̬ʧ��"
	end
	
	if not RoleQuestDB.UpdateCharFinishQuestNum(PlayerId,1) then
		CancelTran()
		return {false,3091} --"���������������ʧ��"
	end
	--����������
	if QuestNode("�����Ʒ") then
		local Keys = QuestNode:GetKeys("�����Ʒ")
		for i = 1,table.getn(Keys) do
			local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����Ʒ", Keys[i])
			if tbl[3] then
				local give_type = tbl[1]
				local give_name = tbl[2]
				local del_num = g_RoomMgr.GetItemCount(PlayerId,give_type,give_name)
				if(del_num>0) then
					local res = g_RoomMgr.DelItem(PlayerId, give_type, give_name,del_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
					if IsNumber(res) then
						CancelTran()
						return {false,res}
					end
					table.insert(del_items,{give_type,give_name,del_num, res})
				end
			end
		end
	end
	
	local LoopQuestTbl = {"", 0}
	local loopname, loopnum = "", 0
	if Quest_Common(sQuestName, "��������") == 10 then
		local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "������", "1")
		local res = StmtContainer._GetQuestLoop:ExecStat(PlayerId, tbl[1])
		if res and res:GetRowNum()>0 then
			local PlayerLevel = data["PlayerLevel"]
			loopname = tbl[1]
			loopnum = res:GetData(0, 0)
			local loopmgr = g_LoopQuestMgr[loopname][loopnum+1]
			local n = 0
			local temptbl = {}
			if loopmgr then
				for i=1, table.getn(loopmgr) do
					if sQuestName ~= loopmgr[i].QuestName
						and PlayerLevel >= loopmgr[i].MinLevel and PlayerLevel <= loopmgr[i].MaxLevel then
						table.insert(temptbl, loopmgr[i].QuestName)
					end
				end
				n = table.getn(temptbl)
				if n > 0 then
					LoopQuestTbl[1] = temptbl[math.random(1, n)]
					LoopQuestTbl[2] = loopnum+1
				end
			end
			if n <= 0 then
				StmtContainer._DeleteQuestLoop:ExecStat(PlayerId, loopname)
				LoopQuestTbl[1] = "LoopOver"
				LoopQuestTbl[2] = 0
			end
		end
	end
	
	local uExpMultiple = RoleQuestDB.GetQuestExpMultiple(PlayerId,sQuestName)
	local succ,add_items,AddExpTbl,SoulRet,MercenaryLevelTbl,uAddSoul = RoleQuestDB.GiveQuestAward(data,uExpMultiple,sceneName,loopnum)
	if not succ then
		CancelTran()
		return {false,add_items}
	end
	
	local delItemTbl = {}
	for i=1,table.getn(del_items) do
		local type,name,num,res=del_items[i][1],del_items[i][2],del_items[i][3],del_items[i][4]
		local Tbl = {}
		Tbl["nType"] = type
		Tbl["sName"] = name
		Tbl["nCount"] = num
		Tbl["res"] = res
		table.insert(delItemTbl, Tbl)
	end
	
	local DirectDB = RequireDbBox("DirectDB")
	local DirectTbl = DirectDB.AddPlayerQuestDirect(PlayerId, "�������", sQuestName)
	
	local addItemTbl = {}
--	local param = {}
--	param["char_id"] = PlayerId
	for i=1, table.getn(add_items) do
--		param["nType"] = add_items[i][1]
--		param["sName"] = add_items[i][2]
--		param["nCount"] = add_items[i][3]
--		param["itemTbl"] = add_items[i][4]
		local Tbl = {}
		--Tbl["QuestItemVar"] = RoleQuestDB.AddQuestItemVar(param)
		Tbl["nType"] = add_items[i][1]
		Tbl["sName"] = add_items[i][2]
		Tbl["nCount"] = add_items[i][3]
		Tbl["res"] = add_items[i][4]
		Tbl["msgType"] = add_items[i][5]
		DirectDB.AddPlayerItemDirect(PlayerId, "��������Ʒ", Tbl["nType"], Tbl["sName"], DirectTbl)
		table.insert(addItemTbl, Tbl)
	end
	
	local TeamPlayerID = data["TeamPlayerID"]
	local TeamPlayerExp = nil
	if TeamPlayerID and next(TeamPlayerID) then
		if AddExpTbl and AddExpTbl["AddExp"] then
			local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
			local AreaDB = RequireDbBox("AreaDB")
			TeamPlayerExp = {}
			for i=1, #(TeamPlayerID) do
				local iExp = math.floor(AddExpTbl["AddExp"]*0.05)
				local ID = TeamPlayerID[i]
				
				if AreaDB.Check2PlayerInSameArea(PlayerId,ID) then
					local param = {}
					param["char_id"] = ID
					local Lev_Exp = CharacterMediatorDB.GetCharLevelExpDB(param)
					local iDBLevel = Lev_Exp:GetData(0,0)
					local iDBExp = Lev_Exp:GetData(0,1)
					Lev_Exp:Release()
					
					local iCurLevel,iLevelExp = AddPlayerExp(iDBLevel,iExp,iDBExp,ID)
					if iCurLevel then
						param["char_level"]	= iCurLevel
						param["char_exp"]	= iLevelExp
						param["nAddExp"] = iExp
						param["addExpType"] = event_type_tbl["�������������"]
						CharacterMediatorDB.AddLevel(param)
						
						local iAddExpTbl = {}
						iAddExpTbl["Level"] = iCurLevel
						iAddExpTbl["Exp"] = iLevelExp
						iAddExpTbl["AddExp"] = iExp
						iAddExpTbl["uInspirationExp"] = 0
						iAddExpTbl["DirectTbl"] = DirectTbl
						table.insert(TeamPlayerExp,{ID,iAddExpTbl})
					end
				end
				
			end
		end
	end
	
	--�����һ��Ӷ���ȼ�״̬����Ϊ�����������Լ���ͨ�����Ӷ������Ҳ��Ӱ��Ӷ���ȼ�״̬
	--local MLRes = MercenaryLevelDB.CheckMercenaryLevel( {["CharId"] = PlayerId} )
	
	local resData = {}
	resData["delItemTbl"] = delItemTbl
	resData["addItemTbl"] = addItemTbl
	resData["AddExpTbl"] = AddExpTbl
	resData["SoulRet"] = SoulRet
	resData["MercenaryLevelTbl"] = MercenaryLevelTbl
	resData["TeamPlayerExp"] = TeamPlayerExp
	--resData["MLRes"] = MLRes
	resData["DirectTbl"] = DirectTbl
	resData["LoopQuestTbl"] = LoopQuestTbl
	resData["uAddSoul"] = uAddSoul
	
	if LoopQuestTbl[1] ~= "" and LoopQuestTbl[1] ~= "LoopOver" then
		local param = {}
		param["PlayerId"] = PlayerId
		param["QuestName"] = LoopQuestTbl[1]
		param["sceneName"] = sceneName
		param["LoopNum"] = LoopQuestTbl[2]
		resData["AddLoopQuestResult"] = AddQuest(param)
	end
	local buffName = Quest_Common(sQuestName, "buff����")
	if buffName and vipBuffTbl[buffName] then
		local UseVIPItemDB = RequireDbBox("UseVIPItemDB")
		local succ = UseVIPItemDB.SaveWelfareRole(PlayerId,buffName)
		if not succ then
			CancelTran()
			return {false,3091}
		end
	end
	return {true,resData}
end

--�������
function RoleQuestDB.FinishQuest(data)
	return FinishQuest(data)
end

local function GiveUpQuest(data)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local PlayerId = data["PlayerId"]
	local sQuestName = data["QuestName"]
	local sceneName = data["sceneName"]
	local del_items = {}
	
	if Quest_Common(sQuestName, "�����Ʒ") then
		local Keys = Quest_Common:GetKeys(sQuestName, "�����Ʒ")
		for i = 1,table.getn(Keys) do
			local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����Ʒ", Keys[i])
			if tbl[3] then
				local give_type = tbl[1]
				local give_name = tbl[2]
				local give_num = tonumber(tbl[3])
				local num = g_RoomMgr.GetItemCount(PlayerId, give_type, give_name)
				if(num ~= 0) then
					if(give_num >= num) then
						local res = g_RoomMgr.DelItem(PlayerId, give_type,give_name,num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
						if IsNumber(res) then
							CancelTran()
							return {false,res}
						end
						table.insert(del_items,{give_type,give_name,num, res})
					else
						local res = g_RoomMgr.DelItem(PlayerId, give_type,give_name,give_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
						if IsNumber(res) then
							CancelTran()
							return {false,res}
						end
						table.insert(del_items,{give_type,give_name,give_num, res})
					end
				end
			end
		end
	end
	
	--ˢ��������ȴʱ��
	local cdtime = Quest_Common(sQuestName, "��ȴʱ��")
	if cdtime then
		RefreshQuestCD(sQuestName, PlayerId)
	end
	
	if Quest_Common(sQuestName, "��������") == 10 then
		local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "������", "1")
		local res = StmtContainer._GetQuestLoop:ExecStat(PlayerId, tbl[1])
		if res and res:GetRowNum()>0 then
			StmtContainer._DeleteQuestLoop:ExecStat(PlayerId, tbl[1])
		end
	end
	
	data["item_tbl"] = del_items
	return RoleQuestDB.DeleteQuest(data)
end

--��������
function RoleQuestDB.GiveUpQuest(data)
	return GiveUpQuest(data)
end

local function CheckQuestState(PlayerId, sQuestName)
	--���ʱ�������Ƿ�ʱ
	local limit_time = Quest_Common(sQuestName, "��ʱ")
	if limit_time and limit_time~=0 then
		local start_time = RoleQuestDB.GetQuestAcceptTime(sQuestName,PlayerId)
--		if(start_time == nil) then
--			return {false,"û�п�ʼʱ��,û�н�������"}
--		end
		local finish_time = os.time()
		local dtime = (finish_time-start_time)
		if(dtime > limit_time) then
			return false--"����ʱ"
		end
	end
	
	--��������Ƿ���������
	if g_QuestNeedMgr[sQuestName] then
		local vartbl = RoleQuestDB.SelectQuestVarList(sQuestName,PlayerId)
		for i = 1, table.getn(vartbl) do
			local varname = vartbl[i][1]
			local donum = vartbl[i][2]
			local neednum = g_QuestNeedMgr[sQuestName][varname].Num
			if donum < neednum then
				return false--"����������δ����"
			end
		end
	end
	
	if Quest_Common(sQuestName, "��Ʒ����") then
		local Keys = Quest_Common:GetKeys(sQuestName, "��Ʒ����")
		local RoomMgr = RequireDbBox("GasRoomMgrDB")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", Keys[k], "Arg")
			local needtype = Arg[1]
			local needname = Arg[2]		--�������Ʒ��
			local neednum = Arg[3]
			local have_num = RoomMgr.GetItemCount(PlayerId,needtype,needname)
			if have_num < neednum then
				return false--"����������δ����"
			end
		end
	end
	
	return true--���Ѿ�������
end

local function QuestFailure(data)
	local PlayerId = data["PlayerId"]
	local QuestName = data["QuestName"]
	
	--���������˸�����״̬
	local state,_ = RoleQuestDB.GetQuestState({PlayerId,QuestName})
	if not state then
		return false		--"���ǽ���������"
	end
	
	if CheckQuestState(PlayerId,QuestName) then--�Ѿ�����Ļ�,�Ͳ�����Ϊʧ����
		return false
	end
	
	if not RoleQuestDB.UpdateQuestState(QuestState.failure,PlayerId, QuestName) then
		return false
	end
	local LogMgr = RequireDbBox("LogMgrDB")
	LogMgr.QuestFail(PlayerId, QuestName)
	return true
end

--����ʧ��
function RoleQuestDB.QuestFailure(data)
	return QuestFailure(data)
end

local function GutQuestFailure(data)
	local PlayerIdTbl = data["PlayerIdTbl"]
	local QuestName = data["QuestName"]
	
	for _, PlayerId in pairs(PlayerIdTbl) do 
		if CheckQuestState(PlayerId,QuestName) then--�Ѿ�����Ļ�,�Ͳ�����Ϊʧ����
			return false
		end
		if not RoleQuestDB.UpdateQuestState(QuestState.failure,PlayerId, QuestName) then
			return false
		end
		local LogMgr = RequireDbBox("LogMgrDB")
		LogMgr.QuestFail(PlayerId, QuestName)	
	end
	return true
end

--��������ʧ��
function RoleQuestDB.GutQuestFailure(data)
	return GutQuestFailure(data)
end

function RoleQuestDB.AllPlayerQuestFail(data)
	local PlayerTbl = data["PlayerIdTbl"]
	local QuestName = data["QuestName"]
	local res = {}
	for _,id in pairs(PlayerTbl) do
		local param = {}
		param["PlayerId"] = id
		param["QuestName"] = QuestName
		table.insert(res,{id,RoleQuestDB.QuestFailure(param)})
	end
	return res
end

--�뿪����,������ʧ��
function RoleQuestDB.LeaveSceneSetQuestFailure(data)
	local PlayerId = data["char_id"]
	local SceneName = data["scene_name"]
	if data["scene_type"] >= 2 then	--��������
		local QuestNumRes = StmtContainer._GetDoingQuests:ExecStat(PlayerId)
		if QuestNumRes:GetRowNum() > 0 then
			local FailureQuestTbl = {}
			local param = {}
			for i=1, QuestNumRes:GetRowNum() do
				local sQuestName = QuestNumRes:GetData(i-1,0)
				if Quest_Common(sQuestName) then
					local Quest = Quest_Common(sQuestName, "�뿪��������ʧ��")
					if Quest and Quest == SceneName then
						param["PlayerId"] = PlayerId
						param["QuestName"] = sQuestName
						table.insert(FailureQuestTbl,{["DelSucc"]=RoleQuestDB.QuestFailure(param),["QuestName"]=sQuestName})
					end
				end
			end
			return FailureQuestTbl
		end
	end
end

local function DeleteQuest(data)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local PlayerId = data["PlayerId"]
	local sQuestName = data["QuestName"]
	local del_items = data["item_tbl"]
	local sceneName = data["sceneName"]
	--����������
	if not RoleQuestDB.DeleteAllQuestVar(sQuestName,PlayerId) then
		CancelTran()
		return {false,3090} --"����������ʧ��"
	end
	--ɾ������
	if not RoleQuestDB.GiveUpQuestSql(sQuestName, PlayerId) then
		CancelTran()
		return {false,300011} --"ɾ������ʧ��"
	end
	
	if Quest_Common(sQuestName, "��������") then
		local Keys = Quest_Common:GetKeys(sQuestName, "��������")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��������", Keys[k], "Arg")
			local droptype = Arg[1]
			local dropname = Arg[2]
			local havenum = g_RoomMgr.GetItemCount(PlayerId,droptype,dropname)
			if havenum > 0 then
				local res = g_RoomMgr.DelItem(PlayerId, droptype,dropname,havenum,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false,3089} --"������Ʒɾ��ʧ��"
				end
				table.insert(del_items,{droptype,dropname,havenum,res})
			end
		end
	end
	
	if Quest_Common(sQuestName, "��Ʒ����") then
		local Keys = Quest_Common:GetKeys(sQuestName, "��Ʒ����")
		local RoomMgr = RequireDbBox("GasRoomMgrDB")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", sQuestName, "��Ʒ����", Keys[k], "Arg")
			local needtype = Arg[1]
			local needname = Arg[2]		--�������Ʒ��
			local neednum = Arg[3]
			local have_num = g_RoomMgr.GetItemCount(PlayerId,needtype,needname)
--			if needtype ~= 16 and have_num>=neednum then
--				local res = g_RoomMgr.DelItem(PlayerId, needtype,needname,neednum)
--				if IsNumber(res) then
--					CancelTran()
--					return {false,"ɾ��������Ʒʧ��"}
--				end
--				if IsTable(res) then
--					for i = 1,#res do
--						for j = 1,#res[i] do
--							g_RoomMgr.DelItemFromStaticTable(res[i][j])
--						end
--					end
--				end
--				table.insert(del_items,{needtype,needname,neednum,res})
--			elseif have_num>0 then
			if have_num>0 and needtype == 16 then
				local res = g_RoomMgr.DelItem(PlayerId, needtype,needname,have_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
				if IsNumber(res) then
					CancelTran()
					return {false, 300012} --"ɾ��������Ʒʧ��"
				end
				table.insert(del_items,{needtype,needname,have_num,res})
			end
		end
	end
	
	local delItemTbl = {}
	for i=1,table.getn(del_items) do
		local type,name,num,res=del_items[i][1],del_items[i][2],del_items[i][3],del_items[i][4]
		local Tbl = {}
		Tbl["nType"] = type
		Tbl["sName"] = name
		Tbl["nCount"] = num
		Tbl["res"] = res
		table.insert(delItemTbl, Tbl)
	end
	
	local LogMgr = RequireDbBox("LogMgrDB")
	LogMgr.GiveUpQuest(PlayerId, sQuestName)
	
	return {true,delItemTbl}
end

--������������Ϣ(�Լ���ص���Ʒ��Ϣ)
function RoleQuestDB.DeleteQuest(data)
	return DeleteQuest(data)
end

local function DecreQuestItemVar(data)
	local PlayerId = data["PlayerId"]
	local ItemType = data["ItemType"]
	local ItemName = data["ItemName"]
	local nCount = data["nCont"]
	local sceneName = data["sceneName"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	
--	local ChangeQuestItemTbl = {}
--	if g_ItemQuestMgr[ItemName] then
--		for i = 1, table.getn(g_ItemQuestMgr[ItemName]) do
--			if ItemType == g_ItemQuestMgr[ItemName][i][1] then
--				local sQuestName = g_ItemQuestMgr[ItemName][i][2]
--				local ItemTbl = GetItemVarNum(PlayerId,sQuestName, ItemType, ItemName)
--				table.insert(ChangeQuestItemTbl,ItemTbl)
--			end
--		end
--	end
	--local DelQuestItemTbl = {}
	--local DelGiveQuestItemTbl = {}
	
	if g_WhereGiveQuestMgr["Goods"][ItemName] then
		local sQuestName = g_WhereGiveQuestMgr["Goods"][ItemName][1]
		local queststate = RoleQuestDB.GetQuestState({PlayerId,sQuestName})
		if queststate ~= nil and queststate ~= QuestState.finish then
			local del_items = {}
			if Quest_Common(sQuestName, "�����Ʒ") then
				local Keys = Quest_Common:GetKeys(sQuestName, "�����Ʒ")
				for i = 1,table.getn(Keys) do
					local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����Ʒ", Keys[i])
					if tbl[3] then
						local give_type = tbl[1]
						local give_name = tbl[2]
						local give_num = tonumber(tbl[3])
						local num = g_RoomMgr.GetItemCount(PlayerId, give_type, give_name)
						if(num ~= 0) then
							if(give_num >= num) then
								local res = g_RoomMgr.DelItem(PlayerId, give_type,give_name,num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
								if IsNumber(res) then
									CancelTran()
									return {false,res}
								end
								table.insert(del_items,{give_type,give_name,num, res})
							else
								local res = g_RoomMgr.DelItem(PlayerId, give_type,give_name,give_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
								if IsNumber(res) then
									CancelTran()
									return {false,res}
								end
								table.insert(del_items,{give_type,give_name,give_num, res})
							end
						end
					end
				end
			end
			local param = {}
			param["PlayerId"] = PlayerId
			param["QuestName"] = sQuestName
			param["item_tbl"] = del_items
			param["sceneName"] = data["sceneName"]
			local result = RoleQuestDB.DeleteQuest(param)
			if not result[1] then
				return {false,result[2]}
			else
				return {true,sQuestName,result[2]}
				--DelQuestItemTbl = result[2]
			end
			--return {true,sQuestName,DelQuestItemTbl}
		end
	end
	
	--local DelQuestName = nil
	if g_QuestPropMgr[ItemName] 
		and g_QuestPropMgr[ItemName][1] == ItemType then
		local sQuestName = g_QuestPropMgr[ItemName][2]
		local queststate = RoleQuestDB.GetQuestState({PlayerId,sQuestName})
		if queststate ~= nil and queststate ~= QuestState.finish then
			local del_items = {}
			if Quest_Common(sQuestName, "�����Ʒ") then
				local Keys = Quest_Common:GetKeys(sQuestName, "�����Ʒ")
				for i = 1,table.getn(Keys) do
					local tbl = GetCfgTransformValue(true, "Quest_Common", sQuestName, "�����Ʒ", Keys[i])
					if tbl[3] then
						local give_type = tbl[1]
						local give_name = tbl[2]
						local give_num = tonumber(tbl[3])
						local num = g_RoomMgr.GetItemCount(PlayerId, give_type, give_name)
						if(num ~= 0) then
							if(give_num >= num) then
								local res = g_RoomMgr.DelItem(PlayerId, give_type,give_name,num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
								if IsNumber(res) then
									CancelTran()
									return {false,res}
								end
								table.insert(del_items,{give_type,give_name,num, res})
							else
								local res = g_RoomMgr.DelItem(PlayerId, give_type,give_name,give_num,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
								if IsNumber(res) then
									CancelTran()
									return {false,res}
								end
								table.insert(del_items,{give_type,give_name,give_num, res})
							end
						end
					end
				end
			end
			local param = {}
			param["PlayerId"] = PlayerId
			param["QuestName"] = sQuestName
			param["item_tbl"] = del_items
			param["sceneName"] = sceneName
			local result = RoleQuestDB.DeleteQuest(param)
			if not result[1] then
				return {false,result[2]}
			else
				return {true,sQuestName,result[2]}
				--DelQuestItemTbl = result[2]
			end
			--return {true,sQuestName,DelQuestItemTbl}
		end
	end
	return {true}
end

--ɾ��������Ʒ,��ʲôɾ����ص�����
function RoleQuestDB.DecreQuestItemVar(data)
	return DecreQuestItemVar(data)
end

local function DeleteItem(data)
	local PlayerId = data["PlayerId"]
	local ItemType = data["ItemType"]
	local ItemName = data["ItemName"]
	local ItemNum = data["nCont"]
	local sceneName = data["sceneName"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local res = g_RoomMgr.DelItem(PlayerId, ItemType, ItemName, ItemNum,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
	if IsNumber(res) then
		CancelTran()
		return {false,300011} --"��Ʒɾ��ʧ��"
	end
	--������Щ,���ɾ������һ��������Ʒ,��ô����Ҳ��ɾ��
	--local result = RoleQuestDB.DecreQuestItemVar(data)
	--if not result[1] then
	--	return {false,result[2]}
	--end
	
	return {true,res}
end

--ɾ����Ʒ
function RoleQuestDB.DeleteItem(data)
	return DeleteItem(data)
end

local function DeleteItemByPos(data)
	local PlayerId 			= data["PlayerId"]
	local ItemType 			= data["ItemType"]
	local ItemName 			= data["ItemName"]
	local ItemNum				= data["nCont"]
	local ItemRoomIndex = data["nRoomIndex"]
	local ItemPos 			= data["nPos"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local DelRet = g_RoomMgr.DelItemByPos(PlayerId,ItemRoomIndex,ItemPos,ItemNum,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
	local res = {}
	if IsNumber(DelRet) then
		CancelTran()
		return {false,300011} --"��Ʒɾ��ʧ��"
	end
	table.insert(res,SetResult(DelRet,ItemRoomIndex,ItemPos,ItemNum,ItemType,ItemName))	
	--������Щ,���ɾ������һ��������Ʒ,��ô����Ҳ��ɾ��
	--local result = RoleQuestDB.DecreQuestItemVar(data)
	--if not result[1] then
	--	return {false,result[2]}
	--end
	
	--return {true,result[2],result[3],result[4],res}
	return {true,res}
end

--ɾ����Ʒ,(����Ʒλ���й�)
function RoleQuestDB.DeleteItemByPos(data)
	return DeleteItemByPos(data)
end

function RoleQuestDB.ConsumeItem(data)
	local PlayerId = data["PlayerId"]
	local ConsumeTbl = data["ConsumeTbl"]
	local ConsumeItemTbl = {}
	for i,v in pairs(ConsumeTbl) do
		local UseTbl = v
		local ItemType = UseTbl[1]
		local ItemName = UseTbl[2]
		local ItemNum	= UseTbl[3]
		local result = {}
		data["ItemType"] = UseTbl[1]
		data["ItemName"] = UseTbl[2]
		data["nCont"] = UseTbl[3]
		
		if UseTbl[4] ~= nil then
			data["nRoomIndex"] = UseTbl[4]
			data["nPos"] = UseTbl[5]
			result = RoleQuestDB.DeleteItemByPos(data)
		else
			result = RoleQuestDB.DeleteItem(data)
		end
		
		if not result[1] then
			return {false,result[2]}
		end
		table.insert(ConsumeItemTbl,{ItemType,ItemName,ItemNum,result[2]})
	end
	return {true,ConsumeItemTbl}
end

local function AddExp(data)
	local AddExp = data["addExp"]
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local Lev_Exp = CharacterMediatorDB.GetCharLevelExpDB(data)
	local DBLevel = Lev_Exp:GetData(0,0)
	local DBExp = Lev_Exp:GetData(0,1)
	Lev_Exp:Release()
	local CurLevel,LevelExp = AddPlayerExp(DBLevel,AddExp,DBExp,data["char_id"])
	if CurLevel then
		data["char_level"] = CurLevel
		data["char_exp"] = LevelExp
		data["nAddExp"] = AddExp
		
		CharacterMediatorDB.AddLevel(data)
		return CurLevel,LevelExp
	end
end

--�����Ҿ���
function RoleQuestDB.AddExp(data)
	return AddExp(data)
end

local function UseItemAddExp(data)
	data["addExpType"] = event_type_tbl["ʹ�þ������þ���"]
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local ItemType, ItemName, ItemCount = g_RoomMgr.GetTypeCountByPosition(data["nCharID"], data["nRoom"], data["nPos"])
	if ItemCount == nil or ItemCount == 0 or ItemType ~= 1 or ItemName ~= data["ItemName"] then
		return
	end

	local CurLevel,LevelExp = RoleQuestDB.AddExp(data)
	if CurLevel and LevelExp then
		local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
		local res = g_RoomMgr.DelItemByPos(data["nCharID"],data["nRoom"],data["nPos"],data["nCount"],event_type_tbl["��Ʒʹ��"])
		if not res then
			CancelTran()
		end
		return res,{CurLevel,LevelExp}
	end
end

--��������Ӿ���
function RoleQuestDB.UseItemAddExp(data)
	return UseItemAddExp(data)
end

local function SendItem(playerId, exp, fetch, money, itemTbl, MailTitle, MailContent,sceneName, isFlag, soul)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local sysMailExecutor = RequireDbBox("SysMailDB")
	local AddItemsTbl = {}
	if itemTbl then
		for i=1, table.getn(itemTbl) do
			local item = itemTbl[i]
			local BigID	= item[1]
			local ItemName 	= item[2]
			local Count	= 0
			if isFlag then
				Count	=isFlag * item[3]
			else
				Count	= item[3]
			end
			
			local params= {}
			params.m_nType = BigID
			params.m_sName = ItemName
			params.m_nBindingType = g_ItemInfoMgr:GetItemInfo(BigID,ItemName,"BindingStyle") or 0
			params.m_nCharID = playerId
			params.m_sCreateType = 32
			for j=1, Count do
				local itemID = g_RoomMgr.CreateItem(params)
				if not itemID then
					return false
				end
				table.insert(AddItemsTbl,{itemID})
			end
		end
	end
	
	if AddItemsTbl[1] or (money and money~=0) then
 		local sendRet = sysMailExecutor.SendSysMail(1014, playerId, MailTitle, MailContent, AddItemsTbl, money, event_type_tbl["������ʼ�"])
		if sendRet == false then
			return false
		end
	end
	return true
end


local function PlayerAward(playerId, exp, fetch, money, itemTbl, MailTitle, MailContent,sceneName,sceneType, isFlag, soul)
	local expResult, soulResult, mailResult,bSucc, soulValue
	local  moneyResult = {}
	local itemResult = {}
	local data = {}
	data["char_id"] = playerId
	if exp and exp ~=0 then
		data["addExp"] = exp
		data["addExpType"] = event_type_tbl["��������"]
		expResult = {AddExp(data)}
	end
	if soul and soul ~= 0 then
		local EquipMgrDB = RequireDbBox("EquipMgrDB")
		local parm = {}
		parm["soulCount"] = soul
		parm["PlayerId"] = playerId
		parm["addSoulType"] = event_type_tbl["��������"]
		bSucc,soulValue = EquipMgrDB.ModifyPlayerSoul(parm)
		if not bSucc then
			return false
		end
	end 
	if fetch and fetch~=0 then
		local EquipMgrDB = RequireDbBox("EquipMgrDB")
		local parm = {}
		parm["soulCount"] = fetch
		parm["PlayerId"] = playerId
		parm["addSoulType"] = 32
		bSucc,soulResult = EquipMgrDB.ModifyPlayerSoul(parm)
		if not bSucc then
			return false
		end
	end
	if money and money ~= 0 then
		local MoneyManagerDB =	RequireDbBox("MoneyMgrDB")
		local fun_info = g_MoneyMgr:GetFuncInfo("Quest")
		
		local bFlag,uMsgID
		-- ����������󶨽�
		if sceneType and sceneType == 14 then
			bFlag,uMsgID = MoneyManagerDB.AddMoneyByType(fun_info["FunName"],fun_info["MoneyAward"],playerId, 2, money,nil, event_type_tbl["���������󶨽��"])
		else
			bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["MoneyAward"],playerId, money,nil,event_type_tbl["��������"])
		end
		if not bFlag then
			return false
		end
		moneyResult = {bFlag,uMsgID}
	end
	if itemTbl then
		local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
		local index
		for i=1, #(itemTbl) do
			index = i
			local item = itemTbl[i]
			if item then
				data["nType"]		= item[1]
				data["sName"] 		= item[2]
				if isFlag then
					data["nCount"]		= isFlag * item[3]
				else
					data["nCount"]		= item[3]
				end
				data["sceneName"]	= sceneName
				data["createType"]	= event_type_tbl["��������"]
				local res = CharacterMediatorDB.AddItem(data)
				if IsNumber(res) then
					if res ~= 47 then --�����ռ䲻�� �����ʼ�, ��������� index ��ֵΪnil ���ʼ�
						index = nil				
					end
					break
				else
					table.insert(itemResult,{item[1],item[2],item[3],res})
					index = nil
				end
			end
		end
		if index then
			local mailTbl = {}
			for i = index, #(itemTbl) do
				table.insert(mailTbl, itemTbl[i])
			end
			mailResult = SendItem(playerId, 0, 0, 0, mailTbl, MailTitle, MailContent,sceneName, isFlag)
			if not mailResult then
				return false
			end
		end
	end
	return true,{expResult, moneyResult, itemResult, soulResult, mailResult,fetch, soulValue}
end

local function SendItemOffLine(playerId)
	local chardb = RequireDbBox("CharacterMediatorDB")
	local data = {}
	data["char_id"] = playerId
	local result = chardb.GetPlayerStateData(data)
	local flag = 1
	for i = 0, result:GetRowNum() - 1 do
		if stateTbl[result:GetData(i,0)] then
			local res = stateTbl[result:GetData(i,0)] 
			return res[1], res[2]
		end
	end
	return flag
end

-- function RoleQuestDB:FbActionAward(data)
function RoleQuestDB.FbActionAward(data)
	local result = {}
	local MailTitle = data["MailTitle"]
	local MailContent = data["MailContent"]
	local sceneName = data["sceneName"]
	local sceneType = data["sceneType"]
	
	local AreaFbPointDB = RequireDbBox("AreaFbPointDB")
	for playerId, v in pairs(data) do
		if IsNumber(playerId) then
			if v.isInGame then --�������Ϸ��ֱ�ӷ�����
				local resSucc, awardInfo = PlayerAward(playerId, v.exp , v.fetch, v.money, v.itemTbl, MailTitle, MailContent,sceneName,sceneType, v.isFlag, v.soul)
				if not resSucc then
					CancelTran()
					return false
				end
				result[playerId] = awardInfo
				if v.fightScore and v.fightScore ~= 0 then
					AreaFbPointDB.AddAreaFbPointByType(playerId, v.fightScore,8,sceneName,nil,event_type_tbl["�����������ӻ���"])
				end
			else--������Ϸ��,���ʼĵ���ʽ������
				local flag, type = SendItemOffLine(playerId)
				if not type then
					result[playerId] = SendItem(playerId, v.exp, v.fetch, v.money, v.itemTbl, MailTitle, MailContent,sceneName, v.isFlag, v.soul)
				elseif type == "all" then
					result[playerId] = SendItem(playerId, flag * (v.exp or 0), flag * (v.fetch or 0), flag * (v.money or 0), v.itemTbl, MailTitle, MailContent,sceneName, flag * (v.isFlag or 0), flag * (v.soul or 0))
				elseif type == "exp" then
					result[playerId] = SendItem(playerId, flag * (v.exp or 0), v.fetch, v.money, v.itemTbl, MailTitle, MailContent,sceneName, v.isFlag, v.soul)
				elseif type == "item" then
					result[playerId] = SendItem(playerId, v.exp, v.fetch, v.money, v.itemTbl, MailTitle, MailContent,sceneName, flag * (v.isFlag or 0), v.soul)
				end
				
				if not result[playerId] then
					CancelTran()
					return false
				end
				if type and type ~= "item" and type ~= "exp" then
					if v.fightScore and v.fightScore ~= 0 then
						AreaFbPointDB.AddAreaFbPointByType(playerId, flag * v.fightScore,8,sceneName,nil,event_type_tbl["�����������ӻ���"])
					end
				end
			end
		end
	end
	return true,result
end

function RoleQuestDB.MonsAttackTongAward(data)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")	
  local cdepotMgr = RequireDbBox("GasCDepotMgrDB")
  local tong_box = RequireDbBox("GasTongBasicDB")
	local WarZoneDB = RequireDbBox("WarZoneDB")
	local nTongID = data["nTongID"]
	local nItemBigID = data["nItemBigID"]
	local sItemName = data["sItemName"]
	local nDepotIndex = data["nDepotIndex"]
	local sSceneName = data["sSceneName"]
	local nExperience = data["nExperience"]
	
	local leaderId = tong_box.GetTongLeaderId(nTongID)
	local nRelativeLine = WarZoneDB.GetTongRelativeLine(nTongID)
	local tongInfo = tong_box.GetTongInfo(nTongID)
	local nTongLevel = tongInfo.tong_level
	local nTongMemberNum = tongInfo.member_num
	local stationLevelModulus = TongStationLevelModulus_Server(nRelativeLine, "Modulus")
	local tongLevelModulus = TongLevelModulus_Server(nTongLevel, "Modulus")
	nExperience = nExperience * nTongMemberNum * stationLevelModulus * tongLevelModulus
	sItemName = sItemName .. nExperience
	
	local params= {}
	params.m_nType = nItemBigID
	params.m_sName = sItemName
	params.m_nBindingType = 0
	params.m_nCharID = leaderId
	params.m_sCreateType = event_type_tbl["���﹥�ǽ���"]
	
	local itemID = g_RoomMgr.CreateItem(params)
	if not itemID then
		LogErr("���﹥�ǽ��������򴴽�ʧ��","sBigID:"..nItemBigID.."sItemName:"..sItemName.."nCharID:"..leaderId)
	end
	local nRes = cdepotMgr.AutoAddItems(tong_box.GetTongDepotID(nTongID), nItemBigID, sItemName, {itemID}, nDepotIndex)
	if IsNumber(nRes) or not nRes then
		LogErr("���﹥�ǽ����������Ͳֿ�ʧ��","nDepotIndex:"..nDepotIndex.."nItemBigID:"..nItemBigID.."sItemName:"..sItemName)
	end
	params.m_nType = data["nItem1BigID"]
	params.m_sName = data["sItem1Name"]
	
	local tbl_item_id = {}
	--�����ĸ���������
	for i=1,4 do
		local itemID4 = g_RoomMgr.CreateItem(params)
		table.insert(tbl_item_id,itemID4)
	end
	local nRes = cdepotMgr.AutoAddItems(tong_box.GetTongDepotID(nTongID), params.m_nType, params.m_sName, tbl_item_id, nDepotIndex)

--��ʱ���α�ʯ����
--	nItemBigID = data["nStoneBigID"]
--	params.m_nType = nItemBigID
--	
--	for j = 1, 4 do
--		sItemName = data["sStoneName" .. j]
--		params.m_sName = sItemName
--		for i = 1, 25 do
--			local nItemID = g_RoomMgr.CreateItem(params)
--			local nRes = cdepotMgr.AutoAddItems(tong_box.GetTongDepotID(nTongID), nItemBigID, sItemName,{nItemID}, nDepotIndex)
--		end
--	end
end

function RoleQuestDB.CountQuestLimitByName(sQuestName)
	local res = StmtContainer._CountQuestLimitByName:ExecStat(sQuestName)
	return res:GetData(0,0)
end

function RoleQuestDB.CountObjDropLimitByName(ObjName)
	local res = StmtContainer._CountObjDropLimitByName:ExecStat(ObjName)
	return res:GetData(0,0)
end

function RoleQuestDB.FirstQuestFromLeiMeng(data)
	local NoviceDirectDB = RequireDbBox("NoviceDirectDB")
	NoviceDirectDB.InsertPlayerFirstFinishInfo(data)
	return RoleQuestDB.AcceptQuest(data)
end

function RoleQuestDB.TempMemberExpAdd(data)
	local PlayerTempExp = data["PlayerTempExp"]
	--local ExpTbl = {}
	for id, exp in pairs(PlayerTempExp) do
		local param = {}
		param["char_id"] = id
		param["addExp"] = exp
		param["addExpType"] = event_type_tbl["ɱ�ֻ�þ���"]
		local CurLevel, CurExp = RoleQuestDB.AddExp(param)
--		if CurLevel and CurExp then
--			ExpTbl[id] = {}
--			ExpTbl[id]["Level"] = CurLevel
--			ExpTbl[id]["Exp"] = CurExp
--			ExpTbl[id]["TeamAwardExp"] = exp * ExpCofe
--			ExpTbl[id]["AddExp"] = exp
--			ExpTbl[id]["uInspirationExp"] = 0
--		end
	end
	--return ExpTbl
end

local function GetLoopQuestState(CharId)
	local res = StmtContainer._GetAllQuestLoop:ExecStat(CharId)
	local tbl = {}
	if res and res:GetRowNum()>0 then
		for i=0, res:GetRowNum()-1 do
			local loopname = res:GetData(i,0)
			local loopnum = res:GetData(i,1)
			local iserror = true
			if g_LoopQuestMgr[loopname] and g_LoopQuestMgr[loopname][loopnum] then
				for n=1, #(g_LoopQuestMgr[loopname][loopnum]) do
					local questname = g_LoopQuestMgr[loopname][loopnum][n].QuestName
					if GetQuestState{CharId, questname} == QuestState.init then
						iserror = false
					end
				end
			end
			
			if iserror then
				StmtContainer._DeleteQuestLoop:ExecStat(CharId, loopname)
			else
				table.insert(tbl, {loopname, loopnum})
			end
		end 
	end
	return tbl
end

function RoleQuestDB.GetLoopQuestState(CharId)
	return GetLoopQuestState(CharId)
end

SetDbLocalFuncType(RoleQuestDB.AddQuestVarNum)
SetDbLocalFuncType(RoleQuestDB.AddQuestTheater)
SetDbLocalFuncType(RoleQuestDB.AddQuestVarNumForTeam)
SetDbLocalFuncType(RoleQuestDB.AddVarNumForTeamQuests)
SetDbLocalFuncType(RoleQuestDB.AddVarNumForLevelQuests)
SetDbLocalFuncType(RoleQuestDB.ShareQuest)
SetDbLocalFuncType(RoleQuestDB.AddNewQuest)
SetDbLocalFuncType(RoleQuestDB.AddNewQuestVar)
SetDbLocalFuncType(RoleQuestDB.AddQuest)
SetDbLocalFuncType(RoleQuestDB.GiveUpQuest)
SetDbLocalFuncType(RoleQuestDB.AcceptQuest)
SetDbLocalFuncType(RoleQuestDB.FinishQuest)
SetDbLocalFuncType(RoleQuestDB.GetAwardItemFromQuest)
SetDbLocalFuncType(RoleQuestDB.ItemRequestQuest)
SetDbLocalFuncType(RoleQuestDB.QuestFailure)
SetDbLocalFuncType(RoleQuestDB.QuestIsLimitTime)
SetDbLocalFuncType(RoleQuestDB.KillNpcAddQuestDropObj)
SetDbLocalFuncType(RoleQuestDB.FbActionAward)
SetDbLocalFuncType(RoleQuestDB.AddExp)
SetDbLocalFuncType(RoleQuestDB.CheckQuestVarNeedNum)
SetDbLocalFuncType(RoleQuestDB.CheckQuestItemNeedNum)
SetDbLocalFuncType(RoleQuestDB.CheckQuestSatisfy)
SetDbLocalFuncType(RoleQuestDB.LeaveSceneSetQuestFailure)
SetDbLocalFuncType(RoleQuestDB.MonsAttackTongAward)
SetDbLocalFuncType(RoleQuestDB.FirstQuestFromLeiMeng)
SetDbLocalFuncType(RoleQuestDB.TempMemberExpAdd)
SetDbLocalFuncType(RoleQuestDB.ClearQuest)
SetDbLocalFuncType(RoleQuestDB.DeleteAllQuestVar)
SetDbLocalFuncType(RoleQuestDB.GetQuestAcceptTime)
SetDbLocalFuncType(RoleQuestDB.GetQuestState)
SetDbLocalFuncType(RoleQuestDB.UpdateQuestState)
SetDbLocalFuncType(RoleQuestDB.UpdateQuestTime)
SetDbLocalFuncType(RoleQuestDB.InsertCharFinishQuestNum)
SetDbLocalFuncType(RoleQuestDB.SelectCharFinishQuestNum)
SetDbLocalFuncType(RoleQuestDB.UpdateCharFinishQuestNum)
SetDbLocalFuncType(RoleQuestDB.GetQuestExpMultiple)
SetDbLocalFuncType(RoleQuestDB.Is2CharHaveSameKillNpcQuest)
SetDbLocalFuncType(RoleQuestDB.SelectQuestVarList)
SetDbLocalFuncType(RoleQuestDB.SetQuestVarNum)
SetDbLocalFuncType(RoleQuestDB.DeleteQuestVar)
SetDbLocalFuncType(RoleQuestDB.GiveUpQuestSql)
SetDbLocalFuncType(RoleQuestDB.GetAllQuestVar)
SetDbLocalFuncType(RoleQuestDB.GetAllQuestSql)
SetDbLocalFuncType(RoleQuestDB.GetDoingQuestSql)
SetDbLocalFuncType(RoleQuestDB.GetLoopQuestState)
SetDbLocalFuncType(RoleQuestDB.GetAllQuestAwardItemSql)
SetDbLocalFuncType(RoleQuestDB.GetAllYbFinishQuest)
SetDbLocalFuncType(RoleQuestDB.GetNowQuestSql)
SetDbLocalFuncType(RoleQuestDB.CanAcceptQuest)
SetDbLocalFuncType(RoleQuestDB.CheckNeedItemNum)
SetDbLocalFuncType(RoleQuestDB.IntoTrapAddItem)
SetDbLocalFuncType(RoleQuestDB.SingleGridItem)
SetDbLocalFuncType(RoleQuestDB.GiveQuestAward)
SetDbLocalFuncType(RoleQuestDB.GutQuestFailure)
SetDbLocalFuncType(RoleQuestDB.AllPlayerQuestFail)
SetDbLocalFuncType(RoleQuestDB.DeleteQuest)
SetDbLocalFuncType(RoleQuestDB.DecreQuestItemVar)
SetDbLocalFuncType(RoleQuestDB.DeleteItem)
SetDbLocalFuncType(RoleQuestDB.DeleteItemByPos)
SetDbLocalFuncType(RoleQuestDB.ConsumeItem)
SetDbLocalFuncType(RoleQuestDB.UseItemAddExp)
SetDbLocalFuncType(RoleQuestDB.CountQuestLimitByName)
SetDbLocalFuncType(RoleQuestDB.CountObjDropLimitByName)
return RoleQuestDB

