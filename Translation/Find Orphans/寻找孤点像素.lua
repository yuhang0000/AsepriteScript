------------------------------------------------------------------------
-- 一个查找孤点像素的 Aseprite 脚本
--
-- by Willow & Edward Willis
-- 遵循 MIT 协议: 免费应用于所有用途，商业或其他用途
-- 来源于: https://shemake.dev/tech/viewing/Aseprite_findOrphans
------------------------------------------------------------------------
if (app.activeSprite == nil) then
  local Show_oops = Dialog("错误")
  Show_oops:label{text = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
  Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
  Show_oops:show{wait = false}
  return
end

-- 简单的搜索。检查每个像素与临近像素
-- (酱样子稿效率更高，但无趣...)
local function selectOrphans()

    local img = app.activeImage
    local cel = img.cel
    local box = cel.bounds
    local xCel = box.x
    local yCel = box.y
    local i = 0
    local img_width = img.width - 1
    local img_height = img.height - 1;

    local newSel = Selection()

    -- 创建一个阵列 init 0
    grid = {}
    for i = 1, 8 do
        grid[i] = {}
        for j = 1, 2 do
            grid[i][j] = 0 -- 填充这个矩阵的值
        end
    end

    for y = 0, img_height do
        for x = 0, img_width do
            local color = img:getPixel(x, y)

            -- 这里存储了周围 8 个像素的坐标
            -- 左上
            grid[1][1] = x - 1;
            grid[1][2] = y - 1;
            -- 左
            grid[2][1] = x - 1;
            grid[2][2] = y;
            -- 左下
            grid[3][1] = x - 1;
            grid[3][2] = y + 1;
            -- 下
            grid[4][1] = x;
            grid[4][2] = y + 1;
            -- 右下
            grid[5][1] = x + 1;
            grid[5][2] = y + 1;
            -- 右
            grid[6][1] = x + 1;
            grid[6][2] = y;
            -- 右上
            grid[7][1] = x + 1;
            grid[7][2] = y - 1;
            -- 上
            grid[8][1] = x;
            grid[8][2] = y - 1;

            -- 检查这 8 个像素的颜色
            local isOrphan = true
            for i = 1, 8 do

                -- 如果 x 超过预定范围
                if(grid[i][1] < 0 or grid[i][1] > img_width) then
                    goto continue
                end
                -- 如果 y 超过预定范围
                if(grid[i][2] < 0 or grid[i][2] > img_height) then
                    goto continue
                end

                if(color == img:getPixel(grid[i][1], grid[i][2])) then
                    isOrphan = false;
                    goto endloop
                end
                ::continue::
            end

            ::endloop::
            if( isOrphan ) then
                local px = Rectangle(xCel + x, yCel + y, 1, 1)
                newSel:add(px)
            end
        end
    end

    local spr = app.activeSprite
    local prevSel = spr.selection
    if not prevSel.isEmpty then
        newSel:intersect(prevSel)
    end

    -- 将新的选区设置为活动选区，并再次缩小画布
    spr.selection = newSel
end

-- 运行介个脚本
do
    selectOrphans()
end
