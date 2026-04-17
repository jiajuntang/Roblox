local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local origBright = Lighting.Brightness
local origFogEnd = Lighting.FogEnd
local origFogColor = Lighting.FogColor
local origAmbient = Lighting.Ambient

local WEATHER_INTERVAL = 60
local WEATHER_DURATION = 120
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local penguins = {}

local penguinSayings = {
    "My name is Guin Guin, also known as Marky Penguin!",
    "YI WU!",
    "Am I adopted?",
    "I am hungry...",
    "plssss fishhhh",
    "Do you like me?",
    "1+1=67.",
    "OI think my moms kinda homeless",
    "I think i am kinda homelesss",
    "I think that my fish is kinda penguinless",
    "yes = no and no = yes",
    "WHAT ARE YOU",
    "Can i eat you?",
    "I like ROTTEN FISH",
    "My favourite colour is totally penguin",
    "PLSSSS i need fish i think i am kinda penguinlesss",
    "I am not penguining",
    "My brain isnt braining",
    "HIIIIIIIIIIIIIIIIIIII",
    "Wait a minute, Who are you?????",
}

local function announce(msg)
    for _,p in pairs(Players:GetPlayers()) do
        local hint = Instance.new("Hint")
        hint.Text = msg
        local pg = p:FindFirstChild("PlayerGui")
        if pg then
            hint.Parent = pg
            task.delay(5, function()
                if hint and hint.Parent then hint:Destroy() end
            end)
        end
    end
end

local function setAllStats(speed, jump)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local hum = ch:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = speed
                hum.JumpPower = jump
            end
        end
    end
end

local function clearPenguins()
    for _,pen in pairs(penguins) do
        if pen and pen.Parent then pen:Destroy() end
    end
    penguins = {}
end

local function resetWeather()
    Lighting.Brightness = origBright
    Lighting.FogEnd = origFogEnd
    Lighting.FogColor = origFogColor
    Lighting.Ambient = origAmbient
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
    clearPenguins()
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local sword = ch:FindFirstChild("Weather Sword")
            if sword then sword:Destroy() end
        end
        local bp = p:FindFirstChild("Backpack")
        if bp then
            local sword = bp:FindFirstChild("Weather Sword")
            if sword then sword:Destroy() end
        end
    end
    announce("The weather has cleared!")
end

local function sonicMode()
    announce("SONIC MODE! Speed +20% Jump +10%!")
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(200, 200, 255)
    setAllStats(DEFAULT_SPEED * 1.2, DEFAULT_JUMP * 1.1)
end

local function hackerEvent()
    announce("HACKER EVENT! Speed +20% Jump +40%!")
    Lighting.Brightness = 0.8
    Lighting.Ambient = Color3.fromRGB(0, 255, 0)
    Lighting.FogEnd = 500
    Lighting.FogColor = Color3.fromRGB(0, 50, 0)
    setAllStats(DEFAULT_SPEED * 1.2, DEFAULT_JUMP * 1.4)
end

local function snowStorm()
    announce("SNOW STORM! Speed -25% Jump -5%!")
    Lighting.FogEnd = 100
    Lighting.FogColor = Color3.fromRGB(220, 220, 235)
    Lighting.Brightness = 1.5
    Lighting.Ambient = Color3.fromRGB(180, 180, 200)
    setAllStats(DEFAULT_SPEED * 0.75, DEFAULT_JUMP * 0.95)
end

local function sandStorm()
    announce("SAND STORM! Visibility reduced!")
    Lighting.FogEnd = 80
    Lighting.FogColor = Color3.fromRGB(194, 178, 128)
    Lighting.Brightness = 1.2
    Lighting.Ambient = Color3.fromRGB(180, 160, 120)
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
end

local function penguinTalk(pen)
    local head = pen:FindFirstChild("Head")
    if not head then
        head = pen:FindFirstChild("HumanoidRootPart")
    end
    if not head then return end
    local msg = penguinSayings[math.random(1, #penguinSayings)]
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.Adornee = head
    bill.Parent = head
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 0.3
    label.Text = msg
    label.TextColor3 = Color3.fromRGB(0, 0, 0)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.Parent = bill
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
    task.delay(3, function()
        if bill and bill.Parent then bill:Destroy() end
    end)
end

local function findNearestPlayer(pos)
    local best = nil
    local bestDist = 999999
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local root = ch:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - pos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = root
                end
            end
        end
    end
    return best, bestDist
end

local function spawnPenguin(pos)
    local pen = Instance.new("Model")
    pen.Name = "Penguin"

    -- Body (oval shaped)
    local body = Instance.new("Part")
    body.Name = "HumanoidRootPart"
    body.Size = Vector3.new(2.5, 3.5, 2)
    body.BrickColor = BrickColor.new("Really black")
    body.Material = Enum.Material.SmoothPlastic
    body.Position = pos
    body.Anchored = false
    body.Shape = Enum.PartType.Block
    body.Parent = pen

    local bodyMesh = Instance.new("SpecialMesh")
    bodyMesh.MeshType = Enum.MeshType.Sphere
    bodyMesh.Scale = Vector3.new(0.8, 1, 0.7)
    bodyMesh.Parent = body

    -- White belly (front)
    local belly = Instance.new("Part")
    belly.Size = Vector3.new(1.8, 2.5, 0.5)
    belly.BrickColor = BrickColor.new("White")
    belly.Material = Enum.Material.SmoothPlastic
    belly.Anchored = false
    belly.Parent = pen

    local bellyMesh = Instance.new("SpecialMesh")
    bellyMesh.MeshType = Enum.MeshType.Sphere
    bellyMesh.Scale = Vector3.new(0.8, 0.9, 0.5)
    bellyMesh.Parent = belly

    local bWeld = Instance.new("Weld")
    bWeld.Part0 = body
    bWeld.Part1 = belly
    bWeld.C0 = CFrame.new(0, -0.2, 0.6)
    bWeld.Parent = belly

    -- Head (round)
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(2, 2, 2)
    head.BrickColor = BrickColor.new("Really black")
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = false
    head.Parent = pen

    local hWeld = Instance.new("Weld")
    hWeld.Part0 = body
    hWeld.Part1 = head
    hWeld.C0 = CFrame.new(0, 2.2, 0)
    hWeld.Parent = head

    -- White face patch
    local face = Instance.new("Part")
    face.Shape = Enum.PartType.Ball
    face.Size = Vector3.new(1.2, 1.2, 0.5)
    face.BrickColor = BrickColor.new("White")
    face.Material = Enum.Material.SmoothPlastic
    face.Anchored = false
    face.Parent = pen

    local fWeld = Instance.new("Weld")
    fWeld.Part0 = head
    fWeld.Part1 = face
    fWeld.C0 = CFrame.new(0, -0.2, 0.6)
    fWeld.Parent = face

    -- Left eye
    local leftEye = Instance.new("Part")
    leftEye.Shape = Enum.PartType.Ball
    leftEye.Size = Vector3.new(0.3, 0.3, 0.3)
    leftEye.BrickColor = BrickColor.new("Really black")
    leftEye.Material = Enum.Material.SmoothPlastic
    leftEye.Anchored = false
    leftEye.Parent = pen

    local leWeld = Instance.new("Weld")
    leWeld.Part0 = head
    leWeld.Part1 = leftEye
    leWeld.C0 = CFrame.new(-0.35, 0.1, 0.85)
    leWeld.Parent = leftEye

    -- Right eye
    local rightEye = Instance.new("Part")
    rightEye.Shape = Enum.PartType.Ball
    rightEye.Size = Vector3.new(0.3, 0.3, 0.3)
    rightEye.BrickColor = BrickColor.new("Really black")
    rightEye.Material = Enum.Material.SmoothPlastic
    rightEye.Anchored = false
    rightEye.Parent = pen

    local reWeld = Instance.new("Weld")
    reWeld.Part0 = head
    reWeld.Part1 = rightEye
    reWeld.C0 = CFrame.new(0.35, 0.1, 0.85)
    reWeld.Parent = rightEye

    -- Left eye white
    local leftEyeW = Instance.new("Part")
    leftEyeW.Shape = Enum.PartType.Ball
    leftEyeW.Size = Vector3.new(0.15, 0.15, 0.15)
    leftEyeW.BrickColor = BrickColor.new("White")
    leftEyeW.Material = Enum.Material.Neon
    leftEyeW.Anchored = false
    leftEyeW.Parent = pen

    local lewWeld = Instance.new("Weld")
    lewWeld.Part0 = leftEye
    lewWeld.Part1 = leftEyeW
    lewWeld.C0 = CFrame.new(0.05, 0.05, 0.1)
    lewWeld.Parent = leftEyeW

    -- Right eye white
    local rightEyeW = Instance.new("Part")
    rightEyeW.Shape = Enum.PartType.Ball
    rightEyeW.Size = Vector3.new(0.15, 0.15, 0.15)
    rightEyeW.BrickColor = BrickColor.new("White")
    rightEyeW.Material = Enum.Material.Neon
    rightEyeW.Anchored = false
    rightEyeW.Parent = pen

    local rewWeld = Instance.new("Weld")
    rewWeld.Part0 = rightEye
    rewWeld.Part1 = rightEyeW
    rewWeld.C0 = CFrame.new(-0.05, 0.05, 0.1)
    rewWeld.Parent = rightEyeW

    -- Beak (orange triangle)
    local beak = Instance.new("Part")
    beak.Size = Vector3.new(0.6, 0.3, 0.8)
    beak.BrickColor = BrickColor.new("Deep orange")
    beak.Material = Enum.Material.SmoothPlastic
    beak.Anchored = false
    beak.Parent = pen

    local beakMesh = Instance.new("SpecialMesh")
    beakMesh.MeshType = Enum.MeshType.Wedge
    beakMesh.Scale = Vector3.new(0.8, 0.5, 1)
    beakMesh.Parent = beak

    local beakWeld = Instance.new("Weld")
    beakWeld.Part0 = head
    beakWeld.Part1 = beak
    beakWeld.C0 = CFrame.new(0, -0.3, 0.9) * CFrame.Angles(math.rad(180), 0, 0)
    beakWeld.Parent = beak

    -- Left wing
    local leftWing = Instance.new("Part")
    leftWing.Size = Vector3.new(0.5, 2.5, 1.2)
    leftWing.BrickColor = BrickColor.new("Really black")
    leftWing.Material = Enum.Material.SmoothPlastic
    leftWing.Anchored = false
    leftWing.Parent = pen

    local lwMesh = Instance.new("SpecialMesh")
    lwMesh.MeshType = Enum.MeshType.Sphere
    lwMesh.Scale = Vector3.new(0.4, 1, 0.6)
    lwMesh.Parent = leftWing

    local lwWeld = Instance.new("Weld")
    lwWeld.Part0 = body
    lwWeld.Part1 = leftWing
    lwWeld.C0 = CFrame.new(-1.3, 0.2, 0) * CFrame.Angles(0, 0, math.rad(15))
    lwWeld.Parent = leftWing

    -- Right wing
    local rightWing = Instance.new("Part")
    rightWing.Size = Vector3.new(0.5, 2.5, 1.2)
    rightWing.BrickColor = BrickColor.new("Really black")
    rightWing.Material = Enum.Material.SmoothPlastic
    rightWing.Anchored = false
    rightWing.Parent = pen

    local rwMesh = Instance.new("SpecialMesh")
    rwMesh.MeshType = Enum.MeshType.Sphere
    rwMesh.Scale = Vector3.new(0.4, 1, 0.6)
    rwMesh.Parent = rightWing

    local rwWeld = Instance.new("Weld")
    rwWeld.Part0 = body
    rwWeld.Part1 = rightWing
    rwWeld.C0 = CFrame.new(1.3, 0.2, 0) * CFrame.Angles(0, 0, math.rad(-15))
    rwWeld.Parent = rightWing

    -- Left foot
    local leftFoot = Instance.new("Part")
    leftFoot.Size = Vector3.new(0.8, 0.3, 1.2)
    leftFoot.BrickColor = BrickColor.new("Deep orange")
    leftFoot.Material = Enum.Material.SmoothPlastic
    leftFoot.Anchored = false
    leftFoot.Parent = pen

    local lfWeld = Instance.new("Weld")
    lfWeld.Part0 = body
    lfWeld.Part1 = leftFoot
    lfWeld.C0 = CFrame.new(-0.5, -1.9, 0.3)
    lfWeld.Parent = leftFoot

    -- Right foot
    local rightFoot = Instance.new("Part")
    rightFoot.Size = Vector3.new(0.8, 0.3, 1.2)
    rightFoot.BrickColor = BrickColor.new("Deep orange")
    rightFoot.Material = Enum.Material.SmoothPlastic
    rightFoot.Anchored = false
    rightFoot.Parent = pen

    local rfWeld = Instance.new("Weld")
    rfWeld.Part0 = body
    rfWeld.Part1 = rightFoot
    rfWeld.C0 = CFrame.new(0.5, -1.9, 0.3)
    rfWeld.Parent = rightFoot

    -- Humanoid
    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 100
    hum.Health = 100
    hum.WalkSpeed = 10
    hum.JumpPower = 50
    hum.Parent = pen

    pen.PrimaryPart = body
    pen.Parent = workspace
    table.insert(penguins, pen)
    task.spawn(function()
        while pen and pen.Parent and hum.Health > 0 do
            local pRoot = pen:FindFirstChild("HumanoidRootPart")
            if not pRoot then break end
            local nearestRoot, dist = findNearestPlayer(pRoot.Position)
            if nearestRoot then
                if dist > 100 then
                    pRoot.CFrame = nearestRoot.CFrame * CFrame.new(math.random(-10, 10), 5, math.random(-10, 10))
                elseif dist > 20 then
                    hum:MoveTo(nearestRoot.Position)
                    if math.random(1, 3) == 1 then
                        hum.Jump = true
                    end
                else
                    local wanderX = math.random(-15, 15)
                    local wanderZ = math.random(-15, 15)
                    hum:MoveTo(nearestRoot.Position + Vector3.new(wanderX, 0, wanderZ))
                    if math.random(1, 5) == 1 then
                        hum.Jump = true
                    end
                end
            else
                local wanderX = math.random(-30, 30)
                local wanderZ = math.random(-30, 30)
                hum:MoveTo(pos + Vector3.new(wanderX, 0, wanderZ))
            end
            task.wait(math.random(1, 3))
        end
    end)
    task.spawn(function()
        while pen and pen.Parent and hum.Health > 0 do
            task.wait(math.random(3, 7))
            penguinTalk(pen)
        end
    end)
end

local function penguinEvent()
    announce("PENGUIN EVENT! Penguins are everywhere!")
    Lighting.Brightness = 1.8
    Lighting.Ambient = Color3.fromRGB(200, 230, 255)
    Lighting.FogEnd = 300
    Lighting.FogColor = Color3.fromRGB(200, 220, 240)
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local root = ch:FindFirstChild("HumanoidRootPart")
            if root then
                for i = 1, 10 do
                    local offset = Vector3.new(math.random(-20, 20), 5, math.random(-20, 20))
                    spawnPenguin(root.Position + offset)
                end
            end
        end
    end
end

local function chaosEvent()
    announce("CHAOS EVENT! Everyone gets a sword!")
    setAllStats(DEFAULT_SPEED, DEFAULT_JUMP)
    Lighting.Brightness = 0.5
    Lighting.Ambient = Color3.fromRGB(255, 50, 50)
    for _,p in pairs(Players:GetPlayers()) do
        local ch = p.Character
        if ch then
            local hum = ch:FindFirstChild("Humanoid")
            local bp = p:FindFirstChild("Backpack")
            if hum and bp then
                if not bp:FindFirstChild("Weather Sword") and not ch:FindFirstChild("Weather Sword") then
                    local dmg = math.floor(hum.MaxHealth * 0.25)
                    local tool = Instance.new("Tool")
                    tool.Name = "Weather Sword"
                    tool.RequiresHandle = true
                    tool.CanBeDropped = false
                    local handle = Instance.new("Part")
                    handle.Name = "Handle"
                    handle.Size = Vector3.new(1, 1, 5)
                    handle.BrickColor = BrickColor.new("Really red")
                    handle.Material = Enum.Material.Neon
                    handle.Massless = true
                    handle.Parent = tool
                    local canHit = true
                    tool.Activated:Connect(function()
                        if not canHit then return end
                        canHit = false
                        local chr = tool.Parent
                        if not chr then canHit = true return end
                        local plr = Players:GetPlayerFromCharacter(chr)
                        if not plr then canHit = true return end
                        local root = chr:FindFirstChild("HumanoidRootPart")
                        if not root then canHit = true return end
                        handle.BrickColor = BrickColor.new("Bright yellow")
                        task.delay(0.15, function()
                            if handle and handle.Parent then
                                handle.BrickColor = BrickColor.new("Really red")
                            end
                        end)
                        for _,other in pairs(Players:GetPlayers()) do
                            if other ~= plr and other.Character then
                                local oRoot = other.Character:FindFirstChild("HumanoidRootPart")
                                local oHum = other.Character:FindFirstChild("Humanoid")
                                if oRoot and oHum and oHum.Health > 0 then
                                    local dist = (oRoot.Position - root.Position).Magnitude
                                    if dist <= 10 then
                                        oHum:TakeDamage(dmg)
                                    end
                                end
                            end
                        end
                        task.wait(1)
                        canHit = true
                    end)
                    tool.Parent = bp
                end
            end
        end
    end
end

print("WEATHER SYSTEM LOADED")

while true do
    task.wait(WEATHER_INTERVAL)
    local roll = math.random(1, 100)
    if roll <= 15 then
        sonicMode()
    elseif roll <= 25 then
        hackerEvent()
    elseif roll <= 30 then
        snowStorm()
    elseif roll <= 80 then
        penguinEvent()
    elseif roll <= 95 then
        sandStorm()
    else
        chaosEvent()
    end
    task.wait(WEATHER_DURATION)
    resetWeather()
end
