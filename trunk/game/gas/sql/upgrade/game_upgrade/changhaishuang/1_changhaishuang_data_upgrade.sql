

#����̵���۱������Ʒ
delete im from tbl_player_sell_item_id diit,tbl_item_static im where diit.psii_nItemId = im.is_uId;
#����̵������Ʒ��̬��
delete from tbl_npcshop_player_sell_item;

#����Ҫɾ����Ʒ��ʱ��
create table tbl_del_item_id_temp(is_uId bigint not null, primary key(is_uId));

#�����ڰ��������Ʒ������ʱ��
insert into tbl_del_item_id_temp select ist.is_uId 
from tbl_item_static ist left join tbl_item_in_grid iig on ist.is_uId = iig.is_uId where iig.is_uId is null; 

#����ʱ��ɾ���ڶ��������Ʒ
delete diit from tbl_del_item_id_temp diit,tbl_item_market im where diit.is_uId = im.is_uId;

#����ʱ��ɾ���ڴ������������Ʒ
delete diit from tbl_del_item_id_temp diit,tbl_contract_manufacture_order_item im where diit.is_uId = im.is_uId;

#����ʱ��ɾ�����ʼ������Ʒ
delete diit from tbl_del_item_id_temp diit,tbl_mail_item im where diit.is_uId = im.is_uId;

#����ʱ��ɾ�������ϵ�װ����Ʒ
delete diit from tbl_del_item_id_temp diit,tbl_item_equip im where diit.is_uId = im.is_uId;

#����ʱ��ɾ���ڲֿ����Ʒ
delete diit from tbl_del_item_id_temp diit,tbl_item_collectivity_depot im where diit.is_uId = im.is_uId;

#����ʱ��ɾ����ʹ�õı�����Ʒ
delete diit from tbl_del_item_id_temp diit,tbl_item_bag_in_use im where diit.is_uId = im.is_uId;

#��Ҫɾ����Ʒ�Ӿ�̬����ɾ��
delete im from tbl_del_item_id_temp diit,tbl_item_static im where diit.is_uId = im.is_uId;


##���¼�����Ʒ����
delete from tbl_grid_info;
insert into tbl_grid_info(gir_uGridID,gi_uCount,is_uType,is_sName)
    	select 
    		gir_uGridID,count(1),item.is_uType,item.is_sName
    	from 
    		tbl_item_in_grid as room,
    		tbl_item_static as item 
    	where 
    		item.is_uId = room.is_uId
    	group by 
    		gir_uGridID;