gac_gas_require "shortcut/ShortcutCommon"

--[[
������洢��˵����
	Type		Arg1				Arg2		Arg3
	1(��Ʒ)		uBigID				uSmallID	uGlobalID
	2(����)		TypeID				Level
	3(װ��)		EquipPart(װ����λ)
	4(��)		arrayName
��ע��	װ��ûʹ��ʱ������Ʒ(��ʱ������ϵ�ͼ��������Ʒ��)
		װ��ʹ�ú�����װ��(��ʱ������ϵ�ͼ������װ����)
--]]
function GetPieceInfo(Piece)
	local type = Piece:GetState()
	local arg1, arg2, arg3
	if(type == EShortcutPieceState.eSPS_Item) then
		--�ø����Ϸŵ�����Ʒ
		arg2, arg1 = Piece:GetItemContext()
		arg3 = Piece:GetMainSkill()
	elseif(type == EShortcutPieceState.eSPS_Skill) then
		--�ø����Ϸŵ��Ǽ���
		local fs = Piece:GetSkillContext()
		arg1 = fs.SkillName
		arg2 = fs.Level
		arg3 = Piece:GetMainSkill()
	elseif(type == EShortcutPieceState.eSPS_Equip) then
		--�ø����Ϸŵ���װ��
	elseif(type == EShortcutPieceState.eSPS_Array) then
		--�ø����Ϸŵ�����
		local fs = Piece:GetSkillArrayContext()
		arg1 = fs.SkillName
		arg2 = fs.Level
		arg3 = Piece:GetMainSkill()
	end
	return type, arg1, arg2, arg3
end

--������������
function SaveShortcut(Conn, Piece)
	local type, arg1, arg2, arg3 = GetPieceInfo(Piece)
	local pos = Piece:GetPos()
	if type == EShortcutPieceState.eSPS_Skill and string.find(arg1, "��ͨ����") == nil then
		local eCoolDownType = g_MainPlayer:GetSkillCoolDownType(arg1)
		if eCoolDownType == ESkillCoolDownType.eSCDT_FightSkill or 
			eCoolDownType == ESkillCoolDownType.eSCDT_NoComCDFightSkill or
			eCoolDownType == ESkillCoolDownType.eSCDT_UnrestrainedFightSkill or 
			eCoolDownType == ESkillCoolDownType.eSCDT_NonFightSkill then
			g_MainPlayer:AddLearnSkill(arg1,arg2)
		end
	end
	assert( pos,"����posΪnil" )
	assert( type,"����typeΪnil")
	assert( arg1,"����arg1Ϊnil")
	assert( arg2,"����arg2Ϊnil")
	assert( arg3,"����arg3Ϊnil")	
	if g_GameMain.m_MainSkillsToolBar.m_CurrentPage > 1 then
		pos = (g_GameMain.m_MainSkillsToolBar.m_CurrentPage - 1) * 10 + pos	
	end
	g_GameMain.m_MainSkillsToolBar.m_PieceTbl[arg3][pos] = {type, arg1, arg2}
	Gac2Gas:SaveShortCut(g_Conn, pos, type, arg1, arg2, arg3) --λ�á����ӵ���Ʒ���ԡ��������ơ����ܵĵȼ����Ƿ�Ϊ���˵�
	Gac2Gas:SaveShortCutEnd(g_Conn)
end

--�������˷��ؿ��������
function Gas2Gac:ReturnShortcut(Conn, Pos, Type, Arg1, Arg2, Arg3)
	--��������Ƿ�Ϸ�
	if	g_CheckShortcutData(Type, Arg1, Arg2, Arg3) then
		g_GameMain.m_MainSkillsToolBar:ReturnSkill( Pos, Type, Arg1, Arg2, Arg3 )
	end
end

function Gas2Gac:ReturnShortcutEnd(Conn,index)
	g_GameMain.m_MainSkillsToolBar.m_CurrentPage = index
	g_GameMain.m_BeastPoseWnd.m_BgBtnTbl[index]:AddFlashInfoByName("OrangeEquip")
	g_GameMain.m_BeastPoseWnd:UpdateBeastPosToolBar()
end