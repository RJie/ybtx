create table tbl_attribute_panel
(        cs_uId		              bigint unsigned     not  null,	#��ɫid
         ap_uAttribute1           tinyint unsigned     not null ,   #�ؼ�
         ap_uAttribute2           tinyint unsigned     not null ,    #����ҳ
	 primary	key(cs_uId),
         foreign	key (cs_uId)	        references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;
   
