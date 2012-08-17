gac_require "message/message_box/MsgBoxMsg"
gac_gas_require "event/Event"
cfg_load "item/HoleMaterial_Common"

CStone = class ( SQRDialog )
CMSG  = class ( SQRDialog )
CStoneAttrWnd = class( SQRDialog )

function CStone:Ctor( Parent )
	self:CreateFromRes( "StoneMain" , Parent )
	self.wholeAttr = {}		--�����������Ժ� 1<����>2<����>3<����>
	self.stonetbl = {}		--���汦ʯ,����Ӧ��frameID, partID , holeID
	self.holetbl   = {}		--�����׵Ŀ�λ��frameID, partID , holeID
	self.FrameID = 1		--Ŀǰѡ�е����  Ĭ��Ϊ 1
	self.PartID = nil		--Ŀǰѡ�еĲ�λ
	self:InitMSG()
	self:AllInitStonePart(self)
	self:InitAttrWnd(self)
	self.partwholeAttr ={}
	self.PartStoneType = {{18013,18014},{18013,18014},{18013,18014},{18013,18014},
						{18015,18016,18017},{18015,18016,18017},{18015,18016,18017},{18015,18016,18017},
						{18014,18016,18018},{18014,18016,18018},{18014,18016,18018},{18014,18016,18018}}

	g_ExcludeWndMgr:InitExcludeWnd(self, 2)
end

function CStone.GetWnd()
	local Wnd = g_GameMain.m_stone
	if not Wnd then
		Wnd = CStone:new(g_GameMain)
		g_GameMain.m_stone = Wnd
	end
	return Wnd
end

function CStone:OnChildCreated()
	self.m_XBtn		= self:GetDlgChild("XBtn")
	self.m_Panel1	= self:GetDlgChild("one")
	self.m_Panel2	= self:GetDlgChild("two")
	self.m_Panel3	= self:GetDlgChild("three")
	
	self.m_tblPart = {}
	for i = 1, 12 do
		self.m_tblPart[i] = self:GetDlgChild("Part" .. i)
		if i~=1 and i~=5 and i~= 9 then
			self.m_tblPart[i]:EnableWnd(false)
			self.m_tblPart[i]:ShowWnd(false)
		end
	end

	self.m_Check	= self:GetDlgChild("checkShow")
	self:GetDlgChild("shuoming"):SetTransparent( 0.5 )--�ؼ�͸��
	self:GetDlgChild("two"):EnableWnd(false)
	self:GetDlgChild("three"):EnableWnd(false)
end

function CStone:InitMSG()
	self.m_MSG = CMSG:new()
	self.m_MSG:CreateFromRes("WndMsg", g_GameMain)

end

function CStone:InitAttrWnd(parent)
	self.attrWnd = CStoneAttrWnd:new()
	self.attrWnd:CreateFromRes("StoneAttribute", parent)
	self.attrWnd.AttrText = self.attrWnd:GetDlgChild("AttrText")

end

function CStone:AllInitStonePart(Parent)
	self.stonepart = {}
	for i =1, 12 do
		self.stonepart[i] = CStonePart:new()
		self.stonepart[i]:CreateFromRes( "StonePart"..i, Parent )
		self.stonepart[i]:ShowWnd( true )
		self.stonepart[i]:InitPart()
		self.stonepart[i].m_Position = i
	end
	self.StonePartUsing = self.stonepart[1]		--��ǰ�򿪵�StonePart
end

function CStone:VirtualExcludeWndClosed()
	self.StonePartUsing:Close()
end

function CStone:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
		if(Child == self.m_XBtn) then
			self:ShowWnd(false)
		elseif(Child == self.m_Panel1) then
			--֪ͨServer�������, ���Ը���
			if self.FrameID ~= 1 then
				Gac2Gas:ChangeFrame(g_Conn,self.FrameID,1)
				self:DrawStoneFrame(1)
				self.StonePartUsing:Close()
			end
		elseif(Child == self.m_Panel2) then
			if self.FrameID ~= 2 then
				Gac2Gas:ChangeFrame(g_Conn, self.FrameID, 2)
				self:DrawStoneFrame(2)
				self.StonePartUsing:Close()
			end
		elseif(Child == self.m_Panel3) then
			if self.FrameID ~= 3 then
				Gac2Gas:ChangeFrame(g_Conn, self.FrameID, 3)
				self:DrawStoneFrame(3)
				self.StonePartUsing:Close()
			end
		elseif(Child == self.m_Check) then
			self.attrWnd:ShowWnd( not self.attrWnd:IsShow() )
		else
			for i = 1, 12 do
				if(Child == self.m_tblPart[i]) then
					DrawpartstoneFrame(i)
				end
			end
		end
	end
end

function CMSG:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
		if(Child == self:GetDlgChild("BtnOK")) then
			self:ShowWnd(false)
			local StoneWnd = CStone.GetWnd()
			StoneWnd.StonePartUsing.m_ZhaiChu:EnableWnd(false)
			Gac2Gas:RequestRemovalStone(g_Conn,StoneWnd.FrameID,StoneWnd.PartID,StoneWnd.StonePartUsing.NowSelectHoleID)
		elseif(Child == self:GetDlgChild("BtnCancel")) then
			self:ShowWnd(false)
			self:GetDlgChild("WndInfo"):SetWndText("")
		end
	end
end

function CStone:DrawStoneFrame(name) --��ʼ�����
	--���ݱ�ʯ���� ��ʾ����,����,���˼ӳ�
	--���ݽ�ɫ�ȼ� �����ڶ�,��������ʯ��� <δ��>
	--���ݵȼ��ж��Ƿ����ڶ������������ ����Ҫ����
	self.wholeAttr = {}
	--local color = {"#c000000#eff0000ff#P","#c00ff00","#cff0000"}
	local color = {"#c000000","#c00ff00","#cff0000"}
	self.FrameID = name
	for i =1, 12 do  --ʮ������λ, ������Ƕ��ͬ���͵ı�ʯ
		local AllHoleState = {1,1,1,1,1,1,1,1}  --1 δ����, 2 �ѿ���, 3 ����Ƕ
		for j =1, #(self.holetbl) do
			if(self.holetbl[j][1] == self.FrameID and self.holetbl[j][2] == i ) then
				--������Ѿ���,�ı�AllHoleState�ж�Ӧ�׵�״̬
				AllHoleState[self.holetbl[j][3]] = 2
			end
		end
		for j =1, #(self.stonetbl) do
			if(self.stonetbl[j][1] == self.FrameID and self.stonetbl[j][2] == i ) then
				--������Ѿ���Ƕ,�ı�AllHoleState�ж�Ӧ�׵�״̬
				AllHoleState[self.stonetbl[j][3]] = 3
			end
		end
		local szStoneType = ""
		for j =1, #(self.PartStoneType[i]) do
			if szStoneType == "" then
				szStoneType = szStoneType..GetStaticTextClient(self.PartStoneType[i][j])
			else
				szStoneType = szStoneType..","..GetStaticTextClient(self.PartStoneType[i][j])
			end
		end
		--��ͬ��λ ����Ƕ��ʯ���͵���ʾ��Ϣ
		self.m_tblPart[i]:SetMouseOverDescAfter("#cffffff"..GetPartDisplayName(i).."#r"..
		color[AllHoleState[1]]..GetStaticTextClient(18021)..color[AllHoleState[2]]..GetStaticTextClient(18021)
		..color[AllHoleState[3]]..GetStaticTextClient(18021)..color[AllHoleState[4]]..GetStaticTextClient(18021).."#r"
		..color[AllHoleState[5]]..GetStaticTextClient(18021)..color[AllHoleState[6]]..GetStaticTextClient(18021)
		..color[AllHoleState[7]]..GetStaticTextClient(18021)..color[AllHoleState[8]]..GetStaticTextClient(18021).."#r"..
		"#cffffff"..GetStaticTextClient(18020)..szStoneType)
	end
	for i =1, #(self.stonetbl) do  --�ڱ�ʯ�������ʾ��������ֵ
		local ItemInfo = g_ItemInfoMgr:GetItemFunInfo(self.stonetbl[i][4],self.stonetbl[i][5])
		local ItemLanInfo = g_ItemInfoMgr:GetItemLanFunInfo(self.stonetbl[i][4],self.stonetbl[i][5])
		if(self.stonetbl[i][1] == self.FrameID) then
			self:AccountAttr(ItemInfo,ItemLanInfo,self.stonetbl[i][2],self.stonetbl[i][3])
		end
	end
	self.attrWnd.AttrText:SetWndText("#r" .. GetStaticTextClient(1072))
	for i =1, #(self.wholeAttr) do
		self.attrWnd.AttrText:AddWndText("#r"..self.wholeAttr[i][3].."+"..self.wholeAttr[i][2])
	end
end
function CStone:AccountAttr(ItemInfo, ItemLanInfo, position, holepos)
	local flag = false
	for j =1, #(self.wholeAttr) do
		if(self.wholeAttr[j][1] == ItemInfo("AttrType")) then
			flag = true
			self.wholeAttr[j][2] = self.wholeAttr[j][2] + ItemInfo("AttrValue")
			for k = 1, 8 do
				local res = JudgeButtonActive( position, k )
				if  res ~= 3 then
					break
				elseif k == 4 and k == holepos then
					self.wholeAttr[j][2] = self.wholeAttr[j][2] + ItemInfo("Award4")
				elseif k == 8 and k == holepos then
					self.wholeAttr[j][2] = self.wholeAttr[j][2] + ItemInfo("Award8")
				end
			end
			break
		end
	end
	if(not flag) then
		table.insert(self.wholeAttr,{ItemInfo("AttrType"),ItemInfo("AttrValue"),ItemLanInfo("ShowAttrType")})
		for k = 1, 8 do
			local res = JudgeButtonActive( position, k )
			if  res ~= 3 then
				break
			elseif k == 4 or k ==8 then
				if k == holepos then
					self.wholeAttr[#(self.wholeAttr)][2] = self.wholeAttr[#(self.wholeAttr)][2] + ItemInfo("Award4")
				end
			end
		end
	end
end

function JudgeButtonActive( partID, holename )  --�жϿ׵�״̬
  	--  1 <���Դ��>   2 <�Ѿ����>,<������Ƕ>
  	--  3 <�Ѿ���Ƕ> 4 <ǰ��Ļ�û�д��> 5 <ǰ��Ļ�û����Ƕ>
	local res = 1
	local StoneWnd = CStone.GetWnd()
	for i=1,#(StoneWnd.holetbl) do
		if( StoneWnd.holetbl[i][1] ==StoneWnd.FrameID and StoneWnd.holetbl[i][2] ==partID ) then --��� �� ��λ
			if( StoneWnd.holetbl[i][3] ==holename ) then
				--���ѿ���,�����ٷ��ô�ײ���
				res = 2
			end
		end
	end
	for i=1,#(StoneWnd.stonetbl) do
		if( StoneWnd.stonetbl[i][1] ==StoneWnd.FrameID and StoneWnd.stonetbl[i][2] == partID and StoneWnd.stonetbl[i][3] == holename ) then
			--����Ƕ,�����ٷ��ñ�ʯ   
			res = 3
		end
	end
	if(res ==1) then --�ж�ǰ����Ƿ�ȫ�����
		for i =1,tonumber(holename)-1 do
			local Flag = false
			if( tonumber(holename) > 1) then
				res = 4
				for j=1, #(StoneWnd.stonetbl) do
					if( StoneWnd.stonetbl[j][1] ==StoneWnd.FrameID and StoneWnd.stonetbl[j][2] ==partID and StoneWnd.stonetbl[j][3] ==i) then --��� �� ��λ
						res = 1
						Flag = true
						break
					elseif(j == #(StoneWnd.stonetbl)) then
						res = 4
					end
				end
			elseif( tonumber(holename) == 1) then
				break
			end
			if(not Flag) then
				res = 4
				for j = 1, #(StoneWnd.holetbl) do
					if( StoneWnd.holetbl[j][1] ==StoneWnd.FrameID and StoneWnd.holetbl[j][2] ==partID and StoneWnd.holetbl[j][3] ==i) then --��� �� ��λ
						res = 1
						break
					elseif(j == #(StoneWnd.holetbl)) then
						res = 4
						return res
					end
				end
			end
		end
	end
	if( res ==2 ) then
		--�жϰ�˳��ǰ��Ŀ��Ƿ��Ѿ���Ƕ
		for i=1, tonumber(holename)-1 do
			if( 0== #(StoneWnd.stonetbl) and tonumber(holename) > 1) then
				res = 5
			end
			if( tonumber(holename) == 1 )then
				break
			end
			for j=1, #(StoneWnd.stonetbl) do
				if( StoneWnd.stonetbl[j][1] ==StoneWnd.FrameID and StoneWnd.stonetbl[j][2] ==partID and StoneWnd.stonetbl[j][3] == i ) then
					res = 2
					break
				elseif(j == #(StoneWnd.stonetbl)) then
					res = 5
					return res
				end
			end
		end
	end
	return res
end

--RCP ʵ�ֹ���--
function CStone:SendAllHoleInfoEnd()
	if(self.PartID ~= nil) then
		DrawpartstoneFrame(self.PartID)
	end
	if(self.FrameID == 1) then
		self:DrawStoneFrame(1)
	elseif(self.FrameID == 2) then
		self:DrawStoneFrame(2)
	elseif(self.FrameID == 3) then
		self:DrawStoneFrame(3)
	else
		self:DrawStoneFrame(1)
	end
	SetEvent( Event.Test.SendAllHoleInfoEnd,true,flag)
end
function CStone:ReturnOpenHole(flag)
	g_DelWndImage(self.StonePartUsing.m_tblPart[self.StonePartUsing.NowSelectHoleID], 1, IP_ENABLE, IP_CLICKDOWN)
	self.StonePartUsing.m_tblPart[self.StonePartUsing.NowSelectHoleID]:SetMouseOverDescAfter("")
	self.StonePartUsing.MaterialID ={}
	if(flag ==true) then
		SetEvent( Event.Test.OpenHole,true,flag)
	else
		SetEvent( Event.Test.OpenHole,false,flag)
	end
end
function CStone:ReturnInlayStone(flag)
	if not flag then
		g_DelWndImage(self.StonePartUsing.m_tblPart[self.StonePartUsing.NowSelectHoleID], 1, IP_ENABLE, IP_CLICKDOWN)
		self.StonePartUsing.m_tblPart[self.StonePartUsing.NowSelectHoleID]:SetMouseOverDescAfter("")
	end
	self.StonePartUsing.MaterialID ={}
	SetEvent( Event.Test.InlayStone,true,flag)
end
function CStone:ReturnRemovalStone(flag)
	if(flag ==true) then
		
	end
	SetEvent( Event.Test.RemovalStone,true,flag)
end
function CStone:NotifyAddAttr(frameid, position, holePos)
	if(self.PartID ~= position) then
		return
	end
	local BigId = 0
	local Index = 0
	for i =1, #(self.stonetbl) do
		if(self.stonetbl[i][1]==frameid and self.stonetbl[i][2] ==position and self.stonetbl[i][3] ==holePos) then
			BigId = self.stonetbl[i][4]
			Index = self.stonetbl[i][5]
		end
	end
	if(BigId == 0 or Index == 0) then
		return
	end
	self.StonePartUsing:NotifyShowAddAttr(BigId,Index)
end

function CStone:OnPlayerLevelUp()
	if g_MainPlayer:CppGetLevel() >= 60 then
		self.m_tblPart[2]:EnableWnd(true)
		self.m_tblPart[6]:EnableWnd(true)
		self.m_tblPart[10]:EnableWnd(true)
		self.m_tblPart[2]:ShowWnd(true)
		self.m_tblPart[6]:ShowWnd(true)
		self.m_tblPart[10]:ShowWnd(true)
	else
		self.m_tblPart[2]:EnableWnd(false)
		self.m_tblPart[6]:EnableWnd(false)
		self.m_tblPart[10]:EnableWnd(false)
		self.m_tblPart[2]:ShowWnd(false)
		self.m_tblPart[6]:ShowWnd(false)
		self.m_tblPart[10]:ShowWnd(false)
	end
end

function CStone:OpenPanel(bShow)
	self:OnPlayerLevelUp()
	self:ShowWnd(bShow)
end

function CStone:NotifyOpenPanel(num)
	if(num == 2) then
		self:GetDlgChild("two"):EnableWnd(true)
	elseif(num == 3) then
		self:GetDlgChild("three"):EnableWnd(true)
	end
end

function CStone:OnReturnGetOpenedHole(Conn,frameID, position, holeID)--�Ѵ�׵�
	table.insert(self.holetbl, {frameID, position, holeID})
end
function CStone:OnReturnGetInlayedHole(Conn,frameID, position, holePos ,stoneBigID, stonename)--����Ƕ�Ŀ�
	table.insert(self.stonetbl, {frameID, position, holePos, stoneBigID, stonename})
end
function CStone:OnReturnOpenHole(Conn,flag)--��׵ķ���
	self.StonePartUsing:VirtualExcludeWndClosed()
	self:ReturnOpenHole(flag)
end
function CStone:OnReturnInlayStone(Conn,flag)--��Ƕ�ķ���
	self.StonePartUsing:VirtualExcludeWndClosed()
	self:ReturnInlayStone(flag)
end
function CStone:OnReturnRemovalStone(Conn,flag)--��ʯժ������
	self:ReturnRemovalStone(flag)
end
--���,��Ƕ,ժ��End ,��Ҫ���� ��HoleTbl,StoneTbl
function CStone:OnUpdateAllHoleInfoBegin(Conn)  --�����첽����
	self.holetbl = {}
	self.stonetbl = {}
	for i =1, 8 do
		g_DelWndImage(self.StonePartUsing.m_tblPart[i], 1, IP_ENABLE, IP_CLICKDOWN)
		self.StonePartUsing.m_tblPart[i]:SetMouseOverDescAfter("")
	end
end
function CStone:OnSendAllHoleInfoEnd(Conn)--��ʼ������
	self:SendAllHoleInfoEnd()
end
function CStone:OnNotifyAddAttr(Conn, frameid, position, holePos)--��Ƕ��4, 8 ��ʱ ��4, ��8���׵ı�ʯ��ø������� ����m%,n%
	self:NotifyAddAttr(frameid, position, holePos)
end
function CStone:OnNotifyOpenPanel(Conn,num)-- �ȼ��������� �����������
	self:NotifyOpenPanel(num)
end
function CStone:OnUsePanel(Conn,PanelID)-- ֪ͨ����ʹ���ĸ����
	self.FrameID = PanelID
end