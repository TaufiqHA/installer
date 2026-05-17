# GEMINI.md - MyApp Windows Installer

## Project Overview
This project is a Windows installer generator for a Node.js and MongoDB-based application. It utilizes **Inno Setup** to create a user-friendly `.exe` installer that automates the deployment of the entire application stack.

### Key Technologies
- **Inno Setup (6.x)**: For creating the Windows installer executable.
- **PowerShell**: For handling complex installation and update logic (Node.js/MongoDB installation, ZIP extraction, PM2 setup).
- **winget**: Used by scripts to install system dependencies (Node.js, MongoDB).
- **PM2**: Used for Node.js process management on the target machine.
- **Node.js**: The target application's runtime environment.

## Directory Structure
- `MyApp_Setup.iss`: The primary Inno Setup script. Defines the installer's metadata, UI pages, and execution steps.
- `scripts/`:
  - `install.ps1`: The main installation script executed by the installer. Handles dependency checks, downloading the app ZIP, configuring `.env`, and starting the app via PM2.
  - `update.ps1`: A script bundled with the app for handling subsequent updates.
- `assets/`: Contains installer assets like `app.ico` and `BACA.txt`.
- `dist/`: The target directory for the compiled `MyApp_Installer.exe`.

## Building and Running

### Build the Installer
To compile the installer from source:
1.  Ensure **Inno Setup 6.x** is installed on your Windows machine.
2.  Open `MyApp_Setup.iss` in the Inno Setup Compiler.
3.  Click **Compile** (or press `F9`).
4.  The output will be generated in `dist/MyApp_Installer.exe`.

### Development and Testing
- **Modifying Installer Logic**: Edit `MyApp_Setup.iss` for UI/Wizard changes and `scripts/install.ps1` for installation flow changes.
- **Testing Scripts**: You can test the PowerShell scripts independently, but they are designed to receive parameters from the Inno Setup executable.

## Development Conventions

### Scripting Guidelines
- **PowerShell (v5.1+)**: Ensure compatibility with Windows 10/11 default PowerShell. Use `-ExecutionPolicy Bypass` when calling scripts.
- **Error Handling**: Scripts should use `Log`, `Ok`, and `Err` functions for consistent logging and termination on failure.
- **Admin Privileges**: The installer and scripts require administrator privileges (`PrivilegesRequired=admin` in `.iss`).

### Customization
- **Application Metadata**: Update `#define` constants in `MyApp_Setup.iss` (e.g., `AppName`, `AppVersion`, `ZipUrl`).
- **Environment Variables**: Add or modify variables in the `Create-Env` function within `scripts/install.ps1`.
- **Dependencies**: To add new dependencies, use `winget` commands in `install.ps1` or bundle them in the `assets/` folder and update the `.iss` file to include them in the installer.

### Updating the App
- The application is updated via `scripts/update.ps1`, which is placed in the installation directory. It downloads a new ZIP from `ZipUrl` and restarts the PM2 process.
