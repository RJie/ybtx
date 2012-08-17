gac_gas_require "team/TeamMgr"
--gas_require "relation/team/GasTeammatePosMgr"
local team_box = "GasTeamDB"

g_AverageAssignOrder = {}
CGasTeam = class()

--��������ӡ�����id
function CGasTeam.InviteMakeTeam(Conn, uTargetID)

	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
	local uCharID = Player.m_uID
	local name = Player.m_Properties:GetCharName()
	local playerlev = Player:CppGetLevel()
	local playerclass = Player:CppGetClass()
	if uTargetID == uCharID then
		--, "���������Լ���ӣ�"
		MsgToConn(Conn,117)
		return
	end
	
	local function CallBack(bFlag,uCapID,eAM)
		if not bFlag then
			if IsNumber(uCapID) then
				MsgToConn(Conn,uCapID)
			end
			return
		else
			if uCapID == uCharID then
				--˵����������ӻ����˼������
				Gas2GacById:ReturnInviteMakeTeam(uTargetID, uCharID, name, playerlev, playerclass, eAM)
			else
				Gas2GacById:ReturnAppJoinTeam(uCapID, uCharID, name, playerlev, playerclass)
			end
		end
	end
	
 	local parameters = {}
	parameters.uCharID	= uCharID
	parameters.uTargetID	= uTargetID
	
	CallAccountManualTrans(Conn.m_Account, team_box, "InviteTeam", CallBack, parameters)
end

--��������ӡ���������
function CGasTeam.InviteMakeTeamByName(Conn, uTargetName)

	local Player = Conn.m_Player
	
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	local name = Player.m_Properties:GetCharName()
	local uCharID = Player.m_uID
	local playerlev = Player:CppGetLevel()
	local playerclass = Player:CppGetClass()
	if uTargetName == name then
		--, "���������Լ���ӣ�"
		MsgToConn(Conn,117)
		return
	end
	
	--�ص������������߼���
	--ps:��һ��������С���������ڶ����Ƿ��䷽ʽ
	local function CallBack(bFlag,uCapID,eAM,uTargetID)
		if not bFlag then
			if IsNumber(uCapID) then
				MsgToConn(Conn,uCapID)
			end
			return
		else
			if uCapID == uCharID then
				--˵����������ӻ����˼������
				Gas2GacById:ReturnInviteMakeTeam(uTargetID,uCharID, name, playerlev, playerclass, eAM)
			else
				Gas2GacById:ReturnAppJoinTeam(uCapID, uCharID, name, playerlev, playerclass)
			end
			MsgToConn(Conn,142)
		end
	end
	
 	local parameters = {}
	parameters.uCharID	= uCharID
	parameters.uTargetName	= uTargetName
	
	CallAccountManualTrans(Conn.m_Account, team_box, "InviteTeamByName", CallBack, parameters)
end
--------------------------------------------------------------------------------------

--����Ӧ���롿
function CGasTeam.RespondInvite(Conn, InviterID, InviterName, bAccept)
	local Invitee = Conn.m_Player
	if not (Invitee and IsCppBound(Invitee)) then return end
	if Invitee.m_TemporaryTeam then return end
		
	local InviteeID = Invitee.m_uID
	--�ص������������߼���
	local function CallBack(bFlag,uMsgID,sTtr)
			if not bFlag then
				if IsNumber(uMsgID) then
					if IsString(sTtr) then
						MsgToConn(Conn,uMsgID,sTtr)
					else
						MsgToConn(Conn,uMsgID)
					end
				end
			else
				local RetRes = uMsgID
				local char_name = RetRes.CharName
				if not bAccept then
					MsgToConnById(InviterID,101,char_name)
					MsgToConn(Conn,137,InviterName)
				else
					local eAM, AuctionStandard, AuctionBasePrice = RetRes.eAM,RetRes.AuctionStandard,RetRes.AuctionBasePrice
					local TeamID = RetRes.uTeamID
	
					if bFlag == "CreateTeam" then
							MsgToConn(Conn,118)
							MsgToConnById(InviterID,118)
							--���淨�飩������Ӻ��ʼ����ȡ����λ�õ�Tick�������汾��Ҫ��ʾ����λ��
							CGasTeammatePosMgr.CreateGetTeammatePosTick(TeamID,InviterID,InviteeID)
							--���·��䷽ʽ
							Gas2GacById:UpdateAssignMode(InviterID, eAM)
							Gas2GacById:UpdateAuctionStandard(InviterID, AuctionStandard)
							Gas2GacById:UpdateAuctionBasePrice(InviterID, AuctionBasePrice)
					elseif bFlag == "AddMember" then
							local team_members = RetRes.team_members
							MsgToConnById(InviteeID,118)
							for m =1,#team_members do
								local member_id = team_members[m][1]
								MsgToConnById(member_id,120,char_name)
							end
 							local MarkInfo = RetRes.MarkInfo
 							for i=1,MarkInfo:GetRowNum() do
								Gas2GacById:ReturnUpdateTeamMark(InviterID, MarkInfo(i,1), MarkInfo(i,2), MarkInfo(i,3))
							end	
							Gas2GacById:ReturnUpdateTeamMarkEnd(InviterID) 
					end
					--���䷽ʽ������� 
					
					CGasTeam.InitAllServerTeamInfo(TeamID)
					
					Gas2GacById:UpdateAssignMode(InviteeID, eAM)
					Gas2GacById:UpdateAuctionStandard(InviteeID, AuctionStandard)
					Gas2GacById:UpdateAuctionBasePrice(InviteeID, AuctionBasePrice)
				end
			end
	end
	local parameters = {}
	parameters.uCharID	= InviteeID
	parameters.InviterID	= InviterID
	parameters.bAccept	= bAccept
	parameters.InviterName	= InviterName
	CallAccountManualTrans(Conn.m_Account, team_box, "RespondInvite", CallBack, parameters)
end


--����Ӧ���롿
function CGasTeam.RespondApp(Conn, InviterID, InviterName, bAccept)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	--�ص������������߼���
	local function CallBack(bFlag,uMsgID,sTtr)
			if not bFlag then
				if IsNumber(uMsgID) then
					if IsString(sTtr) and string.len(sTtr) > 0 then
						MsgToConn(Conn,uMsgID,sTtr)
					else
						MsgToConn(Conn,uMsgID)
					end
				end
			else
				local RetRes = uMsgID
				local char_name = RetRes.CharName 
				if not bAccept then
					MsgToConnById(InviterID,101,char_name)
					MsgToConn(Conn,138,InviterName)
				elseif bFlag == "AddMember" then
					local eAM, AuctionStandard, AuctionBasePrice = RetRes.eAM,RetRes.AuctionStandard, RetRes.AuctionBasePrice
					local team_members,uTeamID = RetRes.team_members,RetRes.uTeamID
					local MarkInfo = RetRes.MarkInfo
					CGasTeam.InitAllServerTeamInfo(uTeamID)
					MsgToConnById(InviterID,118)
					for m =1,#team_members do
							local member_id = team_members[m][1]
							MsgToConnById(member_id,120,InviterName)
					end
 					for i=1,MarkInfo:GetRowNum() do
						Gas2GacById:ReturnUpdateTeamMark(InviterID, MarkInfo(i,1), MarkInfo(i,2), MarkInfo(i,3))
					end	
					Gas2GacById:ReturnUpdateTeamMarkEnd(InviterID) 
 					--���䷽ʽ������� 
					Gas2GacById:UpdateAssignMode(InviterID, eAM)
					Gas2GacById:UpdateAuctionStandard(InviterID, AuctionStandard)
					Gas2GacById:UpdateAuctionBasePrice(InviterID, AuctionBasePrice)
				end
			end
	end
	
	local parameters = {}
	parameters.uCharID	= Player.m_uID
	parameters.InviterID	= InviterID
	parameters.bAccept	= bAccept
	parameters.InviterName	= InviterName
	CallAccountManualTrans(Conn.m_Account, team_box, "RespondApp", CallBack, parameters)
end

--����ɢ���顿
function CGasTeam.BreakTeam(Conn)
	local Player =  Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	local uCharID = Player.m_uID
	local char_name = Player.m_Properties:GetCharName()
	--�ص������������߼���
	local function CallBack(tblRet)
		if not tblRet then return end
		local team_members,uTeamID = tblRet.m_tblTeamMeb, tblRet.m_nTeamID
		CGasTeam.InitAllServerTeamInfo(uTeamID)
		for j=1, #team_members do
				local member_id = team_members[j][1]
				--֪ͨС�ӱ���ɢ
				MsgToConnById(member_id, 99, char_name)
				--ˢ��С�����
				Gas2GacById:UpdateTeammateIcon(member_id)
		end
		--����ӵ�����˳�����
		local LeaveSceneTbl = tblRet.LeaveSceneTbl
		for i=1,#(LeaveSceneTbl) do
			local id = LeaveSceneTbl[i][1]
			local serverId = LeaveSceneTbl[i][2]
			Gas2GasAutoCall:NotifyPlayerLeaveFbScene(GetServerAutoConn(serverId), id, 30, 8803)
		end
	end
	local parameters = {}
	parameters.uCharID	= uCharID
	CallAccountManualTrans(Conn.m_Account, team_box, "BreakTeam", CallBack, parameters, Player.m_Properties:GetTeamID())
end

--���뿪���顿
function CGasTeam.LeaveTeam(Conn)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	local uPlayerID = Player.m_uID
	local char_name = Player.m_Properties:GetCharName()
	local function CallBack(resData)
			if nil == resData then return end
			local uNewCap = resData.m_nNewTeamCap
			local  team_members = resData.m_tblTeamMem
			local uTeamID = resData.m_nTeamID
			
			if Player and IsCppBound(Player) then
				CTeamServerManager_CppRemoveTeamMember(uTeamID, 1, Player:GetEntityID())
			end
			CGasTeam.InitAllServerTeamInfo(uTeamID)
			
			if #team_members == 1 then
  			--С�ӽ�ɢ
  			local member_id = team_members[1][1]
				--"��������С��2���Զ���ɢ"
				MsgToConnById(member_id,125)
				Gas2GacById:UpdateTeammateIcon(member_id)
			else
				for m =1,#team_members do
					local member_id = team_members[m][1]
					MsgToConnById(member_id,122,char_name)
					local NewCaper = g_GetPlayerInfo(uNewCap)
					if  NewCaper and IsCppBound(NewCaper) then
						MsgToConnById(member_id,123, NewCaper.m_Properties:GetCharName())
					end
				end
			end
  		MsgToConn(Conn,126)
  		Gas2GacById:UpdateTeammateIcon(uPlayerID)
			
			--�淨�飬���ٻ�ȡ����λ�õ�Tick
  		CGasTeammatePosMgr.LeaveTeamStopGetTeammatePos(uTeamID,uPlayerID)
  		Gas2GacById:StopSendTeammatePos(uPlayerID)
  		
  		--����ӵ�����˳�����
  		local LeaveSceneTbl = resData.LeaveSceneTbl
			for i=1,#(LeaveSceneTbl) do
				local id = LeaveSceneTbl[i][1]
				local serverId = LeaveSceneTbl[i][2]
				Gas2GasAutoCall:NotifyPlayerLeaveFbScene(GetServerAutoConn(serverId), id, 30, 8803)
			end
	end
	
	local parameters = {}
	parameters.LeaverID = uPlayerID
	CallAccountManualTrans(Conn.m_Account, team_box, "LeaveTeam", CallBack, parameters, Player.m_Properties:GetTeamID())
end
----------------------------------------------------------------------------------------------
--���޳���Ա��
function CGasTeam.RemoveTeamMember(Conn, LeaverID)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	local uPlayerID = Player.m_uID
	
	local function CallBack(resData)
			if not resData then return end
			local team_members = resData.m_tblTeamMem
			local uTeamID,leaver_name = resData.m_nTeamID,resData.m_LeaverName
			
			local Target = g_GetPlayerInfo(LeaverID)
			if Target and IsCppBound(Target) then
				CTeamServerManager_CppRemoveTeamMember(uTeamID, 1, Target:GetEntityID())
			end
			CGasTeam.InitAllServerTeamInfo(uTeamID)
			for i=1,#team_members do
				local member_id = team_members[i][1]
				MsgToConnById(member_id,122,leaver_name)
			end		
			if #team_members == 1 then
				--С�ӽ�ɢ
  			local member_id = team_members[1][1]
				--"��������С��2���Զ���ɢ"
				MsgToConnById(member_id,125)
				Gas2GacById:UpdateTeammateIcon(member_id)
			end
			
			--�淨�飬���ٻ�ȡ����λ�õ�Tick
			CGasTeammatePosMgr.LeaveTeamStopGetTeammatePos(uTeamID,LeaverID)
			
			--����ӵ�����˳�����
			local LeaveSceneTbl = resData.LeaveSceneTbl
			for i=1,#(LeaveSceneTbl) do
				local id = LeaveSceneTbl[i][1]
				local serverId = LeaveSceneTbl[i][2]
				Gas2GasAutoCall:NotifyPlayerLeaveFbScene(GetServerAutoConn(serverId), id, 30, 8803)
			end
			
			MsgToConnById(LeaverID,127)
			Gas2GacById:UpdateTeammateIcon(LeaverID)
	end
	
	local parameters = {}
	parameters.LeaverID = LeaverID
	parameters.uPlayerID = uPlayerID
	CallAccountManualTrans(Conn.m_Account, team_box, "RemoveTeamMember", CallBack, parameters,Player.m_Properties:GetTeamID())
end

--------------------------------------------------------------------------
--�����öӳ���
function CGasTeam.SetCaptain(Conn, uTargetID)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	local uPlayerID = Player.m_uID
	
	local function CallBack(nIndex,res)
		if not nIndex then
			if IsNumber(res) then
				MsgToConn(Conn, res)
			end
			return
		end
		
		CGasTeam.InitAllServerTeamInfo(res.m_TeamID)
		local team_members = res.m_tblTeamMem
		local cap_name = res.m_nTeamCap
		for i=1,#team_members do
			local member_id = team_members[i][1]
			MsgToConnById(member_id,128,cap_name)
		end
	end
	
	local parameters = {}
	parameters.uTargetID = uTargetID
	parameters.uPlayerID = uPlayerID
	CallAccountManualTrans(Conn.m_Account, team_box, "SetCaptainRPC", CallBack, parameters, Player.m_Properties:GetTeamID())
end

------------------------------------------------------------------------------

--�����÷��䷽ʽ��
function CGasTeam.SetAssignMode(Conn, eAM)
	local Player = Conn.m_Player
	
	if not (Player and IsCppBound(Player)) then return end
	if Player.m_TemporaryTeam then return end
		
	local uPlayerID = Player.m_uID
	
	local function CallBack(nIndex,tblMembers,TeamID)
		if nIndex ~= 2 then return end
		for _, id in pairs( tblMembers) do
			local member_id = id[1]
			Gas2GacById:UpdateAssignMode(member_id, eAM)
		end
	end
	
	local parameters = {}
	parameters.eAM = eAM
	parameters.uPlayerID = uPlayerID
	
	CallAccountManualTrans(Conn.m_Account, team_box, "SetAssignModeRPC", CallBack, parameters, Player.m_Properties:GetTeamID())
end

-------------------------------------------------------------------------------

--��������г�Ա���������Լ�����
local function GetTeammates(tblMembers, PlayerID)
	local tbl = {}
	local row = tblMembers:GetRowNum()
	for i = 1, row do
		if	PlayerID ~= tblMembers(i,1) then
			local charId	= tblMembers(i,1)						--��ɫID
			local charName	= tblMembers(i,2)						--��ɫ��
			local bOnline	= true				--����״̬
			if 0 == tblMembers(i,3) then
				bOnline	= false
			end
			local player 	= g_GetPlayerInfo(charId)
			local entityId	= (player and IsCppBound(player)) and player:GetEntityID() or 0	--EntityID
			local class		= tblMembers(i,4)						--ְҵ
			local sex		= tblMembers(i,5)						--�Ա�
			local nLevel = tblMembers(i,6)
			table.insert(tbl, {charId, charName, bOnline, entityId, class, sex,nLevel})
		end
	end
	return tbl
end
------------------------------------------------------------------
function CGasTeam.GetTeamMembersByConn(Conn)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
	local uPlayerID = Player.m_uID
	CGasTeam.GetTeamMembers(uPlayerID)
end

--�����С�����г�Ա��
function CGasTeam.GetTeamMembers(uPlayerID)
	local Player = g_GetPlayerInfo(uPlayerID)
	if Player and Player.m_TemporaryTeam then
		g_TemporaryTeamMgr:SendTeamInfo(Player.m_TemporaryTeam)
		return 
	end
	local function CallBack(tblRes)
		local team_mates,team_cap,uTeamID,uLevel = tblRes.team_mates,tblRes.captain,tblRes.uTeamID,tblRes.PlayerLevel
		Gas2GacById:ReturnGetTeamMemberBegin(uPlayerID)
		local team_size = 0
		local team_info = {}
		if team_mates and team_mates:GetRowNum() > 0 then
				team_size = team_mates:GetRowNum()
				team_info = GetTeammates(team_mates, uPlayerID)
		end
		if Player and IsCppBound(Player) then
			if not Player.m_TemporaryTeam then
				Player:SetTeamID(uTeamID)
				if uTeamID > 0 then
					CTeamServerManager_CppAddTeamMember(uTeamID,1,Player:GetEntityID())
				end
			end
		end
		for i = 1, #team_info do
			local charInfo = team_info[i]
			if charInfo[1] ~= uPlayerID then
				local char = g_GetPlayerInfo(charInfo[1])
				local entityId	= (char and IsCppBound(char)) and char:GetEntityID() or 0
				Gas2GacById:ReturnGetTeamMember( uPlayerID,charInfo[1], charInfo[2], charInfo[3], entityId, charInfo[5],charInfo[6],charInfo[7])
			end
			Gas2GacById:SendTeamMemberLevel(charInfo[1],uPlayerID,uLevel)
		end
		Gas2GacById:ReturnGetTeamMemberEnd(uPlayerID, team_cap, team_size)
	end
	
	local parameters = {}
	parameters.uPlayerID = uPlayerID
	CallDbTrans(team_box, "GetTeamMembersByChar", CallBack, parameters)
end
--------------------------------------------------------------------------

--�����䷽ʽ������ģʽ������Ʒ���趨�� 
function CGasTeam.SetAuctionStandard(Conn, AuctionStandard)
	local Player = Conn.m_Player
	
	if not (Player and IsCppBound(Player)) then return end
		
	local uPlayerID = Player.m_uID
	
	local function CallBack(team_members,uTeamID)
			if not team_members then return end
			--Gas2Gac:UpdateAuctionStandard(g_TeamMgr:GetTeamMsgSender(uTeamID), AuctionStandard)
			for _, id in pairs( team_members) do
					local member_id = id[1]
					Gas2GacById:UpdateAuctionStandard(member_id, AuctionStandard)
			end
	end
	
	local parameters = {}
	parameters.uPlayerID = uPlayerID
	parameters.AuctionStandard = AuctionStandard
	CallAccountManualTrans(Conn.m_Account, team_box, "SetAuctionStandardRPC", CallBack, parameters, Player.m_Properties:GetTeamID())
end 

--�����䷽ʽ������ģʽ�������׼��趨�� 
function CGasTeam.SetAuctionBasePrice(Conn, AuctionBasePrice)
	local Player = Conn.m_Player
	
	if not (Player and IsCppBound(Player)) then return end
		
	local uPlayerID = Player.m_uID
	
	local function CallBack(team_members,uTeamID)
			if not team_members then return end
			for _, id in pairs( team_members) do
					local member_id = id[1]
					Gas2GacById:UpdateAuctionBasePrice(member_id, AuctionBasePrice)
			end
	end
	
	local parameters = {}
	parameters.uPlayerID = uPlayerID
	parameters.AuctionBasePrice = AuctionBasePrice
	CallAccountManualTrans(Conn.m_Account, team_box, "SetAuctionBasePriceRPC", CallBack, parameters, Player.m_Properties:GetTeamID())
end 
---------------------------------------------------------------------------------

--������֪ͨ�����Ŷ�С�ӳ�Ա��
function CGasTeam.NotifyTeamInfoOnline(data)
	local Conn,uCharID,teamInfo = unpack(data)
	local team_id = teamInfo["team_id"]
	local team_cap = teamInfo["team_cap"]
	local eAM = teamInfo["eAM"]
	local AuctionStandard = teamInfo["AuctionStandard"]
	local AuctionBasePrice = teamInfo["AuctionBasePrice"]
	local MarkInfo = teamInfo["MarkInfo"]
	local nIndex = teamInfo["nIndex"]
	local onList = teamInfo["AppTeamList"]
	local Player = Conn.m_Player
	
	if(next(onList)) then
		Gas2Gac:GetLineTeamListBegin(Conn)
			for k,v in pairs(onList) do
				local nType  = onList[k][1] 
				local nTime  = onList[k][2] 
				Gas2Gac:GetLineTeamList(Conn,nType,nTime)
			end
		Gas2Gac:GetLineTeamListEnd(Conn)
	end
	g_TemporaryTeamMgr:InitTemporaryTeamInfo(uCharID)
	
	if team_id == 0 or (not IsCppBound(Conn.m_Player)) then return end
	
	Gas2GacById:UpdateAssignMode(uCharID, eAM)
	Gas2GacById:UpdateAuctionStandard( uCharID, AuctionStandard)
	Gas2GacById:UpdateAuctionBasePrice( uCharID, AuctionBasePrice)
	--ˢ�±����Ϣ
	for i=1,MarkInfo:GetRowNum() do
		Gas2GacById:ReturnUpdateTeamMark(uCharID, MarkInfo(i,1), MarkInfo(i,2), MarkInfo(i,3))
	end	
	Gas2GacById:ReturnUpdateTeamMarkEnd(uCharID)
	if 0 ~= nIndex  then
		--,"���ǵ�һ�����ߵĶ����Ա���Զ�ת��Ϊ�ӳ���"
		MsgToConn(Conn,129)
		if nIndex == 2 then
			--,"���ǵ�һ�����ߵ��Ŷӳ�Ա���Զ�ת��Ϊ�ų���"
			MsgToConn(Conn,130)
		end
	end
end

--[[
   	��Ա���߶�С���Ŷ���Ϣ����
--]]
function CGasTeam.DealWithTeamInfoLogout(uCharID,teamInfo)
	local function Init()
		local TeamID = teamInfo["team_id"]
		local new_cap = teamInfo["team_cap"]
		local tblMembers = teamInfo["team_members"]
		local validateInfo = teamInfo["validateInfo"]
		for m=1,validateInfo:GetRowNum() do
			MsgToConnById(validateInfo(m,1),101,teamInfo["char_name"])
		end
		if TeamID ==nil or TeamID == 0 then return end
		CGasTeam.InitAllServerTeamInfo(TeamID)
		if new_cap ~= uCharID and new_cap ~= 0 then
			--"�ӳ����ߣ��ӳ�ת�Ƹ���" ..
			for i=1,#tblMembers do
				local member_id = tblMembers[i][1]
				if member_id == new_cap then
					MsgToConnById(member_id,143)
				else
					MsgToConnById(member_id,131,teamInfo["new_cap_name"])
				end
			end
		end	
		for i=1,#tblMembers do
			local member_id = tblMembers[i][1]
			Gas2GacById:NotifyOffline(member_id, uCharID)
		end
	end
	apcall(Init)
end

--��ɾ����ɫʱ��С���Ŷ���Ϣ�Ĵ���
function CGasTeam.DealWithTeamInfoWhenDelChar(uPlayerID,sCharName,team_info)
		local uTeamID = team_info.m_nTeamID
		local team_members = team_info.m_tblTeamMembers
		if uTeamID == nil or 0 == uTeamID then return end
		CGasTeam.InitAllServerTeamInfo(uTeamID)
		if IsTable(team_members) then
			--֪ͨ�����˸����뿪
			for i=1,#team_members do 
				local member_id = team_members[i][1]
				MsgToConnById(member_id,122,sCharName)
			end
			if #team_members == 1 then
				--С�ӽ�ɢ
  			local member_id = team_members[1][1]
				--"��������С��2���Զ���ɢ"
				MsgToConnById(member_id,125)
				Gas2GacById:UpdateTeammateIcon(member_id)
			end
		end
		--�淨�飬���ٻ�ȡ����λ�õ�Tick
		CGasTeammatePosMgr.LeaveTeamStopGetTeammatePos(uTeamID,uPlayerID)
end

--��֪ͨ����������ˢ�±��������Ա��
function CGasTeam.SendTeamMemberHPMP()
   local AllTeamInfo = g_TeamMgr.m_tblMembers
   for i,v in pairs(g_TeamMgr.m_tblMembers) do
       local TeamInfo = v
       for i =1,#TeamInfo do
           local member_id = TeamInfo[i]
           local member = g_GetPlayerInfo(member_id)
           if member and IsCppBound(member)   then
            local nTeamID = member.m_Properties:GetTeamID()
            local nCurHP, nMaxHP = member:CppGetHP(),member:CppGetMaxHP()
            local nCurMP, nMaxMP = 0,0
           	local nClass = member:CppGetClass()
            local sClass = g_GetPlayerClassNameByID(nClass)
           	if not (sClass == "������ʿ" or sClass == "��ʿ" or "����սʿ" == sClass) then
                nCurMP, nMaxMP = member:CppGetMP(),member:CppGetMaxMP()
            end
            for _, otherServerConn in pairs(g_OtherServerConnList) do
               Gas2GasCall:SendTeamMemberHPMP(otherServerConn,nTeamID,member_id,nCurHP,nMaxHP,nCurMP,nMaxMP)
            end
         end
      end
  end
end

--------------------------------------------------------------------------------------------
----------------------------------------�����㲥��Ϣ--------------------------------------
function CGasTeam.InitAllServerTeamInfo(TeamID,nType)
	local init_type = nType or 0
	for server_id in pairs(g_ServerList) do
			Gas2GasAutoCall:InitTeamInfo(GetServerAutoConn(server_id),TeamID,server_id,init_type)
	end
end


function CGasTeam.SetTeamMemberLevel(player_id)
	for server_id in pairs(g_ServerList) do
			Gas2GasAutoCall:ResetTeamMemberLevel(GetServerAutoConn(server_id),player_id)
	end
end

function CGasTeam.InitTeamInfo(Conn,TeamID,server_id,nType)
	local function CallBack(team_info)
		g_TeamMgr:InitTeamInfo(team_info)
		if 0 == nType then
			local sender = g_TeamMgr:GetTeamMsgSender(TeamID)
			Gas2Gac:UpdateTeammateIcon(sender)
		else
			--�з�ֻ��entityid
			local uCharID = nType
			local char = g_GetPlayerInfo(uCharID)
			local char_team_id = (char and IsCppBound(char) and char.m_TemporaryTeam) and char.m_TemporaryTeam or TeamID
			local members = g_TeamMgr:GetMembers(char_team_id)
			local sender = g_TeamMgr:GetTeamMsgSender(char_team_id)
			for i =1,#members do
				local member_id = members[i]
				local member = g_GetPlayerInfo(member_id)
				local entityId = (member and IsCppBound(member)) and member:GetEntityID() or 0
				Gas2Gac:ReceiveTeamMemberEntityId(sender,member_id,entityId)
			end
		end
	end
	if TeamID then
		if not g_App:CallDbHalted() and TeamID > 0 then
			local data = {["TeamID"] = TeamID,["server_id"] = server_id}
			CallDbTrans("GasTeamDB", "GetTeamCapAndMem", CallBack, data)
		end
	end
end

function CGasTeam.ResetTeamMemberLevel(Conn,player_id)
	local player = g_GetPlayerInfo(player_id)
	local function CallBack(uLevel,uTeamID)
		if player and IsCppBound(player) then
			if not player.m_TemporaryTeam then
				player:SetTeamID(uTeamID)
				if uTeamID > 0 then
					CTeamServerManager_CppAddTeamMember(uTeamID,1,player:GetEntityID())
				end
			end
		end
		local sender = g_TeamMgr:GetTeamMsgSender(uTeamID)
		Gas2Gac:SendTeamMemberLevel(sender,player_id,uLevel)
	end
	local data = {}
	data.m_uPlayerID = player_id
	CallDbTrans("GasTeamDB", "GetPlayerLevelAndTeamID", CallBack, data)
end

