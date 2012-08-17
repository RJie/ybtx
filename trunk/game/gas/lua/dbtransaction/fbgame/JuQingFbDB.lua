--���鱾
cfg_load "fb_game/JuQingTransmit_Common"

local JuQingTransmit_Common = JuQingTransmit_Common



local StmtContainer = class()
local event_type_tbl = event_type_tbl
local JuQingFbDB = CreateDbBox(...)

function JuQingFbDB.FbCheck(charId, ActionName, Member, IsAutoTeam)
	local Level = JuQingTransmit_Common(ActionName, "Level")
	
	local ExChanger = RequireDbBox("Exchanger")
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
	
	if not IsAutoTeam then
		local GasTeamDB =  RequireDbBox("GasTeamDB")
		local teamId = GasTeamDB.GetTeamID(charId)
		if teamId == 0 then
			return false, {191035}
		end
	end
	
	for _, id in pairs(Member) do
		local sName = ExChanger.getPlayerNameById(id)
		
		--���ȼ�
		local MemberLevel = CharacterMediatorDB.GetPlayerLevel(id)
		if MemberLevel < Level then
			if charId == id then
				return false, {191010, Level}
			else
				return false, {191009, Level}
			end
		end
		
		--����Ƿ��Ѿ��μӹ���
		local mercParam = {}
		mercParam["PlayerId"] = id
		mercParam["ActivityName"] = "���鱾�޴�"
		
		local Name = ExChanger.getPlayerNameById(id)
		local IsAllow, FinishTimes = ActivityCountDbBox.CheckSinglePlayerActivityCount(mercParam)
		
		--30����ǰһ��2��
		--30-40�� һ��4��
		--40-50�� һ��6��
		--50-60�� һ��8��
		--60����  һ��10��
		--print(FinishTimes)
		if IsAllow then
			if MemberLevel < 30 then
				if FinishTimes >= 2 then
					IsAllow = false
				end
			elseif MemberLevel >= 30 and MemberLevel < 40 then
				if FinishTimes >= 4 then
					IsAllow = false
				end
			elseif MemberLevel >= 40 and MemberLevel < 50 then
				if FinishTimes >= 6 then
					IsAllow = false
				end
			elseif MemberLevel >= 50 and MemberLevel < 60 then
				if FinishTimes >= 8 then
					IsAllow = false
				end
			else
				if FinishTimes >= 10 then
					IsAllow = false
				end
			end
		end
		
		if not IsAllow then
			return false, {3511, Name}
		end
	end
	
	return true
end



local StmtDef =
{
	"_GetKillBossTime",
	"select unix_timestamp(ac_dtTime) from tbl_activity_count where cs_uId = ? and ac_sActivityName = ?"
}
DefineSql( StmtDef , StmtContainer )

local StmtDef =
{
	"_InsertWeekAwardState",
	"insert into tbl_activity_count (cs_uId,ac_sActivityName,ac_dtTime) values (?,?,now())"
}
DefineSql( StmtDef , StmtContainer )

local StmtDef =
{
	"_UpdateWeekAwardState",
	[[
		update
			tbl_activity_count
		set
			cs_uId = ?,
			ac_sActivityName = ?,
			ac_dtTime = now()
		where
			cs_uId = ? and ac_sActivityName = ?
	]]
}
DefineSql( StmtDef , StmtContainer )

--��һ���ж�,�ǵ�����ɵķ���true
local function DateCompare(oldDate)
	local Time = 5--ʱ��̶�
	
	local nowDate = os.date("*t",os.time())
	local dbDate = os.date("*t",oldDate)
	if (nowDate.year == dbDate.year)
		and (nowDate.month == dbDate.month) then
			
			local day = nowDate.day - dbDate.day
			if day == 0 then--�����ͬһ���(��ͬ����)
				if (nowDate.hour < Time and dbDate.hour < Time) 
					or (nowDate.hour >= Time and dbDate.hour >= Time) then
					return true
				end
			elseif day == 1 then--�������μ���(��ͬ����)
				if nowDate.hour < Time and dbDate.hour >= Time then
					return true
				end
			end
			
	end
	return false
end

local function CheckIsFinish(charID, NpcName)
	local result = StmtContainer._GetKillBossTime:ExecStat(charID, NpcName)
	if result:GetRowNum() > 0 then
		--��һ���ж�,����ǵ�����ɵ�,�Ͳ����ٸ�������
		if DateCompare(result:GetData(0,0)) then
			return false
		end
		
		StmtContainer._UpdateWeekAwardState:ExecStat(charID, NpcName, charID, NpcName)
	else
		StmtContainer._InsertWeekAwardState:ExecStat(charID, NpcName)
	end
	
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return true
	else
		return false
	end
end

function JuQingFbDB.AddPointForPlayerTbl(data)
	local SceneName = data["SceneName"]
	local PlayerInfo = data["PlayerInfo"]
	local NpcName = data["NpcName"]
	local ExChanger = RequireDbBox("Exchanger")
	local AreaFbPointDB = RequireDbBox("AreaFbPointDB")
	
	local PointTbl = {}
	for uCharId,Info in pairs(PlayerInfo) do
		
		if CheckIsFinish(uCharId, "���鱾:"..NpcName) then
			local res = AreaFbPointDB.AddAreaFbPointByType(uCharId,Info["Point"],5,SceneName,nil,event_type_tbl["�����������ӻ���"])
			if not res then
				CancelTran()
				return false
			end
			
			PointTbl[uCharId] = {ExChanger.getPlayerNameById(uCharId),Info["Point"]}
		else
			PointTbl[uCharId] = {ExChanger.getPlayerNameById(uCharId),0}
		end
		
	end
	return true, PointTbl
end



--�õ������Ѿ���ɹ��ĸ���
local StmtDef =
{
	"_GetFinishAction",
	[[
		select
			ac_sActivityName,unix_timestamp(ac_dtTime)
		from
			tbl_activity_count
		where
			ac_sActivityName like "%���鱾:%" and cs_uId = ?
	]]
}
DefineSql( StmtDef , StmtContainer )

function JuQingFbDB.GiveFinishAction(data)
	local PlayerId = data["PlayerId"]
	local AreaFbPointDB = RequireDbBox("AreaFbPointDB")
	local ActionTbl = {}
	
	local res = StmtContainer._GetFinishAction:ExecStat(PlayerId)
	if res:GetRowNum() > 0 then
		for i=1, res:GetRowNum() do
			local BossName = res:GetData(i-1, 0)
			
			if DateCompare(res:GetData(i-1,1)) then
				BossName = string.gsub(BossName,"���鱾:","")
				
				local keys = JuQingTransmit_Common:GetKeys()
				for id=1, #(keys) do
					local JuQingCommon = JuQingTransmit_Common(keys[id])
					if BossName == JuQingCommon("BossName") then
						table.insert(ActionTbl, JuQingCommon("ActionName"))
						break
					end
				end
				
			end
		end
	end
	
	return true, ActionTbl
end

SetDbLocalFuncType(JuQingFbDB.GiveFinishAction)
SetDbLocalFuncType(JuQingFbDB.AddPointForPlayerTbl)
return JuQingFbDB
