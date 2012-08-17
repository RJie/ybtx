drop table tbl_channel_id;

create table tbl_channel_id
(
	ci_nId bigint not null,
	primary key(ci_nId) using hash
)engine=innodb;

alter table tbl_tong_station_time add foreign key (t_uId) references tbl_tong(t_uId) on update cascade on delete cascade;

alter table tbl_tong_line_time add foreign key (t_uId)	references tbl_tong(t_uId) on update cascade on	delete cascade;

alter table tbl_tong_header_award_time add foreign key (t_uId)	references tbl_tong(t_uId) on update cascade on	delete cascade;

#�������ÿ�����߾�����ȡ�������ݿ��
create table tbl_char_off_line_exchage_limit_value
(
	cs_uId						bigint unsigned	not	null,
	cd_sLastExChangeDataTime  	varchar(32) not null,
	cm_uAfflatusValue			bigint unsigned	not null  default 0,
	foreign	key(cs_uId)			references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;

# ��¼��ҵȼ�������ʱ��
create table tbl_char_levelup_time
(
	cs_uId bigint unsigned not null,
	clt_uLevelUpTime datetime not null default 0, #��¼�ȼ�������ʱ��
	clt_uLevel tinyint unsigned	not null default 1, #role level,
	key(cs_uId),
	key(clt_uLevel),
	foreign	key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

# ��¼�ۻ�����һ�βμӵ����ں������ۻ��Ĵ���
create table tbl_activity_store_data
(
	cs_uId                bigint unsigned   not null,
	asd_sActivityName     varchar(32) 			not null,
	asd_dtTime            datetime					not null,
	asd_uStoreTimes       tinyint unsigned 	not null default 0,
	key(cs_uId),
	key(asd_sActivityName),
	foreign	key(cs_uId) references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

#��Ʒһ��ʱ����Ի�õ��������
create table tbl_item_amount_limit	
(
	cs_uId		bigint 	unsigned	not null,		#item owner
	is_sName	varchar(96)		not	null,		#item name	
	key(is_sName),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_user_draw_balance_log
(
	tid_uDetailID					bigint unsigned not null,	#detail id
	cs_uId								bigint unsigned not null,	#char_id
	udb_uAmount						bigint unsigned not null,
	udbl_RetCode					bigint	not null,					
	udbl_dtTime						datetime not null,				
	key(tid_uDetailID),
	key(cs_uId),
	key(udbl_dtTime)
)engine=innodb;

insert into tbl_database_upgrade_record values("all_1_upgrade_0.5.4.0.sql");
