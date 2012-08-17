################################################################
#		����������Ϣ
################################################################

#ɱ���ั������¼Boss״̬
#create table tbl_scene_boss_state
#(
#	 sc_uId							bigint	unsigned	not null,
#	 sbs_uBossId					tinyint unsigned 	not null,
#	 sbs_uBossState				tinyint unsigned 	not null,
#	 
#	 primary key (`sc_uId`, `sbs_uBossId`),
#	 foreign key (`sc_uId`) references tbl_scene (`sc_uId`) on update cascade on delete cascade
#)engine=innodb;

create table tbl_char_dataoshapoint		#dataosha dungeon
(
	cs_uId			bigint unsigned		not null,		#role identifier
	cs_uWinNum		bigint	unsigned	not null default 0,	#win times
	cs_uLoseNum		bigint	unsigned	not null default 0,	#lose times
	cs_uRunNum		bigint	unsigned	not null default 0,	#flee times
	cs_udataoshapoint	bigint	unsigned	not null default 0,	#total marks
	cd_uInFbTimes		bigint	unsigned	not null default 0,	#total take times
	cd_dDate 		datetime 		not null default 0,	#last join game time
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_char_dataoshaaccum		#datasha dungeon statistic
(
	cs_uId			bigint unsigned		not null,		#role identifier
	cs_uUpWeekWinNum	bigint	unsigned	not null default 0,	#win times of last week
	cs_uUpWeekLoseNum	bigint	unsigned	not null default 0,	#lose times of last week
	cs_uUpWeekRunNum	bigint	unsigned	not null default 0,	#flee times of last week
	cs_uUpWeekPoint 	bigint	unsigned	not null default 0,	#total marks of last week
	cs_dUpDate 		datetime not null,#����ʱ��			#last time joining game of last week
	cs_uCurrWeekWinNum	bigint	unsigned	not null default 0,	#win times of this week
	cs_uCurrWeekLoseNum	bigint	unsigned	not null default 0,	#lose times of this week
	cs_uCurrWeekRunNum	bigint	unsigned	not null default 0,	#flee times of this week
	cs_uCurrWeekPoint 	bigint unsigned		not null default 0,	#total marks of this week
	cs_dCurrDate 		datetime not null,#����ʱ��			#last time joining game of this week
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#�����ɫ�������Ļ�����Ϣ
create table tbl_char_jifensaipoint		#jifensai dungeon
(
	cs_uId			bigint unsigned		not null,		#role identifier
	cs_uType		tinyint	unsigned	not null,		#game type: 
										#  1: 2-players
										#  2: 3-players
										#  3: 5-players
	cs_uWinNum		int	unsigned	not null default 0,	#win times
	cs_uLoseNum		int	unsigned	not null default 0,	#lose times
	cs_uRunNum		int	unsigned	not null default 0,	#flee times
	cs_uPoint		int	unsigned	not null default 20000, #marks for waiting while getting start to join games
	cj_uInFbTimes	int	unsigned		not null default 0,	#total take times
	cj_dDate 		datetime 		not null default 0,	#last time of joing game
	cj_uKillNum		int	unsigned	not null default 0,	#killed number
	cj_uDeadNum		int	unsigned	not null default 0,	#dead times
	primary key (cs_uId, cs_uType),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#�����ɫ�������Ļ����ۼ���Ϣ
create table tbl_char_jifensaiaccum
(
	cs_uId				bigint unsigned		not null,
	cs_uType				tinyint	unsigned	not null,#1��ʾ2����,2��ʾ3����,3��ʾ5����
	cs_uUpWeekWinNum		int	unsigned		not null default 0,
	cs_uUpWeekLoseNum		int	unsigned		not null default 0,
	cs_uUpWeekRunNum		int	unsigned		not null default 0,
	cs_uUpWeekPoint int	unsigned		not null default 0,#���ܵ���������
	cs_dUpDate 			datetime not null,#����ʱ��
	cs_uCurrWeekWinNum		int	unsigned		not null default 0,
	cs_uCurrWeekLoseNum		int	unsigned		not null default 0,
	cs_uCurrWeekRunNum		int	unsigned		not null default 0,
	cs_uCurrWeekPoint int	unsigned		not null default 0,#���ܵ���������
	cs_dCurrDate 			datetime not null,#����ʱ��
	primary key (cs_uId, cs_uType),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;


#�����ɫ�������Ļ�����Ϣ
create table tbl_fbvar_award
(
	fa_Name			varchar(32) 			not null,
	fa_Date			datetime not null,#������ʱ��
	primary	key(fa_Name)
)engine=innodb;

#���򸱱����� ��������¼��
#create table tbl_area_fb_quest
#(
#	cs_uId								bigint unsigned		not null,
#	aq_uAcceptCount 			tinyint unsigned  not null,#����(��Զ���)��ȡ�����򸱱�������� ���ܳ���2��
#	aq_uFinishCount				tinyint unsigned  not null,#�����ύ�����򸱱�������� ���ܳ���2��
#	aq_dtLastAcceptTime 	datetime,									 #�������һ����ȡ���򸱱�����ʱ��
#	aq_dtLastFinishTime 	datetime,									 #�������һ���ύ���򸱱�����ʱ��
#	primary key(cs_uId),
#	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
#)engine=innodb;

#��������
create table tbl_area_fb_point
(
	cs_uId								bigint unsigned				not	null,
	afp_uPointType				bigint	unsigned			not	null,           #�������� 1.��Ȼ���� 2.���ڻ��� 3.�ƻ����� 4.����ɱ���� 5.���������� 6.���׻���
	afp_uPoint						bigint	unsigned			not	null default 0, #����
	
	primary	key(cs_uId,afp_uPointType),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#������μӴ���
create table tbl_activity_count
(
	cs_uId								bigint unsigned		not	null,
	ac_sActivityName			varchar(32) 			not null,
	ac_dtTime							datetime					not null,
	key(cs_uId),
	key(ac_sActivityName),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

#������μ���ʷ�ܴ����ͳɹ������������
create table tbl_activity_history_count
(
	cs_uId								bigint unsigned		not	null,
	ac_sActivityName			varchar(32) 			not null,
	ac_HistoryTimes				bigint unsigned		not null default 0,
	ac_SuccessfullTimes		bigint unsigned		not null default 0,  # �ɹ�����
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

#�μӻ���ܴ���
create table tbl_activity_in_count
(
	cs_uId								bigint unsigned		not	null,
	aic_sActivityName			varchar(32) 			not null,
	aic_uInTimes					bigint unsigned		not null,
	primary key (cs_uId, aic_sActivityName),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

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

#���ܶ��⽱���Ĵ���
create table tbl_extra_reward_count
(
	cs_uId								bigint unsigned		not	null,
	erc_sActivityName			varchar(32) 			not null,
	erc_dtTime						datetime					not null,
	key(cs_uId),
	key(erc_sActivityName),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

#�������ѵõ��Ĺؿ�����
create table tbl_merc_educate_card
(
	cs_uId								bigint unsigned		not	null,
	mec_uCardId	tinyint	unsigned			not null,
	
	primary key(cs_uId, mec_uCardId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;


#����������Ա��¼, ����ٴν���ø������������м��
create table tbl_char_entered_scene
(
	sc_uId	bigint	unsigned	not null,
	cs_uId	bigint unsigned		not	null,
	primary key(sc_uId, cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign key(sc_uId) references tbl_scene(sc_uId) on update cascade on delete cascade
)engine = innodb;



#�����
create table tbl_action_match_list
(
	cs_uId	bigint unsigned		not	null,		#��ɫid
	aml_sActionName	varchar(32) 		not null,  	#�����Ļ��
	aml_uLvStep	tinyint unsigned  	not null,	#�ȼ���
	aml_uGroupId bigint unsigned 		not null, #���������id,id��ͬ��Ҫ����һ��
	aml_uWaitingTeammate tinyint unsigned  	not null default 0, #�ȴ�����ȷ�Ͻ�����Ϊ0ʱ�����к�������
	unique key(cs_uId, aml_sActionName),
	key(aml_sActionName, aml_uLvStep),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

#�����
create table tbl_action_room
(
	ar_uId 		bigint unsigned		not null auto_increment,
	ar_sActionName	varchar(32) 		not null,  	#�����Ļ��
	ar_uState	tinyint unsigned 	not null,	#����������״̬, 0:�Ŷ�״̬(�����л�û��������), 1:�������Ѿ���������, 2:�����в��ɽ���
	ar_uLvStep	tinyint unsigned  	not null,	#�ȼ���
	sc_uId		bigint unsigned, 			#�����ĳ���id
	primary key(ar_uId),					
	foreign key(sc_uId) references tbl_scene(sc_uId) on update cascade on delete cascade
)engine = innodb;

#�����,  ��������ͨ����, ��Ȼ��Ҫ��ӱ����Ļ, ������Ա����ͨ�����Ա�տ�ʼʱ��һ��,����ͨ���鷢���ı�ʱ�򲻻�Ӱ�������Ա
create table tbl_action_team
(
	at_uId		bigint unsigned		not null		auto_increment,
	cap_sName       varchar(32),                 			 #�ӳ���
	ar_uId		bigint	unsigned		not null,		#�����,Ϊ�յ�ʱ��˵����û�з��䷿��,�����Ŷӽ׶�
	at_uTeamLevel	int	unsigned		not null default 0,#����ĵȼ�
	at_uOtherInfo	int	unsigned		not null default 0,#����Ϊ����ID
	at_uTempPoint	bigint unsigned		not null default 0,#������,��ʱ�Ļ���
	at_uIndex tinyint unsigned 		not null default 0,#ȷ��������Fb��λ�õı�ʶ
	primary key(at_uId),
	foreign key(ar_uId) references tbl_action_room(ar_uId) on update cascade on delete cascade
)engine = innodb;

create table tbl_action_team_member		#������Ա��
(
	cs_uId	bigint unsigned		not	null,		#��ɫid
	at_uId	bigint unsigned		not null,		#������
	atm_uState	tinyint unsigned 	not null default 0, #��ɫ״̬  0����δ׼��, 1�����Ѿ�׼����, 2�����ѽ���
	primary key(cs_uId, at_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign key(at_uId) references tbl_action_team(at_uId) on update cascade on delete cascade
)engine = innodb;

create table tbl_warn_value		#���һ�����ֵ��
(
	cs_uId	bigint unsigned		not	null,		#��ɫid
	w_uValue smallint unsigned not null default 0,	#����ֵ
	w_dtTime datetime not null default 0,	#����ʱ��
	primary key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

create table tbl_action_xianxie		#��Ѫ�������÷ּ�¼
(
	cs_uId	bigint unsigned		not	null,		#��ɫid
	ax_uWin tinyint not null default 0,		#ʤ��
	ax_uScore tinyint not null default 0,		#�����
	ax_dtTime datetime not null default 0,
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
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