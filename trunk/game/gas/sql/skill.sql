
################################################################
#		����
################################################################
create table tbl_fight_skill
(
	cs_uId 			bigint unsigned 		not null,					#��ҽ�ɫID
	fs_sName		varchar(96)			not null,				#������
	fs_uLevel 	tinyint unsigned		not null default 0,			#���ܵȼ�
	fs_uKind		tinyint unsigned		not null default 0, 		#��ͨ����or�츳����
	primary	key( cs_uId, fs_sName,fs_uKind),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

##���������׶�
create table tbl_skill_layer
(
	cs_uId 			bigint unsigned 		not null,							#��ҽ�ɫID
	fs_sName		varchar(96)					not null,							#������
	sl_uLayer		tinyint							not null,							#���������׶�
	primary	key( cs_uId, fs_sName,sl_uLayer),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

##����ϵ
create table tbl_skill_Series
(
	cs_uId 			bigint 	unsigned 				not null,						#��ҽ�ɫID
	ss_uSeries  tinyint	unsigned				not null,						#����ϵ
	primary	key( cs_uId),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

##ÿ���Ӧ�Ľڵ�
create table tbl_skill_node
(
	cs_uId 			bigint 	unsigned 				not null,						#��ҽ�ɫID
	sn_uNode		tinyint	unsigned				not null,						#�ڵ�
	primary	key( cs_uId,sn_uNode),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

create table tbl_cool_down
(
	cs_uId 					bigint unsigned 		not null,
	cd_sName					varchar(96)			not null,		#������
	cd_dCoolDownLeftTime		bigint				not null,		#���ܿ�ʼ��ȴʱ��,��ʩ��ʱ��
	cd_dCoolDownSaveTime		datetime				not null,		#������ȴ����ʱ��
	cd_bSwitchEquipSkill		tinyint			not null,	#�Ƿ�Ϊװ�����ܵ��л�CD
	primary key(cs_uId,cd_sName),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

create table tbl_aure_magic
(
	cs_uId 				bigint unsigned 	not null,
	am_sAureMagicName	char(96)			not null,
	am_uSkillLevel			bigint unsigned		not null,
	am_uSkillName			char(96)			not null,
	am_uAttrackType		bigint unsigned		not null,
	
	primary key(cs_uId,am_sAureMagicName),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

create table tbl_char_magicstate
(
	cs_uId				bigint unsigned		not null,
	cms_uMagicName		char(192)			not null,
	cms_uMagicType		tinyint 	  unsigned	not null, 	#1,2,3,4 4��ħ��״̬
	cms_uMagicTime		bigint			not null,
	cms_uMagicRemainTime	bigint	  		not null,
	cms_uCount			bigint	  		not null,
	cms_uProbability		float				not null,
	cms_uMagicStoreObjID1	bigint	  unsigned,			#ħ��Ч��
	cms_uMagicStoreObjID2	bigint	  unsigned,
	cms_uMagicStoreObjID3	bigint	  unsigned,
	cms_uSkillLevel			bigint unsigned		not null,
	cms_uSkillName		char(192)			not null,
	cms_uAttrackType		bigint unsigned		not null,
	cms_bIsDot			tinyint(1)			not null,
	cms_bFromEqualsOwner	tinyint(1)			not null,
	cms_uServantName		char(192),
	cso_uServantID 	  tinyint unsigned	not null default 0,
	
	key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
	
)engine=innodb;

create table tbl_char_magic_obj
(
	cs_uId				bigint unsigned		not null,
	cmo_uMagicStoreObjID	bigint	unsigned		not null,
	cmo_uMagicCountID		bigint 	unsigned		not null,
	cmo_uMagicOperaterID	bigint	unsigned		not null,
	cmo_uData1			bigint				not null,
	cmo_uData2			bigint	unsigned		not null,
	cmo_uServantName		char(192),
	cso_uServantID 	  tinyint unsigned	not null default 0,
	
	key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_char_servant_name
(
	cs_uId					bigint 		unsigned	not null,
	csn_sServantResName		varchar(96)	not null,		#�ٻ�����Դ��
	csn_sServantRealName		varchar(96) collate utf8_unicode_ci not null,		#�ٻ������� -- ��Ҷ����
	primary	key( cs_uId, csn_sServantResName),
	foreign 	key(cs_uId) 	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

create table tbl_char_servant
(
	cs_uId					bigint 			unsigned	not null,
	cso_sServantResName		varchar(96)		not null,
	cso_uServantLevel			tinyint	unsigned			not null,
	cso_uServantAIType		tinyint	unsigned			not null,
	cso_uServantType			tinyint(1)			not null,
	cso_uCurHP				int	unsigned		not	null,
	cso_uCurMP				int	unsigned		not	null,
	cso_uLeftTime			bigint unsigned		not null,
	cso_uServantID 	  tinyint unsigned	not null default 0,
	
	key(cs_uId),
	foreign 	key(cs_uId) 	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;