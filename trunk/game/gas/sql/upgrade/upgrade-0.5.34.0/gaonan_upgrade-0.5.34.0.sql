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