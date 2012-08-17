drop table if exists tbl_tong_battle_exploit;
drop table if exists tbl_battle_camp_exploit;
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
	ce_uAmCampExploit			bigint unsigned		not null default 0,     #camp exploit
	ce_uSsCampExploit			bigint unsigned		not null default 0,     #camp exploit
	ce_uXsCampExploit			bigint unsigned		not null default 0,     #camp exploit
	primary	key(ce_uAmCampExploit)
)engine=innodb;