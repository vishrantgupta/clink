;
; Copyright (c) 2012 Martin Ridgers
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;

;-------------------------------------------------------------------------------
Name                    "clink v${CLINK_VERSION}"
InstallDir              "$PROGRAMFILES\clink"
OutFile                 "${CLINK_BUILD}_setup.exe"
AllowSkipFiles          off
SetCompressor           /SOLID lzma
LicenseBkColor          /windows
LicenseData             ${CLINK_SOURCE}\installer\license.rtf
LicenseForceSelection   off
RequestExecutionLevel   admin
XPStyle                 on

;-------------------------------------------------------------------------------
Page license
Page directory
Page components
Page instfiles

UninstPage uninstConfirm
UninstPage components
UninstPage instfiles

;-------------------------------------------------------------------------------
Function cleanLegacyInstall
    IfFileExists $INSTDIR\..\clink_uninstall.exe +3 0
        DetailPrint "Install does not trample an existing one."
        Return

    ; Start menu items and uninstall registry entry.
    ;
    Delete $SMPROGRAMS\clink\*
    RMDir $SMPROGRAMS\clink
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Product"

    ; Install dir
    ;
    Delete /REBOOTOK $INSTDIR\..\clink*

    ; Migrate state to the new location.
    ;
    IfFileExists $APPDATA\clink 0 +2
        Rename $APPDATA\clink $LOCALAPPDATA\clink
FunctionEnd

;-------------------------------------------------------------------------------
Section "!Application files" app_files_id
    SectionIn RO
    SetShellVarContext all

    ; Install to a versioned folder to reduce interference between versions.
    ;
    StrCpy $INSTDIR $INSTDIR\${CLINK_VERSION}

    ; Installs the main files.
    ;
    CreateDirectory $INSTDIR
    SetOutPath $INSTDIR
    File ${CLINK_BUILD}\clink_dll_x*.dll
    File ${CLINK_BUILD}\clink.lua
    File ${CLINK_BUILD}\CHANGES
    File ${CLINK_BUILD}\LICENSE
    File ${CLINK_BUILD}\clink_x*.exe
    File ${CLINK_BUILD}\clink.bat
    File ${CLINK_BUILD}\clink_inputrc
    File ${CLINK_BUILD}\clink.html

    ; Create a start-menu shortcut
    ;
    StrCpy $0 "$SMPROGRAMS\clink\${CLINK_VERSION}"
    CreateDirectory $0
    CreateShortcut "$0\clink v${CLINK_VERSION}.lnk" "$INSTDIR\clink.bat" "" "$SYSDIR\cmd.exe" 0 SW_SHOWMINIMIZED 
    CreateShortcut "$0\clink v${CLINK_VERSION} Documentation.lnk" "$INSTDIR\clink.html"

    ; Create an uninstaller and a shortcut to it.
    ;
    StrCpy $1 "clink_uninstall_${CLINK_VERSION}.exe"
    WriteUninstaller "$INSTDIR\$1"
    CreateShortcut "$0\Uninstall clink v${CLINK_VERSION}.lnk" "$INSTDIR\$1"

    ; Add to "add/remove programs" or "programs and features"
    ;
    StrCpy $0 "Software\Microsoft\Windows\CurrentVersion\Uninstall\clink_${CLINK_VERSION}"
    WriteRegStr HKLM $0 "DisplayName"       "clink v${CLINK_VERSION}"
    WriteRegStr HKLM $0 "UninstallString"   "$INSTDIR\$1"
    WriteRegStr HKLM $0 "Publisher"         "Martin Ridgers"
    WriteRegStr HKLM $0 "DisplayIcon"       "$SYSDIR\cmd.exe,0"
    WriteRegStr HKLM $0 "URLInfoAbout"      "http://code.google.com/p/clink"
    WriteRegStr HKLM $0 "HelpLink"          "http://code.google.com/p/clink"
    WriteRegStr HKLM $0 "InstallLocation"   "$INSTDIR"
    WriteRegStr HKLM $0 "DisplayVersion"    "${CLINK_VERSION}"

    SectionGetSize ${app_files_id} $1
    WriteRegDWORD HKLM $0 "EstimatedSize"   $1

    ; Clean up legacy installs.
    ;
    Call cleanLegacyInstall

    CreateDirectory $LOCALAPPDATA\clink
SectionEnd

;-------------------------------------------------------------------------------
Section "Autorun when cmd.exe starts"
    SetShellVarContext all
    ExecShell "open" "$INSTDIR\clink_x86.exe" "autorun --install" SW_HIDE
SectionEnd

;-------------------------------------------------------------------------------
Section "!un.Application files"
    SectionIn RO
    SetShellVarContext all

    ExecShell "open" "$INSTDIR\clink_x86.exe" "autorun --uninstall" SW_HIDE

    ; Delete the instaltion directory and root directory if it's empty.
    ;
    Delete /REBOOTOK $INSTDIR\clink*
    Delete $INSTDIR\CHANGES
    Delete $INSTDIR\LICENSE
    RMDir /REBOOTOK $INSTDIR
    RMDir /REBOOTOK $INSTDIR\..

    ; Remove start menu items and uninstall registry entry.
    RMDir /r $SMPROGRAMS\clink\${CLINK_VERSION}
    RMDir $SMPROGRAMS\clink
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\clink_${CLINK_VERSION}"
SectionEnd

;-------------------------------------------------------------------------------
Section /o "un.User scripts and history"
    SetShellVarContext all

    RMDIR /r $APPDATA\clink         ; ...legacy path.
    RMDIR /r $LOCALAPPDATA\clink
SectionEnd