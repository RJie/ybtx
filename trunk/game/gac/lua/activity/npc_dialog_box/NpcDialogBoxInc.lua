lan_load "npc/Lan_NotFunNpcTypeMap"
CNpcDialogBox             = class( SQRDialog )
CNpcDialogRichTextItem    = class( SQRDialog )
CNpcDialogBoxListCtrlItem = class( SQRDialog )
CNpcDialogBoxListCtrlItemListItem = ( SQRDialog )
CNpcFuncListCtrlItem      = class( SQRDialog )

CNpcDialogBox.DlgTextType = 
{
	["��ȡ����"]				= 0,  --["����"]
	["�ύ����"]				= 1,  --["����"]
	["�̵�"]					= 2,
	["���۽�����"]				= 3,
	["�̻ᴴ������"]			= 4,
	["�̻�������"]				= 5,
	["��Ʊ"]					= 6,
	["Ӷ��С�Ӵ�����"]			= 7,
	["Ӷ���Ŵ�Ӫ��������"]	= 8,
	["�Ƕ���������"]			= 9,  --�淨
	["������������"]			= 10, --�淨
	["���³Ǵ��ʹ�"]			= 11,
	--["���򸱱����񷢲���"]		= 12,
	["�ճ��������"]			= 13,
	["������ᱦ������"]		= 14,
	["����̽�ձ�����"]			= 15,
	["ս������"]				= 16,
	["����"]					= 17, --�淨
	["������"]				= 18, --���
	["�Ⱦ�С��Ϸ������"]		= 19, --�Ⱦ�
	["������������"]			= 20, --�淨
	["�ֿ�"]					= 21,
	["Ӷ����������"]			= 22,
	["Ӷ��С�����봦"]			= 23,
	["Ӷ����ս������"]		= 24,
	["���콨��"]				= 25,
	["���׽�Ǯ"]				= 26,
	["��Ӷ���Ųֿ�"]			= 27,
	["��������"]				= 28,
	["���µȼ�"]				= 29,
	["���"]					= 30,
	["��������"]				= 31,
	["�Ƽ��з�"]				= 32,
	["�Ƽ�ѧϰ"]				= 33,
	["���볷��"]				= 36,
	["ռ���פ��"]				= 42,
	["����"]					= 43,
	["Ӷ������ս������"] 		= 44,
	["Ӷ��С�Ӹ�����"]			= 45,
	--["��Դ�չ���ѯ��"]			= 46,
	["��Դ��ȡ��"]				= 47,
	["��Ὠ����ȡ��"] 			= 48,
	["�����ս���ʹ�"] 			= 49,
	["����"]					= 50,
	["����"]					= 51,
	["���"]					= 52,
	["��ҩ"]					= 53,
	["�ɿ�"]					= 54,
	["����"]					= 55,
	["��������ѧϰNpc"]			= 56,
	["����תְNpc1"]			= 57,
	["����תְNpc2"]			= 58,
	["����תְNpc3"]			= 59,
	["����תְNpc4"]			= 60,
	["����תְNpc5"]			= 61,
	["����תְNpc6"]			= 62,
	["���פ�ش��ʹ�"] 			= 63,
	["�����Դ���䴦"] 			= 64,
	["Ӷ����ˢ�ֱ����ʹ�"]		= 65,
	["����ʦ"]				= 66,
	["��ս����"]				= 67,
	["��ս����"]				= 68,
	["��Դ��ȡ����"]			= 69,
	["������"]				= 70,
	["����"]					= 71,
	["���Ʒ��ȡ"]	= 72,
	
	["Ӷ��С������"]				= 80,
	["Ӷ���Ŵ�����"]				= 81,
	["Ӷ��С������ת��"]		= 82,
	["Ӷ��С����������"]		= 83,
	["������������"]			= 100,
	
	["Ӷ��ָ���Ǽ�"]			= 101,
	["Ӷ��ָ������"]			= 102,
	["Ӷ��ָ������Ȩ"]			= 103,
--	["���﹥�ǽ���"]			= 104,
--	["������Դ�����"]			= 105,
--	["����NPC"] = 106,
	
	["���³Ǳ�����"]			= 107,
	["���˻������"]			= 108,
	["Ӷ����������"]			= 109,
	["�Ͻ�����ѫ��"]			= 110,
	["Boss����ս����"]			= 111,
	["�����̵�"]				= 112,
	["����������"]			= 114,
	["����ܴ�����"]			= 113,
	["����������"]				= 115,
	["�Ⱦ�����������"]		=116,
	["װ������"]                =   117,
	["װ��׷��"]                = 118,
	["��ͨ�̵�"]                = 119,
	["���³�����"]                = 120,
	["����"]							= 121,
	["���ٳ���"]						= 122,
	["Ӷ���Ÿ�����"]               = 123,
	["����"] = 124,
	["�ʽ����(����)"] = 125,
	["�ʽ����(��ֵ)"] = 126,
	["�ʽ����(����)"] = 127,
	["������ȡ����"] = 128,
	["��ɱ���ֽ���"] = 129,
	["����֮Ѩ"]	   = 130,
	["Ӷ����Ա��ļ��"] = 131
}

--����NPC ��Npc�����������ʾ������
--ENpcShowDlg = {}
CNpcDialogBox.ENpcShowDlg = Lan_NotFunNpcTypeMap

function CNpcDialogBox:InitFunLink()
	self.linkfun = {}
	self.linkfun[0] = self.AcceptQuestFun
	self.linkfun[1] = self.FinishQuestFun
	self.linkfun[2] = self.ShopSellFun
	self.linkfun[3] = self.SellOrderFun
	self.linkfun[4] = self.CreatCofCFun
	self.linkfun[5] = self.CofCMainFun
	self.linkfun[6] = self.StockMainFun
	self.linkfun[7] = self.TongCreateFun
	self.linkfun[8] = self.TongMainFun
	self.linkfun[9] = self.DaTaoShaFun
	self.linkfun[10] = self.JiFenSaiFun
	self.linkfun[11] = self.AreaFbSelFun
--	self.linkfun[11] = self.MercenaryGroupFbFun
	-- libing self.linkfun[12] = self.AreaFbQuestFun
	self.linkfun[13] = self.MatchGameSelFun
	self.linkfun[14] = self.DaDuoBaoFun
	self.linkfun[15] = self.JuQingFun
	self.linkfun[16] = self.WarZoneSelFun
	self.linkfun[17] = self.StartQuestionFun
	self.linkfun[18] = self.EnterTongAreaFun
	self.linkfun[19] = self.DrinkFun
	self.linkfun[20] = self.MercenaryEducateActionFun
	self.linkfun[21] = self.DepotFun
	self.linkfun[22] = self.TongRecommendFun
	self.linkfun[23] = self.TongRequestFun
	self.linkfun[24] = self.TongChallengeFun
	self.linkfun[25] = self.CreateBuildingFun
	self.linkfun[26] = self.ContributeMoneyFun
	self.linkfun[27] = self.OpenMercenaryDepotFun
	self.linkfun[28] = self.PromptForageRandomFun
	self.linkfun[29] = self.UpdateOrderFun
	self.linkfun[30] = self.BackoutFun
	self.linkfun[31] = self.MakingFun
	self.linkfun[32] = self.TongOpenScienceFun
	self.linkfun[33] = self.TongLearnScienceFun
	self.linkfun[36] = self.ApplyRetreatFun
	self.linkfun[42] = self.TakeStationFun
	self.linkfun[43] = self.TongAlignmentFun
	self.linkfun[44] = self.EnterTongChallengeAreaFun
	self.linkfun[45] = self.TongChangeNameFun
	--self.linkfun[46] = self.TongViewResOrderFun
	self.linkfun[47] = self.TongFetchResFun
	self.linkfun[48] = self.TongFetchBuildingFun
	self.linkfun[49] = self.ExitTongChallengeFun
	self.linkfun[50] = self.LiveSkillSmithingNPCFun
	self.linkfun[51] = self.LiveSkillCastingNPCFun
	self.linkfun[52] = self.LiveSkillCuisineNPCFun
	self.linkfun[53] = self.LiveSkillPharmacyNPCFun
	self.linkfun[54] = self.LiveSkillCollectOreNPCFun
	self.linkfun[55] = self.LiveSkillFlowerNPCFun
	self.linkfun[56] = self.LearnCommonSkillNpcFun
	self.linkfun[57] = self.LearnSkillNpc1Fun
	self.linkfun[58] = self.LearnSkillNpc2Fun
	self.linkfun[59] = self.LearnSkillNpc3Fun
	self.linkfun[60] = self.LearnSkillNpc4Fun
	self.linkfun[61] = self.LearnSkillNpc5Fun	
	self.linkfun[62] = self.LearnSkillNpc6Fun	
	self.linkfun[63] = self.LeaveTongAreaFun
	self.linkfun[64] = self.TongResTransFun
	self.linkfun[65] = self.MercenaryMonsterFbFun
	self.linkfun[66] = self.OpenFixEquipWndFun
	self.linkfun[67] = self.ChallengeIntroduceFun
	self.linkfun[68] = self.NationIntroduceFun
	self.linkfun[69] = self.RescourseIntroduceFun
	self.linkfun[70] = self.LingYuTransmitFun
	self.linkfun[71] = self.LiveSkillCraftNPCFun
	self.linkfun[72] = self.GMCompenateFun
	self.linkfun[80] = self.CanUpTongTypeFun
	self.linkfun[81] = self.CreateArmyCorpsFun
	self.linkfun[82] = self.CanChangeTongTypeFun
	self.linkfun[83] = self.ResetTongTypeFun
	self.linkfun[100] = self.JiFenSaiInfoFun
	self.linkfun[101] = self.BeComeYbFun
	self.linkfun[102] = self.DingJiYbFun
	self.linkfun[103] = self.ReceivePowerYbFun
--	self.linkfun[104] = self.MonsterAttackIntroduceFun
--	self.linkfun[106] = self.SpecialNpcFun
	
	self.linkfun[107] = self.UndergroudTeamList
	self.linkfun[108] = self.ActionTeamList
	self.linkfun[109] = self.TaskTeamList
	self.linkfun[110] = self.HandForage
	self.linkfun[111] = self.BossBattleFun
	self.linkfun[112] = self.ShopSellFun
	self.linkfun[113] = self.OpenContractManuMarketWnd
	self.linkfun[114] = self.PromptForageRandomFun
	self.linkfun[115] = self.IssueFetchFun
	self.linkfun[116] = self.DrinkShootFun
	self.linkfun[117] = self.OpenEquipRefine
	self.linkfun[118] = self.OpenEquipSuperaddWnd
	self.linkfun[119] = self.ShopSellFun
	self.linkfun[120] = self.AreaFbFun
	self.linkfun[121] = self.BuyOrderFun
	self.linkfun[122] = self.QuickSell
	self.linkfun[123] = self.ArmyCorpsChangeNameFun
	self.linkfun[124] = self.OpenNeedFireActivity
	self.linkfun[125] = self.OpenTongContributeMoneyExp
	self.linkfun[126] = self.OpenTongContributeMoneySoul
	self.linkfun[127] = self.OpenTongContributeMoneyResource
	self.linkfun[128] = self.GivePointIntroduceFun
	self.linkfun[129] = self.PkPointIntroduceFun
	self.linkfun[130] = self.DragonCaveFun
	self.linkfun[131] = self.TongRecruitFun
	
end

function CNpcDialogBox:RunLinkFun(Index, uParam1)
	assert(self.linkfun[Index],"Index["..Index.."]������")
	if g_MainPlayer.m_LockCenter ~= nil and g_MainPlayer.m_LockCenter.m_LockingObj ~= nil then
 		Gac2Gas:SetLockingNPCID(g_Conn,g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID())
  end
	self.linkfun[Index](self, uParam1)
end	
	
function CNpcDialogBox:AcceptQuestFun(uParam1)
	local questname= self.QuestNameList[uParam1+1]
--	local GlobalID = g_QuestGiverGlobalID[questname].GiverGlobalID
--	Gac2Gas:ShowTakeQuestWnd(g_Conn, questname, GlobalID)
--	print("AcceptQuestFun " .. (self.m_TargetEntityID or "��") )
	g_GameMain.m_takeTask:ShowTakeQuestWnd(questname,self.m_TargetEntityID)
end

function CNpcDialogBox:FinishQuestFun(uParam1)
	local questname=self.QuestNameList[uParam1+1]
	if g_AllMercenaryQuestMgr[questname] then
		local GlobalID = g_QuestFinishGlobalID[questname].FinishGlobalID
		Gac2Gas:ShowFinishQuestWnd(g_Conn, questname, GlobalID)
	else
		g_GameMain.m_finishTask:ShowFinishQuestWnd(questname,self.m_TargetEntityID)
	end
end

function CNpcDialogBox:ShopSellFun(uParam1)

	g_GameMain.m_NPCShopSell:NPCShopSellWnd(self.m_NpcNameText)

end

function CNpcDialogBox:AreaFbFun(uParam1)

end


function CNpcDialogBox:SellOrderFun(uParam1)
	g_GameMain.m_CSMSellOrderWnd:OpenCSMSellOrderWnd()
end

function CNpcDialogBox:BuyOrderFun(uParam1)
	CPurchasingAgentMainWnd.GetWnd():OpenPanel(true)
end

function CNpcDialogBox:QuickSell(uParam1)
	CPurchasingAgentMainWnd.GetWnd():OnQuickSellBtn()
end

function CNpcDialogBox:CreatCofCFun(uParam1)
	Gac2Gas:OpenCofCNpcDialog(g_Conn,0)
end

--function CNpcDialogBox:CofCMainFun(uParam1)
--	local cofc_id = g_MainPlayer.m_Properties:GetCofcID()
--	Gac2Gas:GetCofcInfo(g_Conn, cofc_id)
--end

function CNpcDialogBox:StockMainFun(uParam1)
	if g_GameMain.m_CofCMainStockWnd == nil then
		g_GameMain.m_CofCMainStockWnd = CreateStockMainWnd(g_GameMain)
		g_GameMain.m_CofCMainStockWnd:ShowWnd(true)
	elseif g_GameMain.m_CofCMainStockWnd:IsShow() == false then
		g_GameMain.m_CofCMainStockWnd:ShowWnd(true)
	end
	Gac2Gas:GetCofCStockInfo(g_Conn)
end

function CNpcDialogBox:CreateArmyCorpsFun(uParam1)
	if(not g_GameMain.m_TongCreate) then
		gac_require "relation/tong/TongCreate"
		g_GameMain.m_TongCreate = CreateTongCreateWnd(g_GameMain)
	end
	g_GameMain.m_TongCreate:OpenPanel(2)
end

---------------------Ӷ���Ÿ���
function CNpcDialogBox:ArmyCorpsChangeNameFun(uParam1)
	if g_MainPlayer.m_Properties:GetArmyCorpsName() == "" then
		MsgClient(8509)
		return
	end
	if( not string.find(g_MainPlayer.m_Properties:GetArmyCorpsName(), "&") ) then
		MsgClient(8544)
		return
	end
	Gac2Gas:PreChangeArmyCorpsName(g_Conn)
end

function CNpcDialogBox:TongCreateFun(uParam1)
	if(not g_GameMain.m_TongCreate) then
		gac_require "relation/tong/TongCreate"
		g_GameMain.m_TongCreate = CreateTongCreateWnd(g_GameMain)
	end
	g_GameMain.m_TongCreate:OpenPanel(1)
end

function CNpcDialogBox:CanUpTongTypeFun(uParam1)
	if g_GameMain.m_TongBase.m_TongPos ~= g_TongMgr.m_tblPosInfo["�ų�"] then
		MsgClient(9355)
		return false
	end
	CTongTypeUpdateWnd.GetWnd():OnUpTongTypeFun()
end

function CNpcDialogBox:CanChangeTongTypeFun(uParam1)
	if g_GameMain.m_TongBase.m_TongPos ~= g_TongMgr.m_tblPosInfo["�ų�"] then
		MsgClient(9355)
		return false
	end
	CTongTypeChangeWnd.GetWnd():OpenPanel(true)
end

function CNpcDialogBox:ResetTongTypeFun(uParam1)
	if g_GameMain.m_TongBase.m_TongPos ~= g_TongMgr.m_tblPosInfo["�ų�"] then
		MsgClient(9370)
		return false
	end
	CTongTypeChangeWnd.GetWnd():ResetTongType()
end

function CNpcDialogBox:TongMainFun(uParam1)
	local tongId =g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	else
		g_GameMain.m_TongMainBuildPan:ShowWnd(true)
		local AutoCloseWnd = CAutoCloseWnd:new()
		AutoCloseWnd:AutoCloseWnd(g_GameMain.m_TongMainBuildPan)
	end
end

function CNpcDialogBox:TongRecommendFun(uParam1)
	if(not g_GameMain.m_TongRecommend) then
		gac_require "relation/tong/TongRecommend"
		g_GameMain.m_TongRecommend = CreateTongRecommendWnd(g_GameMain)
	end
	g_GameMain.m_TongRecommend:OpenPanel(true) --��������������ڿ����͹ر�����
end

function CNpcDialogBox:TongRequestFun(uParam1)
	if(not g_GameMain.m_TongRequest) then
		gac_require "relation/tong/TongRequest"
		g_GameMain.m_TongRequest = CreateTongRequestWnd(g_GameMain)
	end
	g_GameMain.m_TongRequest:OpenPanel()
end

function CNpcDialogBox:TongRecruitFun(uParam1)
	if(not g_GameMain.m_TongRecruit) then
		local TongRecruit = CTongRecruit.GetWnd(g_GameMain)
	end
	g_GameMain.m_TongRecruit:OpenPanel()
end

function CNpcDialogBox:TongChallengeFun(uParam1)
	local tongId = g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	else
		if(not g_GameMain.m_TongChallenge) then
			gac_require "relation/tong/TongChallenge"
			g_GameMain.m_TongChallenge = CreateTongChallengeWnd(g_GameMain)
		end
		g_GameMain.m_TongChallenge:OpenPanel()
		local AutoCloseWnd = CAutoCloseWnd:new()
		AutoCloseWnd:AutoCloseWnd(g_GameMain.m_TongChallenge)
	end
end

function CNpcDialogBox:TongFetchBuildingFun(uParam1)
	if not g_GameMain.m_TongFetchBuildingWnd then
		gac_require "relation/tong/TongFetchBuildingWnd"
		g_GameMain.m_TongFetchBuildingWnd = CreateTongFetchBuildingWnd(g_GameMain)
	end
	g_GameMain.m_TongFetchBuildingWnd:OpenPanel()
end

function CNpcDialogBox:ExitTongChallengeFun(uParam1)
	Gac2Gas:ExitTongChallenge(g_Conn)
end

function CNpcDialogBox:TongFetchResFun(uParam1)
	Gac2Gas:GetTongFethResInfo(g_Conn)
end

--function CNpcDialogBox:TongViewResOrderFun(uParam1)
--	local tongId = g_MainPlayer.m_Properties:GetTongID()
--	if(0 == tongId) then
--		MsgClient(9401)
--		return
--	else
--		if(not g_GameMain.m_TongViewResOrder) then
--			gac_require "relation/tong/TongViewResOrderWnd"
--			g_GameMain.m_TongViewResOrder = CreateTongViewResOrderWnd(g_GameMain)
--		end
--		g_GameMain.m_TongViewResOrder:OpenPanel()
--	end
--end

function CNpcDialogBox:TongChangeNameFun(uParam1)
	if( g_MainPlayer.m_Properties:GetTongID() == 0 ) then
		MsgClient(9401)
		return
	end
	if( not string.find(g_MainPlayer.m_Properties:GetTongName(), "&") ) then
		MsgClient(8999)
		return
	end
	Gac2Gas:PreChangeTongName(g_Conn)
end

function CNpcDialogBox:LiveSkillSmithingNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("����")
	g_GameMain.m_NpcDlgCopy:OpenPanel("����", bFlag)
end

function CNpcDialogBox:LiveSkillCastingNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("����")
	g_GameMain.m_NpcDlgCopy:OpenPanel("����", bFlag)
end

function CNpcDialogBox:LiveSkillCraftNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("����")
	g_GameMain.m_NpcDlgCopy:OpenPanel("����", bFlag)
end

function CNpcDialogBox:LiveSkillCuisineNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("���")
	g_GameMain.m_NpcDlgCopy:OpenPanel("���", bFlag)
end

function CNpcDialogBox:LiveSkillPharmacyNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("��ҩ")
	g_GameMain.m_NpcDlgCopy:OpenPanel("��ҩ", bFlag)
end

function CNpcDialogBox:LiveSkillCollectOreNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("�ɿ�")
	g_GameMain.m_NpcDlgCopy:OpenPanel("�ɿ�", bFlag)
end

function CNpcDialogBox:LiveSkillFlowerNPCFun(uParam1)
	local bFlag = g_GameMain.m_LiveSkillMainWnd:GetStateByName("����")
	g_GameMain.m_NpcDlgCopy:OpenPanel("����", bFlag)
end

function CNpcDialogBox:DaTaoShaFun(uParam1)
	if  g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowDaTaoShaWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:JiFenSaiFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowJiFenSaiWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:AreaFbSelFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowAreaFbSelWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:MatchGameSelFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowMatchGameSelWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:DaDuoBaoFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowDaDuoBaoWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:JuQingFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowJuQingWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:DrinkFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowDrinkWnd(g_Conn, EntityID)
	end 
end

function CNpcDialogBox:MercenaryEducateActionFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowYbEducateActionWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:MercenaryMonsterFbFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowMercenaryMonsterFbWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:JiFenSaiInfoFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowJiFenSaiInfoWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:WarZoneSelFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		ShowWarZoneSelWnd(EntityID)
	end
end



--local NpcTriggerEvent_Common = NpcTriggerEvent_Common
function CNpcDialogBox:StartQuestionFun( uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
--		local QuestionTypeName = nil 
		local NpcName = self.m_NpcNameText
--		local TriggerTbl = NpcTriggerEvent_Common[npcName]
--		for _, v in pairs(TriggerTbl) do 
--			if v.TriggerType == "ѡ��" then
--				for _, Arg in pairs( v.ScriptArg) do
--					if Arg[1] == "����" then
--						QuestionTypeName = Arg[2]
--						break
--					end
--				end
--				break
--			end
--		end
		local TriggerTbl = GetNpcTriggerArg(NpcName, "ѡ��", "����")
		if not TriggerTbl then
			return
		end
		local QuestionTypeName = TriggerTbl["Arg"][1][1]
		if QuestionTypeName == nil or QuestionTypeName == "" then
			return
		end		
		Gas2Gac:RetShowEssayQuestionWnd(g_Conn, QuestionTypeName, "", EntityID)
	end
end


function CNpcDialogBox:EnterTongAreaFun(uParam1)
	if(not g_MainPlayer) then return end
	local tongId = g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	else
		if(g_MainPlayer.m_LockCenter.m_LockingObj) then
			local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
			Gac2Gas:EnterTongArea(g_Conn, EntityID)
		end
	end
end

function CNpcDialogBox:LeaveTongAreaFun(uParam1)
	if(not g_MainPlayer) then return end
	local tongId = g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	else
		if(g_MainPlayer.m_LockCenter.m_LockingObj) then
			local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
			Gac2Gas:LeaveTongArea(g_Conn, EntityID)
		end
	end
end

function CNpcDialogBox:TongResTransFun(uParam1)
	if(not g_MainPlayer) then return end
	local tongId = g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	else
		if(g_MainPlayer.m_LockCenter.m_LockingObj) then
			local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
			Gac2Gas:ShowTongResTransWnd(g_Conn, EntityID)
		end
	end
end

function CNpcDialogBox:EnterTongChallengeAreaFun(uParam1)
	if(not g_MainPlayer) then return end
	local tongId = g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	else
		if(g_MainPlayer.m_LockCenter.m_LockingObj) then
			local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
			Gac2Gas:EnterTongChallengeArea(g_Conn, EntityID)
		end
	end
end

function CNpcDialogBox:DepotFun(uParam1)
	g_GameMain.m_Depot:OpenPanel()
	g_GameMain.m_WndMainBag:ShowWnd(true)
	g_GameMain.m_WndBagSlots.m_lcAddBagSlots:UpdateBagSlotsPos()
end

--�򿪼�������ѧϰ���
function CNpcDialogBox:LearnCommonSkillNpcFun(uParam1)
	local Wnd = g_GameMain.m_LearnCommonSkillWnd
	if not Wnd:IsShow() then
		OpenLearnCommonSkillWnd()
	end
end

local function OpenNpcSkillLearnWnd()
	if not g_GameMain.m_NpcSkillLearnWnd.m_InitWnd then
		Gac2Gas:RequestSkillSeries(g_Conn)
		g_GameMain.m_NpcSkillLearnWnd.IsOpenWnd = true
	else
		g_GameMain.m_NpcSkillLearnWnd:OpenSelf()
	end
end

--��ʦ��ʦ
function CNpcDialogBox:LearnSkillNpc1Fun(uParam1)
	local ClassID = g_MainPlayer:CppGetClass()
	if ClassID ==  EClass.eCL_Warrior then
		OpenNpcSkillLearnWnd()
	end		
end

--ħ��ʿ��ʦ
function CNpcDialogBox:LearnSkillNpc2Fun(uParam1)
	local ClassID = g_MainPlayer:CppGetClass()
	if ClassID ==  EClass.eCL_MagicWarrior then
		OpenNpcSkillLearnWnd()
	end		
end

--��ʦ��ʦ
function CNpcDialogBox:LearnSkillNpc3Fun(uParam1)
	local ClassID = g_MainPlayer:CppGetClass()
	if ClassID ==  EClass.eCL_NatureElf then
		OpenNpcSkillLearnWnd()	
	end		
end

--аħ��ʦ
function CNpcDialogBox:LearnSkillNpc4Fun(uParam1)
	local ClassID = g_MainPlayer:CppGetClass()
	if ClassID ==  EClass.eCL_EvilElf then
		OpenNpcSkillLearnWnd()	
	end		
end

--��ʦ��ʦ
function CNpcDialogBox:LearnSkillNpc5Fun(uParam1)
	local ClassID = g_MainPlayer:CppGetClass()
	if ClassID ==  EClass.eCL_Priest then
		OpenNpcSkillLearnWnd()	
	end		
end

--���˵�ʦ
function CNpcDialogBox:LearnSkillNpc6Fun(uParam1)
	local ClassID = g_MainPlayer:CppGetClass()
	if ClassID ==  EClass.eCL_OrcWarrior then
		OpenNpcSkillLearnWnd()	
	end		
end

--���콨��--(��ʾ��Ὠ�����)
function CNpcDialogBox:CreateBuildingFun(uParam1)
	if(not g_GameMain.m_TongCreateBuilding) then
		g_GameMain.m_TongCreateBuilding = CTongBuildingItemCreateWnd:new()
	end
	g_GameMain.m_TongCreateBuilding:OpenPanel(true)
end

--���׽�Ǯ--
function CNpcDialogBox:ContributeMoneyFun(uParam1)
	if(not g_GameMain.m_ContributeMoney) then
		gac_require "relation/tong/TongMsgBox"
		g_GameMain.m_ContributeMoney = CreateTongInputBoxWnd(g_GameMain)
	end
	Gac2Gas:GetMoneyCanContribute(g_Conn)
end

--��ʾӶ���Ųֿ�--(��ʾ���ֿ����)
function CNpcDialogBox:OpenMercenaryDepotFun(uParam1)
	g_GameMain.m_TongDepot:OpenPanel()
end

--��������(����������)
function CNpcDialogBox:PromptForageRandomFun(uParam1)
	if not IsCppBound(g_MainPlayer) then
		return
	end
	if(g_MainPlayer.m_LockCenter.m_LockingObj) then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:RandomShowTongSellResWnd(g_Conn, EntityID)
	end
end

--����NPC�ȼ�--
function CNpcDialogBox:UpdateOrderFun(uParam1)
	local function IsContinue(GameWnd, uButton)
		if uButton == MB_BtnOK then
			if  g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
				local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
				Gac2Gas:UpdateBuildingLevel(g_Conn, EntityID)
			end
		end
		return true
	end	
	MessageBox(g_GameMain, GetStaticTextClient(9102), BitOr(MB_BtnOK, MB_BtnCancel), IsContinue, g_GameMain)
end

--���--
function CNpcDialogBox:BackoutFun(uParam1)
	local function IsContinue(GameWnd, uButton)
		if uButton == MB_BtnOK then
			if  g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
				local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
				Gac2Gas:RemoveBuilding(g_Conn, EntityID)
			end	
		end
		return true
	end
	MessageBox(g_GameMain, GetStaticTextClient(9101), BitOr(MB_BtnOK, MB_BtnCancel), IsContinue, g_GameMain)
end

--��������--
function CNpcDialogBox:MakingFun(uParam1)
	if(not g_GameMain.m_TongProductionCenter) then
		g_GameMain.m_TongProductionCenter = CTongProductionCenterWnd:new()
	end
	g_GameMain.m_TongProductionCenter:OpenPanel(true)
end

--�Ƽ��з�--
function CNpcDialogBox:TongOpenScienceFun(uParam1)
	g_GameMain.m_TongScience:OpenPanel(true)
end

--�Ƽ�ѧϰ--
function CNpcDialogBox:TongLearnScienceFun(uParam1)
	g_GameMain.m_TongLearnScience:OpenPanel(true)
end

--���볷��--
function CNpcDialogBox:ApplyRetreatFun(uParam1)
	if not IsCppBound(g_MainPlayer) then
		return
	end

	local function RetreatStationWarn(g_GameMain,uButton)
		if uButton == MB_BtnOK then
			Gac2Gas:RequestRetreatStation(g_Conn)
		end

		g_GameMain.m_RetreatStationWarn = nil
		return true
	end
	
	local str = MsgBoxMsg(17012)
	g_GameMain.m_RetreatStationWarn = MessageBox( g_GameMain, str, BitOr( MB_BtnOK, MB_BtnCancel), RetreatStationWarn, g_GameMain)
end

--ռ���פ��--
function CNpcDialogBox:TakeStationFun(uParam1)

end

--����--
function CNpcDialogBox:TongAlignmentFun(uParam1)

end

--��װ���������
function CNpcDialogBox:OpenFixEquipWndFun(uParam1)
--    g_GameMain.m_FixEquipWnd:ShowWnd(true)
--    if   g_GameMain.m_WndMainBag:IsShow() == false then
--        g_GameMain.m_WndMainBag:ShowWnd(true)  
--    end
--    if g_GameMain.m_RoleStatus:IsShow() == false then
--        g_GameMain.m_RoleStatus:ShowPanel(true)  
--    end
--    g_GameMain.m_FixEquipWnd:SetFocus()
--    g_GameMain.m_RoleStatus:UpdataEquipTips()
--	g_GameMain.m_WndMainBag.m_ctItemRoom:UpdateBagTips()
--		local AutoCloseWnd = CAutoCloseWnd:new()
--		AutoCloseWnd:AutoCloseWnd(g_GameMain.m_FixEquipWnd)

	
	g_GameMain.m_NewFixEquipWnd.m_EquipInRoleCheckBtn:SetCheck(true)
	g_GameMain.m_NewFixEquipWnd.m_EquipInBagCheckBtn:SetCheck(false)
	if not g_GameMain.m_NewFixEquipWnd:IsShow() then	
		g_GameMain.m_CEquipInRoleWnd:SetData()
		g_GameMain.m_CEquipInBagWnd:SetData()
		g_GameMain.m_NewFixEquipWnd:ShowWnd(true)
	end
	if not g_GameMain.m_CEquipInRoleWnd:IsShow() then
		g_GameMain.m_CEquipInRoleWnd:ShowWnd(true)
	end
	g_GameMain.m_CEquipInBagWnd:ShowWnd(flase)
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_NewFixEquipWnd)
end

function CNpcDialogBox:ChallengeIntroduceFun(uParam1)
	CShowRulesWnd.GetWnd(nil,"��ս����")
end

function CNpcDialogBox:NationIntroduceFun(uParam1)
	CShowRulesWnd.GetWnd(nil,"��ս����")
end

function CNpcDialogBox:RescourseIntroduceFun(uParam1)
	CShowRulesWnd.GetWnd(nil,"��Դ��ȡ����")
end

function CNpcDialogBox:GivePointIntroduceFun(uParam1)
	CShowRulesWnd.GetWnd(nil,"������ȡ����")
end

function CNpcDialogBox:PkPointIntroduceFun(uParam1)
	CShowRulesWnd.GetWnd(nil,"��ɱ���ֽ���")
end


function CNpcDialogBox:BeComeYbFun(uParam1)
	if g_GameMain.m_MercenaryLevelTrace.m_IsCheckIn then
		local InfoWnd = g_GameMain.m_InformationWnd
		if InfoWnd:IsShow() then
			InfoWnd:ShowWnd(false)
		end
		g_GameMain.m_MercenaryDirWnd:InitWnd()
	end
end

function CNpcDialogBox:DingJiYbFun(uParam1)
	--Gac2Gas:DoMercenaryLevelAppraise(g_Conn)
end

function CNpcDialogBox:ReceivePowerYbFun(uParam1)
	--ShowMercenaryLevelAward()
end

function CNpcDialogBox:LingYuTransmitFun(uParam1)
	local Wnd = CLingYuTransmitWnd.GetWnd()
	Wnd:ShowLingYuTransmitWnd()
end
--
--function CNpcDialogBox:SpecialNpcFun(uParam1)
--	local Wnd = g_GameMain.m_SpecialNpcWnd
--	Wnd:InitWnd()
--end

function CNpcDialogBox:SpecialNpcFun(uParam1)
	local Wnd = g_GameMain.m_SpecialNpcWnd
	Wnd:InitWnd()
end

function CNpcDialogBox:UndergroudTeamList() 	 --���³Ǹ����Ŷ�
	g_GameMain.m_TeamListOneItem.state = 1
	g_GameMain.m_TeamListOneItem.m_Text2:SetWndText(GetStaticTextClient(26006))
	Gac2Gas:getAppTeamList(g_Conn,1)
	g_GameMain.m_TeamAppUnderList:ShowWnd(true)
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_TeamAppUnderList)
end

function CNpcDialogBox:ActionTeamList()   	  	--���˻�����б�
	g_GameMain.m_TeamListOneItem.state = 2
	g_GameMain.m_TeamListOneItem.m_Text2:SetWndText(GetStaticTextClient(26007))
	Gac2Gas:getAppTeamList(g_Conn,2)
	g_GameMain.m_TeamAppActList:ShowWnd(true)
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_TeamAppActList)
end

function CNpcDialogBox:TaskTeamList()						--	Ӷ���������б�
	g_GameMain.m_TeamListOneItem.state = 3
		g_GameMain.m_TeamListOneItem.m_Text2:SetWndText(GetStaticTextClient(26008))
		Gac2Gas:getAppTeamList(g_Conn,3)
	g_GameMain.m_TeamAppTaskList:ShowWnd(true)
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_TeamAppTaskList)
end

local function SetData(nItemCount)
	if nItemCount > 0 then
		g_GameMain.m_HandForage.m_ShowText:SetWndText(GetStaticTextClient(210000, nItemCount,nItemCount * 10)) 
	end
end

function CNpcDialogBox:HandForage(uParam1)
	local nItemCount = g_GameMain.m_BagSpaceMgr:GetItemCountBySpace(g_StoreRoomIndex.PlayerBag,1, "����ѫ��" )
	
	if (not g_GameMain.m_HandForage) then
		--gac_require "relation/tong/TongForageWnd"
		if nItemCount > 0 then
			g_GameMain.m_HandForage = CTongForageWnd.GetWnd(nItemCount, nItemCount * 10)
		end
	end
	if nItemCount > 0 then
		SetData(nItemCount)
	else
		MsgClient(9446)
		return
	end
	g_GameMain.m_HandForage:ShowWnd(true)
end

function CNpcDialogBox:BossBattleFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowBossBattleWnd(g_Conn, EntityID)
	end
end

function CNpcDialogBox:DragonCaveFun(uParam1)
	if g_MainPlayer and g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		Gac2Gas:ShowDragonCaveWnd(g_Conn, EntityID)
	end
end
--function CNpcDialogBox:IssueFetchFun(uParam1)
--	if (not g_GameMain.m_IssueFetchWnd) then
--		g_GameMain.m_IssueFetchWnd = CTongForageQueryWnd.CreateTongForageQuery(g_GameMain)
--	end
--	g_GameMain.m_IssueFetchWnd:ShowWnd(true)
--end

function CNpcDialogBox:IssueFetchFun(uParam1)
	if g_MainPlayer then
		Gac2Gas:IssueFetchQueryWnd(g_Conn)
	end
end

function CNpcDialogBox:DrinkShootFun(uParam1)
	if g_MainPlayer then
		Gac2Gas:DrinkShootGetReady(g_Conn)
	end
end

function CNpcDialogBox:GMCompenateFun(uParam1)
	g_GameMain.m_GmActivity:OpenWnd()
end

function CNpcDialogBox:OpenContractManuMarketWnd()
    CContractManufactureMarketWnd.OpenContractManufMarketWnd()
end

function CNpcDialogBox:OpenEquipRefine()
    CEquipRefine.OpenEquipRefineWnd()
end


function CNpcDialogBox:OpenEquipSuperaddWnd()
    CEquipSuperaddWnd.OpenSuperaddWnd()
end

function CNpcDialogBox:OpenNeedFireActivity()
	if g_MainPlayer.m_LockCenter.m_LockingObj then
		local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
		CTongNeedFireActivityWnd.CheckNeedFireIsOpen(EntityID)
	end
end

function CNpcDialogBox:OpenTongContributeMoneyExp()
	local tongId =g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	end
	Gac2Gas:GetTongContributeMoneyInfo(g_Conn,1)
end
function CNpcDialogBox:OpenTongContributeMoneySoul()
	local tongId =g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	end
	Gac2Gas:GetTongContributeMoneyInfo(g_Conn,2)
end
function CNpcDialogBox:OpenTongContributeMoneyResource()
	local tongId =g_MainPlayer.m_Properties:GetTongID()
	if(0 == tongId) then
		MsgClient(9401)
		return
	end
	Gac2Gas:GetTongContributeMoneyInfo(g_Conn,3)
end
