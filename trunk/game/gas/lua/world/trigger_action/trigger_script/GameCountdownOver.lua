local function Script(Arg, Trigger, Player)

	local Object = Trigger or Player
	local Scene = Object.m_Scene
--	if not Scene.m_SceneCountDownTick then
--		CfgLogErr("�����ű���д���ִ���!", "����("..Scene.m_SceneName..")û�н��е���ʱ,���ܴ����رյ���ʱ")
--		return
--	end
	if Scene.m_SceneCountDownTick then
		UnRegisterTick(Scene.m_SceneCountDownTick)
		Scene.m_SceneCountDownTick = nil
		Scene.m_SceneCountDown = nil
		Gas2Gac:CloseGameCountdownWnd(Scene.m_CoreScene)
	end
end

return Script