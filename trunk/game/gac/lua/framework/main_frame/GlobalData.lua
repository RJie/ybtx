gac_gas_require "item/item_info_mgr/ItemInfoMgr"
gac_gas_require "liveskill/LiveSkillMgr"
gac_gas_require "framework/common/CMoney"
gac_gas_require "relation/tong/TongPurviewMgr"
gac_require "information/tooltips/ToolTips"
gac_require "setting/system_setting/UISettingMgr"
gac_require "framework/display_common/TimeTrans"
gac_require "framework/texture_mgr/DynImageMgr"
gac_require "framework/display_common/DisplayCommon"
gac_require "setting/function_area/ExcludeWnd"
gac_require "framework/url_mgr/UrlMgr"
--����ļ����������ȫ�ֱ���

g_ItemInfoMgr = CItemInfoMgr:new()

-- ��ʼ������ g_ItemInfoMgr ֮��
g_Tooltips = CTooltips:new()
	
-- �����ж�̬����Ʒ��Ϣ�ı��������ݿ��idΪ����
g_DynItemInfoMgr = CDynItemInfoMgr.Init()

-- Imageӳ���
g_ImageMgr = CImageMgr:new()

g_LiveSkillMgr = g_LiveSkillMgr or CLiveSkillMgr:new()

g_UISettingMgr		= CUISettingMgr:new()
g_CTimeTransMgr		= CTimeTrans:new()
g_DynImageMgr		= CDynImageMgr:new()
g_MoneyMgr			= CMoney:new()
g_UISettingMgr		= CUISettingMgr:new()
g_CTimeTransMgr		= CTimeTrans:new()
g_DisplayCommon		= CDisplayCommon:new()
g_TongPurviewMgr	= CTongPurviewInfoMgr:new()
g_ExcludeWndMgr		= CShowOpendWnd:new()
g_UrlMgr			= CUrlMgr:new()
