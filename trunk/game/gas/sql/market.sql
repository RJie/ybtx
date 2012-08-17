
#################################################################################
#                                                                               #
#                           ==**tables of market**==                                  #
#                                                                               #
#################################################################################

#####  order
create table tbl_market_order_static(			#market order static info
	mos_uId			bigint unsigned		not null 	auto_increment,		#order identifier
	mos_tCreateTime		datetime 		not null,				#create time
	primary key(mos_uId)
)engine=innodb;


#####  item referred by order
create table tbl_item_market(				#items that order refers
	is_uId			bigint unsigned		not null,				#item identifier
	mos_uId			bigint unsigned		not null,				#order identifier
	primary key (is_uId),
	foreign key (is_uId) 	references tbl_item_static(is_uId) on 	update cascade on delete cascade,
	foreign key (mos_uId)	references tbl_market_order_static(mos_uId) on  update cascade on delete cascade
)engine=innodb;


#####  acquisition orders
create table tbl_market_buy_order(			#acquisition orders
	mos_uId				bigint unsigned		not null,		# order identifier
	cs_uId				bigint unsigned		not null,		# role referred by order
	mbo_sItemName		varchar(96)			not null,		# acquired item name
	mbo_uCount			bigint unsigned		not null,		# acquired item number
	mbo_uPrice			bigint unsigned		not null,		# item price
	mbo_tEndTime		datetime 			not null,		# end time
	primary key (mos_uId),
	key (mbo_sItemName),
	key (mbo_tEndTime), 
	foreign key (mos_uId)	references tbl_market_order_static(mos_uId) on 	update cascade on delete cascade,
	foreign key (cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

#####  ���۲���
create table tbl_market_sell_order(
	mos_uId				bigint unsigned		not null,		#����ID
	cs_uId				bigint unsigned		not null,		#��ɫID
	mso_sItemType		varchar(36)	        not null,		#������Ʒ���
	mso_sItemName		varchar(96)	 not null,		#������Ʒ����
	mso_uCount			bigint	unsigned	not null,		#������Ʒ��Ŀ
	mso_uPrice			bigint	unsigned	not null,		#���ۼ�
	mso_tEndTime		datetime 			not null,		#������ֹʱ��
	mso_uCanUseLevel	bigint	unsigned			not null,		#��Ʒ��ʹ�õȼ�
	mso_sSuitName		varchar(120) binary collate utf8_unicode_ci	 default "",	#��װ����
    mso_uQuality       tinyint unsigned    default 0,    #װ���Ļ�����ԣ�������ƷΪ0����ħΪ1��ս��Ϊ2
    mso_sItemDisplayName varchar(96)	binary collate utf8_unicode_ci		not null,		#������Ʒ��ʾ����
	primary key (mos_uId),
	key (mso_sItemName),
	key (mso_tEndTime),
	key (mso_uCanUseLevel),
	key(mso_uQuality),
	foreign key (mos_uId)	references tbl_market_order_static(mos_uId) on 	update cascade on delete cascade,
	foreign key (cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

#### ��¼������Ʒ�ļ۸�
create table tbl_market_sell_price(			#record item sold price
	cs_uId					bigint unsigned not null,		#role
	msp_sItemType			varchar(36)		not null,		#item type
	msp_sItemName			varchar(96)		not null,		#item name
	msp_uPrice				bigint unsigned		not null,	#sold price
	
	key(cs_uId,msp_sItemType,msp_sItemName),
	foreign key (cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

#### ��¼�չ���Ʒ�ļ۸�
create table tbl_market_buy_price(			#record item acquired price
	cs_uId					bigint unsigned not null,		#role
	mbp_sItemType			varchar(36)		not null,		#item type
	mbp_sItemName			varchar(96)		not null,		#item name
	mbp_uPrice				bigint unsigned		not null,	#acquired price
	
	key(cs_uId,mbp_sItemType,mbp_sItemName),
	foreign key (cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;


###�з���ʱ�򣬽�����۳����̵����Ʒ�����������ݿ��
create table tbl_npcshop_player_sell_item(      #record item which player sold to npcshop when change server 
    cs_uId                  bigint unsigned not null,       #role
    npsi_nShopType          tinyint unsigned not null,      #pay type in shop like money or jifen type
    npsi_nId                bigint unsigned not null auto_increment,       #id point to one pack of item's id
    npsi_sItemType          tinyint unsigned not null,      #item type
    npsi_sItemName          varchar(36)      not null,      #item name
    npsi_nItemCount         tinyint unsigned not null, #count of a pack of item
    npsi_nBindingType       tinyint unsigned    not null,

    key(cs_uId),
    key(npsi_nId),
    foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine = innodb;

#�۳����̵�Ķѵ���Ʒid
create table tbl_player_sell_item_id(
    psii_nId bigint unsigned not null,
    psii_nItemId    bigint unsigned not null,
    unique key(psii_nItemId),
    key(psii_nId),
    foreign key (psii_nId)	references tbl_npcshop_player_sell_item(npsi_nId) on update cascade on delete cascade,
    foreign	key(psii_nItemId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine = innodb;

create table tbl_market_cfg_info(
    mci_uType						tinyint unsigned				    not	null,		#��Ʒ����
	mci_sName						varchar(96)							not	null,		#��Ʒ����
	mci_uAttrIndex                  tinyint unsigned                    not null,       #���Զ�Ӧ��index
    mci_uCamp                       tinyint unsigned,                    #������Ӫ 

    primary key(mci_uType, mci_sName)
)ENGINE = MEMORY;

create table tbl_market_purchasing_cfg_info(
    mpci_sName						varchar(96)							not	null,		#��Ʒ����
    mpci_uType						tinyint unsigned				    not	null,		#��Ʒ����
	mpci_uChildType			tinyint unsigned				    default 0,
	mpci_uCanUseLevel	bigint	unsigned		not null,		#��Ʒ��ʹ�õȼ�
    mpci_uQuality       tinyint unsigned    default 0,
 	mpci_sItemDisplayName varchar(96)	binary collate utf8_unicode_ci		not null,		#��Ʒ��ʾ����
    key(mpci_uType),
	key(mpci_uChildType),
	key(mpci_uCanUseLevel),
	key(mpci_uQuality),
	key(mpci_sItemDisplayName),
    primary key(mpci_sName)
)ENGINE = MEMORY;

create table tbl_npcshop_buy_tip(
	cs_uId			bigint(20) 	unsigned not null,
	nbt_LiuTongShopBuyTip	tinyint 	unsigned default 1, #Ĭ����ʾ��0Ϊ����ʾ	
	nbt_CommonShopBuyTip	tinyint 	unsigned default 1, #Ĭ����ʾ��0Ϊ����ʾ	

	primary key (cs_uId),
	foreign key (cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;


#���������õ�װ�����׻����ǿ��������ɽ������ޡ���ǿ�����ޣ����������ݿ������Ҫ��
create table tbl_market_equip_info(
	mos_uId			bigint 	unsigned	not null,
	mei_uIntenQuality	tinyint		unsigned	not null,
	mei_uAdvanceQuality	tinyint 	unsigned	not null,
	mei_sIntenSoul		varchar(12)	not null,
	mei_sAdvanceSoul	varchar(12)	not null,

	key(mos_uId),
	foreign key(mos_uId)	references tbl_market_sell_order(mos_uId) 	on update cascade on delete cascade
)engine = innodb;


#####  order
create table tbl_contract_manufacture_order_static(			
	cmo_uId			    bigint unsigned		not null 	auto_increment,		#order identifier
	cmo_tCreateTime		datetime 		    not null,				#create time
	primary key(cmo_uId)
)engine=innodb;

#����ܴ���������
create table tbl_contract_manufacture_order(
    cmo_uId             bigint      unsigned    not null,
    cs_uId              bigint      unsigned    not null,
    cmo_sSkillName      varchar(96)             not null,
    cmo_sDirection      varchar(96)             not null,
    cmo_sPrescripName   varchar(96)             not null,
    cmo_tEndTime        datetime 			    not null,		# end time
    cmo_uCMMoney        bigint      unsigned    not null,
    cmo_sDisplayProductName varchar(96)         not null,

    
    primary key(cmo_uId),
    foreign key (cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade,
    foreign key (cmo_uId) references tbl_contract_manufacture_order_static(cmo_uId) on update cascade on delete cascade
)engine = innodb;

#����ܴ����������������Ҫ�Ĳ�����Ϣ
create table tbl_contract_manufacture_order_item(
    cmo_uId             bigint      unsigned    not null auto_increment,
    is_uId              bigint      unsigned    not null,
    
    primary key (is_uId),
    foreign key (is_uId) references tbl_item_static(is_uId) on update cascade on delete cascade,
    foreign key (cmo_uId) references tbl_contract_manufacture_order(cmo_uId) on update cascade on delete cascade

)engine = innodb;


#��ѯ����ܴ��������õ����ñ�����Ϣ������ܵȼ���������Ʒ�ȼ�
create table tbl_contract_manufacture_cfg_info(
	cmci_sSkillName      varchar(96)             not null,
    cmci_sDirection      varchar(96)             not null,
    cmci_sPrescripName    varchar(96)            not null,
	cmci_uSkillLevel     tinyint	unsigned     not null,
	cmci_uProductLevel   tinyint	unsigned     not null,

	key(cmci_sSkillName),
	key(cmci_sDirection),
	key(cmci_sPrescripName)
)engine = memory;

#��ȯ������Ϣ��
create table tbl_coupons_info(
    ci_uId          bigint  unsigned		not null,
    ci_sName        varchar(96)  collate utf8_unicode_ci           not null,
    ci_uSmallIcon   int     unsigned        not null,
    ci_uPrice       int(10) unsigned        not null,
    ci_sDesc        varchar(1024)           collate utf8_unicode_ci       not null,
    ci_sUrl         varchar(1024)           collate utf8_unicode_ci        not null,
    primary key (ci_uId)
)engine = innodb;

create table tbl_char_bought_coupons(
    cbc_uId     bigint unsigned		not null 	auto_increment,  
    cs_uId      bigint unsigned     not null,
    ci_uId      bigint unsigned     not null,
    cbc_sSequenceId varchar(96)     not null, 
    
    primary key (cbc_uId),
    key(cs_uId, ci_uId),
    foreign key (cs_uId)  references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;