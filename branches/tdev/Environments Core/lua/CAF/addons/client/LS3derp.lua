local RD = {}

local status = false

--The Class
/**
	The Constructor for this Custom Addon Class
*/
function RD.__Construct()
	status = true
	return true , "No Implementation yet"
end

/**
	The Destructor for this Custom Addon Class
*/
function RD.__Destruct()
	return false , "Can't disable"
end

/**
	Get the required Addons for this Addon Class
*/
function RD.GetRequiredAddons()
	return {"Resource Distribution"}
end

/**
	Get the Boolean Status from this Addon Class
*/
function RD.GetStatus()
	return true
end

/**
	Get the Version of this Custom Addon Class
*/
function RD.GetVersion()
	return 3.05, "Beta"
end

local isuptodatecheck;
/**
	Update check
*/
function RD.IsUpToDate(callBackfn)
	return true
end

/**
	Get any custom options this Custom Addon Class might have
*/
function RD.GetExtraOptions()
	return {}
end

/**
	Gets a menu from this Custom Addon Class
*/
function RD.GetMenu(menutype, menuname)//Name is nil for main menu, String for others
	return {}
end

/**
	Get the Custom String Status from this Addon Class
*/
function RD.GetCustomStatus()
	return ;
end

/**
	Can the Status of the addon be changed?
*/
function RD.CanChangeStatus()
	return false;
end

/**
	Returns a table containing the Description of this addon
*/
function RD.GetDescription()
	return {
				"Life Support",
				"",
				""
			}
end

CAF.RegisterAddon("Life Support", RD, "2")


