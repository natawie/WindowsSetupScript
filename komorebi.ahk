#SingleInstance Force

WorkspaceNumber := 10

ArrayFromZero(Length) {
  temp := []
  Loop Length {
    temp.Push(A_Index-1)
  }
  return temp
}

global numbers := ArrayFromZero(WorkspaceNumber)

init() {
  Run "komorebic toggle-focus-follows-mouse --implementation windows", ,"Hide"
  Run "komorebic float-rule class TaskManagerWindow", ,"Hide"
  Run "komorebic float-rule title 'Control Panel'", ,"Hide"
  Run "komorebic identify-tray-application exe Discord.exe", ,"Hide"
  Run "komorebic identify-tray-application exe cider.exe", ,"Hide"

  for num in numbers{
    Runwait("komorebic workspace-padding 0 " . num . " 20",,"hide")
    RunWait("komorebic container-padding 0 " . num . " 10",,"Hide")
  }
}

init()

For num in numbers{
  Hotkey("!" . (num), (key) => Run("komorebic focus-workspace " . Integer(SubStr(key, 2))-1, ,"Hide"))
}

For num in numbers{
  Hotkey("!+" . (num), (key) => Run("komorebic move-to-workspace " . Integer(SubStr(key, 3))-1, ,"Hide"))
}

!q::{
  WinClose("A")
}

Run "komorebic complete-configuration", ,"Hide"
