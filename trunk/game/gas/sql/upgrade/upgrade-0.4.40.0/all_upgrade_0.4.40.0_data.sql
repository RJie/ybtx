set autocommit=0;
#--------------------------����sql����ָ���---------------------------------------

update tbl_item_static set is_uType = 43 where is_uType  = 1 and is_sName like "%����ʯ%";
update tbl_market_sell_order set mso_sItemType = 43 where mso_sItemName like "%����ʯ%" and mso_sItemType = 1;
update tbl_npcshop_player_sell_item set npsi_sItemType = 43 where npsi_sItemName like "%����ʯ%" and npsi_sItemType= 1;
update tbl_item_boxitem_pickup set ibp_uType = 43 where ibp_sName like "%����ʯ%"  and ibp_uType  = 1;

delete from tbl_item_static where is_sName = "��˵Ļ��䣨���ף�" and is_uType = 24;
delete from tbl_item_static where is_sName = "��˵Ļ��䣨��ʥ��" and is_uType = 24;
delete from tbl_item_static where is_sName = "��˵Ļ��䣨��˹��" and is_uType = 24;

delete from tbl_item_static where is_sName = "֩������";
delete from tbl_item_static where is_sName = "1������ͼ��";
delete from tbl_item_static where is_sName = "1����ָģ��";
delete from tbl_item_static where is_sName = "2������ͼ��";
delete from tbl_item_static where is_sName = "2����ָģ��";
delete from tbl_item_static where is_sName = "�¾ɵ�����";
delete from tbl_item_static where is_sName = "1����ָģ��";
delete from tbl_item_static where is_sName = "��Ƥ����";
delete from tbl_item_static where is_sName = "�����۾�";
delete from tbl_item_static where is_sName = "1������ͼ��";


delete from tbl_item_boxitem_pickup where ibp_sName = "֩������";
delete from tbl_item_boxitem_pickup where ibp_sName = "1������ͼ��";
delete from tbl_item_boxitem_pickup where ibp_sName = "1����ָģ��";
delete from tbl_item_boxitem_pickup where ibp_sName = "1������ͼ��";
delete from tbl_item_boxitem_pickup where ibp_sName = "2������ͼ��";
delete from tbl_item_boxitem_pickup where ibp_sName = "2����ָģ��";
delete from tbl_item_boxitem_pickup where ibp_sName = "�¾ɵ�����";
delete from tbl_item_boxitem_pickup where ibp_sName = "1����ָģ��";
delete from tbl_item_boxitem_pickup where ibp_sName = "��Ƥ����";
delete from tbl_item_boxitem_pickup where ibp_sName = "�����۾�";

delete from tbl_shortcut where sc_Arg1 = "֩������";
delete from tbl_shortcut where sc_Arg1 = "1������ͼ��";
delete from tbl_shortcut where sc_Arg1 = "1����ָģ��";
delete from tbl_shortcut where sc_Arg1 = "2������ͼ��";
delete from tbl_shortcut where sc_Arg1 = "2����ָģ��";
delete from tbl_shortcut where sc_Arg1 = "�¾ɵ�����";
delete from tbl_shortcut where sc_Arg1 = "1����ָģ��";
delete from tbl_shortcut where sc_Arg1 = "��Ƥ����";
delete from tbl_shortcut where sc_Arg1 = "�����۾�";
delete from tbl_shortcut where sc_Arg1 = "1������ͼ��";

#--------------------------����sql����ָ���---------------------------------------
insert into tbl_database_upgrade_record values ("all_upgrade_0.4.40.0_data.sql");
commit;
