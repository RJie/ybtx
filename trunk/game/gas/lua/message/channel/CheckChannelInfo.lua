--require "message/channel/Dyn_System_Message"
--Channel_Common��������
--[[
	index: 		���б���������λ��
	name_d:		�߻���������
	name_p:		����������
	name_channel:	Ƶ������
--]]
local function _get_Channel_Common_Info()
	g_channel_info = {}
	for i, v in pairs(Channel_Common) do
		g_channel_info[v.index] = { v.index, v.name_d, v.name_p, v.name_channel }
	end
end

_get_Channel_Common_Info()


local function _get_sys_dyn_msg()
	g_sys_dyn_msg = {}
	for i, v in pairs(Dyn_System_Message) do
		table.insert(g_sys_dyn_msg, v)
	end
end
_get_sys_dyn_msg()