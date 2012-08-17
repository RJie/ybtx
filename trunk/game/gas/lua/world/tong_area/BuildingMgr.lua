gas_require "world/tong_area/BuildingMgrInc"


g_BuildingMgr = CBuildingMgr:new()
g_BuildingMgr.m_AutoRepairTime = 6 * 60 * 1000

g_BuildingMgr.m_AllBuildingNpc = {} --���н�����
g_BuildingMgr.m_AutoRepairBuildingTick = {}

function CBuildingMgr:GetTongBuildingHpTbl(tongId)
	if self.m_AllBuildingNpc[tongId] then
		local buildingHpTbl = {}
		for buildingId, npc in pairs(self.m_AllBuildingNpc[tongId]) do
			if IsCppBound(npc) and npc:CppGetMaxHP() >0 then
				buildingHpTbl[buildingId] = npc:CppGetHP() / npc:CppGetMaxHP()
			end
		end
		return buildingHpTbl
	end
end


function CBuildingMgr:AutoRepairBuilding(tick, tongId)
--for tongId, v in pairs(self.m_AllBuildingNpc)do
		local data = {}
		data["tongId"] = tongId
		data["buildingTbl"] = self:GetTongBuildingHpTbl(tongId)
		if data["buildingTbl"] then
			CallDbTrans("GasTongbuildingDB", "AutoRepairBuilding", nil, data, tongId)
		else
			UnRegisterTick(tick)
			self.m_AutoRepairBuildingTick[tongId] = nil
		end
--end
end


--		buildingInfo[1]  ����ID
--		buildingInfo[2]  ����Name
--		buildingInfo[3]  �������� X
--		buildingInfo[4]  �������� Y
--		buildingInfo[5]  ����HP
--		buildingInfo[6]  ����State
-- 		buildingInfo[7]	��ʼ����������ʱ��
--    buildingInfo[8]	�������Id
--		buildingInfo[9]	�����ȼ�

--�ڳ���
function CBuildingMgr:CreateBuildingNpc(scene, buildingInfo, camp, centerPos)
	assert(Npc_Common(buildingInfo[2]), "Npc_Common ��û����д ���� [" .. buildingInfo[2] ..  "] ����Ϣ")
	local fPos = CFPos:new()
	fPos.x = (centerPos[1] + buildingInfo[3])* EUnits.eGridSpan
	fPos.y = (centerPos[2] + buildingInfo[4])* EUnits.eGridSpan
	
	local npc, logMsg = g_NpcServerMgr:CreateServerNpc( buildingInfo[2], buildingInfo[9], scene, fPos)
	if not IsServerObjValid(npc) then
		LogErr("���ս����Npcʧ��", logMsg)
		return
	end
	npc:CppSetCamp(camp)
	local maxHp = npc:CppGetMaxHP()
	npc:CppSetHP(maxHp * buildingInfo[5])
	npc.m_TongID = buildingInfo[8]
	npc.m_BuildingId = buildingInfo[1]
	npc.m_Pos = fPos
	self:AddBuildingNpcInTbl(buildingInfo[8], buildingInfo[1],npc)
	return npc
end

function CBuildingMgr:CreateTempBuildingNpc(scene, buildingInfo, camp, centerPos)
	assert(Npc_Common(buildingInfo[1]), "Npc_Common ��û����д ���� [" .. buildingInfo[2] ..  "] ����Ϣ")
	local fPos = CFPos:new()
	fPos.x = (centerPos[1] + buildingInfo[2])* EUnits.eGridSpan
	fPos.y = (centerPos[2] + buildingInfo[3])* EUnits.eGridSpan
	
	local npc, logMsg = g_NpcServerMgr:CreateServerNpc( buildingInfo[1], buildingInfo[5], scene, fPos)
	if not IsServerObjValid(npc) then
		LogErr("���ս����Npcʧ��", logMsg)
		return
	end
	npc:CppSetCamp(camp)
	local maxHp = npc:CppGetMaxHP()
	local uPlayerID = buildingInfo[6]
	local Player = g_GetPlayerInfo(uPlayerID)
	local GameCamp = Player:CppGetGameCamp()
	npc:CppSetGameCamp(GameCamp)
	npc.m_TongID = buildingInfo[4]
	npc.m_Pos = fPos
	return npc
end

function CBuildingMgr:AddBuildingNpcInTbl(tongId, buildingId , npc)
	if self.m_AllBuildingNpc[tongId] == nil then
		self.m_AllBuildingNpc[tongId] = {}
	end
	assert(self.m_AllBuildingNpc[tongId][buildingId] == nil)
	self.m_AllBuildingNpc[tongId][buildingId] = npc
	if not self.m_AutoRepairBuildingTick[tongId] then
		self.m_AutoRepairBuildingTick[tongId] = RegClassTick("AutoRepairBuildingTick",g_BuildingMgr.AutoRepairBuilding, g_BuildingMgr.m_AutoRepairTime ,g_BuildingMgr, tongId)
	end
end

function CBuildingMgr:RemoveBuildingNpc(npc)
	if npc.m_BuildingId
		and self.m_AllBuildingNpc[npc.m_TongID] 
		and npc == self.m_AllBuildingNpc[npc.m_TongID][npc.m_BuildingId] then
		self.m_AllBuildingNpc[npc.m_TongID][npc.m_BuildingId] = nil
		if not next(self.m_AllBuildingNpc[npc.m_TongID]) then
			self.m_AllBuildingNpc[npc.m_TongID] = nil
		end
	end
end

function CBuildingMgr:DestroyAllTongBuildingNpc(tongId)
	if self.m_AllBuildingNpc[tongId] then
		for _, npc in pairs(self.m_AllBuildingNpc[tongId]) do
			g_NpcServerMgr:DestroyServerNpcNow(npc, false)  
		end
	end
	self.m_AllBuildingNpc[tongId] = nil
end

function CBuildingMgr:DestroyTongBuildingNpc(tongId, buildingId)
	local npc = self.m_AllBuildingNpc[tongId] and self.m_AllBuildingNpc[tongId][buildingId]
	if npc then
		g_NpcServerMgr:DestroyServerNpcNow(npc, false)
	end
end

function CBuildingMgr:CreateTongTempBuilding(Conn, name, roomIndex, roomPos, buildData)
	local centerPos = buildData[1]
	local relationPos = buildData[2]
	local tongId = buildData[3]
	local sceneId = buildData[4]
	
	local function CallBack( bFlag, res, camp, buildingInfo)
		if (not bFlag) and IsNumber(res) then
			MsgToConn(Conn, res)
		elseif bFlag then
			local scene = CSceneMgr:GetScene(sceneId)
			if scene then
				local buildingNpc = self:CreateTempBuildingNpc(scene, buildingInfo, camp, centerPos)
				if not scene.m_TongBuildingTbl[tongId] then
					scene.m_TongBuildingTbl[tongId] = {}
				end
				table.insert(scene.m_TongBuildingTbl[tongId], buildingNpc)
			end
		end
	end
	
  local parameters = {}
	parameters["sName"]	= name
	parameters["nIndex"] = roomIndex
	parameters["nPos"] = roomPos
	parameters["x"]	= relationPos[1]
	parameters["y"]	= relationPos[2]
	parameters["uPlayerID"]	= Conn.m_Player.m_uID
	parameters["sceneName"] = Conn.m_Player.m_Scene.m_SceneName
	local scene = CSceneMgr:GetScene(sceneId)
	local sceneType = scene.m_SceneAttr.SceneType
	if sceneType ~= 8 then
		MsgToConn(Conn, 9417)
		return
	end
	
	CallAccountManualTrans(Conn.m_Account, "GasTongbuildingDB", "DealWithItem", CallBack, parameters, tongId)
end

-- buildData �Ľṹ{centerPos, relativePos, tongId, sceneId, tongPosition}
--��IsCanLayBuildingOnPos �����ķ���ֵ[2]
function CBuildingMgr:CreateTongBuildingCallDb(Conn, name, roomIndex, roomPos, buildData)
	local centerPos = buildData[1]
	local relationPos = buildData[2]
	local tongId = buildData[3]
	local sceneId = buildData[4]
	local tongPosition = buildData[5]
	local function CallBack( bFlag, res, MemberInitiators)
		if (not bFlag) and IsNumber(res) then
			MsgToConn(Conn, res)
		elseif bFlag then
			if IsTable(res) then
				for i=1, #MemberInitiators do
					for ServerId, _ in pairs(g_ServerList) do
						Gas2GasAutoCall:AddVarNumForTeamQuest(GetServerAutoConn(ServerId), MemberInitiators[i], "���"..name, 1)
					end
				end
			end
		end 
	end
	
  local parameters = {}
	parameters["sName"]	= name
	parameters["nIndex"] = roomIndex
	parameters["nPos"] = roomPos
	parameters["x"]	= relationPos[1]
	parameters["y"]	= relationPos[2]
	parameters["uTongID"] = tongId
	parameters["uSceneID"] = sceneId
	if tongPosition then --�ڻ���ƽԭ
		parameters["warZoneId"] = tongPosition.m_WarZoneId
		parameters["stationId"] = tongPosition.m_StationId
	end
	parameters["uPlayerID"]	= Conn.m_Player.m_uID
	parameters["sceneName"] = Conn.m_Player.m_Scene.m_SceneName
	CallAccountManualTrans(Conn.m_Account, "GasTongbuildingDB", "CreateBuilding", CallBack, parameters, tongId)
end

function Db2Gas:CreateTongBuilding(data)
	local uTongID = data.TongId
	local sceneType = data.SceneType
	local sceneId = data.SceneId
	local camp = data.Camp
	local warZoneId = data.WarZoneId
	local stationId = data.StationId
	local buildingInfo = data.BuildingInfo
	local centerPos
	if sceneType == 6 then
		centerPos = g_TongFbMgr:GetCenterPos()
	elseif sceneType == 7 then --�����ս����
		centerPos = g_WarZoneMgr:GetStationPos(stationId)
	end
	
	local scene = CSceneMgr:GetScene(sceneId)
	if scene then
		local npc = g_BuildingMgr:CreateBuildingNpc(scene, buildingInfo, camp, centerPos)
		if sceneType == 7 then
			if not g_WarZoneMgr.m_Warring then
				npc:ServerDoNoRuleSkill("��սȫ����", npc)
			end
		end
	end
end

function Db2Gas:UpdateBuildingLevel(data)
	local tongId = data.TongId
	local buildingId = data.BuildingId
	local newLevel = data.NewLevel
	
	local buildingNpc = g_BuildingMgr:GetBuildingNpc(tongId, buildingId)
	if buildingNpc then
		local hpRate = buildingNpc:CppGetHP() / buildingNpc:CppGetMaxHP()
		buildingNpc:CppSetLevel(newLevel)
		buildingNpc:CppSetHP(hpRate * buildingNpc:CppGetMaxHP())
	end
end

function Db2Gas:RemoveBuilding(data)
	local tongId = data.TongId
	local buildingId = data.BuildingId
	local buildingNpc = g_BuildingMgr:GetBuildingNpc(tongId, buildingId)
	if buildingNpc then
		g_NpcServerMgr:DestroyServerNpcNow(buildingNpc, false)
--		local fPos = buildingNpc.m_Pos
--		local NeedRes = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetTongItemBigID(), buildingNpc.m_Name,"NeedRes")
--		local ResFoldLimit = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetTongItemBigID(), buildingNpc.m_Name,"ResFoldLimit")
--		local dropResource = NeedRes * 0.5
--		DropResource(buildingNpc.m_Scene, fPos.x, fPos.y, dropResource, ResFoldLimit)
	end
end

function Db2Gas:DestroyBuilding(data)
	local tongId = data.TongId
	local buildingId = data.BuildingId
	local buildingNpc = g_BuildingMgr:GetBuildingNpc(tongId, buildingId)
	if buildingNpc then
		g_NpcServerMgr:DestroyServerNpcNow(buildingNpc, false)
	end
end

function Db2Gas:AutoRepairBuilding(data)
	local tongId = data.TongId
	local autoRepairHpTbl = data.AutoRepairHpTbl
	local tongBuildingTbl = g_BuildingMgr.m_AllBuildingNpc[tongId]
	if tongBuildingTbl then
		for buildingId, addHp in pairs(autoRepairHpTbl) do
			local npc =  tongBuildingTbl[buildingId]
			if npc then
				npc:CppSetHP(npc:CppGetHP() + npc:CppGetMaxHP() * addHp)
			end
		end
	end
end

function CBuildingMgr:IsInBuildFbArea(SceneName, Pos)
	local fPos = CPos:new()
	fPos.x = math.floor(Pos.x)
	fPos.y = Pos.y
	
	local AreaName = g_BuildingAreaMgr:GetSceneAreaName(SceneName, fPos)
	if AreaName and AreaName ~= "" then
		return true
	else
		return false
	end
end

function CBuildingMgr:IsInBuildWarZoneArea(SceneName, Pos, StationId)
	local fPos = CPos:new()
	fPos.x = math.floor(Pos.x)
	fPos.y = Pos.y
	
	local AreaName = g_BuildingAreaMgr:GetSceneAreaName(SceneName, fPos)
	if not AreaName or AreaName == "" then
		return false
	end
	
	local StationAreaName = g_BuildingAreaMgr:GetSceneAreaNameByStationId(SceneName, StationId)
	
	if StationAreaName and StationAreaName == AreaName then
		return true
	else
		return false
	end
end

local AreaNameTbl = {}
AreaNameTbl["Chlger"] = "��������"
AreaNameTbl["Tgt"] = "�ط�����"
function CBuildingMgr:IsInBuildChallengeArea(player, Pos)
	local fPos = CPos:new()
	fPos.x = math.floor(Pos.x)
	fPos.y = Pos.y
	
	local Scene = player.m_Scene
	local SceneName = Scene.m_SceneName
	local TongId = player.m_Properties:GetTongID()
	
	local AreaName = g_BuildingAreaMgr:GetSceneAreaName(SceneName, fPos)
	if not AreaName or AreaName == "" then
		return false
	end
	
	if TongId == Scene.m_ChlgerTongId then
		if AreaName ~= AreaNameTbl["Chlger"] then
			return false
		end
	elseif TongId == Scene.m_TgtWzId then
		if AreaName ~= AreaNameTbl["Tgt"] then
			return false
		end
	end
	
	return true
end

function CBuildingMgr:ClearTick()
	for tongId, tick in pairs(self.m_AutoRepairBuildingTick) do
		UnRegisterTick(tick)
		self.m_AutoRepairBuildingTick[tongId] = nil
	end
end

function CBuildingMgr:IsCanLayTempBuildingOnPos(player, pos)
	local tongId = player.m_Properties:GetTongID()
	if tongId == 0 then
		return {false, 9401}
	end
	local scene  = player.m_Scene
	local sceneType = scene.m_SceneAttr.SceneType
	local relativePos
	local centerPos
	if sceneType == 8 then  --����ڰ�ḱ����
		if tongId == scene.m_ChlgerTongId then
			centerPos = g_TongChallengeFbMgr:GetChallengerCenterPos()
		elseif tongId == scene.m_TgtTongId then
			centerPos = g_TongChallengeFbMgr:GetTargetCenterPos()
		end
		relativePos = {pos.x - centerPos[1] , pos.y - centerPos[2]}
		if not self:IsInBuildChallengeArea(player, pos) then
			return {false, 9406}
		end
	else
		return {false, 9417}
	end
	return {true, {centerPos, relativePos, tongId, scene.m_SceneId}}
end

--����Ƕ���ǰ���ж�, �ڶ������,���ݿ����ʱ�򻹻��жϰ���ʱ�ľ���λ��(ս�����ǰ�ḱ��),
function CBuildingMgr:IsCanLayBuildingOnPos(player, pos, name)
	local tongId = player.m_Properties:GetTongID()
	if tongId == 0 then
		return {false, 9401}
	end
	local scene  = player.m_Scene
	local sceneType = scene.m_SceneAttr.SceneType
	local relativePos
	local tongPosition
	local centerPos
	if sceneType == 6 then  --����ڰ�ḱ����
		if scene.m_TongId ~= tongId then
			return {false, 9405}
		end
		centerPos = g_TongFbMgr:GetCenterPos()
		relativePos = {pos.x - centerPos[1] , pos.y - centerPos[2]}
		local sSceneName = scene.m_SceneName
		local nStart, nEnd = string.find(name, "������ʩ")
		if nStart then
			sSceneName = "������" .. sSceneName
		end
		nStart, nEnd = string.find(name, "������")
		if nStart then
			sSceneName = "������" .. sSceneName
		end
		if not self:IsInBuildFbArea(sSceneName, pos) then
			return {false, 9406}
		end
	elseif sceneType == 7 then --�����ս����
		tongPosition = g_WarZoneMgr:FindTong(tongId)
		if tongPosition and scene.m_WarZone.m_WarZoneId == tongPosition.m_WarZoneId then
			centerPos = g_WarZoneMgr:GetStationPos(tongPosition.m_StationId)
			relativePos = {pos.x - centerPos[1] , pos.y - centerPos[2]}
			local sSceneName = scene.m_SceneName
			local nStart, nEnd = string.find(name, "������ʩ")
			if nStart then
				sSceneName = "������" .. sSceneName
			end
			nStart, nEnd = string.find(name, "������")
			if nStart then
				sSceneName = "������" .. sSceneName	
			end
			if not self:IsInBuildWarZoneArea(sSceneName, pos, tongPosition.m_StationId) then
				return {false, 9406}
			end
		else
			return {false, 9405}
		end
	else
		return {false, 9405}
	end
	
	local BarrierRadius = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetTongItemBigID(), name, "BarrierRadius")
	local GridPos = CPos:new()
	local dir = {{-1, -1}, {-1, 1}, {1, 1}, {1, -1}}
	for i = 1, 4 do
		for j = 1, BarrierRadius do		-- ���������BarrierRadius>1�ļ�ⲻȫ
			GridPos.x = pos.x + j * dir[i][1]
			GridPos.y = pos.y + j * dir[i][2]
			local barrierType = scene.m_CoreScene:GetBarrier(GridPos)
			if barrierType ~= EBarrierType.eBT_NoBarrier then
				return {false, 9425}
			end
		end
	end

	local Radius =  g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetTongItemBigID(), name, "Radius")
	local buildingTbl = self.m_AllBuildingNpc[tongId]
	for _, npc in pairs(buildingTbl) do
		local fPos = npc.m_Pos
		local dx = pos.x - fPos.x / EUnits.eGridSpan
		local dy = pos.y - fPos.y / EUnits.eGridSpan
		local dName = npc.m_Properties:GetCharName()
		local dRadius = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetTongItemBigID(), dName, "Radius")
		local similar = name == dName and 2 or 1	-- ͬ��(�������)����Ϊ��ֹ����ͬһ����λ��
		local disSq = math.sqrt(dx * dx + dy * dy)
		if disSq < (Radius + dRadius) * similar then
			return {false, 9408}
		end
	end
	
	return {true, {centerPos, relativePos, tongId, scene.m_SceneId, tongPosition}}
end

function CBuildingMgr:GetBuildingNpc(tongId, buildingId)
	if  self.m_AllBuildingNpc[tongId] then
		return self.m_AllBuildingNpc[tongId][buildingId]
	end
end
