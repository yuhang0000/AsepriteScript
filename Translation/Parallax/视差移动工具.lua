-- 视差 - 由 Hazel Quantock 编写
-- 来源:https://github.com/TekF/Aseprite-Scripts
-- 按不同的数量来滚动图层
-- 控件在一个方向上批量移动所有层,因此可以轻松地定位一系列帧


local help = Dialog("帮助")
		:label{text="视差(Parallax)    由 Hazel Quantock 编写 @TekF"}
		:separator()
		:label{text="默认情况下，每一层的移动速度是下面一层的两倍。"}
		:newrow()
		:label{text="在图层名称中输入“w=x”、“w=y”或“w=xy”，"}
		:newrow()
		:label{text="以将图层包裹在 x 和/或 y 轴上。"}
		:newrow()
		:label{text="如何自定义每个图层的移动速度:"}
		:newrow()
		:label{text="“<图层滴名字> s=<移动速度>”"}
		:newrow()
		:label{text="举个栗子:"}
		:newrow()
		:label{text="#图层2 s=7"}
		:newrow()
		:label{text="#图层1 s=3"}

-- 保留图像的原始位置，这样就可以处理子像素的移动(单元格位置存储为整数))
local positions = {}

function Scroll( x, y )

	local sprite = app.activeSprite
	--防呆操作，检测是否在活动文档中运行
  if (app.activeSprite == nil) then
    local Show_oops = Dialog("错误")
    Show_oops:label{text = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
    Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
    Show_oops:show{wait = false}
    return
  end

	local deb = nil
	--deb = Dialog("Debug")   -- 或者，也许我可以使用 app.command.DeveloperConsole

	for i,layer in ipairs(sprite.layers) do
		if layer ~= nil then
			-- 从层名中读取速度值
			local speed = tonumber(string.match( layer.name, "s=([0-9%.%-]+)" ))
			if deb then deb:label{ label="speed", text=tostring(speed) } end
			
			if speed == nil then
				-- 默认速度:每一层的移动速度是下一层的两倍
				speed = 2^(i-1)
			end
		
			-- 从层名读取包裹值(wrap到底是什么意思鸭??)
			local wrapX,wrapY = string.match( layer.name, "w=(x?)(y?)" )
			if deb then deb:label{ label="wrap", text=tostring(wrapX)..tostring(wrapY) } end

			-- 将它们转换为布尔值
			if wrapX=="x" then wrapX = true else wrapX = false end
			if wrapY=="y" then wrapY = true else wrapY = false end
			
			local cel = layer:cel(app.activeFrame)

			if cel ~= nil and speed ~= 0 then

				-- get position from array, if not there or != stored one (as int), set from the int(不会翻译:从数组中获取位置，如果不存在，或者 != 存储一个 (作为int)，从int中设置)
				local pos = positions[layer.name]
				if pos == nil or math.floor(pos[1]) ~= cel.position.x or math.floor(pos[2]) ~= cel.position.y then
					--注意，如果图层改变了包裹，这些值将会出错
          --但我还没有处理这种情况，因为换行标志在层名中，
          --这样代码就会认为这是一个不同的层，不会被混淆!
					pos = { cel.position.x, cel.position.y }
					if wrapX then pos[1] = 0.0 end
					if wrapY then pos[2] = 0.0 end
				end
				
				pos[1] = pos[1] + x*speed
				pos[2] = pos[2] + y*speed

				if wrapX or wrapY then
					local ipos = { math.floor(pos[1]), math.floor(pos[2]) }
					
					-- 选择要包裹的区域
					-- 如果图层比精灵/画布大，选它(否则会在小范围区域内出现奇怪的东西)
					local bounds = sprite.bounds:union(Rectangle(cel.bounds))
					sprite.selection = Selection(bounds)
					
					-- 设置它正在工作的层(似乎无法指定这个，所以设置应用程序的当前层)
					app.activeLayer = layer -- 它没有说我可以这样做，但它似乎并不介意

					-- 这些都是愚蠢的!只要给我一个2D输入!
					if wrapX and ipos[1] ~= 0 then
						if ipos[1] > 0 then
							app.command.MoveMask{ target="content", direction="right", units="pixel", quantity=ipos[1], wrap=true }
						else
							app.command.MoveMask{ target="content", direction="left", units="pixel", quantity=-ipos[1], wrap=true }
						end
						pos[1] = pos[1]-ipos[1]
					end
					if wrapY and ipos[2] ~= 0 then
						if ipos[2] > 0 then
							app.command.MoveMask{ target="content", direction="down", units="pixel", quantity=ipos[2], wrap=true }
						else
							app.command.MoveMask{ target="content", direction="up", units="pixel", quantity=-ipos[2], wrap=true }
						end
						pos[2] = pos[2]-ipos[2]
					end
					app.command.DeselectMask()
				end
				
				if not wrapX and not wrapY then
					cel.position = Point( pos[1], pos[2] )
				else if not wrapX then
					cel.position = Point( pos[1], cel.position.y )
				else if not wrapY then
					cel.position = Point( cel.position.x, pos[2] )
				end end end
				
				positions[layer.name] = pos
			end
		end
	end

	if deb then deb:show{wait=false} end
	
	-- 呃呃呃!需要刷新!
	app.refresh()
end


local dlg = Dialog("视差控制台")
dlg
	:button{text=utf8.char(0x2196),onclick=function() Scroll( 1, 1 ) end}
	:button{text="↑",onclick=function() Scroll( 0, 1 ) end}
	:button{text=utf8.char(0x2197),onclick=function() Scroll( -1, 1 ) end}
	:newrow()
	:button{text="←",onclick=function() Scroll( 1, 0 ) end}
	:button{text="?", onclick=function() help:show{} end}
	:button{text="→",onclick=function() Scroll( -1, 0 ) end}
	:newrow()
	:button{text=utf8.char(0x2199),onclick=function() Scroll( 1, -1 ) end}
	:button{text="↓",onclick=function() Scroll( 0, -1 ) end}
	:button{text=utf8.char(0x2198),onclick=function() Scroll( -1, -1 ) end}
	:show{wait=false}
--dlg.bounds = Rectangle( 250, 500, dlg.bounds.width, dlg.bounds.height );

