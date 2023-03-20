function getGridAroundTown(cityID){
    local townPopulation = AITown.GetPopulation(cityID);
    local townLocation = AITown.GetLocation(cityID);

    local gridSize = (townPopulation / 100).tointeger();
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
    print("CityID "+ cityID)
    print("vehicleID"+ vehicleID)
    AIGroup.MoveVehicle(getMainBusGroup(cityID), vehicleID);
    return vehicleID
}

function DistanceManhatten_circ_GetLocation(station1, station2){
    return AITile.GetDistanceManhattanToTile(AIBaseStation.GetLocation(station1),AIBaseStation.GetLocation(station2))
}

function  ID_GetLargestUntappedIndustry(id_cargoID) {
    ailist_cargoProducersList = AIIndustryList_CargoProducing(id_cargoID);

    ailist_cargoProducersList.Valuate(AIIndustry.GetAmountOfStationsAround);
    ailist_cargoProducersList.RemoveAboveValue(0);

    ailist_cargoProducersList.Valuate(AIIndustry.GetLastMonthProduction, cargoID);

    return ailist_cargoProducersList.Begin();
}

function ID_GetNearAcceptingIndustry(id_producerID, i_minDist ) {
    id_producerType = AIIndustry.GetIndustryType(id_producerID);
    tile_producerPosition = AIIndustry.GetLocation(id_producerID);
    ailist_producedCargoList = AIIndustryType.GetProducedCargo(id_producerType);

    ailist_cargoAcceptorList = AIIndustryList_CargoAccepting(alist_producedCargoList.Begin()) //TODO: das hier ist bisschen heßlig und geht bei Modpacks glaub nicht wenn sachen mehr optionen haben
    
    ailist_cargoAcceptorList.Valuate(AIIndustry.GetDistanceSquareToTile, tile_producerPosition);
    ailist_cargoAcceptorList.RemoveBelowValue(i_minDist);

    return ailist_cargoAcceptorList.Begin();
}