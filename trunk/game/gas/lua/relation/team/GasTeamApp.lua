CTeamAppl = class()
local appteamlist_box = "GasAppTeamListDB"
local teamlist = "appteamlist"
--��ѯ�б���Ϣ
function CTeamAppl.getAppTeamList(Conn,nType)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
		
		local function CallBack(AppTeamList)
			if not (Player and IsCppBound(Player)) then return end
			Gas2Gac:GetTeamListBegin(Conn,nType)
				 for k,v in pairs(AppTeamList) do
				 		local nID    = AppTeamList[k][1]
				 		local sName  = AppTeamList[k][2]
				 		local nCamp  = AppTeamList[k][3]
				 		local nClass = AppTeamList[k][4]
				 		local nLevel = AppTeamList[k][5] 
				 		local nType  = AppTeamList[k][6] 
				 		local sMsg 	 = AppTeamList[k][7] 
				 		local nTime  = AppTeamList[k][8] 
				 		if nCamp == Player:CppGetBirthCamp()then
				 		Gas2Gac:GetTeamList(Conn, nID, sName, nCamp, nClass, nLevel, nType, sMsg, nTime)
						end	
				 end
			Gas2Gac:GetTeamListEnd(Conn,nType)	
		end	
		local parameters = {}
		parameters.uCharID = Player.m_uID
		parameters.nType = nType
		--parameters.saveTime = tonumber(GetStaticTextClient(990003)) --���ñ�����ʱ��
		CallAccountManualTrans(Conn.m_Account, appteamlist_box, "inquireAppTeamList", CallBack, parameters, teamlist)
end


 --ȡ���������뿪�Ŷ��б�
function CTeamAppl.leaveList(Conn,nType)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end

	local function CallBack(bFlag)
		if not bFlag then
			return
		else
			Gas2Gac:RenewTeamList(Conn,nType)  --���سɹ�ȡ��������ˢ���б�
		end
	end
	
	local parameters = {}
		parameters.uCharID = Conn.m_Player.m_uID
		parameters.nType = nType
		CallAccountManualTrans(Conn.m_Account, appteamlist_box, "removeAppTeamList", CallBack, parameters, teamlist)
end

 --��������б�
function CTeamAppl.joinTeamList(Conn,nType,sMsg)
	local Player = Conn.m_Player
	if not (Player and IsCppBound(Player)) then return end
		
		local function CallBack(bFlag)
			if not bFlag then
				return
			else
				Gas2Gac:RenewTeamList(Conn,nType)  --����ˢ���б�
				Gas2Gac:ChangeBtnState(Conn,nType)  --���ڸı䰴��״̬
			end
		end
		local parameters = {}
			parameters.uCharID = Player.m_uID
			parameters.nType   = nType
			parameters.sMsg = sMsg
			CallAccountManualTrans(Conn.m_Account, appteamlist_box, "addAppTeamList", CallBack, parameters, teamlist)
end

--��ҵ��ˢ���б�
function CTeamAppl.upFreshTeamList(Conn,nType)
	
	local Player = Conn.m_Player
		if(Player.m_nUpdateOnlineTeamListTimeMark and os.time() - Player.m_nUpdateOnlineTeamListTimeMark < 10 ) then
				return --ˢ��ʱ����С��12��(�ͻ���������,������������������)
			else
				Player.m_nUpdateOnlineTeamListTimeMark = os.time()
			end
	local function CallBack(AppTeamList)
				Gas2Gac:GetTeamListBegin(Conn,nType)
					 for k,v in pairs(AppTeamList) do
					 		local nID    = AppTeamList[k][1]
					 		local sName  = AppTeamList[k][2]
					 		local nCamp  = AppTeamList[k][3]
					 		local nClass = AppTeamList[k][4]
					 		local nLevel = AppTeamList[k][5] 
					 		local nType  = AppTeamList[k][6] 
					 		local sMsg 	 = AppTeamList[k][7] 
					 		local nTime  = AppTeamList[k][8] 
					 		if nCamp == Conn.m_Player:CppGetBirthCamp()then
					 		Gas2Gac:GetTeamList(Conn, nID, sName, nCamp, nClass, nLevel, nType, sMsg, nTime)
							end	
					 end
				Gas2Gac:GetTeamListEnd(Conn,nType)	
			end	
			local parameters = {}
			parameters.uCharID = Conn.m_Player.m_uID
			parameters.nType = nType
			--parameters.saveTime = tonumber(GetStaticTextClient(990003)) --���ñ�����ʱ��
			CallAccountManualTrans(Conn.m_Account, appteamlist_box, "inquireAppTeamList", CallBack, parameters, teamlist)
end
