
#log���ݿ��ṹ�޸����
alter table tbl_log_event_type add key (le_uId);
alter table tbl_log_char add key(lc_sName);
alter table tbl_log_user add key(le_uId);
alter table tbl_log_user add key(lus_uId);
alter table tbl_log_player add key(le_uId);
alter table tbl_log_player add key(lcs_uId);
alter table tbl_log_player_taker add key(le_uId);
alter table tbl_log_player_taker add key(lcs_uId);
alter table tbl_log_player_giver add key(le_uId);
alter table tbl_log_player_giver add key(lcs_uId);
alter table tbl_log_npc_taker add key(le_uId);
alter table tbl_log_npc_giver add key (lng_sNpcName);
alter table tbl_log_npc_giver add key(le_uId);
alter table tbl_log_tong_taker add key(le_uId);
alter table tbl_log_tong_giver add key(le_uId);
alter table tbl_log_service_begin add key(le_uId);
alter table tbl_log_service_end add key(le_uId);
alter table tbl_log_service_crash add key(le_uId);
alter table tbl_log_service_online_num add key(le_uId);
alter table tbl_log_service_scene_online_num add key(le_uId);
alter table tbl_log_login add key(le_uId);
alter table tbl_log_logout add key(le_uId);
alter table tbl_log_enter_world add key(le_uId);
alter table tbl_log_leave_world add key(le_uId);
alter table tbl_log_travel add key(le_uId);
alter table tbl_log_logout_abnormality add key(le_uId);
alter table tbl_log_change_scene add key(le_uId);
alter table tbl_log_money add lm_sCode1 char(32) not null;
alter table tbl_log_money add lm_sCode2 char(32) not null;
alter table tbl_log_money add key(le_uId);
alter table tbl_log_item add key(le_uId);
alter table tbl_log_item add key(lis_uId);
alter table tbl_log_item_giver add key(le_uId);
alter table tbl_log_item_giver add key(lis_uId);
alter table tbl_log_item_taker add key(le_uId);
alter table tbl_log_item_taker add key(lis_uId);
alter table tbl_log_item_del add lid_sCode char(32) not null;
alter table tbl_log_item_del add key(le_uId);
alter table tbl_log_item_del add key(lis_uId);
alter table tbl_log_experience add le_sCode1 char(32) not null;
alter table tbl_log_experience add le_sCode2 char(32) not null;
alter table tbl_log_experience add key(le_uId);
alter table tbl_log_level add key(le_uId);
alter table tbl_log_reputation add key(le_uId);
alter table tbl_log_skill add key(le_uId);
alter table tbl_log_market add key(le_uId);
alter table tbl_log_gm_command add key(le_uId);
alter table tbl_log_player_trade add key(le_uId);
alter table tbl_log_player_trade add key(lpt_uFromCharId);
alter table tbl_log_player_trade add key(lpt_uToCharId);
alter table tbl_log_player_trade add key(lis_uId);
alter table tbl_log_player_post add key(le_uId);
alter table tbl_log_player_post add key(lpp_uFromCharId);
alter table tbl_log_player_post add key(lpp_uToCharId);
alter table tbl_log_player_post add key(lis_uId);
alter table tbl_log_quest_create add key(le_uId);
alter table tbl_log_quest_create add key(lcs_uId);
alter table tbl_log_quest_finish add key(le_uId);
alter table tbl_log_quest_giveup add key(le_uId);
alter table tbl_log_quest_giveup add key(lcs_uId);
alter table tbl_log_quest_failure add key(le_uId);
alter table tbl_log_quest_failure add key(lcs_uId);
alter table tbl_log_enter_scene add key(le_uId);
alter table tbl_log_leave_scene add key(le_uId);
alter table tbl_log_scene add key(le_uId);
alter table tbl_log_soul add ls_sCode1 char(32) not null;
alter table tbl_log_soul add ls_sCode2 char(32) not null;
alter table tbl_log_soul add key(le_uId);
alter table tbl_log_equip_create add key(le_uId);
alter table tbl_log_equip_intensify add key(le_uId);
alter table tbl_log_equip_upgrade add key(le_uId);
alter table tbl_log_equip_destroy add key(le_uId);
alter table tbl_log_equip_intensifyback add key(le_uId);
alter table tbl_log_equip_puton add key(le_uId);
alter table tbl_log_equip_putoff add key(le_uId);
alter table tbl_log_player_dead add key(le_uId);
alter table tbl_log_player_dead add key(lpd_uPlayerId);
alter table tbl_log_player_kill add key(le_uId);
alter table tbl_log_player_kill add key(lpk_uPlayerId);
alter table tbl_log_npc_name add key(le_uId);
alter table tbl_log_npc_name add key(lnn_sNpcName);
alter table tbl_log_talent add lt_uType tinyint unsigned 	not null;
alter table tbl_log_talent add key(le_uId);
alter table tbl_log_reborn_info add key(le_uId);
alter table tbl_log_compose_info add key(le_uId);
alter table tbl_log_enter_team add key(le_uId);
alter table tbl_log_leave_team add key(le_uId);
alter table tbl_log_activity_start add key(le_uId);
alter table tbl_log_activity_start add key(lea_sName);
alter table tbl_log_enter_activity add key(le_uId);
alter table tbl_log_enter_activity add key(lea_sName);
alter table tbl_log_leave_activity add key(le_uId);
alter table tbl_log_leave_activity add key(lea_sName);
alter table tbl_log_activity_mark add key(le_uId);
alter table tbl_log_channel_used add key(le_uId);
alter table tbl_log_add_friend add key(le_uId);
alter table tbl_log_delete_friend add key(le_uId);
drop table tbl_log_point_nature;
drop table tbl_log_point_evil;
drop table tbl_log_point_armor;
drop table tbl_log_point_dataosha;
drop table tbl_log_point_jifensai;
drop table tbl_log_point_destroy;
alter table tbl_item_static add is_sCode char(32) not null;


create table tbl_log_jifenpoint
(
		le_uId bigint unsigned not null,
		lj_uPoint bigint not null,
		lj_uType tinyint unsigned not null, #�������� 1.��Ȼ���� 2.���ڻ��� 3.�ƻ����� 4.����ɱ���� 5.���������� 6.���׻���
		lj_sCode1 char(32) not null, #�仯����������ɵ�
		lj_sCode2 char(32) not null, #����������
		
		
		key(le_uId)
)engine=innodb;

create table tbl_serial_jifen
(
	lcs_uId			bigint unsigned not null,
	sj_sCode char(32) not null,	#����������
	
	primary key(lcs_uId)
)engine = innodb;

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

create table tbl_serial_soul
(
	lcs_uId			bigint unsigned not null,
	ss_sCode char(32) not null,	#����������
	
	primary key(lcs_uId)
)engine = innodb;

create table tbl_serial_experience
(
	lcs_uId			bigint unsigned not null,
	se_sCode char(32) not null,	#����������
	
	primary key(lcs_uId)
)engine = innodb;

create table tbl_serial_money
(
	lcs_uId			bigint unsigned not null,
	sm_sCode char(32) not null,	#����������
	
	primary key(lcs_uId)
)engine = innodb;

create table tbl_log_depot_money
(
	le_uId				bigint unsigned		not	null,
	ldm_uMoney		bigint not	null,
	ldm_sCode1 char(32) not null, #��ȡǮ��ֿ�Ǯ���������ɵ�
	ldm_sCode2 char(32) not null, #����������
	
	key(le_uId)
)engine=innodb;

create table tbl_serial_depot_money
(
	lcs_uId			bigint unsigned not null,
	sdm_sCode char(32) not null,	#����������
	
	primary key(lcs_uId)
)engine = innodb;

create table tbl_serial_item_del
(
	lcs_uId			bigint unsigned not null,
	sid_sCode char(32) not null,	#����������
	
	primary key(lcs_uId)
)engine = innodb;


create table tbl_log_player_latency
(	
	cs_uId		bigint unsigned		not	null,
	pl_uLatency	int unsigned not null,
	pl_tTime	datetime not null,
	key(cs_uId),
	key(pl_tTime)
)engine = innodb;

create table tbl_serial_item
(
	si_sCode char(32) not null	

)engine = innodb;

drop table tbl_log_tong_taker;
drop table tbl_log_tong_giver;
alter table tbl_log_char_static add key(lus_uId);

create table tbl_log_tong_taker
(
		le_uId		bigint unsigned		not	null,
		lts_uId		int unsigned			not null, #���Id
		
		key(le_uId),
		key(lts_uId)
)engine=innodb;


create table tbl_log_tong_giver
(
		le_uId		bigint unsigned	not	null,
		lts_uId		int unsigned		not null, #���Id
		
		key(le_uId),
		key(lts_uId)
)engine=innodb;

#��������Ϣ��
create table tbl_log_tong_static
(
		lts_uId  int unsigned	not null, #���Id
		lts_sName	varchar(100) collate utf8_unicode_ci not null,#����

		primary key(lts_uId)
)engine=innodb;

 #�������log��
 create table tbl_log_tong_honor
 (
 	le_uId		bigint unsigned			not	null,
 	lth_uHonor bigint unsigned		not null,
 	
 	key(le_uId)
 )engine=innodb;	
 
 #��Ṧѫlog��
 create table tbl_log_tong_exploit
 (
 	le_uId			bigint unsigned			not	null,
 	lte_uExploit bigint unsigned		not null,
 	
 	key(le_uId)
 )engine=innodb;	
  
 #���ȼ�log��
 create table tbl_log_tong_level
 (
 	le_uId			bigint unsigned			not	null,
 	ltl_uLevel	tinyint unsigned	 not null,
 	
 	key(le_uId)
 )engine=innodb;	
 
 #����ʽ�log��
 create table tbl_log_tong_money
 (
 	le_uId			bigint unsigned		not	null,
 	ltm_uMoney 	bigint not null,
 	
 	key(le_uId)
 )engine=innodb;	
 
  #�����Դlog��
 create table tbl_log_tong_resource
 (
 	le_uId			bigint unsigned		not	null,
 	ltr_uResource bigint not null ,
 	
 	key(le_uId)
 )engine=innodb;	
 
alter table tbl_friends_group drop foreign key tbl_friends_group_ibfk_1;
alter table tbl_friends_group drop column cs_uId;
alter table tbl_player_friends drop column pf_ukind;

alter table tbl_item_static drop column is_sCode;
alter table tbl_log_item_static add column lis_sCode char(32) not null;

alter table tbl_log_player_dead add column lpd_uLevel tinyint	unsigned not null;
alter table tbl_log_player_dead add key(lpd_uLevel);
alter table tbl_log_player_kill add column lpk_uLevel tinyint	unsigned not null;
alter table tbl_log_player_kill add key(lpk_uLevel);

#��ʿ���� ������̬ �޸�
delete from tbl_char_magicstate where cms_uSkillName = '������̬';
delete from tbl_aure_magic where am_uSkillName = '������̬';
#�����ר���������ȵ���
delete from tbl_specialize_smithing where ss_uType in("����","����","����");
delete from tbl_specialize_smithing where ss_uType = "��ָ" and ss_uSkillType = 2;
delete from tbl_expert_smithing where es_uType in("����","����","����");
delete from tbl_expert_smithing where es_uType = "��ָ" and es_uSkillType = 2;

#��¼�ʺ����һ�ε�¼ʱ������һ���˳�ʱ��
create table tbl_user_last_login_logout_time
(
	us_uId int unsigned not null,
	ulllt_dtLoginTime datetime not null, #�ʺ����һ�ε�¼ʱ��
	ulllt_dtLogoutTime datetime not null,#�ʺ����һ�εǳ�ʱ��
	
	primary key(us_uId),
	foreign key(us_uId) references tbl_user_static(us_uId) on update cascade on delete cascade
)engine=innodb;

#�������������������¼
create table tbl_log_service_online_num
(
		le_uId					bigint unsigned			not null,
		lson_uServerId tinyint	unsigned	not	null, #������id
		lson_uOnlineUserNum bigint unsigned			not null #��������������
		
)engine=innodb;

#�������ϸ�����������������
create table tbl_log_service_scene_online_num
(
		le_uId					bigint unsigned			not null,
		lsson_uServerId tinyint	unsigned	not	null,
		lsson_uOnlineUserNum bigint unsigned			not null,
		lsson_sSceneName varchar(96) not null,
		lsson_uSceneType tinyint	unsigned	not	null
		
)engine=innodb;

##��Ʒ����˳��̬��
create table tbl_item_type_order
(
	is_uType						tinyint unsigned				not	null,		#��Ʒ����
	is_uOrder						tinyint unsigned				not	null,		#����˳��
	
	unique key(is_uType),
	key(is_uOrder)
)engine=MEMORY;


alter table tbl_user_Last_login_logout_time rename tbl_user_last_login_logout_time;







