#��������ҳɼ���¼����ɱ�˴���������������������Ϣ���鿴
alter table tbl_char_jifensaipoint add cj_uKillNum		bigint	unsigned	not null default 0 after cj_dDate;
alter table tbl_char_jifensaipoint add cj_uDeadNum		bigint	unsigned	not null default 0 after cj_uKillNum;


alter table tbl_user_wait_queue add uwq_uContextId bigint	unsigned	not	null after uwq_uOnServerId;

#�����ٻ�������ʱ����
alter table tbl_char_servant_outline add cso_uLeftTime bigint unsigned not null after cso_uCurMP;

#���顢���Ȼظ���Ϣ��֤��
#���ڽ��ձ���������Ϣ����֤
create table tbl_revert_validate
(
	cs_uInviter		bigint unsigned	not	null,	#������
	cs_uInvitee		bigint unsigned not null, #��������
	rv_uFun				tinyint unsigned not null, #��������
	unique key(cs_uInviter,cs_uInvitee,rv_uFun),
	foreign	key(cs_uInviter)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign	key(cs_uinvitee)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;




#�޸���Һ��ѱ�ṹ
alter table tbl_player_friends drop foreign key tbl_player_friends_ibfk_3;
alter table tbl_player_friends add foreign key (fc_uId,cs_uId) references tbl_friends_class(fc_uId,cs_uId) on update cascade on delete cascade;

#���Ӽ�¼�ʺŴ���ʱ����ֶ�
alter table tbl_user_static add us_dtCreateTime	datetime not null;

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

