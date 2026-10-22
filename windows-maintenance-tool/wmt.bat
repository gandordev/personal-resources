@echo off

title Mantenimiento Automatico Windows 11
color 0A

echo.
echo ========================================
echo    MANTENIMIENTO AUTOMATICO WINDOWS 11
echo ========================================
echo.

:: Executing as admin
::                                         net session >nul 2>&1
::                                         if %errorLevel% neq 0 (
::                                             echo Es necesario ejecutar con permisos de administrador.
::                                             echo Se va a cerrar el programa.
::                                             pause
::                                             exit /b 1
::                                         )

:: Complete scan
is_complete_scan=0

:: Main menu
:menu
    cls
    echo ========================================
    echo    MANTENIMIENTO AUTOMATICO WINDOWS 11
    echo ========================================
    echo.
    echo 1. Mantenimiento completo (recomendado)
    echo 2. Mantenimiento de seguridad
    echo 3. Mantenimiento de rendimiento
    echo 4. Limpieza de disco
    echo 5. Diagnostico del sistema
    echo 6. Actualizar software
    echo 7. Salir
    echo.
    set /p choice="Selecciona una opcion (1-7): "

    if %choice%==1 (
        set is_complete_scan=1
        goto completo
    )
    set is_complete_scan=0
    if %choice%==2 goto security
    if %choice%==3 goto performance
    if %choice%==4 goto cleanup
    if %choice%==5 goto diagnosis
    if %choice%==6 goto update
    if %choice%==7 exit
    goto menu

:: Complete scan
:completo
    echo.
    goto security
    goto performance
    goto cleanup
    goto diagnosis
    goto update
    echo.
    pause
    goto menu

:: Restart
:restart
    :: TODO


:: Security scan
:security
    echo.
    echo [1/4] Actualizando definiciones de Windows Defender...
    powershell -Command "Update-MpSignature" 2>&1 >nul
    if %errorLevel% equ 0 (echo Definiciones actualizadas) else echo Error al actualizar

    echo [2/4] Escaneo rapido de seguridad...
    powershell -Command "Start-MpScan -ScanType QuickScan" 2>&1 >nul
    echo Escaneo iniciado (se ejecuta en segundo plano)

    echo [3/4] Verificando estado del firewall...
    echo.
    powershell -Command "Get-NetFirewallProfile | Format-Table Name, Enabled -AutoSize"

    echo [4/4] Comprobando estado de seguridad...
    echo.
    powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled, AntispywareEnabled, RealTimeProtectionEnabled, LastQuickScanTime | Format-Table -AutoSize"

    echo.
    echo Mantenimiento de seguridad finalizado!
    echo.
    if %is_complete_scan% neq 1 (
        pause
        goto menu)


:: Performance scan
:performance
    echo.
    echo [1/71] Optimizando memoria del sistema...
    fsutil behavior set memoryusage 2 >nul 2>&1
    if %errorLevel% equ 0 (echo Memoria optimizada) else echo Error optimizando memoria

    echo [2/7] Ajustando temporizadores del sistema...
    bcdedit /set useplatformtick yes >nul 2>&1
    bcdedit /set disabledynamictick yes >nul 2>&1
    echo Temporizadores ajustados (puede requerir reinicio)

    echo [3/7] Optimizando unidad C...
    powershell -Command "Optimize-Volume -DriveLetter C -ReTrim -Verbose" 2>&1 >nul
    if %errorLevel% equ 0 (echo Unidad optimizada) else echo Error optimizando

    echo [4/7] Limpiando archivos temporales...
    del /q /f /s %temp%\* >nul 2>&1
    del /q /f /s C:\Windows\Temp\* >nul 2>&1
    echo Archivos temporales eliminados

    echo [5/7] Limpiando actualizaciones temporales...
    DISM /Online /Cleanup-Image /StartComponentCleanup /NoRestart
    if %errorLevel% equ 0 (echo Limpieza DISM completada) else echo Error en DISM

    echo [6/7] Reparando imagen de Windows...
    DISM /Online /Cleanup-Image /RestoreHealth /NoRestart
    if %errorLevel% equ 0 (echo Reparacion completada) else echo Error en reparacion

    echo [7/7] Verificando procesos con alto consumo...
    echo.
    echo Procesos con mayor uso de CPU:
    powershell -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 -Property Name, CPU, WorkingSet | Format-Table -AutoSize"

    echo.
    echo Mantenimiento de rendimiento finalizado!
    echo.
    if %is_complete_scan% neq 1 (
        pause
        goto menu)


:: Disk cleaning
:cleanup
    echo.
    echo [1/3] Limpieza basica de disco...
    start /wait cleanmgr /sagerun:1
    if %errorLevel% equ 0 (echo Limpieza completada) else echo Error en limpieza

    echo [2/3] Limpieza avanzada de actualizaciones...
    DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase /NoRestart
    if %errorLevel% equ 0 (echo Limpieza DISM completada) else echo Error en DISM

    echo [3/3] Liberando espacio temporal...
    del /q /f /s %temp%\* >nul 2>&1
    del /q /f /s C:\Windows\Temp\* >nul 2>&1
    echo Archivos temporales eliminados

    echo.
    echo Limpieza de disco finalizada!
    echo.
    if %is_complete_scan% neq 1 (
        pause
        goto menu)


:: System diagnosis
:diagnosis
    echo.
    echo [1/5] Verificando integridad de archivos del sistema...
    sfc /scannow
    if %errorLevel% equ 0 (echo Verificacion completada) else echo Error en verificacion

    echo [2/5] Comprobando salud de la imagen de Windows...
    DISM /Online /Cleanup-Image /CheckHealth
    if %errorLevel% equ 0 (echo Salud verificada) else echo Error en verificacion

    echo [3/5] Verificando disco duro...
    chkdsk C: /scan
    if %errorLevel% equ 0 (echo Disco verificado) else echo Error en verificacion

    echo [4/5] Informacion del sistema...
    echo.
    systeminfo | findstr /C:"Nombre del sistema" /C:"Memoria fisica" /C:"Espacio en disco"

    echo [5/5] Estado de la memoria...
    echo.
    powershell -Command "$mem = Get-Counter '\Memoria\Bytes disponibles'; $memMB = [math]::Round($mem.CounterSamples.CookedValue / 1MB, 2); Write-Host 'Memoria disponible: ' $memMB 'MB'"

    echo.
    echo Diagnostico del sistema finalizado!
    echo.
    if %is_complete_scan% neq 1 (
        pause
        goto menu)


:: Update software
:update
    echo.
    echo [1/3] Buscando Winget...
    where winget >nul 2>&1
    if %errorLevel% equ 0 (
        echo Actualizando aplicaciones con Winget...
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
        if %errorLevel% equ 0 (echo Winget actualizado) else echo Error con Winget
    ) else (
        echo [i] Winget no esta disponible. Instalalo desde Microsoft Store.
    )

    echo [2/3] Verificando actualizaciones de Windows...
    echo.
    powershell -Command "$session = New-Object -ComObject Microsoft.Update.Session; $searcher = $session.CreateUpdateSearcher(); $result = $searcher.Search('IsInstalled=0'); Write-Host 'Actualizaciones pendientes: ' $result.Updates.Count"

    echo [3/3] Actualizando definiciones de seguridad...
    powershell -Command "Update-MpSignature" 2>&1 >nul
    if %errorLevel% equ 0 (echo Definiciones actualizadas) else echo Error al actualizar

    echo.
    echo Actualizacion de software finalizada!
    echo.
    if %is_complete_scan% neq 1 (
        pause
        goto menu)
