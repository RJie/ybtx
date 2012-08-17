gac_gas_require "framework/message/MessageFun"
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

local funlist = 
{ 
	{"ClearDb2GacMsg",""},
	
	{"OpenMessageBox","I"},

	{"RetSendUserAdviceInfo","I"},
	{"RetQuestionsList","S"},
--GMָ������
  {"ReturnOpenPanel","i"},
  {"OpenMailWnd",""},
-- 
	{ "ByteCall",				"cc" },
	{ "Reload",					"S"  },
	{ "GMPrint",				"S"  },
-- Զ�̱�����ȡ ���RPC
	{ "Remote_MS_GetValue",		"S" },
	{ "Remote_MS_GetValues",	"S" },
	{ "Remote_MS_GetType",		"S" },
	{ "Remote_ResumeResult",	"S" },
	{ "Remote_ReceiveResult",	"S" },
	{ "RetOpenGMConsole",	"b" },

--��ɫ�������RPC
	{ "SetExp",					"IIIII"  	},
	{ "SetClass",				"II" 	},
	{ "SetCamp" ,				"II"	},
	{"NotifyClientCreateNewCoreObj",         ""},
	{	"RetSetMercenaryLevel",				"Ib"},
	{	"RetSetMercenaryIntegral",		"I"},
	{	"ExposePlayer",		"I"},
	
-- ��ɫս������
	{ "RetGetTotalTicket", "I"},
	{ "SendUserGameID", "i"},
	{ "RetDelTicket", "I"},
--Player �������
	{ "UpdateFightSkillError",  "s"      }, --��������ѧϰʧ��
	{ "UpdateFightSkill",      "sCC"      }, --�������ܵ�ѧϰ���������츳���ܵ�����
	{ "ReturnNonFightSkill",    "s"     }, --��ս������ѧϰ
	{ "ReturnLearnSkill",       "sC"     }, -- ���ؼ�������
	{ "RetAllFightSkill", 			"sCC"	}, --�������ơ� ���� ��
	{ "AddTalentSkill",             "sC"   }, --�������ơ� ���� ��
	{ "RetAddFightSkillStart",    ""},	--���ܷ��سɹ�
	{ "ReCommonlySkill",        "s"      }, 
	{ "ReAssociateAttr",        "b"       },
	{ "ReWeaponAttr",          "bs"       },
	{ "RemoveTempSkill",       "I"     }, 
	{ "OnCastTempSkill",       "I"     }, 
	{ "CreateTempSkill",        "sIII"       },
	
	{	"ReturnSeries",			"I"},  --����ϵ��Ϣ
	{	"ReturnSkillNode",		"I"}, --���ؽ����Ϣ
	{	"RetAddFightSkillEnd",""},
	
	{	"ReturnGetCompensateItemInfoBegin", "I"},
	{	"ReturnGetCompensateItemInfo", "IsIII"},
	{	"ReturnActivationCodeCompensateItem", "Iisi"},
	{	"ReturnGetCompensateItemInfoEnd", "I"},
	{	"LearnNoneFightSkill",	"Is"},
	{	"CancelLearnNoneFightSkill", "I"},
-- ϴ�츳
	{"ClearAllGenius",        "" },

-- ��ȴʱ�����
	{	"SetCoolDownTime",		"III"	},
	
-- �ٻ��޼������
	{ "CreateServantSkill",      "s" }, -- ����ٻ��޼���
	{ "DelServantSkill",		 "s" }, -- ɾ���ٻ��޼���
--npc for test
	{ "RetrunNpcIdForTest", 		"I"		},
	
-- ��½���RPC
	{	"RetReSetLogin",		"b"},		--���߿ͻ������������ĺ�
	{ "ReturnCheckUser",		"bis" },
	{ "ReturnCheckUserByActivationCode",		"sss" },
	{ "ReceiveAntiIndulgenceExitGame",		"" },
	{	"ReturnStartApex", ""},
	{ "ReturnCharList",			"IsIIIfIIIsCsIIssssssIIIIIIIII" },
	{ "ReturnDelCharList",			"IsIIIfIIIIIIssssssIIIIIIIII" },              --test add
	{ "ReturnDelCharListEnd",			"" },                      --test add
	{ "ReturnCharListEnd",		"" },
	{ "ReturnRecruitInfo",		"III" },
	{ "RetReturnRecruitInfo",		"IIII" },
	
	{ "ReturnCreateRole",		"i" },
	{ "DelCharEnd",				"" },
	{ "CompleteDelCharEnd",				"" },
	{"GetBackRoleEnd",      ""},
	{"DelCharErr", "I"},
	{"RuturnGetBackRole", ""},
	{"ReturnNameDiff",    "b"},
	{ "ReturnCharListBegin", "I"},--�Ƿ���ע��ɫ�������falseΪû��
	{	"RetServerIpInfo",	"sIsI"},
	{	"RetAccountSucc", ""},
	
	{ "InitMoneyInfo",				"ddd" },
	{ "InitMainPlayer",				"IIsI" },
	{ "InitOtherPlayer",			"IIIIiiICiiiisHsssssssssIbIH" },
	{ "CreatePlayerEnded", 			"sI" },
	{"ReturnLoginWaitingQueue",		"I"},
	{"ReturnDelWaitingUser",""},
	{"ReturnUpdateWaitSequence",	"I"},
--	{ "InitAgileInfo", 			"IIII" },
	{"ReturnPreChangePlayerName",	"b"},
	{"ReturnChangePlayerName",		"bI"},
--��ȡ�����ɫѡ�����������ʱ
	{ "RetGetDelayTime",           ""},

-- ��ɫ״̬�������ͷ�
--	{ "AdjustBulletTime",		"ICf" },	-- ObjGlobalId, BulletId, AdjustTime
	{ "ForceDirection",			"IC" },
	{ "AddFx",					"Iii" },
	{ "MustRemoveFx",	"II" },
	{ "RemoveFx",				"II" },
	{ "OnInitQianXing",		"Ib" },
	{ "OnQianXing",         		"Ib" },
	{ "OnBlind",            		"Ib" },

	{ "OnFallOver",         		"Ib" },
	{ "MoveStop", "" },
	{ "DoNormalAttackAni", "I" },
	{ "CancelNormalAttack", "" },
	{ "CancelAutoTrack", "I" },
	{ "OnShowDeadMsgBox", "IHH" },--��һ����������ս�����õ��������Ĵ���
	{ "OnPermitReborn", "s" },
	{ "CloseRebornMsgWnd", "" },
	{ "ChangeSceneCancelSelectGround", "" },
--npc
	{ "InitNpc",				"IIiiICiisHI" },
	{ "CreateCreature",	"iiiiCiis" },	
	{ "ChangedGridPosEnd", ""},
	{"RetShowTextNpc", "IsIIH"}, --NpcShowContent
	{"RetNpcDropItem", "IsIb"},
	{"RetNpcDropItemEnd","I"},
	{"RetGetSingleGridDropItem","I"},
	{"RetSelectAllDropItems","b"},
	{"NotifyClosePickUpWnd",""},
	{"RetGetDropItemGrid","I"},
	{"NotifyAuctionDropItem", "IsII"},
	
	{"FinishAuction", "I"},
	{"NotifyClearBagPos",""},
	{"NotifyChangeAuctionPrice","II"},
	{"SetDestroyBtnEnable",""},
	{"RetCancelAuction",""},
	{"NotifyCloseAuctionWnd",""},
	{"SendNpcRpcMessage", "sIs"},
	{"SendNpcRpcMessageByMessageID", "sII"},
	{"NotifyNpcDropItem","Ib"},
	{"NpcDoSkillTalk","IsIIs"},
	{"NpcDoSkillAdvise","sIs"},
	{"NpcDoSkillAdviseRepl","sIsss"},
	{"ShowTheaterNpcTalk","IsIsh"},
	{"ShowTheaterNpcDoTalk","IsIsss"},
	{"DoAlertPhaseEffect", "II"},
	{"DoAlertEndEffect", "I"},
	{"ClearNpcAlertEffect", "I"},
	
	{"RetShowFuncNpcOrObjTalkWnd", ""},  --npc�Ի���
	{"ShowNpcTalkWnd", "sIIb"},	--npc�����Ի�
	{"RetNpcTalkHeadInfo", "Ib"},
	
	--��Ѩ�
	{"RetShowDragonCaveWnd", "I"},
	{"RetEnterDragonCave", "s"},
	{"SendMsgToLocalSence", ""},
	{"SendMsgToOtherSence",""},
	{"SendMsgToEverySence",""},
	
	--���򸱱�
	{"RetShowAreaFbSelWnd","I"},
	{"RetAreaFbBossNum","sIIII"},
	{"RetIsJoinAreaFb","sIIII"},
	{"RetDelAllAreaFb", ""},
	{"RetIsChangeOut", "II"},
	{"RetInsertAreaFbList", "s"}, 
	{"OpenAllAreaFb", ""},
	
	{"ChangeBackgroundMusic","s"},
	{"RevertBackgroundMusic",""},
	
	--Ӷ����ˢ�ֱ�
	{"RetShowMercenaryMonsterFbWnd",""},
	{"RetIsJoinMercenaryMonsterFb","sI"},	
	
	--��ս����ĸ���
	--{"RetIsJoinDareFb","ss"},
	{"RetAreaFbListBegin","ss"},
	{"RetAreaFbListEnd",""},
	
	--���򸱱�
	{"RetIsJoinScopesFb","sII"},
	
	--���鸱��
	{"SendScenarioFinishInfo","s"},
	{"RetShowJuQingWnd","I"},
	{"RetIsJoinSenarioFb","sII"},
	{"SendScopesExplorationDPS","sIIIII"},
	{"SendScopesExplorationDPSEnd",""},
	{"RetChangeCameraPos","sb"},
	
	--���ս���
	--{"RetShowWarZoneSelWnd", "II"},
	{"ReturnGetMoneyCanContribute", "dd"},
	{"RetEnterWarZone", "bs"},
	{"OpenTongChallengeExitBtnWnd", ""},
	{"OpenTongChallengeBattleCountWnd", ""},
	{"OpenTongMonsAttackExitBtnWnd", ""},
	{"OpenTongMonsAttackCountWnd", ""},
	{"OpenTongWarExitBtnWnd", ""},
	{"OpenTongWarBattleCountWnd", ""},
	{"TongChallengeBegin", "I"},
	{"TongChallengeBattleBegin", "I"},
	{"TongWarBattleBegin", "I"},
	{"TongMonsAttackBegin", "I"},
	{"InitTongDownTimeWnd", "II"},
	{"CloseTongChallengePanel", ""},
	{"CloseTongWarPanel", ""},
	{"InitTongBattlePersonalCountWnd", "IIIII"},
	{"UpdateTongBattlePersonalCountInfo", "III"},
	{"UpdateCountInfo", "III"},
	{"OpenTongMonsAttackCountWnd", ""},
    {"ReturnTongProfferCount", "I"}, 	--�����Ź��׻�����Ŀ
    {"ReturnTongLevel", "II"}, 			--����ͼ�����׵ȼ�
    {"ReturnProfferPoint","I"},			--�����Ź��׻�����Ŀ
    {"ReturnTeamProfferPoint","I"},		--���ضӹ�
	{"ShowRobResZeroExitWnd", "s"},
	{"ShowRobResOverExit", ""},
	{"RetRobResourceWnd", "s"},
	{"RetOpenAutoSeekWnd", "sI"},
	{"RetOpenAutoSeekWndBegin", ""},
	{"RetStationSeekWnd", "IIsIIII"},	
	{"RetFbStationAutoSeek", "sII"},
	{"RetNotForageWnd", ""},
	{"ShowCountDown", "sI"},
	{"RetCharLearnedTech", "sI"},
		
	
	{"OpenConfirmWnd", "ss"},
	{"OpenSecConfirmWnd", "ssI"},
	{"CreateTbl", ""},
	{"InsertTbl", "sssI"},
	
	
	{"RetNpcHeadInfo", "I"},
	
	{"SetActionPanelWarnValue", "I"},
	
	--�󶴸���
	{"OreMapInfoShow","sII"},
	{"JoinAreaSceneMsgBox","IIsI"},
	{"TeamJoinSceneMsgBox","IIsI"},
	{"CreateAreaSceneMsgBox","s"},
	{"IsExitSceneMsgBox","b"},
	{"InviteJoinSceneMsgBox","IIssIs"},
	
	--������ս
	{"ShowChallengeMessage","Is"},
	{"ShowChallengeAdvertMessage","IsIII"},
	{"PropChallengeMessage","Is"},
	{"PropChallengeAdvertMessage","IsIII"},
	{"SetChallengeFlag","b"},
	{"CancelChallengeWnd","b"},
	
	--�Ե粨С��Ϸ
	{"CheckHeadFishing","sI"},
	
	--��Ʒʹ��
	{"NotifyUseItemProgressLoad",  "Is"},	--֪ͨ�ͻ��˿�ʼʹ����Ʒ����
	{"NotifyUseItemProgressStop",  ""},		--֪ͨ�ͻ��˽���ʹ����Ʒ����
	
	{"NotifySandGlassLoad",  "I"},
	{"NotifySandGlassClose", ""},
	-----------------
	
--��������
	{"RetObjShowContentWnd","I"},-- ��������GlobalID
	{ "InitIntObj",  "IsI"},
	{"RetShowAnimation","I"},
	{ "RetShowQuestObjTalkWnd",  "I"},---- ��������GlobalID
	{"RetShowCollObjWnd","I"},-- ��������GlobalID
	{"NotifyCloseCollWnd",""},
	{"RetCanCollItemEnd","II"},-- ��������GlobalID,�����ж��Ƿ��������
	{"RetCanCollItem","IsI"},-- ��Ʒ���࣬��Ʒ������������Ʒ���ŵĸ��Ӻ�
	{"RetCollGetGridItem","Ib"},--��Ʒ���ŵĸ��Ӻţ�boolֵ��ʾ��ȡ�ø��ӵ���Ʒ�Ƿ�ɹ�
	{"RetCollAllItemGrid","I"},
	{"RetSelectAllGridItems","b"},--boolֵ��ʾ��ȡ�����и��ӵ���Ʒ�Ƿ�ɹ�
	{"NotifyLoadProgressBar",  "Ibs"}, --֪ͨ�ͻ��˶�ȡ����������������ϵͳר�ã�
	{"ResourceLoadProgress",  "Is"}, --֪ͨ�ͻ��˶�ȡ��������װ����Դ��
	{"NotifyTeammateTransport","s"}, --֪ͨ�������ٻ������ѵ�����
	{"IntObjChangeModel","Iss"},
	{"IntObjChangeState","IH"},
	{"NotifyStopProgressBar",""},
	{"NotifyIntObjEffect","Is"},
	{"NotifyIntObjDoAction","IsH"},

	--��������
	{"PlayerTransportSetGrid",""},-- ���������Ҫ����Ա���ͼ�ڿ�trapѰ·

-- ��Ʒ�ռ����

	{ "ReturnBreakItemBegin",""},		
	{ "ReturnBreakProducts","CsC"},		
	{ "ReturnBreakItemEnd","bCC"},		
	{ "AddBreakItemExp","I"},	
	{ "InitBreakItemExp","I"},			
	{ "ReturnAddMoney","d"},									 --��ӽ�Ǯ
	{ "ReturnAddMoneySlowly","dI"},						 --��ӽ�Ǯ
	{ "ReturnAddMoneyError","d"},							 --��ӽ�Ǯ
	{ "ReturnAddTicket","d"},								 --���Ӷ����
	{ "ReturnAddTicketError","d"},						 --���Ӷ����
	{ "ReturnAddBindingMoney","d"},								 --��Ӱ󶨽�Ǯ
	{ "ReturnAddBindingMoneyError","d"},						 --��Ӱ󶨽�Ǯ����
	{ "ReturnAddBindingTicket","d"},								 --��Ӱ�Ӷ����
	{ "ReturnAddBindingTicketError","d"},						 --��Ӱ�Ӷ���ҳ���
		
	{ "RetCharBagInfo",		"dCCCsI" },
	{ "RetCharBagInfoEnd",	"" },
	{ "RetItemTypeInfo", "dCsi" },
	{ "SetItemBindingTypeByID", "di" },
	{ "RetItemLeftTime", "di" },
	{ "RetItemRoom", "C" },
	{ "RetAddItemToGrid", "d" },
	{ "RetAddItemToGridEnd", "dCIsI" },
	{ "RetAddItemToGridEndEx", "dC" },
	{ "RetRefreshBag", "" },
	{ "RetAddItem", "dCC" },
	
	{ "RetItemMakerName", "sd" },		-- ��Ʒ������
	{ "RetAddItemAllGMEnd", "CsC"},		--"���࣬С�࣬��Ŀ"(�����¼��ͱ�ʾ��ӵ�����ȫ�����)
	{ "RetAddItemGMError", "Css"},		--"���࣬С�࣬����˵��"
	{ "RetPlayerItemSound", "Cs"},
	
	{ "RetDelItemFromGrid",			"dCCb"},					--"�ռ䣬λ�ã�ItemID"
	{ "RetQuestDelItemEnd","CC"},				--"�ռ䣬λ��"
	{ "RetDelItemError",		"c"},
	{ "RetDelItemAllGMEnd",		"CsC"},
	{ "RetDelItemGMError",	"Css"}, 		--"���࣬С�࣬����˵��"
	
	{ "RetSplitItemEnd",	"CCCC"},			--"�ռ�a��λ��a���ռ�b,λ��b"
	{ "RetSplitItemError",	"cCCCC"},		--"������Ϣ���ռ�a��λ��a���ռ�b,λ��b"
	
	{ "RetQuickMoveEnd",""},           --Room,Pos
	{ "RetQuickMoveError","c"},
	
	{ "RetMoveItemEnd",	"CCCC"},					--"�ռ�a��λ��a���ռ�b,λ��b"
	{ "RetMoveItemError",	"CCCC"},
	{ "ReturnPlaceBag",    "CCCC"}, 				--�ռ䣬λ�ã����Ŀռ䣬ʹ�����ĸ�RoomIndex(0:��ʾ������)
	{ "ReturnPlaceBagError",   ""},
	{ "ReturnFetchBag",  "CCCd"},						--nSlot,nRoom,nPos
	{ "ReturnFetchBagError", ""},	
	{ "ReturnChange2Bag", "CC"},						--nASlotRoom,nASlot,nBSlotRoom,nBSlot
	{ "ReturnChange2BagError", ""},	
	{ "ReturnDelBag" ,"C"},
	{ "ReturnDelBagError", "c"},	
	{ "RetCleanBag", ""},
	{ "ReturnSetBagState",""}, 							--���ð�����ʹ��״̬
	{ "RetMoveItemByGridID", "dCC"},
	{ "RetReplaceItemByGridIDEnd", "CCCC"},

	{ "ReturnGetDepotInfo", "d"},
	{ "ReturnOpenDepotSlotError", ""},
	{ "RetUseItem", "CCdI"},					--Room,Pos,nItemID,eEquipPart	

-- ��ʾ��Ϣ���� ���RPC
--	{ "Message",				"I" },
	{ "Talk",					"Is" },
	{ "AddItemMsgToConn",        "d"}, 
	
--��ȡ������Ұ�ڶ���
	{ "ReturnObjInSight","IH" }, --����ID, ��������
	
-- �����
	{ "ReturnShortcut", "CCsII"}, --Pos, Type, Arg1, Arg2, Arg3
	{"ReturnShortcutEnd","I"},
	
--װ��ϵͳ�������������ϵ�װ��
	{ "UpdateModel",		"I" },
	{ "UpdateAni",			"I" },
	{ "UpdateCoreInfo",		"I"},
	{ "AoiAddEquip",				 "IIss"},	
	{"RetEquipInfo",				"CsdCI" },	--��ʼ����̬װ��
	{ "RetJewelryInfo", 			"CsdC" }, 	--��ʼ����Ʒ(��,��)
	{ "RetFetchEquipByPart",       	"Cb" },  	 --ȡ��װ��,����ɾ��װ��
	{ "RetSwitchTwoRing",          	"CsCs"    },  --�������ҽ�ָ
	{ "RetSwitchWeapon",          	"CsCs"    },  --�������ָ�������
	{"RetCommonWeaponInfo",   		"dsIIIfffIIIs"}, --[[	����װ����������Ϣ,
															������ID, ��ʾ���ƣ������ͣ������ȼ���
															��ǰ�ȼ���DPS,
															��ǰ����������������ǰ����ǿ��������
															��������1����������1��ֵ��
															��������2����������2��ֵ,
															ǿ�����ڼ��׶Σ���װ���ͣ���Ʒor��ͨ������װ��,
															����Ƭ�趨������1������Ƭ�趨������2��
															����Ƭ�趨������3������Ƭ�趨������4,
															ǿ�����׶ε��츳����Ӧ�����,�;����ޣ���ǰ�;�ֵ��
														--]]
	{"RetCommonArmorInfo",			"dsIIIIIIIIIIs"}, --[[���ػ��׵���Ϣ
															������ID, ��ʾ���ƣ������ͣ������ȼ���
															��ǰ�ȼ���װ������ʱ������1��װ������ʱ������2��װ������ʱ������3����̬װ������
															��ǰ����������������ǰ����ǿ��������
															��������1����������1��ֵ��
															��������2����������2��ֵ��
															ǿ�����ڼ��׶Σ���װ���ͣ���Ʒor��ͨ������װ����
															����Ƭ�趨������1������Ƭ�趨������2,
															ǿ�����׶ε��츳����Ӧ�����,�;����ޣ���ǰ�;�ֵ��
														--]]
	{"RetCommonRingInfo",			"dsIIIIIIIIs"}, --[[���ؽ�ָ����Ϣ
															������ID, ��ʾ���ƣ������ͣ������ȼ���
															��ǰ�ȼ���DPS����̬װ������
															��ǰ����������������ǰ����ǿ��������
															��������1����������1��ֵ��
															��������2����������2��ֵ��
															ǿ�����ڼ��׶Σ���װ���ͣ���Ʒor��ͨ������װ����
															����Ƭ�趨������1������Ƭ�趨������2,
															ǿ�����׶ε��츳����Ӧ�����,�;����ޣ���ǰ�;�ֵ��
														--]]
	{"RetCommonShieldInfo",			"dsIIIIIIIIIIs"}, --[[���ض��Ƶ���Ϣ
															������ID, ��ʾ���ƣ������ͣ������ȼ���
															��ǰ�ȼ���
															��ǰ����������������ǰ����ǿ��������
															��������1����������1��ֵ��
															��������2����������2��ֵ��
															ǿ�����ڼ��׶Σ�����Ƭ�趨������1������Ƭ�趨������2,��������1��ֵ����������2��ֵ����������3��ֵ����������4��ֵ,
															ǿ�����׶ε��츳����Ӧ�����,�;����ޣ���ǰ�;�ֵ��
																
														--]]
	{"NoticeIntensifySuccess",		"dI"},		--����װ��ǿ���ɹ�����������Ʒid,װ��part
	{"NoticePourIntensifyError","dI"},         -- ע��ǿ����������Ϣ��ʾ�� ��������ƷID������
	{"NoticePourIntensifySuccess","d"},			-- ע��ǿ���Ļ�ɹ�		
	{"NoticeAdvanceError","d"},               	-- װ������ʧ��
	{"NoticeAdvanceSuccess", "d"},				-- װ�����׳ɹ�����������ƷID
	{"NoticeAbsorbSoul", "Id"},					-- װ����ȡ�꣬��������ƷID�������Ŀ
	{"NoticePourUpgradeError", "dI"},			--ע��������󣬲�������ƷID�������Ŀ
	{"NoticePourUpgradeSuccess","d"},     		--ע������ɹ�
	{"RetEquipAddAttrInfo", "dsIsIsIsIsIsI"},    --����װ��ǿ����4~9�׶Σ��ĸ������ԺͶ�Ӧ��ֵ
  	{"RetEquipIntensifyInfo", "dIsIsIIsIII"},  --����װ��ǿ�������Ϣ���ͻ���
	{"UpdateEquipIntensifyInfo", "d"},		--װ��ǿ��ʧ����Ϣ����
--���ϵͳ���
	{ "ReturnInviteMakeTeam",		"IsICH"	},	--�������������
	{ "ReturnAppJoinTeam",			"IsIC"	},	--�ӳ��õ����������Ϣ
	{ "UpdateAssignMode",			"H"		},	--���·��䷽ʽ
	{ "NotifyNoTeam",				""		},	--֪ͨ �Լ��Ѿ����ٶ�����
	{ "ReturnGetTeamMemberBegin",	""		},	--���ػ�ö����Ա��ʼ
	{ "ReturnGetTeamMember",		"IsbIICH"},	--���ػ�ö����Ա
	{ "ReturnGetTeamMemberEnd",		"IH"	},	--���ػ�ö������
	{ "UpdateTeammateIcon",			""		},	--֪ͨ���¶���ͷ��
	{ "NotifyOffline",				"I"		},	--֪ͨ���Ѿ�����
	{ "NotifyOnline",				"I"		},	--֪ͨ���Ѿ�����
	{ "UpdateAuctionStandard",		"I"		},	--֪ͨ������Ʒ�ʱ�׼
	{ "UpdateAuctionBasePrice",		"I"		},	--֪ͨ�����ĵ׼۱�׼
	{ "ReturnUpdateTeamMark",		"III"	},	--����С�ӱ����Ϣ��������������ͣ�����Ƕ������ͣ�����id
	{ "ReturnUpdateTeamMarkEnd",	""		},	--����С�ӱ����Ϣ����
	{ "ReturnUpdateHPMPByCharID",	"IIIII"	},	--����CharIDˢ��С�ӳ�ԱѪֵħֵ
	{ "SendTeamMemberLevel",		"IC"	},	--����С�ӳ�Ա�ȼ�
	{ "ReceiveTeamMemberEntityId",		"II"	},

--����Ŷ�
	{"GetTeamListBegin","I"},	--nType
	{"GetTeamList","IsIIIIsI"},	
	{"GetTeamListEnd","I"},	--nType
	{"RenewTeamList","I"},	--nType
	{"GetLineTeamList","II"},
	{"GetLineTeamListBegin",""},
	{"GetLineTeamListEnd",""},
	{"ChangeBtnState","I"},
	
	
--����
	{"RetIsShowQuestTraceBack","b"},	--�Ƿ�Ҫ��ʾ����׷�����
	{ "NotifyTeammateShareQuest","Iss"}, --��������Ķ���ID, ���������������
	{ "RetGetQuest", "sIIHH"},			  --��������,����״̬��������ʱ��,���������Ƿ��Ѿ�����,�����Ӧ����Ʒ����ID
	{ "RetGetQuestLoop", "sI"},
	{ "RetAcceptQuest", "sHsI"},
	{ "RetFinishQuest", "ss"},		  --��������	 	
	{ "RetQuestVar", "ssI"},          --�������ϸ��
	{"RetQuestBuffVar","ssI"},   --���������Buff���󣨽�����״̬���������
	{ "RetAddQuestVar", "ssI"},          --�������ϸ��
	{ "RetGiveUpQuest", "sb"},		  --��������ɹ�
 	{ "RetIncrementQuestVar", "ssI"}, --����ĸ���(�������ƣ�����������ƣ���������)
 	{ "ClearLoopQuest", "s"},
 	{ "InitMasterStrokeQuestLevTbl", ""},

	{ "RetAcceptTask",  ""}, --���ؽ���������ȡ
	{ "RetShowTakeQuest", "s"},	--������ʾ������ȡ��壬����(��������)
	{	"RetShowTakeDareQuest","ss"},--������ս������ȡ���
	{ "RetShowFinishQuest", "sH"},--������ʾ���������壬����(��������,Ӷ��������ƷҪ����һ��)
	{ "NotifyQuestFailure", "s" }, --����ʧ��֪ͨ�ͻ���
	{ "RetShowQihunjiZhiyinWnd", "b" },
--��������yy
	{ "SendHideQuestSign", "s"}, --��������������

--������ش���
	{	"RetSendMercQuestPool","sI"},
	{	"RetShowMercQuestPoolWndEnd","Is"},
	{	"RetSendMercTempQuestPool","sI"},
	{	"RetSendMercTempQuestPoolEnd","b"},
	
	--Ӷ���ȼ�ָ��
	{"RetCheckInMercenaryInfo",""},
	{"RetUpdateMercenaryLevelTrace","IIsssIIIIII"},
	{"RetUpdateMercenaryLevelAwardItem","s"},
	{"RetShowMercenaryLevelAward",""},
	{"SetMercenaryLevelFinishAwards","s"},
	{"ClearMercenaryLevelFinishAwards",""},
	{"ShowMercenaryLevelMessage","I"},
	{"RetShowOpenYbAssessWnd",""},
	
--����Npcͷ����Ϣ
	{ "UpdateNpcHeadSign", ""},
	{	"RetSetNpcDirection", "II"},
--�������
	--[[ �����Ķ������£� 
		SUBSCRIBE = 1,
		UN_SUBSCRIBE = 0
	--]]
	{ "TalkResult", "sbsII"},							--�����ķ�����Ϣ(��ɫ��,�Ƿ�ɹ������ݣ���ɫ��ID����ɫ�ĵȼ�)
	{ "TalkContent", "ssII" },						--���յ���Ϣ (�������� ��������ݣ���ɫ��ID����ɫ�ĵȼ�)
	{"SecretChatFail",  "s" },							--��������ʧ����Ϣ
	{ "ChannelMessage", 			"IsISI" },   	--����Ϣ(˵����id��˵����������Ƶ������Ϣ����)
	{ "RetSetDefaultChannelPanel", 	"b" },			--�������default
	{ "RetRenamePanel",	 		"b" },				--������������������Ϣ
	{ "RetDeletePanel",				"b" },			--����ɾ�����������Ϣ
	{ "RetGetChannelPanelInfo", 	"III" },		--��ȡ���������Ϣ��Ƶ��ID�����Ʋ��������λ�ã�
	{ "RetGetPanelInfo", 			"sII" },		--��ȡ�����Ϣ �����ƣ�λ�ã�������
	{"RetInfoByID",                  "dCs"},			--����ID��BigID��Item
	{"ReturnSaveChatInWorldShow",""},
	{"ReturnSaveChatInCHItemShow",""},
	{"ReturnSaveChatInCHMoneyShow",""},

--��Ⱥϵͳ
	{"ReturnAddFriendClass","bIs"},			--��ӷ��鷵�ؽ��,��������ӷ���ɹ�����־,��������ID,������������
	{"ReturnSearchPlayer","IsIb"},			--���ؾ�ȷ���Һ��ѵĻ�����Ϣ ���������ID�����name����ҵȼ�������Ƿ����� 
	{"ReturnSearchPlayerEnd",""},			--���ط��ͺ�����Ϣ������־
	{"ReturnInviteToBeFriend","sII"},		--֪ͨ����Լ�����Ϊ���� ������Ҫ���Լ������name,���Ҫ���Լ��������ID,Ҫ���Լ������ID
	{"ReturnAddFriendToClass","IIsHCCCsCI"},		--��Ӧ��Ӻ��� ������������ID, ���ID, ����name, �ȼ�, ��Ӫ, ְҵ, С������, ���ڳ���, �Ƿ�����
	{"ReturnGetAllFriendClassBegin",""},	--���ͷ�����Ϣ��ʼ
	{"ReturnGetAllFriendClass","Is"},		--��ͻ��˷��ͺ��ѷ�����Ϣ ������������ID����������
	{"ReturnGetAllFriendClassEnd",""},		--���ͷ�����Ϣ����
	{"ReturnGetAllFriendInfo","IIsHCCCsCI"},	-- ��ͻ��˷�����Һ�����Ϣ ������������ID, ���ID, ����name, �ȼ�, ��Ӫ, ְҵ, С������, ���ڳ���, �Ƿ�����
	{"ReturnGetAllFriendInfoEnd",""},		--��ͻ��˷�����Һ�����Ϣ������־
	{"PrivateChatReceiveMsg","IsS"},		--��Է�����˽������ ����������������ҵ�ID,�����������name�����͵�����
	{"ReturnDeleteMyFriend","bII"},			--ɾ�����ѳɹ���֪ͨ���  ������ɾ���ɹ����ı�־, �Է���ID, �Է��������ID
	{"ReturnBeDeleteByFriend","II"}, --ɾ�����ѳɹ���֪ͨ�Է� ������ɾ���Լ������ID����������ڵ��Լ��ĺ�����ID
	{"ReturnDeleteBlackListMem","bI"}, --ɾ�����������ر�־ �������ɹ���־, ��������ԱID 
	{"ReturnMoveToBlackList","b"},  --������Ӻ������ĳɹ���� �������ɹ����ı�־
	{"ReturnChangeToClass","b"},   --�����ƶ����ѱ�־ ���������سɹ����
	{"ReturnDeleteFriendClass","bI"}, --ɾ��������ɹ���־ ������ɾ��������ɹ���־, ������ID
	{"ReturnCreateFriendGroup","I"}, --����Ⱥ ������ȺID
	{"ReturnSearchGroup","Iss"}, --���ؾ�ȷ����Ⱥ ������ȺID��Ⱥname��Ⱥ��
	{"ReturnSearchGroupEnd",""}, --��ȷ����Ⱥ������־
	{"ReturnGetAllFriendGroupBegin",""}, --���ͺ���Ⱥ��ʼ
	{"ReturnGetAllFriendGroup","IsIssI"},  --��ͻ��˷��ͺ���Ⱥ��Ϣ ������--����Ⱥ��ţ�����Ⱥ���ƣ�����Ⱥ���ͣ�����Ⱥ��ǩ������Ⱥ����
	{"ReturnGetAllFriendGroupEnd",""}, --���ͺ���Ⱥ����
	{"ReturnGetAllGroupMemInfo","IsCIC"}, --Ⱥ��Ա��Ϣ ������--���ID,���name,���ְλ��ʶ(1:Ⱥ����2:����Ա(���ֻ������)��3:��ͨ��Ա),--�������ȺID,����ǲ�������(1--���ߣ�2--����)
	{"ReturnGetAllGroupMemInfoEnd","I"}, --���ͺ�����Ϣ���� ������ȺID
	{"ReturnAddGroupMem","IsCIC"}, --Ⱥ��Ա��Ϣ ������--���ID,���name,���ְλ��ʶ(1:Ⱥ����2:����Ա(���ֻ������)��3:��ͨ��Ա),--�������ȺID,����ǲ�������(1--���ߣ�2--����)
	{"ReturnInitAssociationInfo",""}, --��ʼ����Ⱥ������
	{"RecevieRequestJoinIntoFriendGroup","IsI"}, --Ⱥ�������Ա�յ�������Ϣ ���������ID�����name��ȺID
	{"ReturnRequestJoinIntoFriendGroupEnd",""}, --����Ⱥ����׼��
	{"PublicChatReceiveMsg","IsS"},  --��Ⱥ����ı����ҷ���Ⱥ��Ϣ ������ȺId, ����Ϣ�����Name,��Ϣ����text
	{"ReceiveInviteToGroup","IsIs"},    --����ҷ����������Ⱥ���� ���������ID�����name��ȺID��Ⱥname
	{"ReturnLeaveGroup","I"},  --�����뿪Ⱥ ������ȺID
	{"ReturnDisbandGroup","I"},   --��ɢȺ���� ������ȺID
	{"ReturnSetCtrlType","III"}, --�������ù���Ա ���������ID��ȺID������/ȡ������� 2-���ù���Ա��3-ȡ������Ա
	{"NotifyFriendOnline","II"},    --֪ͨ����������� ������������Id�����ID
	{"NotifyFriendOffline","II"}, --����֪ͨ���� ������������ID������ID
	{"ReceiveMemberLeaveGroup","II"}, --�����޳��� ���������ID��ȺID
	{"ReceiveBeKickOutOfGroup","I"}, --�յ����޳�����Ϣ ������ȺID
	{"ReturnRenameFriendClass","bIss"},--�����޸ĺ��������� �������ɹ����ı�־,��ID,������,������
	{"NotifyFriendGroupOnline","II"}, --��������֪ͨ����Ⱥ��Ա ���������ID ,ȺID
	{"NotifyFriendGroupOffline","II"},--��������֪ͨ����Ⱥ��Ա ���������ID ,ȺID
	{"ReturnChangeShowSentence", "bs"},--�����޸�������� �������������
	{"ReturnSaveAssociationPersonalInfo",""}, --���ر��������Ϣ ����������ɹ����
	{"ReturnGetAssociationPersonalInfo","CssCCCCs"}, --���ز鿴�ĸ�����Ϣ ����(����,����,��Ȥ,����,����,����״̬,����,
																												--	���¶�̬��һ��,���¶�̬�ڶ���,���¶�̬������)
	{"ReturnGetAssociationMemberInfo","IIsIIssssIIIIs"}, --���������Ϣ ����(���ID,����,����,��Ӫ,�ȼ�,Ӷ����,�̻�,����������(��ͼ)
																												--	��Ȥ,����,����,����״̬,����,���¶�̬��һ��,���¶�̬�ڶ���,���¶�̬������)
	{"ReturnGetMemberIdbyNameForPrivateChat", "IsS"}, --����ͨ���Է����ֿ�ʼ˽�� �������Է�ID, �Է�����, ������Ϣ
	{"ReceiveCofcChatSendMsg","sS"}, --���̻���������Ա����Ⱥ����Ϣ ����������Ϣ�����name����Ϣ����
	{"ReturnAddToBlackList",  "Ibs"}, --������ӵ�������
	{"ReturnChangeGroupDeclare", "IS"},
	{"ReturnInitFriendGroupInfoEnd",""},
	{"ReceiveSendOfflineMsg","IssS"},
	{"ReturnUpdateFriendInfo", "IHCsII"},			--ˢ��ָ��������Ϣ ������ID, �ȼ�, С������, ���ڳ���, ����ID
	{"ReturnUpdateOnlineFriendInfo", "IIHCsI"},		--ˢ�����ߺ�����Ϣ ������ID, ����ID, �ȼ�, С������, ���ڳ���
	{"ReturnUpdateOnlineFriendInfoClassEnd", "I"},	--ˢ�����ߺ�����Ϣ����һ����� ��ID
	{"ReturnRefuseGroupMsgOrNot","II"},--����/����Ⱥ��Ϣ
--��ʱ
	{"RetGetDelayTime",			""},		--���ط�������ʱ

--�ʼ�ϵͳ
	{"RetDeleteMail", 		"I"},					--����ɾ���ʼ��ɹ������Ϣ���������Ƿ�ɹ���

	{"RetMailListBegin",    ""},               --�ʼ��б���֮ǰ��gas2gac��
	{"RetMailList",		"IIsIsId"},				--��ȡ�ʼ��б��������ʼ�ID��������ID�����⣬�ʼ�״̬������޸�ʱ��-��λ���룬������������
	{"RetSysMailList",  "IssId"},				--��ȡϵͳ�ʼ��б��������ʼ�ID��������������npc��ϵͳ�������⣬״̬������޸�ʱ��-��λ���룩
	{"RetMailListEnd",    ""},
	{"RetSendEmail",		"b"},				--���ط����ʼ��ɹ���񣬲������Ƿ�ɹ���
	{ "SendMailGoodsBegin", ""}, 				--�����ʼ�id ,����id������Ʒ
	{"RetTakeAtachment",	"bI"},				--���ػ�ȡ�������������Ƿ�ɹ�,mailID��
	
	{"RetGetMailGoods",        "IIIssI"},			--���ظ�����ϸ��Ϣ,����(EmailID, ��Ʒid,�ڼ�������,��Ʒ������,��Ʒ�� �� ��Ʒ����)
	{"RetGetMailGoodsEnd",         "I"},			--���ظ�����Ϣ����
	{"RetTakeAtachmentByIndex",     "IbI"},		--ͨ�����ѡ����ȡ�����ķ��� ����(�ڼ�������,�Ƿ���ȡ�ɹ�,mailID)
	{"RetMailTextAttachmentInfo",         "dss"},			--�����ʼ��ı���������Ϣ
	{"RetSoulPearlItemInfo",         "dI"},			--���ػ������Ϣ
	{"RetOreMapItemInfo",         "ds"},			--���ؿ��ͼ����Ϣ
	{"RetPickOreItemInfo",         "dII"},			--���زɿ󹤾ߵ���Ϣ
	{"RetGetMailInfo",		"IIIsSIIsIi"},		--[[
	
													���ػ�ȡ�ʼ���Ϣ������:
														�ʼ�ID��
														������id��
														�ռ���id��
														�ż����⣬
														�ż����ݣ�
														�ż�״̬��
														������Ǯ,
														�����˷���ʱ�䣬
														������ʱ�䣬
														����������
												--]]
	{"RetCheckMailTextAttachment", "sssSIi"},	--�����ʼ��ı����������ݡ�������ʱ�䡢�����ߡ����⡢���ݡ����ͣ�0Ϊ��ͨ�û��ʼ���1Ϊϵͳ�ʼ���

	{"RetGetSendMoneyCess", "Ii"},	
	
--����Ƕ��ʯ
	{"ReturnOpenHole","b"},                     --��׹��ܵķ���, ����: �Ƿ�ɹ�
	{"ReturnInlayStone","b"},			  --��Ƕ���ܵķ���, ����: �Ƿ�ɹ�
	{"ReturnGetInlayedHole","IIIIs"},          --��ʼ����Ƕ�ı�ʯ   ����: ���ID ,��λID , �׵�ID, ��ʯ����,  ��ʯ����
	{"ReturnGetOpenedHole","III"},           --��ʼ����׵Ŀ�       ����: ���ID ,��λID , �׵�ID
	{"NotifyAddAttr","III"},			  --֪ͨ���Ӹ�������    ����: ���ID ,��λID , �׵�ID(4 or 8)
	{"ReturnRemovalStone","b"},		  --ժ����ʯ�ķ���   ����: �Ƿ�ɹ�
	{"ReturnSynthesisItemEnd","b"},	  --�ϳɽ���֪ͨ   ����: �Ƿ�ɹ�
	{"ReturnSynthesisItem","dIs"},		  --�ϳ� ����  ����:  ItemID, type  , name
	{"UpdateAllHoleInfoBegin",""},		  --���³�ʼ���������� ��ʼ֪ͨ
	{"SendAllHoleInfoEnd",""},			  --��ʼ������֪ͨ
	{"RetWhiteStoneAppraise","IsII"},	  --�ױ�ʯ��������  ����: type  , name  ,  ItemID,   �ڼ��μ����Ľ��
	{"RetWhiteStoneAppraiseFirstTime","Is"},	  --�ױ�ʯ��һ�μ�������12���߼���ʯ��Ϣ  ����: type  , name
	{"RetTakeAppraisedStone","b"},		  --��ȡ����  ����: �Ƿ�ɹ�
	{"NotifyOpenPanel", "I"},			  --֪ͨ�����������  ����: ���ID
	{"UsePanel", "I"},			  	  --֪ͨ����ʹ���ĸ����
	
	--NPC shop
	{"RetNpcTradeSucc", ""},   								--NPC���׳ɹ�
	{"ReturnPlayerSoldGoodsListBegin",""},
	{"ReturnPlayerSoldGoodsList", "dsIIdII"},		--����������Ʒ�б���������Ʒ���ͣ���Ʒ���ƣ���Ʒ��Ŀ��index, ��Ʒid
	{"ReturnPlayerSoldGoodsListEnd", ""},			--����������Ʒ�б����
    {"ConcealOrNotPlayersTradeRequest", "b"},         --�ܾ�������ҽ�������ɹ�
  --��ҽ���
	{"GotTradeInvitation","Is"},              --֪ͨ����н������󣻲���������������ID������������
	{"ReturnChoosedTradeItem","IssId"},        --��ʾ����������Ҫ���׵���Ʒ����������Ʒ��ʾ�ڽ�������λ�ã���Ʒ���ͣ���Ʒ���ƣ�Ҫ���׵���Ʒ��Ŀ, ��Ʒid
	{"ReturnInviteeChoosedItem","IssId"},      --��ʾ���ױ�������Ҫ���׵���Ʒ���������ڽ�������λ�ã���Ʒ���ͣ���Ʒ���ƣ�Ҫ���׵���Ʒ��Ŀ, ��Ʒid
	{"ReturnChoosedTradeMoney","d"},          --��ʾ���������߽��׵Ľ����Ŀ�������������Ŀ
	{"ReturnChoosedInviteeTradeMoney","d"},   --��ʾ���ױ������߽��׵Ľ����Ŀ�������������Ŀ
	{"ReturnDenyedTrade",""},                 --֪ͨ��ҶԷ��ܾ����ף�
	{"ReturnAgreeToTrade","I"},               --֪ͨ��ҶԷ����ܽ��ף�  
	{"ReturnCancelChoosedItemSuc",""},        --֪ͨ���ȡ��������Ʒ������ɹ���
	{"ReturnResetItemList","IIsId"},           --���ظ�����µĽ����б�ȡ��ĳ��Ҫ���׵���Ʒ�󣩣���������Ʒ��ʾ�ڽ�������λ�ã���Ʒ���ͣ���Ʒ���ƣ�Ҫ���׵���Ʒ��Ŀ, ��Ʒid
	{"ReturnResetItemListEnd","I"},            --���ظ�����µĽ����б�ȡ��ĳ��Ҫ���׵���Ʒ�󣩽���
	{"ReturnReplaceItem","IssIdIIII"},             --�滻ĳ�����׵���Ʒ������������������£�����������Ʒ��ʾ�ڽ�������λ�ã���Ʒ���ͣ���Ʒ���ƣ�Ҫ���׵���Ʒ��Ŀ, ��Ʒid
	{"ReturnLockedTrade",""},                 --֪ͨ��ҶԷ��Ѿ������˽���
	{"ReturnCanceledTrade",""},               --֪ͨ��ҶԷ�ȡ���˽���
	{"RetSubmitedTrade",""},                  --֪ͨ��ҶԷ��ύ�˽���
 	{"RetGetTradeCess","IIi"}, 
 	{"ReturnChoosedTradeItemError", "II"},	  --Ҫ���׵���Ʒ���������ף�������viewIndex
  	{"ReturnReplaceItemError", "II"},			  --replace������Ʒ���ɹ�
  	--�õ������������׵���Ϣ
  	{"GetPlayersTradeRequestBegin", ""},	  --��ʼ֪ͨ������������
  	{"GetPlayersTradeRequest", "Is"},		  --���Ͷ�������׵������Ϣ�����������id�� �������
  	{"GetPlayersTradeRequestEnd", ""}, 		  --����֪ͨ������������
  	
  
  --���۽�������1��2��3��4�ֱ�Ϊ�������б��չ��б�������Ʒ���չ���Ʒ  
  {"RetCSMTotalNo",     "II"},                --��Ʒ�б�����Ŀ�����������λ�ã���Ʒ����Ŀ
  {"RetCSMOrderList",   "dIsssdIdd"},                --�������˷�����ƷҪ��ʾ�������Ϣ�����������λ�ã�����ID����ɫ���ƣ���Ʒ���ͣ���Ʒ���ƣ��۸���Ŀ����ֹʱ��, ��Ʒid
  {"RetCSMOrderListEnd","I"},                --��Ʒ�б��ؽ��������������λ��
  {"RetCSMBuyOrderFinishNum", "II"},				 --��ɫ�չ��б���ʾ�����Ŀ������������ID�������Ŀ
  {"RetCSMAddOrderSuc","Ib"},                 --�����Ʒ�����ɹ�,���������λ�ã��Ƿ�ɹ�
  {"RetCSMCancelOrderSucc","Ib"},               --ȡ����Ʒ�����ɹ�,���������λ�ã��Ƿ�ɹ�
  {"RetCSMTakeAttachmentError", "b"},           --��ȡ��Ʒ��ɣ��������Ƿ���ȡ�ɹ�
  {"RetCSMPay2OrderError", "b"},                 -- ���չ��߳��۷�����������Ʒ
  {"RetCSMBuyOrderError", "I"},                --�����Ƿ�ɹ����������Ƿ�ɹ�
  {"RetIfHaveItemToTake", ""},                 --�չ���Ʒ�������Ƿ��п���ȡ��Ʒ
  {"RetGetCSMRememberPrice", "II"},				--�����ϴ���ҳ��ۻ��չ�����Ʒ�۸񣬲��������no�����ۻ����չ���壩����Ʒ�۸�
  {"RetCloseCSMWnd", ""},
--������ͨϵͳ
 	{"ReturnTicketToTicket", "bii"},							--Ӷ���Ҷһ��󶨵�Ӷ���� �������Ƿ�ɹ� ���ӵ�Ӷ���ң����ӵİ󶨵�Ӷ����
 	{"ReturnTicketToMoney", "bii"},								--Ӷ���ұҶһ���� �������Ƿ�ɹ������ӵ�Ӷ���� ���ӵĽ��
 	{"ReturnMoneyToMoney", "bii"},								--��ұҶһ��󶨵Ľ�� �������Ƿ�ɹ�  ���ӵĽ�ң����ӵİ󶨵Ľ��

--����ӳ��
	{"ReturnAllKeyMaps",				"ssI"},		--�������а���ӳ��Key��
	{"ReturnAllKeyMapsEnd",				""},		--���ؽ���֪ͨ
	{"ReturnSetKeyMap",					"b"},		--����֪ͨ���ð���ӳ������Ƿ�ɹ�
	{"ReturnMouseKey",					"IIIIIII"},	--��������������
	{"ReturnChangeMouseCtrlBeforeGame",	"b"},		--��������Ϸ֮ǰ���е��������
	
--���а�
	{"RetSortListBegin",	""},		--��ʼ�������а���Ϣ
	{"RetSortList",			"IisCd"},	--�������а���Ϣ
	{"RetSortListEnd",		"ss"},		--�������а���Ϣ����
--���ϵͳ
	--������
	{"ReturnRequestCreateTong",	""},			--�������֮ǰ���жϷ���
	{"ReturnCreateTong",		""},		
	{"ReturnJoinInTong",		""},			--���ؼ���Ӷ����
	
	--��������id�������ƣ��������ƣ��ŵ�ǰ���������������ޣ��ŵȼ������������Ź�ѫ�����ʽ��ŵ�ǰ���ݣ����������ޣ�����ּ
	{"ReturnGetTongInfo", "IssIIIIIIIISHHHIIIs"},		--�����������Ϣ
	
	{"ReturnGetTongMemberInfoStart", ""},		--���س�Ա��Ϣ��ʼ
	{"ReturnGetTongMemberInfo", "IsIIIIIIIIs"},	--���س�Ա��Ϣ����������ɫid����ɫ���ƣ��ڰ���е�ְλ���ﹱ���ȼ���ְҵ����ɫ����,���������飬�Ƿ�����,�Ź�,��ѫ
	{"ReturnGetTongMemberInfoEnd", "I"},		--���س�Ա��Ϣ����,�����������Ա����
	{"ReturnGetTongRequestInfoBegin", ""},	
	{"ReturnGetTongRequestInfo", "IsIIII"},	--����������Ϣ  ������������id�����������֣������ߵȼ���������ְҵ��
	{"ReturnGetTongRequestInfoEnd", "I"},		--����������Ϣ������������������Ϣ��������
	{"ReturnBeJoinTong", "b"},					--�����Ƿ�ͬ������� ������ͬ���ܾ�
	{"ReturnPosChanged", "H"},					--�����ڰ���е�ְλ
	{"ReturnChangePos", "b"},					--�����޸�ְλ�Ƿ�ɹ����������Ƿ�ɹ�
	{"ReturnGetTongLog", "IIS"},				--������־��Ϣ��������ʱ�䣬���ͣ�����
	{"ReturnGetTongLogEnd", ""},				--������־��Ϣ����
	{"ReturnGetAllTongSomeInfo", "IsIIsIIII"},		--�������а����Ϣ�����������id�����ƣ�����
	{"ShowFoundTong","s"},             --��ʾ��ѯ����С��
	{"ReturnGetAllTongSomeInfoEnd", ""},		--�������а����Ϣ����
	{"ReturnGetAllPlayerSomeInfo", "IsIIfII"},		--��������δ��������ҵ���Ϣ�����������id�����ƣ��ȼ���ְҵ��ս����������������
	{"ShowFoundPlayer","s"},             --��ʾ��ѯ�������
	{"ReturnGetAllPlayerSomeInfoEnd", ""},		--��������δ�����������Ϣ����
	{"ReturnChangeTongPurpose", "b"},			--�����޸İ����ּ�Ƿ�ɹ�
	{"ReturnKickOutOfTong", "b"},				--���ؿ�������Ա�Ƿ�ɹ�
	{"ReturnBeOutOfTong", ""},					--֪ͨ�뿪�����˹ر����
	{"ReturnTongResign", "b"},					--��ְ�Ƿ�ɹ�
	{"ReseiveInviteJoinTong", "Iss"},			--��ļ
	{"ReseiveResponseBeInviteToTong", "sb"},	--��Ӧ��ļ
	{"ReseiveRecommendJoinTong", "ISS"},
	{"ReturnPreChangeTongName", ""},
	{"ReturnGetTongRelativeLine", "H"},			--����Ӷ���ŵ�ǰս��
	{"ShowTongMsg","I"},							--֪ͨ����Ӷ��С�����ͳɹ�
	{"TongTypeChanged","I"},					--֪ͨС�����͸ı�
	{"OnRequestJoinInTong",""},
	{"ReturnTongContributeMoneyInfo","III"}, --���ؾ�Ǯ���
	{"ReturnContributeMoney",""},
	{"RetChangeInfoWnd",""},   ---���ص������
	
	
	-----����ĸĳ�Ӷ��С����
	-----���������ڵ�Ӷ����
	{"ReturnRequestCreateArmyCorps",""},		--���󴴽�Ӷ���ųɹ�
	{"ReturnCreateArmyCorps",""},						--����Ӷ���ųɹ�
	{"OnArmyCorpsPosChanged","I"},					--֪ͨȨ��
	{"ReturnArmyCorpsInfo","sIISsIII"},			--����Ӷ���Ż�����Ϣ
	{"ReturnPreChangeArmyCorpsName",""},
	{"OnArmyCorpsNameChanged","S"},         --�����ı�
	{"OnArmyCorpsPurposeChanged","S"},			--��ּ�ı�
	{"OnInviteJoinArmyCorps","Iss"},				--��������
	{"ReturnArmyCorpsTeamInfoBegin","II"},	--����Ӷ��С����Ϣ
	{"ReturnArmyCorpsTeamInfoEnd",""},			--����Ӷ��С����Ϣ
	{"ReturnArmyCorpsTeamInfo","IssIIIIII"},	--����Ӷ��С����Ϣ
	{"OnLeaveArmyCorps","b"},								--���ŷ���
	{"OnKickOutOfArmyCorps","b"},						--�߳��ŷ���
	{"OnBeKickOutOfArmyCorps",""},					--�߳���֪ͨ���ߵ�������
	-----Ӷ����end
	
	
	--�����Դ
	{"ReturnRequestAddTongBuyOrder", ""},
	{"ReturnGetTongSellResInfo", "III"},
	{"ReturnGetTongFethResInfo", "II"},
	{"ShowTongSellResWnd", "Ib"},
	{"ShowMyResOrderWnd", ""},
	{"ShowTongResTransWnd", ""},
	{"RetIssueFetchQueryWnd", "sIIII"},
	
	
	{"ReturnGetTongMarketOrderInfoListBegin", ""},
	{"ReturnGetTongMarketOrderInfoList", "SSSII"},
	{"ReturnGetTongMarketOrderInfoListEnd", ""},
	{"ReturnGetTongMyResOrderInfo", "SSSII"},
	
	--��Ὠ��
	{"ReturnGetCreatingBuildingitemInfo", "sIIsIsIsIsIsIsI"},	--���������ڽ�������ƣ��õ�ʱ�䣬id��6���ȴ���������ơ�id
	{"ReturnGetTongBuildingList", "IsffIII"},	--���ذ�Ὠ����Ϣ������������id�����ƣ������꣬�����꣬��ǰ������״̬, ���ȼ���
	{"ReturnGetTongBuildingListEnd", ""},		--���ؽ�����Ϣ����
	{"ReturnCreateBuilding", "b"},				--���콨���ɹ�
	{"ReturnRemoveBuilding", "b"},				--��������ɹ�
	{"ReturnGetCreatingProdItemInfo", "sIIsIsIsIsIsIsI"},		
	{"TongMoneyMsgToConn", "II"},		
	{"FilterAvailableBuildingItems","I"}, --����Ӷ��С�ӵȼ�����ɸѡ�ɽ�����Ŀ,������Ӷ��С�ӵȼ�				
	--���Ƽ�
	{"ReturnGetTongFightScienceInfoBegin", "CC"},	--����Ӷ���ſƼ���Ϣ��ʼ
	{"ReturnGetTongFightScienceInfo", "sCII"},		--����Ӷ���ſƼ���Ϣ
	{"ReturnGetTongFightScienceInfoEnd", ""},		--����Ӷ���ſƼ���Ϣ����
	
	--���ս��
	{"ReturnGetTongChallengeInfoListBegin", "HH"},
	{"ReturnGetTongChallengeInfoListEnd", ""},
	{"ReturnGetTongChallengeInfoList", "ssII"},	--����Ӷ������ս�б���Ϣ�������������ƣ��ų����ƣ�ս����פ��
	{"ReturnTongChallengeMemberListInfoBegin", ""},
	{"ReturnTongChallengeMemberListInfo", "sIIII"},
	{"ReturnTongChallengeMemberListInfoEnd", ""},
	{"ReturnTongLevelInfo", "b"},
	
	{"ReturnTongWarMemberListInfoBegin", ""},
	{"ReturnTongWarMemberListInfo", "sIIIII"},
	{"ReturnTongWarMemberListInfoEnd", ""},
	{"ReturnTongWarAwardListInfoBegin",""},
	{"ReturnTongWarAwardListInfo","sIIII"},
	{"ReturnTongWarAwardListInfoEnd",""},
	{"ReturnTongGetExploitSum", "I"},
	{"ReturnCampGetExploitSum","III"},
	{"ShowNoneAwardWnd",""},
	{"ShowNoTongNoneAwardWnd",""},
	{"ShowNoPlayerGetAwardWnd",""},
	{"ReturnGetTongBattleListInfoBegin", ""},
	{"ReturnGetTongBattleListInfo", "ssII"},
	{"ReturnGetTongBattleListInfoEnd", ""},
	{"ReturnTongMonsAttackListInfoBegin", ""},
	{"ReturnTongMonsAttackListInfo", "sII"},
	{"ReturnTongMonsAttackListInfoEnd", ""},
	{"ReturnSendChallenge", "b"},					--���ذ����ս��Ϣ���������Ƿ�ɹ�
	{"ShowTongChallengeStatisticsWnd", "sIIIsIII"},
	--����е
	{"ReturnGetTongArmList", "IssIIIsI"},		--���ؾ�е��Ϣ����������еid�����ͣ����ƣ��ȼ����;ã�״̬����ȡ�����֣������õľ�е�⽨��id
	{"ReturnGetTongArmIdAndNum", "II"},			--���ؾ�е������Ϣ������������id���Ѿ���ռ�õ�����
	{"ReturnGetArmInfoEnd", ""},				--���ؾ�е��Ϣ���
	{"ReturnCreateArm", "b"},					--���������е���Ƿ�ɹ����������Ƿ�ɹ�
	{"ReturnDestroyArm", "b"},					--���ػ�е�������Ƿ�ɹ����������Ƿ�ɹ�
	{"ReturnGetArm", "b"},						--������ȡ��е���Ƿ�ɹ�
	{"ReturnRenameArm", "b"},					--�����޸Ļ�е�������Ƿ�ɹ�
	{"ReturnGiveBackArm", "b"},					--���ع黹��е���Ƿ�ɹ�
	{"ReturnForciblyGiveBack", "b"},			--����ǿ�ƹ黹��е���Ƿ�ɹ�
	{"ReturnBeRepairArm", "b"},					--��������/ֹͣ�����е���Ƿ�ɹ�
	--�����Դ
	{"ReturnGetTongAllResInfo", "II"},		--���ذ����Դ��Ϣ������������Ǯ��������Դ����
	{"ReturnGetTongAllResInfoEnd", ""},			--���ذ����Դ��Ϣ����
--	{"ReturnContributeRes", "b"},				--���ؾ�����Դ�Ƿ�ɹ�
	{"ProvideParam", "s"},

   {"NotifyJoinFightInTriangle", ""},   --
   {"RetRequestFightInTriangle","b"},
   {"RetCancelFightInTriangle",""},
   {"RetAgreedFightInTriangle","b"},
--�̻�ϵͳ
	--�̻����
	{"RetOpenCofCNpcDialogBegin",""},			-- ׼����ʼ���̻��б���Ϣ��
	{"RetOpenCofCNpcDialog","IsI"},				-- ��ĳnpc���̻��б���Ϣ���������̻�id���̻����ơ��̻��Ա����
	{"RetOpenCofCNpcDialogEnd",""},				-- ���̻��б���Ϣ����
	{"RetRequestCreateCofc", ""},				-- �����̻�ɹ�									
  	{"RetGetCofcInfo","ssIIIIIIIIIIsIIs"},  	-- �̻��������г�����������������Ϣ��--�������Լ���ְλ���̻����ƣ��ȼ����ʽ���ҵָ���������̻�������������������ֵ��
  																						--��Դ�����ӳɣ������̻�ӯ���������̻�ӯ����������ռӳɣ�Ŀǰ���������Ƽ����ƣ� ���пƼ��ȼ����ܿƼ��ȼ����̻���ּ
  								
  	{"RetGetCofcQuestInfo", "s"},				-- �̻��������е�������Ϣ����������������
  	{"RetGetCofcQuestInfoEnd", ""},				-- ����������Ϣ����
  	{"RetModifyCofcPropose", ""},				-- �޸��̻���ּ�ɹ�	
  	
  	--�̻��Ա���
  	{"RetGetCofCMembersInfoBegin", "" },		--׼����ʼ���̻��Ա��Ϣ
  	{"RetGetCurCofCMembersInfo","IssIssssII"},		--���̻��Ա��Ϣ�������������Ϣid, �������, ְλ, �ȼ�, ����, ְҵ�����������¶�̬�����飬�Ƿ�����
  	{"RetGetCofCMembersInfoEnd", "I"},			--���̻��Ա��Ϣ��������ʼ��ʾ�ڿͻ���,���������������Ŀ
  	
  	{"RetGetCofCAppInfoBegin",""},				--׼����ʼ����������̻�������Ϣ
  	{"RetGetCurCofCAppInfo","IsIssss"},			--���̻���������Ϣ�������������Ϣid, �������,, �ȼ�, ����, ְҵ, ������, ����
  	{"RetGetCofCAppInfoEnd","I"},				--���̻���������Ϣ��������ʼ��ʾ�ڿͻ���,���������������������Ŀ
	{"RetKickOutCofCMember",""},        --����Ҵ��̻���ɾ��֮��֪ͨ�ͻ���
		
	--�̻�Ƽ����
	{"ReturnGetCofcTechnologyInfo", "III"},			--���̻�Ƽ������Ϣ���������Ƽ�Id ,�Ƽ�����, �Ƽ��ȼ�, ���пƼ��ȼ�, �ܿƼ��ȼ���
	{"ReturnGetCofcTechnologyInfoEnd", "I"},				--���̻�Ƽ���Ϣ�������������������������Ƽ�id

	--�̻���־
	{"ReturnLogBegin",""},						--�����̻���־��Ϣ��ʼ
	{"ReturnLog","sII"},                --�����̻���־��Ϣ ��������־���ݡ���־����(0-��Ա 1--���� 2--�Ƽ� 3--����)������ʱ��
 	{"ReturnLogEnd",""},                --�����̻���־��Ϣ����
 	
	--�̻��Ʊ
	{"RetGetCofCStockKMapBegin", ""},			--��Ʊ���׼�¼��ʼ
	{"RetGetCofCStockKMap", "III"},				--��Ʊ���׼�¼��Ϣ������ʱ�䡢�������������ۼ��ܶ�
	{"RetGetCofCStockKMapEnd", "II"},				--��Ʊ���׼�¼����

	{"RetGetCofCStockInfoBegin",""},			--׼����ʼ���̻��Ʊ��Ϣ
	{"RetGetCofCStockInfo","IsIIsIIIII"},		--��ʼ����Ʊ�����Ϣ,��������Ʊ���ţ����ƣ�ִ�������ɱ����Ƿ����������������ۣ���������͵ģ�������ۣ���������ߵģ�����߼ۣ���ͼ�
	{"RetGetCofCStockInfoEnd",""},				--���̻��Ʊ��Ϣ������
	
	{"RetGetCofCStockOrderListBegin", "I"},		--�õ���Ʊ�Ķ����б���������Ʊ����
	{"RetGetCofCStockOrderList", "IIII"},		--�õ���Ʊ�Ķ����б����������ͣ�0Ϊ�򵥣�1Ϊ�������������š��۸�����
	{"RetGetCofCStockOrderListEnd", "II"},		--���ܹ����������ܹ���
	
	{"RetGetCofCStockMyDealingInfoBegin", ""},			--�õ��ҵĹ�Ʊ������Ϣ	
	{"RetGetCofCStockMyDealingInfo", "IIsIIIsIIII"},		--�õ��ҵĹ�Ʊ������Ϣ��������������������ˮ�š����롢���ơ��ҵ����������͡��ҵ��۸��Ƿ������������򡢳��С��ɱ�
	{"RetGetCofCStockMyDealingInfoEnd", ""},
	
	{"RetGetCofCFinancialReport", "sIssIIIIIIIIIIsIsIsIsIsI"},	--��������Ʊ���ƣ���Ʊ��ţ��ڼ俪ʼʱ�䣻�ڼ����ʱ�䣻
																--	�̻�ȼ����̻����ʽ��ڼ����룻�۳���Ʊ���ڼ佻�������������������ҳ��й������ҵĳ��гɱ���
																--	�̻��������̻��Ծ�ȣ�����Ϊ��һ�������ɶ��Ľ�ɫ���ͳ��й���
	{"RetGetCofcMyHaveInfo", "II"},				--�õ��Ҷ�ĳ֧��Ʊ�ĳ�������������������������ɱ�
	{"RetDeleteOrder","b"},              --������������ͻ��˷��ز����ɹ����
	
--Ŀ���������
	{"RetAimInfoEnd",        "I"},               --֪ͨ�ͻ�����ʾĿ���������;true--Ŀ��������塢false--С�ӳ�Ա�������
	{"RetFightingEvaluationInfoInfo","ffffIIf"},
	{"RetAimFightingEvaluationInfoInfo","IffffIIf"},
	{"RetAimEquipInfo",	"CsdCI" },				--��ʼ����̬װ��
--װ������
	{"ReturnIdentifyResult","b"}, --֪ͨ�ͻ��˼����ɹ����
--����Ƭ�趨
	{"ReturnArmorPieceEnactment","b"}, --֪ͨ�ͻ����趨�ɹ����
	
--����ֿ����
	{"ReturnGetCollectiveBagOnePageItemListStart", "I"},				--���زֿ���Ʒ��Ϣ��ʼ�����������ͣ�ÿҳ�����������
	{"ReturnGetCollectiveBagOnePageItemListEnd", "II"},				--���زֿ���Ʒ��Ϣ��ϣ��������ֿ����ͣ�ҳ��
	{"ReturnCollectiveBagMoveItemSelf", "bII"},						--���ؼ���ֿ��ڲ���Ʒ�ƶ��Ƿ�ɹ������������ͣ�ҳ��
	{"ReturnCollectiveBagAddItemFromOther", "bII"},					--���شӸ��˰����϶���Ʒ����������Ƿ�ɹ����������Ƿ�ɹ����������ҳ��������
	{"ReturnBagAddItemFromCollectiveBag", "bII"},					--���شӼ�������϶���Ʒ�����˰����Ƿ�ɹ�
	
--������Ʒ�������
	{"RetTakeAllBoxitemDrop",			"I"},					--��ȡ���к�����Ʒ�������Ʒ boxitemID
	{"RetGetBoxitemInfoBegin",			""},					--׼����ʼ��ʾ�������Ʒ
	{"RetGetBoxitemInfo",				"IssI"},					--��������Ʒ�������Ʒ��Ϣ����������Ʒ���ͣ���Ʒ���ƣ���Ʒ��Ŀ
	{"RetGetBoxitemInfoEnd",			"III"},					--����Ʒ��Ϣ������������������Ʒ��ҳ������ǰҳ��,������Ʒid
	
--��������
	{"ReturnProduceByTwoMaterials",					"bIsd"},	--����������������Ʒ�Ƿ�ɹ�,��Ʒ����,����,ID
	{"ReturnProduceByProductName",					"b"},		--��ҩ������������Ʒ�Ƿ�ɹ�----����ĳ������
	{"ReturnGetLiveSkillHasLearnedBegin",			""},	--��ʼ�����������Ϣ
	{"ReturnGetLiveSkillHasLearned",				"sII"},	--�����������Ϣ
	{"ReturnGetLiveSkillHasLearnedEnd",				""},	--�����������Ϣ����
	{"ReturnLiveSkillRefine",						"bIsI"},--��������Ƿ�ɹ�
	{"ReturnGetPracticedInfoBegin",					""},	--��ʼ������������Ϣ
	{"ReturnGetPracticedInfo",						"sI"},	--������������Ϣ
	{"ReturnGetPracticedInfoEnd",					"sI"},	--������������Ϣ����
	{"ReturnGetPracticedInfoForNpcPanelBegin",		""},	--��ʼ������������Ϣ
	{"ReturnGetPracticedInfoForNpcPanel",			"sI"},	--������������Ϣ
	{"ReturnGetPracticedInfoForNpcPanelEnd",		"sI"},	--������������Ϣ����
	{"ReturnGetLiveSkillExpert",					"sI"},	--����ר����Ϣ
	{"ReturnGetProductsCanMakeBegin",	"sI"},	--�õ��������ҩƷ��ʼ
	{"ReturnLearnNewDirection",			"sss"},	--�õ��������ҩƷ����������Ʒ����
	{"ReturnGetProductsCanMake",			"s"},	
	{"ReturnGetProductsCanMakeEnd",		""},	--�õ�����⿵�ʳƷ����
	{"ReturnLiveSkillExp",							"Is"},	--�õ����ܾ��顣���������飬������
	{"ReturnGetLiveSkillProdRemainCDTime",			"sI"},	--����ʣ����ȴʱ��
--������ֻ�
	{"CultivateFlowerStart",					"sI"},
	{"UpdateFlowerState",							"H"},		--���»���״̬(����,����,ȱ����)
	{"UpdateFlowerHealthPoint",				"i"},		--���»�����ֵ
	{"AddFlowerHealthPoint",				"i"},		--���»�����ֵ
	{"UpdateFlowerGetCount",				"i"},			--���»����ջ����
	{"CultivateFlowerSkillBtnEnable", "i"},		--���»��ܼ�����ȴʱ��
	{"PlayFlowerSkillEffect", "i"},		--���»��ܼ�����ȴʱ��
	{"CultivateFlowerSkillCoolDown",	"i"},
	{"FlowerGiveItemCoolDownCD",	""},
	{"FlowerEnd",	""},
	{"ShowGatherItemsWnd",	"IsIIs"},
-- С��Ϸ
 	{"BeginSmallGame","sI"},--֪ͨ�ͻ��ˣ�С��Ϸ��ʼ
 	{"ExitSmallGame",""},--�˳�С��Ϸ
 	{"RetMsgBeginSmallGame","sI"},--������Ϣ,���߿ͻ����Ƿ���С��Ϸ
 	{"CloseSmallGameMsgWnd",""},--������С��Ϸ����Ӧʱ��
 	{"PlayerSmallGameSuccFx","sI"},--С��Ϸ�ɹ�ͬ����Ч

--��ϵͳ
	{"ReturnSaveBattleArrayPos", "Id"},				--���ر�����
	{"ReturnGetAllBattleArrayPosInfo","IsIIIIII"},	--�������е�������Ϣ
	{"ReturnGetAllBattleArrayPosInfoEnd",""},		--����������Ϣ��β��־
	{"ReturnGetAllBattleArrayMemPosInfo","IIIIII"},	--��������������Ϣ
	{"ReturnGetAllBattleArrayMemPosInfoEnd",""},	--����������Ϣ��β��־
	{"ReturnSaveBattleArrayMemPos", "b"},           --���ر�����
	{"ReturnRevertToBattleArrayBook","b"},			--�����󷨼���ת��������Ľ��
	{"ReturnDeleteBattaleShape","b"},				--����ɾ��������Ϣ�ɹ����ı�־
	{"RetCommonBattleArrayBookInfo","diiiii"},		--���ظ���Ҷ�̬��Ϣ����ļ�¼
--{"RetCommonBattleArrayBookInfoEnd",""},
	{"ReturnSaveBattleArrayShortCutIndex", "b"},	--���ر����󷨿����λ��
	{"ReturnGetAllBattleSkill","Is"},				--�����󷨼���
	{"RetCloseBattlePanel","I"},						--�رձ������͵���� ��������ƷID
	
	
	--������
	{"RetCheckCamelState",			"sb"}, --��֤״̬�ķ���
	{"RetPhysicalStrengh",		"I"},	 --��������
	{"RetPhysicalState", 			"b"},		--������ɺ�֪ͨ�ͻ��˹ر����
	--ʹ����Ʒ
	{"CreatItemSelector","IsI"},
	{"SetItemCoolDownTime","sII"},
	
--���鶯����Ӧ
	{"OtherPlayFacial", 		"Is"},			--���鶯����Ӧ���������Է���ɫID�����Ŷ�����)
	{"NpcDoActionState", 		"Iss"},			--NPC�����鶯��, ������NpcID�� ������� ������)
	{"DoFacialAction", "ssI"},	
	{"PlayFacialActionFailed", "s"},
	-- ��������
	--{"DoAlternatingAction",		"IIss"},			-- ��ս���Ľ�������������(���ID, ����ID������״̬)
	{"RetHoldThingName",	"Is"},--����OBJ��,֪ͨ�ͻ���ʹ���Ǹ�����
	{"RetHoldThingTimeOver", "I"},--����OBJ,��ʱ��
	{"OpenXLProgressWnd","I"},--���������Ĵ���
	{"CloseXLProgressWnd",""},--�ر������Ĵ���
	--�ʴ�ϵͳ
	{"RetShowEssayQuestionWnd","ssI"},--��ʾ�����	����(����GAME��������  ������ƣ�ȡ�ⷶΧ �� ȡ������ ��������)
	--{"RetInitEssayQuestion","s"},		--�����ʼ����Ŀ	����(������ƣ������ID,��������)
	{"RetAnswerResult","Ibs"},												--�ش��ͻ��˴����� ����( ����ID,������ ) yy
	{"ShowBoxItemWnd","b"},						--������ϵͳ���ڴ򿪺���ʱ(����.  b����Ľ��)
	{"InitBoxItemWnd","b"},           
	-- �ʴ�ϵͳ����
	
	---------------------------------------
	{"WeekAwardMsgFromJfs",""},--ÿ�ܸ���������Ϣ
	
	--ս��ͳ�����
	{"OpenFbDpsInfoWnd",""},
	{"CloseFbDpsInfoWnd",""},
	{"UpdateMemberDpsInfo", "sII"},
	{"DeleteMemberDpsInfo", "s"},
	
	--�����еļǷְ�
	{"RetOpenFbActionWnd","si"},
	{"RetCloseFbActionWnd","s"},
	{"RetOpenCountScoreWnd","sIs"},
	{"RetCloseCountScoreWnd","s"},
	{"RetInsertFbActionToQueue","sbI"},
	{"RetDelQueueFbAction","sb"},
	{"RetInitFbActionQueueWnd","s"},
	{"RetSetJoinBtnEnable","s"},
	{"RetInFbActionPeopleNum","sI"},
	{"RetIsJoinFbActionAffirm","sII"},
	{"RetFbActionOverTime","s"},
	
	{"RetShowRollMsg","ss"},
	
	--����ɱ
	{"RetShowDaTaoShaWnd","I"},
	{"RetSetSceneStateForClient","H"},
	
	{"DtsUpdateAllInfo","IIII"},
	{"DtsUpdateLivePlayerNum","I"},
	--������
	{"RetShowJiFenSaiWnd","I"},--����������
	{"RetSetJFSPlayerCamp",""},
	{"RetShowJiFenSaiInfoWnd","IIIfIII"},
	--{"RetJFSAddMemberInfo","II"},
	{"RetJFSUpdateMemberInfo","II"},
	--{"RetJFSAllMember","III"},
	{"SetPlayerAlphaValue","I"},--�������͸����
	--������ᱦ
	{"RetShowDaDuoBaoWnd",""},
	{"RetShowDrinkWnd",""},
	--Ӷ��ѵ���
	{"RetShowYbEducateActionWnd",""},
	{"RetIsContinueYbXlAction","Ib"},
	{"RetOverYbXlAction","IsI"},
	{"RetShowYbEducateActInfoWnd","sII"},
	{"RetShowSmallActInfoWnd","I"},
	{"SendResumeNum","bIII"},
	{"RetUpDateSmallInfo",""},
	{"RetCloseYbEducateActInfoWnd",""},
	{"RetStopXiuXingTaBgm",""},
	{"RetUpdateYbEduActInfo","IsfI"},
	{"SendPlayXiuXingTaBgm","I"},
	{"RetBeginYbEduActGame","I"},
	{"RetYbEducateActShowMsg","IIII"},
	{"RetYbEducateActShowLoseGameMsg","IIII" },
	{"RetRecordGameInfo","sI" },
	
	{"ActionAllReady","IIs"},
	{"WaitOtherTeammate","s"},
	{"ChangeActionWarModel",""},
	
	--Boss����ս
	{"RetShowBossBattleWnd",""},
	{"RetShowBossBattleInfoWnd","sb"},
	{"RetUpdateBossBattleInfoWnd","I"},
	{"BossBattleKillBossMsg","ssss"},
	{"BossBattleJoinFailMsg","s"},
	{"RetEnterBossBattle", "s"},
	{"RetLeaveBossBattle", "b"},
	{"RetWaitBossBattle", ""},
	
	--�Ⱦ����
	{"BeginDrinkShoot", ""},
	{"UpdateDrinkShootTurnArrow", "II"},
	
	--����ʱ����
	{"RetShowDownTimeWnd","I"},--�򿪵���ʱ����
	{"RetCloseDownTimeWnd",""},--�رյ���ʱ����
	-----------------------------------------
	
	{"SpecailItemCoolDown","sIICC"},
	{"SetTickCompassHeadDir","HIII"},
	{"SetCompassHeadDir","HII"},
	{"ClearCompassHeadDir",""},	
	{"UseItemPlayerEffect","ss"},
	{"UseItemTargetEffect","ssI"},
	{"UseItemOnPosEffect","ssIII"},
--	{"SendNpcStateMsg","sss"},
--	{"SendNpcNotStateMsg","ss"},
	{"SetItemGridWndState","IIb"},			--����Ʒ���Ӽ���
	{"OnRClickQuestItem","Is"},
	--����ϵͳ
	{"RetFinishAreaQuest","s"},  ---�������������ƣ�
	{"RetFirstTimeIntoArea","sII"},  ---�������������ƣ�
	{"RetPlayerAreaInfo","sII"},
	{"RetPlayerSceneAreaInfo","s"},---�������������ƣ�
	{"SendTeammatePos","IsII"}, -- ��������巵�ض���λ��
	{"SendTongmatePos","IsIIs"}, -- ��������巵�ض���λ��
	{"CheckIsNeedSendTeammatePos",""},--���ʱѯ�ʿͻ����Ƿ���Ҫ���Ͷ���λ��
	{"CheckIsNeedSendTongmatePos","I"},--���ʱѯ�ʿͻ����Ƿ���Ҫ���Ͱ���λ��
	{"StopSendTeammatePos",""},  -- �뿪������������ٷ��Ͷ���λ��
	{"StopSendTongmatePos",""},  -- �뿪������������ٷ��Ͱ���λ��
	{"StopSendFbPlayerPos", ""},
	{"HideLeavedTongmatePos","I"},
	{"HideLeftFbPlayerPos", "I"},
	{"HideLeavedTeammatePos","I"},
	{"SendFbPlayerPos", "ISIISIb"},

	--NPC�Ի�ϵͳ
	
	--��Ϸ����
	{"ReturnGetUISetting", "bbbbbbbbbbbbbb"},	--����UI����
	{"ReturnGetGameSettingInfo", "iiiiiiI"},	--������Ϸ���õ���Ϣ
	{"RetQuestSortSettingInfo",	"I"},			--��Ϸ������׷������������Ϣ
	{"ReturnNotifyClientLeave", "C"},			--��������������
	{"ChangeToStateNow", "C"},					--���߿ͻ��˿�������ע���ͻ��˴�����		
	{"ChangeSceneErrMsg", "ss"},
	{"RetGMGetSceneGridPos","ss"},
	
	--����Npc��͸����
	{"SetNpcAlphaValue", "IC"},
	
	--���Ƿ����Npc�����
	{"NotifyWhetherTakeOverNpc", "I"},
	{"SetNpcAlphaValue", "IC"},
	--���ؽ�ɫ������ʾ���Ҫ��ʾ����Ϣ
	{"ReturnModifyPlayerSoulNum","I"},--��ͻ��˷��ؽ�ɫ����ʣ�µĻ�ֵ
	{"ReturnModifyPlayerSoulNumSlowly","III"},--��ͻ��˷��ؽ�ɫ����ʣ�µĻ�ֵ
 {"ReturnPlayerPoint","IIIIIIIIIII"},--����֪ͨ�ͻ��ˣ���ɫ����ʣ�µ�7�ֻ��ֵ�ֵ
 {"UpdatePlayerPoint","Ii"},--��ͻ��˷�����ҹ����궫����ʣ��Ļ��� ������֧�����͡�ʣ�����
 {"UpdateComboHitsTimes","I"}, --ͬ��������
 
 --С�������
 {"InitMatchGameCountWnd", "sCIC"},  -- �������    ��ǰ�÷�(�ܵ÷�)  ��ʱ ���� ʣ��ʱ�� �״̬
 {"MatchGameAddTeam","bIs"},--����µĳ�Ա��Ϣ
 {"MatchGameAddTeamMember","bIIs"},
 {"MatchGameRemoveTeam","I"},
 {"MatchGameRemoveTeamMember","II"},
 {"MatchGameShowTeam","I"},
 {"MatchGameShowTeamMember","IIs"},
 {"MatchGameUpdatePlayerScore", "IIIIb"},
 {"MatchGameUpdateTeamScore","IIIb"},
 --{"InsertMatchGameListItem", "I"}, --��������
 {"CloseList", ""},   --�رռǷְ�
 {"RetShowMatchGameSelWnd","Ss"},
 {"BeginGame","I"},      --��Ϸ����ʱ��
 {"PlayHeadEffect","ssI"},      --ͷ����ʾ(ͬ��Ѫ�Ӿ���)
 {"OpenGameCountdownWnd","II"},
 {"CloseGameCountdownWnd",""},
 {"DelNpcFunLinkTbl","s"},
 {"DelNpcFunTbl",""},
 
 {"SetCountdownTime","I"},
 {"SetMatchGameWndTitleText", "I"},
 {"ShowMatchGameStatisticsWnd", "sSII"},
 {"MatchGameSetWaitTime", "I"},
 
 {"SetCanBeSelectOtherPlayer", "b"},
 {"SetSceneState", "b"},
 
 {"GetTiredNess", "S"},
 {"IsDrunk", "b"},
 
 {"SetMoneyTypeBtnCheck", "I"}, --npc�̵��л�������Ʒ��֧����ʽʱ�����°����ﵱǰѡ��֧����ʽchkbtn��״̬
 --ϵͳ��Ϣ
-- {"SystemFriendMsgToClient","I"}, --ϵͳ��Ϣ����������ϢId,��Ϣ����
 {"SysMovementNotifyToClient","S"}, --ϵͳ�ͨ�棬��������Ϣ����
 {"OpenGacProfiler", "b"},	-- ���� Lua Profiler
 {"ReturnAimPlayerSoulNum","I"}, -- ����Ҫ�鿴��������ϵĻ�ֵ ��������ֵ��
 {"SendPlayerBossMsg","Isss"}, --��Ҵ���ˢBOSS����

	--Pk����
	{"UpdatePkSwitchState", ""},						--����PKֵ״̬
--/**��PK����**/
	{"InitPkSwitch","b"},
	{"TransferSwitchState","b"},
	{"CreateWarTransprot",""},
	{"CreateMatchGameWnd","s"},
	{"RetGetForageAutoInfo","sII"},
	{"RetShowIssueWnd","I"},
	{"RetOpenFetchWnd",""},
	
	--������Դ��
	{"RetShowCancelWnd",""},
	{"CreateRobTransprot",""},
	{"RetOpenSignQueryWnd","sIIs"},
	{"RetNoneOpenSignQueryWnd","s"},
	{"ShowJudgnJoinWnd","s"},
	{"DelItem",""},
	
	
	--����ӿ�
	{"RetEnterOtherServer","sIIsS"},--����1:ip;����2:�˿�;����3:��ת����������;����4:��Կ; ����5:����������lastMsgId
	{"ChangedInSameSceneSuc", ""},
	
	--ѹ���õ�rpc��Ϣ
	{"ClearActionTimesSucMsg", ""},--������������
	{"ExitMatchGameSuccMsg", ""},--������������
	
	{"ShowAcutionAssignWnd",	"IsIIII"},

	--�������ʰȡ��ʽ
	{"ShowNeedAssignWnd",	"IsIIIHI"},						--�����������
	{"CloseNeedAssignWnd",	"I"},							--�ر����������
	{"ReturnPlayerAppellationInfo",""}, --���ز�ѯ���ĳ�ν���� ����:��ν����
	
	{"HideFBDeadMsgWnd",	""},							--�رո������
	{"HideTeamPVPFBDeadMsgWnd",	""},							--�رո������
		--��ʱ��
	{"TempBagSetGrid",	"Is"},
	{"TempBagClearGrid",	"I"},
	{"OpenTempBag",	""},
	{"CloseTempBag",	""},
	
	{"UpdateHeadInfoByEntityID", "I"},						--����ָ������ͷ����Ϣ
	{"ReturnCharAllAppellationInfo","I"}, --�������н�ɫ��ν
	{"ReturnAddNewAppellation","I"}, --������ӳ�ν
	{"ReturnDelAppellationBegin",""}, --��ճƺ��б�

	{"RetEquipAdvanceInfo", "dIIIIIIIsIIIIIIsssss"}, -- װ��������Ϣ
	{"RetEquipEnactmentInfo","IsIsIsIsI"}, --װ����������
	{"RetActiveJingLingSkill", "I"}, 		--����鼼�ܳɹ��񣬼���ľ��鼼��index
	{"RetActiveJingLingSkillPiece", "dII"}, --����鼤���� ��ƷID������ID��װ����λ
	{"AdvancedEquipReborn","d"},			--���������ɹ� ��ƷID
	{"SetActionCount","sII"}, --���û��Ϣ����ϵĲμӴ���
	{"RetShowActionInfoWnd", "II"},
	{"ReturnGetActionCountExBegin",""},
	{"ReturnGetActionCountEx","sII"},
	{"ReturnGetActionCountExEnd",""},
	{"ReturnGetActionAllTimes", "sI"},
	{"AddActionNum", "sI"},
	{"SetDungeonCount","sI"}, --���û��Ϣ����ϵĲμӴ���
	{"RetShowDungeonInfoWnd", ""},
	{"ShowMercCard","I"},		-- ��ʾ��������Ƭ
	{"RecordMercCard","I"},
	{"InitMercCard",""},
	
	{"LoadSpecialEffect", "ss"},
	{"LoadContinuancelEffect", "ss"},
	{"CancelSpecialEffect", "ss"},
	
	{"UpdateHeadModelByEntityID", "I"},		-- ����ͷ��ģ��
	
	{"UpdateShadowModel", "I"},		--������֪ͨ��Ұ�����
	{"RetEquipDuraValue", "dIIII"},--������װ��id��װ����λ��װ�����;�״̬��0װ����Ч��1װ����졢2װ��������
    {"RetEquipDuraValueInBag", "dIIII"}, --������װ��id,roomindex��pos��װ��curDuraValue, maxDuraValue
    {"RetShowEquipDuraWnd", "b"},--�����������;����˺󴰿ڵ���ʾ���
    {"RetRenewEquipSuc", "IIsd"}, --����װ���ɹ����غ�����������װ����λ��װ��type��װ�����ƣ�װ��id
    {"RenewAllEquipEnd", ""},
    {"RefreshListCtrlInRole", ""},
    {"RefreshListCtrlInBag", ""}, --����װ���ɹ���ˢ����ʾ�б�
  -- �е�ͼ���
  {"SetMatchGameNpcTips", "sS"},
  {"RetShowWarZoneState", "IIs"},
  {"EndSendWarZoneState", ""},
  {"UpdateWarZoneState", "IIs"},
  
  --����LOG
  {"RebornTimeLog", ""},
  {"BornNpcOnMiddleMap", "ssff"},
  {"DeadNpcOnMiddleMap", "ss"},
  {"AreaPkOnMiddleMap", "ssbII"},
  {"RobResWinOnMiddleMap", "sssI"},
  
  --����
	{"ReturnIncubatePetEgg","bss"},
	{"ReturnPetEggPourSoul","IssIsIIIIss"}, --���ػ��޷����ɹ���Ϣ
	{"ReturnCharPetInfo","IssIIIIII"},
	{"ReturnCharPetEggInfo","ss"},
	{"ReturnCharPetInfoEnd",""},
	{"ReturnThrowAwayPet","Ib"},
	{"ReturnChangePetName","Is"},
	{"ReturnThrowAwayPetEgg","s"},
	{"ReturnPreparePet","I"},
	{"ReturnUsePetSkillStone","IsI"},
	{"RetInitPetWndInfoBegin",""},
	--�����̳�
	{"RetHotSaleItemBegin", ""}, 
	{"RetHotSaleItem", "IIsI"},--�����̳���������Ʒ��������������Ʒ�������͡���Ʒtype����Ʒ����
	{"RetHotSaleItemEnd", "I"},--������������Ʒ��������
	{"RetTakeYongBingBi", "I"},--���ص�ǰӵ��Ӷ������Ŀ����������ǰӵ��Ӷ������Ŀ
	
	{"ShowNewDirect", "si"},--������ָ���� ״̬
	{"ShowNewDirectBegin", ""},
	{"ShowNewDirectEnd", ""},
	
	{"UpdateDirectAwardInfo", "s"},--��������Ϊ��
	{"RetEquipIntenBack", "IIII"},--װ��ǿ�����ˣ�������װ���ڰ����е�roomIndex��װ���ڰ����е�pos
	{"RetCancelLeaveGame", ""},--�г���ʱ��ȡ������״̬
	
	{"RetPicInfo", "Ib"},
	
	{"ReturnFightingEvaluation","If"},  --PlayerID,FightingEvaluation
	{"ReturnCharInfo","IsIII"}, 		--PlayerID,PlayerName,PlayerClass,PlayerLevel,PlayerCamp
	{"RetUpdateEquipEffect","I"},
	{"PickOreStart",""},
	{"PickOreEnd",""},
	{"PickOreActionEnd","I"},
	
	{"RetCharCMOrderBegin", ""},   --  ������������ҳ����50������Ϊ1ҳ��
	{"RetCharContractManufactureOrder", "IsssdI"},--��������ܴ���������Ϣ������������id����������ơ������䷽���ơ���ֹʱ�䡢�ֹ���
    {"RetCharCMOrderMaterialInfo", "IIIsI"},--��������ܴ����������������Ϣ������������id���ڼ��ֲ��ϣ�����type������name��������Ŀ
	{"RetCharCMOrderEnd", "I"},
	{"RetAddCMOrderSuc", ""},
	{"RetCancelContractManufactureOrder", ""},
	{"RetCommonCMOrderBegin",""},
	{"RetCommonCMOrderEnd",""},
	{"RetCommonContractManufactureOrder","IssssdI"},--����������ID�����Name���������ơ�����ܷ����䷽���ơ���������ʱ�䡢�ֹ���
	{"RetCommonCMOrderMaterialInfo","IIIsI"},--����������ID���ڼ��ֲ��ϡ�materialType��materialName��materialNum
    {"RetTakeContractManufactureOrder", ""},
	--��������ͻ��˴��ݼ�ʱ���ȸ��µ��ļ��ʹ���
	{"SendMsgToGac", "IsS"},
	{"NotifyGacReply", ""},
	
	--������ֵ���
	{"InitPlayerAfflatusValue", "IIII"},
	{"ReturnExpOrSoulBottleInfo","dII"},
	{"ShowSoulBottleAddSoulMsg","I"},
	{"ReturnBottleState","dI"},
	{"SendResistanceValue","Isffff"},
	{"UpdatePlayerCurOffLineExp", "I"},
	
	{"ReturnUpdateMoneyPayType", ""},
	
	{"RetCreateRoleSucAtRushActivity", ""},--��ע��д�����ɫ�ɹ�
	{"ReturnFinishInfo", "sI"},
	
	
	{"RetEquipRefine", "b"},    --װ������rpc
	{"RetBoxitemOpened", "db"},  --���غ�����Ʒ�Ƿ�򿪹���Ϣ
	{"ReturnNpcShopBuyTipInfo", "II"},--���ش��̵깺����ʱ���Ƿ���ʾ��ʹ����ͨ���..����Ϣ������1����ͨ�̵���ʾ��־��1Ϊ��ʾ��0Ϊ����ʾ����1��ͨ���̵���ʾ��־��1Ϊ��ʾ��0Ϊ����ʾ����
	{"GetBackRoleFail", "I"}, 
	
	{"ShowTransWndInfo", "sIsIIb"},
	
	{"RetLoginConnectStepInfo", "I"}, --��½���ӹ����и������Ӳ�����Ϣ��������msgID
	{"RetLoginCheckUserQueue", "I"}, --��¼�ȴ���֤�ʺŶ���
	{"ReturnCharAddSoulMsg","I"},
	{"ReturnIdentityAffirm","b"},
	{"ReturnLockItemBagByTime","I"},
	{"RetOpenIdentityAffirmWnd",""},
	{"ReturnInitLockItemBagByTime","I"},
	{"RetItemBagLockTimeOut",""},
	{"RetEquipSuperaddRate", "dII"}, --����װ��׷�ӱ���ֵ;������װ��id��װ��׷�ӱ���
	{"RetEquipSuperaddSuc", ""}, --װ��׷�ӳɹ�
	
	{"ReturnMyPurchasingInfoBegin",""}, --����
	{"ReturnMyPurchasingInfo","IsIII"},	--����
	{"ReturnMyPurchasingInfoEnd",""},		--����
	{"RetAddMyPurchasing","bI"},					--����
	{"RetCancelMyPurchasing","bI"},					--����
	{"ReturnPurchasingInfoBegin",""}, --����
	{"ReturnPurchasingInfo","IsIIIIs"},	--����
	{"ReturnPurchasingInfoEnd","I"},		--����
	{"ReturnSellGoods","b"},		--����
	{"ReturnFastSellItemInfoBegin",""}, --����
	{"ReturnFastSellItemInfo","sII"},	--����
	{"ReturnFastSellItemInfoEnd",""},		--����
	{"ReturnFastSellItemOrder","III"},
	{"ReturnFastSellItemOrderFail",""},
	{"GetAveragePriceByItemName","II"},
	
	{"TestDb2Gac", "Is"},
	{"RetOpenTongNeedFireActivity","bI"},
	{"RetCheckNeedFireIsOpen","bI"},
	{"RetAddNeedFireItem","b"},
	{"RetAddFirewoodMsg","sss"},
	{"RetNeedFireActivityEnd","I"},
	{"RetTongNeedFireActivityMsg",""},
	{"YYReturn","S"},
	{"YYLoginFail",""},
	
	{"RetCapableOfBuyingCouponsInfoBegin", ""},
    {"RetCapableOfBuyingCouponsInfo", "IsIISS"},--������sequenceID, name, price, smallIcon, desc, url
	{"RetCapableOfBuyingCouponsInfoEnd", ""},
	{"RetBoughtCouponsInfoBegin", ""},
	{"RetBoughtCouponsInfo", "IIssIISS"},--������index, ID, sequenceID, name, price, smallIcon, desc, url
	{"RetBoughtCouponsInfoEnd",""},    
	{"RetCSMAddSellOrderOverAvgPrice", "IsI"},
	{"ShowPanelByTongItem", "sIIsII"},
	
	{"OpenWebBrowser", "s"},
	{"WeiBoLoginFaild", ""},
	
}



Db2GacFunList =
{
["TestDb2Gac"] = true,
["RetInsertFbActionToQueue"] = true,
["RetInFbActionPeopleNum"] = true,
["RetDelQueueFbAction"] = true,
["WaitOtherTeammate"] = true,
["ActionAllReady"] = true,
["SetActionPanelWarnValue"] = true,
}




--����messge��Ϣ����
local MessageFunTbl,IDToFunTbl = GetMessageFun("Message", "Lan_Message_Common")
g_MsgIDToFunTbl = IDToFunTbl
g_MessageFunTbl = MessageFunTbl
for i , p in pairs (MessageFunTbl) do
	table.insert(funlist,p)
	Db2GacFunList[p[1]] = true
end

local FriendMsgToClientFunTbl, IDToFriendMsgFunTbl = GetMessageFun("SystemFriendMsgToClient", "Lan_SystemFriendMessage_Common")
g_MsgIDIDToFriendFunTbl = IDToFriendMsgFunTbl
g_FriendMsgToClientFunTbl = FriendMsgToClientFunTbl
for i , p in pairs (FriendMsgToClientFunTbl) do
	table.insert(funlist,p)
end


--����Db2GacRp����
local temp = {}  

for i, v in pairs(funlist) do
	if Db2GacFunList[v[1]] then
		table.insert(temp, {"_Db2" .. v[1], "sIb" .. v[2]})
	end
end

for i = 0, #temp do
	table.insert(funlist, temp[i])
end


return "Gas2Gac",funlist
