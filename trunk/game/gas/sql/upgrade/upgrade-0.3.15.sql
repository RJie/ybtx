
##������Db2Gas���ַ������� �ı�
create table tbl_long_string_value
(
	ac_uId			bigint unsigned		not	null,
	lsv_sValue	varchar(256),
	primary key(ac_uId)
)engine=memory;

alter table tbl_arg_common change ac_sValue ac_sValue varchar(32);

#ɾ��װ������Ļ�������
alter table tbl_item_armor drop column ia_uAddAttr3;
alter table tbl_item_armor drop column ia_uAddAttr4;
alter table tbl_item_armor drop column ia_uAddAttrValue3;
alter table tbl_item_armor drop column ia_uAddAttrValue4;

alter table tbl_item_weapon drop column iw_uAddAttr3;
alter table tbl_item_weapon drop column iw_uAddAttr4;
alter table tbl_item_weapon drop column iw_uAddAttr5;
alter table tbl_item_weapon drop column iw_uAddAttr6;

alter table tbl_item_weapon drop column iw_uAddAttrValue3;
alter table tbl_item_weapon drop column iw_uAddAttrValue4;
alter table tbl_item_weapon drop column iw_uAddAttrValue5;
alter table tbl_item_weapon drop column iw_uAddAttrValue6;

alter table tbl_item_ring drop column ir_uAddAttr3;
alter table tbl_item_ring drop column ir_uAddAttr4;
alter table tbl_item_ring drop column ir_uAddAttrValue3;
alter table tbl_item_ring drop column ir_uAddAttrValue4;

alter table tbl_item_shield drop column is_uAddAttr3;
alter table tbl_item_shield drop column is_uAddAttr4;
alter table tbl_item_shield drop column is_uAddAttrValue3;
alter table tbl_item_shield drop column is_uAddAttrValue4;
	
##װ����������
create table tbl_item_equip_armor_attr(
	is_uId          bigint unsigned not null,	#��ƷID
	ieaa_sAttr1		varchar(48), #����Ƭ1(����)
	ieaa_sAttr2		varchar(48), #����Ƭ2(����)
	ieaa_sAttr3		varchar(48), #����Ƭ3(����)
	ieaa_sAttr4		varchar(48), #����Ƭ4(����)
	
	primary key (is_uId),
	foreign	key(is_uId)	references tbl_item_static(is_uId) on	update cascade on delete cascade
)engine = innodb;

#�޸����ߺ���Ⱥ������Ϣ���������(��Ϊ��������������޸�������ʱ�����ɾ�����ɾ�����������������������)
alter table tbl_request_add_group drop foreign key tbl_request_add_group_ibfk_1;
alter table tbl_request_add_group drop foreign key tbl_request_add_group_ibfk_2;
alter table tbl_request_add_group drop foreign key tbl_request_add_group_ibfk_3;
alter table tbl_request_add_group drop primary key;
alter table tbl_request_add_group add foreign key (`rag_uManager`) references `tbl_char_static` (`cs_uId`) on update cascade on delete cascade;
alter table tbl_request_add_group add foreign key (`rag_uInvitee`) references `tbl_char_static` (`cs_uId`) on update cascade on delete cascade;
alter table tbl_request_add_group add foreign key (fg_uId) references tbl_friends_group (fg_uId) on update cascade on delete cascade;
alter table tbl_request_add_group add primary key (`rag_uManager`, `rag_uInvitee`,fg_uId,rag_uType);

#ɾ���ٻ��޴洢�������
alter table tbl_char_servant_outline drop foreign key tbl_char_servant_outline_ibfk_1;
alter table tbl_char_servant_outline drop primary key;
alter table tbl_char_servant_outline add foreign key(cs_uId) REFERENCES
tbl_char_static(cs_uId) ON DELETE CASCADE ON UPDATE CASCADE;

#ϴ�츳����
delete from tbl_shortcut where sc_Arg1 in (select distinct fs_sName from tbl_fight_skill where fs_uKind = 2 and tbl_shortcut.cs_uid = tbl_fight_skill.cs_uId);
delete from tbl_skill_Series;
delete from tbl_fight_skill where fs_uKind = 2;
delete from tbl_skill_node;
delete from tbl_skill_layer;
delete from tbl_char_appellation where ca_sAppellation in("��ϰ���佣ʿ","���佣ʿ","���մ�ʿ","Ӣ�´�ʿ","ս���ʿ","���մ�ʿ","���´�ʿ","��ϰ������ʿ","������ʿ","������ʿ","��η��ʿ","��Ѫ��ʿ","������ʿ","������ʿ","��ϰ�񱩽�ʿ","�񱩽�ʿ","ɱ¾��ʿ","�п��ʿ","�����ʿ","�����ʿ","�ѻ���ʿ");
delete from tbl_char_appellation where ca_sAppellation in("���ױ�˪ħ��ʿ","��˪ħ��ʿ","��ԭħ��ʿ","Ԫ��ħ��ʿ","����ħ��ʿ","����ħ��ʿ","���ħ��ʿ","���׻���ħ��ʿ","����ħ��ʿ","ŭ��ħ��ʿ","����ħ��ʿ","����ħ��ʿ","����ħ��ʿ","���ħ��ʿ","��������ħ��ʿ","����ħ��ʿ","����ħ��ʿ","����ħ��ʿ","����ħ��ʿ","����ħ��ʿ","����ħ��ʿ");
delete from tbl_char_appellation where ca_sAppellation in("��ϰ��ʦ","���淨ʦ","�����ʦ","�����ʦ","����ħ��ʦ","ŭ��ħ��ʦ","����ħ��ʦ","��ϰڤ�뷨ʦ","ڤ�뷨ʦ","���Ĵ�ʦ","ڤ˼��ʦ","����ħ��ʦ","�Ի�ħ��ʦ","��ѧħ��ʦ","��ϰ����ʦ","��˪��ʦ","����ħ��ʦ","����ħ��ʦ","�籩��ħ��ʦ","Ԫ��֮��","�����ħ��ʦ");
delete from tbl_char_appellation where ca_sAppellation in("������Լаħ","��Լаħ","����аħ","���аħ","��Ԩʹ��","����ʹ��","����ʹ��","���׺ڰ�аħ","�ڰ�аħ","ҹ֮аħ","��֮аħ","�ڰ�ʹ��","����ʹ��","а��ʹ��","���ײٿ�аħ","�ٿ�аħ","����аħ","����аħ","������","�ƿ���","������");
delete from tbl_char_appellation where ca_sAppellation in("������а��ʦ","��а��ʦ","������ʦ","������ʦ","�ͽ�����","��������","ʥ������","��������ʦ","����ʦ","�ػ���","������","��ʹ�ػ���","��ʹ������","��ʹ������","���׻ָ���ʦ","�ָ���ʦ","������ʦ","������ʦ","�������","�������","�������");
delete from tbl_char_appellation where ca_sAppellation in("������Ѫսʿ","��Ѫսʿ","Ѫ������","��ɱ����","ս������","��Ѫ����","����","������ηսʿ","��ηսʿ","ɱ¾����","��η����","��­��","�ϼ���","�����","���׷��սʿ","���սʿ","�п�����","�ױ�����","Ұ������","�����","��¾��");
delete from tbl_char_appellationList where ca_uAppellation >= 90 and  ca_uAppellation <= 232;
delete from tbl_char_servant_outline;
delete from tbl_char_servant_name;
delete from tbl_char_magic_obj;
delete from tbl_char_magicstate;
delete from tbl_aure_magic;

#��tbl_conf_server������ʼ�ķ���������������
insert into tbl_conf_server (sc_sVarName, sc_sVarValue) values ("MaxOnLineUserNum","100");