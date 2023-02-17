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

function getCrowdedBusGroup(cityID) {
    local cityName = AITown.GetName(cityID);
    local groups = AIGroupList()
    foreach (ID, value in groups) {
        if (AIGroup.GetName(ID) == ("CrowdedBus_"+cityName))
        return ID
    }
}

function getRatingBusGroup(cityID) {
    local cityName = AITown.GetName(cityID);
    local groups = AIGroupList()
    foreach (ID, value in groups) {
        if (AIGroup.GetName(ID) == ("RatingsBus_"+cityName))
        return ID
    }
}

function BuildAndAssignBus(depotID, engineID, cityID){
    local vehicleID = AIVehicle.BuildVehicle(depotID,engineID);
    AIGroup.MoveVehicle(getMainBusGroup(cityID), vehicleID);
    return vehicleID
}

function shuffleList(list){
    // BAD shuffling
    local length = list.Count()
    local shuffle_number = AIBase.RandRange(2)
    local newlist = AIList()
    while(!list.IsEmpty()){
        foreach(item, value in list){
            shuffle_number = AIBase.RandRange(2)
            if (shuffle_number>0){
                list.RemoveItem(item)
                newlist.AddItem(item, value)
            }
        }
    }
    return newlist
}

function nearestNeighbourTSPSolverStations(list_of_stations){
    local shuffeled_list = shuffleList(list_of_stations)
    local length = shuffeled_list.Count()
    local start = shuffeled_list.Begin()
    local ordered_list = AIStationList(AIStation.STATION_BUS_STOP)
    for(local i=0; i<length; i+=1){
        print("ENTERING THE LOOP")
        shuffeled_list.Valuate(AITile.GetDistanceManhattanToTile, start)
        shuffeled_list.Sort(AIList.SORT_BY_VALUE, true);
        ordered_list.AddItem(i,shuffeled_list.GetValue(shuffeled_list.Begin()))
        shuffeled_list.RemoveItem(shuffeled_list.Begin())
        start = shuffeled_list.Begin()
        i +=1
    }
    return ordered_list

}