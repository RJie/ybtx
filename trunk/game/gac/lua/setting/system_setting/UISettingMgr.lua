CUISettingMgr = class()

local fl_tblIndex = {}
fl_tblIndex["�������"]				= 1
fl_tblIndex["��ҳƺ�"]				= 2
fl_tblIndex["���Ӷ��С��"]			= 3
fl_tblIndex["���Ӷ����"]			= 4
fl_tblIndex["�����������"]			= 5
fl_tblIndex["������ҳƺ�"]			= 6
fl_tblIndex["�������Ӷ��С��"]		= 7
fl_tblIndex["�������Ӷ����"]		= 8
fl_tblIndex["NPC����"]				= 9
fl_tblIndex["��������"]				= 10
fl_tblIndex["��ʾͷ��"]				= 11
fl_tblIndex["���������"]			= 12
fl_tblIndex["�����ͣ��ʾ��������"]	= 13
fl_tblIndex["�ѷ�����ѡ��"]			= 14

function CUISettingMgr:Ctor()
	self.m_tblDefault = {true,false,false,false,true,false,false,false,true,true,true,false,true,false}
	self.m_tblInfo = {}
end

function CUISettingMgr:ReturnGetUISetting(b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14)
	self.m_tblInfo = {b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14}
	g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
	g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit()
	g_GameMain.m_CharacterInSyncMgr:UpdateFriendCanSelectedInSync()
end

--�õ�ĳ�����Ա����õ�״̬�����ؽ����true����false
function CUISettingMgr:GetOnePropState(sIndex)
	if not self.m_tblInfo then return false end
	return self.m_tblInfo[fl_tblIndex[sIndex]]
end

function Gas2Gac:ReturnGetUISetting(Conn,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14)
	g_UISettingMgr:ReturnGetUISetting(b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14)
end