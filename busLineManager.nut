
require("utils.nut")

class BusLineManager{
}

function BusLineManager::ManageLinesAndBuild(cityID){
  // builds bus in first depot in town cityID
  local depot = BusLineManager.getDepotInTown(cityID);

  local engine_list = AIEngineList(AIVehicle.VT_ROAD)
  engine_list.Valuate(AIEngine.GetCapacity);
  engine_list.KeepTop(2);

  local engine = engine_list.Begin();

  local vehicles_in_depot = AIVehicleList_Depot(depot);
  vehicles_in_depot.Sort(AIList.SORT_BY_ITEM, true);
//  print("Vehicles in Depot Empty: " + vehicles_in_depot.IsEmpty())
  local vehicle = vehicles_in_depot.Begin();
  vehicles_in_depot.Valuate(AIVehicle.GetProfitLastYear);



  // recycling variable vehicle
  local initialBusses = 5;
  local minimalLastYearProfit = 1000;
  local cost = mean(vehicles_in_depot)

  //if (cost > minimalLastYearProfit ||  vehicles_in_depot.Count()< initialBusses){
  if (vehicles_in_depot.Count()< initialBusses){
    vehicle = AIVehicle.BuildVehicle(depot,engine);
    print("Random Order, built vehicle "+ AIVehicle.GetName(vehicle)+ " in depot: ")
    BusLineManager.applySemiRandomOrder(vehicle, cityID, depot);
    AIVehicle.StartStopVehicle(vehicle);
  }

  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStation.GetNearestTown);
  station_list.KeepValue(cityID);
  station_list.Valuate(AIStation.GetCargoWaiting, 0)

  //local whenToBuildCrowdedBus = AITown.GetPopulation(cityID) / 20;
  local whenToBuildCrowdedBus = 60
  if (AIStation.GetCargoWaiting(station_list.Begin(),0)> whenToBuildCrowdedBus){
    vehicle = AIVehicle.BuildVehicle(depot,engine);
    print("Crowded Order, built vehicle "+ AIVehicle.GetName(vehicle)+ " in depot: ")
    BusLineManager.applyOrderToCrowded(vehicle, cityID, depot);
    AIVehicle.StartStopVehicle(vehicle);
  }
}

function BusLineManager::getDepotInTown(cityID){
  local townLocation = AITown.GetLocation(cityID);
  local grid = AITileList();
  local townPopulation = AITown.GetPopulation(cityID);
  local grid = getGridAroundTown(cityID);
  grid.Valuate(AIRoad.IsRoadDepotTile);
  grid.KeepValue(1);
  grid.Valuate(AITile.GetClosestTown);
  grid.KeepValue(cityID);
  grid.Valuate(AITile.GetOwner)
  grid.KeepValue(AICompany.ResolveCompanyID(AICompany.COMPANY_SELF));
  return grid.Begin();

}

function BusLineManager::usedEngine(){
  local engine_list = AIEngineList(AIVehicle.VT_ROAD)
  engine_list.Valuate(AIEngine.GetCapacity);
  engine_list.KeepTop(2);
  return engine_list.Begin();
}

function BusLineManager::getFirstVehicle(){
  local vehicles_in_depot = AIVehicleList_Depot(depot);
}



function BusLineManager::applySemiRandomOrder(vehicle_id, cityID, depot){
  // function also makes new orders for every other vehicle assignes to depot
  // ok this is confusing, we add the vehicle_id to the depot to remove it and then to add it again;
  // TODO this better
  AIOrder.AppendOrder(vehicle_id, depot, AIOrder.OF_SERVICE_IF_NEEDED);
  local vehicles_in_depot = AIVehicleList_Depot(depot);
  // applies Semi Random Ordering of all stations in cityID and in depot
  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStation.GetNearestTown);
  station_list.KeepValue(cityID);
  local station_list_count = station_list.Count()

  //    station_list.Sort(AIList.SORT_BY_ITEM, true);
  foreach (station, value in station_list){
    AIOrder.AppendOrder(vehicle_id, AIBaseStation.GetLocation(station), AIOrder.OF_NONE);
  }
  for (local i=1; i<2*station_list_count; i+=1){
    AIOrder.MoveOrder(vehicle_id, 0, AIBase.RandRange(station_list_count));

  AIOrder.AppendOrder(vehicle_id, depot, AIOrder.OF_SERVICE_IF_NEEDED);
  }
}

function BusLineManager::applyOrderToCrowded(vehicle_id, cityID, depot){

    AIOrder.AppendOrder(vehicle_id, depot, AIOrder.OF_SERVICE_IF_NEEDED);
    local vehicles_in_depot = AIVehicleList_Depot(depot);
    local station_list = AIStationList(AIStation.STATION_BUS_STOP);
    station_list.Valuate(AIStation.GetNearestTown);
    station_list.KeepValue(cityID);
    station_list.Valuate(AIStation.GetCargoWaiting, 0)
    local minStationWaiting = mean(station_list)

    station_list.RemoveBelowValue(minStationWaiting)
    local station_list_count = station_list.Count()

    foreach (station, value in station_list){
      AIOrder.AppendOrder(vehicle_id, AIBaseStation.GetLocation(station), AIOrder.OF_NONE);
    }
    local order_count =AIOrder.GetOrderCount(vehicle_id)
    for (local i=1; i<2*order_count; i+=1){
      AIOrder.MoveOrder(vehicle_id, 0, AIBase.RandRange(order_count));
    }

}