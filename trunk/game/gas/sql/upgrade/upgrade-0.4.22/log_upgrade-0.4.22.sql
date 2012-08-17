#����
create table tbl_log_item_armor
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint unsigned		not null,			#��Ʒid
	lia_uBaseLevel		tinyint unsigned 	not null, 		#��ʼ�ȼ�
	lia_uCurLevel        tinyint unsigned 	not null,
	lia_uUpgradeAtrrValue1	int unsigned 	not null, 			#װ������ʱ������һ����������1~3�������ñ��е�˳��
	lia_uUpgradeAtrrValue2	int unsigned 	not null,			#װ������ʱ�����Զ�
	lia_uUpgradeAtrrValue3	int unsigned 	not null,			#װ������ʱ��������
	lia_uStaticProValue		int unsigned 	not null,       	#��̬װ������ֵ
	lia_uIntensifyQuality    tinyint unsigned    not null default 0, 	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	le_uServerId int unsigned 			not null,
	
	key (le_uId),
	key (lis_uId),
	key (le_uServerId)
)engine=myisam;

create table tbl_log_item_weapon
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint unsigned		not null,			#��Ʒid
	liw_uBaseLevel 		tinyint unsigned 	not null, 		#��ʼ�ȼ�������ʱ�޸ģ�
	liw_uCurLevel       tinyint unsigned 	not null,
	liw_uDPS			float unsigned 	not null,			#��ǰDPS������ʱ�޸ģ�	
	liw_uAttackSpeed float unsigned 	not null default 0,			#�����ٶ�
	liw_uDPSFloorRate tinyint 	not null default 0,			#��������
	liw_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	le_uServerId int unsigned 			not null,
	
	key (le_uId),
	key (lis_uId),
	key (le_uServerId)
)engine=myisam;

create table tbl_log_item_ring
(
	le_uId			bigint unsigned 	not null,
	lis_uId			bigint unsigned 	not null,		    #��ƷID
	lir_uBaseLevel		tinyint unsigned	not null, 		#��ʼ�ȼ�
	lir_uCurLevel        tinyint unsigned 	not null,
	lir_uDPS			float unsigned	not null,			    #������
	lir_uStaticProValue  float unsigned	not null,			#��̬װ������ֵ
	lir_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	le_uServerId int unsigned 			not null,
	
	key (le_uId),
	key (lis_uId),
	key (le_uServerId)
)engine=myisam;

#����
create table tbl_log_item_shield
(
	le_uId			bigint unsigned 	not null,
	lis_uId 			bigint unsigned 	not null,		#��ƷID
	lis_uBaseLevel 		tinyint unsigned 	not null, 		#��ʼ�ȼ�������ʱ�޸ģ�
	lis_uCurLevel        tinyint unsigned 	not null,
	lis_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	le_uServerId int unsigned 			not null,
	
	key (le_uId),
	key (lis_uId),
	key (le_uServerId)
)engine=myisam;

alter table tbl_log_xiuxingta add column lx_sFloorId varchar(2) not null after lx_uSpendTimes;
alter table tbl_log_xiuxingta add key(lx_sFloorId);

##װ����������
create table tbl_log_item_equip_armor (
	le_uId			bigint unsigned 	not null,
	lis_uId          bigint unsigned not null,	#��ƷID
	liea_sAttr		varchar(48) not null, #����Ƭ(����)
	liea_uAddTimes tinyint	unsigned   not null,
	liea_uIndex tinyint	unsigned   not null,
	le_uServerId int unsigned 			not null,
	
	key (le_uId),
	key (lis_uId),
	key (le_uServerId)
)engine = myisam;

##���Ʋ��������������ԡ�
create table tbl_log_item_shield_Attr
(
	le_uId			bigint unsigned 	not null,
	lis_uId 			bigint unsigned not null,	#��ƷID
	lisa_uAttrValue1	int unsigned ,				#װ������ʱ������һ����ֵ��ֵ(�Ժ������õ�)
	lisa_uAttrValue2	int unsigned ,				#װ������ʱ�����Զ���Ȼ��ֵ��ֵ(�Ժ������õ�)
	lisa_uAttrValue3	int unsigned ,				#װ������ʱ���������ƻ���ֵ��ֵ(�Ժ������õ�)
	lisa_uAttrValue4	int unsigned ,				#װ������ʱ�������İ��ڿ�ֵ��ֵ(�Ժ������õ�)
	le_uServerId int unsigned 			not null,
	
	key (le_uId),
	key (lis_uId),
	key (le_uServerId)
)engine=myisam;

alter table tbl_log_event_type add key (le_uServerId);

##װ��ǿ����Ϣ��
create table tbl_log_item_equip_intensify
(
	le_uId			bigint unsigned 	not null,
	lis_uId		bigint unsigned		not null,			#��Ʒid
	liei_uIntensifySoulNum	int unsigned		not null default 0,#ͬ�ϣ�������������ǿ���Ļ���Ŀ
	liei_uPreAddAttr1	varchar(48) not null default "" , 					#ǿ����һ�׶εĸ�������1��ǿ��ʱ�޸ģ�
	liei_uPreAddAttrValue1	int unsigned not null default 0,   			#��������1��ֵ		��ǿ��ʱ�޸ģ�
	liei_uPreAddAttr2	varchar(48) not null default "", 					#ǿ����һ�׶εĸ�������2��ǿ��ʱ�޸ģ�
	liei_uPreAddAttrValue2	int unsigned not null default 0,   			#ǿ����һ�׶εĸ�������2��ֵ��ǿ��ʱ�޸ģ�
	liei_uAddAttr1		varchar(48) not null default "" , 					#ǿ����ǰ�׶θ�������1	��ǿ��ʱ�޸ģ�
	liei_uAddAttrValue1	int unsigned not null default 0,   				#ǿ����ǰ�׶θ�������1��ֵ��ǿ��ʱ�޸ģ�
	liei_uAddAttr2		varchar(48) not null default "", 					#ǿ����ǰ�׶θ�������2	��ǿ��ʱ�޸ģ�
	liei_uAddAttrValue2	int unsigned not null default 0,   				#ǿ����ǰ�׶θ�������2��ֵ��ǿ��ʱ�޸ģ�
	liei_uIntensifyPhase	tinyint unsigned not null default 0,				#װ��ǿ�����Ľ׶Σ���ʼΪ0����1��2��3��4��
	liei_uEuqipSuitType	tinyint unsigned not null default 0,				#װ��ǿ��������װ���ͣ�0��ʾ�ޣ�1��ʾ2���ף�2��ʾ3���ף�3��ʾ4���ף�4��ʾ�����ף�5��ʾ8����
	liei_sSuitName		varchar(120) not null default "",					#��װ����
	liei_uIntensifyBackState tinyint unsigned not null default 0, 			#װ���Ƿ�ɽ���������0��ʾ����������1��ʾ����
	liei_uIntensifyTimes      smallint unsigned not null default 0, 		#��¼װ��ǿ������
	liei_uIntensifyBackTimes  smallint unsigned not null default 0, 		#��¼װ����������
	liei_uIntenTalentIndex     smallint unsigned not null default 0,        #ǿ�������׶β����Ķ����츳��������
	le_uServerId int unsigned 			not null,
	
	key(le_uId),
	key(lis_uId),
	key(le_uServerId)
)engine=myisam;

#############װ��ǿ��4~9�׶����Ա�######################
create table tbl_log_item_equip_intensifyAddAttr
(
	le_uId			bigint unsigned 	not null,
  lis_uId      bigint unsigned 	not null,		                #��ƷID
  liei_sAddAttr4       varchar(48)   not null default "",        					#ǿ��4�׶θ�������
  liei_uAddAttr4Value  int unsigned  not null default 0,          				#ǿ��4�׶θ�������ֵ
  liei_sAddAttr5       varchar(48)   not null default "",       					#ǿ��5�׶θ�������
  liei_uAddAttr5Value  int unsigned  not null default 0,          				#ǿ��5�׶θ�������ֵ
  liei_sAddAttr6       varchar(48)   not null default "",        					#ǿ��6�׶θ�������
  liei_uAddAttr6Value  int unsigned  not null default 0,          				#ǿ��6�׶θ�������ֵ
  liei_sAddAttr7       varchar(48)   not null default "",        					#ǿ��7�׶θ�������
  liei_uAddAttr7Value  int unsigned  not null default 0,          				#ǿ��7�׶θ�������ֵ
  liei_sAddAttr8       varchar(48)   not null default "",        					#ǿ��8�׶θ�������
  liei_uAddAttr8Value  int unsigned  not null default 0,          				#ǿ8�Ľ׶θ�������ֵ
  liei_sAddAttr9       varchar(48)   not null default "",        					#ǿ��9�׶θ�������
  liei_uAddAttr9Value  int unsigned  not null default 0,          				#ǿ��9�׶θ�������ֵ
  le_uServerId int unsigned 	not null,
  
  key(le_uId),
  key(lis_uId),
  key(le_uServerId)
)engine=myisam;

create table tbl_log_dataosha_point
	(
		le_uId bigint unsigned not null,
		ldp_uPoint bigint not null,
		le_uServerId int unsigned not null,
		
		key(le_uId),
		key(le_uServerId)
	)engine=myisam;
