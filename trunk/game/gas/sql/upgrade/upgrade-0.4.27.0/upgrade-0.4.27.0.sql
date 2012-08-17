#�ٻ��ޱ����
rename table tbl_char_servant_outline to tbl_char_servant;

#���pk����
create table tbl_char_pk
(
	cs_uId						bigint unsigned		not	null,
	cp_dtTime					datetime				not null,
	cp_uMin						bigint unsigned		not	null,
	cp_uMax						bigint unsigned		not	null,
	primary key(cs_uId,cp_dtTime,cp_uMin,cp_uMax),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine = innodb;


#ɾ����Դ�㱨��ʱ���
drop table tbl_tong_rob_res_time;

#�����µ���Դ�㱨��ʱ���
create table tbl_tong_rob_res_time	 #tong resource info
(
	trrti_sObjName			varchar(96)    		not null, 
	trrti_uCamp 			bigint unsigned		not null,  			#tong camp
	trrti_uId    	     bigint unsigned		not null,  			#tong id
	trrti_dtSignTime   DateTime          not null,     #signup time
	trrti_uServerId    bigint unsigned		not null,  			#current server id
	primary key(trrti_sObjName,trrti_uCamp,trrti_uId ,trrti_dtSignTime),
	foreign	key(trrti_uId) references tbl_tong(t_uId) on update cascade on	delete cascade
)engine=innodb;

alter table tbl_request_tong drop column rt_sExtraInfo; ##ȥ��Ӷ����������Ϣ
alter table tbl_member_tong add column mt_uPorfferExpend		bigint unsigned		not null after mt_sPosition;#�����ʹ�ù���

alter table tbl_request_tong drop foreign key tbl_request_tong_ibfk_2;
alter table tbl_request_tong drop column rt_uRecomId;

alter table tbl_request_tong drop foreign key tbl_request_tong_ibfk_1;
alter table tbl_request_tong drop key cs_uId;
alter table tbl_request_tong add foreign key (cs_uId)	references tbl_char_static(cs_uId) on	update cascade on	delete cascade;

alter table tbl_tong_draw_forage_time drop primary key;
alter table tbl_tong_draw_forage_time change tdft_sTime tdft_dtTime dateTime not null,add primary key(tdft_dtTime);


