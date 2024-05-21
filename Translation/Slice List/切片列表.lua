-- 创建文档内所有切片的列表
-- 遗憾的是，还没有对动画的支持，因为它没有在 API 中出现(?)
-- 脚本由 Jonathan smamatrs 编写，在推特 @jsmars 和我的网站 https://jsmars.com 上查看我的开发
-- 脚本来自于: https://github.com/jsmars/DevTools

if not app.activeSprite then return app.alert "错误: 没有可以用的活动文档，嗯，你是直接在主页上打开的吗？" end

local dlg = Dialog("切片列表")

local count = 0;
for a,slice in ipairs(app.activeSprite.slices) do
	count = count + 1
	dlg:label{ label = "名称", text = slice.name }
	dlg:label{ label = "范围", text = "x: " .. slice.bounds.x .. "  y: " .. slice.bounds.y .. "  w: " .. slice.bounds.width .. "  h: " .. slice.bounds.height }
	if slice.center ~= nil then 
		dlg:label{ label = "9 片", text = "x: " .. slice.center.x .. "  y: " .. slice.center.y .. "  w: " .. slice.center.width .. "  h: " .. slice.center.height } end
	if slice.pivot ~= nil then 
		dlg:label{ label = "锚点", text = "x: " .. slice.pivot.x .. "  y: " .. slice.pivot.y } end
	dlg:label{ label = "数据", text = slice.data }
	
	dlg:button{ text = "删除", onclick= function() 
		app.activeSprite:deleteSlice(slice) 
		app.refresh()
		end }
end
if count == 0 then
	dlg:label{ label = "此文档没有发现切片" } end

dlg:show{}