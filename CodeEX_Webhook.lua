-- ============================================================
--  CodeEX_Webhook.lua
--  Upload to: github.com/C0L1NUS/outfit → main/CodeEX_Webhook.lua
--  Posts raw JSON for each code directly to your Discord webhook.
-- ============================================================

local HttpService = game:GetService("HttpService")

-- !! CHANGE THIS to your Discord webhook URL !!
local WEBHOOK_URL = "https://discord.com/api/webhooks/1473298353591681141/fXrdGD8OroWYwzGZskAeX0yQ1aHODF-daIU1XsRnHP_DpxoI5U1tl_-VgHPU8qltCk0Q"

-- Code metadata injected by the loader
local CODE  = _G.__CACCode  or "unknown"
local INDEX = _G.__CACIndex or 1
local TOTAL = _G.__CACTotal or 1

-- ── Grab HumanoidDescription ─────────────────────────────────
local hd = game.Players.LocalPlayer.PlayerGui
    .CommunityOutfits.Holder.Main.ViewOutfitDetails.List
    .OutfitDetails.ViewportHolder.Holder.DraggableNPCVPF
    .NPC.Humanoid.HumanoidDescription

if not hd or not hd:IsA("HumanoidDescription") then
    warn("[CodeEX] HumanoidDescription not found for code: " .. CODE)
    return
end

local humanoid = hd.Parent

-- ── Helpers ───────────────────────────────────────────────────
local function safeNum(val) return tonumber(val) or 0 end

local function rgb(color3)
    return {
        R = math.round(color3.R * 255),
        G = math.round(color3.G * 255),
        B = math.round(color3.B * 255),
    }
end

-- ── Build export table ────────────────────────────────────────
local export = {
    Code    = CODE,
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

    BodyColors = {
        HeadColor     = rgb(hd.HeadColor),
        TorsoColor    = rgb(hd.TorsoColor),
        LeftArmColor  = rgb(hd.LeftArmColor),
        RightArmColor = rgb(hd.RightArmColor),
        LeftLegColor  = rgb(hd.LeftLegColor),
        RightLegColor = rgb(hd.RightLegColor),
    },
}

-- Remove zero values
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

-- ── Encode to JSON ────────────────────────────────────────────
local json = HttpService:JSONEncode(export)

-- ── POST to Discord webhook ───────────────────────────────────
-- Discord message limit is 2000 chars; split if needed
local header = string.format("**[%d/%d] Code `%s`**\n", INDEX, TOTAL, CODE)
local maxBody = 1990 - #header - 12 -- account for ```json\n...\n```

local function postChunk(text, label)
    local payload = HttpService:JSONEncode({
        username = "CAC Exporter",
        content  = label .. "```json\n" .. text .. "\n```",
    })
    local ok, err = pcall(function()
        game:HttpPost(WEBHOOK_URL, payload, false, "application/json")
    end)
    if not ok then
        warn("[CodeEX] Webhook POST failed: " .. tostring(err))
    end
end

if #json <= maxBody then
    -- Fits in one message
    postChunk(json, header)
else
    -- Split across multiple messages
    local chunks = {}
    local pos = 1
    while pos <= #json do
        table.insert(chunks, string.sub(json, pos, pos + maxBody - 1))
        pos = pos + maxBody
    end
    for i, chunk in ipairs(chunks) do
        local label = i == 1
            and header
            or string.format("**[%d/%d] Code `%s` (part %d/%d)**\n", INDEX, TOTAL, CODE, i, #chunks)
        postChunk(chunk, label)
        if i < #chunks then task.wait(0.5) end -- respect rate limit
    end
end

print(string.format("[CodeEX] ✅ Sent JSON for code '%s' to Discord.", CODE))
