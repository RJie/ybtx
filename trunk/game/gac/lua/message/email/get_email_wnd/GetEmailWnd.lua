CGetEmailWnd = class(SQRDialog)

--�����ռ��䴰��
function CGetEmailWnd:Ctor()
	self:CreateFromRes("GetEmail",g_GameMain)
	self:InitGetEmailWndChild()
	self.m_SenderName = self:GetDlgChild("SenderName")
	self.m_EmailTitle = self:GetDlgChild("EmailTitle")
	self.m_EmailText = self:GetDlgChild("EmailText")
	self.m_EmailText:SetMouseWheel(true)
	self.m_EmailGetGoodsTbl = {}

	g_ExcludeWndMgr:InitExcludeWnd(self, 2, false, {g_GameMain.m_EmailBox})
end


--�ռ��䴰���ó�Ա������¼�����ӿؼ�
function CGetEmailWnd:InitGetEmailWndChild()
	self.m_Close			=	self:GetDlgChild("Close")
	self.m_close			=	self:GetDlgChild("close")
	self.m_Reply			=	self:GetDlgChild("Reply")
	self.m_Money			=	self:GetDlgChild("Money")
	self.m_MoneyCanTake			=	self:GetDlgChild("MoneyCanTake")
	self.m_Jin				=	self:GetDlgChild("Jin")
	self.m_Yin				=	self:GetDlgChild("Yin")
	self.m_Tong				=	self:GetDlgChild("Tong")
	self.m_JinText				=	self:GetDlgChild("jinText")
	self.m_YinText				=	self:GetDlgChild("YinText")
	self.m_TongText				=	self:GetDlgChild("TongText")
	self.m_HaveAttechment			=	self:GetDlgChild("HaveAttechment")
	self.m_TakeAttachment	=	self:GetDlgChild("TakeAttachment")
	self.m_DeleteEmail		=	self:GetDlgChild("DeleteEmail")
	self.m_Reply			=	self:GetDlgChild("Reply")
	self.m_MakeTextAttach	=	self:GetDlgChild("MakeTextAttach")
	self.m_GoodFriend		=	self:GetDlgChild("GoodFriend")
	self.m_Ignore			=	self:GetDlgChild("Ignore")
	
	self.m_Goods_01			=	self:GetDlgChild("Goods_01")
	self.m_Goods_02			=	self:GetDlgChild("Goods_02")
	self.m_Goods_03			=	self:GetDlgChild("Goods_03")
	self.m_Goods_04			=	self:GetDlgChild("Goods_04")
	self.m_GoodsName_01			=	self:GetDlgChild("ItemName1")
	self.m_GoodsName_02			=	self:GetDlgChild("ItemName2")
	self.m_GoodsName_03			=	self:GetDlgChild("ItemName3")
	self.m_GoodsName_04			=	self:GetDlgChild("ItemName4")
	self.m_GoodsName_01:EnableWnd(false)
	self.m_GoodsName_02:EnableWnd(false)
	self.m_GoodsName_03:EnableWnd(false)
	self.m_GoodsName_04:EnableWnd(false)
	
	self.m_Jin:EnableWnd(false)
	self.m_Yin:EnableWnd(false)
	self.m_Tong:EnableWnd(false)
end

--�ռ��䴰���¼���Ӧ����
function CGetEmailWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if(uMsgID == BUTTON_LCLICK) then
		if g_MainPlayer.m_ItemBagLock and (not (Child == self.m_Close or Child == self.m_close)) then
				MsgClient(160032)
				return 
		end
		if(Child == self.m_Close or Child == self.m_close)then
			self:ShowWnd(false)
			g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl={}
			g_GameMain.m_EmailBox.EmailWndTbl.m_ChoosedMail = nil
			Gac2Gas:GetMailList(g_Conn)
		elseif(Child == self.m_MakeTextAttach)then
			--���������ı�����,���ڰ�������, ��Ҫ�ɷ�������
			Gac2Gas:TakeContextAtachment(g_Conn,g_GameMain.m_EmailBox.mailID)
		elseif(Child == self.m_TakeAttachment) then--��ȡȫ������
				Gac2Gas:TakeAttachment(g_Conn,g_GameMain.m_EmailBox.mailID)  --����� Ҫ�����ݿ�ɾ������,��ӵ���Ұ������ݿ���
		elseif(Child == self.m_Reply)then
			if g_GameMain.m_EmailBox.senderID > 0 then
				local replyTitle = "Re:" .. self.m_EmailTitle:GetWndText()
				local replyReceiver = g_GameMain.m_EmailBox.SenderName
				g_GameMain.m_ReceiveBox:ShowReplyBox(replyTitle,replyReceiver)
			else
				MsgClient(4022)
			end
		elseif(Child == self.m_DeleteEmail)then
			local haveNoGoods = true
			for i=1, 5 do
				if g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i] then
					haveNoGoods = false
					break
				end
			end
			if haveNoGoods ==  false or g_GameMain.m_ReceiveBox.m_AttacMoney ~= 0  then
				if g_GameMain.m_EmailBox.m_wndmsg  then
					g_GameMain.m_EmailBox.m_wndmsg:ShowWnd(false)
				end
				self.m_MsgBox =	MessageBox( self, MsgBoxMsg(250),MB_BtnOK) 
				return
			else
				local choosedMail = g_GameMain.m_EmailBox.EmailWndTbl.m_ChoosedMail
				if choosedMail then
					Gac2Gas:DeleteMail(g_Conn,choosedMail.ID)
				end
			end
		elseif(Child == self.m_GoodFriend)then
			--���˷��������Ϊ����
			if g_GameMain.m_EmailBox.senderID == 0 then
				MsgClient(4017)
				return
			end
			
			local tblInfo	= {}
			tblInfo.name	= g_GameMain.m_EmailBox.SenderName
			g_GameMain.m_AssociationWnd:CreateAddToClassWnd(tblInfo, false)
			self.m_GoodFriend:EnableWnd(false)
		elseif(Child == self.m_Ignore)then
			local senderName = g_GameMain.m_EmailBox.SenderName
			if g_GameMain.m_EmailBox.senderID == 0 then
				MsgClient(4016)
				return
			end
			g_GameMain.m_AssociationBase:AddBlackListByName(senderName)
			self.m_Ignore:EnableWnd(false)
		elseif(Child == self.m_Money)then
				Gac2Gas:GetMailMoney(g_Conn,g_GameMain.m_EmailBox.mailID)
		elseif(Child == self.m_Goods_01)then  --��ȡ����
			--������������ȡ��Ʒ����  ����<Email_id,Emailindex>
				Gac2Gas:TakeAttackmentByIndex(g_Conn,g_GameMain.m_EmailBox.mailID,1)--1����emailIndex = 1
		elseif(Child == self.m_Goods_02)then
				Gac2Gas:TakeAttackmentByIndex(g_Conn,g_GameMain.m_EmailBox.mailID,2)--1����emailIndex = 1
		elseif(Child == self.m_Goods_03)then
			Gac2Gas:TakeAttackmentByIndex(g_Conn,g_GameMain.m_EmailBox.mailID,3)--1����emailIndex = 1
		elseif(Child == self.m_Goods_04)then
				Gac2Gas:TakeAttackmentByIndex(g_Conn,g_GameMain.m_EmailBox.mailID,4)--1����emailIndex = 1
		end
	end
end

--��ʾ�ظ��ż��Ĵ���
function CGetEmailWnd:ShowReplyBox(replyTitle,replyReceiver)
	g_GameMain.m_ReceiveBox:ShowWnd(false)
	g_GameMain.m_SendBox.m_EmailTitle:SetWndText(replyTitle)
	g_GameMain.m_SendBox.m_ReceiverName:SetWndText(replyReceiver)
	g_GameMain.m_SendBox.m_EmailText:SetWndText("")
	g_GameMain.m_SendBox.m_Jin:SetWndText("")
	g_GameMain.m_SendBox.m_Yin:SetWndText("")
	g_GameMain.m_SendBox.m_Tong:SetWndText("")
	g_GameMain.m_SendBox.m_SendBtn:EnableWnd(false)
	g_GameMain.m_SendBox:ShowWnd(true)
	g_GameMain.m_WndMainBag:ShowWnd(true)
	g_GameMain.m_SendBox:SetFocus()
	g_GameMain.m_WndMainBag:SetFocus()
	g_GameMain.m_SendBox.m_SendBtn:EnableWnd(true)
end

--��ʾ�ռ��䴰��
function CGetEmailWnd:ShowGetMailWnd(senderName,mailTitle,mailText,MoneyAtta,senderID)

	g_GameMain.m_ReceiveBox.m_SenderName:SetWndText(senderName .. GetStaticTextClient(1128))
	g_GameMain.m_ReceiveBox.m_EmailTitle:SetWndText(mailTitle)
	g_GameMain.m_ReceiveBox.m_EmailText:SetWndText(mailText)
	
	if senderID > 0 then
		g_GameMain.m_SendBox:AddSenderList(senderName)
	end
	
	local bFlag = false
	if MoneyAtta > 0 then
		bFlag = true
		g_GameMain.m_ReceiveBox.m_AttacMoney = MoneyAtta
		gac_gas_require "framework/common/CMoney"
		local money = CMoney:new()
		local tblWnd = {g_GameMain.m_ReceiveBox.m_Jin,g_GameMain.m_ReceiveBox.m_JinText,g_GameMain.m_ReceiveBox.m_Yin,g_GameMain.m_ReceiveBox.m_YinText,g_GameMain.m_ReceiveBox.m_Tong,g_GameMain.m_ReceiveBox.m_TongText}
		money:ShowMoneyInfo(MoneyAtta,tblWnd)	
  	g_GameMain.m_ReceiveBox.m_Money:EnableWnd(true)
  end
  g_GameMain.m_ReceiveBox.m_Jin:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_JinText:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_Yin:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_YinText:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_Tong:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_TongText:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_Money:ShowWnd(bFlag)
	g_GameMain.m_ReceiveBox.m_MoneyCanTake:ShowWnd(bFlag)
	
  g_GameMain.m_ReceiveBox.m_Reply:EnableWnd(true)
	g_GameMain.m_ReceiveBox:ShowWnd(true)
	g_GameMain.m_ReceiveBox:SetFocus()
end

--��ʾ�ռ�����Ʒ����
function CGetEmailWnd:ShowGetMailGoods(mailid)
	g_GameMain.m_ReceiveBox.m_Goods_01:SetWndText("")
	g_GameMain.m_ReceiveBox.m_Goods_02:SetWndText("")
	g_GameMain.m_ReceiveBox.m_Goods_03:SetWndText("")
	g_GameMain.m_ReceiveBox.m_Goods_04:SetWndText("")
	g_GameMain.m_ReceiveBox.m_Goods_01:SetMouseOverDesc("")
	g_GameMain.m_ReceiveBox.m_Goods_02:SetMouseOverDesc("")
	g_GameMain.m_ReceiveBox.m_Goods_03:SetMouseOverDesc("")
	g_GameMain.m_ReceiveBox.m_Goods_04:SetMouseOverDesc("")
	g_GameMain.m_ReceiveBox.m_GoodsName_01:SetWndText("")
	g_GameMain.m_ReceiveBox.m_GoodsName_02:SetWndText("")
	g_GameMain.m_ReceiveBox.m_GoodsName_03:SetWndText("")
	g_GameMain.m_ReceiveBox.m_GoodsName_04:SetWndText("")
	g_GameMain.m_ReceiveBox.m_Goods_01:EnableWnd(false)
	g_GameMain.m_ReceiveBox.m_Goods_02:EnableWnd(false)
	g_GameMain.m_ReceiveBox.m_Goods_03:EnableWnd(false)
	g_GameMain.m_ReceiveBox.m_Goods_04:EnableWnd(false)
	g_DelWndImage(g_GameMain.m_ReceiveBox.m_Goods_01, 1, IP_ENABLE, IP_CLICKDOWN)
	g_DelWndImage(g_GameMain.m_ReceiveBox.m_Goods_02, 1, IP_ENABLE, IP_CLICKDOWN)
	g_DelWndImage(g_GameMain.m_ReceiveBox.m_Goods_03, 1, IP_ENABLE, IP_CLICKDOWN)
	g_DelWndImage(g_GameMain.m_ReceiveBox.m_Goods_04, 1, IP_ENABLE, IP_CLICKDOWN)
	g_GameMain.m_ReceiveBox.m_Ignore:EnableWnd(true)
	g_GameMain.m_ReceiveBox.m_GoodFriend:EnableWnd(true)
	local flag = g_GameMain.m_AssociationBase:IsInBlackListById(g_GameMain.m_EmailBox.senderID)
	if(flag == 1)then--�Ǻ���
		g_GameMain.m_ReceiveBox.m_GoodFriend:EnableWnd(false)
	elseif(flag ==2)then--�ں�������
		g_GameMain.m_ReceiveBox.m_Ignore:EnableWnd(false)
	end
	--��ʾ��Ʒ����
	local mailGoodsCount = # g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl
	if mailGoodsCount > 0 then
		g_GameMain.m_ReceiveBox.m_HaveAttechment:SetWndText(GetStaticTextClient(1127))
	else
		g_GameMain.m_ReceiveBox.m_HaveAttechment:SetWndText(GetStaticTextClient(1126))
	end
	for i=1, mailGoodsCount do
		if(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][5] == mailid)then
			local Wnd,WndName
			if(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][1]==1)then
				Wnd = g_GameMain.m_ReceiveBox.m_Goods_01
				WndName = g_GameMain.m_ReceiveBox.m_GoodsName_01
				Wnd:EnableWnd(true)
			elseif(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][1]==2)then
				Wnd = g_GameMain.m_ReceiveBox.m_Goods_02
				WndName = g_GameMain.m_ReceiveBox.m_GoodsName_02
				Wnd:EnableWnd(true)
			elseif(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][1]==3)then
				Wnd = g_GameMain.m_ReceiveBox.m_Goods_03
				WndName = g_GameMain.m_ReceiveBox.m_GoodsName_03
				Wnd:EnableWnd(true)
			elseif(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][1]==4)then
				Wnd = g_GameMain.m_ReceiveBox.m_Goods_04
				WndName = g_GameMain.m_ReceiveBox.m_GoodsName_04
				Wnd:EnableWnd(true)
			end
			if(#(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i]) >0)then  --��i����������Ʒ
				local itemType = tonumber(g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][2])
				local itemName = g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][3]
				local SmallIcon = g_ItemInfoMgr:GetItemInfo(itemType,itemName,"SmallIcon")
				local DisplayName = g_ItemInfoMgr:GetItemLanInfo(itemType,itemName,"DisplayName")
				if(Wnd:GetWndText() == "")then
					g_LoadIconFromRes(SmallIcon, Wnd, -1, IP_ENABLE, IP_CLICKDOWN)
					local GlobalID = g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl[i][6]
					g_SetWndMultiToolTips(Wnd,itemType,itemName,GlobalID,0)
				end
				local count = 0
				for j=1, mailGoodsCount do
					local tbl = g_GameMain.m_ReceiveBox.m_EmailGetGoodsTbl 
					if tbl[i][1] == tbl[j][1] then
						count = count + 1
					end
				end
				Wnd:SetWndText(count)
				WndName:SetWndText(DisplayName)
			end
		end
	end
end




