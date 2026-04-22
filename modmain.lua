GLOBAL.setmetatable(env, {
    __index = function(_, key)
        return GLOBAL.rawget(GLOBAL, key)
    end,
})

modimport("scripts/deepseek_translator")

local translator = DeepSeekTranslator.Create({
    proxy_url = "http://127.0.0.1:8787/translate",
    default_language = GetModConfigData("DEFAULT_LANGUAGE") or "ZH",
    translate_incoming = GetModConfigData("TRANSLATE_INCOMING") ~= false,
    enable_send_commands = GetModConfigData("ENABLE_SEND_COMMANDS") ~= false,
})

translator:Install()
