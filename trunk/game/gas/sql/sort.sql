
##################################�����������а�######################################

#�ȼ�.�������а�
create table tbl_sort_level				#ranking board of roles' level
(
	sl_uOrder smallint unsigned not null,									#sequence id
	sl_uUpdown tinyint not null,								#up or down
	cs_uId bigint unsigned not null,									#role ID
	sl_uLevel tinyint unsigned not null default 1,		#level
	sl_uLevelExp bigint unsigned not null default 0,			#experience
	
	primary key(cs_uId),
	key(sl_uOrder),
	key(sl_uLevel),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

#������Ӫ�Եȼ�.����ֵ��������
create table tbl_sort_level_by_camp		#ranking board of roles' level group by camp
(
	slbc_uOrder smallint unsigned not null,									#sequence id
	slbc_uUpdown tinyint not null,								#up or down
	cs_uId bigint unsigned not null,									#role id
	
	primary key(cs_uId),
	key(slbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#���󶨽�Ǯ���а�
create table tbl_sort_money					#role sorted by money
(
	sm_uOrder smallint unsigned not null,									#sequence id
	sm_uUpdown tinyint not null,								#up or down
	cs_uId bigint unsigned not null,									#role ID
	sm_uMoney bigint unsigned not null default 0,			#total money
	
	primary key(cs_uId),
	key(sm_uOrder),
	key(sm_uMoney),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Բ��󶨽�Ǯ���а�
create table tbl_sort_money_by_camp #role sorted by money group by camp
(
	smbc_uOrder smallint unsigned not null,										#sequence id
	smbc_uUpdown tinyint not null ,								#up or down
	cs_uId bigint unsigned not null,										#role ID
	
	primary key(cs_uId),
	key(smbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#��ɫ�����������а�
create table tbl_sort_deadtimes
(
	sd_uOrder smallint unsigned not null,										#����
	sd_uUpdown tinyint not null,									#����
	cs_uId bigint unsigned not null,										#���ID
	sd_uDeadTimes bigint unsigned	not null default 0,		#��ɫ�����Ĵ���
	
	primary key(cs_uId),
	key(sd_uOrder),
	key(sd_uDeadTimes),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Խ�ɫ����������������
create table tbl_sort_deadtimes_by_camp
(
	sdbc_uOrder smallint unsigned not null,									#����
	sdbc_uUpdown tinyint not null,								#����
	cs_uId bigint unsigned not null,									#���ID
	
	primary key(cs_uId),
	key(sdbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#��ɫɱ�������а�
create table tbl_sort_kill_npc_count
(
	sknc_uOrder smallint unsigned not null,											#����
	sknc_uUpdown tinyint not null,										#����
	cs_uId bigint unsigned not null,											#���ID
	sknc_uKillNpcCount bigint unsigned not null default 0,	#��ɫɱ���޸���
	
	primary key(cs_uId),
	key(sknc_uOrder),
	key(sknc_uKillNpcCount),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Խ�ɫɱ���޸�����������
create table tbl_sort_kill_npc_count_by_camp
(
	skncbc_uOrder smallint unsigned not null,												#����
	skncbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	primary key(cs_uId),
	key(skncbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#��ɫɱ�����а�
create table tbl_sort_kill_player_count
(
	skpc_uOrder smallint unsigned not null,												#����
	skpc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	skpc_uKillPlayerCount bigint unsigned not null default 0,	#��ɫɱ�˸���
	
	primary key(cs_uId),
	key(skpc_uOrder),
	key(skpc_uKillPlayerCount),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Խ�ɫɱ�˸�����������
create table tbl_sort_kill_player_count_by_camp
(
	skpcbc_uOrder smallint unsigned not null,												#����
	skpcbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	primary key(cs_uId),
	key(skpcbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#��ɫ����ʱ���ۻ����а�
create table tbl_sort_player_onlinetime
(
	spo_uOrder smallint unsigned not null,												#����
	spo_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	spo_uPlayerOnTimeTotal bigint unsigned not null default 0,	#��ɫ����ʱ���
	
	primary key(cs_uId),
	key(spo_uOrder),
	key(spo_uPlayerOnTimeTotal),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Խ�ɫ����ʱ���ۻ���������
create table tbl_sort_player_onlinetime_by_camp
(
	spobc_uOrder smallint unsigned not null,												#����
	spobc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	primary key(cs_uId),
	key(spobc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;


#����ɱ�ܲ�����������
create table tbl_sort_dataosha_all_jointimes
(
	sdaj_uOrder smallint unsigned not null,												#����
	sdaj_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	sdaj_uJoinTimes	bigint	unsigned		not null default 0,#����ɱ�ܲ�������
	
	primary key(cs_uId),
	key(sdaj_uOrder),
	key(sdaj_uJoinTimes),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Դ���ɱ�ܲ�����������
create table tbl_sort_dataosha_all_jointimes_by_camp
(
	sdajbc_uOrder smallint unsigned not null,												#����
	sdajbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	primary key(cs_uId),
	key(sdajbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#����ɱ��ʤ����������
create table tbl_sort_dataosha_all_wintimes
(
	sdaw_uOrder smallint unsigned not null,												#����
	sdaw_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	sdaw_uWinTimes	bigint	unsigned		not null default 0,#����ɱ�ܲ�������
	
	primary key(cs_uId),
	key(sdaw_uOrder),
	key(sdaw_uUpdown),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ�Դ���ɱ��ʤ����������
create table tbl_sort_dataosha_all_wintimes_by_camp
(
	sdawbc_uOrder smallint unsigned not null,												#����
	sdawbc_uUpdown tinyint not null,											#����
	cs_uId bigint unsigned not null,												#���ID
	
	primary key(cs_uId),
	key(sdawbc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

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

#ս������������
create table tbl_sort_fight_evaluation					#role sorted by fight evaluation
(
	sfe_uOrder smallint unsigned not null,									#sequence id
	sfe_uUpdown tinyint not null,								#up or down
	cs_uId bigint unsigned not null,									#role ID
	sfe_uPoint float unsigned not null,			#total money
	
	primary key(cs_uId),
	key(sfe_uOrder),
	key(sfe_uUpdown),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������Ӫ��ս�����������а�
create table tbl_sort_fight_evaluation_by_camp #role sorted by fight evaluation group by camp
(
	sfebc_uOrder smallint unsigned not null,										#sequence id
	sfebc_uUpdown tinyint not null ,								#up or down
	cs_uId bigint unsigned not null,										#role ID
	
	primary key(cs_uId),
	key(sfebc_uOrder),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

####################################��������Ӷ��С��������б�#######################################
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















