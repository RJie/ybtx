
CGasSyssetting = class()

function CGasSyssetting.SysSettingBegain(Conn)
	local Player = Conn.m_Player
	if Player == nil then
		return
	end
	Player.tblSysSettingInfo = Player.tblSysSettingInfo or {}
end

function CGasSyssetting.SysSettingEnd(Conn)
	local Player = Conn.m_Player
	if Player == nil then
		return
	end
	local parameters = Player.tblSysSettingInfo
	if parameters == nil then
		return
	end
	--�ص������������߼���
	local function CallBack(result)
		--��������
		Gas2Gac:ReturnSetKeyMap( Conn, true )
		
		--�������
		if result["mouse_ret"] then
			if ( Player ~= nil and Player.tblSysSettingInfo ~= nil) then
				local parameter = Player.tblSysSettingInfo["MouseSetting"]
				if parameter ~= nil then
					Gas2Gac:ReturnMouseKey(Conn, parameter["lockTarget"], parameter["movekey"], parameter["selectLeft"], parameter["selectRight"], parameter["attrackLeft"], parameter["attrackRight"], parameter["distance"])
				end
			end
		end
		
		Player.tblSysSettingInfo = nil
	end
	CallAccountAutoTrans(Conn.m_Account, "SysSettingDB", "SysSettingEndDB", CallBack, parameters)
end
