--����Ĵ�����ָ ���һ��obj�󴫵���һ���ط�(Ҫ������)
gas_require "framework/main_frame/SandBoxDef"

local g_AreaFbSceneMgr = g_AreaFbSceneMgr
local AreaFb_Common = AreaFb_Common
local FbActionDirect_Common = FbActionDirect_Common
local CallDbTrans = CallDbTrans
local Entry = CreateSandBox(...)

function Entry.Exec(Conn, ServerIntObj, ObjName, GlobalID)
	local Player = Conn.m_Player
	local Scene = Player.m_Scene
	local SceneName = Scene.m_LogicSceneName

	--print("�㿪�˸�����")
	--Scene.m_KilledBossNum = Scene.m_KilledBossNum + 1
	
	-- ����Ѿ��ƹ����Ͳ��ټ���
	if Scene.m_AddAreaFbCount then
		return
	end

	Scene.m_AddAreaFbCount = true	-- ��ʾ�Ѿ����ǹ���
	local parameters = {}
	parameters["SceneID"] = Scene.m_SceneId
	
	local ResetMode = g_AreaFbSceneMgr.ResetMode[SceneName]
	if ResetMode[1] == 1 or ResetMode[1] == 2 then
		parameters["ExtraLimitType"] = SceneName
	end
	local ActionName = AreaFb_Common(SceneName, "ActionName")	
	local limitType = FbActionDirect_Common(ActionName, "MaxTimes")
	parameters["ActivityName"] = limitType
	parameters["SceneName"]	= SceneName
	
	for PlayerID, _ in pairs(Scene.m_tbl_Player) do
		parameters["PlayerId"] = PlayerID
		--print(PlayerID.."����")

		local function CallBack()
			-- ��ʾPlayerID�ӹ�����
			if not Scene.m_AddCountPlayerList then
				Scene.m_AddCountPlayerList = {}
			end
			Scene.m_AddCountPlayerList[PlayerID] = true
		end
		CallDbTrans("ActivityCountDB", "AddAreaFbCount", CallBack, parameters, PlayerID)
	end

end
 
return Entry
 
