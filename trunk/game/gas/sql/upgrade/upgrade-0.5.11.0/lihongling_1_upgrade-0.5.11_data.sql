update tbl_tong as tt,tbl_building_tong as tbt set tbt.bt_sBuildName = "����������"
where tt.t_uId = tbt.t_uId and tt.t_uCamp = 1 and tbt.bt_sBuildName in("����������","��ʥ������","��˹������");
update tbl_tong as tt,tbl_building_tong as tbt set tbt.bt_sBuildName = "��ʥ������"
where tt.t_uId = tbt.t_uId and tt.t_uCamp = 2 and tbt.bt_sBuildName in("����������","��ʥ������","��˹������");
update tbl_tong as tt,tbl_building_tong as tbt set tbt.bt_sBuildName = "��˹������"
where tt.t_uId = tbt.t_uId and tt.t_uCamp = 3 and tbt.bt_sBuildName in("����������","��ʥ������","��˹������");


update tbl_item_static as tis,tbl_item_store_room as isr,tbl_char_static as cs
set tis.is_sName = "����������" 
where tis.is_uId = isr.is_uId and cs.cs_uId = isr.cs_uId and cs.cs_uCamp = 1 and tis.is_sName in("����������","��ʥ������","��˹������");

update tbl_item_static as tis,tbl_item_store_room as isr,tbl_char_static as cs
set tis.is_sName = "��ʥ������" 
where tis.is_uId = isr.is_uId and cs.cs_uId = isr.cs_uId and cs.cs_uCamp = 2 and tis.is_sName in("����������","��ʥ������","��˹������");

update tbl_item_static as tis,tbl_item_store_room as isr,tbl_char_static as cs
set tis.is_sName = "��˹������" 
where tis.is_uId = isr.is_uId and cs.cs_uId = isr.cs_uId and cs.cs_uCamp = 3 and tis.is_sName in("����������","��ʥ������","��˹������");


update tbl_tong as tt,tbl_item_collectivity_depot as icd,tbl_item_static as tis
set tis.is_sName = "����������"  
where tt.t_uDepotID = icd.cds_uId and icd.is_uId = tis.is_uId and tt.t_uCamp = 1 and tis.is_sName in("����������","��ʥ������","��˹������");

update tbl_tong as tt,tbl_item_collectivity_depot as icd,tbl_item_static as tis
set tis.is_sName = "��ʥ������"  
where tt.t_uDepotID = icd.cds_uId and icd.is_uId = tis.is_uId and tt.t_uCamp = 2 and tis.is_sName in("����������","��ʥ������","��˹������");

update tbl_tong as tt,tbl_item_collectivity_depot as icd,tbl_item_static as tis
set tis.is_sName = "��˹������"  
where tt.t_uDepotID = icd.cds_uId and icd.is_uId = tis.is_uId and tt.t_uCamp = 3 and tis.is_sName in("����������","��ʥ������","��˹������");