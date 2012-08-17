#drop database if exists ybtx_game_log;
#create database ybtx_game_log;
#use ybtx_game_log;

################################################################
#
#		�������Ĳ��ֵı��
#		
#		ע�⣺��Ϸ�߼�����ֻ����ӻ���ɾ���������Ĳ�
#					�ֵı�����ݣ�������Ӧ�ö�ȡ��Щ���ݵ�����
#
################################################################


################################################################
#		�¼���¼
################################################################
create table tbl_log_event
(
 le_uId				bigint unsigned			not	null auto_increment,
 le_dtDateTime		datetime				not null,
 
 primary	key(le_uId ),
 key (le_dtDateTime)
 )engine=innodb;

create table tbl_log_event_type
(
	le_uId				bigint unsigned not null,
	let_uEventType	smallint unsigned not null,
	
	key(le_uId),
	key (let_uEventType)
)engine=innodb;

################################################################
#		�˺š���ɫ����Ʒ��Ϣ���ݼ�¼
################################################################

create table tbl_log_user_static
(
 lus_uId		int unsigned	not	null,
 lus_sName	varchar(96)		not	null,
 lus_dtCreateTime	datetime not null,			 
 
 primary	key(lus_uId),
 unique key(lus_sName)
)engine = innodb;

create table tbl_log_char_static
(
 lcs_uId							bigint unsigned		not	null,
 lus_uId							int	unsigned			not	null,
 lcs_sHair						varchar(96)	not	null,	#ͷ��
 lcs_sHairColor				varchar(96)	not	null,	#��ɫ
 lcs_sFace						varchar(96)	not	null,	#����
 lcs_uScale						tinyint	unsigned	not	null,	#���ű���
 lcs_uSex							tinyint	unsigned	not	null,	#�Ա�
 lcs_uClass						tinyint	unsigned	not	null,	#ְҵ
 lcs_uCamp					tinyint	unsigned	not	null,			#��Ӫ
 lcs_dtCreateDate 		datetime not null					, #��ɫ����ʱ��

 primary	key(lcs_uId),
 key(lus_uId)
 )engine = innodb;

#δɾ���Ľ�ɫ�б�
create table tbl_log_char
(
 lcs_uId					bigint	unsigned	not	null, 
 lc_sName					char(32) collate utf8_unicode_ci not	null,

 primary	key(lcs_uId),
 key(lc_sName)
 )engine=innodb;
 
 #�ѱ�ɾ���Ľ�ɫ�б�
create table tbl_log_char_deleted		#deleted roles
(
	le_uId			bigint unsigned not null,
	lcs_uId			bigint	unsigned	not	null,   	#role identifier
	lcd_sName		char(32) collate utf8_unicode_ci not null,	#role name that be used while be avtived

	primary	key(lcs_uId),
	key(le_uId),
	key(lcd_sName)
)engine=innodb;

create table tbl_log_item_static
(
 lis_uId							bigint unsigned					not	null,
 lis_uType						tinyint unsigned				not	null,		#��Ʒ����
 lis_sName						varchar(96)							not	null,		#��Ʒ����
 lcs_uId					bigint	unsigned	not	null, 
 lis_sCode						char(32) not null,   
 
 key(lis_sName),
 key(lcs_uId),
 primary key(lis_uId),
 key(lis_uType)
 )engine = innodb;

##��Ʒ������
create table tbl_log_item_binding    	#binding info of a item
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint 	unsigned	not	null,		#item identifier
	lib_uBindType	tinyint	unsigned	default 0, 		#item binding type
									#	0 stands for unbindinged
									#	1 stands for would be bindinged when be used
									#	2 stands for bindinged
															
	key(le_uId),
	key(lis_uId),
	key(lib_uBindType)
)engine=innodb;
################################################################
#		����log��ʵ��
################################################################

create table tbl_log_user
(
	le_uId					bigint unsigned			not	null,
	lus_uId					int unsigned			not null,
	
	key(le_uId),
	key(lus_uId)
)engine=innodb;


create table tbl_log_player
(
	le_uId					bigint unsigned			not	null,
	lcs_uId					bigint unsigned			not null,
	
	key(le_uId),
	key(lcs_uId)
 )engine=innodb;

create table tbl_log_player_taker
(
	le_uId					bigint unsigned			not	null,
	lcs_uId					bigint unsigned			not null,
	
	key(le_uId),
	key(lcs_uId)
)engine=innodb;


create table tbl_log_player_giver
(
	le_uId					bigint unsigned			not	null,
	lcs_uId					bigint unsigned			not null,
	
	key(le_uId),
	key(lcs_uId)
 )engine=innodb;

create table tbl_log_npc_taker
(
 le_uId					bigint unsigned			not	null,
 lnt_sNpcName		varchar(768)			not null,

 key (lnt_sNpcName),
 key(le_uId)
)engine=innodb;

create table tbl_log_npc_giver
(
	le_uId					bigint unsigned			not	null,
	lng_sNpcName		varchar(768)		not null,
	
	key (lng_sNpcName),
	key(le_uId)
)engine=innodb;

###############################################��Ӷ��С�������Ϣ��#############################
create table tbl_log_tong_taker
(
	le_uId		bigint unsigned		not	null,
	lts_uId		int unsigned			not null, #Ӷ��С��Id
	
	key(le_uId),
	key(lts_uId)
)engine=innodb;

create table tbl_log_tong_giver
(
	le_uId		bigint unsigned	not	null,
	lts_uId		int unsigned		not null, #Ӷ��С��Id
	
	key(le_uId),
	key(lts_uId)
 )engine=innodb;

#Ӷ��С�ӻ�����Ϣ��
create table tbl_log_tong_static
(
 lts_uId  int unsigned	not null, #Ӷ��С��Id
 lts_sName	varchar(100) collate utf8_unicode_ci not null,#����
 lts_dtCreateTime  datetime          not null,   #create time
 lts_uCamp      tinyint					  not null,      #tong camp
 lts_uInitiatorId bigint unsigned		not null, #tong Initiator

 primary key(lts_uId),
 key(lts_uCamp)
)engine=innodb;

#Ӷ��С������log��
create table tbl_log_tong_honor
(
	le_uId		bigint unsigned			not	null,
	lth_uHonor bigint unsigned		not null,

	key(le_uId)
 )engine=innodb;	

#Ӷ��С�ӹ�ѫlog��
create table tbl_log_tong_exploit
(
	le_uId			bigint unsigned			not	null,
	lte_uExploit bigint unsigned		not null,
	
	key(le_uId)
 )engine=innodb;	

#Ӷ��С�ӵȼ�log��
create table tbl_log_tong_level
(
	le_uId			bigint unsigned			not	null,
	ltl_uLevel	tinyint	unsigned not null,
	
	key(le_uId)
 )engine=innodb;	

#Ӷ��С���ʽ�log��
create table tbl_log_tong_money
(
	le_uId			bigint unsigned		not	null,
	ltm_uMoney 	bigint not null,
	
	key(le_uId)
 )engine=innodb;	

#Ӷ��С����Դlog��
create table tbl_log_tong_resource
(
	le_uId			bigint unsigned		not	null,
	ltr_uResource bigint not null ,
	
	key(le_uId)
 )engine=innodb;	


#Ӷ��С�ӷ�չ��
create table tbl_log_tong_develop_degree
(
	le_uId			bigint unsigned		not	null,
	ltdd_uDevelopDegree bigint not null ,
	
	key(le_uId)
 )engine=innodb;	
 
 
#Ӷ��С�ӽ�ɢ��
create table tbl_log_tong_break
(
	le_uId			bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltb_uBreakCharId bigint unsigned		not null, #tong Initiator
	
	key(le_uId)
 )engine=innodb;	
 
 
 #Ӷ��С�������¼���
create table tbl_log_tong_member_event
(
	le_uId			bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltme_uEventType tinyint not null,#1-����;2-�߳�;3-�˳�;4-����
	ltme_uExecutorId bigint unsigned		not null, #ִ����
	ltme_uObjectId bigint unsigned		not null, #��ִ����
	ltme_uJobType tinyint not null,
	
	key(le_uId),
	key(lts_uId),
	key(ltme_uEventType)
 )engine=innodb;
 
#Ӷ��С�ӿƼ��¼���
create table tbl_log_tong_technology_event
(
	le_uId			bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltte_uEventType tinyint not null,#1-��ʼ�з�;2-ֹͣ�з�;3-����з�
	ltte_uExecutorId bigint unsigned		not null, #ִ����
	ltte_sName     varchar(96)         	not null , #technology name
	ltte_uLevel    tinyint unsigned     not null,  #current level
	
	key(le_uId),
	key(lts_uId),
	key(ltte_sName)
 )engine=innodb;
 
 #Ӷ��С�ӽ����¼���
create table tbl_log_tong_building_event
(
	le_uId			bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltbe_sName     varchar(96)         	not null , #��������
	ltbe_uLevel    tinyint unsigned     not null,  #�����ȼ�
	ltbe_uEventType tinyint not null,#1-���ý���;2-����ݻٽ���
	ltbe_uExecutorId bigint unsigned		not null, #ִ����
	ltbe_uExecutorTongId bigint unsigned		not null, #ִ����Ӷ��С��
	ltbe_uBuildingId bigint unsigned		not null,#����id
	ltbe_uAddParameter float unsigned		not null,#���Ӳ���(Ѫ���ٷֱ�/Ŀ��ȼ�/�ݻ�ʱ������Դ)
	
	key(le_uId),
	key(lts_uId),
	key(ltbe_sName)
 )engine=innodb;
 
#Ӷ��С����Ʒ�����
create table tbl_log_tong_item_produce
(
	le_uId			bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltip_sName     varchar(96) not null , #��Ʒ����
	ltip_uEventType tinyint not null,#1-��ʼ;2-ȡ�� 3-�������
	ltip_uExecutorId bigint unsigned		not null, #ִ����
	
	key(le_uId),
	key(lts_uId),
	key(ltip_uEventType)
 )engine=innodb;
 
 #Ӷ��С��ת���ͱ�
create table tbl_log_tong_change_type
(
	le_uId			bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltct_uNewType  tinyint not null, #������
	ltct_uOldType tinyint not null,#ԭ����
	ltct_uExecutorId bigint unsigned	not null, #ִ����
	
	key(le_uId),
	key(lts_uId)
 )engine=innodb;
 
#Ӷ��С�Ӳֿ��ȡ��
create table tbl_log_tong_depot
(
	le_uId	bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltd_uType  tinyint not null, #�������� 1-���׷��룻2-������룻 3-��ȡ
	lis_uId bigint 	unsigned	not	null,#��Ʒid
	ltd_uDepotId  tinyint not null, #�ֿ�id
	ltd_uExecutorId bigint unsigned	not null, #ִ����
	ltd_uExecutorPosition tinyint unsigned not null,#ִ����ְλ
	
	key(le_uId),
	key(lts_uId),
	key(ltd_uType)
 )engine=innodb;
 
#Ӷ��С��Ǩ��פ�ر�
create table tbl_log_tong_station_move
(
	le_uId	bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltsm_uExecutorId bigint unsigned	not null, #ִ����
	ltsm_uEventType tinyint unsigned	not null, #Ǩ������
	ltsm_uOldWarzoneId  int  not null, 
	ltsm_uOldIndex      int not null, 
	ltsm_uNewWarzoneId int  not null, 
	ltsm_uNewIndex    int not null, 

	key(le_uId),
	key(lts_uId),
	key(ltsm_uEventType)
 )engine=innodb;
 
#Ӷ��С����ս��ʼ
create table tbl_log_tong_challenge_start
(
	le_uId	bigint unsigned		not	null,
	ltcs_uExecutorId bigint unsigned	not null, #ִ����
	ltcs_uChallengeTongId  int unsigned	not null, #��սӶ��С��Id
	ltcs_uRecoveryTongId  int unsigned	not null, #����Ӷ��С��Id
	ltcs_uWarzoneId    int unsigned  not null, #ս��id
	ltcs_uIndex      int unsigned 	not null, #פ��id

	key(le_uId),
	key(ltcs_uChallengeTongId),
	key(ltcs_uRecoveryTongId),
	key(ltcs_uWarzoneId)
 )engine=innodb;
 
 #Ӷ��С����ս����
create table tbl_log_tong_challenge_end
(
	ltce_uChallengeTongId  int unsigned	not null, #��սӶ��С��Id
	ltce_uRecoveryTongId  int unsigned	not null, #����Ӷ��С��Id
	ltce_uWarzoneId    int unsigned  not null, #ս��id
	ltce_uIndex      int unsigned 	not null, #פ��id
	ltce_uResult   smallint unsigned	not null , #��սʤ�� 0 - ʧ�� 1 - �ɹ�
	ltce_dtEndTime datetime	not null , #����ʱ��

	key(ltce_uChallengeTongId),
	key(ltce_uRecoveryTongId),
	key(ltce_uWarzoneId)
 )engine=innodb;
 ##############################��Ӷ���������Ϣ��############################
create table tbl_log_army_corps
(
  lac_uId				bigint unsigned	not null,	
  lac_sName			varchar(100) collate utf8_unicode_ci not null,
  lac_uCreateCharId		bigint unsigned	not null,
  lac_uCamp			tinyint	not null,			
 	lac_dtCreateTime datetime not null,
	
  key(lac_uId),
  key(lac_uCamp)
)engine=innodb;

create table tbl_log_army_corps_break
(
	le_uId					bigint unsigned			not null,
  lac_uId				bigint unsigned	not null,	
  lcs_uId			bigint unsigned	not null,
	
	key(le_uId),
  key(lac_uId),
  key(lcs_uId)
)engine=innodb;

create table tbl_log_army_corps_member_event
(
	le_uId					bigint unsigned			not null,
  lac_uId				bigint unsigned	not null,	#Ӷ����id
	lacme_uEventType tinyint not null,#1-����;2-�߳�;3-����
	lacme_uExecutorId bigint unsigned		not null, #ִ����
	lacme_uObjectId bigint unsigned		not null, #��ִ����
	lacme_uJobType tinyint not null,#ְλ
	
	key(le_uId),
  key(lac_uId),
  key(lacme_uEventType)
)engine=innodb;
################################################################
#		�������¼���¼
################################################################

#�������������������¼
create table tbl_log_service_online_num
(
 le_uId					bigint unsigned			not null,
 lson_uServerId tinyint	unsigned	not	null, #������id
 lson_uOnlineUserNum bigint unsigned			not null, #��������������

 key(lson_uServerId),
 key(le_uId)
 )engine=innodb;

#�������ϸ�����������������
create table tbl_log_service_scene_online_num
(
 le_uId					bigint unsigned			not null,
 lsson_uServerId tinyint	unsigned	not	null,
 lsson_uOnlineUserNum bigint unsigned			not null,
 lsson_sSceneName varchar(96) not null,
 lsson_uSceneType tinyint	unsigned	not	null,
 
 key(lsson_uServerId),
 key(le_uId)
 )engine=innodb;
################################################################
#		������¼
################################################################

create table tbl_log_login
(
 le_uId					bigint unsigned			not null,
 ll_sIP 					varchar(45) 						not null,
 ll_sSN					varchar(96)				not null,

 key(ll_sIP),
 key(ll_sSN),
 key(le_uId)
)engine=innodb;

create table tbl_log_logout
(
	le_uId					bigint unsigned			not null,
	ll_sSN					varchar(96)				not null,
	
	key(le_uId),
	key(ll_sSN)
)engine=innodb;

create table tbl_log_char_login
(
 le_uId					bigint unsigned			not null,
 lcs_uId 			bigint unsigned			not null,
 lcl_uLevel tinyint unsigned			not null,	
 
 key(le_uId),
 key(lcs_uId)
)engine=innodb;
################################################################
#		����Ʋ��仯��¼
################################################################

create table tbl_log_money
(
 le_uId bigint unsigned		not	null,
 lcs_uId			bigint unsigned not null,
 lm_uMoney		bigint 	not null,
 lm_uMoneyType	tinyint not null,
 lm_sCode1 char(32) not null,	#�仯��Ǯ���������ɵ�
 lm_sCode2 char(32) not null,	#����������

 key(le_uId),
 key(lcs_uId),
 key(lm_uMoneyType)
)engine=innodb;


create table tbl_log_depot_money
(
 le_uId				bigint unsigned		not	null,
 ldm_uMoney		bigint not	null,
 ldm_sCode1 char(32) not null, #��ȡǮ��ֿ�Ǯ���������ɵ�
 ldm_sCode2 char(32) not null, #����������

 key(le_uId)
 )engine=innodb;


create table tbl_log_item
(
 le_uId				bigint unsigned		not null,
 lis_uId				bigint unsigned		not null,

 key(le_uId),
 key(lis_uId)
)engine=innodb;

create table tbl_log_item_giver
(
 le_uId				bigint unsigned		not null,
 lis_uId				bigint unsigned		not null,
 
 key(le_uId),
 key(lis_uId)
)engine=innodb;

create table tbl_log_item_taker
(
 le_uId				bigint unsigned		not null,
 lis_uId				bigint unsigned		not null,
 
 key(le_uId),
 key(lis_uId)
)engine=innodb;

create table tbl_log_item_del
(
	le_uId				bigint unsigned		not null,
	lis_uId				bigint unsigned		not null,
	lid_sCode			char(32) not null,   #��������
	
	key(le_uId),
	key(lis_uId)
)engine=innodb;


create table tbl_log_experience
(
	le_uId				bigint unsigned		not	null,
	lcs_uId			bigint unsigned not null,
	le_uExp			bigint 			not null,
	le_sCode1 char(32) not null, #�仯����������ɵ�
	le_sCode2 char(32) not null, #����������
	
	key(le_uId),
	key(lcs_uId)
)engine=innodb;


create table tbl_log_level
(
 le_uId				bigint unsigned		not	null,
 ll_uLevel			tinyint unsigned			not null,	

 key(le_uId),
 key(ll_uLevel)
)engine=innodb;


create table tbl_log_reputation
(
	le_uId				bigint unsigned		not	null,
	lr_uExp			int unsigned			not null,
	
	key(le_uId)
)engine=innodb;

create table tbl_log_skill
(
 le_uId				bigint unsigned			not	null,
 ls_sName		varchar(96)			not null, #������
 ls_uLevel		tinyint unsigned not null, #���ܵȼ�	
 ls_uType tinyint unsigned not null, #0����ѧϰ��1��������
 ls_uIsNonSkill tinyint unsigned not null, #0 ������ս������ ��1 �����ս������

 key(le_uId),
 key(ls_uType),
 key(ls_uIsNonSkill)
)engine=innodb;

#���۽�����
create table tbl_log_market(
	le_uId		bigint unsigned	not	null,
	mos_uId		bigint unsigned	not null,#����ID
	lm_uCount	int	unsigned	not null, #��Ʒ��Ŀ
	lm_uPrice	bigint	unsigned	not null, #��Ʒ����
	
	key(le_uId),
	key(mos_uId)
)engine=innodb;


create table tbl_log_market_item(
	le_uId		bigint unsigned	not	null,
	mos_uId		bigint unsigned	not null,#����ID
	
	key(le_uId),
	key(mos_uId)
)engine=innodb;

#�������󹺶�����
create table tbl_log_market_buy_order_static
(			
	le_uId		bigint unsigned	not	null,
	lmos_uId				bigint unsigned		not null,		# order identifier
	lmbo_sItemName		varchar(96)			not null,		# acquired item name
	lmbo_uCount			bigint unsigned		not null,		# acquired item number
	lmbo_uPrice			bigint unsigned		not null,		# item price
	
	key(le_uId),
	key(lmos_uId),
	key(lmbo_sItemName)
)engine=innodb;	

#����ܴ���������
create table tbl_log_contract_manufacture_order_static(
  le_uId		bigint unsigned	not	null,
  lcmo_uId             bigint      unsigned    not null,
  lcmo_sSkillName      varchar(96)             not null,
  lcmo_sDirection      varchar(96)             not null,
  lcmo_sPrescripName   varchar(96)             not null,
  lcmo_uCMMoney        bigint      unsigned    not null,
  
  key(le_uId),
  key(lcmo_uId)
)engine = innodb;


create table tbl_log_contract_manufacture_order(
	le_uId		bigint unsigned	not	null,
  lcmo_uId             bigint      unsigned    not null,
  
  key(le_uId),
  key(lcmo_uId)
)engine = innodb;
################################################################
#             �������ʼ����
################################################################
create table tbl_log_player_trade
(
 le_uId						bigint unsigned not null,
 lpt_uFromCharId		bigint unsigned not null,
 lpt_uToCharId			bigint unsigned not null,
 lpt_uMoneyType		tinyint	unsigned,
 lpt_uMoney				bigint unsigned,
 lis_uId						bigint unsigned,	

 key(le_uId),
 key(lpt_uFromCharId),
 key(lpt_uToCharId),
 key(lis_uId)
)engine=innodb;
################################################################
#       �������ָ��
################################################################

#�������
create table tbl_log_quest_create
(
 le_uId			bigint unsigned 	not null,
 lcs_uId			bigint unsigned 	not null,
 lqc_sQuestName	varchar(96) 		not null,

 key(le_uId),
 key(lcs_uId),
 key(lqc_sQuestName)
)engine=innodb;

#�������
create table tbl_log_quest_finish
(
 le_uId			bigint unsigned 	not null,
 lqf_sQuestName	varchar(96) 		not null,
 
 key(le_uId),
 key(lqf_sQuestName)
)engine=innodb;

#�������
create table tbl_log_quest_giveup
(
 le_uId			bigint unsigned 	not null,
 lcs_uId			bigint unsigned 	not null,
 lqg_sQuestName	varchar(96) 		not null,

 key(le_uId),
 key(lcs_uId),
 key(lqg_sQuestName)
)engine=innodb;

#����ʧ��
create table tbl_log_quest_failure
(
 le_uId			bigint unsigned 	not null,
 lcs_uId			bigint unsigned 	not null,
 lqf_sQuestName	varchar(96) 		not null,

 key(le_uId),
 key(lcs_uId),
 key(lqf_sQuestName)
)engine=innodb;

################################################################
#       �������ָ��
################################################################
create table tbl_log_enter_scene
(
 le_uId			bigint unsigned 	not null,

 key(le_uId)
 )engine=innodb;

create table tbl_log_leave_scene
(
 le_uId			bigint unsigned 	not null,
 
 key(le_uId)
)engine=innodb;

create table tbl_log_create_scene
(
 le_uId			bigint unsigned 	not null,
 lcs_uSceneId	bigint unsigned 	not null,
 
 key(le_uId),
 key(lcs_uSceneId)
)engine=innodb;


create table tbl_log_join_activity
(
 le_uId	 bigint unsigned 	not null,
 lcs_uId bigint unsigned 	not null,
 lts_uId int unsigned	not null,
 
 key(le_uId),
 key(lcs_uId),
 key(lts_uId)
)engine=innodb;

#######################################################
#             matchgame���
#######################################################
create table tbl_log_matchgame_server		#matchgame��������̼�¼
(
	lms_uRoomId  bigint unsigned not null,		#�����
	lms_sActionName varchar(32),							#���
	lms_uSceneId bigint unsigned not null,		#�����
	lms_uIndex tinyint unsigned not null,			#���ڲ�ֱ��泬��sLog���ȵļ�¼
	lms_dtTime datetime not null default 0,		#����ʱ��
	lms_sLog	 varchar(1024),									#����̼�¼
	
	key(lms_uRoomId),
	key(lms_uSceneId),
	key(lms_uIndex)
)engine = innodb;

create table tbl_log_matchgame_room					#matchgame���ݿ�Room������¼
(
	lmr_uRoomId bigint unsigned not null,			#�����
	lmr_sActionName varchar(32),							#���
	lmr_uSceneId bigint unsigned not null,		#�����
	lmr_uServerId tinyint unsigned not null,	#������id
	lmr_dtTime datetime not null default 0,		#����ʱ��
	
	key(lmr_uRoomId),
	key(lmr_uSceneId),
	key(lmr_uServerId)
)engine = innodb;

create table tbl_log_matchgame_member				#matchgame���ݿ���Ҳ�����¼
(
	lcs_uId			bigint unsigned not null,
	lmm_sActionName varchar(32),							#���
	lmm_uTeamId bigint unsigned not null,
	lmm_uRoomId	bigint unsigned not null,			#�����
	lmm_sFuncName varchar(16),								#��������
	lmm_sState varchar(32),										#���غ���
	lmm_dtTime datetime not null default 0,		#����ʱ��
	
	key(lcs_uId),
	key(lmm_uTeamId),
	key(lmm_uRoomId)
)engine = innodb;

create table tbl_log_xianxie				#��Ѫ�����������¼
(
	le_uId			bigint unsigned 	not null,
	lcs_uId			bigint unsigned not null,
	lx_uWin 		tinyint not null default 0,		#ʤ��
	lx_uScore 	tinyint not null default 0,		#�����
	lx_uKillNum	tinyint not null default 0,		#ɱ����
	lx_uDeadNum	tinyint not null default 0,		#������
	
	key(le_uId),
	key(lcs_uId)
)engine = innodb;

#######################################################
#             ר�ż�¼gmlog�Ĺ���
#######################################################
create table tbl_log_gmcommand
(
 lg_sAccountName	varchar(96)	not null,
 lg_sIP			varchar(48)	not null,
 lg_sCallTime		timestamp	not null,
 lg_sCmdContent	varchar(384) not null
 
 )engine=innodb;

#������Ϣ
create table tbl_log_scene
(
 le_uId			bigint unsigned 	not null,
 ls_sSceneName varchar(96)	not null,

 key(le_uId)
)engine=innodb;

#����Ϣ
create table tbl_log_soul
(
 le_uId			bigint unsigned 	not null,
 lcs_uId			bigint unsigned 	not null,
 ls_uSoulValue bigint not null,
 ls_sCode1 char(32) not null, #�仯��Ǯ���������ɵ�
 ls_sCode2 char(32) not null, #����������

 key(le_uId),
 key(lcs_uId)
)engine=innodb;

#######################################################
#             װ�������Ϣ
#######################################################

#װ��ǿ��
create table tbl_log_equip_intensify
(
 le_uId			bigint unsigned 	not null,
 lei_uLevel		tinyint unsigned 	not null,

 key(le_uId)
 )engine=innodb;

#װ������
create table tbl_log_equip_upgrade
(
 le_uId			bigint unsigned 	not null,
 leu_uLevel		tinyint unsigned 	not null,

 key(le_uId)
 )engine=innodb;

#װ��ϴ��
create table tbl_log_equip_intensifyback
(
 le_uId			bigint unsigned 	not null,

 key(le_uId)
 )engine=innodb;

#��װ��
create table tbl_log_equip_puton
(
 le_uId			bigint unsigned 	not null,
 lep_uEquipPart	tinyint unsigned  not null,   #װ��λ��

 key(le_uId)
)engine=innodb;

#��װ��
create table tbl_log_equip_putoff
(
 le_uId			bigint unsigned 	not null,

 key(le_uId)
)engine=innodb;

#װ��������Ϣ��
create table tbl_log_item_equip_advance
(
 le_uId			bigint unsigned 	not null,
 lis_uId		bigint unsigned		not null,			#��Ʒid
 liea_uCurAdvancePhase tinyint unsigned	not null,			#װ����ǰ���׵Ľ׶�
 liea_uTotalAdvancedTimes int  unsigned,					#װ�����ܽ��״���
 liea_uSkillPieceIndex1 	tinyint	unsigned,				#���ܼ����������1����
 liea_uSkillPieceIndex2 	tinyint	unsigned,				#���ܼ����������2����
 liea_uSkillPieceIndex3 	tinyint	unsigned,				#���ܼ����������3����
 liea_uSkillPieceIndex4 	tinyint	unsigned,				#���ܼ����������4����		
 liea_uChoosedSkillPieceIndex 	tinyint unsigned,			#��ǰѡ��ļ��ܼ�������������
 liea_sJingLingType               varchar(3),                 #�������ͣ��𡢷硢�ء�����ˮ
 liea_uAdvanceSoulNum             smallint unsigned default 0,          #ע��Ľ��׻���Ŀ
 liea_uAdvancedTimes              int unsigned default 0,               #���״���
 liea_uAdvancedAttrValue1         int unsigned,
 liea_uAdvancedAttrValue2         int unsigned,
 liea_uAdvancedAttrValue3         int unsigned,
 liea_uAdvancedAttrValue4         int unsigned,
 liea_sAdvancedSoulRoot           varchar(12),
 liea_sAdvancedAttr1	            varchar(48),
 liea_sAdvancedAttr2	            varchar(48),
 liea_sAdvancedAttr3	            varchar(48),
 liea_sAdvancedAttr4	            varchar(48),

 key(le_uId),
 key(lis_uId)
)engine=innodb;

#��ҵ�ǰ�����log��
create table tbl_log_equip_advancedActiveSkill
(
	le_uId			bigint unsigned 	not null,
	lcs_uId			bigint unsigned 	not null,
	iea_uActiveSkillIndex	int unsigned,					#���ѡ����õļ�����������
	
	key(le_uId),
	key(lcs_uId)
)engine=innodb;
	
	
#װ���;�
create table tbl_log_item_equip_durability
(
  le_uId			bigint unsigned 	not null,
  lis_uId          bigint unsigned not null,	#��ƷID
  lied_uMaxDuraValue float unsigned,          #�;�����ֵ
  lied_uCurDuraValue float unsigned,         #��ǰ�;�ֵ
   
  key(lis_uId),
  key(le_uId)
)engine = innodb;

#����
create table tbl_log_item_armor
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint unsigned		not null,			#��Ʒid
	lia_uBaseLevel		tinyint unsigned 	not null, 		#��ʼ�ȼ�
	lia_uCurLevel        tinyint unsigned 	not null,
	lia_uUpgradeAtrrValue1	int unsigned 	not null, 			#װ������ʱ������һ����������1~3�������ñ��е�˳��
	lia_uUpgradeAtrrValue2	int unsigned 	not null,			#װ������ʱ�����Զ�
	lia_uUpgradeAtrrValue3	int unsigned 	not null,			#װ������ʱ��������
	lia_uStaticProValue		int unsigned 	not null,       	#��̬װ������ֵ
	lia_uIntensifyQuality    tinyint unsigned    not null default 0, 	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	lia_sIntenSoul varchar(6),
	
	key (le_uId),
	key (lis_uId)
)engine=innodb;

create table tbl_log_item_weapon
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint unsigned		not null,			#��Ʒid
	liw_uBaseLevel 		tinyint unsigned 	not null, 		#��ʼ�ȼ�������ʱ�޸ģ�
	liw_uCurLevel       tinyint unsigned 	not null,
	liw_uDPS			float unsigned 	not null,			#��ǰDPS������ʱ�޸ģ�	
	liw_uAttackSpeed float unsigned 	not null default 0,			#�����ٶ�
	liw_uDPSFloorRate tinyint 	not null default 0,			#��������
	liw_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	liw_sIntenSoul varchar(6),
	
	key (le_uId),
	key (lis_uId)
)engine=innodb;

create table tbl_log_item_ring
(
	le_uId			bigint unsigned 	not null,
	lis_uId			bigint unsigned 	not null,		    #��ƷID
	lir_uBaseLevel		tinyint unsigned	not null, 		#��ʼ�ȼ�
	lir_uCurLevel        tinyint unsigned 	not null,
	lir_uDPS			float unsigned	not null,			    #������
	lir_uStaticProValue  float unsigned	not null,			#��̬װ������ֵ
	lir_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	lir_sIntenSoul varchar(6),
	
	key (le_uId),
	key (lis_uId)
)engine=innodb;

#����
create table tbl_log_item_shield
(
	le_uId			bigint unsigned 	not null,
	lis_uId 			bigint unsigned 	not null,		#��ƷID
	lis_uBaseLevel 		tinyint unsigned 	not null, 		#��ʼ�ȼ�������ʱ�޸ģ�
	lis_uCurLevel        tinyint unsigned 	not null,
	lis_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	lis_sIntenSoul varchar(6),
	
	key (le_uId),
	key (lis_uId)
)engine=innodb;

##װ����������
create table tbl_log_item_equip_armor (
	le_uId			bigint unsigned 	not null,
	lis_uId          bigint unsigned not null,	#��ƷID
	liea_sAttr		varchar(48) not null, #����Ƭ(����)
	liea_uAddTimes tinyint	unsigned   not null,
	liea_uIndex tinyint	unsigned   not null,
	
	key (le_uId),
	key (lis_uId)
)engine = innodb;

##���Ʋ��������������ԡ�
create table tbl_log_item_shield_Attr
(
	le_uId			bigint unsigned 	not null,
	lis_uId 			bigint unsigned not null,	#��ƷID
	lisa_uAttrValue1	int unsigned ,				#װ������ʱ������һ����ֵ��ֵ(�Ժ������õ�)
	lisa_uAttrValue2	int unsigned ,				#װ������ʱ�����Զ���Ȼ��ֵ��ֵ(�Ժ������õ�)
	lisa_uAttrValue3	int unsigned ,				#װ������ʱ���������ƻ���ֵ��ֵ(�Ժ������õ�)
	lisa_uAttrValue4	int unsigned ,				#װ������ʱ�������İ��ڿ�ֵ��ֵ(�Ժ������õ�)
	
	key (le_uId),
	key (lis_uId)
)engine=innodb;


##װ��ǿ����Ϣ��
create table tbl_log_item_equip_intensify
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint unsigned		not null,			#��Ʒid
	liei_uIntensifySoulNum	int unsigned		not null default 0,#ͬ�ϣ�������������ǿ���Ļ���Ŀ
	liei_uPreAddAttr1	varchar(48) not null default "" , 					#ǿ����һ�׶εĸ�������1��ǿ��ʱ�޸ģ�
	liei_uPreAddAttrValue1	int unsigned not null default 0,   			#��������1��ֵ		��ǿ��ʱ�޸ģ�
	liei_uPreAddAttr2	varchar(48) not null default "", 					#ǿ����һ�׶εĸ�������2��ǿ��ʱ�޸ģ�
	liei_uPreAddAttrValue2	int unsigned not null default 0,   			#ǿ����һ�׶εĸ�������2��ֵ��ǿ��ʱ�޸ģ�
	liei_uAddAttr1		varchar(48) not null default "" , 					#ǿ����ǰ�׶θ�������1	��ǿ��ʱ�޸ģ�
	liei_uAddAttrValue1	int unsigned not null default 0,   				#ǿ����ǰ�׶θ�������1��ֵ��ǿ��ʱ�޸ģ�
	liei_uAddAttr2		varchar(48) not null default "", 					#ǿ����ǰ�׶θ�������2	��ǿ��ʱ�޸ģ�
	liei_uAddAttrValue2	int unsigned not null default 0,   				#ǿ����ǰ�׶θ�������2��ֵ��ǿ��ʱ�޸ģ�
	liei_uIntensifyPhase	tinyint unsigned not null default 0,				#װ��ǿ�����Ľ׶Σ���ʼΪ0����1��2��3��4��
	liei_uEuqipSuitType	tinyint unsigned not null default 0,				#װ��ǿ��������װ���ͣ�0��ʾ�ޣ�1��ʾ2���ף�2��ʾ3���ף�3��ʾ4���ף�4��ʾ�����ף�5��ʾ8����
	liei_sSuitName		varchar(120) not null default "",					#��װ����
	liei_uIntensifyBackState tinyint unsigned not null default 0, 			#װ���Ƿ�ɽ���������0��ʾ����������1��ʾ����
	liei_uIntensifyTimes      smallint unsigned not null default 0, 		#��¼װ��ǿ������
	liei_uIntensifyBackTimes  smallint unsigned not null default 0, 		#��¼װ����������
	liei_uIntenTalentIndex     smallint unsigned not null default 0,        #ǿ�������׶β����Ķ����츳��������
	
	key(le_uId),
	key(lis_uId)
)engine=innodb;


#װ��׷��
create table tbl_log_item_equip_superaddation(
	le_uId			bigint unsigned 	not null,
	lis_uId          bigint unsigned not null,
	lies_uCurSuperaddPhase tinyint unsigned not null,
	
	key(le_uId),
	key (lis_uId)
)engine = innodb;


##װ��������
create table tbl_log_item_maker
(
	le_uId			bigint unsigned 	not null,
	lis_uId						bigint unsigned not null, 	#��Ʒid
	lcs_uId 						bigint unsigned 		not null,		#������
	
	key(le_uId),
	key(lis_uId)
)engine=innodb;

#############װ��ǿ��4~9�׶����Ա�######################
create table tbl_log_item_equip_intensifyAddAttr
(
	le_uId			bigint unsigned 	not null,
  lis_uId      bigint unsigned 	not null,		                #��ƷID
  liei_sAddAttr4       varchar(48)   not null default "",        					#ǿ��4�׶θ�������
  liei_uAddAttr4Value  int unsigned  not null default 0,          				#ǿ��4�׶θ�������ֵ
  liei_sAddAttr5       varchar(48)   not null default "",       					#ǿ��5�׶θ�������
  liei_uAddAttr5Value  int unsigned  not null default 0,          				#ǿ��5�׶θ�������ֵ
  liei_sAddAttr6       varchar(48)   not null default "",        					#ǿ��6�׶θ�������
  liei_uAddAttr6Value  int unsigned  not null default 0,          				#ǿ��6�׶θ�������ֵ
  liei_sAddAttr7       varchar(48)   not null default "",        					#ǿ��7�׶θ�������
  liei_uAddAttr7Value  int unsigned  not null default 0,          				#ǿ��7�׶θ�������ֵ
  liei_sAddAttr8       varchar(48)   not null default "",        					#ǿ��8�׶θ�������
  liei_uAddAttr8Value  int unsigned  not null default 0,          				#ǿ8�Ľ׶θ�������ֵ
  liei_sAddAttr9       varchar(48)   not null default "",        					#ǿ��9�׶θ�������
  liei_uAddAttr9Value  int unsigned  not null default 0,          				#ǿ��9�׶θ�������ֵ
  
  key(le_uId),
  key(lis_uId)
)engine=innodb;
#######################################################
#             ս�������Ϣ
#######################################################
#��������¼�
create table tbl_log_player_dead
(
	le_uId			bigint unsigned 	not null,
	lpd_uPlayerId	bigint unsigned 	not null,
	lpd_uLevel tinyint	unsigned not null,
	
	key(lpd_uPlayerId),
	key(le_uId)
)engine=innodb;
#���ɱ���¼�
create table tbl_log_player_kill
(
	le_uId			bigint unsigned 	not null,
	lpk_uPlayerId	bigint unsigned 	not null,
	lpk_uLevel tinyint	unsigned not null,
	
	key(lpk_uPlayerId),
	key(le_uId)
)engine=innodb;
#�����������
create table tbl_log_npc_name
(
	le_uId			bigint unsigned 	not null,
	lnn_sNpcName	varchar(96) 	not null,
	
	key(le_uId),
	key(lnn_sNpcName)
)engine=innodb;

#ս�������Ϣ���ձ�
create table tbl_log_char_fight_info
(
	le_uId bigint unsigned not null,
	lcs_uId bigint unsigned not null,#���id
	lcfi_uLevel tinyint unsigned not null,#�ȼ�
	lcfi_uSeries  tinyint unsigned not null,#�츳ϵ
	lcfi_uFightPoint smallint unsigned not null,#ս����
	lcfi_uNatureResistance float unsigned	not null,#��Ȼ��
	lcfi_uEvilResistance float unsigned	not null,#�ƻ���ֵ
	lcfi_uDestructionResistance float unsigned	not null,#���ڿ�ֵ
	lcfi_uDefence float unsigned	not null,#����ֵ
	
	key(le_uId),
	key(lcs_uId),
	key(lcfi_uLevel)
)engine = innodb;

#����Pk
create table tbl_log_char_pk
(
	le_uId			bigint unsigned 	not null,
	lcp_uFlagId int unsigned not null,#����id
	lcp_uResponsesId bigint unsigned not null,#������id
	lcp_uChallengeId bigint unsigned not null,#��ս��id
	lcp_uCostTime bigint unsigned 	not null,#ս��ʱ��
	lcp_uIsSucc tinyint unsigned not null,#ʤ��
	
	key(le_uId),
	key(lcp_uFlagId),
	key(lcp_uIsSucc)
)engine=innodb;

#3V3����\�Ƕ���\��Ѫ������\���鱾\���³�
create table tbl_log_team_activity
(
	le_uId bigint unsigned not null,
	lta_uSuccTeamId bigint unsigned not null,#ʤ������id
	lta_uFailTeamId bigint unsigned not null,#ʧ�ܶ���id
	lta_uCostTime bigint unsigned not null,#��������ܺ�ʱ
	lta_uActivityType tinyint unsigned not null,#����� 1-3V3����\2-�Ƕ���\3-��Ѫ������\4-���鱾\5-���³�
	
	key(le_uId),
	key(lta_uActivityType)
)engine = innodb;
#######################################################
#             �츳�����Ϣ
#######################################################
create table tbl_log_talent
(
	le_uId			bigint unsigned 	not null,
	lt_sTalentName varchar(96) 	not null,
	lt_uType tinyint unsigned 	not null, #1-ѧ�츳��2ϴ�츳
	
	key(le_uId),
	key(lt_uType)
)engine=innodb;
#######################################################
#             ���������Ϣ
#######################################################
create table tbl_log_reborn_info
(
	le_uId			bigint unsigned 	not null,
	lr_uMethod 		tinyint unsigned 	not null,
	
	key(le_uId)
)engine=innodb;
#######################################################
#             �ϳ������Ϣ
#######################################################
create table tbl_log_compose_info
(
	le_uId			bigint unsigned 	not null,
	
	key(le_uId)
)engine=innodb;
#######################################################
#             ��������Ϣ
#######################################################
create table tbl_log_enter_team
(
	le_uId			bigint unsigned 	not null,
	let_uTeamId		bigint unsigned		not null,
	
	key(le_uId)
)engine=innodb;

create table tbl_log_leave_team
(
	le_uId			bigint unsigned 	not null,
	let_uTeamId		bigint unsigned		not null,

	key(le_uId)
)engine=innodb;
#######################################################
#             ������Ϣ
#######################################################

create table tbl_log_enter_activity
(
	le_uId			bigint unsigned 	not null,
	lea_uSceneId	bigint unsigned 	not null,
	lea_sName		varchar(96)			not null,
	
	key(le_uId),
	key(lea_sName)
)engine=innodb;

create table tbl_log_leave_activity
(
	le_uId			bigint unsigned 	not null,
	lea_uSceneId	bigint unsigned 	not null,
	lea_sName		varchar(96)			not null,
	
	key(le_uId),
	key(lea_sName)
)engine=innodb;

create table tbl_log_xiuxingta
(
	le_uId			bigint unsigned 	not null,
	lx_uGateId		int unsigned 		not null,
	lx_uSceneId bigint	unsigned	not	null,
	lx_uSucceedFlag tinyint unsigned 	not null,#1--�ɹ���2--ʧ�ܣ�3--ʱ�䵽 4--����
	lx_uSpendTimes bigint unsigned 		not null, #ÿ�ػ��ѵ�ʱ��
	lx_sFloorId varchar(2) not null,#��id
	
	key(le_uId),
	key(lx_uSceneId),
	key(lx_uSucceedFlag),
	key(lx_sFloorId)
)engine=innodb;
#######################################################
#            ����ϵ��Ϣ
#######################################################
create table tbl_log_add_friend
(
	le_uId bigint unsigned not null,
	laf_uFriendId bigint unsigned not null,
	
	key(le_uId)
)engine=innodb;

create table tbl_log_delete_friend
(
	le_uId bigint unsigned not null,
	ldf_uFriendId bigint unsigned not null,
	
	key(le_uId)
)engine=innodb;

create table tbl_log_user_cheat
(
	lus_sName	varchar(96)		not	null,
	lcs_uId		bigint unsigned	not	null,
	luc_dtAppearTime datetime not null,
	luc_sSceneName varchar(96) not null,
	
	key(lus_sName),
	key(luc_dtAppearTime)
)engine=innodb;

#######################################################
#            ������Ϣ
#######################################################
create table tbl_log_jifenpoint
(
	le_uId bigint unsigned not null,
	lcs_uId		bigint unsigned	not	null,
	lj_uPoint bigint not null,
	lj_uType tinyint unsigned not null, #�������� 1.��Ȼ���� 2.���ڻ��� 3.�ƻ����� 4.����ɱ���� 5.���������� 6.���׻���
	lj_sCode1 char(32) not null, #�仯����������ɵ�
	lj_sCode2 char(32) not null, #����������
	
	key(le_uId),
	key(lcs_uId,lj_uType)
)engine=innodb;

create table tbl_log_dataosha_point
(
	le_uId bigint unsigned not null,
	ldp_uPoint bigint not null,
	
	key(le_uId)
)engine=innodb;
	

#�����ӳ� 
create table tbl_log_player_latency 
(        
	cs_uId          bigint unsigned         not     null, 
	pl_uLatency     int unsigned not null, 
	pl_tTime        datetime not null, 
	
	key(cs_uId), 
	key(pl_tTime) 
)engine = innodb; 

#��¼������ߵĳ�������������������
create table tbl_log_player_logout_position 
(    
	le_uId bigint unsigned not null,    
	lcs_uId bigint unsigned not null, 
	lplp_sSceneName	varchar(96) not	null,		#scene name 
	lplp_sAreaName varchar(128) not	null, 
	lplp_uPosX	float	unsigned	not	null default 1,
	lplp_uPosY	float	unsigned	not	null default 1,
	
	key(le_uId),
	key(lcs_uId),
	key(lplp_sSceneName),
	key(lplp_sAreaName)
)engine = innodb; 
#######################################################
#            �����log��Ϣ
#######################################################
##�����log
create table tbl_log_commerce_skill
(
	le_uId bigint unsigned not null,
	lcs_uId 		bigint unsigned 		not null,
	lcs_sSkillName			varchar(96)					not null,		#��������
	lcs_uSkillLevel		tinyint	unsigned		not null,		#���ܵȼ�
	lcs_uExperience		bigint	unsigned		not null,		#����ֵ
	
	key(le_uId),
	key(lcs_uId)
)engine=innodb;

##����������log
create table tbl_log_specialize_smithing
(
	le_uId bigint unsigned not null,
	lcs_uId 						bigint unsigned 		not null,
	lss_uSkillType			tinyint unsigned		not null,			#�����������͡���������׵�
	lss_uType					varchar(96)						not null,		#��������������
	lss_uSpecialize		bigint	unsigned		not null,		#�����ȴ�С
	
	key(lcs_uId),
	key(le_uId)
)engine=innodb;

##����ר��log
create table tbl_log_expert_smithing
(
	le_uId bigint unsigned not null,
	lcs_uId 						bigint unsigned 		not null,		
	les_uSkillType			tinyint unsigned		not null,			#�����������͡���������׵�
	les_uType					varchar(96)					not null,		#ר������
	les_uLevel					tinyint	unsigned		not null,		#ר���ȼ�
	
	key(le_uId),
	key(lcs_uId)
)engine=innodb;
	
#�ֻ�
create table tbl_log_cultivate_flowers
(
	le_uId bigint unsigned not null,
	
	key(le_uId)
)engine = innodb;
	
#����Ʒ��������
create table tbl_log_item_vendue
(
	le_uId bigint unsigned not null,
	
	key(le_uId)
)engine = innodb;

#����Ʒ�������
create table tbl_log_item_vendue_end
(
	le_uId bigint unsigned not null,
	
	key(le_uId)
)engine = innodb;

#����װ����ǿ������
create table tbl_log_equip_intensify_level_up
(
	le_uId bigint unsigned not null,
	
	key(le_uId)
)engine = innodb;

#����������������¼���ݿ�����Ƿ�ɹ���ֵΪsql�ļ���
create table tbl_database_upgrade_record(
		dur_sRecord varchar(64) not null,
		dur_dtTime datetime not null
)engine = innodb;

#���߾���һ�
create table tbl_log_exp_change
(
	le_uId bigint unsigned not null,
	
	key(le_uId)
)engine = innodb;

#���ս��������
create table tbl_log_char_fighting_evaluation
(
	le_uId bigint unsigned not null,
	lcs_uId			bigint unsigned		not	null,
	lcfe_uPoint	float unsigned not null,
	
	key(le_uId),
	key(lcs_uId)
)engine = innodb;

#��¼��ɫ�ٶȱ仯log
create table tbl_log_char_speed
(
	lcs_sName	varchar(96)	not	null,
	lcs_uSpeed float not null,
	lcs_dtAppearTime datetime not null,
	lcs_sChangeReason varchar(96) not null,
	
	key(lcs_sName),
	key(lcs_uSpeed)
)engine=innodb;

#��¼��ɫ���顢��ϵ���仯log
create table tbl_log_char_exp_soul_modulus
(
	lcs_uId	bigint unsigned	not	null,
	lcesm_uModulusType tinyint unsigned not null,#ϵ������ 1-��ϵ�� 2-����ϵ��
	lcesm_uModulusValue float unsigned not null,#ϵ��ֵ
	lcesm_dtChangeTime datetime not null,#ϵ��ֵ
	
	key(lcs_uId)
)engine=innodb;

#Ӷ��С��������Դ�㱨��
create table tbl_log_tong_resource_sig_up
(
	le_uId	bigint unsigned		not	null,
	lts_uId int unsigned	not null, #Ӷ��С��Id
	ltrsu_uExecutorId bigint unsigned		not null, #ִ����
	ltrsu_uExploit bigint not null,
	ltrsu_sObjName varchar(96) not null,
	
	key(le_uId),
	key(lts_uId),
	key(ltrsu_uExecutorId)
 )engine=innodb;	


#��ȯ������Ϣlog��
create table tbl_log_coupons_info(
	le_uId	bigint unsigned		not	null,
	lci_uId          bigint  unsigned		not null,
	lci_sName        varchar(96)  collate utf8_unicode_ci           not null,
	lci_uSmallIcon   int     unsigned        not null,
	lci_uPrice       int(10) unsigned        not null,
	lci_sDesc        text  collate utf8_unicode_ci       not null,
	lci_sUrl         text  collate utf8_unicode_ci        not null,
	
	key (le_uId),
	key (lci_uId)
)engine = innodb;

#��ҹ����ȯlog��Ϣ
create table tbl_log_char_bought_coupons(
	le_uId	bigint unsigned		not	null,
	lcs_uId      bigint unsigned     not null,
	lci_uId      bigint unsigned     not null,
	lcbc_sSequenceId varchar(96)     not null, 
	
	key (le_uId),
	key(lcs_uId, lci_uId)
)engine = innodb;

#######################################################
#            ɾLOG���
#######################################################

CREATE TABLE `tbl_log_normal_delete`(
	`lnd_sName` varchar(96) not	null,
	primary	key(`lnd_sName`)
)engine = innodb;

insert into `tbl_log_normal_delete` values('tbl_log_event');
insert into `tbl_log_normal_delete` values('tbl_log_event_type');
insert into `tbl_log_normal_delete` values('tbl_log_char_deleted');
insert into `tbl_log_normal_delete` values('tbl_log_user');
insert into `tbl_log_normal_delete` values('tbl_log_player');
insert into `tbl_log_normal_delete` values('tbl_log_player_taker');
insert into `tbl_log_normal_delete` values('tbl_log_player_giver');
insert into `tbl_log_normal_delete` values('tbl_log_npc_taker');
insert into `tbl_log_normal_delete` values('tbl_log_npc_giver');
insert into `tbl_log_normal_delete` values('tbl_log_tong_taker');
insert into `tbl_log_normal_delete` values('tbl_log_tong_giver');
insert into `tbl_log_normal_delete` values('tbl_log_tong_honor');
insert into `tbl_log_normal_delete` values('tbl_log_tong_exploit');
insert into `tbl_log_normal_delete` values('tbl_log_tong_level');
insert into `tbl_log_normal_delete` values('tbl_log_tong_money');
insert into `tbl_log_normal_delete` values('tbl_log_tong_resource');
insert into `tbl_log_normal_delete` values('tbl_log_tong_develop_degree');
insert into `tbl_log_normal_delete` values('tbl_log_tong_member_event');
insert into `tbl_log_normal_delete` values('tbl_log_tong_technology_event');
insert into `tbl_log_normal_delete` values('tbl_log_tong_building_event');
insert into `tbl_log_normal_delete` values('tbl_log_tong_item_produce');
insert into `tbl_log_normal_delete` values('tbl_log_tong_change_type');
insert into `tbl_log_normal_delete` values('tbl_log_tong_depot');
insert into `tbl_log_normal_delete` values('tbl_log_tong_station_move');
insert into `tbl_log_normal_delete` values('tbl_log_tong_challenge_start');
insert into `tbl_log_normal_delete` values('tbl_log_army_corps_member_event');
insert into `tbl_log_normal_delete` values('tbl_log_service_online_num');
insert into `tbl_log_normal_delete` values('tbl_log_service_scene_online_num');
insert into `tbl_log_normal_delete` values('tbl_log_login');
insert into `tbl_log_normal_delete` values('tbl_log_logout');
insert into `tbl_log_normal_delete` values('tbl_log_char_login');
insert into `tbl_log_normal_delete` values('tbl_log_money');
insert into `tbl_log_normal_delete` values('tbl_log_depot_money');
insert into `tbl_log_normal_delete` values('tbl_log_item');
insert into `tbl_log_normal_delete` values('tbl_log_item_giver');
insert into `tbl_log_normal_delete` values('tbl_log_item_taker');
insert into `tbl_log_normal_delete` values('tbl_log_experience');
insert into `tbl_log_normal_delete` values('tbl_log_level');
insert into `tbl_log_normal_delete` values('tbl_log_reputation');	
insert into `tbl_log_normal_delete` values('tbl_log_skill');
insert into `tbl_log_normal_delete` values('tbl_log_market');
insert into `tbl_log_normal_delete` values('tbl_log_market_item');
insert into `tbl_log_normal_delete` values('tbl_log_market_buy_order_static');
insert into `tbl_log_normal_delete` values('tbl_log_contract_manufacture_order_static');
insert into `tbl_log_normal_delete` values('tbl_log_contract_manufacture_order');
insert into `tbl_log_normal_delete` values('tbl_log_player_trade');
insert into `tbl_log_normal_delete` values('tbl_log_quest_create');
insert into `tbl_log_normal_delete` values('tbl_log_quest_finish');
insert into `tbl_log_normal_delete` values('tbl_log_quest_giveup');
insert into `tbl_log_normal_delete` values('tbl_log_quest_failure');
insert into `tbl_log_normal_delete` values('tbl_log_enter_scene');
insert into `tbl_log_normal_delete` values('tbl_log_leave_scene');
insert into `tbl_log_normal_delete` values('tbl_log_xianxie');
insert into `tbl_log_normal_delete` values('tbl_log_scene');
insert into `tbl_log_normal_delete` values('tbl_log_soul');
insert into `tbl_log_normal_delete` values('tbl_log_equip_intensify');
insert into `tbl_log_normal_delete` values('tbl_log_equip_upgrade');
insert into `tbl_log_normal_delete` values('tbl_log_equip_intensifyback');
insert into `tbl_log_normal_delete` values('tbl_log_equip_puton');
insert into `tbl_log_normal_delete` values('tbl_log_equip_putoff');
insert into `tbl_log_normal_delete` values('tbl_log_equip_advancedActiveSkill');
insert into `tbl_log_normal_delete` values('tbl_log_player_dead');
insert into `tbl_log_normal_delete` values('tbl_log_player_kill');
insert into `tbl_log_normal_delete` values('tbl_log_npc_name');
insert into `tbl_log_normal_delete` values('tbl_log_char_fight_info');
insert into `tbl_log_normal_delete` values('tbl_log_char_pk');
insert into `tbl_log_normal_delete` values('tbl_log_team_activity');
insert into `tbl_log_normal_delete` values('tbl_log_talent');
insert into `tbl_log_normal_delete` values('tbl_log_reborn_info');
insert into `tbl_log_normal_delete` values('tbl_log_compose_info');
insert into `tbl_log_normal_delete` values('tbl_log_enter_team');
insert into `tbl_log_normal_delete` values('tbl_log_leave_team');
insert into `tbl_log_normal_delete` values('tbl_log_enter_activity');
insert into `tbl_log_normal_delete` values('tbl_log_leave_activity');
insert into `tbl_log_normal_delete` values('tbl_log_xiuxingta');
insert into `tbl_log_normal_delete` values('tbl_log_add_friend');
insert into `tbl_log_normal_delete` values('tbl_log_delete_friend');
insert into `tbl_log_normal_delete` values('tbl_log_jifenpoint');
insert into `tbl_log_normal_delete` values('tbl_log_dataosha_point');
insert into `tbl_log_normal_delete` values('tbl_log_player_logout_position');
insert into `tbl_log_normal_delete` values('tbl_log_commerce_skill');
insert into `tbl_log_normal_delete` values('tbl_log_specialize_smithing');
insert into `tbl_log_normal_delete` values('tbl_log_expert_smithing');
insert into `tbl_log_normal_delete` values('tbl_log_cultivate_flowers');
insert into `tbl_log_normal_delete` values('tbl_log_item_vendue');
insert into `tbl_log_normal_delete` values('tbl_log_item_vendue_end');
insert into `tbl_log_normal_delete` values('tbl_log_equip_intensify_level_up');
insert into `tbl_log_normal_delete` values('tbl_log_exp_change');
insert into `tbl_log_normal_delete` values('tbl_log_char_fighting_evaluation');
insert into `tbl_log_normal_delete` values('tbl_log_tong_resource_sig_up');
insert into `tbl_log_normal_delete` values('tbl_log_coupons_info');
insert into `tbl_log_normal_delete` values('tbl_log_char_bought_coupons');
insert into `tbl_log_normal_delete` values('tbl_log_tong_break');
insert into `tbl_log_normal_delete` values('tbl_log_item_del');
insert into `tbl_log_normal_delete` values('tbl_log_join_activity');