cfg_load "image_res/Image_Client"

CImageMgr = class()

function CImageMgr:GetImagePath(ImageID)
	ImageID = tonumber(ImageID)
	assert(Image_Client(ImageID),ImageID .. "�ֶ���Image_Client���ñ�����")
	local ImagePath = Image_Client(ImageID,"ImagePath")
	return ImagePath
end