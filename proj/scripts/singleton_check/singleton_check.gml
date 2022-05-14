/// @func singleton_check()
/// @desc checks singleton
function singleton_check()
{
	singletonInit = false;
	if (instance_number(object_index) > 1)
	{
		bunger_log("SINGLETON DUPLICATE ", id, ":`", object_get_name(object_index), "` DELETED");
		instance_destroy(id);
	}
	else
		singletonInit = true;
}