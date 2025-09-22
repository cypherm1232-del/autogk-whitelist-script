-- Injection Script with Built-in Whitelist
-- Copy this entire script into your executor

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Your whitelist - edit these User IDs
local whitelist = {
    [123456789] = true,  -- Replace with real User IDs
    [987654321] = true,  -- Add more as needed
    [555444333] = true,
}

-- Function to check if local player is whitelisted
local function isWhitelisted()
    return whitelist[LocalPlayer.UserId] == true
end

-- Function to check access
local function checkAccess()
    if not isWhitelisted() then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Access Denied";
            Text = "You are not authorized to use this script.";
            Duration = 5;
        })
        LocalPlayer:Kick("You are not authorized to use this script.")
        return false
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Access Granted";
            Text = "Welcome " .. LocalPlayer.Name .. "!";
            Duration = 3;
        })
        print("✅ Access granted for " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")")
        return true
    end
end

-- Main execution
if checkAccess() then
    print("🚀 AutoGK Script loaded successfully!")
    
    -- PUT YOUR ACTUAL AUTOGK SCRIPT CODE BELOW THIS LINE
    -- ================================================
    
    -- Example: Basic notification that script is working
    wait(1)
    game.StarterGui:SetCore("SendNotification", {
        Title = "AutoGK Loaded";
        Text = "Script is now active!";
        Duration = 5;
    })
    
    -- Your actual AutoGK features go here:
    -- ESP code, aimbot, auto-farm, etc.
    
    print("All AutoGK features loaded!")
    
    -- ================================================
    -- END OF YOUR SCRIPT CODE
    
else
    -- Access denied - script stops
    print("🛑 AutoGK execution halted - user not whitelisted")
    return
end
