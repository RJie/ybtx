gac_require "relation/cofc/CofCMainInc"
gac_require "relation/cofc/Members"
gac_require "relation/cofc/Technology"
gac_require "relation/cofc/Log"

--�����̻���������Ϣ
--�������Լ���ְλ���̻����ƣ��ȼ����ʽ���ҵָ���������̻�������������������ֵ����Դ�����ӳɣ������̻�ӯ���������̻�ӯ����������ռӳɣ�Ŀǰ���������Ƽ����ƣ� ���пƼ��ȼ����ܿƼ��ȼ����̻���ּ
function Gas2Gac:RetGetCofcInfo(Conn,selfOccupation, name, level, money, exp, onlinePersonCount, totalPersonCount, populirity, res, lastProfit, thisProfit, recovery, curTechName, techLevel, techTotalLevel, propose)
	if g_GameMain.m_CofCMainWnd == nil then
		g_GameMain.m_CofCMainWnd = CreateChamberOfCommerce(g_GameMain)
	end
	g_GameMain.m_CofCMainWnd.m_CurQuestInfoTbl = {}
	g_GameMain.m_CofCMainWnd.m_selfOccu = selfOccupation	--�Լ����̻��е�ְλ
	
	g_GameMain.m_CofCMainWnd.m_tblCofCInfo = {name, level, money, exp, onlinePersonCount, totalPersonCount, populirity, res, lastProfit, thisProfit, recovery, curTechName, techLevel, techTotalLevel, propose}
	g_GameMain.m_CofCMainWnd:OpenCofcMainWnd(name, level, money, exp, onlinePersonCount, totalPersonCount, populirity, res, lastProfit, thisProfit, recovery, curTechName, techLevel, techTotalLevel, propose)
	
	local assoListWnd = g_GameMain.m_AssociationWnd.m_AssociationListWnd
	if(assoListWnd) then
		assoListWnd:RetSetCofCList()
	end
end

function Gas2Gac:RetGetCofcQuestInfo(Conn, questName)
	table.insert(g_GameMain.m_CofCMainWnd.m_CurQuestInfoTbl,questName)
end

function Gas2Gac:RetGetCofcQuestInfoEnd(Conn)
	g_GameMain.m_CofCMainWnd:ShowCurQuestInfo()
end


--�޸��̻���ּ���غ���
function Gas2Gac:RetModifyCofcPropose( Conn )	
	local cofcMainWnd = g_GameMain.m_CofCMainWnd
	local newProposeText = cofcMainWnd.m_CofCModifyCPurposeWnd.m_ProposeText:GetWndText()	
	cofcMainWnd.m_CofCPurposeDesc:SetWndText(newProposeText)
end

---------------------------------------------------------------------------------

--�����̻�������
function CreateChamberOfCommerce(Parent)
	local wnd = CChamberOfCommerceWnd:new()
	wnd:CreateFromRes("CofCMain",Parent)
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 1)
	wnd:ShowWnd(false)
	wnd:InitMainWndChild()
	return wnd
end

--�ó�Ա��������¼�̻�����������е�child�ؼ�
function CChamberOfCommerceWnd:InitMainWndChild()
	self.m_CofCName					=	self:GetDlgChild("Name")   								--�̻�����
	self.m_CofCLevel 				= 	self:GetDlgChild("Level")								--�̻�ȼ�
	self.m_CofCMoney				=	self:GetDlgChild("Money") 								--�̻��ʽ�
	self.m_CofCMemberNo				= 	self:GetDlgChild("Exploit") 							--�̻�����
	self.m_CofCCommerce 			= 	self:GetDlgChild("Popularity ") 						--�̻�ָ��
	self.m_CofCPopulirity			=	self:GetDlgChild("Stable") 								--����ֵ
	self.m_CofCSourceCount 			= 	self:GetDlgChild("SourceCountText") 					--��Դ�����ӳ�
	self.m_CofCLastWeekProfit		= 	self:GetDlgChild("LastWeekProfitText") 					--�����̻�ӯ��
	self.m_CofCCurWeekProfit		= 	self:GetDlgChild("CurWeekProfitText") 					--�����̻�ӯ��
	self.m_CofCDebrisRecovery		= 	self:GetDlgChild("DebrisRecoveryText") 					--������ռӳ�
	self.m_CofCFinancialLogBtn 		=	self:GetDlgChild("CheckFinancialLog") 					--�鿴��ʷ�Ʊ�
	self.m_CofCCurTechnology		= 	self:GetDlgChild("CurUpdateTechText") 					--Ŀǰ���������Ƽ�
	self.m_CofCModifyPurposeBtn		=	self:GetDlgChild("ChangePurposeBtn")					--�޸���ּ��ť
	self.m_CofCPurposeDesc			=	self:GetDlgChild("PurposeText")							--��ʾ��ּ����
	self.m_CofCCloseBtn				= 	self:GetDlgChild("Close")								--�رմ��ڰ�ť
	self.m_CofCMemberBtn			= 	self:GetDlgChild("CofCMemberBtn")						--�̻��Ա��ť
	self.m_CofCTechBtn				=	self:GetDlgChild("CofCTech")							--�̻�Ƽ���ť
	self.m_CofCLogBtn				=	self:GetDlgChild("CofCLogBtn")							--�̻���־��ť
	self.m_CofCCloseWndBtn			= 	self:GetDlgChild("ShutDownBtn")							--�̻�رհ�ť
	self.m_ChallengeLable			=	self:GetDlgChild("ChallengeLable")						--Ŀǰ��������**�Ƽ�
	self.m_OpenCofCStock			=	self:GetDlgChild("RequestOpenStock")
	self.m_CofCModifyPurposeBtn:EnableWnd(false)												--��ʼ�����޸��̻���ּ��尴ťΪ���ɵ�״̬
end

--�̻�����¼���Ӧ����
function CChamberOfCommerceWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CofCCloseWndBtn or Child == self.m_CofCCloseBtn) then 			--�رհ�ť
	  		self:ShowWnd(false)
	  	elseif(Child == self.m_CofCMemberBtn)    then 							--���̻��Ա��尴ť
	  		self:OpenCofCMemberWnd()
	  	elseif(Child == self.m_CofCTechBtn)      then								--���̻�Ƽ���尴ť										
	  		self:OpenCofCTechWnd()
	  	elseif(Child == self.m_CofCLogBtn)       then								--���̻���־��尴ť	
	  		self:OpenCofCLogWnd()
	  	elseif(Child == self.m_CofCFinancialLogBtn) then							--�鿴��ʷ�Ʊ�
	  		self:CheckFinancialLog()	
	  	elseif(Child == self.m_CofCModifyPurposeBtn) then	 						--�޸��̻���ּ
	  		self:ModifyCofCPurpose()
	  	elseif(Child == self.m_OpenCofCStock) then
	  		Gac2Gas:RequestOpenCofCStock(g_Conn)
		end
	end
end

--���̻�������
function CChamberOfCommerceWnd:OpenCofcMainWnd(name, level, money, exp, onlinePersonCount, totalPersonCount, populirity, res, lastProfit, thisProfit, recovery, curTechName, techLevel, techTotalLevel, propose)
	self.m_CofCName:SetWndText( name )
	self.m_CofCLevel:SetWndText( level )
	self.m_CofCMoney:SetWndText( money )
	self.m_CofCMemberNo:SetWndText( onlinePersonCount .. "/" .. totalPersonCount )
	self.m_CofCCommerce:SetWndText( exp .. "%")
	self.m_CofCPopulirity:SetWndText( populirity )
	self.m_CofCSourceCount:SetWndText( res )
	self.m_CofCLastWeekProfit:SetWndText( lastProfit )
	self.m_CofCCurWeekProfit:SetWndText( thisProfit )
	self.m_CofCDebrisRecovery:SetWndText( recovery .. "%" )
	self.m_CofCCurTechnology:SetWndText( techLevel .. "/" .. techTotalLevel )
	self.m_CofCPurposeDesc:SetWndText( propose )
	self.m_ChallengeLable:SetWndText(GetStaticTextClient(1085, curTechName))
	if self.m_selfOccu	==  "�᳤" or self.m_selfOccu == "���᳤" then
		self.m_CofCModifyPurposeBtn:EnableWnd(true)
	end
end

--��ʾ�̻��������е�������Ϣ
function CChamberOfCommerceWnd:ShowCurQuestInfo()
	local questTbl = g_GameMain.m_CofCMainWnd.m_CurQuestInfoTbl
	for i =1, table.getn(questTbl) do
		local questNameWnd = Quest ..i
		local questWnd = self:GetDlgChild(questNameWnd)
		local questName = questTbl[i]
		questWnd:SetWndText(questName)
	end
end

--���̻��Ա����
function CChamberOfCommerceWnd:OpenCofCMemberWnd()
	if g_GameMain.m_CofCMemberWnd == nil then
		g_GameMain.m_CofCMemberWnd = CreateCofCMemberWnd(g_GameMain)
		g_GameMain.m_CofCMemberWnd:ShowWnd(true)
		Gac2Gas:GetCofCMembersInfo(g_Conn)
		return
	elseif g_GameMain.m_CofCMemberWnd:IsShow() == false then
		g_GameMain.m_CofCMemberWnd:ShowWnd(true)
		Gac2Gas:GetCofCMembersInfo(g_Conn)
	end
end

--���̻�Ƽ�����
function CChamberOfCommerceWnd:OpenCofCTechWnd()
	if g_GameMain.m_CofCTechWnd == nil then
		g_GameMain.m_CofCTechWnd = CreateCofCTechWnd(g_GameMain)
	end
	g_GameMain.m_CofCTechWnd:ShowWnd(true)
	g_GameMain.m_CofCTechWnd:ClearTabel()
	Gac2Gas:GetCofcTechnologyInfo(g_Conn)
end

--���̻���־����
function CChamberOfCommerceWnd:OpenCofCLogWnd()
	if g_GameMain.m_CofCLogWnd == nil then
		g_GameMain.m_CofCLogWnd = CreateCofCLogWnd(g_GameMain)
		g_GameMain.m_CofCLogWnd:ShowWnd(true)
		local logType = 4 		--�������͵�log
		Gac2Gas:GetCofCLogInfo(g_Conn, 4)
		return
	elseif g_GameMain.m_CofCLogWnd:IsShow() == false then
		g_GameMain.m_CofCLogWnd:ShowWnd(true)
		g_GameMain.m_CofCLogWnd:ShowWnd(true)
		Gac2Gas:GetCofCLogInfo(g_Conn, 4)
	end
end

function CChamberOfCommerceWnd:CheckFinancialLog()
	local financialCurWeek = 0
	Gac2Gas:GetCofCFinancialReport(g_Conn,g_MainPlayer.m_Properties:GetCofcID(), financialCurWeek)
end


function CChamberOfCommerceWnd:ModifyCofCPurpose()
	if self.m_CofCModifyPurposeWnd == nil then
		self.m_CofCModifyCPurposeWnd = CreateModifyCofCPurposeWnd(self)
		self.m_CofCModifyCPurposeWnd:ShowWnd(true)
		return
	elseif self.m_CofCModifyPurposeWnd:IsShow() == false then
		self.m_CofCModifyCPurposeWnd:ShowWnd(true)
		self.m_CofCModifyPurposeWnd.m_ProposeText:SetWndText("")
	end
end

--�޸��̻���ּ����--------------------------------------------------------------------------------
function CreateModifyCofCPurposeWnd(Parent)
	local wnd = CModifyCofCPurposeWnd:new()
	wnd:CreateFromRes("CofCModifyPropose",Parent)
	wnd:ShowWnd( true )
	wnd.m_OkBtn 			= wnd:GetDlgChild("ok")		
	wnd.m_CloseBtn 			= wnd:GetDlgChild("close")
	wnd.m_ProposeText		= wnd:GetDlgChild("nameTest")			--�̻���ּ����
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCMainWnd})
	return wnd
end

function CModifyCofCPurposeWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  if(Child == self.m_CloseBtn) then 		--�رհ�ť
	  	self:ShowWnd(false)
	  elseif(Child == self.m_OkBtn) then																				
	  	self:SetNewProposeText()
	  end
	end
end

--�����µ��̻���ּ
function CModifyCofCPurposeWnd:SetNewProposeText()
	local proposeText = self.m_ProposeText:GetWndText()		
	local proposeLen = string.len(proposeText)
	if proposeLen > math.pow(2,8) then 				--�޶��̻���ּ����
		self.m_MsgBox = MessageBox(self, MsgBoxMsg(16001), MB_BtnOK)
	else
		self:ShowWnd(false)
		Gac2Gas:ModifyCofcPropose( g_Conn, proposeText )	
	end																
end
