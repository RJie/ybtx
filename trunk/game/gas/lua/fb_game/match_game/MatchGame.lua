gas_require "fb_game/match_game/MatchGameInc"
gas_require "fb_game/match_game/MatchGameRoom"

local GameState = {}
GameState.eOpen = 1
GameState.eClose = 2

--������ "9:24" ���ַ����л�ȡ��Ե��� 0:00 �㾭��������
local function GetOffsetSecond(strTime)
	local index1 = string.find(strTime, ":")
	local index2 = string.find(strTime, ":", index1 + 1) or 0
	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
	local sec = 0
	if index2 ~= 0 then
		sec = tonumber(string.sub(strTime, index2 + 1, -1))
	end
	assert(hour and min and sec, "ʱ���ʽ����")
	return (hour * 60 + min) * 60  + sec
end

--�ж��Ƿ��ڿ���ʱ����
local function IsInOpenTime(data, length)
	local curDate =  os.date("*t")
	local todayOffsetSecond = (curDate.hour * 60 + curDate.min) * 60 + curDate.sec
	local timeTbl = {}
	for _, timeStr in pairs(data.time) do
		table.insert(timeTbl, GetOffsetSecond(timeStr))
	end
	curDate.wday = ((curDate.wday == 1) and 7 or curDate.wday-1)  --��ϵͳ���ڻ����������
	local wdayTbl = data.wday
	if wdayTbl == nil then
		wdayTbl = {1,2,3,4,5,6,7}
	end
	
	for _, wday in pairs(wdayTbl) do
		
		for _, offset in pairs(timeTbl) do
			local endOffset = offset + length * 60
			local day = (curDate.wday >= wday and curDate.wday - wday) or curDate.wday + 7 - wday --��Խ����
			local curOffsetSecond = todayOffsetSecond + day * 86400
			
			if curOffsetSecond >= offset and curOffsetSecond < endOffset then
					return true, endOffset - curOffsetSecond
			end
		end
		
	end

	return false
end

function CMatchGame:Init(gameName, cfgData)
	self.m_GameName = gameName
	self.m_CfgData = cfgData
	self.m_JoinTeamTbl = {} --������
	self.m_JoinTeamCount = 0 --���������
	self.m_RoomTbl = {} --�����

	if self.m_CfgData.OpenTime == nil then -- û��OpenTime ˵��Ϊ����ʱ�䶼���ŵĸ�����Ϸ��Ϸ,
		self.m_State = GameState.eOpen
	else --��ʱ����
		self.m_State = GameState.eClose
		g_AlarmClock:AddTask("���� ".. gameName .. " ����", self.m_CfgData.OpenTime, self.Open, nil, self)
		local isOpenTime, length = IsInOpenTime(self.m_CfgData.OpenTime, self.m_CfgData.OpenTime.length)
		if isOpenTime then
			self:Open(length)
		end
	end
end

--���ڷ������ر�
function CMatchGame:ClearTick()
	if self.m_CloseTick then
		UnRegisterTick(self.m_CloseTick)
		self.m_CloseTick = nil
	end
	
	for _, room in pairs(self.m_RoomTbl) do
		room:ClearTick()
	end
end

function CMatchGame:Open(length)
	if length == nil then
		length = self.m_CfgData.OpenTime.length * 60
	end
--	print("���ų���ʱ��", length)
	if self.m_CfgData.OpenTime then --���ڶ�ʱ���ŵ���Ϸ,ע��ر�tick
		if self.m_CloseTick then -- ������,���ñ���д�Ŀ���ʱ�����,������׼���ڶ��ο��� �ϴλ�û����
			UnRegisterTick(self.m_CloseTick)
			self.m_CloseTick = nil
		end
		local closeTime = length * 1000
		self.m_CloseTick = RegClassTick("CloseMatchGameTick", self.Close, closeTime, self)
	end
	
	self.m_State = GameState.eOpen
	--print("������Ϸ�������:::::::::::::::::::::������Ϸ " .. self.m_GameName .. " ����")
end

function CMatchGame:Close()
	if self.m_CloseTick then
		UnRegisterTick(self.m_CloseTick)
		self.m_CloseTick = nil
	end
	
	self.m_State = GameState.eClose
	--print("������Ϸ�������:::::::::::::::::::::�ر���Ϸ " .. self.m_GameName .. " ����")
end

function CMatchGame:IsOpen()
	return self.m_State == GameState.eOpen
end

function CMatchGame:IsClose()
	return self.m_State == GameState.eClose
end

function CMatchGame:IsJoinNpc(npcName)
	return self.m_CfgData.JoinNpcTbl[npcName]
end


function CMatchGame:GetRoom(roomId)
	return self.m_RoomTbl[roomId]
end

function CMatchGame:GetNewRoom(roomId)
	local newRoom = CMatchGameRoom:new()
	newRoom:Init(self.m_GameName, roomId)
	self.m_RoomTbl[roomId] = newRoom
	newRoom:SetReady()
	--self.m_NextRoomId = self.m_NextRoomId + 1
	--print("������Ϸ�������:::::::::::::::::::::���Ӹ��·���  " .. newRoom.m_RoomId)
	return newRoom
end

function CMatchGame:IntoSceneScriptCommon(player, room)
	local campType = MatchGame_Common(self.m_GameName, "CampType")
	local team = room:FindPlayer(player.m_uID)

	if campType == 1 then --ͳһ��Ӫ
		player:SetGameCamp(1)
	elseif campType == 2 then--����
		local gameCamp = room:GetGameCamp(player.m_uID)
		if gameCamp then
			player:SetGameCamp(gameCamp) 
		end
	end
	if self.m_CfgData.EnterSceneDoSkill then
		for _, sillName in ipairs(self.m_CfgData.EnterSceneDoSkill) do
			player:PlayerDoFightSkillWithoutLevel(sillName)
		end
	end
	if self.m_CfgData.EnterSceneTeamDoSkill and team then
		if self.m_CfgData.EnterSceneTeamDoSkill[team.m_Index] then
			for _, sillName in ipairs(self.m_CfgData.EnterSceneTeamDoSkill[team.m_Index]) do
				player:PlayerDoFightSkillWithoutLevel(sillName)
			end
		end
	end
	if self.m_CfgData.EnterSceneAddTempSkill then
		for _, tempSkillName in ipairs(self.m_CfgData.EnterSceneAddTempSkill) do
			player:AddTempSkill(tempSkillName, 1)
		end
	end
	
	if MatchGame_Common(self.m_GameName, "ForbidSelectPlayer") == 1 then -- ��ֹѡ�����
		Gas2Gac:SetCanBeSelectOtherPlayer(player.m_Conn, false)
	end
end

function CMatchGame:OnPlayerIntoScene(player, room)
	--print("������Ϸ�������:::::::::::::::::::::��ҽ���" .. self.m_GameName .. "��Ϸ����!")
	if IsCppBound(player) then
		Gas2Gac:RetSetJoinBtnEnable(player.m_Conn, self.m_GameName)
		self:IntoSceneScriptCommon(player, room)
		local team = room:FindPlayer(player.m_uID)
		room:OnPlayerIntoScene(team, player)
	end
end

function CMatchGame:OnPlayerLeaveScene(player, room)
	--print("������Ϸ�������:::::::::::::::::::::����뿪" .. self.m_GameName .. "��Ϸ����!")
	if IsCppBound(player) then
		player:SetGameCamp(0)
		if MatchGame_Common(self.m_GameName, "ForbidSelectPlayer") == 1 then --�ָ� ����ѡ�����
			Gas2Gac:SetCanBeSelectOtherPlayer(player.m_Conn, true)
		end
		player.m_FbActionExpModulus = nil
		player.m_FbActionMoneyModulus = nil
		room:OnPlayerLeaveScene(player)
		Gas2Gac:CloseList(player.m_Conn)
	end
end

function CMatchGame:OnPlayerAtSceneReborn(player)
--print("������Ϸ�������:::::::::::::::::::::����ڸ���������" .. self.m_GameName .. "��Ϸ����!")
	if IsCppBound(player) then
		local game, room = g_MatchGameMgr:GetRoomByScene(player.m_Scene)
		if game then --��Ҹ��������,�ָ�״̬
			self:IntoSceneScriptCommon(player, room)
		end
		
--		if self.m_CfgData.EnterSceneDoSkill then
--			for _, sillName in ipairs(self.m_CfgData.EnterSceneDoSkill) do
--				player:PlayerDoFightSkillWithoutLevel(sillName)
--			end
--		end
		
--		if self.m_CfgData.EnterSceneAddTempSkill then
--			for _, tempSkillName in ipairs(self.m_CfgData.EnterSceneAddTempSkill) do
--				player:AddTempSkill(tempSkillName, 1)
--			end
--		end
	end
end

function CMatchGame:PlayerOffLine(player)
	
end

function CMatchGame:PlayerLogin(player, room)
	local  team = room:FindPlayer(player.m_uID)
	self:IntoSceneScriptCommon(player, room)
	room:ResumeGame(team, player)
end

--�����ݿ�ĳ�Աtableת����ԭ���ṹ��table
local function TransformMemberTbl(dbPlayerTbl)
	local playerTbl = {}
	for _, playerId in pairs(dbPlayerTbl) do
		playerTbl[playerId] = true
	end
	return playerTbl
end

function CMatchGame:CreateNewRoom(scene, roomId, roomMembers, captainsTbl, teamIndexTbl)
	local newRoom = self:GetNewRoom(roomId)
	local oldTbl = {}
	local teamCount = 0
	for teamId, v in pairs(roomMembers) do
		local teamTbl = {}
		teamTbl.m_PlayerTbl = TransformMemberTbl(v)
		teamTbl.m_TeamId = teamId
		teamTbl.m_PlayerCount = #v
		
		oldTbl[teamId] = teamTbl
		teamCount = teamCount + 1
	end
	SetSceneMatchGameData(scene, "GameName", newRoom.m_GameName)
	SetSceneMatchGameData(scene, "RoomId", newRoom.m_RoomId)
	newRoom:SetPlayers(oldTbl, teamCount, captainsTbl, teamIndexTbl)
	newRoom:Open(scene)
end

function CMatchGame:AddTeam(roomId, actionTeamId, teamIndex, teamMember, captainName)
	local room = self:GetRoom(roomId)
	if room then
		room:AddMatchTeam(actionTeamId, teamIndex, TransformMemberTbl(teamMember), #teamMember, captainName)
	end
end
