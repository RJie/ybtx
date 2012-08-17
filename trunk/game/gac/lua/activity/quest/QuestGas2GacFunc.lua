--��½���õõ��������������״̬

function GacGiveDoingQuest(QuestName)
	local function IsGiveUp(g_GameMain,uButton)
		if uButton == MB_BtnOK then
			Gac2Gas:GiveUpQuest(g_Conn, QuestName)
		end
		g_GameMain.m_MsgBox = nil
		return true
	end
	g_GameMain.m_MsgBox = MessageBox( g_GameMain, MsgBoxMsg(8002, g_GetLanQuestName(QuestName)), BitOr( MB_BtnOK, MB_BtnCancel),IsGiveUp,g_GameMain)
end

--ʱ��TICK
local TimeDegree = {} 
local QuestTimeTickTbl = {}
local function QuestTime(Tick, LimitTime, QuestName)
	TimeDegree[QuestName] = TimeDegree[QuestName] + 1
	if TimeDegree[QuestName] >= LimitTime then
		if QuestTimeTickTbl[QuestName] ~= nil then
			UnRegisterTick(QuestTimeTickTbl[QuestName])
			QuestTimeTickTbl[QuestName] = nil
		end
--		print("����ʧ��")
		MsgClient(3009, g_GetLanQuestName(QuestName))
		g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State = QuestState.failure	
		g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
		g_GameMain.m_QuestTraceBack:ShowTrackByQuestName(QuestName)
		UpdateObjCanUseState()
		TimeDegree[QuestName] = nil		
		Gac2Gas:SetQuestFailure(g_Conn, QuestName)
		return 
	end
	local remnanttime = LimitTime - TimeDegree[QuestName]
	
	if TimeDegree[QuestName]%10 == 0 or remnanttime <= 10 then
		local Second = (LimitTime - TimeDegree[QuestName])%60
		local Minute = math.floor((LimitTime - TimeDegree[QuestName])/60)
		local result = ""
		if Minute <= 0 then
			MsgClient(3021, g_GetLanQuestName(QuestName),Second)
--			result = "����["..QuestName.."]����".. Second.."�����!"
		else
			MsgClient(3022, g_GetLanQuestName(QuestName),Minute,Second)
--			result = "����["..QuestName.."]����"..Minute.."��"..Second.. "�����!"	
		end
	end
end

function UnRegisterAllQuestTick()
	for QuestName, questtick in pairs(QuestTimeTickTbl) do
		UnRegisterTick(questtick)
		QuestTimeTickTbl[QuestName] = nil
		TimeDegree[QuestName] = nil
	end
end

function Gas2Gac:RetGetQuest(Conn, QuestName, State, AcceptTime, IsCanFinish, YbItemIndex)
--	print("AcceptTime",AcceptTime)
	local AcceptTime = tonumber(AcceptTime)
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] = {}
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State = State
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_AcceptTime = AcceptTime
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_YbItemIndex = YbItemIndex
	
	if State ~= QuestState.finish then
		if( nil == g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName]) then
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName] = {}
			if g_QuestNeedMgr[QuestName] then
				for i,v in pairs(g_QuestNeedMgr[QuestName]) do
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][i] = {}
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][i].DoNum = 0
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][i].NeedNum = v.Num
				end
			end
			
			if Quest_Common(QuestName, "������״̬����") then
				local Keys = Quest_Common:GetKeys(QuestName, "������״̬����")
				for k = 1, table.getn(Keys) do
					local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������״̬����", Keys[k], "Function")
					local needbuff = tbl[1]		--�����Buff��
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff] = {}
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff].DoNum = 0
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff].NeedNum = 1
				end	
			end
			
			if Quest_Common(QuestName, "��Ʒ����") then
				local Keys = Quest_Common:GetKeys(QuestName, "��Ʒ����")
				for k = 1, table.getn(Keys) do
					local Arg = GetCfgTransformValue(true, "Quest_Common", QuestName, "��Ʒ����", Keys[k], "Arg")
					local ItemType = Arg[1]		--�����Buff��
					local ItemName = Arg[2]		--�����Buff��
					UpdateQuestItemCount(ItemType,ItemName)
--					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff] = {}
--					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff].DoNum = 0
--					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff].NeedNum = 1
				end	
			end
		end
		--g_GameMain.m_QuestTraceBack:ShowTrackByQuestName(QuestName)
		g_GameMain.m_QuestTraceBack:CreateQuestItem(QuestName)
	end
	
	if State == QuestState.init and Quest_Common(QuestName, "��ʱ") then
		if IsCanFinish ~= 1 then
			local LimitTime = Quest_Common(QuestName, "��ʱ")
			if LimitTime and LimitTime ~= 0 then
				local dtime = os.time()-AcceptTime
				if dtime > LimitTime then
					MsgClient(3009, g_GetLanQuestName(QuestName))
					g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State = QuestState.failure
					g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
					g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
					g_GameMain.m_QuestTraceBack:ShowTrackByQuestName(QuestName)
					UpdateObjCanUseState()
					TimeDegree[QuestName] = nil		
					Gac2Gas:SetQuestFailure(g_Conn, QuestName)
				else
					TimeDegree[QuestName] = 0
					QuestTimeTickTbl[QuestName] = RegisterTick("QuestTimeTick", QuestTime, 1000, LimitTime-dtime, QuestName)
				end
				return
			end
		end
	end
	g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
	--RetShowHintMsgWnd()
	UpdateObjCanUseState()
end

function Gas2Gac:RetGetQuestLoop(Conn, LoopName, LoopNum)
	g_GameMain.m_QuestRecordWnd.m_LoopTbl[LoopName] = LoopNum
end

--�õ�����
function Gas2Gac:RetAcceptQuest(Conn, QuestName, YbItemIndex, LoopName, LoopNum)
	MsgClient(3026,g_GetLanQuestName(QuestName))
	g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName] = {}
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] = {}
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State = QuestState.init
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_AcceptTime = os.time()
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_YbItemIndex = YbItemIndex
	if Quest_Common(QuestName, "��������") == 10 and LoopName ~= "" and LoopNum>0 then
		g_GameMain.m_QuestRecordWnd.m_LoopTbl[LoopName] = LoopNum
	end
	if g_QuestNeedMgr[QuestName] then
		for i,v in pairs(g_QuestNeedMgr[QuestName]) do
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][i] = {}
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][i].DoNum = 0
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][i].NeedNum = v.Num
			
			if v.NeedLevel then
				local CurLevel = g_MainPlayer:CppGetLevel()
				if CurLevel >= v.NeedLevel then
					Gac2Gas:SetQuestLevelVarNum(g_Conn, QuestName, i)
				end
			end
		end
	end
	
	if Quest_Common(QuestName, "������״̬����") then
		local Keys = Quest_Common:GetKeys(QuestName, "������״̬����")
		for k = 1, table.getn(Keys) do
			local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������״̬����", Keys[k], "Function")
			local needbuff = tbl[1]		--�����Buff��
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff] = {}
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff].DoNum = 0
			g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][needbuff].NeedNum = 1
		end
	end
	
	local GameName = Quest_Common(QuestName, "������Ϸ")
	if GameName and GameName~="" then
		g_GameMain.m_SGMgr:BeginSmallGameByQuest(GameName)	--�ӵ���С��Ϸ�����ж��Ƿ���Խ���С��Ϸ״̬
	end
	--������TICK  ��ʱ������� TICK~~~~~~~
	
	local LimitTime = Quest_Common(QuestName, "��ʱ")
	if LimitTime and LimitTime ~= 0 then
		TimeDegree[QuestName] = 0
		QuestTimeTickTbl[QuestName] = RegisterTick("QuestTimeTick", QuestTime, 1000, LimitTime, QuestName)
	end
	g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
	g_GameMain.m_QuestRecordWnd:DeleteQuestNode(2,QuestName)
	g_GameMain.m_HandBookWnd:AddQuest(QuestName)
	--g_GameMain.m_NpcHeadSignMgr:ShowQuestFace(QuestName)
	g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
	g_GameMain.m_QuestTraceBack:AcceptQuest(QuestName)
	local MercenaryQuestPoolWnd = CQuestPoolWnd.GetWnd()
	MercenaryQuestPoolWnd:DeleteQuestPoolQuest(QuestName)
	g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
	UpdateObjCanUseState()
	
	g_GameMain.m_takeTask:AcceptQuestReturn(QuestName)
	
	if Quest_Common(QuestName, "��Ʒ����") then
		local Keys = Quest_Common:GetKeys(QuestName, "��Ʒ����")
		for k = 1, table.getn(Keys) do
			local Arg = GetCfgTransformValue(true, "Quest_Common", QuestName, "��Ʒ����", Keys[k], "Arg")
			local ItemType = Arg[1]
			local ItemName = Arg[2]
			UpdateQuestItemCount(ItemType,ItemName)
		end	
	end
	
	local FinishQuestMaxLevel = Quest_Common(QuestName, "����������ߵȼ�")
	if FinishQuestMaxLevel and FinishQuestMaxLevel ~= 0 then
		local CurLevel = g_MainPlayer:CppGetLevel()
		if CurLevel > FinishQuestMaxLevel then
			Gac2Gas:SetQuestFailure(g_Conn, QuestName)
		end
	end
	
	--RetShowHintMsgWnd()
	g_GameMain.m_GuideBtn:BeAlertQuestEmptyAlert()
end

--�������
function Gas2Gac:RetFinishQuest(Conn, QuestName, LoopQuestName)
	MsgClient(3027, g_GetLanQuestName(QuestName))
	local Proffer = Quest_Common(QuestName, "����Ź�����")
	if Proffer and Proffer~="" then
		MsgClient(300021, g_ReturnSentenceParse(Proffer, QuestName) )
	end
	if Quest_Common(QuestName, "��������") == 10 and LoopQuestName == "LoopOver" then
		local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������", "1")
		g_GameMain.m_QuestRecordWnd.m_LoopTbl[tbl[1]] = nil
	end
	g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName] = nil
	g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State = QuestState.finish
	--g_GameMain.m_NpcHeadSignMgr:ShowQuestFace(QuestName)
	g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
	g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
	g_GameMain.m_QuestRecordWnd:DeleteQuestNode(3,QuestName)
	g_GameMain.m_HandBookWnd:DeleteQuest(QuestName)
	g_GameMain.m_QuestTraceBack:RemoveFromQuestTbl(QuestName)
	g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
	SelGoodsAwardChoosed = false
	UpdateObjCanUseState()
	if QuestTimeTickTbl[QuestName] ~= nil then
		TimeDegree[QuestName] = nil
		UnRegisterTick(QuestTimeTickTbl[QuestName])
		QuestTimeTickTbl[QuestName] = nil 
	end
	g_GameMain.m_finishTask:FinishQuestReturn(QuestName)
	--RetShowHintMsgWnd()
	g_GameMain.m_GuideBtn:BeAlertQuestEmptyAlert()
	g_GameMain.m_GuideData:CheckConditionBeDone() --����
	g_GameMain.m_GuideBtn:BeAlertQuestFinish(QuestName)
end

local function GetNewString(QuestName, str)
	if str and str ~= "" then
		local LinkTbl = {}
		if Quest_Common(QuestName, "��Ʒ������") then
			local Keys = Quest_Common:GetKeys(QuestName, "��Ʒ������")
			for i=table.getn(Keys),1,-1 do
				local subject = Quest_Common(QuestName, "��Ʒ������", Keys[i], "Subject")
				local itemlink = GetCfgTransformValue(false, "Quest_Common", QuestName, "��Ʒ������", Keys[i], "Arg")
				if subject~="" and itemlink[1] then
					table.insert(LinkTbl,"Item"..i)
				end
			end
		end
		
		if Quest_Common(QuestName, "������") then
			local Keys = Quest_Common:GetKeys(QuestName, "������")
			for i=table.getn(Keys),1,-1 do
				local subject = Quest_Common(QuestName, "������", Keys[i], "Subject")
				local hipelink = Quest_Common(QuestName, "������", Keys[i], "HyperLink")
				if subject~="" and hipelink~=0 then
					table.insert(LinkTbl,"Link"..i)
				end
			end
		end
		
		for i=1, table.getn(LinkTbl) do
			local FindStr = "%b{"..LinkTbl[i].."}"
			local sTblInfo = string.match(str,FindStr)
			if sTblInfo then
				local num = string.find(sTblInfo,",")
				local strHipeLink = string.sub(sTblInfo,2,num-1)
				str = string.gsub(str, FindStr, strHipeLink)
			end
		end
		
		str = string.gsub(str, "#r", "")
	end
	return str
end

local function QuestVarNotify(QuestName,NeedType, VarName,TrackInfo,NeedNum, VarNum, IsShowMsg)
	local canfinish = true
	local playerquestvar = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName]
	for varname, v in pairs(playerquestvar) do
		if v.DoNum<v.NeedNum then
			canfinish = false
			break
		end
	end
	
	if canfinish then
		MsgClient(3010,g_GetLanQuestName(QuestName))
		local LimitTime = Quest_Common(QuestName, "��ʱ")
		if LimitTime and LimitTime ~= 0 then
			--�������ʱ����,��ô����һ���,��ֹͣ��ʱ
			if QuestTimeTickTbl[QuestName] ~= nil then
				TimeDegree[QuestName] = nil
				UnRegisterTick(QuestTimeTickTbl[QuestName])
				QuestTimeTickTbl[QuestName] = nil 
			end
			
			Gac2Gas:SetQuestIsLimitTime(g_Conn, QuestName)
			return canfinish
		end
		if Quest_Common(QuestName, "���򸱱�����") then
			Gac2Gas:SetQuestIsLimitTime(g_Conn, QuestName)
		end
		return canfinish
	end
	
	if not IsShowMsg then
		return canfinish
	end
	
	--local len = string.len(VarName)
	--if IsTable(TrackInfo) then
	--	local MsgStr = TrackInfo[2]
	--	if VarNum == NeedNum then
	--		MsgClient(3020,MsgStr)
	--	else
	--		MsgClient(3019,MsgStr,VarNum,NeedNum)
	--	end
	--else
		if NeedType == "ɱ������" then
			local starti,endi = string.find(VarName,"ɱ")
			local NpcName = string.sub(VarName,endi+1,len)
			if VarNum == NeedNum then
				MsgClient(3012,NeedNum,GetNpcDisplayName(NpcName))
			else
				MsgClient(3011,GetNpcDisplayName(NpcName),VarNum,NeedNum)
			end
		elseif NeedType == "��Ʒ����" then
			local DisplayName = g_ItemInfoMgr:GetItemLanInfoJustByName(VarName,"DisplayName")
			if VarNum == NeedNum then
				MsgClient(3014,NeedNum,DisplayName)
			else
				MsgClient(3013,DisplayName,VarNum,NeedNum)
			end
		elseif NeedType == "��Ʒʹ������" then
			local starti,endi = string.find(VarName,"ʹ��Item")
			local ItemName = string.sub(VarName,endi+1,len)
			local DisplayName = g_ItemInfoMgr:GetItemLanInfoJustByName(ItemName,"DisplayName")
			if VarNum == NeedNum then
				MsgClient(3016,NeedNum,DisplayName)
			else
				MsgClient(3015,DisplayName,VarNum,NeedNum)
			end
		elseif NeedType == "��������ʹ������" then
			local starti,endi = string.find(VarName,"ʹ��Obj")
			local ObjName = string.sub(VarName,endi+1,len)
			if VarNum == NeedNum then
				MsgClient(3018,NeedNum,GetIntObjDispalyName(ObjName))
			else
				MsgClient(3017,GetIntObjDispalyName(ObjName),VarNum,NeedNum)
			end
	--	elseif NeedType == "��������" then
		else
			TrackInfo = GetNewString(QuestName, TrackInfo)
			if VarNum == NeedNum then
				MsgClient(3020,TrackInfo)
			else
				MsgClient(3019,TrackInfo,VarNum,NeedNum)
			end
		end
	--end
	return canfinish
end

--�õ�����ı���

function Gas2Gac:RetQuestVar(Conn, QuestName, VarName, VarNum)
	local tbl = {}
	local OldNum = tbl.DoNum 
	tbl.DoNum = VarNum
	if g_QuestNeedMgr[QuestName] == nil or g_QuestNeedMgr[QuestName][VarName] == nil then
		--�����assert��Ϊ��Ԥ���ڿ����ڲ߻����������ñ��µ�Bug�������ڿ���ȥ��
		assert(false, "����"..QuestName.."�����������ñ��е���Ϣ�Ѿ��޸ģ���֪ͨ����������Ա�ֶ������ݿ���ɾ������������ؽ����ݿ⣡���˽����ֶ�ɾ�������񣡣�delete from tbl_quest where q_sName = '"..QuestName.."'��")
	end
	
	tbl.NeedNum = g_QuestNeedMgr[QuestName][VarName].Num
	local TrackInfo = g_QuestNeedMgr[QuestName][VarName].TrackInfo
	local NeedType = g_QuestNeedMgr[QuestName][VarName].NeedType
	
	g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][VarName] = tbl
	
	if g_GameMain.m_QuestRecordWnd.m_SelectQuestName == QuestName then
		g_GameMain.m_QuestRecordWnd:InitQuestInfo(QuestName)
	end
	if OldNum ~= VarNum then
		local canfinish = QuestVarNotify(QuestName,NeedType,VarName,TrackInfo,tbl.NeedNum, tbl.DoNum)
		if OldNum == tbl.NeedNum or canfinish or VarNum == 0 then
			g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
			g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		end
		g_GameMain.m_QuestTraceBack:QuestVarNumChange(QuestName)
		UpdateObjCanUseState()
	end
end

function UpdateQuestItemCount(ItemType,ItemName,IsShowMsg)
	local ItemQuestTbl = g_ItemQuestMgr[ItemName]
	if ItemQuestTbl then
		for i = 1, #(ItemQuestTbl) do
			local iType = ItemQuestTbl[i][1]
			local QuestName = ItemQuestTbl[i][2]
			if iType == ItemType then
				local vartbl = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName]
				if vartbl then
					local oldnum = vartbl[ItemName].DoNum
					local neednum = vartbl[ItemName].NeedNum
					local count = g_GameMain.m_BagSpaceMgr:GetItemCountByType( iType, ItemName ) 
					local varnum = count
					if count > neednum then
						varnum = neednum
					end
					local TrackInfo = g_QuestNeedMgr[QuestName][ItemName].TrackInfo
					g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][ItemName].DoNum = varnum
					if oldnum ~= varnum then
						local canfinish = QuestVarNotify(QuestName,"��Ʒ����",ItemName,TrackInfo,neednum, varnum, IsShowMsg)
						g_GameMain.m_QuestTraceBack:QuestVarNumChange(QuestName)
						if oldnum == neednum or canfinish or varnum == 0 then
							g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
							g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
						end
					end
				end
			end
		end
	end
end

--�õ������Buff(������״̬����)����
function Gas2Gac:RetQuestBuffVar(Conn, QuestName, BuffVar, VarNum)
	local tbl = {}
	local OldNum = tbl.DoNum
	tbl.DoNum = VarNum
	tbl.NeedNum = 1
	local TrackInfo = ""
	local BuffQuestMgr = g_BuffQuestMgr[QuestName]
	if BuffQuestMgr then
		for buffname,Tbl in pairs(BuffQuestMgr) do
			if buffname == BuffVar then
				TrackInfo = Tbl.TrackInfo
				break
			end
		end
	end
	
	g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][BuffVar] = tbl
	
	if g_GameMain.m_QuestRecordWnd.m_SelectQuestName == QuestName then
		g_GameMain.m_QuestRecordWnd:InitQuestInfo(QuestName)
	end
	if OldNum ~= VarNum then
		local canfinish = QuestVarNotify(QuestName, "������״̬����", BuffVar,TrackInfo,1, VarNum)
		g_GameMain.m_QuestTraceBack:QuestVarNumChange(QuestName)
		if OldNum == tbl.NeedNum or canfinish or VarNum == 0 then
			g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
			g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		end
	end
end

function Gas2Gac:RetAddQuestVar(Conn, QuestName, VarName, AddNum)
	if g_QuestNeedMgr[QuestName] == nil or g_QuestNeedMgr[QuestName][VarName] == nil then
		assert(false, "���ñ��в��Ҳ��� ������:"..QuestName.." �� "..VarName.. " ����")
	end
	local tbl = {}
	local OldNum = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][VarName].DoNum
	local NeedNum = g_QuestNeedMgr[QuestName][VarName].Num
	local TrackInfo = g_QuestNeedMgr[QuestName][VarName].TrackInfo
	local NeedType = g_QuestNeedMgr[QuestName][VarName].NeedType
	
	g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName][VarName].DoNum = OldNum+AddNum
	
	if g_GameMain.m_QuestRecordWnd.m_SelectQuestName == QuestName then
		g_GameMain.m_QuestRecordWnd:InitQuestInfo(QuestName)
	end
	
	if AddNum ~= 0 then
		local canfinish = QuestVarNotify(QuestName,NeedType,VarName,TrackInfo,NeedNum, OldNum+AddNum, true)
		g_GameMain.m_QuestTraceBack:QuestVarNumChange(QuestName)
		if OldNum == NeedNum or canfinish or OldNum+AddNum == 0 then
			g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
			g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		end
		UpdateObjCanUseState()
	end
end

--ɾ������
function Gas2Gac:RetGiveUpQuest(Conn, QuestName, result)
	if (true == result) then
		if Quest_Common(QuestName, "��������") == 10 then
			local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������", "1")
			g_GameMain.m_QuestRecordWnd.m_LoopTbl[tbl[1]] = nil
		end
		MsgClient(3028,g_GetLanQuestName(QuestName))
		g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName] = nil
		g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] = nil
		g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
		g_GameMain.m_HandBookWnd:DeleteQuest(QuestName)
		g_GameMain.m_QuestTraceBack:RemoveFromQuestTbl(QuestName)
		g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
		UpdateObjCanUseState()
		if QuestTimeTickTbl[QuestName] ~= nil then
			TimeDegree[QuestName] = nil
			UnRegisterTick(QuestTimeTickTbl[QuestName])
			QuestTimeTickTbl[QuestName] = nil 
		end
		--RetShowHintMsgWnd()
		g_GameMain.m_GuideBtn:BeAlertQuestEmptyAlert()
	end
end

--����ʧ��
function Gas2Gac:NotifyQuestFailure(Conn, QuestName)
	if QuestTimeTickTbl[QuestName] ~= nil then
		TimeDegree[QuestName] = nil
		UnRegisterTick(QuestTimeTickTbl[QuestName])
		QuestTimeTickTbl[QuestName] = nil 
	end
	if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State ~= QuestState.failure	then
		g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State = QuestState.failure	
		g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
		g_GameMain.m_QuestTraceBack:ShowTrackByQuestName(QuestName)
		UpdateObjCanUseState()
	end
end

--��������yy
function Gas2Gac:SendHideQuestSign(Conn, QuestName)
	if g_GameMain then
		if g_GameMain.m_QuestRecordWnd then
			g_GameMain.m_QuestRecordWnd.g_QuestHide[QuestName] = QuestName
		end
		if g_GameMain.m_NpcHeadSignMgr then
			g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		end
		if g_GameMain.m_AreaInfoWnd then
			g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
		end
	end
end

--����Npcͷ����Ϣ
function Gas2Gac:UpdateNpcHeadSign(Conn)
	if g_GameMain.m_NpcHeadSignMgr then
		g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
	end
end

-- �����ڲ߻����������ҽ�ȡ������ʧ�ܵĻ���ɾ����ҵĻ�״̬
function Gas2Gac:ClearLoopQuest(Conn, LoopName)
	if not g_GameMain.m_QuestRecordWnd.m_LoopTbl[LoopName] then
		return
	end
	local QuestName = g_LoopQuestMgr[LoopName][1][1].QuestName
	g_GameMain.m_QuestRecordWnd.m_LoopTbl[LoopName] = nil
	g_GameMain.m_AreaInfoWnd:RefreshQuestInfo(QuestName)
	g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
	g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
	UpdateObjCanUseState()
end

function Gas2Gac:InitMasterStrokeQuestLevTbl(Conn)
	g_GameMain.m_GuideBtn:BeAlertQuestEmptyAlert()
	g_MasterStrokeQuestLevTbl = {}
	g_MasterStrokeQuestLevTbl["DynamicLev"] = {}
	for QuestName, _ in pairs(g_MasterStrokeQuestMgr) do
		if not g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName]
			or g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State ~= QuestState.finish
			or Quest_Common(QuestName, "�ܷ��ظ�") == 1 then
				local level = Quest_Common(QuestName, "����ȼ�")
				if tonumber(level) then
					level = tonumber(level)
					if not g_MasterStrokeQuestLevTbl[level] then
						g_MasterStrokeQuestLevTbl[level] = {}
					end
					g_MasterStrokeQuestLevTbl[level][QuestName] = level
				else
					g_MasterStrokeQuestLevTbl["DynamicLev"][QuestName] = level
				end
		end
	end
end