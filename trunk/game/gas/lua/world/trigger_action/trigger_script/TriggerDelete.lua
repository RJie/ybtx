local function DeleteObject(Arg, Trigger, Player)
	if Player.m_Properties:GetType() == ECharacterType.IntObj then   --Npc����Trapɾ��Npc��Npc�뿪Trap��ɾ��
		return 
	end
	Player:SetOnDisappear(true) 
end


local function DeleteNpcIn(Arg, Trigger, Player)   --Npc����Trap��ɾ��
	if Player.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end
	if Player.m_TgtSentryIndex then
		if Trigger.m_SentryIndex == Player.m_TgtSentryIndex and
			Trigger.m_InBattleNum == 0 then
			Player:SetOnDisappear(false)
		end
	end
end

local funcTbl = {
	["Npc����Trap��ɾ��"] = DeleteNpcIn,
	["������ɾ��"] = DeleteObject,
}	

local function Script(Arg, Trigger, Player)
	local type = Arg[1]
	if IsFunction (funcTbl[type]) then
		funcTbl[type](Arg, Trigger, Player)
	end
end

return Script