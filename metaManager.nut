require("busStationManager.nut");
require("busLineManager.nut");
require("utils.nut")

class MetaManager{

}

function MetaManager::optimizeBusNetworkIn(cityID){
    // only calls busLineManager we have more than station cost + bus cost in bank
    local bankbalance = AICompany.GetBankBalance(AICompany.COMPANY_SELF);
    local engine = BusLineManager.usedEngine()
    local engine_cost = AIEngine.GetPrice(engine);
    local bus_station_cost = AIRoad.GetBuildCost(AIRoad.ROADTYPE_ROAD, AIRoad.BT_BUS_STOP);

    local int = AICompany.GetLoanInterval();

    local depot = BusLineManager.getDepotInTown(cityID);
    local station_list = AIStationList(AIStation.STATION_BUS_STOP);

    station_list.Valuate(AIStation.GetNearestTown);
    station_list.KeepValue(cityID);

    print("!!!!!!!!!!!!!!!!!!")
    foreach(item, value in station_list){
        print(item)
        print(value)
        print(AIBaseStation.GetName(item))
    }
    print("!!!!!!!!!!!!!!!!!!")
    foreach(item, value in shuffleList(station_list)){
        print(item)
        print(value)
        print(AIBaseStation.GetName(item))
    }
    local solved = nearestNeighbourTSPSolverStations(station_list)

    station_list.Valuate(AIStation.GetCargoWaiting, 0)
    BusLineManager.deleteObsolete(cityID);
    //print("STATION LIST Begin: "+station_list.Begin())
    if(bankbalance < 1000 && AIStation.GetCargoWaiting(station_list.Begin(),0)> 3*60 && AICompany.GetLoanAmount() != AICompany.GetMaxLoanAmount()){
        print("###########################")
        AICompany.SetLoanAmount(int + AICompany.GetLoanAmount()); //Das ist damit man wenn man kein geld hat trotzdem noch volle stationen abarbeitet
        local vehicle = BuildAndAssignBus(depot, engine, cityID);
        print("Took loan, crowded Order, built vehicle "+ AIVehicle.GetName(vehicle)+ " in depot: ")
        BusLineManager.applyOrderToCrowded(vehicle, cityID, depot);
        AIVehicle.StartStopVehicle(vehicle);
    }
    if (bankbalance > engine_cost + 1.5*bus_station_cost){
        BusStationManager.ManageGrid(cityID)
    }

    if (bankbalance > 2*engine_cost + 1.5*bus_station_cost){
        BusLineManager.ManageLinesAndBuild(cityID);
        }
}