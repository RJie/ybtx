cfg_load "scene/AreaTransport_Common"

g_SceneAreaTransportTbl = {}

function InitSceneAreaTransportSetting(SceneName, areaNames, region)
	assert(region and areaNames, "�����õ������ļ��汾����!! ����°ڹֱ༭��,Ȼ�����µ��������ļ�.")
	g_SceneAreaTransportTbl[SceneName] = {}
	g_SceneAreaTransportTbl[SceneName].AreaNames = areaNames
	g_SceneAreaTransportTbl[SceneName].Region = region
end

function GetSceneTransportAreaName(SceneName, Pos)
	local areaData = g_SceneAreaTransportTbl[SceneName]
	if not areaData then
		return SceneName
	end
	local areaLine = areaData.Region[Pos.x]
	if areaLine then
		local y = Pos.y
		for i = 1, #areaLine, 3 do
			if areaLine[i] <= y then
				if areaLine[i + 1] >= y then
					return SceneName .. "_" ..areaData.AreaNames[areaLine[i + 2]]
				end
			else
				return SceneName
			end
		end
	end
	return SceneName
end


--cfg_require "scene/ShiKanBuLei_Transport"
--cfg_require "scene/ShuangZiZhen_Transport"



local keys = AreaTransport_Common:GetKeys()
for n = 1,#keys do
	local SceneName = keys[n]
	local filename = AreaTransport_Common(SceneName, "SetAreaTransportFile")
	cfg_require(filename)
end
