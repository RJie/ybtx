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
	
	key(le_uId),
	key(lts_uId),
	key(ltbe_sName)
 )engine=innodb;
 
 alter table tbl_log_char_login add column lcs_uId 			bigint unsigned			not null;
 alter table tbl_log_char_login add column lcl_uLevel tinyint unsigned			not null;
 
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
create table tbl_log_tong_building_move
(
	le_uId	bigint unsigned		not	null,
	lts_uId  int unsigned	not null, #Ӷ��С��Id
	ltbm_uExecutorId bigint unsigned	not null, #ִ����
	ltbm_uOldPosX        	float        						not null, 
	ltbm_uOldPosY        	float 				        	not null, 
	ltbm_uNewPosX        	float        						not null, 
	ltbm_uNewPosY        	float 				        	not null, 

	key(le_uId),
	key(lts_uId)
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
	le_uId	bigint unsigned		not	null,
	ltce_uChallengeTongId  int unsigned	not null, #��սӶ��С��Id
	ltce_uRecoveryTongId  int unsigned	not null, #����Ӷ��С��Id
	ltce_uWarzoneId    int unsigned  not null, #ս��id
	ltce_uIndex      int unsigned 	not null, #פ��id
	ltce_uResult   smallint unsigned	not null , #��սʤ�� 0 - ʧ�� 1 - �ɹ�
	ltce_dtEndTime datetime	not null , #����ʱ��

	key(le_uId),
	key(ltce_uChallengeTongId),
	key(ltce_uRecoveryTongId),
	key(ltce_uWarzoneId)
 )engine=innodb;
 
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


#װ��׷��
create table tbl_log_item_equip_superaddation(
	lis_uId          bigint unsigned not null,
	lies_uCurSuperaddPhase tinyint unsigned not null,
	lies_uMaxSuperaddPhase tinyint unsigned not null,
	
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

create table tbl_log_team_activity
(
	le_uId bigint unsigned not null,
	lta_uSuccTeamId bigint unsigned not null,
	lta_uFailTeamId bigint unsigned not null,
	lta_uCostTime bigint unsigned not null,
	lta_uActivityType tinyint unsigned not null,
	
	key(le_uId),
	key(lta_uActivityType)
)engine = innodb;