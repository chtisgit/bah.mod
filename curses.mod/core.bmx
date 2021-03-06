' Copyright (c) 2007-2017 Bruce A Henderson
' All rights reserved.
'
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions are met:
'     * Redistributions of source code must retain the above copyright
'       notice, this list of conditions and the following disclaimer.
'     * Redistributions in binary form must reproduce the above copyright
'       notice, this list of conditions and the following disclaimer in the
'       documentation and/or other materials provided with the distribution.
'     * Neither the name of Bruce A Henderson nor the
'       names of its contributors may be used to endorse or promote products
'       derived from this software without specific prior written permission.
'
' THIS SOFTWARE IS PROVIDED BY Bruce A Henderson ``AS IS'' AND ANY
' EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
' DISCLAIMED. IN NO EVENT SHALL Bruce A Henderson BE LIABLE FOR ANY
' DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
' (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
' LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
' ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
' (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
' SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
SuperStrict

Import BRL.Map
Import BRL.LinkedList
Import BRL.System

Import "common.bmx"

Type TBindCallback

	Field widget:TCursesWidget
	Field data:Object
	Field cb:Int(widget:TCursesWidget, data:Object, key:Int)
	
End Type


Rem
bbdoc: The base type for all widgets.
End Rem
Type TCursesWidget

	Field screen:TCursesScreen
	
	Field widgetPtr:Byte Ptr
	
	Field bindings:TMap = New TMap

	Rem
	bbdoc: Gets the parent screen of this widget.
	End Rem
	Method getScreen:TCursesScreen()
		Return screen
	End Method
	
	Rem
	bbdoc: Add a key binding for the specified key.
	about: @data can be any arbitrary data you wish to be supplied when the callback is executed.
	End Rem
	Method bindKey(key:Int, data:Object, bindFunc:Int(widget:TCursesWidget, data:Object, key:Int))
	
		Local bc:TBindCallback = New TBindCallback
		bc.widget = Self
		bc.cb = bindFunc
		bc.data = data
		
		bindings.insert(String(key), bc)
	
		bindCDKObject(getType(), widgetPtr, key, keyBindCallback , Self)
		
	End Method
	
	Rem
	bbdoc: Removes a key binding.
	End Rem
	Method unbindKey(key:Int)
	
		unbindCDKObject(getType(), widgetPtr, key)
		
		bindings.remove(String(key))
	
	End Method
	
	Rem
	bbdoc: Removes all the key bindings.
	End Rem
	Method clearBindings()
		cleanCDKObjectBindings(getType(), widgetPtr)
		
		bindings.clear()
	End Method
	
	Rem
	bbdoc: Returns True if a binding for @key exists.
	End Rem
	Method hasBind:Int(key:Int)
		Return isCDKObjectBind(getType(), widgetPtr, key)
	End Method
	
	' this is "our" callback for key binding. We then pass on to the user callback function.
	Function keyBindCallback:Int(cdktype:Int, obj:Byte Ptr, clientData:Object, inp:Int)
	
		If TCursesWidget(clientData) Then
		
			Local bc:TBindCallback = TBindCallback(TCursesWidget(clientData).bindings.valueForKey(String(inp)))
			
			If bc Then
				Return bc.cb(TCursesWidget(clientData), bc.data, inp)
			End If
		
		End If
	
	End Function

	Rem
	bbdoc: Sets up the preprocess callback.
	about: Before processing any keys, the callback function will be called first, allowing you
	to override/add any specific functionality you need.<br>
	Your callback function should return @True if the original event should continue to be processed,
	or @False if you don't want processing to continue.
	End Rem
	Method setPreprocess(data:Object, callback:Int(widget:TCursesWidget, data:Object, key:Int))
		
		Local bc:TBindCallback = New TBindCallback
		bc.widget = Self
		bc.cb = callback
		bc.data = data
		
		bindings.insert("preprocess", bc)
		
		setCDKObjectPreProcess(widgetPtr, preprocessBindCallback, Self)
		
	End Method
	
	' oh tangled webs we weave...
	' this is "our" callback for preprocess. We then pass it onto the user callback function.
	Function preprocessBindCallback:Int(cdktype:Int, obj:Byte Ptr, clientData:Object, inp:Int)
	
		If TCursesWidget(clientData) Then
	
			Local bc:TBindCallback = TBindCallback(TCursesWidget(clientData).bindings.valueForKey("preprocess"))
			
			If bc Then
				Return bc.cb(TCursesWidget(clientData), bc.data, inp)
			End If
	
		End If
	End Function
	

	Rem
	bbdoc: Displays the widget.
	End Rem
	Method show() Abstract
	
	Rem
	bbdoc: Enables the user-positioning of the widget.
	about: Controls are as follows:
	<ul>
	<li>ENTER / RETURN : finish positiong</li>
	<li>ESCAPE : reset to original position</li>
	<li>UP / 8 : move up</li>
	<li>DOWN / 2 : move down</li>
	<li>LEFT / 4 : move left</li>
	<li>RIGHT / 6 : move right</li>
	<li>7 : move up and left</li>
	<li>9 : move up and right</li>
	<li>1 : move down and left</li>
	<li>3 : move down and right</li>
	<li>5 : position at screen center</li>
	<li>t : position at the top</li>
	<li>b : position at the bottom</li>
	<li>l : position on the left</li>
	<li>r : position on the right</li>
	<li>c : horizontal center</li>
	<li>C : vertical center</li>
	</ul>
	End Rem
	Method position() Abstract
	
	Rem
	bbdoc: Hides the widget.
	End Rem
	Method hide() Abstract
	
	Rem
	bbdoc: Moves the widget to @x, @y.
	about: If @relative is True, @x and @y represent a position relative to the widget's current location.<br>
	If @refresh is True, the screen will be refreshed to show the new location.
	End Rem
	Method move(x:Int, y:Int, relative:Int, refresh:Int) Abstract
	
	Rem
	bbdoc: Injects a single character into the widget
	End Rem
	Method injectCharacter(char:Int) Abstract

	Rem
	bbdoc: Frees the widget.
	about: Detaches from the parent screen, and frees the widget and its associated memory.
	End Rem
	Method free()
	
		If screen Then
			' remove from the screen
			screen.removeWidget(Self)
			' detach the screen reference
			screen = Null
		End If

		' destroy the actual widget		
		If widgetPtr Then
			destroyCDKObject(widgetPtr)
			widgetPtr = Null
		End If
		
	End Method
	
	Method Delete()
		free()
	End Method
	
	Method getType:Int() Abstract

	Method getWindow:Byte Ptr() Abstract
	
	Rem
	bbdoc: How the wigdet was exited, or the current state.
	about:
	<table>
	<tr><th>Constant</th><th>Meaning</th></tr>
	<tr><td>vNORMAL</td><td>This means the widget exited normally. This  value is set when the widget is given the 
	characters TAB or RETURN.</td></tr>
	<tr><td>vEARLY_EXIT</td><td>This means the widget exited early. This value is set when characters are
	injected into the widget via the injectCDKXXX function and the character injected does not exit the widget.
	(ie: TAB or RETURN)</td></tr>
	<tr><td>vESCAPE_HIT</td><td>This value states the user hit ESCAPE to leave the widget.</td></tr>
	<tr><td>vNEVER_ACTIVATED</td><td>This is the initial state of the value. This means that the widget has not
	been activated.<br>You may also see this if you request the widget exitType while the widget is in focus.</td></tr>
	</table>
	End Rem
	Method exitType:Int()
	End Method

	Rem
	bbdoc: Returns the box height of the widget
	End Rem
	Method boxHeight:Int()
		Return bmx_curses_boxHeight(widgetPtr, getType())
	End Method
	
	Rem
	bbdoc: Returns the box width of the widget
	End Rem
	Method boxWidth:Int()
		Return bmx_curses_boxWidth(widgetPtr, getType())
	End Method

	Rem
	bbdoc: Returns the column (x) of the widget "window".
	End Rem
	Method getbegx:Int()
		Return bmx_curses_getbegx(getWindow())
	End Method

	Rem
	bbdoc: Returns the row (y) of the widget "window".
	End Rem
	Method getbegy:Int()
		Return bmx_curses_getbegy(getWindow())
	End Method
	
	Rem
	bbdoc: Sets the upper left hand drawing character of the widget
	End Rem
	Method setULChar(char:Int)
		bmx_curses_setULCharOf(widgetPtr, char)
	End Method

	Rem
	bbdoc: Sets the lower left hand drawing character of the widget
	End Rem
	Method setLLChar(char:Int)
		bmx_curses_setLLCharOf(widgetPtr, char)
	End Method

	Rem
	bbdoc: Sets the upper right hand drawing character of the widget
	End Rem
	Method setURChar(char:Int)
		bmx_curses_setURCharOf(widgetPtr, char)
	End Method

	Rem
	bbdoc: Sets the lower right hand drawing character of the widget
	End Rem
	Method setLRChar(char:Int)
		bmx_curses_setLRCharOf(widgetPtr, char)
	End Method
	
End Type

Type TCDKDriver

	' the main curses window
	Global mainWindow:TCursesWindow
	' list of screens in use
	Global screens:TList = New TList
	Global initialized:Int = False
	
	' the current screen.
	Global currentScreen:TCursesScreen
	
	Global focusWidget:TCursesWidget
	
	Method New()

		If Not initialized Then
		
			brl.System.Driver = New TConsoleSystemDriver
		
			mainWindow = TCursesWindow._create(initscr())
			cbreak()
			
			SetCurrentScreen(TCursesScreen.Create())
			screens.addLast(currentScreen)
			
			AddHook EmitEventHook, eventHook
			
			initCDKColor()
			initialized = True
			atexit_ cleanup

		End If
		
	End Method
	
	Function cleanup()
		For Local screen:TCursesScreen = EachIn screens
			screen.free()
		Next
		endCDK()
	End Function

	Function SetCurrentScreen(screen:TCursesScreen)
		currentScreen = screen
	End Function
	
	Function GetCurrentScreen:TCursesScreen()
		Return currentScreen
	End Function
	
	Function SetFocus(widget:TCursesWidget)
		widget.show()
		focusWidget = widget
		nodelay(widget.getWindow(), True)
	End Function
	
	Function eventHook:Object(id:Int, data:Object, context:Object)
		Local event:TEvent = TEvent(data)
		Select event.id
			Case EVENT_KEYDOWN
				If focusWidget Then
					focusWidget.injectCharacter(event.data)
					Select focusWidget.exitType()
						Case vESCAPE_HIT
							' TODO : GADGETACTION or GADGETDONE ??
							EmitEvent CreateEvent(EVENT_GADGETACTION, focusWidget, vESCAPE_HIT)
						Case vNORMAL
							EmitEvent CreateEvent(EVENT_GADGETACTION, focusWidget, vNORMAL)
					End Select
				End If
		End Select
		
		Return data
	End Function
	
End Type

Rem
bbdoc: Sets the current screen.
about: New widgets will be created on this screen.
End Rem
Function SetCurrentScreen(screen:TCursesScreen)
	TCDKDriver.SetCurrentScreen(screen)
End Function

Rem
bbdoc: Gets the current screen.
End Rem
Function GetCurrentScreen:TCursesScreen()
	Return TCDKDriver.GetCurrentScreen()
End Function

Rem
bbdoc: Sets the current widget.
End Rem
Function SetFocus(widget:TCursesWidget)
	TCDKDriver.SetFocus(widget)
End Function

Rem
bbdoc: A Curses Screen instance.
about: 
End Rem
Type TCursesScreen

	Field screenPtr:Byte Ptr
	
	Field widgets:TList = New TList
	
	Function Create:TCursesScreen()
		Local this:TCursesScreen = New TCursesScreen
		
		this.screenPtr = initCDKScreen(TCDKDriver.mainWindow.windowPtr)
		
		Return this
	End Function

	Rem
	bbdoc: Shows the screen.
	End Rem
	Method show()
		drawCDKScreen(screenPtr)
	End Method
	
	Rem
	bbdoc: Hides the screen.
	End Rem
	Method hide()
		eraseCDKScreen(screenPtr)
	End Method
	
	Rem
	bbdoc: Refreshes the screen and its widgets.
	End Rem
	Method refresh()
		refreshCDKScreen(screenptr)
	End Method
	
	Method addWidget(widget:TCursesWidget)
		widgets.addLast(widget)
		widget.screen = Self
	End Method
	
	Method removeWidget(widget:TCursesWidget)
		widgets.remove(widget)
	End Method

	Method free()
		For Local widget:TCursesWidget = EachIn widgets
			widget.free()
		Next
		destroyCDKScreen(screenPtr)
	End Method
	
End Type



Type TConsoleSystemDriver Extends TSystemDriver

	Field NativeDriver:TSystemDriver

	Method New()
		NativeDriver=brl.System.Driver
	End Method
	
	Method Poll()
		NativeDriver.Poll()
	End Method
		
	' seems a bit hacky....  but for now it works ;-)
	Method wait()
		Local mouseEvent:TMouseEvent = TMouseEvent(bmx_getmouse())
		If mouseEvent Then
			EmitEvent CreateEvent(mouseEvent.event, mouseEvent, 0, mouseEvent.x, mouseEvent.y)
		End If
		If TCDKDriver.focusWidget Then
			Local k:Int = bmx_curses_getchCDKObject(TCDKDriver.focusWidget.widgetPtr, TCDKDriver.focusWidget.getType())
			If k <> -1 Then
				EmitEvent CreateEvent( EVENT_KEYDOWN, Null, k )
				Return
			End If
		End If
		Delay(1)
		?linux
		EmitEvent CreateEvent(0)
		?win32
		Poll()
		?macos
		Poll()
		?
	End Method
	
	Method Emit( osevent:Byte Ptr,source:Object )
		Throw "oops"
	End Method

	Method IsFullScreen:Int()
		Return False
	End Method	

	Method SetMouseVisible(bool:Int)
		NativeDriver.SetMouseVisible bool
	End Method

	Method MoveMouse( x:Int, y:Int )
		NativeDriver.MoveMouse x,y
	End Method

	Rem
	internal: Notify user.
	End Rem
	Method Notify( text:String, serious:Int )
		If text = Null Then
			text = ""
		End If
		
		serious = Max(0,Min(serious, 1))

		popupLabel(StringToCenteredArray(text))
		
	End Method
	
	Rem
	internal: Request user confirmation.
	End Rem
	Method Confirm:Int( text:String, serious:Int )
		If text = Null Then
			text = ""
		End If
		
		serious = Max(0,Min(serious, 1))
		
		Local parts:String[] = StringToCenteredArray(text)
		
		If serious Then
			parts = ["</U>Warning", ""] + parts
		Else
			parts = ["</U>Info", ""] + parts
		End If

		Local dialog:TCursesDialog = TCursesDialog.Create(POS_CENTER, POS_CENTER, parts, ..
			["</B/24>Ok", "<R></B16>Cancel"], COLOR_PAIR(2) | A_REVERSE, True, True, False)
		
		Local res:Int = 0
		
		If dialog Then
			res = 1 - dialog.activate() 
		End If
		
		dialog.free()
		
		Return res
	End Method
	
	Rem
	internal: Request user confirmation or cancellation.
	End Rem
	Method Proceed:Int( text:String, serious:Int )
		If text = Null Then
			text = ""
		End If
		
		serious = Max(0,Min(serious, 1))
		
		Local parts:String[] = StringToCenteredArray(text)
		
		If serious Then
			parts = ["</U>Warning", ""] + parts
		Else
			parts = ["</U>Info", ""] + parts
		End If

		Local dialog:TCursesDialog = TCursesDialog.Create(POS_CENTER, POS_CENTER, parts, ..
			["</B/24>Yes", "</B/16>No", "<R></B16>Cancel"], COLOR_PAIR(2) | A_REVERSE, True, True, False)
		
		Local res:Int = -1
		
		If dialog Then
			res = 1 - dialog.activate() 
		End If
		
		dialog.free()
		
		Return res
	End Method

	Method RequestFile:String( text:String,exts:String, Save:Int,file:String )
		Local req:Byte Ptr
		Local f:String = Null
		Local opensave:Int
		Local reqButton:String

		Local fs:TCursesFileSelector = TCursesFileSelector.Create(POS_CENTER, POS_CENTER, 20, 65, ..
			text, Null, A_NORMAL, "_", A_REVERSE, "</5>", "</48>", "</N>", "</N>")
			
		f = fs.activate()

		fs.free()
		
		Return f
	End Method
	
	Method RequestDir:String( text:String, path:String )
		Local p:String = Null
		Local req:Byte Ptr

		' TODO

		Return p
	End Method

	Method OpenURL:Int( url:String )
		Return NativeDriver.OpenURL(url)
	End Method
	
	Method DesktopWidth:Int()
	End Method
	
	Method DesktopHeight:Int()
	End Method

	Method DesktopDepth:Int()
	End Method

	Method DesktopHertz:Int()
	End Method

End Type

Type TMouseEvent

	Field id:Int
	Field state:Int
	Field x:Int
	Field y:Int
	Field z:Int
	Field event:Int

	Function _create:TMouseEvent(id:Int, x:Int, y:Int, z:Int, state:Int) { nomangle }
		Local this:TMouseEvent = New TMouseEvent
		this.id = id
		this.x = x
		this.y = y
		this.z = z
		this.state = state
		Return this
	End Function

End Type


Type TCursesFileSelector Extends TCursesWidget

	Field titlePtr:Byte Ptr
	Field labelPtr:Byte Ptr

	Function Create:TCursesFileSelector(x:Int, y:Int, height:Int, width:Int, ..
			title:String, label:String, fieldAttribute:Int, ..
			filler:String, highlight:Int, dAttribute:String, fAttribute:String, lAttribute:String, ..
			sAttribute:String, box:Int = True, shadow:Int = False)
			
		Local this:TCursesFileSelector = New TCursesFileSelector

		this.init(x, y, height, width, title, label, fieldAttribute, filler, highlight, dAttribute, ..
			fAttribute, lAttribute, sAttribute, box, shadow)
		
		If Not this.widgetPtr Then
			this.free()
			Return Null
		End If

		TCDKDriver.currentScreen.addWidget(this)

		Return this
	End Function
	
	Method Init(x:Int, y:Int, height:Int, width:Int, title:String, label:String, fieldAttribute:Int, ..
			filler:String, highlight:Int, dAttribute:String, fAttribute:String, lAttribute:String, ..
			sAttribute:String, box:Int = True, shadow:Int = False)

		If title Then
			titlePtr = title.toCString()
		End If

		If label Then
			labelPtr = label.toCString()
		End If
		
		If Not filler Then
			filler = "_"
		End If
	
		If title Then
			If label Then
				widgetPtr = newCDKFselect(TCDKDriver.currentScreen.screenPtr, x, y, height, width, titlePtr, labelPtr, fieldAttribute, ..
					filler[0], highlight, dAttribute, fAttribute, lAttribute, sAttribute, box, shadow)
			Else
				widgetPtr = newCDKFselect(TCDKDriver.currentScreen.screenPtr, x, y, height, width, titlePtr, Null, fieldAttribute, ..
					filler[0], highlight, dAttribute, fAttribute, lAttribute, sAttribute, box, shadow)
			End If
		Else
			If label Then
				widgetPtr = newCDKFselect(TCDKDriver.currentScreen.screenPtr, x, y, height, width, Null, Null, fieldAttribute, ..
					filler[0], highlight, dAttribute, fAttribute, lAttribute, sAttribute, box, shadow)
			Else
				widgetPtr = newCDKFselect(TCDKDriver.currentScreen.screenPtr, x, y, height, width, Null, Null, fieldAttribute, ..
					filler[0], highlight, dAttribute, fAttribute, lAttribute, sAttribute, box, shadow)
			End If
		End If
		
	End Method

	Method show()
		'bmx_curses_drawCDKLabel(widgetPtr)
	End Method
	
	Method position()
		'bmx_curses_positionCDKLabel(widgetPtr)
	End Method

	Method hide()
		'bmx_curses_eraseCDKLabel(widgetPtr)
	End Method

	Method move(x:Int, y:Int, relative:Int, refresh:Int)
	End Method

	Method injectCharacter(char:Int)
	End Method

	Method getWindow:Byte Ptr()
		Return bmx_curses_CDKFselect_window(widgetPtr)
	End Method

	Method Activate:String(actions:Int = 0)
		Local ret:String = Null
		Local s:Byte Ptr = activateCDKFselect(widgetPtr, actions)
		
		If s Then
			ret = String.fromCString(s)
		End If
		
		Return ret
	End Method

	Method getType:Int()
		Return vFSELECT
	End Method

End Type

Rem
bbdoc: 
End Rem
Function popupLabel(message:String[], attribute:Int = 0)

	Local length:Int = message.length
	Local msg:Byte Ptr = arrayToCStrings(message)
	
	If Not attribute Then
	
		popupLabel_(TCDKDriver.currentScreen.screenPtr, msg, length)
		
	Else
	
		popupLabelAttrib(TCDKDriver.currentScreen.screenPtr, msg, length, attribute)
	
	End If
	
	freeCStringArray(msg, length)

End Function

Rem
bbdoc: 
End Rem
Type TCursesDialog Extends TCursesWidget

	Field message:Byte Ptr
	Field messageCount:Int
	Field _buttons:Byte Ptr
	Field buttonCount:Int
	
	Rem
	bbdoc: 
	End Rem
	Function Create:TCursesDialog(x:Int, y:Int, text:String[], buttons:String[], highlight:Int, separator:Int, box:Int, shadow:Int)
		Local this:TCursesDialog = New TCursesDialog
		
		this.init(x, y, text, buttons, highlight, separator, box, shadow)
		
		If Not this.widgetPtr Then
			this.free()
			Return Null
		End If

		TCDKDriver.currentScreen.addWidget(this)
	
		Return this
	End Function
	
	Method Init(x:Int, y:Int, text:String[], buttons:String[], highlight:Int, separator:Int, box:Int, shadow:Int)

		messageCount = text.length
		message = arrayToCStrings(text)
	
		buttonCount = buttons.length
		_buttons = arrayToCStrings(buttons)
		
		widgetPtr = newCDKDialog(TCDKDriver.currentScreen.screenPtr, x, y, message, text.length, _buttons, buttons.length, highlight, separator, box, shadow)
		
	End Method
	
	Method free()
	
		If message Then
			freeCStringArray(message, messageCount)
		End If
		
		If _buttons Then
			freeCStringArray(_buttons, buttonCount)
		End If
	
		Super.free()
	
	End Method
	
	Method show()
	
	End Method
	
	Method position()
	
	End Method
	
	Method hide()
	
	End Method

	Method move(x:Int, y:Int, relative:Int, refresh:Int)
	End Method
	
	Method injectCharacter(char:Int)
	End Method
	
	Method getWindow:Byte Ptr()
		Return bmx_curses_CDKDialog_window(widgetPtr)
	End Method

	Rem
	bbdoc: Returns the currently selected button.
	End Rem
	Method currentButton:Int()
		Return bmx_dialog_currentButton(widgetPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method Activate:Int(actions:Int = 0)
	
		Return activateCDKDialog(widgetPtr, actions)
	
	End Method

	Method getType:Int()
		Return vDIALOG
	End Method

End Type



Type TCursesPanel

	Field panelPtr:Byte Ptr
	Field window:TCursesWindow
	
	Function Create:TCursesPanel(window:TCursesWindow)
		Local this:TCursesPanel = New TCursesPanel
	
		this.window = window
		this.panelPtr = new_panel(window.windowPtr)
	
		Return this
	End Function

	Method bottom()
		bottom_panel(panelPtr)
	End Method
	
	Method hide()
		hide_panel(panelPtr)
	End Method
	
	Method show()
		show_panel(panelPtr)
	End Method
	
	Method move(x:Int, y:Int)
		move_panel(panelPtr, x, y)
	End Method
	
	Method top()
		top_panel(panelPtr)
	End Method
	
	Method isHidden:Int()
		Return panel_hidden(panelPtr)
	End Method
	
	
End Type

Rem
bbdoc: A Curses Window.
End Rem
Type TCursesWindow

	Field windowPtr:Byte Ptr
	
	Rem
	bbdoc: Creates a new window of the given dimensions at the specific coordinates.
	End Rem
	Function Create:TCursesWindow(x:Int, y:Int, w:Int, h:Int)
		Local this:TCursesWindow = New TCursesWindow
		this.windowPtr = newwin(h, w, x, y)
		If this.windowPtr Then
			Return this
		End If
	End Function
	
	' private
	Function _create:TCursesWindow(windowPtr:Byte Ptr)
		If windowPtr Then
			Local this:TCursesWindow = New TCursesWindow
			this.windowPtr = windowPtr
			Return this
		End If
	End Function
	
	Rem
	bbdoc: Writes the characters of the string on the window.
	returns: 0 on success, -1 on error.
	about: If maxChars is -1, then the entire string will be added, up to  the  maximum
	number of characters that will fit on the line, otherwise only the specified count of characters
	will be added.
	End Rem
	Method addStr:Int(text:String, maxChars:Int = -1)
		Return bmx_curses_waddstr(windowPtr, text, maxChars)
	End Method
	
	Rem
	bbdoc: Moves the cursor to (x, y) and then writes the characters string on the window.
	returns: 0 on success, -1 on error.
	about: If maxChars is -1, then the entire string will be added, up to  the  maximum
	number of characters that will fit on the line, otherwise only the specified count of characters
	will be added.
	End Rem
	Method moveAddStr:Int(x:Int, y:Int, text:String, maxChars:Int = -1)
		Return bmx_curses_mvwaddstr(windowPtr, x, y, text, maxChars)
	End Method
	
	Rem
	bbdoc: Moves the window so that the upper left-hand corner is at position (x, y).
	about: If the move would cause  the  window  to be off the screen, it is an error and the window is not moved.
	End Rem
	Method move:Int(x:Int, y:Int)
		Return mvwin(windowPtr, y, x)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method free()
		If windowPtr Then
			delwin(windowPtr)
			windowPtr = Null
		End If
	End Method
	
	Method Delete()
		free()
	End Method
	
End Type

Rem
bbdoc: 
End Rem
Function mousemask:Int(mask:Int, oldMask:Int Var)
	Return bmx_mousemask(mask, Varptr oldMask)
End Function

Rem
bbdoc: 
End Rem
Function shell:Int(command:String = Null)
	Local ret:Int
	
	def_prog_mode()
	endwin()
	If Not command Then
		ret = system_("sh")
	Else
		ret = system_(command)
	End If
	refresh()
	
	Return ret
End Function 

Rem
bbdoc: Left Tee.
about: Tee pointing to the right
End Rem
Global ACS_LTEE:Int = ACS_LTEE_()
Rem
bbdoc: Right Tee.
about: Tee pointing to the left
End Rem
Global ACS_RTEE:Int = ACS_RTEE_()
Rem
bbdoc: Bottom Tee.
about: Tee pointing up
End Rem
Global ACS_BTEE:Int = ACS_BTEE_()
Rem
bbdoc: Top Tee.
about: Tee pointing down
End Rem
Global ACS_TTEE:Int = ACS_TTEE_()
Rem
bbdoc: Upper left corner.
End Rem
Global ACS_ULCORNER:Int = ACS_ULCORNER_()
Rem
bbdoc: Lower left corner.
End Rem
Global ACS_LLCORNER:Int = ACS_LLCORNER_()
Rem
bbdoc: Upper right corner.
End Rem
Global ACS_URCORNER:Int = ACS_URCORNER_()
Rem
bbdoc: Lower right corner.
End Rem
Global ACS_LRCORNER:Int = ACS_LRCORNER_()
Rem
bbdoc: Horizontal line.
End Rem
Global ACS_HLINE:Int = ACS_HLINE_()
Rem
bbdoc: Vertical line.
End Rem
Global ACS_VLINE:Int = ACS_VLINE_()
Rem
bbdoc: Large plus or crossover.
End Rem
Global ACS_PLUS:Int = ACS_PLUS_()
Rem
bbdoc: Scan line 1.
End Rem
Global ACS_S1:Int = ACS_S1_()
Rem
bbdoc: Scan line 9.
End Rem
Global ACS_S9:Int = ACS_S9_()
Rem
bbdoc: Diamond.
End Rem
Global ACS_DIAMOND:Int = ACS_DIAMOND_()
Rem
bbdoc: Checker board (stipple).
End Rem
Global ACS_CKBOARD:Int = ACS_CKBOARD_()
Rem
bbdoc: Degree symbol.
End Rem
Global ACS_DEGREE:Int = ACS_DEGREE_()
Rem
bbdoc: Plus/minus.
End Rem
Global ACS_PLMINUS:Int = ACS_PLMINUS_()
Rem
bbdoc: Bullet.
End Rem
Global ACS_BULLET:Int = ACS_BULLET_()
Rem
bbdoc: Arrow pointing left.
End Rem
Global ACS_LARROW:Int = ACS_LARROW_()
Rem
bbdoc: Arrow pointing right.
End Rem
Global ACS_RARROW:Int = ACS_RARROW_()
Rem
bbdoc: Arrow pointing down.
End Rem
Global ACS_DARROW:Int = ACS_DARROW_()
Rem
bbdoc: Arrow pointing up.
End Rem
Global ACS_UARROW:Int = ACS_UARROW_()
Rem
bbdoc: Board of squares.
End Rem
Global ACS_BOARD:Int = ACS_BOARD_()
Rem
bbdoc: Lantern symbol.
End Rem
Global ACS_LANTERN:Int = ACS_LANTERN_()
Rem
bbdoc: Solid square block.
End Rem
Global ACS_BLOCK:Int = ACS_BLOCK_()
Rem
bbdoc: Mouse button 1 up.
End Rem
Global BUTTON1_RELEASED:Int = BUTTON1_RELEASED_()
Rem
bbdoc: Mouse button 1 down.
End Rem
Global BUTTON1_PRESSED:Int = BUTTON1_PRESSED_()
Rem
bbdoc: Mouse button 1 clicked.
End Rem
Global BUTTON1_CLICKED:Int = BUTTON1_CLICKED_()
Rem
bbdoc: Mouse button 1 double clicked.
End Rem
Global BUTTON1_DOUBLE_CLICKED:Int = BUTTON1_DOUBLE_CLICKED_()
Rem
bbdoc: Mouse button 1 triple clicked.
End Rem
Global BUTTON1_TRIPLE_CLICKED:Int = BUTTON1_TRIPLE_CLICKED_()
Rem
bbdoc: Mouse button 2 up.
End Rem
Global BUTTON2_RELEASED:Int = BUTTON2_RELEASED_()
Rem
bbdoc: Mouse button 2 down.
End Rem
Global BUTTON2_PRESSED:Int = BUTTON2_PRESSED_()
Rem
bbdoc: Mouse button 2 clicked.
End Rem
Global BUTTON2_CLICKED:Int = BUTTON2_CLICKED_()
Rem
bbdoc: Mouse button 2 double clicked.
End Rem
Global BUTTON2_DOUBLE_CLICKED:Int = BUTTON2_DOUBLE_CLICKED_()
Rem
bbdoc: Mouse button 2 triple clicked.
End Rem
Global BUTTON2_TRIPLE_CLICKED:Int = BUTTON2_TRIPLE_CLICKED_()
Rem
bbdoc: Mouse button 3 up.
End Rem
Global BUTTON3_RELEASED:Int = BUTTON3_RELEASED_()
Rem
bbdoc: Mouse button 3 down.
End Rem
Global BUTTON3_PRESSED:Int = BUTTON3_PRESSED_()
Rem
bbdoc: Mouse button 3 clicked.
End Rem
Global BUTTON3_CLICKED:Int = BUTTON3_CLICKED_()
Rem
bbdoc: Mouse button 3 double clicked.
End Rem
Global BUTTON3_DOUBLE_CLICKED:Int = BUTTON3_DOUBLE_CLICKED_()
Rem
bbdoc: Mouse button 3 triple clicked.
End Rem
Global BUTTON3_TRIPLE_CLICKED:Int = BUTTON3_TRIPLE_CLICKED_()
Rem
bbdoc: Mouse button 4 up.
End Rem
Global BUTTON4_RELEASED:Int = BUTTON4_RELEASED_()
Rem
bbdoc: Mouse button 4 down.
End Rem
Global BUTTON4_PRESSED:Int = BUTTON4_PRESSED_()
Rem
bbdoc: Mouse button 4 clicked.
End Rem
Global BUTTON4_CLICKED:Int = BUTTON4_CLICKED_()
Rem
bbdoc: Mouse button 4 double clicked.
End Rem
Global BUTTON4_DOUBLE_CLICKED:Int = BUTTON4_DOUBLE_CLICKED_()
Rem
bbdoc: Mouse button 4 triple clicked.
End Rem
Global BUTTON4_TRIPLE_CLICKED:Int = BUTTON4_TRIPLE_CLICKED_()
Rem
bbdoc: Control was down during button state change.
End Rem
Global BUTTON_CTRL:Int = BUTTON_CTRL_()
Rem
bbdoc: Shift was down during button state change.
End Rem
Global BUTTON_SHIFT:Int = BUTTON_SHIFT_()
Rem
bbdoc: Alt was down during button state change.
End Rem
Global BUTTON_ALT:Int = BUTTON_ALT_()
Rem
bbdoc: Report mouse movement.
End Rem
Global REPORT_MOUSE_POSITION:Int = REPORT_MOUSE_POSITION_()

Rem
bbdoc: Report all button state changes.
End Rem
Global ALL_MOUSE_EVENTS:Int = ALL_MOUSE_EVENTS_()

Rem
bbdoc: 
End Rem
Global LINES:Int = LINES_()
Rem
bbdoc: 
End Rem
Global COLS:Int = COLS_()

