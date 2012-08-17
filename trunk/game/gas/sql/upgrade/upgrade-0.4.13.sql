

alter table tbl_mail add column m_uLogMailType smallint unsigned 	not null;

##�ֽ�������
create table tbl_item_break_exp	#item left time
(
	cs_uId		bigint 		unsigned	not	null,	#char identifier
	ibp_uExp  bigint 		unsigned	not	null,	#break exp
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;


##*������ȡ*##
create table tbl_tong_draw_forage
(
	tdf_uId   bigint unsigned     	not null,										#char id
	tdf_uTotal    bigint unsigned    	not null  default 50,			#forage total num
	primary	key(tdf_uId),
  foreign	key(tdf_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;
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
update tbl_war_zone_station set wz_uId = 1 where wz_uId = 3;
update tbl_tong_challenge set tc_nPassiveWzId = 1 where tc_nPassiveWzId = 3;
update tbl_tong_challenge_battle set tcb_nPassiveWzId = 1 where tcb_nPassiveWzId = 3;
delete from tbl_war_zone where wz_uId = 3;
delete from tbl_scene where sc_uType = 6;
