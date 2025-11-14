import PyInstaller.__main__

PyInstaller.__main__.run([
    'main.py',
    '--onefile',
    '--name=AIBackend',
    '--noconsole',  # ウィンドウを表示しない
])
