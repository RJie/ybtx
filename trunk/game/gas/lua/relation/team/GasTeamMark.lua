
CTeamMark = class()
function CTeamMark.UpdateTeamMark(Conn, uMarkType, uTargetType, uTargetID)
	local Player = Conn.m_Player
	if Player == nil then
		return
	end
	local uPlayerID = Player.m_uID
	--�жϴ������������Ƿ���ȷ
	if not(uMarkType >= 0 and uMarkType <= 10) then
		return
	end
	if 1 ~= uTargetType and 2 ~= uTargetType and 3 ~= uTargetType then
		return
	end
	
	--�ص������������߼���
	local function CallBack(TeamMembers)
			if IsTable(TeamMembers) then
				for j=1,#TeamMembers do
					local MemberID = TeamMembers[j][1]
					Gas2GacById:ReturnUpdateTeamMark(MemberID, uMarkType, uTargetType, uTargetID)
					Gas2GacById:ReturnUpdateTeamMarkEnd(MemberID)
				end
			end
	end
  local parameters = {}
	parameters.uPlayerID = uPlayerID
	parameters.uMarkType= uMarkType
	parameters.uTargetType = uTargetType
	parameters.uTargetID = uTargetID
	CallAccountManualTrans(Conn.m_Account, "GasTeamMarkDB", "UpdateTeamMark", CallBack, parameters, Conn.m_Player.m_Properties:GetTeamID())
end

----------------------------------------------------------------------