##########################��������Դ��״̬���
create table tbl_tong_rob_state(
	trs_sState  varchar(96)	  not null,	
	primary	key(trs_sState)
)engine=innodb;


##########################��������Դ�㳡�����
create table tbl_tong_rob_scene(
	trse_sObjName  varchar(96)  not null,	
	trse_uSceneId  bigint  not null,
	trse_uServerId  bigint  not null,	
	primary	key(trse_sObjName, trse_uSceneId)
)engine=innodb;
