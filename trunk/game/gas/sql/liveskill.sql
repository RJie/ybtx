##�����
create table tbl_commerce_skill
(
	cs_uSID						bigint unsigned					not	null auto_increment,
	cs_uId 						bigint unsigned 		not null,
	cs_uSkillType			tinyint	unsigned		not null,		##�������ͣ�0��Ĭ��ѧ��ģ�1�ǿ���ѧ����֣�����1��ֻ��ѧϰһ�ֵ�
	cs_sSkillName			varchar(96)					not null,		#��������
	cs_uSkillLevel		tinyint	unsigned		not null,		#���ܵȼ�
	cs_uExperience		bigint	unsigned		not null,		#����ֵ
	primary	key(cs_uSID),
	unique key(cs_uId,cs_uSkillType,cs_sSkillName),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

##ѧ����䷽
create table tbl_skill_directions
(
	cs_uId 						bigint unsigned 		not null,
	sd_sName					varchar(96)					not null, ##ѧ����䷽
	sd_sSkillName				varchar(96)					not null,  ##��������
	sd_sDirectionType		varchar(96)					not null,  ##�䷽����
	unique key(cs_uId,sd_sSkillName,sd_sDirectionType,sd_sName),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

create table tbl_directions_cool_time
(
	cs_uId 						bigint unsigned 		not null,
	sd_sName					varchar(96)					not null, ##ѧ����䷽
	sd_sSkillName				varchar(96)					not null,  ##��������
	sd_sDirectionType		varchar(96)					not null,  ##�䷽����
	sd_dtStartTime			datetime not null, #��ȴ��ʼʱ��
	unique key(cs_uId,sd_sSkillName,sd_sDirectionType,sd_sName),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

##����������
create table tbl_specialize_smithing
(
	cs_uId 						bigint unsigned 		not null,
	ss_uSkillType			tinyint unsigned		not null,			#�����������͡���������׵�
	ss_uType					varchar(96)						not null,		#��������������
	ss_uSpecialize		bigint	unsigned		not null,		#�����ȴ�С
	unique key(cs_uId,ss_uType),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

##����ר��
create table tbl_expert_smithing
(
	cs_uId 						bigint unsigned 		not null,		
	es_uSkillType			tinyint unsigned		not null,			#�����������͡���������׵�
	es_uType					varchar(96)					not null,		#ר������
	es_uLevel					tinyint	unsigned		not null,		#ר���ȼ�
	unique key(cs_uId,es_uSkillType,es_uType),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

##����
create table tbl_flower
(
	cs_uId 						bigint unsigned 		not null,		#���ID
	f_sFlowerName			varchar(150)				not null,		#��������
	f_dStartTime			datetime 						not null,		#��ʼ��ֲʱ��
	f_dCoolDownTime		datetime						default null,		#���ܼ�����ȴʱ��
	f_uHealthPoint		int unsigned 				not null default 100,		#������
	f_uMaxHealth			int unsigned 				not null default 100,		#�ﵽ��߽�����
	f_uGetCount				int unsigned 				not null default 0,		#�ɲɼ����� 
	f_uLevel					int unsigned 				not null default 1,		#�ȼ�
	f_uEventId				bigint unsigned 		not null default 0,		#�¼�ID
	
	key(cs_uId),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;