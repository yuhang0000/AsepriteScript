-- 用 弗洛伊德-斯坦伯格抖动算法 将图像转换为 Pico-8/Picotron 调色板的脚本
-- 由 aquova 编写, 2022-2024
-- https://github.com/aquova/aseprite-scripts

PICO8_PALETTE = {
    {r =   0, g =   0, b =   0},
    {r =  29, g =  43, b =  83},
    {r = 126, g =  37, b =  83},
    {r =   0, g = 135, b =  81},
    {r = 171, g =  82, b =  54},
    {r =  95, g =  87, b =  79},
    {r = 194, g = 195, b = 199},
    {r = 255, g = 241, b = 232},
    {r = 255, g =   0, b =  77},
    {r = 255, g = 163, b =   0},
    {r = 255, g = 236, b =  39},
    {r =   0, g = 228, b =  54},
    {r =  41, g = 173, b = 255},
    {r = 131, g = 118, b = 156},
    {r = 255, g = 119, b = 168},
    {r = 255, g = 204, b = 170},
}

PICOTRON_PALETTE = {
    {r =   0, g =   0, b =   0},
    {r = 108, g =  51, b =  44},
    {r = 160, g =  87, b =  61},
    {r = 239, g = 139, b = 116},
    {r = 247, g = 206, b = 175},
    {r = 234, g =  51, b =  82},
    {r = 179, g =  37, b =  77},
    {r = 116, g =  44, b =  82},
    {r =  69, g =  46, b =  56},
    {r =  94, g =  87, b =  80},
    {r = 158, g = 137, b = 123},
    {r = 194, g = 195, b = 199},
    {r = 253, g = 242, b = 233},
    {r = 243, g = 176, b = 196},
    {r = 238, g = 127, b = 167},
    {r = 209, g =  48, b = 167},
    {r =  32, g =  43, b =  80},
    {r =  48, g =  93, b = 166},
    {r =  73, g = 162, b = 160},
    {r =  86, g = 170, b = 248},
    {r = 133, g = 220, b = 243},
    {r = 183, g = 155, b = 218},
    {r = 129, g = 118, b = 153},
    {r = 111, g =  80, b = 147},
    {r =  39, g =  82, b =  88},
    {r =  58, g = 133, b =  86},
    {r =  79, g = 175, b =  92},
    {r = 104, g = 225, b =  84},
    {r = 165, g = 234, b =  95},
    {r = 252, g = 237, b =  87},
    {r = 242, g = 167, b =  59},
    {r = 219, g = 114, b =  44},
}

PALETTE = nil

-- 询问用户喜欢用哪种调色板(平台) 
function userInput()
    local dlg = Dialog("模拟 Pico-8 抖色")

    dlg:combobox{
        id="platform",
        label="使用哪种调色板?",
        option="Pico-8",
        options={"Pico-8", "Picotron"},
    }
    dlg:button{ id="ok", text="选择",  focus=true}
    dlg:show()

    return dlg.data
end

function convertImage()
    -- 获取当前图像
    
    --防呆操作，检测是否在活动文档中运行
    if (app.activeSprite == nil) then
      local Show_oops = Dialog("模拟 Pico-8 抖色")
      Show_oops:label{text = "错误: 没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
      Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
      Show_oops:show{wait = false}
      return
    end

    local img = app.activeCel.image

    -- 确保图像为RGBA
    if img.colorMode ~= ColorMode.RGB then
        local dlg = Dialog("模拟 Pico-8 抖色")
        dlg:label{ label="错误:", text="图像必须为 RGB 颜色模式，脚本才能运行" }
        dlg:button{ text="确定" }
        dlg:show()
        return
    end

    -- 复制图像到缓冲区
    local copy = img:clone()

    -- 设置指定调色板
    local spr = app.activeSprite
    local pal = createPalette()
    spr:setPalette(pal)

    for y = 0, copy.height - 1 do
        for x = 0, copy.width - 1 do
            -- 遍历每个像素，找到 Pico-8 调色板中最接近的颜色
            local p = copy:getPixel(x, y)
            local old = createRgbTable(p)
            local closest = findClosestColor(old)
            local err = sub(old, closest)

            local packed = app.pixelColor.rgba(closest.r, closest.g, closest.b, 0xFF)
            copy:drawPixel(x, y, packed)

            -- 将任何误差应用于相邻像素
            if (x + 1) < copy.width then
                applyError(copy, x + 1, y, err, 7.0 / 16.0)
            end

            if 0 <= (x - 1) and (y + 1) < copy.height then
                applyError(copy, x - 1, y + 1, err, 3.0 / 16.0)
            end

            if (y + 1) < copy.height then
                applyError(copy, x, y + 1, err, 5.0 / 16.0)
            end

            if (x + 1) < copy.width and (y + 1) < copy.height then
                applyError(copy, x + 1, y + 1, err, 1.0 / 16.0)
            end
        end
    end

    img:drawImage(copy)
end

-- 从上面的表创建一个新的调色板
function createPalette()
    local pal = Palette(#PALETTE)
    for i, v in pairs(PALETTE) do
        local color = app.pixelColor.rgba(v.r, v.g, v.b, 0xFF)
        pal:setColor(i - 1, color)
    end
    return pal
end

-- 使用 欧氏距离 找到最接近的匹配调色板颜色
function findClosestColor(p)
    local best_dist = 999999
    local best_idx = 0
    for k, v in pairs(PALETTE) do
        local dist = colorDist(p, v)
        if dist < best_dist then
            best_dist = dist
            best_idx = k
        end
    end
    return PALETTE[best_idx]
end

-- 计算 欧氏距离 的平方
function colorDist(a, b)
    return ((a.r - b.r) ^ 2) + ((a.g - b.g) ^ 2) + ((a.b - b.b) ^ 2)
end

-- 将32位颜色值转换为 Lua RGB表
function createRgbTable(p)
    local r = app.pixelColor.rgbaR(p)
    local g = app.pixelColor.rgbaG(p)
    local b = app.pixelColor.rgbaB(p)

    return {r = r, g = g, b = b}
end

-- 对相邻像素应用 弗洛伊德-斯坦伯格抖动算法 进行抖色
function applyError(img, x, y, err, percent)
    local nr = img:getPixel(x, y)
    local n = createRgbTable(nr)
    local nc = add(n, mul(err, percent))
    local np = app.pixelColor.rgba(clamp(nc.r), clamp(nc.g), clamp(nc.b), 0xFF)
    img:drawPixel(x, y, np)
end

-- 增加了两个 Lua RGB表
function add(a, b)
    return {r = a.r + b.r, g = a.g + b.g, b = a.b + b.b}
end

-- 两个 Lua RGB表 的减法
function sub(a, b)
    return {r = a.r - b.r, g = a.g - b.g, b = a.b - b.b}
end

-- Lua RGB表 与标量的乘法
function mul(a, val)
    return {r = a.r * val, g = a.g * val, b = a.b * val}
end

-- 锁定 0到255之间 的值
function clamp(v)
    if v < 0 then
        return 0
    elseif v > 0xFF then
        return 0xFF
    else
        return v
    end
end

do
    local palette = userInput()
    if palette.ok then
        local pal = palette.platform
        if pal == "Pico-8" then
            PALETTE = PICO8_PALETTE
        else
            PALETTE = PICOTRON_PALETTE
        end
        convertImage()
    end
end
