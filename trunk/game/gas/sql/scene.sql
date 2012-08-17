
################################################################
#		����
################################################################

#	Scene	��Ϣ ���ܣ���ʱֻ��ÿ��	CoreScene	��¼һ�� uint64	��Ϊ������Ϣ
create table tbl_scene			#table of all scenes including dungeons 
(
	 sc_uId			bigint	unsigned	not	null	auto_increment,	 	#scene idenfier
	 sc_sSceneName		varchar(96) 		not	null,		#scene name
	 sc_uServerId		tinyint unsigned	not	null, 		#server that scene belongs to
	 sc_dtCreationDateTime	datetime		not	null,		#create time
	 sc_dtLastActiveDateTime	datetime	not	null,		
	 sc_uProcess		bigint		unsigned default 0,		
	 sc_uType		tinyint unsigned not null, 			#scene type
	 primary key(	sc_uId ),
	 key(sc_sSceneName),
	 key(sc_uProcess),
	 key(sc_uType)
)engine=innodb;

create table tbl_scene_distribute
(
	sc_sSceneName  varchar(96) 		not	null,		#scene name
	sc_uServerId	tinyint unsigned	not	null,
	primary key(sc_sSceneName)
)engine=innodb;


#�����������
create table tbl_scene_arg		#scene extro info
(
	 sc_uId		bigint	unsigned 	not	null	auto_increment,
	 sa_sArgName	varchar(16) 		not	null, #������
	 sa_sArgValue	varchar(96),			#�ַ�������ֵ 		sa_nArgValue �� sa_sArgValue ֻ��һ������
	 sa_nArgValue	int,				#���ֱ���ֵ		sa_nArgValue �� sa_sArgValue ֻ��һ������
	 primary key(	sc_uId,  sa_sArgName),
	 foreign	key(sc_uId)	references tbl_scene(sc_uId) on	update cascade on delete cascade
)engine=innodb;



# 1   ����   2 ��ʥ��͢  3 ��˹   yy

#	��ʼ�� tbl_scene ��, ע��	MetaScene	���Ҫ�� Scene_Common ���һ��
#insert into
#	tbl_scene( sc_sSceneName, sc_dtCreationDateTime, sc_dtLastActiveDateTime , sc_uProcess )
#values
#	(	'����ֵ�',	now(),	now(),	0	),
#	(	'�����ƽԭ',	now(),	now(),	0	),
#	(   '���Ͽ�',   now(),  now(),  0 ),
#	(	'����1',	now(),	now(),	0	),
#	(	'����2',	now(),	now(),	0	),
#	(	'����3',	now(),	now(),	0	),
#	(	'����4',	now(),	now(),	0	);
