--PS��10�������µĽ�ɫɾ�����ڽ����б���7�죻10������30�����±���20�죻31�����ϱ���60�졣
function GetDelCharSavedTimeByLevel(level)
	if level < 11 then
		return 7
	elseif level < 31 then
		return 20
	else
		return 60
	end
end