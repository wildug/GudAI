require("utils.nut")

function TrainManager::usedEngine(){
  local engine_list = AIEngineList(AIVehicle.VT_RAIL)
  engine_list.Valuate(AIEngine.GetCapacity);
  engine_list.KeepTop(1);
  return engine_list.Begin();
}

function B_connectStations(id_station1, id_station2) {

  //Base Position der Stationen herausfinden
  tile_station1Pos = AIBaseStation.GetLocation(id_station1);
  tile_station2Pos = AIBaseStation.GetLocation(id_station2);

  //Tiles der Station ermitteln
  ailist_station1RailTiles = AITileList_StationType(id_station1, AIStation.STATION_TRAIN);
  ailist_station2RailTiles = AITileList_StationType(id_station2, AIStation.STATION_TRAIN);

  ailist_station1RailTiles.Valuate(AIRail.IsRailStationTile);
  ailist_station1RailTiles.KeepValue(true);
  ailist_station2RailTiles.Valuate(AIRail.IsRailStationTile);
  ailist_station2RailTiles.KeepValue(true);

  //Dominierende Richtung zwischen Stationen ermitteln
  int_xDist = AIMap.GetTileX(tile_station2Pos) - AIMap.GetTileX(tile_station1Pos);
  int_yDist = AIMap.GetTileY(tile_station2Pos) - AIMap.GetTileY(tile_station1Pos);
  

  //Richtung der Stationen ermitteln

  

  //Richtige Richtung der endtiles ermitteln (basierend auf position)

  //Endtile jeder Station ermitteln

  //Freie Endtiles ermitteln

  //tiles die verbunden werden müssen herausfinden
    

  //verbinden
}