#��Ӫ״̬
create table tbl_recruit_camp
(
	rc_uCamp		tinyint unsigned	not null,   
	rc_uState	tinyint unsigned	not null,   #״̬(0,1,2)  --0�ر�,1��ͨ,2�ؽ�
	primary	key(rc_uCamp)
)engine = innodb;



#���ͨ����ļ������ɫ
create table tbl_char_recruit_info
(
	cs_uId			bigint unsigned		not	null,
	cri_uRecFlag	tinyint	unsigned not	null,	#recruit flag
	primary	key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;


#��ļ����
create table tbl_char_recruit_time
(
	crt_dtTime	datetime not null
)engine = innodb;


#�ؽ���ļ��Ϣ
create table tbl_recruit_info
(
	ri_uMinNum	smallint 	unsigned	not null, 
	ri_uMaxNum	smallint 	unsigned	not null 
)engine = innodb;


alter table tbl_tong_rob_resource add unique key(trr_sObjName);