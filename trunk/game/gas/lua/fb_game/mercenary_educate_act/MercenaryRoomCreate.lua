
local GameProbability = {
			[1] = {1,15},--15%
			[2] = {16,55},--40%
			[3] = {56,80},--25%
			[4] = {81,95},--15%
			[5] = {96,100},--5%
			}

local GameTypeDeadTimes = {100, 100, 100, 100, 0}--ÿһ�����ͻ���ֵĴ���
local m_ToTalFloor = 4
local m_CloseFbTime = 20 --������,�˳�������ʱ��
local RewardFloorType = 5 --����5�ǽ�����
local DividedNum = 10
local ExtraExpPara = 2
CMercenaryRoomCreate = class()
--g_MercenaryRoomCreate = CMercenaryRoomCreate:new()
CMercenaryRoomCreate.GameState = 
{
	BeforeGame = "BeforeGame", 
	StartGame = "StartGame", 
	LoseGame = "GameEnd", 
	PrepareNextGame = "PrepareNextGame",
}
--g_MercenaryRoomCreate.m_DownTimeTick = {}

local function GetXiShu(FloorNum)
	local XS = (1+(0.1*(FloorNum-1))) * 100
	return XS
end

-- function CMercenaryRoomCreate:GetRandomGameID(Player,FloorNum)
function CMercenaryRoomCreate.GetRandomGameID(Player,FloorNum)
	local Level = Player:CppGetLevel()
--	local RandNum = math.random(1,100)
--	local GameType = 1
--	for i=1, #(GameProbability) do
--		if RandNum >= GameProbability[i][1]
--			and RandNum <= GameProbability[i][2] then
--			GameType = i
--			break
--		end
--	end
	local Scene = Player.m_Scene
	local MercInfo = nil
	
	if FloorNum == 1 then
		MercInfo = Player
		MercInfo.m_TempMercCardInfo = Player.m_MercCardInfo
	else
		MercInfo = Scene.m_MercenaryActionInfo
	end
	
	local GameTypeTbl = {}
	if MercInfo.m_IsRewardFloor then	-- ˢ������
		--for i=1, #(Player.m_MercenaryEduActTbl) do
		--	local ActionMgr = Player.m_MercenaryEduActTbl[i]
		for _, ActionMgr in pairs(MercInfo.m_MercenaryEduActTbl) do
			if ActionMgr.m_GameType == RewardFloorType then -- RewardFloorType�ǽ����ص�����
				if ActionMgr.m_MinLevel <= Level
					and ActionMgr.m_MinFloor <= FloorNum then
					--print("���뽱����"..ActionMgr.m_GameID)
					table.insert(GameTypeTbl,ActionMgr.m_GameID)
				end			
			end
		end	
	else	-- ˢ��ͨ��
		for i=1, #(MercInfo.m_TempMercCardInfo) do
			local ActionMgr = MercInfo.m_MercenaryEduActTbl[MercInfo.m_TempMercCardInfo[i]]
			if ActionMgr.m_GameType ~= RewardFloorType then	-- ��ͨ�ز����������
				--local SumSelTimes = Player.m_MercenaryEduActTbl.m_GameTypeTimes[ActionMgr.m_GameType]
				--if not SumSelTimes or (SumSelTimes < GameTypeDeadTimes[ActionMgr.m_GameType]) then
					if ActionMgr.m_MinLevel <= Level
						and ActionMgr.m_MinFloor <= FloorNum then
						
						--print("������ͨ"..ActionMgr.m_GameID)
						table.insert(GameTypeTbl,ActionMgr.m_GameID)
					end
				--end
			end
		end	
	end
	
	local GameID = 1
	if next(GameTypeTbl) then
		local RandNum = nil
		-- GMָ��
		if Player.GMGotoMercLevel then
			GameID = Player.GMGotoMercLevel 
			-- ������Χ
			if not g_MercenaryEduActMgr[GameID] then
				GameID = 1
			end
			return GameID
		else
			RandNum = math.random(1,#(GameTypeTbl))
			GameID = GameTypeTbl[RandNum]
			--print("ѡ��GameID = " .. GameID)
		end
		if MercInfo.m_IsRewardFloor then	-- ˢ������
			MercInfo.m_MercenaryEduActTbl[GameID] = nil
		elseif FloorNum ~= 1 then
			for i=1, #(MercInfo.m_TempMercCardInfo) do
				--��ѡ�����Ļ,���б���ȥ��
				if MercInfo.m_TempMercCardInfo[i] == GameID then
					table.remove(MercInfo.m_TempMercCardInfo,i)
					--print("ȥ����"..i)
					break
				end
			end
		end
	end
	--print("GameID "..GameID)
	return GameID
end

--�Ӽ���,��ȥ������
-- function CMercenaryRoomCreate:YbEduActAddOrResetSkill(Player, GameID, IsAdd)
function CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, GameID, IsAdd)
	if GameID and IsCppBound(Player) then
		local SkillTbl = nil
		if IsAdd then
			SkillTbl = g_MercenaryEduActMgr[GameID].m_LoadSkillTbl
			--�����ʱ����
			Player:RemoveAllTempSkill()
			Player:CancelCastingProcess()
		else
			SkillTbl = g_MercenaryEduActMgr[GameID].m_ResetSkillTbl
			--�����ʱ����
			Player:RemoveAllTempSkill()
			Player:CancelCastingProcess()
			--����������ŵĶ���
			Player:ClearPlayerActionState()
		end
		if SkillTbl then
			for _, sillName in ipairs(SkillTbl) do
				Player:PlayerDoFightSkillWithoutLevel(sillName)
			end
		end
	end
end

-- function CMercenaryRoomCreate:ClearDownTimeTick(Scene)
function CMercenaryRoomCreate.ClearDownTimeTick(Scene)
	if Scene.m_DownTimeTick then
		--print("delete Tick PlayerID:",PlayerId)
		UnRegisterTick(Scene.m_DownTimeTick)
		Scene.m_DownTimeTick = nil
	end
end

-- function CMercenaryRoomCreate:ClearAllTick(Scene)
function CMercenaryRoomCreate.ClearAllTick(Scene)
	if Scene.m_DownTimeTick then
		--print("delete Tick PlayerID:",PlayerId)
		UnRegisterTick(Scene.m_DownTimeTick)
		Scene.m_DownTimeTick = nil
	end

	if Scene.m_TimeOverTick then
		UnRegisterTick(Scene.m_TimeOverTick)
		Scene.m_TimeOverTick = nil
	end
	
	if Scene.m_DividuallyRewardTick then
		UnRegisterTick(Scene.m_DividuallyRewardTick)
		Scene.m_DividuallyRewardTick = nil
	end
end

-- function CMercenaryRoomCreate:GetPlayerBornPos(BornPoint, SelRoomNum)
function CMercenaryRoomCreate.GetPlayerBornPos(BornPoint, SelRoomNum)
	if g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum] then
		local Pos = CPos:new()
		Pos.x = g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum].DynamicPoint[1]--YbEducateActionTransport_Server[SelRoomNum]["DynamicPoint"][1]
		Pos.y = g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum].DynamicPoint[2]--YbEducateActionTransport_Server[SelRoomNum]["DynamicPoint"][2]
		Pos.x = Pos.x + BornPoint[1]
		Pos.y = Pos.y + BornPoint[2]
		return Pos
	else
		return BornPoint
	end
end

-- ������߻ָ���Ϸ
-- function CMercenaryRoomCreate:ResumeLoadYbActionInfo(Player)
function CMercenaryRoomCreate.ResumeLoadYbActionInfo(Player)
	local Scene = Player.m_Scene
	if IsTable(Scene.m_MercenaryActionInfo) then
		Scene.m_MercenaryActionInfo.m_IsGameEnd = nil
		local FloorNum = Scene.m_MercenaryActionInfo.m_FloorNum
		
		local MercenaryEduActMgr = nil
		local NowGameID = Scene.m_MercenaryActionInfo.m_GameID
		if NowGameID then
			MercenaryEduActMgr = g_MercenaryEduActMgr[NowGameID]
		end
		local SelRoomNum = Scene.m_MercenaryActionInfo.m_SelMercenaryRoomNum
		local Pos = CMercenaryRoomCreate.GetPlayerBornPos(MercenaryEduActMgr.m_BornPoint, SelRoomNum)
		Player:SetGridPosByTransport( Pos )
		--local DownTime = MercenaryEduActMgr.m_FitoutTime
		--Gas2Gac:RetShowYbEducateActInfoWnd(Player.m_Conn, MercenaryEduActMgr.m_RulesText, DownTime)
		local LifeNum = Scene.m_MercenaryActionInfo.m_LifeNum
		local MercMoney = Scene.m_MercenaryActionInfo.m_MercMoney
	
		local XS = GetXiShu(FloorNum)
		Gas2Gac:RetUpdateYbEduActInfo(Player.m_Conn, MercMoney, FloorNum, XS, m_ToTalFloor)
		
		-- �ж���Ϸ�Ľ׶�	
		if CMercenaryRoomCreate.IsInState(Scene, CMercenaryRoomCreate.GameState.BeforeGame) then   				-- ��Ϸ��ʼǰ
			CMercenaryRoomCreate.SendMusicType(Scene, CMercenaryRoomCreate.GameState.BeforeGame)
			local DownTime = MercenaryEduActMgr.m_FitoutTime
			Gas2Gac:RetShowYbEducateActInfoWnd(Player.m_Conn, MercenaryEduActMgr.m_RulesText, DownTime, NowGameID)
			
			--�������г����е���Ϣ
			local function TickBack(Tick, param)
				local Player = param[1]
				CMercenaryRoomCreate.ClearDownTimeTick(Scene)
				
				if IsCppBound(Player) and Player.m_Scene.m_MercenaryActionInfo then
					CMercenaryRoomCreate.LoadYbEduActNpcOrObj(Player, NowGameID)
				end
			end
			
			CMercenaryRoomCreate.ClearDownTimeTick(Scene)
			local data = {Player}
			Scene.m_DownTimeTick = RegisterTick("XiuXingTaInfoTick",TickBack,DownTime*1000,data)
				
		elseif CMercenaryRoomCreate.IsInState(Scene, CMercenaryRoomCreate.GameState.StartGame) then				-- ��Ϸ��
			CMercenaryRoomCreate.SendMusicType(Scene, CMercenaryRoomCreate.GameState.StartGame)
			Gas2Gac:RetRecordGameInfo(Player.m_Conn, MercenaryEduActMgr.m_RulesText, NowGameID)
			-- �ұ߻˵��
			Gas2Gac:RetShowSmallActInfoWnd(Player.m_Conn, NowGameID)
			
			-- �ָ�����
			local OveTypeTempTbl = Scene.m_MercenaryActionInfo.m_OverTypeTempTbl
			for NpcName, Score in pairs(Scene.m_MercenaryActionInfo.m_OverTypeTbl) do
				if NpcName ~= "����ʱ��" and NpcName ~= "��ʱ" then
					local NameLocal = OveTypeTempTbl[NpcName].Local
					local CountNum = OveTypeTempTbl[NpcName].Num
					if Score == true then
						Gas2Gac:SendResumeNum(Player.m_Conn, true, NameLocal, CountNum, NowGameID)
					else
						Gas2Gac:SendResumeNum(Player.m_Conn, false, NameLocal, CountNum - Score, NowGameID)
					end
				end
			end
			Gas2Gac:RetUpDateSmallInfo(Player.m_Conn)
			CMercenaryRoomCreate.ResumeYbActGame(Player, MercenaryEduActMgr)
			
			-- �Ӽ���
			CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, NowGameID, true)
		elseif CMercenaryRoomCreate.IsInState(Scene, CMercenaryRoomCreate.GameState.GameEnd) then				-- ÿ����Ϸ������
			CMercenaryRoomCreate.SendMusicType(Scene, CMercenaryRoomCreate.GameState.GameEnd)
			-- ͷ�ϼ���Ч
			local playerInfo = Scene.m_MercenaryActionInfo
			local RoomNum = playerInfo.m_SelMercenaryRoomNum
			local SwitchPos = {}
			SwitchPos.x = g_MercenaryEduActMgr.m_RoomPoints[RoomNum].SwitchPoint[1]
			SwitchPos.y = g_MercenaryEduActMgr.m_RoomPoints[RoomNum].SwitchPoint[2]
--			print("���ߣ�SwitchPos.x:"..SwitchPos.x.."  SwitchPos.y"..SwitchPos.y)
			Gas2Gac:SetCompassHeadDir(Player.m_Conn, 2, SwitchPos.x*EUnits.eGridSpanForObj, SwitchPos.y*EUnits.eGridSpanForObj)
			Gas2Gac:RetRecordGameInfo(Player.m_Conn, MercenaryEduActMgr.m_RulesText, NowGameID)
			--���������,�ͼ���
			if (LifeNum > 0 and FloorNum <= m_ToTalFloor) then
				--����һ����ʾ���,���Ƿ�Ҫ����
				local Is15Floor = false
				-- �ұ߻˵��
--				Gas2Gac:RetShowSmallActInfoWnd(Player.m_Conn, NowGameID)
				-- ���Ϣ
				Gas2Gac:RetIsContinueYbXlAction(Player.m_Conn,LifeNum,Is15Floor)
				
--				-- �ָ�����
--				local OveTypeTempTbl = Scene.m_MercenaryActionInfo.m_OverTypeTempTbl
--				for NpcName, Score in pairs(Scene.m_MercenaryActionInfo.m_OverTypeTbl) do
--					if NpcName ~= "����ʱ��" then
--						local NameLocal = OveTypeTempTbl[NpcName].Local
--						local CountNum = OveTypeTempTbl[NpcName].Num
--						if Score == true then
--							Gas2Gac:SendResumeNum(Player.m_Conn, true, NameLocal, CountNum, NowGameID)
--						else
--							-- �ж��Ƿ��Ǳ���NPC�� �Ƿ�ɹ�
--							if Scene.m_MercenaryActionInfo.m_IsProtectNpc then
--								if Scene.m_MercenaryActionInfo.m_GameIsSucc then
--									Gas2Gac:SendResumeNum(Player.m_Conn, false, NameLocal, 1, NowGameID)
--								end
--							else
--								Gas2Gac:SendResumeNum(Player.m_Conn, false, NameLocal, CountNum - Score, NowGameID)	
--							end
--						end
--					end
--				end
--				Gas2Gac:RetUpDateSmallInfo(Player.m_Conn)
				
				-- ȥ�����õļ���
				CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, NowGameID, false)
			--else
				-- ���>=m_ToTalFloor���˳���Ϸ
				--CMercenaryRoomCreate.ClearAllTick(Scene)
				--CMercenaryRoomCreate.GameEndGiveAward(Player, nil)
			end
		elseif CMercenaryRoomCreate.IsInState(Scene, CMercenaryRoomCreate.GameState.PrepareNextGame) then	-- ������غ�׼��������һ��
			CMercenaryRoomCreate.SendMusicType(Scene, CMercenaryRoomCreate.GameState.PrepareNextGame)
			Gas2Gac:RetRecordGameInfo(Player.m_Conn, MercenaryEduActMgr.m_RulesText, NowGameID)
			if LifeNum > 0 and FloorNum < m_ToTalFloor then
				-- �ұ߻˵��
--				Gas2Gac:RetShowSmallActInfoWnd(Player.m_Conn, NowGameID)
				-- ���Ϣ
				Gas2Gac:RetIsContinueYbXlAction(Player.m_Conn,LifeNum,Is15Floor)
				-- ȥ�����õļ���
				CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, NowGameID, false)
			else
				-- �����һ�㲻�ǽ�������� >=m_ToTalFloor��,���˳���Ϸ
				local IsRewardFloor = CMercenaryEducateAct.IsNextRewardFloor(Scene)
				if not IsRewardFloor then
					CMercenaryRoomCreate.ClearAllTick(Scene)
					--AwardItemTbl = GetEndGiveItem(Level)
					CMercenaryRoomCreate.GameEndGiveAward(Player, nil)
				end
			end
		end
		
		if IsCppBound(Player) then
			Player:SetGameCamp(MercenaryEduActMgr.m_GameCamp)
		else
			return
		end
	end
end

--���ˢ����(��һ�ν���,�Ͳ�Trap)
-- function CMercenaryRoomCreate:RandomLoadYbActionInfo(Player, SelRoomNum)
function CMercenaryRoomCreate.RandomLoadYbActionInfo(Player, SelRoomNum)
	local Scene = Player.m_Scene
	if IsTable(Scene.m_MercenaryActionInfo) then
		
		-- �ж��Ƿ��ǽ�����
		if Scene.m_MercenaryActionInfo.m_IsRewardFloor then
			--Scene.m_MercenaryActionInfo.m_FloorNum = "������"
		else
			Scene.m_MercenaryActionInfo.m_FloorNum = Player.m_Scene.m_MercenaryActionInfo.m_FloorNum + 1
			--print("+1��Ϊ "..Scene.m_MercenaryActionInfo.m_FloorNum )
		end
		
		Scene.m_MercenaryActionInfo.m_IsGameEnd = nil

		local FloorNum = Scene.m_MercenaryActionInfo.m_FloorNum
		
		-- �õ�GameID
		local GameID = nil
		local MercenaryEduActMgr = nil
		if Player.m_TempYbGameID then		-- ��һ�ν���
			GameID = Player.m_TempYbGameID
			MercenaryEduActMgr = g_MercenaryEduActMgr[GameID]
			Player.m_TempYbGameID = nil
		else
--			if Scene.m_MercenaryActionInfo.IsCurrFloor then 	-- ����ظ���ս��һ��
--				GameID = Scene.m_MercenaryActionInfo.m_GameID
--				Scene.m_MercenaryActionInfo.IsCurrFloor = false
--			else	-- �µ�һ��
				GameID = CMercenaryRoomCreate.GetRandomGameID(Player, FloorNum)	
				Scene.m_MercenaryActionInfo.m_GameID = GameID	
--			end

			MercenaryEduActMgr = g_MercenaryEduActMgr[GameID]
			local Pos = CMercenaryRoomCreate.GetPlayerBornPos(MercenaryEduActMgr.m_BornPoint, SelRoomNum)
			--print("---��ʼ����---  x: "..Pos.x.."  y: "..Pos.y)
			Player:SetGridPosByTransport( Pos )
		end
		
		Scene.m_MercenaryActionInfo.m_SelMercenaryRoomNum = SelRoomNum
		Scene.m_MercenaryActionInfo.m_GameID = GameID
		
		-- ����
		local DownTime = MercenaryEduActMgr.m_FitoutTime
		Gas2Gac:RetShowYbEducateActInfoWnd(Player.m_Conn, MercenaryEduActMgr.m_RulesText, DownTime, GameID)					
		local LifeNum = Player.m_Scene.m_MercenaryActionInfo.m_LifeNum
		local SuccTimes = Scene.m_MercenaryActionInfo.m_SuccTimes
		--Scene.m_MercenaryActionInfo.m_MercMoney = Scene.m_MercenaryActionInfo.m_MercMoney + Player:CppGetLevel()
		local MercMoney = Scene.m_MercenaryActionInfo.m_MercMoney
		local XS = GetXiShu(FloorNum)
		if Scene.m_MercenaryActionInfo.m_IsRewardFloor then
			Gas2Gac:RetUpdateYbEduActInfo(Player.m_Conn, MercMoney, "������", XS, m_ToTalFloor)
		else
			Gas2Gac:RetUpdateYbEduActInfo(Player.m_Conn, MercMoney, FloorNum, XS, m_ToTalFloor)
		end
		if IsCppBound(Player) then
			Player:SetGameCamp(MercenaryEduActMgr.m_GameCamp)
		else
			return
		end
		
		--�������г����е���Ϣ
		local function TickBack(Tick, param)
			local Player = param[1]
			CMercenaryRoomCreate.ClearDownTimeTick(Scene)
			
			if IsCppBound(Player) and Player.m_Scene.m_MercenaryActionInfo then
				CMercenaryRoomCreate.LoadYbEduActNpcOrObj(Player, GameID)
			end
		end
		
		CMercenaryRoomCreate.ClearDownTimeTick(Scene)
		local data = {Player}
		Scene.m_DownTimeTick = RegisterTick("XiuXingTaInfoTick",TickBack,DownTime*1000,data)
	end
end

-- function CMercenaryRoomCreate:BeginYbEducateAction(Conn)
function CMercenaryRoomCreate.BeginYbEducateAction(Conn)
	if IsCppBound(Conn) and IsCppBound(Conn.m_Player) then
		local Player = Conn.m_Player
		local Scene = Player.m_Scene
		if Scene:GetSceneType() == 14 and Scene.m_MercenaryActionInfo then
			-- �����ʱ����������BeforeGame״̬����Դ���Ϣ
			if not CMercenaryRoomCreate.IsInState(Player.m_Scene, CMercenaryRoomCreate.GameState.BeforeGame) then 
				return
			end
				
			CMercenaryRoomCreate.ClearDownTimeTick(Player.m_Scene)
			
			local GameID = Player.m_Scene.m_MercenaryActionInfo.m_GameID
			
			--�������г����е���Ϣ
			CMercenaryRoomCreate.LoadYbEduActNpcOrObj(Player, GameID)
		end
	end
end

-- function CMercenaryRoomCreate:GetDynamicPoint(SelRoomNum)
function CMercenaryRoomCreate.GetDynamicPoint(SelRoomNum)
	if g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum] then
		local Pos = {}
		Pos[1] = g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum].DynamicPoint[1]
		Pos[2] = g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum].DynamicPoint[2]
		return Pos
	end
end

--�������г����е���Ϣ(��ʼ����)
--function CMercenaryRoomCreate:LoadYbEduActNpcOrObj(Player, GameID)
function CMercenaryRoomCreate.LoadYbEduActNpcOrObj(Player, GameID)
	local Scene = Player.m_Scene
	if not CMercenaryRoomCreate.IsInState(Scene, CMercenaryRoomCreate.GameState.BeforeGame) then   				-- ������Ϸ��ʼǰ����ˢ��
		LogErr("����������Ϸ����ʱˢ��һ�صĹ֣�", Player.m_Conn)
		return
	end
	
	--CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, GameID, true)
	local MercenaryEduActMgr = g_MercenaryEduActMgr[GameID]
	local NpcFilePath = MercenaryEduActMgr.m_NpcFilePath
	local centerPos = CMercenaryRoomCreate.GetDynamicPoint(Scene.m_MercenaryActionInfo.m_SelMercenaryRoomNum)
	Scene.m_CenterPos = centerPos
	--�������еĽ����������������
	Scene.m_MercenaryActionInfo.m_OverTypeTbl = {}
	Scene.m_MercenaryActionInfo.m_OverTypeTempTbl = {}
	for i, tbl in pairs(MercenaryEduActMgr.OverTypeTbl) do
		Scene.m_MercenaryActionInfo.m_OverTypeTbl[tbl[1]] = tbl[2]
		Scene.m_MercenaryActionInfo.m_OverTypeTempTbl[tbl[1]] = {}
		Scene.m_MercenaryActionInfo.m_OverTypeTempTbl[tbl[1]].Num = tbl[2]
		Scene.m_MercenaryActionInfo.m_OverTypeTempTbl[tbl[1]].Local = i
	end
	
	-- �������е�ʧ���������������
	if MercenaryEduActMgr.LoseGameTypeTbl then	
		Scene.m_MercenaryActionInfo.m_LoseGameTypeTbl = {}
		Scene.m_MercenaryActionInfo.m_LoseGameTypeTempTbl = {}
		for i, tbl in pairs(MercenaryEduActMgr.LoseGameTypeTbl) do
			if tbl[1] == "NPC����" then
				tbl[2] = 0
			end
			Scene.m_MercenaryActionInfo.m_LoseGameTypeTbl[tbl[1]] = tbl[2]
			Scene.m_MercenaryActionInfo.m_LoseGameTypeTempTbl[tbl[1]] = {}
			Scene.m_MercenaryActionInfo.m_LoseGameTypeTempTbl[tbl[1]].Num = tbl[2]
			Scene.m_MercenaryActionInfo.m_LoseGameTypeTempTbl[tbl[1]].Local = i
		end	
	end
	
	--Ϊ�˸�Ҫ���������ϼ�һ����Ҷ���,Ҫ���޷�֪��,Ҫ����������˭
	local OverTbl = Scene.m_MercenaryActionInfo.m_OverTypeTbl
	Scene.m_MercenaryActionInfo.m_IsProtectNpc = false
	if OverTbl["����ʱ��"] then
		if not Scene.m_MercenaryActSaveNpcTbl then
			Scene.m_MercenaryActSaveNpcTbl = {}
		end
		for NpcName,_ in pairs(OverTbl) do
			if NpcName ~= "����ʱ��" then
				table.insert(Scene.m_MercenaryActSaveNpcTbl,NpcName)				
			end
		end
		Scene.m_MercenaryActionInfo.m_IsProtectNpc = true
	end
	
	local LoseGameType = Scene.m_MercenaryActionInfo.m_LoseGameTypeTbl
	if LoseGameType then
		if LoseGameType["NPC����"] then
			if not Scene.m_MercenaryActSaveNpcTbl  then
				Scene.m_MercenaryActSaveNpcTbl = {}
			end
			for NpcName,_ in pairs(LoseGameType) do
				if NpcName ~= "NPC����" then
					table.insert(Scene.m_MercenaryActSaveNpcTbl,NpcName)				
				end
			end
			Scene.m_MercenaryActionInfo.m_IsProtectNpc = true
		end
	end
	
	
	g_DynamicCreateMgr:Create(Scene, NpcFilePath, centerPos)
	
	CMercenaryRoomCreate.BeginYbActGame(Player, MercenaryEduActMgr)
	
	local Pos = CMercenaryRoomCreate.GetPlayerBornPos(MercenaryEduActMgr.m_BornPoint, Scene.m_MercenaryActionInfo.m_SelMercenaryRoomNum)
--	print("---��ʼ����---  x: "..Pos.x.."  y: "..Pos.y)
	Player:SetGridPosByTransport( Pos )
end

-- function CMercenaryRoomCreate:BeginYbActGame(Player, MercenaryEduActMgr)
function CMercenaryRoomCreate.BeginYbActGame(Player, MercenaryEduActMgr)
	local Scene = Player.m_Scene
	CMercenaryRoomCreate.SetGameState(Scene, CMercenaryRoomCreate.GameState.StartGame)
	CMercenaryRoomCreate.ClearDownTimeTick(Scene)
	local OverTbl = Player.m_Scene.m_MercenaryActionInfo.m_OverTypeTbl
	local DownTime = OverTbl["��ʱ"] or OverTbl["����ʱ��"]
	
	-- ��¼��Ϸ����ʱ��
	Scene.m_MercenaryActionInfo.m_BeginGameTime = math.floor(GetProcessTime() / 1000)
	Scene.m_MercenaryActionInfo.m_CurGameLastTime = nil
	if IsNumber(DownTime) and DownTime > 0 then
--		local nowdate = os.date("*t")
--		local nowmin = nowdate.min
--		local nowsec = nowdate.sec
--	
--		Scene.m_MercenaryActionInfo.m_BeginGameTime = nowmin*60+nowsec
		--Scene.m_MercenaryActionInfo.m_BeginGameTime2 = GetProcessTime()/1000
		Gas2Gac:RetBeginYbEduActGame(Player.m_Conn, DownTime)
		local data = {Scene, MercenaryEduActMgr, Player.m_Conn}

		if Scene.m_TimeOverTick then
			UnRegisterTick(Scene.m_TimeOverTick)
			Scene.m_TimeOverTick = nil
		end

		Scene.m_TimeOverTick = RegClassTick("XiuXingTaBeginTick",CMercenaryRoomCreate.TimeOver,DownTime*1000,self,data)
	end
--	Scene.m_Decreased = false
end

-- function CMercenaryRoomCreate:ResumeYbActGame(Player, MercenaryEduActMgr)
function CMercenaryRoomCreate.ResumeYbActGame(Player, MercenaryEduActMgr)
	local Scene = Player.m_Scene
	local OverTbl = Player.m_Scene.m_MercenaryActionInfo.m_OverTypeTbl
	local DownTime = OverTbl["��ʱ"] or OverTbl["����ʱ��"]
	if not DownTime or IsBoolean(DownTime) then
		return
	end
	
	-- ����ʣ���ʱ��
--	local Scene = Player.m_Scene	
--	local PlayerId = Player.m_uID
--	local nowdate = os.date("*t")
--	local nowmin = nowdate.min
--	local nowsec = nowdate.sec
--	
--	local Interval = DownTime - (nowmin*60+nowsec) + Scene.m_MercenaryActionInfo.m_BeginGameTime
	local Interval = DownTime - math.floor(GetProcessTime() / 1000) + Scene.m_MercenaryActionInfo.m_BeginGameTime
--	print("Interval  "..Interval.."  DownTime"..DownTime)
	if Interval > 0 then
		Gas2Gac:RetBeginYbEduActGame(Player.m_Conn, Interval)	--��ʼ����ʱ
		if Scene.m_TimeOverTick then
			UnRegisterTick(Scene.m_TimeOverTick)
			Scene.m_TimeOverTick = nil
		end
		local data = {Scene, MercenaryEduActMgr}
		--CMercenaryRoomCreate.m_DownTimeTick[PlayerId] = RegClassTick("YbActionBeginTick",CMercenaryRoomCreate.TimeOver,Interval*1000,self,data)
		Scene.m_TimeOverTick = RegClassTick("XiuXingTaBeginTick",CMercenaryRoomCreate.TimeOver,Interval*1000,self,data)
	else
		local data = {Scene, MercenaryEduActMgr}
		CMercenaryRoomCreate.TimeOver(nil, data)
	end
end

--ʱ�䵽��,����
function CMercenaryRoomCreate:TimeOver(Tick, data)
	local Scene = data[1]
	local MercenaryEduActMgr = data[2]
	local Conn = data[3]
	if Scene and Scene.m_MercenaryActionInfo then
		
		CMercenaryRoomCreate.ClearAllTick(Scene)
		
		if Scene then
			
			local OverTbl = Scene.m_MercenaryActionInfo.m_OverTypeTbl
			if OverTbl["��ʱ"] then
				OverTbl["��ʱ"] = true
				if MercenaryEduActMgr.IsOverFun(OverTbl) then
					--print("CMercenaryRoomCreate.GameEnd(Scene, false)")
					CMercenaryRoomCreate.GameEnd(Scene, false, true)				
				end
			else
				OverTbl["����ʱ��"] = true
				CMercenaryRoomCreate.GameEnd(Scene, true)
				
				if IsCppBound(Conn) then
					local GameID = Scene.m_MercenaryActionInfo.m_GameID
					Gas2Gac:RetYbEducateActShowMsg(Conn, GameID, 2, 1, 1)--NPC(1/1)��
				end
				
			end
			
		end
		
	end
end

-- function CMercenaryRoomCreate:SendKillNpcNumMsgByName(Player, OverTypeTbl, Name)
function CMercenaryRoomCreate.SendKillNpcNumMsgByName(Player, OverTypeTbl, Name)
	if not IsCppBound(Player) then
		return
	end
	
	local Conn = Player.m_Conn
	local Scene = Player.m_Scene
	local OveTypeTempTbl = Scene.m_MercenaryActionInfo.m_OverTypeTempTbl
	local LoseGameTempTbl = Scene.m_MercenaryActionInfo.m_LoseGameTypeTempTbl
	local GameID = Scene.m_MercenaryActionInfo.m_GameID
	local Num = OverTypeTbl[Name]
	if Name ~= "��ʱ" and Name ~= "����ʱ��" then
		if OveTypeTempTbl[Name] then
			local CountNum = OveTypeTempTbl[Name].Num
			local NameLocal = OveTypeTempTbl[Name].Local
			if Num == true then
				Num = 0
			end
			Gas2Gac:RetYbEducateActShowMsg(Conn, GameID, NameLocal, CountNum-Num, CountNum)--NPC(2/5)��
		elseif LoseGameTempTbl[Name] then 
			local CountNum = LoseGameTempTbl[Name].Num
			local NameLocal = LoseGameTempTbl[Name].Local
			if Num == true then
				Num = 0
			end
			Gas2Gac:RetYbEducateActShowLoseGameMsg(Conn, GameID, NameLocal, CountNum-Num, CountNum)--NPC(2/5)��
		end
		--MsgToConn(Player.m_Conn, 3604,Name,CountNum-Num,CountNum)
	end
end

-- function CMercenaryRoomCreate:SendKillNpcNumMsg(Player, OverTypeTbl)
function CMercenaryRoomCreate.SendKillNpcNumMsg(Player, OverTypeTbl)
	if not IsCppBound(Player) then
		return
	end
	
	local Conn = Player.m_Conn
	local Scene = Player.m_Scene
	local OveTypeTempTbl = Scene.m_MercenaryActionInfo.m_OverTypeTempTbl
	local LoseGameTempTbl = Scene.m_MercenaryActionInfo.m_LoseGameTypeTempTbl
	local GameID = Scene.m_MercenaryActionInfo.m_GameID

	for Name,Num in pairs(OverTypeTbl) do
		if Name ~= "��ʱ" and Name ~= "����ʱ��" and Name ~= "NPC����" then
			if OveTypeTempTbl[Name] then
				local CountNum = OveTypeTempTbl[Name].Num
				local NameLocal = OveTypeTempTbl[Name].Local
				if Num == true then
					Num = 0
				end
				Gas2Gac:RetYbEducateActShowMsg(Conn, GameID, NameLocal, CountNum-Num, CountNum)--NPC(2/5)��
			elseif LoseGameTempTbl[Name] then 
				local CountNum = LoseGameTempTbl[Name].Num
				local NameLocal = LoseGameTempTbl[Name].Local
				if Num == true then
					Num = 0
				end
				Gas2Gac:RetYbEducateActShowLoseGameMsg(Conn, GameID, NameLocal, CountNum-Num, CountNum)--NPC(2/5)��
			end
			--MsgToConn(Player.m_Conn, 3604,Name,CountNum-Num,CountNum)
		end
	end
end

--ÿ��ɱ�ֺ����
--��NPC��������Ҳ�Trap��,���������
-- function CMercenaryRoomCreate:KillTargetAddNum(Scene, NpcName, Score)
function CMercenaryRoomCreate.KillTargetAddNum(Scene, NpcName, Score)
	if Scene and Scene.m_MercenaryActionInfo then
		if not Score then
			Score = 1
		end
		local GameID = Scene.m_MercenaryActionInfo.m_GameID
		local OverTbl = Scene.m_MercenaryActionInfo.m_OverTypeTbl
		local LoseGameTbl = Scene.m_MercenaryActionInfo.m_LoseGameTypeTbl
		
		-- ��ѯ��ң��������ǵ���
		local Player = nil		
		for playerID, player in pairs(Scene.m_tbl_Player) do
			Player = player
		end
		
		local OverTypeMgr = g_MercenaryEduActMgr[GameID].m_OverType -- MercenaryEducateAction_Server(GameID, "OverType")
		local HaveAnd = string.find(OverTypeMgr, "and")
		if OverTbl[NpcName] then
			if OverTbl[NpcName] ~= true then
				OverTbl[NpcName] = OverTbl[NpcName] - Score

				if OverTbl[NpcName] > 0 then	
					if HaveAnd then			
						CMercenaryRoomCreate.SendKillNpcNumMsg(Player, OverTbl)
					else
						CMercenaryRoomCreate.SendKillNpcNumMsgByName(Player, OverTbl, NpcName)
					end
				else
					if OverTbl[NpcName] == 0 then
						if HaveAnd then			
							CMercenaryRoomCreate.SendKillNpcNumMsg(Player, OverTbl)
						else
							CMercenaryRoomCreate.SendKillNpcNumMsgByName(Player, OverTbl, NpcName)
						end
						OverTbl[NpcName] = true
						if g_MercenaryEduActMgr[GameID].IsOverFun(OverTbl) then
							CMercenaryRoomCreate.GameEnd(Scene, true)
						end
					elseif OverTbl[NpcName] < 0 then
						OverTbl[NpcName] = true
						--С��0��,ֻ�б���ˢ�����Ļ��,�����Ĳ����,Ҳ���������(����ֻ�ܱ���һ��ˢ����)
						CMercenaryRoomCreate.GameEnd(Scene, false)--ˢ��������,��ʧ��
					end
				end
				
			end
		end
		
		if LoseGameTbl and LoseGameTbl[NpcName] then
			if LoseGameTbl[NpcName] ~= true then
				LoseGameTbl[NpcName] = LoseGameTbl[NpcName] - Score
				
				if LoseGameTbl[NpcName] > 0 then
					CMercenaryRoomCreate.SendKillNpcNumMsg(Player, LoseGameTbl)
				else
					if LoseGameTbl[NpcName] == 0 then
						CMercenaryRoomCreate.SendKillNpcNumMsg(Player, LoseGameTbl)
						LoseGameTbl[NpcName] = true
						CMercenaryRoomCreate.GameEnd(Scene, false)
					end
				end
				
			end
		end	
		
	end
end

--�����ɼ�,���������
-- function CMercenaryRoomCreate:CollAddNum(Player, NpcName, Num)
function CMercenaryRoomCreate.CollAddNum(Player, NpcName, Num)
	if Player and Player.m_Scene.m_MercenaryActionInfo then
		local Scene = Player.m_Scene
		local GameID = Scene.m_MercenaryActionInfo.m_GameID
		local OverTbl = Scene.m_MercenaryActionInfo.m_OverTypeTbl
		if OverTbl[NpcName] then
			if OverTbl[NpcName] ~= true then
				OverTbl[NpcName] = OverTbl[NpcName] - Num
				
				if OverTbl[NpcName] > 0 then
					if Num == 3 then
						Gas2Gac:UseItemPlayerEffect(Player.m_Conn,"fx/setting/other/other/xiaoyouxi/create.efx","xiaoyouxi/create")
					end
					CMercenaryRoomCreate.SendKillNpcNumMsg(Player, OverTbl)
				else
					OverTbl[NpcName] = true
					CMercenaryRoomCreate.SendKillNpcNumMsg(Player, OverTbl)
					if g_MercenaryEduActMgr[GameID].IsOverFun(OverTbl) then
						CMercenaryRoomCreate.GameEnd(Scene, true)
					end
				end
				
			end
		end
	end
end

local function XiuXingTaReborn(Player)
	if IsCppBound(Player) and not Player:CppIsLive() then
		Player:Reborn(0.1)
	end
end

--����ڸ���������
-- function CMercenaryRoomCreate:PlayerDeadInYbActFb(Attacker, Player)
function CMercenaryRoomCreate.PlayerDeadInYbActFb(Attacker, Player)
	local Scene = Player.m_Scene
	if Scene.m_MercenaryActionInfo then
		
		if not Scene.m_MercenaryActionInfo.m_IsGameEnd then
			CMercenaryRoomCreate.GameEnd(Scene, false)
		else
			if IsCppBound(Player) and not Player:CppIsLive() then
				RegisterOnceTick(Scene, "m_XiuXingTaRebornTick", XiuXingTaReborn, 2000, Player) -- ����󸴻�		
			end
		end
		
	end
end

-- function CMercenaryRoomCreate:SendPlayerDeadMsg(Player)
function CMercenaryRoomCreate.SendPlayerDeadMsg(Player)
	if not IsCppBound(Player) then
		return
	end
	local Scene = Player.m_Scene
	if Scene.m_MercenaryActionInfo then
		local LifeNum = Scene.m_MercenaryActionInfo.m_LifeNum
		local FloorNum = Scene.m_MercenaryActionInfo.m_FloorNum
		--���������,�ͼ���
		if LifeNum > 0 and FloorNum < m_ToTalFloor then
			--����һ����ʾ���,���Ƿ�Ҫ����
			local Is15Floor = false
			--if FloorNum >= m_ToTalFloor then
			--	Is15Floor = true
			--end
			--CMercenaryRoomCreate.FinishGameGiveAward(Player,true)
			
			-- �ĳ�ֱ��3��󸴻��ѯ������Ƿ�����
			--Gas2Gac:RetIsContinueYbXlAction(Player.m_Conn,LifeNum,Is15Floor)
			--Scene.m_MercenaryActionInfo.m_LifeNum = LifeNum - 1  -- ȥ���������ƣ��������������
			CMercenaryRoomCreate.SetGameState(Scene, CMercenaryRoomCreate.GameState.PrepareNextGame)
		else
			--����һ����ʾ���,Ȼ������ѡ���˳�����
			--�ӹ���,������ʾ������Ʒ�����,����ʲô��ʾʲô
			
			if LifeNum <=0 then
				Scene.m_IsLoseGame = true
			end
			Scene.m_MercenaryActionInfo.m_FloorNum = m_ToTalFloor--��Ϊm_ToTalFloor,��ʾ�����
		end
		
--	RegisterOnceTick(Scene, "m_XiuXingTaRebornTick", XiuXingTaReborn, 3000, Player) -- ����󸴻�
	end
end

local function DestroyAllFromScene(SceneID)
	g_NpcBornMgr:DeleteAllNpcExceptServant(SceneID)
	DestroyOneSceneIntObj(SceneID)
	DestroyOneSceneTrap(SceneID)
	local Scene = g_SceneMgr:GetScene(SceneID)
	if Scene then
		UnRegisterObjOnceTick(Scene)
	end
end

-- ɾ�����������ж����󣬴�������
local function DelAllAndCreateSwichTick(data)
	local Scene = data.m_Scene
	local Player = data.m_Player
	local SceneID = Scene.m_MercenaryActionInfo.m_FbSceneID
	DestroyAllFromScene(SceneID)

	--ȥ�����õļ���-------
	if Scene.m_MercenaryActionInfo.m_GameID then
		CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, Scene.m_MercenaryActionInfo.m_GameID, false)
	end
	-- ˢ������
	CMercenaryEducateAct.CreateFbTrap(Scene)
	if IsCppBound(Player) and not Player:CppIsLive() then
		--Player:Reborn(0.1)
		RegisterOnceTick(Scene, "m_XiuXingTaRebornTick", XiuXingTaReborn, 2000, Player) -- ����󸴻�		
	end
end

-- function CMercenaryRoomCreate:GameEnd(Scene, IsSucc, IsTimeOver)
function CMercenaryRoomCreate.GameEnd(Scene, IsSucc, IsTimeOver)
	local Player = nil
	for playerID, player in pairs(Scene.m_tbl_Player) do
		Player = player
	end
	CMercenaryRoomCreate.ClearAllTick(Scene)
	if not Scene.m_MercenaryActionInfo.m_IsGameEnd then
		Scene.m_MercenaryActionInfo.m_GameIsSucc = IsSucc
		Scene.m_MercenaryActionInfo.m_IsGameEnd = true
		
		--ɾ�������ڵĶ���-------------
		local SceneID = Scene.m_MercenaryActionInfo.m_FbSceneID
		DestroyAllFromScene(SceneID)
		
		-- һ�����ɾһ��
		local data = {}
		data.m_Player = Player
		data.m_Scene = Scene
		RegisterOnceTick(Scene, "m_DelAllAndCreateSwichTick", DelAllAndCreateSwichTick, 1000, data) 
		--------------------------------
		
		--ȥ�����õļ���-------
		if Scene.m_MercenaryActionInfo.m_GameID then
			CMercenaryRoomCreate.YbEduActAddOrResetSkill(Player, Scene.m_MercenaryActionInfo.m_GameID, false)
		end
		-----------------------
		
--		--����Ҽ���Ѫ
--		if IsCppBound(Player) and Player:CppIsLive() then
--			local HP = Player:CppGetMaxHP()
--			local MP = Player:CppGetMaxMP()
--			Player:CppInitHPMP(HP,MP)
--		end
		-------------------------------
		CMercenaryRoomCreate.SetGameState(Scene, CMercenaryRoomCreate.GameState.GameEnd)
		-- ͷ�ϼ���Ч
		local playerInfo = Scene.m_MercenaryActionInfo
		local RoomNum = playerInfo.m_SelMercenaryRoomNum
		local SwitchPos = {}
		SwitchPos.x = g_MercenaryEduActMgr.m_RoomPoints[RoomNum].SwitchPoint[1]
		SwitchPos.y = g_MercenaryEduActMgr.m_RoomPoints[RoomNum].SwitchPoint[2]
		
		if IsCppBound(Player) and IsCppBound(Player.m_Conn) then
			Gas2Gac:SetCompassHeadDir(Player.m_Conn,2, SwitchPos.x*EUnits.eGridSpanForObj, SwitchPos.y*EUnits.eGridSpanForObj)
		end
		
		local FloorNum = Scene.m_MercenaryActionInfo.m_FloorNum
		local IsRewardFloor = Scene.m_MercenaryActionInfo.m_IsRewardFloor
		if FloorNum == m_ToTalFloor and IsRewardFloor then
			Scene.m_MercenaryActionInfo.m_XiuXingTaWin = true 	-- ͨ��
		end
		
		-- ������LOG
		local PlayerID = Scene.m_MercenaryActionInfo.m_PlayerID
		local LastTime = math.floor(GetProcessTime() / 1000) - Scene.m_MercenaryActionInfo.m_BeginGameTime
		Scene.m_MercenaryActionInfo.m_CurGameLastTime = LastTime
		local SaveData = {}
		SaveData.PlayerID = PlayerID
		SaveData.GameID = Scene.m_MercenaryActionInfo.m_GameID
		
		if Scene.m_MercenaryActionInfo.m_IsRewardFloor then
			for i, num in pairs(CMercenaryEducateAct.RewardFloorNumTbl) do
				if num == Scene.m_MercenaryActionInfo.m_FloorNum then
					SaveData.LevelNum = "J"..i
				end
			end
		else
			SaveData.LevelNum = Scene.m_MercenaryActionInfo.m_FloorNum
		end
		
		SaveData.SceneID = Scene.m_SceneId
		SaveData.PlayerID = PlayerID
		SaveData.uSpendTimes = LastTime

		if IsSucc then
			if IsCppBound(Player) and IsCppBound(Player.m_Conn) then
				SaveData.uSucceedFlag = 1
			end
			
			--CMercenaryRoomCreate.SetGameState(Scene, CMercenaryRoomCreate.GameState.PrepareNextGame)
			local OverTbl = Scene.m_MercenaryActionInfo.m_OverTypeTbl
--			local DownTime = OverTbl["��ʱ"] or OverTbl["����ʱ��"]
--			if DownTime and Player and IsCppBound(Player) then
--				Gas2Gac:RetBeginYbEduActGame(Player.m_Conn, 0)--�ü�ʱֹͣ
--			end
			-- 
			if OverTbl["��ʱ"] then
				OverTbl["��ʱ"] = true
			end
			--��ӡ��ʾ��Ϣ(��������Ϣ)
			--���ý����ӿ�
			if IsCppBound(Player) then
				MsgToConn(Player.m_Conn,3605)
				Gas2Gac:UseItemPlayerEffect(Player.m_Conn,"fx/setting/other/other/brith/create.efx","brith/create")
				--CMercenaryRoomCreate.FinishGameGiveAward(Player,false)
			end
			-- �ӳɹ�����
			local FloorNum = Scene.m_MercenaryActionInfo.m_FloorNum
			local XS = GetXiShu(FloorNum)
			Scene.m_MercenaryActionInfo.m_SuccTimes= Scene.m_MercenaryActionInfo.m_SuccTimes + 1
			local SuccTimes= Scene.m_MercenaryActionInfo.m_SuccTimes
			Scene.m_MercenaryActionInfo.m_MercMoney = Scene.m_MercenaryActionInfo.m_MercMoney + 1
			local MercMoney = Scene.m_MercenaryActionInfo.m_MercMoney
			if IsCppBound(Player) then
				Gas2Gac:RetUpdateYbEduActInfo(Player.m_Conn, MercMoney, FloorNum, XS, m_ToTalFloor)
			end
		else
			if IsTimeOver then	
				SaveData.uSucceedFlag = 3		-- ʱ�䵽����
			else
				SaveData.uSucceedFlag = 2
			end
			--CMercenaryRoomCreate.SetGameState(Scene, CMercenaryRoomCreate.GameState.LoseGame)
			if IsCppBound(Player) then
				MsgToConn(Player.m_Conn,3606)
				--Gas2Gac:UseItemPlayerEffect(Player.m_Conn,"fx/setting/other/other/xunlian/shibai.efx","xunlian/create")
				CMercenaryRoomCreate.SendPlayerDeadMsg(Player)
			end
		end
		
		if IsCppBound(Player) and IsCppBound(Player.m_Conn) then
			CallAccountAutoTrans(Player.m_Conn.m_Account, "LogMgrDB", "SaveXiuXingTaLogInfo", nil, SaveData)
		end		
		
		local OverTbl = Scene.m_MercenaryActionInfo.m_OverTypeTbl
		local DownTime = OverTbl["��ʱ"] or OverTbl["����ʱ��"]
		if DownTime and Player and IsCppBound(Player) then
			Gas2Gac:RetBeginYbEduActGame(Player.m_Conn, 0)--�ü�ʱֹͣ
		end
		-- ˢ������
		--g_MercenaryEduAction:CreateFbTrap(Scene)
	end
end

-- function CMercenaryRoomCreate:IsCanClose(Player, IsSucc)
function CMercenaryRoomCreate.IsCanClose(Player, IsSucc)
	if not CMercenaryRoomCreate.m_IsExitGame then
		return false
	end
	return true
end

local function StringToNumber(Level,FloorNum,strInfo)
	if strInfo then
		strInfo = string.gsub( strInfo, "L", Level)
		local count = assert(loadstring( "return " .. strInfo))()
		return count * GetXiShu(FloorNum) / 100--�����Ͳ���Ҳ�й�ϵ
	else
		return 0
	end
end

local function GetEndGiveItem(PlayerLevel)
	local FbName = "Ӷ��ѵ���"--Ӷ��ѵ���
	if g_MercenaryAwardItemMgr[FbName] then
		for i=1, #(g_MercenaryAwardItemMgr[FbName]) do
			local ItemMgr = g_MercenaryAwardItemMgr[FbName][i]
			if ItemMgr[1] and ItemMgr[2] then
				local LevelTbl = ItemMgr[1]
				local ItemTbl = ItemMgr[2]
				if LevelTbl[1] and LevelTbl[2] then
					if PlayerLevel >= LevelTbl[1] and PlayerLevel <= LevelTbl[2] then
						return ItemTbl
					end
				elseif LevelTbl[1] and PlayerLevel == LevelTbl[1] then
					return ItemTbl
				end
			end
		end
	end
	return
end

local function CreateXXTTrap(Scene)
	-- ���������ˢ��ȥ�¹ص�Trap
	local playerInfo = Scene.m_MercenaryActionInfo
	local SelRoomNum = playerInfo.m_SelMercenaryRoomNum
	local TrapPos = CPos:new()
	TrapPos.x = g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum].TrapPoint[1]--YbEducateActionTransport_Server[SelRoomNum]["TrapPoint"][1]
	TrapPos.y = g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum].TrapPoint[2]--YbEducateActionTransport_Server[SelRoomNum]["TrapPoint"][2]
	local Trap = CreateServerTrap(Scene, TrapPos, "Ӷ��ѵ������͵�")
end

-- IsFailed �Ƿ�ʧ��
--function CMercenaryRoomCreate:FinishGameGiveAward(Player, IsFailed, Scene)
function CMercenaryRoomCreate.FinishGameGiveAward(Player, IsFailed, Scene)
	local playerInfo = Scene.m_MercenaryActionInfo
	if not playerInfo then
		return
	end
	local FloorNum = playerInfo.m_FloorNum
	local IsRewardFloor = CMercenaryEducateAct.IsNextRewardFloor(Scene)
	if FloorNum >= m_ToTalFloor and not IsRewardFloor then  -- ���ڵ���m_ToTalFloor��������һ�ز��ǽ�����
		CMercenaryRoomCreate.GameEndGiveAward(Player, AwardItemTbl)
	else
		-- ���������ˢ��ȥ�¹ص�Trap
		CreateXXTTrap(Scene)
	end
	
	if not IsCppBound(Player) then
		return
	end
	
	local PlayerId = Player.m_uID
	local GameID = playerInfo.m_GameID
	local MercenaryEduActMgr = g_MercenaryEduActMgr[GameID]
	local Level = Player:CppGetLevel()
	local FloorNum = playerInfo.m_FloorNum
	local dbData = {}
	dbData[PlayerId] = {}
	dbData[PlayerId].isInGame = true
	--dbData[PlayerId].itemTbl = MercenaryEduActMgr.m_AwardItemTbl
	dbData[PlayerId].exp = playerInfo.m_ExpModulus * StringToNumber(Level,FloorNum,MercenaryEduActMgr.m_AwardExp)
	dbData[PlayerId].money = playerInfo.m_MoneyModulus * StringToNumber(Level,FloorNum,MercenaryEduActMgr.m_AwardMoney)
	dbData[PlayerId].fetch = playerInfo.m_ExpModulus * StringToNumber(Level,FloorNum,MercenaryEduActMgr.m_AwardFetch)
	
	if IsFailed then
	--	dbData[PlayerId].itemTbl = nil
		if Level > 15 then
			dbData[PlayerId].exp = dbData[PlayerId].exp / 2
			dbData[PlayerId].money = 0 --dbData[PlayerId].money / 2
			dbData[PlayerId].fetch = dbData[PlayerId].fetch / 2
		else
			dbData[PlayerId].exp = dbData[PlayerId].exp * 0.9
			dbData[PlayerId].money = dbData[PlayerId].money * 0.9
			dbData[PlayerId].fetch = dbData[PlayerId].fetch * 0.9
		end
	end
	
	if Level < 7 then
		dbData[PlayerId].exp = dbData[PlayerId].exp * 1.5
	end
	local AwardItemTbl = nil
	if FloorNum >= m_ToTalFloor then
		-- ȥ������
		--AwardItemTbl = GetEndGiveItem(Level)
		if IsFailed and Player.m_Scene.m_IsLoseGame then
			AwardItemTbl = nil
		end
		if AwardItemTbl and next(AwardItemTbl) then
			if dbData[PlayerId].itemTbl then
				for i=1, #(AwardItemTbl)do
					table.insert(dbData[PlayerId].itemTbl,AwardItemTbl[i])
				end
			else
				dbData[PlayerId].itemTbl = AwardItemTbl
			end
		end
		local ExtraExp = Player.m_Scene.m_MercenaryActionInfo.m_MercMoney * ExtraExpPara * Player:CppGetLevel()
		--print("dbData[PlayerId].exp"..dbData[PlayerId].exp.."    ���⽱�� "..ExtraExp)
		dbData[PlayerId].exp = dbData[PlayerId].exp + ExtraExp
		--print("dbData[PlayerId].exp  = "..dbData[PlayerId].exp)
	end
	
	dbData[PlayerId].exp = math.floor(dbData[PlayerId].exp)
	dbData[PlayerId].money = math.floor(dbData[PlayerId].money)
	dbData[PlayerId].fetch = math.floor(dbData[PlayerId].money)
	dbData["MailTitle"] = 1022
	dbData["MailContent"] = 1023
	
	Player:OnSavePlayerSoulTickFunc(nil,Player)
	local function CallBack(IsSucc, result)
		if IsSucc and Player and IsCppBound(Player) then
--			local AwardTbl = {}
			-- ����
			local expResult = result[PlayerId][1]
			if expResult and expResult[1] then
				MsgToConn(Player.m_Conn,3600,dbData[PlayerId].exp)
				--CRoleQuest.AddPlayerExp_DB_Ret(Player, {expResult[1],expResult[2],dbData[PlayerId].exp, 0})
				local AddExpTbl = {}
				AddExpTbl["Level"] = expResult[1]
				AddExpTbl["Exp"] = expResult[2] -- -(DividedNum-Tick.AwardTimes)*AwardTbl.m_AddExp
				AddExpTbl["AddExp"] = dbData[PlayerId].exp
				AddExpTbl["uInspirationExp"] = 0
				CRoleQuest.AddPlayerExp_DB_Ret(Player, AddExpTbl)		
			end

			-- ��Ǯ
			if result[PlayerId][2][1] then
				MsgToConn(Player.m_Conn,3602,dbData[PlayerId].money)
			else
				if IsNumber(result[PlayerId][2][2]) then
					MsgToConn(Player.m_Conn,result[PlayerId][2][2])
				end
			end
			
			-- ��
			if result[PlayerId][4] then
				MsgToConn(Player.m_Conn,3601,dbData[PlayerId].fetch)
				Player.m_uSoulValue = result[PlayerId][4] + Player.m_uKillDropSoulCount
				Gas2Gac:ReturnModifyPlayerSoulNum(Player.m_Conn, Player.m_uSoulValue)
			end
			
			-- ��¼�ۼƾ��顢��Ǯ����
			Scene.m_MercenaryActionInfo.m_TotalExp = Scene.m_MercenaryActionInfo.m_TotalExp + dbData[PlayerId].exp
			Scene.m_MercenaryActionInfo.m_TotalMoney = Scene.m_MercenaryActionInfo.m_TotalMoney + dbData[PlayerId].money
			Scene.m_MercenaryActionInfo.m_TotalSoul = Scene.m_MercenaryActionInfo.m_TotalSoul + dbData[PlayerId].fetch
			
			local itemResult = result[PlayerId][3]
			if next(itemResult) then
				for i=1,#(itemResult) do
					if IsNumber(itemResult[i][4]) then
						if itemResult[i][4] == 3 then
							--,'�����ռ䲻��'
							MsgToConn(Player.m_Conn,160000)
						elseif itemResult[i][4] == 0 then
							MsgToConn(Player.m_Conn,8003,'CreateFightItem error')
						end
					else
						MsgToConn(Player.m_Conn,3603,itemResult[i][3],itemResult[i][2])
						CRoleQuest.add_item_DB_Ret(Player, itemResult[i][1], itemResult[i][2], itemResult[i][3],itemResult[i][4])
					end
				end
			end
			
			--������һ���Trap
			if FloorNum >= m_ToTalFloor then
				--CMercenaryRoomCreate.GameEndGiveAward(Player, AwardItemTbl)
				if not Player.m_Scene.m_IsLoseGame then
					-- ���ݿ������ӳɹ�����
					local parameters = {}
					parameters["PlayerId"] = PlayerId
					parameters["ActivityName"] = "Ӷ��ѵ���"
					CallDbTrans("ActivityCountDB", "AddSuccessRecordCount", nil, parameters, PlayerId)
				end
			elseif not IsFailed then
				--g_MercenaryEduAction:CreateFbTrap(Player.m_Scene)
			end
		
		end
	end
	
	dbData["sceneName"] = Player.m_Scene.m_SceneName
	dbData["sceneType"] = Player.m_Scene.m_SceneAttr.SceneType
	OnSavePlayerExpFunc({Player})
	CallDbTrans("RoleQuestDB", "FbActionAward", CallBack, dbData, Player.m_AccountID)
end

-- function CMercenaryRoomCreate:GameEndGiveAward(Player, ItemTbl)
function CMercenaryRoomCreate.GameEndGiveAward(Player, ItemTbl)
	if not IsCppBound(Player) or not IsCppBound(Player.m_Conn) then
		return
	end
	
	local Scene = Player.m_Scene
	Gas2Gac:RetOverYbXlAction(Player.m_Conn,1,"",1)
--	if ItemTbl and next(ItemTbl) then
--		for i=1, #(ItemTbl) do
--			Gas2Gac:RetOverYbXlAction(Player.m_Conn,2,ItemTbl[i][2],ItemTbl[i][3])
--		end
--	end 
	Gas2Gac:RetOverYbXlAction(Player.m_Conn,2,"�ܾ���",Scene.m_MercenaryActionInfo.m_TotalExp)
	Gas2Gac:RetOverYbXlAction(Player.m_Conn,2,"�ܽ�Ǯ",Scene.m_MercenaryActionInfo.m_TotalMoney)
	Gas2Gac:RetOverYbXlAction(Player.m_Conn,2,"�ܻ�ֵ",Scene.m_MercenaryActionInfo.m_TotalSoul)
	Gas2Gac:RetOverYbXlAction(Player.m_Conn,2,"���⾭��",Scene.m_MercenaryActionInfo.m_MercMoney * ExtraExpPara * Player:CppGetLevel())
	Gas2Gac:RetOverYbXlAction(Player.m_Conn,3,"",m_CloseFbTime)
	
	-- �����ֵ
	local uAfflatusValue = FbAfflatus_Common("Ӷ��ѵ���", "AfflatusValue")
	if uAfflatusValue and IsNumber(uAfflatusValue)then
		Player:AddPlayerAfflatusValue(uAfflatusValue)
	end
	
	local function OverGameFb(Tick, param)
		local Player = param[1]
		local Scene = Player.m_Scene
		CMercenaryRoomCreate.ClearAllTick(Scene)
		if IsCppBound(Player) then
			CMercenaryEducateAct.ExitYbEducateAction(Player.m_Conn)
		end
	end
	local data = {Player}
--	CMercenaryRoomCreate.m_DownTimeTick[Player.m_uID] = RegisterTick("YbActionEndTick",OverGameFb,m_CloseFbTime*1000,data)
	CMercenaryRoomCreate.ClearDownTimeTick(Scene)
	Scene.m_DownTimeTick = RegisterTick("XiuXingTaEndTick",OverGameFb,m_CloseFbTime*1000,data)
end

-- function CMercenaryRoomCreate:SendMusicType(Scene, State)
function CMercenaryRoomCreate.SendMusicType(Scene, State)
	local MusicType = nil
	if State == CMercenaryRoomCreate.GameState.StartGame then
		if Scene.m_MercenaryActionInfo.m_IsRewardFloor then
			MusicType = 1	-- �����ص�����
		else
			MusicType = 2	-- ��ͨ������
		end
	else
		MusicType = 3	-- �ȴ�ʱ����
	end
	
	--if Scene.m_MercenaryActionInfo.LastMusicType ~= MusicType then		
		for id,Player in pairs(Scene.m_tbl_Player) do
			Gas2Gac:SendPlayXiuXingTaBgm(Player.m_Conn, MusicType)
		end
		Scene.m_MercenaryActionInfo.LastMusicType = MusicType
	--end
end

-- function CMercenaryRoomCreate:SetGameState(Scene, State)
function CMercenaryRoomCreate.SetGameState(Scene, State)
	--print("��Ϸ״̬Ϊ��"..State)
	Scene.m_MercenaryActionInfo.GameState = State
	CMercenaryRoomCreate.SendMusicType(Scene, State)
end

-- function CMercenaryRoomCreate:IsInState(Scene, State)
function CMercenaryRoomCreate.IsInState(Scene, State)
	if Scene.m_MercenaryActionInfo.GameState == State then
		--print("���ߺ���Ϸ״̬Ϊ: "..State)
		--CMercenaryRoomCreate.SendMusicType(Scene, State)
		return true
	else
		return false
	end
end
