local HttpService = game:GetService("HttpService")

-- Wait for HumanoidDescription to be available
local hd
for i = 1, 20 do
    local ok, result = pcall(function()
        return game.Players.LocalPlayer.PlayerGui
            .CommunityOutfits.Holder.Main.ViewOutfitDetails.List
            .OutfitDetails.ViewportHolder.Holder.DraggableNPCVPF
            .NPC.Humanoid.HumanoidDescription
    end)
    if ok and result and result:IsA("HumanoidDescription") then
        hd = result
        break
    end
    task.wait(0.5)
end

if not hd then
    warn("HumanoidDescription not found after waiting — is the outfit preview open?")
    return
end

local humanoid = hd.Parent

local function safeNum(val)
    return tonumber(val) or 0
end

local function rgb(color3)
    return {
        R = math.round(color3.R * 255),
        G = math.round(color3.G * 255),
        B = math.round(color3.B * 255),
    }
end

local export = {
    RigType = "R15",
    Accessories = {
        BackAccessory      = safeNum(hd.BackAccessory),
        FaceAccessory      = safeNum(hd.FaceAccessory),
        FrontAccessory     = safeNum(hd.FrontAccessory),
        HairAccessory      = safeNum(hd.HairAccessory),
        HatAccessory       = safeNum(hd.HatAccessory),
        NeckAccessory      = safeNum(hd.NeckAccessory),
        ShouldersAccessory = safeNum(hd.ShouldersAccessory),
        WaistAccessory     = safeNum(hd.WaistAccessory),
    },
    Scales = {
        BodyTypeScale   = safeNum(hd.BodyTypeScale),
        DepthScale      = safeNum(hd.DepthScale),
        HeadScale       = safeNum(hd.HeadScale),
        HeightScale     = safeNum(hd.HeightScale),
        ProportionScale = safeNum(hd.ProportionScale),
        WidthScale      = safeNum(hd.WidthScale),
    },
    Animations = {
        ClimbAnimation = safeNum(hd.ClimbAnimation),
        FallAnimation  = safeNum(hd.FallAnimation),
        IdleAnimation  = safeNum(hd.IdleAnimation),
        JumpAnimation  = safeNum(hd.JumpAnimation),
        MoodAnimation  = safeNum(hd.MoodAnimation),
        RunAnimation   = safeNum(hd.RunAnimation),
        SwimAnimation  = safeNum(hd.SwimAnimation),
        WalkAnimation  = safeNum(hd.WalkAnimation),
    },
    BodyParts = {
        Face     = safeNum(hd.Face),
        Head     = safeNum(hd.Head),
        LeftArm  = safeNum(hd.LeftArm),
        LeftLeg  = safeNum(hd.LeftLeg),
        RightArm = safeNum(hd.RightArm),
        RightLeg = safeNum(hd.RightLeg),
        Torso    = safeNum(hd.Torso),
    },
    Clothes = {
        GraphicTShirt = safeNum(hd.GraphicTShirt),
        Pants         = safeNum(hd.Pants),
        Shirt         = safeNum(hd.Shirt),
    },
    BodyColors = {
        HeadColor     = rgb(hd.HeadColor),
        TorsoColor    = rgb(hd.TorsoColor),
        LeftArmColor  = rgb(hd.LeftArmColor),
        RightArmColor = rgb(hd.RightArmColor),
        LeftLegColor  = rgb(hd.LeftLegColor),
        RightLegColor = rgb(hd.RightLegColor),
    },
}

local function cleanZeros(tbl)
    for k, v in pairs(tbl) do
        if type(v) == "number" and v == 0 then
            tbl[k] = nil
        elseif type(v) == "table" then
            cleanZeros(v)
        end
    end
end
cleanZeros(export)

local json = HttpService:JSONEncode(export)

local WEBHOOK_URL = "https://discord.com/api/webhooks/1473298353591681141/fXrdGD8OroWYwzGZskAeX0yQ1aHODF-daIU1XsRnHP_DpxoI5U1tl_-VgHPU8qltCk0Q"

local code  = _G.__CACCode  or "unknown"
local index = _G.__CACIndex or 1
local total = _G.__CACTotal or 1

local header  = string.format("**[%d/%d] Code `%s`**", index, total, code)
local maxBody = 1990 - #header - 12
local content = header .. "\n```json\n" .. (
    #json <= maxBody and json or string.sub(json, 1, maxBody) .. "\n... (truncated)"
) .. "\n```"

local payload = HttpService:JSONEncode({ username = "CAC Exporter", content = content })

local ok, err = pcall(function()
    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload
    })
end)

if ok then
    print(string.format("✅ Sent '%s' to webhook!", code))
else
    warn("❌ Webhook failed: " .. tostring(err))
end

