#include-once
#include <Array.au3>
#include <File.au3>
#include <WinAPI.au3>
#include <NamedPipes.au3>

; File operate
; Last update: 2012.10.14

Const $FILE_MODE_READ = 0
Const $FILE_MODE_WRITE = 2
Const $FILE_MODE_CREATEDIR = 8
Const $FILE_MODE_BINARY = 16
Const $FILE_MODE_UTF16LE = 32
Const $FILE_MODE_UTF16BE = 64
Const $FILE_MODE_UTF8BOM = 128
Const $FILE_MODE_UTF8NOBOM = 256

; Custom open file function
Func MyOpenFile($filename, $mode)
	Local $file, $action
	$action = getFileAction($mode)
	$file = FileOpen($filename, $mode)
	ChkFileErr($filename, $mode, $file)
	Return ($file)
EndFunc   ;==>MyOpenFile

; Load file content with Read mode
Func MyLoadFile($filename)
	Local $file, $file_size, $file_content
	; For Read
	$file = MyOpenFile($filename, 0)
	ChkFileErr($filename, 0, $file)
	; Read file content
	$file_size = FileGetSize($filename)
	$file_content = FileRead($file, $file_size)
	FileClose($file)
	Return ($file_content)
EndFunc   ;==>MyLoadFile

; Load file content with Read mode
Func MyLoadFileEx($filename, $mode)
	Local $file, $file_size, $file_content
	; For Read
	$file = MyOpenFile($filename, $mode)
	ChkFileErr($filename, 0, $file)
	; Read file content
	$file_size = FileGetSize($filename)
	$file_content = FileRead($file, $file_size)
	FileClose($file)
	Return ($file_content)
EndFunc   ;==>MyLoadFileEx

; Write file content
Func MyWriteFile($filename, $content)
	; For Write
	Local $file = MyOpenFile($filename, 10)
	ChkFileErr($filename, 10, $file)
	If $content <> "" Then FileWrite($file, $content)
	FileClose($file)
EndFunc   ;==>MyWriteFile

; Write file content
Func MyWriteFileEx($filename, $content, $mode)
	; For Write
	Local $file = MyOpenFile($filename, $mode)
	ChkFileErr($filename, 0, $file)
	If $content <> "" Then FileWrite($file, $content)
	FileClose($file)
EndFunc   ;==>MyWriteFileEx

; Append file content
Func MyAppendFile($filename, $content)
	; For Append
	Local $file = MyOpenFile($filename, 9)
	ChkFileErr($filename, 9, $file)
	If $content <> "" Then FileWrite($file, $content)
	FileClose($file)
EndFunc   ;==>MyAppendFile

; Check file err
Func ChkFileErr($filename, $mode, $errcode)
	Local $action = getFileAction($mode)
	If $errcode = -1 Then
		MsgBox(4112, "File I/O error", "Op:" & $action & @CRLF & @CRLF & "File:" & $filename)
		Exit 999
	EndIf
EndFunc   ;==>ChkFileErr

; Get file operation desc
Func getFileAction($mode)
	Local $action, $lMode
	$action = ""
	$lMode = BitAND(16891, $mode)
	Select
		Case $lMode = 0 ;Read
			$action &= "Read"
		Case $lMode = 1 ;Append
			$action &= "Append"
		Case $lMode = 2 ;Write
			$action &= "Write"
		Case $lMode = 8 ;Create directory
			$action &= "Create directory"
		Case $lMode = 16 ;Force binary mode
			$action &= "Force binary mode"
		Case $lMode = 32 ;Unicode
			$action &= "UTF16 Little Endian"
		Case $lMode = 64 ;Unicode
			$action &= "UTF16 Big Endian"
		Case $lMode = 128 ;Unicode
			$action &= "UTF8 (with BOM)"
		Case $lMode = 256 ;Unicode
			$action &= "UTF8 (without BOM)"
		Case Else
			$action = "-"
	EndSelect
	Return ($action)
EndFunc   ;==>getFileAction

; #FUNCTION# ====================================================================================================
; Name...........:	DirMoveEx
; Description....:  AutoIt
; Syntax.........:	DirMoveEx($sSrcPath, $sDstPath)
; Parameters.....:	$sSrcPath - source dir
;					$sDstPath - destination dir
;
; Return values..:	Success -
;					Failure -
; Author.........:	yahao
; Modified.......: 20111018
; Remarks........:
; Related........:
; Link...........:
; Example........: DirMoveEx("C:\Test","C:\NewDir")
; ===============================================================================================================
Func DirMoveEx($sSrcPath, $sDstPath)
	Local $cmd, $ec

	$sSrcPath = StringRegExpReplace($sSrcPath, "[\\/]+\z", "") & "\"
	$sDstPath = StringRegExpReplace($sDstPath, "[\\/]+\z", "") & "\"

	$cmd = @ComSpec & " /c xcopy """ & $sSrcPath & "*.*"" """ & $sDstPath & """ /E /Q /Y >NUL"
	$ec = RunWait($cmd, "", @SW_HIDE)

	$cmd = @ComSpec & " /c rmdir /S /Q """ & $sSrcPath & """ >NUL"
	$ec += RunWait($cmd, "", @SW_HIDE)

	Return $ec
EndFunc   ;==>DirMoveEx

; Strip trailing backslash, and add one after to make sure there's only one
Func StripPathTrailingBackslash($sPath)
	Return (StringRegExpReplace($sPath, "[\\/]+\z", "") & "\")
EndFunc   ;==>StripPathTrailingBackslash

;遍历文件夹内的文件，获取带完整路径的文件名，也包含子目录中的
;入参：
;     $aFile ........... 保存文件信息的数组
;     $sBeginFolder .... 起始文件夹
Func MygetAllFilesInFolder(ByRef $aFile, $sBeginFolder)
	$aFile = _FileListToArrayEx($sBeginFolder, "*.*", 1, -1, True, True)
EndFunc   ;==>MygetAllFilesInFolder

;===============================================================================
; Description:    lists all or preferred files and or folders in a specified path (Similar to using Dir with the /B Switch)
; Syntax:          _FileListToArrayEx($sPath, $sFilter = '*.*', $iFlag = 0, $sExclude = '')
; Parameter(s):     $sPath = Path to generate filelist for
;                   $sFilter = The filter to use. Search the Autoit3 manual for the word "WildCards" For details, support now for multiple searches
;                           Example *.exe; *.txt will find all .exe and .txt files
;                  $iFlag = determines weather to return file or folders or both.
;                   $sExclude = exclude a file from the list by all or part of its name
;                           Example: Unins* will remove all files/folders that start with Unins
;                       $iFlag=0(Default) Return both files and folders
;                      $iFlag=1 Return files Only
;                       $iFlag=2 Return Folders Only
;                   $f_recurse = use recursive mode or not
;                   $f_full_path = include full path or not
;
; Requirement(s):   None
; Return Value(s):  On Success - Returns an array containing the list of files and folders in the specified path
;                       On Failure - Returns the an empty string "" if no files are found and sets @Error on errors
;                       @Error or @extended = 1 Path not found or invalid
;                       @Error or @extended = 2 Invalid $sFilter or Invalid $sExclude
;                      @Error or @extended = 3 Invalid $iFlag
;                       @Error or @extended = 4 No File(s) Found
;
; Author(s):        SmOke_N, modified by mfecteau, Ascend4nt & KaFu
;                   http://www.autoitscript.com/forum/index....p?showtopic=33930&view=findpos
; Note(s):          The array returned is one-dimensional and is made up as follows:
;                   $array[0] = Number of Files\Folders returned
;                   $array[1] = 1st File\Folder
;                   $array[2] = 2nd File\Folder
;                   $array[3] = 3rd File\Folder
;                   $array[n] = nth File\Folder
;
;                   All files are written to a "reserved" .tmp file (Thanks to gafrost) for the example
;                   The Reserved file is then read into an array, then deleted
;===============================================================================
Func _FileListToArrayEx($s_path, $s_mask = "*.*", $i_flag = 0, $s_exclude = -1, $f_recurse = False, $f_full_path = False)
	If FileExists($s_path) = 0 Then Return SetError(1, 1, 0)

	; Strip trailing backslash, and add one after to make sure there's only one
	$s_path = StringRegExpReplace($s_path, "[\\/]+\z", "") & "\"

	; Set all defaults
	If $s_mask = -1 Or $s_mask = Default Then $s_mask = "*.*"
	If $i_flag = -1 Or $i_flag = Default Then $i_flag = 0
	If $s_exclude = -1 Or $s_exclude = Default Then $s_exclude = ""

	; Look for bad chars
	If StringRegExp($s_mask, "[/:><\|]") Or StringRegExp($s_exclude, "[/:><\|]") Then
		Return SetError(2, 2, 0)
	EndIf

	; Strip leading spaces between semi colon delimiter
	$s_mask = StringRegExpReplace($s_mask, "\s*;\s*", ";")
	If $s_exclude Then $s_exclude = StringRegExpReplace($s_exclude, "\s*;\s*", ";")

	; Confirm mask has something in it
	If StringStripWS($s_mask, 8) = "" Then Return SetError(2, 2, 0)
	If $i_flag < 0 Or $i_flag > 2 Then Return SetError(3, 3, 0)

	; Validate and create path + mask params
	Local $a_split = StringSplit($s_mask, ";"), $s_hold_split = ""
	For $i = 1 To $a_split[0]
		If StringStripWS($a_split[$i], 8) = "" Then ContinueLoop
		If StringRegExp($a_split[$i], "^\..*?\..*?\z") Then
			$a_split[$i] &= "*" & $a_split[$i]
		EndIf
		$s_hold_split &= '"' & $s_path & $a_split[$i] & '" '
	Next
	$s_hold_split = StringTrimRight($s_hold_split, 1)
	If $s_hold_split = "" Then $s_hold_split = '"' & $s_path & '*.*"'

	Local $i_pid, $s_stdout, $s_hold_out, $s_dir_file_only = "", $s_recurse = "/s "
	If $i_flag = 1 Then $s_dir_file_only = ":-d"
	If $i_flag = 2 Then $s_dir_file_only = ":D"
	If Not $f_recurse Then $s_recurse = ""

	$i_pid = @ComSpec & " /u /c dir /b " & $s_recurse & "/a" & $s_dir_file_only & " " & $s_hold_split
	$s_hold_out = _RunWaitStdOut($i_pid, "", @SW_HIDE)
	; ConsoleWrite($command & @crlf & $s_hold_out & @crlf & @extended & @crlf)

	;找不到文件时替换成空内容
	Local $findcontent = StringStripWS(StringReplace($s_hold_out, @LF, ""), 3)
	If $findcontent = "找不到文件" Or $findcontent = "File Not Found" Then $s_hold_out = ""

	$s_hold_out = StringRegExpReplace($s_hold_out, "\v+\z", "")
	If Not $s_hold_out Then Return SetError(4, 4, 0)

	; Parse data and find matches based on flags
	Local $a_fsplit = StringSplit(StringStripCR($s_hold_out), @LF), $s_hold_ret
	$s_hold_out = ""

	If $s_exclude Then $s_exclude = StringReplace(StringReplace($s_exclude, "*", ".*?"), ";", "|")

	For $i = 1 To $a_fsplit[0]
		If $s_exclude And StringRegExp(StringRegExpReplace( _
				$a_fsplit[$i], "(.*?[\\/]+)*(.*?\z)", "\2"), "(?i)\Q" & $s_exclude & "\E") Then ContinueLoop
		If StringRegExp($a_fsplit[$i], "^\w:[\\/]+") = 0 Then $a_fsplit[$i] = $s_path & $a_fsplit[$i]
		If $f_full_path Then
			$s_hold_ret &= $a_fsplit[$i] & Chr(1)
		Else
			$s_hold_ret &= StringRegExpReplace($a_fsplit[$i], "((?:.*?[\\/]+)*)(.*?\z)", "$2") & Chr(1)
		EndIf
	Next

	$s_hold_ret = StringTrimRight($s_hold_ret, 1)
	If $s_hold_ret = "" Then Return SetError(5, 5, 0)

	Return StringSplit($s_hold_ret, Chr(1))
EndFunc   ;==>_FileListToArrayEx

; ====================================================================================================
; Execute a command and display the results
; ====================================================================================================
; Paul Campbell (PaulIA), ProgAndy, modified by KaFu and trancexx
; http://www.autoitscript.com/forum/index....p?showtopic=76607&view=findpos

Func _RunWaitStdOut($sCmd, $sWorkingDir = "", $state = @SW_SHOW)
	Local $pBuffer
	Local $iBytes, $sData, $hReadPipe, $hWritePipe, $tBuffer, $tProcess, $tSecurity, $tStartup
	Local $STILL_ACTIVE = 0x103
	Local Const $STARTF_USESHOWWINDOW = 0x1
	Local Const $STARTF_USESTDHANDLES = 0x100

	; Set up security attributes
;~     $tSecurity = DllStructCreate($tagSECURITY_ATTRIBUTES)
;~     DllStructSetData($tSecurity, "Length", DllStructGetSize($tSecurity))
;~     DllStructSetData($tSecurity, "InheritHandle", True)

	; Create a pipe for the child process's STDOUT
	_NamedPipes_CreatePipe($hReadPipe, $hWritePipe);, $tSecurity)

	;**************
	_WinAPI_SetHandleInformation($hReadPipe, 1, 0) ; redundant in this new situation
	_WinAPI_SetHandleInformation($hWritePipe, 1, 1)
	;**************

	; Create child process
	$tProcess = DllStructCreate($tagPROCESS_INFORMATION)
	$tStartup = DllStructCreate($tagSTARTUPINFO)
	DllStructSetData($tStartup, "Size", DllStructGetSize($tStartup))
	DllStructSetData($tStartup, "Flags", BitOR($STARTF_USESTDHANDLES, $STARTF_USESHOWWINDOW))
	DllStructSetData($tStartup, "StdOutput", $hWritePipe)
	DllStructSetData($tStartup, "StdError", $hWritePipe)
	DllStructSetData($tStartup, "ShowWindow", $state)
	_WinAPI_CreateProcess("", $sCmd, 0, 0, True, 0, 0, $sWorkingDir, DllStructGetPtr($tStartup), DllStructGetPtr($tProcess))
	Local $handle = DllStructGetData($tProcess, "hProcess"), $exitCode
	_WinAPI_CloseHandle(DllStructGetData($tProcess, "hThread"))

	Do
		$exitCode = DllCall("kernel32.dll", "long", "GetExitCodeProcess", "hwnd", $handle, "dword*", 0)
	Until $exitCode[0] <> $STILL_ACTIVE
	$exitCode = $exitCode[2]
	; Close the write end of the pipe before reading from the read end of the pipe
	_WinAPI_CloseHandle($handle)
	_WinAPI_CloseHandle($hWritePipe)

	; Read data from the child process
	$tBuffer = DllStructCreate("wchar Text[4096]")
	$pBuffer = DllStructGetPtr($tBuffer)
	While 1
		_WinAPI_ReadFile($hReadPipe, $pBuffer, 4096, $iBytes)
		If $iBytes = 0 Then ExitLoop
		$sData &= StringLeft(DllStructGetData($tBuffer, "Text"), $iBytes / 2)
	WEnd
	_WinAPI_CloseHandle($hReadPipe)
	SetExtended($exitCode)
	Return $sData
EndFunc   ;==>_RunWaitStdOut