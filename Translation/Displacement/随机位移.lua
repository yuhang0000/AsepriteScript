--[[

一个用于 Asesprite 的简单像素位移脚本。

移动所有命中概率测试的像素点，X/Y移动最大值是指定随机移动的最大位移量.

原作者: Heidi Uri
制作时间: 2019-06-29
来自于: https://community.aseprite.org/t/script-displacement/3438
--]]

--防呆操作，检测是否在活动文档中运行
if (app.activeSprite == nil) then
  local Show_oops = Dialog("错误")
  Show_oops:label{text = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
  Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
  Show_oops:show{wait = false}
  return
end

function errorcel()
  local cel_oops = Dialog("错误")
  cel_oops:label{text = "当前区域为空画布，无法操作。"}
  cel_oops:button{text="关闭", onclick=function() cel_oops:close() end}
  cel_oops:show{wait = false}
  return
end

local dialog = Dialog("随机移动")
local wobuganle = 0

--是否添加新图层
local addFrame = 0;
function addFrames() 
  if (addFrame == 0) then 
    addFrame = 1; 
    else 
    addFrame = 0; 
  end
  dialog:modify { id="run", focus=true}
end
--是否应用到所有图层
local alllayer = 0;
function alllayers() 
  if (alllayer == 0) then 
    alllayer = 1; 
    else 
    alllayer = 0; 
  end
  dialog:modify { id="run", focus=true}
end

dialog:number { id="probability", label="随机概率", text="0.5", decimals=2}
dialog:number { id="xDistance", label="X 轴移动最大值", text="1", decimals=0}
dialog:number { id="yDistance", label="Y 轴移动最大值", text="1", decimals=0}
dialog:check  { id="NewFrame", label="创建到下一帧", selected=false, onclick = function() addFrames() end}
dialog:check  { id="Layers", label="应用到所有图层", selected=false, onclick = function() alllayers() end}
dialog:button { id="info", text="关于", onclick = function()
    print("一种像素点随机位移脚本，该脚本根据给定的概率来随机移动像素点。")
    print(" ")
    print("概率范围一般设置在 0 - 1 之间 (超过了范围也能用啦)。如果设置为 1 的话，每个像素点都将会执行位移 (并不是全部像素点都向同一方向位移，每个像素点单独位移随机方向，1 即为 100% 概率事件)。")
    print("如果某个像素点概率被命中的话，上面的 X 距离和 Y 距离是限制该像素点随机位移的最大距离。\n")
    print("修改了以下内容: ")
    print("修复了该脚本仅对背景图层生效问题，现在可对任意图层进行修改;")
    print("添加了 “创建到下一帧” 的选项。")
    print("添加了 “应用到所有图层” 的选项。")
    print(" ")
    print("原作者: Heidi Uri")
    print("汉化者: yuhang0000")
    print("制作时间: 2019-06-29")
    print("汉化时间: 2024-05-14 \n ")
end}
dialog:button { id="run", text="运行", focus=true, onclick = function() displace() end}
dialog:button { text="关闭", onclick = function() dialog:close() end}
dialog:show{wait=false};

local sprites

--是否应用所有图层
function displace()
  wobuganle = 0
  if(alllayer == 1) then
    --创建新帧
    if(addFrame == 1) then
      --print("创建新帧到: "..(app.frame.frameNumber+1).."F")
      app.command.NewFrame()
    end
    --遍历所有在同一帧的cel
    sprites = app.sprite
    
    if (#sprites.cels == 0) then
      errorcel()
      return
    end
    
    ThisIsNumber = 0
    for i,cel233 in ipairs(sprites.cels) do
      if(cel233.frameNumber == app.frame.frameNumber) then
        ThisIsNumber = ThisIsNumber + 1
        --print(i)
        cel = sprites.cels[i]
        Run()
      end
    end
    if (ThisIsNumber == 0) then
      errorcel()
      return
    end
    
  else
      --创建新帧
      if(addFrame == 1) then
        --print("创建新帧到: "..(app.frame.frameNumber+1).."F")
        app.command.NewFrame()
      end
    sprites = app.layer
    CheckCelMax()
  end
    
end

--print(app.layer)

--让我看看当前帧号是不是超过了cel的总量
function CheckCelMax()
  
  --print("cel总数: "..#sprites.cels.."  位置: "..sprites.cels[#sprites.cels].frameNumber)
  if (#sprites.cels == 0) then
      errorcel()
      wobuganle = 1
      return
    else
      if (#sprites.cels >= app.frame.frameNumber) then
       cel = sprites.cels[app.frame.frameNumber]
       aaa = app.frame.frameNumber
      else
       cel = sprites.cels[#sprites.cels]
       aaa = (#sprites.cels)
      end
       CheckCel()
       if (wobuganle == 0) then Run() end
  end
    
end

--当cel编号与当前帧号不一致时，尝试纠正
function CheckCel()
  --print("当前cel位置: "..cel.frameNumber)
  --print("当前帧位置: "..app.frame.frameNumber)
  
  if (cel.frameNumber < app.frame.frameNumber) then
    --print("小了")
    while (cel.frameNumber ~= app.frame.frameNumber) do
      aaa = aaa + 1
      if (aaa > #sprites.cels) then
        errorcel()
        wobuganle = 1
        return
      end
      cel = sprites.cels[aaa]
      --print("纠正cel中: "..cel.frameNumber)
      if (cel.frameNumber > app.frame.frameNumber) then
        errorcel()
        wobuganle = 1
        return
      end
    end
  end
  if (cel.frameNumber > app.frame.frameNumber) then
    --print("大了")
    while (cel.frameNumber ~= app.frame.frameNumber) do
      aaa = aaa - 1
      if (aaa < 1) then
        errorcel()
        wobuganle = 1
        return
      end
      cel = sprites.cels[aaa]
      --print("纠正cel中: "..cel.frameNumber)
      if (cel.frameNumber < app.frame.frameNumber) then
        errorcel()
        wobuganle = 1
        return
      end
    end
  end
  
  --print("纠正后: "..cel.frameNumber.."  cel序号: "..aaa)
end

--开始随机运算
function Run()
  local image = Image(cel.image.width, cel.image.height, cel.image.colorMode)   
  for x = 0, cel.image.width do
  for y = 0, cel.image.height do
        local pixel = cel.image:getPixel(x, y)
        
        if math.random(0, 1) < dialog.data.probability then
            local dx = math.random(-dialog.data.xDistance, dialog.data.yDistance)
            local dy = math.random(-dialog.data.xDistance, dialog.data.yDistance)
            local x2 = x + dx
            local y2 = y + dy
            
            if x2 >= 0 and x2 < cel.image.width and y2 >= 0 and y2 < cel.image.height then
                pixel = cel.image:getPixel(x + dx, y + dy)
            end
            
            image:drawPixel(x, y, pixel)
        else
            image:drawPixel(x, y, pixel)
        end                
  end
  end        
  cel.image = image
  --刷新图层
  app.refresh()
  --print("==========完成==========\n ")
end

--[[练习，遍历所有符合相同帧的cel合集
for i,output in ipairs(app.sprite.cels) do
  if(output.frameNumber == app.frame.frameNumber) then
    print(i)
  end
end
]]--