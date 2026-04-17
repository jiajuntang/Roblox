game:GetService("Players").PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(ch)
        task.wait(1)
        local hum = ch:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        for _,part in pairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
    end)
end)
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
        local ok, s = pcall(function() return v.Source end)
        if ok and s then
            if s:find("Unanchor") or s:find("GetObjects") or s:find("HttpEnabled") then
                v:Destroy()
            end
        end
    end
end
for _,p in pairs(workspace:GetDescendants()) do
    if p:IsA("BasePart") then
        if p.Name ~= "SpawnLocation" then
            p.Anchored = true
        end
    end
end
print("PROTECTED AND ANCHORED")
