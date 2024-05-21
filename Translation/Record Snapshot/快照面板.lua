--[[
    Record v3.x - 快捷面板
    License: MIT
    Website: https://sprngr.itch.io/aseprite-record
    Source: https://github.com/sprngr/aseprite-record
]]

--[[
    Record Core Library
]]

error_messages = {
    invalid_api_version = "抱歉，你的 Aseprite 版本太老了，该脚本需要 Aseprite v1.2.30 或更新版本。请更新 Aseprite 以继续。",
    no_active_sprite = "没有可以用的活动文档，嗯，你是直接在主页上打开的吗？",
    save_required = "欧不！你还没有保存你的文档，我无法创建该快照。",
    snapshot_required = "您至少需要拍摄一个快照才能加载这个快照(延时摄影)。",
}

-- Utility functions
function check_api_version()
    if app.apiVersion < 15 then
        show_error(error_messages.invalid_api_version)
        return false
    else
        return true
    end
end

function show_error(error_msg)
    local error_dialog = Dialog("错误")
    error_dialog
        :label { text = error_msg }
        :newrow()
        :button { text = "关闭", onclick = function() error_dialog:close() end }
    error_dialog:show()
end

local function get_active_frame_number()
    local frame = app.activeFrame
    if frame == nil then
        return 1
    else
        return frame
    end
end

RecordingContext = {}

function RecordingContext:get_recording_index()
    local path = self.index_file
    if not app.fs.isFile(path) then
        return 0
    end
    local file = io.open(path, "r")
    assert(file)
    local contents = file:read()
    io.close(file)
    return tonumber(contents)
end

function RecordingContext:set_recording_index(index)
    local path = self.index_file
    local file = io.open(path, "w")
    assert(file)
    file:write("" .. index)
    io.close(file)
end

function RecordingContext.new(sprite)
    local self = {}
    setmetatable(self, { __index = RecordingContext })
    self.sprite_file_name = app.fs.fileTitle(sprite.filename)
    self.sprite_file_path = app.fs.filePath(sprite.filename)
    self:_init_directory()
    self.index_file = app.fs.joinPath(self.record_directory_path, "#index.txt")
    self:_promote_v2_to_v3()
    return self
end

function RecordingContext:_init_directory()
    local dir_name_legacy = "#快照 - "..self.sprite_file_name
    local dir_path_legacy = app.fs.joinPath(self.sprite_file_path, dir_name_legacy)
    if app.fs.isDirectory(dir_path_legacy) then
        -- For 2.x Target Directory Backwards Compatibility
        self._is_legacy_recording = true
        self.record_directory_name = dir_name_legacy
    else
        self._is_legacy_recording = false
        self.record_directory_name = "#快照 - "..self.sprite_file_name
    end

    self.record_directory_path = app.fs.joinPath(self.sprite_file_path, self.record_directory_name)
end

function RecordingContext:_promote_v2_to_v3()
    if not self._is_legacy_recording then
        return -- Is not v2.x
    end
    if app.fs.isFile(self.index_file) then
        return -- Is v2.x, but already has promoted structure
    end
    -- 2.x Add Missing Index File for Forward Compatibility
    local is_index_set = false
    local current_index = 0
    while not is_index_set do
        if not app.fs.isFile(self:get_recording_image_path(current_index)) then
            is_index_set = true
            self.context:set_recording_index(current_index)
        else
            current_index = current_index + 1
        end
    end
end

function RecordingContext:get_recording_image_path(index)
    return app.fs.joinPath(self.record_directory_path, self.sprite_file_name .. "_" .. index .. ".png")
end

Snapshot = {}

function Snapshot:_initialize(sprite)
    self.auto_snap_enabled = false
    self.auto_snap_delay = 1
    self.auto_snap_increment = 0
    self.context = nil

    -- Instance of Aseprite Sprite object
    -- https://github.com/aseprite/api/blob/master/api/sprite.md#sprite
    self.sprite = nil
    if sprite then
        self.sprite = sprite
        self.context = RecordingContext.new(sprite)
    end
end

function Snapshot:_increment_recording_index()
    local index = self.context:get_recording_index(self) + 1
    self.context:set_recording_index(index)
end

function Snapshot:get_recording_image_path(index)
    return self.context:get_recording_image_path(index)
end

function Snapshot.new()
    local self = {}
    setmetatable(self, { __index = Snapshot })
    self:_initialize(nil)
    return self
end

function Snapshot:is_active()
    if not self:is_valid() then
        return false
    end
    return self.auto_snap_enabled
end

function Snapshot:is_valid()
    if self.sprite then
        return true
    end
    return false
end

function Snapshot:reset()
    self:_initialize(nil)
end

function Snapshot:auto_save()
    if not self.auto_snap_enabled then
        return
    end
    if not self.sprite then
        return
    end

    self.auto_snap_increment = self.auto_snap_increment + 1
    if self.auto_snap_increment < self.auto_snap_delay then
        return
    end
    self.auto_snap_increment = 0
    self:save()
end

function Snapshot:_get_current_image()
    local image = Image(self.sprite.width, self.sprite.height, self.sprite.colorMode)
    image:drawSprite(self.sprite, get_active_frame_number())
    return image
end

function Snapshot:_get_saved_image_content(index)
    if index < 0 then
        return nil
    end
    local path = self:get_recording_image_path(index)
    if not app.fs.isFile(path) then
        return nil
    end
    local file = io.open(path, "rb")
    assert(file)
    local content = file:read("a")
    io.close(file)
    return content
end

function Snapshot:save()
    local image = self:_get_current_image()
    local index = self.context:get_recording_index()
    local path = self:get_recording_image_path(index)
    image:saveAs{
        filename = path, 
        palette = self.sprite.palettes[1]
    }

    local image_changed = true
    local prev_content = self:_get_saved_image_content(index - 1)
    if prev_content ~= nil then
        local curr_content = self:_get_saved_image_content(index)
        assert(curr_content ~= nil)
        if prev_content == curr_content then
            image_changed = false
        end
    end

    if image_changed then
        self:_increment_recording_index()
    end
end

function Snapshot:set_sprite(sprite)
    if not app.fs.isFile(sprite.filename) then
        return show_error(error_messages.save_required)
    end

    if (not self.sprite or self.sprite ~= sprite) then
        self:_initialize(sprite)
    end
end

function Snapshot:update_sprite()
    local sprite = app.activeSprite
    if not sprite then
        return show_error(error_messages.no_active_sprite)
    end
    self:set_sprite(sprite)
end

--[[
    End Record Core Library
]]

local snapshot = Snapshot.new()

local function take_snapshot()
    snapshot:update_sprite()
    if not snapshot:is_valid() then
        return
    end
    snapshot:save()
end

local function open_time_lapse()
    snapshot:update_sprite()
    if not snapshot:is_valid() then
        return
    end

    local path = snapshot:get_recording_image_path(0)
    if app.fs.isFile(path) then
        app.command.OpenFile { filename = path }
    else
        show_error(error_messages.snapshot_required)
    end
end

if check_api_version() then
    local main_dialog = Dialog {
        title = "记录 - 快照面板"
    }

    -- Creates the main dialog box
    main_dialog:button {
        text = "拍摄快照",
        onclick = function()
            take_snapshot()
        end
    }
    main_dialog:button {
        text = "打开快照(延时摄影)",
        onclick = function()
            open_time_lapse()
        end
    }
    main_dialog:show { wait = false }
end
