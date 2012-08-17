--gas_require "world/player/PlayerDeadDrop"
gas_require "world/trigger_action/obj/CollObj/IntObjCollObjGac2Gas"
gas_require "fight/fightskill/SpecailSkill"
gas_require "world/tong_area/TongBattleCountMgr"
gas_require "log_mgr/CLogMgr"

CCharacterMediatorCallbackHandler = class( CCharacterServerCallbackHandler, ICharacterMediatorCallbackHandler )
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
	["��˹ǰ�ߴ�����פ��"]= true,
	["��˹ǰ�ߴ�����ƽԭ"]= true,
	["ǰ������2"]= true,
	["ǰ������"]= true,
	
}

--/**��PK����**/
--PkCriminalTime = 20		--PK�ͷ�ʱ�� 20��
--KillerPkCriminalTime = 30		--��ɱ״̬PK�ͷ�ʱ�� 30��

--������ߣ����������Ϣ
local function ClearEquipAttrTranID(player)
    local attrTranIDTbl = player.m_EquipAttrTransIDTbl
    for i, v in pairs(attrTranIDTbl) do
        local proptyTbl = v
        for j, w in pairs(proptyTbl) do
            local tranID = w["TranID"]
            if tranID ~= nil then
                player:DestroyTransaction(tranID)
            end
        end
    end
    attrTranIDTbl = nil
end

function CCharacterMediatorCallbackHandler:OnDestroyed(Player)
    ClearEquipAttrTranID(Player)
    CStoneMgr.GetStoneMgr():DelAllStonePropertyValue(Player)--��ʯ���Գ���
    --print( "CCharacterMediatorCallbackHandler:OnDestroyed",Player.m_uID)
	if Player.m_Conn.m_ChangeToServer then
		if Player.m_OtherServerInfo and next(Player.m_OtherServerInfo) then
			local Ip = Player.m_OtherServerInfo["Ip"]
			local Port = Player.m_OtherServerInfo["Port"]
			local sKey = Player.m_OtherServerInfo["sKey"]
			local lastMsgIdStr = Player.m_OtherServerInfo["lastMsgIdStr"]
			Gas2Gac:RetEnterOtherServer(Player.m_Conn, Ip, Port, 1, sKey, lastMsgIdStr)
			
		end
		ChangeSceneOver(Player)
	end
end

function CCharacterMediatorCallbackHandler:OnSetLockObj( uEntityID, uTargetEntityID)
	--print( "CCharacterMediatorCallbackHandler:OnSetLockObj")
	local Entity = CEntityServerManager_GetEntityByID(uEntityID)
	local TargetEntity = CEntityServerManager_GetEntityByID(uTargetEntityID)
	Entity.m_LockingObj = TargetEntity
	if Entity.m_LockingIntObj then
		Entity.m_LockingIntObj = nil
	end
end

--�����򿪵Ĵ���
function CCharacterMediatorCallbackHandler:ListeningOpenWnd(pCharacter)
--print("ListeningOpenWnd(pCharacter)")
	--pCharacter:AddListeningWnd()
	--pCharacter:DelListeningWnd()
	--�������ڽ��׹����У��ƶ���ȡ�����ף��رս������
	if pCharacter.m_Conn.busystate ~= nil and
		pCharacter.m_Conn.busystate == 1 then
		local playerTran = CPlayerTran:new(uCharID)
		playerTran:ClearTradeState(pCharacter.m_Conn)
	end
	
	--�����Ʒʹ�ö���
	if pCharacter.m_UseItemLoadingTick then
		StopItemProgressTick(pCharacter)
	end
	
	if pCharacter.m_CollectResTick then
		TongStopLoadProgress(pCharacter)
	end
	
	if pCharacter.m_PickUpNpcID then
		BreakPlayerPickUpItem(pCharacter)
	end
	
	if pCharacter.m_ActionLoadingTick then
		BreakPlayerActionLoading(pCharacter)
	end
	
	if pCharacter.m_CollIntObjID then
		BreakPlayerCollItem(pCharacter)
	end
	
	if pCharacter.m_PickOre then
		pCharacter.m_PickOre:PickOreEnd(pCharacter)
	end
	--if pCharacter.m_ActionState then
	--	CancelActionState(pCharacter)
	--end
	
	if pCharacter.m_KickBehavor then
		CKickBehavior.CancelKickBehavior_S(pCharacter)
	end
	
	if pCharacter.m_CommLoadProTick then
		CommStopLoadProgress(pCharacter, EProgressBreak.ePB_Move)
	end
end

--���㾭��ֵ
function CalculateSingleExp(MonsterLevel,CharacterLevel)
	local uLevelDiff = MonsterLevel - CharacterLevel;
	local Exp=0

	if uLevelDiff <= -20 then
		return Exp
	end

	if uLevelDiff > 5 then
		uLevelDiff = 5
	end

	Exp = ((CharacterLevel*3)+50) * (1 + uLevelDiff*4 / (CharacterLevel+60))
	return Exp
end

local function UpdateEquipDurability(Conn, result)
    local equipInfoTbl = result["EquipInfoTbl"]  
    for i=1, # equipInfoTbl do
        local equipID = equipInfoTbl[i][1]
        local equipDuraState = equipInfoTbl[i][2]
        local equipRet = equipInfoTbl[i][3]
        local equipPart = equipInfoTbl[i][4]
        local equipType = equipInfoTbl[i][5]
        local equipName = equipInfoTbl[i][6]
        local curDuraValue = equipInfoTbl[i][7]
        local maxDuraValue = equipInfoTbl[i][8]
        local shortCutRet = equipInfoTbl[i][9]
        local newCommonlySkill = equipInfoTbl[i][10]
        local equipMgr = g_GetEquipMgr()
        equipMgr:GetEquipDuraState(Conn, equipID, equipDuraState, equipPart, equipRet, equipType, equipName, curDuraValue, maxDuraValue, shortCutRet, newCommonlySkill)
    end
end

local function DelWithEquipTimeInfo(Conn, AllInfo)
	local Player = Conn.m_Player
	if not Player then return end
    local equip_mgr = g_GetEquipMgr()
	for y=1, table.maxn(AllInfo) do
		local nBigID,nIndex,nItemID,eEquipPart,EquipRet = AllInfo[y]["nBigID"],AllInfo[y]["nIndex"],AllInfo[y]["nItemID"],AllInfo[y]["eEquipPart"],AllInfo[y]["EquipRet"]
		local equip_info = equip_mgr:GetEquipFromRet(nItemID,Player.m_uID,nBigID,nIndex,EquipRet)
		local bTimeOut = EquipRet.m_tblTimeOut[2]
		local old_time = EquipRet.m_tblTimeOut[1]
		if ((not bTimeOut ) and (old_time and old_time > 0) )then
            equip_info:DisablePropty(Player,eEquipPart, "DelWithEquipTimeInfo")
		end
    end
end

function CCharacterMediatorCallbackHandler:OnDead(Attacker, BeAttacker)
	--if BeAttacker.m_Properties:GetType() == ECharacterType.Player then	--����ж�Ӧ���Ƕ���ģ�BeAttacker�Ǹ�CharacterMediator���϶������
	if not IsServerObjValid(BeAttacker) then
		return
	end
	
	CClaspBehavior.DorpBeforClear(BeAttacker) -- �����ұ��ŵĶ����Ƿ���Ҫ�����ǰ���ڵ���
	BeAttacker:ClearPlayerActionState()
	
	--�����Ʒʹ�ö���
	if BeAttacker.m_UseItemLoadingTick then
		StopItemProgressTick(BeAttacker)
	end
	
	if BeAttacker.m_CollectResTick then
		TongStopLoadProgress(BeAttacker)
	end
	
	-- TODO:
	if BeAttacker.m_ActionLoadingTick then
		BreakPlayerActionLoading(BeAttacker)
	end
	
	if BeAttacker.m_CommLoadProTick then
		CommStopLoadProgress(BeAttacker)
	end
	
	if BeAttacker.m_PickOre then
		BeAttacker.m_PickOre:PickOreEnd(BeAttacker)
	end
	
	BeAttacker.m_SetCtrlState = 0
	BeAttacker.m_tblDoSkillCtrlState = {}
	DeadUpdatePlayerInfo(Attacker, BeAttacker)--�ڸ�����,�������˾͸���
	if BeAttacker.m_ReplaceModel ~= nil then
		g_NpcServerMgr:DestroyServerNpcNow(BeAttacker.m_ReplaceModel, false)
		BeAttacker.m_ReplaceModel = nil 
	end
	
	local AttackScene = BeAttacker.m_Scene
--		local PkType = AttackScene.m_SceneAttr.PkType								--��ͼPK����
	
	local PKState = BeAttacker:CppGetPKState()
	if BeAttacker.RebornCountTick then
		BeAttacker:RebornCountTime()
		BeAttacker.m_RebornCountTime = BeAttacker.m_RebornCountTime + 5
		if BeAttacker.m_RebornCountTime >= 30 then
			BeAttacker.m_RebornCountTime = 30
		end
	end
	--������Ǹ���������,�������ָ����
	BeAttacker:DeadToClientMsg()
	
	
	local IsKillByNpc
	local NpcName = ""
	local KillerId
	local killerEntityId
	local beKilledByNpc = true
	if IsServerObjValid(Attacker) and Attacker ~= BeAttacker then
		local Master = Attacker:GetMaster()
		local Killer = nil									--ɱ����
		if Attacker.m_Properties:GetType() == ECharacterType.Player then
		    beKilledByNpc = false
		    if Master == nil then
				Killer = Attacker
				KillerId = Attacker.m_uID
				killerEntityId = Attacker:GetEntityID()
			end
		elseif Master and Master ~= BeAttacker and Master.m_Properties:GetType() == ECharacterType.Player then
			Killer = Master
			KillerId = Master.m_uID
			killerEntityId = Master:GetEntityID()
		else
			IsKillByNpc = true
			NpcName = Attacker.m_Properties:GetCharName()
			killerEntityId = Attacker:GetEntityID()
		end
		if Killer then
			local scene = Killer.m_Scene
			if scene.m_SceneAttr.SceneType == 13 then
				g_MatchGameMgr:AddMatchGameCount(Killer, 10, "ɱ�˵÷�")
				g_MatchGameMgr:AddMatchGameCount(BeAttacker, 14, "�����÷�")
				for BuffName, v in pairs(g_MatchGameMgr:GetCountInfoByType(12)) do
					local stateCascade = BeAttacker:GetStateCascade(BuffName)
					if stateCascade > 0 then
						g_MatchGameMgr:AddMatchGameCount(BeAttacker, 12, BuffName, stateCascade)
					end
				end
			end
			--��¼ɱ������
			Killer.m_KillPlayerCount = Killer.m_KillPlayerCount + 1
			if PKState == true then
				if scene then
					local nType = scene.m_SceneAttr.SceneType
					if nType == 7 and g_WarZoneMgr.m_Warring then
						CTongBasic.UpdateExploitOnKillOther(Killer, BeAttacker)
					end
					if nType == 26 then
						local KillerPlayerId = Killer.m_Conn.m_Player.m_Properties:GetCharID()
						local data = {}
						data["type"] = 2
						data["charId"] = KillerPlayerId
						CallAccountAutoTrans(Killer.m_Conn.m_Account, "GasTongOtherDB", "AddCharData", CallBack, data, KillerPlayerId)
					end
				end
			end
			--�������Ʒ��Ǯ
--/**��PK����**/
--				if PkType ~= EZoneType.eZT_Other then
--					PlayerDeadDrop(BeAttacker, Killer)
--				end
--				if PkType ~= EZoneType.eZT_WarZone and PkType ~= EZoneType.eZT_Other then
				--�����ɱ���û�п�����ɱ״̬,��ɱ�˵���Ҽ�PKֵ.
			if IsCppBound(Killer) and IsCppBound(BeAttacker) then
				if Killer:CppGetPKState() == true and BeAttacker:CppGetPKState() == true then
					local param = {}
					param["attackerId"] = KillerId
					param["beAttackedId"] = BeAttacker.m_uID
					if Killer.m_Conn.m_Account then
						local function CallBack(result)
							if not result then
								return
							end
							if IsCppBound(Killer) then
								Killer:AddPkValue(BeAttacker)
							end
						end
						CallAccountAutoTrans(Killer.m_Conn.m_Account, "CharacterMediatorDB", "GetPkFlagInfo", CallBack, param)
					end
				end
			end
--					--����Կ�״̬��ɱ��,��ɱ���߼��൱��ͬ�ȼ��ֵ�5������.
--					if Killer:CppGetPKState() == EPKState.ePKS_Rivalry then
--						if BeAttacker:CppGetPKState() == EPKState.ePKS_Rivalry then
--							Killer.m_CriminalTime = PkCriminalTime
--							Killer:PkCriminalTick()
--						end
--						local addExp = CalculateSingleExp(BeAttacker:CppGetLevel(),Killer:CppGetLevel())*5
--						AddPlayerExp(Killer, addExp)
--						MsgToConn(Killer.m_Conn, 193023, BeAttacker.m_Properties:GetCharName(), addExp)
--					end
--				elseif PkType == EZoneType.eZT_WarZone and PkType ~= EZoneType.eZT_Other then
--					if Killer:CppGetPKState() == EPKState.ePKS_Rivalry or Killer:CppGetPKState() == EPKState.ePKS_Killer then
--						if g_WarZoneMgr.m_Warring then
--							if BeAttacker:CppGetPKState() == EPKState.ePKS_Rivalry then
--								Killer.m_CriminalTime = PkCriminalTime
--								Killer:PkCriminalTick()
--							end
--							local KillerTongId = Killer.m_Conn.m_Player.m_Properties:GetTongID()
--							if KillerTongId ~= 0 then						
--								local addExploit = 1
--								local data = {}
--								data["uTongID"] = KillerTongId
--								data["uExploit"] = addExploit
--								
--								CallAccountAutoTrans(BeAttacker.m_Conn.m_Account, "GasTongBasicDB", "UpdateExploit", nil, data, KillerTongId)
--								MsgToConn(Killer.m_Conn, 9419, BeAttacker.m_Properties:GetCharName(), addExploit)
--							end
--						end
--					end
--				end
			MsgToConn(BeAttacker.m_Conn, 193002, Killer.m_Properties:GetCharName())
		end
	end
	
	local data = { 
				["deadTimes"] = 1,
				["KillerId"] = KillerId,
				["BeAttackerId"] = BeAttacker.m_uID,
				["SceneName"] = BeAttacker.m_Scene.m_SceneName,
				["IsKillByNpc"] = IsKillByNpc,
				["NpcName"] = NpcName,
				["AttackTimes"]=0, 
				["BeAttackTimes"]=0, 
				["DeadFlag"] = true, 
				["BeKilledByNpc"] = beKilledByNpc,
			}
		-- ��������������ܲ���װ���;�
		local game, room = g_MatchGameMgr:GetRoomByScene(BeAttacker.m_Scene)
		if room then
			if room.m_CfgData.EquipDura == 1 or room.m_CfgData.EquipDura == 3 then
				data["BeKilledByNpc"] = nil
			end
		end
		
    local function CallBack(suc, result)
        if suc then
            if BeAttacker then
                local Conn = BeAttacker.m_Conn
                UpdateEquipDurability(Conn, result)
            end
	    end
    end
	if BeAttacker.m_Conn.m_Account then
		CallAccountAutoTrans(BeAttacker.m_Conn.m_Account, "CharacterMediatorDB", "SaveCharDeadTimes", CallBack, data)
	end
	AddKillChallengePersonNum(killerEntityId)
	g_TongBattleCountMgr:KillPersonCallBack(killerEntityId)
	g_TongBattleCountMgr:AddDeathCount(BeAttacker)
end

function CCharacterMediatorCallbackHandler:OnPermitReborn( uObjID1, uObjID2 )
	--print("CCharacterMediatorCallbackHandler:OnPermitReborn", uObjID1, uObjID2)
	--������ԭ����ѡ����ʾuObjID1����uObjID2���Ƿ������
	local CharacterDictator1 = CCharacterDictator_GetCharacterByID(uObjID1)
	local CharacterDictator2 = CCharacterDictator_GetCharacterByID(uObjID2)
	
	if not CharacterDictator1 or not IsServerObjValid(CharacterDictator1) 
		or not CharacterDictator2 or not IsServerObjValid(CharacterDictator2) then
		return
	end
	CharacterDictator2.b_PermitReborn = true
	CharacterDictator2.b_RebornFromID = uObjID1
	local RebornPos = CPos:new()
	CharacterDictator1:GetGridPos( RebornPos )
	CharacterDictator2.RebornPos = RebornPos
	Gas2Gac:OnPermitReborn(CharacterDictator2.m_Conn,CharacterDictator1.m_Properties:GetCharName())
end

function CCharacterMediatorCallbackHandler:OnDoNonCombatStateMagicOp(MopName, ArgValue, SourceEntityID, TargetEntityID)
	if(MopName == "����ʱ�˳�����") then
		return
	elseif(MopName == "С������Ϸ����") then
		local Player = CEntityServerManager_GetEntityByID(TargetEntityID)
		if IsServerObjValid(Player) then 
			g_MatchGameMgr:AddMatchGameCount(Player, 5, MopName)
		end
		return
	elseif (MopName == "���ɱ¾") then
		local Player = CEntityServerManager_GetEntityByID(TargetEntityID)
		if IsServerObjValid(Player) then 
			Player:IsFirstTimeAndSendMsg("���ɱ¾", 2007)
		end
		return
	elseif(MopName == "��ҹ��������") then
		local Player = CEntityServerManager_GetEntityByID(TargetEntityID)
		local PlayerPos = CFPos:new()
		Player:GetPixelPos(PlayerPos)
		local NpcLevel = Player:CppGetLevel()
		local Scene = Player.m_Scene
	
		if not IsCppBound(Player.m_ReplaceModel) then 
			local NewNpc = g_NpcServerMgr:CreateServerNpc("��ҹ������1", NpcLevel, Scene, PlayerPos)
			if not IsServerObjValid(NewNpc) then
				return
			end
			NewNpc:ServerDoSkill("��ҹ���������ñ�����",1, Player)
			local uPosX,uPosY= GetScenePosition(260001)
			local Pos = CPos:new()
			Pos.x = uPosX
			Pos.y = uPosY
			Player:SetGridPosByTransport(Pos)
			
			Player.m_ReplaceModel = NewNpc
			Player.m_ConfirmFlag = true
		end
		return
	elseif (MopName == "��������״̬") then
		local Player = CEntityServerManager_GetEntityByID(TargetEntityID)
		local scene = Player.m_Scene
		local Pos = CPos:new()
		Player:GetGridPos(Pos)
		local SceneName = scene.m_SceneName
		local areaName = g_AreaMgr:GetSceneAreaName(SceneName, Pos)
		local sceneType = scene.m_SceneAttr.SceneType 
		if sceneType == 26 or sceneType == 27 or sceneType == 7 or TempAreaTbl[areaName] then
			if string.find(areaName, "ǰ��") and Player:CppGetLevel() <= 40 then
				Player:CppSetPKState(false)
				Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
				Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
				Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
				return
			end
		else
			Player:CppSetPKState(false)
			Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
			Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
			Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
			return
		end
		return
	end
	assert(IsNumber(ArgValue))
	local TargetEntity = CEntityServerManager_GetEntityByID(TargetEntityID)
	assert(TargetEntity)
	assert(IsNumber(TargetEntity.m_uNonCombatValue[MopName]))
	TargetEntity.m_uNonCombatValue[MopName] = TargetEntity.m_uNonCombatValue[MopName] + ArgValue
	--�������ս����Ϊͨ��ִ�в���
end

function CCharacterMediatorCallbackHandler:OnCancelNonCombatStateMagicOp(MopName, ArgValue, SourceuEntityID, TargetEntityID)
	if(MopName == "����ʱ�˳�����") then
		local TargetEntity = CEntityServerManager_GetEntityByID(TargetEntityID)
		--ʱ�䵽��,�˳�������ᱦ����
		CaptureTreasure.PlayerBuffTimeIsOver(TargetEntity)
		return
	elseif(MopName == "С������Ϸ����") then
		return
	elseif (MopName == "���ɱ¾") then
		return
	elseif(MopName == "��ҹ��������") then
		return
	elseif(MopName == "��������״̬") then
		local Player = CEntityServerManager_GetEntityByID(TargetEntityID)
		local scene = Player.m_Scene
		local Pos = CPos:new()
		Player:GetGridPos(Pos)
		local SceneName = Player.m_Scene.m_SceneName
		local areaName = g_AreaMgr:GetSceneAreaName(SceneName, Pos)
		if scene.m_AreaInfoTbl then
			local pkState = scene.m_AreaInfoTbl[areaName].m_AreaState
			Player:CppSetPKState(pkState)
			Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
			Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
			Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
		end
		return
end
	assert(IsNumber(ArgValue))
	local TargetEntity = CEntityServerManager_GetEntityByID(TargetEntityID)
	assert(TargetEntity)
	assert(IsNumber(TargetEntity.m_uNonCombatValue[MopName]))
	TargetEntity.m_uNonCombatValue[MopName] = TargetEntity.m_uNonCombatValue[MopName] - ArgValue
	--�������ս����Ϊͨ�ó���ħ������
end

function CCharacterMediatorCallbackHandler:OnCreateTempSkill(uEntityID,SkillName,uSkillLevel,uTime,uID)
	--print( "CCharacterMediatorCallbackHandler:OnCreateTempSkill",SkillName,uSkillLevel,uTime,uID)
	local Entity = CEntityServerManager_GetEntityByID(uEntityID)
	if IsServerObjValid(Entity) then 
		Gas2Gac:CreateTempSkill( Entity:GetConnection(),SkillName,uSkillLevel,uTime,uID)
	end
end

function CCharacterMediatorCallbackHandler:OnRemoveTempSkill(uEntityID,uID)
	--print( "CCharacterMediatorCallbackHandler:OnRemoveTempSkill",uID)
	local Entity = CEntityServerManager_GetEntityByID(uEntityID)
	if IsServerObjValid(Entity) then 
		Gas2Gac:RemoveTempSkill( Entity:GetConnection(),uID )
	end
end

function CCharacterMediatorCallbackHandler:OnCastTempSkill(uEntityID,uID)
	--print( "CCharacterMediatorCallbackHandler:OnRemoveTempSkill",uID)
	local Entity = CEntityServerManager_GetEntityByID(uEntityID)
	if IsServerObjValid(Entity) then 
		Gas2Gac:OnCastTempSkill( Entity:GetConnection(),uID )
	end
end

-- ��������
function CCharacterMediatorCallbackHandler:OnRidingHorseChanged(uEntityID, strHorseName, strHorseType)
	--print( "CCharacterMediatorCallbackHandler:OnRidingHorseChanged",uEntityID, strHorseName, strHorseType)
	local Entity = CEntityServerManager_GetEntityByID(uEntityID)
	if not IsServerObjValid(Entity) then
		return
	end
	local ResID = g_sParseHorseTblServer[strHorseName]
	Entity.m_Properties:SetHorseResID(ResID)
	if ResID and ResID > 256 then
		LogErr("ResID ������Χ", ResID)
	end
	Entity.m_Properties:SetHorseType(strHorseType)
	Gas2Gac:UpdateModel( Entity:GetConnection() ,uEntityID)
	Gas2Gac:UpdateModel( Entity:GetIS(0) ,uEntityID)
end

-- ��е
function CCharacterMediatorCallbackHandler:OnForbitUseWeapon(uEntityID, bForbit)
	local Character = CEntityServerManager_GetEntityByID(uEntityID)
	if not IsServerObjValid(Character) then
		return
	end
	Character:ForbidUseWeapon(bForbit)
end

----��ת�����ص�����
function CCharacterMediatorCallbackHandler:OnTransfered(Player, OldCoreScene, OldPosX, OldPosY, NewCoreScene)
	local OldScene = g_SceneMgr:GetSceneByCoreScene(OldCoreScene)
	assert(OldScene == Player.m_Scene)
	
	local function ResumeServantByTransfered()
		local userName 		= Player.m_Conn.m_UserName
		local AccountID 	= Player.m_AccountID
		local data = {}
		data["char_id"]			= Player.m_uID
		
		local function callback(result)
			if IsCppBound(Player) then
				Player:LoadServantFromDB(result, true)
			end
		end
		
		CallDbTrans("CharacterMediatorDB", "ResumeServantByTransfered", callback, data, username, AccountID)
	end
	
	if IsServerObjValid(Player) then
		local Scene = g_SceneMgr:GetSceneByCoreScene(NewCoreScene)
		--Player.m_Scene.m_tbl_Player[Player.m_uID] = nil
		local RebornType = Player.m_Scene.m_SceneAttr.RebornType or 1   --������һ���͵Ĵ���
		if not Player:CppIsLive() then
			apcall(Player.Reborn, Player, 1)
		end
		
		local SavePos = Player.m_LastSceneSavePos
		if not SavePos then
			Player:PlayerLeaveCurentScene(OldPosX, OldPosY)
		else
			local Pixelx = SavePos[1]*EUnits.eGridSpanForObj
			local Pixely = SavePos[2]*EUnits.eGridSpanForObj
			apcall(Player.PlayerLeaveCurentScene, Player, Pixelx, Pixely)
			Player.m_LastSceneSavePos = nil
		end
		--�ڳ������л�ʱ,�ȵ������е���������
		apcall(g_PlayerLeaveSceneFb, Player, OldScene)
	---------------------------------------
		--Player:ShowHideQuestTraceBackWnd(Player.m_Scene.m_SceneAttr.SceneType,Scene.m_SceneAttr.SceneType)
		
		Player.m_Scene = Scene
		Player.m_IsChangeSceneing = nil
		Scene.m_tbl_Player[Player.m_uID] = Player
		apcall(Player.ChangeSceneSavePos, Player)
		apcall(NewServerPlayerChangeScene, Player)
		
		StressRpcToClient(Gas2Gac,"ChangedInSameSceneSuc", Player.m_Conn)
		
		--�������յ��Ľ��������б�
		Player.m_Conn.invitor_info_tbl= {}
		apcall(LeaveScene, OldScene, Player)
		apcall(ResumeServantByTransfered)
	end
end

--function CCharacterMediatorCallbackHandler:OnCaughtViewSightOf(OwnCharacter, uEntityID)
--print("CCharacterMediatorCallbackHandler:OnCaughtViewSightOf")
--	local Character = CEntityServerManager_GetEntityByID(uEntityID)
--	if not Character then
--		return
--	end
--	if Character:GetGameEntityType()==EGameEntityType.eGET_CharacterMediator then
		--- ������˵���ˣ���ʱ�����Զ���ӹ��ܣ�����Ҫ��ȥ������ע�ͼ��ɣ�
		--�Ѿ�ʵ��������ң���ͬһ�������϶��и������ɱ������ʱ�Զ���ӵĹ���
--		if Character:CppGetCamp() ~= OwnCharacter:CppGetCamp() then
--			--��Ӫ��ͬ������
--			return
--		end
--		
--		local pos1 = CPos:new()
--		Character:GetGridPos(pos1)
--		local SceneName = Character.m_Scene.m_SceneName
--		local AreaName1 = g_AreaMgr:GetSceneAreaName(SceneName, pos1, nil, nil, nil )
--		--������û�����񷵻�
--		if not g_AreaQuestMgr[AreaName1] then
--			return
--		end
--		
--		local pos2 = CPos:new()
--		OwnCharacter:GetGridPos(pos2)
--		local AreaName2 = g_AreaMgr:GetSceneAreaName(SceneName, pos2, nil, nil, nil )
--		--����ͬһ���򷵻�
--		if AreaName1 ~= AreaName2 then
--			return
--		end
--		
--		local function CallBack(pre_OwnTeamID,pre_TargetTeamID,result,TeamInfo)
--		end
--	
-- 		local parameters = {}
--		parameters["uCharID"]	= OwnCharacter.m_uID
--		parameters["uTargetID"]	= Character.m_uID
--		parameters["sAreaName"]	= AreaName1
--		
--	end
--end

-- ���˺���ϲɼ����OBJ������
function CCharacterMediatorCallbackHandler:OnBreakGatherProcess(uEntityID)
	local Character = CEntityServerManager_GetEntityByID(uEntityID)
	if not Character then
		return
	end
	
	--�����Ʒʹ�ö���
	if Character.m_UseItemLoadingTick then
		StopItemProgressTick(Character, true)
	end
	
	if Character.m_CollectResTick then
		TongStopLoadProgress(Character)
	end
	
	-- TODO:
	if Character.m_ActionLoadingTick then
		BreakPlayerActionLoading(Character,true)
	end
	
	if Character.m_CommLoadProTick then
		CommStopLoadProgress(Character, EProgressBreak.ePB_Attack)
	end
	
	if Character.m_UseItemLoadingTick then
		Character.m_IsBattle = 1
	end
end

function CCharacterMediatorCallbackHandler:OnItemSkillEnd(GlobalID, szSKillName)
	--print("OnItemSkillEnd",GlobalID,szSKillName)
	local CCharacter=CCharacterDictator_GetCharacterByID(GlobalID)
	ItemSkillEnd(CCharacter, szSKillName)
end

--����ӿ�
function CCharacterMediatorCallbackHandler:OnBurstSoulPrize(uObj1ID, uObj2ID, uSoulMul) --uObj1ID���Id��uObj2ID����Id
	--print("CCharacterMediatorCallbackHandler:OnBurstSoulPrize ", uObj1ID, uObj2ID, uSoulMul)
	local CharacterDictator = CCharacterDictator_GetCharacterByID(uObj1ID)
	local Monster = CCharacterDictator_GetCharacterByID(uObj2ID)
	if CharacterDictator == nil or Monster == nil or CharacterDictator.m_Conn.m_Account == nil 
		or not IsServerObjValid(CharacterDictator) or not IsServerObjValid(Monster)then
		return 
	end
	CharacterDictator:OnBurstSoulPrize(Monster,uSoulMul)
end

function CCharacterMediatorCallbackHandler:OnChangeModulus(uObjID, uProperty, uModulus)
	local CharacterDictator = CCharacterDictator_GetCharacterByID(uObjID)
	if not CharacterDictator or not IsServerObjValid(CharacterDictator) then
		return
	end
	if uProperty == NonCombatBehavior.nCB_ExpModulusChange then
		CharacterDictator.m_ExpModulus = CharacterDictator.m_ExpModulus + uModulus
		if CharacterDictator.m_ExpModulus < 0 then
			CharacterDictator.m_ExpModulus = 0 
		end
		SaveExpSoulModulusChangeLog(CharacterDictator.m_uID,uProperty,CharacterDictator.m_ExpModulus)
	elseif uProperty == NonCombatBehavior.nCB_FetchModulusChange then
		CharacterDictator.m_FetchModulus = CharacterDictator.m_FetchModulus + uModulus
		if CharacterDictator.m_FetchModulus < 0 then
			CharacterDictator.m_FetchModulus = 0
		end
		SaveExpSoulModulusChangeLog(CharacterDictator.m_uID,uProperty,CharacterDictator.m_FetchModulus)
	elseif uProperty == NonCombatBehavior.nCB_ExpModulusInFBChange then
		CharacterDictator.m_ExpModulusInFB = CharacterDictator.m_ExpModulusInFB + uModulus
		SaveExpSoulModulusChangeLog(CharacterDictator.m_uID,uProperty,CharacterDictator.m_ExpModulusInFB)
	end
end

function CCharacterMediatorCallbackHandler:OnChangeScene(uEntityID, szSceneName, uPosX, uPosY)
	local Player = CEntityServerManager_GetEntityByID(uEntityID)
	if IsCppBound(Player) then
		if Player.m_Scene.m_SceneName ~= szSceneName and g_SceneMgr:GetSceneByName(szSceneName) then
			ChangeSceneByName(Player.m_Conn, szSceneName, uPosX , uPosY)
		else
			local Pos = CPos:new()
			Pos.x = uPosX
			Pos.y = uPosY
			Player:SetGridPosByTransport(Pos)
		end
	end
end

function CCharacterMediatorCallbackHandler:OnFinishDuel(pCharacter, bResult)
	pCharacter:PlayerDoItemSkill("��ս��������",1)
	if pCharacter:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel) then
		if not bResult then
			CChanllengeFlagMgr.ChallengeLoserSendInform(pCharacter)
		end
	end
end


--�����ͱ����������ﵽһ����Ŀ��ʱ�򣬼���װ���;������Ϣ
--���������id����������������������
function CCharacterMediatorCallbackHandler:OnAttackTimesChanged(uEntityID, uBeAttackTimes)
    local Player = CEntityServerManager_GetEntityByID(uEntityID)
	if not IsServerObjValid(Player)  then 
	    return
	end
    local data = {["CharID"]=Player.m_uID, ["AttackTimes"]=0, ["BeAttackTimes"]=uBeAttackTimes}
    

	local Conn = Player.m_Conn
	local function CallBack(suc, result)
	    if suc then
            UpdateEquipDurability(Conn, result)
	    end
        local AllInfo = result["AllEquipInfo"] 
        DelWithEquipTimeInfo(Conn, AllInfo)
    end
    if Conn.m_Account then
        CallAccountAutoTrans(Conn.m_Account, "EquipDurabilityDB", "UpdateEquipDurability", CallBack, data)
    end
end

function CCharacterMediatorCallbackHandler:DoAlertPhaseEffect( Player, AlertNpc, uLastTime)
	if IsServerObjValid(Player) and IsServerObjValid(AlertNpc) and Player.m_Conn then
		Gas2Gac:DoAlertPhaseEffect(Player.m_Conn, AlertNpc:GetEntityID(), uLastTime)
	end
end

function CCharacterMediatorCallbackHandler:DoAlertEndEffect( Player, AlertNpc)
	if IsServerObjValid(Player) and IsServerObjValid(AlertNpc) and Player.m_Conn then
		Gas2Gac:DoAlertEndEffect(Player.m_Conn, AlertNpc:GetEntityID())
	end
end

function CCharacterMediatorCallbackHandler:OnMasterDisbandTruck(Master, Truck)
	--print("CCharacterMediatorCallbackHandler:OnMasterDisbandTruck")
	MsgToConn(Master.m_Conn, 9210)
end

function CCharacterMediatorCallbackHandler:OnMasterDestoryTruck(Master, Truck)
	--print("CCharacterMediatorCallbackHandler:OnMasterDestroyTruck")
	TruckDestroy(Truck)
	MsgToConn(Master.m_Conn, 9211)
end

local function SaveServantInfo(Player, ServantData)
	local userName 		= Player.m_Conn.m_UserName
	local AccountID 	= Player.m_AccountID
	local data = {}
	data["char_id"]			= Player.m_uID
	data["ServantData"]	= ServantData
		
	CallDbTrans("CharacterMediatorDB", "SaveServantInfo", nil, data, username, AccountID)
end


local function DealWithLittlePet(Player)
	local userName 		= Player.m_Conn.m_UserName
	local AccountID 	= Player.m_AccountID
	local data = {}
	data["char_id"] = Player.m_uID
	if Player.bLoadServant and Player:GetServantByType(ENpcType.ENpcType_LittlePet) then
		local function CallBack(result)
			if result then
				for _, resInfo in pairs(result) do
					local item_id,left_time, item_type, item_name = resInfo[1],resInfo[2],resInfo[3],resInfo[4]
					if left_time <= 0 and item_type == 40 then
						CPutItemsToBag.RetDelPet(Player.m_uID,item_name,item_type,true)
					end
				end
			end
		end
		CallDbTrans("ItemLifeMgrDB", "GetItemLeftTimeByPlayer", CallBack, data, username, AccountID)
	end
end

function CCharacterMediatorCallbackHandler:SaveServantInfo(Player)
	SaveServantInfo(Player,Player:GetServantDataTbl())
	local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
	if IsServerObjValid(Truck) then
		PlayerSaveTruckInfo(Player, Truck)
	end
end


function CCharacterMediatorCallbackHandler:SaveServantInfoOnServantChange(Player)
	local ServantDataTbl = {}
	--Ŀǰֻ�洢ֻ�ܴ�һ����Npc
	local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
	if NpcInfoMgr_CanTakeOnlyOne(ENpcType.ENpcType_Truck) and IsServerObjValid(Truck) then
		local DataTbl = Player:GetServantData(Truck)
		if DataTbl ~= nil then
			table.insert(ServantDataTbl, {1, DataTbl} )
		end
	end
	SaveServantInfo(Player, ServantDataTbl)
	DealWithLittlePet(Player)
	if not IsServerObjValid(Truck) then
		return
	end
	PlayerSaveTruckInfo(Player, Truck)
end

function CCharacterMediatorCallbackHandler:BeClearServantByTransfer(NewSceneName)
	local Setting = Scene_Basic_Common_Shell(NewSceneName)
	if Setting and Setting("ClearServant") == 1 then
		return true
	end
	return false
end

function CCharacterMediatorCallbackHandler:InSceneArea(player, sAreaName)
	local Pos = CPos:new()
	player:GetGridPos( Pos)		
	local areaName = g_AreaMgr:GetSceneAreaName(player.m_Scene.m_SceneName, Pos)
	if sAreaName == areaName then
		return true
	else
		return false
	end
end

function CCharacterMediatorCallbackHandler:OnPlayerEnterBattleState(Player)
	--print("Player Enter Battle State !")
end

function CCharacterMediatorCallbackHandler:OnPlayerLeaveBattleState(Player)
	if not IsCppBound(Player) then
		return
	end
	if Player.m_InBattle then
		Player:CppSetPKState(false)
		Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
		Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
		Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
	end
end

function CCharacterMediatorCallbackHandler:OnLogSpeedChangeReason(Player, fSpeed, szSpeedChangeReason)
	SavePlayerSpeedLog(Player.m_Properties:GetCharName(), fSpeed, szSpeedChangeReason)
end

function CCharacterMediatorCallbackHandler:OnDoWorldSkill(Player, sSkillName,uSkillLevel)
	Player:DoSkillInPlayerSet( Player.m_Conn,1,1, sSkillName,uSkillLevel,"")
end

function CCharacterMediatorCallbackHandler:OnDoCampSkill(Player, sSkillName,uSkillLevel)
	Player:DoSkillInPlayerSet( Player.m_Conn,2, Player:CppGetBirthCamp(),sSkillName,uSkillLevel,"")
end

function CCharacterMediatorCallbackHandler:OnDoArmyCorpsSkill(Player, sSkillName,uSkillLevel)
	local ArmyCorpsID  = Player.m_uArmyCorpsID 
	if ArmyCorpsID ~= 0 then
		Player:DoSkillInPlayerSet( Player.m_Conn,3,ArmyCorpsID, sSkillName,uSkillLevel,"")
	else 
		Player:PlayerDoPassiveSkill(sSkillName,uSkillLevel)	
	end
end

function CCharacterMediatorCallbackHandler:OnDoTongSkill(Player, sSkillName,uSkillLevel)
	local TongID  = Player.m_Properties:GetTongID()
	if TongID ~= 0 then
		Player:DoSkillInPlayerSet( Player.m_Conn,4,TongID, sSkillName,uSkillLevel,"")
	else 
		Player:PlayerDoPassiveSkill(sSkillName,uSkillLevel)	
	end
end
