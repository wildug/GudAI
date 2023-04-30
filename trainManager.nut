require("utils.nut")

function TrainManager::usedEngine(){
  local engine_list = AIEngineList(AIVehicle.VT_RAIL)
  engine_list.Valuate(AIEngine.GetCapacity);
  engine_list.KeepTop(1);
  return engine_list.Begin();
}