local HttpService = game:GetService("HttpService")
local hd = game.Players.LocalPlayer.PlayerGui
    .CommunityOutfits.Holder.Main.ViewOutfitDetails.List
    .OutfitDetails.ViewportHolder.Holder.DraggableNPCVPF
    .NPC.Humanoid.HumanoidDescription

if not hd or not hd:IsA("HumanoidDescription") then
    warn("HumanoidDescription not found or path incorrect")
    return
end

local humanoid = hd.Parent

local function safeNum(val)
    return tonumber(val) or 0
end

-- Color3 values stored as 0-255 integers for easy reading and round-tripping
local function rgb(color3)
    return {
        R = math.round(color3.R * 255),
        G = math.round(color3.G * 255),
        B = math.round(color3.B * 255),
    }
end

local export = {
    RigType = humanoid.RigType.Name,

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

    -- Color3 props exported as 0-255 RGB objects
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
print("=== CLEAN CAC OUTFIT JSON ===")
print(json)
print("==============================")
if setclipboard then
    setclipboard(json)
    print("Copied to clipboard!")
else
    print("Copy the JSON from above manually")
end