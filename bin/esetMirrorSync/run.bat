::%windir%\system32\cmd.exe
@echo off

set mirrorTool=MirrorTool.exe
set mirrorPath=%~dp0

call :getFormatTime
set currentDate=%getFormatTime%
set mirrorLogDir=%~dp0\logs
set mirrorLogFile=%mirrorLogDir%\%currentDate%.log

set updateModule=False
set updateRepository=False
::--------------------------------------------

::ESET数据存放目录
set esetDate=d:\ESET_Date

::自动选择服务器
set downServer=--repositoryServer AUTOSELECT
::存储库临时目录
set repositoryTempPath=--intermediateRepositoryDirectory %esetDate%\repositoryTemp
::存储库路径
set repositoryPath=--outputRepositoryDirectory %esetDate%\repository

::指定语言
set language=--languageFilterForRepository zh_CN en_US
::指定关键字
set keyWord=--productFilterForRepository Antivirus File Management

::----------------------------------------------

::病毒库类型 [regular | pre-release | delayed}
set moduleType=--mirrorType regular
::病毒库临时目录
set moduleTempPath=--intermediateUpdateDirectory %esetDate%\moduleTemp
::病毒库目录
set modulePath=--outputDirectory %esetDate%\module
::离线许可文件
set licenseFileName=mirrorTool-esetfilesecurityformicrosoftwindowsserver-0.lf
set offLicense=--offlineLicenseFilename %mirrorPath%\%licenseFileName%

::---------------------------

if "%1" == "" (
  call :getArgs --help
  echo Press any key to exit.
  pause>nul
) else (
  call :getArgs %*
)

if %exitCode% gtr 0 exit /b %exitCode%

(echo u >%windir%\u.tmp)2>nul
if not exist %windir%\u.tmp (
  echo This script must be run as Administrator 1>&2
  exit /b 1
) else (
  del /f %windir%\u.tmp 2>nul
)

echo\
echo Synchronizing ESET installation files
echo\

::---------begin------------
::创建日志目录
if not exist %mirrorLogDir% (
  mkdir %mirrorLogDir%
)

if exist %mirrorPath%\%mirrorTool% (
  call :syncStart
) else (
  echo [%mirrorTool%] cannot be found. | tee -a %mirrorLogFile%
)

echo -----------%date%---------------|tee -a %mirrorLogFile%
exit /b 0

::-----func--------

::获取时间
:getFormatTime
set getFormatTime=%date:~,10%_%time%
set getFormatTime=%getFormatTime:/=%
set getFormatTime=%getFormatTime:-=%
set getFormatTime=%getFormatTime: =%
set getFormatTime=%getFormatTime::=%
set getFormatTime=%getFormatTime:.=%
goto :eof

:printUsage
echo  Usage: %~nx0 [options]
echo\
echo  -h, --help              [optional] print this help message
echo  -m, --module            [optional] Update virus library
echo  -r, --repository        [optional] Synchronize repositories  
echo\
echo              ESET NOD32 2020-03-19 , Yao
goto :eof

:syncStart
if %updateModule% == True (
  %mirrorPath%\%mirrorTool% %moduleType% %moduleTempPath% %modulePath% %offLicense% | tee -a %mirrorLogFile%
)

if %updateRepository% == True (
  %mirrorPath%\%mirrorTool% %downServer% %repositoryTempPath% %repositoryPath% %language% %keyWord% | tee -a %mirrorLogFile%
)
goto :eof

:getArgs
::退出码 0 = 正常, 1 = 错误退出, 2 = 正常退出
set exitCode=0
:loop
if "%1" == "" goto :getArgsBreak
if "%1" == "-h" (
  call :printUsage
  set exitCode=2
  goto :eof
) else (
  if "%1" == "--help" (
      call :printUsage
      set exitCode=2
      goto :eof
  )
)

if "%1" == "-m" (
  set updateModule=True
) else (
  if "%1" == "--module" (
      set updateModule=True
  )
)

if "%1" == "-r" (
  set updateRepository=True
) else (
  if "%1" == "--repository" (
      set updateRepository=True
  )
)
if "%updateModule%" == "False" (
  if "%updateRepository%" == "False" (
    echo Unknown option "%1". Run '%~nx0 --help' for usage information. >&2
    set exitCode=1
    goto :eof
  )
)
shift
goto :loop
:getArgsBreak
goto :eof

::-----func-------
