-- 打开对话框以选择两种颜色之间的色调的脚本。
-- 由 aquova 编写, 2018
-- https://github.com/aquova/aseprite-scripts

-- 打开对话框，询问你需要选择什么颜色
local dlg = Dialog("求过度色")
-- 创建起始颜色为黑色(划掉),我在这里直接改成取当前前景色和背景色.
local color1 = Color{r=app.fgColor.red, g=app.fgColor.green, b=app.fgColor.blue, a=app.fgColor.alpha} 
local color2 = Color{r=app.bgColor.red, g=app.bgColor.green, b=app.bgColor.blue, a=app.bgColor.alpha} 
dlg:color{ id="color1", label="选择颜色", color=color1}
dlg:color{ id="color2", color=color2}
dlg:shades{ id="showhues", visible=false,onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      end end}
dlg:slider{ id="num_hues", label="生成数量", min=3, max=9, value=3 }
dlg:button{ id="ok", text="生成", focus=true, onclick = function() showOutput(dlg.data.color1, dlg.data.color2) end}
dlg:button{ id="cancel", text="取消", onclick = function() dlg:close() end}
dlg:show{wait = false}

-- 生成颜色渐变并显示它们
function showOutput(color1, color2)
    -- 求两种颜色各自的RGBA信息
    local m = {
        r=(color1.red - color2.red),
        g=(color1.green - color2.green),
        b=(color1.blue - color2.blue),
        a=(color1.alpha - color2.alpha)
    }
    numHues = dlg.data.num_hues+1
    huestable = {}
    for i=0,numHues do
        -- 线性地找出两个初始颜色之间的颜色
        local newRed = color1.red - math.floor(m.r * i / numHues)
        local newGreen = color1.green - math.floor(m.g * i / numHues)
        local newBlue = color1.blue - math.floor(m.b * i / numHues)
        local newAlpha = color1.alpha - math.floor(m.a * i / numHues)

        local newC = Color{r=newRed, g=newGreen, b=newBlue, a=newAlpha}
        -- 将生成的颜色插入到这个表里
        table.insert(huestable,newC)
    end
    -- 把结果打印在对话框里
    HHH = dlg.bounds.height
    dlg:modify{ id="showhues", colors=huestable, visible=true}
    dlg:modify{ id="color1", visible=false}
    dlg:modify{ id="color2", visible=false}
    dlg:modify{ id="num_hues", visible=false}
    dlg:modify{ id="ok", visible=false}
    dlg:modify{ id="cancel", text="确定" }
    --窗口太大我不喜欢，让它调小一点点
    if (numHues > 6) then
      www = dlg.bounds.width
      xxx = dlg.bounds.x
      else
      www = ((dlg.bounds.width/3)*2)
      xxx = (dlg.bounds.x + ((dlg.bounds.width - www)/2))
    end
    dlg.bounds = Rectangle(xxx,(dlg.bounds.y + ((HHH - dlg.bounds.height)/2)),www,dlg.bounds.height)
    app.refresh()
end
--print("X:"..dlg.bounds.x.." Y:"..dlg.bounds.y.." W:"..dlg.bounds.width.." H:"..dlg.bounds.height)