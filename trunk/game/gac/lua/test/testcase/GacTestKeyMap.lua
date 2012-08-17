gac_require "test/common/CTstLoginControler"
engine_require "common/Misc/TypeCheck"

function InitGacTestKeyMap()
	local Test_KeyMap = TestCase("GacTestKeyMap")
	controler = CTstLoginControler:new()
 	function Test_KeyMap:setup()
	end
	function Test_KeyMap:TestBegin()
		controler:OneStepLogin()
	end
	function Test_KeyMap:Test_SetKeyMap()
	--���԰���ӳ���������
		local g_CGameAccelerator = CGameAccelerator:new()
		g_CGameAccelerator:OnAccelerator( Msg, 119 , lParam)
		assert_true(g_GameMain.m_SysSetting.m_KPmap:IsShow())
		--��������otherKey
		local wnd = g_GameMain.m_SysSetting.m_KPmap.SkillKeyWnd[1]         --��һ��
		wnd:OnCtrlmsg(wnd:GetDlgChild("oneKey"),BUTTON_LCLICK,0,0)
		g_GameMain.m_KeyAccelerator:OnAccelerator( Msg, 68 , lParam)
		g_GameMain.m_SysSetting.m_KPmap:OnCtrlmsg(g_GameMain.m_SysSetting.m_KPmap.mCok,BUTTON_LCLICK,0,0)
		local m_SetKeyMap = WaitEvent(true,nil,Event.Test.SetKeyMapEnd)--�����Ƿ�ɹ�
		local m_SendAllKeyMapsEnd = WaitEvent(true,nil,Event.Test.SendAllKeyMapsEnd)
		--��������otherKey
		local wnd = g_GameMain.m_SysSetting.m_KPmap.SkillKeyWnd[2]         --��һ��
		wnd:OnCtrlmsg(wnd:GetDlgChild("otherKey"),BUTTON_LCLICK,0,0)
		g_GameMain.m_KeyAccelerator:OnAccelerator( Msg, 69 , lParam)
		g_GameMain.m_SysSetting.m_KPmap:OnCtrlmsg(g_GameMain.m_SysSetting.m_KPmap.mCok,BUTTON_LCLICK,0,0)
		local m_SetKeyMap = WaitEvent(true,nil,Event.Test.SetKeyMapEnd)--�����Ƿ�ɹ�
		local m_SendAllKeyMapsEnd = WaitEvent(true,nil,Event.Test.SendAllKeyMapsEnd)
		
		g_GameMain.m_SysSetting.m_KPmap:OnCtrlmsg(g_GameMain.m_SysSetting.m_KPmap.mCcancal,BUTTON_LCLICK,0,0)
	end
	function Test_KeyMap:Test_DefaultSetKeyMap()
	--���Իָ���Ĭ������
		local g_CGameAccelerator = CGameAccelerator:new()
		g_CGameAccelerator:OnAccelerator( Msg, 119 , lParam)
		assert_true(g_GameMain.m_SysSetting.m_KPmap:IsShow())
		g_GameMain.m_SysSetting.m_KPmap:OnCtrlmsg(g_GameMain.m_SysSetting.m_KPmap.mCDefault,BUTTON_LCLICK,0,0)
		g_GameMain.m_SysSetting.m_KPmap:OnCtrlmsg(g_GameMain.m_SysSetting.m_KPmap.mCok,BUTTON_LCLICK,0,0)
		g_GameMain.m_SysSetting.m_KPmap:OnCtrlmsg(g_GameMain.m_SysSetting.m_KPmap.mCcancal,BUTTON_LCLICK,0,0)
	end
	function Test_KeyMap:TestEnd()
		controler:LoginOutFromGame()
	end
	
	function Test_KeyMap:teardown()
	end
end

