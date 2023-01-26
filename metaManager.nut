require("busStationManager.nut");
require("busLineManager.nut");


class MetaManager{

}

function MetaManager::optimizeBusNetworkIn(cityID){
    // only calls busLineManager we have more than station cost + bus cost in bank
    local bankbalance = AICompany.GetBankBalance(AICompany.COMPANY_SELF);
    local engine_cost = AIEngine.GetPrice(BusLineManager.usedEngine());
    local bus_station_cost = AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_BUS_STOP);

    local int = AICompany.GetLoanInterval();

    local depot = BusLineManager.getDepotInTown(cityID);
    local station_list = AIStationList(AIStation.STATION_BUS_STOP);

    station_list.Valuate(AIStation.GetNearestTown);
    station_list.KeepValue(cityID);
    station_list.Valuate(AIStation.GetCargoWaiting, 0)

    BusLineManager.deleteObsolete(cityID);

    if(station_list.Begin()> 3*60){
        print("###########################")
        AICompany.SetLoanAmount(int + AICompany.GetLoanAmount());
        vehicle = AIVehicle.BuildVehicle(depot,engine);
        print("Took loan, crowded Order, built vehicle "+ AIVehicle.GetName(vehicle)+ " in depot: ")
        BusLineManager.applyOrderToCrowded(vehicle, cityID, depot);
        AIVehicle.StartStopVehicle(vehicle);
        this.sleep(100);
    }
    if (bankbalance > engine_cost + 1.5*bus_station_cost){
        BusStationManager.ManageGrid(cityID)
    }

    if (bankbalance > 2*engine_cost + 1.5*bus_station_cost){
        BusLineManager.ManageLinesAndBuild(cityID);
        }
}