-- ����player����Ҳ��Ҫ�����Դ�������ڽ�ɫѡ�����ʹ�����ɫ��ʱ��Ҳ��Ҫ֪��ȱʡ��װ����Դid
-- ������ɾ����װ���󣬻�����ʾ������ģ��
cfg_load "model_res/HorseRes_Common"
cfg_load "model_res/WeaponRes_Common"
cfg_load "model_res/CustomRes_Common"
cfg_load "item/Equip_Weapon_Common"
cfg_load "item/Equip_Armor_Common"
cfg_load "item/Equip_Jewelry_Common"
cfg_load "item/Equip_Ring_Common" 
cfg_load "item/Equip_Shield_Common"

-- ������Դ
g_sParseHorseTblServer = {}
g_sParseHorseTblClient = {}
AddCheckLeakFilterObj(g_sParseHorseTblServer)
AddCheckLeakFilterObj(g_sParseHorseTblClient)

function ParseHorseResServer()
	local count = 1
	for i,p in ipairs(HorseRes_Common:GetKeys()) do
		g_sParseHorseTblServer[p] = count
		count = count + 1
	end
end	

function ParseHorseResClient()
	local count = 1
		for i,p in ipairs(HorseRes_Common:GetKeys()) do
		g_sParseHorseTblClient[count] = p
		count = count + 1
	end
end

ParseHorseResServer()
ParseHorseResClient()
AddCheckLeakFilterObj(g_sParseHorseTblServer)
AddCheckLeakFilterObj(g_sParseHorseTblClient)

--������Դ
g_sParseWeaponTblServer = {}
g_sParseWeaponTblClient = {}
AddCheckLeakFilterObj(g_sParseWeaponTblServer)
AddCheckLeakFilterObj(g_sParseWeaponTblClient)

function ParseWeaponResServer()
	local count = 1
	for i,p in ipairs(WeaponRes_Common:GetKeys()) do
		g_sParseWeaponTblServer[p] = count
		count = count + 1
	end
end	

function ParseWeaponResClient()
	local count = 1
	for i,p in ipairs(WeaponRes_Common:GetKeys()) do
		g_sParseWeaponTblClient[count] = p
		count = count + 1
	end
end

ParseWeaponResServer()
ParseWeaponResClient()
AddCheckLeakFilterObj(g_sParseWeaponTblServer)
AddCheckLeakFilterObj(g_sParseWeaponTblClient)

g_ParseCustomTblServer = {}
g_ParseCustomTblClient = {}

function ParseCustomResServer()
	local count = 1
	for i,p in ipairs(CustomRes_Common:GetKeys()) do
		g_ParseCustomTblServer[p] = count
		count = count + 1
	end
end	

function ParseCustomResClient()
	local count = 1
	for i,p in ipairs(CustomRes_Common:GetKeys()) do
		g_ParseCustomTblClient[count] = p
		count = count + 1
	end
end

ParseCustomResServer()
ParseCustomResClient()
AddCheckLeakFilterObj(g_ParseCustomTblServer)
AddCheckLeakFilterObj(g_ParseCustomTblClient)

--����������
g_SParseWeaponTbl = {}
g_CParseWeaponTbl = {}
AddCheckLeakFilterObj(g_SParseWeaponTbl)
AddCheckLeakFilterObj(g_CParseWeaponTbl)

function ParseWeaponTbl()
	local count = 1
	for i,p in ipairs(Equip_Weapon_Common:GetKeys()) do
		g_SParseWeaponTbl[p] = count
		g_CParseWeaponTbl[count] = p
		count = count + 1
	end
end

ParseWeaponTbl()

-- ���ƽ�����
g_SParseShieldTbl = {}
g_CParseShieldTbl = {}
AddCheckLeakFilterObj(g_SParseShieldTbl)
AddCheckLeakFilterObj(g_CParseShieldTbl)

function ParseShieldTbl()
	local count = 1
	for i,p in ipairs(Equip_Shield_Common:GetKeys()) do
		g_SParseShieldTbl[p] = count
		g_CParseShieldTbl[count] =  p
		count = count + 1
	end
end

ParseShieldTbl()

-- ��ָ������
g_SParseRingTbl = {}
g_CParseRingTbl = {}
AddCheckLeakFilterObj(g_SParseRingTbl)
AddCheckLeakFilterObj(g_CParseRingTbl)

function ParseRingTbl()
	local count = 1
	for i,p in ipairs(Equip_Ring_Common:GetKeys()) do
		g_SParseRingTbl[p] = count
		g_CParseRingTbl[count] =  p
		count = count + 1
	end		
end

ParseRingTbl()

--��Ʒ������ 
g_SParseJewelryTbl = {}
g_CParseJewelryTbl = {}
AddCheckLeakFilterObj(g_SParseJewelryTbl)
AddCheckLeakFilterObj(g_CParseJewelryTbl)

function ParseJewelryTbl()
	local count = 1
	for i,p in ipairs(Equip_Jewelry_Common:GetKeys()) do
		g_SParseJewelryTbl[p] = count
		g_CParseJewelryTbl[count] =  p
		count = count + 1
	end		
end

ParseJewelryTbl()

--���߽�����
g_SParseArmorTbl = {}
g_CParseArmorTbl = {}
AddCheckLeakFilterObj(g_SParseArmorTbl)
AddCheckLeakFilterObj(g_CParseArmorTbl)

function ParseArmorTbl()
	local count = 1
	for i,p in ipairs(Equip_Armor_Common:GetKeys()) do
		g_SParseArmorTbl[p] = count
		g_CParseArmorTbl[count] =  p
		count = count + 1
	end		
end

ParseArmorTbl()

function g_GetNewRoleRes(nClass)
	--    ģ��10������
	--    ͷ��         �·�        ����(����)  �粿            �ֲ�       �Ų�        ����       ����(ĳЩְҵ)
	local uArmetResID, uBodyResID, uBackResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID, uOffWeaponID =
		"","","","","","",0,0
		
	if nClass == EClass.eCL_Warrior then			--��ʿ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"��ʿͷ��","��ʿ����","��ʿ���","��ʿ����","��ʿЬ��",g_sParseWeaponTblServer["��ʿ����"]
	
	elseif nClass == EClass.eCL_MagicWarrior then	--ħ��ʿ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"ħ��ʿͷ��","ħ��ʿ����","ħ��ʿ���","ħ��ʿ����","ħ��ʿЬ��",g_sParseWeaponTblServer["ħ��ʿ����"]
	
	elseif nClass == EClass.eCL_Paladin then		--������ʿ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"������ʿͷ��","������ʿ����","������ʿ���","������ʿ����","������ʿЬ��",g_sParseWeaponTblServer["������ʿ����"]
	
	elseif nClass == EClass.eCL_NatureElf then		--��ʦ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"��ʦͷ��","��ʦ����","��ʦ���","��ʦ����","��ʦЬ��",g_sParseWeaponTblServer["��ʦ����"]
	
	elseif nClass == EClass.eCL_EvilElf then		--аħ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"аħͷ��","аħ����","аħ���","аħ����","аħЬ��",g_sParseWeaponTblServer["аħ����"]
	
	elseif nClass == EClass.eCL_Priest then			--��ʦ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"��ʦͷ��","��ʦ����","��ʦ���","��ʦ����","��ʦЬ��",g_sParseWeaponTblServer["��ʦ����"]
	
	elseif nClass == EClass.eCL_ElfHunter then		--���鹭����
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"���鹭����ͷ��","���鹭��������","���鹭���ּ��","���鹭���ֻ���","���鹭����Ь��",g_sParseWeaponTblServer["���鹭��������"]
		
	elseif nClass == EClass.eCL_DwarfPaladin then	--������ʿ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID =
		"������ʿͷ��","������ʿ����","������ʿ���","������ʿ����","������ʿЬ��",g_sParseWeaponTblServer["������ʿ����"]
	
	elseif nClass == EClass.eCL_OrcWarrior then		--����սʿ
		uArmetResID, uBodyResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID, uOffWeaponID =
		"����սʿͷ��","����սʿ����","����սʿ���","����սʿ����","����սʿЬ��",g_sParseWeaponTblServer["����սʿ����"],g_sParseWeaponTblServer["����սʿ��������"]
	end
	
	--return uArmetResID, uBodyResID, uBackResID, uShoulderResID, uArmResID, uShoeResID, uWeaponID, uOffWeaponID
	local ResTbl = {}
	ResTbl["ArmetResID"] 		= uArmetResID
	ResTbl["BodyResID"] 		= uBodyResID
	ResTbl["ArmResID"] 			= uArmResID
	ResTbl["ShoeResID"] 		= uShoeResID
	ResTbl["ShoulderResID"] 	= uShoulderResID
	ResTbl["WeaponResID"] 		= uWeaponID
	ResTbl["OffWeaponResID"] 	= uOffWeaponID
	return ResTbl
end

function g_DelPieceByPart(EquipPart,RenderObj)
	if EquipPart == EEquipPart.eWear then --�·�
		RenderObj:RemovePiece( "body" )
	elseif EquipPart == EEquipPart.eHead then  --ͷ
		RenderObj:RemovePiece( "armet" )
	elseif EquipPart == EEquipPart.eBack then --��
		RenderObj:RemovePiece( "back" )
	elseif EquipPart == EEquipPart.eShoe then --Ь
		RenderObj:RemovePiece( "shoe" )
	elseif EquipPart == EEquipPart.eWeapon then --����
		RenderObj:RemovePiece( "weapon" )
	elseif EquipPart == EEquipPart.eAssociateWeapon then --����
		RenderObj:RemovePiece( "offweapon" )
	elseif EquipPart == EEquipPart.eShoulder then --��
		RenderObj:RemovePiece( "shoulder" )
	elseif EquipPart == EEquipPart.eHand then --��
		RenderObj:RemovePiece( "arm" )	
	end
end

function g_GetDefaultResID(nClass)
	return  "��������","���廤��","����Ь��"
end

function g_IsUpdateModel(EquipPart)
	if EquipPart == EEquipPart.eWear --�·�
		or EquipPart == EEquipPart.eHead --ͷ��
		or EquipPart == EEquipPart.eShoulder--�粿
		or EquipPart == EEquipPart.eShoe --�Ų�
		or EquipPart == EEquipPart.eWeapon --��������
		or EquipPart == EEquipPart.eAssociateWeapon --��������	
		or EquipPart == EEquipPart.eHand --�ֲ�
		or EquipPart == EEquipPart.eBack then --���� 								
		return true
	end
	return false
end

function CheckWeaponEquipType(EquipType)
	local hand = string.sub(EquipType,1,2)
	if hand == "��" then
		return true
	end
	return false
end

function g_GetResIDByEquipPart(EquipPart,Player)
	local uBodyResID, uArmResID, uShoeResID = g_GetDefaultResID(Player:CppGetClass())
	local ResID = 0
	if EquipPart == EEquipPart.eWear then --�·�
		local BodyResID = nil 
		local IndexID = Player.m_Properties:GetBodyIndexID()
		if IndexID ~= 0 then
			BodyResID = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"ResID")
		end
		return (BodyResID and BodyResID or uBodyResID)
	elseif EquipPart == EEquipPart.eHead then  --ͷ��
		local HeadResID = nil
		local IndexID =  Player.m_Properties:GetHeadIndexID()
		local bShowArmet = Player.m_Properties:GetShowArmet()
		if IndexID ~= 0 and bShowArmet then
			HeadResID = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"ResID")
		end
		return (HeadResID and HeadResID or ResID )
	elseif EquipPart == EEquipPart.eShoulder then --�粿
		local ShoulderResID	= nil
		local IndexID =  Player.m_Properties:GetShoulderIndexID()
		if IndexID ~= 0 then
			ShoulderResID = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"ResID")
		end
		return (ShoulderResID and ShoulderResID or ResID)
	elseif EquipPart == EEquipPart.eShoe then   --�Ų�
		local ShoeResID = nil  
		local IndexID =  Player.m_Properties:GetShoeIndexID()
		if IndexID ~= 0 then
			ShoeResID = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"ResID")
		end
		return ShoeResID and ShoeResID or uShoeResID
	elseif EquipPart == EEquipPart.eWeapon then --��������
		local WeaponResID = nil
		local IndexID =  Player.m_Properties:GetWeaponIndexID()
		if IndexID ~= 0 then
			WeaponResID = g_sParseWeaponTblServer[g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticWeaponBigID(),g_CParseWeaponTbl[IndexID],"ResID")]
		end
		return (WeaponResID and WeaponResID or ResID)
	elseif EquipPart == EEquipPart.eAssociateWeapon then --��������	
		local OffWeaponResID  = nil
		local nBigID =  Player.m_Properties:GetOffWeaponBigID()
		if nBigID ~= 0 then
			local IndexID =  Player.m_Properties:GetOffWeaponIndexID()
			if g_ItemInfoMgr:IsStaticWeapon(nBigID) then
				if CheckWeaponEquipType(g_ItemInfoMgr:GetItemInfo(nBigID,g_CParseWeaponTbl[IndexID],"EquipType")) then 
					OffWeaponResID = g_sParseWeaponTblServer[g_ItemInfoMgr:GetItemInfo(nBigID,g_CParseWeaponTbl[IndexID],"AssociateResID")]
				else
					OffWeaponResID = g_sParseWeaponTblServer[g_ItemInfoMgr:GetItemInfo(nBigID,g_CParseWeaponTbl[IndexID],"ResID")]
				end
			elseif g_ItemInfoMgr:IsStaticShield(nBigID) then
				OffWeaponResID = g_sParseWeaponTblServer[g_ItemInfoMgr:GetItemInfo(nBigID,g_CParseShieldTbl[IndexID],"ResID")]
			end
			
		end
		return (OffWeaponResID and OffWeaponResID or ResID)		
	elseif EquipPart == EEquipPart.eHand then  --�ֲ�
		local HandResID  = nil
		local IndexID =  Player.m_Properties:GetArmIndexID()
		if IndexID ~= 0 then 
			HandResID = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"ResID")
		end 
		return (HandResID and HandResID or uArmResID)			
	elseif EquipPart == EEquipPart.eBack then  --����
		local BackResID  = nil
		local IndexID =  Player.m_Properties:GetBackIndexID()
		if IndexID ~= 0 then 
			BackResID = g_ItemInfoMgr:GetItemInfo(g_ItemInfoMgr:GetStaticArmorBigID(),g_CParseArmorTbl[IndexID],"ResID")
		end
		return (BackResID and BackResID or ResID)			
	end
end

function g_GetEquipPhaseByEquipPart(eEquipPart,Player)
	if eEquipPart == EEquipPart.eWeapon then
		return Player.m_Properties:GetWeaponPhase()
	elseif eEquipPart == EEquipPart.eAssociateWeapon then
		return Player.m_Properties:GetOffWeaponPhase()
	elseif eEquipPart == EEquipPart.eWear then
		return Player.m_Properties:GetBodyPhase()
	elseif eEquipPart == EEquipPart.eHead then
		local bShowArmet = Player.m_Properties:GetShowArmet()
		if bShowArmet then
			return Player.m_Properties:GetHeadPhase()
		else
			return 0
		end
	elseif eEquipPart == EEquipPart.eShoulder then
		return Player.m_Properties:GetShoulderPhase()
	elseif eEquipPart == EEquipPart.eHand then
		return Player.m_Properties:GetArmPhase()
	elseif eEquipPart == EEquipPart.eShoe then
		return Player.m_Properties:GetShoePhase()
	end	
end

ERace = {}
ERace.Human = "����" 
ERace.Dwarf = "����"
ERace.Elf   = "����" 	
ERace.Orc   = "����" 

function ClassToRace(Class)
	if Class == EClass.eCL_Warrior or  Class == EClass.eCL_MagicWarrior or Class == EClass.eCL_Paladin or 
		 Class == EClass.eCL_NatureElf or Class == EClass.eCL_EvilElf or Class == EClass.eCL_Priest then
		return ERace.Human
	elseif Class == EClass.eCL_ElfHunter then
		return ERace.Elf
	elseif Class == EClass.eCL_DwarfPaladin then
		return ERace.Dwarf
	elseif Class == EClass.eCL_OrcWarrior then
		return ERace.Orc
	end
end

function GetClassNameStr(uClass)
	local ClassName
	if uClass == EClass.eCL_Warrior  then
		ClassName = "djs"
	elseif uClass == EClass.eCL_MagicWarrior then
		ClassName = "mjs"
	elseif	 uClass == EClass.eCL_Paladin then
		ClassName = "qs"
	elseif	 uClass == EClass.eCL_NatureElf then
		ClassName = "fs"
	elseif	 uClass == EClass.eCL_EvilElf then
		ClassName = "xm"
	elseif	 uClass == EClass.eCL_Priest then
		ClassName = "ms"
	elseif uClass == EClass.eCL_ElfHunter then
		ClassName = "djs"
	elseif uClass == EClass.eCL_DwarfPaladin then
		ClassName = "djs"
	elseif uClass == EClass.eCL_OrcWarrior then
		ClassName = "sr"
   	end
   	return ClassName
end

function GetNewRoleFxName(uClass, uSex)
	local FxFilePath = "fx/setting/xuanrenjiemian/"
	local ClassName = GetClassNameStr(uClass)
   	return 	FxFilePath..ClassName.."/"..MakeAniFileName(uClass, uSex, nil)..".efx"
end

function split (s, delim)
	assert (type (delim) == "string" and string.len (delim) > 0, "bad delimiter")
	local start = 1
	local t = {}  -- results table
	
	if string.sub(s,1,1) == "\"" and string.sub(s,-1) == "\"" then
		s = string.sub(s,2,string.len(s)-1)
	end
	
	while true do
		local pos = string.find (s, delim, start, true) -- plain find
		if not pos then
			break
		end
		table.insert (t, string.sub (s, start, pos - 1))
		start = pos + string.len (delim)
	end -- while
	
	-- insert final one (after last delimiter)
	table.insert (t, string.sub (s, start))
	return t
end

function GetModelName(ModelFileName)
	if ModelFileName == "" or ModelFileName ==nil then
		return ""
	end 
	local temp1,temp2
	temp1 = string.gsub(ModelFileName,"/",",")
	temp2 = string.gsub(temp1,".mod","")
	local Table = split(temp2, ",")
	return Table[table.getn(Table)]
end

-- ��������ƴ��
function MakeAniFileName( uClass, uSex, AniType )
	local strRaceSexType = GetRaceSexTypeString( uClass, uSex )
	local strAniType = ""
	if AniType ~= nil then
		local AniTypeTable = split(AniType, ",")
		strAniType = AniTypeTable[1]
		if table.getn(AniTypeTable) > 1 then
			if strAniType=="wf" then
				local strPlayType = AniTypeTable[2]
				if strPlayType == "" or strPlayType == nil then
					print("AniType Error")
				else 
					return strAniType.."/"..strRaceSexType .."_"..strAniType.."_"..strPlayType
				end
			elseif strAniType == "jt" then
				local strHorseType = AniTypeTable[2]
				if strHorseType == "" or strHorseType == nil then
					print("AniType Error")
				else 
					return strAniType.."/"..strRaceSexType.."_"..strHorseType
				end
			elseif strAniType == "zq" then
				local strHandType = GetHandTypeString(AniTypeTable[2], uClass)
				local strHorseType = AniTypeTable[3]
				return strRaceSexType.."_"..strHorseType.."_"..strHandType
			end
		end
	end 
	
	local strClassType = GetClassTypeSting(uClass)	
	local strHandType = GetHandTypeString(strAniType, uClass)
	strAniFileName = strRaceSexType .."_"..strClassType.."_"..strHandType
	return strAniFileName
end

-- �õ�"�����Ա�"������������һ���ֶΣ�
function GetRaceSexTypeString(uClass, uSex)
    local strRace, strSex
	if EClass.eCL_Warrior == uClass or EClass.eCL_NatureElf == uClass or EClass.eCL_MagicWarrior == uClass or
		EClass.eCL_Priest == uClass or EClass.eCL_EvilElf == uClass or EClass.eCL_Paladin == uClass then
		strRace = "rl"		-- ����
	elseif EClass.eCL_OrcWarrior == uClass then 
		strRace = "sr"		-- ����
--	elseif EClass.eCL_DwarfPaladin == uClass then
--		strRace = "ar"
--	elseif EClass.eCL_ElfHunter == uClass then
--		strRace = "jl"		
	else
		strRace = "rl"
		--LogErr("������Ϣ�����ݸ�����ƴ�Ӻ�����[ְҵ]�������󣬻�����varient����" .. uClass )	
	end
	
	if ECharSex.eCS_Male == uSex then
		strSex="m"			-- ��
	elseif ECharSex.eCS_Female == uSex then
		strSex="w"			-- Ů
	else
		strSex="m"
		--LogErr("������Ϣ�����ݸ�����ƴ�Ӻ�����[�Ա�]�������󣬻�����varient����" .. uSex )
	end
	
	return strRace..strSex
end

-- �õ�"ְҵ����"�����������ڶ����ֶΣ�
function GetClassTypeSting( uClass )
	local strClassType = ""
	if EClass.eCL_Warrior == uClass or EClass.eCL_MagicWarrior == uClass or EClass.eCL_OrcWarrior == uClass then
		strClassType = "js"		-- ��ʿ��ħ��ʿ������սʿ
	elseif EClass.eCL_NatureElf == uClass or EClass.eCL_EvilElf == uClass or EClass.eCL_Priest == uClass then
		strClassType = "fs"		-- ��ʦ����ʦ��аħ
	elseif EClass.eCL_Paladin == uClass then
		strClassType = "qs"		-- ���
--	elseif EClass.eCL_DwarfPaladin == uClass then
--		strClassType = "qs"		-- ����
--	elseif EClass.eCL_ElfHunter == uClass then
--		strClassType = "gs"		-- ���鹭����
	else
		strClassType = "js"
		--LogErr("������Ϣ�����ݸ�����ƴ�Ӻ�����[ְҵ]�������󣬻�����varient����" .. uClass )
	end
	
	return strClassType
end

-- �õ�"��˫������"�����������ڶ����ֶΣ�
function GetHandTypeString(strAniType, uClass)
	local result, HandType = g_ItemInfoMgr:EquipTypeCheck(strAniType, uClass)
	if HandType ~= nil then
		if HandType == "˫" then
			strHandType="ss"
		else
			strHandType="ds"
		end	
	else
		strHandType="ds"		-- ���ֶ������ڵ��ֶ�������
	end
	return strHandType
end
