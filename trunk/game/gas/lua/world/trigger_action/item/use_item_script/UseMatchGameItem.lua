cfg_load "item/MatchGameItem_Common"
local TempAreaTbl = {
	["���׵۹�������ǲӪ��"] = true,
	["��ʥ������������ʿӪ��"]= true,
	["��˹�¾�������ǲӪ��"]= true,
	["��ʨ��Ѫ��Ӫ��"] = true,
	["��ʥ�����ӹ�Ӫ��"]= true,
	
	["�ӹ��¾�Ӫ��"]= true,
	["���׻�ʨ�ӿ���Ӫ��"]= true,
	["��ʥ��������Ӫ��"]= true,
	["�����¾�Ӫ��"]= true,
	
	["ѩ��¶̨"]= true,
	["��ԷС��"]= true,
	["���С��"]= true,

	["���ִ�"]= true,
	["��ʥ����Ӫ��"]= true,
	["��˹���ִ���"]= true,
	["���ֽ�ս��"]= true,
	
	["����ǰ�ߴ�����"]= true,
	["����ǰ�ߴ�����פ��"]= true,
	["����ǰ�ߴ�����ƽԭ"]= true,
	["��ʥǰ�ߴ�����"]= true,
	["��ʥǰ�ߴ�����פ��"]= true,
	["��ʥǰ�ߴ�����ƽԭ"]= true,
	["��˹ǰ�ߴ�����"]= true,
	["��˹ǰ�ߴ�����פ��"]= tr,
	["��˹ǰ�ߴ�����ƽԭ"]= true,
	["ǰ������2"]= true,
	["ǰ������"]= true,
	
}


local function DoMethod(Player, type, value)
	if type == "���ֵ" then
		if IsCppBound(Player) then
			Player:AddPlayerAfflatusValue(value)
		end
	end
end

local function CanPk(Player, BuffSkillName)
	if string.find(BuffSkillName, "����") then
		if IsCppBound(Player) then
			local scene = Player.m_Scene
			local Pos = CPos:new()
			Player:GetGridPos(Pos)
			local SceneName = scene.m_SceneName
			local areaName = g_AreaMgr:GetSceneAreaName(SceneName, Pos)
			if TempAreaTbl[areaName] then
				if string.find(areaName, "ǰ��")  and Player:CppGetLevel() <= 40 then
					Player:CppSetPKState(false)
					Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
					Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
					return
				end
				return 
			end
			local sceneType = scene.m_SceneAttr.SceneType
			if sceneType == 26 or sceneType == 27 or sceneType == 7 then
				return
			else
				Player:CppSetPKState(false)
				Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
				Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
				Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
			end
		end
	end
end

local function UseMatchGameItem(Conn, ItemName, RoomIndex, Pos)
	local Player = Conn.m_Player
	local CanUse = MatchGameItem_Common(ItemName,"CanUse")
	local BuffSkillName = MatchGameItem_Common(ItemName, "BuffName")
	
	local Arg = GetCfgTransformValue(false, "MatchGameItem_Common", ItemName, "Arg")
	--local Arg = MatchGameItem_Common(ItemName, "Arg")
	if CanUse ~= 1 then  --�Ƿ�����Ҽ�ʹ��
		return 
	end
	
	if Player:CppGetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_InDoingSkill) then
		MsgToConn(Conn, 838)
		return
	end
	local function CallBack(res)
		if not res then
			return 
		end
		if BuffSkillName ~= nil and BuffSkillName ~= "" then
			Player:PlayerDoItemSkill(BuffSkillName, 1)
		end
		local len = table.getn(Arg)
		if len ~= 0 then
			local type = Arg[1]
			local value = Arg[2]
			DoMethod(Player, type, value)
		end
		CanPk(Player, BuffSkillName)
	end
	local data = {}
	data["PlayerID"]	= Player.m_uID
	data["ItemName"]	= ItemName
	data["RoomIndex"] = RoomIndex
	data["Pos"]				= Pos
	data["sceneName"] = Player.m_Scene.m_SceneName
	CallAccountManualTrans(Conn.m_Account, "GatherLiveSkillDB", "DelMatchGameItem", CallBack, data)
end

return UseMatchGameItem
