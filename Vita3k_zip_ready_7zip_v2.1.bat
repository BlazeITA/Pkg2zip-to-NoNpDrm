@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

title VITA3K READY - 7ZIP
color 0B

:: ------------------- CONFIG -------------------
set "SCRIPT_DIR=%~dp0"
set "SEVENZIP="
set "MAPFILE=TITLEID_NAME_MATCH.txt"
set "ERRORLOG=VITA3K_errors.log"

:: Counters
set /a TOTAL=0
set /a DONE=0
set /a ZIP_OK=0
set /a ZIP_SKIP=0
set /a ZIP_FAIL=0
set /a FOLDER_FAIL=0
set /a RENAME_APP_OK=0
set /a RENAME_APP_SKIP=0
set /a RENAME_APP_FAIL=0
set /a RENAME_RAW_OK=0
set /a RENAME_RAW_SKIP=0
set /a RENAME_RAW_FAIL=0

:: ------------------- DETECT 7ZIP -------------------
if exist "%SCRIPT_DIR%7z.exe" set "SEVENZIP=%SCRIPT_DIR%7z.exe"
if not defined SEVENZIP if exist "%SCRIPT_DIR%7-Zip\7z.exe" set "SEVENZIP=%SCRIPT_DIR%7-Zip\7z.exe"
if not defined SEVENZIP if exist "C:\Program Files\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
if not defined SEVENZIP if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"
if not defined SEVENZIP for /f "delims=" %%I in ('where 7z.exe 2^>nul') do set "SEVENZIP=%%I"

if exist "%ERRORLOG%" del /q "%ERRORLOG%"

:: ------------------- CHECKS -------------------
echo ======================================================================
echo VITA3K FINAL EN
echo MERGE + ZIP + CLEANUP + RENAME
echo ======================================================================
echo.
color 0A
echo Working folder    : %cd%
echo.

if not defined SEVENZIP (
    color 0C
    echo [ERROR] 7z.exe was not found.
    pause
    exit /b 1
)

if not exist "%MAPFILE%" (
    color 0C
    echo [ERROR] Mapping file not found: %MAPFILE%
    pause
    exit /b 1
)

if not exist "app" (
    color 0C
    echo [ERROR] app folder not found.
    pause
    exit /b 1
)

echo 7-Zip detected    : %SEVENZIP%
echo Mapping file      : %MAPFILE%
echo.

:: ------------------- LIST TITLES -------------------
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

:: ------------------- PROCESS ONE -------------------
for /f %%T in ('dir /b /ad /on app 2^>nul') do call :ProcessOne "%%T"

:: ------------------- FINAL RENAME PASS -------------------
color 0B
echo.
echo ======================================================================
echo FINAL RENAME PASS ON EXISTING RAW ZIPS
echo ======================================================================
color 0A

for %%Z in (*_Vita3K_Ready.zip) do (
    set "RAWZIP=%%~nxZ"
    set "TITLEID=%%~nZ"
    set "TITLEID=!TITLEID:~0,9!"

    echo [FINAL PASS] Checking !RAWZIP! (!TITLEID!)

    call :DoRename "!RAWZIP!" "!TITLEID!" RENAME_RAW_RES

    if /I "!RENAME_RAW_RES!"=="OK" set /a RENAME_RAW_OK+=1
    if /I "!RENAME_RAW_RES!"=="SKIP" set /a RENAME_RAW_SKIP+=1
    if /I "!RENAME_RAW_RES!"=="FAIL" set /a RENAME_RAW_FAIL+=1
)

:: ------------------- FINAL SUMMARY -------------------
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
echo.

echo ------------------ RENAME FROM APP (ProcessOne) ------------------
set /a TOTAL_RENAME_APP=RENAME_APP_OK+RENAME_APP_SKIP+RENAME_APP_FAIL
echo Renamed ZIP files : !RENAME_APP_OK!
echo Rename skipped    : !RENAME_APP_SKIP!
echo Rename failed     : !RENAME_APP_FAIL!
echo.

echo ------------------ RENAME EXISTING ZIP (Final Pass) ------------------
set /a TOTAL_RENAME_RAW=RENAME_RAW_OK+RENAME_RAW_SKIP+RENAME_RAW_FAIL
echo Renamed ZIP files : !RENAME_RAW_OK!
echo Rename skipped    : !RENAME_RAW_SKIP!
echo Rename failed     : !RENAME_RAW_FAIL!
echo.

echo ------------------ TOTAL RENAME ------------------
set /a TOTAL_RENAMED=RENAME_APP_OK+RENAME_RAW_OK
set /a TOTAL_SKIPPED=RENAME_APP_SKIP+RENAME_RAW_SKIP
set /a TOTAL_FAIL=RENAME_APP_FAIL+RENAME_RAW_FAIL
echo Total renamed     : !TOTAL_RENAMED!
echo Total skipped     : !TOTAL_SKIPPED!
echo Total failed      : !TOTAL_FAIL!
echo.

if exist "%ERRORLOG%" (
    color 0C
    echo Titles with errors:
    type "%ERRORLOG%"
    color 0A
)

echo.
pause
exit /b

:: =========================================================
:: ===================== FUNCTIONS ==========================
:: =========================================================

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

:: ------------------- STEP 1: SOURCE STRUCTURE -------------------
echo [STEP 1] Checking Source Structure.
if exist "app\!TITLEID!" (
    echo [STEP 1.1] GAME = [X]
) else (
    echo [STEP 1.1] GAME = [ ]
)
if exist "patch\!TITLEID!" (
    echo [STEP 1.2] UPDATE = [X]
) else (
    echo [STEP 1.2] UPDATE = [ ]
)
if exist "addcont\!TITLEID!" (
    echo [STEP 1.3] DLCS = [X]
) else (
    echo [STEP 1.3] DLCS = [ ]
)

:: ------------------- CHECK EXISTING ZIPS -------------------
if defined FINALZIP if exist "!FINALZIP!" (
    echo [SKIP] Renamed game already present in folder: !FINALZIP!
    set "ZIPRES=SKIP"
    set "RENAMERES=SKIP"
    goto Cleanup
)

if exist "!RAWZIP!" (
    echo [SKIP] RAW ZIP already exists
    set "ZIPRES=SKIP"
    call :DoRename "!RAWZIP!" "!TITLEID!" RENAMERES_APP
    goto Cleanup
)

:: ------------------- STEP 2: MERGE -------------------
mkdir "!TMPDIR!" >nul 2>nul
if errorlevel 1 (
    set "ZIPRES=FOLDER_FAIL"
    goto Cleanup
)

xcopy "app\!TITLEID!" "!TMPDIR!\app\!TITLEID!" /E /I /Y >nul
if errorlevel 1 (
    set "ZIPRES=FOLDER_FAIL"
    goto Cleanup
)

if exist "patch\!TITLEID!" xcopy "patch\!TITLEID!" "!TMPDIR!\app\!TITLEID!" /E /I /Y >nul
if exist "addcont\!TITLEID!" xcopy "addcont\!TITLEID!" "!TMPDIR!\addcont\!TITLEID!" /E /I /Y >nul

:: ------------------- STEP 3: ZIP WITH 7ZIP -------------------
pushd "!TMPDIR!"
if exist "addcont" (
    "%SEVENZIP%" a -tzip "..\!RAWZIP!" "app\*" "addcont\*" >nul
) else (
    "%SEVENZIP%" a -tzip "..\!RAWZIP!" "app\*" >nul
)
popd

if not exist "!RAWZIP!" (
    set "ZIPRES=ZIP_FAIL"
    goto Cleanup
)

set "ZIPRES=OK"
call :DoRename "!RAWZIP!" "!TITLEID!" RENAMERES_APP

:Cleanup
rd /s /q "!TMPDIR!" >nul 2>nul

endlocal & (
    set "RET_ZIPRES=%ZIPRES%"
    set "RET_RENAMERES_APP=%RENAMERES_APP%"
)

set /a DONE+=1
if /I "%RET_ZIPRES%"=="OK" set /a ZIP_OK+=1
if /I "%RET_ZIPRES%"=="SKIP" set /a ZIP_SKIP+=1
if /I "%RET_ZIPRES%"=="ZIP_FAIL" set /a ZIP_FAIL+=1
if /I "%RET_ZIPRES%"=="FOLDER_FAIL" set /a FOLDER_FAIL+=1

if /I "%RET_RENAMERES_APP%"=="OK" set /a RENAME_APP_OK+=1
if /I "%RET_RENAMERES_APP%"=="SKIP" set /a RENAME_APP_SKIP+=1
if /I "%RET_RENAMERES_APP%"=="FAIL" set /a RENAME_APP_FAIL+=1

goto :eof

:GetFinalZipName
setlocal DisableDelayedExpansion
set "RID=%~1"
set "RESULT="
for /f "usebackq delims=" %%N in (`powershell -NoProfile -Command "$id='%RID%'; $line=Get-Content '%MAPFILE%' | ? { $_.StartsWith($id + [char]9) } | select -First 1; if($line){$n=$line.Split([char]9)[1];$n=$n -replace '[\\/:*?""<>|]',''; if($n){$n+'.zip'}}"`) do set "RESULT=%%N"
endlocal & set "%~2=%RESULT%"
goto :eof

:DoRename
setlocal
set "ZIPFILE=%~1"
set "RID=%~2"
set "DEST="
set "RESULT=SKIP"

call :GetFinalZipName "%RID%" DEST

if not defined DEST goto end
if not exist "%ZIPFILE%" goto end
if /I "%~nx1"=="%DEST%" goto end
if exist "%DEST%" goto end

ren "%ZIPFILE%" "%DEST%" >nul 2>nul
if errorlevel 1 (
    set "RESULT=FAIL"
    goto end
)

echo [OK] Renamed: %DEST%
set "RESULT=OK"

:end
endlocal & set "%~3=%RESULT%"
goto :eof