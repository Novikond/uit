-- > UI Tools (UIT) < -- [by Novikond]

local order = getObjectOrder('healthBar') + 100

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

uit = {
    graphics = {
        text = function(tag, text, x, y, width, alignment) -- draw a text
            local exampleText = 'The quick brown fox jumps over the lazy dog. 1234567890'
            makeLuaText(tag, text or exampleText, width or 0, x or 0, y or 0)
            setTextAlignment(tag, alignment or 'left')
            setObjectCamera(tag, 'camHUD')
            setTextSize(tag, 18)
            setProperty(tag .. '.antialiasing', true)
            setTextFont(tag, 'PhantomMuff.ttf')
            setObjectOrder(tag, order)
            addLuaText(tag, true)
        end,

        img = function(tag, image, x, y, scale) -- draw an image
            local exampleSprite = 'missingSprite'
            makeLuaSprite(tag, image or exampleSprite, x or 0, y or 0) 
            setObjectCamera(tag, 'camHUD')
            scaleObject(tag, scale or 1, scale or 1)
            setObjectOrder(tag, order)
            addLuaSprite(tag, true)
        end,

        obj = function(tag, x, y, width, height, color) -- draw a simple rectangle
            makeLuaSprite(tag, nil, x or 0, y or 0)
            makeGraphic(tag, width or 100, height or 100, color or '000000')
            setObjectCamera(tag, 'camHUD')
            setObjectOrder(tag, order)
            addLuaSprite(tag, true)
        end
    },

    effect = {
        color = function(tag, color, speed, easeType) -- color shift effect
            setProperty(tag .. '.color', getColorFromHex(color))
            doTweenColor(tag .. '-effect-blink', tag, 'ffffff', (speed or 0.2) / playbackRate, easeType or 'linear') -- not using startTween() cuz buggy
        end,

        alpha = function(tag, alphaFrom, alphaTo, speed, options) -- alpha shift effect
            setProperty(tag .. '.alpha', alphaFrom)
            startTween(tag .. '-effect-alpha', tag, {alpha = alphaTo}, (speed or 0.2) / playbackRate, options or nil)
        end,

        bop = function(tag, scaleX, scaleY, speed, options) -- object scale effect
            setProperty(tag .. '.scale.x', scaleX)
            setProperty(tag .. '.scale.y', scaleY)
            startTween(tag .. '-effect-bop-x', tag .. '.scale', {x = 1}, (speed or 0.2) / playbackRate, options or nil)
            startTween(tag .. '-effect-bop-y', tag .. '.scale', {y = 1}, (speed or 0.2) / playbackRate, options or nil)
        end,

        move = function(tag, ogX, ogY, moveX, moveY, speed, options) -- X and Y shift effect
            setProperty(tag .. '.x', ogX + moveX)
            setProperty(tag .. '.y', ogY + moveY)
            startTween(tag .. '-effect-shift-x', tag, {x = ogX}, (speed or 0.2) / playbackRate, options or nil)
            startTween(tag .. '-effect-shift-y', tag, {y = ogY}, (speed or 0.2) / playbackRate, options or nil)
        end
    },

    util = {
        formatTime = function(millisecond) -- converts millisecond to "min:sec" format
            local seconds = math.floor(millisecond / 1000)
            return string.format("%01d:%02d", (seconds / 60) % 60, seconds % 60) 
        end,

        floorDecimal = function(value, decimals) -- port of "floorDecimal" from Psych's source code to lua
            if decimals < 1 then return math.floor(value) end

            local tempMult = 1
            for i = 1, decimals do tempMult = tempMult * 10 end
        
            local newValue = math.floor(value * tempMult)
            return newValue / tempMult
        end,

        oto = function(tag, objToTrace, options) -- "object traces object"
            options = options or {}
            local optionX = options.x
            local optionY = options.y
            local traceAlpha = options.alpha ~= false
            local traceVisible = options.visible ~= false
            
            if optionX ~= nil and optionX ~= false then
                setProperty(tag .. '.x', getProperty(objToTrace .. '.x') + (optionX or 0))
            end
        
            if optionY ~= nil and optionY ~= false then
                setProperty(tag .. '.y', getProperty(objToTrace .. '.y') + (optionY or 0))
            end
        
            if traceAlpha then
                setProperty(tag .. '.alpha', getProperty(objToTrace .. '.alpha'))
            end
        
            if traceVisible then
                setProperty(tag .. '.visible', getProperty(objToTrace .. '.visible'))
            end
        end,

        lerp = function(a, b, t) -- l e r p
            return a + (b - a) * t
        end,

        tomlParse = function(toml_string) -- parses .toml files into the lua table
            local result = {}
            local current_table = result
            local stack = {}
        
            for line in toml_string:gmatch("[^\r\n]+") do
                line = trim(line)
        
                -- skip comments
                if line ~= "" and not line:match("^%s*#") then
                    -- handle tables
                    local table_name = line:match("^%[(.+)%]$")
                    if table_name then
                        table_name = trim(table_name)
                        current_table[table_name] = {}
                        table.insert(stack, current_table)
                        current_table = current_table[table_name]
                    else
                        -- handle key-value pairs
                        local key, value = line:match("^(%S+)%s*=%s*(.+)$")
                        if key and value then
                            key = trim(key)
                            value = trim(value)
        
                            -- remove quotes from strings
                            if value:sub(1, 1) == '"' and value:sub(-1) == '"' then
                                value = value:sub(2, -2)
                            elseif value:sub(1, 1) == "'" and value:sub(-1) == "'" then
                                value = value:sub(2, -2)
                            elseif tonumber(value) then
                                value = tonumber(value)
                            elseif value == "true" then
                                value = true
                            elseif value == "false" then
                                value = false
                            end
        
                            current_table[key] = value
                        end
                    end
                end
            end
            return result
        end
    }
}

return uit