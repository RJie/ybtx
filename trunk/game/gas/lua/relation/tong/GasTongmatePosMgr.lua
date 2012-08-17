cfg_load "scene/NotShowMateIcon_Server"

--print("���� tong !!!")
CGasTongmatePosMgr = class()
local g_TongmatePosMgr = {}
local GetPosTime = 5000 --����

local function DestroyGetTongmatePosTick(TongID)
	--print("-- DestroyGetTongmatePosTick")
	if g_TongmatePosMgr[TongID] and 
		g_TongmatePosMgr[TongID].m_GetTongmatePosTick then
		UnRegisterTick(g_TongmatePosMgr[TongID].m_GetTongmatePosTick)
		g_TongmatePosMgr[TongID].m_GetTongmatePosTick = nil
	end
--	if g_TongmatePosMgr[TongID] and g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl then
--		g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl = nil
--	end
--	if g_TongmatePosMgr[TongID] and g_TongmatePosMgr[TongID].m_LastSendTime then
--		g_TongmatePosMgr[TongID].m_LastSendTime = nil
--	end
	--g_TongmatePosMgr[TongID] = nil
end


local function GetTongmatePosTick(Tick, TongID)
	--print("---tick")
	local tblMembers = g_GasTongMgr:GetMembers(TongID)
	-- �������Աֻʣ1����ע��Tick
	if #(tblMembers) <= 1 or next(g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl) == nil then
		DestroyGetTongmatePosTick(TongID)
		return
	end
				
	local IsAnyOneOn = false
	local IsAnyOneNeed = false
	for i = 1, #(tblMembers) do
		local MemberId = tblMembers[i]
		local pMember = g_GetPlayerInfo(MemberId)
		if IsCppBound(pMember) then
			IsAnyOneOn = true
			local SceneName = pMember.m_Scene.m_LogicSceneName
			--ֻ�����ض��ĵ�ͼ�ŷ���λ��
			--for _, scene_name in pairs(g_GasTongMgr.MiddleMapShowTongMateScene) do
				--if SceneName == scene_name then	
					local GridPos = CPos:new()
					pMember:GetGridPos(GridPos)
					
					for id, Player in pairs(g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl) do
						IsAnyOneNeed = true
						if IsCppBound(Player) then
							--for _, scene_name in pairs(g_GasTongMgr.MiddleMapShowTongMateScene) do
								--if Player.m_Scene.m_SceneName == scene_name then
									if id ~= MemberId then
										-- ���MemberId�Ƕ��ѣ�������Ϣ			
										local IsTeamMate = false
										local TeamID = pMember.m_Properties:GetTeamID()
										local tblTeamMembers = g_TeamMgr:GetMembers(TeamID)
										for i = 1, #(tblTeamMembers) do
											local TeamMemberId = tblTeamMembers[i]
											if id == TeamMemberId then
												--print("����Ƕ��ѣ�������Ϣ")
												IsTeamMate = true
											end
										end
										if not IsTeamMate then
											local MemberName = pMember.m_Properties:GetCharName()
											if NotShowMateIcon_Server(SceneName) then
												Gas2GacById:HideLeavedTongmatePos(id, MemberId)	-- ֪ͨ�������ߵ������� MemberId �ı�־
											else
												Gas2GacById:SendTongmatePos(id,MemberId,SceneName,GridPos.x,GridPos.y, MemberName)
											end
										end
									end
								--end	
							--end
						end
					end
					
--					if not IsAnyOneNeed then
--						print("û����")
--						DestroyGetTongmatePosTick(TongID)
--					end
				--end
			--end
		end
	end
	
	-- ���û����Ҫ������Ϣ����ע��	
	if not IsAnyOneOn then
		--print("û������")
		DestroyGetTongmatePosTick(TongID)
		--g_TongmatePosMgr[TongID] = nil
	end
	
	if not IsAnyOneNeed then
		--print("û����Ҫ����")
		DestroyGetTongmatePosTick(TongID)
		--g_TongmatePosMgr[TongID] = nil
	end
	
end

local function GetTongmatePos(Player)
	local TongID = Player.m_Properties:GetTongID()
	if TongID == 0 then
		return
	end
	local PlayerId = Player.m_uID
	
	if not g_TongmatePosMgr[TongID] then
		g_TongmatePosMgr[TongID] = {}
		--print("--------ע��Tick")
		local tick = RegisterTick("GetTongmatePosTick",GetTongmatePosTick,GetPosTime,TongID,PlayerId)
		g_TongmatePosMgr[TongID].m_GetTongmatePosTick = tick
		g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl = {}
		g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl[PlayerId] = Player
	else
		if not g_TongmatePosMgr[TongID].m_GetTongmatePosTick then
			--print("--------ע��Tick2222")
			local tick = RegisterTick("GetTongmatePosTick",GetTongmatePosTick,GetPosTime,TongID,PlayerId)
			g_TongmatePosMgr[TongID].m_GetTongmatePosTick = tick
		end
		if not g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl then
			g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl = {}
		end
		g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl[PlayerId] = Player
	end
	
	---ע��TickǰԤ�Ȼ�ȡһ�ΰ���Ա������
	local tblMembers = g_GasTongMgr:GetMembers(TongID)
	for i = 1, #(tblMembers) do
		local MemberId = tblMembers[i]
		if MemberId ~= PlayerId then
			local pMember = g_GetPlayerInfo(MemberId)
			
			-- ��Ա���ض���ͼ�ŷ���λ��
			if IsCppBound(pMember) then
				--for _, scene_name in pairs(g_GasTongMgr.MiddleMapShowTongMateScene) do
					--if pMember.m_Scene.m_SceneName == scene_name then
				local SceneName = pMember.m_Scene.m_SceneName
				-- ֻ��ͬһ�ŵ�ͼ�ϵİ���Ա��λ����Ϣ�ᱻ����
				if SceneName == Player.m_Scene.m_SceneName then
					-- ���MemberId�Ƕ��ѣ�������Ϣ			
					local IsTeamMate = false
					local TeamID = Player.m_Properties:GetTeamID()
					local tblTeamMembers = g_TeamMgr:GetMembers(TeamID)
					for i = 1, #(tblTeamMembers) do
						local TeamMemberId = tblTeamMembers[i]
						if MemberId == TeamMemberId then
							--print("����Ƕ��ѣ�������Ϣ")
							IsTeamMate = true
						end
					end
					if not IsTeamMate then
						local GridPos = CPos:new()
						pMember:GetGridPos(GridPos)
						
						local MemberName = pMember.m_Properties:GetCharName()
						-- ����5��ŷ�����Ϣ
						if not g_TongmatePosMgr[TongID].m_LastSendTime then
							g_TongmatePosMgr[TongID].m_LastSendTime = {}
						end
						
						if not g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] then -- ��һ�δ�
							--print("--------send��һ��")
							if NotShowMateIcon_Server(SceneName) then
								Gas2GacById:HideLeavedTongmatePos(MemberId, PlayerId)	-- ֪ͨ�������ߵ�������PlayerID�ı�־
							else
								Gas2GacById:SendTongmatePos(PlayerId, MemberId, SceneName, GridPos.x, GridPos.y, MemberName)
								g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] = os.time()
							end
						else	
							local NowTime = os.time()
							if NowTime - g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] > 5 then
								if NotShowMateIcon_Server(SceneName) then
									Gas2GacById:HideLeavedTongmatePos(MemberId, PlayerId)	-- ֪ͨ�������ߵ�������PlayerID�ı�־
								else
									g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] = NowTime
									--print(NowTime.."--------------send!"..MemberName)
									Gas2GacById:SendTongmatePos(PlayerId, MemberId, SceneName, GridPos.x, GridPos.y, MemberName)
								end
							end 		
						end
					end
				end
					--end
				--end
			end
		end
	end
	

end

-- function CGasTongmatePosMgr:PlayerStopGetTongmatePos(Player)
function CGasTongmatePosMgr.PlayerStopGetTongmatePos(Player)
	local function Init()
		local TongID = Player.m_Properties:GetTongID()
		local PlayerId = Player.m_uID
		
		if g_TongmatePosMgr[TongID] then
			if g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl 
				and g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl[PlayerId] then
				g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl[PlayerId] = nil
				-- �������Աֻʣ1����ע��Tick
				local tblMembers = g_GasTongMgr:GetMembers(TongID)
				if #(tblMembers) <= 1 or next(g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl) == nil then
					DestroyGetTongmatePosTick(TongID)
				end
				
--				if g_TongmatePosMgr[TongID].m_LastSendTime 
--					and g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] then
--					g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] = nil
--				end
			end
		end
	
	end
	apcall(Init)
end

-- �³�Ա������ʱ����
--function CGasTongmatePosMgr:CreateGetTongmatePosTick(TongID,uTargetID,uPlayerID)
function CGasTongmatePosMgr.CreateGetTongmatePosTick(TongID,uTargetID,uPlayerID)
	Gas2GacById:CheckIsNeedSendTongmatePos(uTargetID, TongID)
end

-- �����뿪������ҡ����ߵ���ҡ��뿪ָ����ͼ����ҵ�ͼ��
-- function CGasTongmatePosMgr:StopSendLeavedTongmatePos(TongID, PlayerID)
function CGasTongmatePosMgr.StopSendLeavedTongmatePos(TongID, PlayerID)
	if not g_TongmatePosMgr[TongID] then
		return	
	end
	--print("�����뿪�����������  "..PlayerID.." ����")
	local tblMembers = g_GasTongMgr:GetMembers(TongID)
	for i = 1, #(tblMembers) do
		local MemberId = tblMembers[i]
		local pMember = g_GetPlayerInfo(MemberId)
		if IsCppBound(pMember) then		
			if MemberId ~= PlayerID then
				Gas2GacById:HideLeavedTongmatePos(MemberId, PlayerID)	-- ֪ͨ�������ߵ�������PlayerID�ı�־
			else
				-- ���������˵�ͼ��
				Gas2GacById:StopSendTongmatePos(PlayerID)
				
				if g_TongmatePosMgr[TongID] and g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl then
					g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl[PlayerID] = nil
				end
				if g_TongmatePosMgr[TongID].m_LastSendTime 
					and g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] then
					g_TongmatePosMgr[TongID].m_LastSendTime[PlayerId] = nil
				end
			end
		end
	end
	-- ����ʱ�ж��Ƿ����g_TongmatePosMgr
	if #(tblMembers) <= 1 
		or next(g_TongmatePosMgr[TongID]) == nil 
		or next(g_TongmatePosMgr[TongID].m_NeedSendPlayerTbl) == nil then
		--print("���")
		DestroyGetTongmatePosTick(TongID)
		g_TongmatePosMgr[TongID] = nil
	end
end

-- function CGasTongmatePosMgr:GetTongmatePos(Conn)
function CGasTongmatePosMgr.GetTongmatePos(Conn)
	if not IsCppBound(Conn.m_Player) then
		return
	end
	
	local TongID = Conn.m_Player.m_Properties:GetTongID()
	local tblMembers = g_GasTongMgr:GetMembers(TongID)
	-- �������Աֻʣ1�����򷵻�
	if #(tblMembers) <= 1 then
		return
	end
	
	GetTongmatePos(Conn.m_Player)
end

-- function CGasTongmatePosMgr:StopGetTongmatePos(Conn)
function CGasTongmatePosMgr.StopGetTongmatePos(Conn)
	if not IsCppBound(Conn.m_Player) then
		return
	end
	CGasTongmatePosMgr.PlayerStopGetTongmatePos(Conn.m_Player)
end
