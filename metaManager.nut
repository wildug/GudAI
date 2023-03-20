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

    station_list.Valuate(AIStation.GetCargoWaiting, 0)
    BusLineManager.deleteObsolete(cityID);
    //print("STATION LIST Begin: "+station_list.Begin())
    // take a loan if stations are full and no money is left for busses
    if(bankbalance < 1000 && AIStation.GetCargoWaiting(station_list.Begin(),0)> 3*60 && AICompany.GetLoanAmount() != AICompany.GetMaxLoanAmount()){
        print("###########################")
        print(AICompany.SetLoanAmount(int + AICompany.GetLoanAmount()))
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

function MetaManager::metaManageTrains(){
    local bankbalance = AICompany.GetBankBalance(AICompany.COMPANY_SELF);
    grouplist = AIGroupList()
    grouplist.Valuate(AIGroup.GetVehicleType)
    grouplist.KeepValue(AIVehicle.VT_RAIL)
    if (bankbalance > 100000){
        trainGroup = AIGroup.CreateGroup(AIVehicle.VT_RAIL, AIGroup.GROUP_INVALID)
        AIGroup.SetName(trainGroup, "TrainGroup"+(grouplist.Count()+1))
    }
    
    foreach (groupID, value in grouplist){
        MetaManager.optimizeTrainNetwork(groupID)
    }

}

function MetaManager::optimizeTrainNetwork(groupID){
    // only calls busLineManager we have more than station cost + bus cost in bank
    local bankbalance = AICompany.GetBankBalance(AICompany.COMPANY_SELF);
    local engine = trainManager.usedEngine()
    local railway_cost = AIEngine.GetPrice(engine);
    local train_station_cost = AIRail.GetBuildCost(AIRail.RAILTYPE_INVALID, AIRail.BT_DEPOT);

    local station_list = AIStationList(AIStation.STATION_TRAIN);
    local number_of_trainStations = station_list.Count()
    
    

    local depot = trainManager.getDepotOfRoute(routeID);

    trainManagerusLineManager.deleteObsolete(routeID);

}