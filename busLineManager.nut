
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
    vehicle = BuildAndAssignBus(depot, engine, cityID);
    print("Random Order, built vehicle "+ AIVehicle.GetName(vehicle)+ " in depot: ")
    BusLineManager.applySemiRandomOrder(vehicle, cityID, depot);
    AIVehicle.StartStopVehicle(vehicle);
  }

  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStation.GetNearestTown);
  station_list.KeepValue(cityID);
  station_list.Valuate(AIStation.GetCargoRating, 0);
  station_list.KeepAboveValue(1);
  station_list.Sort(AIList.SORT_BY_VALUE, true);

  local whenToBuildRatingsBus = 35;
  if (AIStation.GetCargoRating(station_list.Begin(),0)< whenToBuildRatingsBus){
    print("Jaambus: "+ AIStation.GetCargoRating(station_list.Begin(),0));
    vehicle = BuildAndAssignBus(depot, engine, cityID);
    print("Rating Order, built vehicle "+ AIVehicle.GetName(vehicle)+ " in depot: ")
    BusLineManager.applyOrderToLowRatings(vehicle, cityID, depot);
    AIVehicle.StartStopVehicle(vehicle);
  }
 //TODO Change Selling of Rating Vehicles, dont sell them imediatly anymore

  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStation.GetNearestTown);
  station_list.KeepValue(cityID);
  station_list.Valuate(AIStation.GetCargoWaiting, 0)

  //local whenToBuildCrowdedBus = AITown.GetPopulation(cityID) / 20;
  local whenToBuildCrowdedBus = 60
  if (AIStation.GetCargoWaiting(station_list.Begin(),0)> whenToBuildCrowdedBus){
    vehicle = BuildAndAssignBus(depot, engine, cityID);
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

// TODO Improve SELLER, TAkes too long
// Endless cycle in lategame
function BusLineManager::deleteObsolete(cityID){
  local depot = BusLineManager.getDepotInTown(cityID);
  local bus_list = AIVehicleList_Depot(depot)
  foreach(bus, value in bus_list){
    if (AIVehicle.GetAgeLeft(bus)< 0){
      AIVehicle.SendVehicleToDepot(bus);
      if (AIVehicle.GetProfitLastYear(bus)> 300){
        print("Sold Vehicle because too old "+ AIVehicle.GetName(bus)) 
        local newbus =  AIVehicle.CloneVehicle(depot, bus, false)
        AIVehicle.StartStopVehicle(newbus)
        print("cloned vehicle")
      }
      while(!AIVehicle.SellVehicle(bus)){
        continue
      }
    }

    continue

    if (AIVehicle.GetProfitLastYear(bus)< -300 && AIVehicle.GetAge(bus) > 2){
      AIVehicle.SendVehicleToDepot(bus);
      print("Sold Vehicle because not worth it "+ AIVehicle.GetName(bus)) 
      while(!AIVehicle.SellVehicle(bus)){
        continue
      }
    }
  }
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
    }
  AIOrder.AppendOrder(vehicle_id, depot, AIOrder.OF_SERVICE_IF_NEEDED);
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

    BusLineManager.nearestNeighbourTSPSolverStations(vehicle_id, station_list)

    AIGroup.MoveVehicle(getCrowdedBusGroup(cityID), vehicle_id);

}

function BusLineManager::applyOrderToLowRatings(vehicle_id, cityID, depotID) {
  AIOrder.AppendOrder(vehicle_id, depotID, AIOrder.OF_SERVICE_IF_NEEDED);
  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStation.GetNearestTown);
  station_list.KeepValue(cityID);
  station_list.Valuate(AIStation.GetCargoRating, 0);
  local meanStationRating = mean(station_list);
  station_list.RemoveAboveValue(meanStationRating);
  local station_list_count = station_list.Count()

  BusLineManager.nearestNeighbourTSPSolverStations(vehicle_id, station_list)

  AIGroup.MoveVehicle(getRatingBusGroup(cityID), vehicle_id);


}

function BusLineManager::nearestNeighbourTSPSolverStations(vehicle_id, list_of_stations){
    local length = list_of_stations.Count()
    local randomIndex = AIBase.RandRange(length+1)
    local station  = list_of_stations.Begin()
    local j = 1
    for (local i=1; i<randomIndex; i+=1){
        station = list_of_stations.Next()
    }
    local ordered_list = AIStationList(AIStation.STATION_BUS_STOP)
    ordered_list.AddItem(station, j)
    j+=1
    while (j <=length){
        //print("ENTERING THE LOOP")
        list_of_stations.Valuate(DistanceManhatten_circ_GetLocation, station)
        list_of_stations.Sort(AIList.SORT_BY_VALUE, true);
        station = list_of_stations.Begin()
        station = list_of_stations.Next()
        print(AIBaseStation.GetName(station))

        AIOrder.AppendOrder(vehicle_id, AIBaseStation.GetLocation(station), AIOrder.OF_NONE);
        ordered_list.AddItem(station,j)
        list_of_stations.RemoveItem(list_of_stations.Begin())
        j +=1
    }
}