gac_gas_require "framework/common/CMoneyInc"


--��Ǯ�ĵط��������ڴ˱���д��Ӧ����
--["FunName"]��["Description"] ��ÿ�����ܶ��������
--�����Ǵ����ĸ�ϵͳ��["FunName"]Ҳ�Ǵ����ĸ�ϵͳ
--�����Ĳ��������ĸ�ϵͳ���ĸ�����
--["Description"]�����������������������erating����õģ�����ֻ�п�Ǯ������õ���ֻ����Ǯ�Ĺ��ܿ��Բ��������
function CMoney:Ctor()
	self.m_tblMoneyFun =
		{	
			["NpcShop"] 		= {["FunName"]= "NpcShop",["Description"]= "Npc��ͨ�̵�",["Sell"] = "Sell",["Buy"] = "Buy",["BuyBack"] = "BuyBack"},
			["CSM"] 				= {["FunName"]= "CSM",["Description"]= "�����й���Ѻ�˰��",["AddSellOrder"]= "AddSellOrder",["AddBuyOrder"]= "AddBuyOrder",["CancelBuyOrder"]= "CancelBuyOrder",["BuyOrder"]= "BuyOrder"},
			["Quest"] 			= {["FunName"]= "Quest",["Description"]= "�Ⱦ�����",["MoneyAward"]= "MoneyAward",["Drink"] = "Drink"},
			["GMcmd"] 			= {["FunName"]= "GMcmd",["Description"]= "gmָ��",["AddMoney"] = "AddMoney",["AddBindingTicket"] = "AddBindingTicket",["AddBindingMoney"] = "AddBindingMoney",
										["AddTicket"] = "AddTicket"},
			["GmTools"] 		= {["FunName"]= "GmTools",["Description"]= "gm����",["AddMoney"] = "AddMoney",["AddTicket"] = "AddTicket"},
			["Depot"] 			= {["FunName"]= "Depot",["Description"]= "�ֿ��ȡǮ",["SaveMoney"] = "SaveMoney",["GetMoney"] = "GetMoney",},
			["Mail"] 				= {["FunName"]= "Mail",["Description"]= "�ʼ�����Ѻ�˰��",["GetMoney"] = "GetMoney",["SendMail"] = "SendMail"},
			["Tong"] 				= {["FunName"]= "Tong",["Description"]= "Ӷ��С�Ӿ�Ǯ",["Contribut"] = "Contribut",["RegistTong"] = "RegistTong"},
			["ArmyCorps"] 	= {["FunName"]= "ArmyCorps",["Description"]= "Ӷ���Ŵ�������",["RegistArmyCorps"] = "RegistArmyCorps"},
			["fuben"] 			= {["FunName"]= "fuben",["Description"]= "��ᱦ����",["Daduobao"] = "Daduobao"},
			["PlayerTran"] 	= {["FunName"]= "PlayerTran",["Description"]= "��ҽ���˰",["PlayerTran"] = "PlayerTran"},
			["Trap"] 				= {["FunName"]= "Trap",["Description"]= "��trap��Ǯ",["TrapAddMoney"] = "TrapAddMoney"},
			["LearnSkill"] 	= {["FunName"]= "LearnSkill",["Description"]= "����ѧϰ",["LearnSkill"] = "LearnSkill"},
			["EquipDurability"] = {["FunName"] = "EquipDurability",["Description"]= "װ������", ["RenewEquip"] = "RenewEquip"},
			["ToolMall"] = {["FunName"]= "ToolMall" ,["Description"]= "�����̳�", ["BuyItemForSelf"] = "BuyItemForSelf", ["BuyItemForOther"] = "BuyItemForOther", ["DrawBalance"] = "DrawBalance"},
			["LiveSkill"] = {["FunName"]= "LiveSkill" ,["Description"]= "����ܺ�ר��ѧϰ", ["LearnSkill"] = "LearnSkill"},
			["Afflatus"] = {["FunName"] = "Afflatus",["Description"]= "�����߾���", ["ExChgMoney"] = "ExChgMoney"},
			["Stone"] = {["FunName"] = "Stone",["Description"]= "��ʯϵͳ", ["SynthesisExpend"] = "SynthesisExpend", ["RemoveStone"] = "RemoveStone"},
			["Chat"] = {["FunName"] = "Chat",["Description"]= "Ƶ�������շ�", ["WorldChat"] = "WorldChat",["ChuanSheng"] = "ChuanSheng"},
			["ContractManufacture"] = {["FunName"] = "ContractManufacture",["Description"]= "����������Ѻ�˰��", ["AddContractOrder"] = "AddContractOrder", ["CancelContractOrder"] = "CancelContractOrder"},
			["RobResourceAward"] = {["FunName"] = "RobResourceAward",["Description"]= "ռ����Դ��Ӷ��С�ӳ���ȡ�ǰ󶨽�", ["HeaderAward"] = "HeaderAward"},
			["SpecialTransport"] = {["FunName"] = "SpecialTransport",["Description"]= "����NPC��������", ["SpecialNpc"] = "SpecialNpc"},
			["ClearTalent"] = {["FunName"] = "ClearTalent",["Description"]= "���תְ", ["ClearTalent"] = "ClearTalent"},
			["ArmorPieceEnactment"] = {["FunName"] = "ArmorPieceEnactment",["Description"]= "װ����Ƕ����Ƭ��Ǯ", ["ArmorPieceEnactment"] = "ArmorPieceEnactment"},
			["SpecialTransportUnBind"] = {["FunName"] = "SpecialTransportUnBind",["Description"]= "����NPC���ͷǰ󶨽��", ["SpecialTransportUnBind"] = "SpecialTransportUnBind"},
			["EquipSuperadd"] = {["FunName"] = "EquipSuperadd",["Description"]= "װ��׷�����Ľ�Ǯ", ["EquipSuperadd"] = "EquipSuperadd"},
			["WebShop"] = {["FunName"] = "WebShop",["Description"]= "WebShop����", ["buy"] = "buy"},
			["PurchasingAgent"] = {["FunName"] = "PurchasingAgent",["Description"]= "���й����",["CancelBuyOrder"] = "CancelBuyOrder",["AddBuyOrder"] = "AddBuyOrder"},
			["GMCompenate"] = {["FunName"] = "GMCompenate",["AddMoney"] = "AddMoney"},
			["BuyCoupons"] = {["FunName"] = "BuyCoupons",["Description"]= "�����ȯ",["BuyCouponsUsingJinBi"] = "BuyCouponsUsingJinBi"},
			["LearnTongTech"] ={["FunName"]="LearnTongTech", ["Description"]="ѧϰӶ��С�ӿƼ�",["LearnTongTech"] ="LearnTongTech"},
	}
end

function CMoney:GetFuncInfo(sFuncName)
	return self.m_tblMoneyFun[sFuncName]
end

--��ĳ������ͭ����ɽ�����ͭ��������Ȼ�󷵻�
function CMoney:ChangeMoneyToGoldAndArgent(money)
	local Money		= money or 0
	local nMoney	= tonumber(Money)
	local nGold		= math.floor(nMoney / 10000) 
	local nSilver	= math.floor( (nMoney - nGold * 10000) / 100)
	local nCopper	= math.floor((nMoney - nGold * 10000 - nSilver * 100))
	return nGold, nSilver, nCopper
end

--��һ��������ͭת��Ϊ����ͭ��ʽ�����ַ�����ʽ����
--�� 		EGoldType.GoldBar ���� nil
--���(RMB) EGoldType.GoldCoin 	
function CMoney:ChangeMoneyToString(nMoney,eGoldType)
	local nGold, nSilver, nCopper = self:ChangeMoneyToGoldAndArgent(nMoney)
	local str = ""
	if eGoldType then 
		str = ( nGold <= 0 and "" or nGold .. CTextureFontMgr_Inst():GetEmtStrByIdx("#1001") )
					.. ( (nSilver <= 0 and nGold <= 0) and "" or nSilver .. CTextureFontMgr_Inst():GetEmtStrByIdx("#1002") )
					.. ( nCopper .. CTextureFontMgr_Inst():GetEmtStrByIdx("#1003") )		
	else
		str = ( nGold <= 0 and "" or nGold .. CTextureFontMgr_Inst():GetEmtStrByIdx("#1106") )
					.. ( (nSilver <= 0 and nGold <= 0) and "" or nSilver .. CTextureFontMgr_Inst():GetEmtStrByIdx("#1107") )
					.. ( nCopper .. CTextureFontMgr_Inst():GetEmtStrByIdx("#1108") )
	end
				
	return str
end

--�ѽ���ͭת��Ϊͭ
function CMoney:ChangeGoldAndArgentToMoney(Gold, Argent, Copper)
	local nGold	= (tonumber(Gold)) or 0
	local nArgent =  (tonumber(Argent)) or 0
	local nCopper = (tonumber(Copper)) or 0
	
	return nGold * 10000 + nArgent * 100 + nCopper
end

function CMoney:ShowMoneyInfo(nMoney,tblWnd)
	local GoldText,GoldBtn,ArgentText,ArgentBtn,CopperText,CopperdBtn = unpack(tblWnd)
	
	local jinCount, yinCount, tongCount = self:ChangeMoneyToGoldAndArgent(nMoney)
	
	CopperText:SetWndText(tongCount)
	
	if jinCount > 0 then
		GoldBtn:ShowWnd(true)
		GoldText:ShowWnd(true)
		
		ArgentText:ShowWnd(true)
		ArgentBtn:ShowWnd(true)
		
		GoldText:SetWndText(jinCount)
		ArgentText:SetWndText(yinCount)
	else
		
		GoldBtn:ShowWnd(false)
		GoldText:ShowWnd(false)
		GoldText:SetWndText("")
		
		if yinCount > 0 then
			ArgentText:ShowWnd(true)
			ArgentBtn:ShowWnd(true)
			ArgentText:SetWndText(yinCount)
		else
			ArgentText:ShowWnd(false)
			ArgentBtn:ShowWnd(false)
			ArgentText:SetWndText("")
		end
	end
end

--�������Ľ�Ǯ�Ƿ����Ҫ�󣬲��������ڶ��󣬴������ͣ�����߹��������ȣ�1������2��ͭ��2��
--�������ݰ�����
--@��������������ֵĶ�����@����������ո�@����ͭΪ������Ϊ2λ��@����������С��
function CMoney:CheckInputMoneyValidate(wndObj, wndType,funType)
	local inputText = wndObj:GetWndText()
	local findResult = string.find(inputText, "[^0123456789]")
	if  findResult ~= nil  then
		inputText = string.sub(inputText, 1, findResult-1)
		wndObj:SetWndText( inputText )
	end
	local inputCount = tonumber( inputText )
	if inputCount == nil or inputCount <= 0 then 	--������Ƿ����ֵĶ���
		wndObj:SetWndText("")
		inputCount = 0
		return
	end
	if wndType == 1 and inputCount > 999999 then
	    local validateMoney = string.sub(inputText, 1, 6 )
    	wndObj:SetWndText(validateMoney)
	    if wndObj.m_MsgBox == nil then
	        local function CallBack(Context,Button)
	            if(Button == MB_BtnOK) then
	                wndObj.m_MsgBox:DestroyWnd()
	                wndObj.m_MsgBox = nil
	            end
	        end
	        	if funType == "SendMail" then
	        		 wndObj.m_MsgBox = MessageBox(wndObj, MsgBoxMsg(255), MB_BtnOK, CallBack)
	        	elseif funType == "ContributeMoney" then
	        		--
	        	else
            	wndObj.m_MsgBox = MessageBox(wndObj, MsgBoxMsg(160), MB_BtnOK, CallBack)
            end
            return 
       end
	end
	if wndType == 2 and inputCount > 99 then --��������������ͭ�����ܳ���99	 		
		local validateMoney = string.sub(inputText, 1, 2 )
		wndObj:SetWndText(validateMoney)
		return
	end
end

--����ϵͳ�շѵļ��㣻�����������۸���Ʒ��Ŀ, �ۿۣ������ۿ�
--�����ڼ��۽�������ӳ��ۺ��չ�����ʱ������Ҫ�ķ���
function CMoney:CalculateTotalFee(price, count, discount, otherDiscount)
    assert(IsNumber(price) and IsNumber(discount) and IsNumber(otherDiscount))
    local totalFee = math.ceil(price * count * discount * otherDiscount)
    if totalFee < 10 then
        return 10
    else
        return totalFee
    end
end

function CMoney:ShowMoneyInfoWithoutShowingWndFalse(nMoney,tblWnd)
	local GoldText,ArgentText,CopperText = unpack(tblWnd)
	
	local jinCount, yinCount, tongCount = self:ChangeMoneyToGoldAndArgent(nMoney)
	CopperText:SetWndText(tongCount)

	if jinCount > 0 then
		GoldText:SetWndText(jinCount)
		ArgentText:SetWndText(yinCount)
	else
	    GoldText:SetWndText("")
		if yinCount > 0 then
			ArgentText:SetWndText(yinCount)
		else
			ArgentText:SetWndText("")
		end
	end
end

function CMoney:GetAftertaxMoney(Money)
	if tonumber(Money) == nil then
		return 0
	end
	return math.ceil(Money*0.95)
end

--�ж����ӵ�еĽ�Ǯ����ȡϵͳ��������Ƿ��㹻
function CMoney:CheckPayingSysFeeEnough(totalFee)
    if totalFee > g_MainPlayer.m_nBindMoney then 
    	if totalFee > g_MainPlayer.m_nMoney + g_MainPlayer.m_nBindMoney then
    		return false, 156
    	else
            return true, 161
    	end
    end
    return true
end

g_MoneyMgr = g_MoneyMgr or CMoney:new()
