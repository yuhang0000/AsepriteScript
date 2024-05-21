----------------------------------------------------------------------
-- 生成法线贴图
--
-- 它只适用于 RGB 颜色模式。
-- 来源于:https://gist.github.com/ruccho/efa1139ddd6da6d4d22def161209d2e7
----------------------------------------------------------------------

local dig = Dialog("生成法线贴图")
dig:check{id="FFFFF",text="反转 Y 轴 ",selected=false,onclick=function() dig:modify{id="start",focus=true} end}
dig:button{id="start",text="生成",focus=true,onclick=function() run() end}
dig:button{id="esc",text="关闭",focus=true,onclick=function() dig:close() end}
dig:show{wait=false}

function run()

if app.apiVersion < 1 then
    return app.alert("抱歉，这个脚本只能在 Aseprite v1.2.10-beta3 以及更高版本才能使用。")
  end
  
    --防呆操作，检测是否在活动文档中运行
  if (app.activeSprite == nil) then
    local Show_oops = Dialog("错误")
    Show_oops:label{text = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
    Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
    Show_oops:show{wait = false}
    return
  end
  
  local cel = app.activeCel
  if not cel then
    local Show_oops = Dialog("错误")
    Show_oops:label{text = "当前区域为空画布，无法操作。"}
    Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
    Show_oops:show{wait = false}
    return
  end

  local img = cel.image:clone()
  local position = cel.position
  
  if img.colorMode == ColorMode.RGB then
    local rgba = app.pixelColor.rgba
    local rgbaA = app.pixelColor.rgbaA
    for it in img:pixels() do
        local x = it.x
        local y = it.y
        local top = 2
        local left = 2
        local right = 2
        local bottom = 2
        if rgbaA(it()) < 255 then
            -- 忽略的透明像素
        else
        -- 处理像素
            -- 检测顶部
            if y > 0 then
                -- 检测
                local topPixel = img:getPixel(x, y - 1)
                if rgbaA(topPixel) < 255 then
                    top = 0
                elseif y > 1 then
                    topPixel = img:getPixel(x, y - 2)
                    if rgbaA(topPixel) < 255 then
                        top = 1
                    end
                end
            else
                top = 0
            end
            -- 检测底部
            if y < img.height - 1 then
                -- 检测
                local bottomPixel = img:getPixel(x, y + 1)
                if rgbaA(bottomPixel) < 255 then
                    bottom = 0
                elseif y < img.height - 2 then
                    bottomPixel = img:getPixel(x, y + 2)
                    if rgbaA(bottomPixel) < 255 then
                        bottom = 1
                    end
                end
            else
                bottom = 0
            end
            -- 检测左侧
            if x > 0 then
                -- 检测
                local leftPixel = img:getPixel(x - 1, y)
                if rgbaA(leftPixel) < 255 then
                    left = 0
                elseif x > 1 then
                    leftPixel = img:getPixel(x - 2, y)
                    if rgbaA(leftPixel) < 255 then
                        left = 1
                    end
                end
            else
                left = 0
            end
            -- 检测右侧
            if x < img.width - 1 then
                -- 检测
                local rightPixel = img:getPixel(x + 1, y)
                if rgbaA(rightPixel) < 255 then
                    right = 0
                elseif x < img.width - 2 then
                    rightPixel = img:getPixel(x + 2, y)
                    if rgbaA(rightPixel) < 255 then
                        right = 1
                    end
                end
            else
                right = 0
            end
            local light = 0

            -- -2 ~ +2
            local y_digit = - top + bottom
            local y = y_digit * 32 + 128
            local x_digit = - right + left
            local x = x_digit * 32 + 128
            local z_digit = math.max(math.abs(x_digit), math.abs(y_digit))
            local z = z_digit * -32 + 255
            local color
            if (dig.data.FFFFF == false) then
              color = rgba(x,y,z,255)
              else
              color = rgba(x,-y,z,255)
            end
            it(color)
        end
    end
    
  elseif img.colorMode == ColorMode.GRAY then
    local Show_oops = Dialog("错误")
    Show_oops:label{text = "此脚本只适用于 RGB 颜色模式。"}
    Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
    Show_oops:show{wait = false}
    return
  elseif img.colorMode == ColorMode.INDEXED then
    local Show_oops = Dialog("错误")
    Show_oops:label{text = "此脚本只适用于 RGB 颜色模式。"}
    Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
    Show_oops:show{wait = false}
    return
  end

  local sprite = app.activeSprite
  local frame = app.activeFrame
  local currentLayer = app.activeLayer
  local newLayerName = currentLayer.name .. "_法线贴图"
  local newLayer = nil
  for i,layer in ipairs(sprite.layers) do
    if layer.name == newLayerName then
        -- 写入法线的层已经存在
        newLayer = layer
    end
  end
  if newLayer == nil then
    newLayer = sprite:newLayer()
    newLayer.name = newLayerName
  end
  local newCel = sprite:newCel(newLayer, frame, img, position)

  app.refresh()
end