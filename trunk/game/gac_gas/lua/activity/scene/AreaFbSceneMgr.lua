cfg_load "fb_game/AreaFb_Common"


g_AreaFbSceneMgr = {}
g_AreaFbSceneMgr["general"] = {}--����ͨ�����򸱱�(����������)
g_AreaFbSceneMgr["typeName"] = {"��Ȼ", "����", "�ƻ�", "����"} --���Ͷ�Ӧ����
g_AreaFbSceneMgr["BossNames"] = {}
g_AreaFbSceneMgr["BossNum"] = {}
g_AreaFbSceneMgr["ResetMode"] = {}
g_AreaFbLev = {}  -- �洢���������ĵȼ�
AddCheckLeakFilterObj(g_AreaFbSceneMgr)
AddCheckLeakFilterObj(g_AreaFbLev)

local function AreaFbSceneMgr()
	--��ͨ���� AreaFb_Common ��ȡ
	for _, SceneName in pairs(AreaFb_Common:GetKeys()) do
		local p = AreaFb_Common(SceneName)
--		if g_AreaFbSceneMgr["general"][p("Type")] == nil then
--			g_AreaFbSceneMgr["general"][p("Type")] = {}
--		end
--		table.insert(g_AreaFbSceneMgr["general"][p("Type")], SceneName)
		
		-- ��¼�����ȼ�
		g_AreaFbLev[SceneName] = AreaFb_Common(SceneName, "NeedLevel")
		
		-- ��¼��������ģʽ
		g_AreaFbSceneMgr.ResetMode[SceneName] = loadstring("return {" .. AreaFb_Common(SceneName, "ResetMode") .. "}")()
		
		-- ��¼����BOSS����
	  local BossNames = loadstring("return {" .. AreaFb_Common(SceneName, "BossName") .. "}")()
	  local BossNum = 0
	  if not g_AreaFbSceneMgr.BossNames[SceneName] then
	  	g_AreaFbSceneMgr.BossNames[SceneName] = {}
	  end
	  for _, Name in pairs(BossNames[1]) do
	  	BossNum = BossNum + 1
	  	g_AreaFbSceneMgr.BossNames[SceneName][Name] = true
	  end
	  g_AreaFbSceneMgr.BossNum[SceneName] = BossNum
	  
	end	
end
AreaFbSceneMgr()


