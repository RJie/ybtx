set autocommit=0;

delete from tbl_tong_item_create where tic_sItemName = "��ս��ҩ";
delete from tbl_item_static where is_sName = "��ս��ҩ";

insert into tbl_database_upgrade_record values("all_1_upgrade_0.5.4.0_data.sql");
commit;
