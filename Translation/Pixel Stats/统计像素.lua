--[[
                           --==统计像素 v1.2 (LUA)==--
                              脚本开发: Haloflooder
                              想法来源: CopherNeue

                                      描述
                  计算像素数量并输出出所有颜色的rgb值以及百分比!

                                      安装
      如何安装呢，你只需要做的就是在 文件>脚本 中单击“打开脚本文件夹”并拖动脚本
                              放到弹出的文件夹中。
]]
--来自于:https://community.aseprite.org/t/pixel-stats-check-the-total-amount-of-colored-pixels-you-used-in-your-art/1897

--防呆操作，检测是否在活动文档中运行
if (app.activeSprite == nil) then
  local Show_oops = Dialog("错误")
  Show_oops:label{text = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？"}
  Show_oops:button{text="关闭", onclick=function() Show_oops:close() end}
  Show_oops:show{wait = false}
  return
end

local execTime = os.clock();

-- 如果图像超过设定值，脚本将停止运行以防止Aseprite崩溃
-- 如果您的图像有超过500种颜色，您可以将数字更改为更高的数字
-- 但要小心!!任何大于1000的值都会冻结一个项目很长一段时间!
local maxColors = 500;

-- 如果您希望脚本运行得更快，请将此值更改为 false
-- 如果你把它设置为 false 的话，脚本将不会显示像素所在的颜色组(比如红色，橙色等)。
local showGroupedColors = true;

-- 将这些值更改为您认为最小值的白色
-- 举例:我认为任何低于16(16,16,16)的数字都是黑色的!
-- 举个栗子:我认为任何高于239(239,239,239)的数字都是白色的!
local considerBlack = 16;
local considerWhite = 239;

-- 显示有关代码执行的更多信息(输出调试信息)
local debug = false;
local initTime, imageTime, finalTime, groupTime, sortTime;

-- 让我们开始运行介个屎山代码吧!(原话)

local pc = app.pixelColor;
local img = app.activeImage;
local spr = app.activeSprite;
local sel = spr.selection;
local selected = true;
local box = sel.bounds;
if (box.width == 0 and box.height == 0) then
	box = Rectangle(0,0,img.width,img.height);
	selected = false;
end

local colorData = {};
local pixelAmt = box.width*box.height;

local hsvData = {};
local hsvColors = {
	"Red",
	"Orange",
	"Yellow",
	"Yellow Green",
	"Green",
	"Green Cyan",
	"Cyan",
	"Blue Cyan",
	"Blue",
	"Blue Magenta",
	"Magenta",
	"Red Magenta",
};

local hsvColorsForChinese = {
  "红",
	"橙",
	"黄",
	"黄绿",
	"绿",
	"青绿",
	"青",
	"青蓝",
	"蓝",
	"蓝紫",
	"紫",
	"紫红",
};

-- 我滴天纳，我完全不会LUA，这比 C Share 难学多了，瞧瞧这个
local NBspace = 0;
local NBspacePlus = "";

local justGray = 0;
local justWhite = 0;
local justBlack = 0;

for i=1, #hsvColors do
	hsvData[i] = 0;
end

-- 随机函数从这里开始
-- 用于 RGB转HSV 的转换器
-- 代码引用自这里: http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
function rgb2hsv(r, g, b) 
	r,g,b = r/255, g/255, b/255;

	local max = math.max(r, g, b);
	local min = math.min(r, g, b);
	local h,s,v
	v = max;

	local d = max-min;

	if max == 0 then s = 0 else s = d/max end

	if (max == min) then
		h = 0;
	else
		if (max == r) then
			h = (g-b)/d
			if (g < b) then h = h+6 end
		elseif (max == g) then h = (b-r)/d+2
		elseif (max == b) then h = (r-g)/d+4
		end
		h = h/6;
	end

	return {
		h * 255, 
		s * 255, 
		v * 255
	};
end

-- LUA 居然没有圆/弧... 欧不！！！
function round(n)
	return n%1 >= 0.5 and math.ceil(n) or math.floor(n)
end

-- 我滴妈呀…介个代码有点让人一头雾水的，但它与其他脚本相比，还是有用的
-- 这是为了帮助获得文本宽度
-- 请原谅我的 “一行” 数组
local charCodes = {};
for i=0, 128 do
	charCodes[i] = 5;
end
charCodes[32] = 4;charCodes[33] = 2;charCodes[34] = 4;charCodes[35] = 6;charCodes[36] = 6;charCodes[37] = 6;charCodes[38] = 6;charCodes[39] = 3;charCodes[40] = 3;charCodes[41] = 3;charCodes[42] = 6;charCodes[43] = 6;charCodes[44] = 6;charCodes[45] = 4;charCodes[46] = 2;charCodes[47] = 4;charCodes[49] = 3;charCodes[58] = 2;charCodes[59] = 2;charCodes[60] = 4;charCodes[62] = 4;charCodes[63] = 4;charCodes[64] = 9;charCodes[73] = 2;charCodes[74] = 3;charCodes[77] = 6;charCodes[79] = 6;charCodes[81] = 6;charCodes[84] = 6;charCodes[86] = 6;charCodes[87] = 8;charCodes[88] = 6;charCodes[89] = 6;charCodes[91] = 3;charCodes[92] = 4;charCodes[93] = 3;charCodes[94] = 6;charCodes[95] = 6;charCodes[96] = 4;charCodes[102] = 4;charCodes[105] = 2;charCodes[106] = 3;charCodes[108] = 2;charCodes[109] = 8;charCodes[114] = 4;charCodes[115] = 4;charCodes[116] = 3;charCodes[119] = 6;charCodes[120] = 6;charCodes[123] = 4;charCodes[124] = 2;charCodes[125] = 4;


-- 这个函数计算 Aseprite 文档中的像素数量。这严重
-- 依赖于使用默认字体的 Aseprite 所展示的UI界面。
function textWidth(str)
	local w = 0;
	str = str.."";
	for i=1, str:len() do
		w = w+charCodes[string.byte(string.sub(str,i,i))]
	end
	return w; -- 返回有多宽宽度
end

-- 不幸的是，我们为较小的像素创建分隔符的唯一方法是用 “:” 填充它 XD
function createSpacer(str,maxstr)
	local spacer = "";
	--if (not speedMeUp) then
		local w = textWidth(str);
		local maxW = textWidth(maxstr);
		local calc = (maxW-w)/4;
		
		local repeater = math.floor(calc);
		
		for i=0, repeater do
			spacer = spacer.." ";
		end

		if (calc-repeater >= .5) then
			spacer = ":"..spacer;
		end
	--end
	return spacer;
end

if (debug) then
	print(" ");
	print("[DEBUG] 花费了 "..(os.clock()-execTime).."ms 来完成初始化");
	print(" ");
	initTime = os.clock();
end

-- 现在咱们要正式运行这些代码哩!

-- 检测文档中的图层是否有超过1层
local multiLayers = false;
if (#spr.layers > 1) then
	multiLayers = true;
end
-- 询问用户是想单独分析这个图层还是整个图像(将所有可见图层全部合并!)
local flattenLayers = false;
local cancel = false;
if (multiLayers) then
	local question = app.alert{
		title="[统计像素 v1.2]",
		text={
			"俺在文档中检测到你有建立多个图层欸？","",
			"你是想整合所有可见图层再进行分析",
			"还是只想分析当前所选中的单个图层?"
		},
		buttons={"分析整个图层","分析当前图层","取消"}
	}
	if (question == 1) then
		flattenLayers = true;
		app.command.FlattenLayers{visibleOnly=true}
		img = app.activeImage;
	elseif (question == 3 or question == 0) then
		cancel = true;
	end
end
-- 获取像素数据!
if (not cancel) then
	local hueDivide = 256/#hsvColors;
	local bigGroup = 0;
	local overMax = false;
	local totalColors = 0;
	for y=box.y, box.y+(box.height-1) do
		for x=box.x, box.x+(box.width-1) do
			local c = img:getPixel(x, y);
			local r = pc.rgbaR(c);
			local g = pc.rgbaG(c);
			local b = pc.rgbaB(c);
			local a = pc.rgbaA(c);

			local cStr = r..","..g..","..b; -- 我们还没有列出不透明度
			if (a ~= 0) then -- 检查像素是否完全透明
				if ((colorData[cStr] == nil)) then -- 检查颜色信息是否已经在数组中
					colorData[cStr] = 1;
					totalColors = totalColors+1;
				else
					colorData[cStr] = colorData[cStr]+1;
				end

				if (maxColors <= totalColors) then
					overMax = true;
					break;
				end

				if (showGroupedColors) then -- 我们要列出这个颜色组吗?
					local h = rgb2hsv(r,g,b); -- 计算介个HSV值!
					local calcHue = (round(h[1]/hueDivide) % #hsvColors)+1;
					if (r <= considerBlack and g <= considerBlack and b <= considerBlack) then -- 检查有木有黑的
						justBlack = justBlack+1;
					elseif (r >= considerWhite and g >= considerWhite and b >= considerWhite) then -- 检查有木有白的
						justWhite = justWhite+1;
					elseif (r == g and g == b and r == b) then -- 检查有木有灰的
						justGray = justGray+1;
					else
						hsvData[calcHue] = hsvData[calcHue]+1;
					end
				end
			end
		end
		if (overMax) then
			break;
		end
	end
	if (debug) then
		print(" ");
		print("[DEBUG] 花费了 "..(os.clock()-initTime).."ms 来读取图像数据");
		print(" ");
		imageTime = os.clock();
	end

	-- 将数据从高到低排序
	local pixelStuff = {};

	for key in pairs(colorData) do table.insert(pixelStuff,{key, colorData[key]}) end

	table.sort(pixelStuff, function(a,b)
		a = a[2];
		b = b[2];
		return a > b;
	end)
	if (debug) then
		print(" ");
		print("[DEBUG] 花费了 "..(os.clock()-imageTime).."ms 对颜色数据进行排序");
		print(" ");
		sortTime = os.clock();
	end

	-- 分析数据!

	-- 图像数据
	print("######## 统计像素v1.2 ########");
	print(" ");
	print("===========图像数据===========");
	if (selected) then
		print("选择大小: "..box.width.."x"..box.height);
	else
		print("图像大小: "..img.width.."x"..img.height);
	end
	print("像素总数: "..pixelAmt);
	print("颜色总数: "..#pixelStuff);
	print(" ");

	-- 如果分析的颜色总数达到最大颜色，我们将显示此警告消息而不是颜色数据
	if (overMax) then
		print("########################")
		print("#         ERROR        #")
		print("########################\n")
		print("这张图片中的颜色数量超过了上线欸")
		print("如果超过了 "..maxColors.." 种颜色，脚本会挂掉，Aseprite连同你的文档也会一起炸掉。\n")
		print("如果你想要更改颜色的最大数量之后")
		print("继续运行这个脚本，你可以更改 “maxColors” 的数值")
		print("这个数值请在 “<你的脚本安装路径>/统计像素.lua” 里编辑。")
		print("\n\n")
	else
		-- 颜色分组统计
		
		-- 计算这个数据的最长字串符
		local NBspace1 = 0;
		for i=1, #hsvColors do
	   	if(NBspace < string.len(hsvData[i])) then
	   	 NBspace = string.len(hsvData[i]);
	   	 --print(NBspace);
		  end
	   	if(NBspace1 < string.len(hsvColorsForChinese[i])) then
	   	 NBspace1 = string.len(hsvColorsForChinese[i]);
	   	 --print(NBspace);
		  end
	  end
	  if(NBspace < string.len(justBlack)) then
	   	 NBspace = string.len(justBlack);
	   	 --print(NBspace);
	  end
		if(NBspace < string.len(justWhite)) then
	   	 NBspace = string.len(justWhite);
	   	 --print(NBspace);
	  end
	  if(NBspace < string.len(justGray)) then
	   	 NBspace = string.len(justGray);
	   	 --print(NBspace);
		end
	  NBspace1 = NBspace1+8;
	  --print(NBspace);
	  
	  
	  --空格复制机 2333
	  local NBspacePlus1 = "";
	  local num = 1
	  while num<NBspace do
	    NBspacePlus = NBspacePlus.." ";
	    num = num+1;
	  end
	  num = 1
	  while num<NBspace1 do
	    NBspacePlus1 = NBspacePlus1.." ";
	    num = num+1;
	  end
		
		if (showGroupedColors) then
			print("=========颜色分组统计=========");
			for i=1, #hsvColors do
				local key = hsvColors[i];
				local key1 = hsvColorsForChinese[i];
				local value = hsvData[i];
				--local spacer1 = createSpacer(key,"Blue Magenta"); -- 介素蓝紫色，因为它是列表中最长的单词
				--中文字符用介个
				print(key1..":"..string.sub(NBspacePlus1,(utf8.len(hsvColorsForChinese[i])*2),-1)..value..string.sub(NBspacePlus,string.len(hsvData[i]),-1).."   ("..(round(((value/pixelAmt)*100)*1000)/1000).."%)");
				--英文字符用介个
				--print(key..":"..string.sub(NBspacePlus1,string.len(hsvColors[i]),-1)..value..string.sub(NBspacePlus,string.len(hsvData[i]),-1).."   ("..(round(((value/pixelAmt)*100)*1000)/1000).."%)");
			end
			--print("黑:"..createSpacer("Black:","Blue Magenta").."  "..justBlack.."  ("..(round(((justBlack/pixelAmt)*100)*1000)/1000).."%)");
			--print("白:"..createSpacer("White:","Blue Magenta").."  "..justWhite.."  ("..(round(((justWhite/pixelAmt)*100)*1000)/1000).."%)");
			--print("灰:"..createSpacer("Gray:","Blue Magenta").."  "..justGray.."  ("..(round(((justGray/pixelAmt)*100)*1000)/1000).."%)");
			print("黑:".."            "..justBlack..string.sub(NBspacePlus,string.len(justBlack),-1).."   ("..(round(((justBlack/pixelAmt)*100)*1000)/1000).."%)");
      print("白:".."            "..justWhite..string.sub(NBspacePlus,string.len(justWhite),-1).."   ("..(round(((justWhite/pixelAmt)*100)*1000)/1000).."%)");
			print("灰:".."            "..justGray..string.sub(NBspacePlus,string.len(justGray),-1).."   ("..(round(((justGray/pixelAmt)*100)*1000)/1000).."%)");

			print(" ");
			if (debug) then
				print(" ");
				print("[DEBUG] 花费了 "..(os.clock()-sortTime).."ms 来显示图像和颜色分组数据");
				print(" ");
				groupTime = os.clock();
			end
		end

		-- 颜色数据
		print("=========颜色单独统计=========");
		
		-- 计算这个数据的最长字串符
		NBspace1 = 0;
		NBspacePlus1 = "";
		NBspace2 = 0;
		NBspacePlus2 = "";
		for i=1, #pixelStuff do
	   	if(NBspace1 < string.len(pixelStuff[i][1])) then
	   	 NBspace1 = string.len(pixelStuff[i][1]);
	   	 --print(NBspace);
		  end
	   	if(NBspace2 < string.len(pixelStuff[i][2])) then
	   	 NBspace2 = string.len(pixelStuff[i][2]);
	   	 --print(NBspace);
		  end
		end
	  
	  --空格复制机 2333
	  local num = 1
	  while num<NBspace1 do
	    NBspacePlus1 = NBspacePlus1.." ";
	    num = num+1;
	  end
	  local num = 1
	  while num<NBspace2 do
	    NBspacePlus2 = NBspacePlus2.." ";
	    num = num+1;
	  end
		
		for i=1, #pixelStuff do
			local key = pixelStuff[i][1];
			local value = pixelStuff[i][2];
			local spacer1 = createSpacer(key,"000,000,000");
			local spacer2 = createSpacer(value,pixelStuff[1][2].."");
			print(key..":"..string.sub(NBspacePlus1,string.len(pixelStuff[i][1]),-1).."   "..value..string.sub(NBspacePlus2,string.len(pixelStuff[i][2]),-1).."   ("..(round(((value/pixelAmt)*100)*1000)/1000).."%)");
		end
		if (debug) then
			print(" ");
			print("[DEBUG] 花费了 "..(os.clock()-groupTime).."ms 来显示颜色分组数据");
			print(" ");
		end
	end
	if (flattenLayers) then
		app.command.Undo();
	end

	finalTime = os.clock()-execTime
	print(" ");
	print("总共花费了 "..(round(finalTime*1000)/1000).."ms 来完成统计计算");
end