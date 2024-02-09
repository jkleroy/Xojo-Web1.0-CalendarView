#tag Class
Protected Class WebColorSelector
Inherits WebControlWrapper
	#tag Event
		Function ExecuteEvent(Name as String, Parameters() as Variant) As Boolean
		  If not self.Enabled then Return False
		  
		  Select Case Name
		  Case "selectColor"
		    Dim id As Integer = Parameters(0)
		    
		    
		    
		    If Type = TypeCheckbox then
		      If UBound(Selections) < id then
		        ReDim Selections(id)
		      End If
		      
		      Selections(id) = not Selections(id)
		      
		    else
		      
		      mSelected = id
		    End If
		    
		    RaiseEvent SelectColor(id, Colors(id), FormatColor(Colors(id)))
		    
		    //Can update this for less web data
		    Redraw()
		    
		    
		    
		    Return True
		    
		    
		    
		  End Select
		End Function
	#tag EndEvent

	#tag Event
		Sub FrameworkPropertyChanged(Name as String, Value as Variant)
		  //Only send changes to the browser if the Shown event has fired. Otherwise, they should be rendered in the InitialHTML event.
		  If ControlAvailableInBrowser Then
		    Select Case Name
		    Case "Enabled"
		      Dim js As String
		      If value Then
		        js = "Xojo.get('" + Me.ControlID + "').style.opacity = 1; Xojo.get('" + Me.ControlID + "').style.cursor = 'auto';"
		      Else
		        js = "Xojo.get('" + Me.ControlID + "').style.opacity = 0.5; Xojo.get('" + Me.ControlID + "').style.cursor = 'default';"
		      End If
		      ExecuteJavaScript(js)
		      
		    Case "Visible"
		      Dim js As String
		      If value then
		        js = "Xojo.get('" + Me.ControlID + "').style.visibility = ""visible"";"
		      Else
		        js = "Xojo.get('" + Me.ControlID + "').style.visibility = ""hidden"";"
		      End If
		      ExecuteJavaScript(js)
		      
		    End Select
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub Hidden()
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  
		  DelayedAutoUpdate = New Timer
		  DelayedAutoUpdate.Mode = timer.ModeSingle
		  DelayedAutoUpdate.Period = 10000*(1.0+Rnd)
		  
		  AddHandler DelayedAutoUpdate.Action, AddressOf AutoUpdate
		  
		  
		  Open()
		  
		  If myPicSelected is Nil then
		    
		    Dim p As Picture = Picture.FromData(DecodeBase64(picSelected))
		    myPicSelected = New WebPicture(p)
		    
		  End If
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resized()
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub SetupCSS(ByRef Styles() as WebControlCSS)
		  styles(0).value("visibility") = "visible" // Every WebSDK control needs this
		  
		  Dim xHeight As Integer
		  If Width > Height then
		    xHeight = Height
		  else
		    xHeight = 22
		  End If
		  
		  Dim st As new WebControlCSS
		  st.Selector="." + self.ControlID + "-inline-block"
		  st.Value("position") = "relative"
		  st.Value("display") = "inline-block"
		  Styles.Append st
		  
		  st = new WebControlCSS
		  st.Selector = "." + self.ControlID + "-color-pick"
		  st.Value("cursor") = "pointer"
		  st.Value("clear") = "both"
		  st.Value("margin-right") = "5px"
		  st.Value("margin-bottom") = "5px"
		  st.Value("width") = str(xHeight-2) + "px"
		  st.Value("height") = str(xHeight-2) + "px"
		  st.Value("border") = "1px dotted #333"
		  Styles.Append st
		  
		  st = new WebControlCSS
		  st.Selector = "." + self.ControlID + "-color-pick:hover"
		  st.Value("border") = "1px solid #000"
		  Styles.Append st
		  
		  st = new WebControlCSS
		  st.Selector = "." + self.ControlID + "-text"
		  st.Value("cursor") = "pointer"
		  st.Value("margin-right") = "5px"
		  st.Value("margin-bottom") = "5px"
		  st.Value("margin-left") = "-2px"
		  st.Value("height") = str(xHeight) + "px"
		  st.Value("vertical-align") = "text-bottom"
		  st.Value("display") = "inline-block"
		  Styles.Append st
		  
		  st = new WebControlCSS
		  st.Selector = "." + self.ControlID + "-selected"
		  st.Value("background") = "url(" + myPicSelected.URL + ")"
		  st.Value("width") = str(myPicSelected.Width)+"px"
		  st.Value("height") = str(myPicSelected.Height)+"px"
		  st.Value("margin") = str((xHeight-myPicSelected.Height)/2) + "px"
		  st.Value("position") = "relative"
		  st.Value("vertical-align") = "top"
		  st.Value("left") = "-1px"
		  st.Value("top") = "-1px"
		  Styles.Append st
		End Sub
	#tag EndEvent

	#tag Event
		Function SetupHTML() As String
		  Dim sty As String = ""
		  Dim cla As String
		  If Not Self.Enabled Then
		    'sty = " style=""opacity:0.5;cursor:default"""
		  End If
		  
		  If Width > Height then
		    'sty = " style=""width:" + str((me.Height-2+5)*(UBound(Colors)+1)) + "px"""
		    sty = " style=""width: auto;"""
		  else
		    sty = " style=""overflow-y: auto;"""
		  End If
		  
		  If me.Style <> Nil then
		    cla = " class=""" + me.Style.Name + """"
		  End If
		  
		  Return "<div id=""" + self.ControlID + """" + cla + sty + ">" + GetHTML + "</div>"
		End Function
	#tag EndEvent

	#tag Event
		Function SetupJavascriptFramework() As String
		  //
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddColor(C As Color, Caption As String = "")
		  Colors.Append C
		  
		  If Caption <> "" then
		    Captions.Append Caption
		  End If
		  
		  Selections.Append False
		  
		  Redraw()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AutoUpdate(caller As Timer)
		  
		  
		  #if DebugBuild
		    
		    Dim Product As String = me.kProductKey
		    #if TargetWeb
		      If kProductKey.left(3) <> "Web" then
		        Product = "Web" + kProductKey
		      End If
		    #Endif
		    
		    If not System.Network.IsConnected then
		      Return
		    End If
		    Dim f As FolderItem
		    try
		      f = SpecialFolder.ApplicationData.Child("JeremieLeroy.com")
		      If f Is Nil or not f.exists then f.CreateAsFolder
		      f = f.Child(Product)
		      If f Is Nil or not f.exists then f.CreateAsFolder
		      f = f.Child("config.ini")
		    Catch
		      
		    End Try
		    
		    Dim txt As String
		    Dim lastcheck As new date
		    Dim d As new date
		    lastcheck.Month = d.Month-2
		    If f <> Nil and f.Exists then
		      Dim ti As TextInputStream
		      ti = ti.Open(f)
		      
		      While txt.left(4) <> "last" and not ti.EOF
		        txt = ti.ReadLine
		      Wend
		      
		      If txt.Left(4) = "last" then
		        lastcheck.SQLDateTime = txt.NthField("=", 2)
		        
		        If lastcheck.TotalSeconds + 172800.0 > d.TotalSeconds then
		          'If lastcheck.TotalSeconds + 20 > d.TotalSeconds then
		          Return
		        End If
		      End If
		    End If
		    
		    
		    
		    Dim update As New HTTPSocket
		    Dim result As String = update.Get("http://live.jeremieleroy.com/autoupdate.php?item=" + product + "&version=" +_
		    str(me.kVersion) + "&xojo=" + XojoVersionString + "&reg=" + str(Registered) + "&limit=" + str(mLimitDate) , 5)
		    
		    Dim updateAvailable As Boolean = True
		    
		    
		    If left(Result, len(Product)) <> Product then
		      updateAvailable = False
		    End If
		    
		    If NthField(result, ":", 2) = "" or NthField(result, ":", 2) = "no update" then
		      updateAvailable = False
		    End If
		    
		    Dim ts As TextOutputStream
		    If f <> Nil Then
		      ts = TextOutputStream.Create(f)
		      ts.Write "[Settings]" + EndOfLine
		      ts.Write "lastcheck=" + d.SQLDateTime
		      ts.Close
		    End If
		    
		    If updateAvailable Then
		      #If TargetWeb
		        Msgbox("New version available" + EndOfLine + EndOfLine + _
		        "New version of the " + kProductKey + " is available." + EndOfLine + _
		        NthField(result, ":", 2) + EndOfLine + _
		        EndOfLine + _
		        "Would you like to download the update now ?" + EndOfLine + EndOfLine + _
		        "(This message will only appear in DebugBuild)")
		        
		        ShowURL("http://www.jeremieleroy.com/products.php#" + kProductKey, True)
		      #elseif TargetDesktop
		        
		        Dim n As new MessageDialog
		        Dim b As MessageDialogButton
		        n.ActionButton.Caption = "Update"
		        n.CancelButton.Visible = True
		        n.CancelButton.Caption = "Later"
		        
		        n.Title = "New version available"
		        n.Message = "New version of the " + kProductKey + " is available." + EndOfLine + _
		        NthField(result, ":", 2) + EndOfLine + _
		        EndOfLine + _
		        "Would you like to download the update now ?" + EndOfLine + EndOfLine + _
		        "(This message will only appear in DebugBuild)"
		        
		        b=n.ShowModal //display the dialog
		        Select Case b //determine which button was pressed.
		        Case n.ActionButton
		          ShowURL("http://www.jeremieleroy.com/products.php#" + kProductKey)
		        Case n.CancelButton
		          //user pressed Cancel
		        End select
		      #endif
		    End If
		    
		    
		  #else
		    If not Registered then
		      #If TargetWeb
		        
		      #Else
		        Dim d As new MessageDialog
		        Dim b As MessageDialogButton
		        
		        d.Title = "Demo Software in use"
		        d.Icon = MessageDialog.GraphicNote
		        d.ActionButton.Caption="Yes"
		        d.CancelButton.Visible = True
		        d.CancelButton.Caption = "No"
		        
		        d.Message = "This application was built with a Demo version of " + kProductKey + " by Jérémie Leroy." + EndOfLine + _
		        "If you wish to disable this message, then please encourage the developer of this application to purchase the " + kProductKey + "." + EndOfLine + _
		        EndOfLine + _
		        "Would you like to visit Jérémie Leroy's website ?"
		        b=d.ShowModal
		        If b=d.ActionButton then
		          ShowURL("http://www.jeremieleroy.com/products/")
		        End If
		        
		      #Endif
		      
		    End If
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatColor(c As color) As String
		  If c = &c0 then
		    
		    Return "#000"
		  End If
		  
		  Dim R, G, B, A As String
		  
		  
		  R = Hex(c.Red)
		  G = Hex(c.Green)
		  B = Hex(c.Blue)
		  'A = Hex(c.Alpha)
		  
		  If len(R) = 1 then
		    R = "0" + R
		  End If
		  If len(G) = 1 then
		    G = "0" + G
		  End If
		  If len(B) = 1 then
		    B = "0" + B
		  End If
		  'If len(A) = 1 then
		  'A = "0" + A
		  'End If
		  
		  
		  Return "#" + R + G +B + A
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetHTML() As String
		  
		  
		  If UBound(Colors) = -1 then Return ""
		  
		  Dim cla As String
		  'If Width > Height then
		  cla = " class=""" + self.ControlID + "-color-pick "+ self.ControlID + "-inline-block"" "
		  'else
		  'cla = " class=""" + self.ControlID + "-color-pick "" "
		  'End If
		  Dim claText As String = " class=""" + self.ControlID + "-text"" "
		  Dim onClick As String = " onclick=""Xojo.triggerServerEvent('" + Self.ControlID + "','selectColor',['%%']);return false;"""
		  Dim i As Integer
		  Dim Data() As String
		  
		  'Data.Append "<div class=""" + Self.ControlID + "-inline-block"" style=""height: " + str(me.Height) + """>"
		  
		  dim ColorData() As String
		  
		  If UBound(Selections) < UBound(Colors) then
		    Redim Selections(UBound(Colors))
		  End If
		  
		  For i = 0 to UBound(Colors)
		    
		    //Top Div
		    If Width > Height then
		      ColorData.Append "<div class=""" + self.ControlID + "-inline-block"" " + onClick.Replace("%%", str(i)) + ">"
		    else
		      ColorData.Append "<div " + onClick.Replace("%%", str(i)) + ">"
		    End If
		    
		    //Color Square
		    ColorData.Append "<div id=""" + Self.ControlID + "_" + str(i) + """" + cla  + " style=""background-color: " + FormatColor(Colors(i)) + """ role=""radio"">"
		    If Selected = i or (Type = TypeCheckbox and Selections(i)) then
		      ColorData.Append "<div class=""" + Self.ControlID + "-selected""></div>"
		    End If
		    ColorData.Append "</div>"
		    
		    //Caption
		    If UBound(Captions) >= i and Captions(i) <> "" then
		      ColorData.Append "<div" + claText + ">" + Captions(i) + "</div>"
		    End If
		    
		    //End
		    ColorData.Append "</div>"
		    
		  Next
		  
		  Data.Append Join(ColorData, "")
		  
		  'Data.Append "</div>"
		  
		  
		  
		  
		  
		  Return Join(Data, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Redraw()
		  
		  If ControlAvailableInBrowser() Then
		    ExecuteJavaScript("Xojo.get('" + me.ControlID + "').innerHTML = '" + _
		    ReplaceLineEndings(GetHTML.ReplaceAll("'", "\'"), "") + "';")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function Registered() As Boolean
		  
		  
		  Return True
		  
		  
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event SelectColor(Index As Integer, C As Color, HTMLColor As String)
	#tag EndHook


	#tag Property, Flags = &h0
		Captions() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Colors() As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Handles the AutoUpdate after the app is open.
		#tag EndNote
		Private DelayedAutoUpdate As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mLimitDate As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelected As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		myPicSelected As WebPicture
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mSelected
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mSelected = value
			  
			  
			  
			  If Type = TypeCheckbox then
			    If UBound(Selections) < value then
			      ReDim Selections(value)
			    End If
			    
			    Selections(value) = True
			  End If
			  
			  Redraw()
			End Set
		#tag EndSetter
		Selected As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		Selections() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As Integer
	#tag EndProperty


	#tag Constant, Name = iconSource, Type = String, Dynamic = False, Default = \"http://www.iconarchive.com/show/farm-fresh-icons-by-fatcow/color-swatch-icon.html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = JavascriptNamespace, Type = String, Dynamic = False, Default = \"jly.WebColorSelector", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kProductKey, Type = String, Dynamic = False, Default = \"WebColorPicker", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseDate, Type = Double, Dynamic = False, Default = \"20140731", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersion, Type = String, Dynamic = False, Default = \"1.0.0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = LayoutEditorIcon, Type = String, Dynamic = False, Default = \"iVBORw0KGgoAAAANSUhEUgAAALgAAAAQCAYAAAClfLVEAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAACxIAAAsSAdLdfvwAAAEzSURBVGhD7Zo9CsJAEEZzFStvIlgKdl5ExNLCg3gHbcRbaKG9lSdQGFlwNZtMfshXrbzAlDtF8vx8u7PFfPMwpcysqNbu+DKlvJ6T89WU8nqu7idTyus5209NKa/n87IwpbyedliaVM53t+3apHJ63kZjU6pQ4A5rATz9gStwh7UAnr5PBe6wFsCFFCfBK//eJHg/dUFRUnAUPQlrURTBw1VFCW8/PGVnB3AAjwxkrSgRbgD/bUxx8D9x8Ca4Q5KT4CR4NgneoCBfvr3jRAAH8OwAjxrSltwRdgAH8GwA/yhHmevaprKa4gAO4FkBXoW8a8oJ4ACeHeAR8i642WTWrz5wDj58XM8kk0nmsDsp3EXpN7XkFCW9nMU5+J+cg7epCg6Og2fp4H38GwfHwcsBp47q35WRj/A0SL4IAAAAAElFTkSuQmCC", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = NavigatorIcon, Type = String, Dynamic = False, Default = \"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAILSURBVDhPpZFdSFNhGMdf6QMhqIsi0KvmnBc6NNAJmlsXuYVFDHLR1aQouiqUbuxGoaCuhS6D7pxbZpFF0JdUV5FDc5ljbsPTigJpTLyIkNiv57zn7KPdFHXgx3l4znl+PO//VYDKNxjk9xsU9n5mq/4HSp6RV4qRF4rLwvhzpXtq+TQqMWjx/pSMSlsLZDh/M01hYo2tHZZg+KVi8pOHqVwXY89sgQxd3LytUYlQRbCxz2DjQobNcwY/t3+3NnituL6whxsLuxmbswXJQZy5SxqVPFkRsCsL9cJOA+oKWjAaV4y+VVwRxqXWR1gPoNaP2PRXBPKpswbz9z/2yhm4Z6B1WpB322MzGaUO+Zfo9b+jJ7DIwWBc92Ylsfs2D8z0SiG2x+D8ByEJ7oeWoC8QZ+gqhK9BR/CN7pnDHyeKmplqQZsIfE+Ep7KFLeg9uog/nKN/KEd7cF4L7snQXIfF3WpBYwQaTKLQOGtt4B4wcB9bo1VoOpHVvagMTdpEqgV/E5i+hZpgyxmQEN2SsGwe0rqyjNdJxucg7XWQ8jTpHtMOiB2wuCN1KUQ9/O0WFATDEqT6muFsiOKZECudzZYg6qQ4H9YQcdYI0j2QFUoCr4uvx7v5MtDNSldJINJH8o/JlNTlDRLb5Ah1vx1h1dvC6mEXKZ+LpKfF2iDmsgZNolKXBP8fophM27/wC4hDDQhd8cpeAAAAAElFTkSuQmCC", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = picSelected, Type = String, Dynamic = False, Default = \"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAACxIAAAsSAdLdfvwAAAAwSURBVChTY2CgFvgPBXjNgykC0TgVYijCZjRWk9AF8VqHLEnQ8UQ5HOYjvL4jNrwBXSFvkUQ+fAcAAAAASUVORK5CYII\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = ShowStyleProperty, Type = Boolean, Dynamic = False, Default = \"True", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = TypeCheckbox, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeRadio, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
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
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Selected"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
