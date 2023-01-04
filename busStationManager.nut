class BusStationManager{
}

function BusStationManager::ManageGrid(cityID){
    // builds Station based on Population in non overlapping fashion
    AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);
    local townPopulation = AITown.GetPopulation(cityID);
    local townLocation = AITown.GetLocation(cityID);

    local gridSize = (townPopulation / 150).tointeger();
    local grid = AITileList();
    grid.AddRectangle(townLocation - AIMap.GetTileIndex(gridSize,gridSize), townLocation + AIMap.GetTileIndex(gridSize,gridSize));
    // TODO: GRID Can be empty if it is crossing map border, fix this by checking for borders
    print("EmptyGrid"+grid.IsEmpty())
    local stationList = AIStationList(AIStation.STATION_BUS_STOP);
    foreach (station,value in stationList) {
        local loc = AIBaseStation.GetLocation(station);
        grid.RemoveRectangle(loc - AIMap.GetTileIndex(3,3), loc + AIMap.GetTileIndex(3,3));
    }
    grid.Valuate(AIRoad.IsRoadTile);
    grid.KeepValue(1);
    grid.Valuate(AITile.GetClosestTown);
    grid.KeepValue(cityID);
    grid.Valuate(AIRoad.IsRoadStationTile);
    grid.KeepValue(0);
    grid.Valuate(AITile.GetCargoProduction, 0, 1, 1, 3);
//    foreach (tile,value in grid) {
//        AILog.Info(AIMap.GetTileX(tile) + "|" + AIMap.GetTileY(tile) + "|" + AITile.GetCargoProduction(tile, 0, 1, 1, 3));
//    }
    local passengerProdCap = 5;
    local station = 0;
    local stationLoc = 0;
    while(AITile.GetCargoProduction(grid.Begin(),0,1,1,3) > passengerProdCap){
        print("DEBUG :" + AITile.GetCargoProduction(grid.Begin(),0,1,1,3))
      stationLoc = grid.Begin();   
      print("Precond: "+AIMap.IsValidTile(stationLoc))
      if (AIRoad.BuildDriveThroughRoadStation(stationLoc, stationLoc - AIMap.GetTileIndex(0, 1), AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW) ||
      AIRoad.BuildDriveThroughRoadStation(stationLoc, stationLoc - AIMap.GetTileIndex(1, 0), AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW)){
        print("Here")
        grid.RemoveRectangle(stationLoc - AIMap.GetTileIndex(3,3), stationLoc + AIMap.GetTileIndex(3,3));
      } else{
        print("There")
        grid.RemoveTop(1);
      }
    }


    // build depot
    grid = AITileList();
    grid.AddRectangle(townLocation - AIMap.GetTileIndex(gridSize,gridSize), townLocation + AIMap.GetTileIndex(gridSize,gridSize));
    grid.Valuate(AIRoad.IsRoadDepotTile);
    grid.KeepValue(1);
    grid.Valuate(AITile.GetClosestTown);
    grid.KeepValue(cityID);
    grid.Valuate(AITile.GetOwner)
    grid.KeepValue(AICompany.ResolveCompanyID(AICompany.COMPANY_SELF));
    if (grid.IsEmpty()){
        local depot;
        grid = AITileList();
        grid.AddRectangle(townLocation - AIMap.GetTileIndex(gridSize,gridSize), townLocation + AIMap.GetTileIndex(gridSize,gridSize));
        grid.Valuate(AIRoad.IsRoadTile);
        grid.KeepValue(1);
        grid.Valuate(AITile.GetClosestTown);
        grid.KeepValue(cityID);
        grid.Valuate(AIRoad.IsRoadStationTile);
        grid.KeepValue(0);

        local point_towards;
        foreach(tile, value in grid){
            point_towards = tile+AIMap.GetTileIndex(0, 1);
                if (AIRoad.BuildRoad(tile,point_towards) && AIRoad.BuildRoadDepot(point_towards, tile)) {
                    depot =  point_towards;
                    break;
                }

            point_towards = tile+AIMap.GetTileIndex(0, -1);
                if (AIRoad.BuildRoad(tile,point_towards) && AIRoad.BuildRoadDepot(point_towards, tile)) {
                    depot =  point_towards;
                    break;
                }

                point_towards = tile+AIMap.GetTileIndex(1, 0);
                if (AIRoad.BuildRoad(tile,point_towards) && AIRoad.BuildRoadDepot(point_towards, tile)) {
                    depot =  point_towards;
                    break;
                }

                point_towards = tile+AIMap.GetTileIndex(-1, 0);
                if (AIRoad.BuildRoad(tile,point_towards) && AIRoad.BuildRoadDepot(point_towards, tile)) {
                    depot =  point_towards;
                    break;
                }
        }
    }
}


function BusStationManager::printCargoIDs(){
    local cargoList = AICargoList();
    foreach (carg,value in cargoList){
        AILog.Info("ID: " + carg + " | NAME: " + AICargo.GetName(carg));
    }
}