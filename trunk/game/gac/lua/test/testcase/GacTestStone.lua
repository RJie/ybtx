gac_require "test/common/CTstLoginControler"
engine_require "common/Misc/TypeCheck"
--����Ƕ��ʯ ��������  
function InitGacTestStone()
	local TestStone= TestCase("GacTestStone")
	controler = CTstLoginControler:new()
	
	function TestStone:setup()
	end
	function TestStone:TestBegin()
		controler:OneStepLogin()
	end
	
	--��׹���
	function TestStone:test_dakong()
		local StoneWnd = CStone.GetWnd()
		StoneWnd:ShowWnd(true) --�򿪱�ʯ���
		StoneWnd:OnCtrlmsg(StoneWnd:GetDlgChild("1"),BUTTON_LCLICK,0,0)
		 
		Gac2Gas:GM_Execute( g_Conn, "$additem(15,\"һ�������\",1)" )
		local str = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		Gac2Gas:GM_Execute( g_Conn, "$additem(15,\"���������\",1)" )
		local str1 = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		Gac2Gas:GM_Execute( g_Conn, "$additem(15,\"���������\",1)" )
		local str2 = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		--[[  --��Ϊ�����ĸ����еȼ�����,�Ȳ���
		Gac2Gas:GM_Execute( g_Conn, "$additem(15,\"�ļ������\",1)" )
		local str3 = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		--]]
		--�㿪��������
		g_GameMain.m_FunctionArea:OnCtrlmsg( g_GameMain.m_FunctionArea.m_ChkBtnBag,BUTTON_LCLICK,0,0 )
		assert_true(StoneWnd.StonePartUsing:IsShow(),"[PartStoneISShow]")
		WndMainBag = g_GameMain.m_WndMainBag
		 
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("1"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("dakong"),BUTTON_LCLICK,0,0)
		local strRet = WaitEvent(true,nil,Event.Test.OpenHole) --��׵ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("2"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("dakong"),BUTTON_LCLICK,0,0)
		local strRet1 = WaitEvent(true,nil,Event.Test.OpenHole) --��׵ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 2)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("3"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("dakong"),BUTTON_LCLICK,0,0)
		local strRet2 = WaitEvent(true,nil,Event.Test.OpenHole) --��׵ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		
		--[[  --�ȼ�����
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 3)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("4"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("dakong"),BUTTON_LCLICK,0,0)
		local strRet3 = WaitEvent(true,nil,Event.Test.OpenHole) --��׵ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		--]]
	end
	
	--��Ƕ����
	function TestStone:test_xiangqian()
		local StoneWnd = CStone.GetWnd()
		StoneWnd:OnCtrlmsg(StoneWnd:GetDlgChild("1"),BUTTON_LCLICK,0,0)
		Gac2Gas:GM_Execute( g_Conn, "$additem(14,\"һ�����鱦ʯ\",1)" )
		local str = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		Gac2Gas:GM_Execute( g_Conn, "$additem(14,\"һ�����鱦ʯ\",1)" )
		local str1 = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		Gac2Gas:GM_Execute( g_Conn, "$additem(14,\"һ�����鱦ʯ\",1)" )
		local str2 = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)

		assert_true(StoneWnd.StonePartUsing:IsShow(),"[PartStoneISShow]")
		WndMainBag = g_GameMain.m_WndMainBag
		 --��Ƕ��һ����
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("1"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("xiangqian"),BUTTON_LCLICK,0,0)
		local strRet = WaitEvent(true,nil,Event.Test.InlayStone) --��Ƕ�ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		--��Ƕ�ڶ�����
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("2"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("xiangqian"),BUTTON_LCLICK,0,0)
		local strRet1 = WaitEvent(true,nil,Event.Test.InlayStone) --��Ƕ�ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		--��Ƕ��������
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("3"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("xiangqian"),BUTTON_LCLICK,0,0)
		local strRet1 = WaitEvent(true,nil,Event.Test.InlayStone) --��Ƕ�ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.OpenHole,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
	end
	
	--ժ������
	function TestStone:test_zhaichu()
		local StoneWnd = CStone.GetWnd()
		StoneWnd:OnCtrlmsg(StoneWnd:GetDlgChild("1"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("1"),BUTTON_LCLICK,0,0)
		StoneWnd.StonePartUsing:OnCtrlmsg(StoneWnd.StonePartUsing:GetDlgChild("zhaichu"),BUTTON_LCLICK,0,0)
		assert_true(StoneWnd.m_MSG:IsShow(),"[MSGWndISShow]")
		StoneWnd.m_MSG:OnCtrlmsg(StoneWnd.m_MSG:GetDlgChild("BtnOK"),BUTTON_LCLICK,0,0)
		local strRet = WaitEvent(true,nil,Event.Test.RemovalStone) --ժ���ķ���
		local allHolestateRet = WaitEvent(true,nil,Event.Test.SendAllHoleInfoEnd)--���»�ȡ���п׵�״̬
		SetEvent(Event.Test.RemovalStone,false)
		SetEvent(Event.Test.SendAllHoleInfoEnd,false)
		StoneWnd:ShowWnd(false) --�رձ�ʯ���
	end
	
	--��ײ��Ϻϳɹ���
	function TestStone:test_dakongMaterialcompound()
--		local StoneCompoundWnd = CStoneCompound.GetWnd()
--		StoneCompoundWnd:ShowWnd(true)  --�򿪺ϳ����
--		Gac2Gas:GM_Execute( g_Conn, "$additem(15,\"һ�������\",12)" )
--		local str = WaitEvent(true,nil,Event.Test.AddItem)
--		SetEvent(Event.Test.AddItem,false)
--
--		assert_true(StoneCompoundWnd:IsShow(),"[MaterialCompoundISShow]")
--		WndMainBag = g_GameMain.m_WndMainBag
--		 --�ϳ�
--		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1) --��ժ���ı�ʯ�ڰ�����һ��λ��
--		StoneCompoundWnd:OnCtrlmsg(StoneCompoundWnd:GetDlgChild("lowstone"),BUTTON_LCLICK,0,0)
--		StoneCompoundWnd:OnCtrlmsg(StoneCompoundWnd:GetDlgChild("compound"),BUTTON_LCLICK,0,0)
--		local strRet = WaitEvent(true,nil,Event.Test.ReturnSynthesisItemEnd) --�ϳɵķ���
--		SetEvent(Event.Test.ReturnSynthesisItemEnd,false)
--		StoneCompoundWnd:OnCtrlmsg(StoneCompoundWnd:GetDlgChild("lowstone"),BUTTON_LCLICK,0,0)
	end
	
	--��ʯ�ϳɹ���
	function TestStone:test_stonecompound()
--		local StoneCompoundWnd = CStoneCompound.GetWnd()
--		Gac2Gas:GM_Execute( g_Conn, "$additem(14,\"һ�����鱦ʯ\",16)" )
--		local str = WaitEvent(true,nil,Event.Test.AddItem)
--		SetEvent(Event.Test.AddItem,false)
--
--		assert_true(StoneCompoundWnd:IsShow(),"[StoneCompoundISShow]")
--		WndMainBag = g_GameMain.m_WndMainBag
--		 --�ϳ�
--		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
--		StoneCompoundWnd:OnCtrlmsg(StoneCompoundWnd:GetDlgChild("lowstone"),BUTTON_LCLICK,0,0)
--		StoneCompoundWnd:OnCtrlmsg(StoneCompoundWnd:GetDlgChild("batchcompound"),BUTTON_LCLICK,0,0)
--		local strRet = WaitEvent(true,nil,Event.Test.ReturnSynthesisItemEnd) --�ϳɵķ���
--		SetEvent(Event.Test.ReturnSynthesisItemEnd,false)
--		StoneCompoundWnd:OnCtrlmsg(StoneCompoundWnd:GetDlgChild("lowstone"),BUTTON_LCLICK,0,0)
--		StoneCompoundWnd:ShowWnd(false) --�رպϳ����
	end
	
	--�ױ�ʯ����
	--[[
	function TestStone:test_whiteStone()
		local Whitestone = CWhiteStone.GetWnd()
		Whitestone:ShowWnd(true) --�򿪰ױ�ʯ�������
		Gac2Gas:GM_Execute( g_Conn, "$additem(18,\"�ױ�ʯ\",20)" )
		local str = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		assert_true(Whitestone:IsShow(),"[WhiteStoneISShow]")
		WndMainBag = g_GameMain.m_WndMainBag
		 --����
		for i = 1, 20 do
			WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 4)
			Whitestone:OnCtrlmsg(Whitestone:GetDlgChild("Fromstone"),BUTTON_LCLICK,0,0)
			Whitestone:OnCtrlmsg(Whitestone:GetDlgChild("jianding"),BUTTON_LCLICK,0,0)
			local strRet = WaitEvent(true,nil,Event.Test.RetTakeAppraisedStone) --�����ķ���
			SetEvent(Event.Test.RetTakeAppraisedStone,false)
			Whitestone:OnCtrlmsg(Whitestone:GetDlgChild("jianding"),BUTTON_LCLICK,0,0)
			
			local strRet = WaitEvent(true,nil,Event.Test.RetTakeAppraisedStone) --�����ķ���
			SetEvent(Event.Test.RetTakeAppraisedStone,false)
			--��ȡ�����õ��ı�ʯ 
			Whitestone:OnCtrlmsg(Whitestone:GetDlgChild("Tostone"),BUTTON_LCLICK,0,0)
			local strRet1 = WaitEvent(true,nil,Event.Test.RetTakeAppraisedStone) --��ȡ�ķ���
			SetEvent(Event.Test.RetTakeAppraisedStone,false)
			--Whitestone:OnCtrlmsg(Whitestone:GetDlgChild("Fromstone"),BUTTON_LCLICK,0,0)
		end
		Whitestone:ShowWnd(false)  --�رհױ�ʯ�������
	end
	--]]
	function TestStone:TestEnd()
		controler:LoginOutFromGame()
	end
	
	function TestStone:teardown()
	end
end
