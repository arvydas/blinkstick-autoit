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
Local $hand

_GetHIDDevInstByVidPid(0x20A0, 0x41E5)
$hand = OpenHID($strDev)
If $hand <> $INVALID_HANDLE_VALUE Then
   Local $CapsKeyboard = DllStructCreate($tagHIDP_CAPS)
   HidD_GetCAPS($hand, DllStructGetPtr($CapsKeyboard))
	  ConsoleWrite('Usage = ' & hex(DllStructGetData($CapsKeyboard, 'Usage'), 8)  &  @LF)
	  ConsoleWrite('UsagePage = ' & hex(DllStructGetData($CapsKeyboard, 'UsagePage'), 8)  &  @LF)
	  ConsoleWrite('InputReportLength = ' & hex(DllStructGetData($CapsKeyboard, 'InputReportByteLength'), 4)  &  @LF)
	  ConsoleWrite('OutputReportLength = ' & hex(DllStructGetData($CapsKeyboard, 'OutputReportByteLength'), 4)  &  @LF)
	  ConsoleWrite('FeatureReportLength = ' & hex(DllStructGetData($CapsKeyboard, 'FeatureReportByteLength'), 4)  &  @LF)
	  ConsoleWrite('Reserved = ' & hex(DllStructGetData($CapsKeyboard, 'Reserved'), 4)  &  @LF)
	  ConsoleWrite('NumberLinkCollectionNodes = ' & hex(DllStructGetData($CapsKeyboard, 'NumberLinkCollectionNodes'), 4)  &  @LF)
	  ConsoleWrite('NumberInputButtonCaps = ' & hex(DllStructGetData($CapsKeyboard, 'NumberInputButtonCaps'), 4)  &  @LF)
	  ConsoleWrite('NumberInputValueCaps = ' & hex(DllStructGetData($CapsKeyboard, 'NumberInputValueCaps'), 4)  &  @LF)
	  ConsoleWrite('NumberInputDataIndices = ' & hex(DllStructGetData($CapsKeyboard, 'NumberInputDataIndices'), 4)  &  @LF)
	  ConsoleWrite('NumberOutputButtonCaps = ' & hex(DllStructGetData($CapsKeyboard, 'NumberOutputButtonCaps'), 4)  &  @LF)
	  ConsoleWrite('NumberOutputValueCaps = ' & hex(DllStructGetData($CapsKeyboard, 'NumberOutputValueCaps'), 4)  &  @LF)
	  ConsoleWrite('NumberOutputDataIndices = ' & hex(DllStructGetData($CapsKeyboard, 'NumberOutputDataIndices'), 4)  &  @LF)
	  ConsoleWrite('NumberFeatureButtonCaps = ' & hex(DllStructGetData($CapsKeyboard, 'NumberFeatureButtonCaps'), 4)  &  @LF)
	  ConsoleWrite('NumberFeatureValueCaps = ' & hex(DllStructGetData($CapsKeyboard, 'NumberFeatureValueCaps'), 4)  &  @LF)
	  ConsoleWrite('NumberFeatureDataIndices = ' & hex(DllStructGetData($CapsKeyboard, 'NumberFeatureDataIndices'), 4)  & @LF)

   ;ConsoleWrite(@LF & 'Get: ' & DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') & @LF)

   Local $ReportBufferW = DllStructCreate('byte reportID; byte report['  & DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') -1 & ']')  ;/* 128 ?????? + ????? ??? dummy ?????? ID */
   If @ERROR Then
     MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
   EndIf
   DllStructSetData($ReportBufferW, 'reportID', 0x01)
   
   DllStructSetData($ReportBufferW, 'report', 0x00, 1)
   DllStructSetData($ReportBufferW, 'report', 0x00, 2)
   DllStructSetData($ReportBufferW, 'report', 0xFF, 3)
   
   For $X = 4 to DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') -1
     DllStructSetData($ReportBufferW, 'report', 0x00, $X)
   Next
   ;DllStructSetData($ReportBufferW, 'report', 0x16, 3)

   ConsoleWrite(@LF & 'Set: ' & hex (DllStructGetData($ReportBufferW, 'report'), DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') -1 ) & @LF )
   HidD_SetFeature( $hand, $ReportBufferW)
   
   ;HidD_GetFeature( $hand, $ReportBufferW)
   ;ConsoleWrite(@LF & 'Get: ' & hex(DllStructGetData($ReportBufferW, 'report'), DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') -1 ) & @LF)

   ;DllStructSetData($ReportBufferW, 'report', 0x00, 3)
   ;ConsoleWrite(@LF & 'Set: ' & hex (DllStructGetData($ReportBufferW, 'report'), DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') -1 ) & @LF )
   ;HidD_SetFeature( $hand, $ReportBufferW)
   ;HidD_GetFeature( $hand, $ReportBufferW)
   ;ConsoleWrite(@LF & 'Get: ' & hex(DllStructGetData($ReportBufferW, 'report'), DllStructGetData($CapsKeyboard, 'FeatureReportByteLength') -1 ) & @LF)


   CloseHID($hand)
EndIf

Func _GetHIDDevInstByVidPid($VID, $PID)

    Local $GUID, $tGUID
$tGUID = DllStructCreate($tagGUID)
    $GUID = DllStructGetPtr($tGUID)
  
DllCall("hid.dll", "BOOLEAN", "HidD_GetHidGuid", "HWnd", $GUID)
If @ERROR Then
  MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  Local $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_GetHidGuid","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
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
       MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
      Else
       ;Check for WinAPI error
       $WinAPI_Error = _WinAPI_GetLastError()
       If $WinAPI_Error <> 0 Then
        MsgBox(0,"HidD_GetAttributes","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
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
  MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_GetPreparsedData","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  EndIf
EndIf
Return $res[0]
EndFunc
Func HidD_GetCAPS($hDevice, $pCapsKeyboard)
  Local $pKbdPreparcedData = DllStructCreate('Ptr PreparcedData;')
  $res = DllCall("hid.dll", "int", "HidD_GetPreparsedData", "ptr", $hDevice, "ptr", DllStructGetPtr($pKbdPreparcedData, 'PreparcedData'))
  Debug($res)
  If @ERROR Then
   MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
  Else
   ;Check for WinAPI error
   $WinAPI_Error = _WinAPI_GetLastError()
   If $WinAPI_Error <> 0 Then
    MsgBox(0,"HidD_GetPreparsedData","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
   Else
    ConsoleWrite(DllStructGetData($pKbdPreparcedData, 'PreparcedData') & @LF)
   EndIf
  EndIf

  ;Local $CapsKeyboard = DllStructCreate($tagHIDP_CAPS)
  $res = DllCall("hid.dll", "int", "HidP_GetCaps", "ptr", DllStructGetData($pKbdPreparcedData, 'PreparcedData'), "ptr", $pCapsKeyboard)
  Debug($res)
  If @ERROR Then
   MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
  Else
   ;Check for WinAPI error
   $WinAPI_Error = _WinAPI_GetLastError()
   If $WinAPI_Error <> 0 Then
    MsgBox(0,"HidP_GetCaps","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
   EndIf
  EndIf
EndFunc
Func CloseHID($hDevice)
$res = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hDevice)
Debug($res)
If @ERROR Then
  MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidP_GetCaps","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  EndIf
EndIf
EndFunc
Func HidD_GetFeature( $hDevice, $tReportBufferR)
$res = DllCall("hid.dll", "BOOLEAN", "HidD_GetFeature", "HWnd", $hDevice, "PTR", DllStructGetPtr($tReportBufferR), "ulong", DllStructGetSize($tReportBufferR))
Debug($res)
If @ERROR Then
  MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_GetFeature","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  Else
   if Not $res[0] Then
    MsgBox(16, "HidD_GetFeature", "Fail")
   EndIf
  EndIf
EndIf
EndFunc

Func HidD_SetFeature( $hDevice, $tReportBufferW)
$res = DllCall("hid.dll", "BOOLEAN", "HidD_SetFeature", "HWnd", $hDevice, "PTR", DllStructGetPtr($tReportBufferW), "ulong", DllStructGetSize($tReportBufferW))
Debug($res)
If @ERROR Then
  MsgBox(0,"","@ERROR: " & @ERROR & @CRLF & "@EXTENDED: " & @EXTENDED)
Else
  ;Check for WinAPI error
  $WinAPI_Error = _WinAPI_GetLastError()
  If $WinAPI_Error <> 0 Then
   MsgBox(0,"HidD_SetFeature","Error " & _WinAPI_GetLastError() & @CRLF & _WinAPI_GetLastErrorMessage()) ;Error 13: The data is invalid.
  Else
   if Not $res[0]  then
    MsgBox(16, "HidD_SetFeature", "Fail")
   EndIf
  EndIf
EndIf
EndFunc 