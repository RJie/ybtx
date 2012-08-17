alter table tbl_channel_id drop primary key;
alter table tbl_channel_id change ci_uId ci_nId bigint not null, add primary key (ci_nId);




alter table tbl_novice_direct add primary key (cs_uId, nd_sFirstTime);

##Ӷ���Ž���С��ħ��������Ӫȡ��
update tbl_building_tong set bt_sBuildName = "����С�ͷ�����ʩ" where bt_sBuildName = "С�ͷ�����ʩ"
   	and t_uId in(select t_uId from tbl_tong where t_uCamp = 1);
update tbl_building_tong set bt_sBuildName = "��ʥС�ͷ�����ʩ" where bt_sBuildName = "С�ͷ�����ʩ"
   	and t_uId in(select t_uId from tbl_tong where t_uCamp = 2);
update tbl_building_tong set bt_sBuildName = "��˹С�ͷ�����ʩ" where bt_sBuildName = "С�ͷ�����ʩ"
   	and t_uId in(select t_uId from tbl_tong where t_uCamp = 3);

#ʵʱ��������ͳ�Ʊ�
create table `ONLINE_STAT`(     
  `server_id` tinyint NOT NULL,  #���ڴ洢�߱�ʶ����д1��ʼ����Ȼ��
  `online_number` int NOT NULL DEFAULT '0',  #���ڴ洢server_id ����ʶ�ߵ�ǰ����������
  `update_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',  #���ڼ�¼���ݸ���ʱ�䣨������Ӧ����ͬһ��ʱ�����£�
  PRIMARY KEY (`server_id`)  
)DEFAULT CHARSET=utf8;


##ɾ������ӳ��������,���bug
alter table tbl_keymap drop foreign key tbl_keymap_ibfk_1;
alter table tbl_keymap drop primary key;
alter table tbl_keymap add foreign key(cs_uId) REFERENCES
tbl_char_static(cs_uId) ON DELETE CASCADE ON UPDATE CASCADE;


alter table tbl_char_appellationList modify ca_uAppellation int unsigned not null;
alter table tbl_char_pet modify cp_sPetName varchar(96) collate utf8_unicode_ci;
alter table tbl_pet_skill modify ps_sSkillName varchar(96) not  null;
alter table tbl_pet_skill modify ps_uIndex	tinyint unsigned not  null;
alter table tbl_merc_educate_card add primary key(cs_uId, mec_uCardId);
alter table tbl_char_magicstate add key(cs_uId);
alter table tbl_char_magic_obj add key(cs_uId);
alter table tbl_char_servant_outline add key(cs_uId);
alter table tbl_liveskill_log add key(cs_uId);
alter table tbl_flower add key(cs_uId);

#user_log
create table tbl_user_log_code	
(
	ulc_uErrorCode			bigint unsigned not null,	#user_log code
	primary key(ulc_uErrorCode)
)engine=innodb;

alter table tbl_tong_tech_order add column tto_dtUpdateTime DateTime  not null;


##ɾ��״̬��û�õ�����
alter table tbl_char_magicstate drop column cms_bIsEffective;
alter table tbl_char_magic_obj drop column cmo_bIsEffective;

###�з���ʱ�򣬽�����۳����̵����Ʒ�����������ݿ��
create table tbl_npcshop_player_sell_item(      #record item which player sold to npcshop when change server 
    cs_uId                  bigint unsigned not null,       #role
    npsi_nShopType          tinyint unsigned not null,      #pay type in shop like money or jifen type
    npsi_nId                bigint unsigned not null auto_increment,       #id point to one pack of item's id
    npsi_sItemType          varchar(36)      not null,      #item type
    npsi_sItemName          varchar(36)      not null,      #item name
    npsi_nItemCount         tinyint unsigned not null, #count of a pack of item
    npsi_nBindingType       tinyint unsigned    not null,

    key(cs_uId),
    key(npsi_nId)
)engine = innodb;


#�۳����̵�Ķѵ���Ʒid
create table tbl_player_sell_item_id(
    psii_nId bigint unsigned not null,
    psii_nItemId    bigint unsigned not null,
    key(psii_nItemId),
    key(psii_nId),
    foreign key (psii_nId)	references tbl_npcshop_player_sell_item(npsi_nId) on update cascade on delete cascade
)engine = innodb;

#������μ���ʷ�ܴ����ͳɹ������������
create table tbl_activity_history_count
(
	cs_uId bigint unsigned not null,
	ac_sActivityName varchar(32) not null,
	ac_HistoryTimes bigint unsigned not null default 0,
	ac_SuccessfullTimes bigint unsigned not null default 0,  # �ɹ�����
	foreign	key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;

create table tbl_mercenary_level(
	cs_uId bigint unsigned not null,
	ml_uStatus tinyint unsigned not null default 1,
	ml_sSubject1 varchar(32) not null default "",
	ml_sSubject2 varchar(32) not null default "",
	ml_sSubject3 varchar(32) not null default "",
	ml_uCount1 tinyint unsigned not null default 0,
	ml_uCount2 tinyint unsigned not null default 0,
	ml_uCount3 tinyint unsigned not null default 0,
	ml_uCallenge tinyint unsigned not null default 0,
	primary key (cs_uId),
	foreign key (cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=Innodb;

create table tbl_mercenary_level_award(
	cs_uId bigint unsigned not null,
	mla_sAward varchar(96) not null default "", ##�������ȡ��Ӷ����Ȩ
	primary key (cs_uId, mla_sAward),
	foreign key (cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=Innodb;

create table tbl_finish_npc_talk(
	cs_uId bigint unsigned not null,
	fnt_sTalkName varchar(96) not null default "", ##�������ɵĽ����Ի�
	primary key (cs_uId, fnt_sTalkName),
	foreign key (cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=Innodb;

alter table tbl_log_money add column lcs_uId	bigint unsigned	not	null after le_uId;
alter table tbl_log_money add key(lcs_uId);
alter table tbl_log_experience add column lcs_uId	bigint unsigned	not	null after le_uId;
alter table tbl_log_experience add key(lcs_uId);
alter table tbl_log_soul add column lcs_uId	bigint unsigned	not	null after le_uId;
alter table tbl_log_soul add key(lcs_uId);
alter table tbl_log_jifenpoint add column lcs_uId	bigint unsigned	not	null after le_uId;
alter table tbl_log_jifenpoint add key(lcs_uId);


################################################################
#�����̳�
################################################################
create table tbl_toolsmall_item_buyer
(	
	tib_uID				bigint unsigned not null auto_increment,	#order id
	cs_uBuyerID			bigint unsigned not null,	#buyer id
	is_uId					bigint unsigned		not null,#item_id
	ib_dtBuyTime		datetime 		not null,				#buy time
	primary key(tib_uID),
	unique key(is_uId),
	key(cs_uBuyerID),
	key(ib_dtBuyTime),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade,
	foreign	key(cs_uBuyerID)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_toolsmall_item_geter
(
	tib_uID				bigint unsigned not null,	#order id
	cs_uGeterID			bigint unsigned not null,	#buyer id
	primary key(tib_uID),
	foreign	key(tib_uID)	references tbl_toolsmall_item_buyer(tib_uID) on	update cascade on delete cascade
)engine=innodb;

alter table tbl_group_manager add column gm_uRefuseMsgFlag tinyint unsigned not null default 0;

------------------------------------------------------------------------------------

create table tbl_market_cfg_info(
    	mci_uType			tinyint unsigned		not null,	#��Ʒ����
	mci_sName			varchar(96)			not null,	#��Ʒ����
	mci_uAttrIndex                  tinyint unsigned                not null,       #���Զ�Ӧ��index
	mci_uAdvanceSoulRoot            tinyint unsigned,               #���׻���������ͣ�
    	mci_uMaxAdvancePhase            tinyint unsigned,	        #���ɽ��׽׶�1.������ 2.�������� 3.�������� 4.��������        
	mci_uIntenSoulRoot              tinyint unsigned,               #ǿ������������ͣ�1��ʾս��(��ʾΪ������)��2��ʾ��ħ(��������)
	mci_uMaxIntenPhase              tinyint unsigned,               #����ǿ���׶�
        mci_uCamp                       tinyint unsigned,                    #������Ӫ 

        primary key(mci_uType, mci_sName)
)ENGINE = MEMORY;

alter table tbl_market_sell_order drop column mso_uSoulRoot;
alter table tbl_market_sell_order add column  mso_uQuality tinyint unsigned    default 0;
alter table tbl_market_sell_order add key(mso_uQuality );

alter table tbl_market_sell_order change mso_sSuitName mso_sSuitName
varchar(120) binary collate utf8_unicode_ci      default "";
update tbl_market_sell_order set mso_sSuitName = "" where mso_sSuitName is null;


#��¼��ǰ�汾��
create table tbl_server_version(
    sv_uVersion int not null default 0,
    PRIMARY KEY (sv_uVersion) 
)engine = innodb;

alter table tbl_market_sell_order change mso_sItemName mso_sItemName varchar(96) not null;
alter table tbl_market_sell_order add column mso_sItemDisplayName varchar(96)    binary collate utf8_unicode_ci not null after mso_uQuality;

alter table tbl_sort_create_time add column sct_uId tinyint unsigned	not null first;
alter table tbl_sort_create_time add primary key (sct_uId);

create table tbl_log_player_logout_position 
(    
	le_uId bigint unsigned not null,    
  lcs_uId bigint unsigned not null, 
  lplp_sSceneName	varchar(96) not	null,		#scene name 
  lplp_sArgNameName varchar(16) not	null, 
  lplp_uPosX	float	unsigned	not	null default 1,
	lplp_uPosY	float	unsigned	not	null default 1,
	
	key(le_uId), 
  key(lcs_uId),
  key(lplp_sSceneName),
  key(lplp_sArgNameName)
)engine = innodb; 

create table tbl_log_channel_chat
(
		lcs_uId	bigint unsigned	not	null,
		lcc_sMsg	text not null,
		lcc_dtChatTime datetime	not null,
		lcc_sChannelName varchar(96) not null,
		lcc_uServerId tinyint	unsigned	not	null, 
		
		key(lcs_uId)
)engine = innodb;
