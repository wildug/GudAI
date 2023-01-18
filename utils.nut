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