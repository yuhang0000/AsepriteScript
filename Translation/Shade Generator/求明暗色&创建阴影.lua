-- 用于给指定颜色创建 阴影/明暗 的脚本
-- 由 aquova 编写, 2018
-- https://github.com/aquova/aseprite-scripts

-- 打开对话框, 顺便问问你需要选择什么颜色
local dlg = Dialog("求明暗色/创建阴影")-- 创建起始颜色为黑色(划掉),我在这里直接改成取当前前景色颜色.
local defaultColor = Color{r=app.fgColor.red, g=app.fgColor.green, b=app.fgColor.blue, a=app.fgColor.alpha}
dlg:color{ id="color1", color=defaultColor }
dlg:shades{ id="showcolor", visible=false,onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      end end}
dlg:button{ id="ok", text="确定", focus=true,onclick = function() Run(dlg.data.color1) end}
dlg:button{ id="cancel", text="取消", function() dlg:close() end}
dlg:show{wait = false}

function generateColors(color)
    local colors = {}
    for light=1,0,-0.1 do
        local newCol = Color{h=color.hslHue, s=color.hslSaturation, l=light}
        table.insert(colors, newCol)
    end

    return colors
end

function Run(color)
    local colors = generateColors(Color{r=color.red, g=color.green, b=color.blue, a=color.alpha})
    dlg:modify{ id="color1", visible=false}
    dlg:modify{ id="showcolor", visible=true, colors=colors}
    dlg:modify{ id="ok", visible=false}
    dlg:modify{ id="cancel", text="确定"}
    dlg.bounds = Rectangle(dlg.bounds.x - (dlg.bounds.width/2),dlg.bounds.y,dlg.bounds.width*2,dlg.bounds.height)
    app.refresh()
end

dlg.bounds = Rectangle(dlg.bounds.x - (dlg.bounds.width/24),dlg.bounds.y,dlg.bounds.width + (dlg.bounds.width/12),dlg.bounds.height)
app.refresh()