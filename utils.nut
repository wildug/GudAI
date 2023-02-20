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


function nearestNeighbourTSPSolverStations(vehicle_id, list_of_stations){
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

//    print("list in function")
//    foreach(item, value in ordered_list){
//        print(item)
//        print(value)
//        print(AIBaseStation.GetName(item))
//    }
//    print("list outside function")

    return ordered_list

}

function DistanceManhatten_circ_GetLocation(station1, station2){
    return AITile.GetDistanceManhattanToTile(AIBaseStation.GetLocation(station1),AIBaseStation.GetLocation(station2))
}