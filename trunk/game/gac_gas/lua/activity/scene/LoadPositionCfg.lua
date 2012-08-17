cfg_load "scene/Position_Common"
cfg_load "liveskill/OreMap_Pos_Common"
gac_gas_require "scene_mgr/SceneCfg"

--local function GetItemTbl(item)
--	local tbl = loadstring("return" .. item)()
--	return tbl
--end

--����Position_Common��
--local function LoadPosition_Common()
--	for r, TblInfo in pairs(Position_Common) do 
--		local Position = GetItemTbl(TblInfo.Position)
--		rawset(TblInfo, "Position", Position)	
--	end 
--end

--LoadPosition_Common()
local function CheckPosition(scene, PosX, PosY, str, PosID)
	if scene then
		local CoreScene = scene.m_CoreScene
		local pos = CPos:new(PosX, PosY)
		local barrierType = CoreScene:GetBarrier(pos)
		if barrierType == EBarrierType.eBT_HighBarrier then
			CfgLogErr("�������ñ���д����",str.." ID("..PosID..") ��������("..PosX..","..PosY..")�ڵ�ͼ("..scene.m_SceneName..")���ϰ�")
		elseif barrierType == EBarrierType.eBT_OutRange then
			CfgLogErr("�������ñ���д����",str.." ID("..PosID..") ��������("..PosX..","..PosY..")������ͼ("..scene.m_SceneName..")��Χ")
		end
	end
end

function GetScenePosition(PosID, scene)
	PosID = tonumber(PosID)
	if Position_Common(PosID) then
		local PosX = Position_Common(PosID, "PosX")
		local PosY = Position_Common(PosID, "PosY")
		local SceneName = Position_Common(PosID, "SceneName")
		CheckPosition(scene, PosX, PosY, "Position_Common���ñ�", PosID)
		return PosX, PosY, SceneName
	else
		CfgLogErr("Position_Common���ñ���д����","����ID("..PosID..")������")
	end
end

function GetScenePositionTbl(PosID, scene)
	PosID = tonumber(PosID)
	if Position_Common(PosID) then
		local PosX = Position_Common(PosID, "PosX")
		local PosY = Position_Common(PosID, "PosY")
		local SceneName = Position_Common(PosID, "SceneName")
		CheckPosition(scene, PosX, PosY, "Position_Common���ñ�", PosID)
		return {PosX, PosY}, SceneName
	else
		CfgLogErr("Position_Common���ñ���д����","����ID("..PosID..")������")
	end
end

--��ȡ��������Ϣ
function GetOreMapPosition(PosID, scene)
	PosID = tonumber(PosID)
	if OreMap_Pos_Common(PosID) then
		local PosX = OreMap_Pos_Common(PosID, "PosX")
		local PosY = OreMap_Pos_Common(PosID, "PosY")
		local SceneName = OreMap_Pos_Common(PosID, "SceneName")
		CheckPosition(scene, PosX, PosY, "OreMap_Pos_Common���ñ�", PosID)
		return PosX, PosY, SceneName
	else
		CfgLogErr("OreMap_Pos_Common���ñ���д����","����ID("..PosID..")������")
	end
end
