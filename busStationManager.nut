class BusStationManager{
}

function BusStationManager::ManageGrid(cityID){
    local townPopulation = AITown.GetPopulation(cityID);
    local townLocation = AITown.GetLocation(cityID);

    local gridSize = (townPopulation / 150).tointeger();
    local grid = AITileList();
    grid.AddRectangle(townLocation - AIMap.GetTileIndex(gridSize,gridSize), townLocation + AIMap.GetTileIndex(gridSize,gridSize));
    local stationList = AIStationList(AIStation.STATION_BUS_STOP);
    foreach (station,value in stationList) {
        local loc = AIBaseStation.GetLocation(station);
        grid.RemoveRectangle(loc - AIMap.GetTileIndex(3,3), loc + AIMap.GetTile(3,3));
    }
    grid.Valuate(AIRoad.IsRoadTile);
    grid.KeepValue(1);
    grid.Valuate(AIRoad.IsRoadStationTile);
    grid.KeepValue(0);
    grid.Valuate(AITile.GetCargoProduction, 0, 1, 1, 3);
    foreach (tile,value in grid) {
        AILog.Info(AIMap.GetTileX(tile) + "|" + AIMap.GetTileY(tile) + "|" + AITile.GetCargoProduction(tile, 0, 1, 1, 3));
    }
    local passengerProdCap = 5;
    while(AITile.GetCargoProduction(grid.Begin(),0,1,1,3) > passengerProdCap){

    }
}

function BusStationManager::printCargoIDs(){
    local cargoList = AICargoList();
    foreach (carg,value in cargoList){
        AILog.Info("ID: " + carg + " | NAME: " + AICargo.GetName(carg));
    }
}