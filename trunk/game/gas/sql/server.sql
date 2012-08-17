

################################################################
#		����������
################################################################
#global variables for game server 
create table tbl_var_server
(
	sv_sVarName		varchar(48)	not	null,		#variable's name
	sv_sVarValue	text	not	null,					#variable's value
	sv_dtDate		timestamp not null,				#last update time
	sv_uServerId	tinyint unsigned,				#server id,
	primary	key(sv_sVarName, sv_uServerId)
)engine=innodb;


###############################################################
#                ������������
###############################################################
#global configuration variables
create table tbl_conf_server
(
	sc_sVarName	varchar(32) not null,		#variable's name
	sc_sVarValue 	varchar(128) not null,#variable's value
	key(sc_sVarName)
)engine=innodb;
#)engine=memory;

#ʵʱ��������ͳ�Ʊ�
#table of online number
create table `ONLINE_STAT`
(     
  `server_id` tinyint NOT NULL,  #serverid
  `online_number` int NOT NULL DEFAULT '0',  #online numbers
  `update_time` datetime NOT NULL, #update time
  PRIMARY KEY (`server_id`)  
)engine = memory;

#��¼��ǰ�汾��
create table tbl_server_version
(
    sv_uVersion int not null default 0,
    PRIMARY KEY (sv_uVersion) 
)engine = innodb;

#����������������¼���ݿ�����Ƿ�ɹ���ֵΪsql�ļ���
create table tbl_database_upgrade_record
(
		dur_sRecord varchar(64) not null,
		dur_dtTime datetime not null
)engine = innodb;
