 
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

return "Gac2Gas",
{
	{ "ByteCall","cc"},
	{ "SetLockingNPCID","I"},

-- Զ�̱�����ȡ ���RPC
	{ "Remote_MS_GetValue",		"S" },
	{ "Remote_MS_GetValues",	"S" },
	{ "Remote_MS_GetType",		"S" },
	{ "Remote_CB_GetValue",		"S" },
	{ "Remote_CB_GetType",		"S" }, 
	{ "Remote_ResumeResult",	"S" },
-- ��½���RPC
	{ "CheckUser",				"sssssss" },
	{"CheckTrusteeUser", "sssss"},
	{ "Get_Char_List",			"" },
	{ "Get_DeletedChar_List",			"" },
	{ "CreateAccount", "s"},
	{	"UserForceTipSigal","s"},
	{"LoginWaitingQueue",""},
	{"CancelLoginWaiting",""},
-- ������ɫ 		
	{ "GetCampServerIpInfo",	"I"},
	{ "CreateRole",				"sHHHHHHHII"}, -- strName, nHair,nHairColor,nFace,nScale,nSex,nClass,campInfo,m_nInherence,xpos,ypos
	{ "DelChar",				"I" },
	{ "CompleteDeleteChar",		"I" },
	{ "GetBackRole",			"S" },
	{ "PreChangePlayerName",			"I" },
	{ "CharEnterGame",			"II" },
	{ "DestroyPlayer",			""  },
	{ "CharEnterOtherServer",	"IsS"},
	--{ "CompleteDeleteChar",		"I" },
	{"ChangePlayerName",		"Is"},
	
	--��ֵ�һ�
	{"ChangeTicketToMoney",		"I"},
	{"GetTotalTicket",		""},
	{"GetCompensateItemInfo",		"I"},
	{"GetActivationCodeCompenateItem",		""},
	{"TakeCompensateItem",		"IsI"},
	{"TakeActivationCodeCompensate",		"I"},
-- Agreement
	{ "SetUserAgreement", 		""},
	
-- npc for test
	{ "AddNpcForTest", 			"III"},
	
-- ��ɫ״̬�������ͷ�		
	{ "AttackMe",				"IsI"},
	{ "ChangeGridPos",  "Iii"},
	{ "UnLockObj",				""},
	{ "UnLockIntObj",				""},
	{ "ActiveBehavior",		""},
	{	"ActiveBehaviorDoSkill","Isff"},
	{ "QuitFitoutState",	""},
	{ "BeginKickBehavior",""},
	{ "EndKickBehavior","II"},
	{ "CancelKickBehavior",""},
--	{ "AdjustBulletTime",		"Cf"	},  -- BulletId, AdjustTime )
--Player �������
	{ "AddTalentSkill", 			"sI"	},
	{ "UpdateFightSkill",		"sCC"},
	{ "GoBackOrStay",			"b"		},
	{ "GoLastMasterSceneReborn",""},
	{ "StationReborn",		""		},
	{ "ExitOrInMode",		"b"},
	{ "GoIntoFbOrStay",	"b"},
	{ "DoReborn",	""},
	{ "AreaFbRebornToRePoint",	""},
	{ "MatchGameJoinPointReborn",	""},
	
	{	"RequestSkillSeries", ""}, --����������Ϣ
	{	"SetSeries",					"I"}, --�����츳ϵ
	{	"SetSkillNode",				"I"}, -- ���ü��ܽ��
	
-- ϴ�츳
	{"ClearAllGenius",          ""      },
-- �洢�����
	{ "SaveShortCut", 			"CCsII" }, 		--pos, type, arg1, arg2, arg3
	{ "SaveShortCutEnd",        ""},
	
--�ٻ�����������
	{"RequestSetServantName",	"Iss"},
	
--NPC���� ����
	{"GetNpcDirection","I"},
--�����ӵ�ħ��
	{ "StartBulletMagicTest", "" },
	{ "ShutDownBulletMagicTest", "" },	

-- ��Ʒ�ռ����
	{"BreakItem",		"CC"},
	{"DelWithTimeOutItem",		"dHs"},
	{ "OnUseDelItemByPos",		 	"CCH" },   --nRoomIndex,nPos,nCount
	{ "OnLButtonUpDelItemByPos",	"CCH" },   --nRoomIndex,nPos,nCount
	{ "SplitItem",       		"CCCCH" }, 	--nARoom,nAPos,nBRoom,nBPos,nACount
	{ "MoveItem",        		"CCCC" },  	--nARoom,nAPos,nBRoom,nBPos
	{ "PlaceBag", 			 	"CCC"},   	--nRoom,nPos,nSlot
	{ "FetchBag", 			 	"CCC"},   	--nSlot,nRoom,nPos
	{ "Change2Bag", 			"CC"},   			--nASlotRoom,nASlot,nBSlotRoom,nBSlot
	{ "CleanBag",					"C"},    --�������
	{ "DelBag", 				"C"},   			 	--nSlot
	{ "QuickMove",  			"CCC"}, 	 		--nARoom,nAPos,nStoreMain
	{ "SaveMoneyToDepot", 			"d"},
	{ "GetMoneyFromDepot", 			"d"},
	{ "GetDepotInfo", 			""},
	{	"UseItem", 				"CCHsI"},	 	--nRoomIndex,nPos,nBigID,Index,eEquipPart
	{	"UseItemEnd", 		"s"},	 			
	{ "FetchEquipByPart",		"CCC"}, 		--eEquipPart,nRoomIndex,nPos
	{"RClickFetchEquipByPart","C"},
	{ "SwitchTwoRing", 			""},     		--�������ҽ�ָ
	{ "SwitchWeapon", 			""},     		--�������ֺ͸�������
	{	"DelEquip"     , 		"C"},			--ֱ�Ӵ�������ɾ��װ��
	{ "FortifiedEquip", 		"CIdCICICI"},	--ǿ��װ��
	{"DelQuestItemByPos","sCCH"},--ɾ��������߾ͻ�ɾ������
-- ��ʾ��Ϣ���� ���RPC
	{ "TestMessage", 			"C" },
	
-- GM Command ���RPC
	{ "GM_Execute",				"S" },
	{ "GM_RunScript",			"S" },
	{ "GM_OpenConsole",			"" },
--Gm Player ���RPC
	{ "SetGridPos", 			"ii"},			--������ҵĸ�������
	
--���ϵͳ���
	{ "InviteMakeTeam", 		"I"		},	--����id�������
	{ "InviteMakeTeamByName", 		"s"		},	--���������������
	{ "RespondInvite", 			"Isb"	},	--��Ӧ����
	{ "RespondApp",				"Isb"	},	--��Ӧ����
	{ "BreakTeam", 				""		},	--��ɢ����
	{ "SetCaptain", 			"I"		},	--���öӳ�
	{ "LeaveTeam", 				""		},	--�뿪����
	{ "SetAssignMode", 			"H"		},	--���÷��䷽ʽ
	{ "GetTeamMembers", 		""		},	--��øö���Ķ�Ա
	{ "GetTeammateProp", 		"I"		},	--��ȡ���ѵ�����
	{ "RemoveTeamMember",		"I"		},	--�߳�����
	{ "SetAuctionStandard",		"I"		},	--�����������䷽ʽ������Ʒ�ʱ�׼
	{ "SetAuctionBasePrice",		"I"		},	--�����������䷽ʽ�������׼�
	{ "OnLeftClickTeammateIcon","I"		},	--����������ͷ��ѡ�ж���
	{ "UpdateTeamMark",			"III"	},	--С�ӱ��,������������ͣ��������ͣ�����id
	
--�������
	{"getAppTeamList","I"}, 				--nType  �Ŷ�����	
	{"leaveList","I"},							--nType
	{"joinTeamList","Is"},          --nType,sMsg
	{"upFreshTeamList","I"},				--nType
--��Ⱥϵͳ
	{"AddFriendClass",	"s"},					--��Ӻ������
	{"SearchPlayerAccurately","sI"}, 	--��ȷ���Һ��� ����������name������ID
	{"AddFriendToClass","Is"},          --��Ӻ��ѵ��������� ���������ID,������
	{"PrivateChatSendMsg","IS"},  --˽�� ������Ҫ�ĵĶ���ID����������
	{"RespondAddFriend", 	"III"}, --��Ӧ��Ӻ��� ���� ����Լ�Ϊ���ѵ����ID������Լ�Ϊ���ѵ������ID���Լ�����ID
	{"DeleteMyFriend","I"},        --ɾ������ ������Ҫɾ�����ѵ�ID 
	{"UpdateFriendClassName","Is"},  --�޸ĺ��������� ������������ID��������
	{"DeleteBlackListMember","I"},   --ɾ�����Ѻ���������ĺ��� ������Ҫɾ���ĺ���ID
	{"MoveToBlackList","I"},    --��Ӻ��ѵ����������� ������Ҫ��ӵĺ���ID
	{"AddBlackListByName","s"}, --ͨ�����name����Ҽ��뵽���������� ������Ҫ��ӵ����name
	{"ChangeToClass","II"},   --�������ƶ������������ ����������ID������ID
	{"DeleteFriendClass","I"}, --ɾ�������� ������Ҫɾ������ID
	{"CreateFriendGroup","sIsS"},  --��������Ⱥ ������Ⱥ����,Ⱥ���Ⱥ�ؼ���,Ⱥ����
	{"SearchGroupAccurately","sI"}, --��ȷ����Ⱥ ����:Ⱥname��ȺID
	{"RequestJoinIntoFriendGroup","I"}, --�������Ⱥ ������ȺID
	{"ResponseRequestJoinGroup","III"}, --ͬ�������߼���Ⱥ ������������ID��ȺID
	{"PublicChatSendMsg","IS"},    --Ⱥ�� ������ȺID����������
	{"InviteToGroup","II"},    --�������Ⱥ ��������������ID,ȺID
	{"ResponseInviteToGroup","III"},  --��Ӧ�������Ⱥ ������ȺID
	{"LeaveGroup","I"},   --�˳�Ⱥ ������ȺID
	{"DisbandGroup","I"}, --��ɢȺ ������ȺID
	{"SetCtrlType","III"},  --����/ȡ������Ա ���������ID��ȺID��Ҫ���õ���� 2-���ù���Ա��3-ȡ������Ա
	{"KickOutOfGroup","II"}, --�޳���� ���������ID��ȺID
	{"RenameFriendClass","Iss"}, --�޸ĺ��������� ��������ID,�����name,ԭ�ȵ�����
	{"ChangeShowSentence","s"},		--�޸�������� �������¼���
	{"SaveAssociationPersonalInfo","CssCCCCs"}, --���������Ϣ
	{"GetAssociationPersonalInfo",""}, -- �鿴������Ϣ
	{"GetAssociationMemberInfo","I"}, -- �鿴�����Ϣ ���������ID
	{"SearchPlayerCondition","IIIIs"}, --�������Һ��� ������ְҵ���Ա���͵ȼ�����ߵȼ������ڵ�ͼ
	{"SearchGroupCondition","sI"}, --�������Һ���Ⱥ �������ؼ��֣�����
	{"GetMemberIdbyNameForPrivateChat", "sS"}, --ͨ���Է����ֿ�ʼ˽��(����ID) �������Է�����, ��������
	{"CofcChatSendMsg","S"}, -- �̻�Ⱥ�� ��������������
	{"AddFriendToClassByName","sI"}, --ͨ���������������Ϊ�Լ����� ���������name��������Id
	{"ChangeGroupDeclare", "IS"},
	{"RefuseBeAddFriend","I"},			--�ܾ���������
	{"UpdateFriendInfo", "I"},			--ˢ��ָ��������Ϣ
	{"UpdateOnlineFriendInfo", ""},		--ˢ�����ߺ�����Ϣ
	{"RefuseGroupMsgOrNot","II"},--����/����Ⱥ��Ϣ
	{"GetTongProfferCount", ""}, --��ѯ��ǰ�Ź��׻�����Ŀ
	{"GetTongLevel", ""}, --��ѯ�ŵȼ�
	{"LearnTongTech", "s"},--ѧϰӶ��С�ӿƼ�

--����ӳ��
	{"SetKeyMap", 					"ssIb"},	--��Ӱ���ӳ�� (����Ϊ��������, ��������, ��һ���ǵڶ�λ��)
	{"GetAllKeyMaps", 				""},		--��ȡ���а���ӳ�� 
	{"ChangeMouseCtrl", 			"IIIIIII"},	--�޸�������û�Tabɸѡ����
	{"ChangeMouseCtrlBeforeGame",	"ICb"},		--������Ϸ֮ǰ�����������
	
--�������
	--[[ �����Ķ������£�
		SUBSCRIBE = 1,
		UN_SUBSCRIBE = 0
	--]]
	{"SetChannelPanel",			"III"},		--������������Ƶ�� (Ƶ��id�� ����orȡ�����ģ����λ��)
	{"SetChannelPanelEnd",			""},	
	{"SetDefaultChannelPanel", 	""},		--����ΪĬ����Ϣ
	{"RenamePanel", 			"sI"},		--���������, 
	{"AddPanel",				"SI"},		--������
	{"DeletePanel", 			"SI"},		--ɾ�����
	{"SetPanel",				"SI"},		--�������
	{"TalkToChannel",			"SI"},		--��ĳƵ��˵����sΪ��Ϣ���ݣ�IΪƵ��id
	{"MovePosB2PosA",		"II"},			--��λ��B�Ƶ�λ��A������Ϊ��Aλ�ã�Bλ�ã�
	{"GetInfoByID",         "d"},   		--ͨ��ID�õ����������Ϣ
	{"SaveNotShowMsgWnd","s"},
	
--��ȡ��������ʱ
	{"GetDelayTime",			""}, 	--��ȡ��������ʱ
	
--������� 
	{"GiveUpQuest",				"s"},	--�������� �������������ƣ�
--	{"GetQuestState",			"s"}, --��ȡ����״̬ �������������ƣ�
--	{"GetQuestVar",				"ss"},--��ȡĳ������������ �������������ƣ�����������ƣ�
--	{"GetAllQuestVar",		"s"},	--��ȡĳ���������������� �������������ƣ�
--	{"GetAllQuest",				""},	--��ȡ��ɫ���д�������ݿ��������Ϣ
	{"AcceptQuest",			"sI"},		--�������񣬲���(�������ƣ�GlobalID)
	{"RequestQuestByItem", "s"},  --��������(��Ʒ��������)�� ����(��������)
	{"AcceptQuestJoinFb","ss"},--������Ա��ȡ���������
	{"FinishQuest",			"sII"},		--������񣬲���(�������ƣ�ѡ�еĿ�ѡ������������GlobalID��
	{"ShowTakeQuestWnd", "sI"},			--��ʾ������ȡ��壬�������������ƣ�GlobalID��
	{"ShowFinishQuestWnd", "sI"},     --��ʾ���������壬�������������ƣ�GlobalID��
	{"ShareQuest","s"},
	{"ResponseShareQuest","Is"},  --��������Ķ���ID��������
	{"SetQuestFailure","s"},	--����ʧ�ܷ�����Ϣ
	{"SetQuestIsLimitTime","s"},--������ʱ����,������ʱ
	{"SetQuestLevelVarNum","ss"},--�ȼ����������(������ʱ,��ҵȼ����˾ͼӼ���)
--�������С��Ϸ()
	{"SmallGameSucceed", "sI"},	--С��Ϸ�ɹ����
	{"SmallGameFaild", "s"},		--С��Ϸʧ��
	{"SmallGameCancel","sI"},		--ȡ��С��Ϸ
	{"ExitSmallGame","sI"},--�ƶ������Ǳ����˳�
	{"AgreeBeginSmallGame","sI"},--�Ƿ�ͬ�⿪��С��Ϸ

--Ӷ���ȼ�ָ��	
	{"SetCheckInMercenaryInfo",""},
	{"CreateMercenaryLevel",""},
	{"MercenaryLevelUp",""},
	{"DoMercenaryLevelAppraise",""},
	{"GetMercenaryLevelAward","b"},
	{"SetMercenaryLevelAward","s"},
--npc

	{"ClickNpc", "I"},			--����Npc��Ϊ
	{"ShowQuestNpcTalkWnd", "I"},	  --npc�Ի���
	{"ClickItem","IsCC"},
	--{"ShowTakeQuestObjTalkWnd","I"},
	{"ShowNpcDropItemWnd","I"},
	{"CancelGetDropItems","I"},
	{"SelectAllDropItems","I"},
	{"SelectSingleGridDropItem","II"},
	{"SubmitAuctionPrice","I"},
	{"SubmitAuctionStandard","I"},
	{"PlayerCancelAuction",""},
	
	{"AddFinishNpcTalk","sIb"},--npc�����Ի��Ӽ�¼
	{"GetNpcTalkHeadInfo", "I"},
	
	-------------------------------------
	--DPS��Ϣ�ӿ�
	{"BeginSendFbDpsInfo",""},
	{"EndSendFbDpsInfo",""},
	{"GetBossDpsInfo",""},
	{"ChangeDpsShowType","s"},
	
	--����ͳһ�ӿ�
	{"EnterFbSceneFromWnd","s"},
	{"CancelFbAction","s"},
	{"AgreeJoinFbAction","s"},
	{"NotJoinFbAction","s"},
	{"AutoJoinActio", "IIs"},
	--����ɱ
	{"JoinDaTaoSha",""},
	{"ShowDaTaoShaWnd","I"},
	{"ExitDTSFbAction",""},
	--������
	{"JoinJiFenSai","I"},
	{"ShowJiFenSaiWnd","I"},
	{"ExitJFSFbAction",""},
	{"ShowJiFenSaiInfoWnd","I"},
	--������ᱦ
	{"JoinDaDuoBao","I"},
	{"ShowDaDuoBaoWnd","I"},
	{"ShowDrinkWnd","I"},
	{"HaveDrink","S"},
	{"GetTiredNess", "S"},
	{"IsDrunk", ""},
	--Ӷ��ѵ���
	{"JoinYbEducateAction","s"},
	{"ShowYbEducateActionWnd","I"},
	{"ContinueYbXlAction","b"},
	{"BeginYbEducateAction",""},
	
	--Ӷ����ˢ�ֱ�
	{"ShowMercenaryMonsterFbWnd","I"},
	{"EnterGeneralMercenaryMonsterFb",""},
	{"AgreedJoinMercenaryMonsterFb","sI"},	
	--{"OpenSignQueryWnd",""},	
	{"OpenAutoSeekWnd",""},	
	{"FbStationAutoSeekInfo",""},
	{"JoinRobResFb",""},	
	{"JudgeWarTransport","s"},	
	{"GetProffer",""},	
	{"PlayerExitFb",""},
	{"CloseActionWnd",""},
	{"GoRobResRebormPlaceStay","b"},
	{"GetForageAutoInfo",""},
	{"IssueTongInfo",""},
	{"IssueFetchQueryWnd",""},
	{"RetIssueFetchWnd", ""},
	{"PlayerOutFb", ""},
	
	--������Դ��
	{"CancelSign", ""},
	{"ShowCancelWnd", ""},
	{"EnterRobScene", "b"},
	{"OpenSignQueryWnd", ""},
	{"ConfirmJoin",""},						
	{"GetHeaderAward",""},
	
	--Boss����ս
	{"ShowBossBattleWnd","I"},
	{"CanJoinBossBattle",""},
	{"CancelJoinBossBattle",""},
	{"EnterBossBattle","Is"},
	{"TimeOverLeaveBossBattle",""},
	
	--�Ⱦ��������
	{"DrinkShootGetReady",""},
	{"DrinkShootNextPlayer",""},
	{"DrinkShootDoAction","s"},
	{"DrinkShootDoSkill","sII"},
	
	--�Ե粨С��Ϸ
	{"HeadGameChangeAction","s"},
	{"HeadGameChangeActionBag","s"},
	
	--Npc�Ի����
	{"RemitSpecScene","Is"},
	{"RenoSpecNpc","Is"},
	{"GetPicInfo","I"},
	{"IsCanTransport","IsIb"},
	{"RetTransInfo","sII"},
	----------------------------------------
	--��Ѩ�
	{"ShowDragonCaveWnd", "I"},
	{"EnterDragonCave", "s"},
	{"IntoDragonCave","s"},
	{"LeaveDragonCave", ""},
	---------------���򸱱�
	{"ShowAreaFbSelWnd","I"},
	{"EnterGeneralAreaFb","Is"},
	{"EnterSpecialAreaFb","Is"},
	{"AgreedJoinAreaFb","sII"},
	{"DecideJoinAreaFb","sII"},
	{"AgreedChangeOut",""},
	{"ReferAreaFbQuest","s"},
	{"GetDungeonCount", ""},
	
	--��ս����ĸ���
	{"AgreedJoinDareFb","ss"},
	
	--���򸱱�
	{"EnterScopesFb","s"},
	{"AgreedJoinScopesFb","sII"},
	
	--���鸱��
	{"ShowJuQingWnd","I"},
	{"EnterSenarioFb","sb"},
	{"AgreedJoinSenarioFb","sII"},
	{"CancelChangeCameraPos",""},
	
	--������˹������򸱱�
	{"PublicAreaInvite", "I"},			
	
	-------------���Ϣ���
	{"GetActionCount",""},
	{"GetActionCountEx",""},
	
	-------------����������Ϸ
	{"ShowMatchGameSelWnd", "I"},
	{"JoinMatchGame", "sb"},
	{"UseFbItem","sss"},
	{"UseFbSecItem","ssI"},
	
	
	-------------���ս���
	--{"ShowWarZoneSelWnd", "I"},
	{"EnterWarZone", "Is"},
	{"UpdateBuildingLevel", "I"},
	{"EnterZone", "I"},
	{"DeleteHandForage", ""},
	
	
	--�󶴸���
	{"JoinOreScene","IIs"},
	{"JoinOreNextScene",""},
	{"TeamJoinScene","IIsI"},
	{"CreateAreaScene","s"},
	{"LeaveAreaScene",""},
	{"SendInviteJoinSceneMsg","I"},
	{"InviteChangeScene","IIsIs"},
	-----------------
	
--��������
	{"ShowQuestObjTalkWnd","I"},--��������GlobalID
	{"ObjShowContentWnd","I"},--��������GlobalID
	{"ShowCollObjWnd","I"},--��������GlobalID
	{"SelectSingleGridItem","II"},--��Ʒ���ŵĸ��Ӻţ���������GlobalID
	{"SelectAllGridItems","I"},----��������GlobalID
	{"SendSuccPerfetColl","I"},----��������GlobalID
	{"CancelCollItems","I"},--��������GlobalID
	{"RequestShowAnimation","I"},
	{"ShowAnimationEnd","I"},
	{"ShowCollItems","I"},
	{"OnSelectIntObj","I"},  --֪ͨ�������˱��������IntObj
	{"OnLClickIntObj","I"},   --�����������������Ӧ����������GlobalID
	{"ResponseCallRequest","sb"}, --�ٻ������֣��Ƿ�����ٻ�
	{"BreakPlayerActionLoading",""},

--�ʼ�ϵͳ
	--��ͨ�ʼ�
	{"CheckMailTextAttachment", "II"},		--�������Ҽ��ʼ��ı��������鿴�ż������Ǹ����������ı������ڰ������nRoomIndex��nPos
	{"RightButtonClickMailBox","I"},
	{"GetMail",				"I"},			--��ȡ�ʼ����ݣ��������ʼ�ID��
	{"GetMailList",			""},			--��ȡ�ʼ��б�
	{"SendMail",			"ssSII"},	--�����ʼ����ռ������ƣ��ʼ����⣬�ʼ����ݣ�Ǯ����Ŀ��
	{"GetSendMoneyCess", "I"},
	{"SendMailGoodsEnd", ""},           --�������
	{"TakeAtachment",		"I"},		--��ȡ�������ʼ�ID����Ʒ����)
	{"DeleteMail",			"I"},	   	--ɾ���ʼ����ʼ�ID��
	{"SendMailGoods",       "II" },	--�����ʼ�����Ʒ���֣���������ƷID���ʼ���Ʒ���ĸ��Ӻ�grid
	{"TakeContextAtachment",        "I"},--��ȡ�ı��������������ʼ�ID
	{"TakeAttackmentByIndex",   "II"},--�ռ�����ȡ�������ӵ���Ʒ���������ʼ�ID�����Ӻ�
	{"GetMailMoney",           "I"},--�ռ�����ȡ��Ǯ���������ʼ�ID
	{"TakeAttachment",        "I"},--�ռ�����ȡȫ�����ӵ���Ʒ���������ʼ�ID
	{"DeleteBatchMailBegin", ""},
	{"DeleteBatchMail","I"},--������ɾ���ʼ���ʼ��������mailID
	{"DeleteBatchMailEnd",""},	--������ɾ���ʼ�����,��������ͨ�ʼ���1����ϵͳ�ʼ���2��
	
--Npc Shop
	{"BuyItem", 		"sssII" },		--������Ʒ, ������Npc�������ͣ���Ʒ���ƣ�����, �󶨻��߲��󶨵�Ǯtype
	{"BuyItemByPos", 	"sssIIII"},		--������Ʒ��ĳ���ӣ�Npc�������ͣ���Ʒ���ƣ�������RoomIndex������pos, �󶨻��߲��󶨵�Ǯtype
	{"BuyBackItem", 	"sI"},			--������Ʒ��������Npc���ƣ�����
	{"BuyBackAllItem", 	"s"},			--����������Ʒ, ������Npc����
	{"PlayerSellItemByPos", 	"siII"},--��������������Npc���ƣ�RoomIndex��Pos������
	{"PlayerSoldGoodsList", 	"s"},		--������Ʒ�б�,������npcName
	
	--����Ƕ��ʯ	
	{"SendSynthesisItem","d"} ,			--���ͺϳ�����Ĵ�ײ��ϻ�ʯ����������ײ��ϻ�ʯID
	{"SendSynthesisItemEnd",""} ,		--���ͺϳ�����Ĵ�ײ��ϻ�ʯ����
	{"RequestOpenHole","IIId"},		--�����ף�����������Panel,��λ��Depart,�׺�Slot,��ײ���ItemID
	{"RequestInlayStone","IIId"},		--������Ƕ������������Panel,��λ��Depart,�׺�Slot,��ʯStoneId
	{"RequestRemovalStone","III"},		--ժ���Ѿ���Ƕ�ı�ʯ������������Panel,��λ��Depart,�׺�Slot
	{"SendSynthesisItemBegin",""},		--���ͺϳ�����Ĵ�ײ��ϻ�ʯ��ʼ
	{"RequestStoneAppraiseAgain",""},	--����ױ�ʯ�ٴμ���
	{"TakeAppraisedStone",""},		--��ȡ�������ɵı�ʯ
	{"ChangeFrame","II"},				--�������
 --��ҽ���
	{"SendTradeInvitation","I"},     --����������������ͽ������룬�������Է�ID
	{"DenyedTrade","I"},             --��Ҿܾ��˽��ף��������Է�ID
	{"AgreeToTrade","I"},            --���ױ������߽����˽������󣬶Է�ID
	{"ChoosedTradeItem","IiIId"},     --���ѡ���˽��׵���Ʒ���������Է�ID��nRoomIndex��pos���ڰ����е�λ�ã���Ӧ��nRoomIndex������Ʒ��Ŀ, ��Ʒid
	{"CancelChoosedItem","II"},      --���ȡ���˽��׵���Ʒ���������Է�ID����Ʒ�ڽ������е�λ��
	{"ReplaceItem","IIiIId"},         --����滻�˽��׵���Ʒ���������Է�ID����Ʒ�ڽ������е�λ�ã�nRoomIndex���ڰ����е�λ�ã���Ӧ��nRoomIndex������Ʒ��Ŀ, ��Ʒid
	{"ChoosedTradeMoney","Id"},      --��������˽��׵Ľ����Ŀ���������Է�ID�������Ŀ
	{"HaveLockedTrade","I"},         --��������˽��ף��������Է�ID
	{"CanceledTrade","I"},           --���ȡ���˽��ף��������Է�ID  
	{"SubmitedTrade","I"},           --����ύ�˽��ף��������Է�ID
	{"GetTradeCess","I"},          
	{"SenTradeInvitationByPlayerName", "s"},--����������������ͽ������룬�������Է�����
	
	{"GetPlayersTradeRequestList", ""},	--������ʾ��ҽ�������		
	{"DenyAllPlayersTradeRequest", ""},	--�ܾ����н�������
	
	--װ����������Ĺ���	
	{"PourUpgradeSoul","dI"},		 --װ����ID,ע������
	--װ����ǿ����Ĺ���
	{"PourIntensifySoul","dI"},		 --װ����ID��ע������
	--װ��ǿ��
	{"IntensifyEquip",		"dI"},	--ǿ��װ����������װ��id
	{"EquipIntensifyUseStone", "dIII"}, --��װ��ǿ��ʯǿ����װ����������
	--װ������
	{"ArmorOrJewelryIdentify","IIssfIIIId"},--���߼��� ����:���߻���ֵ������id��װ�����ƣ������ֶΣ�����ֵ,
	{"WeaponIdentify","IIssfIIIIdI"},--װ������ ������
	--����Ƭ�趨
	{"ArmorPieceEnactment","IsIIIIdIIs"},
	--װ������
	{"UpgradeEquip","dI"},            --װ����ID
	
	{"PourPearl2Equip", "II"},				--������������ע��װ�� ������װ��ID������ID
	
	--���۽�����
	{"CSMBuyOrder",    "I"},					--���򶩵���Ʒ�� ����������ID
	{"CSMSearchBuyOrder",   "IIIsIIiII" },	--��ѯ�����б���������Ʒ���ͣ���Ʒ���ƣ���ʼ�ȼ�����ֹ�ȼ�������ʽ��ҳ��
	{"CSMSearchSellOrder",   "sIIIIIIiIiib" },	--��ѯ�����б���������Ʒ���ƣ���ʼ�ȼ�����ֹ�ȼ����Ƿ���ã�����ʽ��ҳ����1-��Ʒ��2-��װ��ս��ħ��
	{"CSMGetOrderByItemType","IIsIIIIIIiIiib"},	--ͬ�ϣ����ϱ߶�������������壬��Ʒ���
	{"CSMGetOrderByItemAttr","IIsssssIIIIIIiIiib"},--ͬ�ϣ������Ҳ�������壬���������� parentNodeText������������ ����������
	{"CSMGetOrderBySomeItemType","IIsIIIIIIiIiib"},--��ѯ�����б���������壬 ĳ������Ʒ�Ĵ������֣�ĳһ���ִ�������ļ�����Ʒ��,��Ʒ���ƣ���ʼ�ȼ�����ֹ�ȼ����Ƿ���ã�����ʽ��ҳ��
	{"CSMGetOrderByExactItemAttr","IIIsIIIIIIiIiib"},--��ѯ�����б���������壬��Ʒ���ͣ�����������������ĳ������,��Ʒ���ƣ���ʼ�ȼ�����ֹ�ȼ����Ƿ���ã�����ʽ��ҳ��
	{"CSMSearchCharBuyOrder",   "" },		--��Ҳ�ѯ���˹����б�
	{"CSMSearchCharSellOrder",   "II"},		--��Ҳ�ѯ���˳����������������ʽ��ҳ��
	{"CSMAddBuyOrder",   "sIdI" },						--�������չ���������������Ʒ������Ŀ���۸�ʱ��
	{"CSMAddSellOrder",   "iIIdIb"},						--�����ӳ��۶�����������RoomIndex��pos����Ŀ���۸�ʱ��,�Ƿ񼤻��ס�۸��ܣ�true��false��
	{"CSMCancelBuyOrder",   "I" },					--���ȡ���չ�����������������ID
	{"CSMCancelSellOrder",   "I"},					--���ȡ�����۶���������������ID
	{"CSMTakeAttachment",    "I"},					--�����ȡ������ ����������ID
	{"CSMSellGoods2Order",       "IiI"},					--֧������,����������ID��RoomIndex��pos
	{"CSMFastSearchBuyOrderItem",       ""},					--֧������,����������ID��RoomIndex��pos
	{"GetCSMRememberPrice",	"Iss"},					--�õ�����ϴγ���ĳ����Ʒ�ļ۸񣬲���:���no����Ʒ���ͣ���Ʒ����
	{"CSMGetOrderBySeveralSortItem", "IIIsIIIIIIiIiib"},
	{"CSMGetTopPriceBuyOrderByItemName","s"},
	{"CSMGetAveragePriceByItemName","s"},
	{"SetMoneyType",       "I"},	  --���ð��������ѡ�еĻ�������
	
	--���а�
	{"GetSortList", "ssC"},
	
--���ϵͳ------------------------------------------------------------------------------------------------
	{"EnterTongArea", "I"},				--�����ḱ��
	{"LeaveTongArea", "I"},		--��ḱ�����ʹ�
	{"EnterTongChallengeArea", "I"}, --��������ս����
	--������
	{"RequestCreateTong", ""},			--�������֮ǰ�ж��Ƿ���Դ���
	{"CreateTong", "sS"},				--�������  �������������
	{"GetTongInfo", ""},				--��ð����Ϣ 
	{"GetTongMemberInfo", ""},			--��ð���Ա��Ϣ 
	{"GetTongRequestInfo", ""},			--������������Ϣ 
	{"BeJoinTong", "Ib"},				--�Ƿ�ͬ������� ������������ID��ͬ���ܾ�
	{"ChangePos", "IHH"},				--�޸�ְλ�� ���������id��ԭ����ְλ����ְλ
	{"GetTongLog", "I"},				--��ȡ��־��Ϣ�� ��������־����
	{"GetAllTongSomeInfo", ""},  --������а����Ϣ
	{"SearchTong", "s"},			--��ѯ�����С��������Ϣ
	{"GetAllPlayerSomeInfo",""},  --�������δ����С�ӵ������Ϣ
	{"SearchPlayer", "s"},			--��ѯ�����С��������Ϣ
	{"RequestJoinTong", "I"},			--�������ĳ��ᣬ������Ҫ����İ��id
	{"RequestJoinTongByName", "s"},--�������ĳ��ᣬ������Ŀ������
	{"ChangeTongPurpose", "S"},			--�޸İ����ּ���������µ���ּ
	{"KickOutOfTong", "I"},				--��������Ա����������Աid
	{"RecommendJoinTong", "ss"},		--�Ƽ�ĳ�˼����ᣬ��������ɫ���ƣ��Ƽ���Ϣ
	{"LeaveTong", ""},					--��Ա�˳����
	{"TongResign", ""},					--��ְ
	{"InviteJoinTong", "I"},			--��ļ
	{"InviteJoinTongByName", "s"},--��ļ
	{"ResponseBeInviteToTong", "Ib"},	--��Ӧ��ļ
	{"ResponseBeRecommendJoinTong","Ib"},
	{"PreChangeTongName",""},
	{"ChangeTongName","s"},
	{"ChangeTongType","I"},				--����ת��
	{"UpTongType","I"},						--��������
	{"ResetTongType",""},					--��ֵ����
	
	{"ContributeMoneyChangeExp","I"}, --��Ǯ�þ���
	{"ContributeMoneyChangeSoul","I"}, --��Ǯ�û�ֵ
	{"ContributeMoneyChangeResource","I"}, --��Ǯ�þ���
	{"GetTongContributeMoneyInfo","I"},	--��Ǯ��Ϣ
	
	--��Ὠ��
	{"CancelCreateBuildingItem", "I"},	--ȡ������/�ȴ�����Ľ���
	{"GetCreatingBuildingItemInfo", ""},--��ȡ���ڽ���͵ȴ�����Ľ���ģ����Ϣ
	{"CreateBuildingItem", "sI"},		--���콨��ģ��
	{"GetTongLevelToFilterAvailableBuildingItems",""},--��ȡС�ӵȼ�����ɸѡ�ɽ���Ŀ
	{"GetTongBuildingList", ""},		--��ȡ������Ϣ
	{"CreateBuilding", "sII"},			--���콨����������������������ơ��ڰ����е�λ��
	{"RemoveBuilding", "I"},			--�������������������id
	{"BeRepairBuilding", "II"},			--�����ֹͣ��������������id���ͻ��˵�ǰ��ʾ״̬
	{"GetTongBuildingItem", "s"},		--��ð�Ὠ����Ʒ
	
	{"GetCreatingProdItemInfo", ""},	--������ڽ������Ʒ��Ϣ
	{"TongFetchBuilding", ""},
	--���Ƽ�
	{"GetTongFightScienceInfo", ""},	--��ȡӶ����ս���Ƽ���Ϣ
	{"UpdateTongScience", "sC"},		--����Ӷ����ս���Ƽ�
	{"CancelUpdateScience", "sC"},		--ȡ�������е�Ӷ����ս���Ƽ�
	
	--���ս��
	{"GetTongChallengeInfoList", ""},	--��ð����ս�б�
	{"GetTongBattleListInfo", ""}, --��ð����ս��ս�б�
	{"SendChallenge", "III"},			--��ĳ�����ս��������ս��Id, פ��Id, �����
	{"TongChallengeReborn", ""},  --����ڰ����ս��������������
	{"RequestRetreatStation", ""}, --����פ�س���
	{"ExitTongChallenge", ""},		--�˳���ս
	{"GetTongRelativeLine", ""},	--Ӷ��������ս��
	{"RequestShowTongChallengeBattleCountWnd", ""},
	{"GetTongChallengeMemberListInfo", ""},
	{"JudgeOpenChallenge", ""},
	{"GetTongWarMemberListInfo", ""},
	{"RequestShowTongWarBattleCountWnd", ""},
	{"GetTongMonsAttackListInfo", ""},
	

	
	--����е
	{"GetArmInfo", ""},					--��ʾ���о�е
	{"CreateArm", "IsI"},				--�����е�ޣ���������𣬳���id
	{"DestroyArm", "II"},				--���ٻ�е�ޣ���������е��id����ǰ״̬
	{"GetArm", "I"},					--��ȡ��е�ޣ���������е��id
	{"RenameArm", "sI"},				--�޸Ļ�е������
	{"GiveBackArm", ""},				--�黹��е�ޣ���������е��id
	{"ForciblyGiveBack", "II"},			--�黹��е�ޣ���������е��id����ǰ״̬
	{"BeRepairArm", "II"},				--����/ֹͣ�����е�ޣ���������е��id����ǰ״̬
	--�����Դ
	{"ContributeMoney", "I"},			--���׽�Ǯ������������
	{"GetMoneyCanContribute", ""},

	--�����������
	{"CreateTongProdItem", "sII"},		--��������Ʒ�����������ơ����ࡢ����Ĳֿ�
	{"CancelCreateProdItem", "I"},		--ȡ�����죬��������Ʒid
	{"QuikMoveItemFromCDepotToBag", "HHHH"},		
	
	--�����Դ
	{"RequestAddTongBuyOrder", ""},
	{"AddTongBuyOrder", "II"},
	{"CancelTongBuyOrder", ""},
	{"SellTongResource", "I"},
	{"FetchResource", ""},
	{"GetTongMarketOrderInfoList", ""},
	{"GetTongSellResInfo", "Ib"},
	{"GetTongFethResInfo", ""},
	{"GetTongMyResOrderInfo", ""},
	{"ShowTongSellResWnd", "I"},
	{"RandomShowTongSellResWnd", "I"},
	{"ShowMyResOrderWnd", ""},
	{"ShowTongResTransWnd", "I"},
	
	{"RequestFightInTriangle","I"},
	{"AgreedFightInTriangle",""},
	{"CancelFightInTriangle",""},
	{"TransToTongArea", "s"},
	
------------------------------------------------------------------------------------------------------
	{"RequestCreateArmyCorps",""},			--����Ӷ����֮ǰ�ж��Ƿ���Դ���
	{"CreateArmyCorps","sS"},						--����Ӷ����
	{"GetArmyCorpsInfo",""},						--��ȡӶ���Ż�����Ϣ
	{"ChangeArmyCorpsPurpose","S"},			--�޸�Ӷ������ּ
	{"ChangeArmyCorpsName","S"},        --�޸�Ӷ������
	{"InviteJoinArmyCorps","I"},				--��������
	{"InviteJoinArmyCorpsByName","s"},	--��������
	{"ResponseBeInviteToArmyCorps","Ib"},
	{"GetArmyCorpsTeamInfo",""},				--��ȡӶ����������Ӷ��С����Ϣ
	{"LeaveArmyCorps",""},							--����
	{"KickOutOfArmyCorps","I"},					--�߳�Ӷ����
	{"GetTargetTongMemberInfo","I"},		--��ȡĿ��Ӷ��С�ӵĳ�Ա��Ϣ
	{"ChangeArmyCorpsPos","II"},					--�޸�Ȩ��
	{"PreChangeArmyCorpsName",""},
----------------------------------------------------------------------------------------------------------

--�̻�ϵͳ
	--�̻����

	{"OpenCofCNpcDialog","I"},			-- ���̻�npc�Ի��򣬵õ��̻��б�������npcid
	{"RequestJoinCofC","Is"},			-- ��������̻ᣬ�������̻�id,��������
	{"IntroduceJoinCofC","ss"},			-- ����������Ҽ����̻ᣬ����������������������Ա������˵�����
	{"RequestCreateCofc", "s"},			-- �����̻ᣬparam �̻�����
	{"LeaveCofc", ""},					-- �˳��̻�
	{"GetCofcInfo", "I"},				-- ���̻�������õ��̻���Ϣ��������npcid
	{"GetCofCMembersInfo", ""},			-- ���̻��Ա��壬�õ������Ϣ
	{"RequestOpenCofCStock",""},		--����ͨ�̻��Ʊ
	

	{"GetCofcTechnologyInfo", ""},			-- ���̻�Ƽ���壬�õ������Ϣ	
	{"GetCofCLogInfo", "I"},				-- ���̻���־��壬�õ������Ϣ,������(0-��Ա 1--���� 2--�Ƽ� 3--����4--����)
	{"GetCofCFinancialLogInfo", ""},	-- �̻��������в鿴��ʷ�Ʊ�
	{"ModifyCofcPropose", "s"},			-- �̻��������޸��̻���ּ���������̻���ּ
	
	--�̻��Ա���
	{"KickOutCofCMember", "I"},			--���̻��Ա�߳�������:�����Ϣid
	{"ApproveJoinCofC", "I"},			--������������߼����̻ᣬ�����������Ϣid
	{"RefuseJoinCofC", "I"},			--�ܾ���������߼����̻ᣬ�����������Ϣid
	{"ChangeCofCMemberPos", "Is"},		--�޸Ļ�Աְλ,�����������Ϣid���µ�ְλ
	
	--�̻�Ƽ����
	{"SetCurTech","I"},					--�������õ�ǰ������Ŀ���������Ƽ�id
	{"SetCofcCurrentTechnology","I"},				

	--�̻��Ʊ
	{"GetCofCStockKMap", "IiI"},		--�õ�k��ͼ���ݡ���������Ʊ���룻��Χ����������ֵ���������������15��2*60��8*60��
	{"GetCofCStockInfo",""},			--�õ����й�Ʊ��Ϣ
	{"GetCofCStockOrderList","I"},		--�õ�ĳ֧��Ʊ�Ķ����б���������Ʊ��id
	{"GetCofCStockMyDealingInfo", ""},	--�õ��ҵ�����������Ϣ
	{"GetCofCFinancialReport", "Ii"},	--�õ�ĳ֧��Ʊ�Ĳ��񱨸档��������Ʊid�������ڵ�����ƫ�ƣ���ֵ��
	{"GetCofcMyHaveInfo", "I"},			--�õ��Ҷ�ĳ֧��Ʊ�ĳ����������������Ʊid			
	{"CofcStockBuy", "III"},			--�����Ʊ����������Ʊid���������������׼۸�
	{"CofcStockSell", "III"},			--���۹�Ʊ����������Ʊid���������������׼۸�
	{"CofcStockDeleteOrder", "I"},		--��������������������id
	--Ŀ���������
	{"RequestAimInfo","I"},             --Ŀ��Ľ�ɫID;true--Ŀ��������塢false--С�ӳ�Ա�������
	--for stress test
	{"TestRpc","iissiisssssss"},
	--����ֿ����
	{"GetCollectiveBagOnePageItemList","II"},		--���ĳ�ֿ�������Ʒ��Ϣ�����������ͣ�ҳ��
	{"CollectiveBagAddItemFromOther","IIIII"},		--�Ӹ��˰����϶���Ʒ��������������������˰������ͣ�����λ�ã�����������ͣ�ҳ��������
	{"BagAddItemFromCollectiveBag","IIIII"},		--�Ӽ�������϶���Ʒ�����˰���������������������ͣ�ҳ�������ӣ����˰������ͣ�����λ��
	--������Ʒ���
	{"GetBoxitemInfo",			"IIIs"},				--�Ҽ������еĺ�����Ʒ���õ��������Ʒ��Ϣ��������������Ʒ���ڵ�nRoomIndex, nPos
	{"SelectBoxState", "II"},							--��ѯ���ӵ�״̬ ������������Ʒ���ڵ�nRoomIndex, nPos
	{"TakeAllBoxitemDrop",		"I"},				--��ȡ������Ʒ�����������Ʒ��������������Ʒid
	{"TakeOneDropItemByIndex",	"III"},				--��ȡ������Ʒ������ڶ���Ʒ�е�һ������������ǰ��ʾ��ҳ�����������Ʒ��ˮ��,������Ʒid
	{"GetOnePageDropItem",		"III"},				--�õ�ĳһҳҪ��ʾ�ĵ�����Ʒ��Ϣ��������������Ʒid����ǰ��ʾҳ��������Ʒ��ҳ����ÿ4����ƷΪһҳ��
	{"CollectiveBagMoveItemSelf","IIIII"},			--����ֿ���Ʒ�ڲ��ƶ�������������ֿ����ͣ���ʼ��Ʒ����ҳ������Ʒ��ʼ���ӣ���ƷĿ��ҳ����ȥƴĿ����ӣ�

	--��������
	{"ProduceByTwoMaterials","sIIsIII"},			--����������������Ʒ����������̥��Ʒ�ʲ��ϡ����������
	{"ProduceByProductName","sssI"},		--��ҩ������������Ʒ����������Ʒ���ƣ�Ҫ����������
	{"ProduceByProductNameAll","sss"},		--��ҩ������������Ʒ---ȫ����������������Ʒ����
	{"GetLiveSkillHasLearned",""},					--��������������Ϣ
	{"LearnLiveSkill","s"},							--ѧϰ�����
	{"WashLiveSkill", "s"},							--ϴ�������
	{"GetPracticedInfo","C"},						--�����������Ϣ
	{"GetPracticedInfoForNpcPanel","C"},			--�����������Ϣ
	{"LearnLiveSkillExpert","ss"},					--ר��ѧϰ
	{"GetLiveSkillExpert","s"},						--���ר����Ϣ
	{"GetProductsCanMake","s"},
	{"ForgetLiveSkillExpert", ""},					--����ר��
	{"GetLiveSkillProdRemainCDTime", "sss"},		--���ʣ����ȴʱ��
	--������ֻ�
	{"CareForFlower","I"},							--�ֻ�
	{"FlowerStateClean",""},						
	{"FlowerPerishGiveItem","b"},			
	--����
	{"AvargeSoulCountToEquip", "II"},				--�Ҽ�����,����ֵƽ�����������װ���������������ڰ����е�roomindex��pos
	
	--���鶯����Ӧ
	{"FacialAction", "Is"},					--�����鶯������������Ӧ�¼�������:Npc���֣�NpcID�����鶯������
	
--��ϵͳ
	{"SaveBattleArrayPos", "sIIIIIii"},    --��������
	{"SaveBattleArrayMemPos","IsIIIII"},   --����������Ϣ
	{"RevertToBattleArrayBook","Is"},      --��ԭ����
	{"UseBattleArraySkill","s"},           
	{"SaveBattleArrayShortCutIndex", "sI"},--�����󷨿����λ��
	
	--������
	{"CheckCamelState",			"s"},	--����������״̬�����⣩
	{"CheckCrazyHorseState",		"s"},	--���������״̬�����⣩
	{"SendSuccStateName","ss"},  --����״̬��һ�㣩
	--��������ѡ��
	{"SelectArea",			"fffs"},
	
	--�ʴ�ϵͳ
	{"CreateAnswerTbl","I"},--�������ѡ��𰸽���� ����  ��������
	{"AnswerQuestion","sIIsII"},--����( �������,�����ID,��ѡ��)(ѡ��𰸺����)
	{"AnswerQuestionFinish","IsIII"}, --���� ( ��Ŀ����, ��������, ������ʽ, ������ȷ����Ҫ��)
	--������Ʒ�༼��
	{"FightSpecialSkill",		"s"},--���⼼��
	--����ϵͳ
	--{"GetPlayerAreaInfo","s"}, ---�������������ƣ�
	{"GetPlayerSceneAreaInfo","s"},---�������������ƣ�
	{"PlayerChangeAreaPlace","ffsb"},---
	{"GetTeammatePos",""}, -- ��������ϻ�ȡ����λ��
	{"StopGetTeammatePos",""},
	{"GetTongmatePos",""}, -- ��������ϻ�ȡ����Աλ�� 
	{"StopGetTongmatePos",""},
	{"StopGetFbPlayerPos", ""},
	{"GetBornNpcOnMiddleMap", ""},
	{"GetFbBossOnMiddleMap", ""},
	{"SendAreaPkOnMiddleMap", "s"},
	{"SendRobResOnMiddleMap", "s"},

	{"GetCampInfoByNum", "I"},

	--��Ϸ����
	{"SysSettingBegain",	""},
	{"SysSettingEnd",		""},
	{"GameSetting",			"iiiiiiI"}, --�������ԣ��������Ƿ������ӡ��Ƿ���Խ��ס��Ƿ���Լ���Ⱥ���Ƿ���Խ��ѡ��Ƿ��������,�Ƿ������Զ����
	{"GetGameSettingInfo",	""},		--�õ���Ϸ������Ϣ
	{"SaveUISetting",		"bbbbbbbbbbbbbb"},
	
	-- ��������
	{"SetShowModeOfArmet", "b"},	-- ͷ����ʾ״̬
	
	--����
	{"NotifyClientLeave", "CI"},	--�����˷�����������
	{"NotifyToCharSelect", "I"}, --�ؽ�ɫѡ�����
	{"ClientLogout", "CC"},			--����֪ͨ
--	{"Exit2CharList", "" },		--���ؽ�ɫѡ�����
	{"CancelReadLeftTime", ""},  --ȡ������
	
	--�ٻ������
	{"MasterAttackCommand", "II"},	--�����򱦱����͹���ָ��
	{"MasterRetreatCommand", "II"},	--�����򱦱����ͳ���ָ��
	{"MasterDisbandCommand", "II"},	--�����뱦�����ͽ�ɢָ��
	{"MasterSpreadCommand", "II"},--�����չ��
	{"MasterOrderServantMoveCommand", "IIII"},--������ƶ�
	{"TestEquipIntensifyAddAttr2", ""},
	{"AgreeTakeOverNpc", "II"},
	
	--�̻����䳵
	{"TruckFollow", "I"},
	{"TruckStop", "I"},
	{"TruckKillSelf", "I"},
	{"GetChallengParam", ""},
	
	--װ��ǿ�����ϴ��
	{"EquipIntensifyBack", "IsdI"}, 	--Ҫ��ϴ��ǿ����װ����������װ��type��װ�����ƣ�װ��id,װ����λ��0��ʾ�ڰ����
	
	--�����̳�
	{"BuyItemInToolsMall", "IsII"},    --������, ����:ItemType, itemName, ֧����ʽ
	{"GiveItemInToolsMall","HsICss"},    --�������ˣ�������itemType��itemName,ncount,֧����ʽ��������name
	{"GetAimPlayerSoulNum","I"},          --��ѯ������ϵĻ�ֵ  ������Ҫ�鿴�����Id
    {"GetHotSaleItemInfo", "I"},--��ѯ��ǰ�̳���������Ʒ,��������Ʒ����
	{"TakeYongBingBi", ""}, --��ȡӶ����
	{"RequestTakeYongBingBi", "I"},--������ȡӶ���ҵ���Ŀ,������Ҫ��ȡ��Ӷ������Ŀ
	--Pk����
	{"OpenPkSwitch", "b"},						--��PK����
	
--/**��PK����**/
	{"OpenCSMWnd", ""},
	{"OpenMailWnd", ""},

	--������ս
	{"JudgeDistance", ""},
	{"CreateChallengeFlag", ""},
	{"DestroyChallengeFlag",""},
	{"SendChallengeMessage", "I"},
	{"StartChallenge", "b"},
	
	--�������ʰȡ��ʽ
	{"SelectNeedAssign", "IHII"},
	{"SavePlayerAppellation","II"}, --�����ɫ��ν ��������ν����
	{"EquipSmeltSoul","IsIIIIdIsII"},--װ�������� ������װ������Id��װ�����ƣ�����������λ�á��������������ӡ�װ������λ�á�װ������λ�á�װ��Id������������Id������������ơ�װ���ǴӰ��������Ļ��Ǵӽ�ɫ��������ϳ�����
    {"EquipAdvance", "dIII"}, 		--װ������equipID, equipPart, stoneRoomIndex1, stonePos1
    {"ActiveJingLingSkillPiece", "dII"}, --����鼤���� ��ƷID�����鼤����ID��װ���Ĳ�λ
    {"AdvancedEquipReborn","dI"},    	--���鼤�������� ��ƷID��װ���Ĳ�λ
    {"ActiveJingLingSkill","I"},		--����鼼��
    {"RenewEquipDuraValue","III"}, --������װ����λ��װ��id,����װ����֧����ʽ
    {"RenewAllEquipDuraValue", "I"}, --�޸���������װ��
    {"RenewEquipInBagDuraValue", "I"},--���޸��������װ��
    {"RenewEquipOnWearingDuraValue", "I"}, --���޸���ɫ���ϵ�װ��
    {"SelectAcutionAssign", "IIIb"},
    
  --�������
	{"StopLoadProgress", ""},			--ESC����϶���
		
	{"PlayActionCyc", "Isssbss"},
	
	-- �е�ͼ���
	{"GetMatchGameNpcTips", "s"},
	{"GetWarZoneState", "s"},
	{"GetFbPlayerPos", ""},

	{"PlayActionCyc", "Isssbss"},	
	--��ʱ��
	{"ClearTempBagObj",	"I"},
	{"UseTempBagObj",	"I"},
	--����
	{"IncubatePetEgg","sII"}, 		--�������޵� ���������ƣ��������������ӡ�
	{"PetEggPourSoul","sI"},  --���޵�ע������ɻ��� ���������޵����ơ����Ļ�ֵ
	{"ThrowAwayPet","I"},			--�������� ����������id
	{"ChangePetName","Is"},		--���޸��� ������������
	{"ThrowAwayPetEgg","s"},	--�������޵� ��������������
	{"UsePetSkillStone","sII"}, --������ʯ��ʹ�� ���������ƣ��������������ӡ�
	{"PreparePet","I"},			--׼������ ����������id
	{"InitPetWndInfo",""},
	{"SendUserAdviceInfo",	"SHH"},
	{"QueryQuestionList", ""},
	--����ϵͳ
	{"FinishPlayerDirect",	"s"},
	{"GetDirectAwardItem",	"Hs"},
	{"AddPlayerDirectAction",	"sss"},
	{"UpdatePlayerDirect",	""},
	{"UseEquipIntenBackItem", "IIIIIIIs"},
	
	--����ܴ���
	{"AddNeedContractManufactureOrder", "ssIIs"},    --��Ӵ�������;������liveSkillName��direction��time,money,�䷽��
    {"SearchCharContractManufactureOrder", "I"},    --��������ǰ��ѯҳ��
    {"CancelContractManufactureOrder", "I"}, --ȡ����������������������ID
    {"SearchCommonContractManuOrder", "ssIIII"}, --���Ҵ���������productName, skillName, skillLevel, productLowLevel, productHighLevel, curPage)
    {"TakeContractManufactureOrder", "I"}, --��������������������

	--�ȸ������,�ͻ�������ʱ֪ͨ�������˷����ȸ��´�����и���
	{"SendIdToGas", "i"},  --�ȸ��¼�¼��id
	{"SendHotUpdateMsg", "Isss"}, --�ȸ�����Ϣ�����
	
	--������ֵ���
	{"GetAfflatus_OffLineExp_Info", ""},
	{"ExChangeAfflatus", "I"},
	{"OpenExpOrSoulBottle","II"},
	
	{"UpdateChoosedMoneyPayType", "I"},--���ݴ򿪵��̵����ͣ���ͨ�̵�orͨ���̵꣩������ѡ���֧����ʽ��������
	{"EquipRefine", "dIsIs"},--װ��������������װ��id��װ��type��װ��name������ʯtype������ʯname
	{"UpdateShopTipFlag","II"},--������1���̵����ͣ�1Ϊ��ͨ��0Ϊͨ�ã���2��tip��ʾ���1Ϊ��ʾ��0Ϊ����ʾ��
	{"SetDefaultShopTipFlag", ""},--�ָ������̵���ʾ��Ϣ������
	{"IdentityAffirm","s"},
	{"LockItemBagByTime","I"},
	{"OpenItemBagLockWnd",""},
	{"ItemBagLockTimeOut",""},
	
	{"EquipSuperadd", "Isd"}, --װ��׷�ӣ�������
	{"UpdateEquipEffectToGas","I"},
	{"OpenTongNeedFireActivity",""},--��������
	{"CheckNeedFireIsOpen","I"},
	{"AddNeedFireItem","IIss"},
	{"YYRequest","sss"},
	{"YYlogin","S"},
	
	{"GetCapableOfBuyingCouponsList", ""},
	{"BuyCouponsUsingJinBi", "Is"}, --�����ȯ����������ţ�����
	{"GetBoughtCouponsInfo", ""},
	{"UseVIPItem","sHH"},
	{"ChangeSceneByMsg","IIII"},
	
	{"WeiBoRequestStart", "sss"},
	{"WeiBoLoginCheck", "s"},
}
	 


