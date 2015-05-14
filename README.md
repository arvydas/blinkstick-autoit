# BlinkStick AutoIt

BlinkStick AutoIt provides an interface to control Blinkstick devices connected to your computer with [AutoIt scripting language](http://www.autoitscript.com).

What is BlinkStick? It's a smart USB RGB LED device. More info about it here:

[http://www.blinkstick.com](http://www.blinkstick.com)


##Requirements

Microsoft Windows Operating System and [AutoIt package](http://www.autoitscript.com/site/autoit/downloads/).

##Getting Started Example

```
#Include "blinkstick.au3"

If FindBlinkStick() Then
   SetColor(0xff, 0xff, 0x00)
   CloseBlinkStick()
Else
   MsgBox(0,"Error","Could not find any connected BlinkSticks")
EndIf
```

##API

Copy the file in the same folder as your script and include it like this:

```
#Include "blinkstick.au3"
```

Find BlinkStick:

```
FindBlinkStick()
```

Close BlinkStick HID device after the script ends

```
CloseBlinkStick()
```

Set RGB color for BlinkStick

```
SetColor($r, $g, $b)
```

Set RGB colors for BlinkStick Pro

```
SetColors($channel, $leds, $r, $g, $b)
```

Set BlinkStick mode

```
SetMode($mode)
```

[More information about BlinkStick modes](https://www.blinkstick.com/help/tutorials/blinkstick-pro-modes)

Turn BlinkStick off

```
TurnOff()
```

Blink RGB color for number of $times with $delay between each blink

```
BlinkColor($r, $g, $b, $delay, $times)
```

Pulse BlinkStick RGB color for number of $times

```
PulseColor($r, $g, $b, $times)
```

##Limitations

Currently supports only one BlinkStick per script. Please [contact](http://www.blinkstick.com/help/contact) if you need support for multiple BlinkSticks on the same computer.

##Maintainers
* Arvydas Juskevicius - [http://twitter.com/arvydev](http://twitter.com/arvydev)
