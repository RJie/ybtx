gas_require "log_mgr/CLogMgr"

local function GetItemTbl(Str)
	local tbl = loadstring("return" .. Str)()
	return tbl
end
------------------------------------ ս����Ʒ��غ���--------------------------------------------------------------
local function DBCreateFightItem(Player, uBigID, sItemName , nCount )
	--��ʱȷ�����м��ܴ�������Ʒ������SkillItem_Common ����21����Ʒ
	local function callback(result)
		if IsCppBound(Player) then
			if IsNumber(result) then
				if result == 3 then
					--,'�����ռ䲻��'
					MsgToConn(Player.m_Conn,160000)
				elseif result == 0 then
					MsgToConn(Player.m_Conn,8003,'CreateFightItem error')
				end
				return
			end
			CRoleQuest.add_item_DB_Ret(Player,uBigID,sItemName,nCount,result)
		end
	end
	
	local data = {}
	data["char_id"]		= Player.m_uID
	data["nType"]		= uBigID
	data["sName"] 		= sItemName
	data["nCount"]		= nCount
	data["sceneName"]	= Player.m_Scene.m_SceneName
	data["createType"]	= event_type_tbl["������Ʒ���"]
	local Conn = Player.m_Conn
	if Conn.m_Account == nil then
		return
	end
	CallAccountAutoTrans(Conn.m_Account, "CharacterMediatorDB","AddItem",callback,data)
end

--����(������)�ɹ�, ɾ��ս�������Ʒ
local function DBDelFightItemByID(Player, itemid)
	--���ݿ����
	local function callback(res, pos_info)
		if not res then
			return
		end
	end
	
	local parameter = {}
	parameter["char_id"] = Player.m_Conn.m_Player.m_uID
	parameter["item_id"] = itemid
	CallAccountManualTrans(Player.m_Conn.m_Account, "CharacterMediatorDB", "DeleteItem", callback, parameter)
end

local function DBDelMarkFightItemByCount(Player, nItemType, nIndex , requireCount )
	local function CallBack(res)
	end
	local parameter = {}
	parameter["nCharID"] =  Player.m_uID
	parameter["nItemType"] = nItemType
	parameter["nIndex"] = nIndex
	parameter["nCount"] = requireCount
	CallAccountManualTrans(Player.m_Conn.m_Account, "CharacterMediatorDB", "DelItem", CallBack, parameter)
end

function g_UseSkillItem(Connection, Player, nRoomIndex, nPos, nBigID, nIndex, nItemID,nEquipPart,Data)
	assert(3==nBigID)
	local SkillName = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"SkillName")
	if not SkillName or SkillName == "" or Player:IsSingTypeSkill(SkillName) then
		--3����Ʒ��û�����Ʒ�� ����ʹ�ô���Ʒ����
		return
	end
	local ItemType = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"ItemType")
	if ItemType == "��սҩˮ" then
		SceneType = Player.m_Scene.m_SceneAttr.SceneType
		if SceneType ~= 1 and SceneType ~= 7 and SceneType ~= 8 and SceneType ~= 26 and SceneType ~= 27 then
			MsgToConn(Connection, 842)
			return
		end
	end
		
	if (Player:CppGetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseDrugItemSkill) == true) then
		MsgToConn(Connection, 1036)
		return
	end
	local RequireCount = tonumber(g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"Count"))
	if RequireCount < 0 then
		RequireCount = 0 - RequireCount
	end

	if Player:TestDBTransBlock() then
		MsgToConn(Connection, 802)
		return
	end
	local uSuccess = Player:PlayerDoItemSkill(SkillName,g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"SkillLevel"))
	if uSuccess == EDoSkillResult.eDSR_Success and RequireCount ~= 0 then
		DBDelFightItemByID(Player,nItemID)
	else
		--print("g_UseSkillItem Failed")
	end
end

function ItemSkillEnd(Player, SkillName)
	local skillItem,nIndex,requireCount,Count
	local keys = SkillItem_Common:GetKeys()
	for i, v in pairs(keys) do
		local skillItem = SkillItem_Common(v)
		if skillItem("SkillName") == SkillName then
			nIndex = v
			Count = skillItem("Count")
			break
		end
	end
	if nIndex and Count ~= 0 and Player.NowSkillItemTbl == nil then
		--print("���ܼ��ܱ������...ע��!")
		return
	end
	if nIndex and Count ~= 0 and #(Player.NowSkillItemTbl) > 0 then
		--���ڲ�֧�ּ���������Ʒ����������Ҫ��lua�����̣������߼��ܵ�����
		--��Ϊ���ܵ�TestItemExist�ص�Ҫ�����ݿ���Ʒ�Ƿ���ڣ���������������ݿ��callback���첽����������Ʒ���ڴ澵��
--		for i = 1, #(Player.NowSkillItemTbl) do
--			DBDelFightItemByID(Player,Player.NowSkillItemTbl[i][2])
--		end
--		Player.NowSkillItemTbl = {}
		return
	end
	local keys = SkillItem_Common:GetKeys()
	for i, v in pairs(keys) do
		local skillItem = SkillItem_Common(v)
		local ConsumeItemSkillNameTbl = {}
		if skillItem("ConsumeItemSkillName") ~= "" then
			ConsumeItemSkillNameTbl = GetItemTbl(skillItem("ConsumeItemSkillName"))
		end
		for j =1, # ConsumeItemSkillNameTbl do
			if ConsumeItemSkillNameTbl[j] == SkillName then
				nIndex = v
				requireCount = GetItemTbl(skillItem("Count"))[j]
				break
			end
		end
	end
	if nIndex then
		if requireCount > 0 then
			DBCreateFightItem(Player, 3, nIndex , requireCount )
		else
			--print("��֧�ּ���������Ʒ")
--			Count = 0 - requireCount
--			if Count == 0 then
--				return
--			end
--			for i = 1, #(Player.NowSkillItemTbl) do
--				DBDelFightItemByID(Player,Player.NowSkillItemTbl[i][2])
--			end
--			Player.NowSkillItemTbl = {}
		end
	end
end


function Gac2Gas:FightAreaSkillSelectArea(Connection,fPosX,fPosY,SkillName, ItemName)
	local Player = Connection.m_Player
	local pos = CFPos:new()
	pos.x = fPosX
	pos.y = fPosY
	
	local nIndex, nLevel, Count, isSuccess, isItemExist, uSuccess
	local keys = SkillItem_Common:GetKeys()
	for i, v in pairs(keys) do
		local skillItem = SkillItem_Common(v)
		if skillItem("SkillName") == SkillName and v == ItemName then
			nIndex = v
			nLevel = skillItem("SkillLevel")
			Count = skillItem("Count")
			if Count < 0 then
				Count = 0 - Count
			end
			break
		end
	end
	if not nIndex then
		--print("Gac2Gas:FightAreaSkillSelectArea �˼��ܲ�����Ʒ����")
		return
	end
	if #(Player.NowSkillItemTbl) > Count or #(Player.NowSkillItemTbl) == Count then  --��Ʒ����
		if Player.NowSkillItemTbl[1][1] == nIndex then
			isItemExist = true
			isSuccess = true
		end
	end

	if isSuccess then
		if Player:TestDBTransBlock() then
			MsgToConn(Connection, 802)
			return
		end
		uSuccess = Player:PlayerDoPosSkill(SkillName, nLevel, pos)
	else
		--print("ʹ��ʧ��")
		return
	end
	if Player:IsSingTypeSkill(SkillName) and uSuccess == EDoSkillResult.eDSR_Success then
		--�����༼��  ����������ʱ�ٻص�ɾ����Ʒ
		return
	elseif uSuccess == EDoSkillResult.eDSR_Success and Count ~= 0 then
		if isSuccess and #(Player.NowSkillItemTbl) > 0 then
			for i = 1, #(Player.NowSkillItemTbl) do
				--����������,�ص��ҩƷ���ܴӿͻ����ٻ���,����NowSkillItemTbl������Ʒ�Ѿ�ɾ����
				--����еص�ҩƷ�������ڸĳɶ����ݿ�
				DBDelFightItemByID(Player,Player.NowSkillItemTbl[i][2])
			end
		else
			--print("g_UseSkillItem Failed:��Ʒ����")
		end
		Player.NowSkillItemTbl = {}
	else
		Player.NowSkillItemTbl = {}
		--print("g_UseSkillItem Failed")
	end
end

function Gac2Gas:FightSkillRequireItem(Connection, SkillName, SkillLevel)
	--������ ��ItemName
	--ConsumeItemSkillName
	local Player = Connection.m_Player
	local nIndex, requireCount
	local keys = SkillItem_Common:GetKeys()
	for i, v in pairs(keys) do
		local skillItem = SkillItem_Common(v)
		local ConsumeItemSkillNameTbl = {}
		if skillItem("ConsumeItemSkillName") ~= "" then
			ConsumeItemSkillNameTbl = GetItemTbl(skillItem("ConsumeItemSkillName"))
		end
		for j =1, # ConsumeItemSkillNameTbl do
			if ConsumeItemSkillNameTbl[j] == SkillName then
				nIndex = v
				requireCount = GetItemTbl(skillItem("Count"))[j]
				break
			end
		end
	end
	if not nIndex then
		--SkillItem_Common���в������������
		return
	end
	if (Player:CppGetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseDrugItemSkill) == true) then
		MsgToConn(Connection, 1036)
		return
	end
	local Count
	local uSuccess
	if requireCount > 0 then
		uSuccess = Player:PlayerDoItemSkill(SkillName, SkillLevel)
		if uSuccess == EDoSkillResult.eDSR_Success then
			DBCreateFightItem(Player, 3, nIndex , requireCount )
		end
		return
	else
		Count = 0 - requireCount
	end
	
	local function CallBack(ret)
		if not ret then
			--print("��Ʒ��������")
			return
		end
		if Player:IsSingTypeSkill(SkillName) then
			--�����༼��  ����������ʱ�ٻص�ɾ����Ʒ
			--uSuccess = Player:PlayerDoItemSkill(SkillName, SkillLevel)
			return
		else
			uSuccess = Player:PlayerDoItemSkill(SkillName, SkillLevel)
			if uSuccess == EDoSkillResult.eDSR_Success then
				DBDelMarkFightItemByCount(Player, 3, nIndex , Count )
			end
		end
	end
	
	local parameter = {}
	parameter["nCharID"] =  Player.m_Conn.m_Player.m_uID
	parameter["nItemType"] = 3
	parameter["nIndex"] = nIndex
	parameter["nCount"] = requireCount
	CallAccountManualTrans(Player.m_Conn.m_Account, "CharacterMediatorDB", "HaveItemCount", CallBack, parameter)
end
