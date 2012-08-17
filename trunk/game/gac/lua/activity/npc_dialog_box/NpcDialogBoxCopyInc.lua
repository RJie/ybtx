CNpcDialogBoxCopy = class( SQRDialog )

CNpcDialogBoxCopy.DlgTextType =
{
	["����"] = {18001, 18007},
	["����"] = {18002, 18008},
	["���"] = {18003, 18009},
	["��ҩ"] = {18004, 18010},
	["�ɿ�"] = {18005, 18011},
	["����"] = {18006, 18012},
	["����"] = {18013, 18014},
}

CNpcDialogBoxCopy.ENpcShowDlg ={}

CNpcDialogBoxCopy.ENpcShowDlg["����"] =
{
	[1] = {GetStaticTextClient(3015), false},	--"ѧϰ����"
	[2] = {GetStaticTextClient(3016), true},	--"��������"
	[3] = {GetStaticTextClient(3017), true},	--"��������"
	[4] = {GetStaticTextClient(3018), true},	--"����ר��ѧϰ"
}

CNpcDialogBoxCopy.ENpcShowDlg["����"] =
{
	[1] = {GetStaticTextClient(3019), false},	--"ѧϰ����"
	[2] = {GetStaticTextClient(3020), true},	--"��������"
	[3] = {GetStaticTextClient(3021), true},	--"��������"
	[4] = {GetStaticTextClient(3022), true},	--"����ר��ѧϰ"
}

CNpcDialogBoxCopy.ENpcShowDlg["���"] =
{
	[1] = {GetStaticTextClient(3023), false},	--"ѧϰ���"
	[2] = {GetStaticTextClient(3024), true},	--"�������"
	[3] = {GetStaticTextClient(3025), true},	--"�������"
}

CNpcDialogBoxCopy.ENpcShowDlg["��ҩ"] =
{
	[1] = {GetStaticTextClient(3026), false},	--"ѧϰ��ҩ"
	[2] = {GetStaticTextClient(3027), true},	--"������ҩ"
	[3] = {GetStaticTextClient(3028), true},	--"������ҩ"
}

CNpcDialogBoxCopy.ENpcShowDlg["�ɿ�"] =
{
	[1] = {GetStaticTextClient(3029), false},	--"ѧϰ�ɿ�"
	[2] = {GetStaticTextClient(3030), true},	--"�����ɿ�"
	[3] = {GetStaticTextClient(3031), true},	--"�����ɿ�"
}

CNpcDialogBoxCopy.ENpcShowDlg["����"] =
{
	[1] = {GetStaticTextClient(3032), false},	--"ѧϰ����"
	[2] = {GetStaticTextClient(3033), true},	--"��������"
	[3] = {GetStaticTextClient(3034), true},	--"��������"
}

CNpcDialogBoxCopy.ENpcShowDlg["����"] =
{
	[1] = {GetStaticTextClient(3038), false},	--"ѧϰ����"
	[2] = {GetStaticTextClient(3039), true},	--"��������"
	[3] = {GetStaticTextClient(3040), true},	--"��������"
	[4] = {GetStaticTextClient(3041), true},	--"����ר��ѧϰ"
}

function CNpcDialogBoxCopy:InitFunLink()
	self.linkfun		= {}
	self.linkfun[1]	= self.Learn
	self.linkfun[2]	= self.Upgrade
	self.linkfun[3]	= self.Wash
	self.linkfun[4]	= self.OpenExpert
end
