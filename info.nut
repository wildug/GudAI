class MyNewAI extends AIInfo {
  function GetAuthor()      { return "Newbie AI Writer"; }
  function GetName()        { return "GudAI"; }
  function GetDescription() { return "An example AI by following the tutorial at http://wiki.openttd.org/"; }
  function GetVersion()     { return 1; }
  function GetDate()        { return "2022-10-27"; }
  function CreateInstance() { return "MyNewAI"; }
  function GetShortName()   { return "XXXX"; }
  function GetAPIVersion()  { return "12"; }
}

RegisterAI(MyNewAI());