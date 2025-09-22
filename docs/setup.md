# Roblox Whitelist Script Setup Guide

## Prerequisites
- Roblox Studio access
- Server script permissions in your game
- Basic understanding of Roblox scripting

## Installation Steps

### Step 1: Download the Script
1. Go to the `scripts/` folder in this repository
2. Copy the contents of `whitelist-obfuscated.lua`
3. Or use the remote version if you prefer external loading

### Step 2: Install in Roblox Studio
1. Open your game in Roblox Studio
2. In the Explorer window, find **ServerScriptService**
3. Right-click ServerScriptService → **Insert Object** → **Script**
4. Rename the new script to "WhitelistSystem"
5. Delete the default code and paste your whitelist script
6. Save your place

### Step 3: Configure Your Whitelist

#### Method A: Direct Script Editing
1. In your script, find the whitelist table:
   ```lua
   local whitelist = {
       [123456789] = true,  -- Replace with real User IDs
       [987654321] = true,
   }
   ```
2. Replace the example numbers with actual Roblox User IDs
3. Save the script

#### Method B: Using JSON File (Remote Method)
1. Edit the `data/whitelist.json` file in this repository
2. Add User IDs in this format:
   ```json
   {
       "123456789": true,
       "987654321": true,
       "555444333": true
   }
   ```
3. Use the remote loading script version

### Step 4: Find Roblox User IDs
1. Go to a player's Roblox profile
2. Look at the URL: `https://www.roblox.com/users/123456789/profile`
3. The number `123456789` is their User ID
4. Add this number to your whitelist

### Step 5: Test the System
1. Publish your game to Roblox
2. Test with a non-whitelisted account (should be kicked)
3. Test with a whitelisted account (should be allowed)
4. Check the Output window in Studio for debug messages

## Configuration Options

### Basic Settings
- **Auto-kick**: Players not on whitelist are automatically kicked
- **Logging**: All join attempts are logged to console
- **Real-time checking**: Works for players joining and already in server

### Advanced Options
You can modify the script to:
- Send custom kick messages
- Log to external services
- Add temporary access codes
- Implement admin commands to add/remove players

## Troubleshooting

### Common Issues

**Script doesn't work:**
- Make sure it's in ServerScriptService (not StarterPlayerScripts)
- Check that it's a Script, not a LocalScript
- Verify the game is published, not just saved locally

**Players aren't being kicked:**
- Check the Output window for error messages
- Verify User IDs are correct (numbers, not usernames)
- Make sure HTTP requests are enabled (for remote method)

**Can't access remote whitelist:**
- Enable HTTP requests in Game Settings → Security
- Check that the URL is correct and accessible
- Verify the JSON format is valid

### Enable HTTP Requests (for remote method)
1. In Roblox Studio: **Home** → **Game Settings**
2. Go to **Security** tab
3. Check **"Allow HTTP Requests"**
4. Click **Save**

## Security Notes

### Protecting Your Script
- Keep your repository private
- Use obfuscated versions for public sharing
- Don't share raw User IDs publicly
- Consider using external APIs for sensitive data

### Best Practices
- Regularly update your whitelist
- Monitor who has access
- Keep backup copies of your whitelist
- Test changes in a private server first

## Adding/Removing Players

### To Add a Player:
1. Get their User ID from their profile
2. Add to whitelist: `[UserID] = true,`
3. Update and test the script

### To Remove a Player:
1. Find their entry in the whitelist
2. Delete the line or change to `false`
3. Update the script

## Support

If you encounter issues:
1. Check the Roblox Developer Console for errors
2. Verify all User IDs are correct
3. Test in a private server before going live
4. Make sure the script is in the correct location

## Example Whitelist Formats

### Script Format:
```lua
local whitelist = {
    [123456789] = true,  -- Player1
    [987654321] = true,  -- Player2
    [555444333] = true,  -- Player3
}
```

### JSON Format:
```json
{
    "123456789": true,
    "987654321": true,
    "555444333": true
}
```

Remember to replace all example User IDs with real ones!
