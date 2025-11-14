from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from llama_cpp import Llama
import uvicorn
import sys
import os

app = FastAPI()

# CORS設定（Flutterからのアクセス許可）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# モデルパス取得（exeでもソースでも動作）
def get_model_path():
    if getattr(sys, 'frozen', False):
        # PyInstallerでビルドされた場合
        base_path = os.path.dirname(sys.executable)
    else:
        # 開発環境
        base_path = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base_path, "models", "gemma-2-2b-jpn-it-Q4_K_M.gguf")

# グローバル変数でモデル保持（初回のみロード）"models",
llm = None

@app.on_event("startup")
async def startup_event():
    global llm
    model_path = get_model_path()
    if os.path.exists(model_path):
        llm = Llama(model_path=model_path, n_ctx=512, n_threads=4)
        print(f"Model loaded: {model_path}")
    else:
        print(f"Model not found: {model_path}")

@app.get("/")
def read_root():
    return {"status": "running", "model_loaded": llm is not None}

@app.post("/generate")
def generate(prompt: dict):
    if llm is None:
        return {"error": "Model not loaded"}
    
    text = prompt.get("text", "Hello")
    
    # Gemma2用のプロンプト形式
    formatted_prompt = f"""<start_of_turn>user
{text}<end_of_turn>
<start_of_turn>model
"""
    
    try:
        output = llm(
            formatted_prompt,
            max_tokens=100,
            temperature=0.7,
            stop=["<end_of_turn>", "<start_of_turn>"],
            echo=False
        )
        result = output["choices"][0]["text"].strip()
        return {"response": result if result else "応答を生成できませんでした"}
    except Exception as e:
        return {"error": str(e)}
    
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)

