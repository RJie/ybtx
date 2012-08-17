
#������log��
create table tbl_log_xiuxingta
(
 le_uId			bigint unsigned 	not null,
 lx_uGateId		int unsigned 		not null,
 lx_uSceneId bigint	unsigned	not	null,
 lx_uSucceedFlag tinyint unsigned 	not null,
 lx_uSpendTimes bigint unsigned 		not null,
 le_uServerId int unsigned 		not null, 
	
 key(le_uId),
 key(lx_uSceneId),
 key(lx_uSucceedFlag),
 key(le_uServerId)
)engine=myisam;

alter table tbl_log_compose_info drop column lc_uItemId;

create table tbl_log_item_binding    	#binding info of a item
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint 	unsigned	not	null,		#item identifier
	lib_uBindType	tinyint	unsigned	default 0, 		#item binding type
									#	0 stands for unbindinged
									#	1 stands for would be bindinged when be used
									#	2 stands for bindinged
	le_uServerId int unsigned 			not null,								
	key(le_uId),
	key(lis_uId),
	key(lib_uBindType),
	key(le_uServerId)
)engine=myisam;


#װ���;�
create table tbl_log_item_equip_durability
(
	le_uId			bigint unsigned 	not null,
  lis_uId          bigint unsigned not null,	#��ƷID
  lied_uMaxDuraValue float unsigned,          #�;�����ֵ
  lied_uCurDuraValue float unsigned,         #��ǰ�;�ֵ
  le_uServerId int unsigned 			not null,
   
  key (le_uId),
  key (lis_uId),
  key (le_uServerId)
)engine = myisam;