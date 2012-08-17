
CEquipSmeltSoulScroll = class( SQRDialog )

--@brief װ��������
function CEquipSmeltSoulScroll.EquipSmeltSoul(fromPlaceType,eEquipPart) 
	local state, tbl = g_WndMouse:GetCursorState()
	if(state ~= ECursorState.eCS_EquipSmeltSoul) then return end
	local nBigID,nIndex,itemid,context,equipRoomIndex,equipPos = unpack(tbl)
	local itemType = context[2]
	local SmeltSoulScrollName = context[3]
	local SmeltSoulScrollRoomIndex = context[4]
	local SmeltSoulScrollPos = context[5]

	--��ȡ����������ñ�
	local SmeltSoulScroll_EquipLevel = g_ItemInfoMgr:GetItemInfo(itemType,SmeltSoulScrollName,"EquipLevel")

	local DynInfo = g_DynItemInfoMgr:GetDynItemInfo(itemid)
	if not DynInfo then
		return 
	end
	local curLevel = DynInfo.BaseLevel
	if curLevel > SmeltSoulScroll_EquipLevel * 15  then --��װ���ȼ����ڸ�������������������װ���ȼ�
		MsgClient(194002)
		return
	end
  if g_GameMain.m_EquipUpIntensifyWnd ~= nil and 
	  g_GameMain.m_EquipUpIntensifyWnd:IsShow() then
    g_GameMain.m_EquipUpIntensifyWnd:CloseSelf(itemid)
	end
--װ������
	Gac2Gas:EquipSmeltSoul(g_Conn,nBigID,nIndex,SmeltSoulScrollRoomIndex,SmeltSoulScrollPos,equipRoomIndex or 0,equipPos or 0,itemid or 0,itemType,SmeltSoulScrollName,fromPlaceType,eEquipPart or 0)
end