--����ʱ����buff
gas_require "world/int_obj/IntObjServer"
cfg_load "int_obj/IntObj_Common"

local GetDistance = g_GetDistance
local IntObjServerMgr = g_IntObjServerMgr
local g_ObjActionArgTbl = g_ObjActionArgTbl
local os = os
local DropItemProtectTime = DropItemProtectTime
local MsgToConn = MsgToConn
local NpcDropObjTbl = NpcDropObjTbl

local g_GetPlayerInfo = g_GetPlayerInfo
local Entry = CreateSandBox(...)

function Entry.Exec(Conn, BuffObj, ObjName, GlobalID)
	local PlayerId = Conn.m_Player.m_uID
	
	if GetDistance(Conn.m_Player,BuffObj) > 6 then
		return 
	end
	
	local DropOwnerId = BuffObj.m_Properties:GetDropOwnerId()
	local BelongTeam = BuffObj.m_Properties:GetBelongToTeam()
	local DropNpcID = BuffObj.m_BelongToNpc
	local DropTime = BuffObj.m_Properties:GetDropTime()
	if BelongTeam ~= 0 then  --��npc�������Ʒ�Ѿ�ָ���������ĸ�����
		local TeamID = Conn.m_Player.m_Properties:GetTeamID()
		local IsInSharertbl = false 
		if TeamID == BelongTeam then
			IsInSharertbl = true
		else
			if DropNpcID and NpcDropObjTbl[DropNpcID] then
				local Sharertbl = NpcDropObjTbl[DropNpcID].m_CanSharePlayer
				
				for i = 1, table.getn(Sharertbl) do
					--��ҵĶ����Ѿ���ɢ������Npc����Ȼ��¼�ſ��Է�����Ʒ������б���������ڴ��б���
					if Sharertbl[i] == PlayerId then   
						IsInSharertbl = true
						break
					end
				end
			end
		end
		if not IsInSharertbl then   --�������Ʒ�����ߵ��б���
			if (os.time()-DropTime)<DropItemProtectTime then
				MsgToConn(Conn, 3032)
				return
			end
		end
	elseif DropOwnerId ~= 0 and DropOwnerId ~= PlayerId then
		if DropTime == 0 then
			return
		end
		
		if (os.time()-DropTime)<DropItemProtectTime then
			MsgToConn(Conn, 3032)
			return
		end
	end
	
	--����Ҽ�һ��BUFF
	local tempSkillFlag = false
	if g_ObjActionArgTbl[ObjName] then
		local BuffSkillName = g_ObjActionArgTbl[ObjName][1]
--		print("TemporaryBuffSkillName",BuffSkillName)
		tempSkillFlag = Conn.m_Player:AddTempSkill(BuffSkillName,1)
	end
	if tempSkillFlag then
		if DropOwnerId ~= 0 then
			IntObjServerMgr:Destroy(BuffObj,false)
		else
			IntObjServerMgr:Destroy(BuffObj,true)
		end
	end 
end

return Entry
