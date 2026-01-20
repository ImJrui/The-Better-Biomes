GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,
})

local modimport = modimport
local AddSimPostInit = AddSimPostInit

AddSimPostInit(function()
    -- print("tutu:世界天数:"..TheWorld.state.cycles)
    if TheWorld and TheWorld.state.cycles > 0 then
        return
    end

    if GetModConfigData("RemoveTwiggyTree") then
        local success = false
        for guid, ent in pairs(Ents) do
            if ent.prefab and string.find(ent.prefab, "twiggy") and ent:HasTag("tree") then
                local x, y, z = ent.Transform:GetWorldPosition()
                SpawnPrefab("sapling").Transform:SetPosition(x, y, z)
                ent:Remove()
                success = true
            end
        end
        if success then
            print("The twiggy trees have been replaced by saplings.")
        else
            print("No twiggy tree found.")
        end
    end
end)



