
CGasAssoTongBasic = class()

--Ӷ����Ⱥ��
local function TongChatRequest(Conn,members,message)
	local sender = Conn.m_Player
	if members ~= nil then
		for i=1,members:GetRowNum() do
			local member_id = members(i,1)
			if(g_GetPlayerInfo(member_id) ~=nil and member_id ~= sender.m_uID ) then
				Gas2Gac:ReceiveTongChatSendMsg(g_GetPlayerInfo(member_id).m_Conn,sender.m_Properties:GetCharName(),message)
			else
				--TODO:����������Ϣ
			end
		end
	end
end

--@brief Ӷ����Ⱥ��
--@param text:���������
function CGasAssoTongBasic.TongChatSendMsg(Conn,text)
	local data = {
								["playerId"] = Conn.m_Player.m_uID,
								["text"] = text
							 }
	local function callback( members)
		TongChatRequest(Conn,members,text)
	end
	--local CTongBasicBox = (g_DBTransDef["CTongBasicBox"])
	CallAccountManualTrans(Conn.m_Account, "CTongBasicBox", "GroupChatRequest", callback, data)
end