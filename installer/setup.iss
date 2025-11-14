[Setup]
AppId={{A1B2C3D4-E5F6-4789-ABCD-0123456789AB}}
AppName=AI Desktop App
AppVersion=1.0
DefaultDirName={pf}\AIDesktopApp
DefaultGroupName=AI Desktop App
OutputDir=output
OutputBaseFilename=AIDesktopApp_Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
; バックエンドexe
Source: "..\backend\dist\AIBackend.exe"; DestDir: "{app}\backend"; Flags: ignoreversion

; モデルファイル
Source: "..\backend\models\*.gguf"; DestDir: "{app}\backend\models"; Flags: ignoreversion

; Flutterアプリ
Source: "..\frontend\ai_desktop_app\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\AI Desktop App"; Filename: "{app}\ai_desktop_app.exe"
Name: "{commondesktop}\AI Desktop App"; Filename: "{app}\ai_desktop_app.exe"

[Run]
; バックエンドを起動（WorkingDir追加）
Filename: "{app}\backend\AIBackend.exe"; WorkingDir: "{app}\backend"; Flags: nowait skipifsilent

; フロントエンドを起動（WorkingDir追加）
Filename: "{app}\ai_desktop_app.exe"; WorkingDir: "{app}"; Description: "Launch AI Desktop App"; Flags: nowait postinstall skipifsilent