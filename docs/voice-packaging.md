# Voice Packaging

Build standalone installers and executables for the NeuNuc Voice Pipeline.

---

## Overview

The voice pipeline is built as a standard Python package via `pyproject.toml`. For end-user deployment, it is packaged into a single Windows `.exe` via PyInstaller, wrapped in an Inno Setup wizard. Mobile scaffolding is documented but not yet built.

## Build Layout

```
build/
├── neunuc-voice.spec           # PyInstaller spec
├── neunuc-voice.iss            # Inno Setup installer script
├── install.bat                 # One-click Windows build
├── briefcase.toml              # BeeWare Briefcase config
├── android/
│   └── README_ANDROID.md       # Android build notes
└── ios/
    └── README_IOS.md           # iOS build notes
```

## PyInstaller Standalone .exe

The `build/neunuc-voice.spec` file defines a single-file executable:

```python
# -*- mode: python ; coding: utf-8 -*-
block_cipher = None

a = Analysis(
    ['../src/neunuc_voice/__main__.py'],
    pathex=['../src'],
    binaries=[],
    datas=[
        ('../config/config.yaml', 'config'),
        ('../models', 'models'),
    ],
    hiddenimports=[
        'sounddevice',
        'onnxruntime',
        'fastapi',
        'uvicorn',
    ],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='neunuc-voice',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    icon='../assets/icon.ico',
)
```

Build the `.exe`:

```bash
cd build
pyinstaller neunuc-voice.spec --clean
```

Output: `dist/neunuc-voice.exe`

**Note:** The `icon` field references `assets/icon.ico` which does not exist yet. Create a 256x256 `.ico` file before building, or remove the `icon=` line.

## Inno Setup Wizard

`build/neunuc-voice.iss` creates a professional Windows installer:

```pascal
[Setup]
AppName=NeuNuc Voice
AppVersion=0.1.0
DefaultDirName={autopf}\NeuNucVoice
DefaultGroupName=NeuNuc Voice
OutputDir=dist
OutputBaseFilename=neunuc-voice-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "dist\neunuc-voice.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\config\config.yaml"; DestDir: "{app}\config"; Flags: ignoreversion
Source: "..\models\*"; DestDir: "{app}\models"; Flags: ignoreversion recursesubdirs
Source: "..\assets\icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\NeuNuc Voice"; Filename: "{app}\neunuc-voice.exe"; IconFilename: "{app}\icon.ico"
Name: "{autodesktop}\NeuNuc Voice"; Filename: "{app}\neunuc-voice.exe"; IconFilename: "{app}\icon.ico"

[Run]
Filename: "{app}\neunuc-voice.exe"; Description: "Launch NeuNuc Voice"; Flags: nowait postinstall skipifsilent
```

Build the installer:

```bash
cd build
iscc neunuc-voice.iss
```

Output: `dist/neunuc-voice-setup.exe`

## One-Click Windows Build

`build/install.bat` automates the full build chain:

```batch
@echo off
setlocal enabledelayedexpansion

echo NeuNuc Voice — Windows Installer Builder
echo =========================================
echo.

:: Check Python
call python --version > nul 2>>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH.
    echo Install Python 3.10+ from https://python.org
    pause
    exit /b 1
)

:: Install dependencies
echo [1/4] Installing Python dependencies...
call pip install -e ".[dev]" > nul 2>>&1
if errorlevel 1 (
    echo ERROR: Failed to install Python dependencies.
    pause
    exit /b 1
)

:: Download models
echo [2/4] Downloading ONNX models...
call python scripts/download_models.py > nul 2>>&1
if errorlevel 1 (
    echo WARNING: Model download failed. Models may need manual placement.
)

:: Build .exe
echo [3/4] Building standalone executable...
call pyinstaller build/neunuc-voice.spec --clean --noconfirm > nul 2>>&1
if errorlevel 1 (
    echo ERROR: PyInstaller build failed.
    pause
    exit /b 1
)

:: Build installer
echo [4/4] Building installer...
call iscc build/neunuc-voice.iss > nul 2>>&1
if errorlevel 1 (
    echo ERROR: Inno Setup build failed.
    echo Make sure Inno Setup is installed: https://jrsoftware.org/isinfo.php
    pause
    exit /b 1
)

echo.
echo Build complete.
echo Installer: dist\neunuc-voice-setup.exe
echo.
pause
```

Prerequisites:

- Python 3.10+
- Inno Setup 6.x (download from [jrsoftware.org](https://jrsoftware.org/isinfo.php))
- `pip install pyinstaller`

## BeeWare Briefcase (Desktop + Mobile)

`build/briefcase.toml` defines cross-platform builds via Briefcase:

```toml
[tool.briefcase]
project_name = "NeuNuc Voice"
bundle = "com.neunuc"
version = "0.1.0"
url = "https://github.com/neu-nuc/neunuc-voice"
license = "Apache-2.0"
author = "HelzKelz"
author_email = "helz@neunuc.com"

[tool.briefcase.app.neunuc-voice]
formal_name = "NeuNuc Voice"
description = "Local-first voice assistant with zero-cloud audio policy."
icon = "assets/icon"
sources = ["src/neunuc_voice"]
requires = [
    "sounddevice",
    "onnxruntime",
    "fastapi",
    "uvicorn",
]
```

Desktop build:

```bash
briefcase create
briefcase build
briefcase package
```

## Mobile Scaffolding

### Android

`build/android/README_ANDROID.md`:

1. Install Android Studio and SDK
2. Set `ANDROID_HOME` environment variable
3. Run `briefcase create android`
4. Run `briefcase build android`
5. Run `briefcase run android` (deploys to connected device)

**Note:** Mobile audio I/O requires platform-specific backends. `sounddevice` is desktop-only. Replace with `android.media.AudioRecord` / `AudioTrack` in a platform bridge.

### iOS

`build/ios/README_IOS.md`:

1. Install Xcode 15+
2. Run `briefcase create iOS`
3. Run `briefcase build iOS`
4. Open `build/ios/NeuNuc Voice.xcodeproj` in Xcode
5. Sign with Apple Developer account and deploy

**Note:** iOS audio I/O requires `AVAudioEngine`. Replace `sounddevice` with `pyobjus` / `rubicon-objc` bridge to `AVAudioSession`.

## Asset Requirements

| Asset | Path | Format | Size |
|-------|------|--------|------|
| Desktop icon | `assets/icon.ico` | ICO | 256x256 |
| Desktop icon PNG | `assets/icon.png` | PNG | 512x512 |
| Android adaptive | `assets/icon-android.png` | PNG | 1024x1024 |
| iOS app icon | `assets/icon-ios.png` | PNG | 1024x1024 |

All icons are currently uncreated. The build scripts reference them but will fall back to default PyInstaller/BeeWare icons if missing.

## Build Checklist

Before shipping a release:

- [ ] `config/config.yaml` has production-ready settings
- [ ] All ONNX models are present in `models/`
- [ ] `assets/icon.ico` exists
- [ ] `version` bumped in `pyproject.toml`, `briefcase.toml`, and `config.yaml`
- [ ] `install.bat` tested on a clean Windows VM
- [ ] PyInstaller build produces a working `.exe`
- [ ] Inno Setup installer installs and launches successfully
- [ ] Voice pipeline boots without errors after install

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `icon.ico` not found | Missing asset | Create a 256x256 ICO or remove icon references |
| PyInstaller build huge | Bundling unnecessary packages | Add packages to `excludes` in `.spec` |
| Inno Setup fails | `iscc` not in PATH | Add Inno Setup install directory to PATH |
| `.exe` crashes on launch | Missing ONNX Runtime DLL | Include `onnxruntime` in hiddenimports |
| Mobile build fails | No platform bridge | Implement audio I/O bridge for target platform |
| Briefcase not found | Not installed | `pip install briefcase` |
