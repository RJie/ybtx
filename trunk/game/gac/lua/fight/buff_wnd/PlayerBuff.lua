gac_require "fight/buff_wnd/BaseBuff"

CPlayerBuffWnd 					= class ( CBuffWnd )
CPlayerBuffItem		 			= class ( CBuffItem )
------- ���� CPlayerBuffWnd
function CPlayerBuffWnd:Ctor( Parent )
	self:Init( Parent, g_GameMain.m_PlayerInfo.m_ProgessOne )
end

function CPlayerBuffWnd.GetWnd()
	local Wnd = g_GameMain.m_Buff
	if not Wnd then
		Wnd = CPlayerBuffWnd:new(g_GameMain)
		g_GameMain.m_Buff = Wnd
	end
	return Wnd
end

function CPlayerBuffWnd:GetRemainTime(ID, buff_name)
	local RemainTime = g_MainPlayer:GetRemainTime(buff_name, ID)
	return RemainTime or 0
end

function CPlayerBuffWnd:GetBuffItem()
	return CPlayerBuffItem:new()
end

function CPlayerBuffItem:WndProc(uMsgID, uParam1, uParam2)
	if( uMsgID == WM_RBUTTONUP )then
		local buff_name = nil
		if(g_GameMain.m_Buff.m_tblBuffs[1][self.ID]) then
			buff_name = g_GameMain.m_Buff.m_tblBuffs[1][self.ID].realName
			if( buff_name and g_MainPlayer:IsCanCancelState(buff_name) ) then
				g_MainPlayer:CancelState(self.ID)
			end
		end
	end
end

------- ����Buff Debuff  ������Buff��Debuff��ID�����ƣ�������ʱ��, buffʣ��ʱ��
function CPlayerBuffWnd:UpdatePlayerBuffDebuff(ID, description, DivNum, Time, RemainTime, BuffType, SmallIcon, sName, uEntityID, InstallerID)
	--BuffType : �Ƿ��Ǹ���Ч������, true��ʾ�Ǹ���Ч��DeBuff,false��ʾ��Buff
--	print("buff  ID = "..ID.."  sName ="..sName.."  DivNum ="..DivNum.."  Time ="..Time.."  RemainTime ="..RemainTime)
	g_GameMain.m_CRideCamelWnd:SendToGas(sName,RemainTime)
	if sName == "600��buff" then
		g_GameMain.m_DownTimeWnd:ShowWindow(RemainTime)
	end
	if sName == "���ɱ¾״̬" then
		if Time == 0 then
			CComboHitsWnd.HideComboHitsWnd()
			g_GameMain.ComboHitsInfo.m_IsCrazyState = false
		end
	end
	self:UpdateBuffDebuff(ID, description, DivNum, Time, RemainTime, BuffType, SmallIcon, sName, uEntityID, InstallerID, true)
end


