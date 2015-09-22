  !include "MUI2.nsh"

  RequestExecutionLevel admin

  !define COMPANY_NAME "Akifox Studio"
  !define APP_NAME "Mimic Rush"
  !define APP_FOLDER "Mimic Rush"
  !define APP_EXE "Mimic Rush.exe"
  !define APP_SHORT_NAME "mimicrush"
  !define APP_VERSION "1.2.0" #TODEPLOY
  !define APP_VERSION_MAJOR 1 #TODEPLOY
  !define APP_VERSION_MINOR 2 #TODEPLOY
  #!define APP_INSTALLSIZE 15360
  !define URL_AKIFOX "http://akifox.com"
  !define URL_ABOUT "http://akifox.com/mimicrush"

  !define MUI_ICON ..\..\Export\windows\cpp\bin\icon.ico
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_RIGHT
  !define MUI_HEADERIMAGE_BITMAP "Header.bmp"
  !define MUI_HEADERIMAGE_UNBITMAP "Header.bmp"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "Panel.bmp"
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP "Panel.bmp"

  !define MUI_BGCOLOR EEEEEE


  Name "${APP_NAME} ${APP_VERSION}"
  OutFile "${APP_SHORT_NAME}-${APP_VERSION}-installer.exe"

  InstallDir "$PROGRAMFILES\${APP_FOLDER}"
  InstallDirRegKey HKCU "Software\${APP_FOLDER}" ""

  ShowInstDetails show
;--------------------------------
;Pages
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
    !define MUI_FINISHPAGE_NOAUTOCLOSE
    !define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXE}"
    !define MUI_FINISHPAGE_RUN_CHECKED
    !define MUI_FINISHPAGE_RUN_TEXT "Play ${APP_NAME}"
    !define MUI_FINISHPAGE_LINK "${COMPANY_NAME}"
    !define MUI_FINISHPAGE_LINK_LOCATION "${URL_AKIFOX}"
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
    #!define MUI_UNFINISHPAGE_NOAUTOCLOSE
  !insertmacro MUI_UNPAGE_FINISH


;Languages
!insertmacro MUI_LANGUAGE "English"

;--------------------------------
# No components page, so this is anonymous
Section "Dummy Section" SecDummy

  SetShellVarContext all

  SetOutPath "$INSTDIR"

  #try to uninstall previous versions
  DetailPrint "> Try to uninstall previous version"
  ExecWait '"$INSTDIR\Uninstall.exe" /S _?=$INSTDIR'

  #files
  DetailPrint "> Copy files"
  File /r ..\..\Export/windows\cpp\bin\*.*

  #registry
  DetailPrint "> Write uninstaller registry keys"
  WriteRegStr HKCU "Software\${APP_FOLDER}" "" $INSTDIR
  # Registry information for add/remove programs
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "DisplayName" "${APP_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S _?=$INSTDIR'
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "DisplayIcon" "$\"$INSTDIR\icon.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "Publisher" "${COMPANY_NAME}"
	#WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "HelpLink" "${URL_HELP}"
	#WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "URLUpdateInfo" "${URL_UPDATE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "URLInfoAbout" "${URL_ABOUT}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "VersionMajor" ${APP_VERSION_MAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "VersionMinor" ${APP_VERSION_MINOR}
	# There is no option for modifying or repairing the install
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "NoRepair" 1
	# Set the INSTALLSIZE constant (!defined at the top of this script) so Add/Remove Programs can accurately report the size
	#WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}" "EstimatedSize" ${APP_INSTALLSIZE}

  # uninstaller
  DetailPrint "> Create Uninstaller"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  # shortcuts
  DetailPrint "> Create Shortcuts"
  createDirectory "$SMPROGRAMS\${APP_FOLDER}"
  createShortcut "$SMPROGRAMS\${APP_FOLDER}\${APP_NAME}.lnk" \
    "$INSTDIR\${APP_EXE}"
  createShortcut "$SMPROGRAMS\${APP_FOLDER}\Uninstall.lnk" \
    "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Uninstall"

  SetShellVarContext all

  DetailPrint "> Delete files"
  #remove app
  RMDir /r $INSTDIR

  # remove shortcuts
  DetailPrint "> Delete shortcuts"
  RMDir /r "$SMPROGRAMS\${APP_FOLDER}"

  #remove registry
  DetailPrint "> Delete registry keys"
  DeleteRegKey /ifempty HKCU "Software\${APP_FOLDER}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANY_NAME} ${APP_NAME}"

SectionEnd
