#tag Class
Protected Class Session
Inherits WebSession
	#tag Constant, Name = ErrorDialogCancel, Type = String, Dynamic = True, Default = \"Do Not Send", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ErrorDialogMessage, Type = String, Dynamic = True, Default = \"This application has encountered an error and cannot continue.", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ErrorDialogQuestion, Type = String, Dynamic = True, Default = \"Please describe what you were doing right before the error occurred:", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ErrorDialogSubmit, Type = String, Dynamic = True, Default = \"Send", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ErrorThankYou, Type = String, Dynamic = True, Default = \"Thank You", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ErrorThankYouMessage, Type = String, Dynamic = True, Default = \"Your feedback helps us make improvements.", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NoJavascriptInstructions, Type = String, Dynamic = True, Default = \"To turn Javascript on\x2C please refer to your browser settings window.", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NoJavascriptMessage, Type = String, Dynamic = True, Default = \"Javascript must be enabled to access this page.", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="GMTOffsetInSeconds"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_baseurl"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScaleFactor"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Browser"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="BrowserType"
			EditorType="Enum"
			#tag EnumValues
				"0 - Unknown"
				"1 - Safari"
				"2 - Chrome"
				"3 - Firefox"
				"4 - InternetExplorer"
				"5 - Opera"
				"6 - ChromeOS"
				"7 - SafariMobile"
				"8 - Android"
				"9 - Blackberry"
				"10 - OperaMini"
				"11 - Epiphany"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Connection"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="ConnectionType"
			EditorType="Enum"
			#tag EnumValues
				"0 - AJAX"
				"1 - WebSocket"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Platform"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="PlatformType"
			EditorType="Enum"
			#tag EnumValues
				"0 - Unknown"
				"1 - Macintosh"
				"2 - Windows"
				"3 - Linux"
				"4 - Wii"
				"5 - PS3"
				"6 - iPhone"
				"7 - iPodTouch"
				"8 - Blackberry"
				"9 - WebOS"
				"10 - iPad"
				"11 - AndroidTablet"
				"12 - AndroidPhone"
				"13 - RaspberryPi"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="RenderingEngine"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="EngineType"
			EditorType="Enum"
			#tag EnumValues
				"0 - Unknown"
				"1 - WebKit"
				"2 - Gecko"
				"3 - Trident"
				"4 - Presto"
				"5 - EdgeHTML"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mConnection"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="ConnectionType"
			EditorType="Enum"
			#tag EnumValues
				"0 - AJAX"
				"1 - WebSocket"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="_hasQuit"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ActiveConnectionCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BrowserVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ConfirmMessage"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="GMTOffset"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HashTag"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HeaderCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Identifier"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LanguageCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LanguageRightToLeft"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PageCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Protocol"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RemoteAddress"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusMessage"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Timeout"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Title"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="URL"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_Expiration"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
