gac_require "information/head_info/HeadInfo"
gac_require "information/head_info/DirectionInfo"
cfg_load "appellation/AppellationIdAndText_Common"
lan_load "npc/Lan_Npc_Common"
lan_load "appellation/Lan_AppellationText_Common"

CCharacterInSyncMgr = class()

local tblPKIcon = {"#1101", "#1102", "#1103"}
local function GetShowPkState(Character)
	--if Character:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel) then
	--	return GetStaticTextClient(12500)
	--end
	local bPkState	= Character:CppGetPKState()
	local bInDuel	= Character:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	if( bPkState or bInDuel ) then
		assert(Character.CppGetBirthCamp, Character.m_Properties:GetCharName())
		local nBirthCamp = Character:CppGetBirthCamp()
		return CTextureFontMgr_Inst():GetEmtStrByIdx(tblPKIcon[nBirthCamp])
	end
	return ""
end

local function GetShowPkText(Character)
	if Character:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel) then
		return "" --GetStaticTextClient(12500)
	end
	local pkValue = Character.m_Properties:GetPkValue()
	if(0 == pkValue) then
		return ""
	else
		local sPKValue	= ""
		if(g_GameMain.m_bShowAllName) then
			sPKValue = string.format("%s %d", GetStaticTextClient(12026), pkValue)
		else
			local sIcon		= ""
			local nStarNum	= 0
			if(pkValue < 100) then
				sIcon		= CTextureFontMgr_Inst():GetEmtStrByIdx("#1105")
				nStarNum	= math.floor(pkValue/20) + 1
			elseif(pkValue < 1000) then
				sIcon		= CTextureFontMgr_Inst():GetEmtStrByIdx("#1104")
				nStarNum	= math.floor(pkValue/200) + 1
			else
				sIcon		= CTextureFontMgr_Inst():GetEmtStrByIdx("#1104")
				nStarNum	= 5
			end
			for i = 1, nStarNum do
				sPKValue = sPKValue .. sIcon
			end
		end
		return sPKValue
	end
--	local PkState = Character:CppGetPKState()
--	if PkState == true then
--		return GetStaticTextClient(12020)
--	else
--		return ""
--	end
end

function CCharacterInSyncMgr:Ctor()
	self.m_bShowPKText = true
	self.m_tblCharacter			= {} --���������Ұ�е�Character����
	self.m_tblHeadInfoCache		= {}
	self.m_tblDirectionInfoCache	= {} --ָʾ��Ļ��ȥ�����
	self:CreateHeadInfoCache(100, 100)
end

local ShowObjNameTbl = {
	["��ʰȡ��Obj"] = true,
	["Ӷ�������"] = true,
	["������ս"] = true,
	["ʰȡ��ʯ"] = true,
	["��ʰȡ��Obj��ʱ��"] = true,
	["������"] = true,
	["����Obj"] = true,
	["����"] = true,
	["��"] = true,
	
	["�����ɼ���ƷObj����"] = true,
	["�����ɼ���ƷObj��ʧ"] = true,
	["С��Ϸ"] = true,
}
--��Character���������Ұʱ���øú���
function CCharacterInSyncMgr:CharacterInSync(Character)
	
	local type = Character.m_Properties:GetType()
	
	self:SetRanderStyle(Character)
	
	if(type == ECharacterType.Player) then
		if(Character:IsBattleHorse()) then return end
	elseif(type == ECharacterType.Npc) then
		local npcInfo = Npc_Common(Character.m_Properties:GetCharName())
		if(not npcInfo) then
			ErrLogMsg( "Npc_Common����û��", Character.m_Properties:GetCharName() )
			return
		end
		if npcInfo("ShowBloodType") == 2 or not Character:CppIsAlive() then
			return
		end
	elseif(type == ECharacterType.IntObj) then
		local objName = Character.m_Properties:GetCharName()
		local TriggerAction = IntObj_Common(objName, "TriggerAction")
		
		if not ShowObjNameTbl[TriggerAction] then
			return
		end
	end
	
	Character.m_HeadInfoWnd = self:GetHeadInfoInCache()
	self:UpdateInfo(Character)
	
	self.m_tblCharacter[Character:GetEntityID()] = Character
	self:CreateDirectionInfoWnd(Character)
	
	g_GameMain.m_TeamMarkSignMgr:CharacterInView(Character)
end

function CCharacterInSyncMgr:SetRanderStyle(Character)
	if ( Character == g_MainPlayer.m_LockCenter.m_LockingObj ) then return end
	local type = Character.m_Properties:GetType()
	if ( type == ECharacterType.Player and not Character:IsBattleHorse() ) then
		local bTeamMember = g_GameMain.m_TeamBase:IsTeamMember(Character:GetEntityID())
		if( bTeamMember ) then
			Character:GetRenderObject():SetRenderStyle( 0x08A )
			return
		end
	elseif type == ECharacterType.IntObj then
		local objName = Character.m_Properties:GetCharName()
		if string.find(objName,"��") then
			Character:GetRenderObject():SetRenderStyle( 0x04A )
			return
		end
	end
	Character:GetRenderObject():SetRenderStyle( 0x00A )
end

--����ͷ����Ϣ�ĸ���
function CCharacterInSyncMgr:PlayerHeadInfoInit()
	if(not g_MainPlayer.m_HeadInfoWnd or not IsCppBound(g_MainPlayer.m_HeadInfoWnd)) then
		g_MainPlayer.m_HeadInfoWnd = CreateHeadInfo(100)
	end
	self:UpdateInfo(g_MainPlayer)
	--g_MainPlayer.m_HeadInfoWnd:SetTransparent(1.0)
end

--��������ͷ����Ϣ����
function CCharacterInSyncMgr:DestroyPlayerHeadInfo()
	if ( IsCppBound(g_MainPlayer) and g_MainPlayer.m_HeadInfoWnd and IsCppBound(g_MainPlayer.m_HeadInfoWnd) )then
		g_MainPlayer.m_HeadInfoWnd:ShowWnd(false)
		g_MainPlayer:GetRenderObject():DelChild(g_MainPlayer.m_HeadInfoWnd)
		g_MainPlayer.m_HeadInfoWnd:DestroyWnd()
		g_MainPlayer.m_HeadInfoWnd = nil
	end
end

--��Character�뿪�����Ұʱ���øú���
function CCharacterInSyncMgr:CharacterOutSync(Character)
	local type = Character.m_Properties:GetType()
	if(type == ECharacterType.Npc) then
		local npcInfo = Npc_Common(Character.m_Properties:GetCharName())
		if(not npcInfo) then
			ErrLogMsg( "Npc_Common����û��", Character.m_Properties:GetCharName() )
			return
		end
		if npcInfo("ShowBloodType") == 2 then
			return
		end
	end
	g_GameMain.m_TeamMarkSignMgr:CharacterOutView(Character)
	self:DestroyHeadInfoWnd(Character)
end

function CCharacterInSyncMgr:DestroyHeadInfoWnd(Character)
	local nEntityID = Character:GetEntityID()
	if(self.m_tblCharacter[nEntityID]) then
		self.m_tblCharacter[nEntityID] = nil
		Character.m_HeadInfoWnd:ShowWnd(false)
		Character:GetRenderObject():DelChild(Character.m_HeadInfoWnd)
		table.insert(self.m_tblHeadInfoCache, Character.m_HeadInfoWnd)
		Character.m_HeadInfoWnd = nil
		self:DestroyDirectionInfoWnd(Character)
	end
end

function CCharacterInSyncMgr:GetHeadInfoInCache()
	local wnd = nil
	local tbl = self.m_tblHeadInfoCache
	if( tbl[#tbl] ) then
		wnd = tbl[#tbl]
		table.remove(tbl, #tbl)
	else
		wnd = CreateHeadInfo(100)
	end
	return wnd
end

--�ڴ���ɱ�����е���ʾ
function CCharacterInSyncMgr:UpdateInfoInEscape(Character, type)
	local name = GetStaticTextClient(1113) --������
	local color = g_ColorMgr:GetColor("�ж���Ӫ")
	local bFlag = true
	if(type == ECharacterType.IntObj) then
		bFlag = false
	end
	
	if(bFlag) then
		Character.m_HeadInfoWnd:UpdateHeadInfoWnd(Character, "", "", "", "", name, "", color)
	end
	return bFlag
end

--��Ӷ������ս�����е���ʾ
function CCharacterInSyncMgr:UpdateInfoInTongChallenge(Character, type)
	local name	= Character.m_Properties:GetCharName()
	if(type == ECharacterType.Player and not Character:IsBattleHorse()) then
		local playerTongId	= g_MainPlayer.m_Properties:GetTongID()
		local otherTongId	= Character.m_Properties:GetTongID()
		local sPKValue		= GetShowPkText(Character)
		local sPKState		= GetShowPkState(Character)
		if(nil ~= playerTongId and 0 ~= playerTongId and
			nil ~= otherTongId and 0 ~= otherTongId and playerTongId ~= otherTongId) then
				local color	= g_ColorMgr:GetColor("�ж���Ӫ")
				Character.m_HeadInfoWnd:UpdateHeadInfoWnd(Character, sPKValue, sPKState, "", "", name, "", color)
				return true
		end
	end
	return false
end

--������Ӧ��RenderWnd��Ϣ
function CCharacterInSyncMgr:UpdateInfo(Character)
	local type					= Character.m_Properties:GetType()
	local sPKValue				= ""
	local sPKState				= ""
	local armyCorpsName			= ""
	local tongName				= ""
	local name					= ""
	local honour				= ""
	
	local bShowPlayerName		= true
	local bShowOtherPlayerName	= true
	if(not g_GameMain.m_bShowAllName) then
		bShowPlayerName			= g_UISettingMgr:GetOnePropState("�������")
		bShowOtherPlayerName	= g_UISettingMgr:GetOnePropState("�����������")
	end
	
	if(g_MainPlayer == Character) then
		local bShowPlayerArmyCorpsName, bShowPlayerTongName, bShowPlayerHonour = true, true, true
		if(not g_GameMain.m_bShowAllName) then
			bShowPlayerArmyCorpsName	= g_UISettingMgr:GetOnePropState("���Ӷ����")
			bShowPlayerTongName			= g_UISettingMgr:GetOnePropState("���Ӷ��С��")
			bShowPlayerHonour			= g_UISettingMgr:GetOnePropState("��ҳƺ�")
		end
		sPKValue, sPKState, name, armyCorpsName, tongName, honour = self:UpdatePlayerInfo(Character, bShowPlayerName, bShowPlayerArmyCorpsName, bShowPlayerTongName, bShowPlayerHonour)
		if(not self.m_bShowPKText) then sPKValue, sPKState = "", "" end
	else
		if(1 == g_GameMain.m_SceneStateForClient) then	--�ڴ���ɱ������
			if( self:UpdateInfoInEscape(Character, type) ) then
				return
			end
		end
		
		if(2 == g_GameMain.m_SceneStateForClient and bShowOtherPlayerName) then	--�ڴ���ɱ������
			if( self:UpdateInfoInTongChallenge(Character, type) ) then
				return
			end
		end
		
		if(type == ECharacterType.Player and not Character:IsBattleHorse()) then
			local bShowOtherPlayerArmyCorpsName, bShowOtherPlayerTongName, bShowOtherPlayerHonour = true, true, true
			if(not g_GameMain.m_bShowAllName) then
				bShowOtherPlayerArmyCorpsName	= g_UISettingMgr:GetOnePropState("�������Ӷ����")
				bShowOtherPlayerTongName		= g_UISettingMgr:GetOnePropState("�������Ӷ��С��")
				bShowOtherPlayerHonour			= g_UISettingMgr:GetOnePropState("������ҳƺ�")
			end
			sPKValue, sPKState, name, armyCorpsName, tongName, honour = self:UpdatePlayerInfo(Character, bShowOtherPlayerName, bShowOtherPlayerArmyCorpsName,bShowOtherPlayerTongName, bShowOtherPlayerHonour)
			if(not self.m_bShowPKText) then sPKValue, sPKState = "", "" end
		elseif(type == ECharacterType.Npc) then
			local npc_type	= Character:GetNpcType()
			local camp 		= Character:CppGetCamp()
			local sCharName	= Character.m_Properties:GetCharName()
			if( ServantType_BeServantType(npc_type) ) then
				local Servant = g_MainPlayer:GetServant(npc_type)
				if( (bShowPlayerName and Character == Servant) or bShowOtherPlayerName ) then
					name = Character:GetRealName()
					if("" == name) then
						name = GetNpcDisplayName(sCharName)
					end
					honour = Lan_Npc_Common(MemH64(sCharName),"NpcHonour")
				end
			elseif( (g_UISettingMgr:GetOnePropState("NPC����") and camp ~= 5) or (g_UISettingMgr:GetOnePropState("��������") and camp == 5) ) then
				name = GetNpcDisplayName(Character.m_Properties:GetCharName())
				honour = Lan_Npc_Common(MemH64(sCharName),"NpcHonour")
			end
		elseif(type == ECharacterType.IntObj) then
			name = GetIntObjDispalyName(Character.m_Properties:GetCharName())
			local DuelWinCount = Character.m_Properties:GetDuelWinCount()
			if DuelWinCount ~= "" then
				if DuelWinCount ~= " " then
					honour = DuelWinCount
				end
				name = GetStaticTextClient(12503,Character.m_Properties:GetCreatorName())
			end
		end
	end
		
	if("" ~= armyCorpsName) then
		armyCorpsName = GetStaticTextClient(16003, armyCorpsName)
	end
	if("" ~= tongName) then
		tongName = GetStaticTextClient(16001, tongName)
	end
	if("" ~= honour) then
		honour = GetStaticTextClient(16002, honour)
	end
	
	local color = self:GetTextColor(Character, type)
	Character.m_HeadInfoWnd:UpdateHeadInfoWnd(Character, sPKValue, sPKState, armyCorpsName, tongName, name, honour, color)
end

function CCharacterInSyncMgr:UpdatePlayerInfo(Character, bShowName, bShowArmyCorpsName, bShowTongName, bShowHonour)
	local sPKValue	= GetShowPkText(Character)
	local sPKState	= GetShowPkState(Character)
	local name		= bShowName and Character.m_Properties:GetCharName() or ""
	local tongName	= bShowTongName and Character.m_Properties:GetTongName() or ""
	local armyCorpsName = bShowArmyCorpsName and Character.m_Properties:GetArmyCorpsName() or ""
	local honour = ""
	if bShowHonour then
		local sAppellationIdAndText1 = AppellationIdAndText_Common(Character.m_Properties:GetCharAppellation1(),"Content") or ""
		local sAppellationIdAndText2 = AppellationIdAndText_Common(Character.m_Properties:GetCharAppellation2(),"Content") or ""
		if sAppellationIdAndText1 ~= "" then
			sAppellationIdAndText1 = Lan_AppellationText_Common(MemH64(sAppellationIdAndText1),"Content") 
		end
		if sAppellationIdAndText2 ~= "" then
			sAppellationIdAndText2 = Lan_AppellationText_Common(MemH64(sAppellationIdAndText2),"Content") 
		end
		honour = sAppellationIdAndText1 .. sAppellationIdAndText2
	end 
	return sPKValue, sPKState, name, armyCorpsName, tongName, honour
end

--�ж϶Է�(���)�Ƿ��ǵж���Ӫ(ֻ����Player����)
function CCharacterInSyncMgr:IsEnemyPlayer(Character)
	local playerCamp		= g_MainPlayer:CppGetCamp()
	local playerGameCamp	= g_MainPlayer:CppGetGameCamp()
	local otherCamp			= Character:CppGetCamp()
	local otherGameCamp		= Character:CppGetGameCamp()
	local playerInDuel		= g_MainPlayer:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	local otherInDuel		= Character:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	
	if(playerGameCamp == 0 or otherGameCamp == 0) then
		if(playerCamp ~= otherCamp) then
			return true
		end
	else
		if(playerGameCamp == otherGameCamp) then
			if(playerInDuel and otherInDuel) then
				return true
			end
		else
			return true
		end
	end
	return false
end

--�ж϶Է�(NPC)�Ƿ��ǵж���Ӫ
function CCharacterInSyncMgr:IsEnemyNPC(Character)
	local playerCamp		= g_MainPlayer:CppGetCamp()
	local playerGameCamp	= g_MainPlayer:CppGetGameCamp()
	local otherCamp			= Character:CppGetCamp()
	local otherGameCamp		= Character:CppGetGameCamp()
	local playerInDuel		= g_MainPlayer:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	local otherInDuel		= Character:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	
	if(playerGameCamp == 0 or otherGameCamp == 0) then
		if( (playerCamp ~= otherCamp) and (5 == otherCamp or 1 == otherCamp or 2 == otherCamp or 3 == otherCamp) ) then
			return true
		end
	else
		if( playerGameCamp == otherGameCamp or playerGameCamp == (-otherGameCamp) ) then
			local Master = Character:GetMaster()
			if(playerInDuel and otherInDuel and Master ~= g_MainPlayer) then
				return true
			end
		else
			return true
		end
	end
	return false
end

--�õ���Ҷ���ͷ��������ɫ
function CCharacterInSyncMgr:GetPlayerColor(Character)
	local playerTeamId		= g_MainPlayer.m_Properties:GetTeamID()
	local otherTeamId		= Character.m_Properties:GetTeamID()
	local playerTongId		= g_MainPlayer.m_Properties:GetTongID()
	local otherTongId		= Character.m_Properties:GetTongID()
	local color = nil
	if( self:IsEnemyPlayer(Character) ) then
		color = g_ColorMgr:GetColor("�ж���Ӫ")
	else
		if (nil ~= playerTeamId and 0 ~= playerTeamId and playerTeamId == otherTeamId) then
			color = g_ColorMgr:GetColor("����")
		elseif (nil ~= playerTongId and 0 ~= playerTongId and playerTongId == otherTongId) then
			color = g_ColorMgr:GetColor("ͬӶ����")
		else
			color = g_ColorMgr:GetColor("ͬ��Ӫ")
		end
	end
	return color
end

--�õ�NPCͷ��������ɫ
function CCharacterInSyncMgr:GetNPCColor(Character)
	local playerCamp		= g_MainPlayer:CppGetCamp()
	local playerGameCamp	= g_MainPlayer:CppGetGameCamp()
	local otherCamp			= Character:CppGetCamp()
	local otherGameCamp		= Character:CppGetGameCamp()
	local playerInDuel		= g_MainPlayer:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	local otherInDuel		= Character:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel)
	
	local color = nil
	if playerGameCamp == 0 or otherGameCamp == 0 then
		if playerCamp == otherCamp then
			color = g_ColorMgr:GetColor("ͬ��Ӫ")
		elseif (4 == otherCamp) then
			color = g_ColorMgr:GetColor("·����Ӫ")
		elseif (5 == otherCamp or 1 == otherCamp or 2 == otherCamp or 3 == otherCamp) then --������Ӫ���ߵж���Ӫ
			local bFlag = Character:BeActiveNpc()
			color = bFlag and g_ColorMgr:GetColor("������") or g_ColorMgr:GetColor("������")
		else
			color = g_ColorMgr:GetColor("����")
		end
	else
		if playerGameCamp == otherGameCamp or playerGameCamp == (-otherGameCamp) then
			local Master = Character:GetMaster()
			if playerInDuel and otherInDuel and Master ~= g_MainPlayer then
				color = g_ColorMgr:GetColor("�ж���Ӫ")
			else
				color = g_ColorMgr:GetColor("ͬ��Ӫ")
			end
		else
			local bFlag = Character:BeActiveNpc()
			color = bFlag and g_ColorMgr:GetColor("������") or g_ColorMgr:GetColor("������")
		end
	end
	return color
end

--�õ�OBJͷ��������ɫ
function CCharacterInSyncMgr:GetIntObjColor(Character)
	local objName = Character.m_Properties:GetCharName()
	local TriggerAction = IntObj_Common(objName, "TriggerAction")
	if TriggerAction == "��ʰȡ��Obj��ʱ��" then
		return g_ColorMgr:GetColor("Obj")
	end
	if(string.find(TriggerAction,"ʰȡ")) then
		local itemType = g_ObjActionArgTbl[objName][1]
		if TriggerAction == "ʰȡ��ʯ" then
			itemType = 28
		end
		local Quality = g_ItemInfoMgr:GetItemInfo(itemType, objName,"Quality")
		return g_ColorMgr:GetColor("ϡ".. Quality)
	end
	return g_ColorMgr:GetColor("Obj")
end

--�õ�ͷ��������ɫ
function CCharacterInSyncMgr:GetTextColor(Character, type)
	if(Character == g_MainPlayer) then
		return g_ColorMgr:GetColor("�Լ�")
	end
	if(type == ECharacterType.Player and not Character:IsBattleHorse()) then
		return self:GetPlayerColor(Character)
	elseif(type == ECharacterType.Npc) then
		return self:GetNPCColor(Character)
	elseif(type == ECharacterType.IntObj) then
		return self:GetIntObjColor(Character)
	end
end

--����������Ұ�����еĶ���ͷ����Ϣ״̬
function CCharacterInSyncMgr:UpdateCharacterInSync()
	for i, p in pairs(self.m_tblCharacter) do
		self:SetRanderStyle(p)
		self:UpdateInfo(p)
	end
end

--����������Ұ�����е����ͷ����Ϣ״̬
function CCharacterInSyncMgr:UpdateAllPlayerInSync()
	for i, p in pairs(self.m_tblCharacter) do
		if(p.m_Properties:GetType() == ECharacterType.Player) then
			self:SetRanderStyle(p)
			self:UpdateInfo(p)
		end
	end
end

-- ��������ͷ��ģ�ͣ���ͬ���������
function CCharacterInSyncMgr:UpdateHeadModelInSync()
	bIsShowArmet = g_UISettingMgr:GetOnePropState("��ʾͷ��")
	Gac2Gas:SetShowModeOfArmet(g_Conn, bIsShowArmet)
end

function CCharacterInSyncMgr:UpdateHeadModelByEntityID(EntityID)
	local Character = self.m_tblCharacter[EntityID]
	if(Character) then
		UpdateHeadModel(Character)
		local LockingObj = g_MainPlayer.m_LockCenter.m_LockingObj
		if LockingObj then
			if Character == LockingObj then
				g_GameMain.m_TargetInfo:UpdatePortrait(LockingObj)
			end
		end
	end
end

--�ѷ�����ѡ��
function CCharacterInSyncMgr:UpdateFriendCanSelectedInSync()
	for i, p in pairs(self.m_tblCharacter) do
		g_GameMain.m_HideFollowerMgr:SetFriendCanNotBeSelected(p)
	end
end

--����EntityID��ˢ�����
function CCharacterInSyncMgr:UpdateCharacterHeadInfoByEntityId(EntityID)
	local Character = self.m_tblCharacter[EntityID]
	if(Character) then
		self:SetRanderStyle(Character)
		self:UpdateInfo(Character)
	end
end

function CCharacterInSyncMgr:UpdateTargetColor()
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if(Target and Target.m_HeadInfoWnd and IsCppBound(Target.m_HeadInfoWnd)) then
		Target.m_HeadInfoWnd:TempColor()
	end
end

--��������followerͷ����Ϣ����
function CCharacterInSyncMgr:CloseFollowerHeadInfoWnd()
	for i, p in pairs(self.m_tblCharacter) do
		p.m_HeadInfoWnd:ShowWnd(false)
		if IsCppBound(p) then
			p:GetRenderObject():DelChild(p.m_HeadInfoWnd)
		end
		table.insert(self.m_tblHeadInfoCache, p.m_HeadInfoWnd)
		p.m_HeadInfoWnd = nil
	end
end

function CCharacterInSyncMgr:CreateHeadInfoCache(num, heigth)
	for i = 1, num do
		table.insert( self.m_tblHeadInfoCache, CreateHeadInfo(heigth) )
	end
end

--------------------------------------------------------------------------------------
function CCharacterInSyncMgr:CreateDirectionInfoCache(num)
	for i = 1, num do
		table.insert( self.m_tblDirectionInfoCache, CreateHeadInfo() )
	end
end

function CCharacterInSyncMgr:GetDirectionInfoInCache()
	local wnd = nil
	local tbl = self.m_tblDirectionInfoCache
	if( tbl[#tbl] ) then
		wnd = tbl[#tbl]
		table.remove(tbl, #tbl)
	else
		wnd = CreateDirectionInfo()
	end
	return wnd
end

function CCharacterInSyncMgr:DestroyDirectionInfoWnd(Character)
	if(Character.m_DirectionInfoWnd) then
		Character.m_DirectionInfoWnd:ShowWnd(false)
		Character:GetRenderObject():DelChild(Character.m_DirectionInfoWnd)
		table.insert(self.m_tblDirectionInfoCache, Character.m_DirectionInfoWnd)
		Character.m_DirectionInfoWnd = nil
	end
end

function CCharacterInSyncMgr:CloseFollowerDirectionInfoWnd()
	for i, p in pairs(self.m_tblCharacter) do
		p.m_DirectionInfoWnd:ShowWnd(false)
		Character:GetRenderObject():DelChild(p.m_DirectionInfoWnd)
		table.insert(self.m_tblDirectionInfoCache, p.m_DirectionInfoWnd)
		p.m_DirectionInfoWnd = nil
	end
end

function CCharacterInSyncMgr:CreateDirectionInfoWnd(Character)
	local type = Character.m_Properties:GetType()
	if( type == ECharacterType.Player or type == ECharacterType.Npc ) then
		Character.m_DirectionInfoWnd = self:GetDirectionInfoInCache()
		self:UpdateDirectionInfo(Character, type)
	end
end

function CCharacterInSyncMgr:UpdateDirectionInfo(Character, type)
	Character.m_DirectionInfoWnd:UpdateDirectionInfoWnd(Character, type)
end

function CCharacterInSyncMgr:OnMouseMoveInGameMain()
	if( g_CoreScene ) then
		local selectObj = CEntityClient_GetSelectedEntity(g_CoreScene)
		if(self.m_SelectObj ~= selectObj) then
			if(self.m_SelectObj ~= g_MainPlayer.m_LockCenter.m_LockingObj) then
				self:HeadInfoShowControl(self.m_SelectObj, false)
			end
			self:HeadInfoShowControl(selectObj, true)
		end
		self.m_SelectObj = selectObj
	end
end

function CCharacterInSyncMgr:HeadInfoShowControl(Character, bFlag)
	if(Character and Character.m_HeadInfoWnd) then
		local type = Character.m_Properties:GetType()
		local CharName = Character.m_Properties:GetCharName()
		if type == ECharacterType.Npc  then
			local camp = Character:CppGetCamp()
			if self:IsNeedShowNameNpc(camp) then
				Character.m_HeadInfoWnd:ShowWnd(bFlag)
				Character.m_HeadInfoWnd:ShowWndForQuestNeed(CharName, type)
			end
		end
		self:SetHeadInfoTransparent(Character, bFlag and 2 or 1)
	end
end

function CCharacterInSyncMgr:SetHeadBloodTransparentFun(Character,IsTransparent)
--	local fTrans = IsTransparent and 0.5 or 1.0
--	if Character and IsCppBound(Character) and Character.SetHeadBloodTransparent then
--		Character:SetHeadBloodTransparent(fTrans)
--	end
end

function CCharacterInSyncMgr:IsNeedShowNameNpc(camp)
	return g_UISettingMgr:GetOnePropState("�����ͣ��ʾ��������") and 5 == camp
end

function CCharacterInSyncMgr:ChangeHPByMe(progress)
	if(not g_MainPlayer or 0 == g_MainPlayer.m_iHPLatestChange) then return end
	progress:SetChangeDiff(g_MainPlayer.m_iHPLatestChange, 10000)
end

function CCharacterInSyncMgr:SetHeadInfoTransparent(Character, nFlag)
--	if(Character == g_MainPlayer) then return end
--	local tbl = {[0] = 0, 0.5, 1}
--	if(Character.m_HeadInfoWnd) then
--		Character.m_HeadInfoWnd:SetTransparent(tbl[nFlag])
--	end
--	self:SetHeadBloodTransparentFun(Character,nFlag ~= 2 and true or false)
end

function Gas2Gac:UpdateHeadInfoByEntityID(Conn, EntityID)
	if( EntityID == g_MainPlayer:GetEntityID() ) then
		g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit()
		g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
	else
		g_GameMain.m_CharacterInSyncMgr:UpdateCharacterHeadInfoByEntityId(EntityID)
	end
end

function Gas2Gac:UpdateHeadModelByEntityID(Conn, EntityID)
	if( EntityID == g_MainPlayer:GetEntityID() ) then
		UpdateHeadModel(g_MainPlayer)
		g_GameMain.m_PlayerInfo:Show(true)
		local LockingObj = g_MainPlayer.m_LockCenter.m_LockingObj
		if LockingObj then
			if g_MainPlayer == LockingObj then
				g_GameMain.m_TargetInfo:UpdatePortrait(LockingObj)
			end
		end
		g_GameMain.m_RoleStatus.m_bLoadPiece = nil
		g_GameMain.m_RoleStatus:DrawRole()
	else
		g_GameMain.m_CharacterInSyncMgr:UpdateHeadModelByEntityID(EntityID)
	end
end
