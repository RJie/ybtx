CConsignmentTreeListMap = class ()

local CfgTblItemBigID = {
	BasicItem		= 	g_ItemInfoMgr:GetBasicItemBigID(),
	PlayerBag 	 	=	g_ItemInfoMgr:GetPlayerBagBigID(),
	
	StaticWeapon	=	g_ItemInfoMgr:GetStaticWeaponBigID(),
	StaticArmor		=	g_ItemInfoMgr:GetStaticArmorBigID(),
	StaticShield	=	g_ItemInfoMgr:GetStaticShieldBigID(),
	StaticRing		=	g_ItemInfoMgr:GetStaticRingBigID(),
	StaticJewelry	=	g_ItemInfoMgr:GetStaticJewelryBigID(),
	
	Stone			=	g_ItemInfoMgr:GetStoneBigID(),
	HoleMaterial	=	g_ItemInfoMgr:GetHoleMaterialBigID(),
	
	QuestItem		=	g_ItemInfoMgr:GetQuestItemBigID(),
	Mail			=	g_ItemInfoMgr:GetMailBigID(),
	WhiteStone		=	g_ItemInfoMgr:GetWhiteStoneBigID(),
	SoulPearl		=	g_ItemInfoMgr:GetSoulPearlBigID(),
	SkillItem		=	g_ItemInfoMgr:GetSkillItemBigID(),
	TongSmeltItem	=	g_ItemInfoMgr:GetTongSmeltItemBigID(),
	BoxItem			=	g_ItemInfoMgr:GetBoxItemBigID(),
	TextItem		=	g_ItemInfoMgr:GetTextItemBigID(),
	BattleArrayBooks=	g_ItemInfoMgr:GetBattleArrayBooksBigID(),
	EmbryoItem	=g_ItemInfoMgr:GetEmbryoItemBigID(),
	QualityMaterialItem = g_ItemInfoMgr:GetQualityMaterialItemBigID(),
	
	Flowers         =   g_ItemInfoMgr:GetFlowersBigID(),
	MercCardItem    =   g_ItemInfoMgr:GetMercCardItemBigID(),
	AdvanceStone    =   g_ItemInfoMgr:GetAdvanceStoneBigID(),
	ArmorPiece      =   g_ItemInfoMgr:GetArmorPieceBigID(),
	OreArea         =   g_ItemInfoMgr:GetOreAreaBigID(),
	CreateNpcItem   =   g_ItemInfoMgr:GetCreateNpcItemBigID(),
	EquipIntenBackItem= g_ItemInfoMgr:GetEquipIntensifyBackItem(),
	EquipSuperaddItem = g_ItemInfoMgr:GetEquipSuperaddItem(),
	EquipRefineItem = g_ItemInfoMgr:GetEquipRefineStoneType(),
	
	MathGameItem    =   g_ItemInfoMgr:GetMathGameItemBigID(),
}

local FuncTbl ={
	GetSearchInfoByItemType 		= 1,			--[��ѯĳ����Ʒ]��Ӧ��Gac2Gas:GetSearchInfoByItemType,������nBigID����Ʒ���ࣩ
	GetSearchInfoNeedParent 		= 2,			--[��ѯĳ�����ͷ���ĳ���������е���Ʒ]��Ӧ��Gac2Gas:GetSearchInfoByItemAttr������:nBigID�� parentNodeText, curNodeText
	GetSearchInfoBySomeItemType 	= 3,			--[��ѯĳ������Ʒ]��Ӧ��Gac2Gas:GetSearchInfoBySomeItemType,������type(���ִ���ĳ�������ñ�)
	GetSearchInfoByExactItemAttr	= 4,				--[��ѯĳ����Ʒ�е�ĳ�������б��е�һ�����������]��Ӧ��Gac2Gas:CSMGetOrderByExactItemAttr,������nBigID, attrColName(��������)��exactAttrName�������ĳ�����ԣ��粼�ף�
    GetSearchInfoByItemTypeOrAttr     = 5,            --[��ѯĳ������Ʒ��ĳһ�з���Ҫ��ĺü�����Ʒ]��Ӧ��Gac2Gas:CSMGetOrderBySeveralSortItem,������index(��Ʒtype���ڵ�tbl������ֵ)��attrIndex(��Ʒ��ĳ�������ñ��е�ĳ���з���Ҫ���tbl����ֵ)
}

local IcludingSeveralItemTypeTbl = { 
	Sundries 	= 1,	--�������BoxItem_Common��BasicItem_Common��EmbryoItem_Common��QualityMaterialItem_Common��PlayerBag_Common��QuestItem_Common��������Ʒ
	Jewelry 	= 2,	--StaticJewelry_Common\StaticRing_Common
	Stone			= 3, --Stone_Common\HoleMaterial_Common
	ConsumeItem = 4, --����Ʒ��SkillItem_Common��BasicItem_Common
	EquipIntensify  = 5,    --װ��ǿ����أ�AdvanceStone_Common��ArmorPieceEnactment_Common
	Others      =   6,  --���������������г�����е�������Ʒ��10��17 18 19 23 26 28 29 31 36 39
--���е�    1 2 3  5 6 7 8 9 10 14 15 16 17 18 19 23 24 25 26 27 28 29 30 31 32 34 36 37 38 39
--�����г���1��2��3��5��6��7��8��9��14��15��24��25��27��30��32��34��37��38��
    BasicItem       =   7,--basiItem_Common
    ArmorAndShield  =   8,
    EmbryoItem = 9,
}

--һ���������ж������Ҫ�����ֵ
local IncludingSeveralSortItemType = {
    EquipIntenItem  =   1,  --itemType1, -- ǿ��ʯ������ʯ
    ConsumeItem     =   2,  ----ҩ����ʳƷ��ħ����Ʒ    
    Sunderies       =   3,  -- --�����ҩ���ϡ���ͨ��Ʒ������  
}

function CConsignmentTreeListMap.CreateCSMTreeListMap()
 local TreeListMap =
{
	["����"]	 = {FuncTbl.GetSearchInfoByItemType, 		 CfgTblItemBigID.StaticWeapon},
	["���ֽ�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["���ֽ�"]},
	["���ִ�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["���ִ�"]},
	["���ָ�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["���ָ�"]},
	["���ֵ�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["���ֵ�"]},
	["������"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["������"]},
	["˫�ֽ�"] = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["˫�ֽ�"]},
	["˫�ָ�"] = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["˫�ָ�"]},
	["˫�ִ�"] = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["˫�ִ�"]},
    ["����"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.StaticWeapon, CConsignment.AttrNameMapIndexTbl["˫����"]},
	
	["����"]	 = {FuncTbl.GetSearchInfoBySomeItemType, 		 IcludingSeveralItemTypeTbl.ArmorAndShield},
	["����"] = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticShield, CConsignment.AttrNameMapIndexTbl["����"]},
	["����"] = {FuncTbl.GetSearchInfoByExactItemAttr, 	 CfgTblItemBigID.StaticShield, CConsignment.AttrNameMapIndexTbl["����"]},
	["ͷ��"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["ͷ��"]},
	["�ز�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["�·�"]},
	["����"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["����"]},
	["�Ų�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["Ь��"]},
	["�粿"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["�粿"]},
	["�ֲ�"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["����"]},
	["����"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  		 CfgTblItemBigID.StaticArmor, CConsignment.AttrNameMapIndexTbl["����"]},
	
	["��Ʒ"]	 = {FuncTbl.GetSearchInfoBySomeItemType, 	 IcludingSeveralItemTypeTbl.Jewelry},
    ["����"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,	 CfgTblItemBigID.StaticJewelry, CConsignment.AttrNameMapIndexTbl["����"]},
	["����"]	 = {FuncTbl.GetSearchInfoByExactItemAttr,  CfgTblItemBigID.StaticJewelry, CConsignment.AttrNameMapIndexTbl["����"]},
	["��ָ"]	 = {FuncTbl.GetSearchInfoByItemType,  		 CfgTblItemBigID.StaticRing},
 	
 	["��ʯϵͳ"]	 = {FuncTbl.GetSearchInfoBySomeItemType, 	 IcludingSeveralItemTypeTbl.Stone},
 	["������ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.Stone, CConsignment.AttrNameMapIndexTbl["������ʯ"]},
 	["���з�ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.Stone, CConsignment.AttrNameMapIndexTbl["���з�ʯ"]},
 	["������ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.Stone, CConsignment.AttrNameMapIndexTbl["������ʯ"]},
 	["���Է�ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.Stone, CConsignment.AttrNameMapIndexTbl["���Է�ʯ"]},
 	["���޷�ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.Stone, CConsignment.AttrNameMapIndexTbl["���޷�ʯ"]},
 	["������ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.Stone, CConsignment.AttrNameMapIndexTbl["������ʯ"]},
 	["����"]	 = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.HoleMaterial},
 	
 	["װ��ǿ��"] = {FuncTbl.GetSearchInfoByItemTypeOrAttr, IcludingSeveralItemTypeTbl.EquipIntensify, IncludingSeveralSortItemType.EquipIntenItem},
 	["����ʯ"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.AdvanceStone},
 	["ǿ��ʯ"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.BasicItem, CConsignment.AttrNameMapIndexTbl["ǿ��ʯ"]},
 	["����ʯ"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.EquipIntenBackItem},
 	["�ӳ��ص�"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.ArmorPiece},
 	["׷��ʯ"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.EquipSuperaddItem},
    ["����ʯ"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.EquipRefineItem}, 	
 	
 	["����Ʒ"]		 = {FuncTbl.GetSearchInfoByItemTypeOrAttr, IcludingSeveralItemTypeTbl.ConsumeItem, IncludingSeveralSortItemType.ConsumeItem},
    ["ҩ��"]			 = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.SkillItem, CConsignment.AttrNameMapIndexTbl["ҩ��"]},
	["ʳƷ"]			 = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.SkillItem, CConsignment.AttrNameMapIndexTbl["ʳ��"]},
    ["ħ����Ʒ"]			 = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.BasicItem, CConsignment.AttrNameMapIndexTbl["ħ����Ʒ"]}, 	
 	["�淨��Ʒ"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.MathGameItem},
 	
 	["����"]		 	 = {FuncTbl.GetSearchInfoByItemTypeOrAttr,	IcludingSeveralItemTypeTbl.Sundries,IncludingSeveralSortItemType.Sunderies},
    ["��⿡���ҩ����"]			 = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.BasicItem, CConsignment.AttrNameMapIndexTbl["�����ҩ����"]},
	["����"]			 = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.Flowers},
	["��ͼ"] = {FuncTbl.GetSearchInfoByItemType, CfgTblItemBigID.OreArea},
	["���졢���ײ���"]	 = {FuncTbl.GetSearchInfoBySomeItemType, 	 IcludingSeveralItemTypeTbl.EmbryoItem},
	["��ͨ��Ʒ"]	 = {FuncTbl.GetSearchInfoByExactItemAttr, 			CfgTblItemBigID.BasicItem, CConsignment.AttrNameMapIndexTbl["����"]},
    ["����"] = {FuncTbl.GetSearchInfoByExactItemAttr, CfgTblItemBigID.BasicItem, CConsignment.AttrNameMapIndexTbl["����"]},
	["С����"] = {FuncTbl.GetSearchInfoByItemType,		 CfgTblItemBigID.CreateNpcItem},
	["����"]	 		 = {FuncTbl.GetSearchInfoByItemType,		 CfgTblItemBigID.PlayerBag},
	["����"]			 = {FuncTbl.GetSearchInfoByItemType,		 CfgTblItemBigID.BoxItem},
	["�鼮"] = {FuncTbl.GetSearchInfoByItemType,		 CfgTblItemBigID.TextItem},
	["��������չ��"] = {FuncTbl.GetSearchInfoByItemType,		 CfgTblItemBigID.MercCardItem},
	["������Ʒ"]       = {FuncTbl.GetSearchInfoBySomeItemType, IcludingSeveralItemTypeTbl.Others}
}
	return TreeListMap
end
