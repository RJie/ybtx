gac_gas_require "activity/quest/ParseQuestTbl"
gac_gas_require "activity/npc/CheckNpcTalk"
gac_require "world/npc/NpcCommFunc"
cfg_load "npc/NpcShowTask_Common"

CNpcHeadSign = class (CRenderDialog)
CNpcHeadSignMgr = class ()

local NpcShowQuestFaceTick = {}
local NpcShowQuestFacePic = {}

RegMemCheckTbl("NpcShowQuestFaceTick", NpcShowQuestFaceTick)
RegMemCheckTbl("NpcShowQuestFacePic", NpcShowQuestFacePic)

local HeadSignWndNum = 10
-----------����NPC OBJͷ����Ϣ������

local QuestStatePictureTbl = 
{
	[1]  = g_ImageMgr:GetImagePath(1342),					--�������ͼ��(��ɫ)
	[2]  = g_ImageMgr:GetImagePath(1343),			--��������е�ͼ��(��ɫ)
	[3]  = g_ImageMgr:GetImagePath(1344),			--������ɺ��ͼ��(��ɫ)
	[4]  = g_ImageMgr:GetImagePath(1345),							--��ҵȼ�С�ڵ�������ȼ�2����4����ʱ��(��ɫ)
	[5]  = g_ImageMgr:GetImagePath(1346),		--�������ͼ��(Ӷ��-��ɫ)
	[6]  = g_ImageMgr:GetImagePath(1344),			--������ɺ��ͼ��(Ӷ��-��ɫ)
	[7]  = g_ImageMgr:GetImagePath(1342),					--�������ͼ��(����-��ɫ)
	[8]  = g_ImageMgr:GetImagePath(1344),			--������ɺ��ͼ��(����-��ɫ)
	[9]  = g_ImageMgr:GetImagePath(1347),			--�������ͼ��(�ظ�-ɫ)
	[10] = g_ImageMgr:GetImagePath(1344),			--������ɺ��ͼ��(�ظ�-ɫ)
	[11] = g_ImageMgr:GetImagePath(1348),		--���ɵǼ�ʱ��ͷ��ͼ��
	[12] = g_ImageMgr:GetImagePath(1348),		--���鱾������NPC��ͷ��ͼ��
	[13] = g_ImageMgr:GetImagePath(1348),		--���鱾������NPC��ͷ��ͼ��
	
}

local QuestStateTbl = 
{
	[1]  = "renwu/create01",					--�������ͼ��(��ɫ)
	[2]  = "renwu/create03",			--��������е�ͼ��(��ɫ)
	[3]  = "renwu/create02",			--������ɺ��ͼ��(��ɫ)
	[4]  = "renwu/create01",							--��ҵȼ�С�ڵ�������ȼ�2����4����ʱ��(��ɫ)
	[5]  = "renwu/create01",		--�������ͼ��(Ӷ��-��ɫ)
	[6]  = "renwu/create02",			--������ɺ��ͼ��(Ӷ��-��ɫ)
	[7]  = "renwu/create01",					--�������ͼ��(����-��ɫ)
	[8]  = "renwu/create02",			--������ɺ��ͼ��(����-��ɫ)
	[9]  = "renwu/create01",			--�������ͼ��(�ظ�-ɫ)
	[10] = "renwu/create02",			--������ɺ��ͼ��(�ظ�-ɫ)
	[11] = "renwu/create01",		--���ɵǼ�ʱ��ͷ��ͼ��
	[12] = "renwu/create01",		--���鱾������NPC��ͷ��ͼ��
	[13] = "renwu/create05",		--�����npc ��ͷ��ͼ��
}

function CreateNpcHeadSignWndTbl(parent)
	local tbl = CNpcHeadSignMgr:new()
	tbl.m_QuestSignWndTbl = {}
	for PicType = 1, #(QuestStatePictureTbl) do
		tbl.m_QuestSignWndTbl[PicType] = {}
	end
	tbl.m_NpcFaceWndTbl = {}
	for i = 1, HeadSignWndNum do
		for PicType = 1, #(QuestStatePictureTbl) do
			local Wnd = CNpcHeadSign:new()
			Wnd.m_Type = 0  --0����ͷ�������������
			Wnd.m_PicType = PicType
			Wnd:CreateFromRes( "WndHeadSign", parent )
			
--			local Flag = IMAGE_PARAM:new()
--			Flag.CtrlMask = SM_BS_BK
--			Flag.StateMask = IP_ENABLE
--	
--			local DefaultImage = Wnd:GetWndBkImage(Flag)
--			if not DefaultImage then
--				local DefaultImage = WND_IMAGE_LIST:new()
--			end
--			local Pic = QuestStatePictureTbl[PicType]
--			DefaultImage:AddImage( Wnd:GetGraphic(), -1,  Pic, nil, CFPos:new(), "0xffffffff", 16 ) 	
--			Wnd:SetWndBkImage( Flag, DefaultImage )

			
			tbl.m_QuestSignWndTbl[PicType][i] = Wnd
		end
		
		local Wnd = CNpcHeadSign:new()
		Wnd.m_Type = 1  --1����������Npc����
		Wnd:CreateFromRes("SmallGameEffectWnd", parent)
		Wnd.m_GifWnd = Wnd:GetDlgChild("GifWnd")

		tbl.m_NpcFaceWndTbl[i] = Wnd
	end
	return tbl
end

local function CreateNewNpcHeadSignWnd(AddType,PicType)
	local Wnd = CNpcHeadSign:new()
	if AddType == 0 then
		Wnd:CreateFromRes( "WndHeadSign", g_GameMain )
		Wnd.m_Type = 0
		
		Wnd.m_PicType = PicType
--		
--		local Flag = IMAGE_PARAM:new()
--		Flag.CtrlMask = SM_BS_BK
--		Flag.StateMask = IP_ENABLE
--		
--		local DefaultImage = Wnd:GetWndBkImage(Flag)
--		if not DefaultImage then
--			local DefaultImage = WND_IMAGE_LIST:new()
--		end
--		local Pic = QuestStatePictureTbl[PicType]
--		DefaultImage:AddImage( Wnd:GetGraphic(), -1,  Pic, nil, CFPos:new(), "0xffffffff", 16 ) 	
--		Wnd:SetWndBkImage( Flag, DefaultImage )

	else
		Wnd:CreateFromRes("SmallGameEffectWnd", g_GameMain)
		Wnd:ShoWnd(true)
		Wnd.m_GifWnd = Wnd:GetDlgChild("GifWnd")
		Wnd.m_Type = 1
	end
	return Wnd
end

local function GetCanUseHeadSignWnd(iType,PicType)
	local wndtbl = nil
	if iType == 0 then
		wndtbl = g_GameMain.m_NpcHeadSignMgr.m_QuestSignWndTbl[PicType]
	else
		wndtbl = g_GameMain.m_NpcHeadSignMgr.m_NpcFaceWndTbl
	end
	
	local wndnum = #(wndtbl)
	local reswnd = nil
	if wndnum > 0 then
		reswnd = wndtbl[wndnum]
		table.remove(wndtbl,wndnum)
	else
--		print("CreateNewNpcHeadSignWnd(iType)")
		reswnd = CreateNewNpcHeadSignWnd(iType,PicType)
	end
--	print(#(g_GameMain.m_NpcHeadSignMgr.m_QuestSignWndTbl),#(g_GameMain.m_NpcHeadSignMgr.m_NpcFaceWndTbl))
	return reswnd
end

local function RetWndToWndTbl(Wnd)
	if Wnd.m_Type == 0 then
		local PicType = Wnd.m_PicType
--		print("RetWndToWndTbl(Wnd)")
		table.insert(g_GameMain.m_NpcHeadSignMgr.m_QuestSignWndTbl[PicType],Wnd)
	else
		table.insert(g_GameMain.m_NpcHeadSignMgr.m_NpcFaceWndTbl,Wnd)
	end
end

local function DestroyNpcHeadSignWnd(Character)
	if not IsCppBound(Character) then
		return 
	end
	if not Character.m_HeadSignWnd then
		return
	end
	Character.m_HeadSignWnd:DelWndFxEx()
	Character.m_HeadSignWnd:ShowWnd(false)
	RetWndToWndTbl(Character.m_HeadSignWnd)
--	print("DestroyNpcHeadSignWnd")
	Character:GetRenderObject():DelChild(Character.m_HeadSignWnd)
	Character.m_HeadSignWnd = nil
end

local function CreateNpcHeadSign(Character,iType,PicType)
	local Wnd = GetCanUseHeadSignWnd(iType,PicType)
	Character:GetRenderObject():AddChild( Wnd, eLinkType.LT_SKELETAL, "Bip01 Head" )
	if iType == 1 then
		Wnd:SetOff(-100,-50)
	else
		Wnd:SetOff(0,250)
		local FX = ""
		if QuestStateTbl[PicType] then 
			FX = QuestStateTbl[PicType]
		end
		Wnd:SetLockFlag( BitOr( LOCK_LEFT, LOCK_RIGHT, LOCK_TOP, LOCK_BOTTOM ) )
		Wnd:PlayWndImePathFx("fx/setting/renwu.efx",FX,1)
	end
	Wnd:SetRenderWndHeight(185)
	Wnd:ShowWnd(true)
	return Wnd
end

--����NPCͷ����Ϣ
function CNpcHeadSign:UpdateHeadWnd(CharObj,PictureFileStr)
	if CharObj.m_NpcHeadUpDialog then
		CharObj.m_NpcHeadUpDialog:ShowWnd(false)
		if CharObj.m_NpcHeadUpDialog.WndIsShowTick then
			UnRegisterTick(CharObj.m_NpcHeadUpDialog.WndIsShowTick)
			CharObj.m_NpcHeadUpDialog.WndIsShowTick = nil
		end
		CharObj.m_NpcHeadUpDialog = nil
	end
	
	local Flag = IMAGE_PARAM:new()
	Flag.CtrlMask = SM_BS_BK
	Flag.StateMask = IP_ENABLE
	
--	local DefaultImage = self:GetWndBkImage(Flag)
--	if not DefaultImage then
	local DefaultImage = WND_IMAGE_LIST:new()
--	end
--	DefaultImage:SetGUIAsynEnable(true)
	DefaultImage:AddImage( self.m_GifWnd:GetGraphic(), -1,  PictureFileStr, nil, CFPos:new(), "0xffffffff", 16 ) 	
	self.m_GifWnd:SetWndBkImage( Flag, DefaultImage )
	self.m_Picture = PictureFileStr
	self:ShowWnd(true)
end

-----------����NPC OBJͷ����Ϣ������
function CNpcHeadSignMgr:Ctor()
	self.m_SeeNpcAndObjTbl = {}			--���� �����Ұ�е�NPC OBJ����(GlobalID Name)
	--��ʾ������ͼƬ
--	self.HeadPicState = {none = 0, canaccept = 1, processing = 2, canfinish = 3}
end


--�ж�NPC��OBJ ͷ����ʾ��ͼƬ��Ϣ(����ͼƬ����)
function CNpcHeadSignMgr:NpcAndObjPicInfo(NpcOrObj, flag)
	local name = NpcOrObj.m_Properties:GetCharName()
	local CharType = NpcOrObj.m_Properties:GetType()
	local TypeStr= ""
	if CharType == ECharacterType.IntObj then
		TypeStr = "Obj"
		if string.find(name,"Ӷ���ճ����񷢲���") then
			if not g_GameMain.m_MercenaryLevelTrace.m_IsCheckIn then
				Gas2Gac:RetSendMercTempQuestPoolEnd(g_Conn, false)
				local Wnd = CQuestPoolWnd.GetWnd()
				if Wnd.m_IsShowMercQuest then
					return 1
				end
			end
			return
		end
	elseif CharType == ECharacterType.Npc then
--		if NpcOrObj:CppGetCamp() ~= 4 and 
--			 NpcOrObj:CppGetCamp() ~= 10 and 
--			 NpcOrObj:CppGetCamp() ~= g_MainPlayer:CppGetCamp() then
--			return nil
--		end
		TypeStr = "Npc"
		local funcnametbl = Npc_Common(name, "FuncName")
		if funcnametbl ~= "" then
			funcnametbl = loadstring("return {" .. funcnametbl.."}")()
			if ( type(funcnametbl[1]) == "table" ) then
				funcnametbl = funcnametbl[1]
			end
			for i = 1,#(funcnametbl) do
				local funcname = funcnametbl[i]
				if funcname == "����NPC" then
					local NpcShowTaskCommon = NpcShowTask_Common(name) 
					if not NpcShowTaskCommon then
						return 
					end
					local NpcShowTaskIndex = NpcShowTaskCommon:GetKeys()
					for i,para in pairs(NpcShowTaskIndex) do
						local str = i..""
						local Data = NpcShowTaskCommon(str, "TaskType")
						if Data == "Renovate" and not flag then
							return 12
						else
							return 
						end
					end
				elseif funcname == "Ӷ��ָ���Ǽ�" and g_GameMain.m_MercenaryLevelTrace.m_IsCheckIn then
					return 11
				elseif funcname == "���Ʒ��ȡ" and name == "�����NPC" then
					return 13
				end
			end
		end
	else
		--local str = name..CharType
		--LogErr("����ͷ����ʾ��ͼƬ��Ϣ",str)
		return
	end
	
	if g_GameMain.m_MercenaryLevelTrace.m_IsCheckIn then
		return
	end
	
	if g_WhereFinishQuestMgr[TypeStr][name] ~= nil then
		for i,p in pairs(g_WhereFinishQuestMgr[TypeStr][name]) do
			if CQuest.CheckCanFinishQuest(p) then		--���������ɸ����������
				if g_AllMercenaryQuestMgr[p] then--Ӷ������
					return 6
				elseif g_HideQuestMgr[p] then--��������
					return 8
			--	elseif g_RepeatQuestMgr[p] then
			--		return 10
				else
					return 3
				end
			end
		end
	end
  
	if g_WhereGiveQuestMgr[TypeStr][name] ~= nil then
		for i,p in pairs(g_WhereGiveQuestMgr[TypeStr][name]) do
			local PlayerLev = g_MainPlayer:CppGetLevel()
			local QuestLev = g_ReturnSentenceParse(Quest_Common(p, "����ȼ�"), p)
			if CQuest.CheckQuestAvavilable(p) then		--���������ܸ����������
				if g_AllMercenaryQuestMgr[p] or g_DareQuestMgr[p] or g_ActionQuestMgr[p] then
					return 1
				elseif g_HideQuestMgr[p] then--��������
					return 7
		--	elseif g_RepeatQuestMgr[p] then
		--		return 9
				else
					if (PlayerLev - QuestLev) < 2 then
						return 1
					end
				end
				
			end
		end
	end
	
	if g_WhereFinishQuestMgr[TypeStr][name] ~= nil then
		for i,p in pairs(g_WhereFinishQuestMgr[TypeStr][name]) do
			if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[p] then
				local state = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[p].m_State
				--�ж���ҵ�ǰ���ڵ�ͼ�Ƿ���ȷ
				if IfAcceptQuestMap(g_GameMain.m_SceneName,p) and state == QuestState.init then
					return 2	--����������ڽ�����
				end
			end
		end
	end
	
	for _, Tbl in pairs(g_NpcTalkTbl) do
		for _, NpcName in pairs(Tbl["����Npc"].Param1) do
			if NpcName == name then
				local uEntityID = NpcOrObj:GetEntityID()
				Gac2Gas:GetNpcTalkHeadInfo(g_Conn, uEntityID)
				break
			end
		end
	end

	return
end

--������NPC��OBJ���������Ұʱ ���øú���
function CNpcHeadSignMgr:NpcAndObjInView(Character)
	local NpcName = Character.m_Properties:GetCharName()
	local uEntityID = Character:GetEntityID()
	
	if Character.m_Properties:GetType() ~= ECharacterType.Trap then
		local pic = nil
		if Character.m_HeadSignWnd then
			DestroyNpcHeadSignWnd(Character)
		end
		if NpcShowQuestFaceTick[uEntityID] then
			pic = NpcShowQuestFacePic[uEntityID]
			Character.m_HeadSignWnd = CreateNpcHeadSign(Character,1)
			Character.m_HeadSignWnd:UpdateHeadWnd(Character,pic)
		else
			--Gac2Gas:GetPicInfo(g_Conn, uEntityID)
			
			local funcnametbl = Npc_Common(NpcName, "FuncName")
			if funcnametbl and funcnametbl ~= "" then
				funcnametbl = loadstring("return {" .. funcnametbl.."}")()
				if ( type(funcnametbl[1]) == "table" ) then
					funcnametbl = funcnametbl[1]
				end
				local isspecialNpc = false
				for i = 1,#(funcnametbl) do
					local funcname = funcnametbl[i]
					if funcname == "����NPC" then
						isspecialNpc = true
						Gac2Gas:GetPicInfo(g_Conn, uEntityID)
						break
					end
				end
				if not isspecialNpc then
					local pictype = self:NpcAndObjPicInfo(Character,true)
					if pictype ~= nil then
						Character.m_HeadSignWnd = CreateNpcHeadSign(Character,0,pictype)
					end
				end
			else
				local pictype = self:NpcAndObjPicInfo(Character,true)
				if pictype ~= nil then
					Character.m_HeadSignWnd = CreateNpcHeadSign(Character,0,pictype)
				end
			end
			
		end
	end
	table.insert(self.m_SeeNpcAndObjTbl, uEntityID)
	--print("Npc��������������������"  .. #(self.m_SeeNpcAndObjTbl))
end
--������NPC��OBJ�뿪�����Ұʱ ���øú���
function CNpcHeadSignMgr:NpcAndObjOutView(Character)
	local NpcName = Character.m_Properties:GetCharName()
	for i,ID in pairs(self.m_SeeNpcAndObjTbl) do
		if ID == Character:GetEntityID() then
			self.m_SeeNpcAndObjTbl[i] = nil
			if Character.m_HeadSignWnd then
				DestroyNpcHeadSignWnd(Character)
			end
			return
		end
	end
end

--���������Ұ�����е�����NPC��OBJ��ͷ����Ϣ״̬
function CNpcHeadSignMgr:UpdateNpcAndObjInView()
	for i,EntityID in pairs(self.m_SeeNpcAndObjTbl) do
		local NpcObj = CCharacterFollower_GetCharacterByID(EntityID)
		local IntObjClient = CIntObjClient_GetIntObjByID(EntityID)
		local CharObj = NpcObj or IntObjClient
		if IsCppBound(CharObj) then
			local type = CharObj.m_Properties:GetType()
			if type == ECharacterType.Trap then
				InitTrapEffect( CharObj)
			else
			
				local npcName = CharObj.m_Properties:GetCharName()
				local NpcType = GetFuncTypeByNpcName(npcName)
				g_GameMain.m_SmallMapBG.m_Static:ChangeEntityImageType(EntityID,NpcType)
				if not NpcShowQuestFaceTick[EntityID] then
					local PicType = self:NpcAndObjPicInfo(CharObj, true)
					if CharObj.m_HeadSignWnd then
						if CharObj.m_HeadSignWnd.m_PicType ~= PicType then
							DestroyNpcHeadSignWnd(CharObj)
						end
					end
					if not CharObj.m_HeadSignWnd and PicType then
						CharObj.m_HeadSignWnd = CreateNpcHeadSign(CharObj,0,PicType)
--						CharObj.m_HeadSignWnd:UpdateHeadWnd(CharObj,pic)
					end
				end
			end
		end
	end
end

local function QuestFaceTick(Tick, uEntityID)
	if NpcShowQuestFaceTick[uEntityID] then
		UnRegisterTick(NpcShowQuestFaceTick[uEntityID])
		NpcShowQuestFaceTick[uEntityID] = nil
		NpcShowQuestFacePic[uEntityID] = nil
	end
	local Npc = CCharacterFollower_GetCharacterByID(uEntityID)
	local IntObjClient = CIntObjClient_GetIntObjByID(uEntityID)
	local CharObj = Npc or IntObjClient
	if not IsCppBound(CharObj) then
		return
	end
	if CharObj.m_HeadSignWnd then
		DestroyNpcHeadSignWnd(CharObj)
		local PicType = g_GameMain.m_NpcHeadSignMgr:NpcAndObjPicInfo(CharObj, true)
		if PicType then
			CharObj.m_HeadSignWnd = CreateNpcHeadSign(CharObj,0,PicType)
--			Npc.m_HeadSignWnd:UpdateHeadWnd(Npc,pic)
		end
	end
end

local function PlayerFaceTick()
	if not IsCppBound(g_MainPlayer) then
		return
	end
	if g_MainPlayer.m_HeadSignWnd then
		DestroyNpcHeadSignWnd(g_MainPlayer)
	end
end

--���������Ұ�����е�����NPC��OBJ��ͷ����Ϣ״̬
function CNpcHeadSignMgr:ShowQuestFace(QuestName)
	if not g_QuestHandBookTbl[QuestName] then
		return
	end
	local FileName = ""
	local FaceTime = 0
	local QuestNpcName = ""
	local QuestNode = Quest_Common(QuestName)
	local function ShowPicToPlayer()
		if IsCppBound(g_MainPlayer) then
			
			local type = g_MainPlayer.m_Properties:GetType()
			local NpcName = g_MainPlayer.m_Properties:GetCharName()
			if g_MainPlayer.m_HeadSignWnd then
				DestroyNpcHeadSignWnd(g_MainPlayer)
			end 
			local pic =  g_ImageMgr:GetImagePath(10006)..FileName..".tex"
			g_MainPlayer.m_HeadSignWnd = CreateNpcHeadSign(g_MainPlayer,1)
			RegisterOnceTick(g_GameMain, "PlayerShowQuestFaceTick", PlayerFaceTick, FaceTime*1000)
			g_MainPlayer.m_HeadSignWnd:UpdateHeadWnd(g_MainPlayer,pic)
		end
	end
	
	local function ShowPicToNpc()
		for i,EntityID in pairs(self.m_SeeNpcAndObjTbl) do	
		local NpcObj = CCharacterFollower_GetCharacterByID(EntityID)
		local IntObjClient = CIntObjClient_GetIntObjByID(EntityID)
		local CharObj = NpcObj or IntObjClient
			if IsCppBound(CharObj) then
				local type = CharObj.m_Properties:GetType()
				local NpcName = CharObj.m_Properties:GetCharName()
				if QuestNpcName == NpcName and type ~= ECharacterType.Trap then
					if CharObj.m_HeadSignWnd then
						DestroyNpcHeadSignWnd(CharObj)
					end
					CharObj.m_HeadSignWnd = CreateNpcHeadSign(CharObj,1)
					if NpcShowQuestFaceTick[EntityID] then
						UnRegisterTick(NpcShowQuestFaceTick[EntityID])
					end 
					local pic =  g_ImageMgr:GetImagePath(10006) ..FileName..".tex"
					NpcShowQuestFacePic[EntityID] = pic
					NpcShowQuestFaceTick[EntityID] = RegisterTick("NpcShowQuestFaceTick",QuestFaceTick,FaceTime*1000,EntityID)
					CharObj.m_HeadSignWnd:UpdateHeadWnd(CharObj,pic)
					break
				end
			end
		end	
	end
	
	
	if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] then
		if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State == QuestState.finish then
			if g_QuestHandBookTbl[QuestName].FinishFace then
				FileName = g_QuestHandBookTbl[QuestName].FinishFace[1][1]
				FaceTime = g_QuestHandBookTbl[QuestName].FinishFaceTime
				QuestNpcName = QuestNode("��������ʽ", "Arg")
				if FileName == "" then
					return
				end
				if not FaceTime or not IsNumber(FaceTime) or FaceTime == 0 then
					FaceTime = 5
				end
				if g_QuestHandBookTbl[QuestName].FinishFace[1][2] == "Player" then
					ShowPicToPlayer()
				elseif g_QuestHandBookTbl[QuestName].FinishFace[1][2] == "Npc" then
					ShowPicToNpc()
				else
					return
				end
			else
				return
			end
			
		elseif g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State == QuestState.init then
			if g_QuestHandBookTbl[QuestName].AcceptFace then
				FileName = g_QuestHandBookTbl[QuestName].AcceptFace[1][1]
				FaceTime = g_QuestHandBookTbl[QuestName].AcceptFaceTime
				QuestNpcName = QuestNode("��������ʽ", "Arg")
				if FileName == "" then
					return
				end
				if not FaceTime or not IsNumber(FaceTime) or FaceTime == 0 then
					FaceTime = 5
				end
				if g_QuestHandBookTbl[QuestName].AcceptFace[1][2] == "Player" then
					ShowPicToPlayer()
				elseif g_QuestHandBookTbl[QuestName].AcceptFace[1][2] == "Npc" then
					ShowPicToNpc()
				else
					return 
				end
			else
				return
			end
		end
	end
end

--�������,�����Ҹ��ϵı�����Ϣ
function CNpcHeadSignMgr:ClearPlayerFace()
	if IsCppBound(g_MainPlayer) and g_MainPlayer.m_HeadSignWnd then
		DestroyNpcHeadSignWnd(g_MainPlayer)
	end 
end

function CNpcHeadSignMgr:ClearNpcShowQuestFaceTick()
	for ID,_ in pairs(NpcShowQuestFaceTick) do
		if NpcShowQuestFaceTick[ID] then
			UnRegisterTick(NpcShowQuestFaceTick[ID])
			NpcShowQuestFaceTick[ID] = nil
			NpcShowQuestFacePic[ID] = nil
		end
	end
end

function CNpcHeadSignMgr:ClearNpcHeadInfo(Npc)
	DestroyNpcHeadSignWnd(Npc)
end


function Gas2Gac:RetPicInfo(Conn, EntityID, flag)
	local NpcObj = CCharacterFollower_GetCharacterByID(EntityID)
	local IntObjClient = CIntObjClient_GetIntObjByID(EntityID)
	local CharObj = NpcObj or IntObjClient
	if not IsCppBound(CharObj) then
		return
	end
	local pictype = g_GameMain.m_NpcHeadSignMgr:NpcAndObjPicInfo(CharObj, flag)
	if pictype ~= nil then
		CharObj.m_HeadSignWnd = CreateNpcHeadSign(CharObj,0,pictype)
	end
end

function Gas2Gac:RetNpcTalkHeadInfo(Conn, EntityID, IsUsed)
	local NpcObj = CCharacterFollower_GetCharacterByID(EntityID)
	local IntObjClient = CIntObjClient_GetIntObjByID(EntityID)
	local CharObj = NpcObj or IntObjClient
	if not IsCppBound(CharObj) then
		return
	end
	if not IsUsed then
		CharObj.m_HeadSignWnd = CreateNpcHeadSign(CharObj, 0, 12)
	else
		DestroyNpcHeadSignWnd(CharObj)
	end
end
