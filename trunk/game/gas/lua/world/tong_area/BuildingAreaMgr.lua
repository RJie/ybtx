gas_require "world/tong_area/BuildingAreaMgrInc"

g_BuildingAreaMgr = CBuildingAreaMgr:new()
g_BuildingAreaMgr.m_SceneAreaTbl = {}
g_BuildingAreaMgr.m_SceneAreaKeyTbl = {}

AddCheckLeakFilterObj(g_BuildingAreaMgr.m_SceneAreaTbl)

local WarZoneSceneName = {}
WarZoneSceneName[1] = "����ƽԭ1"
WarZoneSceneName[2] = "����ƽԭ2"
WarZoneSceneName[3] = "����ƽԭ3"
WarZoneSceneName[4] = "����ƽԭ4"
WarZoneSceneName[5] = "����ƽԭ5"
WarZoneSceneName[6] = "����ƽԭ6"

local WarZoneDefenderSceneName = {}
WarZoneDefenderSceneName[1] = "����������ƽԭ1"
WarZoneDefenderSceneName[2] = "����������ƽԭ2"
WarZoneDefenderSceneName[3] = "����������ƽԭ3"
WarZoneDefenderSceneName[4] = "����������ƽԭ4"
WarZoneDefenderSceneName[5] = "����������ƽԭ5"
WarZoneDefenderSceneName[6] = "����������ƽԭ6"

local WarZoneLifeTreeSceneName = {}
WarZoneLifeTreeSceneName[1] = "����������ƽԭ1"
WarZoneLifeTreeSceneName[2] = "����������ƽԭ2"
WarZoneLifeTreeSceneName[3] = "����������ƽԭ3"
WarZoneLifeTreeSceneName[4] = "����������ƽԭ4"
WarZoneLifeTreeSceneName[5] = "����������ƽԭ5"
WarZoneLifeTreeSceneName[6] = "����������ƽԭ6"

local TongFbSceneName = {}
TongFbSceneName[1] = "���פ�ظ���01"
TongFbSceneName[2] = "���פ�ظ���02"
TongFbSceneName[3] = "���פ�ظ���03"

local TongFbDefenderSceneName = {}
TongFbDefenderSceneName[1] = "���������פ�ظ���01"
TongFbDefenderSceneName[2] = "���������פ�ظ���02"
TongFbDefenderSceneName[3] = "���������פ�ظ���03"

local TongFbLifeTreeSceneName = {}
TongFbLifeTreeSceneName[1] = "���������פ�ظ���01"
TongFbLifeTreeSceneName[2] = "���������פ�ظ���02"
TongFbLifeTreeSceneName[3] = "���������פ�ظ���03"

local TongChallengeSceneName = "�����ս��"

g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_HYPY_Area"] = WarZoneSceneName[1]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_HYPYDefender_Area"] = WarZoneDefenderSceneName[1]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_HYPYLifeTree_Area"] = WarZoneLifeTreeSceneName[1]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongArea01_Area"] = TongFbSceneName[1]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongArea02_Area"] = TongFbSceneName[2]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongArea03_Area"] = TongFbSceneName[3]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongDefenderArea01_Area"] = TongFbDefenderSceneName[1]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongDefenderArea02_Area"] = TongFbDefenderSceneName[2]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongDefenderArea03_Area"] = TongFbDefenderSceneName[3]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongLifeTreeArea01_Area"] = TongFbLifeTreeSceneName[1]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongLifeTreeArea02_Area"] = TongFbLifeTreeSceneName[2]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongLifeTreeArea03_Area"] = TongFbLifeTreeSceneName[3]
g_BuildingAreaMgr.m_SceneAreaKeyTbl["scene/Fb_TongChallenge_Area"] = TongChallengeSceneName

function CBuildingAreaMgr:InitWarZoneAreaSetting(key, stationToArea, areaNames, region)
	assert(stationToArea and region and areaNames, "�����ļ��汾����!! ����°ڹֱ༭��,Ȼ�����µ��������ļ�.")
	
	local SceneName = self.m_SceneAreaKeyTbl[key]
	self.m_SceneAreaKeyTbl[key] = SceneName
	self.m_SceneAreaTbl[SceneName] = {}
	self.m_SceneAreaTbl[SceneName].StationToArea = stationToArea
	self.m_SceneAreaTbl[SceneName].AreaNames = areaNames
	self.m_SceneAreaTbl[SceneName].Region = region
	
	for index = 2, 6 do
		self.m_SceneAreaTbl[WarZoneSceneName[index]] = self.m_SceneAreaTbl[SceneName]
	end
end

function CBuildingAreaMgr:InitWarZoneDefenderAreaSetting(key, stationToArea, areaNames, region)
	assert(stationToArea and region and areaNames, "�����ļ��汾����!! ����°ڹֱ༭��,Ȼ�����µ��������ļ�.")
	
	local SceneName = self.m_SceneAreaKeyTbl[key]
	self.m_SceneAreaKeyTbl[key] = SceneName
	self.m_SceneAreaTbl[SceneName] = {}
	self.m_SceneAreaTbl[SceneName].StationToArea = stationToArea
	self.m_SceneAreaTbl[SceneName].AreaNames = areaNames
	self.m_SceneAreaTbl[SceneName].Region = region
	
	for index = 2, 6 do
		self.m_SceneAreaTbl[WarZoneDefenderSceneName[index]] = self.m_SceneAreaTbl[SceneName]
	end
end

function CBuildingAreaMgr:InitWarZoneLifeTreeAreaSetting(key, stationToArea, areaNames, region)
	assert(stationToArea and region and areaNames, "�����ļ��汾����!! ����°ڹֱ༭��,Ȼ�����µ��������ļ�.")
	
	local SceneName = self.m_SceneAreaKeyTbl[key]
	self.m_SceneAreaKeyTbl[key] = SceneName
	self.m_SceneAreaTbl[SceneName] = {}
	self.m_SceneAreaTbl[SceneName].StationToArea = stationToArea
	self.m_SceneAreaTbl[SceneName].AreaNames = areaNames
	self.m_SceneAreaTbl[SceneName].Region = region
	
	for index = 2, 6 do
		self.m_SceneAreaTbl[WarZoneLifeTreeSceneName[index]] = self.m_SceneAreaTbl[SceneName]
	end
end

function CBuildingAreaMgr:InitTongAreaSetting(key, areaNames, region)
	assert(region and areaNames, "�����ļ��汾����!! ����°ڹֱ༭��,Ȼ�����µ��������ļ�.")
	local SceneName = self.m_SceneAreaKeyTbl[key]
	self.m_SceneAreaKeyTbl[key] = SceneName
	self.m_SceneAreaTbl[SceneName] = {}
	self.m_SceneAreaTbl[SceneName].AreaNames = areaNames
	self.m_SceneAreaTbl[SceneName].Region = region
end

--function CBuildingAreaMgr:InitTongDefenderAreaSetting(key, areaNames, region)
--	assert(region and areaNames, "�����ļ��汾����!! ����°ڹֱ༭��,Ȼ�����µ��������ļ�.")
--	local SceneName = self.m_SceneAreaKeyTbl[key]
--	self.m_SceneAreaKeyTbl[key] = SceneName
--	self.m_SceneAreaTbl[SceneName] = {}
--	self.m_SceneAreaTbl[SceneName].AreaNames = areaNames
--	self.m_SceneAreaTbl[SceneName].Region = region
--end

cfg_require "scene/Fb_HYPY_Area"
cfg_require "scene/Fb_TongArea01_Area"
cfg_require "scene/Fb_TongArea02_Area"
cfg_require "scene/Fb_TongArea03_Area"
cfg_require "scene/Fb_TongChallenge_Area"
cfg_require "scene/Fb_HYPYDefender_Area"
cfg_require "scene/Fb_HYPYLifeTree_Area"
cfg_require "scene/Fb_TongDefenderArea01_Area"
cfg_require "scene/Fb_TongDefenderArea02_Area"
cfg_require "scene/Fb_TongDefenderArea03_Area"
cfg_require "scene/Fb_TongLifeTreeArea01_Area"
cfg_require "scene/Fb_TongLifeTreeArea02_Area"
cfg_require "scene/Fb_TongLifeTreeArea03_Area"

function CBuildingAreaMgr:GetSceneAreaName(SceneName, Pos)
	local areaData = self.m_SceneAreaTbl[SceneName]
	if not areaData then
		return ""
	end
	local areaLine = areaData.Region[Pos.x]
	if areaLine then
		local y = Pos.y
		for i = 1, #areaLine, 3 do
			if areaLine[i] <= y then
				if areaLine[i + 1] >= y then
					return areaData.AreaNames[areaLine[i + 2]]
				end
			else
				return ""
			end
		end
	end
	return ""
end

function CBuildingAreaMgr:GetSceneAreaNameByStationId(SceneName, stationId)
	local SceneArea = self.m_SceneAreaTbl[SceneName]
	assert(SceneArea, "�����ļ��ڷ�������")
	local AreaIndex = SceneArea.StationToArea[stationId]
	local AreaName = SceneArea.AreaNames[AreaIndex]
	return AreaName
end
