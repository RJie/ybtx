cfg_load "model_res/NpcRes_Common"

CCharacterClientCallbackHandler = class()

function split (s, delim)
	assert (type (delim) == "string" and string.len (delim) > 0, "bad delimiter")
	local start = 1
	local t = {}  -- results table
	
	if string.sub(s,1,1) == "\"" and string.sub(s,-1) == "\"" then
		s = string.sub(s,2,string.len(s)-1)
	end
	
	while true do
		local pos = string.find (s, delim, start, true) -- plain find
		if not pos then
			break
		end
		table.insert (t, string.sub (s, start, pos - 1))
		start = pos + string.len (delim)
	end -- while
	
	-- insert final one (after last delimiter)
	table.insert (t, string.sub (s, start))
	return t
end

function CCharacterClientCallbackHandler:OnResLoaded(Character)
	if(Character ==nil ) then
		return
	end
	local RenderObj=Character:GetRenderObject()
	if(RenderObj == nil ) then
		return
	end
	
	if RenderObj.weaponEffect~=nil then
		local EffectTable = split(RenderObj.weaponEffect, ",")
		if RenderObj.weaponRenderObj~=nil then
			RenderObj.weaponEffect=RenderObj.weaponRenderObj:AddEffect( EffectTable[1], EffectTable[2], -1, nil)	
		else
			RenderObj.weaponEffect=RenderObj:AddEffect( EffectTable[1], EffectTable[2], -1, nil)
		end
	end
	if RenderObj.offweaponEffect~=nil then
		local EffectTable = split(RenderObj.offweaponEffect, ",")
		if RenderObj.weaponRenderObj.offweaponEffect ~= nil then 
			RenderObj.offweaponEffect=RenderObj.offweaponRenderObj:AddEffect( EffectTable[1], EffectTable[2], -1, nil)
		else
			RenderObj.offweaponEffect=RenderObj:AddEffect( EffectTable[1], EffectTable[2], -1, nil)
		end
	end
	-- �淨ʹ�õİ󶨹���
	RenderObj:AddSkeletal("Bone12")
end
function CCharacterClientCallbackHandler:OnAgileValueChanged(uGlobalID)
	--print("CCharacterClientCallbackHandler:OnAgileValueChanged",uGlobalID)
	local Character = CCharacterFollower_GetCharacterByID(uGlobalID)
	
	if( Character == nil or g_GameMain.m_IsTransfer ==true) then
		--�г����� Update����Variant�ô��룬����������Ĵ���
		return
	end
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	
	if( g_GameMain.m_TargetInfo:IsShow() and Target == Character ) then
		g_GameMain.m_TargetInfo:Update()
	end
	if (g_GameMain.m_TargetOfTargetInfo:IsShow() and Target and Target.m_LockCenter and Target.m_LockCenter.m_LockingObj == Character) then
		g_GameMain.m_TargetOfTargetInfo:Update(Character)
	end
	
	if( Character:GetType()== EClientObjectType.eCOT_Director) then
		g_GameMain.m_PlayerInfo:UpdateHeadInfo()
	end
--	if g_GameMain.m_AimStatusWnd.m_Target ~= nil and g_GameMain.m_AimStatusWnd:IsShow() then
--		if uGlobalID == g_GameMain.m_AimStatusWnd.m_Target:GetEntityID() then
--			g_GameMain.m_AimStatusWnd:UpdateHeadInfo()
--		end
--	end
	
	if Character==g_MainPlayer:GetServant(ENpcType.ENpcType_BattleHorse) then	--ս������
		CBattleHorseInfo.GetWnd():Update()
	elseif Character==g_MainPlayer:GetServant(ENpcType.ENpcType_Summon) then	--�ٻ���
		CServantInfo.GetWnd():Update()
	elseif Character==g_MainPlayer:GetServant(ENpcType.ENpcType_Truck) then		--���䳵
		CTruckInfo.GetWnd():Update()
	end

	g_GameMain.m_TeamBase:UpdateSyncInfoOneByEntityId(uGlobalID) --ͬ���ö�����Ϣ
	
	------------------------------------------
	 --���Լ�Ӱ��Ķ����Ѫ���仯ֵ Ҫ������ˢѪ���������
	 --���н���ˢѪҪд�����֮ǰ
	g_MainPlayer.m_iHPLatestChange = 0
	------------------------------------------
	--print("out CCharacterClientCallbackHandler:OnAgileValueChanged",uGlobalID)
end

function CCharacterClientCallbackHandler:OnCtrlValueChanged(uEntityID, ValueTypeID, bSet)
	--print("CCharacterClientCallbackHandler:OnCtrlValueChanged")
		
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)

	-- ս��״̬��ʾ
	if EFighterCtrlState.eFCS_InBattle == ValueTypeID then		
		if Character:GetType() == EClientObjectType.eCOT_Director then
			if not g_MainPlayer:ExistState("���ν���ս����ʾ״̬") then
				g_GameMain.m_PlayerInfo:FlashShow(bSet)--MsgClient(2100)-- ����ս��״̬ MsgClient(2101)-- ����ս��״̬
			end
		elseif Character:GetType() == EClientObjectType.eCOT_Follower then
			--������˳�ս��ʱ,�ı��Ƿ��ѡ��״̬(��սNPC��)
			local type = Character.m_Properties:GetType()
			if type == ECharacterType.Npc then
				local NpcName = Character.m_Properties:GetCharName()
				local NpcCfg = Npc_Common(NpcName)
				if NpcCfg("ShowBloodType") == 4 then
					local PlayerCamp = g_MainPlayer:CppGetBirthCamp()
					local TargetCamp = Character:CppGetCamp()
					if PlayerCamp == TargetCamp then
						Character:SetCanBeSelected(not bSet)
					end
				end
			end
		end
		
		local StatisticFightInfoWnd = CStatisticFightInfoWnd.GetWnd()
		StatisticFightInfoWnd:OnBattleStateChanged(uEntityID,bSet)
	elseif EFighterCtrlState.eFCS_ForbitMove == ValueTypeID then
		if Character:GetType() == EClientObjectType.eCOT_Director then
			if not bSet then
				g_GameMain.m_SysSetting.m_KPmap:Moving(true)
			end	
		end
	elseif EFighterCtrlState.eFCS_FeignDeath == ValueTypeID then
		if(g_MainPlayer.m_LockCenter.m_LockingObj  == Character)then
			g_MainPlayer:UnLockObj()
		end
	end
end

function CCharacterClientCallbackHandler:OnCastingBarBegin(uEntityID, SkillName, CastType, CastTime, ExpiredTime, bIsSync)
	local FolObj = CCharacterFollower_GetCharacterByID(uEntityID)
	if FolObj ~= nil then
		if FolObj:GetType() == EClientObjectType.eCOT_Director and FolObj == g_MainPlayer then
			if not bIsSync then
				g_MainPlayer.MoveToPos = nil
				g_MainPlayer.MoveToDirection = nil
				g_GameMain.m_skillProgress_Load:OnSelfCastBegin( FolObj, SkillName, CastType, CastTime, ExpiredTime )
			end
			if g_MainPlayer.m_LockCenter.m_LockingObj == g_MainPlayer then
				g_GameMain.m_TargetInfo:OnTaregtCastBegin( FolObj, SkillName, CastType, CastTime, ExpiredTime )
			end
		elseif FolObj:GetType() == EClientObjectType.eCOT_Follower then 
			if FolObj == g_MainPlayer.m_LockCenter.m_LockingObj then
				g_GameMain.m_TargetInfo:OnTaregtCastBegin( FolObj, SkillName, CastType, CastTime, ExpiredTime )
			end
		end
		--Ŀ���Ŀ������
--		if (g_GameMain.m_TargetOfTargetInfo:IsShow() and g_MainPlayer.m_LockCenter.m_LockingObj ~= nil) then
--			if (g_MainPlayer.m_LockCenter.m_LockingObj.m_LockCenter and g_MainPlayer.m_LockCenter.m_LockingObj.m_LockCenter.m_LockingObj == FolObj) then
--				g_GameMain.m_TargetOfTargetInfo:OnTaregtCastBegin(FolObj,  SkillName, CastType, CastTime, ExpiredTime )
--			end
--		end
	end
end

function CCharacterClientCallbackHandler:OnCastingBarEnd(uEntityID)
	--print("CCharacterClientCallbackHandler:OnCastEnd")
	
	local FolObj = CCharacterFollower_GetCharacterByID(uEntityID)

	if FolObj ~= nil then
		if FolObj:GetType() == EClientObjectType.eCOT_Director then
			g_GameMain.m_skillProgress_Load:OnSelfCastEnd()

			if g_MainPlayer.m_LockCenter.m_LockingObj == g_MainPlayer then
				g_GameMain.m_TargetInfo:OnCastEnd()
			end
		elseif FolObj:GetType() == EClientObjectType.eCOT_Follower then 
			if FolObj == g_MainPlayer.m_LockCenter.m_LockingObj then
				g_GameMain.m_TargetInfo:OnCastEnd()
			end
		end
		--Ŀ���Ŀ������
--		if (g_GameMain.m_TargetOfTargetInfo:IsShow() and g_MainPlayer.m_LockCenter.m_LockingObj ~= nil) then
--			if (g_MainPlayer.m_LockCenter.m_LockingObj.m_LockCenter and g_MainPlayer.m_LockCenter.m_LockingObj.m_LockCenter.m_LockingObj == FolObj) then
--				g_GameMain.m_TargetOfTargetInfo:OnCastEnd()
--			end
--		end
	end
end

function CCharacterClientCallbackHandler:OnStateBegin(uEntityID,CategoryId, DynamicId)
	--print("CCharacterClientCallbackHandler:OnStateBegin", CategoryId, DynamicId)

	local MagicState = CBaseStateCfg_GetByGlobalId(CategoryId)

	--�ı�ģ�ͣ�ħ��״̬ģ��
	local ModelTable = split(MagicState:GetModel(), ",")
	if  "" ~= ModelTable[1] or table.getn(ModelTable) ~= 1 then
		self.StateCount = 1	
		--��Ҫ�����ұ��ģ�����Ǽ�������
		self:ChangeBody(uEntityID, ModelTable )
	end
end

function CCharacterClientCallbackHandler:OnStateEnd(uEntityID,CategoryId, DynamicId)
	--print("CCharacterClientCallbackHandler:OnStateEnd", CategoryId, DynamicId)
	
	local MagicState = CBaseStateCfg_GetByGlobalId(CategoryId)
	
	--�ָ�ģ�ͣ�ԭ����ģ��
	local ModelTable = split(MagicState:GetModel(), ",")	
	if  "" ~= ModelTable[1] or table.getn(ModelTable) ~= 1 then
		self.StateCount = self.StateCount - 1
		if( 0 == self.StateCount ) then				
			self:Resume(uEntityID)
		end		
	end
end

function CCharacterClientCallbackHandler:OnBuffIconUpdate(BuffData)
	if not g_MainPlayer or not IsCppBound(g_MainPlayer) or not g_GameMain then
		return
	end
	local uEntityID 	= BuffData:GetObjID()
	local DynamicId 	= BuffData:GetDynamicId()
	local StateName 	= BuffData:GetName()
	local DivNum			= BuffData:GetCount()
	local Time				= BuffData:GetTime()
	local RemainTime	= BuffData:GetRemainTime()
	local BuffType		= BuffData:GetDecrease()
	local SkillLevel	= BuffData:GetSkillLevel()
	local DotInterval	= BuffData:GetDotInterval()
	local InstallerID	= BuffData:GetInstallerID()
	local CalcValue		= BuffData:GetCalcValue()
	
	if RemainTime == 0 and DivNum > 0 then
		return
	end
	
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	if Character == nil then
		return
	end
	local description,SmallIcon
	if DivNum ~= 0 then
		description,SmallIcon = GetBuffTips(StateName, SkillLevel)
		if not description or not SmallIcon then
			return
		end
	end
	if Time<RemainTime and Time ~= -1 then
		RemainTime = Time
	end
	
	local bFriend = false
	if g_MainPlayer:IsFriend(Character) then
		bFriend = true
	end
	if( Character==g_MainPlayer ) then
		--���һ��������ʾbuff�����е�ʱ��
		local PlayerBuffWnd = CPlayerBuffWnd.GetWnd()
		PlayerBuffWnd:UpdatePlayerBuffDebuff(DynamicId, description, DivNum, Time, RemainTime, BuffType, SmallIcon, StateName, uEntityID, InstallerID)
	elseif Character==g_MainPlayer:GetServant(ENpcType.ENpcType_BattleHorse) then--ս������
		g_GameMain.m_BattleHorseBuffWnd:UpdateBuffDebuff(DynamicId, description, DivNum, Time , RemainTime, BuffType, SmallIcon, StateName, uEntityID, InstallerID, true)--ս������buff
	elseif Character==g_MainPlayer:GetServant(ENpcType.ENpcType_Summon) then--�ٻ���
		g_GameMain.m_ServantBuffWnd:UpdateBuffDebuff(DynamicId, description, DivNum, Time , RemainTime, BuffType, SmallIcon, StateName, uEntityID, InstallerID, true)--�ٻ���buff
	end
	
	if Character==g_MainPlayer.m_LockCenter.m_LockingObj then
		CTargetBuffWnd.GetWnd():UpdateBuffDebuff(DynamicId, description, DivNum, Time, RemainTime, BuffType, SmallIcon, StateName, uEntityID, InstallerID, bFriend)
	end
--	if (g_GameMain.m_TargetOfTargetInfo:IsShow() and g_MainPlayer.m_LockCenter.m_LockingObj ~= nil and
--		g_MainPlayer.m_LockCenter.m_LockingObj.m_LockCenter and g_MainPlayer.m_LockCenter.m_LockingObj.m_LockCenter.m_LockingObj == Character) then
--			CTargetOfTargetBuffWnd.GetWnd():UpdateBuffDebuff(DynamicId, description, DivNum, Time, RemainTime, BuffType, SmallIcon, StateName, uEntityID, InstallerID, bFriend)
--	end
	g_GameMain.m_TeamBase:UpdateBuff(DynamicId, description, DivNum, Time, RemainTime, BuffType, SmallIcon, StateName, uEntityID, InstallerID)
end

function CCharacterClientCallbackHandler:OnPhysicalDamageChanged(uObjID,minData,maxData,fStrikeRate,fPhysicDefenceRate,fPhysicDodgeRate,fParryRate)
	--print("OnPhysicalDamageChanged  ",uObjID,minData,maxData,fStrikeRate,fPhysicDefenceRate,fPhysicDodgeRate,fParryRate)
	-- �չ���С�˺�������˺��������ʣ���������ʣ��������ʣ��м���
	local Wnd = nil 
	-- �κ�ֵΪ-1ʱ����ʾ���ֵ���������
	if uObjID == g_MainPlayer:GetEntityID() then
		Wnd = g_GameMain.m_RoleStatus
	elseif g_GameMain.m_AimStatusWnd.m_Target ~= nil then
		if 	uObjID == g_GameMain.m_AimStatusWnd.m_Target:GetEntityID() then		
			Wnd = g_GameMain.m_AimStatusWnd
		end
	end
	if Wnd ~= nil then
		--��ͨ����
		if minData ~= -1 and maxData ~= -1 then 
			minData = string.format("%.0f",minData)
			maxData = string.format("%.0f",maxData)			
			Wnd.NormalAttackDamage = minData .. "-" .. maxData
		end
		--������
		if fStrikeRate ~= -1 then
			fStrikeRate= string.format("%.0f",fStrikeRate*100)
			Wnd.StrikeRate = fStrikeRate
		end
		--���������
		if fPhysicDefenceRate ~= -1 then
			fPhysicDefenceRate = string.format("%.0f",fPhysicDefenceRate*100)
			Wnd.PhysicDefenceRate = fPhysicDefenceRate
		end
		--��������
		if fPhysicDodgeRate ~= -1 then
			fPhysicDodgeRate = string.format("%.0f",fPhysicDodgeRate*100)
			Wnd.PhysicDodgeRate = fPhysicDodgeRate
		end
		--�м���
		if fParryRate ~= -1 then
			fParryRate = string.format("%.0f", fParryRate*100)
			Wnd.ParryRate = fParryRate
		end	
	end
end

function CCharacterClientCallbackHandler:OnMagicDamageChanged(uObjID,fMagicResistRate,fCompleteResistanceRate,fNatureResistanceRate,fDestructionResistanceRate,fEvilResistanceRate,fMagicDodgeRate)
	--print("OnMagicDamageChanged  ",uObjID,fMagicResistRate,fCompleteResistanceRate,fNatureResistanceRate,fDestructionResistanceRate,fEvilResistanceRate,fMagicDodgeRate)
	-- �����ֿ��ʣ�������ȫ��ȫ�ֿ��ʣ���Ȼ���ԣ��ƻ����ԣ����ڿ��ԣ����������
	local Wnd = nil 
	-- �κ�ֵΪ-1ʱ����ʾ���ֵ���������
	if uObjID == g_MainPlayer:GetEntityID() then
		Wnd = g_GameMain.m_RoleStatus
	elseif g_GameMain.m_AimStatusWnd.m_Target ~= nil then
		if 	uObjID == g_GameMain.m_AimStatusWnd.m_Target:GetEntityID() then		
			Wnd = g_GameMain.m_AimStatusWnd			
		end
	end
	if Wnd ~= nil then
		--����������
		if fMagicResistRate ~= -1 then
			fMagicResistRate = string.format("%.0f",fMagicResistRate*100)
			Wnd.MagicResistRate = fMagicResistRate
		end
		--������ȫ��ȫ�ֿ���
		if fCompleteResistanceRate ~= -1 then
			fCompleteResistanceRate = string.format("%.0f",fCompleteResistanceRate*100)
			Wnd.CompleteResistanceRate = fCompleteResistanceRate
		end	
		--��Ȼ����
		if fNatureResistanceRate ~= -1 then 
			fNatureResistanceRate = string.format("%.0f",fNatureResistanceRate*100)
			Wnd.NatureResistanceRate = fNatureResistanceRate
		end
		--�ƻ�����
		if fDestructionResistanceRate ~= -1 then
			fDestructionResistanceRate = string.format("%.0f", fDestructionResistanceRate*100)
			Wnd.DestructionResistanceRate = fDestructionResistanceRate
		end
		--���ڿ���
		if fEvilResistanceRate ~= -1 then
			fEvilResistanceRate =  string.format("%.0f",fEvilResistanceRate*100)
			Wnd.EvilResistanceRate = fEvilResistanceRate
		end
		--���������
		if fMagicDodgeRate ~= -1 then
			fMagicDodgeRate = string.format("%.0f",fMagicDodgeRate*100)
			Wnd.MagicDodgeRate = fMagicDodgeRate
		end	
	end
end

-- �仯ģ��
function CCharacterClientCallbackHandler:ChangeBody( uEntityID, tbl )
	
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	local RenderObj = Character:GetRenderObject()
	
	RenderObj:RemoveAllPiece()
	RenderObj:Delframework()
	InitChangeBodyRender(RenderObj, tbl)
end

-- �ָ�ģ��
function CCharacterClientCallbackHandler:Resume( uEntityID )

	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	local RenderObj = Character:GetRenderObject()
	
	RenderObj:RemoveAllPiece()
	RenderObj:Delframework()
	
	local Type = Character.m_Properties:GetType()

	if Type == ECharacterType.Player then
		UpdateModel(Character)
		UpdateFollowerCoreInfo(Character)
	elseif Type == ECharacterType.Npc then
	 	local NpcName = Character.m_Properties:GetCharName()
		local Sex = Character.m_Properties:GetSex()
		InitRenderNpc(Character:GetRenderObject(), NpcName, Sex)						
	end
end

function CCharacterClientCallbackHandler:CheckIsCanLock(pTarget)
	local NpcName = pTarget.m_Properties:GetCharName()
	if Npc_Common(NpcName) and 
		--��Ѫ����Ϊ1����2��Npc�����Ա�ѡ��
		(Npc_Common(NpcName,"ShowBloodType") == 1 
		or Npc_Common(NpcName,"ShowBloodType") == 2) then
		return false
	end
	return true
end

function CCharacterClientCallbackHandler:SetLockObj(uObjID, uTargetID)
	local CharacterFollower = CCharacterFollower_GetCharacterByID(uObjID)
	local TargetFollower = CCharacterFollower_GetCharacterByID(uTargetID)
	if(CharacterFollower==nil)then
		return
	end
	
--	if TargetFollower and TargetFollower ~= g_MainPlayer and 
--		(not TargetFollower:CanBeSelected() and TargetFollower.m_Properties:GetType() == ECharacterType.Npc) then
--		return
--	end
	if  TargetFollower == nil then
		if(g_MainPlayer.m_LockCenter.m_LockingObj  == CharacterFollower)then
			g_GameMain.m_TargetOfTargetInfo:Close()
		end
		if CharacterFollower == g_MainPlayer then
			g_MainPlayer:SetTarget(0)
		end
		return
	end
	if CharacterFollower == g_MainPlayer then
		if(g_MainPlayer.m_LockCenter.m_LockingObj  ~= TargetFollower)then
			g_MainPlayer:CancelNormalAttack()
		end
		local NpcName = TargetFollower.m_Properties:GetCharName()
		--��Ѫ����Ϊ1����2��Npc�����Ա�ѡ��
		if Npc_Common(NpcName) then
			if Npc_Common(NpcName, "ShowBloodType") ~= 1 and Npc_Common(NpcName, "ShowBloodType") ~= 2 then
				g_MainPlayer:LockObj(TargetFollower)
			else
				g_MainPlayer:UnLockObj()
			end
		else
			g_MainPlayer:LockObj(TargetFollower)
		end
	elseif(g_MainPlayer.m_LockCenter.m_LockingObj  == CharacterFollower and 
		CharacterFollower.m_LockCenter.m_LockingObj ~= TargetFollower)then
		--Ŀ���Ŀ��
		g_GameMain.m_TargetOfTargetInfo:LockTargetOfTarget(TargetFollower)
	end
end


function CCharacterClientCallbackHandler:OnCalValueChanged(uObjID)
	--ˢ���������
	if uObjID == g_MainPlayer:GetEntityID() then
		local Wnd = g_GameMain.m_RoleStatus
		if Wnd:IsShow() then
			Wnd:UpdateAllRoleInfo()
		end
	elseif g_GameMain.m_AimStatusWnd.m_Target ~= nil then
		if uObjID == g_GameMain.m_AimStatusWnd.m_Target:GetEntityID() then
			g_GameMain.m_AimStatusWnd:UpdateAllRoleInfo()
		end
--	elseif( uObjID == g_GameMain.m_TargetInfo.m_TargetEntityID ) then
--		g_GameMain.m_TargetInfo:SmashValueChanged()
	end
end

function CCharacterClientCallbackHandler:OnRelationChanged(uEntityID)
	--print("OnRelationChanged", uEntityID)
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	if g_MainPlayer and Character then
		g_MainPlayer:ChangeCharacterFollowerList(Character)
		g_MainPlayer:ChangeHideModeOnRelationChanged(Character)
		g_MainPlayer:ChangeSelectedModeOnRelationChanged(Character)
	end
end

function CCharacterClientCallbackHandler:OnFireActionEnd(uEntityID)

end

function CCharacterClientCallbackHandler:OnRealNameChange(uEntityID, eType, szRealName)
	--print("CCharacterClientCallbackHandler:OnRealNameChange", eType, szRealName)
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	if Character == g_MainPlayer:GetServant(eType) then
		if(eType == ENpcType.ENpcType_BattleHorse ) then
			CBattleHorseInfo.GetWnd():OnServantNameChanged()
		elseif(eType == ENpcType.ENpcType_Summon) then
			CServantInfo.GetWnd():OnServantNameChanged()
		end
	end
	if(Character.m_HeadInfoWnd) then
		g_GameMain.m_CharacterInSyncMgr:UpdateInfo(Character)
	end
	g_GameMain.m_TargetInfo:Update()
end

function CCharacterClientCallbackHandler:GetWeaponTypeString(uEntityID, bIsMainHandWeapon)
	-- �ڹ�����Ч��ʼ��HIT�ؼ�֡�����Ұ�����SyncRootVariantΪnil
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	if Character.m_Properties.m_StaticSyncRootVariant == nil then
		return ""
	end

	local WeaponTypeTbl = {}
	WeaponTypeTbl["���ֽ�"]		= "sword";
	WeaponTypeTbl["���ָ�"]		= "sword";
	WeaponTypeTbl["���ִ�"]		= "hammer";
	WeaponTypeTbl["���ֵ�"]		= "sword";
	
	WeaponTypeTbl["���ֽ�"]		= "sword";
	WeaponTypeTbl["���ָ�"]		= "sword";
	WeaponTypeTbl["���ִ�"]		= "hammer";
	WeaponTypeTbl["������Ȼ��"]	= "";
	WeaponTypeTbl["���ְ�����"]	= "";
	WeaponTypeTbl["�����ƻ���"]	= "";
	
	WeaponTypeTbl["���ֽ�"]		= "sword";
	WeaponTypeTbl["���ָ�"]		= "sword";
	WeaponTypeTbl["���ִ�"]		= "hammer";
	
	WeaponTypeTbl["˫�ֽ�"]		= "thsword";
	WeaponTypeTbl["˫�ָ�"]		= "thsword";
	WeaponTypeTbl["˫�ִ�"]		= "thhammer";
	WeaponTypeTbl["˫�ֹ�"]		= "";
	WeaponTypeTbl["˫����"]		= "";
	WeaponTypeTbl["˫����Ȼ��"]	= "";
	WeaponTypeTbl["˫�ְ�����"]	= "";
	WeaponTypeTbl["˫���ƻ���"]	= "";
	
	WeaponTypeTbl["��ʿǹ"]		= "lance";
	WeaponTypeTbl["����ì"]		= "lance";
	WeaponTypeTbl["������"]		= "long";
	WeaponTypeTbl["������"]		= "long"

	local WeaponIndexID
	if bIsMainHandWeapon then
		WeaponIndexID = Character.m_Properties:GetWeaponIndexID()
	else
		WeaponIndexID = Character.m_Properties:GetOffWeaponIndexID()
	end

	if WeaponIndexID ~= 0 then
		local EquipType = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticWeaponBigID(),g_CParseWeaponTbl[WeaponIndexID],"EquipType")
		
		return WeaponTypeTbl[EquipType]
	else
		return "hand"
	end	
end

function CCharacterClientCallbackHandler:GetArmorTypeString(uEntityID)
	local Character = CCharacterFollower_GetCharacterByID(uEntityID)
	if Character.m_Properties.m_StaticSyncRootVariant == nil then
		return "bare"
	end
	local IndexID = Character.m_Properties:GetBodyIndexID()
	if IndexID ~= 0 then
		local EquipType = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"EquipType")
		if EquipType == "����" or EquipType == "Ƥ��" then
			return "bare"
--		elseif Info.EquipType == "Ƥ��" then
--			return "leather"
--		elseif Info.EquipType == "����" then
--			return "chain"
		elseif EquipType == "���" or EquipType == "����" then
			return "metal"
		end
	else
		return "bare"
	end	
end

function CCharacterClientCallbackHandler:GetNpcAniFileName(npcName)
	local AniFileName = NpcRes_Common(npcName, "AniFileName")
	return AniFileName
end

function CCharacterClientCallbackHandler:OnUpdateSmashRate(uTargetObjID, eAttackType, uSmashValue, fSmashRate, bTargetIsDead)
	if( uTargetObjID == g_GameMain.m_TargetInfo.m_TargetEntityID ) then
		--print("CCharacterClientCallbackHandler:OnUpdateSmashRate", uTargetObj, uSmashValue, fSmashRate)
		g_GameMain.m_TargetInfo:SmashValueChanged(bTargetIsDead, eAttackType, uSmashValue, fSmashRate)
	end
end

function CCharacterClientCallbackHandler:OnIntoScreen(Character)
	if(Character.m_DirectionInfoWnd) then
		Character.m_DirectionInfoWnd:ShowWnd(false)
	end
end

function CCharacterClientCallbackHandler:OnLeaveScreen(Character)
	if(Character.m_DirectionInfoWnd) then
		Character.m_DirectionInfoWnd:ShowWnd(true)
	end
end

function CCharacterClientCallbackHandler:OnDisplayMsg(Character,MsgID,MsgFX)
	local RenderObj = Character:GetRenderObject()
	local strEffectFile="fx/setting/number3.efx";
	local strEffectName= MsgFX
	local strDisplay=GetStaticTextClient(MsgID)
	local strFontName="msg"
	CFontSprite_DisplayInfo(RenderObj,strEffectFile,strEffectName,strFontName,strDisplay,99999,false,2);
end
