gas_require "multiserver/TransferDataInc"

--[[   �ַ�	˵��	   
i	��ʾ�з�������
I	��ʾ�޷�������
h	��ʾ�з��Ŷ�����
H	��ʾ�޷��Ŷ�����
c	��ʾ�з����ַ�����
C	��ʾ�޷����ַ���
f	��ʾ�����ȸ���
d	��ʾ˫���ȸ���
s	��ʾ����С��256���ַ���
S	��ʾ����С��65536���ַ���
b	��ʾ��������
--]]

local ProList = 
{ 
	{"CheckConnect","sIi"},
	{"RetCheckConnect","sIIi"},
	
  {"SendGlobalAnousment", "S"},
  {"SendSuccConn","I"},--ĳ���������ɹ���������һ��������ʱ�����Լ���serverID����ȥ
  {"ShutDownNotifyOtherServer","I"},
  {"NotifyDestServerChangeScene","IIIIbff"},
  {"RetSrcServerChangeScene","IIII"},
  {"SetUserName","s"},--Ҫ�´�����ɫ,֪ͨҪȥ���Ǹ�������(����Կ��)
  {"RetUserKey","ss"},--������ɫ���Ǹ�������,����Կ��
  
  {"GetDbCall","I"},
  {"LogoutForAdultCheck","I"},
  {"SendDataBegin","Is"},
  {"SendDataEnd","I"},
  {"SendTableEnd","I"},
  {"CancelDelaySaveTick","Id"},
  
  {"NotifyPlayerGetMsg","bCI"},
  {"GetCacheMsg","CId"},
  {"ClearCacheMsg","I"},
  {"UserTipSigal","si"},--ȥ�����ķ���������
  {"UserAutoLoginGame","I"}, 
  {"SendNpcChannelMsg", "sIsI"},
  {"SendPlayerChannelMsg", "IsISI"}, 
  {"InitTeamInfo", "III"},
  {"SendTeamMemberHPMP", "IIIIII"},
  {"ResetTeamMemberLevel", "I"},
  {"SendIBPayInfo", ""},
  {"SendMoneyExchangeInfo", ""},
  {"SendEratingAuditTick", ""},
  
  {"SetCharTongInfo", "III"},
  {"AddTongMember","IIIsIs"},
  {"DelTongMember","III"},
  {"SendTeachPropertyInfo", "I"},
  {"SendTongChannelMsg", "sIsIIS"},
  {"SendArmyChannelMsg","sIsIIS"},
--  {"CreateActionRoom","Is"},
  {"PlayerEnterActionScene","IIs"},
--  {"PlayerCancelAction","IIs"},
--  {"AddActionTeam", "sIII"},
  {"GetPkState", "II"},
  {"CheckAreaFbState", "IIIs"},
  {"SendResistanceValueToGac", "sII"},
  {"RetAreaFbState", "IsIIb"},
  {"KickOutOfCave", "I"},
  {"LeaveOutOfCave", "I"},
  {"DestroyDragon", "II"},
  {"DoSkillInPlayerSet", "IIsIs"},
    
  {"CreateRobScene", "Is"},
  {"UpdateRobResWin", ""},
  {"RetSendWarZoneState", "II"},
  
  {"GetRobResWinInfo", "IIssI"},
  {"ChangeByCancel", "II"},
  
  {"CheckJoinOreScene", "IIsI"},
  {"RetCheckJoinOreScene", "IIsI"},
  
  {"PlayerRetreatStation", "II"},
  {"SendTongMessage", "II"},
  {"UpdateCampExploit",""},
  {"CreateOreBossInScene", "IIsI"},
  {"SendOreBossMsg", "Isss"},
  {"PublicChatSendMsgDef","IsS"},
  {"ReturnSetCtrlType","III"},
  {"ResponseRequestJoinGroup","I"},
  {"ExchangeStation", "IIII"},
  {"CloseTongScene", "II"},
  {"NotifyPlayerLeaveFbScene","III"},
  
  {"RetSetMulExpActivity","s"},
  {"UpdataClosedAction","sbss"},
  {"DestroyNpcAppointByGM","s"},
  {"QuestNpcPosition","Is"},
  {"ReceiveQuestNpcPosition","CIS"},
  
  {"CreateScopesExplorationRoom","II"},
  {"RetCanTransFromTrap","I"},
  {"KickOffRole","s"},
  {"KickRole","I"},
  {"ShutUpRole","II"},
  {"CancelShutUpRole","IsI"},
  {"GMMoveRole","ssII"},
  {"GMSendWarning","sS"},
  {"GMSendMail","s"},
  {"SetPlayerExp","Is"},
  {"KickOffRoleForDelEquip","sIs"},
  {"SetServerType","I"},
  {"SetBuyCouponsAddress",""},
  {"UpdateJointSalesList",""},
  
	{"AgreeInviteJoinScene", "II"},
	{"InviteChangeScene", "IIIII"},
	
	{"FreeActionTime", "I"},
	{"SetAreaPlayerNum", "II"},
  {"RevertAreaPlayerNum",""},
  {"GMSetWarner","IIII"},
  {"SetJfsTeamNum", "I"},
  
  {"SendActionRollMsg","ss"},
  {"NotifyGasUpdate",""},
  
  {"SelectNeedAssign","IHIIs"},
  {"SelectAcutionAssign","IIbIs"},
	
  {"UpdataBossBattlePlayerTbl","sIIi"},
  {"BossBattleSendKillBossMsg","ssss"},
  {"GMBeginBossBattle",""},
  {"GMEndBossBattle",""},
  {"GMSetBossBattleMaxPlayer","I"},
  {"SendPkValueRollMsg","sI"},
  {"AddVarNumForTeamQuest", "IsI"},
  {"SendUpTongTypeMsg",  "s"},
  {"SetArmyCorpsInfoOnLeave", "IIs"},
  {"ReturnChangeGroupDeclare", "IS"},
  {"ReturnAddGroupMem","IsCIC"}, --Ⱥ��Ա��Ϣ ������--���ID,���name,���ְλ��ʶ(1:Ⱥ����2:����Ա(���ֻ������)��3:��ͨ��Ա),--�������ȺID,����ǲ�������(1--���ߣ�2--����)
	{"ReturnDisbandGroup","I"},   --��ɢȺ���� ������ȺID
	{"ReceiveMemberLeaveGroup","II"}, --�����޳��� ���������ID��ȺID
	{"LogCreatedPipe",""},
	
	{"SetRecruitMethod", "IIII"},

	{"SetAllServerWarTime", "III"},
	{"StartAllServerWar", "I"},
	{"StopAllServerWar", ""},
	{"SysPlayerBuffTbl","Is"},
	{"ClearPlayerBuffTbl","I"},
	{"InitNewPanel","I"},
}




--����ֻע��Gas2GacҪ�õ��������Ϣ�ĺ���(Gas2GacProList����ע��)
--��ʹ�õ� Gas2GacById�ĺ���Ҫ������ע��
CrossServerToGacList = 
{
	["TestFun"] = true,
	["SendNpcRpcMessage"] = true,
	["ChannelMessage"] = true,
	["PrivateChatReceiveMsg"] = true,
	["AreaPkOnMiddleMap"] = true,
	["RobResWinOnMiddleMap"] = true,
	
	["ReturnInviteMakeTeam"] = true,
	["ReturnAppJoinTeam"] = true,
	["UpdateAssignMode"] = true,
	["UpdateAuctionStandard"] = true,
	["UpdateAuctionBasePrice"] = true,
	["UpdateTeammateIcon"] = true,
	["StopSendTeammatePos"] = true,
	["StopSendTongmatePos"] = true,
	["HideLeavedTongmatePos"] = true,
	["HideLeavedTeammatePos"] = true,
	["ReturnGetTeamMemberBegin"] = true,
	["ReturnGetTeamMember"] = true,
	["ReturnGetTeamMemberEnd"] = true,
	["SendTeamMemberLevel"] = true,
	["NotifyOnline"] = true,
	["ReturnUpdateTeamMark"] = true,
	["ReturnUpdateTeamMarkEnd"] = true,
	["NotifyOffline"] = true,
	["CheckIsNeedSendTeammatePos"] = true,
	["CheckIsNeedSendTongmatePos"] = true,
	["SendTeammatePos"] = true,
	["SendTongmatePos"] = true,
	["RetAreaFbBossNum"] = true,
	["RetIsJoinAreaFb"] = true,
	["RetDelAllAreaFb"] = true,
	["RetIsJoinScopesFb"] = true,
	["RetIsJoinSenarioFb"] = true,
	["RetIsJoinMercenaryMonsterFb"] = true,
	
	["RetInsertFbActionToQueue"] = true,
	["RetIsJoinFbActionAffirm"] = true,
	["RetInFbActionPeopleNum"] = true,
	
	["RetShowTakeDareQuest"] = true,
	["ReturnLearnNewDirection"] = true,
	["ReturnLiveSkillExp"] = true,
	
	["AddBreakItemExp"] = true,
	["ReturnPosChanged"] = true,
	["RetDelItemFromGrid"] = true,
	["RetDelItemAllGMEnd"] = true,
	["ReturnBeOutOfTong"] = true,
	["ReseiveRecommendJoinTong"] = true,
	["ReseiveInviteJoinTong"] = true,
	["OnRequestJoinInTong"] = true,
	["ReseiveResponseBeInviteToTong"] = true,
	["ReturnJoinInTong"] = true,
	["RetDelQueueFbAction"] = true,
	["NotifyTeammateShareQuest"] = true,
	["ReturnProduceByTwoMaterials"] = true,
	["UpdatePlayerPoint"] = true,
	["RetChangeInfoWnd"] = true,
	
	
	["JoinAreaSceneMsgBox"] = true,
	["InviteJoinSceneMsgBox"] = true,
	["ReturnInviteToBeFriend"] = true,
	["ReturnAddFriendToClass"] = true,
	["ReturnBeDeleteByFriend"] = true,
	["ReturnSetCtrlType"] = true,
	["RecevieRequestJoinIntoFriendGroup"] = true,
	["ReturnGetAllFriendGroup"] = true,
	["ReturnGetAllFriendGroupEnd"] = true,
	["ReturnGetAllGroupMemInfo"] = true,
	["ReturnGetAllGroupMemInfoEnd"] = true,
	["ReturnRequestJoinIntoFriendGroupEnd"] = true,
	["PublicChatReceiveMsg"] = true,
	["ReceiveBeKickOutOfGroup"] = true,
	["ReceiveMemberLeaveGroup"] = true,
	["ReceiveInviteToGroup"] = true,
	["ReturnDisbandGroup"] = true,
	["ReturnChangeGroupDeclare"] = true,
	["ReturnLeaveGroup"] = true,
	["NotifyFriendOnline"] = true,
	["NotifyFriendGroupOnline"] = true,
	["NotifyFriendOffline"] = true,
	["NotifyFriendGroupOffline"] = true,
	
	["ReturnGetCompensateItemInfoBegin"] = true,
	["ReturnGetCompensateItemInfo"] = true,
	["ReturnGetCompensateItemInfoEnd"] = true,
	["ReturnActivationCodeCompensateItem"] = true,
	["ReturnTakeCompensateItem"] = true,
	["CreateWarTransprot"] = true,
	["CreateMatchGameWnd"] = true,
	["RetDelTicket"] = true,
	["RetGetTotalTicket"] = true,
	["SendUserGameID"] = true,
	["ReturnAddMoney"] = true,
	["ReturnAddBindingMoney"] = true,
	["RetItemMakerName"] = true,
	["ReturnAddBindingTicket"] = true,
	["ReturnAddTicket"] = true,
	["RetGiveUpQuest"] = true,
	["RetFinishQuest"] = true,
	["RetOreMapItemInfo"] = true,
	["SetItemGridWndState"] = true,
	["RetItemTypeInfo"] = true,
	["SetItemBindingTypeByID"] = true,
	["RetAddItemToGrid"] = true,
	["RetAddItemToGridEnd"] = true,
	["RetItemRoom"] = true,
	["RetAddItem"] = true,
	["RetAddItemToGridEndEx"] = true,
	["RetAddItemAllGMEnd"] = true,
	["RetSoulPearlItemInfo"] = true,
	["RetRefreshBag"] = true,
	["RetMoveItemByGridID"] = true,
	
	["RetDelItemError"] = true,
	["RetSplitItemEnd"] = true,
	["RetSplitItemError"] = true,
	["RetMoveItemEnd"] = true,
	["RetMoveItemError"] = true,
	["ReturnPlaceBag"] = true,
	["ReturnPlaceBagError"] = true,
	["RetReplaceItemByGridIDEnd"] = true,
	
	["ReturnSetBagState"] = true,
	["ReturnFetchBag"] = true,
	["ReturnFetchBagError"] = true,
	["ReturnDelBag"] = true,
	["ReturnDelBagError"] = true,
	["ReturnChange2Bag"] = true,
	["ReturnChange2BagError"] = true,
	["RetQuickMoveEnd"] = true,
	["RetQuickMoveError"] = true,
	["RetCleanBag"] = true,
	["ReturnBreakItemEnd"] = true,
	["ReceiveAntiIndulgenceExitGame"] = true,
	["ReturnBreakItemBegin"] = true,
	["ReturnBreakProducts"] = true,
	["RetItemLeftTime"] = true,
	["RetBoxitemOpened"] = true,
	["RetMailTextAttachmentInfo"] = true,
	["RetCommonBattleArrayBookInfo"] = true,
	["NoticePourIntensifyError"] = true,
	["NoticePourIntensifySuccess"] = true,
	["ReturnModifyPlayerSoulNum"] = true,
	["UpdateEquipIntensifyInfo"] = true,
	["NoticeIntensifySuccess"] = true,
	["NoticeAdvanceError"] = true,
	["RetActiveJingLingSkill"] = true,
	["RetActiveJingLingSkillPiece"] = true,
	["ReturnAddBindingMoney"] = true,
	["RetEquipDuraValueInBag"] = true,
	["RenewAllEquipEnd"] = true,
	["NoticeAdvanceSuccess"] = true,
	["AdvancedEquipReborn"] = true,
	["RetCommonWeaponInfo"] = true,
	["RetCommonArmorInfo"] = true,
	["RetCommonRingInfo"] = true,
	["RetCommonShieldInfo"] = true,
	["RetEquipIntensifyInfo"] = true,
	["ReturnChoosedTradeItem"] = true,
	["ReturnReplaceItem"] = true,
	["ReturnInviteeChoosedItem"] = true,
	["ReturnLockedTrade"] = true,
	["RetEquipAddAttrInfo"] = true,
	["RetEquipAdvanceInfo"] = true,
	["RetRenewEquipSuc"] = true,
	["RetEquipIntenBack"] =true,
	["ActionAllReady"] = true,
	["WaitOtherTeammate"] = true,
	["SetActionPanelWarnValue"] = true,

	["RetCloseCountScoreWnd"]	= true,
	["RetEquipEnactmentInfo"] = true,
	
	["AddItemMsgToConn"] = true,
	["ReturnFightingEvaluation"] = true,
	["ReturnCharInfo"] = true,
	["ShowTongMsg"]		= true,
	["TongTypeChanged"] = true,
	["OnInviteJoinArmyCorps"]	= true,
	["OnBeKickOutOfArmyCorps"] = true,
	["OnArmyCorpsPosChanged"] = true,
	
	["NotifyChangeAuctionPrice"] = true,
	["FinishAuction"] = true,
	["CloseNeedAssignWnd"] = true,
	["SendResistanceValue"] = true,
	["CreateRobTransprot"] = true,
	
	["ShowNewDirect"] = true,
	["RetShowWarZoneState"] = true,
	["EndSendWarZoneState"] = true,
	["UpdateDirectAwardInfo"] = true,
	["AddActionNum"] = true,
	["ReturnAddGroupMem"] = true,
	["ExitMatchGameSuccMsg"] = true,
	["RetEquipSuperaddRate"] = true,
	["RetUpdateEquipEffect"] = true,
	["RetAddFirewoodMsg"] = true,
	["RetNeedFireActivityEnd"] = true,
	["RetTongNeedFireActivityMsg"] = true,
	["ReturnProfferPoint"]	 = true,	
	["ReturnTeamProfferPoint"] = true,
	["RetCharLearnedTech"] = true,
	["ShowPanelByTongItem"] = true,
	
	["ReturnCampGetExploitSum"] = true,
	["ReturnTongWarAwardListInfoBegin"] = true,
	["ReturnTongWarAwardListInfo"]  = true,
	["ReturnTongWarAwardListInfoEnd"] = true
}

AddCheckLeakFilterObj(CrossServerToGacList)

local _, Gas2GacList = AliasDoFile("gac_gas", "framework/rpc/Gas2GacProList")
for _, v in pairs(g_MessageFunTbl) do
	CrossServerToGacList[v[1]] = true
end

for _, v in pairs(g_FriendMsgToClientFunTbl) do
	CrossServerToGacList[v[1]] = true
end

for funName in pairs(Db2GacFunList) do
	CrossServerToGacList["_Db2"..funName] = true
end

for i, v in pairs(Gas2GacList) do
	if CrossServerToGacList[v[1]] then
		table.insert(ProList, {v[1], "ICd" .. v[2]})
	end
end



--���巢�����ݶԵ�rpc����

local TypeSignTbl = {
	["number"] = "d",
	["string"] = "s",
	["lstring"] = "S",
	["boolean"] = "b",
	["table"] = "",
}
for keyType, v in pairs(g_PairRpcDef) do
	for valueType, funName in pairs(v) do
		table.insert(ProList, {funName, "I" .. TypeSignTbl[keyType] ..  TypeSignTbl[valueType]})
	end
end


return ProList
