gac_require "test/common/CTstLoginControler"

function InitGacPlayerSkillPannel( TestTest )
	local controler = {}
	local WndSkillPannel = {}
	local CbtSkill = {}
	local FunctionArea = {}
	local player_controler = {}
	
	function TestTest:setup()
	end
	--�������
	
	function TestTest:TestBegin()
		controler = CTstLoginControler:new()
		controler:OneStepLogin()
		player_controler = CTstPlayerControler:new()
		CbtSkill = g_GameMain.m_FunctionArea.m_ChkBtnSkill
		--�˵�����
		FunctionArea = g_GameMain.m_FunctionArea
		--���������
		MasterSkillArea = g_GameMain.m_MasterSkillArea 
		--�������
		MainSkillsToolBar = g_GameMain.m_MainSkillsToolBar
		--����ѧϰ���
		WndSkillPannel = g_GameMain.m_SkillParent.m_SkillLearnWnd 
		--�㿪��������
		Gac2Gas:GM_Execute( g_Conn, "$deltblshortcut(" .. g_MainPlayer.m_Properties:GetCharID()
 .. ")" )
	end
	
	function TestTest:TestOpenWndAndUseSkill()
		FunctionArea:OnCtrlmsg( FunctionArea.m_ChkBtnSkill, BUTTON_LCLICK, uParam1, uParam2 )
		assert(g_GameMain.m_SkillParent:IsShow())
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[2], BUTTON_LCLICK, 0, 0)
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillLearnBtn, BUTTON_LCLICK, 0, 0)
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[3], BUTTON_LCLICK, 0, 0)
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillLearnBtn, BUTTON_LCLICK, 0, 0)	
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[4], BUTTON_LCLICK, 0, 0)
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillLearnBtn, BUTTON_LCLICK, 0, 0)			
	end
	
	--����������ϵļ���ͼ���Ϸŵ�������ϣ�Ȼ�󵥻����Ҽ�ʹ��
	function TestTest:TestDragItemOnShortcut()
		for i=1, 10 do
			WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[2], BUTTON_DRAG, 0, 0)
			local state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_PickupSkill, state, "")
			MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, i-1)
			state = g_WndMouse:GetCursorState()
			--print(i)
			assert_equal(ECursorState.eCS_Normal, state, "")
			local tblShortcutPiece = MainSkillsToolBar.m_WndSkill:GetTblShortcutPiece()
			local Piece = tblShortcutPiece[i]
			local PieceState = Piece:GetState()
			assert_equal(EShortcutPieceState.eSPS_Skill, PieceState, "")
			--�����
			MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, i-1)
		end
	end
	
	--����������ϵ�ͼ���ƶ������������ϣ�Ȼ�󵥻����Ҽ�ʹ��
	function TestTest:TestMoveShortcut()
		MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_BtnPage, ITEM_LBUTTONCLICK, 0, 0)
		for i=1, 10 do
			local tblShortcutPiece1 = MainSkillsToolBar.m_WndSkill:GetTblShortcutPiece()
			local Piece1 = tblShortcutPiece1[i]
			MainSkillsToolBar.m_WndSkill:DragShortcut(Piece1)
			local state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_PickupSkill, state, "")
			assert_equal(EShortcutPieceState.eSPS_None, Piece1:GetState(), "")
			
			MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 0, i-1)
			state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_Normal, state, "")
			local tblShortcutPiece2 = MasterSkillArea.m_WndSkill:GetTblShortcutPiece()
			local Piece2 = tblShortcutPiece2[i]
			assert_equal(EShortcutPieceState.eSPS_Skill, Piece2:GetState(), "")
			--�����
			MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 0, i-1)
		end
	end
	
	--��������ϵ�ͼ�궪��
	function TestTest:TestThrowAwayShortcut()
		for i=1, 10 do
			local tblShortcutPiece2 = MasterSkillArea.m_WndSkill:GetTblShortcutPiece()
			local Piece2 = tblShortcutPiece2[i]
			MasterSkillArea.m_WndSkill:DragShortcut(Piece2)
			local state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_PickupSkill, state, "")
			assert_equal(EShortcutPieceState.eSPS_None, Piece2:GetState(), "")
			g_WndMouse:SetCursorSkillState( ECursorSkillState.eCSS_Normal )
			g_GameMain:OnLButtonUp(0,0,0)
			state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_Normal, state, "")
		end
	end
	
	--��������ͼ��
	function TestTest:TestSwapShortcutIcons()
	  --�Ϸŵ�1��ͼ��
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[2], BUTTON_DRAG, 0, 0)
		local state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_PickupSkill, state, "")
		MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, 0)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")
		local tblShortcutPiece = MainSkillsToolBar.m_WndSkill:GetTblShortcutPiece()
		local Piece = tblShortcutPiece[1]
		local PieceState = Piece:GetState()
		assert_equal(EShortcutPieceState.eSPS_Skill, PieceState, "")
		local fs1 = Piece:GetSkillContext()
		
		--�Ϸŵ�2��ͼ��
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[3], BUTTON_DRAG, 0, 0)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_PickupSkill, state, "")
		
		MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, 1)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")
		Piece = tblShortcutPiece[2]
		PieceState = Piece:GetState()
		assert_equal(EShortcutPieceState.eSPS_Skill, PieceState, "")
		local fs2 = Piece:GetSkillContext()
		
		--��1��ͼ��͵�2��ͼ�꽻��
		MainSkillsToolBar.m_WndSkill:DragShortcut(Piece)--�����2��ͼ��
		MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, 0) --�����1������
		MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, 1) --�����2������
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")
		
		Piece = tblShortcutPiece[1]
		local fs1new = Piece:GetSkillContext()
		Piece = tblShortcutPiece[2]
		local fs2new = Piece:GetSkillContext()
		
		assert_equal(fs1, fs2new, "")
		assert_equal(fs2, fs1new, "")
		
		--�ٴӼ���������϶�һ��ͼ��
		WndSkillPannel:OnCtrlmsg(WndSkillPannel.m_SkillBtn[4], BUTTON_DRAG, 0, 0)
		local state, context = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_PickupSkill, state, "")
		
		--�������ϵĵ�1��ͼ�꽻��
		MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, 0) --�����1������
		Piece = tblShortcutPiece[1]
		local fs1newnew = Piece:GetSkillContext()
		assert_equal(context[1], fs1newnew, "")
		state, context = g_WndMouse:GetCursorState()
		assert_equal(fs1new, context[1], "")
		
		--������ϵ�ͼ�궪��
		g_WndMouse:SetCursorSkillState( ECursorSkillState.eCSS_Normal )
		g_GameMain:OnLButtonUp(0,0,0)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")		
	end
	
	function TestTest:TestEnd()
		FunctionArea:OnCtrlmsg( FunctionArea.m_ChkBtnSkill, BUTTON_LCLICK, uParam1, uParam2 )
		controler:LoginOutFromGame()
	end
	
	function TestTest:teardown()
	end
end