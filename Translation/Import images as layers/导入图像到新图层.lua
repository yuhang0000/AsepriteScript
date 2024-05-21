
-- Aseprite 脚本:导入图像作为图层

-- 作者: JJHaggar
-- 在人工智能模型的帮助下生成
-- 来自于:https://community.aseprite.org/t/aseprite-scripts-collection/3599/61

-- 遵循许可证: CC0 1.0 Universal 
-- https://creativecommons.org/publicdomain/zero/1.0/


-- 向用户提示选择文件
local dlg = Dialog("导入图像到新图层 - 选择文件")
dlg:label{
    id = "instructions_label",
    label = "提示:",
    text = "选择一张图像来添加到新的图层"
}
dlg:file{
  id = "file",
  label = "文件:",
  open = true,
  save = false,
  onchange = function(file) dlg:modify{id="file", text=file} end
}
dlg:button{ id = "ok", text = "确定" }
dlg:show()

-- 提取所选文件的目录路径
local file = dlg.data.file
local dir = app.fs.filePath(file)

-- 获取所选目录中的文件列表
if app.fs.isDirectory(dir) then
    local files = app.fs.listFiles(dir)
    for _,filename in ipairs(files) do
        -- 根据扩展名检查该文件是否为图像
        local extension = string.sub(filename, -4)
        if extension == ".png" or extension == ".jpg" or extension == ".bmp" or extension == ".gif" then
            -- 提取文件的完整路径
            local filePath = app.fs.joinPath(dir, filename)

            -- 检查是否有活动精灵
            local sprite = app.activeSprite
            if not sprite then
                return app.alert("没有可以用的活动文档来让我添加新图层, 嗯?你是直接在主页上打开的吗?")
            end

            -- 创建一个新图层，并给新图层命名
            local newLayer = sprite:newLayer()
            newLayer.name = filename

            -- 加载这个图像
            local image = Image{ fromFile=filePath }

            -- 如果图像可以加载，将其添加到文档中
            if image then
                -- 获取当前帧
                local currentFrame = app.activeFrame

                -- 将图像添加到当前帧的图层
                sprite:newCel(newLayer, currentFrame, image)
            else
                app.alert("无法加载图像: " .. filename)
            end

            -- 刷新画布
            app.refresh()
        end
    end
else
    print("错啦！你还没有选择文件。")
end