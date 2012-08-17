gac_require "smallgames/SmallGameMgrInc"
gac_require "smallgames/SmallGameEffectWnd"
gac_require "smallgames/AlternateClickMouse/CAlternateClickMouse"
gac_require "smallgames/ClickPicClient/ClickPicGame/CClickPicGame"
gac_require "smallgames/TiggerCageClient/TiggerCageClient"
gac_require "smallgames/FindKnifeClient/CFindKnifeGame"
gac_require "smallgames/GetFungusClient/CGetFungusWnd"
gac_require "smallgames/GetStoneClient/CGetStoneWnd"

cfg_load "smallgame/SmallGame_Common"

function CreatSmallGame()
	SGameMgr = CSmallGameMgr:new()
	SGameMgr:InitSmallGameAll()
	return SGameMgr
end

local function CheckQuestCondition(GameCommon, GameName)
	local mRequireTbl = GameCommon("QuestRequire")
	local mResultTbl = g_SmallGameStrTbl[GameName].QuestResult --GameCommon.QuestResult
	local mQuestRequire = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[mRequireTbl[1]]
	local mQuestResult = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[mResultTbl[1]]
	local QuestVarMaxNum = g_QuestNeedMgr[mResultTbl[1]][mResultTbl[2]].Num
	if mQuestRequire == nil or mQuestResult == nil or QuestVarMaxNum == nil then
		return false
	end
	if mQuestRequire[mRequireTbl[2]] == nil or mQuestResult[mResultTbl[2]] == nil then
		return false
	end
	if mQuestResult[mRequireTbl[2]].DoNum >= QuestVarMaxNum then
		return false
	end
	return true
end

function CSmallGameMgr:InitSmallGameAll()
	g_GameMain.m_ClickMouseGame = CreateClickMouseGame(g_GameMain)
	g_GameMain.m_ClickPicGame = InitClickPicGame(g_GameMain)
	g_GameMain.m_TiggerCageGame = CreateTiggerCageGame(g_GameMain)
	g_GameMain.m_FindKnife = CreateFindKnifeGame(g_GameMain)
	g_GameMain.m_GetStoneGame = CreateGetStoneWnd(g_GameMain)
	g_GameMain.m_GetFungusGame = CreateGetFungusWnd(g_GameMain)
	
	self.SmallGameScriptTbl = 
	{
		["������������Ҽ�"] = g_GameMain.m_ClickMouseGame,
		["���ͼƬ"] = g_GameMain.m_ClickPicGame,
		["���һ����"] = g_GameMain.m_TiggerCageGame,
		["������ȷ��ѡ��"] = g_GameMain.m_GetHorseMedicine,
		["���»����"] = g_GameMain.m_FindKnife,
		["�����ά������"] = g_GameMain.m_GetStoneGame,
		["������ȷ��λ��"] = g_GameMain.m_GetFungusGame,
	}
	
	
end

function Gas2Gac:RetMsgBeginSmallGame(Conn,GameName,GlobalID)
	local GameCommon = SmallGame_Common(GameName)
	if GameCommon == nil then
		return
	end
	
	g_GameMain.m_SmallGemeMsgWnd:InitSmallGameMsgWnd(GameName,GlobalID)
end

function Gas2Gac:BeginSmallGame(Conn,GameName,ObjID)
	g_GameMain.m_SGMgr:BeginSmallGameFun(GameName,ObjID)
end

function Gas2Gac:ExitSmallGame(Conn)
	if not g_MainPlayer.m_IsWaitShowWnd then
		Gas2Gac:CloseSmallGameMsgWnd(g_Conn)
		g_GameMain.m_SGMgr:CancelSmallGame(true)
	end
end

function CSmallGameMgr:BeginSmallGameFun(GameName,ObjID)
	local GameCommon = SmallGame_Common(GameName)
	if GameCommon == nil then
		return
	end
	self.m_NowScript = GameCommon("ScriptName")
	if self.SmallGameScriptTbl[self.m_NowScript] == nil then
		return
	end
	
	--��Ч��ʾ����
	self.m_SmallGameEffectWnd = CreatSmallGameEffectWnd(g_GameMain)
	self.m_strEffectPath = GameCommon("GifEffectFile")
	self:ShowSmallGameEffectWnd(self.m_strEffectPath)
	--����С��Ϸ
	self.SmallGameScriptTbl[self.m_NowScript]:BeginSmallGame(GameName,ObjID)
end

function CSmallGameMgr:BeginSmallGameByQuest(GameName)
	local GameCommon = SmallGame_Common(GameName)
	if not GameCommon then
		return
	end

	self.m_NowScript = GameCommon("ScriptName")
	if not self.SmallGameScriptTbl[self.m_NowScript] then
		return
	end
	
	--if not CheckQuestCondition(GameCommon, GameName) then
	--	return
	--end
	
	g_GameMain.m_SmallGame = self.m_NowScript

	self.SmallGameScriptTbl[self.m_NowScript]:BeginSmallGame(GameName)
end

function CSmallGameMgr:RunSmallGameFun(uMsgID)
	--С��Ϸ������
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj or g_MainPlayer.m_LockCenter.m_LockingIntObj
	if self.m_NowScript then
		if self.SmallGameScriptTbl[self.m_NowScript] then
			self.SmallGameScriptTbl[self.m_NowScript]:RunSmallGame(uMsgID)
		end
	end
end

function CSmallGameMgr:EndSmallGameFun(ifSucc)
	--���С��Ϸ
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj or g_MainPlayer.m_LockCenter.m_LockingIntObj
	if self.m_NowScript then
		if self.SmallGameScriptTbl[self.m_NowScript] then
			--if not Target then--���������û����,�Ǿ�ʧ�ܰ�
			--	ifSucc = false
			--end
			if ifSucc then
				self.SmallGameScriptTbl[self.m_NowScript]:SuccSmallGame()
			else
				self.SmallGameScriptTbl[self.m_NowScript]:FailSmallGame()
			end
		end
	end
	g_GameMain.m_SmallGame = nil
	g_GameMain.m_DoSmallGame = nil
	self.m_NowScript = nil
end

--�������Ϸ��¼���λ��
function CSmallGameMgr:RecMousePosSmallGame(vecPos)
	if g_GameMain.m_DoSmallGame then
		if self.SmallGameScriptTbl[self.m_NowScript] then
			self.SmallGameScriptTbl[self.m_NowScript]:RecMousePosSmallGame(vecPos)
		end
	end
end

--ȡ�������е�С��Ϸ
function CSmallGameMgr:CancelSmallGame(IsMove)
	if g_GameMain.m_SmallGame or g_GameMain.m_DoSmallGame then
		if self.SmallGameScriptTbl[self.m_NowScript] then
			self.SmallGameScriptTbl[self.m_NowScript]:CancelSmallGame(IsMove)
		end
		g_GameMain.m_SmallGame = nil
		g_GameMain.m_DoSmallGame = nil
		self.m_NowScript = nil
	end
end

--ĳЩ��ʱ��С��Ϸ��ʱ�䵽�˺�Ҫ���õķ���
function EndSmallGlobalFun(ifSucc)
	g_GameMain.m_SGMgr:EndSmallGameFun(ifSucc)
end

--�Լ���Ч��ʾ
function CSmallGameMgr:SmallGameAddRender(strFilePath)
	if strFilePath and IsTable(strFilePath) then
		
		local strEfxFile,strState = strFilePath[1],strFilePath[2]
		if g_MainPlayer and strEfxFile and strState then
			if strEfxFile~="" and strState~="" then
				
				g_MainPlayer:GetRenderObject():AddEffect( strEfxFile, strState, 0, nil )
	
			end
		end
		
	end
end

--�ڴ�������ʾ������Чͼ
function CSmallGameMgr:ShowSmallGameEffectWnd(strFilePath,ShowTime)
	local function LoopShowPic(Tick, FilePath)
		if FilePath and FilePath ~= "" then
			if self.m_SmallGameEffectWnd then
				self.m_SmallGameEffectWnd:AddImage(FilePath)
			end
		end
		
		if self.m_ShowEffectTick then
			UnRegisterTick(self.m_ShowEffectTick)
			self.m_ShowEffectTick = nil
		end
	end
	
	if strFilePath and strFilePath ~= "" then
		
		self.m_SmallGameEffectWnd:AddImage(strFilePath)
		if not self.m_SmallGameEffectWnd:IsShow() then
			self.m_SmallGameEffectWnd:ShowWnd(true)
		end
		if ShowTime and IsNumber(ShowTime) and ShowTime > 0 then
			if self.m_ShowEffectTick then
				UnRegisterTick(self.m_ShowEffectTick)
				self.m_ShowEffectTick = nil
			end
			self.m_ShowEffectTick = RegisterTick("LoopShowPicTick",LoopShowPic,ShowTime*1000,self.m_strEffectPath)
		end
		
	end
end

--�رն�����Чͼ
function CSmallGameMgr:CloseSmallGameEffectWnd()
	if self.m_SmallGameEffectWnd then
		self.m_SmallGameEffectWnd:ShowWnd(false)
		self.m_SmallGameEffectWnd:DestroyWnd()
		self.m_SmallGameEffectWnd = nil
	end
end

--�����ͬ�������˵���Ч��ʾ
function Gas2Gac:PlayerSmallGameSuccFx(Conn,GameName,EntityID)
	local CharFollower = CCharacterFollower_GetCharacterByID(EntityID)
	if CharFollower == nil then
		return
	end
	if EntityID == g_MainPlayer:GetEntityID() then
		--print(GameName)
		MsgClient(3255,Lan_SmallGame_Common(MemH64(GameName), "ShowName"))
	else
		local SuccEfxFile = g_SmallGameStrTbl[GameName].SuccEfxFile
		if SuccEfxFile and next(SuccEfxFile)  then
	--		local SuccEfxFile = loadstring("return " .. SuccEfxFile)()
			CharFollower:GetRenderObject():AddEffect( SuccEfxFile[1], SuccEfxFile[2], 0, nil)
		end
	end
end
