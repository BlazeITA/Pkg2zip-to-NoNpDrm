@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"

title VITA3K READY - WINRAR
color 0B

set "SCRIPT_DIR=%~dp0"
set "WINRAR="
set "MAPFILE=TITLEID_NAME_MATCH.txt"
set "ERRORLOG=VITA3K_errors.log"

set /a TOTAL=0
set /a DONE=0
set /a ZIP_OK=0
set /a ZIP_SKIP=0
set /a ZIP_FAIL=0
set /a FOLDER_FAIL=0
set /a RENAME_OK=0
set /a RENAME_SKIP=0
set /a RENAME_FAIL=0

if exist "%SCRIPT_DIR%WinRAR.exe" set "WINRAR=%SCRIPT_DIR%WinRAR.exe"
if not defined WINRAR if exist "%SCRIPT_DIR%WinRAR\\\\WinRAR.exe" set "WINRAR=%SCRIPT_DIR%WinRAR\\\\WinRAR.exe"
if not defined WINRAR if exist "C:\\\\Program Files\\\\WinRAR\\\\WinRAR.exe" set "WINRAR=C:\\\\Program Files\\\\WinRAR\\\\WinRAR.exe"
if not defined WINRAR if exist "C:\\\\Program Files (x86)\\\\WinRAR\\\\WinRAR.exe" set "WINRAR=C:\\\\Program Files (x86)\\\\WinRAR\\\\WinRAR.exe"
if not defined WINRAR for /f "delims=" %%I in ('where WinRAR.exe 2^>nul') do set "WINRAR=%%I"

if exist "%ERRORLOG%" del /q "%ERRORLOG%"

echo ======================================================================
echo VITA3K FINAL EN
echo MERGE + ZIP + CLEANUP + RENAME
echo ======================================================================
echo.
color 0A
echo Working folder    : %cd%
echo.

if not defined WINRAR (
    color 0C
    echo [ERROR] WinRAR.exe was not found.
    echo.
    pause
    exit /b 1
)

if not exist "%MAPFILE%" (
    color 0C
    echo [ERROR] Mapping file not found: %MAPFILE%
    echo.
    pause
    exit /b 1
)

if not exist "app" (
    color 0C
    echo [ERROR] app folder not found.
    echo.
    pause
    exit /b 1
)

echo WinRAR detected   : %WINRAR%
echo Mapping file      : %MAPFILE%
echo.

for /f %%T in ('dir /b /ad /on app 2^>nul') do set /a TOTAL+=1

echo Games found       : %TOTAL%
echo.

color 0B
echo Detected TITLEIDs:
echo ----------------------------------------------------------------------
color 0A
dir /b /ad /on app 2>nul
color 0B
echo ----------------------------------------------------------------------
echo.

for /f %%T in ('dir /b /ad /on app 2^>nul') do call :ProcessOne "%%T"

echo.
color 0B
echo ======================================================================
echo COMPLETED
echo ======================================================================
echo.
color 0A
echo Total games       : %TOTAL%
echo ZIP files created : %ZIP_OK%
echo ZIP files skipped : %ZIP_SKIP%
echo ZIP files failed  : %ZIP_FAIL%
echo Folder copy fail  : %FOLDER_FAIL%
echo Renamed ZIP files : %RENAME_OK%
echo Rename skipped    : %RENAME_SKIP%
echo Rename failed     : %RENAME_FAIL%

if exist "%ERRORLOG%" (
    echo.
    color 0C
    echo Titles with errors:
    type "%ERRORLOG%"
    color 0A
)

echo.
pause
exit /b

:ProcessOne
setlocal EnableDelayedExpansion
set "TITLEID=%~1"
set "TMPDIR=_VITA3K_TMP_!TITLEID!"
set "RAWZIP=!TITLEID!_Vita3K_Ready.zip"
set "FINALZIP="
set "ZIPRES="
set "RENAMERES="
set /a POS=%DONE%+1

color 0B
echo ======================================================================
echo [!POS!/%TOTAL%] PROCESSING !TITLEID!
echo ======================================================================
color 0A

call :GetFinalZipName "!TITLEID!" FINALZIP

if defined FINALZIP (
    echo [INFO] Expected final ZIP NAME: !FINALZIP!
) else (
    echo [INFO] No valid mapped final name for !TITLEID!.
)

echo [STEP 1] Checking Source Structure.
if exist "app\\\\!TITLEID!" (
    echo [STEP 1.1] GAME = [X]
) else (
    echo [STEP 1.1] GAME = [ ]
)
if exist "patch\\\\!TITLEID!" (
    echo [STEP 1.2] UPDATE = [X]
) else (
    echo [STEP 1.2] UPDATE = [ ]
)
if exist "addcont\\\\!TITLEID!" (
    echo [STEP 1.3] DLCS = [X]
) else (
    echo [STEP 1.3] DLCS = [ ]
)

if defined FINALZIP if exist "!FINALZIP!" (
    echo [SKIP] Renamed game already present in folder: !FINALZIP!
    set "ZIPRES=SKIP"
    set "RENAMERES=SKIP"
    goto ProcessOne_Cleanup
)

if exist "!RAWZIP!" (
    echo [SKIP] ZIP already exists: !RAWZIP!
    set "ZIPRES=SKIP"
    call :DoRename "!RAWZIP!" "!TITLEID!" RENAMERES
    goto ProcessOne_Cleanup
)

if exist "!TMPDIR!" rd /s /q "!TMPDIR!" >nul 2>nul

echo [STEP 2] Creating temp folder
mkdir "!TMPDIR!" >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Cannot create temp folder for !TITLEID!
    >>"%ERRORLOG%" echo !TITLEID! - MKDIR ERROR
    set "ZIPRES=FOLDER_FAIL"
    goto ProcessOne_Cleanup
)

echo [STEP 2.1] Merging source folders
xcopy "app\\\\!TITLEID!" "!TMPDIR!\\\\app\\\\!TITLEID!" /E /I /H /R /Y >nul
if errorlevel 1 (
    echo [ERROR] Base game copy failed for !TITLEID!
    >>"%ERRORLOG%" echo !TITLEID! - BASE COPY ERROR
    set "ZIPRES=FOLDER_FAIL"
    goto ProcessOne_Cleanup
)

if exist "patch\\\\!TITLEID!" (
    echo [STEP 2.2] Merging update
    xcopy "patch\\\\!TITLEID!" "!TMPDIR!\\\\app\\\\!TITLEID!" /E /I /H /R /Y >nul
    if errorlevel 1 (
        echo [ERROR] Patch copy failed for !TITLEID!
        >>"%ERRORLOG%" echo !TITLEID! - PATCH COPY ERROR
        set "ZIPRES=FOLDER_FAIL"
        goto ProcessOne_Cleanup
    )
)

if exist "addcont\\\\!TITLEID!" (
    echo [STEP 2.3] Copying DLC
    xcopy "addcont\\\\!TITLEID!" "!TMPDIR!\\\\addcont\\\\!TITLEID!" /E /I /H /R /Y >nul
    if errorlevel 1 (
        echo [ERROR] DLC copy failed for !TITLEID!
        >>"%ERRORLOG%" echo !TITLEID! - DLC COPY ERROR
        set "ZIPRES=FOLDER_FAIL"
        goto ProcessOne_Cleanup
    )
)

if not exist "!TMPDIR!\\\\app\\\\!TITLEID!" (
    echo [ERROR] Final structure is invalid for !TITLEID!
    >>"%ERRORLOG%" echo !TITLEID! - MERGE ERROR
    set "ZIPRES=FOLDER_FAIL"
    goto ProcessOne_Cleanup
)

echo [STEP 3] ZIP compression with WinRAR
echo [FILE] !RAWZIP!

pushd "!TMPDIR!" >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Cannot enter temp folder for !TITLEID!
    >>"%ERRORLOG%" echo !TITLEID! - PUSHD ERROR
    set "ZIPRES=FOLDER_FAIL"
    goto ProcessOne_Cleanup
)

if exist "addcont" (
    "%WINRAR%" a -afzip -r "..\\\\!RAWZIP!" "app" "addcont" >nul 2>&1
) else (
    "%WINRAR%" a -afzip -r "..\\\\!RAWZIP!" "app" >nul 2>&1
)
set "WERR=!errorlevel!"
popd >nul 2>nul

echo [DEBUG] WinRAR exit code for !TITLEID!: !WERR!

if not exist "!RAWZIP!" (
    echo [ERROR] ZIP was not created for !TITLEID!
    >>"%ERRORLOG%" echo !TITLEID! - ZIP NOT CREATED
    set "ZIPRES=ZIP_FAIL"
    goto ProcessOne_Cleanup
)

if not "!WERR!"=="0" if not "!WERR!"=="1" (
    echo [ERROR] WinRAR returned exit code !WERR!
    >>"%ERRORLOG%" echo !TITLEID! - WINRAR ERROR !WERR!
    set "ZIPRES=ZIP_FAIL"
    goto ProcessOne_Cleanup
)

echo [OK] ZIP created: !RAWZIP!
set "ZIPRES=OK"

call :DoRename "!RAWZIP!" "!TITLEID!" RENAMERES

:ProcessOne_Cleanup
if exist "!TMPDIR!" (
    echo [CLEANUP] Removing temp folder !TMPDIR!
    rd /s /q "!TMPDIR!" >nul 2>nul
    if exist "!TMPDIR!" (
        timeout /t 1 /nobreak >nul
        rd /s /q "!TMPDIR!" >nul 2>nul
    )
    if exist "!TMPDIR!" (
        echo [WARNING] Temp folder not removed: !TMPDIR!
        >>"%ERRORLOG%" echo !TITLEID! - TEMP CLEANUP ERROR
    ) else (
        echo [OK] Temp folder removed: !TMPDIR!
    )
)

if not defined ZIPRES set "ZIPRES="
if not defined RENAMERES set "RENAMERES="

endlocal & set "RET_ZIPRES=%ZIPRES%" & set "RET_RENAMERES=%RENAMERES%"

set /a DONE+=1
if /I "%RET_ZIPRES%"=="OK" set /a ZIP_OK+=1
if /I "%RET_ZIPRES%"=="SKIP" set /a ZIP_SKIP+=1
if /I "%RET_ZIPRES%"=="ZIP_FAIL" set /a ZIP_FAIL+=1
if /I "%RET_ZIPRES%"=="FOLDER_FAIL" set /a FOLDER_FAIL+=1

if /I "%RET_RENAMERES%"=="OK" set /a RENAME_OK+=1
if /I "%RET_RENAMERES%"=="SKIP" set /a RENAME_SKIP+=1
if /I "%RET_RENAMERES%"=="FAIL" set /a RENAME_FAIL+=1

goto :eof

:GetFinalZipName
setlocal DisableDelayedExpansion
set "RID=%~1"
set "RESULT="
for /f "usebackq delims=" %%N in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$id='%RID%'; $line=Get-Content -LiteralPath '%MAPFILE%' | Where-Object { $_.StartsWith($id + [char]9) } | Select-Object -First 1; if($line){ $parts=$line -split [char]9,2; if($parts.Count -eq 2){ $name=$parts[1].Trim(); $name=$name -replace '[\\\\\\\\/:*?""<>|!]',''; if($name){ Write-Output ($name + '.zip') } } }" 2^>nul`) do set "RESULT=%%N"
endlocal & set "%~2=%RESULT%"
goto :eof

:DoRename
setlocal DisableDelayedExpansion
set "ZIPFILE=%~1"
set "RID=%~2"
set "DEST="
set "RESULT=SKIP"

call :GetFinalZipName "%RID%" DEST

if not defined DEST goto DoRename_End
if not exist "%ZIPFILE%" goto DoRename_End
if /I "%~nx1"=="%DEST%" goto DoRename_End
if exist "%DEST%" goto DoRename_End

ren "%ZIPFILE%" "%DEST%" >nul 2>nul
if errorlevel 1 (
    >>"%ERRORLOG%" echo %RID% - RENAME ERROR
    set "RESULT=FAIL"
    goto DoRename_End
)

echo [OK] ZIP renamed successfully: %DEST%
set "RESULT=OK"

:DoRename_End
endlocal & set "%~3=%RESULT%"
goto :eof
