gac_require "relation/tong/TongBaseInc"
gac_gas_require "relation/tong/TongTechnologyMgr"
gac_gas_require "relation/tong/TongProdItemMgr"
cfg_load "tong/TongAutoSeekStation_Common"
lan_load "tong/Lan_TongAutoSeekStation_Common"

local tblStationString =
{
	[0] = GetStaticTextClient(10031),
	[1] = {GetStaticTextClient(2504), GetStaticTextClient(2505), GetStaticTextClient(2506)},--{"����", "��ʥ", "��˹"}
	[2] = {GetStaticTextClient(10026), GetStaticTextClient(10027)},--{"��һս��", "�ڶ�ս��"}
	[3] = {GetStaticTextClient(10028), GetStaticTextClient(10029), GetStaticTextClient(10030)}--{"��һפ��", "�ڶ�פ��", "����פ��"}
}

function CreateTongBase(Parent)
	local TongBase = CTongBase:new()
	TongBase:Init(Parent)
	return TongBase
end

function CTongBase:Init(Parent)
	self.m_tblAllTongList			= {}	--��ʱ�����Ϸ�����а�����Ϣ
	self.m_tblTongWarAward    = {}  --��ʱ��Ź�ս��������ҽ��������Ϣ
	self.m_tblAllPlayerList   = {}  --��ʱ�����Ϸ������δ������������Ϣ
	self.m_tblTongWarAward    = {}  --��ʱ��Ź�ս��������ҽ��������Ϣ
	self.m_tblTongInfo				= {}	--�����Ϣ
	self.m_tblTongMemInfo     = {}  --��ʱ���С�ӳ�Ա��Ϣ
	self.m_TongPos					= 0		--��Ӷ�����е�ְλ
	self.m_CreateBuildingPageNum	= 1		--�����������ҳ��
	self.m_CreateArmPageNum			= 1		--������е���ҳ��
	self.m_tmpArmItemIndex			= -1	--��ѡ�ľ�е����
	self.m_MsgBoxType				= 0		--���öԻ����Ӧ�����ͣ�0Ϊ��ͨ��ʾ��Ϣ��1Ϊȷ��ɾ������,2Ϊȷ����������3Ϊȷ��ֹͣ����4Ϊ����������
	self.m_TongType					= 0		--Ӷ��С������
end

function CTongBase:TranslateStationId(nStation)
	if(0 == nStation) then
		return tblStationString[0]
	end
	local nCamp = math.floor(nStation/100)
	local nLine = math.floor(nStation%100/10)
	local nZone = nStation%10
	return string.format( "%s.%s.%s", tblStationString[1][nCamp], tblStationString[2][nLine], tblStationString[3][nZone] )
end


function CTongBase:GetStationDes(nWarZoneId,nStationId)
	local strStation = ""
	if(nStationId == 0) then
		strStation = GetStaticTextClient(10059)
	else
		local Index = MemH64(nStationId..nWarZoneId)
		strStation = Lan_TongAutoSeekStation_Common(Index,"displayName")
	end
	return strStation
end
	
------�ر����д򿪵İ�����------
function CTongBase:CloseAllTongPan()
	g_ExcludeWndMgr:RemoveOneFuncGroupPan(1)
--	g_GameMain.m_TongWarExitBtnWnd:ClosePanel()
	g_GameMain.m_TongChallengeExitBtnWnd:ClosePanel()
end

------���ذ���Ա��Ϣ��ʼ------
function CTongBase:ReturnGetTongMemberInfoStart(Conn)
	g_GameMain.m_TongMainPan.m_tblPanel[2].m_CurMemNum = 0
	g_GameMain.m_TongMainPan.m_tblPanel[2].m_OnlineMemNum = 0
	g_GameMain.m_TongMainPan.m_tblPanel[2].m_tblTongMemInfo = {}  --��հ���Ա�б�
	g_GameMain.m_TongMainPan.m_tblPanel[2]:InitTblTongPosMember() --��ʼ��ְλ��Ա�б�
end

------���ذ���Ա��Ϣ(ID, ����, ְλ, �ȼ�, ְҵ, �Ѿ����, ���й���, ����, �Ƿ�����)------
function CTongBase:ReturnGetTongMemberInfo(Conn,id,name,position,level,class,proffer,profferExpend,tongProffer,exploit,nOnline,outLineTime)
	g_GameMain.m_TongMainPan.m_tblPanel[2].m_CurMemNum = g_GameMain.m_TongMainPan.m_tblPanel[2].m_CurMemNum + 1
	if nOnline == 1 then
		g_GameMain.m_TongMainPan.m_tblPanel[2].m_OnlineMemNum = g_GameMain.m_TongMainPan.m_tblPanel[2].m_OnlineMemNum + 1
	end
	local tbl = {}
	tbl.id				= id
	tbl.name			= name
	tbl.position		= position
	tbl.level			= level
	tbl.class			= class
	tbl.proffer			= proffer
	tbl.profferExpend	= profferExpend
	tbl.tongProffer 	= tongProffer
	tbl.exploit			= exploit
	tbl.nOnline			= nOnline
	tbl.latestOnLine= outLineTime  
	table.insert(self.m_tblTongMemInfo, tbl)	
	if(position < 5) then
		table.insert(g_GameMain.m_TongMainPan.m_tblPanel[2].m_tblTongPosMem[position], name)
	end
end

------���ذ���Ա��Ϣ����------
function CTongBase:ReturnGetTongMemberInfoEnd(Conn, maxNum)
	table.sort(self.m_tblTongMemInfo, function (a, b) return b.latestOnLine < a.latestOnLine end)
	local OnlineTbl = {}
	local OfflineTbl = {}
	for i, v in ipairs(self.m_tblTongMemInfo) do
		if v.nOnline == 1 then
			table.insert(OnlineTbl,v)
		else
			table.insert(OfflineTbl,v)
		end
	end
	local DisplayList = {}
	for i=1, #OnlineTbl do
		table.insert(DisplayList,OnlineTbl[i])
	end
	for i=1, #OfflineTbl do
		table.insert(DisplayList,OfflineTbl[i])
	end
	g_GameMain.m_TongMainPan.m_tblPanel[2].m_tblTongMemInfo = DisplayList
	if g_GameMain.m_TongMainPan.m_tblPanel[2]:IsShow() then
		g_GameMain.m_TongMainPan.m_tblPanel[2]:UpdateTongMemInfo(maxNum)
	end
	self.m_tblTongMemInfo = {}
end

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--****************************************************************************************************************
--Rpc
--****************************************************************************************************************
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////

------�����뿪���------
function Gas2Gac:ReturnBeOutOfTong(Conn)
	local Wnd = g_GameMain.m_CreateChatWnd.m_ChatSendArea
	Wnd:SetDefaultChannel(ChannelNameTbl[7])
	g_GameMain.m_TongBase.m_TongPos = 0
	g_GameMain.m_TongBase:CloseAllTongPan()
	
	g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit() --����ͷ����Ϣ
end

------���ذ�ᴴ��-----
function Gas2Gac:ReturnCreateTong(Conn)
	g_GameMain.m_TongCreate:ShowWnd(false)
	g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit() --����ͷ����Ϣ
	g_GameMain.m_TongMainPan:ChangePageTo(7)
	g_GameMain.m_TongMainPan:OpenPanel(true)

end

------���ؼ���Ӷ����------
function Gas2Gac:ReturnJoinInTong(Conn)
	g_GameMain.m_TongMainPan:ChangePageTo(7)
	g_GameMain.m_TongBase.m_TongPos = 1   			--����Ӷ���ź�ְλĬ��Ϊ��Ա
	g_GameMain.m_TongMainPan:OpenPanel(true)
end

------���ذ����Ϣ------
function Gas2Gac:ReturnGetTongInfo(Conn, id, name, leaderName, curMemNum, maxMemNum,
		level, honor, exploit, money, res, maxRes, purpose, challengeState, warZoneId, 
		stationId, type, developdegree, permitUpLevel,resName)
	g_GameMain.m_TongBase.m_tblTongInfo =
		{id, name, leaderName, curMemNum, maxMemNum, level, honor, exploit, money, res, maxRes, purpose,
		challengeState, warZoneId, stationId, type, developdegree, permitUpLevel,resName}
		
	g_GameMain.m_TongMainPan.m_tblPanel[1]:UpdateTongInfo(unpack(g_GameMain.m_TongBase.m_tblTongInfo))
--	local assoListWnd = g_GameMain.m_AssociationWnd.m_AssociationListWnd
--	if(assoListWnd) then
--		assoListWnd:RetSetTongList()
--	end
end

function Gas2Gac:ReturnGetTongRequestInfoBegin(Conn)
	g_GameMain.m_TongMainPan.m_tblPanel[3].m_CurMemNum			= 0
	g_GameMain.m_TongMainPan.m_tblPanel[3].m_tblTongAppMemInfo	= {}
end

------������������Ա��Ϣ------
function Gas2Gac:ReturnGetTongRequestInfo(Conn,id,name,level,class,exploit,proffer)
	g_GameMain.m_TongMainPan.m_tblPanel[3].m_CurMemNum = g_GameMain.m_TongMainPan.m_tblPanel[3].m_CurMemNum + 1
	local tbl = {}
	tbl.id			= id
	tbl.name		= name
	tbl.level		= level
	tbl.class		= class
	tbl.proffer		= proffer
	tbl.exploit		= exploit
	table.insert(g_GameMain.m_TongMainPan.m_tblPanel[3].m_tblTongAppMemInfo, tbl)
end

------������������Ա��Ϣ����------
function Gas2Gac:ReturnGetTongRequestInfoEnd(Conn, maxNum)
	g_GameMain.m_TongMainPan.m_tblPanel[3]:UpdateTongMemAppInfo(maxNum)
end

------���ؼ������Ƿ�ɹ�------
function Gas2Gac:ReturnBeJoinTong(Conn, beFlag)
	Gac2Gas:GetTongRequestInfo(g_Conn)
end

------���ؿ�������Ա------
function Gas2Gac:ReturnKickOutOfTong(Conn, bFlag)
	Gac2Gas:GetTongMemberInfo(g_Conn)
end

------���ش�ְ------
function Gas2Gac:ReturnTongResign(Conn, bFlag)
	Gac2Gas:GetTongMemberInfo(g_Conn)
end

------���ر������ߵ���Ӧ------
function Gas2Gac:ReseiveResponseBeInviteToTong(Conn, inviteeName, bFlag)
	if(bFlag) then
		MsgClient(9321, inviteeName)
		if(g_GameMain.m_TongMainPan.m_tblPanel[2]) then
			Gac2Gas:GetTongMemberInfo(g_Conn)
		end
	end
end

------�����޸�ְλ��beSuccess����ȷ���޸��Ƿ�ɹ������ɹ���ζ�Ÿó�Ա��ְλ�Ѿ��������޸���------
function Gas2Gac:ReturnChangePos(Conn, beFlag)
	Gac2Gas:GetTongMemberInfo(g_Conn)
end

function Gas2Gac:ReturnPosChanged(Conn, pos)
	g_GameMain.m_TongBase.m_TongPos = pos
end

------�������а������ֺ�������Ϣ------
function Gas2Gac:ReturnGetAllTongSomeInfo(Conn, nId, sName, nMemNum, nLevel,sCaptainName, nWarZoneId, nStationId, nMaxNum, nStationLine)
	local tbl		= {}
	tbl.nId			= nId
	tbl.sName		= sName
	tbl.nMemNum		= nMemNum
	tbl.nLevel		= nLevel
	tbl.nWarZoneId	= nWarZoneId
	tbl.nStationId	= nStationId
	tbl.sCaptainName = sCaptainName
	tbl.nMaxNum = nMaxNum
	tbl.nStationLine = nStationLine
	table.insert(g_GameMain.m_TongBase.m_tblAllTongList, tbl)
end

local function SortTongFunc(a,b)
	if a.nLevel == b.nLevel then
		return b.nStationLine < a.nStationLine 
	else
		return b.nLevel < a.nLevel
	end
end

------�������а������ֺ�������Ϣ����------
function Gas2Gac:ReturnGetAllTongSomeInfoEnd(Conn)
	table.sort(g_GameMain.m_TongBase.m_tblAllTongList,SortTongFunc)
	g_GameMain.m_TongRequest.m_AllTongInfoTbl = g_GameMain.m_TongBase.m_tblAllTongList
	
	g_GameMain.m_TongRequest:ChangePage(0)
	g_GameMain.m_TongRequest:ShowCurPage()
	g_GameMain.m_TongRequest:DrawRequestList()
	g_GameMain.m_TongBase.m_tblAllTongList = {}
end



------��������δ����Ӷ��С����ҵ���Ϣ------
function Gas2Gac:ReturnGetAllPlayerSomeInfo(Conn, nId, sName, nLevel, nClass, fFightPoint, nProffer, nExploit)
	local tbl		= {}
	tbl.nId			= nId
	tbl.sName		= sName
	tbl.nLevel		= nLevel
	tbl.nClass	= nClass
	tbl.fFightPoint	= fFightPoint
	tbl.nProffer = nProffer
	tbl.nExploit = nExploit
	table.insert(g_GameMain.m_TongBase.m_tblAllPlayerList, tbl)
end

local function SortPlayerFunc(a,b)
	if a.nLevel == b.nLevel then
		return b.fFightPoint < a.fFightPoint
	else
		return b.nLevel < a.nLevel 
	end
end

------��������δ����Ӷ��С����ҵ���Ϣ����------
function Gas2Gac:ReturnGetAllPlayerSomeInfoEnd(Conn)
	table.sort(g_GameMain.m_TongBase.m_tblAllPlayerList,SortPlayerFunc)
	g_GameMain.m_TongRecruit.m_AllPlayerInfoTbl = g_GameMain.m_TongBase.m_tblAllPlayerList
	
	g_GameMain.m_TongRecruit:ChangePage(0)
	g_GameMain.m_TongRecruit:ShowCurPage(0)
	g_GameMain.m_TongRecruit:DrawPlayerList()
	g_GameMain.m_TongBase.m_tblAllPlayerList = {}
end

------�յ���������������Ϣ------
function Gas2Gac:ReseiveInviteJoinTong(Conn, inviterId, inviterName, tongName)
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CreateTongInvMsgMinimum(inviterId, inviterName, tongName)
end


------�����޸İ����ּ------
function Gas2Gac:ReturnChangeTongPurpose(Conn, bFlag)
	Gac2Gas:GetTongInfo(g_Conn)
end

--***************************************************************************
--���ս��
--***************************************************************************
function Gas2Gac:ReturnGetTongChallengeInfoListBegin(Conn, selfWz, selfWzs)
	g_GameMain.m_TongChallenge.m_SelfWz = selfWz
	g_GameMain.m_TongChallenge.m_SelfWzs = selfWzs
	g_GameMain.m_TongChallenge.m_tblTongChanllengeInfo = {}
end

function Gas2Gac:ReturnGetTongChallengeInfoList(Conn, tongName, leaderName, WarZone, Station)
	local tbl = g_GameMain.m_TongChallenge.m_tblTongChanllengeInfo
	table.insert( tbl, {tongName, leaderName, WarZone, Station} )
end

function Gas2Gac:ReturnGetTongChallengeInfoListEnd(Conn)
	g_GameMain.m_TongChallenge:DrawTongChallengeList()
end

function Gas2Gac:ReturnTongChallengeMemberListInfoBegin(Conn)
	g_GameMain.m_TongChallengeBattleCountWnd.m_MemberTbl = {}
end

function Gas2Gac:ReturnTongChallengeMemberListInfo(Conn, sPlayerName, nLevel, nKillNum, nMaxContiKillNum, nDeadTimes)
	local tblMember = g_GameMain.m_TongChallengeBattleCountWnd.m_MemberTbl
	table.insert(tblMember, {sPlayerName, nLevel, nKillNum, nMaxContiKillNum, nDeadTimes})
end

function Gas2Gac:ReturnTongChallengeMemberListInfoEnd(Conn)
	g_GameMain.m_TongChallengeBattleCountWnd:DrawMemberList()
end

function Gas2Gac:ReturnTongWarMemberListInfoBegin(Conn)
	g_GameMain.m_TongWarBattleCountWnd.m_MemberTbl = {}
end

function Gas2Gac:ReturnTongWarMemberListInfo(Conn, sPlayerName, nLevel, nKillNum, nMaxContiKillNum, nDeadTimes, nGetExploit)
	local tblMember = g_GameMain.m_TongWarBattleCountWnd.m_MemberTbl
	table.insert(tblMember, {sPlayerName, nLevel, nKillNum, nMaxContiKillNum, nDeadTimes, nGetExploit})
end

function Gas2Gac:ReturnTongWarMemberListInfoEnd(Conn)
	g_GameMain.m_TongWarBattleCountWnd:DrawMemberList()
end

function Gas2Gac:ReturnTongWarAwardListInfoBegin(Conn)
	local wnd = CTongWarBattleAwardWnd.GetWnd()
	wnd:OpenPanel()
	g_GameMain.m_TongBase.m_tblTongWarAward = {}
	g_GameMain.m_TongWarBattleAwardWnd.m_MemberTbl = {}
end

function Gas2Gac:ReturnTongWarAwardListInfo(Conn, sPlayerName, nLevel, nGetExploit,nAddProffer,nCampAward)
	local tbl = {}
	tbl.sPlayerName = sPlayerName
	tbl.nLevel = nLevel
	tbl.nGetExploit = nGetExploit
	tbl.nAddProffer = nAddProffer
	tbl.nCampAward = nCampAward
	table.insert(g_GameMain.m_TongBase.m_tblTongWarAward, tbl)
end

function Gas2Gac:ReturnTongWarAwardListInfoEnd(Conn)
	local temp = {}
	local DisplayList = {}
	local playerSelf = g_GameMain.m_TongBase.m_tblTongWarAward[1]
	for i,v in ipairs (g_GameMain.m_TongBase.m_tblTongWarAward) do
		if v.sPlayerName ~= playerSelf.sPlayerName then
			table.insert(temp,v)
		end
	end
	table.sort(temp, function(a,b) return b.nGetExploit < a.nGetExploit end )
	table.insert(DisplayList,playerSelf)
	for k,v in ipairs(temp) do
		table.insert(DisplayList,v)
	end
	g_GameMain.m_TongWarBattleAwardWnd.m_MemberTbl = DisplayList
	g_GameMain.m_TongWarBattleAwardWnd:DrawMemberList()
end

function Gas2Gac:ReturnTongMonsAttackListInfoBegin(Conn)
	g_GameMain.m_TongMonsAttackCountWnd.m_MemberTbl = {}
end

function Gas2Gac:ReturnTongMonsAttackListInfo(Conn, sPlayerName, nLevel, nKillNum)
	local tblMember = g_GameMain.m_TongMonsAttackCountWnd.m_MemberTbl
	table.insert(tblMember, {sPlayerName, nLevel, nKillNum})
end

function Gas2Gac:ReturnTongMonsAttackListInfoEnd(Conn)
	g_GameMain.m_TongMonsAttackCountWnd:DrawMemberList()
end

function Gas2Gac:ReturnGetTongBattleListInfoBegin(Conn)
	g_GameMain.m_TongBattleList.m_BattleListInfo = {}
end

function Gas2Gac:ReturnGetTongBattleListInfo(Conn, ChlgTongName, TgtTongName, WarZoneId, StationId)
	local tbl = g_GameMain.m_TongBattleList.m_BattleListInfo
	if TgtTongName == "" then
		TgtTongName = GetStaticTextClient(8329)
	end
	table.insert(tbl, {ChlgTongName, TgtTongName, WarZoneId, StationId})
end

function Gas2Gac:ReturnGetTongBattleListInfoEnd(Conn)
	g_GameMain.m_TongBattleList:DrawTongBattleList()
end

------���ذ��Լս------
function Gas2Gac:ReturnSendChallenge(Conn, bFlag)
	if(bFlag) then
		MessageBox(g_GameMain, MsgBoxMsg(17006), MB_BtnOK)
	end
end

--************************************************************************************
--����ʲƿ�
--************************************************************************************
------���صõ�����ʲ���Ϣ------
function Gas2Gac:ReturnGetTongAllResInfo(Conn, money, res1, res2, res3, res4)
	g_GameMain.m_TongResource:SetTongResInfo(money, res1, res2, res3, res4)
end

--**************************
--�����Ὠ������
--**************************
function Gas2Gac:ReturnGetCreatingBuildingitemInfo(Conn, creatingItemName, creatingItemId, creatingItemPassedTime,
		waitingItemName1, waitingItemId1, waitingItemName2, waitingItemId2, waitingItemName3, waitingItemId3,
		waitingItemName4, waitingItemId4, waitingItemName5, waitingItemId5, waitingItemName6, waitingItemId6)
	local tbl = {creatingItemName, creatingItemId, creatingItemPassedTime,
		waitingItemName1, waitingItemId1, waitingItemName2, waitingItemId2, waitingItemName3, waitingItemId3,
		waitingItemName4, waitingItemId4, waitingItemName5, waitingItemId5, waitingItemName6, waitingItemId6}
	g_GameMain.m_TongCreateBuilding:UpdateInfo(tbl)
end

--��С�ӵȼ�ɸѡ�ɽ���Ŀ
function Gas2Gac:FilterAvailableBuildingItems(Conn,tongLevel)
	g_GameMain.m_TongCreateBuilding:FilterAvailableBuildingItems(tongLevel)
end

function Gas2Gac:ReturnGetCreatingProdItemInfo(Conn, creatingItemName, creatingItemId, creatingItemPassedTime,
		waitingItemName1, waitingItemId1, waitingItemName2, waitingItemId2, waitingItemName3, waitingItemId3,
		waitingItemName4, waitingItemId4, waitingItemName5, waitingItemId5, waitingItemName6, waitingItemId6)
	local tbl = {creatingItemName, creatingItemId, creatingItemPassedTime,
		waitingItemName1, waitingItemId1, waitingItemName2, waitingItemId2, waitingItemName3, waitingItemId3,
		waitingItemName4, waitingItemId4, waitingItemName5, waitingItemId5, waitingItemName6, waitingItemId6}
	g_GameMain.m_TongProductionCenter:UpdateInfo(tbl)
end

function Gas2Gac:ReturnGetTongRelativeLine(Conn, nLine)
	g_GameMain.m_TongProductionCenter:DrawItemCreateList(nLine)
	g_GameMain.m_TongProductionCenter:OnGetCreatingItemInfo()
end

--function Gas2Gac:ReturnRequestAddTongBuyOrder(Conn)
--	if(not g_GameMain.m_TongBuyRes) then
--		gac_require "relation/tong/TongBuyResWnd"
--		g_GameMain.m_TongBuyRes = CreateTongBuyResWnd(g_GameMain)
--	end
--	g_GameMain.m_TongBuyRes:OpenPanel()
--end

--function Gas2Gac:ShowTongSellResWnd(Conn, uTongID, flag)
--	if(not g_GameMain.m_TongSellRes) then
--		g_GameMain.m_TongSellRes = CTongSellForageWnd:new(g_GameMain, flag)
--	end
--	g_GameMain.m_TongSellRes:OpenPanel(uTongID, flag)
--end

--function Gas2Gac:ShowMyResOrderWnd(Conn)
--	if(not g_GameMain.m_TongMyResOrder) then
--		gac_require "relation/tong/TongMyResOrderWnd"
--		g_GameMain.m_TongMyResOrder = CreateTongMyResOrderWnd(g_GameMain)
--	end
--	g_GameMain.m_TongMyResOrder:OpenPanel()
--end

function Gas2Gac:ShowTongResTransWnd(Conn)
	if(not g_GameMain.m_TongResTrans) then
		gac_require "relation/tong/TongResTransWnd"
		g_GameMain.m_TongResTrans = CreateTongResTransWnd(g_GameMain)
	end
	g_GameMain.m_TongResTrans:OpenPanel()
end

function Gas2Gac:ReturnGetTongSellResInfo(Conn, nNum, proffer, tongId)
	CTongSellForageWnd.GetWnd(nNum, proffer, tongId)
end

function Gas2Gac:ReturnGetTongMyResOrderInfo(Conn, TongName, Wz, Wzs, Price, LeftNum)
	g_GameMain.m_TongMyResOrder:ShowMyResOrderInfo(TongName, Wz, Wzs, Price, LeftNum)
end

function Gas2Gac:ReturnGetTongFethResInfo(Conn, LeftFetchResNum, FetchNum)
	CTongFetchResWnd.GetWnd(LeftFetchResNum, FetchNum)
end

function Gas2Gac:ReturnGetTongMarketOrderInfoListBegin(Conn)
	g_GameMain.m_TongViewResOrder.m_TongBuyResOrderTbl = {}
end

function Gas2Gac:ReturnGetTongMarketOrderInfoList(Conn, tongName, wz, wzs, price, leftNum)
	local tbl = g_GameMain.m_TongViewResOrder.m_TongBuyResOrderTbl
	table.insert(tbl, {tongName, wz, wzs, price, leftNum})
end

function Gas2Gac:ReturnGetTongMarketOrderInfoListEnd(Conn)
	local tbl = g_GameMain.m_TongViewResOrder.m_TongBuyResOrderTbl
	local index = 0
	if #tbl > 0 then
		index = 1
	end
	g_GameMain.m_TongViewResOrder:DrawTongBuyResOrderList(index)
end


function Gas2Gac:ShowTongMsg(Conn, MsgId)
	MessageBox(g_GameMain, GetStaticTextClient(MsgId), MB_BtnOK)
end

function Gas2Gac:TongTypeChanged(Conn, Type)
	g_GameMain.m_TongBase.m_TongType = Type
end

function Gas2Gac:ReturnProfferPoint(Conn, ProfferPoint)
	if g_MainPlayer then
		local modifiedJiFenCount = ProfferPoint - g_MainPlayer.m_TongProffer
		CNPCShopSellWnd.UpdatePlayerPoint(10, modifiedJiFenCount, true)
	end
end

function Gas2Gac:ReturnTeamProfferPoint(Conn, TeamProffer)
	if g_MainPlayer then
		g_MainPlayer.m_TeamProffer = TeamProffer
	end
end

function Gas2Gac:TongMoneyMsgToConn(Conn,MsgID,money)
	local g_MoneyMgr = CMoney:new()
	local sMoney = g_MoneyMgr:ChangeMoneyToString(money,EGoldType.GoldCoin)
	MsgClient(MsgID,sMoney)
end
