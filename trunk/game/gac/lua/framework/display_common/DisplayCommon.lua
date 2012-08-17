lan_load "player/Lan_NewRoleProperty_Common"
gac_require "framework/display_common/DisplayCommonInc"

function CDisplayCommon:Ctor()
	self.m_tblClassCanUse =
		{
			EClass.eCL_MagicWarrior,	--"ħ��ʿ"
			EClass.eCL_NatureElf,		--"��ʦ"
			EClass.eCL_EvilElf,			--"аħ"
			EClass.eCL_Priest,			--"��ʦ"
--			EClass.eCL_Paladin,			--"������ʿ"
--			EClass.eCL_ElfHunter,		--"���鹭����"
			EClass.eCL_Warrior,			--"��ʿ"
			EClass.eCL_OrcWarrior,		--"����սʿ"
--			EClass.eCL_DwarfPaladin		--"������ʿ"
		}
			
	self.m_tblPlayerClassForShow =
		{
			[EClass.eCL_MagicWarrior]	= ToolTipsText(232),	--"ħ��ʿ"
			[EClass.eCL_NatureElf]		= ToolTipsText(233),	--"��ʦ"
			[EClass.eCL_EvilElf]		= ToolTipsText(234),	--"аħ"
			[EClass.eCL_Priest]			= ToolTipsText(235),	--"��ʦ"
			[EClass.eCL_Paladin]		= ToolTipsText(236),	--"������ʿ"
			[EClass.eCL_ElfHunter]		= ToolTipsText(237),	--"���鹭����"
			[EClass.eCL_Warrior]		= ToolTipsText(238),	--"��ʿ"
			[EClass.eCL_OrcWarrior]		= ToolTipsText(239),	--"����սʿ"
			[EClass.eCL_DwarfPaladin]	= ToolTipsText(240)		--"������ʿ"
		}
	
	self.m_tblPlayerShortClassForShow =
		{
			[EClass.eCL_MagicWarrior]	= ToolTipsText(284),	--"ħ��"
			[EClass.eCL_NatureElf]		= ToolTipsText(285),	--"��ʦ"
			[EClass.eCL_EvilElf]		= ToolTipsText(286),	--"аħ"
			[EClass.eCL_Priest]			= ToolTipsText(287),	--"��ʦ"
			[EClass.eCL_Paladin]		= ToolTipsText(288),	--"����"
			[EClass.eCL_ElfHunter]		= ToolTipsText(289),	--"����"
			[EClass.eCL_Warrior]		= ToolTipsText(290),	--"��"
			[EClass.eCL_OrcWarrior]		= ToolTipsText(291),	--"����"
			[EClass.eCL_DwarfPaladin]	= ToolTipsText(292)		--"����"
		}
		
	self.m_tblDisplayLevel = {"G", "F", "E", "D", "C", "B", "A", "S"}
	
	self.m_tblAreaFbPoinDisplay =
		{
			[1] = ToolTipsText(251),
			[2] = ToolTipsText(252),
			[3] = ToolTipsText(253),
			[4] = ToolTipsText(254),
			[5] = ToolTipsText(255),
			[6] = ToolTipsText(256),
			[7] = ToolTipsText(298),
			[8] = ToolTipsText(299),
			[9] = ToolTipsText(300),
			[10] = ToolTipsText(1200),
			[11] = ToolTipsText(1199)
		}
end

function CDisplayCommon:GetPlayerCampForShow(nCamp)
	return Lan_NewRoleProperty_Common(nCamp, "DisplayName")
end

function CDisplayCommon:GetPlayerClassForShow(ClassID)
	return self.m_tblPlayerClassForShow[ClassID]
end

function CDisplayCommon:GetPlayerShortClassForShow(ClassID)
	return self.m_tblPlayerShortClassForShow[ClassID]
end

function CDisplayCommon:GetPlayerClassCanUseTable()
	local tblResult = {}
	for i, v in pairs(self.m_tblClassCanUse) do
		local tbl = {}
		tbl.classID				= v
		tbl.classDisplayName	= self.m_tblPlayerClassForShow[v]
		table.insert(tblResult, tbl)
	end
	return tblResult
end

function CDisplayCommon:GetDisplayLevel(nLevel)
	return self.m_tblDisplayLevel[nLevel]
end

function CDisplayCommon:GetTongTypeName(type)
	local sShowType = ""
	if type == g_TongMgr:GetTongTypeByName("��ͨ") then
		sShowType = GetStaticTextClient(10045)
	elseif type == g_TongMgr:GetTongTypeByName("ս��") then
		sShowType = GetStaticTextClient(10046)
	elseif type == g_TongMgr:GetTongTypeByName("����") then
		sShowType = GetStaticTextClient(10053)
	elseif type == g_TongMgr:GetTongTypeByName("��Ӣս��") then
		sShowType = GetStaticTextClient(10054)
	elseif type == g_TongMgr:GetTongTypeByName("��Ӣ����") then
		sShowType = GetStaticTextClient(10055)
	end
	return sShowType
end