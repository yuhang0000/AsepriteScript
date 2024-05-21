-- 颜色混合器 v2.0
-- 以基准颜色为准, 生成衍生的色深, 明度, 暗度和色相。
-- 由 Dominick John 编写, 这是他的推特账号: @dominickjohn
-- 由 David Capello 提供支持与帮助。
-- https://github.com/dominickjohn/aseprite/

-- 怎么用捏:
--    在 文件>脚本 中单击 “打开脚本文件夹” 并拖动这个脚本到弹出的文件夹里
--    你可以在 文件>脚本>颜色混合器 中打开此脚本

-- 一些操作说明:
--    基色: 基准颜色，点击切换前景色/背景色。
--    取当前色: 顾名思义，点击即可获取当前画笔所使用的前景色和背景色。
--    鼠标左键: 设置当前所选颜色为前景色
--    鼠标右键: 设置当前所选颜色为背景色
--    鼠标中键: 设置当前所选颜色为前景色和基准颜色

function lerp(first, second, by)
  return first * (1 - by) + second * by
end

function lerpRGBInt(color1, color2, amount)
  local X1 = 1 - amount
  local X2 = color1 >> 24 & 255
  local X3 = color1 >> 16 & 255
  local X4 = color1 >> 8 & 255
  local X5 = color1 & 255
  local X6 = color2 >> 24 & 255
  local X7 = color2 >> 16 & 255
  local X8 = color2 >> 8 & 255
  local X9 = color2 & 255
  local X10 = X2 * X1 + X6 * amount
  local X11 = X3 * X1 + X7 * amount
  local X12 = X4 * X1 + X8 * amount
  local X13 = X5 * X1 + X9 * amount
  return X10 << 24 | X11 << 16 | X12 << 8 | X13
end

function colorToInt(color)
  return (color.red << 16) + (color.green << 8) + (color.blue)
end

function colorShift(color, hueShift, satShift, lightShift, shadeShift)
  local newColor = Color(color) -- 直接把颜色复制一份

  -- 偏移色相
  newColor.hslHue = (newColor.hslHue + hueShift * 360) % 360

  -- 偏移暗度
  if (satShift > 0) then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0) then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- 偏移明度
  if (lightShift > 0) then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0) then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- 偏移色深
  local newShade = Color {red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0) then
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0) then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

function showColors(shadingColor, fg, bg, windowBounds)
  local dlg
  dlg =
    Dialog {
    title = "颜色混合器"
  }

  -- 缓存
  local FGcache = app.fgColor
  if(fg ~= nil) then
    FGcache = fg
  end

  local BGcache = app.bgColor
  if(bg ~= nil) then
    BGcache = bg
  end

  -- 给当前颜色生成阴影
  local C = app.fgColor
  if(shadingColor ~= nil) then
    C = shadingColor
  end

  -- 生成色深(阴影)
  local S1 = colorShift(C, 0, 0.3, -0.6, -0.6)
  local S2 = colorShift(C, 0, 0.2, -0.2, -0.3)
  local S3 = colorShift(C, 0, 0.1, -0.1, -0.1)
  local S5 = colorShift(C, 0, 0.1, 0.1, 0.1)
  local S6 = colorShift(C, 0, 0.2, 0.2, 0.2)
  local S7 = colorShift(C, 0, 0.3, 0.5, 0.4)

  -- 生成明度
  local L1 = colorShift(C, 0, 0, -0.4, 0)
  local L2 = colorShift(C, 0, 0, -0.2, 0)
  local L3 = colorShift(C, 0, 0, -0.1, 0)
  local L5 = colorShift(C, 0, 0, 0.1, 0)
  local L6 = colorShift(C, 0, 0, 0.2, 0)
  local L7 = colorShift(C, 0, 0, 0.4, 0)

  -- 生成暗度
  local C1 = colorShift(C, 0, -0.5, 0, 0)
  local C2 = colorShift(C, 0, -0.2, 0, 0)
  local C3 = colorShift(C, 0, -0.1, 0, 0)
  local C5 = colorShift(C, 0, 0.1, 0, 0)
  local C6 = colorShift(C, 0, 0.2, 0, 0)
  local C7 = colorShift(C, 0, 0.5, 0, 0)

  -- 生成色相
  local H1 = colorShift(C, -0.15, 0, 0, 0)
  local H2 = colorShift(C, -0.1, 0, 0, 0)
  local H3 = colorShift(C, -0.05, 0, 0, 0)
  local H5 = colorShift(C, 0.05, 0, 0, 0)
  local H6 = colorShift(C, 0.1, 0, 0, 0)
  local H7 = colorShift(C, 0.15, 0, 0, 0)

  -- 把结果打印到窗口上
  dlg:
  shades {
     -- 基色
    id = "base",
    label = "基色",
    colors = {FGcache, BGcache},
    onclick = function(ev)
      showColors(ev.color, FGcache, BGcache, dlg.bounds)
      dlg:close()
    end
  }:button {
    -- 取当前色
    id = "get",
    text = "取当前色",
    onclick = function()
      showColors(app.fgColor, app.fgColor, app.bgColor, dlg.bounds)
      dlg:close()
    end
  }:shades {
     -- 色深
    id = "sha",
    label = "色深",
    colors = {S1, S2, S3, C, S5, S6, S7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- 明度
    id = "lit",
    label = "明度",
    colors = {L1, L2, L3, C, L5, L6, L7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- 暗度
    id = "sat",
    label = "暗度",
    colors = {C1, C2, C3, C, C5, C6, C7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- 色相
    id = "hue",
    label = "色相",
    colors = {H1, H2, H3, C, H5, H6, H7},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }
  
  dlg:show {wait = false, bounds = windowBounds}
end

-- 脚本触发器
do
  showColors(app.fgColor)
end
