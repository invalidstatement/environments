------------------------------------------
//  Environments   //
//   CmdrMatthew   //
------------------------------------------

/*                        Environments Life Support System SDK
Environments.RegisterLSStorage(name, class, res, basevolume, basehealth, basemass)
   This function creates a new storage entity and registers its multipliers
	-name: the name of the new storage
	-class: the entity class of the new storage
	-res: a table in the format of {[amt] = "resource"} of the resources stored inside
	-basevolume: the volume used to calculate the multiplier
	-basehealth: the health given to the device at base volume
	-basemass: the mass of the storages at base volume
   
Environments.RegisterTool(name, filename, category, description, cleanupgroup, limit)
   This function creates a new tool.
    -name: this is the name of the tool you are creating
	-filename: this is the technical name of the tool used by the toolgun system
	-category: the name of the subtab the tool is added to
	-description: a description of what the tool does
	-cleanupgroup: the cleanup group used by the tool
	-limit: the max number of devices a user can spawn from this tool/cleanupgroup
   
Environments.RegisterDevice(toolname, genname, devname, class, model, skin, extra)
   This function adds a device to the tool specified with the specified model.
    -toolname: the name of the tool to add the device to
	-genname: the name of the type of generator
	-devname: the actual name of the generator you are adding
	-class: the class of the generator's entity
	-model: the model of the generator
	-skin: a number for its skin (if needed)
	-extra: any extra variable you need to pass on to the ent as ent.env_extra, can be any value
   */

Environments.RegisterLSStorage("Hydrocarbon Storage", "env_crude_storage", {[1000] = "Crude Oil"}, 4028, 200, 100)
Environments.RegisterLSStorage("Refined Storage", "env_oil_storage", {[1000] = "Oil"}, 4028, 100, 100)

Environments.RegisterLSStorage("Natural Gas Storage", "env_naturalgas_storage", {[1000] = "Natural Gas"}, 4028, 100, 100)

Environments.RegisterDevice("Mining", "Drill", "Basic Oil Drill", "planetary_drill", "models/slyfo/drillplatform.mdl")
Environments.RegisterDevice("Mining", "Laser", "Basic Mining Laser", "env_mining_laser", "models/slyfo/data_probe_launcher.mdl")


Environments.RegisterDevice("Mining", "Oil Storage", "Small Crude Oil Tank", "env_crude_storage", "models/slyfo/barrel_orange.mdl")
Environments.RegisterDevice("Mining", "Refined Oil Storage", "Small Refined Oil Tank", "env_oil_storage", "models/slyfo/barrel_refined.mdl")

Environments.RegisterDevice("Mining", "Gas Storage", "Small Natural Gas Tank", "env_naturalgas_storage", "models/slyfo/t-eng.mdl")

Environments.RegisterDevice("Mining", "Reactors", "Small Natural Gas Reactor", "env_naturalgas_reactor", "models/sbep_community/d12siesmiccharge.mdl")

hook.Add("AddTools", "MiningMod", function()
	Environments.RegisterTool("Mining", "EnvMiningMod", "Mining", "Used to spawn entities used for space mining.", "mining", 30)
end)



