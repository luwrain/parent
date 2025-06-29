
[Setup]
AppId={{org.luwrain.core}}
AppName=LUWRAIN
AppVersion=LUWRAIN_VERSION
AppVerName=LUWRAIN LUWRAIN_VERSION
AppPublisher=The LUWRAIN Project
AppComments=A platform for the creation of apps for the blind and partially-sighted
AppCopyright=Copyright (C) 2012-2022 The LUWRAIN Project
AppPublisherURL=http://luwrain.org
;AppSupportURL=http://java.com/
;AppUpdatesURL=http://java.com/
;{localappdata}\Luwrain
DefaultDirName={code:GetDefaultDir}
DisableStartupPrompt=Yes
DisableDirPage=Yes
DisableProgramGroupPage=Yes
DisableReadyPage=Yes
DisableFinishedPage=Yes
DisableWelcomePage=Yes
DefaultGroupName=LUWRAIN
;Optional License
LicenseFile=
;WinXP or above
MinVersion=0,6.1 
OutputBaseFilename=luwrain
Compression=lzma2/normal
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile=Luwrain\Luwrain.ico
UninstallDisplayIcon={app}\Luwrain.ico
UninstallDisplayName=Luwrain
WizardImageStretch=No
WizardSmallImageFile=setup-icon.bmp
ArchitecturesInstallIn64BitMode=


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "Luwrain\Luwrain.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Luwrain\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Luwrain"; Filename: "%ComSpec%"; Parameters: "/c start {code:GetDefaultDir}\Luwrain.exe"; WorkingDir: "{code:GetDefaultDir}"; IconFilename: "{app}\Luwrain.ico"; Check: returnTrue()
Name: "{autodesktop}\Luwrain"; Filename: "%ComSpec%"; Parameters: "/c start {code:GetDefaultDir}\Luwrain.exe"; WorkingDir: "{code:GetDefaultDir}"; IconFilename: "{app}\Luwrain.ico"; Check: returnTrue()

[Run]
Filename: "{code:GetDefaultDir}\Luwrain.exe"; Parameters: "-Xappcds:generatecache"; Check: returnFalse()
Filename: "{code:GetDefaultDir}\Luwrain.exe"; Description: "{cm:LaunchProgram,Luwrain}"; Flags: nowait postinstall skipifsilent; Check: returnTrue()
Filename: "{code:GetDefaultDir}\Luwrain.exe"; Parameters: "-install -svcName ""Luwrain"" -svcDesc ""Luwrain"" -mainExe ""Luwrain.exe""  "; Check: returnFalse()

[UninstallRun]
Filename: "{code:GetDefaultDir}\Luwrain.exe "; Parameters: "-uninstall -svcName Luwrain -stopOnUninstall"; Check: returnFalse()

[Code]
const
  BN_CLICKED = 0;
  WM_COMMAND = $0111;
  CN_BASE = $BC00;
  CN_COMMAND = CN_BASE + WM_COMMAND;

procedure CurPageChanged(CurPageID: Integer);
var
  Param: Longint;
begin
  // if we are on the ready page, then...
  if CurPageID = wpReady then
  begin
    // the result of this is 0, just to be precise...
    Param := 0 or BN_CLICKED shl 16;
    // post the click notification message to the next button
    PostMessage(WizardForm.NextButton.Handle, CN_COMMAND, Param, 0);
  end;
end;

function returnTrue(): Boolean;
begin
  Result := True;
end;

function returnFalse(): Boolean;
begin
  Result := False;
end;

function GetDefaultDir(def: string): string;
begin
    // {localappdata}\Luwrain
    Result := GetShortName(GetEnv('localappdata')+'\Luwrain');
end;

function InitializeSetup(): Boolean;
begin
// Possible future improvements:
//   if version less or same => just launch app
//   if upgrade => check if same app is running and wait for it to exit
//   Add pack200/unpack200 support? 
  Result := True;
end;  
