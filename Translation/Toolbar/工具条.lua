--来自:https://community.aseprite.org/t/touch-toolbar-helper/2169
local dlg = Dialog("工具条")
dlg
  :button{text="撤销",onclick=function() app.command.Undo() end}
  :button{text="恢复",onclick=function() app.command.Redo() end}
  :button{text="|<",onclick=function() app.command.GotoFirstFrame() end}
  :button{text="<",onclick=function() app.command.GotoPreviousFrame() end}
  :button{text=">",onclick=function() app.command.GotoNextFrame() end}
  :button{text=">|",onclick=function() app.command.GotoLastFrame() end}
  :button{text="+",onclick=function() app.command.NewFrame() end}
  :show{wait=false}