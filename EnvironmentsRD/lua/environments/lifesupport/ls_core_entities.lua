//Core Environments LS Entities/Devices

Environments.RegisterLSStorage("Steam Storage", "env_steam_storage", {[3600] = "steam"}, 4084, 400, 300)
Environments.RegisterLSStorage("Water Storage", "env_water_storage", {[3600] = "water"}, 4084, 400, 500)
Environments.RegisterLSStorage("Energy Storage", "env_energy_storage", {[3600] = "energy"}, 6021, 200, 5)
Environments.RegisterLSStorage("Oxygen Storage", "env_oxygen_storage", {[4600] = "oxygen"}, 4084, 100, 10)
Environments.RegisterLSStorage("Hydrogen Storage", "env_hydrogen_storage", {[4600] = "hydrogen"}, 4084, 100, 10)
Environments.RegisterLSStorage("Nitrogen Storage", "env_nitrogen_storage", {[4600] = "nitrogen"}, 4084, 100, 10)
Environments.RegisterLSStorage("CO2 Storage", "env_co2_storage", {[4600] = "carbon dioxide"}, 4084, 100, 10)
Environments.RegisterLSStorage("Resource Cache", "env_cache_storage", {[4601] = "carbon dioxide",[4600] = "oxygen",[4602] = "hydrogen",[4603] = "nitrogen",[4599] = "water",[4598] = "steam",[4604] = "energy"}, 4084, 100, 10)

Environments.RegisterLSEntity("Water Heater","env_water_heater",{"water","energy"},{"steam"},function(self) local mult = self:GetMultiplier()*self.multiplier local amt = self:ConsumeResource("water", 200) or 0 amt = self:ConsumeResource("energy",amt*1.5)  self:SupplyResource("steam", amt) end, 70000, 300, 300)

//Generator Tool
Environments.RegisterDevice("Generators", "Fusion Generator", "Huge Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_huge.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_large.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Medium Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_medium.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small Fusion Reactor", "generator_fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_small.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small SBEP Reactor", "generator_fusion", "models/Punisher239/punisher239_reactor_small.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large SBEP Reactor", "generator_fusion", "models/Punisher239/punisher239_reactor_big.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small Pallet Reactor", "generator_fusion", "models/Slyfo/forklift_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large Crate Reactor", "generator_fusion", "models/Slyfo/crate_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Classic Reactor", "generator_fusion", "models/props_c17/substation_circuitbreaker01a.mdl")

Environments.RegisterDevice("Generators", "Solar Panel", "Huge Circular Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Large Circular Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_c_large.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Medium Circular Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_c_medium.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Giant Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Huge Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_huge.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Large Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_large.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Medium Solar Panel", "generator_solar", "models/ce_ls3additional/solar_generator/solar_generator_medium.mdl")

Environments.RegisterDevice("Generators", "Water Pump", "Large Water Pump", "generator_water", "models/chipstiks_ls3_models/LargeH2OPump/largeh2opump.mdl")
Environments.RegisterDevice("Generators", "Water Pump", "Small Water Pump", "generator_water", "models/props_phx/life_support/gen_water.mdl")

Environments.RegisterDevice("Generators", "Oxygen Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", 0, "oxygen")
Environments.RegisterDevice("Generators", "Oxygen Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "oxygen")
Environments.RegisterDevice("Generators", "Oxygen Compressor", "Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor_large.mdl", 0, "oxygen")

Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", 3, "nitrogen")
Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "nitrogen")
Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor_large.mdl", 3, "nitrogen")

Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", 2, "hydrogen")
Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "hydrogen")
Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor_large.mdl", 2, "hydrogen")

Environments.RegisterDevice("Generators", "CO2 Compressor", "Compact Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor.mdl", 1, "carbon dioxide")
Environments.RegisterDevice("Generators", "CO2 Compressor", "Large Air Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "carbon dioxide")
Environments.RegisterDevice("Generators", "CO2 Compressor", "Air Compressor", "env_air_compressor", "models/ce_ls3additional/compressor/compressor_large.mdl", 1, "carbon dioxide")

Environments.RegisterDevice("Generators", "Water Splitter", "Water Splitter", "generator_water_to_air", "models/ce_ls3additional/water_air_extractor/water_air_extractor.mdl")
Environments.RegisterDevice("Generators", "Water Splitter", "Electrolysis Generator", "generator_water_to_air", "models/Slyfo/electrolysis_gen.mdl")

Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell", "Small Fuel Cell", "generator_hydrogen_fuel_cell", "models/Slyfo/electrolysis_gen.mdl")

Environments.RegisterDevice("Generators", "Water Heater", "Water Heater", "env_water_heater", "models/ce_ls3additional/water_heater/water_heater.mdl")

//Storage Tool
Environments.RegisterDevice("Storages", "Water Storage", "Massive Water Tank", "env_water_storage", "models/props/de_nuke/storagetank.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Large Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_large.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Medium Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_medium.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Small Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_small.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Tiny Water Tank", "env_water_storage", "models/ce_ls3additional/resource_tanks/resource_tank_tiny.mdl")

Environments.RegisterDevice("Storages", "Energy Storage", "Large Battery", "env_energy_storage", "models/props_phx/life_support/battery_large.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Medium Battery", "env_energy_storage", "models/props_phx/life_support/battery_medium.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Small Battery", "env_energy_storage", "models/props_phx/life_support/battery_small.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Capacitor", "env_energy_storage", "models/props_c17/substation_stripebox01a.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Backup Battery", "env_energy_storage", "models/props_c17/substation_transformer01a.mdl")

Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Storage", "env_oxygen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Oxygen Canister", "env_oxygen_storage", "models/props_phx/life_support/canister_small.mdl")

Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Storage", "env_nitrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Oxygen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_large.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Medium Oxygen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_medium.mdl", 1)
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Small Oxygen Canister", "env_nitrogen_storage", "models/props_phx/life_support/canister_small.mdl", 1)

Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Storage", "env_hydrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Oxygen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_large.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Medium Oxygen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_medium.mdl", 2)
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Small Hydrogen Canister", "env_hydrogen_storage", "models/props_phx/life_support/canister_small.mdl", 2)

Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Storage", "env_co2_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "CO2 Storage", "Large Oxygen Canister", "env_co2_storage", "models/props_phx/life_support/canister_large.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Medium Oxygen Canister", "env_co2_storage", "models/props_phx/life_support/canister_medium.mdl", 3)
Environments.RegisterDevice("Storages", "CO2 Storage", "Small Oxygen Canister", "env_co2_storage", "models/props_phx/life_support/canister_small.mdl", 3)

Environments.RegisterDevice("Storages", "Steam Storage", "Large Steam Tank", "env_steam_storage", "models/chipstiks_ls3_models/LargeSteamTank/largesteamtank.mdl")

Environments.RegisterDevice("Storages", "Resource Cache", "Large Cache", "env_cache_storage", "models/ce_ls3additional/resource_cache/resource_cache_large.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Medium Cache", "env_cache_storage", "models/ce_ls3additional/resource_cache/resource_cache_medium.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Small Cache", "env_cache_storage", "models/ce_ls3additional/resource_cache/resource_cache_small.mdl")

Environments.RegisterDevice("Storages", "Admin Cache", "Small Admin Cache", "environments_admincache", "models/ce_ls3additional/resource_cache/resource_cache_small.mdl")

//Life Support Tool
Environments.RegisterDevice("Life Support", "Suit Dispenser", "Suit Dispenser", "suit_dispenser", "models/props_combine/combine_emitter01.mdl")
Environments.RegisterDevice("Life Support", "LS Core", "LS Core", "env_lscore", "models/SBEP_community/d12airscrubber.mdl")
Environments.RegisterDevice("Life Support", "Atmospheric Probe", "Atmospheric Probe", "env_probe", "models/props_combine/combine_mine01.mdl")
Environments.RegisterDevice("Life Support", "Terraformer", "Terraformer", "environments_terraformer", "models/chipstiks_ls3_models/Terraformer/terraformer.mdl")
