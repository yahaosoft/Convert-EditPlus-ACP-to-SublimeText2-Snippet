Opt('MustDeclareVars', 1)
Opt("TrayIconHide", 1) ;0=show, 1=hide tray icon
Opt("TrayIconDebug", 0) ;0=no info, 1=debug line info
Opt("WinTitleMatchMode", 2) ;2 = Match any substring in the title

#include "inc\my_Common.au3"
#include "inc\my_File.au3"

#cs
	Last update at 2012.10.15
	Readme for start:

	1. copy your *.acp files to \acp folder from EditPlus syntax directory
	2. in AutoIt IDE,press F5 then it will begin convert
	3. the acp_dir can use full absolute path that include *.acp files

	any comments please mailto yahaosoft@gmail.com,thanks!
#ce

Global Const $configinifile = @ScriptDir & "\EPACP2ST2Snippet.ini"
Global $_FileVer = FileGetVersion(@ScriptFullPath) & " @ 20121014"

Global $gWinTitle, $gAcpFileDir, $gSnippetDir

main()
;========== Script End ==========================

;Main program
Func main()
	;read config
	getAppCfg()

	;check Env
	chkEnv()

	;begin convert
	convert_acp_to_snippet()
EndFunc   ;==>main

;read config
Func getAppCfg()
	;read from ini file
	$gWinTitle = IniRead($configinifile, "app", "wintitle", "EPACP2ST2SNIPPET")
	$gAcpFileDir = IniRead($configinifile, "app", "acp_dir", "")
	$gSnippetDir = IniRead($configinifile, "app", "snippet_dir", @ScriptDir & "\snippet")

	If $gAcpFileDir = "" Then $gAcpFileDir = @ScriptDir & "\acp"
	If $gSnippetDir = "" Then $gSnippetDir = @ScriptDir & "\snippet"
EndFunc   ;==>getAppCfg

;check Env
Func chkEnv()
	If $gAcpFileDir = "" Then
		a("error - " & $gWinTitle, "Acp folder is empty!")
		Exit 1
	EndIf

	If $gSnippetDir = "" Then
		a("error - " & $gWinTitle, "Snippet folder is empty!")
		Exit 2
	EndIf

	;add \ to the path
	$gAcpFileDir = StripPathTrailingBackslash($gAcpFileDir)
	$gSnippetDir = StripPathTrailingBackslash($gSnippetDir)
EndFunc   ;==>chkEnv

Func convert_acp_to_snippet()
	Local $arFile, $filecount, $sAcoFile, $aAcp, $iAcpCount, $i, $j, $k, $acpfileidx, $sLog, $count
	Local $sFileContent, $acpText, $acpTitle, $acpBody
	Local $spHeader, $spFooter, $spContent
	Local $filename, $sLanTitle, $sSnippetDir
	Local $szDrive, $szDir, $szFName, $szExt, $aPathPart

	;get all acp files from folder
	$arFile = _FileListToArrayEx($gAcpFileDir, "*.acp", 1, -1, True, True)
	_ArrayDelete($arFile, 0)
	$filecount = UBound($arFile, 1)

	If $filecount = 0 Then
		a($gWinTitle, "no acp files found!")
		Exit 3
	EndIf

	$count = 0
	$filecount -= 1
	For $acpfileidx = 0 To $filecount Step 1
		$sAcoFile = $arFile[$acpfileidx]

		;get filename
		$aPathPart = _PathSplit($sAcoFile, $szDrive, $szDir, $szFName, $szExt)

		;get lan_title and snippet_dir
		$sLanTitle = StringUpper($szFName)
		$sSnippetDir = $gSnippetDir & "My" & $sLanTitle & " Snippets\"
		If Not FileExists($sSnippetDir) Then DirCreate($sSnippetDir)

		;load acp
		$sFileContent = MyLoadFile($sAcoFile)
		$aAcp = StringSplit($sFileContent, "#T", 1)

		$spHeader = "<snippet>" & @CRLF & @TAB & "<content><![CDATA["
		$spFooter = @CRLF & @TAB & "<scope>" & StringLower(getST2ScopeName($sLanTitle)) & "</scope>" & @CRLF & "</snippet>"

		$iAcpCount = $aAcp[0]

		;!!!DEBUG ONLY!!!
;~ 		$iAcpCount = 3

		For $i = 3 To $iAcpCount Step 1
			$acpText = $aAcp[$i]
			If $acpText <> "" Then
				$j = StringInStr($acpText, @CRLF)
				$acpTitle = StringMid($acpText, 2, $j)
				$acpBody = trim(StringMid($acpText, $j + 1, StringLen($acpText)))

				$acpTitle = StringReplace($acpTitle, @CRLF, "")
				$k = StringInStr($acpBody, @CRLF & "#")
				If $k > 0 Then
					$acpBody = StringMid($acpBody, 1, $k)
				EndIf
				$acpBody = StringMid($acpBody, 1, StringLen($acpBody) - 1)
				$acpBody = StringReplace($acpBody, "^!", "${1}")
				$acpBody = StringReplace($acpBody, "^^", "${2}")

				If StringLen($acpBody) > 0 Then
					$spContent = $spHeader
					$spContent &= $acpBody & "]]></content>" & @CRLF & @TAB
					$spContent &= "<tabTrigger>" & $acpTitle & "</tabTrigger>" & @CRLF & @TAB
					$spContent &= "<description>My" & $sLanTitle & " - " & $acpTitle & "</description>"
					$spContent &= $spFooter

					$filename = $sSnippetDir & $acpTitle & ".sublime-snippet"
					MyWriteFileEx($filename, $spContent, $FILE_MODE_WRITE + $FILE_MODE_UTF8NOBOM)

					$count += 1
				EndIf
			EndIf
		Next
	Next

	a($gWinTitle, "Total " & String($count) & " items was converted!")
EndFunc   ;==>convert_acp_to_snippet

Func getST2ScopeName($lan_title)
	Select
		Case $lan_title = "asp"
			Return ("text.html.asp")
		Case $lan_title = "css"
			Return ("source.css")
		Case $lan_title = "sql" Or $lan_title = "tsql"
			Return ("source.sql")
		Case $lan_title = "html" Or $lan_title = "htm"
			Return ("text.html.basic")
		Case $lan_title = "js"
			Return ("source.js")
		Case $lan_title = "txt"
			Return ("text.plain")
		Case Else
			Return ("")
	EndSelect
EndFunc   ;==>getST2ScopeName