function getGridAroundTown(cityID){
    local townPopulation = AITown.GetPopulation(cityID);
    local townLocation = AITown.GetLocation(cityID);

    local gridSize = (townPopulation / 150).tointeger();
    local grid = AITileList();
    local distanceFromEdge = AIMap.DistanceFromEdge(townLocation);
    gridSize = gridSize < distanceFromEdge ? gridSize : distanceFromEdge - 1
    grid.AddRectangle(townLocation - AIMap.GetTileIndex(gridSize,gridSize), townLocation + AIMap.GetTileIndex(gridSize,gridSize));
    return grid
}

function mean(list){
    local sum = 0;
    foreach (id, value in list) {
        sum += list.GetValue(id);
    }
    local count = list.Count()
    if (count == 0){
        return 0
    }
    return sum/ count
}

function getMainBusGroup(cityID) {
    local cityName = AITown.GetName(cityID);
    local groups = AIGroupList()
    foreach (ID, value in groups) {
        if (AIGroup.GetName(ID) == ("MainBus_"+cityName))
        return ID
    }
}

function BuildAndAssignBus(depotID, engineID, cityID){
    local vehicleID = AIVehicle.BuildVehicle(depotID,engineID);
    AIGroup.MoveVehicle(getMainBusGroup(cityID), vehicleID);
    return vehicleID
}