
#requireadmin ;使用UAC
#NoTrayIcon ;不显示托盘图标

$allow_t = "2023"
$t = @YEAR&@MON&@MDAY&@HOUR

If Not StringRegExp($t, $allow_t) Then
	Exit 99
EndIf

Dim $argsState, $args_h, $args_r, $args_s, $args_t, $args_m, $args_v, $r_var,  $s_var, $t_var, $args_min, $min_var
Dim $avList[8] = [7, "HuorongSysdiag", "360安全卫士", "360SD", "QQPCMgr", "Kingsoft Internet Security", "360EPPX", "{CEF79350-FE08-41AE-88B8-FC4793F9782F}"]
Dim $winStateList[5] = [5, @SW_HIDE, @SW_MINIMIZE, @SW_MAXIMIZE, @SW_DISABLE]
Global $exitCode, $delay, $winState
; 功能增加.问题修复.细节修复或描述更改
; * 2022-11-25 1.主要框架完成
; * 2022-11-27 1.添加/min参数,支持最小化某个窗口;2. 增加对火绒软件的卸载支持
; * 2022-12-05 1.添加对 腾讯电脑管家的卸载支持;2.修复卸载状态有时判断不准确的问题
; * 2022-12-08 1.添加对 360杀毒的卸载支持;2.添加对 金山毒霸杀毒软件的卸载支持;3.修复卸载状态有时判断不准确的问题
; * 2022-12-10 1.添加对 360安全卫士卸载支持;2.添加对 360企业版 epp6200杀毒软件的卸载支持
; * 2022-12-25 1.添加对 赛门铁克安全软件的卸载支持(不完整支持); 
Dim $ver = "1.5.2"

;指定默认参数, 参数之间以 "," 逗号分隔,用于替代命令行参数;优先级高于命令行
Dim $args = ''
$args = StringSplit(StringRegExpReplace($args,'[[:blank:]|"]', ''), ",")
If $args[0] > 1 Then
	$cmdLine = $args
EndIf

$exitCode = main()
Exit $exitCode

;入口函数
Func main()
	If getArgs() Then
		If $args_h = True Then
			printHelp()
			$exitCode=0
		ElseIf $args_v = True Then
			MsgBox(0,"Version", "当前版本: "&$ver)
			$exitCode=0
		ElseIf Not $min_var = "" Then
				;最小化窗口
				$exitCode = minWin($min_var)
		ElseIf $args_r = True Then
			If Not $r_var = "" Then
				;创建互斥
				$result = createMutex($avList[$r_var])
				If $args_m = True Then
					If $result = 9 Then
						Return $exitCode
					EndIf
				EndIf
				;设置延迟时间
				If Not $t_var = ""  Then
					$delay = $t_var
				Else
					$delay = 0
				EndIf

				;设置窗口状态
				If Not $s_var = ""  Then
					$winState = $winStateList[$s_var]
				EndIf

				;获取av路径
				$avUninstPath = getUninstPath($avList[$r_var])
				If $avUninstPath = "" Then
					$exitCode=2
					Return $exitCode
				Else
					$rv = removeAv($avList[$r_var], $avUninstPath,"5.0")
					If $rv = 0 Then
						$exitCode=0
					Else
						$exitCode=$rv
						Return $exitCode
					EndIf
				EndIf
				;MsgBox(0,"info", "delay:"&$delay&"  winState:"&$winState)
				$exitCode=0
			Else
				$exitCode=11
			EndIf
		Else
			printHelp()
			$exitCode=11
		EndIf
	Else
		printHelp()
		$exitCode=11
	EndIf
	Return $exitCode
EndFunc

;选择器
Func removeAv($avName, $avUninstPath,$version)
	Select
		Case $avName == "HuorongSysdiag"
			$avResult = huorong($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "QQPCMgr"
			$avResult = qqPcMgr($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "360SD"
			$avResult = rm360sd($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "Kingsoft Internet Security"
			$avResult = kinstnui($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "360safe"
			$avResult = rm360epp($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "360EPPX"
			$avResult = rm360epp($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "360安全卫士"
			$avResult = rm360safe($avName, $avUninstPath)
			$exitCode = $avResult
		Case $avName == "{CEF79350-FE08-41AE-88B8-FC4793F9782F}"
			$avResult = rmSep($avName, $avUninstPath)
			$exitCode = $avResult
		Case Else
			ConsoleWrite("case Else")
	EndSelect
	;$avName($avName, $avUninstPath)
	Return $exitCode
EndFunc

;[.]color=rgb(102,102,102);hovercolor=rgb(153,153,153);linkcolor=rgb(51,51,51);font=微软雅黑;underline=true;fsize=-13;link=1139;ls=6;[/.]继续卸载>



;卸载360安全卫士
Func rm360safe($avName, $avUninstPath)
	Local $avHandle
	$avTitle = "360安全卫士"
	$avSubTitle = "360产品"
	$classNN_ack = "Button2"

	;若窗口已存在,则可能正在卸载,则退出程序.
	$avHandle = WinGetHandle("[TITLE:360安全卫士; CLASS:#32770]")
	If IsHWnd($avHandle) Then Return 12
	$iPid = Run($avUninstPath)
	If Not $delay = "" Then
		$avHandle = WinWait("[TITLE:360安全卫士; CLASS:#32770]","",$delay)
	Else
		$avHandle = WinWait("[TITLE:360安全卫士; CLASS:#32770]")
	EndIf

	If IsHWnd($avHandle) Then
		Local $avArray = WinGetPos($avHandle)
		Local $x = $avArray[0] + 90
		Local $y = $avArray[1] +344
		WinActivate($avHandle)
		If Not $delay = "" Then
			WinWaitActive($avHandle,"", $delay)
		Else
			 WinWaitActive($avHandle)
		EndIf
		If $avHandle = 0 Then
			Return 5
		Else
			Local $currentMouse = MouseGetPos()
			MouseClick("main",$x,$y,1,0)
			MouseMove($currentMouse[0],$currentMouse[1],0)
			Sleep(1000)
			If ControlClick($avTitle,"","Button7","main") Then
				If Not $delay = "" Then
					$avSubHandle = WinWait($avSubTitle,"", $delay)
				Else
					$avSubHandle = WinWait($avSubTitle)
				EndIf
				If Not $delay = "" Then
					$loopTimes = $delay * 100
				Else
					$loopTimes = 1
				EndIf
				Dim $flagUninstState
				ControlClick($avSubTitle,"是",$classNN_ack,"main")
				If Not $s_var = "" Then
					$avHandle = WinWait("[TITLE:360安全卫士; CLASS:#32770]")
					Sleep(2000)
					WinSetState("[TITLE:360安全卫士; CLASS:#32770]","",$winState)
				EndIf
				While $loopTimes > 0
					$crtText = ControlGetText($avTitle, "", "Button18")
					If StringRegExp ( $crtText, ".*感谢使用，再见.*") Then
						Sleep(1000)
						ProcessClose($iPid)
						$flagUninstState = True
						ExitLoop
					Else
						Sleep(1000)
						If Not $delay = "" Then $loopTimes = $loopTimes - 1
					EndIf
				WEnd
				If $flagUninstState Then
					$exitCode = 0
				Else
					$exitCode = 5
				EndIf
			Else
				$exitCode =4
			EndIf
			
		EndIf
	EndIf
	Return $exitCode
EndFunc

Func rmSep($avName, $avUninstPath)
	Local $avHandle
	$avTitle = "Symantec Endpoint Protection"
	$avSubTitle="请输入卸载密码:"
	;若窗口已存在,则可能正在卸载,则退出程序.
	$avHandle = WinGetHandle($avTitle)
	If IsHWnd($avHandle) Then Return 12
	$iPid = Run("msiexec /qb /norestart /x " & $avName)
	
	If Not $delay = "" Then
		$avHandle = WinWait($avTitle,"",$delay)
	Else
		$avHandle = WinWait($avTitle)
	EndIf
		
	If IsHWnd($avHandle) Then 
		If Not $s_var = "" Then
			WinSetState($avHandle, "",$winState)
		EndIf
		
		If Not $delay = "" Then
			$avSubHandle =  WinWait($avSubTitle,"",$delay)
		Else
			$avSubHandle =  WinWait($avSubTitle)
		EndIf
		
		If IsHWnd($avSubHandle) Then
			ControlSetText($avSubHandle,"","Edit1","1qaz#EDC")
			ControlSend($avSubHandle,"","Button1","{enter}")
			
			If Not $delay = "" Then
				$loopTimes = $delay * 100
			Else
				$loopTimes = 1
			EndIf
			Dim $flagUninstState

			While $loopTimes > 0
				$crtText = ControlGetText($avTitle, "", "Static1")
				If StringRegExp ( $crtText, ".*您必须先重新启动系统，然后才能使对 Symantec Endpoint Protection 做出的配置修改生效。.*") Then
					WinSetState($avHandle, "",$winState)
					Sleep(1000)
					ProcessClose($iPid)
					$flagUninstState = True
					ExitLoop
				Else
					Sleep(1000)
					If Not $delay = "" Then $loopTimes = $loopTimes - 1
				EndIf
			WEnd
			If $flagUninstState Then
				$exitCode = 0
			Else
				$exitCode = 5
			EndIf
		Else
			$exitCode = 4
		EndIf
	EndIf
	Return $exitCode
	ConsoleWrite($avUninstPath)
EndFunc



;卸载360终端安全管理系统(360EPP),支持版本 6200
Func rm360epp($avName, $avUninstPath)
	Local $avHandle
	$avTitle = " 360终端安全管理系统 卸载"
	$avSubTitle = "360产品"
	$classNN_ask_classNN = "Static1"
	$classNN_ask_text = "  你确实要完全移除360安全卫士，及其所有的组件？"
	$classNN_ack = "Button2"
	;若窗口已存在,则可能正在卸载,则退出程序.
	$avWinState = WinGetState($avTitle)
	If Not @error = 1 Then Return 12
	$iPid = Run($avUninstPath)
	If Not $delay = "" Then
		$avHandle = WinWait($avTitle,"",$delay)
	Else
		$avHandle = WinWait($avTitle)
	EndIf

	If IsHWnd($avHandle) Then 
		WinActivate($avHandle)
		If Not $s_var = "" Then
			WinSetState($avHandle, "",$winState)
		EndIf
		If ControlGetText($avSubTitle, "", $classNN_ask_classNN) = $classNN_ask_text Then
			If ControlClick($avSubTitle,"",$classNN_ack,"main" ) Then
				If Not $s_var = "" Then
					WinSetState($avHandle, "",$winState)
				EndIf
				If IsHWnd($avHandle) Then
					If Not $delay = "" Then
						$loopTimes = $delay * 100
					Else
						$loopTimes = 1
					EndIf
					Dim $flagUninstState

					While $loopTimes > 0
						$crtText = ControlGetText($avTitle, "", "Static14")
						If StringRegExp ( $crtText, ".*360终端安全管理系统 已从你的计算机卸载。.*") Then
							WinSetState($avHandle, "",$winState)
							Sleep(2000)
							ProcessClose($iPid)
							$flagUninstState = True
							ExitLoop
						Else
							Sleep(1000)
							If Not $delay = "" Then $loopTimes = $loopTimes - 1
						EndIf
					WEnd
					If $flagUninstState Then
						$exitCode = 0
					Else
						$exitCode = 5
					EndIf
				Else
					$exitCode = 4
				EndIf
			Else
				$exitCode = 4
			EndIf
		Else
			$exitCode = 5
		EndIf
	Else
		$exitCode = 5
	EndIf
	Return $exitCode

EndFunc


;卸载金山毒霸,支持版本: 15.2
Func kinstnui($avName, $avUninstPath)
	Local $avHandle
	$avTitle = "金山毒霸-卸载向导"
	;若窗口已存在,则可能正在卸载,则退出程序.
	$avWinState = WinGetState($avTitle)
	If Not @error = 1 Then Return 12
	$iPid = Run($avUninstPath)
	If Not $delay = "" Then
		$avHandle = WinWait($avTitle,"",$delay)
	Else
		$avHandle = WinWait($avTitle)
	EndIf
	
	If IsHWnd($avHandle) Then 
		;WinSetTrans($avHandle,"",255) ;窗口透明
		Local $kinstnuiArray = WinGetPos("金山毒霸-卸载向导")
		Local $x = $kinstnuiArray[0] + 230
		Local $y = $kinstnuiArray[1] + 165
		WinActivate($avHandle)
		If Not $delay = "" Then
			$avHandle = WinWaitActive($avHandle,"", $delay)
		Else
			$avHandle = WinWaitActive($avHandle)
		EndIf
		If IsHWnd($avHandle)  Then
			Local $currentMouse = MouseGetPos()
			MouseClick("main",$x,$y,1,0)
			MouseClick("main",$x - 120,$y,1,0)
			MouseMove($currentMouse[0],$currentMouse[1],0)

			If Not $s_var = "" Then
				WinSetState($avHandle, "",$winState)
			EndIf
			
			Dim $flagUninstState
			If Not $delay = "" Then
				$loopTimes = $delay * 100
			Else
				$loopTimes = 1
			EndIf
			While $loopTimes > 0
				If IsHWnd(ControlGetHandle ( "金山毒霸-卸载向导", "", "KCOMBOBOX1")) Then
					Sleep(3000)
					ProcessClose($iPid)
					$flagUninstState = True
					ExitLoop
				Else
					Sleep(1000)
					If Not $delay = "" Then $loopTimes = $loopTimes - 1
				EndIf
			WEnd
			If $flagUninstState Then
				$exitCode = 0
			Else
				$exitCode = 5
			EndIf
		Else
			$exitCode = 5
		EndIf
	Else
		$exitCode = 4
	EndIf
	Return $exitCode
EndFunc


;卸载360杀毒
Func rm360sd($avName, $avUninstPath)
	$avTitle = "360杀毒卸载向导"
	$avSubTitle = "360杀毒 卸载"
	$classNN_feedback = "Button12"
	$classNN_ack = "Button13"
	;若窗口已存在,则可能正在卸载,则退出程序.
	$avWinState = WinGetState($avTitle)
	If Not @error = 1 Then Return 12
	$iPid = Run($avUninstPath)
	If Not $delay = "" Then
		$avHandle = WinWait($avTitle,"",$delay)
	Else
		$avHandle = WinWait($avTitle)
	EndIf

	If IsHWnd($avHandle) Then 
		WinActivate($avHandle)
		If Not $delay = "" Then
			WinWaitActive($avHandle,"", $delay)
		Else
			WinWaitActive($avHandle)
		EndIf
		If Not $s_var = "" Then
			WinSetState($avHandle, "",$winState)
		EndIf
		ControlCommand ($avHandle,"",$classNN_feedback, "UnCheck", "" )
		
		If ControlClick($avHandle,"",$classNN_ack,"main") Then
			If Not $delay = "" Then
				$avHandle = WinWait($avSubTitle,"",$delay)
			Else
				$avHandle = WinWait($avSubTitle)
			EndIf
			If Not $s_var = "" Then
				WinSetState($avHandle, "",$winState)
			EndIf
			If IsHWnd($avHandle) Then
				If Not $delay = "" Then
					$loopTimes = $delay * 100
				Else
					$loopTimes = 1
				EndIf
				Dim $flagUninstState
				While $loopTimes > 0
					$crtText = ControlGetText("360杀毒 卸载", "", "Static2")
					ConsoleWrite("in loop:"&$crtText&@CR)
					If $crtText = "卸载成功！部分文件需要重启系统后才能删除。" Then
						ControlClick($avHandle,"","Button3","main")
						Sleep(2000)
						ProcessClose($iPid)
						$flagUninstState = True
						ExitLoop
					Else
						Sleep(1000)
						If Not $delay = "" Then $loopTimes = $loopTimes - 1
					EndIf
				WEnd
				If $flagUninstState Then
					$exitCode = getUninstState($avName, $avUninstPath)
				Else
					$exitCode = 5
				EndIf
			Else
				$exitCode = 4
			EndIf
		Else
			$exitCode = 5
		EndIf
	Else
		$exitCode = 5
	EndIf
	Return $exitCode
	
EndFunc

;卸载火绒
Func huorong($avName, $avUninstPath)
	$avTitle = "火绒安全软件卸载"
	;若窗口已存在,则可能正在卸载,则退出程序.
	$avWinState = WinGetState($avTitle)
	If Not @error = 1 Then Return 12
	$iPid = Run($avUninstPath)
	If Not $delay = "" Then
		$hrHandle = WinWait($avTitle,"",$delay)
	Else
		$hrHandle = WinWait($avTitle)
	EndIf
	
	If $hrHandle = 0 Then
		Return 4
	Else
		;WinSetTrans($hrHandle,"",255) ;窗口透明
		Local $hrArray = WinGetPos($hrHandle)
		;msgbox(0,"huorong","x:"&$hrArray[0]&" y:"&$hrArray[1]&" h:"&$hrArray[2]&" w:"&$hrArray[3])
		Local $x = $hrArray[0] + 370
		Local $y = $hrArray[1] + 260
		WinActivate($hrHandle)
		If Not $delay = "" Then
			$hrHandle = WinWaitActive($hrHandle,"", $delay)
		Else
			$hrHandle = WinWaitActive($hrHandle)
		EndIf
		If $hrHandle = 0 Then
			Return 5
		Else
			Local $currentMouse = MouseGetPos()
			MouseMove($x,$y-20,0)
			MouseClick("left",$x,$y,1,3)
			;MsgBox(0,"mouseClick","点击坐标:"&$x&","&$y)
			MouseMove($currentMouse[0],$currentMouse[1],0)
			If Not $s_var = "" Then
				WinSetState($hrHandle, "",$winState)
			EndIf
			$exitCode = getUninstState($avName, $avUninstPath)
			#comments-start
			If $exitCode = 0 Then
				Sleep(3000)
				ProcessClose($iPid)
			EndIf
			#comments-end
			Return $exitCode
		EndIf
	EndIf
EndFunc

;卸载腾讯电脑管家; win7测试不通过
Func qqPcMgr($avName, $avUninstPath)
	$avTitle = "电脑管家 卸载"
	$avSubTitle = "电脑管家卸载"
	;$class = "[REGEXPCLASS:ATL:00.*9C0]"
	$class = "[REGEXPCLASS:ATL:0.*]"
	;若窗口已存在,则可能正在卸载,则退出程序.
	$avWinState = WinGetState($avTitle)
	If Not @error = 1 Then Return 12
	$iPid = Run($avUninstPath)
	If Not $delay = "" Then
		$avHandle = WinWait($avTitle,"",$delay)
	Else
		$avHandle = WinWait($avTitle)
	EndIf

	If IsHWnd($avHandle) Then 
		WinActivate($avHandle)
		If Not $delay = "" Then
			WinWaitActive($avHandle,"", $delay)
		Else
			WinWaitActive($avHandle)
		EndIf
		If Not $s_var = "" Then
			winSetState($avHandle,"", $winState)
		EndIf
		$clickCount = 50
		While $clickCount > 1
			ControlClick($avHandle,"",$class,"main",1,109 , 534)
			Sleep(250)
			;当确认窗口出现时,结束循环
			If WinGetState($avSubTitle) > 0 Then
				If Not $delay = "" Then
					Local $avSubHandle = WinWait($avSubTitle, $delay)
				Else
					Local $avSubHandle = WinWait($avSubTitle)
				EndIf
				
				If IsHWnd( $avSubHandle) Then
					If Not $s_var = "" Then
						winSetState($avSubHandle,"", $winState)
					EndIf
					ControlClick($avSubHandle,"是","Button1","main")
					$exitCode = getUninstState($avName, $avUninstPath)
					If $exitCode = 0 Then
						Sleep(3000)
						ProcessClose($iPid)
					EndIf
					ExitLoop
				EndIf
			EndIf
			$clickCount -= 1
		WEnd
	Else
		$exitCode = 5
	EndIf
	ConsoleWrite("qqpcMgrEnd")
	Return $exitCode
EndFunc

;检查卸载状态
Func getUninstState($avName, $avUninstPath)
	ConsoleWrite("getUninstState")
	Dim $flagReg, $flagPath
	If Not $delay = "" Then
		$loopTimes = $delay * 100
	Else
		$loopTimes = 1
	EndIf
	ConsoleWrite($loopTimes)
	While $loopTimes > 0
		ConsoleWrite("in loop")
		If getUninstPath($avName) = "" Then $flagReg = True
		If FileExists($avUninstPath) = 0 Then $flagPath = True
		ConsoleWrite($flagReg)
		If $flagPath And $flagReg Then
			ExitLoop
		Else
			Sleep(1000)
			If Not $delay = "" Then $loopTimes = $loopTimes - 1
		EndIf
		ConsoleWrite("uninstState:"&$loopTimes&@CR)	
	WEnd
	
	If $flagPath And $flagPath Then
		$exitCode = 0
	Else
		If Not $flagPath Then $exitCode = 6
		If Not $flagPath Then $exitCode = 7
	EndIf
	ConsoleWrite("loop been end.")
	Return $exitCode
EndFunc

;最小化窗口
Func minWin($title)
	$exitCode = 1
	If Not $title = "" Then
		If WinSetState($title, "", @SW_MINIMIZE) = 1 Then
			$exitCode = 0
		Else
			$exitCode = 1
		EndIf
	Else
		$exitCode = 1
	EndIf
	Return $exitCode
EndFunc

;获取卸载文件路径
Func getUninstPath($name)
	If @OSArch == "X86" Then
		Local $regPath[2] = ["HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"&$name]
	Else
		Local $regPath[2] = ["HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"&$name, "HKLM64\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"&$name]
	EndIf
	
	For $var In $regPath
		$uninstPath=RegRead($var,"UninstallString")
		If Not $uninstPath = "" Then
			ExitLoop
		EndIf
	Next
	Return $uninstPath
EndFunc

;创建互斥体
Func createMutex($avName)
	Dim $currentTitle = "rmav-"&$avName
	;MsgBox(0,"test",$currentTitle)
	If WinExists($currentTitle) Then
		$exitCode=9
	Else
		AutoItWinSetTitle($currentTitle)
	EndIf
	Return $exitCode
EndFunc

;打印帮助提示
Func printHelp()
	MsgBox(0,"help","此工具用于自动化卸载杀毒软件,目前支持以下参数:" & @CRLF & _
		"    /? 或 /h 用于打印此帮助信息." & @CRLF & _
		"    /r 指定需要卸载软件的序号." & @CRLF & _
		"            1    火绒杀毒软件【5.0】" & @CRLF & _
		"            2    360安全卫士【13.0】" & @CRLF & _
		"            3    360杀毒【7.0&会被软件本身误报所拦截.】" & @CRLF & _
		"            4    腾讯电脑管家【15.4】" & @CRLF & _
		"            5    金山毒霸【15.2】" & @CRLF & _
		"            6    360EPP【6200】" & @CRLF & _
		"	             --若不指定将退出程序--" & @CRLF & _
		"    /s 指定弹出窗口触发卸载按钮后的处理模式." & @CRLF & _
		"            1    隐藏窗口" & @CRLF & _
		"            2    最小化窗口" & @CRLF & _
		"            3    最大化窗口" & @CRLF & _
		"            4    窗口禁用" & @CRLF & _
		"	             --默认无操作--" & @CRLF & _
		"    /t 指定超时时间,若一段时间后仍无法找到窗口则退出程序;以秒为单位." & @CRLF & _
		"	             --默认永久等待--" & @CRLF & _
		"    /m 创建互斥,若调用两次卸载相同的软件,将会退出." & @CRLF & _
		"    /v  获取当前程序版本." & @CRLF & _
		"    /min  title*    最小化窗口,若存在." & @CRLF & _
		"以上参数大小写不敏感,每次调用只能卸载一个软件,成功卸载返回值为： 0 ,非 0 可以根据定义查询具体含义" & @CRLF & _
		"            0    程序执行正常" & @CRLF & _
		"            1    最小化窗口失败,可能未搜索到窗口" & @CRLF & _
		"            2    注册表未找到键值" & @CRLF & _
		"            3    卸载文件路径未知" & @CRLF & _
		"            4    卸载窗口弹出超时" & @CRLF & _
		"            5    激活卸载窗口超时" & @CRLF & _
		"            6    注册表键值未删除" & @CRLF & _
		"            7    卸载文件未删除" & @CRLF & _
		"            8    UAC权限获取失败" & @CRLF & _
		"            9    有进程互斥" & @CRLF & _
		"            10  其他未知错误" & @CRLF & _
		"            11  命令行参数错误." & @CRLF  _
		"            12  在启动程序前,窗口已弹出" & @CRLF & _
		)
EndFunc

;解析参数
Func getArgs()
	$argsState = False
	If $CmdLine[0] < 1 Then
		$argsState = False
		Return True
	EndIf
	For $i = 1 To $CmdLine[0] Step 1
		Select
			Case $CmdLine[$i] == "/h"
				$argsState = True
				$args_h = True
			Case $CmdLine[$i] == "/?"
				$argsState = True
				$args_h = True
			;需要移除的软件名称
			Case $CmdLine[$i] == "/r"
				$argsState = True
				$args_r = True
				If $CmdLine[0] > $i Then
					;如果 /r的值被匹配到,则通过循环方式对比值是否包含在数组下标内.
					If StringRegExp($CmdLine[$i+1], "^\d+$") = 1 Then
						For $n = 1 To $avList[0] Step 1
							If $n = $CmdLine[$i+1] Then
								$r_var = $CmdLine[$i+1]
								ExitLoop
							EndIf
						Next
						If Not $r_var Then
							MsgBox(16, "参数错误", "参数: 【/r】 的值,必需是一个存在的序号,例如: 【/r 1】")
							$exitCode=11
						EndIf
					Else
						MsgBox(16, "参数错误", "参数: 【/r】 的值,必需是一个序号,例如: 【/r 1】")
						$exitCode=11
					EndIf
				Else
					MsgBox(16, "参数错误", "参数: 【/r】 需要指定一个产品序号,例如: 【/r 1】")
					$exitCode=11
				EndIf
			;窗口状态
			Case $CmdLine[$i] == "/s"
				If $CmdLine[0] > $i Then
					;如果 /s的值被匹配到,则通过循环方式对比值是否包含在数组下标内.
					If StringRegExp($CmdLine[$i+1], "^\d+$") = 1 Then
						For $n = 1 To  $winStateList[0] Step 1
							If $n = $CmdLine[$i+1] Then
								$args_s = True
								$s_var = $CmdLine[$i+1]
								ExitLoop
							EndIf
						Next
						If Not $s_var Then
							MsgBox(16, "参数错误", "参数: 【/s】 的值,必需是一个存在的序号,例如: 【/s 1】")
							$exitCode=11
						EndIf
					Else
						MsgBox(16, "参数错误", "参数: 【/s】 的值,必需是一个序号,例如: 【/s 1】")
						$exitCode=11
					EndIf
				Else
					MsgBox(16, "参数错误", "参数: 【/s】 需要指定一个产品序号,例如: 【/s 1】")
					$exitCode=11
				EndIf
			;窗口等待延迟时间
			Case $CmdLine[$i] == "/t"
				If $CmdLine[0] > $i Then
					If StringRegExp($CmdLine[$i+1], "^\d+$") = 1 Then
						$args_t = True
						$t_var = $CmdLine[$i+1]
					Else
						MsgBox(16, "参数错误", "参数: 【/t】 的值,必需是一个数值,例如: 【/t 2000】")
						$exitCode=11
					EndIf
				Else
					MsgBox(16, "参数错误", "参数: 【/t】需要有一个时间长度值,例如: 【/t 2000】")
					$exitCode=11
				EndIf
			Case $CmdLine[$i] == "/m"
				$args_m = True
			Case $CmdLine[$i] == "/v"
				$argsState = True
				$args_v = True
			Case $CmdLine[$i] == "/min"
				$argsState = True
				If $CmdLine[0] > $i Then
					If StringRegExp($CmdLine[$i+1], "^[-/]+") = 0 Then
						$args_min = True
						$min_var = $CmdLine[$i+1]
					Else
						MsgBox(16, "参数错误", '参数: 【/min】必须是字符串参数,例如: 【/min "window"】')
						$exitCode=11
					EndIf
				Else
					MsgBox(16, "参数错误", '参数: 【/min】必须有一个字符串参数,例如: 【/min "window"】')
					$exitCode=11
				EndIf
			Case Else
				$argsHelp = True
		EndSelect
		If $exitCode = 11 Then
			$argsState = False
			ExitLoop
		EndIf
	Next
	Return $argsState
EndFunc