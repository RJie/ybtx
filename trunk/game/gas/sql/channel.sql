################################################################
#		Ƶ��channel
################################################################

#��������ΪƵ����channel id
create table tbl_channel_id			#channel info for database connection
(
	ci_nId bigint not null,		#use number as channel identifier
	primary key(ci_nId)
)engine=innodb;

#���ַ�����ΪƵ����channel id
create table tbl_channel_name			#channel info for database connection
(	
	cn_sName varchar(32) not null,			#use string as channel identifier
	primary key(cn_sName)
)engine=innodb;

