--ʰȡ������npcʬ�壬�ɼ��ͽ������󣬵�������ӵ����п���ʰȡ��Ʒ�Ĺ���
gas_require "framework/main_frame/ItemHolderInc"


--[[
	Owner: ������Player����,Ҳ������Team����
]]
function CItemHolder:Create(Owner)

	self._m_uCurItemIndex = 0
	self.m_Owner=Owner
	self.m_tbl_Items={}
	self.m_tbl_Opener={}		--���д��˸���������Ҷ�������
	g_App:RegisterTick(self,30*1000)
	self:SetTickName("CItemHolder")

end


function CItemHolder:Destroy()

	g_App:UnRegisterTick(self)
	
end

--uQuality DynAttrib�����Զ�̬װ������
function CItemHolder:AddItem( ItemPlayerOwner,uItemBigId,uItemSmallId, DynAttrib )

	local ItemInfo = 
	{
		m_Owner=ItemPlayerOwner,
		m_uItemBigId=uItemBigId,
		m_uItemSmallId=uItemSmallId,
		m_DynAttrib=DynAttrib
	}
	self._m_uCurItemIndex = self._m_uCurItemIndex - 1
	self.m_tbl_Items[self._m_uCurItemIndex]=ItemInfo
	
	local uFakeItemId = self._m_CurItemIndex
	local nBindingType = 0
	for k,v in pairs(self.m_tbl_Opener) do

		local Conn = k.m_Conn
				
		Gas2Gac:RetAddItemToPickWnd( Conn,uFakeItemId )		
		
	end
end


function CItemHolder:DelItem( uFakeItemId )

	self.m_tbl_Items[uFakeItemId]=nil
	
	
	for k,v in pairs(self.m_tbl_Opener) do
		
		Gas2Gac:RetDelItemFrPickWnd( k.m_Conn,uFakeItemId )
		
	end

end


function CItemHolder:OnTick()

	--print("ʰȡ�ȴ���ʱ��������Ҷ�����ʰȡ����Ʒ")
	self.m_Owner = nil
	
end


--��Ҵ������Ʒ����,��ʱ����Ʒ�б��͸������ң����ָ�뱻��¼
--���б�����������Ʒ�ı䶯���ᷢ�͸��б��е�������ҡ�
function CItemHolder:Open( Player )
	self.m_tbl_Openner[Player]=1
end


function CItemHolder:Close( Player )
	self.m_tbl_Openner[Player]=nil
end