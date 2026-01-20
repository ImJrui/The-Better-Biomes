--level世界 -- task分支 -- room地块/彩蛋等

GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,
})

local AddLevelPreInitAny = AddLevelPreInitAny
local AddTaskPreInit = AddTaskPreInit

local Rooms = {
    ["Sacred"] = {
        enable = GetModConfigData("TheLargestSacred"),
        room_choices = {
            ["SacredBarracks"] = function() return 2 end,
            ["Bishops"] = function() return 2 end,
            ["Spiral"] = function() return 2 end,
            ["BrokenAltar"] = function() return 2 end,
            ["PitRoom"] = 2,
        },
    },
}

for taskname, data in pairs(Rooms) do
    if data.enable then
        AddTaskPreInit(taskname, function(task)
            for room, num in pairs(data.room_choices) do
                task.room_choices[room] = num
            end
        end)
    end
end

-- 从表A中移除表B和表C中的所有元素，返回新表
local function RemoveElementsFromA(A, B, C)
    -- 创建合并的哈希集合（包含B和C的所有元素）
    local setBC = {}
    
    -- 添加表B的元素
    for _, v in ipairs(B) do
        setBC[v] = true
    end
    
    -- 添加表C的元素
    for _, v in ipairs(C) do
        setBC[v] = true
    end
    
    -- 创建新表存储过滤后的元素
    local result = {}
    for _, v in ipairs(A) do
        if not setBC[v] then  -- 只保留不在B或C中的元素
            table.insert(result, v)
        end
    end
    return result
end

local forest_tasks = {}
local forest_cannottasks = {}
local caves_tasks = {}
local caves_cannottasks = {}

local tasks = {
    forest = {
        ["MacTusk"] = "The hunters",
        ["KillerBee"] = "Killer bees!",
        ["SecondaryDeciduous"] = "Mole Colony Deciduous",
        ["SecondaryMeteor"] = "Make a Beehat",
    },
    caves = {
        ["MoreAltars"] = "MoreAltars",
        ["SacredDanger"] = "SacredDanger",
        ["MilitaryPits"] = "MilitaryPits",
        ["MuddySacred"] = "MuddySacred",
    },
}

for name, task in pairs(tasks.forest) do
    local ModConfigData = GetModConfigData(name)
    if ModConfigData == 1 then
        table.insert(forest_tasks, task)
    elseif ModConfigData == 0 then
        table.insert(forest_cannottasks, task)
    end
end

for name, task in pairs(tasks.caves) do
    local ModConfigData = GetModConfigData(name)
    if ModConfigData == 1 then
        table.insert(caves_tasks, task)
    elseif ModConfigData == 0 then
        table.insert(caves_cannottasks, task)
    end
end

-- 创建通用处理函数
local function ProcessLevel(level, task_list, cannot_list)
    for _, task in ipairs(task_list) do
        table.insert(level.tasks, task)
    end
    level.numoptionaltasks = math.max(level.numoptionaltasks - #task_list, 0)
    level.optionaltasks = RemoveElementsFromA(level.optionaltasks, task_list, cannot_list)
end

AddLevelPreInitAny(function(level)
    if level.location == "forest" then
        ProcessLevel(level, forest_tasks, forest_cannottasks)
    end

    if level.location == "cave" then
        ProcessLevel(level, caves_tasks, caves_cannottasks)
    end
end)

