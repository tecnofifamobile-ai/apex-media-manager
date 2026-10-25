[Setup]
AppId={{5F7A6937-2E80-4D56-8A19-9B948C9EAC72}
AppName=APEX Media Manager
AppVersion=2.2.54
AppPublisher=APEX
AppPublisherURL=https://apexmediamanager.com
AppSupportURL=https://apexmediamanager.com
AppUpdatesURL=https://apexmediamanager.com
DefaultDirName={autopf}\APEX Media Manager
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=.\build\windows\installer
OutputBaseFilename=APEX_Media_Manager_Setup
SetupIconFile=.\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: ".\build\windows\x64\runner\Release\APEX_Media.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\APEX Media Manager"; Filename: "{app}\APEX_Media.exe"
Name: "{autodesktop}\APEX Media Manager"; Filename: "{app}\APEX_Media.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\APEX_Media.exe"; Description: "{cm:LaunchProgram,APEX Media Manager}"; Flags: nowait postinstall skipifsilent shellexec
