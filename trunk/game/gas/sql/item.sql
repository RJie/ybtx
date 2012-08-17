
################################################################
#		��Ʒ
################################################################

create table tbl_item_id
(
	ii_uId	bigint unsigned	not	null auto_increment,

	primary	key(ii_uId)
)engine=innodb;

create table tbl_item_static		#item infos, 
(
	is_uId			bigint unsigned		not	null,		#item identifiyer
	is_uType		tinyint unsigned	not	null,		#item type
	is_sName		varchar(96)		not	null,		#item name

	primary	key(is_uId)
)engine=innodb;

##��Ʒ����˳��̬��
create table tbl_item_type_order	#item type ordering for sorting
(
	is_uType	tinyint unsigned		not	null,		#item type
	is_uOrder	tinyint unsigned		not	null,		#view order
	
	unique key(is_uType),
	key(is_uOrder)
)engine=MEMORY;

create table tbl_item_smalltype_order	#item subtype ordering for sorting
(
	is_uType	tinyint unsigned		not	null,		#item type
	is_sName	varchar(96)			not	null,		#item name
	iso_uSmallType	smallint unsigned		not	null,		#item sub-type
	iso_uBaseLevel	smallint unsigned		not	null,		#view order
	unique key(is_uType,is_sName)
)engine=MEMORY;

create table tbl_item_bag_in_use	#baggage in used
(
	cs_uId		bigint unsigned	not	null, 				#baggage owner
	is_uId		bigint unsigned not null, 				#baggage identifier
	ibiu_uBagSlotIndex		tinyint unsigned not null,		#in whish slot it used
	ibiu_uRoomIndex				tinyint unsigned not null,	#in which room it used

	unique key(is_uId),
	unique key(cs_uId,ibiu_uBagSlotIndex),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade,
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_grid_in_room	
(
	gir_uGridID		bigint unsigned		not	null auto_increment,#position sequence id
	cs_uId					bigint 	unsigned	not null,		#pos owner
	gir_uRoomIndex 	tinyint	unsigned 	not null,	#index of baggage which item is in
	gir_uPos				tinyint	unsigned 	not null,		#position
	primary key(gir_uGridID),
	key(cs_uId,	gir_uRoomIndex, gir_uPos),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_item_in_grid	#item index that of main baggage
(
	is_uId		bigint 	unsigned	not	null,		#item identifier
	gir_uGridID		bigint unsigned		not	null,
	unique key(is_uId),
	foreign	key(gir_uGridID)	references tbl_grid_in_room(gir_uGridID) on	update cascade on delete cascade,
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_grid_info	
(
	gir_uGridID		bigint unsigned		not	null,
	gi_uCount	int		unsigned 	not null,		#item count
	is_uType	tinyint unsigned		not	null,		#item type
	is_sName	varchar(96)			not	null,		#item name
	unique key(gir_uGridID),
	foreign	key(gir_uGridID)	references tbl_grid_in_room(gir_uGridID) on	update cascade on delete cascade
)engine=innodb;

#��Ʒһ��ʱ����Ի�õ��������
create table tbl_item_amount_limit	
(
	cs_uId		bigint 	unsigned	not null,		#item owner
	is_sName	varchar(96)		not	null,		#item name	
	key(is_sName),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#�����ֿ���
create table tbl_item_store_room_lock	
(
	cs_uId		bigint 	unsigned	not null,		
	isrl_uTime	int 	unsigned not null,			
	isrl_dtLockTime datetime  not null,

	primary key(cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

##��Ʒ������
create table tbl_item_is_binding    	#binding info of a item
(
	is_uId		bigint 	unsigned	not	null,		#item identifier
	isb_bIsbind	tinyint	unsigned	default 0, 		#item binding type
									#	0 stands for unbindinged
									#	1 stands for would be bindinged when be used
									#	2 stands for bindinged
	unique key(is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;
##��Ʒ��������
create table tbl_item_life		#item left time
(
	is_uId		bigint 		unsigned	not	null,	#item identifier
	il_nLeftTime	bigint  	not null,   			#left time when style is online tick
									#lasts time when style is continuous tick
	il_nLoadTime	datetime  not null,				#load time
	il_uStyle	tinyint		unsigned,			#tick style. 1 stands for online tick, 2 stands for continuous tick.
	unique key(is_uId),
	KEY `il_uStyle` (`il_uStyle`),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

##�ֽ�������
create table tbl_item_break_exp	#item left time
(
	cs_uId		bigint 		unsigned	not	null,	#char identifier
	ibp_uExp  bigint 		unsigned	not	null,	#break exp
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

##########################################################
## ������Ʒ�������Ʒ��Ϣ��
create table tbl_item_boxitem_pickup 	#item box info
(
	cs_uId		bigint 	unsigned	not null,		#item owner
	ibp_uBoxitemId	bigint 	unsigned	not null,		#item that is in the box
	ibp_uId		bigint 	unsigned	not null auto_increment,#sequence id
	ibp_uType	tinyint unsigned	not null,		#drop type
	ibp_sName	varchar(96)		not null,		#item name dropped
	ibp_uCount	tinyint			not null,		#item count dropped
	ibp_uBindingType	tinyint	default null,

	primary key(ibp_uId),
	key(ibp_uBoxitemId),
	foreign	key(cs_uId)     	references tbl_char_static(cs_uId)  on	update cascade on delete cascade,
	foreign key(ibp_uBoxitemId) references tbl_item_static(is_uId) on delete cascade on update cascade
)engine=innodb;

########################################################
#��ʯ��Ƕ��
########################################################

create table tbl_stone_hole		#stone hole info
(
	sh_uId		bigint unsigned not null auto_increment,	#sequence id
	cs_uId		bigint unsigned not null, 			#owner
	sh_uPanel	tinyint unsigned not null,			#panel that the hole belongs to
	sh_uDepart	tinyint unsigned not null ,			#part that the hole belongs to
	sh_uSlot	tinyint unsigned not null,			#slot of a part that hole in
	primary key  (sh_uId),
	unique key (cs_uId, sh_uPanel, sh_uDepart, sh_uSlot),
	foreign	key (cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#########################################################
#��ʯ
#########################################################
create table tbl_stone_in_use  		#in used stone
(
	cs_uId			bigint unsigned 	not null, 	#owner
	sh_uId			bigint unsigned 	not null,       #hole identifier that stone be in
	siu_uType		tinyint unsigned	not	null,	#item type
	siu_sName		varchar(96)		not	null,	#item name
	siu_bIsbind		tinyint unsigned	default 0, 	#item binding type
	primary key (cs_uId, sh_uId),
	foreign key (sh_uId) references tbl_stone_hole(sh_uId)	on update cascade on delete cascade,
	foreign key (cs_uId) references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_stone_frame_use	#current used stone frame
(
	cs_uId			bigint unsigned not null, 		#owner
	us_uPanel			tinyint unsigned not null default 1,	#current using stone frame
	primary key  (cs_uId),
	unique key (cs_uId, us_uPanel),
	foreign	key (cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#################################################################################
#                                                                               #
#                           ==**����ֿ���أ�Ʃ���ᡢ�̻�ȵĲֿ�**==         #
#                                                                               #
#################################################################################
##����ֿ⾲̬�����еļ���ֿⶼ��������
create table tbl_collectivity_depot	#global orgnization depot
(
	cds_uId			bigint unsigned not null auto_increment, 	#depot identifier
	cds_dtCreateTime	datetime             not null,			#create time
	primary key(cds_uId)
)engine=innodb;

##����ֿ���Ʒ��
create table tbl_item_collectivity_depot	#items that in depot
(
	cds_uId			bigint 	unsigned	not null,		#depot identifier
	is_uId			bigint 	unsigned	not null,		#item identifier
	icd_uPageIndex		tinyint	unsigned	not null,		#in which page
	icd_uPos		tinyint	unsigned 	not null,		#slot

	unique key(is_uId),
	key(cds_uId,	icd_uPageIndex, icd_uPos),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade,
	foreign	key(cds_uId)	references tbl_collectivity_depot(cds_uId) on	update cascade on delete cascade
)engine=innodb;

##���˲ֿ��Ǯ��
create table tbl_depot_money			#roles' money in depot
(
	cs_uId				bigint unsigned		not	null,	#owner
	dm_uMoney			bigint unsigned		not	null,	#count
	primary key (cs_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#################################################################################
#                                                                               #
#                           ==**����װ�����**==                                  #
#                                                                               #
#################################################################################

#�Ѿ�װ�����������ߵ�
#EEquipPart.eWeapon					= 1	#weapon
#EEquipPart.eHead					= 3	#head
#EEquipPart.eWear					= 4	#armor
#EEquipPart.eSash					= 5	#sash
#EEquipPart.eCuff					= 6	#cuff
#EEquipPart.eShoe					= 7	#shoe
#EEquipPart.eRingLeft					= 8	#left ring
#EEquipPart.eRingRight					= 9	#right ring
#EEquipPart.eNecklace					= 10	#necklace
#EEquipPart.eAccouterment				= 11	#Accouterment
#EEquipPart.eManteau					= 12	#manteau
#EEquipPart.eCoat					= 13	#coat
create table tbl_item_equip
(
	cs_uId				bigint unsigned		not	null,
	is_uId				bigint unsigned		not	null,
	ce_uEquipPart	tinyint unsigned  not null,   #װ��λ��
	primary key (is_uId),
	unique key(cs_uId,ce_uEquipPart),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_item_armor
(
	is_uId		bigint unsigned		not null,			#��Ʒid
	ia_sName	varchar(48)		not null default "",		#��ʾ����
	ia_uBaseLevel		tinyint unsigned 	not null, 		#��ʼ�ȼ�
	ia_uCurLevel        tinyint unsigned 	not null,
	ia_uUpgradeAtrrValue1	int unsigned 	not null, 			#װ������ʱ������һ����������1~3�������ñ��е�˳��
	ia_uUpgradeAtrrValue2	int unsigned 	not null,			#װ������ʱ�����Զ�
	ia_uUpgradeAtrrValue3	int unsigned 	not null,			#װ������ʱ��������
	ia_uStaticProValue		int unsigned 	not null,       	#��̬װ������ֵ
	ia_uIntensifyQuality    tinyint unsigned    not null default 0, 	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	ia_sIntenSoul varchar(6),
	
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_item_weapon
(
	is_uId 			bigint unsigned 	not null,		#��ƷID
	iw_sName 		varchar(48) 		not null default "",	#��ʾ���ƣ�����ʱ�޸ģ�
	iw_uBaseLevel 		tinyint unsigned 	not null, 		#��ʼ�ȼ�������ʱ�޸ģ�
	iw_uCurLevel       tinyint unsigned 	not null,
	iw_uDPS			float unsigned 	not null,			#��ǰDPS������ʱ�޸ģ�	
	iw_uAttackSpeed float unsigned 	not null default 0,			#�����ٶ�
	iw_uDPSFloorRate tinyint 	not null default 0,			#��������
	iw_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
    iw_sIntenSoul varchar(6),
    
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_item_ring
(
	is_uId			bigint unsigned 	not null,		    #��ƷID
	ir_sName		varchar(48)		not null default "",	#��ʾ����
	ir_uBaseLevel		tinyint unsigned	not null, 		#��ʼ�ȼ�
	ir_uCurLevel        tinyint unsigned 	not null,
	ir_uDPS			float unsigned	not null,			    #������
	ir_uStaticProValue  float unsigned	not null,			#��̬װ������ֵ
	ir_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
	ir_sIntenSoul varchar(6),
	
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

create table tbl_item_shield
(
	is_uId 			bigint unsigned 	not null,		#��ƷID
	is_sName 		varchar(48) 		not null default "",	#��ʾ���ƣ�����ʱ�޸ģ�
	is_uBaseLevel 		tinyint unsigned 	not null, 		#��ʼ�ȼ�������ʱ�޸ģ�
	is_uCurLevel        tinyint unsigned 	not null,
	is_uIntensifyQuality    tinyint unsigned    not null default 0,  	#װ��ǿ�����ʣ���ֵ����װ����ǿ������߽׶�
    is_sIntenSoul varchar(6),
    
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

##���Ʋ��������������ԡ�
create table tbl_item_shield_Attr
(
	is_uId 			bigint unsigned not null,	#��ƷID
	isa_uAttrValue1	int unsigned ,				#װ������ʱ������һ����ֵ��ֵ(�Ժ������õ�)
	isa_uAttrValue2	int unsigned ,				#װ������ʱ�����Զ���Ȼ��ֵ��ֵ(�Ժ������õ�)
	isa_uAttrValue3	int unsigned ,				#װ������ʱ���������ƻ���ֵ��ֵ(�Ժ������õ�)
	isa_uAttrValue4	int unsigned ,				#װ������ʱ�������İ��ڿ�ֵ��ֵ(�Ժ������õ�)
	
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_shield(is_uId) on	update cascade on delete cascade
)engine=innodb;

############װ��������Ϣ��#######################
create table tbl_item_equip_advance
(
	is_uId		bigint unsigned		not null,			#��Ʒid
	iea_uCurAdvancePhase tinyint unsigned	not null,			#װ����ǰ���׵Ľ׶�
	iea_uTotalAdvancedTimes int  unsigned,					#װ�����ܽ��״���
	iea_uSkillPieceIndex1 	tinyint	unsigned,				#���ܼ����������1����
	iea_uSkillPieceIndex2 	tinyint	unsigned,				#���ܼ����������2����
	iea_uSkillPieceIndex3 	tinyint	unsigned,				#���ܼ����������3����
	iea_uSkillPieceIndex4 	tinyint	unsigned,				#���ܼ����������4����		
	iea_uChoosedSkillPieceIndex 	tinyint unsigned,			#��ǰѡ��ļ��ܼ�������������
	iea_sJingLingType               varchar(3),                 #�������ͣ��𡢷硢�ء�����ˮ
	iea_uAdvanceSoulNum             smallint unsigned default 0,          #ע��Ľ��׻���Ŀ
	iea_uAdvancedTimes              int unsigned default 0,               #���״���
	iea_uAdvancedAttrValue1         int unsigned,
	iea_uAdvancedAttrValue2         int unsigned,
	iea_uAdvancedAttrValue3         int unsigned,
	iea_uAdvancedAttrValue4         int unsigned,
	iea_sAdvancedSoulRoot           varchar(12),
	iea_sAdvancedAttr1	            varchar(48),
	iea_sAdvancedAttr2	            varchar(48),
	iea_sAdvancedAttr3	            varchar(48),
	iea_sAdvancedAttr4	            varchar(48),
	
	primary key (is_uId),
	foreign key (is_uId) references tbl_item_static(is_uId) on update cascade on delete cascade
)engine=innodb;

#############��ҵ�ǰ����ܱ�####################
create table tbl_char_equip_advancedActiveSkill
(
	cs_uId		bigint unsigned	not	null,				#���id
	iea_uActiveSkillIndex	int unsigned,					#���ѡ����õļ�����������
	primary key (cs_uId),
	foreign key (cs_uId) references tbl_char_static(cs_uId)  on update cascade on delete cascade
)engine=innodb;

#############װ��ǿ����Ϣ��#########################
create table tbl_item_equip_intensify
(
	is_uId		bigint unsigned		not null,			#��Ʒid
	iei_uIntensifySoulNum	int unsigned		not null default 0,#ͬ�ϣ�������������ǿ���Ļ���Ŀ
	iei_uPreAddAttr1	varchar(48) , 					#ǿ����һ�׶εĸ�������1��ǿ��ʱ�޸ģ�
	iei_uPreAddAttrValue1	int unsigned,   			#��������1��ֵ		��ǿ��ʱ�޸ģ�
	iei_uPreAddAttr2	varchar(48) , 					#ǿ����һ�׶εĸ�������2��ǿ��ʱ�޸ģ�
	iei_uPreAddAttrValue2	int unsigned,   			#ǿ����һ�׶εĸ�������2��ֵ��ǿ��ʱ�޸ģ�
	iei_uAddAttr1		varchar(48) , 					#ǿ����ǰ�׶θ�������1	��ǿ��ʱ�޸ģ�
	iei_uAddAttrValue1	int unsigned,   				#ǿ����ǰ�׶θ�������1��ֵ��ǿ��ʱ�޸ģ�
	iei_uAddAttr2		varchar(48), 					#ǿ����ǰ�׶θ�������2	��ǿ��ʱ�޸ģ�
	iei_uAddAttrValue2	int unsigned,   				#ǿ����ǰ�׶θ�������2��ֵ��ǿ��ʱ�޸ģ�
	iei_uIntensifyPhase	tinyint unsigned,				#װ��ǿ�����Ľ׶Σ���ʼΪ0����1��2��3��4��
	iei_uEuqipSuitType	tinyint unsigned,				#װ��ǿ��������װ���ͣ�0��ʾ�ޣ�1��ʾ2���ף�2��ʾ3���ף�3��ʾ4���ף�4��ʾ�����ף�5��ʾ8����
	iei_sSuitName		varchar(120),					#��װ����
	iei_uIntensifyBackState tinyint unsigned, 			#װ���Ƿ�ɽ���������0��ʾ����������1��ʾ����
	iei_uIntensifyTimes      smallint unsigned, 		#��¼װ��ǿ������
	iei_uIntensifyBackTimes  smallint unsigned, 		#��¼װ����������
	iei_uIntenTalentIndex     smallint unsigned,        #ǿ�������׶β����Ķ����츳��������
	primary key (is_uId),
	foreign key (is_uId) references tbl_item_static(is_uId) on update cascade on delete cascade
#	foreign key (is_uId) references tbl_item_armor(is_uId) on update cascade on delete cascade,
#	foreign key (is_uId) references tbl_item_ring(is_uId) on update cascade on delete cascade,
#	foreign key (is_uId) references tbl_item_shield(is_uId) on update cascade on delete cascade
)engine=innodb;

#############װ��ǿ��4~9�׶����Ա�######################
create table tbl_item_equip_intensifyAddAttr
(
    is_uId      bigint unsigned 	not null,		                #��ƷID
    iei_sAddAttr4       varchar(48)   ,        					#ǿ��4�׶θ�������
    iei_uAddAttr4Value  int unsigned  ,          				#ǿ��4�׶θ�������ֵ
    iei_sAddAttr5       varchar(48)   ,       					#ǿ��5�׶θ�������
    iei_uAddAttr5Value  int unsigned  ,          				#ǿ��5�׶θ�������ֵ
    iei_sAddAttr6       varchar(48)   ,        					#ǿ��6�׶θ�������
    iei_uAddAttr6Value  int unsigned  ,          				#ǿ��6�׶θ�������ֵ
    iei_sAddAttr7       varchar(48)   ,        					#ǿ��7�׶θ�������
    iei_uAddAttr7Value  int unsigned  ,          				#ǿ��7�׶θ�������ֵ
    iei_sAddAttr8       varchar(48)   ,        					#ǿ��8�׶θ�������
    iei_uAddAttr8Value  int unsigned  ,          				#ǿ8�Ľ׶θ�������ֵ
    iei_sAddAttr9       varchar(48)   ,        					#ǿ��9�׶θ�������
    iei_uAddAttr9Value  int unsigned  ,          				#ǿ��9�׶θ�������ֵ
    primary key (is_uId),
    foreign	key(is_uId)	references tbl_item_equip_intensify(is_uId) on	update cascade on delete cascade
)engine=innodb;


##װ����������
create table tbl_item_equip_armor (
		is_uId          bigint unsigned not null,	#��ƷID
		iea_sAttr		varchar(48) not null, #����Ƭ(����)
		iea_uAddTimes tinyint	unsigned   not null,
		iea_uIndex tinyint	unsigned   not null,
		
		primary key (is_uId,iea_uIndex),
    foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine = innodb;

####װ���;�
create table tbl_item_equip_durability(
    is_uId          bigint unsigned not null,	#��ƷID
    ied_uMaxDuraValue float unsigned,          #�;�����ֵ
    ied_uCurDuraValue float unsigned,         #��ǰ�;�ֵ
    primary key (is_uId),
    foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine = innodb;


#####װ��׷��
create table tbl_item_equip_superaddation(
    is_uId          bigint unsigned not null,
    ies_uCurSuperaddPhase tinyint unsigned not null,
    primary key (is_uId),
    foreign key(is_uId) references tbl_item_static(is_uId) on update cascade on delete cascade
)engine = innodb;


##װ��������
create table tbl_item_maker
(
	is_uId						bigint unsigned not null, 	#��Ʒid
	cs_uId 						bigint unsigned 		not null,		#������
	unique key(is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade,
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

##### ����
create table tbl_item_pearl
(
	is_uId			bigint unsigned 	not null,		#��ƷID
	ip_uSoulNum		bigint unsigned 	not null, 		#�����Ŀ
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

##### ���顢������ʹ�ô�������
create table tbl_item_pearl_limit
(
	cs_uId 						bigint unsigned 		not null,		#���id
	ipl_uItemType			tinyint	unsigned   default null,	##���ͣ�1���飬2������
	ipl_uLimitType		tinyint	unsigned   default null,	##��������
	ipl_uLimitTime		bigint unsigned 	not null, 		#ʹ�ô���
	unique key(cs_uId,ipl_uItemType,ipl_uLimitType),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on delete cascade on update cascade
)engine=innodb;

##������Ϣ��
create table tbl_item_battlebook
(
	is_uId      bigint unsigned    not null,	 	                    ##������ˮ��
	ib_uPos1			tinyint	unsigned   default null,					          ##1��λ��
	ib_uPos2			tinyint	unsigned 	 default null,					          ##2��λ��
	ib_uPos3			tinyint	unsigned	 default null,					          ##3��λ��
	ib_uPos4			tinyint	unsigned   default null,					          ##4��λ��
	ib_uPos5			tinyint	unsigned	 default null,					          ##5��λ��
	primary key(is_uId),
	foreign key(is_uId)	references tbl_item_static(is_uId) on update cascade on delete cascade
)engine=innodb;

##���ͼ�������Ա�
create table tbl_item_oremap
(
	is_uId      bigint unsigned				not null,
	io_sName		varchar(96)						default null,					          ##���ͼλ��
	io_uPosX		smallint unsigned			not	null default 1,					        ##����X
	io_uPosY		smallint unsigned			not	null default 1,					        ##����Y

	primary key(is_uId),
	foreign key(is_uId)	references tbl_item_static(is_uId) on update cascade on delete cascade
)engine=innodb;


create table tbl_item_cool_down
(
	cs_uId					bigint unsigned	not	null,
	icd_sName				varchar(96)			not	null,		#��Ʒ����
	icd_dataUseTime	datetime  			not null,		#ʹ��ʱ��	
	primary key(cs_uId, icd_sName),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

##�ɿ󹤾��;ö�
create table tbl_item_pickore_dura
(
	is_uId      bigint unsigned				not null,
	ipd_uMaxDura int unsigned		not	null default 1,          #�;�����ֵ
	ipd_uCurDura int unsigned		not	null default 1,          #��ǰ�;�ֵ

	primary key(is_uId),
	foreign key(is_uId)	references tbl_item_static(is_uId) on update cascade on delete cascade
)engine=innodb;

#��ƿ
create table tbl_item_soul_bottle
(
	cs_uId	bigint unsigned 	not null,	
	is_uId	bigint unsigned 	not null,	
	isb_uState tinyint unsigned not null,  #����״̬ 1--����  2--�ر�
	isb_uStorageNum int unsigned not null, #�洢��
	
	primary key(cs_uId,is_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;

#����ƿ
create table tbl_item_exp_bottle
(
	cs_uId	bigint unsigned 	not null,	
	is_uId	bigint unsigned 	not null,	
	ieb_uState tinyint unsigned not null,  #����״̬ 1--����  2--�ر�
	ieb_uStorageNum int unsigned not null, #�洢��
	
	primary key(cs_uId,is_uId),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine=innodb;