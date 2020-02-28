@echo off
md "%~dp0$testAdmin$" 2>nul
if not exist "%~dp0$testAdmin$" (
    echo RSM没有对其所在目录的写入权限！ >&2
    exit /b 1
) else rd "%~dp0$testAdmin$"
setlocal enabledelayedexpansion
cd %~dp0%
set command=%1
if /i "%command%"=="" (    
    echo 不能输入空指令^^！
    echo ===========================================================================
    echo Rain Software Manager 1.0 ^(C^) 2019 Rain Lab 保留所有权利。
    echo 开发者列表：Rain
    echo ===========================================================================
    echo 使用方法：
    echo 安装包：rsm install[包名称]
    echo 查找包：rsm find[包名称]
    echo 卸载包：rsm remove[package name]
    echo 获取本地软件列表：rsm list
    echo 获取服务器端软件列表：rsm listline
    echo 覆盖安装包：rsm finstall[包名称]
    echo 查看包信息：rsm info[包名称]
    echo 帮助：rsm help
    echo ===========================================================================
    endlocal&exit /b 1
)
if /i "%command%"=="help" (    
    echo ===========================================================================
    echo Rain Software Manager 1.0 ^(C^) 2019 Rain Lab 保留所有权利。
    echo 开发者列表：Rain
    echo ===========================================================================
    echo 使用方法：
    echo 安装包：rsm install[包名称]
    echo 查找包：rsm find[包名称]
    echo 卸载包：rsm remove[package name]
    echo 获取本地软件列表：rsm list
    echo 获取服务器端软件列表：rsm listline
    echo 覆盖安装包：rsm finstall[包名称]
    echo 查看包信息：rsm info[包名称]
    echo 帮助：rsm help
    echo ===========================================================================
    goto exit
)
if /i "%command%"=="find" (    
    if /i "%2"=="" (    
    echo 参数不能为空^^! >&2
    endlocal&exit /b 1
)
    bin\wget -q -O lib\list.ini http://rainlab.synology.me:55/list.ini||goto error1
    (for /f "tokens=2,3,4 delims=~" %%i in (lib\list.ini) do (
    echo=%%i^~%%j^~%%k
    ))>temp.txt
    (for /f "tokens=1,2,3 delims=~" %%i in ('findstr /i /C:%2 temp.txt 2^>nul')do (
    echo=%%i^~%%j^~%%k
    )
    )>temp1.txt
    for /f "tokens=1,2,3 delims=~" %%i in (temp1.txt) do (
    echo 名称：%%i          版本：%%j          标签：%%k>>temp4.txt
    )
    echo=>>temp4.txt
    type temp4.txt|more
    echo ----No More----
    del temp1.txt;temp.txt;temp4.txt>nul 2>nul
    goto exit
)

if /i "%command%"=="listonline" ( 
    bin\wget -q -O lib\list.ini http://rainlab.synology.me:55/list.ini   
    for /f "tokens=2,3,4 delims=~" %%i in (lib\list.ini) do (
    echo 名称：%%i          版本：%%j          标签：%%k>>temp.txt
    )
    type temp.txt|more
    del temp.txt
    goto exit
)

if /i "%command%"=="install" (
    if /i "%2"=="" (    
    echo 参数不能为空^^! >&2
    endlocal&exit /b 1
)
    set va=%2
    if exist programs\%2 goto error2
    for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set va=!!va:%%i=%%i!!
    bin\wget -t3 -q -O temp\%2.rar http://rainlab.synology.me:55/!va!.rsm||goto error1
    echo 下载 %2 中……
    md programs\%2>nul 2>nul
    bin\rar x -o+ -idcdp -inul temp\%2.rar programs\%2
    bin\mkshortcut.exe programs\%2\%2
    move programs\%2\%2.lnk %USERPROFILE%\desktop>nul 2>nul 
    del temp\%2.rar
    if exist programs\%2\install.cmd cmd /c start /w /min programs\%2\install.cmd&&del programs\%2\install.cmd
    echo 安装 %2 成功！
    goto exit
    )

    if /i "%command%"=="finstall" (
    if /i "%2"=="" (    
    echo 参数不能为空^^! >&2
    endlocal&exit /b 1
)
    set va=%2
    for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set va=!!va:%%i=%%i!!
    bin\wget -t3 -q -O temp\%2.rar http://rainlab.synology.me:55/!va!.rsm||goto error1
    echo 下载 %2 中……
    md programs\%2>nul 2>nul
    bin\rar x -o+ -idcdp -inul temp\%2.rar programs\%2
    bin\mkshortcut.exe programs\%2\%2
    move programs\%2\%2.lnk %USERPROFILE%\desktop>nul 2>nul 
    del temp\%2.rar
    if exist programs\%2\install.cmd call programs\%2\install.cmd&&del programs\%2\install.cmd
    echo 安装 %2 成功
    goto exit
    )

if /i "%command%"=="remove" (   
    if /i "%2"=="" (    
    echo 参数不能为空^^! >&2
    endlocal&exit /b 1
)
    if exist programs\%2\remove.cmd call programs\%2\remove.cmd
    ping -n 2 127.0.0.1>nul
    del /s /a /q programs\%2\*.*>nul 2>nul||goto error3
    rd /s /q programs\%2\||goto error3
    del %USERPROFILE%\desktop\%2.lnk||goto error3
    echo 卸载 %2 成功
    goto exit
)

if /i "%command%"=="list" ( 
    dir/b/on programs
    echo ----No More----
    goto exit
)

if /i "%command%"=="info" ( 
    if /i "%2"=="" (    
    echo 参数不能为空^^! >&2
    endlocal&exit /b 1
)
    if not exist programs\%2\info.ini goto error4
    for /f "tokens=1,2" %%i in (programs\%2\info.ini) do (
    echo=名称：%%i    版本：%%j
    )
    goto exit
)

:error
echo 请输入正确的命令^^！
bin\setx.exe errorcode 1>nul 2>nul
endlocal&exit /b 1

:error1
del temp\%2.rar
echo 下载失败。请检查软件是否存在或网络是否连接。
endlocal&exit /b 1

:error2
echo 软件已存在。如果需要覆盖安装，请使用finstall。
endlocal&exit /b 1  

:error3
echo 软件不存在。
endlocal&exit /b 1

:error4
echo 没有软件的安装信息。
endlocal&exit /b 1

:exit
endlocal&exit /b 0