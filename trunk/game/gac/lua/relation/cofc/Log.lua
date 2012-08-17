gac_require "relation/cofc/LogInc"

--������־��Ϣ��ʼ����ʼ���������
function Gas2Gac:ReturnLogBegin(Conn)
	g_GameMain.m_CofCLogWnd.m_LogInfoTbl		=	{}				--��¼�̻���־��Ϣ��table
	g_GameMain.m_CofCLogWnd.m_LogInfoListTbl	=	{}					--�����洢�̻���־��Ϣ�б��е�listctrl�е�item�ؼ�
end

--������־�����Ϣ
function Gas2Gac:ReturnLog(Conn, logCotent, logType, logTime)
	--�����ݿ��е�ʱ���ʽת��Ϊ��������������ʽ
	local tblLogType = {"��Ա","����","�Ƽ�","����","����"}
	local tblWeekday = {"������","����һ","���ڶ�","������","������","������","������"}
	
	local weekday    = tblWeekday[tonumber(os.date("%w", logTime))]
	local date       = os.date("%Y��%m��%d��(" .. weekday .. ")%X", logTime)
	local type       = tblLogType[logType + 1]

	local node			=	{}
	node.Time			=	date
	node.LogType		=	type
	node.Description	=	logCotent
	table.insert(g_GameMain.m_CofCLogWnd.m_LogInfoTbl, node)
end

--����������־��Ϣ�������ڿͻ�����ʾ�����Ϣ
function Gas2Gac:ReturnLogEnd(Conn)
	g_GameMain.m_CofCLogWnd:ShowCofCLogInfo()
end


------------------------------------------------------------------------------------


--�����̻���־���
function CreateCofCLogWnd(Parent)
	local wnd	=	CCofCLogWnd:new()
	wnd:CreateFromRes("CofCLog",Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCMainWnd})
	wnd:InitCofCLogChild()
	return wnd
end

--��ʼ���̻���־�����е��ӿؼ�
function CCofCLogWnd:InitCofCLogChild()
	self.m_CloseBtn		=	self:GetDlgChild("Close")
	self.m_ShutDown		=	self:GetDlgChild("ShutDown")
	self.m_AllBtn		=	self:GetDlgChild("All")
	self.m_MemberBtn	=	self:GetDlgChild("Member")
	self.m_TechBtn		=	self:GetDlgChild("Tech")
	self.m_EconomyBtn	=	self:GetDlgChild("Economy")
	self.m_MissionBtn	=	self:GetDlgChild("Mission")
	self.m_LogList		=	self:GetDlgChild("LogList")
end

local LogType = 
{
["��Ա"] 			= 0,
["����"]			= 1,
["�Ƽ�"]			= 2,
["����"]			= 3,
["����"]			= 4
}

--�̻���־�����¼���Ӧ����
function CCofCLogWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn or Child == self.m_ShutDown) then 			--�رհ�ť
	  		self:ShowWnd(false)
	  	
	  	elseif(Child == self.m_AllBtn)    then 								
				Gac2Gas:GetCofCLogInfo(g_Conn, LogType["����"])
	  	
	  	elseif(Child == self.m_MemberBtn)      then																		
				Gac2Gas:GetCofCLogInfo(g_Conn, LogType["��Ա"])
	  	
	  	elseif(Child == self.m_MissionBtn)       then							
				Gac2Gas:GetCofCLogInfo(g_Conn, LogType["�Ƽ�"])
	  		
	  	elseif(Child == self.m_TechBtn) then						
				Gac2Gas:GetCofCLogInfo(g_Conn, LogType["����"])
		
			elseif(Child == self.m_EconomyBtn) then	
				Gac2Gas:GetCofCLogInfo(g_Conn, LogType["����"])
			end
	end
end

--��ʾ������־��Ϣ
function CCofCLogWnd:ShowCofCLogInfo()
	local logTbl =	self.m_LogInfoTbl
	self.m_LogList:DeleteAllItem()
	for i=1, table.maxn( logTbl ) do
		if ( i == 1 ) then
		  self.m_LogList:InsertColumn( 0, self.m_LogList:GetWndWidth())
		end
		self.m_LogList:InsertItem( i-1, 25 )
		
		local logItemWnd = SQRDialog:new()
		local item = self.m_LogList:GetSubItem( i-1, 0)
		logItemWnd:CreateFromRes( "CofCLogItem", item )
		logItemWnd:ShowWnd( true )
		logItemWnd:SetStyle( 0x60000000 )
		logItemWnd:GetDlgChild("Time"):SetWndText(logTbl[i].Time)
		logItemWnd:GetDlgChild("Type"):SetWndText(logTbl[i].LogType)
		logItemWnd:GetDlgChild("Description"):SetWndText(logTbl[i].Description)
		table.insert(self.m_LogInfoListTbl, logItemWnd)
	end
end
