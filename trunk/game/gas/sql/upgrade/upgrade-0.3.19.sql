drop table tbl_technology_tong;
create table tbl_tong_tech_static
( 
	tts_uId           	bigint unsigned     	not null auto_increment,  	#�Ƽ�id
	t_uId		 						bigint unsigned     	not null,										#���id
  tts_sName         	varchar(96)         	not null ,                 	#�Ƽ�����
  tts_uType         	tinyint unsigned      not null,                  	#���ͣ������Ƽ�����Ʒ�Ƽ���ս���Ƽ�
  tts_uLevel        	tinyint unsigned      not null,      							#��ǰ�ȼ�
	primary key(tts_uId),
	unique key(t_uId,tts_sName,tts_uType),
  foreign	key(t_uId)	        references tbl_tong(t_uId) 	on	update cascade on	delete cascade
)engine=innodb;

##�Ƽ��з��ȴ�����
create table tbl_tong_tech_order
(       
  tts_uId         	bigint unsigned       not null,                 	#�Ƽ�id
  tto_dtStartTime   DateTime            	not null,       						#��ʼʱ��
  tto_uState        tinyint unsigned      not null,      							#״̬
  primary key(tts_uId),
  foreign	key(tts_uId)	        references tbl_tong_tech_static(tts_uId) 	on	update cascade on	delete cascade
)engine=innodb;

##���޵���Ϣ��
create table tbl_pet_egg
(        
	cs_uId	bigint unsigned	not  null,				#��ɫid
	pe_uIncubateTimes tinyint unsigned  not null,	#�Ѿ������Ĵ���
	pe_sEggName varchar(96)	not	null,				#���޵�����
  pe_uAptitudeValue int not null,					#����
	pe_uTotalIncubateTimes tinyint unsigned not null,#��Ҫ�����Ĵ���
  pe_dtIncubateDate datetime,						#������ʱ��
    
	primary	key(cs_uId),
  foreign	key (cs_uId) references tbl_char_static(cs_uId) on	update cascade
)engine=innodb;

##���޾�̬��
create table tbl_pet_static
(        
	ps_uId	bigint unsigned	not  null auto_increment,	#����id
	ps_sPetName varchar(96)	not	null,					#��������(���ñ����������)
  ps_uAptitudeValue int unsigned not null,			#��������
  ps_sPetType varchar(96)	not	null,					#���޹�������
    
	primary	key(ps_uId)
)engine=innodb;

##������Ϣ��
create table tbl_char_pet
(   
	cs_uId	bigint unsigned	not  null,				#��ɫid
	ps_uId	bigint unsigned	not  null,				#����id
	cp_sPetName varchar(96),						#��������(�����������������)
  cp_uPetLevel tinyint unsigned not null,			#���޵ȼ�
  cp_dtHoldTime datetime not null,				#���ʱ��
  cp_uHealthPoint int unsigned not null,			#����ֵ
  cp_uDamageValue int unsigned not null,			#����ֵ
  cp_uExpValue	int unsigned not null,			#���޾���
  cp_uVimValue int unsigned not null,				#����ֵ
    
    
	primary	key(ps_uId),
	foreign	key (cs_uId) references tbl_char_static(cs_uId) on	update cascade,
	foreign	key (ps_uId) references tbl_pet_static(ps_uId) on	update cascade on delete cascade
)engine=innodb;

##���޼��ܱ�
create table tbl_pet_skill
(   
	cs_uId 			bigint unsigned not null,	#��ҽ�ɫID
	ps_uId	bigint unsigned	not  null,		#����id
	ps_sSkillName varchar(96),						#����ѧ��ļ�������
  ps_uIndex	tinyint unsigned, 		#���ܸ���λ��
    
	primary	key(cs_uId,ps_uId,ps_sSkillName,ps_uIndex),
	foreign	key (cs_uId) references tbl_char_static(cs_uId) on	update cascade,
	foreign	key (ps_uId) references tbl_pet_static(ps_uId) on update cascade on delete cascade
)engine=innodb;

##׼��״̬�µĻ���
create table tbl_pet_prepare
(   
	cs_uId 			bigint unsigned not null,	#��ҽ�ɫID
	ps_uId	bigint unsigned	not  null,		#����id
    
	primary	key(cs_uId),
	foreign	key (cs_uId) references tbl_char_static(cs_uId) on	update cascade,
	foreign	key (ps_uId) references tbl_pet_static(ps_uId) on update cascade on delete cascade
)engine=innodb;

alter table tbl_log_skill add column ls_uIsNonSkill tinyint unsigned not null;

##��Ʒ����С�ࡢ�ȼ�����˳���
create table tbl_item_smalltype_order
(
	is_uType						tinyint unsigned				not	null,		#��Ʒ����
	is_sName						varchar(96)							not	null,		#��Ʒ����
	iso_uSmallType			tinyint unsigned				not	null,		#С������
	iso_uBaseLevel			smallint unsigned				not	null,		#�ȼ�
	unique key(is_uType,is_sName)
)engine=MEMORY;


