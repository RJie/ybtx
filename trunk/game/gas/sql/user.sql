

################################################################
#		�ʺ�
################################################################

#us_uId	Ϊͨ��֤�ڱ����ݿ��Ψһid
create table tbl_user_static		#account static info
(
	us_uId		int	unsigned	not	null auto_increment,		#account identifier
	us_sName	varchar(32)		not	null,		#account name
	us_uGameID	int	unsigned not null,
	us_sPassword	varchar(32)		not 	null,	#account password for local login when erating server is out of service.
	us_sMatrixPasswd	varchar(32)	not		null,	#matrix password
	us_sMatrixCoord		varchar(16)	not		null,	#matrix coord
	us_dtCreateTime	datetime not null,			  #first occured time
	primary	key(us_uId),
	unique key(us_sName,us_uGameID),
	key(us_sName,us_uGameID,us_sPassword),
	key(us_uGameID)
)engine=innodb;

#��ű䶯���������
create table tbl_user_basic		#account basic info
(
	us_uId					int	unsigned	not	null,
	ub_uOnlineTime	bigint unsigned  not null	default	0,	 #total online time of a user
	ub_uYuanBao			bigint	unsigned	not null  default 0,	#
	ub_uAgreedVer		smallint unsigned not null default 0,  #last version that user have accepted
	
	primary	key(us_uId),
	foreign	key(us_uId)	references tbl_user_static(us_uId) on	update cascade on delete cascade
)engine=innodb;

#���������Ϣ
create table tbl_user_online		#online user info
(
	us_uId							int	unsigned	not	null,
	uo_sIp							char(45) not null,				#remote ip
	uo_sSN							varchar(96) not null,				#sn for this login, used to identify a whole period between login and logout
	uo_dtLoginTime			datetime not null,			  #login time
	uo_uOnlineTimeBegin	int unsigned not null, 		#user totally time
	uo_uOnServerId			tinyint unsigned	not null,	#server Id
	uo_uLoginKey				bigint		not null,					#
	uo_sMacAddress	 varchar(16) not null,
	
	primary key (`us_uId`),
	key(uo_uOnServerId),
	foreign	key(us_uId)	references tbl_user_static(us_uId) on	update cascade on delete cascade
)engine=innodb;


#GBS��¼�˳�
create table tbl_auth_logout		#table for authenticated logout
(	
	al_sSN							varchar(96) not null,					#sn
	us_uId							int	unsigned	not	null,
	al_sIp							char(45)	not	null,					#remote ip
	al_dtLoginTime			datetime not null,					#login time
	al_uOnlineTimeBegin	int unsigned not null, 			#total online time
	al_uRetry						int	unsigned not null,			#retry times
	al_dtLogoutTime 		datetime,								 		#lotout time
	al_uOnlineTimeEnd		int unsigned not null,	 		#
	
	primary	key(al_sSN),
	foreign	key(us_uId)	references tbl_user_static(us_uId) on	update cascade on delete cascade
)engine=innodb;

#�˺��˳���Ϣ��¼
create table tbl_user_logout		#table for user logout
(	
	us_sName	varchar(32)		not	null,
	us_uGameID	int	unsigned not null,
	ul_dtLogoutTime datetime,	#logout time
	ul_uOnServerId tinyint unsigned	not null,	# server Id
	unique key(us_sName,us_uGameID)
)engine=innodb;


create table tbl_user_wait_queue	#table for user waiting queue
(	
	uwq_uId		bigint	unsigned	not	null auto_increment,# sequence id
	us_sName	varchar(32)		not	null,		#account name
	us_uGameID	int	unsigned not null,
	uwq_uOnServerId tinyint unsigned	not null,	#server Id
	uwq_uContextId	bigint	unsigned	not	null, #context Id
	
	primary	key(uwq_uId),
	unique key(us_sName,us_uGameID)
)engine=innodb;

#��¼�ʺ����һ�ε�¼ʱ������һ���˳�ʱ��
#table to record last login and logout time
create table tbl_user_last_login_logout_time
(
	us_uId int unsigned not null,
	ulllt_dtLoginTime datetime not null, #last login time
	ulllt_dtLogoutTime datetime not null,#last logout time
	
	primary key(us_uId),
	foreign key(us_uId) references tbl_user_static(us_uId) on update cascade on delete cascade
)engine=innodb;

#��¼�Ŷ�����
create table tbl_user_wait_queue_count	
(	
	uwqc_uCount	int	unsigned	not	null 

)engine = memory;


create table tbl_user_trust
(	
	us_uId					int	unsigned	not	null,
	ut_sPassword		varchar(32)		not 	null,			#�й�����
	ut_dtTrustTime	datetime not null,						#�й���ʼʱ��
	ut_uTrustLength	int	unsigned not null,				#�йܳ���ʱ��
	foreign key(us_uId) references tbl_user_static(us_uId) on update cascade on delete cascade
)engine = innodb;


create table tbl_user_everyday_soul_and_exp
(	
	us_uId					int	unsigned	not	null,
	esae_uSoul			bigint unsigned not null,
	esae_uExp				bigint unsigned not null,	
	unique key (us_uId),
	foreign key(us_uId) references tbl_user_static(us_uId) on update cascade on delete cascade
)engine = innodb;

create table tbl_user_activation_code
(	
	us_uId					int	unsigned	not	null,
	uac_ActCode			varchar(60) not null,
	unique key (us_uId),
	foreign key(us_uId) references tbl_user_static(us_uId) on update cascade on delete cascade
)engine = innodb;


