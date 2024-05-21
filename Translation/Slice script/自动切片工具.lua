----------------------------------------------------------------------
-- 一个自动切片工具脚本
-- 作者: Shitake
-- 来源于: https://community.aseprite.org/t/aseprite-slice-script/3130
----------------------------------------------------------------------
local TYPE_AUTO = "自动"
local TYPE_BY_SIZE = "按固定大小进行切分"
local TYPE_BY_COUNT = "按固定比例进行切分"
local METHOD_SMALL = "小"
local METHOD_SAFE = "安全"

local sprite = app.activeSprite

local dlg_conf = Dialog("切片类型")
dlg_conf
  :combobox{  id="type",
              label="类型",
              option=TYPE_BY_SIZE,
              options={ TYPE_BY_SIZE, TYPE_BY_COUNT }}
              -- 尚未完善，等待原作者更新
              -- options={ TYPE_AUTO, TYPE_BY_SIZE, TYPE_BY_COUNT } }
  :check{ id="clear", text="清理残留切片", selected=true }
  :color{ id="color", color=Color{ r=128, g=128, b=128, a=128 } }
  :button{ id="ok", text="确定", focus=true }
  :button{ text="取消" }

local dlg_slice_by_auto_data = Dialog("自动切分类型")
dlg_slice_by_auto_data
  :combobox{  id="method",
              label="类型",
              option=METHOD_SMALL,
              options={ METHOD_SMALL, METHOD_SAFE } }
  :separator{ label="锚点", text="锚点" }
  :number{ id="pivot_x", label="X:", text="0", decimals=integer }
  :number{ id="pivot_y", label="Y:", text="0", decimals=integer }
  :button{ id="ok", text="确定", focus=true }
  :button{ id="back", text="返回" }

local dlg_slice_by_size_data = Dialog("按固定大小")
dlg_slice_by_size_data
  :separator{ label="切分大小", text="切分大小" }
  :number{ id="width", label="宽:", text="8", decimals=integer }
  :number{ id="height", label="高:", text="8", decimals=integer }
  :separator{ label="边距", text="边距" }
  :number{ id="padding_x", label="X:", text="0", decimals=integer }
  :number{ id="padding_y", label="Y:", text="0", decimals=integer }
  :separator{ label="锚点", text="锚点" }
  :number{ id="pivot_x", label="X:", text="0", decimals=integer }
  :number{ id="pivot_y", label="Y:", text="0", decimals=integer }
  :button{ id="ok", text="确定", focus=true }
  :button{ id="back", text="返回" }

local dlg_slice_by_count_data = Dialog("按固定比例")
dlg_slice_by_count_data
    :separator{ label="划分比例", text="划分比例" }
    :number{ id="column", label="列:", text="1", decimals=integer }
    :number{ id="row", label="行:", text="1", decimals=integer }
    :separator{ label="边距", text="边距" }
    :number{ id="padding_x", label="X:", text="0", decimals=integer }
    :number{ id="padding_y", label="Y:", text="0", decimals=integer }
    :separator{ label="锚点", text="锚点" }
    :number{ id="pivot_x", label="X:", text="0", decimals=integer }
    :number{ id="pivot_y", label="Y:", text="0", decimals=integer }
    :button{ id="ok", text="确定", focus=true }
    :button{ id="back", text="返回" }

function slice_by_auto_show()
  dlg_slice_by_auto_data:show()
  if dlg_slice_by_auto_data.data.ok then 
    slice_by_auto()
  end
  if dlg_slice_by_auto_data.data.back then main() end
end

function slice_by_size_show()
  dlg_slice_by_size_data:show()
  if dlg_slice_by_size_data.data.ok then 
    slice_by_size()
  end
  if dlg_slice_by_size_data.data.back then main() end
end

function slice_by_count_show()
  dlg_slice_by_count_data:show()
  if dlg_slice_by_count_data.data.ok then 
    slice_by_count()
  end
  if dlg_slice_by_count_data.data.back then main() end
end

function slice_by_auto()
  clear_slice()
  data = dlg_slice_by_count_data.data
end

function slice_by_size()
  clear_slice()
  data = dlg_slice_by_size_data.data
  cell_width = data.width
  cell_height = data.height
  index = 0
  column = 0
  while column * cell_width < sprite.width do
    row = 0
    while row * cell_height < sprite.height do
      slice = sprite:newSlice(Rectangle(
        column  * cell_width + data.padding_x, 
        row * cell_height + data.padding_y, 
        cell_width - data.padding_x * 2, 
        cell_height - data.padding_y * 2))
      slice.color =  dlg_conf.data.color
      slice.name = sprite.filename .. "_" .. index
      slice.pivot = Point(data.pivot_x, data.pivot_y)
      index = index + 1
      row = row + 1
    end
    column = column + 1
  end
end

function slice_by_count()
  clear_slice()
  data = dlg_slice_by_count_data.data
  cell_width = math.floor(sprite.width / data.column)
  cell_height = math.floor(sprite.height / data.row)
  index = 0
  for column = 0, data.column - 1 do
    for row = 0, data.row - 1 do
      slice = sprite:newSlice(Rectangle(
        column * cell_width + data.padding_x, 
        row * cell_height + data.padding_y, 
        cell_width - data.padding_x * 2, 
        cell_height - data.padding_y * 2))
      slice.color =  dlg_conf.data.color
      slice.name = sprite.filename .. "_" .. index
      slice.pivot = Point(data.pivot_x, data.pivot_y)
      index = index + 1
    end
  end
end

function clear_slice()
  if not dlg_conf.data.clear then return end
  for i, s in ipairs(sprite.slices) do
    sprite:deleteSlice(s)
  end
end

function main()
  dlg_conf:show()
  --防呆操作，检测是否在活动文档中运行
  if (app.activeSprite == nil) then
     local Show_oops = Dialog("自动切片工具")
     Show_oops:label{text = "错误: 没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
     Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
     Show_oops:show{wait = false}
     return
  end
  if not dlg_conf.data.ok then return end
  if dlg_conf.data.type == TYPE_AUTO then slice_by_auto_show() end
  if dlg_conf.data.type == TYPE_BY_SIZE then slice_by_size_show() end
  if dlg_conf.data.type == TYPE_BY_COUNT then slice_by_count_show() end
end

main()