engine_require "common/Misc/TypeCheck"
gac_gas_require "framework/distance/Distance"

EAssignMode =
{
	--eAM_TurnPickup		= 0, --����ʰȡ
	eAM_FreePickup			= 0, --����ʰȡ
	eAM_AverageAssign		= 1, --ƽ������
	eAM_RespectivePickup	= 2, --����ʰȡ
	eAM_AuctionAssign		= 3, --����ģʽ
	eAM_NeedAssign			= 4, --�������
}
AddCheckLeakFilterObj(EAssignMode)

EAuctionStandard =
{
	eAS_GrayStandard   = 0, --��ɫ
	eAS_WhiteStandard  = 1, --��ɫ
	eAS_GreenStandard  = 2, --��ɫ
	eAS_BlueStandard   = 3, --��ɫ
	eAS_PurpleStandard = 4, --��ɫ
	eAS_OrangeStandard = 5, --��ɫ
	eAS_YellowStandard = 6, --��ɫ
	eAS_CyanStandard   = 7, --��ɫ
--	eAS_BlackStandard  = 2, --��ɫ
--	eAS_RedStandard    = 3, --��ɫ
}
AddCheckLeakFilterObj(EAuctionStandard)

-------------------------------------------------------------------------------
