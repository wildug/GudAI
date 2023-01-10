require("busStationManager.nut");
require("busLineManager.nut");


class MetaManager{

}

function MetaManager::optimizeBusNetworkIn(cityID){
    // only calls busLineManager we have more than station cost + bus cost in bank
    local bankbalance = AICompany.GetBankBalance(AICompany.COMPANY_SELF);
    local engine_cost = AIEngine.GetPrice(BusLineManager.usedEngine());
    local bus_station_cost = AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_BUS_STOP);

    if (bankbalance > engine_cost + 1.5*bus_station_cost){
        BusStationManager.ManageGrid(cityID)
    }

    if (bankbalance > 2*engine_cost + 1.5*bus_station_cost){
        BusLineManager.ManageLinesAndBuild(cityID);
        }   
    else{
        local depot = BusLineManager.getDepotInTown(cityID)
        local vehicle = AIVehicleList_Depot(depot).Begin()
        BusLineManager.applySemiRandomOrder(vehicle, cityID, depot)
        }
}