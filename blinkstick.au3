;  Copyright 2013 by Agile Innovative Ltd
; 
;  This file is part of BlinkStick AutoIt library.
; 
;  BlinkStick AutoIt library is free software: you can redistribute 
;  it and/or modify it under the terms of the GNU General Public License as published 
;  by the Free Software Foundation, either version 3 of the License, or (at your option) 
;  any later version.
; 		
;  BlinkStick AutoIt library is distributed in the hope that it will be useful, but 
;  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
; 
;  You should have received a copy of the GNU General Public License along with 
;  BlinkStick AutoIt library. If not, see http:; www.gnu.org/licenses/.

;  Based on the generic code for HID device from AutoIt forum user dennn66
;  http://www.autoitscript.com/forum/topic/135815-hid-data-exchange-w-custom-usb-device/

#include <StructureConstants.au3>
#Include <WinAPI.au3>

Global Const $NULL = Chr(0)
Global Const $DIGCF_DEFAULT       = 0x00000001  ;// only valid with DIGCF_DEVICEINTERFACE
Global Const $DIGCF_PRESENT       = 0x00000002
Global Const $DIGCF_ALLCLASSES     = 0x00000004
Global Const $DIGCF_PROFILE       = 0x00000008
Global Const $DIGCF_DEVICEINTERFACE  = 0x00000010
; Structures
Global Const $SP_DEV_BUF = "byte[2052]"
Global Const $SP_DEVICE_INTERFACE_DETAIL_DATA = "dword cbSize;wchar DevicePath[1024]" ; created at SP_DEV_BUF ptr
Global Const $SP_DEVICE_INTERFACE_DATA = "dword cbSize;byte InterfaceClassGuid[16];dword Flags;ulong_ptr Reserved" ; GUID struct = 16 bytes
Global Const $SP_DEVINFO_DATA = "dword cbSize;byte ClassGuid[16];dword DevInst;ulong_ptr Reserved"

Global Const $tagHIDD_ATTRIBUTES = _
  'ULONG  Size;' & _
  'USHORT VendorID;' & _
  'USHORT ProductID;' & _
  'USHORT VersionNumber;'

Global Const $tagHIDP_CAPS = _
  'USHORT  Usage;' & _
  'USHORT  UsagePage;' & _
  'USHORT InputReportByteLength;' & _
  'USHORT OutputReportByteLength;' & _
  'USHORT FeatureReportByteLength;' & _
  'USHORT Reserved[17];' & _
  'USHORT NumberLinkCollectionNodes;' & _
  'USHORT NumberInputButtonCaps;' & _
  'USHORT NumberInputValueCaps;' & _
  'USHORT NumberInputDataIndices;' & _
  'USHORT NumberOutputButtonCaps;' & _
  'USHORT NumberOutputValueCaps;' & _
  'USHORT NumberOutputDataIndices;' & _
  'USHORT NumberFeatureButtonCaps;' & _
  'USHORT NumberFeatureValueCaps;' & _
  'USHORT NumberFeatureDataIndices;'

Opt("MustDeclareVars", 1)
Global $strDev
Global $res, $WinAPI_Error
Global $hand

; ********************************************************************************************************
;									BlinkStick functions
; ********************************************************************************************************

Func FindBlinkStick()
   _GetHIDDevInstByVidPid(0x20A0, 0x41E5)
   $hand = OpenHID($strDev)
   Return $hand <> $INVALID_HANDLE_VALUE
EndFunc

Func SetColor($r, $g, $b)
   If $hand <> $INVALID_HANDLE_VALUE Then
	  ; Create report buffer
	  Local $ReportBufferW = DllStructCreate('byte reportID; byte report[32]')
	  If @ERROR Then
		MsgBox(0,"","0004 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
		Return
	  EndIf
	  DllStructSetData($ReportBufferW, 'reportID', 0x01)
	  
	  ; Set RGB color
	  DllStructSetData($ReportBufferW, 'report', $r, 1)
	  DllStructSetData($ReportBufferW, 'report', $g, 2)
	  DllStructSetData($ReportBufferW, 'report', $b, 3)
	  
	  ; Fill out the rest of the report with zeros
	  For $X = 4 to 32
		DllStructSetData($ReportBufferW, 'report', 0x00, $X)
	  Next
	  
	  ; Send report to the device
	  HidD_SetFeature( $hand, $ReportBufferW)
   EndIf	  
EndFunc

Func SetColors($channel, $count, $r, $g, $b)
   If $hand <> $INVALID_HANDLE_VALUE Then
	  ; Create report buffer
	  Local $ReportBufferW = DllStructCreate('byte reportID; byte channel; byte report[24]')
	  If @ERROR Then
		MsgBox(0,"","0004 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
		Return
	  EndIf
	  DllStructSetData($ReportBufferW, 'reportID', 0x06)
	  DllStructSetData($ReportBufferW, 'channel', $channel)
	  
	  ; Set RGB color
	  For $X = 0 to $count - 1
		 DllStructSetData($ReportBufferW, 'report', $g, 1 + $X * 3)
		 DllStructSetData($ReportBufferW, 'report', $r, 2 + $X * 3)
		 DllStructSetData($ReportBufferW, 'report', $b, 3 + $X * 3)
	  Next
	  
	  
	  ; Send report to the device
	  HidD_SetFeature( $hand, $ReportBufferW)
   EndIf	  
EndFunc

Func SetMode($mode)
   If $hand <> $INVALID_HANDLE_VALUE Then
	  ; Create report buffer
	  Local $ReportBufferW = DllStructCreate('byte reportID; byte mode;')
	  If @ERROR Then
		MsgBox(0,"","0004 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
		Return
	  EndIf
	  DllStructSetData($ReportBufferW, 'reportID', 0x04)
	  DllStructSetData($ReportBufferW, 'mode', $mode)
	  
	  ; Send report to the device
	  HidD_SetFeature( $hand, $ReportBufferW)
   EndIf	  
EndFunc

Func TurnOff()
   SetColor(0x00, 0x00, 0x00)
EndFunc

Func BlinkColor($r, $g, $b, $delay, $times)
   For $X = 1 to $times
	  SetColor($r, $g, $b)
	  Sleep($delay)
	  TurnOff()
	  Sleep($delay)
   Next
EndFunc

Func PulseColor($r, $g, $b, $times)
   Local $rr = 0
   Local $gg = 0
   Local $bb = 0
   
   TurnOff()
   
   For $X = 1 to $times
	  While $r <> $rr Or $g <> $gg Or $b <> $bb
		 if $rr < $r Then
			$rr = $rr + 1
		 EndIf
		 
		 if $gg < $g Then
			$gg = $gg + 1
		 EndIf

		 if $bb < $b Then
			$bb = $bb + 1
		 EndIf

		 SetColor($rr, $gg, $bb)
		 ;Sleep(1)
	  WEnd
	  
	  While $rr > 0 Or $gg > 0 Or $bb > 0
		 if $rr > 0 Then
			$rr = $rr - 1
		 EndIf
		 
		 if $gg > 0 Then
			$gg = $gg - 1
		 EndIf

		 if $bb > 0 Then
			$bb = $bb - 1
		 EndIf

		 SetColor($rr, $gg, $bb)
		 ;Sleep(1)
	  WEnd
   Next
EndFunc

Func CloseBlinkStick()
   If $hand <> $INVALID_HANDLE_VALUE Then
	  CloseHID($hand)
   EndIf
EndFunc

; ********************************************************************************************************
;									Generic HID code
; ********************************************************************************************************

Func _GetHIDDevInstByVidPid($VID, $PID)

    Local $GUID, $tGUID
$tGUID = DllStructCreate($tagGUID)
    $GUID = DllStructGetPtr($tGUID)
  
DllCall("hid.dll", "BOOLEAN", "HidD_GetHidGuid", "HWnd", $GUID)
If @ERROR Then
  MsgBox(0,"","0005 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  Local $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_GetHidGuid","0001 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  EndIf
EndIf

    ; Get device interface info set handle
    ; for all devices attached to system
    Local $hDevInfo = DllCall("setupapi.dll", "ptr", "SetupDiGetClassDevsW", "ptr", $GUID, "ptr", 0, "hwnd", 0, _
            "dword", BitOR($DIGCF_PRESENT, $DIGCF_DEVICEINTERFACE))
  ;  Debug($hDevInfo)
$hDevInfo = $hDevInfo[0]
   If $hDevInfo <> $INVALID_HANDLE_VALUE Then
      ;ConsoleWrite("hDevInfo: " & $hDevInfo & @CRLF)
        ; Retrieve a context structure for a device interface
        ; of a device information set.
        Local $dwIndex = 0
        Local $bRet
        Local $buf = DllStructCreate($SP_DEV_BUF)
        Local $pspdidd = DllStructCreate($SP_DEVICE_INTERFACE_DETAIL_DATA, DllStructGetPtr($buf))
        Local $cb_spdidd = 6 ; size of fixed part of structure
        If @AutoItX64 Then $cb_spdidd = 8 ; fix for x64
        Local $spdid = DllStructCreate($SP_DEVICE_INTERFACE_DATA)
        Local $spdd = DllStructCreate($SP_DEVINFO_DATA)
        DllStructSetData($spdid, "cbSize", DllStructGetSize($spdid))
        While True
            $bRet = DllCall("setupapi.dll", "int", "SetupDiEnumDeviceInterfaces", "ptr", $hDevInfo, "ptr", 0, _
                    "ptr", $GUID, "dword", $dwIndex, "ptr", DllStructGetPtr($spdid))
            If Not $bRet[0] Then ExitLoop
            Local $res = DllCall("setupapi.dll", "int", "SetupDiGetDeviceInterfaceDetailW", "ptr", $hDevInfo, "ptr", DllStructGetPtr($spdid), _
                    "ptr", 0, "dword", 0, "dword*", 0, "ptr", 0)
            Local $dwSize = $res[5]
   ;      ConsoleWrite("dwSize: " & $dwSize & @CRLF)
            If $dwSize <> 0 And $dwSize <= DllStructGetSize($buf) Then
                DllStructSetData($pspdidd, "cbSize", $cb_spdidd)
                _ZeroMemory(DllStructGetPtr($spdd), DllStructGetSize($spdd))
                DllStructSetData($spdd, "cbSize", DllStructGetSize($spdd))
                $res = DllCall("setupapi.dll", "int", "SetupDiGetDeviceInterfaceDetailW", "ptr", $hDevInfo, "ptr", DllStructGetPtr($spdid), _
                        "ptr", DllStructGetPtr($pspdidd), "dword", $dwSize, "dword*", 0, "ptr", DllStructGetPtr($spdd))
                If $res[0] Then
                    Local $hDrive = DllCall("kernel32.dll", "ptr", "CreateFileW", "wstr", DllStructGetData($pspdidd, "DevicePath"), "dword", 0, _
                            "dword", BitOR($FILE_SHARE_READ, $FILE_SHARE_WRITE), "ptr", 0, "dword", $OPEN_EXISTING, _
                            "dword", 0, "ptr", 0)
                    $hDrive = $hDrive[0]
;               ConsoleWrite("hDrive: " & $hDrive & @CRLF)
                    If $hDrive <> $INVALID_HANDLE_VALUE Then
      Local $kbdAttributes = DllStructCreate($tagHIDD_ATTRIBUTES)
      $res = DllCall("hid.dll", "BOOLEAN", "HidD_GetAttributes", "HWnd", $hDrive, "ptr", DllStructGetPtr($kbdAttributes))
      If @ERROR Then
       MsgBox(0,"","0002 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
      Else
       ;Check for WinAPI error
       $WinAPI_Error = _WinAPI_GetLastError()
       If $WinAPI_Error <> 0 Then
        MsgBox(0,"HidD_GetAttributes","0003 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
       Else
        If $res[0] Then     
;        ConsoleWrite(DllStructGetData($kbdAttributes, 'Size') & ' -> ')
;        ConsoleWrite(hex(DllStructGetData($kbdAttributes, 'VendorID'), 4) & ' -> ')
;        ConsoleWrite(hex(DllStructGetData($kbdAttributes, 'ProductID'), 4) & ' -> ')
;        ConsoleWrite(DllStructGetData($kbdAttributes, 'VersionNumber') & @LF)
         If ($VID == DllStructGetData($kbdAttributes, "VendorID") And $PID == DllStructGetData($kbdAttributes, "ProductID")) Then
          $res = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hDrive)
          If Not $res[0] Then ConsoleWrite("Error closing volume: " & $hDrive & @CRLF)
          $res = DllCall("setupapi.dll", "int", "SetupDiDestroyDeviceInfoList", "ptr", $hDevInfo)
          If Not $res[0] Then ConsoleWrite("SetupDiDestroyDeviceInfoList error." & @CRLF)
          ConsoleWrite("DevicePath: " & DllStructGetData($pspdidd, "DevicePath") & @LF)
          $StrDev = DllStructGetData($pspdidd, "DevicePath")
          Return 1
         EndIf    
          
        EndIf
       EndIf
      EndIf
                        $res = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hDrive)
                      If Not $res[0] Then ConsoleWrite("Error closing volume: " & $hDrive & @CRLF)
                    EndIf
    EndIf
            EndIf
            $dwIndex += 1
        WEnd
        $res = DllCall("setupapi.dll", "int", "SetupDiDestroyDeviceInfoList", "ptr", $hDevInfo)
      If Not $res[0] Then ConsoleWrite("Destroy error." & @CRLF)
    EndIf
    Return 0
EndFunc   ;==>_GetDrivesDevInstByDeviceNumber

Func _ZeroMemory($ptr, $size)
    DllCall("kernel32.dll", "none", "RtlZeroMemory", "ptr", $ptr, "ulong_ptr", $size)
EndFunc   ;==>_ZeroMemory

;Dump array to console
Func Debug($aArray)
    For $X = 0 to Ubound($aArray)-1
        ConsoleWrite("["&$X&"]: " & $aArray[$X] & @CRLF)
    Next
    ConsoleWrite(@CRLF)
EndFunc

Func OpenHID($strDevPath)
$res = DllCall("kernel32.dll", "ptr", "CreateFile", "str", $strDevPath,          "dword", 0, "dword", BitOR($FILE_SHARE_READ, $FILE_SHARE_WRITE), "ptr",$NULL, "dword", $OPEN_EXISTING, "dword", 0, "ptr", $NULL)
Debug($res)
If @ERROR Then
  MsgBox(0,"","0006 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   ;MsgBox(0,"HidD_GetPreparsedData","0007 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  EndIf
EndIf
Return $res[0]
EndFunc
Func HidD_GetCAPS($hDevice, $pCapsKeyboard)
  Local $pKbdPreparcedData = DllStructCreate('Ptr PreparcedData;')
  $res = DllCall("hid.dll", "int", "HidD_GetPreparsedData", "ptr", $hDevice, "ptr", DllStructGetPtr($pKbdPreparcedData, 'PreparcedData'))
  Debug($res)
  If @ERROR Then
   MsgBox(0,"","0008 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
  Else
   ;Check for WinAPI error
   $WinAPI_Error = _WinAPI_GetLastError()
   If $WinAPI_Error <> 0 Then
    MsgBox(0,"HidD_GetPreparsedData","0009 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
   Else
    ConsoleWrite(DllStructGetData($pKbdPreparcedData, 'PreparcedData') & @LF)
   EndIf
  EndIf

  ;Local $CapsKeyboard = DllStructCreate($tagHIDP_CAPS)
  $res = DllCall("hid.dll", "int", "HidP_GetCaps", "ptr", DllStructGetData($pKbdPreparcedData, 'PreparcedData'), "ptr", $pCapsKeyboard)
  Debug($res)
  If @ERROR Then
   MsgBox(0,"","0010 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
  Else
   ;Check for WinAPI error
   $WinAPI_Error = _WinAPI_GetLastError()
   If $WinAPI_Error <> 0 Then
    MsgBox(0,"HidP_GetCaps","0011Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
   EndIf
  EndIf
EndFunc
Func CloseHID($hDevice)
$res = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hDevice)
Debug($res)
If @ERROR Then
  MsgBox(0,"","0012 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidP_GetCaps","0014 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  EndIf
EndIf
EndFunc
Func HidD_GetFeature( $hDevice, $tReportBufferR)
$res = DllCall("hid.dll", "BOOLEAN", "HidD_GetFeature", "HWnd", $hDevice, "PTR", DllStructGetPtr($tReportBufferR), "ulong", DllStructGetSize($tReportBufferR))
Debug($res)
If @ERROR Then
  MsgBox(0,"","0015 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_GetFeature","0016 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  Else
   if Not $res[0] Then
    MsgBox(16, "HidD_GetFeature", "0017 Fail")
   EndIf
  EndIf
EndIf
EndFunc

Func HidD_SetFeature( $hDevice, $tReportBufferW)
$res = DllCall("hid.dll", "BOOLEAN", "HidD_SetFeature", "HWnd", $hDevice, "PTR", DllStructGetPtr($tReportBufferW), "ulong", DllStructGetSize($tReportBufferW))
;Debug($res)
If @ERROR Then
  MsgBox(0,"","0017 @ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_SetFeature","0019 Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  Else
   if Not $res[0]  then
    MsgBox(16, "HidD_SetFeature", "0020 Fail")
   EndIf
  EndIf
EndIf
EndFunc 