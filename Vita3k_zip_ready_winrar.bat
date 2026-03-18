@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

title VITA3K READY - WINRAR
color 0B

set "WINRAR="
set "SCRIPT_DIR=%~dp0"

if exist "%SCRIPT_DIR%WinRAR.exe" set "WINRAR=%SCRIPT_DIR%WinRAR.exe"
if not defined WINRAR if exist "%SCRIPT_DIR%WinRAR\WinRAR.exe" set "WINRAR=%SCRIPT_DIR%WinRAR\WinRAR.exe"
if not defined WINRAR if exist "C:\Program Files\WinRAR\WinRAR.exe" set "WINRAR=C:\Program Files\WinRAR\WinRAR.exe"
if not defined WINRAR if exist "C:\Program Files (x86)\WinRAR\WinRAR.exe" set "WINRAR=C:\Program Files (x86)\WinRAR\WinRAR.exe"

if not defined WINRAR for /f "delims=" %%I in ('where WinRAR.exe 2^>nul') do set "WINRAR=%%I"

echo ======================================================================
echo                         VITA3K FINAL EN
echo                MERGE + ZIP + AUTOMATIC CLEANUP
echo ======================================================================
echo.
color 0A
echo Working folder    : %cd%
echo.

if not exist "app" (
    color 0C
    echo [ERROR] "app" folder not found.
    echo.
    pause
    exit /b 1
)

if not defined WINRAR (
    color 0C
    echo [ERROR] WinRAR.exe was not found.
    echo Please install WinRAR, add it to PATH,
    echo or place WinRAR.exe next to this BAT file.
    echo.
    pause
    exit /b 1
)

echo WinRAR detected   : %WINRAR%
echo.

set /a TOTAL=0
set /a DONE=0
set /a ZIP_OK=0
set /a ZIP_SKIP=0
set /a ZIP_FAIL=0

if exist "VITA3K_errors.log" del /q "VITA3K_errors.log"

for /f %%T in ('dir /b /ad app') do set /a TOTAL+=1

echo Games found       : %TOTAL%
echo.

if %TOTAL%==0 (
    echo No games found in "app".
    echo.
    pause
    exit /b 0
)

color 0B
echo Detected TITLEIDs:
echo ----------------------------------------------------------------------
color 0A
dir /b /ad app
color 0B
echo ----------------------------------------------------------------------
echo.
echo Starting automatic process...
echo.

for /f %%T in ('dir /b /ad app') do (
    set /a DONE+=1
    set "OUT=_Vita3K_%%T"
    set "ZIPNAME=%%T_Vita3K_Ready.zip"

    color 0B
    echo ======================================================================
    echo [!DONE!/%TOTAL%] PROCESSING %%T
    echo ======================================================================
    color 0A

    if exist "!ZIPNAME!" (
        echo [SKIP] ZIP already exists: !ZIPNAME!
        echo Title skipped.
        set /a ZIP_SKIP+=1
        echo.
    ) else (
        if exist "!OUT!" rd /s /q "!OUT!"

        echo [STEP 1] Creating final folder
        mkdir "!OUT!"

        echo [STEP 1.1] Copying base game
        xcopy "app\%%T" "!OUT!\app\%%T" /E /I /H /R /Y >nul

        if exist "patch\%%T" (
            echo [STEP 1.2] Merging update
            xcopy "patch\%%T" "!OUT!\app\%%T" /E /I /H /R /Y >nul
            echo [OK] Update merged successfully.
        ) else (
            echo [INFO] No update found.
        )

        if exist "addcont\%%T" (
            echo [STEP 1.3] Copying DLC
            xcopy "addcont\%%T" "!OUT!\addcont\%%T" /E /I /H /R /Y >nul
            echo [OK] DLC copied successfully.
        ) else (
            echo [INFO] No DLC found.
        )

        if exist "!OUT!\app\%%T" (
            echo [OK] Merge completed successfully.
        ) else (
            color 0C
            echo [ERROR] Final structure is invalid.
            echo %%T - MERGE ERROR>>VITA3K_errors.log
            color 0A
        )

        echo [STEP 2] ZIP compression with WinRAR
        echo [FILE] !ZIPNAME!
        echo [WAIT] Large games may take some time...

        pushd "!OUT!"
        "%WINRAR%" a -afzip -r "..\!ZIPNAME!" * >nul
        set "WERR=!errorlevel!"
        popd

        if exist "!ZIPNAME!" (
            if "!WERR!"=="0" (
                echo [OK] ZIP created successfully.
            ) else if "!WERR!"=="1" (
                echo [WARNING] ZIP created with non-fatal warnings.
            ) else (
                color 0C
                echo [ERROR] WinRAR returned exit code !WERR!
                color 0A
            )

            echo [CLEANUP] Removing temporary folder !OUT!
            rd /s /q "!OUT!"
            set /a ZIP_OK+=1
        ) else (
            color 0C
            echo [ERROR] ZIP was not created for %%T
            echo [ERROR] WinRAR exit code: !WERR!
            color 0A
            echo [INFO] Temporary folder kept for safety.
            echo %%T - ZIP COMPRESSION ERROR ^(CODE !WERR!^)>>VITA3K_errors.log
            set /a ZIP_FAIL+=1
        )

        echo.
    )
)

color 0B
echo ======================================================================
echo                              COMPLETED
echo ======================================================================
echo.
color 0A
echo Total games       : %TOTAL%
echo ZIP files created : %ZIP_OK%
echo ZIP files skipped : %ZIP_SKIP%
echo ZIP files failed  : %ZIP_FAIL%

if exist "VITA3K_errors.log" (
    echo.
    color 0C
    echo Titles with errors:
    type "VITA3K_errors.log"
    color 0A
)

echo.
color 0B
echo Ready ZIP files:
echo ----------------------------------------------------------------------
color 0A
dir /b "*_Vita3K_Ready.zip" 2>nul
color 0B
echo ----------------------------------------------------------------------
echo.
pause
