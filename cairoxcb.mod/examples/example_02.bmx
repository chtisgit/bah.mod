SuperStrict

Framework BaH.CairoXCB
Import brl.polledinput
Import brl.timer

EnablePolledInput()

Local win:TXCBWindow = New TWindow.Create("Cairo XCB Clock", Null, 0, 0, 300, 300)
win.show()

While Not AppTerminate() 
	WaitSystem()
Wend



Type TWindow Extends TXCBWindow

	Field cairo:TCairo
	Field surface:TCairoXCBSurface
	
	Field pix:TXCBPixmap
	
	Field timer:TTimer
	
	Method OnInit()
	
		pix = New TXCBPixmap.Create(300, 300)
	
		surface = TCairoXCBSurface.CreateForXCB(pix)
		cairo = TCairo.Create(surface)
		
		DrawClock()
		
		timer = CreateTimer(1)
		AddHook EmitEventHook,TimerHook,Self,0
	End Method
	
	Function TimerHook:Object( id:Int,data:Object,context:Object )

		Local ev:TEvent=TEvent(data)
		If Not ev Return data

		Local win:TWindow = TWindow(context)
		If Not win Return data

		If ev.id = EVENT_TIMERTICK Then
			win.DrawClock()
			win.OnPaint()
		End If
		
		Return data
	End Function
	
	Method OnPaint()

		CopyPixmap(pix, 0, 0, 0, 0, pix.width, pix.height)
		
		' flush changes to screen
		Flush()
	End Method
	
	Method OnSize(w:Int, h:Int)
		If width <> w Or height <> h Then
			pix = New TXCBPixmap.Create(w, h)
			surface.SetDrawable(pix, w, h)
			DrawClock()
			OnPaint()
		End If
	End Method
	
	Method DrawClock()
		' clear
		cairo.setSourceRgb(1, 1, 1)
		cairo.paint()
		
		draw()

		surface.Flush()
	End Method

	Method draw()
		Local x:Double = width / 2.0
		Local y:Double = height / 2.0
		Local radius:Double = Min (width / 2.0, height / 2.0) - 5.0
	
		' clock back
		cairo.arc(x, y, radius, 0, 360)
		cairo.setSourceRgb(1, 1, 1)
		cairo.fillPreserve()
		cairo.setSourceRgb(0, 0, 0)
		cairo.stroke()
	
		cairo.SelectFontFace( "tahoma", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
		cairo.SetFontSize( 12 )
		
		' clock ticks
		For Local i:Int = 0 Until 12
			Local inset:Double = 0
		
			cairo.Save() ' stack-pen-size
			
			If i Mod 3 = 0 Then
				inset = 0.2 * radius
			Else
				inset = 0.1 * radius
				cairo.SetLineWidth(0.5 * cairo.GetLineWidth())
			End If
			
			cairo.moveTo(x + (radius - inset) * Cos(i * 30), y + (radius - inset) * Sin(i * 30))
			cairo.lineTo(x + radius * Cos(i * 30), y + radius * Sin (i * 30))
			cairo.stroke()
			cairo.restore() ' stack-pen-size
			
			' draw numbers
			inset = 0.3 * radius
			cairo.moveTo(x + (radius - inset) * Cos(i * 30) - 7, y + (radius - inset) * Sin(i * 30) + 4)
			' the circle starts at 3 o'clock so we need to adjust the digits accordingly
			Local t:Int = (i + 2) Mod 12 + 1
			cairo.ShowText( romanNumerals(t) )
		Next
		
		cairo.SelectFontFace( "arial", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
		cairo.SetFontSize( 12 )
		cairo.moveTo(x - 17, y + 30)
		cairo.ShowText("Cairo")
		
		
		' clock hands
		Local hours:Int = CurrentTime()[0..2].toInt() Mod 12
		Local minutes:Int = CurrentTime()[3..5].toInt()
		Local seconds:Int = CurrentTime()[6..8].toInt()
		
		' hour hand:
		' the hour hand is rotated 30 degrees  per hour + 1/2 a degree per minute
		'
		cairo.Save()
		cairo.SetLineWidth(2.5 * cairo.GetLineWidth())
		cairo.moveTo(x, y)
		cairo.lineTo(x + radius / 2 * Sin(30 * hours + minutes / 2.0), ..
				   y + radius / 2 * -Cos(30 * hours + minutes / 2.0))
		cairo.stroke()
		cairo.restore()
		
		' minute hand:
		' the minute hand is rotated 6 degrees per minute + 1/10 a degree per second
		'
		cairo.moveTo(x, y)
		cairo.lineTo(x + radius * 0.75 * Sin(6 * minutes + seconds / 10.0), ..
				   y + radius * 0.75 * -Cos(6 * minutes + seconds / 10.0))
		cairo.stroke()
		
		' seconds hand:
		' he second hand is rotated 6 degrees per second
		'
		cairo.save()
		cairo.setSourceRgb(1, 0, 0) ' red
		cairo.moveTo(x, y)
		cairo.lineTo(x + radius * 0.7 * Sin(6 * seconds), ..
				   y + radius * 0.7 * -Cos(6 * seconds))
		cairo.stroke()
		cairo.restore()
	End Method
	
	Method romanNumerals:String(value:Int)
		Local rn:String = ""
		
		While value > 9
			rn:+ "X"
			value:- 10
		Wend
	
		If value > 8 Then
			rn:+ "IX"
			value:- 9
		End If
		
		If value > 4 Then
			rn:+ "V"
			value:- 5
		End If
		
		If value > 3 Then
			rn:+ "IV"
			value:- 4
		End If
		
		While value > 0
			rn:+ "I"
			value:- 1
		Wend
		
		Return rn
	End Method
End Type

