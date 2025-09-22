-- Obfuscated Whitelist Script
-- This script is protected from easy reading

local function decode(str)
    local result = ""
    for i = 1, #str do
        result = result .. string.char(string.byte(str, i) - 3)
    end
    return result
end

-- Encoded script (your actual whitelist logic is hidden here)
local encodedScript = [[
orfdo#Soshuv#@#jdph=JhwVhuylfh+$Soshuv$,
orfdo#zklwholvw#@#{
####^456789:45`#@#wuxh/#11#Uhsodfh#zlwk#dfwxdo#XvhuLGv
####^:;9876543`#@#wuxh/#11#Dgg#pruh#XvhuLGv#dv#qhhghg
####^88866644`#@#wuxh/
`

11#Ixqfwlrq#wr#fkhfn#li#sod|hu#lv#zklwholvwhg
orfdo#ixqfwlrq#lvZklwholvwhg+sod|hu,
####uhwxuq#zklwholvw^sod|hu1XvhuLg`#@@#wuxh
hqg

11#Kdqgoh#zkhq#sod|huv#mrlq
Sod|huv1Sod|hu$gghg=Frqqhfw+ixqfwlrq+sod|hu,
####li#qrw#lvZklwholvwhg+sod|hu,#wkhq
########sulqw+sod|hu1Qdph#11#$#+LG=#11#sod|hu1XvhuLg#11#$,#lv#qrw#zklwholvwhg$,
########
########11#Rswlrqdo=#Nlfn#qrq0zklwholvwhg#sod|huv
########sod|hu=Nlfn+$\rx#duh#qrw#dxwkrul}hg#wr#dffhvv#wklv#vhuyhu1$,
####hovh
########sulqw+sod|hu1Qdph#11#$#lv#zklwholvwhg#dqg#doorzhg#dffhvv$,
####hqg
hqg,

11#Kdqgoh#sod|huv#douhdg|#lq#wkh#vhuyhu#zkhq#vfulsw#uxqv
iru#B/#sod|hu#lq#sdluv+Sod|huv=JhwSod|huv+,,#gr
####li#qrw#lvZklwholvwhg+sod|hu,#wkhq
########sulqw+sod|hu1Qdph#11#$#+LG=#11#sod|hu1XvhuLg#11#$,#lv#qrw#zklwholvwhg$,
########sod|hu=Nlfn+$\rx#duh#qrw#dxwkrul}hg#wr#dffhvv#wklv#vhuyhu1$,
####hqg
hqg
]]

-- Load and execute the decoded script
local decodedScript = decode(encodedScript)
loadstring(decodedScript)()

print("Security system loaded successfully")
