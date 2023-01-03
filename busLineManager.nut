
class BusLineManager{
}

function BusLineManager::ManageLines(cityID){
    local townLocation = AITown.GetLocation(cityID);

    local grid = AITileList();
    local townPopulation = AITown.GetPopulation(cityID);
    local gridSize = (townPopulation / 150).tointeger();

    grid.AddRectangle(townLocation - AIMap.GetTileIndex(gridSize,gridSize), townLocation + AIMap.GetTileIndex(gridSize,gridSize));
    grid.Valuate(AIRoad.IsRoadDepotTile);
    grid.KeepValue(1);
    grid.Valuate(AITile.GetClosestTown);
    grid.KeepValue(cityID);
    grid.Valuate(AITile.GetOwner)
    grid.KeepValue(AICompany.ResolveCompanyID(AICompany.COMPANY_SELF));
    local depot = grid.Begin();

    local engine_list = AIEngineList(AIVehicle.VT_ROAD)
    engine_list.Valuate(AIEngine.GetCapacity);
    engine_list.KeepTop(2);

    local engine = engine_list.Begin();
    
    local vehicle = AIVehicle.BuildVehicle(depot,engine);
    applyOrder(vehicle);
    AIVehicle.StartStopVehicle(vehicle);

}

function applyOrder(vehicle_id, cityID){
  // applies
  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  station_list.Valuate(AIStaion.GetNearestTown);
  station.KeepValue(cityID);
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
}