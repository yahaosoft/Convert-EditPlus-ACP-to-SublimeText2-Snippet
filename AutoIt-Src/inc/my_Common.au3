#include-once

; common functions
; Last update: 2012.10.14

; Custom Msgbox
Func a($title, $content)
	MsgBox(4160, $title, $content)
EndFunc   ;==>a
; Custom Msgbox
Func a1($content)
	MsgBox(4160, Default, $content)
EndFunc   ;==>a1

; ==============================================================================================
;TRIM function start
Func _LTRIM($sString, $sTrimChars = ' ')

	$sTrimChars = StringReplace($sTrimChars, "%%whs%%", " " & Chr(9) & Chr(11) & Chr(12) & @CRLF)
	Local $nCount, $nFoundChar
	Local $aStringArray = StringSplit($sString, "")
	Local $aCharsArray = StringSplit($sTrimChars, "")

	For $nCount = 1 To $aStringArray[0]
		$nFoundChar = 0
		For $i = 1 To $aCharsArray[0]
			If $aCharsArray[$i] = $aStringArray[$nCount] Then
				$nFoundChar = 1
			EndIf
		Next
		If $nFoundChar = 0 Then Return StringTrimLeft($sString, ($nCount - 1))
	Next
EndFunc   ;==>_LTRIM

Func _RTRIM($sString, $sTrimChars = ' ')

	$sTrimChars = StringReplace($sTrimChars, "%%whs%%", " " & Chr(9) & Chr(11) & Chr(12) & @CRLF)
	Local $nCount, $nFoundChar
	Local $aStringArray = StringSplit($sString, "")
	Local $aCharsArray = StringSplit($sTrimChars, "")

	For $nCount = $aStringArray[0] To 1 Step -1
		$nFoundChar = 0
		For $i = 1 To $aCharsArray[0]
			If $aCharsArray[$i] = $aStringArray[$nCount] Then
				$nFoundChar = 1
			EndIf
		Next
		If $nFoundChar = 0 Then Return StringTrimRight($sString, ($aStringArray[0] - $nCount))
	Next
EndFunc   ;==>_RTRIM

Func _ALLTRIM($sString, $sTrimChars = ' ')

	;  Trim from left first, then right

	$sTrimChars = StringReplace($sTrimChars, "%%whs%%", " " & Chr(9) & Chr(11) & Chr(12) & @CRLF)
	Local $sStringWork = ""

	$sStringWork = _LTRIM($sString, $sTrimChars)
	If $sStringWork <> "" Then
		$sStringWork = _RTRIM($sStringWork, $sTrimChars)
	EndIf
	Return $sStringWork

EndFunc   ;==>_ALLTRIM

Func _TRIM($sString, $sTrimChars = ' ') ; Equivalent to _RTRIM() and provided for dBase equivalence.

	Return _RTRIM($sString, $sTrimChars)

EndFunc   ;==>_TRIM

Func trim($str)
	Return (_ALLTRIM($str))
EndFunc   ;==>trim
;TRIM function end
; ==============================================================================================
