create table tbl_action_xianxie		#��Ѫ�������÷ּ�¼
(
	cs_uId	bigint unsigned		not	null,		#��ɫid
	ax_uWin tinyint not null default 0,		#ʤ��
	ax_uScore tinyint not null default 0,		#�����
	ax_dtTime datetime not null default 0,
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;