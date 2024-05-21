--作者: GunTurtle
--来源于:https://itch.io/queue/c/565204/aseprite?game_id=445017

--防呆操作，检测是否在活动文档中运行
if (app.activeSprite == nil) then
  local Show_oops = Dialog("错误")
  Show_oops:label{text = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
  Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
  Show_oops:show{wait = false}
  return
end

local image = app.activeSprite
local rect=Rectangle(30,30,30,30)
local imgw = image.width
local imgh= image.height

local info = Dialog("透视生成器")
	info:slider{
		id="cenx",
		label="中心点 X",
		min=0,
		max=imgw,
		value=imgw/2
	}
	info:slider{
		id="ceny",
		label="中心点 Y",
		min=0,
		max=imgh,
		value=imgh/2	
	}
	info:slider{id="zgs",label="Z 轴线条数量",min=1,max=30,value=5}
	info:slider{id="xgs",label="X/Y 轴线条数量",min=1,max=30,value=5}
	info:separator{id="animsep",text="生成帧动画"}
	info:number{id="fcount",label="生成帧数"}
	info:slider{id="mox",label="X 轴位移",min=0,max=imgw,value=imgw/2}
	info:slider{id="moy",label="Y 轴位移",min=0,max=imgh,value=imgh/2}
	info:number{id="moz",label="Z 轴位移"}
	info:check{id="anlin",label="平滑移动 X/Y 轴"}
	info:check{id="anliz",label="平滑移动 Z 轴"}
	info:button{id="ok",text="生成",focus=true}
	info:show({wait=false})
	local cx=info.data.cenx --start points
	local cy=info.data.ceny
	local fc=math.max(info.data.fcount,1)
	local xm=info.data.mox
	local ym=info.data.moy
	local zg=info.data.zgs
	local xg=info.data.xgs
	local zm=info.data.moz
	local cz=0

function run()
local nll = image:newLayer()
for q=1,fc do
	app.command.ClearCel()
	local dx=info.data.cenx
	local dy=info.data.ceny
if info.data.fcount>0 then
if info.data.anlin then

	cx=((dx+xm)/2)+(dx-xm)*math.cos(((q-1)/fc)*math.pi)/2
	cy=((dy+ym)/2)+(dy-ym)*math.cos(((q-1)/fc)*math.pi)/2
else
	cx=info.data.cenx+((xm-dx)/fc)*q
	cy=info.data.ceny+((ym-dy)/fc)*q
end
end

for i=0,1,1/xg do for j=0,1 do
app.useTool{
	tool="line",
	brush=Brush(1),
	points={Point(imgw*i,imgh*j),Point(cx,cy)}
} end end
for i=0,1 do for j=0,1,1/xg do
app.useTool{
	tool="line",
	brush=Brush(1),
	points={Point(imgw*i,imgh*j),Point(cx,cy)}
} end end

if info.data.anliz then
cz=zm+(zm)*math.cos(((q-1)/fc)*math.pi)
else
	cz=zm*(q/fc)
end

for i=0,10,10/zg do
local zz=(i+cz)%(10/zg)+i
app.useTool{
	tool="rectangle",
	brush=Brush(1),
	points={Point(cx-cx/zz,cy-cy/zz),Point(cx-(cx-imgw)/(zz),cy-(cy-imgh)/zz)}
}
end
if fc>1 and q<fc then
app.command.NewFrame()	end
end end

if info.data.ok then
	app.transaction(run)
end

