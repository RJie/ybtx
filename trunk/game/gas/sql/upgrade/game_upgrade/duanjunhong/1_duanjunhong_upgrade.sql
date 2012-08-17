#��Ѩ���ͷ��������
create table tbl_building_dragon(
		bt_uId		bigint unsigned			not null,
		t_uId			bigint unsigned			not null,
		bt_buildTime		datetime			not null,
		primary key(bt_uId),
		foreign key(bt_uId)	references tbl_building_tong(bt_uId)  on update cascade on delete cascade,
		foreign key(t_uId)	references tbl_tong(t_uId)  on update cascade on delete cascade
)engine = innodb;

create table tbl_scene_dragoncave   #Ӷ��С����Ѩ������б�
(
  t_uId 	bigint 	unsigned	not	null,    #Ӷ��С��id  
  sc_uId	bigint	unsigned	not	null,	 	#scene idenfier
  primary key(sc_uId),
  foreign key(t_uId) references tbl_tong(t_uId) on update cascade on delete cascade,
	foreign key(sc_uId) references tbl_scene(sc_uId) on delete cascade
)engine = innodb;

create table tbl_tong_dragoncave   #��Ѩ����������Ӷ��С�ӽ�ɫ�б�
(
  cs_uId 	bigint	unsigned	not	null,    #��ɫid
  sc_sFinishTime datetime  not null,	#����ʱ��
	primary key(cs_uId),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;

create table tbl_tong_dragoncavetong   #��Ѩ����������Ӷ��С���б�
(
  t_uId	 bigint	unsigned	not	null, #Ӷ��С��id
  sc_sFinishTime datetime  not null,	#����ʱ��
	primary key(t_uId),
	foreign key(t_uId) references tbl_tong(t_uId) on update cascade on delete cascade
)engine = innodb;