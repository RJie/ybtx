##��ս������ã���ս����������һ��
create table tbl_tong_battle_exploit #tong battle war exploit
(
	cs_uId							bigint unsigned		not null,								#role identifier
	be_uGetExploit			bigint unsigned		not null default 0,     #get exploit
	foreign	key (cs_uId)	references tbl_char_static(cs_uId) 	on	update cascade on	delete cascade
)engine=innodb;

##��ս��Ӫ������ã���ս����������һ��
create table tbl_battle_camp_exploit #tong camp war exploit
(
	ce_uCamp	tinyint	unsigned not	null,	# camp
	ce_uCampExploit			bigint unsigned		not null default 0,     #camp exploit
	primary	key(ce_uCamp)
)engine=innodb;