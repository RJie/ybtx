create table tbl_log_market_item(
	le_uId		bigint unsigned	not	null,
	mos_uId		bigint unsigned	not null,#����ID
	le_uServerId int unsigned 			not null,
	
	key(le_uId,le_uServerId),
	key(mos_uId)
)engine=innodb;


#����ܴ���������
create table tbl_log_contract_manufacture_order_static(
	le_uId		bigint unsigned	not	null,
  lcmo_uId             bigint      unsigned    not null,
  lcmo_sSkillName      varchar(96)             not null,
  lcmo_sDirection      varchar(96)             not null,
  lcmo_sPrescripName   varchar(96)             not null,
  lcmo_uCMMoney        bigint      unsigned    not null,
	le_uServerId int unsigned 			not null,
  
  key(le_uId,le_uServerId),
  key(lcmo_uId)
)engine = innodb;


create table tbl_log_contract_manufacture_order(
	le_uId		bigint unsigned	not	null,
  lcmo_uId             bigint      unsigned    not null,
	le_uServerId int unsigned 			not null,
  
  key(le_uId,le_uServerId),
  key(lcmo_uId)
)engine = innodb;


#���ս��������
create table tbl_log_char_fighting_evaluation
(
	le_uId bigint unsigned not null,
	lcs_uId			bigint unsigned		not	null,
	lcfe_uPoint	float unsigned not null,
	le_uServerId int unsigned not null,
	
	key(le_uId,le_uServerId),
	key(lcs_uId)
)engine = innodb;