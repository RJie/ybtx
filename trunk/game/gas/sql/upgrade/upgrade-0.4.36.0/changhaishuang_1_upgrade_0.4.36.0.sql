
drop table tbl_sort_jifensai_all_wintimes;
drop table tbl_sort_jifensai_all_wintimes_by_camp;
#�������ܲ����������а�
create table tbl_sort_jifensai_join_times
(
	sjjt_uOrder smallint unsigned not null,												#����
	sjjt_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	sjjt_uJoinTimes	bigint	unsigned		not null default 0,#�����ܲ�������
	
	key(sjjt_uOrder),
	key(sjjt_uJoinTimes),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ���������ܲ�����������
create table tbl_sort_jifensai_join_times_by_camp
(
	sjjtbc_uOrder smallint unsigned not null,												#����
	sjjtbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	key(sjjtbc_uOrder),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#Ӷ��С�ӵȼ��������
create table tbl_sort_tong_level
(
	stl_uOrder smallint unsigned not null,								
	stl_uUpdown tinyint not null,							
	t_uId				bigint unsigned		not null,	
	stl_uLevel tinyint	not null,  
	stl_uHonor bigint unsigned		not null,    
	
	primary key(t_uId),
	key(stl_uOrder),
	key(stl_uUpdown),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#������Ӫ��Ӷ��С�ӵȼ�����
create table tbl_sort_tong_level_by_camp 
(
	stlbc_uOrder smallint unsigned not null,		
	stlbc_uUpdown tinyint not null ,					
	t_uId				bigint unsigned		not null,	
	
	primary key(t_uId),
	key(stlbc_uOrder),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#Ӷ��С�������������
create table tbl_sort_tong_exploit
(
	ste_uOrder smallint unsigned not null,								
	ste_uUpdown tinyint not null,							
	t_uId				bigint unsigned		not null,	
	ste_uExploit bigint unsigned	not null,	
	
	primary key(t_uId),
	key(ste_uOrder),
	key(ste_uUpdown),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#������Ӫ��Ӷ��С����������
create table tbl_sort_tong_exploit_by_camp 
(
	stebc_uOrder smallint unsigned not null,		
	stebc_uUpdown tinyint not null ,					
	t_uId				bigint unsigned		not null,	
	
	primary key(t_uId),
	key(stebc_uOrder),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#Ӷ��С�Ӿ����������
create table tbl_sort_tong_resource
(
	str_uOrder smallint unsigned not null,								
	str_uUpdown tinyint not null,							
	t_uId				bigint unsigned		not null,	
	str_uResource bigint unsigned	not null,	
	
	primary key(t_uId),
	key(str_uOrder),
	key(str_uUpdown),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#������Ӫ��Ӷ��С�Ӿ�������
create table tbl_sort_tong_resource_by_camp 
(
	strbc_uOrder smallint unsigned not null,		
	strbc_uUpdown tinyint not null ,					
	t_uId				bigint unsigned		not null,	
	
	primary key(t_uId),
	key(strbc_uOrder),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#Ӷ��С���ʽ��������
create table tbl_sort_tong_money
(
	stm_uOrder smallint unsigned not null,								
	stm_uUpdown tinyint not null,							
	t_uId				bigint unsigned		not null,	
	stm_uMoney bigint unsigned	not null,	
	
	primary key(t_uId),
	key(stm_uOrder),
	key(stm_uUpdown),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#������Ӫ��Ӷ��С���ʽ�����
create table tbl_sort_tong_money_by_camp 
(
	stmbc_uOrder smallint unsigned not null,		
	stmbc_uUpdown tinyint not null ,					
	t_uId	 bigint unsigned		not null,	
	
	primary key(t_uId),
	key(stmbc_uOrder),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#��Ҿ�����������
create table tbl_sort_char_resource					
(
	scr_uOrder smallint unsigned not null,									#sequence id
	scr_uUpdown tinyint not null,								#up or down
	cs_uId bigint unsigned not null,									#role ID
	scr_uResource float unsigned not null,			#total money
	
	primary key(cs_uId),
	key(scr_uOrder),
	key(scr_uUpdown),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ��ս�����������а�
create table tbl_sort_char_resource_by_camp 
(
	scrbc_uOrder smallint unsigned not null,										#sequence id
	scrbc_uUpdown tinyint not null ,								#up or down
	cs_uId bigint unsigned not null,										#role ID
	
	primary key(cs_uId),
	key(scrbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;


#������ʤ���������а�
create table tbl_sort_jifensai_wintimes
(
	sjw_uOrder smallint unsigned not null,												#����
	sjw_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	sjw_uWinTimes	bigint	unsigned		not null default 0,
	
	key(sjw_uOrder),
	key(sjw_uWinTimes),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ��������ʤ����������
create table tbl_sort_jifensai_wintimes_by_camp
(
	sjwbc_uOrder smallint unsigned not null,												#����
	sjwbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	key(sjwbc_uOrder),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;


#������ɱ���������а�
create table tbl_sort_tong_kill_num
(
	stkn_uOrder smallint unsigned not null,												#����
	stkn_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	stkn_uKillNum	bigint	unsigned		not null default 0,
	
	key(stkn_uOrder),
	key(stkn_uKillNum),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ������ɱ����������
create table tbl_sort_tong_kill_num_by_camp
(
	stknbc_uOrder smallint unsigned not null,												#����
	stknbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	key(stknbc_uOrder),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#��Դ������ɱ���������а�
create table tbl_sort_resource_kill_num
(
	srkn_uOrder smallint unsigned not null,												#����
	srkn_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	srkn_uKillNum	bigint	unsigned		not null default 0,
	
	key(srkn_uOrder),
	key(srkn_uKillNum),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ����Դ������ɱ����������
create table tbl_sort_resource_kill_num_by_camp
(
	srknbc_uOrder smallint unsigned not null,												#����
	srknbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	key(srknbc_uOrder),
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;


#Ӷ��С����Դ��ռ������������
create table tbl_sort_tong_resource_occupy_times
(
	strot_uOrder smallint unsigned not null,								
	strot_uUpdown tinyint not null,							
	t_uId				bigint unsigned		not null,	
	strot_uOccupyTimes bigint unsigned	not null,	
	
	primary key(t_uId),
	key(strot_uOrder),
	key(strot_uUpdown),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#������Ӫ��Ӷ��С����Դ��ռ���������
create table tbl_sort_tong_resource_occupy_times_by_camp 
(
	strotbc_uOrder smallint unsigned not null,		
	strotbc_uUpdown tinyint not null ,					
	t_uId				bigint unsigned		not null,	
	
	key(strotbc_uOrder),
	primary key(t_uId),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;

#Ӷ��С�ӻ�ɱ������������
create table tbl_sort_tong_kill_boss_num
(
	stkbn_uOrder smallint unsigned not null,								
	stkbn_uUpdown tinyint not null,							
	t_uId				bigint unsigned		not null,	
	stkbn_uKillNum bigint unsigned	not null,	
	
	primary key(t_uId),
	key(stkbn_uOrder),
	key(stkbn_uUpdown),
	foreign	key(t_uId) references tbl_tong(t_uId) on	update cascade on	delete cascade
)engine=innodb;

#������Ӫ��Ӷ��С�ӻ�ɱ������������
create table tbl_sort_tong_kill_boss_num_by_camp 
(
	stkbnbc_uOrder smallint unsigned not null,		
	stkbnbc_uUpdown tinyint not null ,					
	t_uId				bigint unsigned		not null,	
	
	key(stkbnbc_uOrder),
	primary key(t_uId),
	foreign	key(t_uId) references tbl_tong(t_uId) 		on	update cascade on	delete cascade
)engine=innodb;


#��һ�ɱ������������
create table tbl_sort_char_kill_boss_num
(
	sckbn_uOrder smallint unsigned not null,								
	sckbn_uUpdown tinyint not null,							
	cs_uId				bigint unsigned		not null,	
	sckbn_uKillNum bigint unsigned	not null,	
	
	primary key(cs_uId),
	key(sckbn_uOrder),
	key(sckbn_uUpdown),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ����һ�ɱ������������
create table tbl_sort_char_kill_boss_num_by_camp 
(
	sckbnbc_uOrder smallint unsigned not null,		
	sckbnbc_uUpdown tinyint not null ,					
	cs_uId				bigint unsigned		not null,	
	
	key(sckbnbc_uOrder),
	primary key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

insert into tbl_database_upgrade_record values("changhaishuang_1_upgrade_0.4.36.0.sql");
