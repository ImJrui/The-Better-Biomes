name = "DeepSeek Chat Translator"
description = "Translate other players' chat and send translated chat through a local DeepSeek proxy."
author = "TEST"
version = "0.2.0"

api_version = 10
dst_compatible = true
client_only_mod = true
all_clients_require_mod = false

server_filter_tags = {}

local languages = {
    {description = "Chinese (Simplified)", data = "ZH"},
    {description = "English", data = "EN"},
    {description = "Japanese", data = "JA"},
    {description = "Korean", data = "KO"},
    {description = "French", data = "FR"},
    {description = "German", data = "DE"},
    {description = "Spanish", data = "ES"},
    {description = "Russian", data = "RU"},
}

configuration_options = {
    {
        name = "DEFAULT_LANGUAGE",
        label = "Default translation language",
        hover = "Other players' chat will be translated into this language.",
        options = languages,
        default = "ZH",
    },
    {
        name = "TRANSLATE_INCOMING",
        label = "Translate other players",
        hover = "Insert translated copies of other players' chat into chat history.",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false},
        },
        default = true,
    },
    {
        name = "ENABLE_SEND_COMMANDS",
        label = "Enable /EN: and /ZH:",
        hover = "Type /EN:hello or /ZH:hello to translate before sending.",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false},
        },
        default = true,
    },
}
