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

#Include "blinkstick.au3"

If FindBlinkStick() Then
   SetColor(0xff, 0x00, 0x00)
   Sleep(1000)
   BlinkColor(0x00, 0xff, 0x00, 500, 3)
   Sleep(1000)
   PulseColor(0x00, 0x00, 0xff, 3)
   CloseBlinkStick()
Else
   MsgBox(0,"Error","Could not find a connected BlinkStick")
EndIf
