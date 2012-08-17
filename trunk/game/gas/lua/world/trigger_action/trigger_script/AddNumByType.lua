local function AddSameNpcNum(Arg, Trigger, Player)  --��ͬNpc�Ӽ���

	if not IsCppBound(Player) then
		return
	end
	-- ����
	if not IsCppBound(Trigger.FirstNpc) then
		if Player.m_CreateAnotherPigTick then
			UnRegisterTick(Player.m_CreateAnotherPigTick)
			Player.m_CreateAnotherPigTick = nil
		end
		Trigger.NpcCount = 1
		Trigger.FirstNpc	= Player
		Trigger.ExistNpcName = Player.m_Name -- ����NPC����
	else
		-- ����ȷ ������
		if Player.m_Name == Trigger.ExistNpcName
				and Trigger.NpcCount == 1 then				-- �ɹ���Trigger.NpcCount��Ϊ����
					
			Trigger.NpcCount = Trigger.NpcCount + 1
				-- ȡ��Tick����ԭ������NPC
			if Player.m_CreateAnotherPigTick then
				UnRegisterTick(Player.m_CreateAnotherPigTick)
				Player.m_CreateAnotherPigTick = nil
			end
			
			if Trigger.FirstNpc.m_CreateAnotherPigTick then
				UnRegisterTick(Trigger.FirstNpc.m_CreateAnotherPigTick)
				Trigger.FirstNpc.m_CreateAnotherPigTick = nil
			end	
			
			Player.m_IsNotEmbrace = true
			Trigger.FirstNpc.m_IsNotEmbrace = true
			
			-- ��Ч
			local ModelString = "fx/setting/other/other/fuwen_green/explode.efx"
			local StateString = "fuwen_green/explode"
			local PlayerID = Player.m_OwnerId
			local NewPlayer = g_GetPlayerInfo(PlayerID)
			local NpcID = Player:GetEntityID()
			local FirstNpcID = Trigger.FirstNpc:GetEntityID()
			if IsCppBound(NewPlayer) then
				Gas2Gac:UseItemTargetEffect(NewPlayer.m_Conn, ModelString,StateString,NpcID)
				Gas2Gac:UseItemTargetEffect(NewPlayer.m_Conn, ModelString,StateString,FirstNpcID)
			end
			--Gas2Gac:UseItemTargetEffect(Player:GetIS(0), ModelString, StateString, Player:GetEntityID())
			
			local function DeleteTwoNpc()
				-- ������������ʧ
				Player:SetNoDissolve()
				g_NpcServerMgr:DestroyServerNpcNow(Player, false)
				-- ��һ������ʧ
				if IsCppBound(Trigger.FirstNpc) then
					Trigger.FirstNpc:SetNoDissolve()
					g_NpcServerMgr:DestroyServerNpcNow(Trigger.FirstNpc, false)
				end		
			end
			
			RegisterOnceTick(Player, "DeleteTwoNpcTick", DeleteTwoNpc, 1000)
		end
	end
	
	-- �������2��
	if Trigger.NpcCount == 2 then
		-- �ӷ�
		local TargetName = Arg
		if not TargetName or TargetName == "" then
			return
		end
		local Player = g_GetPlayerInfo(Player.m_OwnerId)
		if not IsCppBound(Player) then
			return		
		end
		CMercenaryRoomCreate.KillTargetAddNum(Player.m_Scene, TargetName)	
	end
end

local function AddNumByBuff(Arg, Trigger, Player) --��buff��Trap�ӻ����
	if not IsCppBound(Player) then
		return
	end
	
	local stateCascade = Player:GetStateCascade(Arg)
	if stateCascade > 0 then
		g_MatchGameMgr:AddMatchGameCount(Player, 11, Arg, stateCascade)
	end
end

local function AddMercActionNum(Arg, Trigger, Player)  --Ӷ��ѵ����Ӽ���,Ӷ��ѵ���Npc�Ӽ���
	if Player.m_OwnerId ~= nil then
		Player = g_GetPlayerInfo(Player.m_OwnerId)
	end
	
	if not IsCppBound(Player) then
		return
	end
	local TargetName = Arg
	if not TargetName or TargetName == "" then
		return
	end
	CMercenaryRoomCreate.KillTargetAddNum(Player.m_Scene, TargetName)
end

local function NpcAddQuestNum(Arg, Trigger, Player)
	local varname = Arg[2]
	local questname = Arg[1]
	if not IsCppBound(Player) then
		Player = g_GetPlayerInfo(Trigger.m_OwnerId)
		if Trigger.m_IsTestDeadOnTimeOver then
			local str = "Npc OwnerID:"..Trigger.m_OwnerId.."���ID:"..Player.m_uID
			LogErr("����������",str)
		end
	else
		if Trigger.m_IsTestDeadOnTimeOver then
			local str = "���ID:"..Player.m_uID
			LogErr("����������",str)
		end
	end
	
	if not Player then
		return
	end
	
	if Trigger.m_IsTestDeadOnTimeOver then
		Trigger.m_IsTestDeadOnTimeOver = nil
	end
	
	g_AddQuestVarNumForTeam(Player, questname, varname, 1)
end

local function TrapAddQuestNum(Arg, Trigger, Player)
	if Player.m_Properties:GetType() == ECharacterType.Npc then
		local PlayerId = Player.m_OwnerId 
		if PlayerId == nil then
			PlayerId = Trigger.m_OwnerId
			if PlayerId == nil then
				return 
			end
		end
		Player = g_GetPlayerInfo(Player.m_OwnerId)
		if not Player then
			return
		end
	else
		if Player.m_Properties:GetType() ~= ECharacterType.Player then
			return 
		end 
	end
	if Player.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	local QuestName = Arg[1]
	local VarName = Arg[2]
	local AddNum = Arg[3]
	g_AddQuestVarNumForTeam(Player, QuestName,VarName,AddNum)
end

local funTbl = {
	[ECharacterType.Npc]		= NpcAddQuestNum,
	[ECharacterType.Trap]		= TrapAddQuestNum,
}

local function AddQuestNum(Arg, Trigger, Player) --Npc����ȻTrap���������,��Ҳ�Trap���������
	local type = Trigger.m_Properties:GetType()
	if IsFunction (funTbl[type]) then
		funTbl[type](Arg, Trigger, Player)
	end
end

local function AddSmallFbNum(Arg, Trigger, Player)  --С����,matchgame,���Ӵӳ涴�ܳ�
	if Player.m_Properties:GetType() == ECharacterType.Player then
		if Player.m_OwnerId ~= nil then
			Player = g_GetPlayerInfo(Player.m_OwnerId)
		else
			Player = Player
		end
		if not Player or not IsCppBound(Player) then
			return
		end
		
		if not Player.m_MatchGameCount then
			Player.m_MatchGameCount = 0
		end
		
		g_MatchGameMgr:AddMatchGameCount(Player, 2, Trigger.m_Properties:GetCharName())
		return
	end
	
	if Player.m_Properties:GetType() == ECharacterType.Npc then
		if not IsCppBound(Player) then
			return
		end
		local scene = Trigger.m_Scene
		g_MatchGameMgr:AllTeamAddCount(scene, 2, Trigger.m_Properties:GetCharName())
		return
	end
end


local AddNumFunTbl = {
	["��ͬNpc�Ӽ���"] = AddSameNpcNum,
	["��buff��Trap�ӻ����"] = AddNumByBuff,
	["Ӷ��ѵ����Ӽ���"] = AddMercActionNum,
	["С�����Ӽ���"] = AddSmallFbNum,
	["����Ӽ���"] = AddQuestNum,
}	

local function Script(Arg, Trigger, Player)
	local type = Arg[1]
	if IsFunction (AddNumFunTbl[type]) then
		AddNumFunTbl[type](Arg[2], Trigger, Player)
	end
end

return Script