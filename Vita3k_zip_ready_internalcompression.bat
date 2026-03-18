@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

title VITA3K READY - INTERNAL COMPRESSION
color 0B

echo ======================================================================
echo                         VITA3K FINAL
echo                 MERGE + ZIP + AUTOMATIC CLEANUP
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

set /a TOTAL=0
set /a DONE=0
set /a ZIP_OK=0
set /a ZIP_SKIP=0
set /a ZIP_FAIL=0

for /f %%T in ('dir /b /ad "app"') do set /a TOTAL+=1

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
dir /b /ad "app"
color 0B
echo ----------------------------------------------------------------------
echo.
echo Starting automatic process...
echo.

for /f %%T in ('dir /b /ad "app"') do (
    set /a DONE+=1
    set "ID=%%T"
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
        if exist "!OUT!" (
            echo [CLEANUP] Previous temporary folder removed.
            rd /s /q "!OUT!"
        )

        echo [STEP 1] Creating final folder
        mkdir "!OUT!"

        echo [STEP 1.1] Copying base game
        xcopy "app\\%%T" "!OUT!\\app\\%%T" /E /I /H /R /Y >nul

        if exist "patch\\%%T" (
            echo [STEP 1.2] Merging update
            xcopy "patch\\%%T" "!OUT!\\app\\%%T" /E /I /H /R /Y >nul
            echo [OK] Update completed.
        ) else (
            echo [INFO] No update found.
        )

        if exist "addcont\\%%T" (
            echo [STEP 1.3] Copying DLC
            xcopy "addcont\\%%T" "!OUT!\\addcont\\%%T" /E /I /H /R /Y >nul
            echo [OK] DLC completed.
        ) else (
            echo [INFO] No DLC found.
        )

        if exist "!OUT!\\app\\%%T" (
            echo [OK] Merge completed successfully.
        ) else (
            color 0C
            echo [ERROR] Final structure is invalid.
            color 0A
        )

        echo [STEP 2] ZIP compression
        echo [FILE] !ZIPNAME!
        echo [WAIT] Large games may take some time...

        powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '!OUT!\\*' -DestinationPath '!ZIPNAME!' -Force"

        if exist "!ZIPNAME!" (
            echo [OK] ZIP created successfully.
            echo [CLEANUP] Removing temporary folder !OUT!
            rd /s /q "!OUT!"
            set /a ZIP_OK+=1
        ) else (
            color 0C
            echo [ERROR] ZIP was not created.
            color 0A
            echo [INFO] Temporary folder kept for safety.
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

if %ZIP_FAIL% GTR 0 (
    color 0C
    echo ZIP files failed  : %ZIP_FAIL%
    color 0A
) else (
    echo ZIP files failed  : %ZIP_FAIL%
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
