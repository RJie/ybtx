local function Script(Arg, Trigger, Player)
	local thisArg = Arg
	local centerPos
	if thisArg[2] == "NpcΪ����" then
		local pos = CPos:new()
		Trigger:GetGridPos(pos)
		centerPos = {pos.x, pos.y}
	elseif thisArg[2] then
		local ID = thisArg[2]
		local CreatScene = Trigger.m_Scene
		local x, y, scene = GetScenePosition(ID, CreatScene)
		if scene ~= CreatScene.m_SceneName then
			CfgLogErr("npc�������ñ�ű���д����",Trigger.m_Properties:GetCharName().."(������̬�ڹ��ļ�)�ű�����д������ID("..ID..")�����������д�ĵ�ͼ(".. scene ..")��ʵ�ʵ�ͼ(".. CreatScene.m_SceneName ..")������")
			return
		end
		centerPos = {x,y}
	end
	
	g_DynamicCreateMgr:Create(Trigger.m_Scene, thisArg[1], centerPos)
end 

return Script