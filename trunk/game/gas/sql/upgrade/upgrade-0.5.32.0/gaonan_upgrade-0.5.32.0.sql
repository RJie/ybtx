create table tbl_warn_value		#���һ�����ֵ��
(
	cs_uId	bigint unsigned		not	null,		#��ɫid
	w_uValue smallint unsigned not null default 0,	#����ֵ
	w_dtTime datetime not null default 0,	#����ʱ��
	primary key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;