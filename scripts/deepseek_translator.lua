local PLENV = env
local AddClassPostConstruct = PLENV.AddClassPostConstruct
GLOBAL.setfenv(1, GLOBAL)

local DeepSeekTranslator = {}
PLENV.DeepSeekTranslator = DeepSeekTranslator

local LANGUAGE_NAMES = {
    ZH = "Simplified Chinese",
    EN = "English",
    JA = "Japanese",
    KO = "Korean",
    FR = "French",
    DE = "German",
    ES = "Spanish",
    RU = "Russian",
}

local function Trim(text)
    return tostring(text or ""):match("^%s*(.-%S)%s*$") or ""
end

local function NormalizeLanguage(code)
    code = string.upper(Trim(code))
    return LANGUAGE_NAMES[code] and code or "ZH"
end

local function CopyColour(colour)
    local copy = {}

    if type(colour) == "table" then
        for key, value in pairs(colour) do
            if type(value) == "table" then
                local child = {}
                for child_key, child_value in pairs(value) do
                    child[child_key] = child_value
                end
                copy[key] = child
            else
                copy[key] = value
            end
        end
    end

    if next(copy) == nil then
        copy[1], copy[2], copy[3], copy[4] = 1, 1, 1, 1
    end

    return copy
end

local function SafeUtf8Len(text)
    local ok, len = pcall(function()
        return text:utf8len()
    end)

    return ok and len or string.len(text)
end

function DeepSeekTranslator.Create(config)
    local self = {}

    self.proxy_url = config.proxy_url
    self.default_language = NormalizeLanguage(config.default_language)
    self.translate_incoming = config.translate_incoming ~= false
    self.enable_send_commands = config.enable_send_commands ~= false
    self.next_request_id = 0

    setmetatable(self, {__index = DeepSeekTranslator})

    return self
end

function DeepSeekTranslator:Log(text)
    print("[DeepSeek Translator] " .. tostring(text))
end

function DeepSeekTranslator:Notice(text)
    self:Log("notice: " .. tostring(text))

    if ChatHistory and ChatHistory.SendCommandResponse then
        ChatHistory:SendCommandResponse("[DeepSeek] " .. tostring(text))
    end
end

function DeepSeekTranslator:DecodeResponse(result)
    local ok, data = pcall(function()
        return json.decode(result)
    end)

    if not ok or type(data) ~= "table" then
        return nil, "Proxy returned non-JSON: " .. tostring(result)
    end

    if type(data.content) == "string" and data.content ~= "" then
        return data.content
    end

    if type(data.error) == "table" and data.error.message then
        return nil, tostring(data.error.message)
    end

    if data.error then
        return nil, tostring(data.error)
    end

    return nil, "Proxy returned no content."
end

function DeepSeekTranslator:RequestTranslation(text, target_language, reason, callback)
    text = Trim(text)
    target_language = NormalizeLanguage(target_language)

    if text == "" then
        callback(false, "", "empty text")
        return
    end

    self.next_request_id = self.next_request_id + 1

    local request_id = self.next_request_id
    local body = json.encode_compliant({
        text = text,
        target_language = target_language,
        reason = reason or "chat",
    })

    self:Log("request #" .. tostring(request_id) .. " target=" .. target_language .. " reason=" .. tostring(reason) .. " text=" .. text)

    local ok, err = pcall(function()
        TheSim:QueryServer(self.proxy_url, function(result, is_successful, result_code)
            self:Log(
                "callback #" .. tostring(request_id)
                .. " success=" .. tostring(is_successful)
                .. " code=" .. tostring(result_code)
                .. " result=" .. tostring(result)
            )

            if is_successful and result_code == 200 then
                local translated, decode_error = self:DecodeResponse(result)
                if translated then
                    callback(true, translated, nil, request_id)
                else
                    callback(false, "", decode_error, request_id)
                end
            else
                callback(false, "", "HTTP " .. tostring(result_code), request_id)
            end
        end, "POST", body)
    end)

    if not ok then
        callback(false, "", "TheSim:QueryServer failed: " .. tostring(err), request_id)
    end
end

function DeepSeekTranslator:InsertIncomingTranslation(chat)
    self:RequestTranslation(chat.message, self.default_language, "incoming", function(success, translated, error_message)
        if not success then
            self:Log("incoming translation failed: " .. tostring(error_message))
            return
        end

        if not ChatHistory or not ChatHistory.AddToHistory or not ChatTypes then
            self:Log("ChatHistory unavailable; translation=" .. tostring(translated))
            return
        end

        local display_name = ChatHistory:GetDisplayName(chat.name or "", chat.prefab)
        local colour = CopyColour(chat.colour)
        local icon = "default"
        if type(GetRemotePlayerVanityItem) == "function" then
            icon = GetRemotePlayerVanityItem(chat.user_vanity or {}, "profileflair") or "default"
        end
        local netid = nil
        if TheNet and chat.userid then
            netid = TheNet:GetNetIdForUser(chat.userid)
        end
        local line = "[" .. self.default_language .. "] " .. translated

        ChatHistory:AddToHistory(
            ChatTypes.Message,
            chat.userid,
            netid,
            display_name,
            line,
            colour,
            icon,
            chat.whisper,
            true,
            TEXT_FILTER_CTX_CHAT
        )
    end)
end

function DeepSeekTranslator:OnIncomingSay(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if not self.translate_incoming then
        return
    end

    if isemote or type(message) ~= "string" or Trim(message) == "" then
        return
    end

    if message:match("^%[[A-Z][A-Z]%]%s+") then
        return
    end

    local my_userid = TheNet and TheNet:GetUserID() or nil
    if my_userid ~= nil and userid == my_userid then
        return
    end

    self:InsertIncomingTranslation({
        guid = guid,
        userid = userid,
        name = name,
        prefab = prefab,
        message = message,
        colour = colour,
        whisper = whisper,
        user_vanity = user_vanity,
    })
end

function DeepSeekTranslator:ParseSendCommand(chat_string)
    local code, text = Trim(chat_string):match("^/%s*([%a][%a])%s*:%s*(.+)$")

    if not code or not text then
        return nil
    end

    code = string.upper(code)

    if not LANGUAGE_NAMES[code] then
        return nil
    end

    text = Trim(text)

    if text == "" then
        return nil
    end

    return code, text
end

function DeepSeekTranslator:TranslateAndSay(text, target_language, whisper)
    target_language = NormalizeLanguage(target_language)

    self:Notice("Translating to " .. target_language .. "...")

    self:RequestTranslation(text, target_language, "outgoing", function(success, translated, error_message)
        if not success then
            self:Notice("Translation failed: " .. tostring(error_message))
            return
        end

        if SafeUtf8Len(translated) > MAX_CHAT_INPUT_LENGTH then
            self:Notice("Translation is too long to send.")
            return
        end

        self:Log("sending translated chat: " .. translated)
        if TheNet and TheNet.Say then
            TheNet:Say(translated, whisper)
        else
            self:Notice("TheNet:Say is unavailable.")
        end
    end)
end

function DeepSeekTranslator:InstallIncomingHook()
    local old_networking_say = Networking_Say

    if type(old_networking_say) ~= "function" then
        self:Log("Networking_Say unavailable; incoming translation disabled")
        return
    end

    local translator = self

    Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
        old_networking_say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
        translator:OnIncomingSay(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    end

    self:Log("incoming chat hook installed; default_language=" .. self.default_language)
end

function DeepSeekTranslator:InstallSendCommandHook()
    if not self.enable_send_commands then
        return
    end

    if type(AddClassPostConstruct) ~= "function" then
        self:Log("AddClassPostConstruct unavailable; send command hook disabled")
        return
    end

    local translator = self

    AddClassPostConstruct("screens/chatinputscreen", function(screen)
        local old_run = screen.Run

        screen.Run = function(chat_screen)
            local chat_string = chat_screen.chat_edit:GetString()
            chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""

            local target_language, text = translator:ParseSendCommand(chat_string)
            if target_language then
                translator:TranslateAndSay(text, target_language, chat_screen.whisper)
                return
            end

            return old_run(chat_screen)
        end
    end)

    self:Log("send command hook installed")
end

function DeepSeekTranslator:Install()
    self:InstallIncomingHook()
    self:InstallSendCommandHook()
    self:Log("installed; proxy_url=" .. self.proxy_url)
end
