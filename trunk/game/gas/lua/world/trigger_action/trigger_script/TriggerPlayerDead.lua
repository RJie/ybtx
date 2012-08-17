-- ĳNpc����,����(������)Player����
local function Script(Arg, Trigger)
	
	local Scene = Trigger.m_Scene
	if not Scene then
		return
	end
	local PlayerTbl = Scene.m_tbl_Player 
	if not PlayerTbl then
		return 
	end
	for _,Player in pairs(PlayerTbl) do
		if not IsCppBound(Player) then
			return
		end
		if Player.m_ConfirmFlag then
			local npc = Player.m_ReplaceModel 
			g_NpcServerMgr:DestroyServerNpcNow(npc, false)
			Player:PlayerDoFightSkillWithoutLevel("��ɱ")
			Player.m_ConfirmFlag = false
		end
	end
end

return Script
