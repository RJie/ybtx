gac_gas_require "player/PlayerMgrInc"

function g_AddPlayerInfo(uCharID, uCharName, player)
	g_tblPlayerMgr[uCharID] = player
	g_tblPlayerName2ID[uCharName] = uCharID
end

function g_DelPlayerInfo(uCharID, uCharName)
	local function Init()
		g_tblPlayerMgr[uCharID] = nil
		g_tblPlayerName2ID[uCharName] = nil
	end
	apcall(Init)
end

function g_GetPlayerInfo(uCharID)
	return g_tblPlayerMgr[uCharID]
end

function g_GetPlayerInfoByName(uCharName)
	if not g_tblPlayerName2ID[uCharName] then
		return nil
	end
	return g_tblPlayerMgr[g_tblPlayerName2ID[uCharName]]
end

function g_LoadGeniusNamefun()
	for j= 1, 9 do
		local tbl = loadGeniusfile(j)
		local Keys = tbl:GetKeys()
		for i ,p in pairs(Keys) do 
			CTalentHolder_InsertName(p) 
		end
	end
	cfg_load "skill/EquipGift_Common"
	local Keys = EquipGift_Common:GetKeys()
	for m, n in pairs(Keys) do
		CTalentHolder_InsertName(n)
	end
end

function g_GetPlayerClassNameByID(ClassID)
	local tbl = {	[EClass.eCL_MagicWarrior]	= "ħ��ʿ",
					[EClass.eCL_NatureElf]		= "��ʦ",
					[EClass.eCL_EvilElf]		= "аħ",
					[EClass.eCL_Priest]			= "��ʦ",
					[EClass.eCL_Paladin]		= "������ʿ",
					[EClass.eCL_ElfHunter]		= "���鹭����",
					[EClass.eCL_Warrior]		= "��ʿ",
					[EClass.eCL_OrcWarrior]		= "����սʿ",
					[EClass.eCL_DwarfPaladin]	= "������ʿ"	}
	return tbl[ClassID]
end
