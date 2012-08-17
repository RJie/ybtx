--�����ܿ����
gac_require "toolbar/short_cut/ShortCut"
gac_require "toolbar/main_skills_toolbar/MainSkillsToolBarInc"
gac_require "toolbar/short_cut/GacShortcut"
gac_require "toolbar/main_skills_toolbar/FunctionBar"

function OpenStonePanel()
	local StoneWnd = CStone.GetWnd()
	StoneWnd:OpenPanel(not StoneWnd:IsShow())
end

function OpenStatisticFightInfoWnd()
	local Wnd = CStatisticFightInfoWnd.GetWnd()
	Wnd:OnOpen(not Wnd:IsShow())
end

--�򿪷�ս���������
function OpenNonFightSkillWnd()
	--local wnd = g_GameMain.m_NonFightSkillWnd
	--wnd:ShowWnd(not wnd:IsShow())
end

--@brief ��ס��,�����ֱ��/�ر���չ��������
--@param index:���ݴ������Ĳ����ֱ��Ӧѡ����չ��������-����
function OpenMasterSkillArea(index)
	if index then
		local Wnd = g_GameMain.m_MasterSkillArea
		local Piece = Wnd.m_WndSkill.m_tblShortcutPiece[index]
		Piece.m_SkillBtn:DelFlashAttention()
		Piece.m_SkillBtn:AddFlashInfoByName("skillclickdown1")	
		Piece:UseShortcut()		
	else
		g_GameMain.m_MasterSkillArea:ShowWnd(not g_GameMain.m_MasterSkillArea:IsShow())
		CMainSkillsToolBar:SetMasterSkillAreaState()
	end
end

--@brief ��ס��.�����ֱ��/������չ��������
--@param index:���ݴ������Ĳ����ֱ��Ӧѡ����չ��������-����
function OpenAddMasterSkillArea(index)
	if index then
		local Wnd = g_GameMain.m_AddMasterSkillArea
		local Piece = Wnd.m_WndSkill.m_tblShortcutPiece[index]
		Piece.m_SkillBtn:DelFlashAttention()
		Piece.m_SkillBtn:AddFlashInfoByName("skillclickdown1")
		Piece:UseShortcut()		
	else
		g_GameMain.m_AddMasterSkillArea:ShowWnd(not g_GameMain.m_AddMasterSkillArea:IsShow())
		CMainSkillsToolBar:SetMasterSkillAreaState()
	end
end

--����J������������
function OpenLiveSkillMainWnd()
	g_GameMain.m_LiveSkillMainWnd:BeOpenPanel()
end
------------------------------����Ϊϵͳ��幦�ܺ���---------------
local MainSkillWnd = 1
local MasterSkillWnd = 2
local AddMasterSkillWnd = 3
local PieceNumber = 10
local OldSkillWndMaxNum = 20
local function DrawPieceWnd (i,SkillName ,tblShortcutPiece,WndSkill,fs)
	local Type = tblShortcutPiece[i]:GetState()
	if Type == EShortcutPieceState.eSPS_Skill then
		WndSkill:DrawSkill(tblShortcutPiece[i], fs)	
	elseif Type == EShortcutPieceState.eSPS_Array then
		WndSkill:DrawArraySkill(tblShortcutPiece[i], fs)
	end
end

--�ż��ܿ��ͼ��
function CMainSkillsToolBar:DrawSkillWnd(wnd, pos, type, arg1, arg2)
	local tblShortcutPiece = wnd:GetTblShortcutPiece()
	for i = 1, table.maxn(tblShortcutPiece) do
		if (tblShortcutPiece[i]:GetPos() == pos) then
			tblShortcutPiece[i]:SetState(type)
			tblShortcutPiece[i]:SetName(arg1)
			local tbl = {}
			tbl.SkillName = arg1
			tbl.Level = arg2
			tbl.AutoSkill = nil
			tblShortcutPiece[i]:SetSkillContext(tbl)
			DrawPieceWnd(i, arg1, tblShortcutPiece, wnd, tbl)
		end
	end
end

--���󷨿��ͼ��
function CMainSkillsToolBar:DrawArrayWnd(wnd, pos, type, arg1, arg2)
	local tblShortcutPiece = wnd:GetTblShortcutPiece()
	for i = 1, table.maxn(tblShortcutPiece) do
		if (tblShortcutPiece[i]:GetPos() == pos) then
			tblShortcutPiece[i]:SetState(type)
			tblShortcutPiece[i]:SetName(arg1)
			local tbl = {}
			tbl.SkillName = arg1
			tbl.Level = arg2
			tblShortcutPiece[i]:SetSkillArrayContext(tbl)
			DrawPieceWnd(i, arg1, tblShortcutPiece, wnd, tbl)
		end
	end
end

--����Ʒ�����ͼ��
function CMainSkillsToolBar:DrawItemWnd(wnd,pos,type,arg1,arg2)
	local tblShortcutPiece = wnd:GetTblShortcutPiece()
	for i = 1, table.maxn(tblShortcutPiece) do
		if (tblShortcutPiece[i]:GetPos() == pos) then
			local uBigID = arg2
			local uIndex = arg1
			local uGlobalID = 0
			local num = g_GameMain.m_BagSpaceMgr:GetItemCountBySpace(g_StoreRoomIndex.PlayerBag,uBigID, uIndex)
			tblShortcutPiece[i]:SetItemContext(uBigID, uIndex, uGlobalID, num)
			tblShortcutPiece[i]:SetState(type)
			wnd:DrawItem(tblShortcutPiece[i])
		end
	end	
end

--���÷���˴��ص���Ӧ����  --pos λ�ã�type ���ͣ�Arg1 �������ƣ�Arg2 ���ܵȼ���Arg3 ��������ǩ
function CMainSkillsToolBar:ReturnSkill( Pos, type, Arg1, Arg2, Arg3 )
	local wnd = nil
	if(MainSkillWnd == Arg3) then
		wnd = g_GameMain.m_MainSkillsToolBar.m_WndSkill
	elseif(MasterSkillWnd == Arg3) then
		wnd = g_GameMain.m_MasterSkillArea.m_WndSkill
	elseif(AddMasterSkillWnd == Arg3) then
		wnd = g_GameMain.m_AddMasterSkillArea.m_WndSkill
	end
	g_GameMain.m_MainSkillsToolBar.m_PieceTbl[Arg3][Pos] = {type, Arg1, Arg2}
	if( type == EShortcutPieceState.eSPS_Skill ) then		--��ʾ�ŵ��Ǽ���
		self:DrawSkillWnd(wnd, Pos, type, Arg1, Arg2)
		g_MainPlayer:AddFXCache(Arg1)
		if(string.find(Arg1, "��ͨ����") == nil) then
			local eCoolDownType = g_MainPlayer:GetSkillCoolDownType(Arg1)
			if eCoolDownType == ESkillCoolDownType.eSCDT_FightSkill or
				 eCoolDownType == ESkillCoolDownType.eSCDT_NoComCDFightSkill or
				 eCoolDownType == ESkillCoolDownType.eSCDT_UnrestrainedFightSkill or
				 eCoolDownType == ESkillCoolDownType.eSCDT_NonFightSkill then
				g_MainPlayer:AddLearnSkill(Arg1,Arg2)
			end
		end
	elseif( type == EShortcutPieceState.eSPS_Item ) then	--��ʾ�ŵ�����Ʒ
		self:DrawItemWnd(wnd,Pos,type,Arg1,Arg2)
	elseif( type == EShortcutPieceState.eSPS_Array ) then	--��ʾ�ŵ����󷨼���
		self:DrawArrayWnd(wnd, Pos, type, Arg1, Arg2)
	end
end

function CMainSkillsToolBar:GetAddSkillWndSkillNameWnd( name,coolDownType, skillWndObj)
	local m_tblShortcutPiece = skillWndObj.m_WndSkill:GetTblShortcutPiece()	
	for i = 1,PieceNumber do
		if m_tblShortcutPiece[i]:GetName() == name 
		or ( m_tblShortcutPiece[i]:GetCoolType() == coolDownType 
		and coolDownType == ESkillCoolDownType.eSCDT_DrugItemSkill)  then
			return true, m_tblShortcutPiece[i], i
		end
	end	
end

--���÷ǹ�����ȴʱ��
function CMainSkillsToolBar:SetCDWnd(Wnd, time, runedTime)
	Wnd.m_SkillStateClientBtn:ShowWnd(false)
	local SkillCdBtn = Wnd.m_SkillCDBtn
	Wnd:RegisterSelfTick(time,runedTime)
end

--���ù�����ȴʱ��
function CMainSkillsToolBar:SetCommCDWnd(Wnd,IsFightSkill)
	--Wnd:UnRegisterSelfTick()
	Wnd.m_SkillStateClientBtn:ShowWnd(false)
	Wnd:UnRegisterSelfCommTick()
	local SkillCdBtn = Wnd.m_SkillCDBtn
	if not SkillCdBtn:IsShow() then 
		SkillCdBtn:setTimeEx(1000,GetRenderTime(g_MainPlayer))
		SkillCdBtn:setRunedTime(0)
		Wnd.m_ShortCutCommTick = RegisterDistortedTickByCoreObj(g_MainPlayer,"ShortCutCommTick",Wnd.OnCommTick,80,Wnd)
	end
end

--���ø��������
function CMainSkillsToolBar:SetAddSkillWndCoolTimer(skillWndObj,LeftTime,skillName,uCoolTime,eCoolDownType)
	local m_tblShortcutPiece = skillWndObj.m_WndSkill:GetTblShortcutPiece()
	for i = 1, PieceNumber do
		local thisWnd = m_tblShortcutPiece[i]
		if m_tblShortcutPiece[i]:GetState() ~= EShortcutPieceState.eSPS_None and eCoolDownType == m_tblShortcutPiece[i]:GetCoolType() and  skillName == m_tblShortcutPiece[i]:GetName() then
			if m_tblShortcutPiece[i]:GetState() == EShortcutPieceState.eSPS_Skill then
				self:SetCDWnd(thisWnd, m_tblShortcutPiece[i]:GetCoolTime(), m_tblShortcutPiece[i]:GetCoolTime() - LeftTime)
			elseif m_tblShortcutPiece[i]:GetState() == EShortcutPieceState.eSPS_Item then
				self:SetCDWnd(thisWnd, LeftTime, 0)
			end
		elseif( m_tblShortcutPiece[i]:GetState() ~= EShortcutPieceState.eSPS_None and
		 eCoolDownType == m_tblShortcutPiece[i]:GetCoolType() and
		  (eCoolDownType == ESkillCoolDownType.eSCDT_FightSkill or
		  eCoolDownType == ESkillCoolDownType.eSCDT_UnrestrainedFightSkill)) then
			self:SetCommCDWnd(thisWnd,true)
		elseif m_tblShortcutPiece[i]:GetState() == EShortcutPieceState.eSPS_Item  --��Ʒ��ȴ������ͬ����ȴʱ��
			and m_tblShortcutPiece[i]:GetCoolType() == eCoolDownType
			and m_tblShortcutPiece[i]:GetCoolType() == ESkillCoolDownType.eSCDT_DrugItemSkill then				
				self:SetCDWnd(thisWnd, LeftTime, 0)
		elseif m_tblShortcutPiece[i]:GetState() == EShortcutPieceState.eSPS_Item --��Ʒ�������ܹ�����ȴʱ��
			and ( m_tblShortcutPiece[i]:GetCoolType() == ESkillCoolDownType.eSCDT_DrugItemSkill 
			or m_tblShortcutPiece[i]:GetCoolType() == ESkillCoolDownType.eSCDT_OtherItemSkill
			or m_tblShortcutPiece[i]:GetCoolType() == ESkillCoolDownType.eSCDT_SpecialItemSkill)	then
				self:SetCommCDWnd(thisWnd)
			end
	end
end

local function GetCoolTimeInfo(skillName)
	local uLevel = 1
	local uCoolTime = g_MainPlayer:GetCoolDownTime( skillName, uLevel ) * 1000
	if g_MainPlayer:IsSwitchEquipSkill(skillName) then
		uCoolTime = 5*60*1000
	end
	return uCoolTime
end
				
--����CDʱ��  o(��_��)o...
function CMainSkillsToolBar:setCoolTimerBtn(name, eCoolDownType, LeftTime)
	local uCoolTime = GetCoolTimeInfo(name)
	
	self:SetAddSkillWndCoolTimer( self,LeftTime,name,uCoolTime,eCoolDownType)
	self:SetAddSkillWndCoolTimer( g_GameMain.m_MasterSkillArea,LeftTime,name,uCoolTime,eCoolDownType)
	self:SetAddSkillWndCoolTimer( g_GameMain.m_AddMasterSkillArea,LeftTime,name,uCoolTime,eCoolDownType)
	
	if g_GameMain.m_ServantSkill ~= nil and g_GameMain.m_ServantSkill:IsShow() then
		local PieceTbl = g_GameMain.m_ServantSkill.m_ServantSkillList:GetTblShortcutPiece()
		for i = 1 ,#(PieceTbl) do 
			if PieceTbl[i]:GetState() ~= EShortcutPieceState.eSPS_None and eCoolDownType == PieceTbl[i]:GetCoolType() and  name == PieceTbl[i]:GetName() then
				if PieceTbl[i]:GetState() == EShortcutPieceState.eSPS_Skill then
					self:SetCDWnd(PieceTbl[i], PieceTbl[i]:GetCoolTime(), PieceTbl[i]:GetCoolTime() - LeftTime)
				end
			elseif( PieceTbl[i]:GetState() ~= EShortcutPieceState.eSPS_None and 
				eCoolDownType == PieceTbl[i]:GetCoolType() and (eCoolDownType == ESkillCoolDownType.eSCDT_FightSkill or
				eCoolDownType == ESkillCoolDownType.eSCDT_UnrestrainedFightSkill)) then
				self:SetCommCDWnd(PieceTbl[i],true)		
			end
		end
	end
end

--���³��������������Ŀ����
function CMainSkillsToolBar:SetAddSkillWndShortCutItemNum(skillWndObj, Index)
	local m_tblShortcutPiece = skillWndObj.m_WndSkill:GetTblShortcutPiece()
	--���¸���������ϵĸ������ݺ͸�������Ʒ����
	for i = 1, PieceNumber do
		local ItemNum
		local thisWnd = m_tblShortcutPiece[i]
		if m_tblShortcutPiece[i]:GetState() == EShortcutPieceState.eSPS_Item and Index == m_tblShortcutPiece[i]:GetIndex() then
			if ItemNum == nil then
				local uBigID, uIndex = m_tblShortcutPiece[i]:GetItemContext()				 
				local num = g_GameMain.m_BagSpaceMgr:GetItemCountBySpace(g_StoreRoomIndex.PlayerBag,uBigID, uIndex)
				ItemNum = num
				local SmallIcon = g_ItemInfoMgr:GetItemInfo(uBigID,uIndex,"SmallIcon")
				if ItemNum > 0 then
					g_LoadIconFromRes( SmallIcon, thisWnd.m_SkillBtn, -2, IP_ENABLE, IP_CLICKDOWN)
				else
						g_LoadGrayIconFromRes(SmallIcon, thisWnd.m_SkillBtn, -2, IP_ENABLE, IP_CLICKDOWN)				
				end
			end
			thisWnd.m_SkillBtnNum:SetWndText(ItemNum)
			thisWnd:SetItemNum(ItemNum)
		end
	end
end

--���ÿ��������Ʒ������  o(��_��)o...
function CMainSkillsToolBar:SetShortCutItemNum(Index)
	self:SetAddSkillWndShortCutItemNum(self, Index)
	self:SetAddSkillWndShortCutItemNum(g_GameMain.m_MasterSkillArea, Index)
	self:SetAddSkillWndShortCutItemNum(g_GameMain.m_AddMasterSkillArea, Index)
end

--ɾ�����������������Ŀ�����ϵ�����
function CMainSkillsToolBar:DelAddSkillWndShortCutItem(Index, skillWndObj, wndType)
	local m_tblShortcutPiece = skillWndObj.m_WndSkill:GetTblShortcutPiece()
	--ɾ������������ϵĸ�������
	for i = 1, PieceNumber do
		local thisWnd = m_tblShortcutPiece[i]
		if thisWnd:GetState() ~= EShortcutPieceState.eSPS_None and Index == thisWnd:GetIndex() then
			local uBigID, uIndex = thisWnd:GetItemContext()
			local num = g_GameMain.m_BagSpaceMgr:GetItemCountBySpace(g_StoreRoomIndex.PlayerBag,uBigID, uIndex)
			if 	num == 0 then
				local SmallIcon = g_ItemInfoMgr:GetItemInfo(uBigID,uIndex,"SmallIcon")
				g_LoadGrayIconFromRes(SmallIcon, thisWnd.m_SkillBtn, -2, IP_ENABLE, IP_CLICKDOWN)	
			end
		end
	end
end

--ɾ��������ϵ�����  o(��_��)o...
function CMainSkillsToolBar:DelShortCutItem(Index)
	local wnd = self.m_WndSkill:GetTblShortcutPiece()
	
	--ɾ����������ĸ��ӵ�����
	for i = 1, PieceNumber do
		local thisWnd = wnd[i]
		if (thisWnd:GetState() == EShortcutPieceState.eSPS_Item and Index == thisWnd:GetIndex()) then
			local uBigID, uIndex = thisWnd:GetItemContext()
			local num = g_GameMain.m_BagSpaceMgr:GetItemCountBySpace(g_StoreRoomIndex.PlayerBag,uBigID, uIndex)				
			if num == 0 then
				local SmallIcon = g_ItemInfoMgr:GetItemInfo(uBigID,uIndex,"SmallIcon")
				g_LoadGrayIconFromRes(SmallIcon, thisWnd.m_SkillBtn, -2, IP_ENABLE, IP_CLICKDOWN)		
			end
		end 
	end
	
	self:DelAddSkillWndShortCutItem(Index, g_GameMain.m_MasterSkillArea, MasterSkillWnd)
	self:DelAddSkillWndShortCutItem(Index, g_GameMain.m_AddMasterSkillArea, AddMasterSkillWnd)
	if self.m_DeleteItem then
		Gac2Gas:SaveShortCutEnd(g_Conn)
		self.m_DeleteItem = false
	end
end

--��ʾ���ܿ���״̬
function CMainSkillsToolBar:SetAddSkillWndShortCutSkillState(SkillName,Bool, skillWndObj,SkillName,uCoolType)
	local m_tblShortcutPiece = skillWndObj.m_WndSkill:GetTblShortcutPiece()
	for i = 1, PieceNumber do
		local thisWnd = m_tblShortcutPiece[i]
		if thisWnd:GetState() ~= EShortcutPieceState.eSPS_None and uCoolType == thisWnd:GetCoolType() and  SkillName == thisWnd:GetName() then
			if thisWnd:GetState() == EShortcutPieceState.eSPS_Skill then
				thisWnd.m_SkillStateBtn:ShowWnd(Bool)
				if Bool then
					thisWnd.m_SkillStateClientBtn:ShowWnd(false)
				end
			end
		end
	end
end

--��ʾ���ܿ���״̬
function CMainSkillsToolBar:SetShortCutSkillState(SkillName,Bool)
	local skill =  CSkillClient_GetSkillByNameForLua( SkillName)
	if(not skill) then return end
	local uCoolType = skill:GetCoolDownType()
		
	local m_tblShortcutPiece = g_GameMain.m_MasterSkillArea.m_WndSkill:GetTblShortcutPiece()
	local wnd = self.m_WndSkill.m_tblShortcutPiece
	
	for i = 1, PieceNumber do
		local thisWnd = wnd[i]
		if (thisWnd:GetState() ~= EShortcutPieceState.eSPS_None and uCoolType == thisWnd:GetCoolType() and SkillName == thisWnd:GetName()) then
			if thisWnd:GetState() == EShortcutPieceState.eSPS_Skill then
				thisWnd.m_SkillStateBtn:ShowWnd(Bool)
				if Bool then
					thisWnd.m_SkillStateClientBtn:ShowWnd(false)
				end				
			end
		end 
	end

	self:SetAddSkillWndShortCutSkillState(SkillName, Bool, g_GameMain.m_MasterSkillArea,SkillName,uCoolType)
	self:SetAddSkillWndShortCutSkillState(SkillName, Bool, g_GameMain.m_AddMasterSkillArea,SkillName,uCoolType)

	if g_GameMain.m_ServantSkill ~= nil and g_GameMain.m_ServantSkill:IsShow() then
		local PieceTbl = g_GameMain.m_ServantSkill.m_ServantSkillList:GetTblShortcutPiece()
		for i = 1, #(PieceTbl) do
			local thisWnd = PieceTbl[i]
			if thisWnd:GetState() ~= EShortcutPieceState.eSPS_None and uCoolType == thisWnd:GetCoolType() and  SkillName == thisWnd:GetName() then
				if thisWnd:GetState() == EShortcutPieceState.eSPS_Skill then
					thisWnd.m_SkillStateBtn:ShowWnd(Bool)
				end
			end
		end	
	end
end

--��������CDʱ��
function CMainSkillsToolBar:ResetCoolTimerBtn( name,IsClearSkillStateClientBtn)
	local function GetSameSkillNameWnd( name,skillWndObj,StartIndex)
		local m_tblShortcutPiece = skillWndObj.m_WndSkill:GetTblShortcutPiece()	
		for i = StartIndex,PieceNumber do
			if m_tblShortcutPiece[i]:GetName() == name  then
				return true, m_tblShortcutPiece[i]
			end
		end	
	end	
	
	local function ClearCD(Wnd)
		if( nil ~= Wnd ) then
			Wnd:ShowWnd( true )
			Wnd:SetFocus()
			Wnd.m_SkillCDBtn:setTimeEx(0,GetRenderTime(g_MainPlayer))
			Wnd:UnRegisterSelfTick()
		end
	end
	
	local function ClearSkillStateClientBtn(Wnd)
		if( nil ~= Wnd ) then
			Wnd.m_SkillStateClientBtn:ShowWnd(false)
		end
	end
	
	local function FindWndFun(skillWndObj)
		for i = 1,PieceNumber do
			local bool, Wnd  = GetSameSkillNameWnd( name, skillWndObj,i)
			if bool then
				if IsClearSkillStateClientBtn then
					ClearSkillStateClientBtn(Wnd)
				else
					ClearCD(Wnd)
				end
			else
				break
			end
		end
	end
	FindWndFun(self)
	FindWndFun(g_GameMain.m_MasterSkillArea)
	FindWndFun(g_GameMain.m_AddMasterSkillArea)	
end

--��Ϣ��Ӧ
function CMainSkillsToolBar:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	--���ü������ķ�ҳ
	if(uMsgID == BUTTON_CLICKDOWN) then
		if(Child == self.m_BtnShowSkill) then
			local bFlag = g_GameMain.m_MasterSkillArea:IsShow()
			g_GameMain.m_MasterSkillArea:ShowWnd(not bFlag)
			self:SetMasterSkillAreaState()
		elseif(Child == self.m_AddSkillWnd) then
			local bFlag = g_GameMain.m_AddMasterSkillArea:IsShow()
			g_GameMain.m_AddMasterSkillArea:ShowWnd(not bFlag)
			self:SetMasterSkillAreaState()
		elseif(Child == self.m_ShowFuncBtn) then
			for i = 1, 2 do
				g_GameMain.m_tblFunctionBar[i]:DoShapeEffect()
			end
		end
	end
end

--��չ�������״̬����
function CMainSkillsToolBar:SetMasterSkillAreaState()
	local strpath = g_RootPath .. "var/gac/MasterSkillBar.txt"
	local fo = CLuaIO_Open(strpath, "w+")
	if fo then
		local data = fo:WriteString("")
		fo:Close()
		local f = CLuaIO_Open(strpath, "a")
		if f then
			f:WriteString(tostring(g_GameMain.m_MasterSkillArea:IsShow()) 
					.. "," .. tostring(g_GameMain.m_AddMasterSkillArea:IsShow()) 
					)
			f:Close()
		end
	end
end

--�õ���չ������Ĵ�״̬
--true�Ǵ򿪣�false�ر�
function CMainSkillsToolBar:GetMasterSkillAreaState()
	local strpath = g_RootPath .. "var/gac/MasterSkillBar.txt"
	local f = CLuaIO_Open(strpath, "rb")
	local data = ""
	if f then
		data = f:ReadAll()
		f:Close()
	end
	
	if(data == "") then
		return false,false
	end
	
	local nIndex = 0
	for i=1,string.len(data) do
		local str = string.sub(data,i,i)
		if str == "," then
			nIndex = i
			break
		end
	end
	
	local bFlag1,bFlag2 = string.sub(data,1,nIndex - 1),string.sub(data,nIndex + 1 ,string.len(data))
	
	local function ToBoolean(sTr)
		return "true" == sTr 
	end
	return ToBoolean(bFlag1),ToBoolean(bFlag2)
end

--�õ���ǰҳ
function CMainSkillsToolBar:GetCurPage()
	return self.m_CurrentPage
end

--����
function CreateMainSkillsToolBar( Parent )
	InitShortCutKeyName()
	local Wnd = CMainSkillsToolBar:new()
	Wnd:CreateFromRes("SkillBar",Parent)
	Wnd:ShowWnd( true )
	Wnd:SetIsBottom(true)
	Wnd.m_CurrentPage = 1
	Wnd.m_ChoosePiece = nil
	return Wnd
end	

function CMainSkillsToolBar:OnChildCreated()
	self.m_WndSkill		= ClassCast(CShortcut, self:GetDlgChild("BtnSkillArea_1"))
	self.m_AddSkillWnd	= self:GetDlgChild("BtnShowAddSkill")
	self.m_BtnShowSkill	= self:GetDlgChild("BtnShowSkill")
	self.m_ShowFuncBtn	= self:GetDlgChild("ShowFuncBtn")
	self:InitSysBtn()
	self.m_WndSkill:Init(1)
	self.m_PieceTbl = {}
	self.m_PieceTbl[1] = {}
	self.m_PieceTbl[2] = {}
	self.m_PieceTbl[3] = {}
end

function CMainSkillsToolBar:InitSysBtn()
	g_GameMain.m_tblFunctionBar = {}
	for i = 1, 2 do
		g_GameMain.m_tblFunctionBar[i] = CreateFunctionBar(g_GameMain, i, self)
		self:InserBefore(g_GameMain.m_tblFunctionBar[i])
	end
end

--�������
function CMainSkillsToolBar:Clear()
	local tblShortcutPiece = self.m_WndSkill:GetTblShortcutPiece()
	for i = 1 ,PieceNumber do
		local Piece = tblShortcutPiece[i]
		local pos = Piece:GetPos()
		local state = Piece:GetState()
		local DrawPiece = Piece.m_SkillBtn 
		g_WndMouse:ClearIconWnd(DrawPiece)
		local numWnd = Piece.m_SkillBtnNum
		numWnd:SetWndText("")
		Piece.m_SkillStateBtn:ShowWnd(false)
		Piece.m_SkillStateClientBtn:ShowWnd(false)
		Piece:UnRegisterSelfTick()
		Piece:UnRegisterSelfCommTick()
		self.m_WndSkill:GetSubItem(0,pos-1):SetMouseOverDescAfter("")
	end
end

function CMainSkillsToolBar:SetKey(PieceID,Key)
	local m_tblShortcutPiece = self.m_WndSkill:GetTblShortcutPiece()
	local Piece = m_tblShortcutPiece[PieceID]
	Piece.m_SkillBtn:SetWndText(Key)
end

function CMainSkillsToolBar:UpdateToolBarTips()
	local tblShortcutPiece = self.m_WndSkill:GetTblShortcutPiece()
	for i = 1,PieceNumber do 
		local Piece = tblShortcutPiece[i]
		local state = Piece:GetState()
		if state == EShortcutPieceState.eSPS_Skill then
			local fs = Piece:GetSkillContext()
			local tips = g_Tooltips:GetWndSkillTips( fs.SkillName,fs.Level)
			Piece.m_SkillBtn:SetMouseOverDescAfter(tips)
			g_MainPlayer:AddLearnSkill(fs.SkillName,fs.Level)
		end
	end
end

function CMainSkillsToolBar:OnClearCommonCD()
	local tblShortcutPiece = self.m_WndSkill:GetTblShortcutPiece()
	for i = 1,#tblShortcutPiece do
		tblShortcutPiece[i]:OnClearCommonCD()
	end
end

--�밴��ӳ�����Ӧ�ĺ���
function ShortCutMainSkill(index)
	local Wnd = g_GameMain.m_MainSkillsToolBar
	local Piece = Wnd.m_WndSkill.m_tblShortcutPiece[index]	
	Piece.m_SkillBtn:DelFlashAttention()
	Piece.m_SkillBtn:AddFlashInfoByName("skillclickdown1")
	Piece:UseShortcut()
end		

--���ú�����������
function ShortCutMasterSkill(index)
	local Wnd = g_GameMain.m_MasterSkillArea
	local Piece = Wnd.m_WndSkill.m_tblShortcutPiece[index]
	Piece:UseShortcut()
end


------------------------------------MainSkillItemWnd�¼���Ӧ-----------

function CMainSkillItemWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	local parentWnd = g_GameMain.m_MainSkillsToolBar
	parentWnd.m_WndSkill:OnEvent(Child, uMsgID, uParam1, uParam2, parentWnd)
end

