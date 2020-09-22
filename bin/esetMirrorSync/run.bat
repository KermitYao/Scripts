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

::ESET���ݴ��Ŀ¼
set esetDate=d:\ESET_Date

::�Զ�ѡ�������
set downServer=--repositoryServer AUTOSELECT
::�洢����ʱĿ¼
set repositoryTempPath=--intermediateRepositoryDirectory %esetDate%\repositoryTemp
::�洢��·��
set repositoryPath=--outputRepositoryDirectory %esetDate%\repository

::ָ������
set language=--languageFilterForRepository zh_CN en_US
::ָ���ؼ���
set keyWord=--productFilterForRepository Antivirus File Management

::----------------------------------------------

::���������� [regular | pre-release | delayed}
set moduleType=--mirrorType regular
::��������ʱĿ¼
set moduleTempPath=--intermediateUpdateDirectory %esetDate%\moduleTemp
::������Ŀ¼
set modulePath=--outputDirectory %esetDate%\module
::��������ļ�
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
::������־Ŀ¼
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

::��ȡʱ��
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
::�˳��� 0 = ����, 1 = �����˳�, 2 = �����˳�
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
