cfg_load "Url/Url_Common"

CUrlMgr = class()

function CUrlMgr:GetUrl(nUrlIndex)
	assert(Url_Common(nUrlIndex), nUrlIndex .. "�ֶ���Url_Common���ñ�����")
	return Url_Common(nUrlIndex, "UrlValue")
end