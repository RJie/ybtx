#include "AGIPGWDataReport.h"

AGIPGWDataReport::AGIPGWDataReport(void)
: SysProtocol(AGIP_CURRENT_VERSION, CMD_GW_DATA_REPORT, sizeof(SAGIPGWDataReport) - sizeof(DATA_INFO))
{
}

AGIPGWDataReport::~AGIPGWDataReport(void)
{
}

int AGIPGWDataReport::initialize()
{
    int nRetCode = E_ERROR;

    m_usTotalLength = sizeof(SAGIPGWDataReport) - sizeof(DATA_INFO);
    nRetCode = SysProtocol::initialize();
    ASSERT(nRetCode == S_SUCCESS);

    return S_SUCCESS;
}


int AGIPGWDataReport::getGatewayID(uint32_t *punGatewayID)
{
    ASSERT(punGatewayID != NULL);
    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    *punGatewayID = htonl(pSAGIPGWDataReport->un_Gateway_ID);
    return S_SUCCESS;
}

int AGIPGWDataReport::getServerID(uint32_t *punServerID)
{
    ASSERT(punServerID != NULL);
    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    *punServerID = htonl(pSAGIPGWDataReport->un_Server_ID);
    return S_SUCCESS;
}

int AGIPGWDataReport::getDataCount(int32_t *pnDataCount)
{
    ASSERT(pnDataCount != NULL);
    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    *pnDataCount = htonl(pSAGIPGWDataReport->n_Data_Count);
    return S_SUCCESS;
}

int AGIPGWDataReport::getDataInfo(int32_t nIndex, int32_t *pnDataType, int32_t *pnDataValue)
{
    int nResult  = E_PDU_INVALID_FIELD;
    int nRetCode = E_PDU_INVALID_FIELD;

    DATA_INFO *pDataInfoBuffer = NULL;
    int32_t nDataCount = 0;

    ASSERT(pnDataType != NULL && pnDataValue != NULL);
    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    nDataCount = htonl(pSAGIPGWDataReport->n_Data_Count);
    if (
        (nIndex < 0) ||
        (nIndex >= nDataCount)
        )
    {
        goto ExitError;
    }
    pDataInfoBuffer = (DATA_INFO *)&pSAGIPGWDataReport->n_Data_Type;
    pDataInfoBuffer += nIndex;

    *pnDataType  = htonl(pSAGIPGWDataReport->n_Data_Type);
    *pnDataValue = htonl(pSAGIPGWDataReport->n_Data_Value);

    nResult = S_SUCCESS;
ExitError:
    return nResult;
}

int AGIPGWDataReport::getDataInfo(int32_t nIndex, DATA_INFO *pDataInfo)
{
    ASSERT(pDataInfo != NULL);
    return this->getDataInfo(nIndex, &pDataInfo->nDataType, &pDataInfo->nDataValue);
}

int AGIPGWDataReport::setGatewayID(uint32_t unGatewayID)
{
    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    pSAGIPGWDataReport->un_Gateway_ID = htonl(unGatewayID);
    return S_SUCCESS;
}

int AGIPGWDataReport::setServerID(uint32_t unServerID)
{
    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    pSAGIPGWDataReport->un_Server_ID = htonl(unServerID);
    return S_SUCCESS;
}

int AGIPGWDataReport::setDataCount(int32_t nDataCount)
{
    ASSERT(false && "Data Count is calculated automatically. Pls use addDataInfo() method!!");
    return E_ERROR;
}

int AGIPGWDataReport::addDataInfo(int32_t nDataType, int32_t nDataValue)
{
    int nResult  = E_PDU_INVALID_FIELD;
    int nRetCode = E_PDU_INVALID_FIELD;

    DATA_INFO *pDataInfoBuffer = NULL;
    int32_t nDataCount = 0;

    SAGIPGWDataReport *pSAGIPGWDataReport = (SAGIPGWDataReport *)m_pucPDU;
    nDataCount = htonl(pSAGIPGWDataReport->n_Data_Count);

    pDataInfoBuffer = (DATA_INFO *)&pSAGIPGWDataReport->n_Data_Type;
    pDataInfoBuffer += nDataCount;

    pDataInfoBuffer->nDataType  = htonl(nDataType);
    pDataInfoBuffer->nDataValue = htonl(nDataValue);

    nDataCount++;
    pSAGIPGWDataReport->n_Data_Count = htonl(nDataCount);
    
    m_usTotalLength += sizeof(DATA_INFO);
    this->setTotalLength(m_usTotalLength);

    nResult = S_SUCCESS;
    //ExitError:
    return nResult;
}

int AGIPGWDataReport::addDataInfo(const DATA_INFO *pDataInfo)
{
    ASSERT(pDataInfo != NULL);
    return this->addDataInfo(pDataInfo->nDataType, pDataInfo->nDataValue);
}

int AGIPGWDataReport::showInfo()
{
    int nRetCode        = E_ERROR;

    uint32_t  unGatewayID = 0;
    uint32_t  unServerID  = 0;
    int32_t   nDataCount  = 0;
    int32_t   nDataType   = 0;
    int32_t   nDataValue  = 0;

    SysProtocol::showInfo();
    nRetCode = getGatewayID(&unGatewayID);
    nRetCode = getGatewayID(&unServerID);
    nRetCode = getDataCount(&nDataCount);
    printf("--------------------------------------------------------AGIPGWDataReport\n");
    printf("Gateway_ID:\t%u\n", unGatewayID);
    printf("Server_ID:\t%u\n", unServerID);
    printf("Data_Count:\t%d\n", nDataCount);
    for (int i = 0; i < nDataCount; i++)
    {
        nRetCode = getDataInfo(i, &nDataType, &nDataValue);
        printf("[%d]Data_Type:\t%d, \t%d\n", i, nDataType, nDataValue);
    }

    printf("--------------------------------------------------------AGIPGWDataReport\n");
    return S_SUCCESS;

}
///////////////////////
//AGIPGWDataReportRes
AGIPGWDataReportRes::AGIPGWDataReportRes(void)
: SysProtocol(AGIP_CURRENT_VERSION, CMD_GW_DATA_REPORT_RES, sizeof(SAGIPGWDataReportRes))
{

}

AGIPGWDataReportRes::~AGIPGWDataReportRes(void)
{

}

int AGIPGWDataReportRes::getResultCode(int32_t *pnResultCode)
{
    ASSERT(pnResultCode != NULL);
    SAGIPGWDataReportRes *pSAGIPGWDataReportRes = (SAGIPGWDataReportRes *)m_pucPDU;
    *pnResultCode = htonl(pSAGIPGWDataReportRes->n_Result_Code);
    return S_SUCCESS;
}

int AGIPGWDataReportRes::setResultCode(int32_t nResultCode)
{
    SAGIPGWDataReportRes *pSAGIPGWDataReportRes = (SAGIPGWDataReportRes *)m_pucPDU;
    pSAGIPGWDataReportRes->n_Result_Code = htonl(nResultCode);
    return S_SUCCESS;
}

int AGIPGWDataReportRes::showInfo()
{
    int nRetCode        = E_ERROR;

    int32_t   nResultCode = 0;

    SysProtocol::showInfo();
    nRetCode = getResultCode(&nResultCode);

    printf("--------------------------------------------------------AGIPGWDataReportRes\n");
    printf("Result_Code:\t%d\n", nResultCode);

    printf("--------------------------------------------------------AGIPGWDataReportRes\n");
    return S_SUCCESS;
}

