##################################################################################
##                                                                               #
##                                 ==**�̻����**==                              #
##                                                                               #
##################################################################################
###�̻���Ϣ��
#create table tbl_cofc
#(
#	c_uId				bigint unsigned		not null auto_increment,	##�̻�id
#	c_sName				varchar(100) collate utf8_unicode_ci not null,					##�̻�����
#	c_dtCreateTime		datetime			not null,					##�̻ᴴ��ʱ��
#	c_uLevel			int unsigned		not null default 1,			##�̻�ȼ�
#	c_uMoney			bigint unsigned		not null default 0,			##�̻��ʽ�
#	c_sPurpose			varchar(600)		not null default '',		##�̻���ּ
#	c_nStockSum			int unsigned		not null default 0,			##���̻�Ĺ�Ʊ����
#	tc_nTechId      int unsigned    not null  default 0,    #�Ƽ�����(��ǰ������Ŀ)��Ϊ0ʱû�п�����Ŀ
#	primary key(c_uId),
#	unique key(c_sName)
#)engine=innodb;
#
###�̻�����������Ϊ�������
#create table tbl_day_popular_cofc
#(
#	c_uId				bigint unsigned		not null,					##�̻�id
#	dpc_uYear			smallint unsigned	not null,					##��
#	dpc_uDayOfYear		smallint unsigned	not null,					##�����е�������ͨ��dayofyear()��ȡ
#	dpc_uWeekOfYear		smallint unsigned	not null,					##�����ڸ����е���������ͨ��weekofyear()��ȡ
#	dpc_uPopular		bigint				not null default 0,			##�̻������ֵ
#	primary key(c_uId, dpc_uYear, dpc_uDayOfYear),
#	foreign	key(c_uId)		references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
###�̻���Ա��
#create table tbl_member_cofc
#( 
#	cs_uId				bigint unsigned		not null,					##��Ա�Ľ�ɫid
#	c_uId				bigint unsigned		not null,					##�̻�id
#	mc_uPosition		varchar(96)			not null,					##���̻��е�ְλ
#	mc_uProffer			tinyint unsigned	not null default 0,			##�ﹱ
#	mc_dtJoinTime		datetime			not null,					##����ʱ��
#	primary key(cs_uId),
#	foreign	key (cs_uId)	references tbl_char_static(cs_uId) on update cascade on delete cascade,
#	foreign	key(c_uId)		references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
###�̻���־��Ϣ��
#create table tbl_log_cofc
#( 
#	lc_uId				bigint unsigned		not null auto_increment,	##��־id
#	c_uId				bigint unsigned		not null,					##�̻�id
#	lc_sContent			varchar(300)		not null,					##��־����
#	lc_Type				tinyint unsigned	not null,					##��־���
#	lc_dtCreateTime		datetime			not null,					##ʱ��
#	primary key(lc_uId),
#	foreign	key(c_uId)	references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
###������Ϣ��
#create table tbl_request_cofc
#(
#	cs_uId				bigint unsigned		not null,					##������id
#	c_uId				bigint unsigned		not null,					##�̻�id
#	rc_uRecomId		bigint unsigned  not null,				##������id
#	rc_dtRequestTime	datetime			not null,					##���������ʱ��
#	rc_sExtraInfo		varchar(300)		not null,					##���ӵ�������Ϣ
#	primary key(cs_uId,c_uId),
#	foreign	key(cs_uId)			references tbl_char_static(cs_uId) on update cascade on delete cascade,
#	foreign	key(rc_uRecomId)	references tbl_char_static(cs_uId) on update cascade on delete cascade,
#	foreign	key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
#
###��Ա�˳��̻���Ϣ��
#create table tbl_leave_cofc
#(
#	cs_uId				bigint unsigned		not null,					##�˳���id
#	lc_dtQuitTime		datetime			not null,					##�˳��̻�ʱ��
#	foreign	key (cs_uId)		references tbl_char_static(cs_uId) on update cascade on delete cascade
#)engine=innodb;
#
##################################################################################
##                                    ��Ʊ���                                   #
##################################################################################
###��Ʊ���б�
#create table tbl_stock_have_cofc
#(
#	c_uId				bigint unsigned		not null,					##��Ʊ�Ĵ��루�̻��id��
#	cs_uId				bigint unsigned		not null default 0,			##��Ʊ������id
#	
#	shc_uId				bigint unsigned		not null auto_increment,	##��¼����ˮ��
#	shc_uNumber			int unsigned		not null,					##���еĹ�Ʊ����
#	shc_uPrice			bigint unsigned		not null default 0,			##����۸��100���
#	shc_dtTradeTime		datetime			not null,					##��������
#	
#	primary key(shc_uId),
#	foreign key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade,
#	foreign key(cs_uId)			references tbl_char_static(cs_uId) on update cascade on delete cascade
#)engine=innodb;
#
###��Ʊ������ʷ��
#create table tbl_stock_exchange_cofc
#(
#	c_uId				bigint unsigned		not null,					##��Ʊ�Ĵ��루�̻��id��
#	sec_uId				bigint unsigned		not null auto_increment,	##��¼����ˮ��
#	
#	sec_uFromId			bigint unsigned		not null,					##��Ʊ��������ʼ��id����Ϊ0��ʾ�̻᱾��
#	sec_uToId			bigint unsigned		not null,					##��Ʊ�������ս᷽id����Ϊ0��ʾ�̻᱾��
#	
#	sec_dtTraceTime		datetime			not null,					##����ʱ���
#	sec_nNumber			bigint unsigned		not null,					##���׶�
#	sec_nPrice			bigint unsigned		not null,					##���׼۸��100��
#	
#	primary key(sec_uId),
#	foreign key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
###��Ʊ����ͳ����ʷ����ȫ�ǶԱ�tbl_stock_exchange_cofc���ʱ���ͳ��ֵ��
#create table tbl_stock_exchange_statistics_cofc
#(
#	c_uId				bigint unsigned		not null,					##��Ʊ�Ĵ��루�̻��id��
#	sesc_uId			bigint unsigned		not null auto_increment,	##��¼����ˮ��
#	sesc_dtEndTime		datetime			not null,					##ͳ��ʱ��ε��յ�ʱ��
#	
#	sesc_nNumber		bigint unsigned		not null default 0,			##�ܽ�����
#	sesc_nSumPrice		bigint unsigned		not null default 0,			##�ܽ��׽���100����ʱ����� ������*�۸�ɼ� �ļӺϣ�
#	sesc_nDeltaType		int unsigned		not null,					##ʱ�������͡�15Ϊ15���ӣ�120Ϊ2h��480Ϊ8h
#	
#	primary key(sesc_uId),
#	foreign key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
###��Ʊ������
#create table tbl_stock_order_cofc
#(
#	c_uId				bigint unsigned		not null,					##��Ʊ�Ĵ��루�̻��id��
#	cs_uId				bigint unsigned,								##�µ��û�id
#	soc_uId				bigint unsigned		not null auto_increment,	##������ˮ��
#	soc_uType			tinyint unsigned	not null,					##�������ͣ�0Ϊ�򵥣�1Ϊ����
#	soc_dtCreateTime	datetime			not null,					##��������ʱ��
#	soc_uPrice			bigint unsigned		not null,					##�ҵ��ļ۸�(��Ҫ��������ĵ�֧�ɵļ۸�)
#	soc_uCostPrice  bigint unsigned		not null default 0,	##������֮ǰ�ĳɱ��۸�(�򵥵ĳɱ��۸���0)
#	soc_uNumber			bigint unsigned		not null,					##Ԥ�ڽ�����
#	
#	primary key(soc_uId),
#	foreign key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade,
#	foreign key(cs_uId)			references tbl_char_static(cs_uId) on update cascade on delete cascade
#)engine=innodb;
#
###�Ʊ���
#create table tbl_stock_report_cofc
#(
#	c_uId				bigint unsigned 	not null,					##��Ʊ�Ĵ��루�̻��id��
#	
#	src_uId				bigint unsigned		not null auto_increment,	##�Ʊ���ˮ��
#	src_dtEndTime		datetime			not null,					##����ʱ��
#	
#	src_uLevel			int unsigned		not null,					##�̻�ȼ�
#	src_uMemberNum		int unsigned		not null,					##�̻��Ա��
#	src_uMoneyAll		bigint unsigned		not null,					##�̻����ʽ�
#	src_uMoneyIncome	bigint unsigned		not null,					##�ڼ�����
#	src_uExchangeNum	bigint unsigned		not null,					##�ڼ��ܽ�����
#	src_uBonusAll		bigint unsigned		not null,					##�ֳ����ܺ���
#	src_uStockNum		int					not null,					##�۳����ܹ���
#	src_uActivePoint	bigint unsigned		not null,					##��Ծ��
#	
#	primary key(src_uId),
#	foreign key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
#
###�Ʊ���ɶ���
#create table tbl_stock_report_shareholder_cofc
#(
#	src_uId				bigint unsigned		not null,					##�Ʊ������ˮ��
#	cs_uId				bigint unsigned		not null,					##��Ʊ������id
#	
#	srsc_uNumber		bigint unsigned		not null,					##������
#	
#	primary key(src_uId, cs_uId),
#	foreign key(src_uId)	references tbl_stock_report_cofc(src_uId)	on update cascade on delete cascade,
#	foreign key(cs_uId)		references tbl_char_static(cs_uId)			on update cascade on delete cascade
#)engine=innodb;
##################################################################################
##                                    �̻����䳵                             #
##################################################################################
##
#create table tbl_cofc_truck
#(
#	ct_uId				bigint unsigned		not null auto_increment,	##���䳵����ˮ��
#	ct_uCarTyp smallint unsigned	not null,			##���䳵���ͺ� 1-���ͳ� ��2 -���ͳ���3 - С�ͳ�
#	ct_uCapacity	bigint unsigned		not null,		##���䳵�ĵ�ǰ����
#	ct_uHP			bigint unsigned		not null,			##���䳵�ĵ�ǰ����ֵ
#	cs_uId				bigint unsigned		default null,		##���䳵�ĳ�����id
#	c_uId				bigint unsigned 	default null,			##���䳵�ĳ����̻����
#	
#	primary key(ct_uId),
#	foreign key(cs_uId)	references tbl_char_static(cs_uId)	on update cascade on delete cascade,
#	foreign key(c_uId)	references tbl_cofc(c_uId)				on update cascade on delete cascade
#)engine = innodb;
##################################################################################
##                                    �̻�Ƽ�                                  #
##################################################################################
#create table tbl_technology_cofc
#(       
#	c_uId		 					bigint unsigned     	not null,										#�̻�id
#	tc_nTechId        int unsigned        	not null,                		#�Ƽ�����
#	tc_uPoint   			bigint unsigned     	not null   default 0,      	#��ǰ��������ɶȣ�
#	tc_uLevel        	int unsigned        	not null   default 0,      	#��ǰ�ȼ�
#	primary	key(c_uId,tc_nTechId),
#	foreign key(c_uId)			references tbl_cofc(c_uId) on update cascade on delete cascade
#)engine=innodb;
