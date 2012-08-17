gas_require "message/ServerMsg"
gac_gas_require "item/Equip/EquipDef"
gas_require "fight/fightskill/PlayerFightSkillGas"
gas_require "world/trigger_action/obj/assign_mode/NeedAssign"
gac_gas_require "shortcut/ShortcutCommon"
gac_gas_require "player/PlayerMgr"
gac_gas_require "activity/item/ItemUseInfoMgr"
gas_require "activity/quest/GasQuestNotepad"
gas_require "item/useitem/GasUseItem"
gas_require "framework/main_frame/GetTableFromExecuteSql"
gas_require "information/sort/PlayerAttribute"
gas_require "world/facial_action/FacialAction"
gas_require "world/other_activity/RideCame"
gas_require "world/other_activity/CrazyHorse"
gas_require "activity/direct/direct"
cfg_load "player/LevelExp_Common"
cfg_load "fb_game/FbActionDirect_Common"
cfg_load "player/RebornPos_Common"
cfg_load "player/DirectInfo_Common"
cfg_load "player/FbRebornPos_Common"
cfg_load "item/Exp_Soul_Bottle_Common"
cfg_load "fb_game/RecruitAward_Common"

local SavePosTickTime = 60*30  --���λ�ô���ʱ������
local SaveFightPropertyTickTime = 60*30
local SavePlayerSoulTickTime = 60*2 --���ڴ���������ϵĻ�ֵд�����ݿ�
local SaveFightingPointTickTime = 60*5 --���ڴ������ս����������д�����ݿ�
--/**��PK����**/
--local PkCriminalRate = 1.5

local ReBornTypeEnmu = {}
ReBornTypeEnmu.rbCurrPos = 1--����ʯ����
ReBornTypeEnmu.rbNewPlayer = 2--���ָ���
ReBornTypeEnmu.rbGoBack = 3--�ظ���㸴��
ReBornTypeEnmu.rbObserverMode = 4--����۲�ģʽ(����)
ReBornTypeEnmu.rbIntoFbPos = 5--�ڸ����Ľ���㸴��
ReBornTypeEnmu.rbNow = 6--��������
ReBornTypeEnmu.rbRobRes = 11--��������
--------------------------------------------

function g_cmdMoveRole(arg1, arg2, arg3)
	local player_id = tonumber(arg1)
	local xPos = tonumber(arg2)
	local yPos = tonumber(arg3)
	local player = g_GetPlayerInfo(player_id)	
	local newpos = CPos:new()
	newpos.x = x
	newpos.y = y
	if player ~= nil then
		player:SetGridPos( newpos )
	end
end
--nRange: ���ͷ�Χ(1-Conn,2-Scene,3-Server)
--******************************************
function Gac2Gas:TestMessage(Connection, nRange)
	--print("*******MsgToConn********")
	if(nRange == 1) then
		MsgToConn( Connection,1 )
		MsgToConn( Connection,2,3,"����è",10 )
		MsgToConn( Connection,3 )
		MsgToConn( Connection,4,999 )
	elseif(nRange == 2) then
		local Scene = Connection.m_Player.m_Scene
		MsgToScene( Scene,1 )
		MsgToScene( Scene,2,3,"����è",10 )
		MsgToScene( Scene,3 )
		MsgToScene( Scene,4,999 )
	elseif(nRange == 3) then
		MsgToServer( 1 )
		MsgToServer( 2,3,"����è",10 )
		MsgToServer( 3 )
		MsgToServer( 4,999 )
	end
end
--******************************************


function CCharacterMediator:GetViewGroup()
	return self.m_uViewGroup
end

function Gac2Gas:UnLockObj( Connection )
	local function Init()
		if( Connection.m_Player and Connection.m_Player.UnLockObj ~= nil ) then
			Connection.m_Player:UnLockObj( true )
		end
	end
	apcall(Init)
end

function Gac2Gas:GoLastMasterSceneReborn(Connection)
	if not IsCppBound(Connection.m_Player) then
		return
	end
	local Scene = Connection.m_Player.m_Scene
	if 1 ~= Scene.m_SceneAttr.RebornType then
		local sceneName = Connection.m_Player.m_MasterSceneName
		local pos = Connection.m_Player.m_MasterScenePos
		if sceneName ~= Scene.m_LogicSceneName then
			Connection.m_Player:SetGameCamp(0)
			Connection.m_Player:CppSetCamp(Connection.m_Player:CppGetBirthCamp())
			ChangeSceneByName(Connection,sceneName,pos.x,pos.y)
		else
			Connection.m_Player:Reborn(0.3)
		end
	end
end

function Gac2Gas:GoBackOrStay( Connection, BeGoBack )
	if not IsCppBound(Connection.m_Player) then
		return
	end
	Connection.m_Player.m_IsGoBackReborn = nil--ֻҪ�յ���Ϣ,�������־
	if Connection.m_Player:CppIsLive() then
		Gas2Gac:CloseRebornMsgWnd(Connection)
		return
	end
	if(BeGoBack) then
		Connection.m_Player:GoBackAndReborn(Connection)
	else
		local RebornTime = Connection.m_Player.m_StayRebornTime
		if RebornTime then
			local res = RebornTime - os.time()
			if res > 0 then
--				LogErr("CDʱ��������¸���ʧ��","���("..Connection.m_Player.m_Properties:GetCharName()..") ID("..Connection.m_Player.m_uID..") "..Connection.m_Player.m_Scene.m_SceneName.."ԭ�ظ���ʱ��("..Connection.m_Player.m_RebornCountTime..")�� ���("..res..")��    ", Connection)
--				Gas2Gac:RebornTimeLog(Connection)
				return
			end
		end
		Connection.m_Player:AtDeadPositionReborn(Connection)
	end
end

function Gac2Gas:StationReborn(Connection)
	Connection.m_Player:StationReborn(Connection)
end

function Gac2Gas:TongChallengeReborn(Connection)
	Connection.m_Player:TongChallengeReborn()
end

--�˳�����(�й۲�ģʽ���˳�����)
local ObserverModeSceneFun = {
	[10] = MsgSelExitIntegralMatch,
}

function Gac2Gas:ExitOrInMode( Connection, InMode )
	local Scene = Connection.m_Player.m_Scene
	if 1 ~= Scene.m_SceneAttr.RebornType then
		if(InMode) then
			Connection.m_Player:EnterObserverMode()
		else
			local SceneType = Scene.m_SceneAttr.m_SceneType
			if ObserverModeSceneFun[SceneType] then
				ObserverModeSceneFun[SceneType](Connection.m_Player)
			else
				local sceneName = Connection.m_Player.m_MasterSceneName
				local pos = Connection.m_Player.m_MasterScenePos 
				Connection.m_Player:SetGameCamp(0)
				Connection.m_Player:CppSetCamp(Connection.m_Player:CppGetBirthCamp())
				ChangeSceneByName(Connection,sceneName,pos.x,pos.y)
			end
		end
	end
end

function Gac2Gas:GoIntoFbOrStay( Connection, BeGoBack )
	if Connection.m_Player and IsCppBound(Connection.m_Player) then
		if Connection.m_Player:CppIsLive() then
			Gas2Gac:CloseRebornMsgWnd(Connection)
			return
		end
		if BeGoBack then
			local RebornTime = Connection.m_Player.m_PlayerRebornTime
			if RebornTime then
				local res = RebornTime - os.time()
				if res > 0 then
--					LogErr("CDʱ��������¸���ʧ��","���("..Connection.m_Player.m_Properties:GetCharName()..") ID("..Connection.m_Player.m_uID..") "..Connection.m_Player.m_Scene.m_SceneName.."������ڵ㸴��CD��("..res..")��", Connection)
--					Gas2Gac:RebornTimeLog(Connection)
					return
				end
			end
			local PixelPos = CFPos:new()
			local PosX = Connection.m_Player.m_Scene.m_SceneAttr.InitPosX
			local PosY = Connection.m_Player.m_Scene.m_SceneAttr.InitPosY
			PixelPos.x = PosX * EUnits.eGridSpanForObj
			PixelPos.y = PosY *EUnits.eGridSpanForObj
			Connection.m_Player:SetPixelPos(PixelPos)
			Connection.m_Player.m_RebornType = ReBornTypeEnmu.rbIntoFbPos
			Connection.m_Player:Reborn(0.3)
		else
			local RebornTime = Connection.m_Player.m_StayRebornTime
			if RebornTime then
				local res = RebornTime - os.time()
				if res > 0 then
--					LogErr("CDʱ��������¸���ʧ��","���("..Connection.m_Player.m_Properties:GetCharName()..") ID("..Connection.m_Player.m_uID..") "..Connection.m_Player.m_Scene.m_SceneName.."����ԭ�ظ���CD��("..res..")��", Connection)
--					Gas2Gac:RebornTimeLog(Connection)
					return
				end
			end
			Connection.m_Player:AtDeadPositionReborn(Connection)
		end
	end
end

function Gac2Gas:GoRobResRebormPlaceStay( Connection, BeGoBack )
	if Connection.m_Player and IsCppBound(Connection.m_Player) then
		if Connection.m_Player:CppIsLive() then
			Gas2Gac:CloseRebornMsgWnd(Connection)
			return
		end
		if BeGoBack then
			local RebornTime = Connection.m_Player.m_PlayerRebornTime
			if RebornTime then
				local res = RebornTime - os.time()
				if res > 0 then
--					LogErr("CDʱ��������¸���ʧ��","���("..Connection.m_Player.m_Properties:GetCharName()..") ID("..Connection.m_Player.m_uID..") "..Connection.m_Player.m_Scene.m_SceneName.."������ڵ㸴��CD��("..res..")��", Connection)
					--Gas2Gac:RebornTimeLog(Connection)
					return
				end
			end
			local PixelPos = CFPos:new()
			
			local PosX,PosY
			--�õ�����������ĸ����
			local SceneName = Connection.m_Player.m_Scene.m_LogicSceneName
			local nCamp =  Connection.m_Player:CppGetCamp()
			local info = RebornPos_Common(SceneName, tostring(nCamp))
			if info then
				local Keys = info:GetKeys()
				for _,p in pairs(Keys) do
					if info(p, "DefaultReborn") == 0 then
						PosX = info(p, "PosX")
						PosY = info(p, "PosY")
					end
				end
			end
			
			PixelPos.x = PosX * EUnits.eGridSpanForObj
			PixelPos.y = PosY * EUnits.eGridSpanForObj
			Connection.m_Player:SetPixelPos(PixelPos)
			Connection.m_Player.m_RebornType = ReBornTypeEnmu.rbRobRes
			Connection.m_Player:Reborn(0.3)
		else
			local RebornTime = Connection.m_Player.m_StayRebornTime
			if RebornTime then
				local res = RebornTime - os.time()
				if res > 0 then
--					LogErr("CDʱ��������¸���ʧ��","���("..Connection.m_Player.m_Properties:GetCharName()..") ID("..Connection.m_Player.m_uID..") "..Connection.m_Player.m_Scene.m_SceneName.."����ԭ�ظ���CD��("..res..")��", Connection)
				--	Gas2Gac:RebornTimeLog(Connection)
					return
				end
			end
			Connection.m_Player:AtDeadPositionReborn(Connection)
		end
	end
end


function Gac2Gas:AreaFbRebornToRePoint(Connection)
	if Connection.m_Player and IsCppBound(Connection.m_Player) then
		local Player = Connection.m_Player
		if Player:CppIsLive() then
			Gas2Gac:HideFBDeadMsgWnd(Connection)
			return
		end
		local Scene = Player.m_Scene
		local SceneId = Scene.m_SceneId
		local flag = true
		if g_NpcBornMgr._m_OnlyNpc[SceneId] then
			local OnlyNpcTbl = g_NpcBornMgr._m_OnlyNpc[SceneId]
			local BossNameTbl = GetCfgTransformValue(false, "AreaFb_Common", Scene.m_SceneName, "BossName")
			for i, v in pairs(BossNameTbl) do
				if OnlyNpcTbl[v] and OnlyNpcTbl[v]:CppGetCtrlState(EFighterCtrlState.eFCS_InBattle) then
				 	flag = false
				 	local bAllPlayerDead = true
				 	for PlayerID, PlayerInScene in pairs(Scene.m_tbl_Player) do
						if PlayerInScene:CppIsLive() then
							bAllPlayerDead = false
						end
					end
					if bAllPlayerDead then
						local pEnmityQueryCallback = CNpcEnmityQueryCallback:new()
						pEnmityQueryCallback:QueryEnemy(OnlyNpcTbl[v])
						local EnemyTbl = pEnmityQueryCallback:GetAllEnemyTbl()
						local sMessage = ",���Ŀ����"
						for i, p in pairs(EnemyTbl) do
							if IsNumber(i) then
								sMessage = sMessage .. "  :" ..p.m_Properties:GetCharName()
								if p:CppIsLive() then
									sMessage = sMessage .. ",����������״̬"
								else
									sMessage = sMessage .. ",��������״̬"
								end
							end
						end
						local EnemyCount = pEnmityQueryCallback:GetEnemyCount()
						if EnemyCount~= 0 then
							LogErr("�����������������,Bossδ����ս��", "Boss�ĳ���б�Ϊ��,����:"..EnemyCount..sMessage)
						else
							LogErr("�����������������,Bossδ����ս��", "Boss�ĳ���б�Ϊ��")
						end
						OnlyNpcTbl[v]:ClearAllEnmity()
					end
					MsgToConn(Connection, 3202)
					return
				end
			end
		end
		if flag then
			Gac2Gas:GoIntoFbOrStay(Connection, true)
			---Gas2Gac:HideFBDeadMsgWnd(Connection)
		end
	end
end

function Gac2Gas:DoReborn( Connection )
	if Connection.m_Player and IsCppBound(Connection.m_Player) then
		if Connection.m_Player:CppIsLive() then
			return
		end
		if Connection.m_Player.b_PermitReborn then
			--Connection.m_Player.b_RebornFromID -- �ͷŸ����pFrom��pTo�������pFrom��λ��
			Connection.m_Player:SetGridPos( Connection.m_Player.RebornPos )
			Connection.m_Player:CppReborn()
			Connection.m_Player:CppInitHPMP(Connection.m_Player:CppGetMaxHP() * 0.1, Connection.m_Player:CppGetMaxMP() * 0.1)
			
			Connection.m_Player.b_PermitReborn = false
			Connection.m_Player.RebornPos = nil
		end
	end
end

function CCharacterMediator:UnLockObj( bMe )
	--print(" CCharacterMediator:UnLockObj() " )
	self.m_LockingObj	= nil
	if( self:GetTarget() ) then	
		if( self.SetTarget ) then
			self:SetTarget( nil )
		end
	end
end

--------------------------------------------------------- PK / PVP / ս�� ��� --------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------------------
function Gac2Gas:SetGridPos(Connection,x,y)
	Connection.m_Player:SetGridPos(x,y)
end

function Gac2Gas:SetPK(Connection,nPK)
	Connection.m_Player:SetPK(nPK)
end

--/******************************************************/
--/*********************PK*******************************/
--/******************************************************/

function CCharacterMediator:SetPKSwitch(Value)
	self:CppSetPKState(Value)
	--MsgToConn(self.m_Conn, PkSwitchMsgIDTable[Value])
	Gas2Gac:UpdatePkSwitchState(self.m_Conn)
	if self:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel) == false then
		Gas2Gac:UpdateHeadInfoByEntityID(self:GetIS(0), self:GetEntityID())
	end
end


--/**********************������ս*************************/
function CCharacterMediator:ChangeChallengeState(bValue)
	local ServantQuery = CServantQueryCallback:new()
	local ServantTbl = ServantQuery:QueryServant(self)
	if bValue then
		self:CppSetCtrlState(EFighterCtrlState.eFCS_InDuel, true)
		for id, Servant in pairs (ServantTbl) do
			Servant:CppSetCtrlState(EFighterCtrlState.eFCS_InDuel, true)
		end
	else
		self:CppSetCtrlState(EFighterCtrlState.eFCS_InDuel, false)
		self:SetGameCamp(0)
		for id, Servant in pairs (ServantTbl) do
			Servant:CppSetCtrlState(EFighterCtrlState.eFCS_InDuel, false)
			Servant:ReSetGameCamp()
		end		
	end
end

function CCharacterMediator:SetGameCamp(value)
	if value == 0 and self:CppGetCtrlState(EFighterCtrlState.eFCS_InDuel) then
		LogErr("��һ�����ս״̬,���ܳ����淨��Ӫ")
	end
	self:CppSetGameCamp(value)
end

function CCharacterMediator:AddPkValue(BeAttacker)
	
	local pkValue = BeAttacker.m_Properties:GetPkValue()
	if pkValue ~= 0 then
		local addPkValue = self.m_Properties:GetPkValue() + pkValue
		self:PlusPkValue(pkValue, addPkValue, BeAttacker.m_uID)
	else
		addPkValue = self.m_Properties:GetPkValue() + 1
		self:PlusPkValue(1,addPkValue,BeAttacker.m_uID)
	end
end

--function CCharacterMediator:MinusPkValue(PkType, NpcLevel)
--	if self:CppGetPKState() ~= EPKState.ePKS_Killer then
--		return
--	end
--	if self.m_Properties:GetPkValue() == 0 then
--		return
--	end
--	local PlayerLevel = self:CppGetLevel()
--	if (PkType == EZoneType.eZT_CommonZone or PkType == EZoneType.eZT_NewCommonZone) and (NpcLevel - 5) <= PlayerLevel and (NpcLevel + 5) >= PlayerLevel then
--		self.m_KillMinusPkValueCount = self.m_KillMinusPkValueCount + 1
--		if self.m_KillMinusPkValueCount >= math.ceil(PlayerLevel*PkCriminalRate) then
--			self.m_KillMinusPkValueCount = 0
--			self:PlusPkValue(-1)
--		end
--	end
--end
--
--local PkSwitchMsgIDTable = {
--	[EPKState.ePKS_Safety] 	= 193013,
--	[EPKState.ePKS_Rivalry] = 193014,
--	[EPKState.ePKS_Killer]	= 193001,
--}
--

local function updatePkValue(Player, tempValue, Value)
	Gas2Gac:UpdatePlayerPoint(Player.m_Conn,7,-tempValue)
	Player.m_Properties:SetPkValue(Value)
	Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
	Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
end

--�������PKֵ
function CCharacterMediator:PlusPkValue(tempValue, Value, id)  --ԭֵ,��ֵ

	if not IsCppBound(self) then
		return 
	end	
	if not IsCppBound(self.m_Conn) then
		return 	
	end
	local function Callback(result)
		if not result then
			return
		end
		local res = result[1]
		local flag = result[2]
		local BeAttackerId = result[3]
		local BeAttacker = g_GetPlayerInfo(BeAttackerId)
		if res then
			if Value > 0 then
				if flag then
					for server_id in pairs(g_ServerList) do
						Gas2GasAutoCall:SendPkValueRollMsg(GetServerAutoConn(server_id), self.m_Properties:GetCharName(), Value)
					end
				end
				MsgToConn(self.m_Conn, 193036, tempValue, Value)
				Gas2Gac:UpdatePlayerPoint(self.m_Conn,7,tempValue)				
				self.m_Properties:SetPkValue(Value)
				Gas2Gac:UpdatePkSwitchState(self.m_Conn)
				Gas2Gac:UpdateHeadInfoByEntityID(self:GetIS(0), self:GetEntityID())
				--updatePkValue(self, tempValue, Value)
				if IsCppBound(BeAttacker) and IsCppBound(BeAttacker.m_Conn) then
					if tempValue == 1 then 
						MsgToConn(BeAttacker.m_Conn, 193037, 0, 0)
						updatePkValue(BeAttacker, tempValue, 0)
						return 
					end
					MsgToConn(BeAttacker.m_Conn, 193037, tempValue, 0)
					updatePkValue(BeAttacker, tempValue, 0)
				end
			end
		end
	end
	local data = {}
	if Value > 0 then
		data["PkValue"]		= tempValue
		data["Value"]		= Value
		data["id"] = id
	end
	data["char_id"]			= self.m_uID
	data["scene_name"]	= self.m_Scene.m_SceneName
	CallAccountManualTrans(self.m_Conn.m_Account, "CharacterMediatorDB", "updatePlayerPkValue", Callback, data, id)
end


--�������PKֵ
function CCharacterMediator:UpdatePlayerPkValue(Value)
	if not IsCppBound(self) or not IsCppBound(self.m_Conn) then
		return
	end
	local PkValue = self.m_Properties:GetPkValue() + Value
	if PkValue < 0 then
		PkValue = 0
	end
	self.m_Properties:SetPkValue(PkValue)
	Gas2Gac:UpdatePkSwitchState(self.m_Conn)
	Gas2Gac:UpdateHeadInfoByEntityID(self:GetIS(0), self:GetEntityID())
end


----�������PKֵ
--function CCharacterMediator:PlusPkValue(Value)  --ԭֵ,��ֵ
--	local Prop = self.m_Properties
--	local PkValue = Prop:GetPkValue()+Value
--	if Value >= 0 then
--		MsgToConn(self.m_Conn, 193004, Value)
--	else
--		MsgToConn(self.m_Conn, 193005, -Value)
--	end
--	if PkValue <= 0 then
--		Prop:SetPkValue(0)
--		self:AutoCancelPkSwitch(false)
--	elseif PkValue > 20 then
--		Prop:SetPkValue(20)
--	else
--		Prop:SetPkValue(PkValue)
--	end
--	Gas2Gac:UpdatePkSwitchState(self.m_Conn)
--	Gas2Gac:UpdateHeadInfoByEntityID(self:GetIS(0), self:GetEntityID())
--	SavePkStateToDB(self)
--end
--
----�Զ��ر���ɱ״̬
--function CCharacterMediator:AutoCancelPkSwitch(flag)
--	if self:CppGetCtrlState(EFighterCtrlState.eFCS_InBattle) then
--		self.m_ClosePkSwitch = true
--		return
--	end
--	if self.m_Properties:GetPkValue() ~= 0 then
--		return
--	end
--	if self.m_PkCriminalTick then
--		return
--	end
--	MsgToConn(self.m_Conn, 193018)
--	if IsOpenProtectScene(self) then
--		self:SetPKSwitch(EPKState.ePKS_Safety)
--	else
--		self:SetPKSwitch(EPKState.ePKS_Rivalry)
--	end
--	if flag then
--		SavePkStateToDB(self)
--	end
--end
--
----�Զ��򿪶Կ�ģʽ
--function CCharacterMediator:AutoOpenRivalryState()
--	if self:CppGetLevel() < 25 then
--		return
--	end
--	if self:CppGetPKState() == EPKState.ePKS_Safety then
--		self:SetPKSwitch(EPKState.ePKS_Rivalry)
--	end
--end
--
--function CCharacterMediator:SetZoneType(Type)
--	apcall(self.CppSetZoneType,self,Type)
--	if self:CppGetLevel() < 25 then
--		return
--	end
--	if not IsOpenProtectScene(self) then
--		MsgToConn(self.m_Conn, 193022)
--		apcall(self.AutoOpenRivalryState,self)
--	end
--end
--
--function CCharacterMediator:PkCriminalTick()
----
----	local function TickFun()
----		self.m_CriminalTime = self.m_CriminalTime - 1
----		if self.m_CriminalTime <= 0 then
----			self.m_CriminalTime = PkCriminalTime
----			self:PlusPkValue(-1)
----			local PkValue = self.m_Properties:GetPkValue()
----			if PkValue == 0 then
----				UnRegisterTick(self.m_PkCriminalTick)
----				self.m_PkCriminalTick = nil
----			end
----		end
----	end
----	self.m_PkCriminalTick = RegisterTick("CriminalTick", TickFun, 60000)
--	
--	local function TickFun()
--		self.m_CriminalTime = self.m_CriminalTime - 1
--		if self.m_CriminalTime <= 0 then
--			UnRegisterTick(self.m_PkCriminalTick)
--			self.m_PkCriminalTick = nil
--			if self:CppGetPKState() == EPKState.ePKS_Killer then
--				self:AutoCancelPkSwitch(true)
--			end
--		end
--	end
--	if self.m_PkCriminalTick then
--		UnRegisterTick(self.m_PkCriminalTick)
--	end
--	self.m_PkCriminalTick = RegisterTick("CriminalTick", TickFun, 60000)
--end
--/***************************��PK����************************************/

--����ѡ�л�������,Ĭ��Ϊ0��1Ϊ��ͨ��ң�2Ϊ�󶨽��
function Gac2Gas:SetMoneyType(Connection,	nMoneyType)
	if not (1 == nMoneyType or 2 == nMoneyType) then
		return
	end
	local Player = Connection.m_Player
	if not (Player and IsCppBound(Player)) then return end
		
	local function CallBack(suc)
		if suc then
			Gas2Gac:SetMoneyTypeBtnCheck(Connection,nMoneyType)
		end
--		print("��ѡ�еĻ���������:", Connection.m_Player.m_Properties:GetMoneyType())
	end
	local data = {["MoneyType"] = nMoneyType, ["CharID"]=Player.m_uID }
	CallAccountManualTrans(Connection.m_Account, "CharacterMediatorDB", "SetMoneyType", CallBack, data)
end

function CCharacterMediator:OnCreateTrap( x, y, TrapID )
	self:CreateTrap( TrapID )
end

function CCharacterMediator:CreateTrap( TrapID )

	self:DestroyTrap()

	local pos = CPos:new()
	self:GetGridPos( pos )

	local Trap = CIntObjTrapServer:new()
	self.m_MyTrap = Trap
	Trap:Create( self.m_Scene , pos.x , pos.y , self, TrapID )

end


function CCharacterMediator:DestroyTrap()
	local function Init()
		if self.m_MyTrap == nil then
			return
		end
	
		--print(" Destroy trap")
		self.m_MyTrap:Destroy()
		self.m_MyTrap = nil
	end
	apcall(Init)
end
-------------------------------װ����Ϣ����----------------------------------
function CCharacterMediator:SetEquipInfo(nBigID,nIndex,nItemID,eEquipPart)
	if eEquipPart == EEquipPart.eWeapon then
		self.m_WeaponInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eAssociateWeapon then
		self.m_AssociateWeaponInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eWear then
		self.m_WearInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eHead then --������Ϣ��û�����
		self.m_HeadInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eShoe then
		self.m_ShoeInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eRingLeft then
		self.m_RingLeftInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eRingRight then
		self.m_RingRightInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eNecklace then
		self.m_NecklaceInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eAccouterment then
		self.m_AccoutermentInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eShoulder then
		self.m_ShoulderInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eSash then
		self.m_SashInfo = {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eHand then
		self.m_HandInfo	= {nBigID,nIndex,nItemID}
	elseif eEquipPart == EEquipPart.eBack then
		self.m_BackInfo	= {nBigID,nIndex,nItemID}
	end
end

function CCharacterMediator:ClearEquipInfo(eEquipPart)
	if eEquipPart == EEquipPart.eWeapon then
		self.m_WeaponInfo = nil
	elseif eEquipPart == EEquipPart.eAssociateWeapon then
		self.m_AssociateWeaponInfo = nil
	elseif eEquipPart == EEquipPart.eWear then
		self.m_WearInfo = nil
	elseif eEquipPart == EEquipPart.eHead then
		self.m_HeadInfo = nil
	elseif eEquipPart == EEquipPart.eShoe then
		self.m_ShoeInfo = nil
	elseif eEquipPart == EEquipPart.eRingLeft then
		self.m_RingLeftInfo = nil
	elseif eEquipPart == EEquipPart.eRingRight then
		self.m_RingRightInfo = nil
	elseif eEquipPart == EEquipPart.eNecklace then
		self.m_NecklaceInfo = nil
	elseif eEquipPart == EEquipPart.eAccouterment then
		self.m_AccoutermentInfo = nil
	elseif eEquipPart == EEquipPart.eShoulder then
		self.m_ShoulderInfo = nil 
	elseif eEquipPart == EEquipPart.eSash then
		self.m_SashInfo = nil 
	elseif eEquipPart == EEquipPart.eHand then
		self.m_HandInfo	= nil 
	elseif eEquipPart == EEquipPart.eBack then
		self.m_BackInfo = nil 
	end
end

--����Լ��ж��Ƿ�Ϊnil,Ϊnil��ʾ�����λ��û��װ��
function CCharacterMediator:GetEquipInfo(eEquipPart)
	if eEquipPart == EEquipPart.eWeapon then
		return self.m_WeaponInfo
	elseif eEquipPart == EEquipPart.eAssociateWeapon then
		return self.m_AssociateWeaponInfo
	elseif eEquipPart == EEquipPart.eWear then
		return self.m_WearInfo
	elseif eEquipPart == EEquipPart.eHead then
		return self.m_HeadInfo
	elseif eEquipPart == EEquipPart.eRingLeft then
		return self.m_RingLeftInfo
	elseif eEquipPart == EEquipPart.eRingRight then
		return self.m_RingRightInfo
	elseif eEquipPart == EEquipPart.eNecklace then
		return self.m_NecklaceInfo
	elseif eEquipPart == EEquipPart.eAccouterment then
		return self.m_AccoutermentInfo
	elseif eEquipPart == EEquipPart.eShoulder then
		return self.m_ShoulderInfo
	elseif eEquipPart == EEquipPart.eSash then
		return self.m_SashInfo 	
	elseif eEquipPart == EEquipPart.eHand then
		return self.m_HandInfo
	elseif eEquipPart == EEquipPart.eShoe then
		return self.m_ShoeInfo
	elseif eEquipPart == EEquipPart.eBack then
		return self.m_BackInfo
	end
end

--���ؽ�ɫ��������װ����Ϣ
function CCharacterMediator:GetArmorInfoTbl()
	local Infotbl = {}
	if self.m_WearInfo ~= nil then
		table.insert(Infotbl,{EEquipPart.eWear,self.m_WearInfo})
	end
	if self.m_HeadInfo ~= nil then
		table.insert(Infotbl,{EEquipPart.eHead,self.m_HeadInfo})
	end
	if self.m_ShoulderInfo ~= nil then
		table.insert(Infotbl,{EEquipPart.eShoulder,self.m_ShoulderInfo})
	end
	if self.m_SashInfo ~= nil then
		table.insert(Infotbl,{EEquipPart.eSash,self.m_SashInfo})
	end
	if self.m_HandInfo ~=nil then
		table.insert(Infotbl,{EEquipPart.eHand,self.m_HandInfo})
	end
	if  self.m_ShoeInfo ~= nil then
		table.insert(Infotbl,{EEquipPart.eShoe,self.m_ShoeInfo})
	end
	return Infotbl
end

--�õ���ɫ���Ϸ�����Ϣ
function CCharacterMediator:SetArmorValue()
	local tbl = self:GetArmorInfoTbl()
	local BanjNumber,SuojNumber,PijNumber,BujNumber = 0,0,0,0
	for i = 1, #(tbl) do 
		local EquipType = g_ItemInfoMgr:GetItemInfo(tbl[i][2][1],tbl[i][2][2],"EquipType")
		if EquipType == "���" then 
			BanjNumber = BanjNumber + 1
		elseif EquipType == "����" then 
			SuojNumber = SuojNumber + 1
		elseif EquipType == "Ƥ��" then 
			PijNumber = PijNumber + 1
		elseif EquipType == "����" then 
			BujNumber = BujNumber + 1
		end
	end
	--����ֵ
	local PunctureValue = PijNumber/6 * 0.2
	--���ֵ
	local ChopValue = BanjNumber/6*0.2 + SuojNumber/6*0.1 - PijNumber/6*0.1 - BujNumber/6*0.1
	--�ۻ�ֵ
	local BluntTraumaValue = BujNumber/6*0.2 - BanjNumber/6*0.1
	self:SetArmorValueRate(BluntTraumaValue,PunctureValue,ChopValue)
end

--�������ֳ�ʼ��
function CCharacterMediator:InitEquipAttackNum()
	self.m_nWeaponAttackNum = 0
	self.m_nHeadAttackNum = 0
	self.m_nWearAttackNum = 0
	self.m_nSashAttackNum = 0
	self.m_nCuffAttackNum = 0
	self.m_nShoeAttackNum = 0
end

function CCharacterMediator:ResumeBaseProperty(FightSkill)
	self:RemoteInit()
	self:InitSpeed()
	self:LoadAllFightSkillToGac(FightSkill)
	if self.m_uLevel > LevelExp_Common.GetHeight() then
		ExpOfCurLevelUp=0
		self.m_uLevelExp=0
	else
		ExpOfCurLevelUp=LevelExp_Common(self.m_uLevel, "ExpOfCurLevelUp")
	end
	--ͬ���߼���Ϣ���ͻ��˵�Director����
	Gas2Gac:InitMainPlayer( self.m_Conn,
		self.m_uLevelExp,
		ExpOfCurLevelUp,
		self.m_Scene.m_SceneName,
		self.m_Scene.m_SceneAttr.SceneType
	)
end

function CCharacterMediator:InitBaseProperty(CharInfo, FightSkill,TeamID,TongID,TongName,playerAppellationInfo, pkPoint,ArmyCorpsName)
	local uCharID = self.m_uID
		
	self.m_Properties = CServerPlayerProperties:new()
	
	local Prpts = self.m_Properties
	
	Prpts:Init(self)
	
	Prpts:SetCharID(uCharID)
	Prpts:SetCharName(CharInfo(1,1))
	Prpts:SetType(ECharacterType.Player)
	Prpts:SetUserID(0)
	Prpts:SetSex(0)
	self:SetTeamID(0)
	self:SetTongID(0)
	Prpts:SetTongName("")
	Prpts:SetCharAppellation1(0)
	Prpts:SetCharAppellation2(0)
	Prpts:SetOffWeaponBigID(nil)
	Prpts:SetWeaponIndexID(nil)
	Prpts:SetShoeIndexID(nil)
	Prpts:SetArmIndexID(nil)
	Prpts:SetBodyIndexID(nil)
	Prpts:SetShoulderIndexID(nil)
	Prpts:SetHeadIndexID(nil)
	Prpts:SetOffWeaponIndexID(nil)
	Prpts:SetBackIndexID(nil)
	Prpts:SetShowArmet(true)
	
	Prpts:SetHorseResID(nil)
	Prpts:SetHandsBehaviorName("")
	Prpts:SetHorseType("")
	Prpts:SetBehaviorType("")
	
	Prpts:SetWeaponPhase(nil)
	Prpts:SetOffWeaponPhase(nil)
	Prpts:SetBodyPhase(nil)
	Prpts:SetHeadPhase(nil)
	Prpts:SetShoulderPhase(nil)
	Prpts:SetArmPhase(nil)
	Prpts:SetShoePhase(nil)
	
	local HairResID = g_ParseCustomTblServer[CharInfo(1,3)]
	local FaceResID = g_ParseCustomTblServer[CharInfo(1,5)]
	Prpts:SetHairResID(HairResID)
	Prpts:SetFaceResID(FaceResID)
	if HairResID > 256 then
		LogErr("HairResID ������Χ", HairResID)
	end
	if FaceResID > 256 then
		LogErr("FaceResID ������Χ", FaceResID)
	end
	
	Prpts:InitCharStatic(CharInfo(1,2),CharInfo(1,7),CharInfo(1,8))
	Prpts:InitFightEnergy()
			--/**PK����**/


	Prpts:SetPkValue(pkPoint)

	self.m_uLevelExp					= CharInfo(1,12)
	
	self.m_uNonCombatValue = {}
	self.m_uNonCombatValue["����ֵ"] = 0
	self.m_uNonCombatValue["���ֵ"] = 0
	self.m_uNonCombatValue["����ֵ"] = 0
	
	self.m_ExpModulus			= 1
	self.m_ExpModulusInFB	= 1
	self.m_FetchModulus		= 1
	self.m_ExpModulusByItem = 3
	self.m_ExpModulusByFifthItem = 5

	self:CppInit(self.m_Class,self.m_uLevel,self.m_Camp)

	self:RemoteInit()
	self:InitSpeed()

	self:LoadAllFightSkill(FightSkill)

	self.m_uViewGroup			= g_ViewGroupMgr:NewViewGroup()

	self.m_LockingObj			= nil

	self.m_MagicEfList			= CList:new()
	self.m_FxIdList				= CList:new()

	self.m_ControlCount			= 0
	self.tblSysSettingInfo = nil
	self.m_bItemDBTransLock		= false
	self:InitEquipAttackNum()

	--TeamID,TongID
	self:SetTeamID(TeamID)
	self:SetTongID(TongID)
	if TongName then
		Prpts:SetTongName(TongName)
	end
	Prpts:SetArmyCorpsName(ArmyCorpsName)
	if playerAppellationInfo then
		Prpts:SetCharAppellation1(playerAppellationInfo[1])
		Prpts:SetCharAppellation2(playerAppellationInfo[2])
	end

	local ExpOfCurLevelUp
	if self.m_uLevel > LevelExp_Common.GetHeight() then
		ExpOfCurLevelUp=0
		self.m_uLevelExp=0
	else
		ExpOfCurLevelUp=LevelExp_Common(self.m_uLevel, "ExpOfCurLevelUp")
	end
	
	--ͬ���߼���Ϣ���ͻ��˵�Director����
	Gas2Gac:InitMainPlayer( self.m_Conn,
	self.m_uLevelExp,
	ExpOfCurLevelUp,
	self.m_Scene.m_SceneName,
	self.m_Scene.m_SceneAttr.SceneType
	)
end


function CCharacterMediator:GetShortInfoByRet(res)
	if res then
		local function InitAllChanelPanelInfo()
			local row = res:GetRowNum()
			if row > 0 then
				for n = 1, row do
					-- ���ﻹҪ���һ�¿�����洢������Ч��
					-- ��Ϊ�߻����ܸ����ñ�
					local Pos, Type, Arg1, Arg2, Arg3 = res(n,1),res(n,2),res(n,3),res(n,4),res(n,5)
					Gas2Gac:ReturnShortcut(self.m_Conn, Pos, Type, Arg1, Arg2, Arg3)
				end
			end
			self:InitShortcutEnd(self)
		end
		apcall(InitAllChanelPanelInfo)
	end
end

------------------------------------CCharacterMediator ��Ʒ DbTrans��Lock--------------------------------------------------------------
function CCharacterMediator:TestDBTransBlock()
	if self.m_Conn.m_Account then
		return self.m_Conn.m_Account.m_bDBTransBlock
	else
		return false
	end
end
function CCharacterMediator:BlockDBTrans()
	if not self.m_Conn.m_Account then
		return false
	end
	if self.m_Conn.m_Account.m_bDBTransBlock then
		return false
	end
	self.m_Conn.m_Account.m_bDBTransBlock = true
	return true
end
function CCharacterMediator:UnBlockDBTrans()
	self.m_Conn.m_Account.m_bDBTransBlock = false
end

function CCharacterMediator:LockItemDbTrans()
	if self.m_bItemDBTransLock then
		return false
	end
	self.m_bItemDBTransLock = true
	return true
end

function CCharacterMediator:UnLockItemDbTrans()
	self.m_bItemDBTransLock = false
end

function CCharacterMediator:InitQuestItemCDTime(ItemCoolDownInfo, IsRevise)
	if self.m_SpecialItemCoolDown  == nil then
		self.m_SpecialItemCoolDown = {}
	end
	local function coolDownEnd(itemName)
		if self.m_SpecialItemCoolDown then
			self.m_SpecialItemCoolDown[itemName] = nil
		end
	end
	
	local function Init()
		local now = os.time()
		
		if IsRevise then
			for itemName, time in pairs(ItemCoolDownInfo) do
				local tickTime = g_ItemUseInfoMgr:GetItemUseInfo(itemName,"CoolDownTime") - ((now - time) * 1000)
				self.m_SpecialItemCoolDown[itemName] = time
				RegisterOnceTick(self, "SpecialItemCoolDownTick",coolDownEnd, tickTime, itemName)
			end

		else
		
			--��Ʒ��ȴʱ��
			for itemName, time in pairs(ItemCoolDownInfo) do
				local tickTime = g_ItemUseInfoMgr:GetItemUseInfo(itemName,"CoolDownTime") - time * 1000
				if not self.m_SpecialItemCoolDown[itemName] then  --�����Ϊnil˵������resume ���õ�
					self.m_SpecialItemCoolDown[itemName] = now - time
					RegisterOnceTick(self, "SpecialItemCoolDownTick",coolDownEnd, tickTime, itemName)
				end
				Gas2Gac:SetItemCoolDownTime(self.m_Conn, itemName, g_ItemUseInfoMgr:GetItemUseInfo(itemName,"CoolDownTime"), time)
			end
		end
	end
	apcall(Init)
end

function CCharacterMediator:InitMoneyInfo(MoneyInfo)
	Gas2Gac:InitMoneyInfo(self.m_Conn,MoneyInfo(1,1),MoneyInfo(1,2),MoneyInfo(1,3))
end

function CCharacterMediator:InitItem(BagInfo,ItemInfo)
	local function Init()
		-- ������ҵĸ��ӱ�����Ϣ
		-- ������ҵ���Ʒ��Ϣ
		local Conn = self.m_Conn
		for n = 1, BagInfo:GetRowNum() do
			Gas2Gac:RetCharBagInfo(Conn,BagInfo(n,1),BagInfo(n,2),BagInfo(n,3),BagInfo(n,4),BagInfo(n,5),BagInfo(n,6))
		end
		apcall(CPutItemsToBag.RetInitBagItem,Conn,ItemInfo, self)		
		Gas2Gac:RetCharBagInfoEnd(Conn)
	end
	
	apcall(Init)
end

function CCharacterMediator:InitEquipToGac(EquipInfo)
	--�����ҵ�װ������Ϣ
	self.EquipType=""
	local uCharID = self.m_uID
	local AllInfo = EquipInfo["AllInfo"]
	local SuitInfoTbl = EquipInfo["SuitInfoTbl"]
	local WeaponEquip ,WeaponTbl,AssociateWeapon,AssociateWeaponTbl = 0,{},0,{}
	local equip_mgr = g_GetEquipMgr()
	local weaponCurDuraValue 
	local AssociaeWeaponCurDuraValue
	for y=1, table.maxn(AllInfo) do
		local Attr,uLower,uUpper = {},0,0
		local nBigID,nIndex,nItemID,eEquipPart,nBindingType,EquipRet = AllInfo[y]["nBigID"],AllInfo[y]["nIndex"],AllInfo[y]["nItemID"],AllInfo[y]["eEquipPart"],AllInfo[y]["nItemBindingType"],AllInfo[y]["EquipRet"]
		local EquipType = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipType")
		--����ʲôװ��,�����ڴ�����
		local equip = equip_mgr:GetEquipFromRet(nItemID,uCharID,nBigID,nIndex,EquipRet)
		equip:SendEquipInfoUsingConn(self.m_Conn)
		Gas2Gac:RetEquipInfo(self.m_Conn,nBigID,nIndex,nItemID,eEquipPart,nBindingType)
        local equipDuraState = AllInfo[y]["EquipRet"]["DuraState"]
	    local equipCurDuraValue = AllInfo[y]["EquipRet"]["CurDuraValue"]
	    local equipMaxDuraValue = AllInfo[y]["EquipRet"]["MaxDuraValue"]
		if eEquipPart == EEquipPart.eAssociateWeapon then
			AssociateWeapon = equip
			AssociateWeaponTbl = {nBigID,nIndex}
			AssociaeWeaponCurDuraValue = equipCurDuraValue
		elseif eEquipPart == EEquipPart.eWeapon then
			WeaponEquip = equip
			WeaponTbl = {nBigID,nIndex}
			self.EquipType=EquipType
			weaponCurDuraValue = equipCurDuraValue	
		end
		self:SetEquipIndexID(eEquipPart,nBigID,nIndex)
	    Gas2Gac:RetEquipDuraValue(self.m_Conn, nItemID, eEquipPart, equipDuraState, equipCurDuraValue, equipMaxDuraValue)
	end
    if WeaponEquip ~= nil and WeaponEquip ~= 0 then
	    if weaponCurDuraValue == 0  then
	        local CommonlySkillName  = g_GetPlayerClassNameByID(self.m_Class).. "��ͨ����"
            Gas2Gac:ReWeaponAttr(self.m_Conn,false,CommonlySkillName)	 
	    end
	end  
	
	if AssociateWeapon ~= nil and AssociateWeapon ~= 0 then
		if AssociaeWeaponCurDuraValue == 0 then
			Gas2Gac:ReAssociateAttr(self.m_Conn,false)
		else
			Gas2Gac:ReAssociateAttr(self.m_Conn,true)
		end
	end
	
    local jingLingSkillInfo = EquipInfo["JingLingSkillInfo"] 
	if jingLingSkillInfo ~= 0 then
		Gas2Gac:RetActiveJingLingSkill(self.m_Conn,jingLingSkillInfo)
	end
end


function CCharacterMediator:InitEquipToPlayer(EquipInfo)
	self.m_ErrorEquipTbl = {}
	--�����ҵ�װ������Ϣ
	self.EquipType=""
	local uCharID = self.m_uID
	local AllInfo = EquipInfo["AllInfo"]
	local SuitInfoTbl = EquipInfo["SuitInfoTbl"]
	local WeaponEquip ,WeaponTbl,AssociateWeapon,AssociateWeaponTbl = 0,{},0,{}
	local equip_mgr = g_GetEquipMgr()
	local WeaponEquipCurDuraValue
	local AssociaeWeaponCurDuraValue
	for y=1, table.maxn(AllInfo) do
		local Attr,uLower,uUpper = {},0,0
		local nBigID,nIndex,nItemID,eEquipPart,nBindingType,EquipRet = AllInfo[y]["nBigID"],AllInfo[y]["nIndex"],AllInfo[y]["nItemID"],AllInfo[y]["eEquipPart"],AllInfo[y]["nItemBindingType"],AllInfo[y]["EquipRet"]
		local EquipType = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipType")
		--����ʲôװ��,�����ڴ�����
		self:SetEquipInfo(nBigID,nIndex,nItemID,eEquipPart)
		local equip = equip_mgr:GetEquipFromRet(nItemID,uCharID,nBigID,nIndex,EquipRet)
		if eEquipPart == EEquipPart.eAssociateWeapon then
			AssociateWeapon = equip
			AssociateWeaponTbl = {nBigID,nIndex}
			AssociaeWeaponCurDuraValue = AllInfo[y]["EquipRet"]["CurDuraValue"]
		elseif eEquipPart == EEquipPart.eWeapon then
			WeaponEquip = equip
			WeaponTbl = {nBigID,nIndex}
			self.EquipType= EquipType	
			WeaponEquipCurDuraValue = AllInfo[y]["EquipRet"]["CurDuraValue"]
		end
		self:SetEquipIndexID(eEquipPart,nBigID,nIndex)
		if self.m_uLevel >= equip.BaseLevel then
			apcall(equip.EnablePropty,equip,self,eEquipPart,"CCharacterMediator:InitEquipToPlayer") 
		else
			self.m_ErrorEquipTbl[eEquipPart] = true
	    end
		self:SetPlayerEquipPhase(eEquipPart,equip.uIntensifyPhase, equip.CurAdvancePhase)
		if equip ~= nil and equip.uIntenTalentIndex and equip.uIntenTalentIndex > 0 then
            apcall(equip.SetIntensifyAddTalent, equip, self, equip.uIntenTalentIndex, equip.BaseLevel, true)
	    end
	end
	
	apcall(self.SetArmorValue, self)
	if not self.m_ErrorEquipTbl[EEquipPart.eWeapon] then
	    if WeaponEquip ~= nil and WeaponEquip ~= 0 then
		    if WeaponEquipCurDuraValue == 0  then
		        local CommonlySkillName  = g_GetPlayerClassNameByID(self.m_Class).. "��ͨ����"
	            self:CppInitMHNA(CommonlySkillName,"������","",2.0,false)
	        else
	            apcall(WeaponEquip.SetWeaponSkill, WeaponEquip, self,WeaponTbl[1],WeaponTbl[2],true)	 
		    end
		end
	end
	if not self.m_ErrorEquipTbl[EEquipPart.eAssociateWeapon] then
		if AssociateWeapon ~= nil and AssociateWeapon ~= 0 then
			if AssociaeWeaponCurDuraValue == 0 then
			    self:CppInitAHNA(nil,"������","",0,false)
			else
	    		local EquipType = g_ItemInfoMgr:GetItemInfo(AssociateWeaponTbl[1],AssociateWeaponTbl[2],"EquipType")
	    		if g_ItemInfoMgr:IsWeapon(AssociateWeaponTbl[1]) then
	    			apcall(AssociateWeapon.SetAssociateSkill, AssociateWeapon,self,AssociateWeaponTbl[1],AssociateWeaponTbl[2],true)
	    		elseif g_ItemInfoMgr:IsStaticShield(AssociateWeaponTbl[1])  then
	    			self:CppInitAHNA(nil,"������",EquipType,0,false)
	    		end
	        end
		end
	end
	
	local jingLingSkillInfo = EquipInfo["JingLingSkillInfo"] 
	apcall(equip_mgr.SetCharJingLingSkill, equip_mgr, self, true, jingLingSkillInfo, uCharID)
	apcall( equip_mgr.GetSuitAttributeByPlayerID, equip_mgr, self, SuitInfoTbl )
end

--ͬ��װ��Index
function CCharacterMediator:SetEquipIndexID(eEquipPart,BigId,Index)
	if eEquipPart == EEquipPart.eWeapon then
		self.m_Properties:SetWeaponIndexID(g_SParseWeaponTbl[Index])	
	elseif eEquipPart == EEquipPart.eAssociateWeapon then
		self.m_Properties:SetOffWeaponBigID(BigId)
		if g_ItemInfoMgr:IsStaticWeapon(BigId) then 
			self.m_Properties:SetOffWeaponIndexID(g_SParseWeaponTbl[Index])
		elseif g_ItemInfoMgr:IsStaticShield(BigId) then
			self.m_Properties:SetOffWeaponIndexID(g_SParseShieldTbl[Index])
		end
	elseif eEquipPart == EEquipPart.eWear then
		self.m_Properties:SetBodyIndexID(g_SParseArmorTbl[Index])
	elseif eEquipPart == EEquipPart.eHead then
		self.m_Properties:SetHeadIndexID(g_SParseArmorTbl[Index])
	elseif eEquipPart == EEquipPart.eShoulder then
		self.m_Properties:SetShoulderIndexID(g_SParseArmorTbl[Index])
	elseif eEquipPart == EEquipPart.eHand then
		self.m_Properties:SetArmIndexID(g_SParseArmorTbl[Index])
	elseif eEquipPart == EEquipPart.eBack then
		self.m_Properties:SetBackIndexID(g_SParseArmorTbl[Index])
	elseif eEquipPart == EEquipPart.eShoe then
		self.m_Properties:SetShoeIndexID(g_SParseArmorTbl[Index])	
	end	
end	
 	
--�ú�������û��ʵ�����壬Ϊװ������ǿ���ȼ���ʾ��Ч���ӿ���
function CCharacterMediator:SetPlayerEquipPhase(eEquipPart,nIntenPhase, nAdvancePhase)
    local fxPhase = GetEquipFxPhase(nAdvancePhase, nIntenPhase)
	if eEquipPart == EEquipPart.eWeapon then
		self.m_Properties:SetWeaponPhase(fxPhase)
	elseif eEquipPart == EEquipPart.eAssociateWeapon then
		self.m_Properties:SetOffWeaponPhase(fxPhase)
	elseif eEquipPart == EEquipPart.eWear then
		self.m_Properties:SetBodyPhase(fxPhase)
	elseif eEquipPart == EEquipPart.eHead then
		self.m_Properties:SetHeadPhase(fxPhase)
	elseif eEquipPart == EEquipPart.eShoulder then
		self.m_Properties:SetShoulderPhase(fxPhase)
	elseif eEquipPart == EEquipPart.eHand then
		self.m_Properties:SetArmPhase(fxPhase)
	elseif eEquipPart == EEquipPart.eShoe then
		self.m_Properties:SetShoePhase(fxPhase)
	end	
end

function CCharacterMediator:GetStateTbl(uGrade)
	local StateVec = {}
	local StoredObjVec = {}
	local stateDBData = self:SerializeStateToDB(uGrade)
	local aData = stateDBData:GetStateVec()
	local num = aData:GetCount()
	
	for i =1, num do
		local aState = aData:Get(i-1);
		local m_bIsDot = 0
		if aState:GetIsDot() then
			m_bIsDot = 1
		end
		local cs_bFromEqualsOwner = 0
		if aState:GetFromEqualsOwner() then
			cs_bFromEqualsOwner = 1
		end
		table.insert(StateVec,{aState:GetName(), aState:GetType(), aState:GetTime(), aState:GetRemainTime(), aState:GetCount(),aState:GetProbability(), aState:GetCancelableInstID(), aState:GetDotInstID(),
			aState:GetFinalInstID(), aState:GetSkillLevel(), aState:GetSkillName(), aState:GetAttackType(), m_bIsDot, cs_bFromEqualsOwner, ""} )
	end
	
	local aData = stateDBData:GetStoredObjVec()
	local num = aData:GetCount()
	for i =1, num do
		-- local aState = aData:Get(i-1);
		local aStoredObj = aData:Get(i-1)
		local nuss = aStoredObj:GetCascadeID()
		table.insert(StoredObjVec, {aStoredObj:GetInstID(), aStoredObj:GetCascadeID(), aStoredObj:GetMOPID(), aStoredObj:GetMOPArg(), aStoredObj:GetMOPRet(), ""})
	end
	self:SaveStateToDBEnd()
	return StateVec,StoredObjVec
end

local function LoadStateFromDB(Character, MagicState, MagicStoreObj, bIsPlayer, ServantID)
	--ħ��״̬��ȡ,  �Ȱ����е�״̬��Ϣ��DB����������Table��
	local stateDBDataSet = CStateDBDataSet:new()
	local aStateVec = stateDBDataSet:GetStateVec()
	for i=1, MagicState:GetRowNum() do
		local bServnatStateData = false
		if not bIsPlayer and (Character.m_Properties:GetCharName() == MagicState(i,15)) and 
			(ServantID == MagicState(i,16)) then
			bServnatStateData = true
		end
		
		if ((bIsPlayer and MagicState(i,15) == "")) or bServnatStateData then
			local stateDBData = aStateVec:CreateDBData()
			local uIsDot = false
			local cs_bFromEqualsOwner = false
			if MagicState(i,13) == 1 then
				uIsDot = true
			end
			if MagicState(i,14) == 1 then
				cs_bFromEqualsOwner = true
			end
			stateDBData:SetName(MagicState(i,1))
			stateDBData:SetType(MagicState(i,2))
			stateDBData:SetTime(MagicState(i,3))
			stateDBData:SetRemainTime(MagicState(i,4))
			stateDBData:SetCount(MagicState(i,5))
			stateDBData:SetProbability(MagicState(i,6))
			stateDBData:SetCancelableInstID(MagicState(i,7))
			stateDBData:SetDotInstID(MagicState(i,8))
			stateDBData:SetFinalInstID(MagicState(i,9))
			stateDBData:SetSkillLevel(MagicState(i,10))
			stateDBData:SetSkillName(MagicState(i,11))
			stateDBData:SetAttackType(MagicState(i,12))
			stateDBData:SetIsDot(uIsDot)
			stateDBData:SetFromEqualsOwner(cs_bFromEqualsOwner)
			aStateVec:PushBack(stateDBData)
		end
	end
	
	local storedObjDBDataVec = stateDBDataSet:GetStoredObjVec()
	for i=1, MagicStoreObj:GetRowNum() do
		local bServantStoredObj = false
		if not bIsPlayer and (Character.m_Properties:GetCharName() == MagicStoreObj(i,6)) and 
			(ServantID == MagicStoreObj(i,7)) then
			bServantStoredObj = true
		end
		
		if (bIsPlayer and MagicStoreObj(i,6) == "") or bServantStoredObj then
			local storedObjDBData = storedObjDBDataVec:CreateDBData()
			storedObjDBData:SetInstID(MagicStoreObj(i,1))
			storedObjDBData:SetCascadeID(MagicStoreObj(i,2))
			storedObjDBData:SetMOPID( MagicStoreObj(i,3))
			storedObjDBData:SetMOPArg(MagicStoreObj(i,4))
			storedObjDBData:SetMOPRet(MagicStoreObj(i,5))
			storedObjDBDataVec:PushBack(storedObjDBData)
		end
	end
	local succ = Character:LoadStateFromDB(stateDBDataSet)
	stateDBDataSet:Release()
end

function CCharacterMediator:ReadStateFromDB(MagicState, MagicStoreObj)
	apcall(LoadStateFromDB,self, MagicState, MagicStoreObj, true)
end

function CCharacterMediator:GetServantData(Servant, servantID)
	if not servantID then
		servantID = 0
	end
	local BaseTbl = {} -- Name,Level,AIType,NpcType,hp,mp
	local StateVec = {}
	local StoredObjVec = {}
	
	local LeftTime = Servant:GetNpcLeftLifeTime()
	if LeftTime ~= 0 then  --������ʱ���npc�Ѿ����������ڣ���Ϊ����ԭ��û����ʧ������Ҫ�����ݿ�
		if LeftTime == -1 then
			LeftTime = 0
		end
		local ServantName = Servant.m_Properties:GetCharName()
		BaseTbl = {
						ServantName,
						Servant:CppGetLevel(),
						Servant:GetAITypeID(),
						Servant:GetNpcType(),
						Servant:CppGetHP(),
						Servant:CppGetMP(),
						LeftTime,
						servantID
				}
		local stateDBData = Servant:SerializeStateToDB(1)
		local aData = stateDBData:GetStateVec()
		local num = aData:GetCount()
				
		for i =1, num do
			local aState = aData:Get(i-1);
			local m_bIsDot = 0
			if aState:GetIsDot() then
				m_bIsDot = 1
			end
			local cs_bFromEqualsOwner = 0
			if aState:GetFromEqualsOwner() then
				cs_bFromEqualsOwner = 1
			end
			table.insert(StateVec,{aState:GetName(), aState:GetType(), aState:GetTime(), aState:GetRemainTime(), aState:GetCount(),aState:GetProbability(), aState:GetCancelableInstID(), aState:GetDotInstID(),
				aState:GetFinalInstID(), aState:GetSkillLevel(), aState:GetSkillName(), aState:GetAttackType(), m_bIsDot, cs_bFromEqualsOwner, ServantName, servantID} )
		end
				
		local aData = stateDBData:GetStoredObjVec()
		local num = aData:GetCount()
		for i =1, num do
			local aStoredObj = aData:Get(i-1)
			local nuss = aStoredObj:GetCascadeID()
			table.insert(StoredObjVec, {aStoredObj:GetInstID(), aStoredObj:GetCascadeID(), aStoredObj:GetMOPID(), aStoredObj:GetMOPArg(), aStoredObj:GetMOPRet(), ServantName, servantID})
		end
		Servant:SaveStateToDBEnd()
	else
		return nil
	end
	return {BaseTbl,StateVec,StoredObjVec}
end

function CCharacterMediator:GetServantDataTbl()
	local ServantDataTbl = {}
	local pServantQueryCallback = CServantQueryCallback:new()
	local ServantTbl = pServantQueryCallback:QueryServant(self)

	local servantID = 0
	for p , v in pairs (ServantTbl) do
		local Servant = v
		--Ŀǰֻ�洢ֻ�ܴ�һ����Npc
		if IsServerObjValid(Servant) and NpcInfoMgr_CanTakeOnlyOne(Servant:GetNpcType()) then
			servantID = servantID + 1
			local DataTbl = self:GetServantData(Servant, servantID)
			if DataTbl ~= nil then
				table.insert(ServantDataTbl, {servantID,DataTbl} )
			end
		end
	end
	return ServantDataTbl
end

function CCharacterMediator:LoadServantFromDB(ServantData, bChangeScene)
	local ServantBaseData = ServantData[1]
	local StateData				= ServantData[2]
	local StateStoreObjData = ServantData[3]
	local uCount = ServantBaseData:GetRowNum()
	if uCount == 0 then
		return
	end
	for num=1, uCount do
		local ServantRealName = ""
		local ServantName = ServantBaseData(num,1)
		local ServantID = ServantBaseData(num,8)
		if self.m_ServantNameInfo ~= nil then
			for i=1, #(self.m_ServantNameInfo) do
				if self.m_ServantNameInfo[i][1] == ServantName then
					ServantRealName = self.m_ServantNameInfo[i][2]
				end
			end
		end
		
		--�ϰ����
		local posSelf = CFPos:new()
		local posT = CFPos:new()
		local Dir = CDir:new()
		local vector2Dir = CVector2f:new()
		self:GetPixelPos(posSelf);
		local uAngle = self:GetActionDir();
		Dir:SetDir(uAngle)
		Dir:Get(vector2Dir)
		posT.x = vector2Dir.x * 3 * EUnits.eGridSpanForObj + posSelf.x;
		posT.y = vector2Dir.y * 3 * EUnits.eGridSpanForObj + posSelf.y;
		
		local pScene = self:GetScene()
		if pScene then
			local pPath = self:GetScene():CreatePath(posSelf, posT, eFPT_HypoLine, eBT_LowBarrier);
			if (pPath == nil and posSelf ~= posT) then
				posT = posSelf
			end
			if pPath ~= nil then
				pPath:Release()
				pPath = nil
			end
		else
			return
		end
		
		local otherData = {
		["m_CreatorEntityID"]		=self:GetEntityID(),
		["m_OwnerId"] = self.m_uID,
		["m_bChangeSceneCreate"]=bChangeScene
		}
		local AIType = NpcInfoMgr_GetAINameByAIType(ServantBaseData(num,3))
		local NpcTypeName = NpcInfoMgr_GetTypeNameByType(ServantBaseData(num,4))
		local ServantLevel = ServantBaseData(num,2)
		if ServantLevel == 0 then
			ServantLevel = self:CppGetLevel()
		end
		local IsBattleHorse = false
		if NpcInfoMgr_GetTypeByTypeName(NpcTypeName) == ENpcType.ENpcType_BattleHorse then
			IsBattleHorse = true
		end
		self.bLoadServant = true
		local Servant = g_NpcServerMgr:CreateServerNpc(ServantName, ServantLevel,self.m_Scene, posT, otherData, self:GetEntityID(), AIType, NpcTypeName, ServantRealName, IsBattleHorse)
		self.bLoadServant = false
		if not IsServerObjValid(Servant) then
			return
		end
		g_NpcServerMgr:SkillCreateNpcEnd(Servant)
		apcall(LoadStateFromDB, Servant, StateData, StateStoreObjData, false, ServantID)
		Servant:CppSetHP(ServantBaseData(num,5)) --HPѪ��
		if ServantBaseData(num,7) ~= 0 then
			Servant:ReSetNpcExistTick(ServantBaseData(num,7)) --ExistTime
		end
		if Servant:GetNpcType() == ENpcType.ENpcType_Truck then
			PlayerLoadTruckInfo(self, Servant)
		end
	end
end

--2009-7-18 15:44:01
--��ʼ����������״̬
local function SetHideQuestSign(Conn, PlayerID)
	for HideQuestName , v in pairs (g_HideQuestMgr) do
		if v[PlayerID] == true then
			Gas2Gac:SendHideQuestSign(Conn, HideQuestName)
		end
	end
end

local function InitMercCardInfo(Conn, Player, MercCardInfo)
	if IsTable(MercCardInfo) then
		Player["m_MercCardInfo"] = {}
		Gas2Gac:InitMercCard(Conn)
		for i, v in pairs(MercCardInfo) do 
			Gas2Gac:RecordMercCard(Conn,i)
			table.insert(Player["m_MercCardInfo"], i)
		end
	end
end

local function InitDirectInfo(Conn, Player, DirectInfo, DirectAwardInfo)
	Gas2Gac:ShowNewDirectBegin(Conn)
	SendPlayerFinishDirect(Player, DirectInfo)
	Gas2Gac:ShowNewDirectEnd(Conn)
	for i , v in pairs(DirectAwardInfo) do
		if DirectInfo_Common(i) then
			Gas2Gac:UpdateDirectAwardInfo(Conn, i)
		end
	end
end	

local function SendActionCount(Conn, Player, ActivityCountTbl)
	if Player:CppGetLevel() >= 15 then
		for ActionName, CountsTbl in pairs(ActivityCountTbl) do
			Gas2Gac:SetActionCount(Conn, ActionName, CountsTbl[1], CountsTbl[2])
		end
		-- ���������л�����󣬴򿪴���
		local nowtime = os.time()
		local nowdate = os.date("*t")
		local nowhour = nowdate.hour	
		local nowmin = nowdate.min	
		Gas2Gac:RetShowActionInfoWnd(Conn, nowhour, nowmin)
	end
end

function CCharacterMediator:ReSendDataToConn(CharInfo, FightSkill, MagicState, MagicStoreObj,TeamID,TongID)
	local uCharID = self.m_uID
	-- self:ReSendToSelf()

	self:RemoteInit()
	self:ReSendSpeedToSelf()

	self:ReSendAllFightSkill(FightSkill)

	if self.m_uLevel > LevelExp_Common.GetHeight() then
		ExpOfCurLevelUp=0
		self.m_uLevelExp=0
	else
		ExpOfCurLevelUp=LevelExp_Common(self.m_uLevel, "ExpOfCurLevelUp")
	end
	--ͬ���߼���Ϣ���ͻ��˵�Director����
	Gas2Gac:InitMainPlayer( self.m_Conn,
	self.m_uLevelExp,
	ExpOfCurLevelUp,
	self.m_Scene.m_SceneName,
	self.m_Scene.m_SceneAttr.SceneType
	)
end



local function InitAllInlayStone(Player, AllInlayedHolesInfo, nowpanel)
	CStoneMgr.GetStoneMgr():InitAllInlayStone(Player, AllInlayedHolesInfo, nowpanel)
end

local function LoginInitStone(Player, OpenedHolesList, AllInlayedHolesInfo, nowpanel)
	CStoneMgr.GetStoneMgr():LoginInitStone(Player, OpenedHolesList, AllInlayedHolesInfo, nowpanel)
end

local function GiveRecruitAward(Player, camp, recruitFlag)
	local buffName = nil
	
	if recruitFlag and recruitFlag ~= 0 then
		if camp == 1 then
			skillName = RecruitAward_Common(recruitFlag, "SkillNameCamp1") 
			buffName = RecruitAward_Common(recruitFlag, "BuffNameCamp1") 
		elseif camp == 2 then
			skillName = RecruitAward_Common(recruitFlag, "SkillNameCamp2") 
			buffName = RecruitAward_Common(recruitFlag, "BuffNameCamp2") 
		else
			skillName = RecruitAward_Common(recruitFlag, "SkillNameCamp3") 
			buffName = RecruitAward_Common(recruitFlag, "BuffNameCamp3") 
		end
		if not Player:ExistState(buffName) then
			Player:PlayerDoItemSkill(skillName, 1)
		end
	end
end

local function InitCreatePlayerInfo(Connection, Player, uCharID, ChangeType, result , lastMsgIdStr, isResume)
	SaveCharLoginFuncFlow(uCharID,"InitCreatePlayerInfo_begin")
	local CharInfo 			= result["CharInfo"]
	local BagInfo			= result["BagInfo"]
	local MoneyInfo 	= result["MoneyInfo"]
	local ItemInfo			= result["ItemInfo"]
	local EquipInfo             	= result["EquipInfo"]
	local StoneHoleInfo 	= result["StoneHoleInfo"]
	local StoneInlayedInfo= result["StoneInlayedInfo"]
	local now_panel 			= result["now_panel"]
	local CommonlyFightSkill	= result["CommonlyFightSkill"]
	local FightSkill			= result["FightSkill"]
	local ShortcutInfo		= result["ShortcutInfo"]
	local UISettingInfo		= result["UISettingInfo"]
	local ServantNameInfo	= result["ServantNameInfo"]
	local SkillCoolDownTime	= result["skillCoolDownData"]
	local AureMagic		= result["AureMagicData"]
	local StateData		= result["StateData"]
	local StateStoreObjData		= result["StateStoreObjData"]
	local ServantData		= result["ServantData"]
	local AllPanel			= result["AllPanel"]
	local AllChanelPanelInfo	= result["AllChanelPanelInfo"]
	local TeamID			= result["TeamID"]
	local TongID			= result["TongID"]
	local TongName		= result["TongName"]
	local TongPos		= result["TongPos"]
	local TongType 		= result["TongType"]
	local battletbl 			= result["battletbl"]
	local AssociationInfo	= result["AssociationInfo"]
	local playersoul 		= result["playersoul"]
	local playe_point 		= result["playe_point"]
	local SysteMsgTbl 		= result["SysteMsgTbl"]
	local FirstTimeInfo 		= result["FirstTimeInfo"]
	local AcceleratorKeyTbl 	= result["AcceleratorKeyTbl"]
	local playerAppellationInfo = result["playerAppellationInfo"]
	local AllAppellationInfo = result["AllAppellationInfo"]
	local MercCardInfo = result["MercCardInfo"]
	local DirectInfo = result["DirectInfo"]
	local DirectAwardInfo = result["DirectAwardInfo"]
	local LiveskillInfo = result["LiveskillHavingLearn"]
	local BurstSoulTime = result["BurstSoulTime"]
	local ItemCoolDownInfo = result["SpecialItemCoolDown"]
	local FlowerInfo		= result["FlowerInfo"]
	local ActivityCountTbl = result["ActivityCountTbl"]
	local IsRevise					= result["IsRevise"]
	local ArmyCorpsID				= result["ArmyCorpsID"]
	local ArmyCorpsName			= result["ArmyCorpsName"]
	local ArmyCorpsPos			= result["ArmyCorpsPos"]
	local QusetSortSetting  = result["QusetSortSetting"]
	local RecruitFlag = result["recruitFlag"]
	local CreateTime = result["createTime"]
	--local MLRes = result["MLRes"]
	--local MLAwards = result["MLAwards"]
	
	----------------------------- ͨ������(����)����Character ----------------------------------
	
	
	Connection.m_LogoutSetting = "Delay"
	----------------------
	--��ʼ��������������
	local SceneInfo = result["MainSceneInfo"]
	local scenepos = CFPos:new()
	scenepos.x = SceneInfo[4]
	scenepos.y = SceneInfo[5]
	
	Player.m_MasterSceneName = SceneInfo[2]
	Player.m_MasterScenePos = scenepos
	--------------------------------
	Player.m_AccountID = Connection.m_Account:GetID()

	Player.m_Scene.m_tbl_Player[uCharID] = Player
	assert(Connection.m_Player == nil)
	
	apcall(Player.SetConnection,Player,Connection)
	
	Player.m_Conn = Connection
	Player.m_Conn.m_Account.m_bDBTransBlock = false
	Player.m_uID = uCharID	
	Player.m_Class = CharInfo(1,8)
	Player.m_Camp = CharInfo(1,9)
	Player.m_uLevel = CharInfo(1,10)
	Player.m_uSoulValue = playersoul
	Player.m_uKillDropSoulCount = 0
	Player.m_KillNpcExp = 0
	Player.m_uArmyCorpsID = ArmyCorpsID
	----------------------------- ����MessageRouter�����,�������ȵ��� ����� Gas2Gac �����ڴ˺���֮ǰ�ᵼ��ʱ������
	apcall(PlayerLoginGetMessage,Player , ChangeType, lastMsgIdStr)
		
	
	Player.m_KillNpcCount = result["killNpcCount"] or 0  --ɱ���޵ĸ���
	Player.m_KillPlayerCount = result["killPlayerCount"] or 0  --ɱ��ҵĸ���
	Player.m_uFightingTotalPoint = result["uTotalPoint"] or 0 --���߳�ʼ��ս��������
--/**��PK����**/	
--	Player.m_KillMinusPkValueCount = 0
	Player.m_PlayerOnTimeBegin = result["lastServerTime"] or os.time() --��ɫ��¼ʱ��
	Player.m_RebornCountTime = 0
	
	Player.m_ServantNameInfo = {}
	for i = 1, ServantNameInfo:GetRowNum() do
		table.insert(Player.m_ServantNameInfo,{ServantNameInfo(i,1),ServantNameInfo(i,2)})
	end
	
	Player.m_FirstTimeInfo = FirstTimeInfo	--��ҵ�һ�������ĳ������
	--֪ͨ�ͻ���,�Ѿ��Ǽǹ�
	if Player:IsFirstTime("�Ǽ�Ӷ��") then--�жϵǼ�
		Gas2Gac:RetCheckInMercenaryInfo(Connection)
	end
--	Player.m_SwitchState = false
	if not IsRevise then
		if CharInfo(1,15) == 0 then
			Player.m_SwitchState = false
		else	
			Player.m_SwitchState = true
		end
	else
		Player.m_SwitchState = result["PkSwitch"]
	end
	 
--	Player.m_SwitchState = 
--		--/**PK����**/
--	print("Prpts", Player.m_PkValue)
--	Player.m_SwitchState = false
--/**��PK����**/
--	Player.m_CriminalTime = CharInfo[18]
--	if CharInfo[19] > 0 then			--PK�ͷ�ʱ��
--		apcall(Player.PkCriminalTick,Player)
--	end

	----------------------------- ��ʼ����������  ----------------------------------
	apcall(Player.CppSetBirthCamp,Player,CharInfo(1,9))
	
	if not isResume then
		apcall(Player.InitBaseProperty,Player,CharInfo, FightSkill,TeamID,TongID,TongName,playerAppellationInfo, playe_point[7],ArmyCorpsName)
	else
		apcall(Player.ResumeBaseProperty,Player,FightSkill)
	end
	apcall(Player.InitMoneyInfo,Player,MoneyInfo)
	apcall(Player.InitQuestItemCDTime,Player,ItemCoolDownInfo, IsRevise)

	if ChangeType == 0 then
		apcall(Player.InitItem,Player,BagInfo, ItemInfo)
		apcall(Player.GetAllPanel,Player,Player,AllPanel)
		apcall(Player.GetAllChanelPanelInfo,Player,Player,AllChanelPanelInfo)	
		apcall(Player.SaveFightingEvaluationInfo,Player,Player)
		apcall(Player.ReturnCharAllAppellationInfo,Player,AllAppellationInfo,Connection)
		apcall(LoginInitStone,Player,StoneHoleInfo, StoneInlayedInfo, now_panel)
		apcall(Player.InitAllKeyMaps,Player,AcceleratorKeyTbl)
		apcall(Player.InitTongInfo,Player,TongPos,TongType,Connection)
		apcall(Player.InitArmyCorpsInfo,Player,ArmyCorpsPos,Connection)
		apcall(Player.ReturnSaveChatInWorldShow,Player,result["IsShowChatWnd"],Connection)
		apcall(Player.ReturnSaveChatInCHItemShow,Player,result["IsShowCHItemChatWnd"],Connection)
		apcall(Player.ReturnSaveChatInCHMoneyShow,Player,result["IsShowCHMoneyChatWnd"],Connection)
		
		Gas2Gac:ReturnGetUISetting(Connection, unpack(UISettingInfo))
		-- ��ʼ�� ����ϵͳ
		apcall(InitDirectInfo, Connection, Player, DirectInfo, DirectAwardInfo)
		local NpcShopBuyTipInfo = result["NpcShopBuyTipInfo"]
		apcall(Player.ReturnNpcShopBuyTipInfo,Player,NpcShopBuyTipInfo,Connection)
	else
		Player.tbl_HighStoneID = result["tbl_HighStoneID"]
	end
	apcall(Player.ReturnEquipEffectInfo,Player,Player,result["EquipEffectInfo"],Connection)
	apcall(Player.InitEnabledSoulBottleInfo,Player,result["ActivationBottle"])
	Player:InitPlayerAoi()
	apcall(Player.ReturnVipEffectInfo,Player,Player,result["VipEffectInfo"])
	if not isResume then
	    Player.m_EquipAttrTransIDTbl = {}
		apcall(Player.InitEquipToPlayer,Player,EquipInfo)
		apcall(Player.InitEquipToGac,Player,EquipInfo)

		local uEntityID = Player:GetEntityID()
		Gas2Gac:UpdateModel( Connection ,uEntityID)
		Gas2Gac:UpdateCoreInfo(Connection,uEntityID)
		Gas2Gac:UpdateModel( Player:GetIS(0) ,uEntityID)

		apcall(Player.ReadStateFromDB,Player,StateData, StateStoreObjData)
		apcall(InitAllInlayStone,Player,StoneInlayedInfo, now_panel)
		apcall(Player.CppInitHPMP,Player,CharInfo(1,13),CharInfo(1,14))
	else
		apcall(Player.InitEquipToGac,Player,EquipInfo)

		local uEntityID = Player:GetEntityID()
		Gas2Gac:UpdateModel( Connection ,uEntityID)
		Gas2Gac:UpdateCoreInfo(Connection,uEntityID)
		Gas2Gac:UpdateModel( Player:GetIS(0) ,uEntityID)
		
	end
	
	apcall(Player.Lua_LoadCommonlyFightSkill,Player,CommonlyFightSkill)
	apcall(Player.InitSkillCoolDownTime,Player,SkillCoolDownTime)
	--apcall(Player.LoadBattleInfo,Player,Connection,battletbl,uCharID)
--/**��PK����**/
--	Player:SetZoneType(Player.m_Scene.m_SceneAttr.PkType)

	if not isResume then
		apcall(Player.InitAureMagic,Player,AureMagic,ChangeType)
		apcall(Player.LoadServantFromDB,Player,ServantData,ChangeType ~= 0)
	end
	------�����������Ϣ------
	apcall(Player.GetShortInfoByRet,Player,ShortcutInfo)
	
	Player.m_uMercenaryLevel = CharInfo(1,16)
	Player.m_uMercenaryIntegral = CharInfo(1,17) 
	Gas2Gac:RetSetMercenaryLevel(Connection, Player.m_uMercenaryLevel, false)
	Gas2Gac:RetSetMercenaryIntegral(Connection, Player.m_uMercenaryIntegral )
	Gas2Gac:ReturnPlayerAppellationInfo(Connection)
	local Scene = Player.m_Scene
	local sceneType = Scene.m_SceneAttr.SceneType
	--���ô��̶�ʱ����Ϊ�˲��Է��㣬���ڵ���Ϊ3�뱣��һ�Σ�ʵ���ϱ�����Ӧ�ø���
	if sceneType == 1 or sceneType == 7 then   --����
		Player.m_SavePosTick = RegClassTick( "Player.m_SavePosTick", Player.OnSaveTick, SavePosTickTime*1000, self, Player )
	--elseif Scene.m_SceneAttr.SceneType >= 2 then  --����
	--	if Scene.m_SceneAttr.SceneType ~= 5 then
	--		Player.m_SaveFbPosTick = RegClassTick( "Player.m_SaveFbPosTick", Player.OnSaveFbTick, SavePosTickTime*1000, self, Player )
	--	end
	end
	
	Player.m_SaveFightPropertyTick = RegClassTick( "Player.m_SaveFightPropertyTick", Player.OnSaveFightPropertyTick, SaveFightPropertyTickTime*1000,self,Player)
	Player.m_SavePlayerSoulTick = RegClassTick( "Player.m_SavePlayerSoulTick", Player.OnSavePlayerSoulTickFunc, SavePlayerSoulTickTime*1000,self,Player)
	Player.m_SavePlayerFightingPointTick = RegClassTick( "Player.m_SavePlayerFightingPointTick", Player.OnSaveFightingPointTickFunc, SaveFightingPointTickTime*1000,self,Player)
	
	------������Ⱥ-------
	apcall(Player.InitAssociationInfo,Player,Connection, uCharID, ChangeType, AssociationInfo)
	
	apcall(Player.IsFirstTimeLoginAndSendMsg,Player,"�½����", 4004)

	--��¼���ͽ�ɫ���ϵĻ�ֵ
	apcall(Player.NotifyPlayerSoulNum,Player,playersoul,Connection)
	apcall(Player.ReturnLiveskillInfo,Player,LiveskillInfo,Connection)

	Player.m_LockingObj = nil
	Player.m_LockingIntObj = nil
--	local uEntityID = Player:GetEntityID()
--	Gas2Gac:UpdateModel( Connection ,uEntityID)
--	Gas2Gac:UpdateCoreInfo(Connection,uEntityID)
--	Gas2Gac:UpdateModel( Player:GetIS(0) ,uEntityID)
	--���߷���������ϵĻ���                        
	apcall(Player.ReturnPlayerPoint,Player,playe_point,Connection)
	if CreateTime and os.time() - CreateTime <= 7 * 24 * 60 * 60 then
		GiveRecruitAward(Player, Player.m_Camp, RecruitFlag)
	end
	if not isResume then
		apcall(Player.InitBurstSoulTime,Player,BurstSoulTime)
	end
	--Player:AddEquipSuiteEff("��װ���������˺�", 2)
	-- ������������״̬
	apcall(SetHideQuestSign, Connection, Player.m_uID)
	-- ��ʼ�� ActionState
	if CharInfo(1,13) == 0 and (Scene.m_SceneAttr.RebornType == 8 or Scene.m_SceneAttr.RebornType == 13) then
		apcall(Player.CppInitByDead,Player)
		local DeadTimes = 0
		if Scene.m_MatchGameDeadTimes and Scene.m_MatchGameDeadTimes[Player.m_uID] then
			DeadTimes = Scene.m_MatchGameDeadTimes[Player.m_uID]
		end
		Gas2Gac:OnShowDeadMsgBox(Player.m_Conn, Scene.m_SceneAttr.RebornType, 0, DeadTimes)
	else
		apcall(Player.SetAndSyncActionState,Player, EActionState.eAS_Idle_BackWpn)
	end
	--return Player
	Player.UseItemParam = {}			--���ʹ����Ʒ��
	apcall(CFlower.ResumeCultivateFlower, Connection, Player, FlowerInfo)
	--�������׷����������ʽ
	if QusetSortSetting then
		Gas2Gac:RetQuestSortSettingInfo(Connection, QusetSortSetting)
	end
	--��ʼ��Ӷ���ȼ���������Ϣ
	--CMercenaryLevel.InitMercenaryLevelTraceWnd(Connection, MLRes, MLAwards)
	--Boss����ս����ʱ���
	--InitBossBattleWnd()
	--���������һ�ΰ����е�ѡ��֧����ʽ�����ð����ڵĽ�Ǯѡ����ʾ
	Gas2Gac:SetMoneyTypeBtnCheck(Connection, CharInfo(1,11))
	if g_NeedAssignTbls[Player.m_uID] then
		for ObjID, v in pairs(g_NeedAssignTbls[Player.m_uID]) do 
			local IntObj = CIntObjServer_GetIntObjServerByID(ObjID)
			if IntObj ~= nil then
				local param = IntObj.m_AddItemData
				Gas2Gac:ShowNeedAssignWnd(Player.m_Conn, param["nType"], param["sName"], 1, g_CurServerId, ObjID, Player.m_Class, IntObj.m_CountTime) --�����������
			end
		end
	end
	if g_AcutionAssignTbls[Player.m_uID] then
		for ObjID, v in pairs(g_AcutionAssignTbls[Player.m_uID]) do 
			local IntObj = CIntObjServer_GetIntObjServerByID(ObjID)
			if IntObj ~= nil then
				local param = IntObj.m_AddItemData
				Gas2Gac:ShowAcutionAssignWnd(Player.m_Conn, param["nType"], param["sName"], 1, g_CurServerId, ObjID, IntObj.m_CountTime)
			end
		end
	end

	-- ��ʼ�� ������������
	apcall(InitMercCardInfo, Connection, Player, MercCardInfo)
	-- ��¼�󵯳����ʾ���
	if ChangeType == 0 then
		apcall(SendActionCount, Connection, Player, ActivityCountTbl)
	end
	--��ҽ��볡��,д��log��Ϣ
	apcall(Player.ChangeSceneWriteDBLog, Player)
	apcall(Player.InitItemBagLock,Player,Player, result["ItemLockTime"])
	SaveCharLoginFuncFlow(uCharID,"InitCreatePlayerInfo_end")
end

local function InitCreatePlayer(Connection, Player, uCharID, ChangeType, result , lastMsgIdStr, isResume)
	SaveCharLoginFuncFlow(uCharID,"InitCreatePlayer_begin")
	apcall(InitCreatePlayerInfo,Connection, Player, uCharID, ChangeType, result , lastMsgIdStr, isResume)
	Connection.m_Player = Player
	Gas2Gac:CreatePlayerEnded( Connection, Player.m_Properties:GetCharName(), ChangeType )
	SaveCharLoginFuncFlow(uCharID,"InitCreatePlayer_end")
end


function CCharacterMediator:InitAllKeyMaps(result)
	apcall(CKeyMapMgr.InitAllKeyMaps,self,result)
end

function CCharacterMediator:InitEnabledSoulBottleInfo(result)
	if result:GetRowNum() > 0 then
		self.m_SoulBottleInfo = {result(1,1),result(1,2)}
		self.m_SoulBottleValue = result(1,3)
	end
end

function CCharacterMediator:ReUsePlayer(Connection, Player, result, lastMsgIdStr)
	apcall(Player.UnRegisterPlayerTick,Player)
	apcall(Player.OnSaveFightPropertyTick,Player,nil, Player)
	apcall(Player.OnSavePlayerSoulTickFunc,Player,nil, Player)
	apcall(Player.OnSaveFightingPointTickFunc,Player,nil, Player)
	apcall(Player.VIPEffectFunc,Player,nil, Player)
	apcall(OnSavePlayerExpFunc,{Player})
	--������Ŷ������͸ɵ�
	apcall(Player.ClearPlayerActionState,Player)
	apcall(InitCreatePlayer,Connection, Player, Player.m_uID, 0, result, lastMsgIdStr, true)
	--������Ǹ���������,�������ָ����
	if not Player:CppIsLive() then
		apcall(Player.CppInitByDead,Player)
		apcall(Player.DeadToClientMsg,Player)
	end
	
	apcall(Player.m_Scene.OnPlayerLogIn,Player.m_Scene,Player)
end

function CCharacterMediator:Create( Connection, uCharID, ChangeType, result, sceneInfo, lastMsgIdStr)
	SaveCharLoginFuncFlow(uCharID,"CCharacterMediator:Create")
	----------------------------- ͨ������(����)����Character ----------------------------------
	local Scene = g_SceneMgr:GetScene(sceneInfo[1])
	assert(Scene ,"��ҵ�¼����������!! ��� GetPlayerLoginInfo ���߼�")
	
	local PixelFPos = CFPos:new()
	PixelFPos.x = sceneInfo[4] * EUnits.eGridSpanForObj
	PixelFPos.y = sceneInfo[5] * EUnits.eGridSpanForObj
	if not Scene.m_CoreScene:IsPixelValid(PixelFPos) then 
		local info = RebornPos_Common(Scene.m_LogicSceneName, tostring(result["CharInfo"](1,9)))
		if info then
			local Keys = info:GetKeys()
			for _,p in pairs(Keys) do
				if info(p, "PosX") ~= 0 and info(p, "PosY") ~= 0 then
					PixelFPos.x = info(p, "PosX") * EUnits.eGridSpanForObj
					PixelFPos.y = info(p, "PosY") * EUnits.eGridSpanForObj
				end
			end
		end
	end
	local Player = CEntityServerCreator_CreateCharacterMediator( Scene.m_CoreScene, PixelFPos, "Player" )
	apcall(RegOnceTickLifecycleObj,"Player",Player)
	Player.m_CallbackHandler = CCharacterMediatorCallbackHandler:new()
	
	apcall(Player.SetCallbackHandler,Player,Player.m_CallbackHandler)
	
	Player.m_Scene = Scene
	
	apcall(InitCreatePlayer,Connection, Player, uCharID, ChangeType, result, lastMsgIdStr, false)

	Gas2Gac:InitPkSwitch(Connection, Player.m_SwitchState)
end



local function ClearInTrapPlayer( Player)
	local function Init()
		for TrapName, IDTbl in pairs( Player.m_Properties.m_InTrapTblName) do
			for _, TrapID in pairs(IDTbl) do 
				local Trap = CIntObjServer_GetIntObjServerByID(TrapID)
				if Trap then
					local TrapCharIDTbl = Trap.m_OnTrapCharIDTbl
					if TrapCharIDTbl[Player:GetEntityID()] then
						TrapCharIDTbl[Player:GetEntityID()] = nil
					end
				end
			end
		end
	end
	apcall(Init)
end

function CCharacterMediator:UnRegisterPlayerTick()
	UnRegisterObjOnceTick(self)
	if self.m_SavePosTick then   --����
		UnRegisterTick( self.m_SavePosTick )
		self.m_SavePosTick = nil
	end
	if self.m_SaveFbPosTick then  --��������
		UnRegisterTick( self.m_SaveFbPosTick )
		self.m_SaveFbPosTick = nil
	end
	--���̲���
	if self.m_SaveFightPropertyTick then
		UnRegisterTick( self.m_SaveFightPropertyTick )
		self.m_SaveFightPropertyTick = nil
	end
	if self.m_SavePlayerSoulTick then
		UnRegisterTick( self.m_SavePlayerSoulTick )
		self.m_SavePlayerSoulTick = nil
	end
	if self.m_SavePlayerFightingPointTick then
		UnRegisterTick( self.m_SavePlayerFightingPointTick )
		self.m_SavePlayerFightingPointTick = nil
	end
	if self.m_UseItemLoadingTick then
		UnRegisterTick( self.m_UseItemLoadingTick )
		--EndServerProgress(self)
		EndUseItemProgress(self)
	end
	if self.m_ActionLoadingTick then
		UnRegisterTick( self.m_ActionLoadingTick )
		EndServerProgress(self)
		--EndUseItemProgress(self)
	end
	if self.m_CollectResTick then
		UnRegisterTick( self.m_CollectResTick )
		TongStopLoadProgress(self)
	end
	
	if self.m_ChangerTick then
		UnRegisterTick(self.m_ChangerTick)
		self.m_ChangerTick = nil
	end
	
	if self.m_TeamPVPFBReborn then
		UnRegisterTick(self.m_TeamPVPFBReborn)
		self.m_TeamPVPFBReborn = nil
	end
	
--/**��PK����**/
--	if self.m_PkCriminalTick then
--		UnRegisterTick(self.m_PkCriminalTick)
--		self.m_PkCriminalTick = nil
--	end
	if self.RebornCountTick then
		UnRegisterTick(self.RebornCountTick)
		self.RebornCountTick = nil
	end
	if self.m_CommLoadProTick then
		UnRegisterTick(self.m_CommLoadProTick)
		self.m_CommLoadProTick = nil
	end
	UnRegisterTickCrazyHorseTick(self)
	UnRegisterTick( self.DeathTick )
	if self.m_LeaveTick then
		UnRegisterTick(self.m_LeaveTick)
		self.m_LeaveTick = nil
	end
	if self.m_SaveAreaTick then
		UnRegisterTick(self.m_SaveAreaTick)
		self.m_SaveAreaTick = nil
	end
	if self.m_VIPEffectTick then
		UnRegisterTick(self.m_VIPEffectTick)
		self.m_VIPEffectTick = nil
	end
	if self.m_DpsInfoTick then
		UnRegisterTick(self.m_DpsInfoTick)
		self.m_DpsInfoTick = nil
	end
end

--[[
======================================================================================================================
���´����������ٽ�ɫ����
======================================================================================================================
--]]
function CCharacterMediator:Destroy()
	local function Init()
		ClearInTrapPlayer(self)
		CActiveBehavior.ClearBehaviorTick(self)
		
		--�ڳ����ûسǸ���Ĵ������˳�
		if self.m_IsGoBackReborn then
			self:ExitAndGoBack()
			self.m_IsGoBackReborn = nil
		end
		-------------------------------
		--���̲�������
		self.m_bDestroy = true
		self:DestroyTrap()
	
		if( self.m_LockingObj ) then
			self:UnLockObj()
		end
		
		if( self.m_LockingIntObj ) then
			self.m_LockingIntObj = nil
		end
	
		if self.m_Flower then
			self.m_Flower:GrowthEnd(self)
		end
		
		if self.m_PickOre then
			self.m_PickOre:PickOreEnd(self)
		end
		self.EquipType=nil
		self.m_CallbackHandler = nil
		self.m_Scene.m_tbl_Player[self.m_uID] = nil
		CEntityServerCreator_DestroyEntity( self )
	end
	
	apcall(Init)
end

--[[
======================================================================================================================
���´������ڱ�������߼����ֵ����ݣ�����λ�ú͵�ǰѪ��
======================================================================================================================
]]--

function CCharacterMediator:OnSaveFightPropertyTick(tick,Player)
	if Player == nil or (not IsCppBound(Player)) or Player.m_bDestroy == true or Player.GetStateTbl == nil then
		LogErr("����Ѿ����٣�Tick����")
		if tick then
			UnRegisterTick(tick)
		end
		return
	end
	local StateVec,StoredObjVec = Player:GetStateTbl(2)
	local data = {}
	data["char_id"]			= Player.m_uID
	data["StateData"]		= StateVec
	data["StateStoreObjData"]	= StoredObjVec
	data["killNpcCount"] = Player.m_KillNpcCount
	data["killPlayerCount"] = Player.m_KillPlayerCount
	data["playerOnTimeTotal"] = math.abs(os.time() - Player.m_PlayerOnTimeBegin)
	Player.m_KillNpcCount = 0 --����ӱ���һ��ɱ����������
	Player.m_KillPlayerCount = 0 --����ӱ���һ��ɱ������֮������
	Player.m_PlayerOnTimeBegin = os.time() --����ӱ���һ�������ۼ�ʱ��֮������
	CallDbTrans("CharacterMediatorDB", "OnSaveFightPropertyTick", nil, data, Player.m_AccountID)
end

function CCharacterMediator:OnSaveBurstSoulTimes()
	if self == nil or (not IsCppBound(self)) or self.m_bDestroy == true then
--		print("����Ѿ����٣����豣����")
		return
	end
	local data = {}
	data["char_id"]				= self.m_uID
	data["BurstSoulTime"] = self:GetBurstSoulTimes()
	CallDbTrans("CharacterMediatorDB", "OnSaveBurstSoulTime", nil, data, self.m_AccountID)
end

function CCharacterMediator:OnSavePlayerSoulTickFunc(tick,Player)
	if Player == nil then
		return
	end
	if Player.m_uKillDropSoulCount ~= 0 then
		local data = {["soulCount"] = Player.m_uKillDropSoulCount,["PlayerId"] = Player.m_uID,["addSoulType"] = 104}
		
		Player.m_uKillDropSoulCount = 0
		CallDbTrans("EquipMgrDB", "ModifyPlayerSoul", nil, data, Player.m_AccountID)
	end
		
	if Player.m_uAddSoulBottleValue and Player.m_uAddSoulBottleValue ~= 0 then
		local tbl = Player.m_SoulBottleInfo
		local uStorageNum = Exp_Soul_Bottle_Common(tbl[2],"StorageNum")

		local param = {["uSoulBottleId"] = tbl[1],["uSoulBottleValue"] = Player.m_uAddSoulBottleValue,
											["PlayerId"] = Player.m_uID,["bottleName"] = tbl[2],["StorageNum"] = uStorageNum	}
		Player.m_uAddSoulBottleValue = 0
		CallDbTrans("ExpOrSoulStorageDB", "StorageSoulValue", nil, param, Player.m_AccountID)
	end 
end

function CCharacterMediator:OnSaveFightingPointTickFunc(tick,Player)
	if not IsCppBound(Player) then
		return
	end
	
	local data = {["uTotalPoint"] = Player.m_uFightingTotalPoint,["charId"] = Player.m_uID}

	CallDbTrans("FightingEvaluationDB", "SaveFightingEvaluation", nil, data, Player.m_AccountID)
end

function OnSavePlayerExpFunc(Member)
	local ChannelIDList = {}
	local param = {}
	param["PlayerTempExp"] = {}
	for i=1, #(Member) do
		local playerTemp = Member[i]
		if playerTemp.m_KillNpcExp ~= 0 then
			param["PlayerTempExp"][playerTemp.m_uID] = playerTemp.m_KillNpcExp
			playerTemp.m_KillNpcExp = 0
			table.insert(ChannelIDList, playerTemp.m_AccountID)
		end
	end
	if next(param["PlayerTempExp"]) then
		CallDbTrans("RoleQuestDB", "TempMemberExpAdd", nil, param, unpack(ChannelIDList))
	end
end

function CCharacterMediator:PlayerLeaveCurentScene(OldPosX, OldPosY)
	local Scene = self.m_Scene
	Scene.m_tbl_Player[self.m_uID] = nil
	if not IsCppBound(self.m_Conn) then
		return
	end
	
	local sceneType = Scene.m_SceneAttr.SceneType
	if sceneType == 1 or sceneType == 7 then   --����
		local CurrPos = CFPos:new()
		CurrPos.x = OldPosX / EUnits.eGridSpanForObj
		CurrPos.y = OldPosY / EUnits.eGridSpanForObj
		
		--��һ���г���ǰ,����������--------------------
		self.m_MasterSceneName = Scene.m_LogicSceneName
		self.m_MasterScenePos = CurrPos
		-------------------------------------------
		
		local data = {}
		data["char_id"]			= self.m_uID
		data["posCur_x"]		= CurrPos.x
		data["posCur_y"] 		= CurrPos.y
		data["scene_id"]		= Scene.m_SceneId
		--print("PlayerLeaveCurentScene(Player)",CurrPos.x,CurrPos.y)
		CallAccountAutoTrans(self.m_Conn.m_Account, "CharacterMediatorDB", "OnSaveSceneToDB", nil, data, Scene.m_SceneId)
	else --if Scene.m_SceneAttr.SceneType >= 2 then  --����
		local data = {}
		data["char_id"]			= self.m_uID
		CallAccountAutoTrans(self.m_Conn.m_Account, "CharacterMediatorDB", "DelFbPosition", nil, data, Scene.m_SceneId)
		
		--����ս����ʧ��(���뿪�����йص�����)
		CRoleQuest.LeaveScene_SetQuestFailure(Scene, self)
	end
end

--���³�������ʱ,д��log
function CCharacterMediator:ChangeSceneWriteDBLog()
	local Scene = self.m_Scene
	local sceneType = Scene.m_SceneAttr.SceneType
	
	local data = {}
	data["PlayerId"] = self.m_uID
	data["SceneType"] = sceneType
	data["SceneID"] = Scene.m_SceneId
	data["SceneName"] = Scene.m_SceneName
	data["curlevel"] = self:CppGetLevel()
	if Scene.m_SceneAttr.SceneType == 13 then
		if not Scene.m_MatchGameData then
			LogErr("m_MatchGameDataΪnil", self.m_uID.." "..g_CurServerId.." "..Scene.m_SceneId.." "..Scene.m_SceneName.." "..tostring(Scene:IsCanChangeIn()).." "..tostring(Scene:IsHavePlayer()))
		end
		data["MatchGameName"] = Scene.m_MatchGameData.GameName
	end
	
	CallDbTrans("LogMgrDB", "EnterScene", nil, data, self.m_AccountID)
end

function CCharacterMediator:SaveFightingEvaluationInfo(player)
	CGasFightingEvaluation.SaveFightingEvaluationInfo(player)
end

function CCharacterMediator:ChangeSceneSavePos()
	if self.m_SavePosTick then
		UnRegisterTick(self.m_SavePosTick)
		self.m_SavePosTick = nil
	end
	if self.m_SaveFbPosTick then
		UnRegisterTick(self.m_SaveFbPosTick)
		self.m_SaveFbPosTick = nil
	end
	
	local Scene = self.m_Scene
	local sceneType = Scene.m_SceneAttr.SceneType
	if sceneType == 1 or sceneType == 7 then   --����
		self:OnSaveTick(nil,self)
		self.m_SavePosTick = RegClassTick( "Player.m_SavePosTick", self.OnSaveTick, SavePosTickTime*1000, self,self )
	else --if Scene.m_SceneAttr.SceneType >= 2 then  --����
		self:OnSaveFbTick(self)
		--if Scene.m_SceneAttr.SceneType ~= 5 then
		--	self.m_SaveFbPosTick = RegClassTick( "Player.m_SaveFbPosTick", self.OnSaveFbTick, SavePosTickTime*1000, self,self )
		--end
	end
	
	self:ChangeSceneWriteDBLog()
end

function CCharacterMediator:OnSaveTick(Tick, Player)
	if not IsCppBound(Player) then
--		print("���C++�����Ѿ�������")
		return
	end

	if Player.m_bDestroy == true then
--		print("����Ѿ����٣����豣����")
		return
	end
	local sceneType = Player.m_Scene.m_SceneAttr.SceneType
	if sceneType ~= 1 and  sceneType ~= 7 then
		return
	end
--	if Player.m_LastSavePos ~= nil then
--		if g_GetDistanceByPos(Player,Player.m_LastSavePos) < iDistance then
--			--print("����һ�α���ľ�������С�����б���")
--			return
--		end
--	end
	
	local posCur = CFPos:new()
	Player:GetPixelPos( posCur )
	local PlayerId = Player.m_uID
	
	--print("OnSaveTick(Player)",posCur.x,posCur.y)
	local data = {}
	data["char_id"]			= PlayerId
	data["posCur_x"]		= posCur.x / EUnits.eGridSpanForObj
	data["posCur_y"] 		= posCur.y / EUnits.eGridSpanForObj
	data["scene_id"]		= Player.m_Scene.m_SceneId
	
	--local CharacterMediatorDB = (g_DBTransDef["CharacterMediatorDB"])
	CallDbTrans("CharacterMediatorDB", "OnSaveSceneToDB", nil, data, Player.m_AccountID, PlayerId)
	
	if not IsCppBound(Player.m_Conn) then
		return
	end
	local data = {}
	data["char_id"] 		= PlayerId
	data["latency"]			= Player.m_Conn:GetLatency()
	CallDbTrans("LogMgrDB", "SetLatencyToDB", nil, data, Player.m_AccountID)
	
end

function CCharacterMediator:OnSaveFbTick(Player)
	if not IsCppBound(Player) or Player.m_bDestroy == true then
--		print("����Ѿ����٣����豣����")
		return
	end
	
--	if Player.m_LastSavePos ~= nil then
--		if g_GetDistanceByPos(Player,Player.m_LastSavePos) < iDistance then
--			--print("����һ�α���ľ�������С�����б���")
--			return
--		end
--	end
	
	local posCur = CFPos:new()
	Player:GetPixelPos( posCur )
	local PlayerId = Player.m_uID
--	print("OnSaveFbTick(Player)",posCur.x,posCur.y)
	local data = {}
	data["char_id"]			= PlayerId
	data["posCur_x"]		= posCur.x / EUnits.eGridSpanForObj
	data["posCur_y"] 		= posCur.y / EUnits.eGridSpanForObj
	data["scene_id"]		= Player.m_Scene.m_SceneId
	
	--local CharacterMediatorDB = (g_DBTransDef["CharacterMediatorDB"])
	CallDbTrans("CharacterMediatorDB", "OnSaveFBToDB", nil, data, Player.m_AccountID, PlayerId)
end

function CCharacterMediator:InitSkillCoolDownTime(SkillCoolDownRet)
	local pSkillCoolDownDBDataMgr = CSkillCoolDownDBDataMgr:new()
	local aCoolDownVec = pSkillCoolDownDBDataMgr:GetSkillCoolDownDBDateVec()
	local RowNum = SkillCoolDownRet:GetRowNum()
	for i=1, RowNum do
		local uRealLeftTime = SkillCoolDownRet(i,2) - SkillCoolDownRet(i,3)*1000 --uLeftTime-uSysRunedTime
		if uRealLeftTime > 1 then
			local CoolDownDBData = aCoolDownVec:CreateDBData()
			CoolDownDBData:SetSkillName(SkillCoolDownRet(i,1))
			CoolDownDBData:SetLeftTime(uRealLeftTime)
			if SkillCoolDownRet(i,4) == 1 then
				CoolDownDBData:SetIsSwitchEquipSkill(true)
			else
				CoolDownDBData:SetIsSwitchEquipSkill(false)
			end
			aCoolDownVec:PushBack(CoolDownDBData)
		end
	end
	apcall(self.CPPInitSkillCoolDownTime,self,pSkillCoolDownDBDataMgr)
	pSkillCoolDownDBDataMgr:Release()
end

--��ȡ���������Ϣ
function CCharacterMediator:GetAllPanel(Player,result)
	CChatChannelMgr.GetAllPanel(Player,result)
end

function CCharacterMediator:GetAllChanelPanelInfo(player,result)
	CChatChannelMgr.GetAllChanelPanelInfo(player,result)
end

function CCharacterMediator:GetSkillCoolDownTimeTbl()
	local function GetCharacterSkillCoolDownTimeTbl()
		local skillCoolDownDataVec = {}
		local skillCoolDownData = self:GetSkillCoolDownTime()
		local SkillCoolDownDBDateVec = skillCoolDownData:GetSkillCoolDownDBDateVec()
		local num = SkillCoolDownDBDateVec:GetCount()
		for i =1, num do
			local SkillName = SkillCoolDownDBDateVec:Get(i-1):GetSkillName()
			local LeftTime = SkillCoolDownDBDateVec:Get(i-1):GetLeftTime()
			local IsSwitchEquipSkill = 0
			if SkillCoolDownDBDateVec:Get(i-1):GetIsSwitchEquipSkill() then
				IsSwitchEquipSkill = 1
			end
			if SkillName ~= nil and LeftTime ~= nil then
				--print("����ʱ���ܵ���ȴʱ�� : ",SkillName,LeftTime)
				table.insert(skillCoolDownDataVec,{SkillName, LeftTime, 0, IsSwitchEquipSkill})
			end
		end
		self:SaveSkillCoolDownTimeToDBEnd()
		return skillCoolDownDataVec
	end
	local ret, msg = apcall(GetCharacterSkillCoolDownTimeTbl)
	return msg
end

function CCharacterMediator:InitAureMagic(AureMagicRes,ChangeType)
	if not AureMagicRes then
		LogErr("CCharacterMediator:InitAureMagic����", ChangeType)
		return
	end
	local uCount = AureMagicRes:GetRowNum()
	for i=1, uCount do
		self:LoadAureMagicFromDB(AureMagicRes(i,1),AureMagicRes(i,2),AureMagicRes(i,3),AureMagicRes(i,4))
	end
end

local PosSkillStateNameTbl = {
							["�ڱ���̬״̬"] = 1,
							["������̬״̬"] = 2,
							["��ʨ��̬״̬"] = 3,
							["��������״̬"] = 1,
							["��������״̬"] = 2,
							["��˪����״̬"] = 3,
							}
							
function CCharacterMediator:InitShortcutEnd(Player)
	for i,v in pairs (PosSkillStateNameTbl) do
		if Player:ExistState(i) then
			Gas2Gac:ReturnShortcutEnd(self.m_Conn,v)
		end
	end
end

function CCharacterMediator:GetAureMagicDataTbl()
	local function GetCharacterAureMgaicTbl()
		local AureMagicDataVec = {}
		local AureMagicDBData = self:SerializeAureMagicToDB()
		local AureMagicDBDateVec = AureMagicDBData:GetAureMagicDBDateVec()
		local num = AureMagicDBDateVec:GetCount()
		for i =1, num do
			local AureMagicName 	= AureMagicDBDateVec:Get(i-1):GetAureMagicName()
			local SkillLevel		 	= AureMagicDBDateVec:Get(i-1):GetSkillLevel()
			local SkillName 		= AureMagicDBDateVec:Get(i-1):GetSkillName()
			local AttackType	 	= AureMagicDBDateVec:Get(i-1):GetAttackType()
			table.insert(AureMagicDataVec,{AureMagicName,SkillLevel,SkillName,AttackType})
		end
		self:SaveAureMagicToDBEnd()
		return AureMagicDataVec	
	end
	local ret, msg = apcall(GetCharacterAureMgaicTbl)
	return msg
end

------------------------------------------------------------------------------------------------------
----����ʱ�����󷨵�������Ϣ
--function CCharacterMediator:LoadBattleInfo(Conn,battletbl,uCharID)
--	local function Init()
--		local uCapatinID,query_result,query_list,bookinfo_list,skill_list = unpack(battletbl)
--		--��ͻ��˷�������������Ϣ
--		if query_result:GetRowNum() > 0 then
--			local query_tbl = query_result:GetTableSet()
--			for i=1,query_result:GetRowNum() do
--				Gas2Gac:ReturnGetAllBattleArrayPosInfo(Conn,query_tbl(i,1),query_tbl(i,2),query_tbl(i,3),query_tbl(i,4),query_tbl(i,5),query_tbl(i,6),query_tbl(i,7),query_tbl(i,8))
--			end
--			Gas2Gac:ReturnGetAllBattleArrayPosInfoEnd(Conn)
--		end
--
--		--��ͻ��˷�����ҵ�����������Ϣ
--		if (uCharID == uCapatinID) then
--			if query_list:GetRowNum() > 0 then 
--				local battleArrayTbl = query_list:GetTableSet()
--				for i = 1,query_list:GetRowNum() do
--					Gas2Gac:ReturnGetAllBattleArrayMemPosInfo(Conn,battleArrayTbl(i,1),battleArrayTbl(i,2),battleArrayTbl(i,3),battleArrayTbl(i,4),battleArrayTbl(i,5),battleArrayTbl(i,6))
--				end
--				Gas2Gac:ReturnGetAllBattleArrayMemPosInfoEnd(Conn)
--			end 
--		end
--
--		--��ͻ��˷����󷨼������Ĵ洢��Ϣ
--		if skill_list:GetRowNum() > 0 then
--			local skill_tbl = skill_list:GetTableSet()
--			for i = 1,skill_list:GetRowNum() do
--				Gas2Gac:ReturnGetAllBattleSkill(Conn,skill_tbl(i,1),skill_tbl(i,2))
--			end
--		end
--	end
--	apcall(Init)
--end
-------------------------------------------------------------------------------------------------------
--����֪ͨ����
function CCharacterMediator:NotifyFriendOnline(allFriendsInfo,uCharID)
	local function Init()
		if allFriendsInfo:GetRowNum() > 0 then
			local allFriendsInfoTbl = allFriendsInfo:GetTableSet()
			for i = 1, allFriendsInfo:GetRowNum() do
				--������Id,���ID
				Gas2GacById:NotifyFriendOnline(allFriendsInfoTbl(i,2), allFriendsInfoTbl(i,1),uCharID)
			end
		end
	end
	apcall(Init)
end

--����֪ͨ����Ⱥ����ĳ�Ա
function CCharacterMediator:NotifyFriendGroupOnline(groupfriends,uCharID)
	local function Init()
		if groupfriends:GetRowNum() > 0 then
			for i = 1, groupfriends:GetRowNum() do
				--���ID,����ȺID
				Gas2GacById:NotifyFriendGroupOnline(groupfriends(i,1),uCharID,groupfriends(i,2))
			end
		end
	end
	apcall(Init)
end

--���߷��ͺ�����������
function CCharacterMediator:SendOfflineFriendRequest(result,Connection)
	local function Init()
		if result:GetRowNum() > 0 then
			local result_tbl = result:GetTableSet()
			for i = 1,result:GetRowNum() do
				Gas2Gac:ReturnInviteToBeFriend(Connection, result_tbl(i,1),result_tbl(i,2),result_tbl(i,3))
			end
		end
	end
	
	apcall(Init)
end

--���߷��ͱ�����������Ⱥ����������
function CCharacterMediator:SendAddToGroupRequest(result,Connection)
	local function Init()
		if nil ~= result and #result > 0 then
			for i = 1,#result do
				Gas2Gac:ReceiveInviteToGroup(Connection, result[i][1],result[i][2],result[i][3],result[i][4])
			end
		end
	end
	
	apcall(Init)
end

--���߷�������������Ⱥ����������
function CCharacterMediator:SendAddToGroupRequestToManger(result,Connection)
	local function Init()
		if nil ~= result and #result > 0 then
			for i = 1,#result do
				Gas2Gac:RecevieRequestJoinIntoFriendGroup(Connection, result[i][1],result[i][2],result[i][3])
			end
		end
	end
	
	apcall(Init)
end

function CCharacterMediator:SendOfflineMsg(msgtbl,Connection)
	if msgtbl and msgtbl:GetRowNum() > 0  then
		for i = 1,msgtbl:GetRowNum() do
			Gas2Gac:ReceiveSendOfflineMsg(Connection,msgtbl(i,1),msgtbl(i,2),msgtbl(i,3),msgtbl(i,4))
		end
	end
end

function CCharacterMediator:SendGMOfflineMsg(gmMsgTbl,Connection)
	if gmMsgTbl and gmMsgTbl:GetRowNum() > 0  then
		for i = 1,gmMsgTbl:GetRowNum() do
			Gas2Gac:ReceiveSendOfflineMsg(Connection,gmMsgTbl(i,1),"GM",gmMsgTbl(i,2),gmMsgTbl(i,3))
		end
	end
end

function CCharacterMediator:InitAssociationInfo(Connection, uCharID, ChangeType, AssociationInfo)
	if ChangeType == 0 then
		--����֪ͨ����
		self:NotifyFriendOnline(AssociationInfo.friends,uCharID)
		self:NotifyFriendGroupOnline(AssociationInfo.groupfriends,uCharID)
	end
	
	--���߷������ߺ�������
	self:SendOfflineFriendRequest(AssociationInfo.friendRequest,Connection)
	self:SendAddToGroupRequest(AssociationInfo.addGroupRequest,Connection)
	self:SendAddToGroupRequestToManger(AssociationInfo.addGroupRequestToManger,Connection)
	self:SendOfflineMsg(AssociationInfo.msgtbl,Connection)
	self:SendGMOfflineMsg(AssociationInfo.gmMsgTbl,Connection)
end
-----------------------------------------------------------------------------------------------------
--����֪ͨ��ɫ���ϵĻ�ֵ
function CCharacterMediator:NotifyPlayerSoulNum(playersoul,Connection)
	local function Init(data)
		local playersoul,Connection = unpack(data)
		Gas2Gac:ReturnModifyPlayerSoulNum(Connection, playersoul)
	end
	
	local data = {playersoul,Connection}
	apcall(Init,data)
end
------------------------------------------------------------------------------------------------------
--���ߺ���ͻ��˷��ͽ�ɫ���г�ν
function CCharacterMediator:ReturnCharAllAppellationInfo(AllAppellationInfo,Connection)
	local function Init()
		if next(AllAppellationInfo) then
			for i = 1,#(AllAppellationInfo) do
				Gas2Gac:ReturnCharAllAppellationInfo(Connection,AllAppellationInfo[i])
			end
		end
	end
	
	apcall(Init)
	
end

--���ߺ���ͻ��˷����̵깺����ʾ��־��Ϣ
function CCharacterMediator:ReturnNpcShopBuyTipInfo(npcshopBuyTipInfo, Connection)
    local liutongShopFlag = npcshopBuyTipInfo["LiuTongShopTipFlag"] or 1--Ĭ����ʾ
    local commonShopFlag =  npcshopBuyTipInfo["CommonShopTipFlag"] or 1 --Ĭ����ʾ
    Gas2Gac:ReturnNpcShopBuyTipInfo(Connection, liutongShopFlag, commonShopFlag)
end

--���ߺ�ˢ�����װ����Ч
function CCharacterMediator:ReturnEquipEffectInfo(player,equipEffectInfo, Connection)
	if equipEffectInfo:GetRowNum() > 0 then
		if equipEffectInfo(1,1) <= 50 then
			player:PlayerDoPassiveSkill("�߼�װ����Ч",1)
		else
			player:PlayerDoPassiveSkill("�μ�װ����Ч",1)
		end
  end
end

function CCharacterMediator:VIPEffectFunc(tick,Player)
	if Player == nil then
		return
	end
	local data = {["char_id"] = Player.m_uID}
	
	local function CallBack(result)
		if result == 0 then
			Player:ClearState("˫������״̬")
			UnRegisterTick( Player.m_VIPEffectTick )
			Player.m_VIPEffectTick = nil
		else
			if result < 5 then
				UnRegisterTick( Player.m_VIPEffectTick )
				Player.m_VIPEffectTick = nil
				Player.m_VIPEffectTick = RegClassTick( "VIPEffectTick", Player.VIPEffectFunc, 60*1000,self,Player)
			end
	  end
	end

	CallDbTrans("UseVIPItemDB", "GetVIPEffect", CallBack, data)
end

--���ߺ�ˢ��VIP��Ч
function CCharacterMediator:ReturnVipEffectInfo(player,VipEffectInfo)
	if VipEffectInfo > 0 then
		player:PlayerDoItemSkill("˫������",1)
		if VipEffectInfo >= 5 then
			player.m_VIPEffectTick = RegClassTick( "VIPEffectTick", player.VIPEffectFunc, 5*60*1000,self,player)
		else
			player.m_VIPEffectTick = RegClassTick( "VIPEffectTick", player.VIPEffectFunc, 60*1000,self,player)
		end
  end
end

function CCharacterMediator:ReturnLiveskillInfo(LiveskillInfo,Conn)
	local function Init()
			CLiveskillBase.RetLiveskillInfo(Conn,LiveskillInfo)
	end
	apcall(Init)
end

function CCharacterMediator:InitTongInfo(TongPos,TongType,Connection)
	Gas2Gac:ReturnPosChanged(Connection ,TongPos)
	Gas2Gac:TongTypeChanged(Connection, TongType)
end

function CCharacterMediator:InitTongMember(result,Connection)
	local TongID			= result["TongID"]
	local TongName		= result["TongName"]
	local ArmyCorpsID	= result["ArmyCorpsID"]
	local ArmyCorpsName	= result["ArmyCorpsName"]
	if TongID ~= 0 then
		g_GasTongMgr:AddTongMember(self.m_uID,TongID,TongName)
		g_GasArmyCorpsMgr:AddArmyCorpsMember(self.m_uID,ArmyCorpsID,ArmyCorpsName)
	end
end

function CCharacterMediator:InitTongTechInfo(result,Conn)
    local techInfoRet = result["TongTechInfo"]
    CTongTech.InitTongTechInfo(Conn, true, techInfoRet)
end

function CCharacterMediator:InitArmyCorpsInfo(ArmyCorpsPos,Connection)
	Gas2Gac:OnArmyCorpsPosChanged(Connection, ArmyCorpsPos)
end

function CCharacterMediator:ReturnSaveChatInWorldShow(result,Connection)
	if result > 0 then
		Gas2Gac:ReturnSaveChatInWorldShow(Connection)
	end
end

function CCharacterMediator:ReturnSaveChatInCHItemShow(result,Connection)
	if result > 0 then
		Gas2Gac:ReturnSaveChatInCHItemShow(Connection)
	end
end

function CCharacterMediator:ReturnSaveChatInCHMoneyShow(result,Connection)
	if result > 0 then
		Gas2Gac:ReturnSaveChatInCHMoneyShow(Connection)
	end
end
------------------------------------------------------------------------------------------------------
--���ߺ���������ϵĻ���
function CCharacterMediator:ReturnPlayerPoint(playe_point,Connection)
	local function Init()
		if #playe_point > 0  then
			Gas2Gac:ReturnPlayerPoint(Connection,playe_point[1],playe_point[2],playe_point[3],playe_point[4],playe_point[5],playe_point[6],playe_point[7],playe_point[8],playe_point[9],playe_point[10],playe_point[11])
		end
	end
	apcall(Init)
end
------------------------------------------------------------------------------------------------------
function CCharacterMediator:InitItemBagLock(Player, ItemLockTime)
	if ItemLockTime[1]  then
		Gas2Gac:ReturnInitLockItemBagByTime(Player.m_Conn,ItemLockTime[2])
		Player.m_ItemBagLock = true
	end
end

-- beingway add 3.17

-- ����
function CCharacterMediator:Reborn(Coefficient,res)
	if self.RebornCountTick then
		self:RebornCountTime()
	end
	Gas2Gac:CloseRebornMsgWnd(self.m_Conn)
	self:CppReborn()
	self:CppInitHPMP(self:CppGetMaxHP() * Coefficient,self:CppGetMaxMP() * Coefficient)
	UnRegisterTick( self.DeathTick )
	self.DeathTick = nil
	if self.AddTalentTbl ~= nil then 
		for i =1, #(self.AddTalentTbl) do
			self:InsertTalent( self.AddTalentTbl[i][1], self.AddTalentTbl[i][2])
		end
	end
	if self.AddSkillTbl ~= nil then 
		for i = 1,#(self.AddSkillTbl) do
			self:AddSkill(self.AddSkillTbl[i][1],self.AddSkillTbl[i][2])
		end
	end
	
	--����Ǳ���������Ҫ�ж��ǲ��ǽ��ü�����
	if self.m_Scene.m_SceneAttr.SceneType == 13 then
		InMatchGameSceneReborn(self)
	end
	
	if self.ClearAllTalentBool then
		self:ClearAllTalent()
		self.ClearAllTalentBool = false
	end
	
	if self.m_RebornType then
		if self.m_RebornType < ReBornTypeEnmu.rbCurrPos or self.m_RebornType > ReBornTypeEnmu.rbNow then
			self.m_RebornType = ReBornTypeEnmu.rbNow
		end
	else
		self.m_RebornType = ReBornTypeEnmu.rbNow
	end
	
	self:IsFirstTimeAndSendMsg("����", 2008)
	
	if self.m_Conn.m_Account then
		local data = {["PlayerId"]=self.m_uID,["RebornMethod"]=self.m_RebornType,["sceneName"] = self.m_Scene.m_SceneName,
						["res"] = res}
		CallAccountAutoTrans(self.m_Conn.m_Account, "LogMgrDB","LogReBorn",nil,data)
	end
	
	self.m_RebornType = nil
	self.AddTalentTbl = nil
	self.AddSkillTbl = nil
end

function CCharacterMediator:GetRecentlyRebornPos(Connection)
	
	return posX,posY
end

function Gac2Gas:MatchGameJoinPointReborn(Conn)
	if not IsCppBound(Conn) or not IsCppBound(Conn.m_Player) then
		return
	end
	if Conn.m_Player:CppIsLive() then
		return
	end
	local scene = Conn.m_Player.m_Scene
	local gameName = scene.m_MatchGameData and scene.m_MatchGameData.GameName
	if gameName and g_MatchGameMgr.m_CfgData[gameName] then
		local tbl = g_MatchGameMgr.m_CfgData[gameName].EnterPointTbl
		if tbl then
			local n = math.random(table.maxn(tbl))
			local PixelPos = CFPos:new()
			PixelPos.x = tbl[n][1] * EUnits.eGridSpanForObj
			PixelPos.y = tbl[n][2] * EUnits.eGridSpanForObj
			Conn.m_Player:SetPixelPos(PixelPos)
			Conn.m_Player:Reborn(1)
		else
			CfgLogErr("MatchGame_Common��EnterPoint������¸���ʧ��","����("..gameName..")��������Ϊ10,EnterPoint��ֻ����̶��㴫��")
		end
	else
		CfgLogErr("Scene_Common������������¸���ʧ��","����("..scene.m_SceneName..")����MatchGame����,�������Ͳ�����10.")
	end
end

-- ��������������ں�,��ѡ��ֱ�ӹ���Ϸ,�������Զ��������㸴��
function CCharacterMediator:ExitAndGoBack()
	local function Init()
		local SceneName = self.m_Scene.m_LogicSceneName
		local nCamp = self:CppGetCamp()
		
		local posCur = CPos:new()
		self:GetGridPos( posCur )
		
		local posX,posY
		--�õ�����������ĸ����
		if RebornPos_Common(SceneName) then
			local info = RebornPos_Common(SceneName, tostring(nCamp))
			if info then
				local Keys = info:GetKeys()
				for _,p in pairs(Keys) do
					if info(p, "DefaultReborn") == 0 then
						if posX == nil or nil == posY then
							posX,posY = info(p,"PosX"),info(p,"PosY")
						else
							local pos1 = (posCur.x - posX)*(posCur.x - posX)+(posCur.y - posY)*(posCur.y - posY)
							local pos2 = (posCur.x - info(p,"PosX"))*(posCur.x - info(p,"PosX"))+(posCur.y - info(p,"PosY"))*(posCur.y - info(p,"PosY"))
							if pos2 < pos1 then
								posX,posY = info(p,"PosX"),info(p,"PosY")
							end
						end
					end
				end
			end
		end
		
		local nFlag = 0
		
		if posX == nil or nil == posY then
			--û�и����Ļ�����Ĭ�ϸ���㸴��
			for _, sceneName in pairs(RebornPos_Common:GetKeys()) do
				for _, index in pairs(RebornPos_Common:GetKeys(sceneName, tostring(nCamp))) do
					local info = RebornPos_Common(sceneName, tostring(nCamp), index)
					if info("DefaultReborn") == 1 then
						if sceneName ~= SceneName then
							--Ĭ�ϳ����͵�ǰ��������ͬһ����������ת
							SceneName = sceneName
						end
						posX,posY = info("PosX"),info("PosY")
						nFlag = 1
						break
					end
				end
			end
			if nFlag == 0 then
				--û��Ĭ�ϸ���㣬�������ظ���
				SceneName = self.m_Scene.m_SceneAttr.SceneName
				posX = self.m_Scene.m_SceneAttr.InitPosX
				posY = self.m_Scene.m_SceneAttr.InitPosY
			end
		end
		
		local SceneId = g_SceneMgr:GetSceneByName(SceneName)
--		for i,v in pairs(g_SceneMgr.m_tbl_Scene) do
--			if SceneName == v.m_SceneName then
--				if v.m_SceneAttr.SceneType == 1 then   --����
--					SceneId = v.m_SceneId
--				end
--				break
--			end
--		end
		
		if SceneId then
			local param = {}
			param["char_id"] = self.m_uID
			param["scene_id"] = SceneId
			param["posCur_x"] = posX
			param["posCur_y"] = posY
			param["char_hp"] = self:CppGetMaxHP() * 0.3
			param["char_mp"] = self:CppGetMaxMP() * 0.3
			CallDbTrans("CharacterMediatorDB", "ExitAndGoBack", nil, param, self.m_AccountID)
		end
	end
	apcall(Init)
	
end

local function GoBackAndRebornDoSkill(Player, SceneName)
	if Scene_Common[SceneName].RebornType == 1 then
		Player:PlayerDoItemSkill("�����",1)
	end	
end

-- �������㸴��
function CCharacterMediator:GoBackAndReborn(Connection)
	local Player = Connection.m_Player
	local SceneName = Player.m_Scene.m_LogicSceneName
	local nCamp = Player:CppGetCamp()
	
	local posCur = CPos:new()
	Player:GetGridPos( posCur )
	
	Player.m_RebornType = ReBornTypeEnmu.rbGoBack
	local posX,posY
	--�õ�����������ĸ����
	local info = RebornPos_Common(SceneName, tostring(nCamp))
	if info then
		local Keys = info:GetKeys()
		for _,p in pairs(Keys) do
			if info(p, "DefaultReborn") == 0 then
				if posX == nil or nil == posY then
					posX,posY = info(p, "PosX"),info(p, "PosY")
				else
					local pos1 = math.sqrt((posCur.x - posX)*(posCur.x - posX)+(posCur.y - posY)*(posCur.y - posY))
					local pos2 = math.sqrt((posCur.x - info(p, "PosX"))*(posCur.x - info(p, "PosX"))+(posCur.y - info(p, "PosY"))*(posCur.y - info(p, "PosY")))
					if pos2 < pos1 then
						posX,posY = info(p, "PosX"),info(p, "PosY")
					end
				end
			end
		end
	end
	
	local nFlag = 0
	
	if posX == nil or nil == posY then
		--û�и����Ļ�����Ĭ�ϸ���㸴��
		for _, sceneName in pairs(RebornPos_Common:GetKeys()) do
			for _, index in pairs(RebornPos_Common:GetKeys(sceneName, tostring(nCamp))) do
				local info = RebornPos_Common(sceneName, tostring(nCamp), index)
				if info("DefaultReborn") == 1 then
					if sceneName == SceneName then
						--˵����ͬһ����
						posX,posY = info("PosX"),info("PosY")
						nFlag = 2
					else
						--Ĭ�ϳ����͵�ǰ��������ͬһ����������ת
						ChangeSceneByName(Connection, sceneName, info("PosX"), info("PosY"), nil, nil)
						GoBackAndRebornDoSkill(self, sceneName)
						nFlag = 1
					end
					break
				end
			end
		end
		if nFlag == 0 then
			--û��Ĭ�ϸ���㣬�������ظ���
			posX = self.m_Scene.m_SceneAttr.InitPosX
			posY = self.m_Scene.m_SceneAttr.InitPosY
			if SceneName ~= self.m_Scene.m_SceneAttr.SceneName then
				ChangeSceneByName(Connection, self.m_Scene.m_SceneAttr.SceneName, PosX, PosY)
				GoBackAndRebornDoSkill(self, self.m_Scene.m_SceneAttr.SceneName)
				nFlag = 1
			end
		end
	end
	
	if nFlag ~= 1 then
		local PixelPos = CFPos:new()
		PixelPos.x =  posX* EUnits.eGridSpanForObj
		PixelPos.y =  posY*EUnits.eGridSpanForObj
		self:SetPixelPos(PixelPos)
		self:Reborn(0.3)
		GoBackAndRebornDoSkill(self, SceneName)
	end
end

function CCharacterMediator:TongChallengeReborn()
	local TongID = self.m_Properties:GetTongID()
	local Scene = self.m_Scene
	local SceneName = Scene.m_SceneName
	local posCur = CPos:new()
	self:GetGridPos(posCur)
	local obj1 = Scene.m_IntObjTbl[1]
	local obj2 = Scene.m_IntObjTbl[2]
	
	--CFPos���͵�
	local Pos1 = CPos:new()
	local Pos2 = CPos:new()
	obj1:GetGridPos(Pos1)
	obj2:GetGridPos(Pos2)
	
	local pos
	if TongID == Scene.m_ChlgerTongId then
		pos = g_TongChallengeFbMgr:GetChallengerCenterPos()
	elseif TongID == Scene.m_TgtTongId then
		pos = g_TongChallengeFbMgr:GetTargetCenterPos()
	end
	
	local PosX, PosY = pos[1], pos[2]
	local dis1 = math.sqrt((posCur.x - pos[1]) * (posCur.x - pos[1]) + (posCur.y - pos[2])*(posCur.y - pos[2]))
	local dis2 = math.sqrt((posCur.x - Pos1.x) * (posCur.x - Pos1.x) + (posCur.y - Pos1.y)*(posCur.y - Pos1.y))
	local dis3 = math.sqrt((posCur.x - Pos2.x) * (posCur.x - Pos2.x) + (posCur.y - Pos2.y)*(posCur.y - Pos2.y))
	
	if obj1.m_Occupyer == TongID and obj2.m_Occupyer == TongID then
		if dis2 <= dis1 and dis2 <= dis3 then
			PosX, PosY = Pos1.x, Pos1.y
		end
		
		if dis3 <= dis1 and dis3 <= dis2 then
			PosX, PosY = Pos2.x, Pos2.y
		end
	end
	
	if obj1.m_Occupyer == TongID and obj2.m_Occupyer ~= TongID then
		if dis2 < dis1 then
			PosX, PosY = Pos1.x, Pos1.y
		end
	end
	
	if obj1.m_Occupyer ~= TongID and obj2.m_Occupyer == TongID then
		if dis3 < dis1 then
			PosX, PosY = Pos2.x, Pos2.y
		end
	end
	
	local PixelPos = CFPos:new()
	PixelPos.x =  PosX * EUnits.eGridSpanForObj
	PixelPos.y =  PosY * EUnits.eGridSpanForObj
	self:SetPixelPos(PixelPos)
	self:Reborn(1)
	self.m_RebornType = ReBornTypeEnmu.rbIntoFbPos
end

--��פ�ظ���
function CCharacterMediator:StationReborn(Connection)
	ChangeTongScene(Connection)
end

function CCharacterMediator:RebornCountTime()
	local function TickFun()
		self.m_RebornCountTime = 0
		UnRegisterTick(self.RebornCountTick)
		self.RebornCountTick = nil
	end
	if self.RebornCountTick then
		UnRegisterTick(self.RebornCountTick)
	end
	self.RebornCountTick = RegisterTick("RebornCountTick", TickFun, 120000)
end

function CCharacterMediator:DeadToClientMsg()
	local AttackScene = self.m_Scene
	local RebornType = AttackScene.m_SceneAttr.RebornType or 1   --������һ���͵Ĵ���
	local OsTime = os.time() - 1
	
	if RebornType == 2 then
		DeadInQuestFB(self)
	elseif self.m_NotShowJFSMsgWnd and RebornType == 3 then
		self.m_NotShowJFSMsgWnd = nil
--		elseif RebornType == 6 then
--			self:GoBackAndReborn(self.m_Conn)
--			Gac2Gas:GoIntoFbOrStay(self.m_Conn, true)
	else
		--	print(os.time(),self.m_RebornCountTime)
		local DeadTimes = 0
		if AttackScene.m_MatchGameDeadTimes and AttackScene.m_MatchGameDeadTimes[self.m_uID] then
			DeadTimes = AttackScene.m_MatchGameDeadTimes[self.m_uID]
		end
		Gas2Gac:OnShowDeadMsgBox(self.m_Conn,RebornType, self.m_RebornCountTime, DeadTimes) --֪ͨ�ͻ�����ʾ������������
		if RebornType == 1 then
			self.m_StayRebornTime = OsTime + self.m_RebornCountTime
			if AttackScene.m_SceneAttr.SceneType == 1 then
				self.m_IsGoBackReborn = true
			end
		elseif RebornType == 7 then
			if AttackScene.m_SceneAttr.SceneType == 7 then
				self.m_IsGoBackReborn = true
			end
		elseif RebornType == 4 then
			self.m_StayRebornTime = OsTime + self.m_RebornCountTime
			self.m_PlayerRebornTime = OsTime + 30
		elseif RebornType == 5 then
			self.m_StayRebornTime = OsTime + self.m_RebornCountTime
			self.m_PlayerRebornTime = OsTime + 10
			
		elseif RebornType == 8 then
			self.m_PlayerRebornTime = OsTime + 10
			
		elseif RebornType == 9 then
			if AttackScene.m_SceneAttr.SceneType == 8 then
				self.m_IsGoBackReborn = true
			end
		elseif RebornType == 12 then
			local function TickFun(Tick)
				UnRegisterTick(Tick)
				self.m_TeamPVPFBReborn = nil
				if not IsCppBound(self) then
					return
				end
				Gas2Gac:HideTeamPVPFBDeadMsgWnd(self.m_Conn)
				if self:CppIsLive() then
					return
				end
				local scene = self.m_Scene
				
				if scene.m_SceneAttr.SceneType == 13 then
					
					local Arg = g_MatchGameMgr:GetMatchTeanIndex(self)
					local info = FbRebornPos_Common(scene.m_LogicSceneName, tostring(Arg))
					if info then
						local Keys = FbRebornPos_Common:GetKeys(scene.m_LogicSceneName, tostring(Arg))
						local num = math.random(1, table.getn(Keys))
						local PixelPos = CFPos:new()
						PixelPos.x = info(tostring(num), "PosX") * EUnits.eGridSpanForObj
						PixelPos.y = info(tostring(num), "PosY") * EUnits.eGridSpanForObj
						self:SetPixelPos(PixelPos)
						self:Reborn(1)
						self:PlayerDoItemSkill("12�ิ���Ч",1)
					else
						CfgLogErr("FbRebornPos_Common����д�����¸���ʧ��","����("..scene.m_LogicSceneName..")ArgΪ("..tostring(Arg)..")�ĸ���û����д", self.m_Conn)
					end
				end
			end
			self.m_TeamPVPFBReborn = RegisterTick("TeamPVPFBReborn",TickFun,30000)
		elseif RebornType == 13 then
			if not AttackScene.m_MatchGameDeadTimes then
				AttackScene.m_MatchGameDeadTimes = {}
			end
			if not AttackScene.m_MatchGameDeadTimes[self.m_uID] then
				AttackScene.m_MatchGameDeadTimes[self.m_uID] = 0
			end
			AttackScene.m_MatchGameDeadTimes[self.m_uID] = AttackScene.m_MatchGameDeadTimes[self.m_uID] + 1
		end
	end
end

-- ԭ�ظ���,ʹ�õ���
function CCharacterMediator:AtDeadPositionReborn(Connection)
	local nCharID,nCharLevel = Connection.m_Player.m_uID,Connection.m_Player:CppGetLevel()
	if nCharLevel < 15 then
		--�ȼ�С��15�����ָ������Ҫ����
		self.m_RebornType = ReBornTypeEnmu.rbNewPlayer
		self:Reborn(1)
	else
		
		--�ص������������߼���
		local function CallBack(res)
			if (not res)then
				--"����ʯ��������������ԭ�ظ��"
				MsgToConn(Connection,8003,"����ʯ��������������ԭ�ظ��")
				return
			end
			--ɾ������ʯ����
			if IsCppBound(Connection) then
				if IsNumber(res) then
					MsgToConn(Connection,res)
					return
				end
				--����
				Connection.m_Player.m_RebornType = ReBornTypeEnmu.rbCurrPos
				Connection.m_Player:Reborn(0.3,res)
				Connection.m_Player:RebornCountTime()
			end
		end
		local parameters = {}
		parameters["nCharID"]	= nCharID
		CallAccountAutoTrans(Connection.m_Account, "CharacterMediatorDB", "DelRebornItem", CallBack, parameters)
	end
end

function CCharacterMediator:LuaSetDoSkillCtrlState(eDoSkillCtrlState, bSet)
	if self.m_tblDoSkillCtrlState == nil then
		self.m_tblDoSkillCtrlState = {}
	end
	if self.m_tblDoSkillCtrlState[eDoSkillCtrlState] then
		if bSet then
			self.m_tblDoSkillCtrlState[eDoSkillCtrlState] = self.m_tblDoSkillCtrlState[eDoSkillCtrlState] + 1
		else
			self.m_tblDoSkillCtrlState[eDoSkillCtrlState] = self.m_tblDoSkillCtrlState[eDoSkillCtrlState] - 1
		end
	else
		if bSet then
			self.m_tblDoSkillCtrlState[eDoSkillCtrlState] = 1
		else
			if self.m_SetCtrlState then
				LogErr("��û�����ô˼��ܿ���ֵ,���ܳ�������","�ϴγ���λ����:"..self.m_SetCtrlState, self.m_Conn)
			else
				LogErr("��û�����ô˼��ܿ���ֵ,���ܳ�������","û���ϴγ���", self.m_Conn)
			end
			return
		end
	end
	if self.m_tblDoSkillCtrlState[eDoSkillCtrlState] < 0 then
		if self.m_SetCtrlState then
			LogErr("lua���õļ��ܿ���ֵ����С��0,�������Ƿ���bug","�ϴγ���λ����:"..self.m_SetCtrlState, self.m_Conn)
		else
			LogErr("lua���õļ��ܿ���ֵ����С��0,�������Ƿ���bug","û���ϴγ���", self.m_Conn)
		end
		return
	end
	--print("lua���õļ��ܿ���ֵ���� : ",self.m_tblDoSkillCtrlState[eDoSkillCtrlState])
	self:CppSetDoSkillCtrlState(eDoSkillCtrlState, bSet)
end

-- ����۲���ģʽ
function CCharacterMediator:EnterObserverMode()
	self.m_RebornType = ReBornTypeEnmu.rbObserverMode
	self:Reborn(0.3)
	self.m_EnterObserverMode = true
	self:SetSize(0)
	self:SetBottomSize(0)
	--self:SetBarrierSize(0)
	self:SetGameCamp(0)
	self:CppSetCamp(ECamp.eCamp_Passerby)
	self:LuaSetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseSkill, true)
	self:CppSetCtrlState(EFighterCtrlState.eFCS_ForbitNormalAttack, true)
	MsgToConn(self.m_Conn,2102)--��ʾ,�Ѿ�����۲���ģʽ
	Gas2Gac:SetPlayerAlphaValue(self.m_Conn,128)
end

-- ȡ���۲���ģʽ
function CCharacterMediator:LeaveObserverMode()
	self:SetSize(0.5)
	self:SetBottomSize(0.5)
	--self:SetBarrierSize(0.5)
	self.m_EnterObserverMode = nil
	self:CppSetCamp(self:CppGetBirthCamp())
	self:LuaSetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseSkill, false)
	self:CppSetCtrlState(EFighterCtrlState.eFCS_ForbitNormalAttack, false)
	Gas2Gac:SetPlayerAlphaValue(self.m_Conn,255)
	self.m_SetCtrlState = 20
end

--��е
function CCharacterMediator:ForbidUseWeapon(bool)
	local equip_mgr = g_GetEquipMgr()
	local function CallBack(Data)
	    local bFlag = Data["ForbidFlag"]
		if bFlag then --��ʼ��е
			local CommonlySkillName  = g_GetPlayerClassNameByID(self.m_Class).. "��ͨ����"
			if Data.WeaponInfo ~= nil then
				local Weapon_equip = equip_mgr:GetEquipFromRet(tonumber(Data.WeaponInfo[3]), self.m_uID, tonumber(Data.WeaponInfo[1]), Data.WeaponInfo[2],Data.WeaponRet)
				Weapon_equip:DisablePropty(self,EEquipPart.eWeapon, "CCharacterMediator:ForbidUseWeapon")
				self:CppInitMHNA(CommonlySkillName,"������","",2.0,false)
				Gas2Gac:ReWeaponAttr(self.m_Conn,false,CommonlySkillName)		
			end
		else --ֹͣ��е
			if Data.WeaponInfo ~= nil  then
				local Weapon_equip = equip_mgr:GetEquipFromRet(tonumber(Data.WeaponInfo[3]), self.m_uID, tonumber(Data.WeaponInfo[1]), Data.WeaponInfo[2],Data.WeaponRet)
				Weapon_equip:EnablePropty(self,EEquipPart.eWeapon, "CCharacterMediator:ForbidUseWeapon")	
				local CommonlySkillName = Weapon_equip:SetWeaponSkill(self,Data.WeaponInfo[1],Data.WeaponInfo[2],false)
				Gas2Gac:ReWeaponAttr(self.m_Conn,true,CommonlySkillName)
			end
		end
	end
	local data = {["PlayerId"] = self.m_uID, ["ForbidFlag"] = bool}
	--local entry = (g_DBTransDef["GasUseItemDB"])
	CallAccountAutoTrans(self.m_Conn.m_Account, "GasUseItemDB", "ForbidUseWeapon", CallBack, data)
end

--��ת����ǰ�Ĵ���
function CCharacterMediator:BeginChangeScene(Scene, fPos)
	local SceneId = Scene.m_SceneId
	ChangeSceneCancelLeaveGame(self.m_Conn)
	if self.m_Scene:GetLogicSceneName() ~= Scene:GetLogicSceneName() then
		--������Ŷ������͸ɵ�
		self:ClearPlayerActionState()
		--�ɵ������ٻ�npc
		self:ClearQuestBeckonNpc()
	end
	Scene.m_PlayerChangeInTbl[self.m_uID] = true
	self:ChangeScene(Scene.m_SceneName,SceneId, Scene.m_CoreScene, fPos)
end

function CCharacterMediator:ClearPlayerActionState()
	CActiveBehavior.RemovePlayerChildModel(self)
	CKickBehavior.CancelKickBehavior_S(self)
end

function CCharacterMediator:IsInBattleState()
	return self:CppGetCtrlState(EFighterCtrlState.eFCS_InBattle)
end

function CCharacterMediator:IsInForbitUseWeaponState()
	return self:CppGetCtrlState(EFighterCtrlState.eFCS_ForbitUseWeapon)
end

function CCharacterMediator:IsFirstTime(sFirstTimeName)
	if self.m_FirstTimeInfo then
		for i=1, table.getn(self.m_FirstTimeInfo) do
			if self.m_FirstTimeInfo[i]== sFirstTimeName then
				return false--��ʾ�Ѿ����һ����
			end
		end
	end
	return true--��ʾ�����ǵ�һ�����
end

--��Ϸ���õ���ָ����Ϣ
function CCharacterMediator:IsFirstTimeAndSendMsg(sFirstTimeName, iMsgID)
	if self:IsFirstTime(sFirstTimeName) then--�ж��Ƿ��ǵ�һ�ν���
		if not self.m_FirstTimeInfo then
			self.m_FirstTimeInfo = {}
		end
		--�޸��ڴ��е�����
		table.insert(self.m_FirstTimeInfo,sFirstTimeName)
		--��ͻ��˷�����ָ������Ϣ
		SystemFriendMsgToClient(self.m_Conn,iMsgID)
		--�����ݿ�
		local param = {}
		param["PlayerId"] = self.m_uID
		param["FirstTimeName"] = sFirstTimeName
		CallAccountAutoTrans(self.m_Conn.m_Account, "NoviceDirectDB", "InsertPlayerFirstFinishInfo", nil, param)
	end
end

--��ҵ�һ�ε�¼ʱ,����ָ����Ϣ
function CCharacterMediator:IsFirstTimeLoginAndSendMsg(sFirstTimeName, iMsgID)
	local function FirstTimeLoginAndSendMsg()
		if self:IsFirstTime(sFirstTimeName) then--�ж��Ƿ��ǵ�һ�ν���
			if not self.m_FirstTimeInfo then
				self.m_FirstTimeInfo = {}
			end
			--�޸��ڴ��е�����
			table.insert(self.m_FirstTimeInfo,sFirstTimeName)
			--��ͻ��˷�����ָ������Ϣ
			if iMsgID then
				SystemFriendMsgToClient(self.m_Conn,iMsgID)
			end
			--�����ݿ�
			local param = {}
			param["PlayerId"] = self.m_uID
			param["FirstTimeName"] = sFirstTimeName
			CallAccountLoginTrans(self.m_Conn.m_Account,"NoviceDirectDB", "InsertPlayerFirstFinishInfo", nil, param)
		end
	end
	apcall(FirstTimeLoginAndSendMsg)
end

--function CCharacterMediator:ShowHideQuestTraceBackWnd(oldSceneType,newSceneType)
--	if oldSceneType ~= 1 and newSceneType == 1 then
--		Gas2Gac:RetIsShowQuestTraceBack(self.m_Conn,true)
--	elseif oldSceneType == 1 and newSceneType ~= 1 then
--		Gas2Gac:RetIsShowQuestTraceBack(self.m_Conn,false)
--	end
--end

local function InitShadowProperties(pCharacter, Shadow)
	Shadow.m_Properties:SetMasterClass(pCharacter:CppGetClass())
	Shadow.m_Properties:SetMasterSex(pCharacter.m_Properties:GetSex())
	Shadow.m_Properties:SetHairResID(pCharacter.m_Properties:GetHairResID())
	Shadow.m_Properties:SetFaceResID(pCharacter.m_Properties:GetFaceResID())
	Shadow.m_Properties:SetWeaponIndexID(pCharacter.m_Properties:GetWeaponIndexID())
	Shadow.m_Properties:SetOffWeaponIndexID(pCharacter.m_Properties:GetOffWeaponIndexID())
	Shadow.m_Properties:SetOffWeaponBigID(pCharacter.m_Properties:GetOffWeaponBigID())
	Shadow.m_Properties:SetHorseResID(pCharacter.m_Properties:GetHorseResID())
	Shadow.m_Properties:SetHandsBehaviorName(pCharacter.m_Properties:GetHandsBehaviorName())
	Shadow.m_Properties:SetHorseType(pCharacter.m_Properties:GetHorseType())
	Shadow.m_Properties:SetBehaviorType(pCharacter.m_Properties:GetBehaviorType())
	Shadow.m_Properties:SetHeadResID(g_GetResIDByEquipPart(EEquipPart.eHead,pCharacter))
	Shadow.m_Properties:SetBodyResID(g_GetResIDByEquipPart(EEquipPart.eWear,pCharacter))
	Shadow.m_Properties:SetArmResID(g_GetResIDByEquipPart(EEquipPart.eHand,pCharacter))
	Shadow.m_Properties:SetShoeResID(g_GetResIDByEquipPart(EEquipPart.eShoe,pCharacter))
	Shadow.m_Properties:SetShoulderResID(g_GetResIDByEquipPart(EEquipPart.eShoulder,pCharacter))
	Shadow.m_Properties:SetWeaponResID(g_GetResIDByEquipPart(EEquipPart.eWeapon,pCharacter))
	Shadow.m_Properties:SetOffWeaponResID(g_GetResIDByEquipPart(EEquipPart.eAssociateWeapon,pCharacter))
	Shadow.m_Properties:SetBackResID(g_GetResIDByEquipPart(EEquipPart.eBack,pCharacter))
	Shadow.m_Properties:SetWeaponPhase(pCharacter.m_Properties:GetWeaponPhase())
	Shadow.m_Properties:SetOffWeaponPhase(pCharacter.m_Properties:GetOffWeaponPhase())
	Shadow.m_Properties:SetBodyPhase(pCharacter.m_Properties:GetBodyPhase())
	Shadow.m_Properties:SetHeadPhase(pCharacter.m_Properties:GetHeadPhase())
	Shadow.m_Properties:SetShoulderPhase(pCharacter.m_Properties:GetShoulderPhase())
	Shadow.m_Properties:SetArmPhase(pCharacter.m_Properties:GetArmPhase())
	Shadow.m_Properties:SetShoePhase(pCharacter.m_Properties:GetShoePhase())
	Shadow.m_Properties:SetIsShadow(true)
end

function CCharacterMediator:SetShadowProperties(Shadow)
	InitShadowProperties(self, Shadow)
	Gas2Gac:UpdateShadowModel(Shadow:GetIS(0), Shadow:GetEntityID())
end

function CCharacterMediator:GetPetName(PetName)
	if self.m_ServantNameInfo ~= nil then
		for i=1, #(self.m_ServantNameInfo) do
			if self.m_ServantNameInfo[i][1] == PetName then
				return self.m_ServantNameInfo[i][2]
			end
		end
	end
	return ""
end

function CCharacterMediator:SetServantShowNameFromClient(Connection, uServantID, sServantResName, sServantRealName)
	local data = {}
	data["PlayerId"]				= Connection.m_Player.m_uID
	data["ServantResName"]		= sServantResName
	data["ServantRealNameName"]	= sServantRealName
	local function callback(succ)
		local Player = Connection.m_Player
		if succ then
			if Player then
				local uTblSize = #(Player.m_ServantNameInfo)
				if uTblSize == 0 then
					table.insert(Player.m_ServantNameInfo,{sServantResName,sServantRealName})
				else
					for i=1, #(Player.m_ServantNameInfo) do
						if Player.m_ServantNameInfo[i][1] == sServantResName then
							Player.m_ServantNameInfo[i][2] = sServantRealName
						elseif i == #(Player.m_ServantNameInfo) then
							table.insert(Player.m_ServantNameInfo,{sServantResName,sServantRealName})
						end
					end
				end
				local pServant = CCharacterDictator_GetCharacterByID(uServantID)
				if pServant then
					pServant:SetRealName(sServantRealName)
				end
				MsgToConn(Connection, 197003)
			end
		else
			MsgToConn(Connection, 197004)
		end
	end	
	local FightSkillDB = "FightSkillDB"
	CallAccountManualTrans(Connection.m_Account, FightSkillDB, "Dbs_SetServantName", callback, data)
end

function CCharacterMediator.SendPlayerInfoToGac(PlayerInfoRes)
	if PlayerInfoRes then
		local RowNum = PlayerInfoRes:GetRowNum()
		local CharIDTbl = {}
		if RowNum > 0 then
			for i = 1,RowNum do
				local PlayerID = PlayerInfoRes(i,1)
				table.insert(CharIDTbl,PlayerID)
			end
	
			for i = 1,RowNum do 
				local PlayerID,PlayerName,PlayerClass,PlayerLevel,PlayerCamp = PlayerInfoRes(i,1),PlayerInfoRes(i,2),PlayerInfoRes(i,3),PlayerInfoRes(i,4),PlayerInfoRes(i,5)
				for n = 1, #(CharIDTbl) do
					Gas2GacById:ReturnCharInfo(CharIDTbl[n],PlayerID,PlayerName,PlayerClass,PlayerLevel,PlayerCamp)
				end
			end
		end
	end
end

function CCharacterMediator.SendFightingEvaluationToGac(FightingEvaluationRes)
	if FightingEvaluationRes then
		local RowNum = FightingEvaluationRes:GetRowNum()
		local CharIDTbl = {}
		if RowNum > 0 then
			for i = 1,RowNum do
				local PlayerID = FightingEvaluationRes(i,1)
				table.insert(CharIDTbl,PlayerID)
			end
			
			for i = 1,RowNum do 
				local PlayerID,FightingEvaluation = FightingEvaluationRes(i,1),FightingEvaluationRes(i,2)
				for n = 1, #(CharIDTbl) do
					Gas2GacById:ReturnFightingEvaluation(CharIDTbl[n],PlayerID,FightingEvaluation)
				end
			end						
		end
	end
end

function Gac2Gas:SetShowModeOfArmet(Conn, bIsShowArmet)
	local Player = Conn.m_Player
	if not Player then
		return
	end
	if Player.m_Properties then
		Player.m_Properties:SetShowArmet(bIsShowArmet)
	else
		LogErr("Gac2Gas:SetShowModeOfArmet ʱ�����,m_Properties ��δ��ʼ�����ͻ��˾�֪ͨ���������")
	end
	Gas2Gac:UpdateHeadModelByEntityID(Conn, Player:GetEntityID())
	Gas2Gac:UpdateHeadModelByEntityID(Player:GetIS(0), Player:GetEntityID())
end

function CCharacterMediator:AddPlayerAfflatusValue(uAfflatusValue)
	local Connection = self.m_Conn
	if not IsCppBound(Connection) then
		return
	end
	local Accout = Connection.m_Account
	if not IsCppBound(Accout) then
		return
	end
	if not IsNumber(uAfflatusValue) or uAfflatusValue <= 0 then
		return
	end
	local function CallBack(bSucc, uMsgId)
		if not bSucc and IsNumber(uMsgId) then
			MsgToConn(Connection,uMsgId)
		end
	end
	local data = {}
	data["char_id"] 			= self.m_uID
	data["uAfflatusValue"]		= uAfflatusValue
	
	CallAccountAutoTrans(Accout, "CharacterMediatorDB", "AddPlayerAfflatusValue", CallBack, data)
end

function CCharacterMediator:AddOffLineExpValue(uOffLineExpValue)
	local Connection = self.m_Conn
	if not IsCppBound(Connection) then
		return
	end
	local Accout = Connection.m_Account
	if not IsCppBound(Accout) then
		return
	end
	
	local data = {}
	data["char_id"] 			= self.m_uID
	data["uOffLineExpValue"]		= uOffLineExpValue
	
	CallAccountAutoTrans(Accout, "CharacterMediatorDB", "AddOffLineExpValue", nil, data)
end

function CCharacterMediator.SendResistanceValueToGac(Fb_Name, TeamID, PlayerID)
	local CharIDTbl = {}
	if TeamID ~= 0 then
		CharIDTbl = g_TeamMgr:GetMembers(TeamID)
	else
		CharIDTbl = {PlayerID}
	end
	for i = 1,#(CharIDTbl) do
		local player = g_GetPlayerInfo(CharIDTbl[i])
		if player then
			local NatureResistanceValue 		= player:CppGetPropertyValueByName(GetPropertyName("��Ȼ��ֵ"))
			local EvilResistanceValue 			= player:CppGetPropertyValueByName(GetPropertyName("���ڿ�ֵ"))
			local DestructionResistanceValue 	= player:CppGetPropertyValueByName(GetPropertyName("�ƻ���ֵ"))
			local Defence 						= player:CppGetPropertyValueByName(GetPropertyName("����ֵ"))
			for j = 1,#(CharIDTbl) do 
				Gas2GacById:SendResistanceValue(CharIDTbl[j],CharIDTbl[i],Fb_Name,NatureResistanceValue,EvilResistanceValue,DestructionResistanceValue,Defence) 
			end
		end
	end
end

function Gac2Gas:GetAfflatus_OffLineExp_Info(Conn)
	local Player = Conn.m_Player
	if not Player then
		return
	end
	
	local function callback(res)
		local CurOffLineExp 		= res["uCurOffLineExp"]
		local CurAfflatusValue		= res["uCurAfflatusValue"]
		local CurMoney				= res["uMoney"]
		Gas2Gac:InitPlayerAfflatusValue( Conn, CurOffLineExp, CurAfflatusValue, CurMoney, g_TestRevisionMaxLevel)	
	end
	
	local char_id = Player.m_uID
	local Accout = Conn.m_Account
	if not IsCppBound(Accout) then
		return
	end
	
	local data = {}
	data["char_id"] 	= char_id
	CallAccountManualTrans(Accout, "CharacterMediatorDB", "GetAfflatusValue_OffLineExp_MoneyInfo", callback, data)
end

function Gac2Gas:ExChangeAfflatus(Conn, uExchgValue)
	local Player = Conn.m_Player
	if not Player then
		return
	end
	
	local function callback(res)
		local bSuccess 				= res["bSuccess"]
		if bSuccess then
			local CurOffLineExp 		= res["uLeftOffLineExp"]
			local CurAfflatusValue		= res["uLeftAfflatusValue"]
			local CirMoney				= res["uLeftMoney"]
			local uExChgMoney			= res["uExChgMoney"]
			Gas2Gac:InitPlayerAfflatusValue( Conn, CurOffLineExp, CurAfflatusValue, CirMoney, g_TestRevisionMaxLevel)
			MsgToConn(Conn, 350004)
			
			--���Ѿ�����������ʱ��Ͳ��ٴ�����
			if res["uCurLevel"] then
				--��ͻ���ͬ������ֵ
				local AddExpTbl = {}
				AddExpTbl["Level"] 				= res["uCurLevel"]
				AddExpTbl["Exp"] 				= res["uCurExp"]
				AddExpTbl["AddExp"] 			= res["uAddExp"]
				AddExpTbl["uInspirationExp"] 	= 0
				CRoleQuest.AddPlayerExp_DB_Ret(Player, AddExpTbl)
			end			
		else
			local ErrMsgID = res["ErrMsg"]	
			MsgToConn(Conn, ErrMsgID)
		end	
	end
	
	local char_id = Player.m_uID
	local Accout = Conn.m_Account
	if not IsCppBound(Accout) then
		return
	end
	
	OnSavePlayerExpFunc({Player})
	
	local data = {}
	data["char_id"] 	= char_id
	data["ExchgValue"]	= uExchgValue
	CallAccountManualTrans(Accout, "CharacterMediatorDB", "ExChangeAfflatusValue", callback, data)
end

function Gas2GasDef:DoSkillInPlayerSet(Conn, uSetType,uTypeID,sSkillName,uSkillLevel,sExt)
	local PlayerSet
	if uSetType == 1 then 
		PlayerSet = g_AllPlayerSender
	elseif uSetType == 2 then
		PlayerSet = CampPlayerSenderTbl[uTypeID]
	elseif uSetType == 3 then
		PlayerSet = g_GasArmyCorpsMgr:GetArmyCorpsMsgSender(uTypeID)
	elseif uSetType == 4 then
		PlayerSet = g_GasTongMgr:GetTongMsgSender(uTypeID)
	end
	if PlayerSet then
	 	PlayerSet:DoSkill(sSkillName,uSkillLevel,sExt)
	 end
end

function CCharacterMediator:DoSkillInPlayerSet(Conn, uSetType,uTypeID,sSkillName,uSkillLevel,sExt)
	for server_id in pairs(g_ServerList) do
		Gas2GasAutoCall:DoSkillInPlayerSet(GetServerAutoConn(server_id), uSetType,uTypeID,sSkillName,uSkillLevel,sExt)
	end
end
