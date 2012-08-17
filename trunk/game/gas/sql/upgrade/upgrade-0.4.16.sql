

##################GM���������ר�ñ�###################
create table tbl_gm_msg				
(
	gm_uSenderId bigint unsigned not null,			#sender identifier
	gm_uRecieverId bigint unsigned 	not null,		#reciever identifier
	gm_dtCreateTime datetime	 not null,		#msg send time
	gm_sContent  varchar(3072)	 not null,		#msg content
	
	key(gm_uSenderId),
	key(gm_uRecieverId)
)ENGINE=InnoDB default CHARSET=latin1;


create table tbl_msg_unready_mark
(
	s_uDisServer	tinyint unsigned not	null,
	s_uSrcServer 	tinyint unsigned not	null,
	mc_uId bigint unsigned		not	null,
	key(s_uDisServer),
	key(s_uSrcServer),
	key(mc_uId)
)engine=memory;


#�Ƕ����������а�
create table tbl_sort_dataosha_point
(
	sdp_uOrder smallint unsigned not null,												#����
	sdp_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	sdp_uPoint bigint	unsigned		not null default 0,#����ɱ����
	
	key(sdp_uOrder),
	key(sdp_uPoint),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�ԽǶ����Ļ�������
create table tbl_sort_dataosha_point_by_camp
(
	sdpbc_uOrder smallint unsigned not null,												#����
	sdpbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	key(sdpbc_uOrder),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_tong_draw_forage_serverid
(
	tdfs_uServerId   tinyint unsigned,	
	primary	key(tdfs_uServerId)
)engine=MEMORY;

drop table tbl_tong_draw_forage_serverid;

#����ʱ��ǼǱ�
create table tbl_tong_draw_forage_time
(
	tdft_sTime  varchar(96)  not null,                 
	primary	key(tdft_sTime)
)engine=innodb;

