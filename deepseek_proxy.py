import json
import os
import pathlib
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


HOST = "127.0.0.1"
PORT = 8787
DEEPSEEK_URL = "https://api.deepseek.com/chat/completions"
MODEL = "deepseek-chat"

LANGUAGES = {
    "ZH": "Simplified Chinese",
    "EN": "English",
    "JA": "Japanese",
    "KO": "Korean",
    "FR": "French",
    "DE": "German",
    "ES": "Spanish",
    "RU": "Russian",
}


def normalize_language(code):
    code = str(code or "ZH").strip().upper()
    return code if code in LANGUAGES else "ZH"


def read_api_key():
    env_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if env_key:
        return env_key

    key_file = pathlib.Path(__file__).with_name("deepseek_key.txt")
    if key_file.exists():
        return key_file.read_text(encoding="utf-8").strip()

    return ""


def request_deepseek(messages):
    api_key = read_api_key()
    if not api_key:
        raise RuntimeError(
            "Set DEEPSEEK_API_KEY or put the key in deepseek_key.txt beside this script."
        )

    payload = {
        "model": MODEL,
        "messages": messages,
        "stream": False,
    }

    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    request = urllib.request.Request(
        DEEPSEEK_URL,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json; charset=utf-8",
        },
    )

    with urllib.request.urlopen(request, timeout=60) as response:
        raw = response.read().decode("utf-8", errors="replace")

    data = json.loads(raw)
    choices = data.get("choices") or []
    message_data = choices[0].get("message") if choices else {}
    content = message_data.get("content") if isinstance(message_data, dict) else None

    if not content:
        raise RuntimeError(f"DeepSeek returned no content: {raw}")

    return content.strip()


def translate_text(text, target_language):
    target_language = normalize_language(target_language)
    target_name = LANGUAGES[target_language]
    text = str(text or "").strip()

    if not text:
        raise RuntimeError("empty text")

    messages = [
        {
            "role": "system",
            "content": (
                "You are a game chat translation engine. Translate only the message "
                "text. Return only the translated text, with no explanations, no "
                "quotes, and no markdown. Preserve player names, usernames, character "
                "names, item names, URLs, commands, and code-like tokens exactly."
            ),
        },
        {
            "role": "user",
            "content": (
                f"Target language: {target_name}\n"
                "If the message is already in the target language, return it unchanged.\n"
                "Message:\n"
                f"{text}"
            ),
        },
    ]

    return request_deepseek(messages)


def hello():
    return request_deepseek(
        [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Hello!"},
        ]
    )


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, data):
        encoded = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def read_json_body(self):
        length = int(self.headers.get("Content-Length", "0") or "0")
        if length <= 0:
            return {}

        body = self.rfile.read(length).decode("utf-8", errors="replace")
        if not body:
            return {}

        return json.loads(body)

    def do_GET(self):
        path = self.path.split("?", 1)[0]

        if path == "/health":
            self.send_json(200, {"ok": True})
        elif path == "/hello":
            self.handle_hello()
        else:
            self.send_json(404, {"error": "not found"})

    def do_POST(self):
        path = self.path.split("?", 1)[0]

        if path == "/hello":
            self.handle_hello()
        elif path == "/translate":
            self.handle_translate()
        else:
            self.send_json(404, {"error": "not found"})

    def handle_hello(self):
        try:
            print("[DeepSeek Proxy] hello request")
            content = hello()
            print(f"[DeepSeek Proxy] hello response: {content!r}")
            self.send_json(200, {"content": content})
        except urllib.error.HTTPError as exc:
            self.handle_http_error(exc)
        except Exception as exc:
            self.handle_error(exc)

    def handle_translate(self):
        try:
            data = self.read_json_body()
            text = str(data.get("text") or "")
            target_language = normalize_language(data.get("target_language"))
            reason = str(data.get("reason") or "chat")

            print(
                f"[DeepSeek Proxy] translate reason={reason!r} "
                f"target={target_language!r} text={text!r}"
            )
            content = translate_text(text, target_language)
            print(f"[DeepSeek Proxy] translated: {content!r}")
            self.send_json(
                200,
                {
                    "content": content,
                    "target_language": target_language,
                },
            )
        except urllib.error.HTTPError as exc:
            self.handle_http_error(exc)
        except Exception as exc:
            self.handle_error(exc)

    def handle_http_error(self, exc):
        detail = exc.read().decode("utf-8", errors="replace")
        print(f"[DeepSeek Proxy] HTTP {exc.code}: {detail}")
        self.send_json(exc.code, {"error": detail or str(exc)})

    def handle_error(self, exc):
        print(f"[DeepSeek Proxy] error: {exc}")
        self.send_json(500, {"error": str(exc)})

    def log_message(self, format, *args):
        print("[DeepSeek Proxy]", format % args)


def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"[DeepSeek Proxy] listening on http://{HOST}:{PORT}")
    print("[DeepSeek Proxy] endpoints: /translate, /hello, /health")
    print("[DeepSeek Proxy] press Ctrl+C to stop")
    server.serve_forever()


if __name__ == "__main__":
    main()
