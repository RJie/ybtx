

##װ����������
create table tbl_item_equip_armor (
		is_uId          bigint unsigned not null,	#��ƷID
		iea_sAttr		varchar(48) not null, #����Ƭ(����)
		iea_uAddTimes tinyint	unsigned   not null,
		iea_uIndex tinyint	unsigned   not null,
		
		primary key (is_uId,iea_uIndex),
    foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine = innodb;


insert into tbl_item_equip_armor select is_uId,ieaa_sAttr1,1,1 from tbl_item_equip_armor_attr where ieaa_sAttr1 is not null;
insert into tbl_item_equip_armor select is_uId,ieaa_sAttr2,1,2 from tbl_item_equip_armor_attr where ieaa_sAttr2 is not null;
insert into tbl_item_equip_armor select is_uId,ieaa_sAttr3,1,3 from tbl_item_equip_armor_attr where ieaa_sAttr3 is not null;
insert into tbl_item_equip_armor select is_uId,ieaa_sAttr4,1,4 from tbl_item_equip_armor_attr where ieaa_sAttr4 is not null;

alter table tbl_gm_msg add column gm_uReadFlag tinyint unsigned 	not null ;

