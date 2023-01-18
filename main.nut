// developer 2
// debug_level script=4

require("busStationManager.nut");
require("busLineManager.nut");
require("metaManager.nut");

class MyNewAI extends AIController
{
  function Start();
}

function MyNewAI::Start()
{
  local adjacent = AITileList();

  if (!AICompany.SetName("GudAI")) {
    local i = 2;
    while (!AICompany.SetName("GudAI #" + i)){
        i = i + 1;
    }
  }
  this.Sleep(20)

  local townlist = AITownList();

  // returns biggest Town at begin of Game
  townlist.Valuate(AITown.GetPopulation);
  local bigTown = townlist.Begin();
  print("Mean Town Population: "+ mean(townlist))
  print(bigTown + "");
  print(AITown.GetName(bigTown));
  print(AITown.GetPopulation(bigTown));
  local locBigTown = AITown.GetLocation(bigTown);
  local layout = AITown.GetRoadLayout(bigTown);
  print(layout)
  //print("loc: "+locBigTown)
  print("locX: "+AIMap.GetTileX(locBigTown))
  print("locY: "+AIMap.GetTileY(locBigTown))
  local i = 1;
  //loans money in the beginning to give it a start first
  local int = AICompany.GetLoanInterval();
  AICompany.SetLoanAmount(2*int + AICompany.GetLoanAmount());
  while (true){
    MetaManager.optimizeBusNetworkIn(bigTown);
    this.Sleep(100);
  }
  // END

  // Attempt to build a bus station on every nth road tile

  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

  local area = AITileList();
  area.AddRectangle(locBigTown - AIMap.GetTileIndex(20, 20), locBigTown + AIMap.GetTileIndex(20, 20));
  //print("Is area list empty? "+ area.IsEmpty());
  area.Valuate(AIRoad.IsRoadTile);
  area.KeepValue(1);

  // dumb for loop to create a depot next to a road tile in a city
  // TODO build ROAD IF DEPOT IN FRONT OF CURVE
  local depot= false;
  local point_towards;
  foreach(tile, value in area){
    point_towards = tile+AIMap.GetTileIndex(0, 1);
		if (AIRoad.BuildRoadDepot(point_towards, tile)) {
			depot =  point_towards;
      AIRoad.BuildRoad(tile,depot)
      break;
		}

    point_towards = tile+AIMap.GetTileIndex(0, -1);
		if (AIRoad.BuildRoadDepot(point_towards, tile)) {
			depot =  point_towards;
      AIRoad.BuildRoad(tile,depot)
      break;
		}

		point_towards = tile+AIMap.GetTileIndex(1, 0);
		if (AIRoad.BuildRoadDepot(point_towards, tile)) {
			depot =  point_towards;
      AIRoad.BuildRoad(tile,depot)
      break;
		}

		point_towards = tile+AIMap.GetTileIndex(-1, 0);
		if (AIRoad.BuildRoadDepot(point_towards, tile)) {
			depot =  point_towards;
      AIRoad.BuildRoad(tile,depot)
      break;
		}
  }


  local engine_list = AIEngineList(AIVehicle.VT_ROAD)
  engine_list.Valuate(AIEngine.GetCapacity);
  engine_list.KeepTop(2);

  local engine = engine_list.Begin();
  print(engine);


  local vehicle = AIVehicle.BuildVehicle(depot,engine);
  local station_id = 0;
  area.Valuate(AIRoad.IsRoadStationTile)
  area.KeepValue(0)

  if (!depot){
    print("NO DEPOT PLACED")
  }
  foreach(tile, value in area){
    //print("IsRoad?: "+AIRoad.IsRoadTile(tile));
    //print("locX: "+AIMap.GetTileX(tile));
    //print("locY: "+AIMap.GetTileY(tile));
    if (tile == depot){
      continue;
    }
    if (station_id % 8 == 0){
      AIRoad.BuildDriveThroughRoadStation(tile, tile - AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
      AIRoad.BuildDriveThroughRoadStation(tile, tile - AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
      //print(AIError.GetLastErrorString());
    }
    station_id = station_id +1;
  }

  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  applyOrder(vehicle);
  AIVehicle.StartStopVehicle(vehicle);

  for (local i = 0; i<3; i+=1){
    vehicle = AIVehicle.CloneVehicle(depot,vehicle, false);
    applyOrder(vehicle);
    AIVehicle.StartStopVehicle(vehicle);
  }



  while (true) {
    while (AIEventController.IsEventWaiting()) {
        local e = AIEventController.GetNextEvent();
        switch (e.GetEventType()) {
           case AIEvent.ET_VEHICLE_CRASHED:
                local ec = AIEventVehicleCrashed.Convert(e);
                local v  = ec.GetVehicleID();
                AILog.Info("We have a crashed vehicle (" + v + ")");
                /* Handle the crashed vehicle */
                break;
            case AIEvent.ET_COMPANY_BANKRUPT:
                AILog.Info("Lappen");
                /*more disses */
                break;
        }
    }
    AILog.Info("I am a "+ AICompany.GetName(AICompany.COMPANY_SELF) +" with a ticker called MyNewAI and I am at tick " + this.GetTick());
    this.Sleep(80)
    optimize(vehicle);

   }
}



function applyOrder(vehicle_id){
  // applies
  local station_list = AIStationList(AIStation.STATION_BUS_STOP);
  while (AIOrder.RemoveOrder(vehicle_id,0)){
    continue;
  }
//    station_list.Sort(AIList.SORT_BY_ITEM, true);
  if (vehicle_id % 2 == 0){
    station_list.Sort(AIList.SORT_BY_ITEM, true);
  }
  else{
    station_list.Sort(AIList.SORT_BY_ITEM, false);
  }
  foreach (station, value in station_list){
    AIOrder.AppendOrder(vehicle_id, AIBaseStation.GetLocation(station), AIOrder.OF_NONE);
  }
}