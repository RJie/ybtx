#�������ÿ�����߾�����ȡ�������ݿ��
create table tbl_char_off_line_exchage_limit_value
(
	cs_uId						bigint unsigned	not	null,
	cd_sLastExChangeDataTime  	varchar(32) not null,
	cm_uAfflatusValue			bigint unsigned	not null  default 0,
	foreign	key(cs_uId)			references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;