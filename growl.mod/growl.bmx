' Copyright (c) 2008, Bruce A Henderson
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

Rem
bbdoc: Growl
End Rem
Module BaH.Growl

ModuleInfo "Version: 1.00"
ModuleInfo "License: BSD"
ModuleInfo "Copyright: 2008 Bruce A Henderson"

ModuleInfo "History: 1.00 Initial Release (Growl 1.1.2)"

ModuleInfo "LD_OPTS: -F%PWD%/Frameworks"

?macos

Import BRL.Map

Import "common.bmx"


Rem
bbdoc: Determines whether the Growl prefpane and its helper app are installed.
returns: True if Growl is installed, False otherwise.
End Rem
Function IsGrowlInstalled:Int()
	Return bmx_Growl_IsInstalled()
End Function

Rem
bbdoc: Cycles through the process list to find whether GrowlHelperApp is running.
returns: Ttrue if Growl is running, False otherwise. 
End Rem
Function IsGrowlRunning:Int()
	Return bmx_Growl_IsRunning()
End Function

Rem
bbdoc: Delegate to supply GrowlApplicationBridge with information and respond to events.
about: The Growl delegate provides your interface to
 GrowlApplicationBridge. When GrowlApplicationBridge needs information about
 your application, it looks for it in the delegate; when Growl or the user
  does something that you might be interested in, GrowlApplicationBridge
  looks for a callback in the delegate and calls it if present
  (meaning, if it is not <code>NULL</code>).
End Rem
Type TGrowlDelegate

	Global delegate:TGrowlDelegate

	Field growlPtr:Byte Ptr
	
	Field dict:TMap = New TMap
	
	Field hasSetDictionary:Int = False
	Field isSet:Int = False
	
	Rem
	bbdoc: Returns the global delegate, or Null if one hasn't been created.
	End Rem
	Function GetDelegate:TGrowlDelegate()
		Return delegate
	End Function
	
	Rem
	bbdoc: Creates an instance of TGrowlDelegate
	End Rem
	Function CreateGrowlDelegate:TGrowlDelegate()
		Return New TGrowlDelegate.Create()
	End Function
	
	Rem
	bbdoc: Creates an instance of TGrowlDelegate
	End Rem
	Method Create:TGrowlDelegate()
		Return delegate
	End Method
	
	Method New()
		If Not delegate Then
			delegate = Self
			growlPtr = bmx_Growl_Delegate_create()
		End If
	End Method

	Rem
	bbdoc: Installs the delegate with the Growl framework.
	returns: True if install was successful, False otherwise.
	End Rem
	Method Install:Int()
		If Not hasSetDictionary Then
			SetRegistrationDictionary()
			hasSetDictionary = True
		End If
		isSet = bmx_Growl_SetDelegate(growlPtr)
		Return isSet
	End Method
	
	Rem
	bbdoc: The name of your application.
	about: This name is used both for user display and for internal bookkeeping, so it should
	clearly identify your application (but it should not be your bundle identifier, because it
	will be displayed to the user) and it should not change between versions and incarnations
	(so don't include a version number or “Lite”, “Pro”, etc.).
	End Rem
	Method SetApplicationName(name:String)
		bmx_growldelegate_setapplicationname(growlPtr, name)
		SetApplicationId(name)
	End Method
	
	Method SetApplicationId(id:String)
		dict.Insert(GROWL_APP_ID, id)
	End Method
	
	Rem
	bbdoc: Sets the application icon data.
	about: The data can be in any format supported by NSImage. As of
	Mac OS X 10.3, this includes the .icns, TIFF, JPEG, GIF, PNG, PDF, and
	PICT formats.
	<p>
	If this is not supplied, Growl will look up your application's icon by
	its application name.
	</p>
	<p>
	Note, that due to the nature of the framework, this method expects a <b>raw</b> image, in
	its original format. e.g. PNG image data.<br>
	You might load wish to pass in a Bank Byte Ptr, or perhaps an IncBinPtr(), etc.
	</p>
	End Rem
	Method SetApplicationIconData(image:Byte Ptr, size:Int)
		bmx_growldelegate_setapplicationicondata(growlPtr, image, size)
	End Method
	
	Rem
	bbdoc: Sets all notifications the application supports.
	End Rem
	Method SetAllNotifications(notifications:String[])
		dict.Insert(GROWL_NOTIFICATIONS_ALL, notifications)
	End Method

	Rem
	bbdoc: Sets the list of notifications enabled by default.
	End Rem
	Method SetDefaultNotifications(notifications:String[])
		dict.Insert(GROWL_NOTIFICATIONS_DEFAULT, notifications)
	End Method
	
	Rem
	bbdoc: Sets the delegate registration dictionary.
	End Rem
	Method SetRegistrationDictionary()
		
		Local defaults:Object = dict.ValueForKey(GROWL_NOTIFICATIONS_DEFAULT)
		If Not defaults Then
			defaults = dict.ValueForKey(GROWL_NOTIFICATIONS_ALL)
		End If
		
		bmx_growldelegate_setregistrationdictionary_array(growlPtr, ..
			dict.ValueForKey(GROWL_NOTIFICATIONS_ALL), ..
			defaults, ..
			String(dict.ValueForKey(GROWL_APP_ID)) )
	End Method
	
End Type

Rem
bbdoc: Structure describing a Growl notification.
End Rem
Type TGrowlNotification

	Field growlPtr:Byte Ptr

	Rem
	bbdoc: Creates a new notification instance, with the notification @name, @title and optional @description.
	about: @name should match a value previously declared in the delegate registration dictionary.
	End Rem
	Function CreateGrowlNotification:TGrowlNotification(name:String, title:String, description:String = "")
		Return New TGrowlNotification.Create(name, title, description)
	End Function
	
	Rem
	bbdoc: Creates a new notification instance, with the notification @name, @title and optional @description.
	about: @name should match a value previously declared in the delegate registration dictionary.
	End Rem
	Method Create:TGrowlNotification(name:String, title:String, description:String = "")
		growlPtr = bmx_Growl_Notification_create(name, title, description)
		Return Self
	End Method

	Rem
	bbdoc: Posts a Growl notification.
	about: If using the Growl-WithInstaller framework, if Growl is not installed the
	user will be prompted to install Growl.
	If the user cancels, this method will have no effect until the next
	application session, at which time when it is called the user will be
	prompted again. The user is also given the option to not be prompted again.
	If the user does choose to install Growl, the requested notification will
	be displayed once Growl is installed and running.
	End Rem
	Method Post()
		bmx_Growl_PostNotification(growlPtr)
	End Method
	
	Rem
	bbdoc: Sets the notification name.
	about: The notification name distinguishes one type of
	notification from another. The name should be human-readable, as it
	will be displayed in the Growl preference pane.
	<p>
	The name is used in the GROWL_NOTIFICATIONS_ALL and
	GROWL_NOTIFICATIONS_DEFAULT arrays in the registration dictionary.
	</p>
	End Rem
	Method SetName(name:String)
		bmx_Growl_Notification_setname(growlPtr, name)
	End Method

	Rem
	bbdoc: Sets the notification title.
	about: A notification's title describes the notification briefly.
	<p>
	It should be easy to read quickly by the user.
	</p>
	End Rem
	Method SetTitle(title:String)
		bmx_Growl_Notification_settitle(growlPtr, title)
	End Method

	Rem
	bbdoc: Sets the notification description.
	about: The description supplements the title with more
	information. It is usually longer and sometimes involves a list of
	subjects. For example, for a 'Download complete' notification, the
	description might have one filename per line. GrowlMail in Growl 0.6
	uses a description of '%d new mail(s)' (formatted with the number of
	messages).
	End Rem
	Method SetDescription(description:String)
		bmx_Growl_Notification_setdescription(growlPtr, description)
	End Method
	
	Rem
	bbdoc: Sets the notification priority.
	about: Priority is represented as an integer from -2 to +2.
	0 is Normal priority, -2 is Very Low priority, and +2 is Very High priority.
	<p>
	Not all displays support priority. If you do not wish to assign a
	priority to your notification, assign 0.
	</p>
	End Rem
	Method SetPriority(priority:Int)
		bmx_Growl_Notification_setpriority(growlPtr, priority)
	End Method
	
	Rem
	bbdoc: Sets the notification icon.
	about: The notification icon usually indicates either what
	happened (it may have the same icon as e.g. a toolbar item that
	started the process that led to the notification), or what it happened
	to (e.g. a document icon).
	<p>
	Note, that due to the nature of the framework, this method expects a <b>raw</b> image, in
	its original format. e.g. PNG image data.<br>
	You might load wish to pass in a Bank Byte Ptr, or perhaps an IncBinPtr(), etc.
	</p>
	End Rem
	Method SetIconData(pix:Byte Ptr = Null, size:Int = 0)
		bmx_Growl_Notification_seticondata(growlPtr, pix, size)
	End Method

	Method Delete()
		If growlPtr Then
			bmx_Growl_Notification_delete(growlPtr)
			growlPtr = Null
		End If
	End Method

End Type

?macos
