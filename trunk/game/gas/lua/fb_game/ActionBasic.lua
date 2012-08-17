cfg_load "fb_game/FbActionDirect_Common"
cfg_load "fb_game/MatchGame_Common"
cfg_load "tong/TongStartTime_Common"
cfg_load "fb_game/JoinCountLimit_Server"
cfg_load "fb_game/JuQingTransmit_Common"

ActionBasic = {}
ActionBasic.ActionInfoTbl = {}
local TongStartTime_Common = TongStartTime_Common
--local ObjNameAndLvStepTbl = {
--	["��ɽ��Ѩ������Դ��"] = 4,
--	["�����ͱ�������Դ��"] = 5,
--	["ѩ���ͱ�������Դ��"] = 6,
--	["����ɽ��������Դ��"] = 7,
--	["���ܵ�������Դ��"] = 8,
--	["����֮צ��Ѩ������Դ��"] = 9,
--	["��������ǰӪ������Դ��"] = 10,
--	["���������̳������Դ��"] = 11,
--	["����Ӫ��������Դ��"] = 12,
--	["�����ֵ�������Դ��"] = 13,
--	["�ݹ�Ĺ��������Դ��"] = 14,
--	["��������������Դ��"] = 15,
--	["����ɭ��������Դ��"] = 16,
--	["�䷨ɭ��������Դ��"] = 17,
--	["����ɳ��������Դ��"] = 18,
--	["������Ӫ��������Դ��"] = 19,
--	["�����ݵ�������Դ��"] = 20,
--	["����ɳ̲������Դ��"] = 21,
--	["����ս��������Դ��"] = 22,
--	["�ѹȷس�������Դ��"] = 23,
--	["��������Ӫ��������Դ��"] = 24,
--	["�һ��̻�Ӫ��������Դ��"] = 25,
--	["������ʿӪ��������Դ��"] = 26,
--	["�������������Դ��"] = 27,
--	["���������ӵ�������Դ��"] = 28,
--	["���뷥ľ��������Դ��"] = 29
--	
--}

function ActionBasic:GetActionInfo(actionName)
	if self.ActionInfoTbl[actionName] then
		return self.ActionInfoTbl[actionName]
	end
	local info = {}
	if MatchGame_Common(actionName) then
	 	info["SingleOrTeam"] = MatchGame_Common(actionName, "SingleOrTeam")
		local LimitType = MatchGame_Common(actionName, "JoinLimitType")
		if LimitType ~= "" then
			info["LimitType"] = LimitType
			info["LimitCount"] = JoinCountLimit_Server(LimitType, "Count")
			info["LimitCycle"] = JoinCountLimit_Server(LimitType, "Cycle")
		end
		info["MinLv"] = MatchGame_Common(actionName, "MinLevel")
		info["MaxLv"] = MatchGame_Common(actionName, "MaxLevel")
		
		info["MinTeams"] = MatchGame_Common(actionName, "MinTeams")
		info["MaxTeams"] = MatchGame_Common(actionName, "MaxTeams")
		info["SceneName"] = MatchGame_Common(actionName, "SceneName")
		if MatchGame_Common(actionName, "AutoTeamPlayerNumber") ~= "" then
			info["AutoTeamPlayerNumber"] = tonumber(MatchGame_Common(actionName, "AutoTeamPlayerNumber"))
		end
		local TeamType = MatchGame_Common(actionName, "TeamType")
		if TeamType ~= ""  then
			info["IsCanNoAutoTeam"] = string.sub(TeamType,-1,-1) == "1"
			info["IsCanAutoTeam"] = string.sub(TeamType,-2,-2) == "1"
			info["IsAllMemberJoin"] = string.sub(TeamType,-3,-3) == "1"
		end
		info["IsCheckItem"] = true
		
		info["WaiJoinTime"] = 20
	elseif JuQingTransmit_Common(actionName) then
		info["SingleOrTeam"] = 2
		info["MinLv"] = JuQingTransmit_Common(actionName, "Level")
		info["MaxLv"] = 150
		
		info["MinTeams"] = 1
		info["MaxTeams"] = 1
		info["SceneName"] = JuQingTransmit_Common(actionName, "SceneName")
		info["AutoTeamPlayerNumber"] = 5
		
		local TeamType = "111"
		if TeamType ~= ""  then
			info["IsCanNoAutoTeam"] = string.sub(TeamType,-1,-1) == "1"
			info["IsCanAutoTeam"] = string.sub(TeamType,-2,-2) == "1"
			info["IsAllMemberJoin"] = string.sub(TeamType,-3,-3) == "1"
		end
	elseif actionName == "�Ƕ���" then
		info["SingleOrTeam"] = 1
		local LimitType = FbActionDirect_Common(actionName, "MaxTimes")
		if LimitType ~= "" then
			info["LimitType"] = LimitType
			info["LimitCount"] = JoinCountLimit_Server(LimitType, "Count")
			info["LimitCycle"] = JoinCountLimit_Server(LimitType, "Cycle")
		end
		info["MinLv"] = FbActionDirect_Common(actionName, "MinLevel")
		info["MaxLv"] = FbActionDirect_Common(actionName, "MaxLevel")
		
		info["MinTeams"] = 20
		info["MaxTeams"] = 40
		info["SceneName"] = "�Ƕ�������"
		
		info["WaiJoinTime"] = 20
	elseif actionName == "������" then
		info["SingleOrTeam"] = 2
		info["IsAllMemberJoin"] = true
		local LimitType = FbActionDirect_Common(actionName, "MaxTimes")
		if LimitType ~= "" then
			info["LimitType"] = LimitType
			info["LimitCount"] = JoinCountLimit_Server(LimitType, "Count")
			info["LimitCycle"] = JoinCountLimit_Server(LimitType, "Cycle")
		end
		info["MinLv"] = FbActionDirect_Common(actionName, "MinLevel")
		info["MaxLv"] = FbActionDirect_Common(actionName, "MaxLevel")
		
		--info["MinTeams"] = 2
		--info["MaxTeams"] = 5
		info["SceneName"] = "����������"
		
		info["WaiJoinTime"] = 20
--	elseif actionName == "������Դ��" then  --Ӷ���ű��� 
--		info["SingleOrTeam"] = 3
--		info["SceneName"] = "������Դ��"
--		info["WaiJoinTime"] = TongStartTime_Common("������Դ�㱨��ʱ��", "OpenTime")
	else
		return
	end
	self.ActionInfoTbl[actionName] = info
	return info
end


local LvStepFunTbl = {}
function ActionBasic:GetActionLvStep(actionName, Param)
	if Param == 80 then
		Param = Param -1
	end
	if actionName == "�Ƕ���" then --Ŀǰ�� �Ƕ��� �ֵȼ��α���
		return math.floor( (Param - 40)/20 )
	elseif actionName == "������" then
		local MatchType = 2
		return MatchType
	elseif MatchGame_Common(actionName) then
		if not LvStepFunTbl[actionName] then
			local str = "return function(L) return (" .. MatchGame_Common(actionName, "LvStep") ..") end"
			LvStepFunTbl[actionName] = loadstring(str)()
		end
		return LvStepFunTbl[actionName](Param)
	end
	return 1
end

----���
--function ActionBasic:GetRobResActionLvStep(actionName, Param)
--	if Param then
--		for _, charId in pairs(Param) do 
--			local parameters = {}
--			parameters["charId"] = charId
--			local gasRobResDb = RequireDbBox("GasTongRobResourceDB")
--			local objName = gasRobResDb.GetObjName(parameters)
--			local ObjId = ObjNameAndLvStepTbl[objName]
--			return ObjId
--		end
--	end
--end

