// developer 2
// debug_level script=4
//fix VSCode

require("busStationManager.nut");
require("busLineManager.nut");
require("metaManager.nut");
require("utils.nut")

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

  local bigTownMainGroup = AIGroup.CreateGroup(AIVehicle.VT_ROAD, AIGroup.GROUP_INVALID);
  AIGroup.SetName(bigTownMainGroup, "MainBus_"+bigTown);
  AIGroup.SetPrimaryColour(bigTownMainGroup,AICompany.COLOUR_GREY);
  local bigTownCrowdedGroup = AIGroup.CreateGroup(AIVehicle.VT_ROAD, bigTownMainGroup);
  AIGroup.SetPrimaryColour(bigTownCrowdedGroup,AICompany.COLOUR_RED);
  AIGroup.SetName(bigTownCrowdedGroup, "CrowdedBus_"+bigTown);
  local bigTownRatingsGroup = AIGroup.CreateGroup(AIVehicle.VT_ROAD, bigTownMainGroup);
  AIGroup.SetPrimaryColour(bigTownRatingsGroup,AICompany.COLOUR_YELLOW);
  AIGroup.SetName(bigTownRatingsGroup, "RatingsBus_"+bigTown);


  print("MainBus_"+AITown.GetName(bigTown))

  local ourTownlist = AITownList()
  ourTownlist.Clear()
  ourTownlist.AddItem(bigTown, townlist.GetValue(bigTown))
  local nextTown
  while (true){
    if (AICompany.GetQuarterlyIncome(AICompany.COMPANY_SELF, AICompany.CURRENT_QUARTER) > 2500*ourTownlist.Count()){

      nextTown = townlist.Begin()
      for(local i=1; i<=ourTownlist.Count();i+=1){
        nextTown = townlist.Next()
      }
      ourTownlist.AddItem(nextTown, townlist.GetValue(nextTown))
      print("ADDED TOWN " + AITown.GetName(nextTown))

      bigTownMainGroup = AIGroup.CreateGroup(AIVehicle.VT_ROAD, AIGroup.GROUP_INVALID);
      print("AAAAAAAAA: " + AIGroup.GetName(bigTownMainGroup));
      print(AIGroup.SetName(bigTownMainGroup, "MainBus_"+nextTown));
      print("BAAAAAAAA: " + AIGroup.GetName(bigTownMainGroup));
      AIGroup.SetPrimaryColour(bigTownMainGroup,AICompany.COLOUR_GREY);
      bigTownCrowdedGroup = AIGroup.CreateGroup(AIVehicle.VT_ROAD, bigTownMainGroup);
      AIGroup.SetPrimaryColour(bigTownCrowdedGroup,AICompany.COLOUR_RED);
      AIGroup.SetName(bigTownCrowdedGroup, "CrowdedBus_"+nextTown);
      bigTownRatingsGroup = AIGroup.CreateGroup(AIVehicle.VT_ROAD, bigTownMainGroup);
      AIGroup.SetPrimaryColour(bigTownRatingsGroup,AICompany.COLOUR_YELLOW);
      AIGroup.SetName(bigTownRatingsGroup, "RatingsBus_"+nextTown);
    }

    foreach (town, value in ourTownlist){
      print("called Meta for "+ AITown.GetName(town))
      MetaManager.optimizeBusNetworkIn(town);
      this.Sleep(100);
    }

    //metaManager.metaManagerTrains()

  }
  // END
}