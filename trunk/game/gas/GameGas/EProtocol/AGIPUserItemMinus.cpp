#include "AGIPUserItemMinus.h"

AGIPUserItemMinus::AGIPUserItemMinus(void)
: SysProtocol(AGIP_CURRENT_VERSION, CMD_USER_ITEM_MINUS, sizeof(SAGIPUserItemMinus))
{
}

AGIPUserItemMinus::~AGIPUserItemMinus(void)
{
}

int AGIPUserItemMinus::getUserID(uint32_t *punUserID)
{
    ASSERT(punUserID != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    *punUserID = htonl(pSAGIPUserItemMinus->un_User_ID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::getRoleID(uint32_t *punRoleID)
{
    ASSERT(punRoleID != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    *punRoleID = htonl(pSAGIPUserItemMinus->un_Role_ID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::getActivityID(uint32_t *punActivityID)
{
    ASSERT(punActivityID != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    *punActivityID = htonl(pSAGIPUserItemMinus->un_Activity_ID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::getItemCode(char *strItemCode)
{
    ASSERT(strItemCode != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    strncpy(strItemCode, pSAGIPUserItemMinus->str_Item_Code, AGIP_ITEM_CODE_LEN);
    return S_SUCCESS;
}

int AGIPUserItemMinus::getItemNum(int32_t *pnItemNum)
{
    ASSERT(pnItemNum != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    *pnItemNum = htonl(pSAGIPUserItemMinus->n_Item_Num);
    return S_SUCCESS;
}

int AGIPUserItemMinus::getItemGatewayID(uint32_t *punItemGatewayID)
{
    ASSERT(punItemGatewayID != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    *punItemGatewayID = htonl(pSAGIPUserItemMinus->un_Item_Gateway_ID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::setUserID(uint32_t unUserID)
{
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    pSAGIPUserItemMinus->un_User_ID = htonl(unUserID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::setRoleID(uint32_t unRoleID)
{
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    pSAGIPUserItemMinus->un_Role_ID = htonl(unRoleID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::setActivityID(uint32_t unActivityID)
{
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    pSAGIPUserItemMinus->un_Activity_ID = htonl(unActivityID);
    return S_SUCCESS;
}

int AGIPUserItemMinus::setItemCode(const char *strItemCode)
{
    ASSERT(strItemCode != NULL);
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    strncpy(pSAGIPUserItemMinus->str_Item_Code, strItemCode, AGIP_ITEM_CODE_LEN);
    return S_SUCCESS;
}

int AGIPUserItemMinus::setItemNum(int32_t nItemNum)
{
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    pSAGIPUserItemMinus->n_Item_Num = htonl(nItemNum);
    return S_SUCCESS;
}

int AGIPUserItemMinus::setItemGatewayID(uint32_t unItemGatewayID)
{
    SAGIPUserItemMinus *pSAGIPUserItemMinus = (SAGIPUserItemMinus *)m_pucPDU;
    pSAGIPUserItemMinus->un_Item_Gateway_ID = htonl(unItemGatewayID);
    return S_SUCCESS;
}

///////////////////////
// AGIPUserItemMinusRes

AGIPUserItemMinusRes::AGIPUserItemMinusRes(void)
: SysProtocol(AGIP_CURRENT_VERSION, CMD_USER_ITEM_MINUS_RES, sizeof(SAGIPUserItemMinusRes))
{

}

AGIPUserItemMinusRes::~AGIPUserItemMinusRes(void)
{

}

int AGIPUserItemMinusRes::getResultCode(int32_t *pnResultCode)
{
    ASSERT(pnResultCode != NULL);
    SAGIPUserItemMinusRes *pSAGIPUserItemMinusRes = (SAGIPUserItemMinusRes *)m_pucPDU;
    *pnResultCode = htonl(pSAGIPUserItemMinusRes->n_Result_Code);
    return S_SUCCESS;
}

int AGIPUserItemMinusRes::setResultCode(int32_t nResultCode)
{
    SAGIPUserItemMinusRes *pSAGIPUserItemMinusRes = (SAGIPUserItemMinusRes *)m_pucPDU;
    pSAGIPUserItemMinusRes->n_Result_Code = htonl(nResultCode);
    return S_SUCCESS;
}

