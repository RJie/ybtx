#��¼��ɫ���顢��ϵ���仯log
create table tbl_log_char_exp_soul_modulus
(
	lcs_uId	bigint unsigned	not	null,
	lcesm_uModulusType tinyint unsigned not null,#ϵ������ 1-��ϵ�� 2-����ϵ��
	lcesm_uModulusValue float unsigned not null,#ϵ��ֵ
	lcesm_dtChangeTime datetime not null,#ϵ��ֵ
	
	key(lcs_uId)
)engine=innodb;

 alter table tbl_log_tong_building_event add column ltbe_uBuildingId bigint unsigned		not null;
 alter table tbl_log_tong_building_event add column ltbe_uAddParameter float unsigned		not null;
 
 
 #Ӷ��С��������Դ�㱨��
create table tbl_log_tong_resource_sig_up
(
	le_uId	bigint unsigned		not	null,
	lts_uId int unsigned	not null, #Ӷ��С��Id
	ltrsu_uExecutorId bigint unsigned		not null, #ִ����
	ltrsu_uExploit bigint not null,
	ltrsu_sObjName varchar(96) not null,
	
	key(le_uId),
	key(lts_uId),
	key(ltrsu_uExecutorId)
 )engine=innodb;	
