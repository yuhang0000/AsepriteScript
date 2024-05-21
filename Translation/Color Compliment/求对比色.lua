-- 用于给指定颜色求出对比色的脚本
-- 由 aquova 编写, 2018
-- https://github.com/aquova/aseprite-scripts

-- 打开对话框, 顺便问问你需要选择什么颜色
local dlg = Dialog("求对比色")
local done = 0
-- 创建起始颜色为黑色(划掉),我在这里直接改成取当前前景色颜色.
local defaultColor = Color{r=app.fgColor.red, g=app.fgColor.green, b=app.fgColor.blue, a=app.fgColor.alpha}
dlg:color{ id="color", color=defaultColor }
dlg:button{ id="ok", text="开始", focus=true, onclick = function() if(done == 0) then generateCompliment(dlg.data.color) else app.fgColor=newCol dlg:close() end end}
dlg:button{ id="cancel", text="取消", onclick = function() dlg:close() end}
dlg:show{wait = false}
    
function generateCompliment(color)
    color.hsvHue = (color.hsvHue + 180) % 360
    newCol = Color{r=color.red, g=color.green, b=color.blue, a=color.alpha}
    -- 生成对比色并打印在对话框上
    done = 1
    dlg:modify{ id="color", color=newCol }
    dlg:modify{ id="ok", text="应用"}
    dlg:modify{ id="cancel", text="确定"}
end