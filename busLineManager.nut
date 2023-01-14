
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
  print("Vehicles in Depot Empty: " + vehicles_in_depot.IsEmpty())
  local vehicle = vehicles_in_depot.Begin();
  local cost = AIVehicle.GetProfitLastYear(vehicle);
  print("Vehicle: " + vehicle +" has cost " + cost + " Unitnumber: " + AIVehicle.GetUnitNumber(vehicle));


  // recycling variable vehicle
  local initialBusses = 5;
  local minimalLastYearProfit = 1000;
  if (cost > minimalLastYearProfit ||  vehicles_in_depot.Count()< initialBusses){
    vehicle = AIVehicle.BuildVehicle(depot,engine);
    BusLineManager.applySemiRandomOrder(vehicle, cityID, depot);
    AIVehicle.StartStopVehicle(vehicle);
  }
  else{
    BusLineManager.applySemiRandomOrder(vehicle, cityID, depot);
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
  local vehicles_in_depot = AIVehicleList_Depot(depot);
  // applies Semi Random Ordering of all stations in cityID and in depot
  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStation.GetNearestTown);
  station_list.KeepValue(cityID);
  local order_count =AIOrder.GetOrderCount(vehicle_id)
  if ((order_count - 1) == station_list.Count()){
    return;
  }
  AIOrder.AppendOrder(vehicle_id, depot, AIOrder.OF_SERVICE_IF_NEEDED);

  foreach(vehicle_id, value in vehicles_in_depot){
    while (AIOrder.RemoveOrder(vehicle_id,0)){
      continue;
    }
  //    station_list.Sort(AIList.SORT_BY_ITEM, true);
    foreach (station, value in station_list){
      AIOrder.AppendOrder(vehicle_id, AIBaseStation.GetLocation(station), AIOrder.OF_NONE);
    }
    order_count =AIOrder.GetOrderCount(vehicle_id)
    for (local i=1; i<order_count; i+=1){
      AIOrder.MoveOrder(vehicle_id, 0, AIBase.RandRange(order_count));
  }
  AIOrder.AppendOrder(vehicle_id, depot, AIOrder.OF_SERVICE_IF_NEEDED);
  }
}