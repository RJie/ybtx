#���Ӷ��С�Ӵ�ʼ�˼�¼������С��ָ������Ӽ���
alter table tbl_tong add t_uInitiatorId	bigint unsigned	not null default 0;

insert into tbl_database_upgrade_record values ("all_upgrade_0.5.0.0.sql");
