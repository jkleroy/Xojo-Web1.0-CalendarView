#tag Class
Protected Class WebCalendarView
Inherits WebControlWrapper
	#tag Event
		Sub Close()
		  If RefreshTimer <> Nil then
		    RefreshTimer.Mode = timer.ModeOff
		    
		    RemoveHandler RefreshTimer.Action, addressof TimerAction
		  End If
		  
		  RaiseEvent Close()
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(Name as String, Parameters() as Variant) As Boolean
		  //Dispatch events from the end user's browser here
		  If Self.Enabled Then
		    Select Case Name
		      
		    Case "MouseDown_"
		      
		      Dim X, Y As Integer
		      X = Parameters(0)
		      Y = Parameters(1)
		      MouseDownOK = handleMouseDown(X, Y)
		      
		    Case "MouseUp_"
		      
		      If MouseDownOK then
		        Dim X, Y As Integer
		        X = Parameters(0)
		        Y = Parameters(1)
		        handleMouseUp(X, Y)
		        
		        MouseDownOK = False
		      End If
		      
		      
		    Case "Scroll_"
		      
		      mScrollPosition = Parameters(0)
		      If MouseDownOK then
		        MouseDownOK = False
		        SelStart = Nil
		        SelEnd = Nil
		        me.Redisplay()
		      End If
		      
		      
		    Case "ClickDate"
		      Dim d As new date
		      d.SQLDate = Parameters(0)
		      d.Hour = 0
		      d.Minute = 0
		      d.Second = 0
		      
		      If ViewType = TypeYear Then
		        
		        DisplayDate = New Date(D)
		        ViewType = me.TypeMonth
		        
		      Elseif ViewType = TypePicker then
		        
		        DisplayDate = New Date(D)
		        DateSelected(D)
		      End If
		      
		      Return True
		      
		    Case "ChangeMonth"
		      DisplayDate.Day = 1
		      
		      If Parameters(0)<0 then
		        DisplayDate.Month = DisplayDate.Month -1
		      Else
		        DisplayDate.Month = DisplayDate.Month+1
		      End If
		      mFirstDate = Nil
		      
		      ViewChanged()
		      
		      Redisplay()
		    End Select
		  End If
		  
		  Return False
		End Function
	#tag EndEvent

	#tag Event
		Sub FrameworkPropertyChanged(Name as String, Value as Variant)
		  If ControlAvailableInBrowser Then
		    
		    Dim js() As String
		    
		    Select Case Name
		    Case "Enabled"
		      
		      'js.Append "var e=Xojo.get('" + Me.ControlID + "');"
		      'js.Append "if (e) {"
		      '
		      'If value Then
		      'js.append "e.style.opacity = 1; e.style.cursor = 'auto';"
		      'Else
		      'js.append "e.style.opacity = 0.5; e.style.cursor = 'default';"
		      'End If
		      'js.Append "};"
		      'ExecuteJavaScript(join(js, EndOfLine.UNIX))
		      
		    Case "Visible"
		      
		      js.Append "var e=Xojo.get('" + Me.ControlID + "');"
		      js.Append "if (e) {"
		      If value then
		        js.Append "e.style.visibility = ""visible"";"
		      Else
		        js.Append "e.style.visibility = ""hidden"";"
		      End If
		      js.Append "};"
		      ExecuteJavaScript(join(js, EndOfLine.UNIX))
		      
		    End Select
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub Open()
		  Freeze = True
		  
		  
		  DisplayDate = New Date
		  
		  #if TargetMacOS
		    DisableScroll = True
		  #endif
		  
		  'HideNightTime = True
		  
		  #if TargetDesktop
		    me.UseFocusRing = False
		    me.EraseBackground = False
		  #elseif TargetWeb
		    TransparentBackground = True
		  #endif
		  me.Animate = False
		  
		  If picLockedEvents is Nil then
		    picLockedEvents = Picture.FromData(DecodeBase64(kPicLockedEvents))
		  End If
		  If picCloseMonthPopup is Nil then
		    picCloseMonthPopup = Picture.FromData(DecodeBase64(kPicCloseMonthPopup))
		  End If
		  
		  #if not kOpenSource
		    xojo.core.timer.CallLater(10000*(1.0+Rnd), AddressOf AutoUpdate)
		  #endif
		  
		  
		  'tLoader = new Timer
		  'tLoader.Mode = timer.ModeSingle
		  'tLoader.Period = 1
		  'AddHandler tLoader.Action, WeakAddressOf HandleLoader
		  
		  
		  '#if not DebugBuild
		  RefreshTimer = New Timer
		  RefreshTimer.Period = 5000
		  RefreshTimer.Mode = timer.ModeMultiple
		  
		  Addhandler RefreshTimer.Action, Weakaddressof TimerAction
		  
		  '#endif
		  
		  
		  MyStyle.MEventHeight = 12
		  TimeWidth = 51
		  minHourHeight = 30
		  ScrollBarWidth = 8
		  minVGap = 10
		  minHGap = 15
		  
		  DisplayWeeknumber = True
		  
		  SetStyle(0)
		  
		  DragEvents = True
		  CreateWithDrag = True
		  
		  HelpTagFormat = "%Start  – %End" + EndOfLine + "%Title – %Location"
		  
		  
		  
		  //Getting day names
		  Today = New Date
		  
		  //Month Names
		  SetupLocaleInfo()
		  
		  ScrollPosition = (Today.Hour)
		  Freeze = False
		  
		  Open()
		  
		  #if TargetDesktop
		    Refresh(False)
		  #elseif TargetWeb
		    Redisplay()
		  #endif
		  
		  #if not kOpenSource
		    Call Registered
		  #endif
		  
		  
		  //Delete this
		  
		  'If not Registered then
		  '#if not DebugBuild
		  'Dim d As new MessageDialog
		  'Dim b As MessageDialogButton
		  '
		  'd.Title = "Demo Software in use"
		  'd.Icon = MessageDialog.GraphicNote
		  'd.ActionButton.Caption="Yes"
		  'd.CancelButton.Visible = True
		  'd.CancelButton.Caption = "No"
		  '
		  'd.Message = "This application was built with a Demo version of CalendarView by Jérémie Leroy." + EndOfLine + _
		  '"If you wish to disable this message, then please encourage the developer of this application to purchase the CalendarView." + EndOfLine + _
		  'EndOfLine + _
		  '"Would you like to visit Jérémie Leroy's website ?"
		  'b=d.ShowModal
		  'If b <> Nil and b=d.ActionButton then
		  'ShowURL("http://www.jeremieleroy.com/")
		  'End If
		  '#endif
		  'End If
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resized()
		  Redisplay()
		End Sub
	#tag EndEvent

	#tag Event
		Sub SetupCSS(ByRef Styles() as WebControlCSS)
		  #if TargetWeb
		    styles(0).value("visibility") = "visible" // Every WebSDK control needs this
		    
		    Dim st As WebControlCSS
		    
		    //------------Date Picker and Year------------
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_cell"
		    st.Value("text-align") = "center"
		    st.Value("padding") = "2px"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_dayNbr"
		    st.Value("border-left") = "dashed 1px #B6B6B6"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_dayNbr:hover"
		    st.Value("background-color") = "#EEE"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_Today"
		    st.Value("background-color") = "#EAF0F9"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_selected"
		    st.Value("background-color") = "#EEEEEE"
		    Styles.Append st
		    
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_title"
		    st.Value("text-align") = "center"
		    st.Value("font-weight") = "bold"
		    st.Value("font-size") = "1.1em"
		    st.Value("cursor") = "default"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_change"
		    st.Value("cursor") = "pointer"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_dayName"
		    st.Value("font-weight") = "bold"
		    st.Value("border-bottom") = "solid 1px #CCC"
		    st.Value("cursor") = "default"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_onmonth"
		    st.Value("color") = "#222"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_offmonth"
		    st.Value("color") = "#999"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_dayLeft"
		    st.Value("border-left") = "0px"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_dayRight"
		    st.Value("border-right") = "0px"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_weekday"
		    'st.Value("border-right") = "0px"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_dp_weekend"
		    st.Value("background-color") = "#F0FAF0"
		    Styles.Append st
		    
		    //------------Year------------
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_y_table"
		    st.Value("border") = "solid 1px #CCC"
		    st.Value("background-color") = "#FFF"
		    Styles.Append st
		    
		    //------------Month------------
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_m_header"
		    If not TransparentBackground then
		      st.Value("background-color") = FormatColor(me.MyColors.Header)
		    End If
		    st.Value("cursor") = "default"
		    'st.Value("border-left") = "solid 1px #000"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_m_title"
		    st.Value("font-weight") = "bold"
		    st.Value("text-size") = str(MyStyle.MTitleTextSize) + "px"
		    st.Value("text-align") = "center"
		    Styles.Append st
		    
		    st = new WebControlCSS
		    st.Selector = "." + self.ControlID + "_m_dayname"
		    st.Value("text-align") = "center"
		    'st.Value("border-left") = "solid 1px #000"
		    Styles.Append st
		    
		    If mStyle = me.StyleOutlook2013 Then
		      st = new WebControlCSS
		      st.Selector = "." + self.ControlID + "_m_dayname_today"
		      st.Value("font-weight") = "bold"
		      st.Value("background-color") = FormatColor(MyColors.MainColor)
		      Styles.Append st
		      
		    End If
		    
		    
		  #endif
		End Sub
	#tag EndEvent

	#tag Event
		Function SetupHTML() As String
		  Dim xStyle As String
		  If me.Style <> Nil then
		    xStyle = " class=""" + me.Style.Name + """ "
		  End If
		  
		  'If Overflow then
		  '//height: " + str(OverflowHeight) + "px
		  If picAjaxLoader is Nil then
		    picAjaxLoader = New WebFile
		    picajaxloader.Data = DecodeBase64(kpicAjaxLoader)
		    picajaxloader.MIMEType = "image/gif"
		    picajaxloader.Filename = "ajax-loader.gif"
		    'picAjaxLoader.Session = Nil //Important
		  End If
		  
		  Dim Data() As String
		  Data.Append "<div id=""" + self.ControlID + """>"
		  Data.Append "<div id=""" + self.ControlID + "_container""" + xStyle + " style=""overflow-y:auto; overflow-x:hidden"">"
		  Data.Append "</div>"
		  'Data.Append "<img style=""display:inherit; zindex:999999; position: absolute; left:50%; top:50%"" id=""" + self.ControlID + "_loader"" src=""" + picajaxloader.URL + """/>"
		  Data.Append "</div>"
		  Return Join(Data, EndOfLine)
		  
		  
		  
		  '<img id=""" + self.ControlID + "_img"" src=""""/>
		  'Else
		  'Return "<div id=""" + self.ControlID + """" + xStyle + "></div>"
		  'End If
		End Function
	#tag EndEvent

	#tag Event
		Function SetupJavascriptFramework() As String
		  Return ""
		End Function
	#tag EndEvent

	#tag Event
		Sub Shown()
		  LoaderShow()
		  Redisplay()
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddEvent(cEvent As CalendarEvent)
		  //Adds a CalendarEvent in the CalendarView
		  
		  EventsSorted = False
		  
		  If cEvent.ID = "" then
		    cEvent.ID = "auto" + format(Microseconds, "0000000000")
		  End If
		  
		  SelStart = Nil
		  SelEnd = Nil
		  
		  mFirstDate = Nil
		  mLastDate = Nil
		  
		  Events.Append cEvent
		  Redim DisplayEvents(-1)
		  
		  Redisplay()
		  
		  'If RaiseNewEvent then
		  'NewEvent(cEvent)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AlphaColor(C As Color, Alpha As Color, Force As Boolean = False) As Color
		  If C.Alpha <> 0 and Not Force then
		    Return C
		  End If
		  
		  #if TargetDesktop
		    If (TargetWin32 and App.UseGDIPlus = False) then
		      Return RGB(C.Red, C.Green, C.Blue, 0)
		    else
		      Return RGB(C.Red, C.Green, C.Blue, Alpha.Red)
		    End If
		  #elseif TargetWeb
		    Return RGB(C.Red, C.Green, C.Blue, Alpha.Red)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AlphaColor(C As Color, Alpha As Integer, Force As Boolean = False) As Color
		  If C.Alpha <> 0 and Not Force then
		    Return C
		  End If
		  
		  #if TargetDesktop
		    If (TargetWin32 and App.UseGDIPlus = False) then
		      Return RGB(C.Red, C.Green, C.Blue, 0)
		    else
		      Return RGB(C.Red, C.Green, C.Blue, Alpha*255.0/100.0)
		    End If
		    
		  #Elseif TargetWeb
		    Return RGB(C.Red, C.Green, C.Blue, Alpha*255.0/100.0)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AutoScroll(deltaX As Integer, deltaY As Integer)
		  //Auto scroll every half second
		  
		  If ticks - lastAutoScroll > 10 then
		    Scroll(deltaX, deltaY)
		    lastAutoScroll = ticks
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CheckRecurringEvents(cEvent As CalendarEvent, FirstDate As Date, EndDate As Date) As CalendarEvent()
		  'Dim i As Integer, U As Integer
		  'Dim RecID() As String
		  Dim Events() As CalendarEvent
		  Dim E As CalendarEvent
		  Dim Recurrence As CalendarRecurrence
		  Dim DisplayDate As Date
		  'Dim limitIdx As Integer
		  Dim limit As Boolean
		  Dim ExitLoop As Boolean
		  
		  Recurrence = cEvent.Recurrence
		  
		  If Recurrence.EndDate <> Nil and Recurrence.EndDate.TotalSeconds < FirstDate.TotalSeconds then _
		  Return Nil
		  
		  If Recurrence.EndAmount >0 then
		    limit = True
		  End If
		  
		  If FirstDate.TotalSeconds > cEvent.StartDate.TotalSeconds then
		    DisplayDate = New Date(FirstDate)
		  Else
		    DisplayDate = New Date(cEvent.StartDate)
		    DisplayDate.Day = DisplayDate.Day + 1
		  End If
		  
		  
		  
		  While DisplayDate.TotalSeconds < EndDate.TotalSeconds
		    
		    If Recurrence.CreateRecurrence(DisplayDate, cEvent, ExitLoop) then
		      E = cEvent.Clone
		      E.setDate(DisplayDate)
		      E.SetLength(cEvent.Length)
		      Events.Append E
		    End If
		    
		    If ExitLoop then
		      Exit While
		    End If
		    
		    DisplayDate.Day = DisplayDate.Day + 1
		  Wend
		  
		  '
		  'Select Case Recurrence.RepeatType
		  '
		  '//WeekDay Recurrence
		  'Case Recurrence.TypeWeekDay
		  '
		  '//Moving to the first day of the Event if necessary
		  'While DisplayDate.TotalSeconds <= cEvent.StartDate.TotalSeconds
		  'DisplayDate.Day = DisplayDate.Day + 1
		  'Wend
		  '
		  'While DisplayDate.TotalSeconds < EndDate.TotalSeconds
		  'If DisplayDate.DayOfWeek>1 and DisplayDate.DayOfWeek<7 then
		  'E = cEvent.Clone
		  'E.setDate(DisplayDate)
		  'E.SetLength(cEvent.Length)
		  'Events.Append E
		  'If limit then
		  'limitidx = limitIdx + 1
		  'If limitIdx >= Recurrence.EndAmount then
		  'exit while
		  'End If
		  'End If
		  'End If
		  'DisplayDate.Day = DisplayDate.Day + 1
		  'Wend
		  '
		  '//Daily Recurrence
		  'Case Recurrence.TypeDaily
		  '
		  '//Moving to the first day of the Event if necessary
		  'While DisplayDate.TotalSeconds <= cEvent.StartDate.TotalSeconds
		  'DisplayDate.Day = DisplayDate.Day + 1
		  'Wend
		  '
		  'While DisplayDate.TotalSeconds < EndDate.TotalSeconds
		  'E = cEvent.Clone
		  'E.setDate(DisplayDate)
		  'E.SetLength(cEvent.Length)
		  'Events.Append E
		  'If limit then
		  'limitidx = limitIdx + 1
		  'If limitIdx >= Recurrence.EndAmount then
		  'exit while
		  'End If
		  'End If
		  'DisplayDate.Day = DisplayDate.Day + 1
		  'Wend
		  '
		  'Case Recurrence.TypeWeekly
		  '
		  'Case Recurrence.TypeMonthly
		  '
		  'DisplayDate.Day = cEvent.StartDate.Day
		  'While DisplayDate.TotalSeconds <= cEvent.StartDate.TotalSeconds
		  'DisplayDate.Month = DisplayDate.Month + 1
		  'Wend
		  '
		  'While DisplayDate.TotalSeconds < EndDate.TotalSeconds
		  'E = cEvent.Clone
		  'E.setDate(DisplayDate)
		  'E.SetLength(cEvent.Length)
		  'Events.Append E
		  'DisplayDate.Month = DisplayDate.Month + 1
		  'If DisplayDate.Day <> cEvent.Day then
		  'DisplayDate.Day = cEvent.Day
		  ''DisplayDate.Month = DisplayDate.Month + 1
		  'End If
		  'Wend
		  '
		  'Case Recurrence.TypeMonthlyRelative
		  '
		  'Case Recurrence.TypeYearly
		  '
		  'DisplayDate.Day = cEvent.StartDate.Day
		  'DisplayDate.Month = cEvent.StartDate.Month
		  '
		  'If DisplayDate.TotalSeconds >= FirstDate.TotalSeconds and DisplayDate.TotalSeconds < EndDate.TotalSeconds then
		  '
		  'While DisplayDate.TotalSeconds < EndDate.TotalSeconds
		  'E = cEvent.Clone
		  'E.setDate(DisplayDate)
		  'E.SetLength(cEvent.Length)
		  'Events.Append E
		  'DisplayDate.Year = DisplayDate.Year + 1
		  'Wend
		  '
		  'End If
		  '
		  'End Select
		  
		  Return Events()
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CombSort(ByRef Input() As CalendarEvent)
		  
		  Const Shrink = 1.3
		  Dim swapped As Boolean
		  Dim i, u, gap As Integer
		  Dim swap As CalendarEvent
		  
		  u = UBound(Input())
		  gap = u
		  
		  
		  while gap > 1 or swapped
		    if gap > 1 then
		      gap = gap / shrink
		    End If
		    
		    swapped = False
		    
		    For i = 0 to u-gap
		      If Input(i) > Input(i+gap) then
		        
		        swap = Input(i)
		        Input(i) = Input(i+gap)
		        Input(i+gap) = swap
		        swapped = True
		      End If
		    Next
		    
		  wend
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DateForXY(x As Integer, y As Integer, Gutter As Boolean = False) As Date
		  //newinversion 1.2.1
		  //Finds the Date for the passed x and y.<br/>
		  //If no Date is found, it returns Nil.
		  
		  Dim DrawX, DrawY As Single
		  Dim DrawDate As New Date
		  Dim i As Integer
		  
		  DrawDate.Hour = 0
		  DrawDate.Minute = 0
		  DrawDate.Second = 0
		  
		  If X>=Width then Return Nil
		  
		  If ViewType = TypePicker then
		    
		    If X>=Width then Return Nil
		    
		    DrawDate.SQLDate = FirstDate.SQLDate
		    
		    Dim HeaderHeight As Integer = 39
		    Dim DayWidth As Single
		    Dim DayHeight As Single
		    
		    Dim ItemsPerLine As Integer
		    Dim TotalItems As Integer
		    
		    Drawy = HeaderHeight
		    Drawx = 0
		    LastDayOver = -1
		    
		    If PickerView = PickerDay then
		      DayWidth = Width / 7
		      DayHeight = (Height - HeaderHeight) / WeeksPerMonth
		      
		      ItemsPerLine = 7
		      TotalItems = WeeksPerMonth * 7
		      
		    elseif PickerView = PickerMonth then
		      DayWidth = Width / 4
		      DayHeight = (Height - HeaderHeight) / 3
		      
		      DrawDate.Month = 1
		      DrawDate.Day = 1
		      
		      ItemsPerLine = 4
		      TotalItems = 12
		      
		    End If
		    
		    For i = 1 to TotalItems
		      
		      If x >= DrawX and x < DrawX + DayWidth and y >= DrawY and y < Drawy + DayHeight then
		        LastDayOver = i
		        Return DrawDate
		      End If
		      
		      If PickerView = PickerDay then
		        DrawDate.Day = DrawDate.Day + 1
		      elseif PickerView = PickerMonth then
		        DrawDate.Month = DrawDate.Month + 1
		      elseif PickerView = PickerYear then
		        DrawDate.Year = DrawDate.Year + 1
		      End If
		      
		      If i mod ItemsPerLine = 0 then
		        Drawy = Drawy + DayHeight
		        Drawx = 0
		      else
		        Drawx = Drawx + DayWidth
		      End If
		    Next
		    
		    
		    Return Nil
		    
		  ElseIf ViewType = TypeYear then
		    
		    Dim VAmount As Integer
		    Dim HAmount As Integer
		    Dim VGap As Single
		    Dim HGap As Single
		    
		    Dim dayWidth As Integer
		    Dim dayHeight As Integer
		    Dim TotalItems, ItemsPerLine, j As Integer
		    Dim kDrawX As Integer
		    
		    If Width > Height then
		      If Width / Height > 2.45 then
		        VAmount = 6
		        HAmount = 2
		      else
		        VAmount = 4
		        HAmount = 3
		      End If
		    else
		      If Width / Height < 0.6 then
		        VAmount = 2
		        HAmount = 6
		      else
		        VAmount = 3
		        HAmount = 4
		      End If
		    End If
		    
		    dayWidth = Floor((Width-(VAmount-1)*minHGap)/(VAmount*7))
		    HGap = (Width - 1-dayWidth * VAmount*7)/(VAmount-1)
		    dayHeight = Floor((Height-(HeaderHeight*HAmount)-minVGap*(HAmount-1))/(6*HAmount))
		    VGap = (Height-1-HeaderHeight*HAmount-dayHeight*6*HAmount)/(HAmount-1)
		    
		    TotalItems = 6*7
		    ItemsPerLine = 7
		    
		    DrawY = HeaderHeight
		    
		    
		    For i = 1 to 12
		      
		      If x >DrawX and x < DrawX + dayWidth * 7 and y > DrawY and y < DrawY + HeaderHeight + dayHeight * 6 then
		        //We found the correct month
		        DrawDate = New Date(DisplayDate.Year, i, 1, 0, 0, 0)
		        
		        //Getting the first day of the mini calendar
		        If DrawDate.DayOfWeek - FirstDayOfWeek <= 0 then
		          DrawDate.Day = DrawDate.Day - (DrawDate.DayOfWeek - FirstDayOfWeek) - 7
		        else
		          DrawDate.Day = DrawDate.Day - (DrawDate.DayOfWeek - FirstDayOfWeek)
		        End If
		        
		        kDrawX = DrawX
		        
		        For j = 1 to TotalItems
		          
		          If x >= DrawX and x < DrawX + DayWidth and y >= DrawY and y < Drawy + DayHeight then
		            Return DrawDate
		          End If
		          
		          
		          DrawDate.Day = DrawDate.Day + 1
		          
		          If j mod ItemsPerLine = 0 then
		            Drawy = Drawy + DayHeight
		            Drawx = kDrawX
		          else
		            Drawx = Drawx + DayWidth
		          End If
		        Next
		        
		        //Not found
		        Return Nil
		      End if
		      
		      If i mod VAmount = 0 then
		        DrawX = 0
		        DrawY = DrawY + HeaderHeight + dayHeight * 6 + VGap
		      else
		        DrawX = DrawX + dayWidth * 7 + HGap
		      End If
		    Next
		    
		    //Not found
		    Return Nil
		    
		    
		  ElseIf ViewType = TypeMonth then
		    
		    DrawDate.SQLDate = FirstDate.SQLDate
		    
		    'Dim HeaderHeight As Integer = 48
		    Dim DayWidth As Single = Width / 7
		    Dim DayHeight As Single = (Height - HeaderHeight) / WeeksPerMonth
		    
		    Drawy = HeaderHeight
		    Drawx = 0
		    For i = 1 to WeeksPerMonth * 7 //A corriger
		      
		      If x >= DrawX and x < DrawX + DayWidth and y >= DrawY and y < Drawy + DayHeight then
		        Return DrawDate
		      End If
		      
		      DrawDate.Day = DrawDate.Day + 1
		      If i mod 7 = 0 then
		        Drawy = Drawy + DayHeight
		        Drawx = 0
		      else
		        Drawx = Drawx + DayWidth
		      End If
		    Next
		    
		  elseif ViewType > TypeMonth then
		    
		    If Gutter then
		      x = TimeWidth+1
		    End If
		    If x <= TimeWidth then
		      Return Nil
		    End If
		    If y <= HeaderHeight and SelStart is Nil then
		      Return Nil
		    End If
		    
		    Dim DayWidth As Single = (Width - TimeWidth) / ViewDays
		    
		    //1. Finding Date
		    DrawX = TimeWidth
		    For i = 0 to ViewDays-1
		      If X >= DrawX and X <= DrawX + DayWidth then
		        DrawDate = New Date(FirstDate)
		        DrawDate.Day = DrawDate.Day + i
		        Exit for i
		      End If
		      DrawX = DrawX + DayWidth
		    Next
		    
		    DrawDate.Hour = 0
		    DrawDate.Minute = 0
		    DrawDate.Second = 0
		    If DayEventClicked then
		      Return DrawDate
		    End If
		    
		    //2. Finding Time
		    DrawY = ViewHeight
		    Dim miny As Integer = ViewHeight - HourHeight
		    #if TargetWeb
		      DrawY = ViewHeight
		    #Else
		      DrawY = DrawY - (VisibleHours-(Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours
		    #endif
		    
		    If HideNightTime and DayStartHour>0 then
		      DrawY = DrawY + HourHeight
		    End If
		    
		    'For i = DayStartHour to VisibleHours
		    For i = 0 to VisibleHours
		      If DrawY > miny then
		        If Abs(DrawY-y) <= HourHeight / 4 + 1 then
		          DrawDate.Hour = i
		          exit for i
		        elseif Abs(DrawY+HourHeight\2-y) <= HourHeight\4 then
		          DrawDate.Hour = i
		          DrawDate.Minute = 30
		          exit for i
		        Elseif i = 23 and Abs(Height-Y) < HourHeight \ 2 then
		          DrawDate.Hour = 23
		          DrawDate.Minute = 59
		          DrawDate.Second = 59
		          'DrawDate.Day = DrawDate.Day + 1
		          exit for i
		        End If
		      End If
		      DrawY = DrawY + HourHeight
		    Next
		    
		    Return DrawDate
		  End If
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeleteAllEvents()
		  //Deletes all CalendarEvents in the CalendarView
		  
		  Redim DisplayEvents(-1)
		  Redim Events(-1)
		  
		  Redisplay()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawBackground(g As Graphics)
		  'If HasBackcolor then
		  'g.ForeColor = Backcolor
		  'g.FillRect(0, 0, g.Width, g.Height)
		  '
		  'else
		  
		  g.ForeColor = GetWindowColor
		  g.FillRect(0, 0, g.Width, g.Height)
		  
		  #if TargetDesktop
		    If me.TrueWindow.Backdrop <> Nil then
		      Dim p As Picture = me.TrueWindow.Backdrop
		      If me.Left < p.Width and me.Top < p.Height then
		        g.DrawPicture p, 0, 0, Width, Height, left, top, Width, Height
		      End If
		    End If
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawBackgroundMonth(gg As Graphics, WeeksPerMonth As Integer, DayWidth As Single, DayHeight As Single, PrintToday As Boolean = True)
		  //In DebugBuild we check performance of drawing
		  #if DebugBuild
		    Dim ms As Double = Microseconds
		  #endif
		  
		  Dim i, u, w, h As Integer
		  Dim text As String
		  Dim x, xx, y As Single
		  Dim DrawDate As Date = New Date(FirstDate)
		  
		  gg.TextFont = TextFont
		  
		  //Header Background
		  If TransparentBackground then
		    #if TargetDesktop
		      If TargetWin32 and not app.UseGDIPlus then
		        DrawBackground(gg)
		      End If
		    #endif
		  else
		    gg.ForeColor = MyColors.Header
		    gg.FillRect(0, 0, gg.Width, HeaderHeight)
		  End If
		  
		  
		  //Drawing Day names
		  
		  gg.TextSize = MyStyle.MNumbersTextSize
		  If MyStyle.MDayNameAlign = AlignLeft then
		    xx = MyStyle.MTextOffset
		  elseif MyStyle.MDayNameAlign = AlignCenter then
		    xx = 0
		  else
		    xx = DayWidth - MyStyle.MTextOffset
		  End If
		  
		  Dim gradientDay As Picture
		  If MyStyle.FillGradient then
		    gradientDay = New Picture(Ceil(DayWidth), Ceil(DayHeight), 32)
		    gradient(gradientDay.Graphics, 0, gradientDay.Height, MyColors.WeekDay, MyColors.WeekDay2)
		  End If
		  
		  For i = 0 to 6
		    If (FirstDayOfWeek + i) = 7 then
		      text = TitleCase(DayNames(7))
		    else
		      text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		    End If
		    
		    
		    gg.ForeColor = MyColors.DayName
		    gg.Bold = False
		    
		    If PrintToday and StyleType = StyleOutlook2013 and ((i = Today.DayOfWeek-FirstDayOfWeek) or (i = Today.DayOfWeek-FirstDayOfWeek+7)) then
		      gg.ForeColor = MyColors.MainColor
		      gg.FillRect(DayWidth*i, 29, DayWidth, 19)
		      gg.ForeColor = MyColors.DayName
		      gg.Bold = True
		    End If
		    
		    //Drawing day names
		    #if TargetDesktop
		      
		      If MyStyle.MDayNameAlign = AlignLeft then
		        gg.DrawString(text, DayWidth * i + xx, 43, DayWidth-xx*2, True)
		      elseif MyStyle.MDayNameAlign = AlignCenter then
		        gg.DrawString(text, DayWidth * i + max(1, (DayWidth - gg.StringWidth(text)) \ 2), 43, DayWidth-2, True)
		      elseif MyStyle.MDayNameAlign = 3 then
		        //Do not draw here
		      else
		        x =DayWidth * i + xx - min(DayWidth-xx, gg.StringWidth(text))
		        gg.DrawString(text, DayWidth * i + xx - min(xx-3, gg.StringWidth(text)), 43, DayWidth, True)
		      End If
		    #endif
		    
		    //Drawing Day Background
		    If MyStyle.FillGradient = False then
		      If ColorWeekend and (FirstDayOfWeek + i = 7 or (FirstDayOfWeek + i) mod 7 = 1) then
		        gg.ForeColor = MyColors.Weekend
		      else
		        gg.ForeColor = MyColors.WeekDay
		      End If
		      gg.FillRect(DayWidth*i, HeaderHeight, Ceil(DayWidth), gg.Height-HeaderHeight)
		    else
		      For j as integer = 0 to WeeksPerMonth
		        gg.DrawPicture(gradientDay, DayWidth*i, HeaderHeight + j*DayHeight)
		        'gg.gradient(DayWidth*i, HeaderHeight+j*DayHeight, Ceil(DayWidth), Ceil(DayHeight), &c363D45, &c2b2c2e)
		      Next
		    End If
		    
		  Next
		  
		  //Drawing title
		  #if TargetDesktop
		    
		    gg.ForeColor = MyColors.Title
		    gg.Bold = True
		    gg.TextSize = MyStyle.MTitleTextSize
		    If UBound(MonthNames)>= DisplayDate.Month then
		      text = MonthNames(DisplayDate.Month) + " " + str(DisplayDate.Year)
		    else
		      text = Str(DisplayDate.Month) + " " + str(DisplayDate.Year)
		    End If
		    gg.DrawString(text, (gg.Width - gg.StringWidth(text)) \ 2, 25, gg.Width, True)
		    
		  #endif
		  
		  
		  //Drawing day numbers
		  gg.TextSize = MyStyle.MNumbersTextSize
		  gg.Bold = False
		  y = HeaderHeight + 14
		  If MyStyle.MDayNumberAlign = AlignLeft then
		    xx = MyStyle.MNumberXOffset
		  elseif MyStyle.MDayNumberAlign = AlignCenter then
		    xx = 1
		  else
		    xx = DayWidth - MyStyle.MNumberXOffset
		  End If
		  x = xx
		  u = WeeksPerMonth * 7
		  Dim Selected As Boolean
		  For i = 1 to u
		    
		    gg.Bold = False
		    Selected = False
		    
		    //Today Background
		    If DrawDate.SQLDate = Today.SQLDate and PrintToday then
		      gg.ForeColor = MyColors.Today
		      If StyleType = StyleOutlook2013 then
		        gg.FillRect(1+(Ceil(x / DayWidth)-1) * DayWidth, y-13, DayWidth, 5)
		      else
		        gg.FillRect(1+(Ceil(x / DayWidth)-1) * DayWidth, y-13, DayWidth, DayHeight)
		      End If
		    End If
		    
		    //Other Month Background
		    If MyStyle.MColorOtherMonth and DrawDate.Month <> DisplayDate.Month then
		      gg.ForeColor = MyColors.OtherMonth
		      If i mod 7 = 1 then
		        gg.FillRect(0, y-13, DayWidth, DayHeight)
		      Else
		        gg.FillRect(1+(Ceil(x / DayWidth)-1) * DayWidth, y-13, DayWidth, DayHeight)
		      End If
		    End If
		    
		    //Clicked Background
		    If SelStart <> Nil and SelEnd <> nil and DrawDate.SQLDate >= SelStart.SQLDate and DrawDate.SQLDate <= SelEnd.SQLDate then
		      Selected = True
		      gg.ForeColor = MyColors.Selected
		      gg.FillRect(1+(Ceil(x / DayWidth)-1) * DayWidth, y-13, DayWidth, DayHeight)
		    End If
		    
		    //Day Header background
		    If MyStyle.MDayNumberBackground then
		      gg.ForeColor = MyColors.DayNumberBackground
		      If i mod 7 = 1 then
		        gg.FillRect(0, y-13, DayWidth, 16)
		      Else
		        gg.FillRect(1+(Ceil(x / DayWidth)-1) * DayWidth, y-13, DayWidth, 16)
		      End If
		    End If
		    
		    
		    
		    
		    If i<8 and MyStyle.MDayNameAlign = 3 then
		      If (FirstDayOfWeek + i-1) = 7 then
		        text = DayNames(7).Left(3) + "." + " " + str(DrawDate.Day)
		      else
		        text = DayNames((FirstDayOfWeek + i-1) mod 7).Left(3) + "." + " " + str(DrawDate.Day)
		      End If
		    else
		      If DrawDate.Day = 1 and MyStyle.MFirstDayOfMonthName then
		        text = str(DrawDate.Day) + " " + MonthNames(DrawDate.Month)
		      else
		        text = str(DrawDate.Day)
		        
		      End If
		      If DrawDate.Day = 1 and MyStyle.MFirstDayOfMonthBold then
		        gg.Bold = True
		      End If
		      
		    End If
		    If PrintToday and StyleType = StyleOutlook2013 and DrawDate.SQLDate = Today.SQLDate then
		      //This style has bold text and special color
		      gg.ForeColor = MyColors.Today
		      gg.Bold = True
		    elseIf DrawDate.Month <> DisplayDate.Month then
		      If gg.ForeColor <> MyColors.DayNumber then
		        gg.ForeColor = MyColors.DayNumber
		      End If
		    else
		      If gg.ForeColor <> MyColors.DayNumberActive then
		        gg.ForeColor = MyColors.DayNumberActive
		      End If
		    End If
		    If Selected and MyStyle.MHasSelectedTextColor then
		      gg.ForeColor = MyColors.MSelectedText
		    End If
		    
		    If MyStyle.MDayNumberAlign = AlignLeft then
		      gg.DrawString(text, x, y+MyStyle.MNumberYOffset)
		    elseif MyStyle.MDayNumberAlign = AlignCenter then
		      gg.DrawString(text, x + (DayWidth - gg.StringWidth(text))\2, y+MyStyle.MNumberYOffset)
		    else
		      gg.DrawString(text, x - gg.StringWidth(text), y+MyStyle.MNumberYOffset)
		    End If
		    
		    
		    
		    DrawDate.Day = DrawDate.Day + 1
		    If i mod 7 = 0 then
		      y = y + DayHeight
		      x = xx
		    else
		      x = x + DayWidth
		    End If
		  Next
		  
		  
		  //Drawing day frames
		  gg.ForeColor = MyColors.Line
		  If mHiDPI then
		    For i = 1 to 6
		      x = DayWidth * i
		      gg.Fillrect(x, HeaderHeight, 2, gg.Height-1)
		    Next
		  else
		    For i = 1 to 6
		      x = DayWidth * i
		      gg.DrawLine(x, HeaderHeight, x, gg.Height-1)
		    Next
		  End If
		  
		  If mHiDPI then
		    For i = 0 to WeeksPerMonth-1
		      y = HeaderHeight + DayHeight * i-1
		      gg.FillRect(0, y, gg.Width, 2)
		    Next
		  else
		    For i = 0 to WeeksPerMonth-1
		      y = HeaderHeight + DayHeight * i
		      gg.DrawLine(0, y, gg.Width-1, y)
		    Next
		  End If
		  
		  //Drawing Week numbers
		  If DisplayWeeknumber then
		    If MyStyle.MDayNumberAlign = AlignLeft then
		      x = DayWidth - 24
		    else
		      x = 11
		    End If
		    DrawDate = FirstDate
		    gg.TextSize = 9
		    y = HeaderHeight + 14
		    h = gg.TextHeight + 2
		    w = Ceil(gg.StringWidth("00"))+2
		    
		    For i = 0 to WeeksPerMonth-1
		      If MyStyle.MDayNumberBackground = False then
		        gg.ForeColor = MyColors.WeekNumberBackground
		        gg.FillRoundRect(x, y-gg.TextAscent-1, w, h, 4, 4)
		      End If
		      
		      
		      gg.ForeColor = MyColors.WeekNumber
		      text = str(DrawDate.WeekOfYear)
		      gg.DrawString(text, x + Ceil((w - gg.StringWidth(text))/2)+1, y)
		      
		      DrawDate.Day = DrawDate.Day + 7
		      y = y + DayHeight
		    Next
		  End If
		  
		  //Drawing border
		  If Border then
		    gg.ForeColor = MyColors.Border
		    #If TargetDesktop
		      gg.DrawRect(0, HeaderHeight, gg.Width, gg.Height-HeaderHeight)
		    #elseif TargetWeb
		      gg.DrawLine(0, 0, gg.Width, 0)
		      'gg.DrawRect(0, HeaderHeight, gg.Width-1, gg.Height-HeaderHeight-1)
		    #endif
		    
		  End If
		  
		  //In DebugBuild we check performance of drawing
		  #if DebugBuild
		    ms = (Microseconds-ms)/1000
		    'DrawInfo = str(ms)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawBackgroundWeek(gg As Graphics, DayWidth As Single, PrintToday As Boolean = True)
		  Dim text As String
		  Dim i, u As Integer
		  Dim DrawDate As Date = New Date(FirstDate)
		  Dim y, w, h As Integer
		  Dim x As Single
		  Dim gc As Graphics
		  
		  gg.TextFont = TextFont
		  
		  
		  //Finding amount of day events for each day
		  //Drawing DragEvent
		  If SelStart <> Nil and SelEnd <> Nil and (SelStart <> SelEnd or DayEventClicked) then
		    Dim E As CalendarEvent = New CalendarEvent("", SelStart, SelEnd)
		    E.FrontMost = True
		    
		    ReDim DisplayEvents(-1)
		    DisplayEvents.Append E
		    SortEvents(FirstDate, LastDate, True)
		  else
		    SortEvents(FirstDate, LastDate)
		  End If
		  u = UBound(DisplayEvents)
		  
		  DayEventsHeight = max(-1, min(DayEventsHeight, gg.Height\2))
		  
		  #If TargetWeb
		    ViewHeight = HeaderHeight + MyStyle.WEventHeight*2 + 4
		    
		  #else
		    
		    If u = -1 then
		      
		      If DayEventsHeight = -1 then
		        ViewHeight = HeaderHeight + MyStyle.WEventHeight + 4
		      else
		        ViewHeight = HeaderHeight + DayEventsHeight
		      End If
		    else
		      //finding amount of DayEvents for the Height of ViewHeight
		      
		      Dim E As CalendarEvent
		      Dim amount() As Integer
		      Dim RemainTime As Double
		      Redim amount(ViewDays-1)
		      Dim idx As Integer
		      For i = 0 to u
		        E = DisplayEvents(i)
		        
		        
		        If E.Length = 0 then
		          y = (E.StartSeconds - FirstDate.TotalSeconds) / 86400
		          amount(y) = amount(y) + 1
		        elseif E.StartTime + E.Length >= 86400 then
		          y = max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400)
		          amount(y) = amount(y) + 1
		          
		          RemainTime = E.Length - (86400-E.StartTime)
		          idx = 1
		          While RemainTime >= 0
		            If y + idx > ViewDays-1 then
		              Exit While
		            else
		              amount(y+idx) = amount(y+idx) + 1
		              RemainTime = RemainTime - 86400
		              idx = idx + 1
		            End If
		          Wend
		        End If
		      Next
		      
		      amount.Sort
		      If DayEventsHeight = -1 then
		        ViewHeight = max(HeaderHeight + MyStyle.WEventHeight + 4, HeaderHeight + amount(ViewDays-1) * MyStyle.WEventHeight + 4)
		      else
		        ViewHeight = HeaderHeight + DayEventsHeight
		      End If
		    End If
		    
		  #endif
		  
		  y = (HeaderHeight - gg.TextHeight)\2 + gg.TextAscent
		  
		  
		  //Drawing Header background
		  If TransparentBackground then
		    #if TargetDesktop
		      If TargetWin32 and not app.UseGDIPlus then
		        DrawBackground(gg)
		      End If
		    #endif
		  else
		    gg.ForeColor = MyColors.Header
		    gg.FillRect(0, 0, gg.Width, HeaderHeight)
		  End If
		  
		  //Drawing Time Background
		  gg.ForeColor = MyColors.TimeBackground
		  gg.FillRect(0, HeaderHeight, TimeWidth, gg.Height-HeaderHeight)
		  
		  //Drawing Year
		  #if TargetDesktop
		    gg.ForeColor = MyColors.DayName
		    gg.TextSize = MyStyle.WTextSize
		    text = str(FirstDate.Year)
		    gg.DrawString(text, (TimeWidth - gg.StringWidth(text)) \ 2, y)
		  #endif
		  
		  //Drawing Week number
		  If DisplayWeeknumber then
		    text = str(DrawDate.WeekOfYear)
		    gg.TextSize = 9
		    gg.ForeColor = MyColors.WeekNumberBackground
		    w = Ceil(gg.StringWidth(text))+4
		    h = gg.TextHeight+2
		    x = (TimeWidth-w)\2
		    gg.FillRoundRect(x, HeaderHeight + 3, w, h, 4, 4)
		    
		    gg.ForeColor = MyColors.WeekNumber
		    gg.DrawString(text, x+3, HeaderHeight + 3 + 1 + gg.TextAscent)
		  End If
		  
		  //Drawing day names
		  x = TimeWidth
		  Dim DayStartY As Integer
		  Dim DayEndY As Integer
		  #if TargetDesktop
		    Dim maxWidth As Integer
		  #endif
		  Dim DefaultDateFormat As String
		  DefaultDateFormat = "AbbreviatedDate"
		  If DayStartHour > 0.0 then
		    If HideNightTime then
		      DayStartY = Ceil(- (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + HourHeight * 1)
		    else
		      DayStartY = Ceil(- (24-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/24 + HourHeight * DayStartHour)
		    End If
		  End If
		  If DayEndHour > 0.0 then
		    If HideNightTime then
		      DayEndY = Floor(- (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + HourHeight * DayEndHour)
		    else
		      DayEndY = Floor(- (24-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/24 + HourHeight * DayEndHour)
		    End If
		  End If
		  gc = gg.Clip(TimeWidth, ViewHeight, gg.Width-TimeWidth, gg.Height-ViewHeight)
		  
		  #if TargetDesktop
		    If WeekHeaderTextFormat = "" then
		      If styleType = StyleOutlook2013 then
		        gg.Bold = true
		      End If
		      For i = 0 to 6
		        text = DrawDate.LongDate
		        text = text.Left(text.Len-5)
		        If text.Right(1) = "," then
		          text = text.Left(len(text) - 1)
		        elseif text.Right(2) = "de" then
		          text = text.Left(len(text) -3)
		        End If
		        
		        maxWidth = max(maxWidth, gg.StringWidth(text))
		        DrawDate.Day = DrawDate.Day + 1
		      Next
		      DrawDate = New Date(FirstDate)
		      If maxWidth < DayWidth-6 then
		        DefaultDateFormat = "LongDate"
		      End If
		    End If
		  #EndIf
		  
		  
		  For i = 0 to ViewDays-1
		    #If TargetDesktop
		      If WeekHeaderTextFormat = "" then
		        If DefaultDateFormat = "LongDate" then
		          text = DrawDate.LongDate
		        else
		          text = DrawDate.AbbreviatedDate
		        End If
		        text = text.Left(text.Len-5)
		        If text.Right(1) = "," then
		          text = text.Left(len(text) - 1)
		        elseif text.Right(2) = "de" then
		          text = text.Left(len(text) -3)
		        End If
		      else
		        text = ParseDate(DrawDate, WeekHeaderTextFormat, "Abbreviated Date")
		      End If
		      
		      gg.Bold = False
		      
		      If PrintToday and MyStyle.WTodayHeader and DrawDate.SQLDate = Today.SQLDate then
		        gg.ForeColor = MyColors.Today
		        gg.FillRect(x, 0, DayWidth, HeaderHeight)
		        If StyleType = StyleOutlook2013 then
		          gg.ForeColor = MyColors.MSelectedText
		          gg.Bold = True
		        else
		          gg.ForeColor = MyColors.DayName
		        End If
		      else
		        gg.ForeColor = MyColors.DayName
		      End If
		      
		      gg.DrawString(text, 3+x + max(0, ( DayWidth-6 - gg.StringWidth(text)) \ 2), y, DayWidth-6, True)
		    #Endif
		    
		    //Drawing day color
		    If PrintToday and DrawDate.SQLDate = Today.SQLDate and MyStyle.WTodayHeader = False then
		      gg.ForeColor = MyColors.Today
		    ElseIf ColorWeekend and (DrawDate.DayOfWeek = 7 or DrawDate.DayOfWeek = 1) then
		      gg.ForeColor = MyColors.Weekend
		    else
		      gg.ForeColor = MyColors.WeekDay
		    End If
		    gg.FillRect(DayWidth * i + TimeWidth, HeaderHeight, Ceil(DayWidth), gg.Height-HeaderHeight)
		    
		    
		    
		    If (DrawDate.DayOfWeek = 7 or DrawDate.DayOfWeek = 1) and ColorWeekend then
		      
		    else
		      If DayStartY > 0 then
		        gc.ForeColor = ShiftColor(gg.ForeColor, -5)
		        gc.FillRect(DayWidth*i, 0, Ceil(DayWidth), min(DayStartY, gc.Height))
		        
		      End If
		      If DayEndY < gg.Height-ViewHeight then
		        gc.ForeColor = ShiftColor(gg.ForeColor, -5)
		        gc.FillRect(DayWidth*i, max(0, DayEndY), Ceil(DayWidth), gc.Height-DayEndY)
		      End If
		    End If
		    
		    x = x + DayWidth
		    DrawDate.Day = DrawDate.Day + 1
		  Next
		  
		  
		  
		  //Drawing Frame
		  gg.ForeColor = &cD6D6D6
		  gg.DrawLine(0, HeaderHeight, gg.Width-1, HeaderHeight)
		  gg.DrawLine(0, ViewHeight-3, gg.Width-1, ViewHeight-3)
		  gg.DrawLine(0, ViewHeight, gg.Width-1, ViewHeight)
		  gg.ForeColor = &cEDEDED
		  gg.DrawLine(0, ViewHeight-2, gg.Width-1, ViewHeight-2)
		  gg.ForeColor = &cE1E1E1
		  gg.DrawLine(0, ViewHeight-1, gg.Width-1, ViewHeight-1)
		  
		  
		  
		  //Drawing horizontal lines
		  y = ViewHeight
		  Dim miny As Integer = y
		  
		  '#if TargetMacOS
		  'y = y - ScrollPosition
		  '#else
		  y = y - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours
		  '#endif
		  
		  For i = 0 to VisibleHours
		    If y > miny then
		      gg.ForeColor = MyColors.Line
		      gg.DrawLine(MyStyle.WHourLineStartX, y, gg.Width-1, y)
		    End If
		    If y + HourHeight\2 > miny then
		      gg.ForeColor = ShiftColor(MyColors.Line, MyStyle.WHalfHourColorOffset)
		      If MyStyle.WHalfHourLineStyle = 0 then
		        gg.DrawLine(TimeWidth+1, y+HourHeight\2, gg.Width-1, y+HourHeight\2)
		      else
		        DrawDottedLine(gg, TimeWidth+1, y + HourHeight\2, gg.Width-1, y+HourHeight\2)
		      End If
		    End If
		    
		    y = y + HourHeight
		    If y > gg.Height then
		      exit for i
		    End If
		  Next
		  
		  
		  gg.ForeColor = MyColors.Line
		  //Drawing vertical lines
		  x = TimeWidth
		  
		  For i = 0 to ViewDays-1
		    gg.DrawLine(x, HeaderHeight, x, gg.Height-1)
		    x = x + DayWidth
		  Next
		  
		  
		  gc = gg.Clip(0, ViewHeight, gg.Width, gg.Height-ViewHeight)
		  
		  //Drawing time
		  DrawDate = New Date(FirstDate)
		  DrawDate.Hour = 1
		  DrawDate.Minute = 0
		  DrawDate.Second = 0
		  
		  y = ViewHeight
		  y = y - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + gg.TextAscent \ 2 - 1 - ViewHeight + HourHeight + MyStyle.WTimeVOffset
		  
		  '#if TargetMacOS
		  'y = y - ScrollPosition
		  '#else
		  'y = y - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours
		  '#endif
		  
		  gc.ForeColor = MyColors.Time
		  gc.TextSize = MyStyle.WTextSize
		  Dim FirstVisible As Boolean
		  Dim startHour, xx, yy As Integer
		  Dim HiddenHour As Boolean
		  HiddenHour = False
		  
		  If HideNightTime then
		    y = y-HourHeight
		    startHour = 0
		    DrawDate.Hour = 0
		  ElseIf MyStyle.WTimeVOffset>0 then
		    DrawDate.Hour = 0
		    startHour = 0
		    y = y-HourHeight
		    
		  else
		    startHour = 1
		  End If
		  
		  For i = startHour to VisibleHours
		    
		    If MyStyle.WTimeFormat.instr("(a)")>0 then
		      text = MyStyle.WTimeFormat
		      If y>gc.TextAscent-gc.TextHeight/2 and not FirstVisible then
		        FirstVisible = True
		        text = text.ReplaceB("(A)", "A").ReplaceB("(a)", "a")
		      elseif DrawDate.Hour=12 then
		        text = text.ReplaceB("(A)", "A").ReplaceB("(a)", "a")
		      else
		        text = text.Replace("(a)", "")
		      End If
		      
		    End If
		    //Using other function as it is a long process
		    text = getTimeTextForWeek(text, i, startHour, New Date(DrawDate))
		    
		    If StyleType = StyleOutlook2013 and MyStyle.WTimeAlign = AlignLeft then
		      
		      If text.InStr(" AM")>0 then
		        text = text.Replace("AM", "").Trim
		        xx = gc.StringWidth(text)
		        yy = gc.TextAscent\2
		        gc.TextSize = 10
		        gc.DrawString(" AM", 3+xx + 2, y-yy)
		        gc.TextSize = MyStyle.WTextSize
		      elseif text.InStr("PM")>0 then
		        text = text.Replace("PM", "").Trim
		        xx = gc.StringWidth(text)
		        yy = gc.TextAscent\2
		        gc.TextSize = 10
		        gc.DrawString(" PM", 3+xx + 2, y-yy)
		        gc.TextSize = MyStyle.WTextSize
		      End If
		    End If
		    
		    If text.InStr(" - ")>0 then
		      gc.TextSize = 10
		      gc.DrawString(text, 5, y, TimeWidth)
		      gc.TextSize = MyStyle.WTextSize
		    ElseIf MyStyle.WTimeAlign = AlignLeft or text.instr(" - ")>0 Then
		      gc.DrawString(text, 5, y)
		    elseif MyStyle.WTimeAlign = AlignCenter then
		      gc.DrawString(text, (TimeWidth-gg.StringWidth(text))\2, y, TimeWidth)
		    elseif MyStyle.WTimeAlign = AlignRight then
		      gc.DrawString(text, TimeWidth - gg.StringWidth(text)-2, y, TimeWidth)
		    End If
		    
		    
		    DrawDate.Hour = DrawDate.Hour + 1
		    If i = startHour and HideNightTime then
		      DrawDate.Hour = DayStartHour
		    End If
		    y = y + HourHeight
		    If y > gg.Height or DrawDate.Hour = 0 then
		      exit for i
		    End If
		  Next
		  
		  //Drawing border
		  If Border then
		    gg.ForeColor = MyColors.Border
		    #If TargetDesktop
		      gg.DrawRect(0, HeaderHeight, gg.Width, gg.Height-HeaderHeight)
		    #elseif TargetWeb
		      gg.DrawLine(0, 0, gg.Width, 0)
		      'gg.DrawRect(0, HeaderHeight, gg.Width-1, gg.Height-HeaderHeight-1)
		    #endif
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawBackgroundYear(gg As Graphics, Print As Boolean = False, PrintToday As Boolean = True)
		  If gg.Height < 50 then Return
		  
		  Dim VAmount As Integer
		  Dim HAmount As Integer
		  Dim MWidth, MHeight As Integer
		  Dim VGap As Single
		  Dim HGap As Single
		  
		  
		  Dim i, j, k, u As Integer
		  Dim x, y, h As Single
		  Dim xx, yy As Integer
		  
		  Dim dayWidth As Integer
		  Dim dayHeight As Integer
		  
		  Dim text As String
		  Dim DrawDate As New Date(FirstDate)
		  Dim StartDate As Date
		  
		  Dim mpic As Picture
		  Dim gm As Graphics
		  
		  gg.TextFont = TextFont
		  
		  //Drawing background
		  If Print = False then
		    If TransparentBackground then
		      #if TargetDesktop
		        If TargetWin32 and not app.UseGDIPlus then
		          DrawBackground(gg)
		        End If
		      #endif
		    else
		      gg.ForeColor = MyColors.YBackground
		      gg.FillRect(0, 0, gg.Width, gg.Height)
		    End If
		  End If
		  
		  //Finding amount of months per line
		  If gg.Width > gg.Height then
		    If gg.Width / gg.Height > 2.45 then
		      HAmount = max(1, Ceil(YearMonthsAmount/6))
		      VAmount = YearMonthsAmount/HAmount
		      'VAmount = 6
		      'HAmount = 2
		    else
		      HAmount = max(1, Ceil(YearMonthsAmount/4))
		      VAmount = YearMonthsAmount/HAmount
		      'VAmount = 4
		      'HAmount = 3
		    End If
		  else
		    If gg.Width / gg.Height < 0.6 then
		      HAmount = max(1, Ceil(YearMonthsAmount/6))
		      VAmount = YearMonthsAmount/HAmount
		      'VAmount = 2
		      'HAmount = 6
		    else
		      HAmount = max(1, Ceil(YearMonthsAmount/4))
		      VAmount = YearMonthsAmount/HAmount
		      'VAmount = 3
		      'HAmount = 4
		    End If
		  End If
		  
		  dayWidth = Floor((gg.Width-(VAmount-1)*minHGap)/(VAmount*7))
		  HGap = (gg.Width - 1-dayWidth * VAmount*7)/(VAmount-1)
		  dayHeight = Floor((gg.Height-(HeaderHeight*HAmount)-minVGap*(HAmount-1))/(6*HAmount))
		  VGap = (gg.Height-1-HeaderHeight*HAmount-dayHeight*6*HAmount)/(HAmount-1)
		  
		  
		  MWidth = dayWidth * 7
		  MHeight = dayHeight * 6
		  
		  //Preparing individual month buffer
		  #if TargetDesktop
		    If TargetWin32 and not App.UseGDIPlus Then
		      mPic = New Picture(MWidth+1, MHeight + HeaderHeight+1, 32)
		    else
		      
		      mPic = New Picture(MWidth+1, MHeight + HeaderHeight+1)
		    End If
		  #elseif TargetWeb
		    mPic = New Picture(MWidth+1, MHeight + HeaderHeight+1)
		  #endif
		  
		  gm = mPic.Graphics
		  
		  
		  
		  gm.ForeColor = MyColors.Header
		  gm.FillRect(0, 0, gm.Width, HeaderHeight)
		  
		  //Drawing Day Names
		  gm.TextFont = TextFont
		  #if TargetWeb
		    gm.TextSize = MyStyle.YNumbersTextSize*3/4
		  #else
		    gm.TextSize = MyStyle.YNumbersTextSize'*2
		  #endif
		  Y = gm.TextAscent + gm.TextHeight
		  For i = 0 to 6
		    gm.ForeColor = MyColors.DayName
		    If (FirstDayOfWeek + i) = 7 then
		      text = TitleCase(DayNames(7)).Left(2)
		    else
		      text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7)).Left(2)
		    End If
		    If gm.StringWidth(text) > dayWidth-2 then
		      text = text.Left(1)
		    End If
		    gm.DrawString(text, DayWidth * i + max(1, (DayWidth - gm.StringWidth(text)) \ 2), Y)
		    
		    //Drawing day background
		    If ColorWeekend and ((FirstDayOfWeek + i) = 7 or (FirstDayOfWeek+i) mod 7 = 1) then
		      gm.ForeColor = MyColors.Weekend
		    else
		      gm.ForeColor = MyColors.WeekDay
		    End If
		    gm.FillRect(dayWidth*i, HeaderHeight, dayWidth+1, gm.Height-HeaderHeight)
		  Next
		  
		  //Drawing day frames
		  gm.ForeColor = MyColors.Line
		  
		  yy = HeaderHeight+MHeight
		  If MyStyle.YLineVertical > LineNone then
		    For i = 1 to 6
		      xx = DayWidth * i
		      If MyStyle.YLineVertical = LineThinSolid then
		        gm.DrawLine(xx, HeaderHeight, xx, yy)
		      elseif MyStyle.YLineVertical = LineThinDotted then
		        DrawDottedLine(gm, xx, HeaderHeight, xx, yy)
		      elseif MyStyle.YLineVertical = LineThinDouble then
		        gm.DrawLine(xx-1, HeaderHeight, xx-1, yy)
		        gm.ForeColor = MyColors.Line2
		        gm.DrawLine(xx, HeaderHeight, xx, yy)
		        gm.ForeColor = MyColors.Line
		      End If
		    Next
		  End If
		  If MyStyle.YLineHorizontal > LineNone then
		    gm.DrawRect(0, HeaderHeight, MWidth+1, MHeight+1)
		    For i = 0 to 5
		      yy = HeaderHeight + DayHeight * i
		      If MyStyle.YLineHorizontal = LineThinSolid then
		        gm.DrawLine(0, yy, MWidth, yy)
		      elseif MyStyle.YLineHorizontal = LineThinDotted then
		        DrawDottedLine(gm, 0, yy, MWidth, yy)
		      elseif MyStyle.YLineHorizontal = LineThinDouble then
		        gm.DrawLine(0, yy-1, MWidth, yy-1)
		        gm.ForeColor = MyColors.Line2
		        gm.DrawLine(0, yy, MWidth, yy)
		        gm.ForeColor = MyColors.Line
		      End If
		    Next
		  End If
		  
		  If Border then
		    gm.ForeColor = MyColors.Border
		    gm.DrawRect 0, 0, gm.Width, gm.Height
		  End If
		  
		  X = 0
		  Y = 0
		  
		  //Setting up DayColor for each day in the year
		  If UBound(DisplayEvents) = -1 then
		    SetDayColor()
		  End If
		  u = UBound(DisplayEvents)
		  
		  For j = 1 to mYearMonthsAmount
		    
		    StartDate = New Date(DrawDate)
		    StartDate.Day = 1
		    StartDate.Hour = 0
		    StartDate.Minute = 0
		    StartDate.Second = 0
		    If StartDate.DayOfWeek - FirstDayOfWeek <= 0 then
		      StartDate.Day = StartDate.Day - (StartDate.DayOfWeek - FirstDayOfWeek) - 7
		    else
		      StartDate.Day = StartDate.Day - (StartDate.DayOfWeek - FirstDayOfWeek)
		    End If
		    
		    //Drawing Month buffer
		    'gg.DrawPicture(mPic, Floor(X), Floor(Y))
		    gg.DrawPicture(mpic, Floor(X), Floor(Y), MWidth+1, MHeight + HeaderHeight+1, 0, 0, mpic.Width, mpic.Height)
		    
		    //Drawing title
		    gg.ForeColor = MyColors.Title
		    gg.Bold = True
		    gg.TextSize = MyStyle.YTitleTextSize
		    text = MonthNames(DrawDate.Month) + " " + str(DisplayDate.Year)
		    gg.DrawString(text, x + (MWidth - gg.StringWidth(text)) \ 2, Y+gg.TextAscent, dayWidth*7, True)
		    
		    
		    gg.TextSize = MyStyle.YNumbersTextSize
		    yy = y + HeaderHeight + (dayHeight-gg.TextHeight)\2 + gg.TextAscent
		    xx = x
		    
		    //Drawing Day Numbers and background color for events
		    For i = 1 to 42
		      
		      //Today Background
		      If DrawDate.Month = Today.Month and StartDate.SQLDate = Today.SQLDate and PrintToday then
		        gg.ForeColor = MyColors.Today
		        gg.FillRect(xx+1, Y +1 + HeaderHeight + Floor((i-0.1)/7)*dayHeight, dayWidth-1, dayHeight-1)
		        gg.ForeColor = mixColor(MyColors.Today, MyColors.Line, &h60)
		        gg.DrawRect(xx, Y + HeaderHeight + Floor((i-0.1)/7)*dayHeight, dayWidth+1, dayHeight+1)
		        '1+(Ceil(x / DayWidth)-1) * DayWidth, y-14, DayWidth, DayHeight)
		      End If
		      
		      //Event Background
		      If StartDate.Month = DrawDate.Month then
		        
		        'If DayColor(StartDate.DayOfYear) <> &c0 then
		        If DayColor(StartDate.DayOfYear) <> Nil then
		          If DayColor(StartDate.DayOfYear).Count = 1 then
		            gg.ForeColor = DayColor(StartDate.DayOfYear).FirstColor
		            gg.FillRect(xx+1, Y +1 + HeaderHeight + Floor((i-0.1)/7)*dayHeight, dayWidth-1, dayHeight-1)
		          else
		            h = (dayHeight-1)/DayColor(StartDate.DayOfYear).Count
		            For k = 0 to DayColor(StartDate.DayOfYear).Count-1
		              gg.ForeColor = DayColor(StartDate.DayOfYear).EventColor(k)
		              gg.FillRect(xx+1, Y+1+h*k+HeaderHeight + Floor((i-0.1)/7)*dayHeight, dayWidth-1, Ceil(h))
		            Next
		          End If
		          
		        End If
		      End If
		      
		      text = str(StartDate.Day)
		      If StartDate.Month <> DrawDate.Month then
		        If gg.ForeColor <> MyColors.DayNumber then
		          gg.ForeColor = MyColors.DayNumber
		          
		        End If
		      else
		        'If DayColor(StartDate.DayOfYear) <> &c0 then
		        If DayColor(StartDate.DayOfYear) <> Nil then
		          If DayColor(StartDate.DayOfYear).FirstColor.Hue = DayColor(StartDate.DayOfYear).FirstColor.Saturation then
		            If DayColor(StartDate.DayOfYear).FirstColor.Value < 0.5 then
		              gg.ForeColor = InvertColor(MyColors.DayNumberActive)
		            End if
		            
		          elseif DayColor(StartDate.DayOfYear).FirstColor.Value < 0.9 then
		            gg.ForeColor = InvertColor(MyColors.DayNumberActive)
		          else
		            gg.ForeColor = MyColors.DayNumberActive
		          End If
		        elseIf gg.ForeColor <> MyColors.DayNumberActive then
		          gg.ForeColor = MyColors.DayNumberActive
		        End If
		      End If
		      
		      gg.DrawString(text, xx + (DayWidth - gg.StringWidth(text))\2, yy)
		      
		      StartDate.Day = StartDate.Day + 1
		      If i mod 7 = 0 then
		        yy = yy + DayHeight
		        xx = x
		      else
		        xx = xx + DayWidth
		      End If
		    Next
		    
		    
		    DrawDate.Day = 1
		    DrawDate.Month = j+1
		    If j mod VAmount = 0 then
		      X = 0
		      Y = Y + HeaderHeight + dayHeight * 6 + VGap
		    else
		      X = X + dayWidth * 7 + HGap
		    End If
		  Next
		  
		  '//Drawing border
		  'If Border then
		  'gg.ForeColor = MyColors.Border
		  'gg.DrawRect(0, 0, gg.Width, gg.Height)
		  'End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawDottedLine(g As Graphics, X1 As Integer, Y1 As Integer, X2 As Integer, Y2 As Integer)
		  
		  Dim w As Integer = X2 - X1
		  Dim h As Integer = Y2 - Y1
		  Dim i As Integer
		  If h = 0 then
		    If w > 450 then
		      Dim u As Integer
		      Dim p As Picture
		      #if TargetDesktop
		        If TargetWin32 and not App.UseGDIPlus Then
		          p = New Picture(w, 1, 32)
		          Dim gp As Graphics = p.Graphics
		          gp.ForeColor = g.ForeColor
		          gp.DrawLine(0, 0, w, 0)
		          gp = p.Mask.Graphics
		          gp.Pixel(1, 0) = &cFFFFFF
		          gp.Pixel(3, 0) = &cFFFFFF
		          
		          i=1
		          u=0
		          while(i<w)
		            i=i*2
		            u=u+1
		          wend
		          w = 4
		          For i = 0 to u
		            gp.DrawPicture(p.mask, w, 0, w, 1, 0, 0, w, 1)
		            w = w*2
		          Next
		          g.DrawPicture(p, X1, Y1)
		          Return
		        Else
		          p = New Picture(w, 1)
		        End If
		      #elseif TargetWeb
		        p = New Picture(w, 1)
		      #endif
		      
		      Dim gp As Graphics = p.Graphics
		      gp.Pixel(0, 0) = g.ForeColor
		      gp.Pixel(2, 0) = g.ForeColor
		      
		      i=1
		      u=0
		      while(i<w)
		        i=i*2
		        u=u+1
		      wend
		      w = 4
		      For i = 0 to u
		        gp.DrawPicture(p, w, 0, w, 1, 0, 0, w, 1)
		        w = w*2
		      Next
		      
		      g.DrawPicture(p, X1, Y1)
		    else
		      'If mHiDPI then
		      'For i = 0 to w step 4
		      'g.FillRect(X1+i, Y1, 2, 2)
		      'Next
		      'else
		      For i = 0 to w step 2
		        g.Pixel(X1+i, Y1) = g.ForeColor
		      Next
		      'End If
		    End If
		  else
		    If h > 450 then
		      Dim u As Integer
		      Dim p As Picture
		      #if TargetDesktop
		        If TargetWin32 and not App.UseGDIPlus Then
		          p = New Picture(1, h, 32)
		          Dim gp As Graphics = p.Graphics
		          gp.ForeColor = g.ForeColor
		          gp.DrawLine(0, 0, 0, h)
		          gp = p.Mask.Graphics
		          gp.Pixel(0, 1) = &cFFFFFF
		          gp.Pixel(0, 3) = &cFFFFFF
		          
		          i=1
		          u=0
		          while(i<h)
		            i=i*2
		            u=u+1
		          wend
		          h = 4
		          For i = 0 to u
		            gp.DrawPicture(p.mask, 0, h, 1, h, 0, 0, 1, h)
		            h = h*2
		          Next
		          
		          g.DrawPicture(p, X1, Y1)
		          Return
		        Else
		          p = New Picture(w, 1)
		        End If
		      #elseif TargetWeb
		        p = New Picture(w, 1)
		      #endif
		      Dim gp As Graphics = p.Graphics
		      gp.Pixel(0,0) = g.ForeColor
		      gp.Pixel(0,2) = g.ForeColor
		      
		      i=1
		      u=0
		      while(i<h)
		        i=i*2
		        u=u+1
		      wend
		      h = 4
		      For i = 0 to u
		        gp.DrawPicture(p, 0, h, 1, h, 0, 0, 1, h)
		        h = h*2
		      Next
		      g.DrawPicture(p, X1, Y1)
		    else
		      'If mHiDPI then
		      'For i = 0 to h step 4
		      'g.FillRect(X1, Y1+i, 2, 2)
		      'Next
		      'else
		      For i = 0 to h step 2
		        g.Pixel(X1, Y1+i) = g.ForeColor
		      Next
		      'End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawEvent(g As Graphics, E As CalendarEvent, X As Integer, Y As Integer, Width As Integer, Height As Integer, DayEvent As Boolean)
		  #if TargetWeb
		    Height = Height-1
		  #endif
		  
		  Dim gp As Graphics
		  Dim p As Picture
		  Dim Antialiasing As Boolean
		  
		  #if TargetWin32 and TargetDesktop
		    If App.UseGDIPlus then
		      gp = g.Clip(X, Y, Width, Height)
		      Antialiasing = True
		    Else
		      p = New Picture(Width, Height, 32)
		      If p is Nil then Return
		      gp = p.Graphics
		      Antialiasing = False
		    End If
		  #Else
		    gp = g.Clip(X, Y, Width, Height)
		    Antialiasing = True
		  #endif
		  
		  Dim Arc As Integer = 6
		  
		  Dim HeaderHeight As Integer
		  If ViewType >= TypeWeek then
		    HeaderHeight = MyStyle.WHeaderHeight
		  End If
		  
		  Dim Transparency As Color
		  If ViewType = TypeMonth then
		    If MyStyle.MDayTransparent then
		      Transparency = MyStyle.MDayTransparency
		    End If
		  elseif ViewType >= TypeWeek then
		    Transparency = MyStyle.WBodyTransparency
		  End If
		  
		  
		  //Drawing background color
		  If MyStyle.WRoundRect then //RoundRect
		    
		    If MyStyle.WBodyColorOffset1 = MyStyle.WBodyColorOffset2 then //No gradient
		      
		      gp.ForeColor = AlphaColor(E.EventColor, Transparency)
		      
		      If Antialiasing then
		        gp.FillRoundRect(0, 0, gp.Width, gp.Height, Arc, Arc)
		      else
		        gp.FillRect(0, 0, gp.Width, gp.Height)
		      End If
		      
		      If HeaderHeight > 0 and not DayEvent then
		        gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WHeaderColorOffset)
		        gp.FillRoundRect(1, 1, gp.Width-2, 1+HeaderHeight, Arc,Arc)
		        gp.FillRect(1, 1+HeaderHeight-2, gp.Width-2, 3)
		      End If
		      
		      If HeaderHeight>0 then
		        gp.ForeColor = AlphaColor(mixColor(E.EventColor, &cFFFFFF, MyStyle.WBodyColorOffset1), Transparency)
		        gp.FillRoundRect(1, 1 + HeaderHeight, gp.Width-2, gp.Height - 2 - HeaderHeight, Arc, Arc)
		        gp.FillRect(1, 1 + HeaderHeight, gp.Width-2, 3)
		      End If
		      
		    else //Gradient
		      
		      If MyStyle.WBodyGradientVertical then
		        gradient2(gp, 1, 1+HeaderHeight, gp.Width-2, gp.Height - 2 - HeaderHeight, _
		        shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		        ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), True)
		      else
		        gradient2(gp, 1, 1, gp.Width-1, gp.Height-2, _
		        shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		        ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), False)
		      End If
		      
		      gp.ForeColor = E.EventColor
		      
		      gp.DrawRoundRect(0, 0, gp.Width, gp.Height, Arc,Arc)
		      If not Antialiasing then
		        gp.DrawRect(0, 0, gp.Width, gp.Height)
		        gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 8,8)
		      End If
		      
		      If HeaderHeight > 0 and not DayEvent then
		        gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WHeaderColorOffset)
		        gp.FillRoundRect(1, 1, gp.Width-2, 1+HeaderHeight, Arc,Arc)
		        gp.FillRect(1, 1+HeaderHeight-2, gp.Width-2, 3)
		      End If
		    End If
		    
		    
		    If not Antialiasing then
		      gp = p.Mask.Graphics
		      
		      //Drawing picture mask
		      gp.ForeColor = &cFFFFFF
		      gp.FillRect(0, 0, gp.Width, gp.Height)
		      gp.ForeColor = &cDDDDDD
		      gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 4, 4)
		      gp.ForeColor = &c888888
		      gp.DrawRoundRect(0, 0, gp.Width, gp.Height, Arc, Arc)
		      gp.ForeColor = &c0
		      gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 8, 8)
		      gp.Pixel(1, 1) = &c707070
		      gp.Pixel(gp.Width-2, 1) = &c707070
		      gp.Pixel(1, gp.Height-2) = &c707070
		      gp.Pixel(gp.Width-2, gp.Height-2) = &c707070
		      
		      
		      If Transparency <> &c0 or MyStyle.WHeaderTransparency <> &c0 then
		        
		        If DayEvent then
		          gp.ForeColor = Transparency
		          gp.FillRoundRect(1, 1, gp.Width-2, gp.Height-2, Arc, Arc)
		          
		        Else //not WholeDay
		          
		          If HeaderHeight > 0  then
		            gp.ForeColor = MyStyle.WHeaderTransparency
		            gp.FillRoundRect(1, 1, gp.Width-2, 1+HeaderHeight, Arc,Arc)
		            gp.FillRect(1, 1+HeaderHeight-3, gp.Width-2, 3)
		          End If
		          gp.ForeColor = Transparency
		          gp.FillRoundRect(1, 1+HeaderHeight, gp.Width-2, gp.Height-2-HeaderHeight, Arc, Arc)
		          If HeaderHeight > 0 then
		            gp.FillRect(1, 1+HeaderHeight, gp.Width-2, 3)
		          End If
		          
		          
		          
		        End If
		      else
		        gp.ForeColor = &c0
		        gp.FillRoundRect(1, 1, gp.Width-2, gp.Height-2, Arc, Arc)
		      End If
		    End If
		    
		  Else //not RoundRect
		    
		    If MyStyle.WEventFill = FillSolid then //No gradient
		      
		      gp.ForeColor = AlphaColor(mixColor(E.EventColor, &cFFFFFF, MyStyle.WBodyColorOffset1), Transparency)
		      
		      gp.FillRect(1, 1 + HeaderHeight, gp.Width-2, gp.Height - 2 - HeaderHeight)
		    elseif MyStyle.WEventFill = FillGradientVertical then
		      
		      gradient(gp, 1+ HeaderHeight, gp.Height - 1 - HeaderHeight, shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		      ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), True, Transparency.Red)
		    elseif MyStyle.WEventFill = FillGradientHorizontal Then
		      gradient(gp, 1, gp.Width-2, shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		      ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), False, Transparency.Red)
		      
		      //Outlook 2013 Style
		    elseif MyStyle.WEventFill = FillOutlook2013 then
		      gp.ForeColor = AlphaColor(E.EventColor, Transparency)
		      gp.FillRect(0, 0, 8, gp.Height)
		      gp.ForeColor = Alphacolor(ShiftColor(E.EventColor, MyStyle.MColorOffset1), Transparency)
		      gp.FillRect(8, 0, gp.Width, gp.Height)
		      If E.DayEvent then
		        gp.ForeColor = &cFFFFFF
		        gp.FillRect(1, 1, 6, gp.Height-2)
		      End If
		    End If
		    
		    //Drawing border
		    If MyStyle.WEventFill <> FillOutlook2013 then
		      gp.ForeColor = E.EventColor
		      gp.DrawRect(0, 0, gp.Width, gp.Height)
		    End If
		    If HeaderHeight > 0 then
		      gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WHeaderColorOffset)
		      gp.FillRect(1, 1, gp.Width-2, HeaderHeight)
		    End If
		    
		    If not Antialiasing then
		      'gp = p.Mask.Graphics
		      'If HeaderHeight > 0 and MyStyle.WHeaderTransparency <> &c0 then
		      '//Drawing picture mask
		      'gp.ForeColor = MyStyle.WHeaderTransparency
		      'gp.FillRect(1, 1, gp.Width-2, HeaderHeight)
		      'End If
		      'If Transparency <> &c0 then
		      'gp.ForeColor = Transparency
		      'gp.FillRect(1, HeaderHeight+1, gp.Width-2, gp.Height-HeaderHeight-2)
		      'End If
		    End If
		    
		    
		    
		  End If
		  
		  If HighlightLockedEvents and E.Editable = False then
		    DrawTexture(gp, picLockedEvents, True, False)
		  End If
		  
		  If not Antialiasing Then
		    g.DrawPicture(p, X, Y)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawEventsMonth(gg As Graphics, WeeksPerMonth As Integer, DayWidth As Single, DayHeight As Single)
		  'Dim mp As new MethodProfiler(CurrentMethodName)
		  If DayHeight < 30 then Return
		  If DayWidth < 30 then Return
		  
		  If UBound(Events) = -1 then Return
		  
		  Dim i, j, u, Idx, DrawIdx, RealLength, v, LeftOffset As Integer
		  Dim text As String
		  Dim x, xx,y, yy As Single
		  Dim E As CalendarEvent
		  Dim DrawDate As Date = New Date
		  DrawDate.Hour = 0
		  DrawDate.Minute = 0
		  DrawDate.Second = 0
		  DrawDate.SQLDate = FirstDate.SQLDate
		  'DrawDate.Day = DrawDate.Day + 1
		  Dim okToDraw As Boolean
		  
		  Dim MonthPopupX, MonthPopupY As Integer
		  
		  If UBound(DisplayEvents) = -1 or DragEvent = DragMove Then
		    SortEvents(FirstDate, LastDate)
		  End If
		  
		  u = UBound(DisplayEvents)
		  If u = -1 then Return
		  
		  y = HeaderHeight+17+MyStyle.MNumberYOffset
		  x = 0
		  LeftOffset = MyStyle.MLeftOffset
		  
		  'Dim amount() As Integer
		  'Redim amount(WeeksPerMonth * 7)
		  
		  Dim DrawPos As New CalendarDrawPosition(WeeksPerMonth*7, (DayHeight-17-MyStyle.MNumberYOffset) / (MyStyle.MEventHeight+1) -1)
		  
		  For i = 1 to WeeksPerMonth * 7
		    okToDraw = True
		    
		    If DrawDate.Day = 12 then
		      i = i
		    End If
		    
		    For j = Idx to u
		      
		      E = DisplayEvents(j)
		      
		      If E.StartDate.SQLDate > DrawDate.SQLDate then
		        Idx = j
		        Exit for j
		      End If
		      
		      If (DrawDate.SQLDate = E.StartDate.SQLDate) or (i=1 and DrawDate > E.StartDate) then
		        
		        If okToDraw then
		          'If j<u and DisplayEvents(j+1).Day = E.Day and DrawPos.Remain((E.StartSeconds - FirstDate.TotalSeconds) / 86400) <2 then
		          If j < u and DisplayEvents(j+1).StartDate.SQLDate <= E.EndDate.SQLDate and DrawPos.Remain(max(0, (DisplayEvents(j+1).StartSeconds - FirstDate.TotalSeconds) / 86400)) < 1 then
		            okToDraw = False
		          else
		            v = DrawPos.Remain(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400))
		            If v < 1 and DrawPos.Hidden(i) > 0 then
		              okToDraw = False
		            elseif v < 0 then
		              okToDraw = False
		            else
		              okToDraw = True
		            End If
		          End If
		        End If
		        
		        yy = DrawPos.Search(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400), E.Length/86400) * (MyStyle.MEventHeight+1)
		        
		        If not okToDraw then
		          DrawPos.AddHidden(i, E.Length/86400)
		          E.Visible = False
		          E.drawX = x
		          E.DrawY = y + yy
		          E.DrawW = DayWidth
		          E.DrawH = MyStyle.MEventHeight
		          Continue For j
		          
		        End If
		        
		        E.Visible = True
		        'yy = DrawPos.Search(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400), E.Length/86400) * (MyStyle.MEventHeight+1)
		        
		        //Event is a whole day event
		        If E.StartDate.Hour = 0 and E.StartDate.Minute = 0 and E.Length mod 86400 = 0 or E.Length > 86400 then
		          RealLength = Floor(E.Length / 86400) + 1 - max(0, (FirstDate.TotalSeconds - E.StartSeconds) / 86400)
		          
		          //Only events that start at 0:00 and length mod 86400=0 have to be set as DayEvents
		          If E.StartDate.Hour = 0 and E.StartDate.Minute = 0 and E.Length mod 86400 = 0 then
		            E.DayEvent = True
		          End If
		          
		          
		          //Should go on to the next week line
		          If RealLength>7 or x+RealLength*DayWidth>gg.Width+5 Then
		            
		            Dim remainDays As Integer = RealLength
		            DrawIdx = 0
		            xx = x
		            
		            Dim textColorEvent As Color = MyStyle.WTextColor
		            
		            If StyleType = StyleOutlook2013 then
		              textColorEvent= mixColor(E.EventColor, &c0, &hB0)
		            else
		              If E.EventColor.Hue = E.EventColor.Saturation then
		                If E.EventColor.Value < 0.5 then
		                  textColorEvent = InvertColor(textColorEvent)
		                End if
		              elseif E.EventColor.Value < 0.9 then
		                textColorEvent = InvertColor(textColorEvent)
		              End If
		            End If
		            
		            
		            While remainDays>0
		              DrawEvent(gg, E, xx, y + yy + DayHeight*DrawIdx, _
		              DayWidth * min(7, remainDays) - LeftOffset * 2, MyStyle.MEventHeight, _
		              E.DayEvent)
		              
		              If DrawIdx = 0 then
		                remainDays = remainDays - (7-Round(x/DayWidth))
		              else
		                
		                
		                //Drawing Text
		                gg.ForeColor = textColorEvent
		                gg.TextSize = MyStyle.MEventTextSize
		                gg.Bold = MyStyle.MDayTextBold
		                If E.DayEvent then
		                  gg.DrawString(E.Title, xx+MyStyle.MTextOffset, y + yy +DayHeight*DrawIdx+ (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, remainDays * DayWidth-MyStyle.MTextOffset*2, True)
		                End If
		                
		                remainDays = remainDays - 7
		                
		              End If
		              
		              xx = MyStyle.MLeftOffset
		              DrawIdx = DrawIdx + 1
		            Wend
		            
		          else
		            //testing
		            DrawEvent(gg, E, x+MyStyle.MLeftOffset, y + yy, _
		            DayWidth * max(1, min(RealLength, 43)) - LeftOffset * 2, MyStyle.MEventHeight, _
		            E.DayEvent)
		            'gg.DrawPicture(p, x+MyStyle.MLeftOffset, y+yy)
		          End If
		          
		          E.drawX = x
		          E.DrawY = y + yy
		          E.DrawW = DayWidth*RealLength
		          E.DrawH = MyStyle.MEventHeight
		          
		          //Drawing Text
		          gg.ForeColor = MyStyle.WTextColor
		          If StyleType = StyleOutlook2013 then
		            gg.ForeColor = mixColor(E.EventColor, &c0, &hB0)
		          else
		            If E.EventColor.Hue = E.EventColor.Saturation then
		              If E.EventColor.Value < 0.5 then
		                gg.ForeColor = InvertColor(gg.ForeColor)
		              End if
		            elseif E.EventColor.Value < 0.9 then
		              gg.ForeColor = InvertColor(gg.ForeColor)
		            End If
		          End If
		          gg.TextSize = MyStyle.MEventTextSize
		          gg.Bold = MyStyle.MDayTextBold
		          If E.DayEvent then
		            gg.DrawString(E.Title, x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, max(1, E.Length/86400+1) * DayWidth-MyStyle.MTextOffset*2, True)
		          else
		            gg.DrawString(E.StartDate.ShortTime + " " + E.Title, x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, max(1, E.Length/86400+1) * DayWidth-MyStyle.MTextOffset*2, True)
		          End If
		          
		        else //Not a whole day event
		          
		          E.drawX = x
		          E.DrawY = y + yy
		          E.DrawW = DayWidth
		          E.DrawH = MyStyle.MEventHeight
		          
		          //Drawing Text
		          gg.ForeColor = E.EventColor
		          
		          If MyStyle.MEventFill = FillOutlook2013 then
		            //testing
		            DrawEvent(gg, E, x+MyStyle.MLeftOffset, y + yy, _
		            DayWidth - LeftOffset * 2+1, MyStyle.MEventHeight, False)
		            
		          End If
		          
		          gg.TextSize = MyStyle.MEventTextSize
		          gg.Bold = MyStyle.MHourBold
		          text = E.StartDate.ShortTime + " "
		          gg.DrawString(text, x+MyStyle.MTextOffset,y+ yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth-MyStyle.MTextOffset*2, True)
		          xx = gg.StringWidth(text)
		          gg.Bold = MyStyle.MTextBold
		          gg.DrawString(E.Title, x+MyStyle.MTextOffset + xx, y+yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth - MyStyle.MTextOffset - xx, True)
		          
		        end if //End of Drawing event
		        
		        
		        
		        'yy = yy + MyStyle.MEventHeight +1
		        
		        
		        
		      elseIf E.Visible = False then //Event doesn't start on that day but we make sure it's space is locked+
		        If E.StartDate.SQLDate < DrawDate.SQLDate and E.EndDate.SQLDate >= DrawDate.SQLDate then
		          Call DrawPos.LockLast((E.StartSeconds - FirstDate.TotalSeconds) / 86400, E.Length / 86400)
		          'DrawPos.AddHidden(i, E.Length / 86400)
		        End If
		        
		      End If
		      
		      
		    Next
		    
		    //Drawing the +xx hidden events
		    If DrawPos.Hidden(i) > 0 then
		      gg.TextSize = MyStyle.MEventTextSize
		      gg.ForeColor = &c0000FF
		      yy = DrawPos.LockLast((DrawDate.TotalSeconds - FirstDate.TotalSeconds) / 86400, 0) * (MyStyle.MEventHeight+1)
		      'yy = DrawPos.Search(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400), E.Length/86400) * (MyStyle.MEventHeight+1)
		      If MoreEventsDate <> Nil and MoreEventsDate.SQLDate = DrawDate.SQLDate then
		        gg.Underline = True
		      End If
		      gg.Bold = False
		      
		      gg.DrawString("+" + str(DrawPos.Hidden(i)), x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent)
		      If gg.Underline then
		        gg.Underline = False
		      End If
		    End If
		    
		    If MonthsPopup.Visible and DrawDate.SQLDate = MonthsPopup.SQLDate then
		      MonthPopupX = x
		      MonthPopupY = y-17-MyStyle.MNumberYOffset
		    End If
		    
		    If i mod 7 = 0 then
		      y = y + DayHeight
		      x = 0
		    else
		      x = x + DayWidth
		    End If
		    
		    DrawDate.Day = DrawDate.Day + 1
		  Next
		  
		  If MonthsPopup.Visible then
		    DrawMonthPopup(gg, MonthPopupX, MonthPopupY, Round(DayWidth)+1, Round(DayHeight)+1)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawEventsMonth_old(gg As Graphics, WeeksPerMonth As Integer, DayWidth As Single, DayHeight As Single)
		  #if False
		    'Dim mp As new MethodProfiler(CurrentMethodName)
		    If DayHeight < 30 then Return
		    If DayWidth < 30 then Return
		    
		    If UBound(Events) = -1 then Return
		    
		    Dim i, j, k, u, Idx, DrawIdx, RealLength, v, DeltaX, LeftOffset As Integer
		    Dim text As String
		    Dim x, xx,y, yy As Single
		    Dim p As Picture
		    Dim gp As Graphics
		    Dim E As CalendarEvent
		    Dim DrawDate As Date = New Date
		    DrawDate.Hour = 0
		    DrawDate.Minute = 0
		    DrawDate.Second = 0
		    DrawDate.SQLDate = FirstDate.SQLDate
		    'DrawDate.Day = DrawDate.Day + 1
		    Dim okToDraw As Boolean
		    
		    If UBound(DisplayEvents) = -1 Then
		      SortEvents(FirstDate, LastDate)
		    End If
		    
		    u = UBound(DisplayEvents)
		    If u = -1 then Return
		    
		    y = HeaderHeight+17+MyStyle.MNumberYOffset
		    x = 0
		    LeftOffset = MyStyle.MLeftOffset
		    
		    'Dim amount() As Integer
		    'Redim amount(WeeksPerMonth * 7)
		    
		    Dim DrawPos As New CalendarDrawPosition(WeeksPerMonth*7, (DayHeight-17) / (MyStyle.MEventHeight+1) -1)
		    
		    For i = 1 to WeeksPerMonth * 7
		      okToDraw = True
		      
		      For j = Idx to u
		        
		        E = DisplayEvents(j)
		        
		        If E.StartDate.SQLDate > DrawDate.SQLDate then
		          Idx = j
		          Exit for j
		        End If
		        
		        If (DrawDate.SQLDate = E.StartDate.SQLDate) or (i=1 and DrawDate > E.StartDate) then
		          
		          If okToDraw then
		            'If j<u and DisplayEvents(j+1).Day = E.Day and DrawPos.Remain((E.StartSeconds - FirstDate.TotalSeconds) / 86400) <2 then
		            If j < u and DisplayEvents(j+1).StartSeconds <= E.EndSeconds and DrawPos.Remain(max(0, (DisplayEvents(j+1).StartSeconds - FirstDate.TotalSeconds) / 86400)) < 1 then
		              okToDraw = False
		            else
		              v = DrawPos.Remain(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400))
		              If v < 1 and DrawPos.Hidden(i) > 0 then
		                okToDraw = False
		              elseif v < 0 then
		                okToDraw = False
		              else
		                okToDraw = True
		              End If
		            End If
		          End If
		          
		          
		          If not okToDraw then
		            DrawPos.AddHidden(i, E.Length/86400)
		            E.Visible = False
		            Continue For j
		            
		          End If
		          
		          E.Visible = True
		          yy = DrawPos.Search(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400), E.Length/86400) * (MyStyle.MEventHeight+1)
		          
		          //Event is a whole day event
		          If E.StartDate.Hour = 0 and E.StartDate.Minute = 0 and E.Length mod 86400 = 0 or E.Length > 86400 then
		            RealLength = Floor(E.Length / 86400) + 1 - max(0, (FirstDate.TotalSeconds - E.StartSeconds) / 86400)
		            
		            //Only events that start at 0:00 and length mod 86400=0 have to be set as DayEvents
		            If E.StartDate.Hour = 0 and E.StartDate.Minute = 0 and E.Length mod 86400 = 0 then
		              E.DayEvent = True
		            End If
		            
		            
		            p = New Picture(DayWidth * max(1, min(RealLength, 43)) - LeftOffset * 2+1, MyStyle.MEventHeight, 32)
		            gp = p.Graphics
		            
		            
		            //Drawing background color
		            If MyStyle.MColorOffset1 <> MyStyle.MColorOffset2 then
		              If MyStyle.MEventFill = FillGradientVertical then
		                gradient(gp, 0, gp.Height, ShiftColor(E.EventColor, MyStyle.MColorOffset1), ShiftColor(E.EventColor, MyStyle.MColorOffset2), True)
		              elseif MyStyle.MEventFill = FillGradientHorizontal then
		                gradient(gp, 0, gp.Width, ShiftColor(E.EventColor, MyStyle.MColorOffset1), ShiftColor(E.EventColor, MyStyle.MColorOffset2), False)
		              elseif MyStyle.MEventFill = FillSolid then
		                gp.ForeColor = E.EventColor
		                gp.FillRect(0, 0, gp.Width, gp.Height)
		              elseif MyStyle.MEventFill = FillOutlook2013 then
		                gp.ForeColor = E.EventColor
		                gp.FillRect(0, 0, 8, gp.Height)
		                gp.ForeColor = ShiftColor(E.EventColor, MyStyle.MColorOffset1)
		                gp.FillRect(8, 0, gp.Width, gp.Height)
		                If E.DayEvent then
		                  gp.ForeColor = &cFFFFFF
		                  gp.FillRect(1, 1, 6, gp.Height-2)
		                End If
		              End If
		              If MyStyle.MBorderSolid then
		                gp.ForeColor = E.EventColor
		                gp.DrawRect(0, 0, gp.Width, gp.Height)
		                If MyStyle.MDayRoundRect then
		                  gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 6, 6)
		                  gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 8, 8)
		                End If
		              End If
		            else
		              gp.ForeColor = ShiftColor(E.EventColor, MyStyle.MColorOffset1)
		              gp.FillRect(0, 0, gp.Width, gp.Height)
		            End If
		            
		            If MyStyle.MDayRoundRect or MyStyle.MDayTransparent then
		              
		              //Drawing picture mask
		              gp = p.Mask.Graphics
		              gp.ForeColor = &cFFFFFF
		              gp.FillRect(0, 0, gp.Width, gp.Height)
		              If MyStyle.MDayRoundRect then
		                
		                gp.ForeColor = mixColor(MyStyle.MDayTransparency, &cFFFFFF, &hB8)
		                gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 4, 4)
		                gp.ForeColor = mixColor(MyStyle.MDayTransparency, &cFFFFFF, &hF)
		                gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 6, 6)
		                If MyStyle.MBorderSolid then
		                  gp.ForeColor = &c0
		                  gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 8, 8)
		                  If MyStyle.MDayTransparent then
		                    gp.ForeColor = MyStyle.MDayTransparency
		                  else
		                    gp.ForeColor = &c0
		                  End If
		                  gp.FillRoundRect(1, 1, gp.Width-2, gp.Height-2, 6, 6)
		                else
		                  If MyStyle.MDayTransparent then
		                    gp.ForeColor = MyStyle.MDayTransparency
		                  else
		                    gp.ForeColor = &c0
		                  End If
		                  gp.FillRoundRect(0, 0, gp.Width, gp.Height, 8, 8)
		                End If
		                gp.Pixel(1, 1) = &c707070
		                gp.Pixel(gp.Width-2, 1) = &c707070
		                gp.Pixel(1, gp.Height-2) = &c707070
		                gp.Pixel(gp.Width-2, gp.Height-2) = &c707070
		              else
		                gp.ForeColor = MyStyle.MDayTransparency
		                gp.FillRect(0, 0, gp.Width, gp.Height)
		              End If
		              'elseif MyStyle.MDayTransparency <> &c0 then
		              'gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.MDayTransparency.Red)
		              'gp.FillRect(1, 1, gp.Width-2, gp.Height-2)
		            End If
		            
		            //Should go on to the next week line
		            If x + p.Width > gg.Width+5 then
		              
		              Dim remainDays As Integer = RealLength
		              DrawIdx = 0
		              xx = x
		              
		              While remainDays>0
		                DrawEvent(gg, E, xx, y + yy + DayHeight*DrawIdx, _
		                DayWidth * min(7, remainDays) - LeftOffset * 2, MyStyle.MEventHeight, _
		                E.DayEvent)
		                
		                If DrawIdx = 0 then
		                  remainDays = remainDays - (7-Round(x/DayWidth))
		                else
		                  remainDays = remainDays - 7
		                End If
		                
		                xx=MyStyle.MLeftOffset
		                DrawIdx = DrawIdx + 1
		              Wend
		              
		              
		              
		              gp = p.Mask.Graphics
		              gp.ForeColor = &cFFFFFF
		              v = Floor(MyStyle.MEventHeight/2)
		              xx = gg.Width - x
		              RealLength = p.Width
		              While RealLength > 3
		                
		                If RealLength > gg.Width+3 then
		                  For k = 0 to v
		                    gp.DrawLine(xx-(v-k), k, xx+(v-k), k)
		                  Next
		                  For k = v to MyStyle.MEventHeight
		                    gp.DrawLine(xx-(k-v), k, xx+(k-v), k)
		                  Next
		                End If
		                
		                If DrawIdx = 0 then
		                  'gg.DrawPicture(p, x, y + yy, gg.Width-x)
		                  RealLength = RealLength - xx
		                  DeltaX = xx
		                else
		                  'gg.DrawPicture(p, 1, y + yy + DayHeight * DrawIdx, -10000, -10000, DeltaX+1)
		                  RealLength = RealLength - gg.Width
		                  DeltaX = DeltaX + gg.Width
		                End If
		                xx = xx + gg.Width
		                DrawIdx = DrawIdx + 1
		                
		              Wend
		              
		            else
		              //testing
		              DrawEvent(gg, E, x+MyStyle.MLeftOffset, y + yy, _
		              DayWidth * max(1, min(RealLength, 43)) - LeftOffset * 2, MyStyle.MEventHeight, _
		              E.DayEvent)
		              'gg.DrawPicture(p, x+MyStyle.MLeftOffset, y+yy)
		            End If
		            
		            E.drawX = x
		            E.DrawY = y + yy
		            E.DrawW = p.Width
		            E.DrawH = p.Height
		            
		            //Drawing Text
		            gg.ForeColor = MyStyle.WTextColor
		            If StyleType = StyleOutlook2013 then
		              gg.ForeColor = mixColor(E.EventColor, &c0, &hB0)
		            else
		              If E.EventColor.Hue = E.EventColor.Saturation then
		                If E.EventColor.Value < 0.5 then
		                  gg.ForeColor = InvertColor(gg.ForeColor)
		                End if
		              elseif E.EventColor.Value < 0.9 then
		                gg.ForeColor = InvertColor(gg.ForeColor)
		              End If
		            End If
		            gg.TextSize = MyStyle.MEventTextSize
		            gg.Bold = MyStyle.MDayTextBold
		            If E.DayEvent then
		              gg.DrawString(E.Title, x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, max(1, E.Length/86400+1) * DayWidth-MyStyle.MTextOffset*2, True)
		            else
		              gg.DrawString(E.StartDate.ShortTime + " " + E.Title, x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, max(1, E.Length/86400+1) * DayWidth-MyStyle.MTextOffset*2, True)
		            End If
		            
		          else //Not a whole day event
		            
		            E.drawX = x
		            E.DrawY = y + yy
		            E.DrawW = DayWidth
		            E.DrawH = MyStyle.MEventHeight
		            
		            //Drawing Text
		            gg.ForeColor = E.EventColor
		            
		            If MyStyle.MEventFill = FillOutlook2013 then
		              //testing
		              DrawEvent(gg, E, x+MyStyle.MLeftOffset, y + yy, _
		              DayWidth - LeftOffset * 2+1, MyStyle.MEventHeight, False)
		              
		              'p = New Picture(DayWidth - LeftOffset * 2+1, MyStyle.MEventHeight, 32)
		              'gp = p.Graphics
		              'gp.ForeColor = E.EventColor
		              'gp.FillRect(0, 0, 8, gp.Height)
		              'gp.ForeColor = ShiftColor(E.EventColor, MyStyle.MColorOffset1)
		              'gp.FillRect(8, 0, gp.Width, gp.Height)
		              'gg.DrawPicture(p, x+MyStyle.MLeftOffset, y+yy)
		              'gg.ForeColor = mixColor(E.EventColor, &c0, &hB0)
		            End If
		            
		            gg.TextSize = MyStyle.MEventTextSize
		            gg.Bold = MyStyle.MHourBold
		            text = E.StartDate.ShortTime + " "
		            gg.DrawString(text, x+MyStyle.MTextOffset,y+ yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth-MyStyle.MTextOffset*2, True)
		            xx = gg.StringWidth(text)
		            gg.Bold = MyStyle.MTextBold
		            gg.DrawString(E.Title, x+MyStyle.MTextOffset + xx, y+yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth - MyStyle.MTextOffset - xx, True)
		            
		          end if //End of Drawing event
		          
		          
		          
		          'yy = yy + MyStyle.MEventHeight +1
		          
		          
		          
		        elseIf E.Visible = False then //Event doesn't start on that day but we make sure it's space is locked+
		          If E.StartDate.SQLDate < DrawDate.SQLDate and E.EndDate.SQLDate >= DrawDate.SQLDate then
		            Call DrawPos.LockLast((E.StartSeconds - FirstDate.TotalSeconds) / 86400, E.Length / 86400)
		            'DrawPos.AddHidden(i, E.Length / 86400)
		          End If
		          
		        End If
		        
		        
		      Next
		      
		      //Drawing the +xx hidden events
		      If DrawPos.Hidden(i) > 0 then
		        gg.TextSize = MyStyle.MEventTextSize
		        gg.ForeColor = &c0000FF
		        yy = DrawPos.LockLast((DrawDate.TotalSeconds - FirstDate.TotalSeconds) / 86400, 0)+1
		        gg.DrawString("+" + str(DrawPos.Hidden(i)), x+MyStyle.MTextOffset, y + yy*(MyStyle.MEventHeight))
		      End If
		      
		      If i mod 7 = 0 then
		        y = y + DayHeight
		        x = 0
		      else
		        x = x + DayWidth
		      End If
		      
		      DrawDate.Day = DrawDate.Day + 1
		    Next
		  #else
		    
		    #Pragma Unused gg
		    #Pragma Unused WeeksPerMonth
		    #Pragma Unused DayWidth
		    #Pragma Unused DayHeight
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawEventsWeek(gg As Graphics, DayWidth As Single)
		  'Dim mp As new MethodProfiler(CurrentMethodName)
		  
		  Dim i, j, u, v, Idx, maxAmount As Integer
		  Dim text As String
		  Dim x, xx,y, yy, w As Single
		  
		  Dim E As CalendarEvent
		  Dim DrawDate As Date = New Date
		  DrawDate.Hour = 0
		  DrawDate.Minute = 0
		  DrawDate.Second = 0
		  DrawDate.SQLDate = FirstDate.SQLDate
		  
		  Dim WholeDay As Boolean
		  Dim FirstJ As Integer
		  Dim okToDraw As Boolean
		  
		  
		  
		  Dim Precision as Integer = 12
		  
		  Dim DrawPosDay As New CalendarDrawPosition(ViewDays, (ViewHeight-HeaderHeight-3) / MyStyle.WEventHeight-1)
		  Dim DrawAmountHour As New CalendarDrawPosition(ViewDays*24*Precision, 10)
		  Dim DrawPosHour As New CalendarDrawPosition(ViewDays*24*Precision, 10)
		  
		  Dim gc As Graphics = gg.Clip(0, ViewHeight, gg.Width, gg.Height-ViewHeight)
		  Dim gpc As Graphics
		  
		  Dim gDay As Graphics
		  If DayEventsHeight >-1 then
		    gDay = gg.Clip(0, HeaderHeight+1, gg.Width, DayEventsHeight-4)
		  else
		    gDay = gg.Clip(0, HeaderHeight+1, gg.Width, me.ViewHeight-HeaderHeight-4)
		  End If
		  
		  //Adding DragEvent
		  If SelStart <> Nil and SelEnd <> Nil and (SelStart.TotalSeconds <> SelEnd.TotalSeconds or DayEventClicked) then
		    E = New CalendarEvent("", SelStart, SelEnd)
		    E.FrontMost = True
		    E.EventColor = MyColors.WDefaultColor
		    
		    ReDim DisplayEvents(-1)
		    DisplayEvents.Append E
		    SortEvents(FirstDate, LastDate, True)
		  else
		    SortEvents(FirstDate, LastDate)
		  End If
		  
		  //If no events to draw we get out
		  u = UBound(DisplayEvents)
		  If u =-1 then Return
		  
		  
		  y = ViewHeight
		  x = TimeWidth+1
		  
		  
		  
		  For j = 0 to u
		    E = DisplayEvents(j)
		    //Event is a whole day event
		    If E.DayEvent then
		      
		    ElseIf E.StartDate.Hour = 0 and E.StartDate.Minute = 0 and E.Length mod 86400 = 0 then
		      E.DayEvent = True
		    Else
		      If E.DayEvent then
		        E.DayEvent = False
		      End If
		      Call DrawAmountHour.Search(max(0, (E.StartSeconds - FirstDate.TotalSeconds)\(3600/Precision)), (E.EndSeconds-E.StartSeconds)\(3600/Precision)-1)
		    End If
		  Next
		  
		  FirstJ = 0
		  
		  //Cycle all Events to draw
		  For i = 1 to ViewDays
		    y = ViewHeight
		    
		    
		    For j = Idx to u
		      xx = 0
		      
		      //Getting Current Event
		      E = DisplayEvents(j)
		      
		      
		      If E.StartDate.SQLDate > DrawDate.SQLDate then
		        Exit for j
		      elseif E.DayEvent and E.StartDate < DrawDate and i>1 then
		        Idx = Firstj
		        Continue for j
		      elseif E.StartDate < DrawDate and E.EndDate.SQLDate < DrawDate.SQLDate then
		        Idx = Firstj
		        Continue for j
		      elseif E.StartDate < DrawDate and E.EndDate.SQLDate>=DrawDate.SQLDate then
		        'if Keyboard.ControlKey then
		        'idx = idx
		        'end if
		      End If
		      
		      'If E.StartDate.SQLDate = DrawDate.SQLDate or (i=1 and E.StartDate < DrawDate) then //or (E.StartDate < DrawDate and E.EndDate.SQLDate>=DrawDate.SQLDate) then
		      
		      FirstJ = j
		      
		      //Setting up the metrics of the Event
		      
		      //Event is a whole day event
		      If E.DayEvent then
		        WholeDay = true
		        y = HeaderHeight +1
		        
		        If j < u and DisplayEvents(j+1).StartSeconds <= E.EndSeconds and DisplayEvents(j+1).DayEvent _
		          and DrawPosDay.Remain(max(0, (DisplayEvents(j+1).StartSeconds - FirstDate.TotalSeconds) / 86400)) < 1 then
		          okToDraw = False
		        else
		          v = DrawPosDay.Remain(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400))
		          If v < 1 and DrawPosDay.Hidden(i) > 0 then
		            okToDraw = False
		          elseif v < 0 then
		            okToDraw = False
		          else
		            okToDraw = True
		          End If
		        End If
		        
		        If DayEventsHeight= 0 then
		          okToDraw = False
		        End If
		        
		        If okToDraw then
		          
		          If E.StartDate < DrawDate then
		            w = max(1, min(Floor(E.EndDate.TotalSeconds - DrawDate.TotalSeconds) / 86400, ViewDays))
		          else
		            w = max(1, min(ViewDays - (E.StartDate.TotalSeconds-FirstDate.TotalSeconds)/86400, E.Length/86400+1))
		          End If
		          
		          yy = DrawPosDay.Search(max(0,(E.StartSeconds - FirstDate.TotalSeconds) / 86400), w-1) * MyStyle.WEventHeight
		          
		          //Seems this has no use
		          'w = max(0, Ceil((E.EndDate.TotalSeconds - LastDate.TotalSeconds)/86400))
		          
		        else
		          DrawPosDay.AddHidden(i, E.Length/86400)
		          E.Visible = False
		          Continue for j
		        End If
		        
		      else //Not All day event
		        
		        //Finding Y position of the Event
		        If HideNightTime and E.StartDate.Hour >= DayStartHour and E.StartDate.Hour < DayEndHour then
		          y = Ceil(ViewHeight - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + (E.StartDate.Hour-DayStartHour+1 + E.StartDate.Minute/60) * Hourheight)
		        elseif not HideNightTime then
		          y = Ceil(ViewHeight - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + (E.StartDate.Hour + E.StartDate.Minute/60) * Hourheight)
		        End If
		        
		        If E.StartDate < DrawDate then
		          Dim nbDays As Integer = Ceil((DrawDate.TotalSeconds - E.StartSeconds)/86400)
		          
		          y = y - HourHeight*24*nbDays
		        End If
		        //A corriger
		        
		        //If Event is out of ViewRange
		        If y + E.Length / 3600 * HourHeight < ViewHeight or y > gg.Height then
		          Continue for j
		        End If
		        
		        
		        WholeDay = False
		        
		        maxAmount = 10-DrawAmountHour.Remain((E.StartSeconds-FirstDate.TotalSeconds)\(3600/Precision), E.Length\(3600/Precision))
		        
		        xx = DrawPosHour.Search((E.StartSeconds-FirstDate.TotalSeconds)\(3600/Precision), E.Length\(3600/Precision)-1) * DayWidth/maxAmount
		        
		        If E.StartDate<DrawDate then
		          xx = E.DrawX-(X-DayWidth)
		        else
		          E.DrawX = xx
		        End If
		        
		        If not E.FrontMost and maxAmount > 0 then
		          w = (DayWidth-1) / (maxAmount)
		        else
		          w = DayWidth-1
		        End If
		        If E.FrontMost then
		          xx = 0
		        End If
		        
		      end if
		      
		      
		      //Drawing the event and Text
		      If WholeDay then
		        E.DrawX = X
		        E.DrawY = Y + YY
		        E.DrawH = MyStyle.WEventHeight
		        E.DrawW = DayWidth*w
		        
		        
		        //Drawing the Event
		        DrawEvent(gDay, E, x, yy, DayWidth * w, MyStyle.WEventHeight, True)
		        
		        
		        //Drawing Text
		        If MyStyle.WAutoTextColor then
		          gDay.ForeColor = E.EventColor
		          
		          If E.EventColor.Saturation < 1.0 then
		            gDay.ForeColor = mixColor(E.EventColor, &c0, &h60)
		          End If
		          
		        else
		          gDay.ForeColor = MyStyle.WTextColor
		          If E.EventColor.Hue = E.EventColor.Saturation then
		            If E.EventColor.Value < 0.5 then
		              gDay.ForeColor = InvertColor(gDay.ForeColor)
		            End if
		          elseif E.EventColor.Value < 0.9 then
		            gDay.ForeColor = InvertColor(gDay.ForeColor)
		          End If
		        End If
		        gDay.TextSize = MyStyle.WHeaderTextSize
		        
		        gDay.DrawString(E.Title, x+MyStyle.MTextOffset,  yy + (18-gDay.TextHeight)\2 + gDay.TextAscent, max(1, E.Length/86400+1) * DayWidth -6, True)
		        
		        
		        
		      Else //Not all day
		        
		        If E.StartDate>=DrawDate then
		          E.DrawX = X + XX
		        End If
		        
		        E.DrawY = Y
		        E.DrawW = W
		        E.DrawH = max(HourHeight/2, E.Length / 3600 * HourHeight)
		        
		        
		        y = y-ViewHeight
		        
		        DrawEvent(gc, E, X+XX, Y, Round(w), max(HourHeight/2, E.Length / 3600 * HourHeight), False)
		        
		        gpc = gc.Clip(Floor(X+XX), Y, W, E.DrawH-1)
		        If E.MouseOver and E.Editable then
		          If MyStyle.WAutoTextColor then
		            gpc.ForeColor = E.EventColor
		          else
		            gpc.ForeColor = MyStyle.WTextColor
		            If E.EventColor.Hue = E.EventColor.Saturation then
		              If E.EventColor.Value < 0.5 then
		                gpc.ForeColor = InvertColor(gpc.ForeColor)
		              End if
		            elseif E.EventColor.Value < 0.9 then
		              gpc.ForeColor = InvertColor(gpc.ForeColor)
		            End If
		          End If
		          gpc.DrawLine(E.DrawW\2-3, E.DrawH-5, E.DrawW\2+3, E.DrawH-5)
		          gpc.DrawLine(E.DrawW\2-3, E.DrawH-3, E.DrawW\2+3, E.DrawH-3)
		        End If
		        
		        
		        //Drawing Text
		        If MyStyle.WAutoTextColor then
		          gpc.ForeColor = E.EventColor
		          
		          If E.EventColor.Saturation < 1.0 then
		            gpc.ForeColor = mixColor(E.EventColor, &c0, &h60)
		          End If
		          
		        else
		          
		          If StyleType = StyleOutlook2013 then
		            gpc.ForeColor = mixColor(E.EventColor, &c0, &hB0)
		          else
		            gpc.ForeColor = MyStyle.WTextColor
		            If E.EventColor.Hue = E.EventColor.Saturation then
		              If E.EventColor.Value < 0.5 then
		                gpc.ForeColor = InvertColor(gpc.ForeColor)
		              End if
		            elseif E.EventColor.Value < 0.9 then
		              gpc.ForeColor = InvertColor(gpc.ForeColor)
		            End If
		          End If
		        End If
		        gpc.TextSize = MyStyle.WHeaderTextSize
		        gpc.Bold = MyStyle.WHeaderTextBold
		        
		        //Fix Version 1.7
		        If MyStyle.WHeaderHeight > 0 then
		          yy = (MyStyle.WHeaderHeight-gpc.TextSize)/2 + gpc.TextAscent
		        else
		          yy = gpc.TextAscent + 1
		        End If
		        
		        If yy < E.DrawH then
		          text = MyStyle.WHeaderTextFormat.Replace("%Start", E.StartDate.ShortTime).Replace("%End", E.EndDate.ShortTime)
		          If text.InStr("%Length")>0 then
		            text = text.Replace("%Length", str(Floor(E.Length/3600)) + ":" + Format(E.Length/60 - Floor(E.Length/3600) * 60, "00"))
		          End If
		          If text <> "" then
		            gpc.DrawString(text, 1+MyStyle.MTextOffset, yy, w-6, True)
		          End If
		        else
		          gpc.DrawString("...", 1+MyStyle.MTextOffset, E.DrawH - 1)
		          Continue for j
		        End If
		        'End If
		        gpc.TextSize = MyStyle.WBodyTextSize
		        gpc.Bold = MyStyle.WBodyTextBold
		        
		        If text <> "" then
		          If MyStyle.WHeaderHeight>0 then
		            yy = max(yy+gpc.TextHeight, MyStyle.WHeaderHeight+gpc.TextHeight)
		          else
		            yy = yy + gpc.TextHeight
		          End If
		        End If
		        
		        text = ""
		        text = E.Title
		        if E.Location <> "" then
		          text = text + " – " + E.Location
		        end if
		        if E.Description <> "" then
		          text = text + EndOfLine + E.Description
		        end if
		        
		        
		        gpc.DrawString(text, 1+MyStyle.MTextOffset, yy, w - 8, False)
		        
		      End If
		      
		      
		      'else
		      '
		      ''Idx = 0
		      'Idx = j
		      'Idx = Firstj
		      '
		      'End If
		      
		    Next
		    
		    //Drawing the +xx hidden events
		    If DrawPosDay.Hidden(i) > 0 and DayEventsHeight <> 0 then
		      gDay.TextSize = MyStyle.WHeaderTextSize
		      gDay.ForeColor = &c0000FF
		      yy = DrawPosDay.LockLast((DrawDate.TotalSeconds - FirstDate.TotalSeconds) / 86400, 0)
		      If yy*(MyStyle.WEventHeight) + gDay.TextHeight < DayEventsHeight then
		        gDay.DrawString("+" + str(DrawPosDay.Hidden(i)), x+MyStyle.MTextOffset, yy*(MyStyle.WEventHeight) + gDay.TextHeight)
		      End If
		    End If
		    
		    
		    x = x + DayWidth
		    DrawDate.Day = DrawDate.Day + 1
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawEventsWeek_old(gg As Graphics, DayWidth As Single)
		  #if False
		    'Dim mp As new MethodProfiler(CurrentMethodName)
		    
		    Dim i, j, u, v, Idx, maxAmount As Integer
		    Dim text As String
		    Dim x, xx,y, yy, w As Single
		    Dim p As Picture
		    Dim gp As Graphics
		    Dim E As CalendarEvent
		    Dim DrawDate As Date = New Date
		    DrawDate.Hour = 0
		    DrawDate.Minute = 0
		    DrawDate.Second = 0
		    DrawDate.SQLDate = FirstDate.SQLDate
		    Dim WholeDay As Boolean
		    Dim FirstJ As Integer
		    Dim okToDraw As Boolean
		    Dim HasBuffer As Boolean
		    
		    
		    Dim Precision as Integer = 12
		    
		    Dim DrawPosDay As New CalendarDrawPosition(ViewDays, (ViewHeight-HeaderHeight-3) / MyStyle.WEventHeight-1)
		    Dim DrawAmountHour As New CalendarDrawPosition(ViewDays*24*Precision, 10)
		    Dim DrawPosHour As New CalendarDrawPosition(ViewDays*24*Precision, 10)
		    
		    Dim gc As Graphics = gg.Clip(0, ViewHeight, gg.Width, gg.Height-ViewHeight)
		    Dim gpc As Graphics
		    
		    Dim gDay As Graphics
		    If DayEventsHeight >-1 then
		      gDay = gg.Clip(0, HeaderHeight+1, gg.Width, DayEventsHeight-4)
		    else
		      gDay = gg.Clip(0, HeaderHeight+1, gg.Width, me.ViewHeight-HeaderHeight-4)
		    End If
		    
		    //Adding DragEvent
		    If SelStart <> Nil and SelEnd <> Nil and (SelStart <> SelEnd or DayEventClicked) then
		      E = New CalendarEvent("", SelStart, SelEnd)
		      E.FrontMost = True
		      E.EventColor = MyColors.WDefaultColor
		      
		      ReDim DisplayEvents(-1)
		      DisplayEvents.Append E
		      SortEvents(FirstDate, LastDate, True)
		    else
		      SortEvents(FirstDate, LastDate)
		    End If
		    
		    //If no events to draw we get out
		    u = UBound(DisplayEvents)
		    If u =-1 then Return
		    
		    
		    y = ViewHeight
		    x = TimeWidth+1
		    
		    
		    
		    For j = 0 to u
		      E = DisplayEvents(j)
		      //Event is a whole day event
		      If E.DayEvent then
		        
		      ElseIf E.StartDate.Hour = 0 and E.StartDate.Minute = 0 and E.Length mod 86400 = 0 then
		        E.DayEvent = True
		      Else
		        If E.DayEvent then
		          E.DayEvent = False
		        End If
		        Call DrawAmountHour.Search(max(0, (E.StartSeconds - FirstDate.TotalSeconds)\(3600/Precision)), (E.EndSeconds-E.StartSeconds)\(3600/Precision)-1)
		      End If
		    Next
		    
		    FirstJ = 0
		    
		    //Cycle all Events to draw
		    For i = 1 to ViewDays
		      y = ViewHeight
		      
		      
		      For j = Idx to u
		        xx = 0
		        
		        //Getting Current Event
		        E = DisplayEvents(j)
		        HasBuffer = (E.Buffer <> Nil and E.FrontMost=False and E.MouseOver = False)
		        
		        
		        
		        If E.StartDate.SQLDate > DrawDate.SQLDate then
		          Exit for j
		        elseif E.DayEvent and E.StartDate < DrawDate and i>1 then
		          Idx = Firstj
		          Continue for j
		        elseif E.StartDate < DrawDate and E.EndDate.SQLDate < DrawDate.SQLDate then
		          Idx = Firstj
		          Continue for j
		        elseif E.StartDate < DrawDate and E.EndDate.SQLDate>=DrawDate.SQLDate then
		          'if Keyboard.ControlKey then
		          'idx = idx
		          'end if
		        End If
		        
		        'If E.StartDate.SQLDate = DrawDate.SQLDate or (i=1 and E.StartDate < DrawDate) then //or (E.StartDate < DrawDate and E.EndDate.SQLDate>=DrawDate.SQLDate) then
		        
		        FirstJ = j
		        
		        //Event is a whole day event
		        If E.DayEvent then
		          WholeDay = true
		          y = HeaderHeight +1
		          
		          If j < u and DisplayEvents(j+1).StartSeconds <= E.EndSeconds and DisplayEvents(j+1).DayEvent _
		            and DrawPosDay.Remain(max(0, (DisplayEvents(j+1).StartSeconds - FirstDate.TotalSeconds) / 86400)) < 1 then
		            okToDraw = False
		          else
		            v = DrawPosDay.Remain(max(0, (E.StartSeconds - FirstDate.TotalSeconds) / 86400))
		            If v < 1 and DrawPosDay.Hidden(i) > 0 then
		              okToDraw = False
		            elseif v < 0 then
		              okToDraw = False
		            else
		              okToDraw = True
		            End If
		          End If
		          
		          If DayEventsHeight= 0 then
		            okToDraw = False
		          End If
		          
		          If okToDraw then
		            
		            If E.StartDate < DrawDate then
		              w = max(1, min(Floor(E.EndDate.TotalSeconds - DrawDate.TotalSeconds) / 86400, ViewDays))
		            else
		              w = max(1, min(ViewDays - (E.StartDate.TotalSeconds-FirstDate.TotalSeconds)/86400, E.Length/86400+1))
		            End If
		            If not HasBuffer then
		              p = New Picture(DayWidth * w + 1, MyStyle.WEventHeight, 32)
		            End If
		            
		            yy = DrawPosDay.Search(max(0,(E.StartSeconds - FirstDate.TotalSeconds) / 86400), w-1) * MyStyle.WEventHeight
		            
		            //Seems this has no use
		            'w = max(0, Ceil((E.EndDate.TotalSeconds - LastDate.TotalSeconds)/86400))
		            
		          else
		            DrawPosDay.AddHidden(i, E.Length/86400)
		            E.Visible = False
		            Continue for j
		          End If
		          
		        else //Not All day event
		          
		          //Finding Y position of the Event
		          If HideNightTime and E.StartDate.Hour >= DayStartHour and E.StartDate.Hour < DayEndHour then
		            y = Ceil(ViewHeight - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + (E.StartDate.Hour-DayStartHour+1 + E.StartDate.Minute/60) * Hourheight)
		          elseif not HideNightTime then
		            y = Ceil(ViewHeight - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours + (E.StartDate.Hour + E.StartDate.Minute/60) * Hourheight)
		          End If
		          
		          If E.StartDate < DrawDate then
		            Dim nbDays As Integer = Ceil((DrawDate.TotalSeconds - E.StartSeconds)/86400)
		            
		            y = y - HourHeight*24*nbDays
		          End If
		          //A corriger
		          
		          //If Event is out of ViewRange
		          If y + E.Length / 3600 * HourHeight < ViewHeight or y > gg.Height then
		            Continue for j
		          End If
		          
		          
		          WholeDay = False
		          
		          maxAmount = 10-DrawAmountHour.Remain((E.StartSeconds-FirstDate.TotalSeconds)\(3600/Precision), E.Length\(3600/Precision))
		          
		          xx = DrawPosHour.Search((E.StartSeconds-FirstDate.TotalSeconds)\(3600/Precision), E.Length\(3600/Precision)-1) * DayWidth/maxAmount
		          
		          If E.StartDate<DrawDate then
		            xx = E.DrawX-(X-DayWidth)
		          else
		            E.DrawX = xx
		          End If
		          
		          If not E.FrontMost and maxAmount > 0 then
		            w = (DayWidth-1) / (maxAmount)
		          else
		            w = DayWidth-1
		          End If
		          If E.FrontMost then
		            xx = 0
		          End If
		          
		          If HasBuffer then
		            If E.Buffer.Width <> Round(w) then
		              HasBuffer = False
		            End If
		          End If
		          
		          If not HasBuffer then
		            p = New Picture(Round(w), max(HourHeight/2, E.Length / 3600 * HourHeight), 32)
		          End If
		          
		        end if
		        
		        If not HasBuffer then
		          gp = p.Graphics
		          
		          //Drawing background color
		          If MyStyle.WRoundRect then //RoundRect
		            
		            
		            If MyStyle.WBodyColorOffset1 = MyStyle.WBodyColorOffset2 then //No gradient
		              gp.ForeColor = E.EventColor
		              gp.FillRect(0, 0, gp.Width, gp.Height)
		              If MyStyle.WHeaderHeight > 0 and not WholeDay then
		                gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WHeaderColorOffset)
		                gp.FillRoundRect(1, 1, gp.Width-2, 1+MyStyle.WHeaderHeight, 6,6)
		                gp.FillRect(1, 1+MyStyle.WHeaderHeight-2, gp.Width-2, 3)
		              End If
		              
		              gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WBodyColorOffset1)
		              gp.FillRoundRect(1, 1 + MyStyle.WHeaderHeight, gp.Width-2, gp.Height - 2 - MyStyle.WHeaderHeight, 6, 6)
		              gp.FillRect(1, 1 + MyStyle.WHeaderHeight, gp.Width-2, 3)
		            else
		              If MyStyle.WBodyGradientVertical then
		                gradient(gp, 1+ MyStyle.WHeaderHeight, gp.Height - 1 - MyStyle.WHeaderHeight, _
		                shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		                ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), True)
		              else
		                gradient(gp, 1, gp.Width-2, shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		                ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), False)
		              End If
		              
		              gp.ForeColor = E.EventColor
		              gp.DrawRect(0, 0, gp.Width, gp.Height)
		              gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 6,6)
		              gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 8,8)
		              If MyStyle.WHeaderHeight > 0 and not WholeDay then
		                gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WHeaderColorOffset)
		                gp.FillRoundRect(1, 1, gp.Width-2, 1+MyStyle.WHeaderHeight, 6,6)
		                gp.FillRect(1, 1+MyStyle.WHeaderHeight-2, gp.Width-2, 3)
		              End If
		            End If
		            
		            'If E.MouseOver and E.Editable then
		            'If MyStyle.WAutoTextColor then
		            'gp.ForeColor = E.EventColor
		            'else
		            'gp.ForeColor = MyStyle.WTextColor
		            'If E.EventColor.Hue = E.EventColor.Saturation then
		            'If E.EventColor.Value < 0.5 then
		            'gp.ForeColor = InvertColor(gp.ForeColor)
		            'End if
		            'elseif E.EventColor.Value < 0.9 then
		            'gp.ForeColor = InvertColor(gp.ForeColor)
		            'End If
		            'End If
		            'gp.DrawLine(gp.Width\2-3, gp.Height-5, gp.Width\2+3, gp.Height-5)
		            'gp.DrawLine(gp.Width\2-3, gp.Height-3, gp.Width\2+3, gp.Height-3)
		            'End If
		            
		            gp = p.Mask.Graphics
		            
		            //Drawing picture mask
		            gp.ForeColor = &cFFFFFF
		            gp.FillRect(0, 0, gp.Width, gp.Height)
		            gp.ForeColor = &cDDDDDD
		            gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 4, 4)
		            gp.ForeColor = &c888888
		            gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 6, 6)
		            gp.ForeColor = &c0
		            gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 8, 8)
		            gp.Pixel(1, 1) = &c707070
		            gp.Pixel(gp.Width-2, 1) = &c707070
		            gp.Pixel(1, gp.Height-2) = &c707070
		            gp.Pixel(gp.Width-2, gp.Height-2) = &c707070
		            
		            
		            If MyStyle.WBodyTransparency <> &c0 or MyStyle.WHeaderTransparency <> &c0 then
		              
		              If WholeDay then
		                gp.ForeColor = MyStyle.WBodyTransparency
		                gp.FillRoundRect(1, 1, gp.Width-2, gp.Height-2, 6, 6)
		                
		              Else //not WholeDay
		                
		                If MyStyle.WHeaderHeight > 0  then
		                  gp.ForeColor = MyStyle.WHeaderTransparency
		                  gp.FillRoundRect(1, 1, gp.Width-2, 1+MyStyle.WHeaderHeight, 6,6)
		                  gp.FillRect(1, 1+MyStyle.WHeaderHeight-3, gp.Width-2, 3)
		                End If
		                gp.ForeColor = MyStyle.WBodyTransparency
		                gp.FillRoundRect(1, 1+MyStyle.WHeaderHeight, gp.Width-2, gp.Height-2-MyStyle.WHeaderHeight, 6, 6)
		                If MyStyle.WHeaderHeight > 0 then
		                  gp.FillRect(1, 1+MyStyle.WHeaderHeight, gp.Width-2, 3)
		                End If
		                
		                'If E.MouseOver and E.Editable then
		                'gp.ForeColor = &c0
		                'gp.DrawLine(gp.Width\2-3, gp.Height-5, gp.Width\2+3, gp.Height-5)
		                'gp.DrawLine(gp.Width\2-3, gp.Height-3, gp.Width\2+3, gp.Height-3)
		                'End If
		                
		              End If
		            else
		              gp.ForeColor = &c0
		              gp.FillRoundRect(1, 1, gp.Width-2, gp.Height-2, 6, 6)
		            End If
		            
		          Else //not RoundRect
		            
		            If MyStyle.WEventFill = FillSolid then //No gradient
		              gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WBodyColorOffset1)
		              gp.FillRect(1, 1 + MyStyle.WHeaderHeight, gp.Width-2, gp.Height - 2 - MyStyle.WHeaderHeight)
		            elseif MyStyle.WEventFill = FillGradientVertical then
		              
		              gradient(gp, 1+ MyStyle.WHeaderHeight, gp.Height - 1 - MyStyle.WHeaderHeight, shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		              ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), True)
		            elseif MyStyle.WEventFill = FillGradientHorizontal Then
		              gradient(gp, 1, gp.Width-2, shiftColor(E.EventColor, MyStyle.WBodyColorOffset1), _
		              ShiftColor(E.EventColor, MyStyle.WBodyColorOffset2), False)
		              
		              //Outlook 2013 Style
		            elseif MyStyle.WEventFill = FillOutlook2013 then
		              gp.ForeColor = E.EventColor
		              gp.FillRect(0, 0, 8, gp.Height)
		              gp.ForeColor = ShiftColor(E.EventColor, MyStyle.MColorOffset1)
		              gp.FillRect(8, 0, gp.Width, gp.Height)
		              If E.DayEvent then
		                gp.ForeColor = &cFFFFFF
		                gp.FillRect(1, 1, 6, gp.Height-2)
		              End If
		            End If
		            
		            //Drawing border
		            If MyStyle.WEventFill <> FillOutlook2013 then
		              gp.ForeColor = E.EventColor
		              gp.DrawRect(0, 0, gp.Width, gp.Height)
		            End If
		            If MyStyle.WHeaderHeight > 0 then
		              gp.ForeColor = mixColor(E.EventColor, &cFFFFFF, MyStyle.WHeaderColorOffset)
		              gp.FillRect(1, 1, gp.Width-2, MyStyle.WHeaderHeight)
		            End If
		            
		            'If E.MouseOver and E.Editable then
		            'If MyStyle.WAutoTextColor then
		            'gp.ForeColor = E.EventColor
		            'else
		            'gp.ForeColor = MyStyle.WTextColor
		            'If E.EventColor.Hue = E.EventColor.Saturation then
		            'If E.EventColor.Value < 0.5 then
		            'gp.ForeColor = InvertColor(gp.ForeColor)
		            'End if
		            'elseif E.EventColor.Value < 0.9 then
		            'gp.ForeColor = InvertColor(gp.ForeColor)
		            'End If
		            'End If
		            'gp.DrawLine(gp.Width\2-3, gp.Height-5, gp.Width\2+3, gp.Height-5)
		            'gp.DrawLine(gp.Width\2-3, gp.Height-3, gp.Width\2+3, gp.Height-3)
		            'End If
		            
		            gp = p.Mask.Graphics
		            If MyStyle.WHeaderHeight > 0 and MyStyle.WHeaderTransparency <> &c0 then
		              //Drawing picture mask
		              gp.ForeColor = MyStyle.WHeaderTransparency
		              gp.FillRect(1, 1, gp.Width-2, MyStyle.WHeaderHeight)
		            End If
		            If MyStyle.WBodyTransparency <> &c0 then
		              gp.ForeColor = MyStyle.WBodyTransparency
		              gp.FillRect(1, MyStyle.WHeaderHeight+1, gp.Width-2, gp.Height-MyStyle.WHeaderHeight-2)
		            End If
		            
		            
		            'If E.MouseOver and E.Editable then
		            'gp.ForeColor = &c0
		            'gp.DrawLine(gp.Width\2-3, gp.Height-5, gp.Width\2+3, gp.Height-5)
		            'gp.DrawLine(gp.Width\2-3, gp.Height-3, gp.Width\2+3, gp.Height-3)
		            'End If
		            
		          End If
		        End If
		        
		        If WholeDay then
		          E.DrawX = X
		          E.DrawY = Y + YY
		          
		          If not HasBuffer then
		            E.Buffer = p
		            E.DrawH = p.Height
		            E.DrawW = p.Width
		          End If
		          If (i mod 7) mod 2 = 1 then
		            //testing
		            DrawEvent(gDay, E, x, yy, DayWidth * w + 1, MyStyle.WEventHeight, True)
		          Else
		            gDay.DrawPicture(E.Buffer, x, yy)
		          End If
		          
		          
		          //Drawing Text
		          If MyStyle.WAutoTextColor then
		            gDay.ForeColor = E.EventColor
		            
		            If E.EventColor.Saturation < 1.0 then
		              gDay.ForeColor = mixColor(E.EventColor, &c0, &h60)
		            End If
		            
		          else
		            gDay.ForeColor = MyStyle.WTextColor
		            If E.EventColor.Hue = E.EventColor.Saturation then
		              If E.EventColor.Value < 0.5 then
		                gDay.ForeColor = InvertColor(gDay.ForeColor)
		              End if
		            elseif E.EventColor.Value < 0.9 then
		              gDay.ForeColor = InvertColor(gDay.ForeColor)
		            End If
		          End If
		          gDay.TextSize = MyStyle.WHeaderTextSize
		          
		          gDay.DrawString(E.Title, x+MyStyle.MTextOffset,  yy + (18-gDay.TextHeight)\2 + gDay.TextAscent, max(1, E.Length/86400+1) * DayWidth -6, True)
		          
		          
		          
		        Else //Not all day
		          
		          If E.StartDate>=DrawDate then
		            E.DrawX = X + XX
		          End If
		          
		          E.DrawY = Y
		          E.DrawW = W
		          
		          If not HasBuffer then
		            E.Buffer = p
		            E.DrawH = p.Height
		          End If
		          
		          y = y-ViewHeight
		          
		          gpc = gc.Clip(Floor(X+XX), Y, W, E.Buffer.Height-1)
		          If (i mod 7) mod 2 = 1 then
		            //testing
		            DrawEvent(gc, E, X+XX, Y, Round(w), max(HourHeight/2, E.Length / 3600 * HourHeight), False)
		          Else
		            gc.DrawPicture(E.Buffer, X+XX, Y)
		          End If
		          
		          If E.MouseOver and E.Editable then
		            If MyStyle.WAutoTextColor then
		              gpc.ForeColor = E.EventColor
		            else
		              gpc.ForeColor = MyStyle.WTextColor
		              If E.EventColor.Hue = E.EventColor.Saturation then
		                If E.EventColor.Value < 0.5 then
		                  gpc.ForeColor = InvertColor(gpc.ForeColor)
		                End if
		              elseif E.EventColor.Value < 0.9 then
		                gpc.ForeColor = InvertColor(gpc.ForeColor)
		              End If
		            End If
		            gpc.DrawLine(gp.Width\2-3, gp.Height-5, gp.Width\2+3, gp.Height-5)
		            gpc.DrawLine(gp.Width\2-3, gp.Height-3, gp.Width\2+3, gp.Height-3)
		          End If
		          
		          
		          //Drawing Text
		          If MyStyle.WAutoTextColor then
		            gpc.ForeColor = E.EventColor
		            
		            If E.EventColor.Saturation < 1.0 then
		              gpc.ForeColor = mixColor(E.EventColor, &c0, &h60)
		            End If
		            
		          else
		            
		            If StyleType = StyleOutlook2013 then
		              gpc.ForeColor = mixColor(E.EventColor, &c0, &hB0)
		            else
		              gpc.ForeColor = MyStyle.WTextColor
		              If E.EventColor.Hue = E.EventColor.Saturation then
		                If E.EventColor.Value < 0.5 then
		                  gpc.ForeColor = InvertColor(gpc.ForeColor)
		                End if
		              elseif E.EventColor.Value < 0.9 then
		                gpc.ForeColor = InvertColor(gpc.ForeColor)
		              End If
		            End If
		          End If
		          gpc.TextSize = MyStyle.WHeaderTextSize
		          gpc.Bold = MyStyle.WHeaderTextBold
		          
		          yy = 11
		          
		          If gpc.TextHeight < E.DrawH then
		            text = MyStyle.WHeaderTextFormat.Replace("%Start", E.StartDate.ShortTime).Replace("%End", E.EndDate.ShortTime)
		            If text.InStr("%Length")>0 then
		              text = text.Replace("%Length", str(Floor(E.Length/3600)) + ":" + Format(E.Length/60 - Floor(E.Length/3600) * 60, "00"))
		            End If
		            If text <> "" then
		              gpc.DrawString(text, 1+MyStyle.MTextOffset, yy, w-6, True)
		              yy = 24
		            End If
		          else
		            gpc.DrawString("...", 1+MyStyle.MTextOffset, E.DrawH - 1)
		            Continue for j
		          End If
		          'End If
		          gpc.TextSize = MyStyle.WBodyTextSize
		          gpc.Bold = MyStyle.WBodyTextBold
		          text = ""
		          text = E.Title
		          if E.Location <> "" then
		            text = text + " – " + E.Location
		          end if
		          if E.Description <> "" then
		            text = text + EndOfLine + E.Description
		          end if
		          
		          
		          gpc.DrawString(text, 1+MyStyle.MTextOffset, yy, w - 8, False)
		          
		        End If
		        
		        
		        'else
		        '
		        ''Idx = 0
		        'Idx = j
		        'Idx = Firstj
		        '
		        'End If
		        
		      Next
		      
		      //Drawing the +xx hidden events
		      If DrawPosDay.Hidden(i) > 0 and DayEventsHeight <> 0 then
		        gDay.TextSize = MyStyle.WHeaderTextSize
		        gDay.ForeColor = &c0000FF
		        yy = DrawPosDay.LockLast((DrawDate.TotalSeconds - FirstDate.TotalSeconds) / 86400, 0)
		        gDay.DrawString("+" + str(DrawPosDay.Hidden(i)), x+MyStyle.MTextOffset, yy*(MyStyle.WEventHeight) + gDay.TextHeight)
		      End If
		      
		      
		      x = x + DayWidth
		      DrawDate.Day = DrawDate.Day + 1
		    Next
		    
		  #else
		    #Pragma Unused gg
		    #Pragma Unused DayWidth
		    
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DrawHTMLMonth() As String
		  Dim Data() As String
		  Dim cla, claArr(), w As String
		  Dim text As String
		  Dim i As Integer
		  Dim DayWidth As Single = Width / 7
		  Dim upToW As Single
		  Dim cellW As Integer
		  
		  Dim css As String
		  css = self.ControlID
		  
		  
		  cla = " class=""" + css + "_m_header"" "
		  Data.Append "<table id=""" + self.ControlID + "_header""" + cla + " cellspacing=""0"" cellpadding=""0"" style=""width:100%; height:48px;-moz-user-select:none;-webkit-user-select:none;"">"
		  Data.Append "<tr>"
		  
		  
		  
		  If UBound(MonthNames)>= DisplayDate.Month then
		    text = MonthNames(DisplayDate.Month) + " " + str(DisplayDate.Year)
		  else
		    text = Str(DisplayDate.Month) + " " + str(DisplayDate.Year)
		  End If
		  cla = " class=""" + css + "_m_title"" "
		  Data.Append "<td colspan=""7""" + cla + ">" + text + "</td></tr>"
		  
		  
		  If MyStyle.MDayNameAlign <> 3 then
		    Data.Append "<tr>"
		    For i = 0 to 6
		      
		      Redim claArr(-1)
		      
		      
		      If (FirstDayOfWeek + i) = 7 then
		        text = TitleCase(DayNames(7))
		      else
		        text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		      End If
		      
		      claArr.Append css + "_m_dayname"
		      
		      //Today
		      If ((i = Today.DayOfWeek-FirstDayOfWeek) or (i = Today.DayOfWeek-FirstDayOfWeek+7)) then
		        claArr.Append css + "_m_dayname_today"
		      End If
		      cla = " class=""" + Join(claArr, " ") + """ "
		      If i = 6 then
		        w = ""
		      else
		        cellW = Round(DayWidth*(i+1)-upToW)
		        
		        w = " width=""" + str(cellW) + "px"" "
		        upToW = upToW + cellW
		      End If
		      Data.Append "<td " + cla + w + ">" + text + "</td>"
		      
		      
		    Next
		    Data.Append "</tr>"
		  End If
		  
		  Data.Append "</table>"
		  
		  Return Join(Data, EndOfLine.UNIX)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DrawHTMLPicker() As String
		  #if TargetWeb
		    Dim Data() As String
		    Dim text, cla, claArr(), css As String
		    Dim DrawDate, Today As Date
		    Dim i, u As Integer
		    Dim onClick As String = " onclick=""Xojo.triggerServerEvent('" + Self.ControlID + "','ClickDate',['%date%']); return false;"" "
		    
		    Dim onClick2 As String = "onclick=""Xojo.triggerServerEvent('" + Self.ControlID + "','ChangeMonth',['%value%']); return false;"" "
		    
		    //Setting FirstDate
		    DrawDate = New Date(FirstDate)
		    Today = New Date
		    
		    css = self.ControlID
		    
		    //Month Title
		    text = MonthNames(DisplayDate.Month) + " " + str(DisplayDate.Year)
		    Data.Append "<table cellspacing=""0"" cellpadding=""0"" style=""width:100%;-moz-user-select:none;-webkit-user-select:none;"">"
		    Data.Append "<tbody>"
		    Data.Append "<tr>"
		    cla = " class=""" + css + "_dp_cell " + css + "_dp_title"" "
		    'If YearSelector then
		    'text = MonthNames(DisplayDate.Month)
		    'Data.Append "<td " + cla + onClick2.Replace("%value%", "-1") + "><</td>"
		    'Data.Append "<td " + cla + " colspan=""2"">" + text + "</td>"
		    'Data.Append "<td " + cla + onClick2.Replace("%value%", "1") + ">></td>"
		    'text = str(DrawDate.Year)
		    'Data.Append "<td " + cla + onClick2.Replace("%value%", "-12") + "><</td>"
		    'Data.Append "<td " + cla + ">" + text + "</td>"
		    'Data.Append "<td " + cla + onClick2.Replace("%value%", "12") + ">></td>"
		    'Else
		    text = MonthNames(DisplayDate.Month) + " " + str(DisplayDate.Year)
		    Data.Append "<td " + cla.Replace(""" ", " " + css + "_dp_change"" ") + onClick2.Replace("%value%", "-1") + ">◀</td>"
		    Data.Append "<td " + cla + " colspan=""5"">" + text + "</td>"
		    Data.Append "<td " + cla.Replace(""" ", " " + css + "_dp_change"" ") + onClick2.Replace("%value%", "1") + ">▶</td>"
		    'End If
		    Data.Append "</tr></tbody></table>"
		    
		    //Drawing DayNames
		    Data.Append "<table cellspacing=""0"" cellpadding=""0"" style=""width:100%;-moz-user-select:none;-webkit-user-select:none;"">"
		    Data.Append "<tbody>"
		    Data.Append "<tr>"
		    
		    cla = " class=""" + css + "_dp_cell " + css + "_dp_dayName"""
		    
		    For i = 0 to 6
		      If (FirstDayOfWeek + i) = 7 then
		        text = TitleCase(DayNames(7))
		      else
		        text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		      End If
		      
		      Data.Append "<th " + cla + " title=""" + text + """>" + text.Left(1) + "</th>"
		    Next
		    
		    Data.Append "</tr>"
		    //End of DayNames
		    
		    //DayNumbers
		    
		    u = WeeksPerMonth*7
		    For i = 1 to u
		      If i mod 7 = 1 then
		        Data.Append "<tr style=""cursor:pointer"">"
		      End If
		      text = str(DrawDate.Day)
		      
		      ReDim claArr(-1)
		      
		      claArr.Append css + "_dp_cell"
		      If DrawDate.Month <> DisplayDate.Month then
		        claArr.Append css + "_dp_offmonth"
		      else
		        claArr.Append css + "_dp_onmonth"
		      End If
		      If SelStart <> Nil and SelEnd <> nil and DrawDate.SQLDate >= SelStart.SQLDate and DrawDate.SQLDate <= SelEnd.SQLDate then
		        claArr.Append css + "_dp_selected"
		      End If
		      If DrawDate.SQLDate = Today.SQLDate Then
		        claArr.Append css + "_dp_Today"
		      End If
		      
		      claArr.Append css + "_dp_dayNbr"
		      
		      If i mod 7 = 1 then
		        claArr.Append css + "_dp_dayLeft"
		      elseif i mod 7 = 0 then
		        claArr.Append css + "_dp_dayRight"
		      End If
		      
		      cla = " class=""" + Join(claArr, " ") + """"
		      'If DrawDate.Month <> DisplayDate.month then
		      'cla = " class=""" + self.ControlID + "_dp-cell " + self.ControlID + "_dp-day "+ self.ControlID + "_dp-offmonth """
		      'else
		      'cla = " class=""" + self.ControlID + "_dp-cell " + self.ControlID + "_dp-day "+ self.ControlID + "_dp-onmonth """
		      'End If
		      
		      Data.Append "<td " + cla + onClick.Replace("%date%", DrawDate.SQLDate) + ">" + text + "</td>"
		      
		      If i mod 7 = 0 then
		        Data.Append "</tr>"
		      End If
		      
		      DrawDate.Day = DrawDate.Day+1
		    Next
		    //End of DayNumbers
		    
		    Data.Append "</tbody>"
		    Data.Append "</table>"
		    
		    Return Join(Data, EndOfLine.UNIX)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DrawHTMLWeek() As String
		  Dim Data() As String
		  Dim cla, claArr(), w As String
		  Dim text As String
		  Dim i As Integer
		  Dim DayWidth As Single = (Width-TimeWidth) / ViewDays
		  Dim upToW As Single
		  Dim cellW As Integer
		  
		  Dim css As String
		  css = self.ControlID
		  
		  Dim DrawDate As Date = New Date
		  DrawDate.Hour = 0
		  DrawDate.Minute = 0
		  DrawDate.Second = 0
		  DrawDate.SQLDate = FirstDate.SQLDate
		  
		  Dim DefaultDateFormat As String = "AbbreviatedDate"
		  'If maxWidth < DayWidth-6 then
		  DefaultDateFormat = "LongDate"
		  'End If
		  
		  
		  cla = " class=""" + css + "_m_header"" "
		  Data.Append "<table id=""" + self.ControlID + "_header""" + cla + " cellspacing=""0"" cellpadding=""0"" style=""width:100%; height:23px;-moz-user-select:none;-webkit-user-select:none;"">"
		  
		  
		  Data.Append "<tr>"
		  
		  //Year
		  text = str(FirstDate.Year)
		  data.Append "<td style=""text-align:center; width:" + str(TimeWidth) + "px"">" + text + "</td>"
		  
		  For i = 0 to ViewDays-1
		    
		    Redim claArr(-1)
		    
		    If WeekHeaderTextFormat = "" then
		      If DefaultDateFormat = "LongDate" then
		        text = DrawDate.LongDate
		      else
		        text = DrawDate.AbbreviatedDate
		      End If
		      text = text.Left(text.Len-5)
		      If text.Right(1) = "," then
		        text = text.Left(len(text) - 1)
		      elseif text.Right(2) = "de" then
		        text = text.Left(len(text) -3)
		      End If
		    else
		      text = ParseDate(DrawDate, WeekHeaderTextFormat, "Abbreviated Date")
		    End If
		    
		    claArr.Append css + "_m_dayname"
		    
		    //Today
		    If MyStyle.WTodayHeader and DrawDate.SQLDate = Today.SQLDate then
		      claArr.Append css + "_w_dayname_today"
		    End If
		    cla = " class=""" + Join(claArr, " ") + """ "
		    If i = 6 then
		      w = ""
		    else
		      cellW = Round(DayWidth*(i+1)-upToW)
		      
		      w = " width=""" + str(cellW) + "px"" "
		      upToW = upToW + cellW
		    End If
		    Data.Append "<td " + cla + w + ">" + text + "</td>"
		    
		    DrawDate.Day = DrawDate.Day + 1
		  Next
		  Data.Append "</tr>"
		  
		  
		  Data.Append "</table>"
		  
		  Return Join(Data, EndOfLine.UNIX)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DrawHTMLYear() As String
		  #if TargetWeb
		    Dim Data() As String
		    'Dim claArr() As String
		    Dim DrawDate As Date
		    Dim i As Integer
		    
		    Dim VAmount As Integer
		    Dim HAmount As Integer
		    //Finding amount of months per line
		    If Width > Height then
		      If Width / Height > 2.45 then
		        HAmount = max(1, Ceil(YearMonthsAmount/6))
		        VAmount = YearMonthsAmount/HAmount
		        
		      else
		        HAmount = max(1, Ceil(YearMonthsAmount/4))
		        VAmount = YearMonthsAmount/HAmount
		        
		      End If
		    else
		      If Width / Height < 0.6 then
		        HAmount = max(1, Ceil(YearMonthsAmount/6))
		        VAmount = YearMonthsAmount/HAmount
		        
		      else
		        HAmount = max(1, Ceil(YearMonthsAmount/4))
		        VAmount = YearMonthsAmount/HAmount
		        
		      End If
		    End If
		    
		    
		    
		    
		    'Dim MWidth, MHeight As Integer
		    'Dim VGap As Single
		    'Dim HGap As Single
		    
		    
		    
		    'Dim dayWidth As Integer
		    'Dim dayHeight As Integer
		    
		    
		    DrawDate = New Date(FirstDate)
		    
		    
		    'dayWidth = Floor((gg.Width-(VAmount-1)*minHGap)/(VAmount*7))
		    'HGap = (gg.Width - 1-dayWidth * VAmount*7)/(VAmount-1)
		    'dayHeight = Floor((gg.Height-(HeaderHeight*HAmount)-minVGap*(HAmount-1))/(6*HAmount))
		    'VGap = (gg.Height-1-HeaderHeight*HAmount-dayHeight*6*HAmount)/(HAmount-1)
		    
		    
		    'MWidth = dayWidth * 7
		    'MHeight = dayHeight * 6
		    
		    
		    
		    
		    
		    //Setting up DayColor for each day in the year
		    If UBound(DisplayEvents) = -1 then
		      SetDayColor()
		    End If
		    
		    Data.Append "<table width=""100%"" height=""100%""><tr><td>"
		    
		    For i = 1 to mYearMonthsAmount
		      
		      
		      //Drawing Day Numbers and background color for events
		      
		      Data.Append DrawHTMLYearSingle(DrawDate)
		      
		      
		      
		      DrawDate.Day = 1
		      DrawDate.Month = i+1
		      If i < mYearMonthsAmount Then
		        If i mod VAmount = 0 then
		          Data.Append "</td></tr>"
		          Data.Append "<tr><td style=""padding:2px"" colspan=""" + str(HAmount) + """></td></tr>"
		          Data.Append "<tr><td>"
		        else
		          Data.Append "</td>"
		          Data.Append "<td style=""padding:2px""></td>"
		          Data.Append "<td>"
		        End If
		      Else
		        Data.Append "</td></tr>"
		      End If
		    Next
		    
		    Data.Append "</table>"
		    
		    Return Join(Data, EndOfLine.UNIX)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DrawHTMLYearSingle(StartDate As Date) As String
		  #if TargetWeb
		    Dim Data() As String
		    Dim text, cla, claArr(), sty, styArr() As String
		    Dim css As String
		    Dim DrawDate As Date
		    Dim i, u As Integer
		    Dim onClick As String = " onclick=""Xojo.triggerServerEvent('" + Self.ControlID + "','ClickDate',['%date%']); return false;"" "
		    
		    'Dim onClick2 As String = "onclick=""Xojo.triggerServerEvent('" + Self.ControlID + "','ChangeMonth',['%value%']); return false;"" "
		    
		    css = self.ControlID
		    
		    //Setting FirstDate
		    DrawDate = New Date(StartDate)
		    DrawDate.Day = 1
		    DrawDate.Hour = 0
		    DrawDate.Minute = 0
		    DrawDate.Second = 0
		    If DrawDate.DayOfWeek - FirstDayOfWeek <= 0 then
		      DrawDate.Day = DrawDate.Day - (DrawDate.DayOfWeek - FirstDayOfWeek) - 7
		    else
		      DrawDate.Day = DrawDate.Day - (DrawDate.DayOfWeek - FirstDayOfWeek)
		    End If
		    
		    //Container
		    cla = " class=""" + css + "_y_table"""
		    Data.Append "<div " + cla + ">"
		    
		    
		    //Month Title
		    cla = " class="""  + css + "_dp_title"""
		    text = MonthNames(StartDate.Month) + " " + str(StartDate.Year)
		    Data.Append "<p " + cla + " style=""margin-top:2px; margin-bottom:2px; width:100%"">" + text + "</p>"
		    
		    
		    //Drawing DayNames
		    Data.Append "<table cellspacing=""0"" cellpadding=""0"" style=""width:100%;-moz-user-select:none;-webkit-user-select:none;"">"
		    Data.Append "<tbody>"
		    Data.Append "<tr>"
		    
		    cla = " class=""" + css + "_dp_cell " + css + "_dp_dayName"""
		    
		    For i = 0 to 6
		      If (FirstDayOfWeek + i) = 7 then
		        text = TitleCase(DayNames(7))
		      else
		        text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		      End If
		      
		      Data.Append "<th " + cla + " title=""" + text + """>" + text.Left(1) + "</th>"
		    Next
		    
		    Data.Append "</tr>"
		    //End of DayNames
		    
		    //DayNumbers
		    
		    u = WeeksPerMonth*4
		    For i = 1 to 42
		      If i mod 7 = 1 then
		        Data.Append "<tr style=""cursor:pointer"">"
		      End If
		      text = str(DrawDate.Day)
		      
		      ReDim claArr(-1)
		      
		      claArr.Append css + "_dp_cell"
		      If DrawDate.Month <> StartDate.Month then
		        claArr.Append css + "_dp_offmonth"
		      else
		        claArr.Append css + "_dp_onmonth"
		      End If
		      If DrawDate.SQLDate = Today.SQLDate Then
		        claArr.Append css + "_dp_Today"
		      End If
		      
		      claArr.Append css + "_dp_dayNbr"
		      
		      If DrawDate.DayOfWeek = 1 or DrawDate.DayOfWeek = 7 then
		        claArr.Append css + "_dp_weekend"
		      else
		        claArr.Append css + "_dp_weekday"
		      End If
		      
		      If i mod 7 = 1 then
		        claArr.Append css + "_dp_dayLeft"
		      elseif i mod 7 = 0 then
		        claArr.Append css + "_dp_dayRight"
		      End If
		      
		      cla = " class=""" + Join(claArr, " ") + """"
		      
		      sty = ""
		      If DrawDate.Month = StartDate.Month then
		        
		        If DayColor(DrawDate.DayOfYear) <> Nil then
		          Redim styArr(-1)
		          styArr.Append "background-color: " + FormatColor(DayColor(DrawDate.DayOfYear).FirstColor)
		          
		          
		          If DayColor(DrawDate.DayOfYear) <> Nil then
		            If DayColor(DrawDate.DayOfYear).FirstColor.Hue = DayColor(DrawDate.DayOfYear).FirstColor.Saturation then
		              If DayColor(DrawDate.DayOfYear).FirstColor.Value < 0.5 then
		                styArr.Append "color: " + FormatColor(InvertColor(MyColors.DayNumberActive))
		              End if
		              
		            elseif DayColor(DrawDate.DayOfYear).FirstColor.Value < 0.9 then
		              styArr.Append "color: " + FormatColor( InvertColor(MyColors.DayNumberActive) )
		            else
		              styArr.Append "color: " + FormatColor( MyColors.DayNumberActive )
		            End If
		          else
		            styArr.Append "color: " + FormatColor( MyColors.DayNumberActive )
		          End If
		          
		          sty = " style=""" + Join(styArr, "; ") + """ "
		          
		        End If
		      End If
		      
		      
		      Data.Append "<td " + cla + sty + onClick.Replace("%date%", DrawDate.SQLDate) + ">" + text + "</td>"
		      
		      If i mod 7 = 0 then
		        Data.Append "</tr>"
		      End If
		      
		      DrawDate.Day = DrawDate.Day+1
		    Next
		    //End of DayNumbers
		    
		    Data.Append "</tbody>"
		    Data.Append "</table>"
		    
		    Return Join(Data, EndOfLine.UNIX)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawMonthPopup(gg As Graphics, X As Integer, Y As Integer, DayWidth As Integer, DayHeight As Integer)
		  Dim w, i, u, xx, yy As Integer
		  Dim h As Integer = 100
		  Dim D As new Date
		  D.Hour = 0
		  d.Minute = 0
		  d.Second = 0
		  d.SQLDate = MonthsPopup.SQLDate
		  Dim text As String = d.LongDate
		  Dim E As CalendarEvent
		  Dim padding As Integer = 10
		  u = UBound(DisplayEvents)
		  
		  
		  gg.TextSize = MyStyle.MNumbersTextSize
		  
		  w = max(gg.StringWidth(text)+4 + 20, DayWidth)+padding*2
		  
		  DayWidth = w-padding*2
		  
		  If X+w > gg.Width then
		    X = gg.Width-w-1
		  End If
		  
		  Dim EventList() As CalendarEvent
		  For i = 0 to u
		    If DisplayEvents(i).StartDate.SQLDate = d.SQLDate or _
		      (DisplayEvents(i).StartDate.TotalSeconds <= d.TotalSeconds and _
		      DisplayEvents(i).EndDate.TotalSeconds >= d.TotalSeconds) then
		      EventList.Append DisplayEvents(i)
		    End If
		  Next
		  
		  u = UBound(EventList)
		  
		  h = max(DayHeight, min(17+MyStyle.MNumberYOffset + (MyStyle.MEventHeight +1) * (u+1), gg.Height-padding*2))+padding*2
		  
		  If Y+h > gg.Height then
		    Y = gg.Height-h-1
		  End If
		  
		  //Drawing Background
		  gg.ForeColor = MyColors.WeekDay
		  gg.FillRect(X, Y, w, h)
		  
		  //Drawing the Frame
		  gg.ForeColor = MyColors.Line
		  gg.DrawRect(X, Y, w, h)
		  
		  //Drawing date
		  gg.ForeColor = MyColors.DayNumberActive
		  gg.DrawString(text, X+2, Y+14+MyStyle.MNumberYOffset)
		  
		  If picCloseMonthPopup <> Nil then
		    gg.DrawPicture(picCloseMonthPopup, X+ w-2-picCloseMonthPopup.Width, Y+ (17-picCloseMonthPopup.Height)\2)
		  End If
		  
		  //Setting the metrics for later use
		  MonthsPopup.Left = X
		  MonthsPopup.Top = Y
		  MonthsPopup.Width = w
		  MonthsPopup.Height = h
		  
		  X = X+padding
		  Y = Y+padding
		  
		  yy = 17 + MyStyle.MNumberYOffset
		  
		  For i = 0 to u
		    E = EventList(i)
		    If E.DayEvent then
		      DrawEvent(gg, E, x+MyStyle.MLeftOffset, y + yy, w-padding*2, MyStyle.MEventHeight, E.DayEvent)
		      
		      //Drawing Text
		      gg.ForeColor = MyStyle.WTextColor
		      If StyleType = StyleOutlook2013 then
		        gg.ForeColor = mixColor(E.EventColor, &c0, &hB0)
		      else
		        If E.EventColor.Hue = E.EventColor.Saturation then
		          If E.EventColor.Value < 0.5 then
		            gg.ForeColor = InvertColor(gg.ForeColor)
		          End if
		        elseif E.EventColor.Value < 0.9 then
		          gg.ForeColor = InvertColor(gg.ForeColor)
		        End If
		      End If
		      gg.TextSize = MyStyle.MEventTextSize
		      gg.Bold = MyStyle.MDayTextBold
		      If E.DayEvent then
		        gg.DrawString(E.Title, x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth-MyStyle.MTextOffset, True)
		      else
		        gg.DrawString(E.StartDate.ShortTime + " " + E.Title, x+MyStyle.MTextOffset, y + yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, max(1, E.Length/86400+1) * DayWidth-MyStyle.MTextOffset*2, True)
		      End If
		      
		    Else //Not a Day event
		      
		      //Drawing Text
		      gg.ForeColor = E.EventColor
		      
		      If MyStyle.MEventFill = FillOutlook2013 then
		        //testing
		        DrawEvent(gg, E, x+MyStyle.MLeftOffset, y + yy, _
		        DayWidth - MyStyle.MLeftOffset * 2+1, MyStyle.MEventHeight, False)
		        
		      End If
		      
		      gg.TextSize = MyStyle.MEventTextSize
		      gg.Bold = MyStyle.MHourBold
		      text = E.StartDate.ShortTime + " "
		      gg.DrawString(text, x+MyStyle.MTextOffset,y+ yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth-MyStyle.MTextOffset*2, True)
		      xx = gg.StringWidth(text)
		      gg.Bold = MyStyle.MTextBold
		      gg.DrawString(E.Title, x+MyStyle.MTextOffset + xx, y+yy + (MyStyle.MEventHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth - MyStyle.MTextOffset - xx, True)
		      
		      
		    End If
		    
		    E.drawX = x
		    E.DrawY = y + yy
		    E.DrawW = DayWidth
		    E.DrawH = MyStyle.MEventHeight
		    E.Visible = True
		    
		    yy = yy + MyStyle.MEventHeight +1
		    
		    If yy > gg.Height then
		      Return
		    End If
		  Next
		  
		  
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawPicker(gg As Graphics)
		  //In DebugBuild we check performance of drawing
		  
		  #if DebugBuild
		    Dim ms As Double = Microseconds
		  #endif
		  
		  
		  If PickerView = PickerMonth then
		    DrawPickerMonth(gg)
		    Return
		  End If
		  
		  
		  Dim i, u As Integer
		  Dim text As String
		  Dim x, xx, y As Single
		  Dim DrawDate As Date
		  Dim DayWidth As Single = gg.Width / 7
		  Dim DayHeight As Single
		  Dim Pos As Integer
		  Dim Today As Date = New Date
		  Dim HeaderHeight As Integer = 39
		  
		  
		  
		  //Setting FirstDate
		  DrawDate = New Date(FirstDate)
		  
		  #if TargetDesktop
		    If mYearPicker <> Nil then
		      mYearPicker.Draw(gg, self)
		      Return
		    End If
		  #endif
		  
		  DayHeight = (gg.Height - HeaderHeight) / WeeksPerMonth
		  
		  If MyStyle.FillGradient then
		    gradient(gg, 0, gg.Height, MyColors.PBackground, MyColors.PBackground2, True)
		  else
		    gg.ForeColor = MyColors.PBackground
		    gg.FillRect(0, 0, gg.Width, gg.Height)
		  End If
		  
		  //Header Background
		  If TransparentBackground then
		    Dim gh As Graphics = gg.Clip(0, 0, gg.Width, HeaderHeight)
		    DrawBackground(gh)
		  else
		    gg.ForeColor = MyColors.Header
		    If StyleType = StyleOutlook2013 then
		      gg.FillRect(0, 0, gg.Width, 22)
		    else
		      gg.FillRect(0, 0, gg.Width, HeaderHeight)
		    End If
		  End If
		  
		  
		  y = 22 \ 2
		  
		  #if TargetDesktop
		    If me isa CalendarView then
		  #elseif TargetWeb
		    If me isa WebCalendarView then
		  #endif
		  gg.ForeColor = MyColors.PArrow
		  
		  
		  If mHiDPI then
		    gg.Pixel(6, y) = gg.ForeColor
		    gg.Pixel(gg.Width-7, y) = gg.ForeColor
		    For i = 7 to 14
		      gg.DrawLine(i, y-i+6, i, y+i-6)
		      gg.DrawLine(gg.Width-i-1, y-i+6, gg.Width-i-1, y+i-6)
		    Next
		  else
		    gg.Pixel(5, y) = gg.ForeColor
		    gg.Pixel(gg.Width-6, y) = gg.ForeColor
		    For i = 6 to 9
		      gg.DrawLine(i, y-i+5, i, y+i-5)
		      gg.DrawLine(gg.Width-i-1, y-i+5, gg.Width-i-1, y+i-5)
		    Next
		  End If
		  
		  else
		    gg.ForeColor = MyColors.PArrow
		    gg.Pixel(2, y) = gg.ForeColor
		    gg.Pixel(gg.Width-3, y) = gg.ForeColor
		    
		    For i = 3 to 6
		      gg.DrawLine(i, y-i+2, i, y+i-2)
		      gg.DrawLine(gg.Width-i-1, y-i+2, gg.Width-i-1, y+i-2)
		    Next
		  End If
		  
		  
		  //Drawing Month
		  gg.ForeColor = MyColors.Title
		  gg.Bold = True
		  text = MonthNames(DisplayDate.Month) + " " + str(DisplayDate.Year)
		  gg.DrawString(text, (gg.Width-gg.StringWidth(text))\2, (22-gg.TextHeight)\2 + gg.TextAscent)
		  
		  //Drawing Day names
		  #if TargetDesktop
		    gg.TextSize = 0
		  #elseif TargetWeb
		    gg.TextSize = 12
		  #endif
		  gg.Bold = MyStyle.PDayNameBold
		  If MyStyle.PDayNamePos = 0 then
		    Pos = 0
		    xx = 1
		  elseif MyStyle.PDayNamePos = 1 then
		    Pos = 1
		    xx = 0
		  else
		    Pos = 2
		    xx = 1
		  End If
		  
		  y = 36
		  
		  Dim NameLength As Integer
		  //Finding how many characters can be displayed
		  For i = 0 to 6
		    If (FirstDayOfWeek + i) = 7 then
		      text = TitleCase(DayNames(7))
		    else
		      text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		    End If
		    If gg.StringWidth(text) < DayWidth-2 then
		      
		    elseif gg.StringWidth(text.Left(3)) < DayWidth-2 then
		      If NameLength = 0 then
		        NameLength = 3
		      End If
		    elseif gg.StringWidth(text.Left(2)) < DayWidth-2 then
		      If NameLength = 0 or NameLength = 3 then
		        NameLength = 2
		      End If
		    elseif gg.StringWidth(text.Left(1)) <=DayWidth-2 then
		      NameLength = 1
		      exit for i
		    End If
		    
		  Next
		  //Drawing day names
		  For i = 0 to 6
		    If (FirstDayOfWeek + i) = 7 then
		      text = TitleCase(DayNames(7))
		    else
		      text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		    End If
		    If NameLength <> 0 then
		      text = text.Left(NameLength)
		    End If
		    
		    gg.ForeColor = MyColors.DayName
		    If Pos = 0 then
		      gg.DrawString(text, DayWidth * i + xx, y)
		    elseif Pos = 1 then
		      gg.DrawString(text, DayWidth * i + max(1, (DayWidth - gg.StringWidth(text)) \ 2), y)
		      
		    else
		      x =DayWidth * i + xx - min(DayWidth-xx, gg.StringWidth(text))
		      gg.DrawString(text, DayWidth * i + xx - min(xx-3, gg.StringWidth(text)), y)
		    End If
		  Next
		  
		  //Drawing day numbers
		  y = 39
		  If MyStyle.PDayNumberPos = 0 then
		    Pos = 0
		    xx = 1
		  elseif MyStyle.PDayNumberPos = 1 then
		    Pos = 1
		    xx = 0
		  else
		    Pos = 2
		    xx = 1
		  End If
		  x = xx
		  u = WeeksPerMonth * 7
		  gg.Bold = MyStyle.PDayNumberbold
		  Dim oktoDraw As Boolean
		  For i = 1 to u
		    
		    //Today Background
		    If DrawDate.SQLDate = Today.SQLDate then
		      gg.ForeColor = MyColors.Today
		      gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		      
		      //Selected
		    ElseIf SelStart <> Nil and SelEnd <> nil and DrawDate.SQLDate >= SelStart.SQLDate and DrawDate.SQLDate <= SelEnd.SQLDate then
		      gg.ForeColor = MyColors.PSelected
		      gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		      
		      //MouseOver
		    ElseIf i = LastDayOver or (DisplayDate <> Nil and DrawDate.SQLDate = DisplayDate.SQLDate) then
		      gg.ForeColor = MyColors.POver
		      If StyleType = StyleOutlook2013 then
		        gg.DrawRoundRect(x+1, y+1, Ceil(DayWidth)-2, Ceil(DayHeight)-2, 2, 2)
		      else
		        gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		      End If
		    End If
		    
		    If StyleType = StyleOutlook2013 then
		      If i = LastDayOver then
		        gg.ForeColor = MyColors.POver
		        gg.DrawRoundRect(x+1, y+1, Ceil(DayWidth)-2, Ceil(DayHeight)-2, 2, 2)
		      End If
		    End If
		    
		    text = str(DrawDate.Day)
		    
		    
		    If DrawDate.Month <> DisplayDate.Month then
		      If gg.ForeColor <> MyColors.PDayNumber then
		        gg.ForeColor = MyColors.PDayNumber
		      End If
		      If MyColors.PDayNumber = MyColors.PBackground then
		        gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		        oktoDraw = False
		      else
		        oktoDraw = true
		      End If
		    else
		      oktoDraw = true
		      If StyleType = StyleOutlook2013 and DrawDate.SQLDate = Today.SQLDate then
		        gg.ForeColor = MyColors.PDayNumberToday
		      elseIf gg.ForeColor <> MyColors.PDayNumberActive then
		        gg.ForeColor = MyColors.PDayNumberActive
		      End If
		    End If
		    If oktoDraw then
		      If Pos = 0 then
		        gg.DrawString(text, x, y+(DayHeight-gg.TextHeight)\2 + gg.TextAscent)
		      elseif Pos = 1 then
		        gg.DrawString(text, x + (DayWidth - gg.StringWidth(text))\2, y+(DayHeight-gg.TextHeight)\2 + gg.TextAscent)
		      else
		        gg.DrawString(text, x - gg.StringWidth(text), y+(DayHeight-gg.TextHeight)\2 + gg.TextAscent)
		      End If
		    End If
		    
		    
		    DrawDate.Day = DrawDate.Day + 1
		    If i mod 7 = 0 then
		      y = y + DayHeight
		      x = xx
		    else
		      x = x + DayWidth
		    End If
		  Next
		  
		  If MyStyle.PLineVertical > LineNone then
		    For i = 1 to 6
		      x = DayWidth * i
		      gg.ForeColor = MyColors.Line
		      If MyStyle.PLineVertical = LineThinSolid then
		        If mHiDPI then
		          gg.FillRect(x, 36, 2, gg.Height)
		        else
		          gg.DrawLine(x, 36, x, gg.Height)
		        End If
		      elseif MyStyle.PLineVertical = LineThinDotted then
		        DrawDottedLine(gg, x, 36, x, gg.Height)
		        
		      elseif MyStyle.PLineVertical = LineThinDouble then
		        If mHiDPI then
		          gg.DrawLine(x-2, 36, x-2, gg.Height)
		        End If
		        gg.DrawLine(x-1, 36, x-1, gg.Height)
		        gg.ForeColor = MyColors.Line2
		        gg.DrawLine(x, 36, x, gg.Height)
		        If mHiDPI then
		          gg.DrawLine(x+1, 36, x+1, gg.Height)
		        End If
		      End If
		    Next
		  End If
		  
		  If Border then
		    gg.ForeColor = MyColors.Border
		    If TransparentBackground then
		      gg.DrawRect(0, HeaderHeight, gg.Width, gg.Height-HeaderHeight)
		      If mHiDPI then
		        gg.DrawRect(1, HeaderHeight+1, gg.Width-2, gg.Height-HeaderHeight-2)
		      End If
		    else
		      gg.DrawRect(0, 0, gg.Width, gg.Height)
		      If mHiDPI then
		        gg.DrawRect(1, 1, gg.Width-2, gg.Height-2)
		      End If
		    End If
		  End If
		  
		  
		  
		  //In DebugBuild we check performance of drawing
		  #if DebugBuild
		    ms = (Microseconds-ms)/1000
		    'DrawInfo = str(ms)
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Private Sub DrawPickerMonth(gg As Graphics)
		  #if TargetDesktop
		    
		    //In DebugBuild we check performance of drawing
		    #if DebugBuild
		      Dim ms As Double = Microseconds
		    #endif
		    
		    Dim i, u As Integer
		    Dim text As String
		    Dim x, xx, y As Single
		    Dim DrawDate As Date
		    Dim DayWidth As Single = gg.Width / 4
		    Dim DayHeight As Single
		    Dim Pos As Integer
		    Dim Today As Date = New Date
		    Dim HeaderHeight As Integer = 39
		    
		    
		    
		    //Setting FirstDate
		    DrawDate = New Date(FirstDate)
		    DrawDate.Month = 1
		    DrawDate.Day = 1
		    
		    If mYearPicker <> Nil then
		      mYearPicker.Draw(gg, self)
		      Return
		    End If
		    
		    DayHeight = (gg.Height - HeaderHeight) / 3
		    
		    If MyStyle.FillGradient then
		      gradient(gg, 0, gg.Height, MyColors.PBackground, MyColors.PBackground2, True)
		    else
		      gg.ForeColor = MyColors.PBackground
		      gg.FillRect(0, 0, gg.Width, gg.Height)
		    End If
		    
		    //Header Background
		    If TransparentBackground then
		      Dim gh As Graphics = gg.Clip(0, 0, gg.Width, HeaderHeight)
		      DrawBackground(gh)
		    else
		      gg.ForeColor = MyColors.Header
		      If StyleType = StyleOutlook2013 then
		        gg.FillRect(0, 0, gg.Width, 22)
		      else
		        gg.FillRect(0, 0, gg.Width, HeaderHeight)
		      End If
		    End If
		    
		    
		    y = 22 \ 2
		    
		    If me isa CalendarView then
		      gg.ForeColor = MyColors.PArrow
		      
		      
		      If mHiDPI then
		        gg.Pixel(6, y) = gg.ForeColor
		        gg.Pixel(gg.Width-7, y) = gg.ForeColor
		        For i = 7 to 14
		          gg.DrawLine(i, y-i+6, i, y+i-6)
		          gg.DrawLine(gg.Width-i-1, y-i+6, gg.Width-i-1, y+i-6)
		        Next
		      else
		        gg.Pixel(5, y) = gg.ForeColor
		        gg.Pixel(gg.Width-6, y) = gg.ForeColor
		        For i = 6 to 9
		          gg.DrawLine(i, y-i+5, i, y+i-5)
		          gg.DrawLine(gg.Width-i-1, y-i+5, gg.Width-i-1, y+i-5)
		        Next
		      End If
		      
		    else
		      gg.ForeColor = MyColors.PArrow
		      gg.Pixel(2, y) = gg.ForeColor
		      gg.Pixel(gg.Width-3, y) = gg.ForeColor
		      
		      For i = 3 to 6
		        gg.DrawLine(i, y-i+2, i, y+i-2)
		        gg.DrawLine(gg.Width-i-1, y-i+2, gg.Width-i-1, y+i-2)
		      Next
		    End If
		    
		    
		    //Drawing Month
		    gg.ForeColor = MyColors.Title
		    gg.Bold = True
		    text = str(DisplayDate.Year)
		    gg.DrawString(text, gg.Width-gg.StringWidth(text)\2, (22-gg.TextHeight)\2 + gg.TextAscent)
		    
		    //Drawing Day names
		    'gg.TextSize = 0
		    'gg.Bold = MyStyle.PDayNameBold
		    'If MyStyle.PDayNamePos = 0 then
		    'Pos = 0
		    'xx = 1
		    'elseif MyStyle.PDayNamePos = 1 then
		    'Pos = 1
		    'xx = 0
		    'else
		    'Pos = 2
		    'xx = 1
		    'End If
		    '
		    'y = 36
		    '
		    'Dim NameLength As Integer
		    '//Finding how many characters can be displayed
		    'For i = 0 to 6
		    'If (FirstDayOfWeek + i) = 7 then
		    'text = TitleCase(DayNames(7))
		    'else
		    'text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		    'End If
		    'If gg.StringWidth(text) < DayWidth-2 then
		    '
		    'elseif gg.StringWidth(text.Left(3)) < DayWidth-2 then
		    'If NameLength = 0 then
		    'NameLength = 3
		    'End If
		    'elseif gg.StringWidth(text.Left(2)) < DayWidth-2 then
		    'If NameLength = 0 or NameLength = 3 then
		    'NameLength = 2
		    'End If
		    'elseif gg.StringWidth(text.Left(1)) <=DayWidth-2 then
		    'NameLength = 1
		    'exit for i
		    'End If
		    '
		    'Next
		    '//Drawing day names
		    'For i = 0 to 6
		    'If (FirstDayOfWeek + i) = 7 then
		    'text = TitleCase(DayNames(7))
		    'else
		    'text = TitleCase(DayNames((FirstDayOfWeek + i) mod 7))
		    'End If
		    'If NameLength <> 0 then
		    'text = text.Left(NameLength)
		    'End If
		    '
		    'gg.ForeColor = MyColors.DayName
		    'If Pos = 0 then
		    'gg.DrawString(text, DayWidth * i + xx, y)
		    'elseif Pos = 1 then
		    'gg.DrawString(text, DayWidth * i + max(1, (DayWidth - gg.StringWidth(text)) \ 2), y)
		    '
		    'else
		    'x =DayWidth * i + xx - min(DayWidth-xx, gg.StringWidth(text))
		    'gg.DrawString(text, DayWidth * i + xx - min(xx-3, gg.StringWidth(text)), y)
		    'End If
		    'Next
		    
		    //Drawing day numbers
		    y = 39
		    If MyStyle.PDayNumberPos = 0 then
		      Pos = 0
		      xx = 1
		    elseif MyStyle.PDayNumberPos = 1 then
		      Pos = 1
		      xx = 0
		    else
		      Pos = 2
		      xx = 1
		    End If
		    x = xx
		    u = 12
		    gg.Bold = MyStyle.PDayNumberbold
		    Dim oktoDraw As Boolean
		    For i = 1 to u
		      
		      //Today Background
		      If DrawDate.Month = Today.Month then
		        gg.ForeColor = MyColors.Today
		        gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		        
		        //Selected
		      ElseIf SelStart <> Nil and SelEnd <> nil and DrawDate.Month >= SelStart.Month and DrawDate.Month <= SelEnd.Month then
		        gg.ForeColor = MyColors.PSelected
		        gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		        
		        //MouseOver
		      ElseIf i = LastDayOver or (DisplayDate <> Nil and DrawDate.Month = DisplayDate.Month) then
		        gg.ForeColor = MyColors.POver
		        If StyleType = StyleOutlook2013 then
		          gg.DrawRoundRect(x+1, y+1, Ceil(DayWidth)-2, Ceil(DayHeight)-2, 2, 2)
		        else
		          gg.FillRect(x, y, Ceil(DayWidth), Ceil(DayHeight))
		        End If
		      End If
		      
		      If StyleType = StyleOutlook2013 then
		        If i = LastDayOver then
		          gg.ForeColor = MyColors.POver
		          gg.DrawRoundRect(x+1, y+1, Ceil(DayWidth)-2, Ceil(DayHeight)-2, 2, 2)
		        End If
		      End If
		      
		      text = MonthNames(DrawDate.Month)
		      
		      
		      If StyleType = StyleOutlook2013 and DrawDate.Month = Today.Month and DrawDate.Year = Today.Year then
		        gg.ForeColor = MyColors.PDayNumberToday
		      elseIf gg.ForeColor <> MyColors.PDayNumberActive then
		        gg.ForeColor = MyColors.PDayNumberActive
		      End If
		      
		      If Pos = 0 then
		        gg.DrawString(text, x, y+(DayHeight-gg.TextHeight)\2 + gg.TextAscent, DayWidth, True)
		      elseif Pos = 1 then
		        gg.DrawString(text, x + (DayWidth - gg.StringWidth(text))\2, y+(DayHeight-gg.TextHeight)\2 + _
		         gg.TextAscent, DayWidth, True)
		      else
		        gg.DrawString(text, x - gg.StringWidth(text), y+(DayHeight-gg.TextHeight)\2 + gg.TextAscent, _
		        DayWidth, True)
		      End If
		      
		      
		      
		      DrawDate.Month = DrawDate.Month + 1
		      If i mod 4 = 0 then
		        y = y + DayHeight
		        x = xx
		      else
		        x = x + DayWidth
		      End If
		    Next
		    
		    If MyStyle.PLineVertical > LineNone then
		      For i = 1 to 3
		        x = DayWidth * i
		        gg.ForeColor = MyColors.Line
		        If MyStyle.PLineVertical = LineThinSolid then
		          
		          gg.DrawLine(x, 36, x, gg.Height)
		          
		        elseif MyStyle.PLineVertical = LineThinDotted then
		          DrawDottedLine(gg, x, 36, x, gg.Height)
		          
		        elseif MyStyle.PLineVertical = LineThinDouble then
		          
		          gg.DrawLine(x-1, 36, x-1, gg.Height)
		          gg.ForeColor = MyColors.Line2
		          gg.DrawLine(x, 36, x, gg.Height)
		          
		        End If
		      Next
		    End If
		    
		    If Border then
		      gg.ForeColor = MyColors.Border
		      If TransparentBackground then
		        gg.DrawRect(0, HeaderHeight, gg.Width, gg.Height-HeaderHeight)
		        
		      else
		        gg.DrawRect(0, 0, gg.Width, gg.Height)
		        
		      End If
		    End If
		    
		    
		    
		    //In DebugBuild we check performance of drawing
		    #if DebugBuild
		      ms = (Microseconds-ms)/1000
		      'DrawInfo = str(ms)
		    #endif
		    
		  #else
		    #Pragma Unused gg
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawScrollBar(gg As Graphics)
		  Dim visibleh As Integer = Height - ViewHeight
		  'ScrollBarHeight = Visibleh / 24 * visibleh
		  
		  
		  
		  ScrollBarHeight = Visibleh / (HourHeight*VisibleHours) * Visibleh
		  
		  Dim p As Picture
		  Dim gp As Graphics
		  Dim Antialiasing As Boolean
		  #if TargetDesktop
		    If TargetWin32 and not app.UseGDIPlus Then
		      p = New Picture(9, ScrollBarHeight, 32)
		      gp = p.Graphics
		      Antialiasing = False
		    Else
		      'p = New Picture(9, ScrollBarHeight)
		      gp = gg.Clip(Width-9, ViewHeight + (Height-ViewHeight-ScrollBarHeight)*ScrollPosition/24, _
		      9, ScrollBarHeight)
		      Antialiasing = True
		    End If
		  #else
		    'p = New Picture(9, ScrollBarHeight)
		    gp = gg.Clip(Width-9, ViewHeight + (Height-ViewHeight-ScrollBarHeight)*ScrollPosition/24, _
		    9, ScrollBarHeight)
		    Antialiasing = True
		  #endif
		  
		  
		  
		  If Antialiasing Then
		    gp.ForeColor = &c4D4D4D22
		    gp.FillRoundRect(0, 0, gp.Width, gp.Height, 8, 8)
		  Else
		    gp.ForeColor = &c4D4D4D
		    gp.FillRect(0, 0, gp.Width, gp.Height)
		    
		    gp = p.Mask.Graphics
		    gp.ForeColor = &cFFFFFF
		    gp.FillRect(0, 0, gp.Width, gp.Height)
		    gp.ForeColor = mixColor(&c4D4D4D, &cFFFFFF, &hBB)
		    gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 4, 4)
		    gp.ForeColor = mixColor(&c4D4D4D, &cFFFFFF, &h88)
		    gp.DrawRoundRect(0, 0, gp.Width, gp.Height, 6, 6)
		    gp.ForeColor = mixColor(&c4D4D4D, &cFFFFFF, &h22)
		    gp.FillRoundRect(1, 1, gp.Width-2, gp.Height-2, 4,4)
		    
		    
		    gg.DrawPicture(p, Width-p.Width, ViewHeight + (Height-ViewHeight-ScrollBarHeight)*ScrollPosition/24)
		    
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawTexture(g As Graphics, Pattern As Picture, Horizontal As Boolean, Vertical As Boolean, Enabled As Boolean = True)
		  
		  If pattern is nil then Return
		  
		  Dim p As Picture = Picture.FromData(Pattern.GetData(Picture.FormatPNG))
		  
		  If not Enabled then
		    Dim m, x, y As Integer
		    Dim c As Color
		    Dim s As RGBSurface = p.RGBSurface
		    
		    
		    For y = 0 to p.Height-1
		      For x = 0 to p.Width-1
		        c = s.Pixel(x, y)
		        m = (c.red*0.2989)+(c.Green*0.5870)+(c.Blue*0.114)
		        s.Pixel(x, y) = RGB(m, m, m)
		      Next
		    Next
		    
		  End If
		  
		  If p.Width >= g.Width and p.Height >= g.Height then
		    g.DrawPicture(p, 0, 0)
		    
		  Else
		    
		    Dim i, j As Integer
		    Dim w, h, sw, sh As Integer
		    
		    w = g.Width
		    h = g.Height
		    sw = p.Width
		    sh = p.Height
		    
		    If Horizontal and Vertical then
		      
		      For j = 0 to h Step sh
		        For i = 0 to w Step sw
		          g.DrawPicture(p, i, j)
		        Next
		      Next
		      
		    Elseif Horizontal then
		      j = (g.Height-p.Height)\2
		      
		      For i = 0 to w Step sw
		        g.DrawPicture(p, i, j)
		      Next
		      
		    Elseif Vertical then
		      
		      i = (g.Width-p.Width)\2
		      For j = 0 to h Step sh
		        g.DrawPicture(p, i, j)
		      Next
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DrawTime(gg As Graphics, DayWidth As Single)
		  Dim y As Integer
		  
		  If HideNightTime and (Today.Hour < DayStartHour or Today.Hour > DayEndHour) then Return
		  
		  If HideNightTime then
		    y = ViewHeight - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours+ (Today.Hour-DayStartHour+1) * HourHeight + Today.Minute * HourHeight / 60
		  else
		    y = ViewHeight - (VisibleHours-(gg.Height-ViewHeight)/HourHeight)*HourHeight*ScrollPosition/VisibleHours+ (Today.Hour) * HourHeight + Today.Minute * HourHeight / 60
		  End If
		  If y < ViewHeight-5 then Return
		  y = y - ViewHeight
		  Dim gc As Graphics = gg.Clip(0, ViewHeight, gg.Width, gg.Height-ViewHeight)
		  
		  
		  If StyleType = StyleOutlook2010 then
		    
		    gc.ForeColor = &cFFD85A
		    gc.DrawLine(0, y-1, TimeWidth-1, y-1)
		    gc.DrawLine(0, y+1, TimeWidth-1, y+1)
		    gc.ForeColor = &cEB8900
		    gc.DrawLine(0, y, TimeWidth-1, y)
		    
		  elseif StyleType = StyleOutlook2013 then
		    gc.ForeColor = &cB1D6F0
		    gc.DrawLine(0, y-1, Width, y-1)
		    gc.DrawLine(0, y+1, Width, y+1)
		    gc.ForeColor = &c2A8DD4
		    gc.DrawLine(0, y, Width, y)
		    
		  else
		    gc.ForeColor = &cFF7F6E
		    
		    If Today.TotalSeconds >= FirstDate.TotalSeconds and Today.TotalSeconds <= LastDate.TotalSeconds then
		      If mHiDPI then
		        gc.ForeColor = ShiftColor(gc.ForeColor, 20)
		        gc.FillRect(TimeWidth + (Today.Day-FirstDate.Day) * DayWidth, y, Ceil(DayWidth)-1, 4)
		        gc.ForeColor = &cFF7F6E
		        gc.FillRect(TimeWidth + (Today.Day-FirstDate.Day) * DayWidth, y+1, Ceil(DayWidth)-1, 2)
		      else
		        gc.FillRect(TimeWidth + (Today.Day-FirstDate.Day) * DayWidth, y, Ceil(DayWidth), 2)
		      End If
		    End If
		    
		    Dim start As Integer
		    If Border then
		      If mHiDPI then
		        start = 2
		      else
		        start = 1
		      End If
		    End If
		    For i as Integer = start to 3+start
		      gc.DrawLine(i, y-((3+start)-i), i, y+((3+start)-i))
		    Next
		    
		    If y >-1 and y < gc.Height then
		      gc.Pixel(3+start, y) = gc.ForeColor
		    End If
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub EraseBuffers()
		  #if False
		    //Erasing all buffers
		    Dim i, u As Integer
		    u = UBound(Events())
		    For i = 0 to u
		      If Events(i).Buffer <> Nil then
		        Events(i).Buffer = Nil
		      End If
		    Next
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function EventForXY(X As Integer, Y As Integer, RemoveMouseOver As Boolean = False) As CalendarEvent
		  If X=-1 or Y=-1 then
		    Return Nil
		  End If
		  
		  If ViewType = TypeYear or ViewType = TypePicker then
		    Return Nil
		  End If
		  
		  Dim i, u As Integer
		  u = UBound(DisplayEvents)
		  Dim E As CalendarEvent
		  Dim Found As Boolean
		  Dim FoundI As Integer = -1
		  
		  If DragEvent > 0 then
		    x =x
		  End If
		  
		  For i = u DownTo 0
		    
		    E = DisplayEvents(i)
		    If RemoveMouseOver and E.MouseOver then
		      E.MouseOver = False
		    End If
		    
		    If not Found then
		      If X>=E.DrawX and X < E.DrawX + E.DrawW and Y >= E.DrawY and Y < E.DrawY + E.DrawH then
		        Found = True
		        FoundI = i
		      End If
		    End If
		  Next
		  
		  If FoundI > -1 then
		    Return DisplayEvents(FoundI)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportAsPicture() As Picture
		  Dim r() As REALbasic.Rect
		  #if TargetWeb
		    Dim p As Picture
		    If ViewType >= TypeWeek then
		      HeaderHeightHTML = 23
		      HourHeight = Ceil(max(minHourHeight, (Height-HeaderHeightHTML-MyStyle.WEventHeight*2-4)/24))
		      
		      p = New Picture(Width, HourHeight*24+MyStyle.WEventHeight*2+4)
		    else
		      
		      HeaderHeightHTML = 48
		      
		      p = New Picture(Width, Height-HeaderHeightHTML)
		      
		    End If
		  #else
		    Dim p As Picture = New Picture(Width, Height, 32)
		  #endif
		  
		  handlePaint(p.Graphics, r())
		  
		  Return p
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportICS() As String
		  //Exports all CalendarEvents in ICS (iCal) format
		  
		  Dim Line() As String
		  Dim i, u As Integer
		  u = UBound(Events)
		  If u = -1 then Return ""
		  Dim Time As String
		  Dim E As CalendarEvent
		  
		  Line.Append "BEGIN:VCALENDAR"
		  Line.Append "VERSION:2.0"
		  Line.Append "PRODID:XOJO CalendarView"
		  
		  For i = 0 to u
		    E = Events(i)
		    
		    Line.Append "BEGIN:VEVENT"
		    
		    If E.Length mod 86400 <> 0 then
		      Time = E.StartDate.SQLDateTime.ReplaceAll("-", "").Replace(" ", "T").ReplaceAll(":", "")
		      If E.StartDate.GMTOffset = 0 then
		        Time = Time + "Z"
		      End If
		    else
		      Time = E.StartDate.SQLDate.ReplaceAll("-", "")
		    End If
		    
		    Line.Append "DTSTART:" + Time
		    
		    //Length
		    If E.Length <> 0 then
		      If E.Length mod 86400 <> 0 then
		        Time = E.EndDate.SQLDateTime.ReplaceAll("-", "").Replace(" ", "T").ReplaceAll(":", "")
		        If E.EndDate.GMTOffset = 0 then
		          Time = Time + "Z"
		        End If
		      else
		        Time = E.EndDate.SQLDate.ReplaceAll("-", "")
		      End If
		      Line.Append "DTEND:" + Time
		    End If
		    
		    //Text information
		    Line.Append "SUMMARY:" + E.Title
		    If E.Location <> "" then
		      Line.Append "LOCATION:" + E.Location
		    End If
		    If E.Description <> "" then
		      Line.Append "DESCRIPTION:" + E.Description
		    End If
		    
		    //Recurrence
		    If E.Recurrence <> Nil then
		      Line.Append "RRULE:" + E.Recurrence.ToICS(E)
		    End If
		    
		    Line.Append "UID:" + E.ID
		    Line.Append "X-RSCV-COLOR:" + FormatColor(E.EventColor)
		    Line.Append "X-RSCV-TAG:" + E.Tag.StringValue
		    Line.Append "END:VEVENT"
		  Next
		  
		  
		  
		  
		  
		  
		  
		  Line.Append "END:VCALENDAR"
		  
		  
		  Return Join(Line, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( deprecated = True )  Function ExportToDB(DB As Database, TableName As String, ID As String = "ID", StartDate As String = "Start", EndDate As String = "End", Title As String = "Title", EventColor As String = "Color", Location As String = "Location", Description As String = "Description", Recurrence As String = "Recurrence") As Boolean
		  //Exports all CalendarEvents to the passed TableName in the passed Database.
		  
		  If DB is Nil then
		    Return False
		  End If
		  If db.Connect = False then
		    Return False
		  End If
		  
		  
		  Dim Rec As DatabaseRecord
		  Dim cEvent As CalendarEvent
		  Dim i As Integer
		  Dim maxID As String
		  Dim RS As RecordSet
		  Dim wSQL As String
		  
		  For i = 0 to UBound(DeletedIDs)
		    DB.SQLExecute("DELETE FROM " + TableName + " WHERE " + ID + "='" + DeletedIDs(i) + "'")
		  Next
		  
		  
		  //Finding the maximum ID
		  RS = DB.SQLSelect("SELECT " + ID + " FROM " + TableName + " ORDER BY " + ID + " DESC LIMIT 0,1")
		  If RS <> Nil then
		    If RS.RecordCount > 0 then
		      maxID = RS.IdxField(1)
		    else
		      maxID = "0"
		    End If
		  else
		    maxID = "0"
		  End If
		  
		  For i = 0 to UBound(Events)
		    cEvent = Events(i)
		    
		    If cEvent.ID <> "" and cEvent.ID.left(4) <> "auto" then
		      wSQL = "SELECT " + StartDate + "," + Title
		      If EndDate <> "" then
		        wSQL = wSQL + "," + EndDate
		      End If
		      If EventColor <> "" then
		        wSQL = wSQL + "," + EventColor
		      End If
		      If Location <> "" then
		        wSQL = wSQL + "," + Location
		      End If
		      If Description <> "" then
		        wSQL = wSQL + "," + Description
		      End If
		      If Recurrence <> "" then
		        wSQL = wSQL + "," + Recurrence
		      End If
		      
		      wSQL = wSQL + " FROM " + TableName + " WHERE " + ID + "=" + cEvent.ID
		      RS = DB.SQLSelect(wSQL)
		    End If
		    If cEvent.ID <> "" and cEvent.ID.left(4) <> "auto" and RS <> Nil and RS.RecordCount > 0 then
		      
		      RS.Edit()
		      
		      RS.Field(StartDate).Value = cEvent.StartDate.SQLDateTime
		      RS.Field(EndDate).Value = cEvent.EndDate.SQLDateTime
		      RS.Field(Title).StringValue = cEvent.Title
		      RS.Field(EventColor).StringValue = FormatColor(cEvent.EventColor)
		      RS.Field(Location).StringValue = cEvent.Location
		      RS.Field(Description).StringValue = cEvent.Description
		      If cEvent.Recurrence <> Nil then
		        RS.Field(Recurrence).StringValue = cEvent.Recurrence.ToICS(cEvent)
		      End If
		      
		      RS.Update
		      
		    else
		      
		      maxID = str(val(maxID) + 1)
		      
		      cEvent.ID = maxID
		      
		      rec = New DatabaseRecord
		      rec.Column(ID) = cEvent.ID
		      rec.Column(StartDate) = cEvent.StartDate.SQLDateTime
		      If EndDate <> "" then
		        rec.Column(EndDate) = cEvent.EndDate.SQLDateTime
		      End If
		      rec.Column(Title) = cEvent.Title
		      rec.Column(EventColor) = FormatColor(cEvent.EventColor)
		      If Location <> "" then
		        rec.Column(Location) = cEvent.Location
		      End If
		      If Description <> "" then
		        rec.Column(Description) = cEvent.Description
		      End If
		      If cEvent.Recurrence <> Nil and Recurrence <> "" then
		        rec.Column(Recurrence) = cEvent.Recurrence.ToICS(cEvent)
		      End If
		      
		      db.InsertRecord TableName, Rec
		      
		    End If
		    
		    If db.Error = False then
		      db.Commit
		      If db.Error then
		        Return False
		      End If
		    else
		      db.Rollback
		      Return False
		    End If
		    
		    
		  Next
		  
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FindScreen() As Integer
		  #if TargetDesktop
		    Dim w As Window = self.TrueWindow
		    
		    For i as Integer = 0 to ScreenCount-1
		      
		      If w.Left >=Screen(i).Left and w.left <= Screen(i).Left + Screen(i).Width then
		        
		        If w.Top >= Screen(i).top and w.top <=Screen(i).Top + Screen(i).Height then
		          
		          Return i
		          
		        End If
		      End If
		    Next
		    
		    Return 0
		    
		    Dim Percent As Integer
		    For i as Integer = 0 to ScreenCount-1
		      
		      If w.left > Screen(i).left + Screen(i).Width then
		        Continue
		      End If
		      
		      If w.top > Screen(i).Top + Screen(i).Height then
		        Continue
		      End If
		      
		      Percent = w.Left + w.Width
		      
		      If w.Left >=Screen(i).Left and w.left <= Screen(i).Left + Screen(i).AvailableWidth then
		        
		        If w.Top >= Screen(i).Left and w.top <=Screen(i).Top + Screen(i).AvailableHeight then
		          
		          Return i
		          
		        End If
		      End If
		    Next
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FocusOn(cEvent As CalendarEvent)
		  //newinversion 1.4.0
		  //Goes to the current date of the passed cEvent.
		  
		  
		  //If Animate is True, 
		  
		  If cEvent is Nil then raise new NilObjectException
		  
		  If me.ViewType = me.TypeOther and ViewDays = 5 and (cEvent.StartDate.DayOfWeek=1 or cEvent.StartDate.DayOfWeek=7) then
		    //For sundays and saturdays we change the amount of days to display or else the event will never be displayed.
		    me.ViewDays = 7
		  End If
		  DisplayDate = cEvent.StartDate
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatColor(c As color) As String
		  If c = &c0 then
		    
		    Return "#000000"
		  End If
		  
		  Dim R, G, B As String
		  
		  
		  R = Hex(c.Red)
		  G = Hex(c.Green)
		  B = Hex(c.Blue)
		  
		  If len(R) = 1 then
		    R = "0" + R
		  End If
		  If len(G) = 1 then
		    G = "0" + G
		  End If
		  If len(B) = 1 then
		    B = "0" + B
		  End If
		  
		  
		  Return "#" + R + G +B
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetEvents() As CalendarEvent()
		  //Retrieves all CalendarEvents from the CalendarView
		  
		  Redim DisplayEvents(-1)
		  Return Events()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetLocaleInfo(type as Integer, mb as MemoryBlock, ByRef retVal as String) As Integer
		  #if TargetWin32
		    
		    Dim LCID As Integer = &H400
		    
		    Soft Declare Function GetLocaleInfoA Lib "kernel32" (Locale As integer, LCType As integer, lpLCData As ptr, cchData As integer) As Integer
		    Soft Declare Function GetLocaleInfoW Lib "kernel32" (Locale As integer, LCType As integer, lpLCData As ptr, cchData As integer) As Integer
		    
		    dim returnValue as Integer
		    dim size as Integer
		    
		    if mb <> nil then size = mb.Size
		    
		    if System.IsFunctionAvailable( "GetLocaleInfoW", "Kernel32" ) then
		      if mb <> nil then
		        returnValue = GetLocaleInfoW( LCID, type, mb, size ) * 2
		        retVal = ReplaceAll( DefineEncoding( mb.StringValue( 0, returnValue ), Encodings.UTF16 ), Chr( 0 ), "" )
		      else
		        returnValue = GetLocaleInfoW( LCID, type, nil, size ) * 2
		      end if
		    else
		      if mb <> nil then
		        returnValue = GetLocaleInfoA( LCID, type, mb, size ) * 2
		        retVal = ReplaceAll( DefineEncoding( mb.StringValue( 0, returnValue ), Encodings.ASCII ), Chr( 0 ), "" )
		      else
		        returnValue = GetLocaleInfoA( LCID, type, nil, size ) * 2
		      end if
		    end if
		    
		    return returnValue
		    
		  #else
		    #Pragma Unused type
		    #Pragma Unused mb
		    #Pragma Unused retVal
		  #endif
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function getTimeTextForWeek(text As String, Hour As Integer, StartHour As Integer, DrawDate As Date) As String
		  
		  Dim HiddenHour As Boolean
		  
		  If HideNightTime then
		    If Hour = StartHour and DayStartHour>0 then
		      HiddenHour = True
		    elseif DayEndHour>0 and Hour = VisibleHours then
		      HiddenHour = True
		    End If
		  End If
		  
		  
		  If MyStyle.WTimeFormat.instr("(a)")>0 then
		    
		    If HiddenHour then
		      Dim mText As String = text
		      text = ParseTime(DrawDate, mtext) + " - "
		      If Hour = StartHour then
		        DrawDate.Hour = DayStartHour
		      elseif Hour = VisibleHours then
		        DrawDate.Hour = 0
		      End If
		      text = text + ParseDate(DrawDate, mText)
		    Else
		      text = ParseTime(DrawDate, text)
		    End If
		    
		  else
		    
		    If ForceAM_PM or DrawDate.ShortTime.InStr("am")>0 or DrawDate.ShortTime.InStr("pm")>0 then
		      If HiddenHour then
		        text = ParseTime(DrawDate, MyStyle.WTimeFormat, "HH ") + " - "
		        If Hour = StartHour then
		          DrawDate.Hour = DayStartHour
		        elseif Hour = VisibleHours then
		          DrawDate.Hour = 0
		        End If
		        text = text + ParseTime(DrawDate, MyStyle.WTimeFormat, "HH ")
		      Else
		        text = ParseTime(DrawDate, MyStyle.WTimeFormat, "HH ")
		      End If
		      
		    else
		      If HiddenHour then
		        text = ParseTime(DrawDate, MyStyle.WTimeFormat, "HH:MM") + " - "
		        If Hour = StartHour then
		          DrawDate.Hour = DayStartHour
		        elseif Hour = VisibleHours then
		          DrawDate.Hour = 0
		        End If
		        text = text + ParseTime(DrawDate, MyStyle.WTimeFormat, "HH:MM")
		      Else
		        text = ParseTime(DrawDate, MyStyle.WTimeFormat, "HH:MM")
		      End If
		    End If
		  End If
		  
		  Return Text
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetWindowColor() As Color
		  #if TargetDesktop
		    #if RBVersion>2009 then
		      If me.TrueWindow.HasBackColor then
		        Return me.TrueWindow.BackColor
		    #else
		      If me.Window.HasBackColor then
		        Return me.Window.BackColor
		    #endif
		    Else
		      #if TargetMacOS
		        //A corriger?
		        Return &cF0F0F0
		        Return &cE8E8E8
		      #else
		        Return FillColor()
		      #endif
		    End If
		    
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub gradient(g as graphics, Start as integer, Length as integer, startColor as color, endColor as color, Vertical As Boolean = True, Alpha As Integer = 0)
		  //modified gradient code, original code: Seth Willits
		  #pragma DisableBackgroundTasks
		  #pragma DisableBoundsChecking
		  
		  dim i as integer, ratio, endratio as Single
		  Dim calcAlpha As Boolean
		  
		  If length = 0 then
		    Return
		  End If
		  
		  #if TargetDesktop
		    If (TargetWin32 and App.UseGDIPlus=False) then
		      Alpha = 0
		    Else
		      If startColor.Alpha <> 0 or endColor.Alpha<>0 then
		        calcAlpha = True
		      End If
		    End If
		  #elseif TargetWeb
		    If startColor.Alpha <> 0 or endColor.Alpha <> 0 then
		      calcAlpha = True
		    End If
		  #endif
		  
		  // Draw the gradient
		  for i = start to start + length
		    
		    // Determine the current line's color
		    ratio = ((length-(i-start))/length)
		    
		    
		    endratio = ((i-start)/length)
		    If calcAlpha then
		      g.ForeColor = RGB(EndColor.Red * endratio + StartColor.Red * ratio, EndColor.Green * endratio +_
		      StartColor.Green * ratio, EndColor.Blue * endratio + StartColor.Blue * ratio, endColor.Alpha * endratio + startColor.Alpha * ratio)
		    else
		      g.ForeColor = RGB(EndColor.Red * endratio + StartColor.Red * ratio, EndColor.Green * endratio +_
		      StartColor.Green * ratio, EndColor.Blue * endratio + StartColor.Blue * ratio, Alpha)
		    End If
		    
		    // Draw the step
		    If Vertical then
		      g.DrawLine 0, i, g.Width, i
		      
		    Else
		      g.DrawLine i, 0, i, g.Height
		    End If
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub gradient2(g as graphics, X As Integer, Y As Integer, Width As Integer, Height As Integer, startColor as color, endColor as color, Vertical As Boolean = True, Alpha As Integer = 0, Special As Integer = 0)
		  //modified gradient code, original code: Seth Willits
		  #pragma DisableBackgroundTasks
		  #pragma DisableBoundsChecking
		  #Pragma Unused Special
		  
		  //Special:
		  //Value 1 the gradient makes a triangle at the left
		  //Value 2 the gradient makes a triangle at the right
		  //Value 3 triangle on both sides
		  
		  Dim gg As Graphics = g.Clip(X, Y, Width, Height)
		  
		  dim i as integer, ratio, endratio as Single
		  Dim calcAlpha As Boolean
		  Dim Start, Length As Integer
		  
		  Start = 0
		  If Vertical then
		    Length = gg.Height-1
		  Else
		    Length = gg.Width-1
		  End If
		  
		  If length = 0 then
		    Return
		  End If
		  
		  #if TargetDesktop
		    If (TargetWin32 and App.UseGDIPlus=False) then
		      Alpha = 0
		    Else
		      If startColor.Alpha <> 0 or endColor.Alpha<>0 then
		        calcAlpha = True
		      End If
		    End If
		  #elseif TargetWeb
		    If startColor.Alpha <> 0 or endColor.Alpha <> 0 then
		      calcAlpha = True
		    End If
		  #endif
		  
		  // Draw the gradient
		  for i = start to start + length
		    
		    // Determine the current line's color
		    ratio = ((length-(i-start))/length)
		    
		    
		    endratio = ((i-start)/length)
		    If calcAlpha then
		      gg.ForeColor = RGB(EndColor.Red * endratio + StartColor.Red * ratio, EndColor.Green * endratio +_
		      StartColor.Green * ratio, EndColor.Blue * endratio + StartColor.Blue * ratio, endColor.Alpha * endratio + startColor.Alpha * ratio)
		    else
		      gg.ForeColor = RGB(EndColor.Red * endratio + StartColor.Red * ratio, EndColor.Green * endratio +_
		      StartColor.Green * ratio, EndColor.Blue * endratio + StartColor.Blue * ratio, Alpha)
		    End If
		    
		    // Draw the step
		    If Vertical then
		      gg.DrawLine 0, i, g.Width, i
		      
		    Else
		      gg.DrawLine i, 0, i, g.Height
		    End If
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub HandleDragEvent(X As Integer, Y As Integer)
		  Dim tmpDate As Date = DateForXY(X, Y)
		  
		  If LastMouseOver is Nil then Return
		  
		  If tmpDate <> Nil then
		    
		    If DragEvent = DragResize then
		      tmpDate.SQLDate = LastMouseOver.StartDate.SQLDate
		      
		      If LastMouseOver.StartSeconds <= tmpDate.TotalSeconds  then
		        
		        If LastMouseOver.StartDate.Hour = tmpDate.Hour and LastMouseOver.StartDate.Minute = tmpDate.Minute then
		          LastMouseOver.EndDate.Hour = LastMouseOver.StartDate.Hour
		          LastMouseOver.EndDate.Minute = LastMouseOver.StartDate.Minute + 15
		        else
		          LastMouseOver.EndDate.Hour = tmpDate.Hour
		          LastMouseOver.EndDate.Minute = tmpDate.Minute
		        End If
		        DragEvent(LastMouseOver)
		        Redisplay()
		        
		      End If
		      
		    elseif DragEvent = DragMove then
		      
		      Dim lastStart As Double = LastMouseOver.StartSeconds
		      Dim Length As Double = LastMouseOver.Length
		      If DayEventClicked then
		        tmpDate.Hour = 0
		        tmpDate.Minute = 0
		        tmpDate.Second = 0
		        LastMouseOver.StartDate = New Date(tmpDate)
		        LastMouseOver.SetLength(Length)
		      else
		        LastMouseOver.StartDate = New Date(tmpDate)
		        LastMouseOver.StartDate.TotalSeconds = Max(tmpDate.TotalSeconds - tmpDate.Hour * 3600 - tmpDate.Minute * 60, tmpDate.TotalSeconds - DragOffset)
		        LastMouseOver.SetLength(Length)
		      End If
		      
		      If lastStart <> LastMouseOver.StartSeconds then
		        DragEvent(LastMouseOver)
		        Redisplay
		      End If
		      
		    End If
		  End if
		  '
		  'While Y > Height-10
		  'AutoScroll(0, 1)
		  'Wend
		  ''If Y > Height-10 then
		  ''AutoScroll(0, 1)
		  ''End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleLoader(caller As Timer)
		  #Pragma Unused caller
		  #if TargetWeb
		    If LoaderVisible then
		      ExecuteJavaScript(" Xojo.get('" + me.ControlID + "_loader').style.display = 'inherit'; ")
		    Else
		      ExecuteJavaScript("setTimeout(function() { Xojo.get('" + me.ControlID + "_loader').style.display = 'none'; }, 1000);")
		    End If
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function handleMouseDown(X As Integer, Y As Integer) As Boolean
		  #if TargetDesktop
		    If me.AcceptFocus then
		      me.SetFocus
		    End If
		    
		    DragBack = False
		    DragEvent = 0
		    
		    
		    If IsContextualClick then
		      Return False
		    End If
		    
		    If ViewType > TypeMonth and X > Width-ScrollBarWidth-1 then
		      MovingScrollBar = True
		      lastX = X
		      lastY = Y
		      #if TargetDesktop
		        Return True
		      #endif
		      
		    Else
		      MovingScrollBar = False
		    End If
		    
		  #Endif
		  
		  
		  
		  'If not DragEvents and not CreateWithDrag then Return False
		  
		  //Type Picker
		  If ViewType = TypePicker then
		    
		    //Nothing
		    #if TargetDesktop
		      Return True
		    #Else
		      Return True
		    #endif
		    
		    
		    //Type Month
		  ElseIf ViewType = TypeMonth then
		    
		    If MonthsPopup.Visible then
		      Dim r As New REALbasic.Rect(MonthsPopup.Left, MonthsPopup.Top, MonthsPopup.Width, MonthsPopup.Height)
		      If r.Contains(New REALbasic.Point(X, Y)) Then
		        
		        If picCloseMonthPopup <> Nil then
		          If X>= MonthsPopup.left+MonthsPopup.Width-picCloseMonthPopup.Width-5 and Y<MonthsPopup.Top+17+5 then
		            MonthsPopup.visible = False
		            Redisplay()
		            Return False
		          End If
		        End If
		        
		        
		      End If
		    End If
		    
		    LastMouseOver = EventForXY(X, Y)
		    
		    If LastMouseOver is Nil then
		      'If not CreateWithDrag then Return False
		      
		      If MonthsPopup.Visible then
		        MonthsPopup.Visible = False
		        Redisplay()
		        Return False
		      End If
		      
		      If CreateWithDrag then
		        SelStart = DateForXY(X, Y)
		      End If
		      
		    else
		      
		      #if TargetDesktop
		        If LastMouseOver.Visible = False then
		          Return True
		          
		        End If
		        If not DragEvents then Return False
		        'If LastMouseOver.Visible = False then Return False
		        
		        If LastMouseOver.Editable then
		          
		          DragEvent = DragMove
		          MouseCursor = System.Cursors.ArrowAllDirections
		          
		        End If
		        lastX = X
		        lastY = Y
		        Return True
		      #endif
		      
		    End If
		    
		    
		    //Type Week
		  Elseif ViewType > TypeMonth then
		    
		    If X < TimeWidth And Y > ViewHeight then
		      Return True
		    End If
		    
		    #if TargetWeb
		      
		      LastMouseOver = EventForXY(X, Y)
		      
		      If LastMouseOver is Nil then
		        If not CreateWithDrag then Return True
		        
		        DayEventClicked = (Y < ViewHeight)
		        SelStart = DateForXY(X, Y)
		        If not DayEventClicked then
		          SelEnd = New Date(SelStart)
		          SelEnd.Hour = SelEnd.Hour + 1
		        End If
		      else
		        
		      end if
		    #Elseif TargetDesktop
		      
		      If Y > me.ViewHeight-3 and Y < me.ViewHeight+2 and not LockDayEventsHeight then
		        me.MouseCursor = System.Cursors.ArrowNorthSouth
		        DragViewHeight = True
		        
		        
		      elseif LastMouseOver is Nil then
		        If not CreateWithDrag then Return False
		        
		        DayEventClicked = (Y < ViewHeight )
		        SelStart = DateForXY(X, Y)
		        
		      else
		        If not DragEvents then Return False
		        
		        DayEventClicked = (Y < ViewHeight )
		        
		        If LastMouseOver.Editable then
		          If Y>ViewHeight and Y >LastMouseOver.DrawY+LastMouseOver.DrawH - 6 then
		            DragEvent = DragResize
		            
		          else
		            DragEvent = DragMove
		            DragOffset = DateForXY(X, Y).TotalSeconds - LastMouseOver.StartSeconds
		            MouseCursor = System.Cursors.ArrowAllDirections
		            If not DayEventClicked then
		              LastMouseOver.MouseOver = True
		            End If
		          End If
		        else
		          DragEvent = DragView
		        End If
		        
		        LastMouseOver.FrontMost = True
		        
		      End If
		    #endif
		    
		  End If
		  
		  lastX = X
		  lastY = Y
		  
		  #if TargetWeb
		    lastMouseDown = Ticks
		    If SelStart <> Nil then
		      If SelEnd is Nil then
		        SelEnd = New Date(SelStart)
		      End If
		      Redisplay()
		      
		      
		    End If
		    
		    Return True
		    
		  #Elseif TargetDesktop
		    Redisplay()
		    
		    If DragViewHeight or SelStart <> Nil or DragEvent>0 then
		      Return True
		    End If
		    
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub handleMouseUp(X As Integer, Y As Integer)
		  #pragma Unused X
		  #pragma Unused Y
		  
		  DragViewHeight = False
		  
		  #if TargetDesktop
		    If MouseCursor <> System.Cursors.StandardPointer then
		      MouseCursor = System.Cursors.StandardPointer
		    End If
		    
		    
		    If DragEvent > 0 then
		      DragEvent(LastMouseOver)
		      DragEvent = 0
		      If LastMouseOver.DayEvent = False then
		        LastMouseOver.MouseOver = True
		      End If
		      LastMouseOver.FrontMost = False
		      LastMouseOver.Buffer = Nil
		      EventsSorted = False
		      EraseBuffers()
		      Redisplay()
		      Return
		    End If
		    
		  #elseif TargetWeb
		    If SelStart is Nil then
		      
		      Dim E As CalendarEvent = EventForXY(X, Y, True)
		      Dim Idx As Integer
		      If E <> Nil and E.Visible and E.Editable then
		        E.Buffer = Nil
		        
		        Idx = Events.IndexOf(E)
		        Dim tmpEvent As CalendarEvent
		        tmpEvent = EditEvent(E)
		        If tmpEvent <> Nil then
		          If tmpEvent.RecurrenceParent <> Nil then
		            Dim ParentEvent As CalendarEvent = CalendarEvent(tmpEvent.RecurrenceParent.Value)
		            idx = Events.IndexOf(ParentEvent)
		            
		            If not EditOrDeleteRecurrentEvent(ParentEvent) then
		              Return
		            End If
		            
		            Dim length As Integer = tmpEvent.Length
		            
		            tmpEvent.setDate(ParentEvent.StartDate)
		            tmpEvent.SetLength(length)
		            tmpEvent.RecurrenceParent = Nil
		            
		            If Idx > -1 Then
		              Redim DisplayEvents(-1)
		            End If
		            
		          End If
		          
		          If Idx > -1 Then
		            Events.Remove(Idx)
		            Events.Insert(Idx, tmpEvent)
		            
		            #if TargetDesktop
		              FullRefresh = True
		              Refresh(False)
		            #elseif TargetWeb
		              Redisplay()
		            #endif
		          End If
		        End If
		        
		      End If
		      Return
		    End If
		  #endif
		  
		  //Type Picker
		  If ViewType = TypePicker then
		    If X < 15 and Y<36 then
		      DisplayDate.Day = 1
		      DisplayDate.Month = DisplayDate.Month -1
		      mFirstDate = Nil
		      
		      ViewChanged()
		    elseif X > Width-15 and Y<36 then
		      DisplayDate.Day = 1
		      DisplayDate.Month = DisplayDate.Month +1
		      mFirstDate = Nil
		      
		      ViewChanged()
		      
		    Elseif Y < 36 then
		      Return
		      
		      'If PickerView < PickerDecade then
		      'PickerView = PickerView + 1
		      'End If
		      'mYearPicker = New CalendarYearPicker
		      
		    else
		      Dim D As Date = DateForXY(X, Y)
		      
		      If PickerView = PickerDay then
		        DisplayDate = New Date(D)
		      Elseif PickerView = PickerMonth then
		        DisplayDate.Month = D.Month
		        
		      End If
		      
		      If PickerView > 0 then
		        PickerView = PickerView-1
		      End If
		      
		      DateSelected(D)
		      
		      
		    End If
		    
		    Redisplay()
		    
		    Return
		    
		  Elseif ViewType = TypeMonth and LastMouseOver <> Nil and LastMouseOver.Visible = False then
		    //User clicked the +# event
		    Dim D As Date = DateForXY(X, Y)
		    If RaiseEvent ShowMoreEvents(D) then
		      Return
		    Else
		      MonthsPopup.Visible = True
		      MonthsPopup.SQLDate = D.SQLDate
		      
		      Redisplay()
		    End If
		    
		  End If
		  
		  If DropObject then
		    DropObject = False
		    Return
		  End If
		  If SelStart is Nil and DragEvent = 0 and ViewType < TypeWeek then
		    Return
		  End If
		  
		  If LastMouseOver <> Nil then
		    RaiseEvent EventClicked(lastMouseOver)
		  End If
		  
		  If ViewType = TypeMonth then
		    
		    
		    SelStart.Hour = 0
		    SelStart.Minute = 0
		    SelStart.Second = 0
		    
		    #If TargetWeb
		      //Wasn't created in MouseDrag
		      SelEnd = DateForXY(X, Y)
		    #endif
		    
		    Freeze = True
		    DisplayDate = SelStart
		    Freeze = False
		    
		    
		    
		    If SelEnd <> Nil then
		      SelEnd.Hour = 0
		      SelEnd.Minute = 0
		      SelEnd.Second = 0
		      
		      
		      #if TargetWeb
		        If Ticks-lastMouseDown > 30 or SelEnd <> Nil then
		          NewEvent(SelStart, SelEnd)
		        End If
		      #else
		        NewEvent(SelStart, SelEnd)
		      #endif
		      
		      'EraseBuffers()
		      SelStart = Nil
		      SelEnd = Nil
		      #if TargetDesktop
		        FullRefresh = True
		        Refresh(False)
		      #elseif TargetWeb
		        Redisplay()
		      #endif
		    else
		      SelStart = Nil
		      SelEnd = Nil
		    End If
		    
		    
		    
		  elseif ViewType > TypeMonth and not MovingScrollBar then
		    
		    If X < TimeWidth And Y > ViewHeight then
		      TimeGutterClick(DateForXY(X, Y, True))
		    End If
		    
		    If LastMouseOver <> Nil then
		      LastMouseOver.FrontMost = False
		      LastMouseOver.Buffer = Nil
		      Redisplay
		    End If
		    
		    #If TargetWeb
		      //Wasn't created in MouseDrag
		      Dim tmpDate As Date = DateForXY(X, Y)
		      If tmpDate.TotalSeconds < SelStart.TotalSeconds then
		        SelEnd = new Date(SelStart)
		        SelStart = tmpDate
		      else
		        SelEnd = DateForXY(X, Y)
		      End If
		    #endif
		    
		    If SelEnd <> Nil then
		      
		      #if TargetWeb
		        If SelStart.TotalSeconds = SelEnd.TotalSeconds Then
		          SelEnd.TotalSeconds = SelEnd.TotalSeconds + 3600
		        End If
		        Redisplay()
		      #endif
		      
		      
		      
		      
		      //Preventing Length = 0 events
		      If SelStart.TotalSeconds <> SelEnd.TotalSeconds or DayEventClicked then
		        NewEvent(SelStart, SelEnd)
		      End If
		      
		      EraseBuffers()
		      
		      #if TargetDesktop
		        SelStart = Nil
		        SelEnd = Nil
		        FullRefresh = True
		        Refresh(False)
		      #elseif TargetWeb
		        Redisplay()
		      #endif
		    Else
		      SelStart = Nil
		      SelEnd = Nil
		      
		    End If
		    
		    
		    
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub handlePaint(g As Graphics, areas() As REALbasic.Rect)
		  'Dim mp As new MethodProfiler(CurrentMethodName)
		  
		  //If control not initialized we return
		  If g is Nil then
		    Return
		  End If
		  
		  If Freeze or Width <= 5 or Height <= 5 or Today is Nil then
		    //Drawing Buffer to the display
		    g.DrawPicture(Buffer, 0, 0)
		    Return
		  End If
		  
		  //In DebugBuild we check performance of drawing
		  #if DebugBuild
		    Dim ms As Double = Microseconds
		  #endif
		  
		  
		  
		  #if TargetCocoa or TargetWeb then
		    FullRefresh = True
		  #endif
		  
		  If areas.Ubound>-1 then
		    g =g 
		  End If
		  
		  
		  //We check if we need to create a new buffer
		  If Buffer is Nil or Width * Height <> lastSize or FullRefresh  or lastToday.TotalSeconds <> Today.TotalSeconds  then
		    
		    Dim gg As Graphics
		    
		    #if TargetDesktop
		      #if TargetCocoa
		        gg = g
		      #elseif TargetWin32
		        Buffer = New Picture(Width, Height, 32)
		        
		        If Buffer is Nil then Return
		        gg = Buffer.Graphics
		        
		      #endif
		    #elseif TargetWeb
		      If TextFont = "" then TextFont = "System"
		      
		      gg = g
		      
		    #endif
		    
		    If Width*Height <> lastSize then
		      EraseBuffers
		      lastSize = gg.Width * gg.Height
		    End If
		    
		    Call HiDPI //Initialize the HiDPI property for the rest of the drawing.
		    
		    lastToday = New Date(Today)
		    
		    
		    
		    If ViewType = TypePicker then
		      
		      If mLastDate is Nil then
		        Call LastDate
		      End If
		      
		      DrawPicker(gg)
		      
		      //Displaying entire year
		    ElseIf ViewType = TypeYear then
		      
		      HeaderHeight = 22
		      
		      DrawBackgroundYear(gg)
		      
		      //Displaying entire Month
		    ElseIf ViewType = TypeMonth then
		      
		      If mLastDate is Nil then
		        Call LastDate
		      End If
		      
		      #if TargetDesktop
		        HeaderHeight = 48
		      #elseif TargetWeb
		        HeaderHeight = 0
		        HeaderHeightHTML = 48
		      #endif
		      
		      
		      Dim DayWidth As Single = g.Width / 7
		      Dim DayHeight As Single = (g.Height - HeaderHeight) / WeeksPerMonth
		      
		      
		      //Drawing Background
		      DrawBackgroundMonth(gg, WeeksPerMonth, DayWidth, DayHeight, True)
		      
		      //Drawing Events
		      DrawEventsMonth(gg, WeeksPerMonth, DayWidth, DayHeight)
		      
		      
		      
		    elseif ViewType >= TypeWeek then
		      
		      
		      Dim DayWidth As Single = (g.Width - TimeWidth) / ViewDays
		      #if TargetWeb
		        HeaderHeight = 0
		        HeaderHeightHTML = 23
		        HourHeight = Ceil(max(minHourHeight, (Height-HeaderHeightHTML-MyStyle.WEventHeight*2-4)/24))
		      #else
		        HeaderHeight = 23
		        HourHeight = max(minHourHeight, Ceil((g.Height-(HeaderHeight + MyStyle.WEventHeight))/VisibleHours))
		      #endif
		      
		      
		      //Drawing Background
		      DrawBackgroundWeek(gg, DayWidth)
		      
		      //Drawing Events
		      DrawEventsWeek(gg, DayWidth)
		      
		      //Draw Time
		      DrawTime(gg, DayWidth)
		      
		      //Drawing Scrollbar
		      If ShowScrollBar then
		        DrawScrollBar(gg)
		      End If
		      
		    End If
		    
		    'MethodProfiler.LogMsg("FullRefresh=False")
		    FullRefresh = False
		  End If
		  
		  #if not TargetMacOS
		    //Drawing Buffer to the display
		    If not Animate or AnimationInProgress=0 then
		      'MethodProfiler.LogMsg("Drawing Buffer")
		      g.DrawPicture(Buffer, 0, 0)
		      
		    else
		      
		      Dim frameRate As Integer = 60
		      Dim AnimationTime As Integer = 800
		      Dim Times() As Double
		      Dim Pos() As Integer
		      Dim i, MaxFrame As Integer
		      MaxFrame = frameRate / (1000 / AnimationTime)
		      Redim Times(MaxFrame)
		      Redim Pos(MaxFrame)
		      Dim currentTime As Double
		      Dim TimePerFrame As Double = 1000 / frameRate
		      
		      For i = 0 to MaxFrame
		        Times(i) = TimePerFrame * (i+1)
		        If AnimationInProgress >0 then
		          Pos(i) = Width - Width * i/MaxFrame
		        else
		          Pos(i) = Width*i/MaxFrame
		        End If
		      Next
		      
		      Dim startTime As Double = Microseconds/1000
		      
		      For i = 0 to MaxFrame
		        currentTime = Microseconds / 1000
		        
		        If i<MaxFrame and i>0 and currentTime - startTime > Times(i) then
		          Continue for i
		        End If
		        While i>0 and currentTime-startTime <  Times(i-1)
		          App.DoEvents (max(1, Times(i-1) - (currentTime-startTime)-1))
		          currentTime = Microseconds / 1000
		        Wend
		        
		        If AnimationInProgress>0 then
		          g.DrawPicture(oldBuffer, 0, 0, Pos(i), Height, Width-Pos(i))
		          g.DrawPicture(Buffer, Pos(i), 0)
		        else
		          
		          g.DrawPicture(oldBuffer, Pos(i), 0)
		          g.DrawPicture(Buffer, 0, 0, Pos(i), Height, Width-Pos(i))
		        End If
		      Next
		      
		      AnimationInProgress = 0
		      g.DrawPicture(Buffer, 0, 0)
		      oldBuffer = Nil
		    End If
		  #endif
		  
		  #if not DebugBuild and not kOpenSource
		    If not Registered then
		      g.ForeColor = &cFF0000
		      g.Bold = True
		      g.TextSize = 16
		      g.DrawString("Demo Version", (g.Width-g.StringWidth("Demo Version"))\2, g.Height\2)
		    End If
		  #endif
		  
		  #if TargetWeb
		    g.ForeColor = &cFF0000
		    g.TextSize = 12
		    g.TextFont = "System"
		    g.Bold = True
		    'g.DrawString("Beta", g.Width-60, g.Height-10)
		  #endif
		  
		  
		  //In DebugBuild we check performance of drawing
		  #if DebugBuild
		    ms = (Microseconds-ms)/1000
		    g.ForeColor = &c0
		    g.TextSize = 12
		    g.Bold = False
		    'g.DrawString(str(ms), 0, 10)
		    'g.ForeColor = &cFF0000
		    'g.DrawString(str(ScrollPosition), 10, 20)
		    'g.DrawString(DrawInfo, 0, 25)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HiDPI() As Integer
		  #If TargetCocoa Then
		    Try
		      Soft Declare Function BackingScaleFactor Lib "AppKit" Selector "backingScaleFactor" (target As WindowPtr) As Double
		      Return BackingScaleFactor(Self.Window)
		    Catch e As ObjCException
		      Return 1
		    End Try
		    
		  #Elseif TargetWin32
		    Declare Function GetDC Lib "user32" (hWnd As Ptr) As Ptr
		    Declare Function GetDeviceCaps Lib "gdi32" _
		    (hdc As Ptr, nIndex As Integer) As Integer
		    Declare Sub ReleaseDC Lib "user32" (hWnd As Ptr, hdc As Ptr)
		    
		    Const LOGPIXELSX = 88
		    Const LOGPIXELSY = 90
		    
		    Dim hdc As Ptr = GetDC(Nil)
		    Dim dpiX As Integer = GetDeviceCaps(hdc, LOGPIXELSX)
		    Dim dpiY As Integer = GetDeviceCaps(hdc, LOGPIXELSY)
		    ReleaseDC(Nil, hdc)
		    
		    Dim scaleFactorX As Double = dpiX / 96
		    Dim scaleFactorY As Double = dpiY / 96
		    Return max(scaleFactorX, scaleFactorY)
		    
		  #Else
		    Return 1
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ImportFromDB(RS As RecordSet, ID As String = "ID", StartDate As String = "Start", EndDate As String = "End", Title As String = "Title", EventColor As String = "Color", Location As String = "Location", Description As String = "Description", Recurrence As String = "Recurrence", Editable As Boolean = True, AllDay As Boolean = False) As Boolean
		  //Imports CalendarEvents from a Database.
		  //Returns True if import is successful.
		  //
		  //If you set the AllDay parameter to True, all events will be a Day event.
		  
		  If RS is Nil then Return False
		  If RS.RecordCount = 0 then Return False
		  
		  Dim cEvent As CalendarEvent
		  
		  While not RS.EOF
		    cEvent = New CalendarEvent
		    
		    cEvent.StartDate = New Date
		    cEvent.StartDate.SQLDateTime = RS.Field(StartDate).StringValue
		    
		    cEvent.EndDate = New Date(cEvent.StartDate)
		    
		    If EndDate <> "" then
		      If RS.Field(StartDate).StringValue = RS.Field(EndDate).StringValue then
		        
		      elseif RS.Field(EndDate).StringValue <> "" then
		        cEvent.EndDate.SQLDateTime = RS.Field(EndDate).StringValue
		      End If
		    End If
		    
		    If AllDay then
		      cEvent.StartDate.Hour = 0
		      cEvent.StartDate.Minute = 0
		      cEvent.StartDate.Second = 0
		      cEvent.EndDate = New Date(cEvent.StartDate)
		    End If
		    
		    cEvent.ID = RS.Field(ID).StringValue
		    cEvent.Title = RS.Field(Title).StringValue
		    If EventColor <> "" then
		      cEvent.EventColor = String2Color(RS.Field(EventColor).StringValue)
		    End If
		    If Location <> "" then
		      cEvent.Location = RS.Field(Location).StringValue
		    End If
		    If Description <> "" then
		      cEvent.Description = RS.Field(Description).StringValue
		    End If
		    If Recurrence <> "" then
		      If RS.Field(Recurrence).StringValue <> "" then
		        cEvent.Recurrence = New CalendarRecurrence(rs.Field(Recurrence).StringValue)
		      End If
		    End If
		    
		    cEvent.Editable = Editable
		    
		    
		    Events.Append cEvent
		    
		    RS.MoveNext()
		  Wend
		  
		  SelStart = Nil
		  SelEnd = Nil
		  
		  mFirstDate = Nil
		  mLastDate = Nil
		  
		  Redim DisplayEvents(-1)
		  
		  Redisplay()
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ImportICS(f As FolderItem, DefaultColor As Color = &c4986E7, Editable As Boolean = False)
		  //Imports CalendarEvents from a ICS/VCS file (iCal format)
		  
		  If f <> Nil and f.Exists then
		    ImportICS(TextInputStream.Open(f).ReadAll, DefaultColor, Editable)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ImportICS(txt As String, DefaultColor As Color = &c4986E7, Editable As Boolean = False)
		  //Imports CalendarEvents from a ICS/VCS formated string (iCal format)
		  
		  'Dim mp As new MethodProfiler(CurrentMethodName)
		  
		  #if DebugBuild
		    Dim ms As Double = Microseconds
		  #endif
		  
		  LoaderShow()
		  
		  
		  Dim Lines() As String = ReplaceLineEndings(txt, EndOfLine).Split(EndOfLine)
		  
		  txt = ""
		  
		  Dim i, u As Integer
		  
		  Dim DocumentOK As Boolean
		  
		  u = UBound(Lines)
		  
		  If u>1000 then
		    Freeze = True
		  End If
		  
		  Dim Summary, Description, Location, UID As String
		  Dim DateStart As Date
		  Dim DateEnd As Date
		  Dim Recurrence As CalendarRecurrence
		  Dim Item, Value As String
		  Dim HasColor As Boolean
		  Dim MyColor As Color
		  Dim Tag As Variant
		  
		  try
		    For i = 0 to u
		      If not DocumentOK then
		        If Lines(i) = "BEGIN:VCALENDAR" then
		          DocumentOK = True
		        End If
		        
		      else
		        Lines(i) = Trim(Lines(i))
		        
		        Item = Lines(i).NthField(":", 1)
		        Value = Lines(i).Mid(Item.len + 2)
		        Item = Item.NthField(";", 1)
		        
		        
		        Select Case Item
		          
		        Case "BEGIN"
		          If Lines(i) = "BEGIN:VEVENT" then
		            
		            Summary = ""
		            Description = ""
		            Location = ""
		            UID = ""
		            DateStart = Nil
		            DateEnd = Nil
		            
		            
		          End If
		          
		        Case "DTSTART"
		          
		          DateStart = New Date(VDate2SQLDate(Value))
		          
		        Case "SUMMARY"
		          Summary = Value
		          
		        Case "DESCRIPTION"
		          Description = Value
		          
		        Case "LOCATION"
		          Location = Value
		          
		        Case "UID"
		          UID = Value
		          
		        Case "DTEND"
		          
		          DateEnd = New Date(VDate2SQLDate(Value))
		          
		        Case "RRULE"
		          
		          Recurrence = New CalendarRecurrence(Value)
		          
		        Case "X-RSCV-COLOR"
		          HasColor = True
		          MyColor = RGB(val("&h" + Value.Mid(2, 2)), val("&h" + Value.Mid(4, 2)), val("&h" + Value.Mid(6, 2)))
		          
		        Case "X-RSCV-TAG"
		          Tag = Value
		          
		        Case "END"
		          If Lines(i) = "END:VEVENT" then
		            If DateStart <> Nil then
		              
		              'If UID <> "" then UID=str(Microseconds)
		              
		              If HasColor then
		                me.AddEvent New CalendarEvent(Summary, DateStart, DateEnd, MyColor, Location, _
		                 Description, UID, Editable, Tag, Recurrence)
		              else
		                me.AddEvent New CalendarEvent(Summary, DateStart, DateEnd, DefaultColor, Location, _ 
		                Description, UID, Editable, Tag, Recurrence)
		              End If
		            End If
		            
		            HasColor = False
		            
		          End If
		          Tag = Nil
		          Recurrence = Nil
		          
		        End Select
		      End If
		      
		      
		      
		    Next
		    
		    
		  Catch
		    
		  End Try
		  
		  #if DebugBuild
		    ms = (Microseconds-ms)/1000
		    'DrawInfo = str(ms)
		  #endif
		  
		  'Refresh(False)
		  Freeze = False
		  Redisplay
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InvertColor(c As Color) As Color
		  
		  Return RGB(255-c.Red, 255-c.Green, 255-c.Blue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoaderHide()
		  
		  If LoaderVisible = True then
		    LoaderVisible =False
		    If tLoader is nil then Return
		    tLoader.Mode = timer.ModeSingle
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoaderShow()
		  
		  If LoaderVisible = False then
		    LoaderVisible = true
		    If tLoader is nil then Return
		    tLoader.Mode = timer.ModeSingle
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function mixColor(frontC As Color, BackC As Color, Alpha As Integer) As Color
		  Dim c As Color
		  Dim a As Single = (255-Alpha) / 255
		  Dim b As Single = Alpha / 255
		  
		  c = RGB( frontC.red * a + BackC.Red * b,  frontC.Green * a + BackC.Green * b,  frontC.Blue * a + BackC.Blue * b)
		  
		  Return C
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ParseDate(D As Date, Format As String, Default As String = "") As String
		  If D is Nil then Return ""
		  
		  If Format = "" then
		    If Default = "" then Return D.LongDate
		    
		    Format = Default
		  End If
		  
		  Dim text As String = Format
		  
		  //Default formats
		  If text.InStr("Long Date")>0 then
		    text = text.Replace("Long Date", D.LongDate)
		  elseif text.InStr("longdate")>0 then
		    text = text.Replace("Longdate", D.LongDate)
		  elseif text.InStr("Short Date")>0 then
		    text = text.Replace("Short Date", D.ShortDate)
		  elseif text.InStr("ShortDate")>0 then
		    text = text.Replace("Shortdate", D.ShortDate)
		  elseif text.InStr("Abbreviated Date")>0 then
		    text = text.Replace("Abbreviated Date", D.AbbreviatedDate)
		  elseif text.InStr("AbbreviatedDate")>0 then
		    text = text.Replace("AbbreviatedDate", D.AbbreviatedDate)
		  elseif text.InStr("SQLDateTime")>0 then
		    text = text.Replace("SQLDateTime", D.SQLDateTime)
		  elseif text.InStr("SQLDate")>0 then
		    text = text.Replace("SQLDate", D.SQLDate)
		  End If
		  
		  If text <> Format then
		    Return Text
		  End If
		  
		  Dim Chars() As String = Format.Split("")
		  
		  Dim i As Integer
		  Dim u As Integer = UBound(Chars)
		  For i = u DownTo 1
		    If left(Chars(i), 1) = Chars(i-1) or chars(i-1) = "\" then
		      Chars(i-1) = Chars(i-1) + Chars(i)
		      Chars.Remove(i)
		    End If
		  Next
		  
		  u = UBound(Chars)
		  For i = 0 to u
		    text = Chars(i)
		    
		    If text.left(1) = "\" then
		      Chars(i) = mid(text, 2)
		      Continue for i
		    End If
		    
		    //Day
		    If text.InStr("dddd")>0 then
		      text = text.Replace("dddd", DayNames(D.DayOfWeek))
		    elseif text.InStrB("l")>0 then
		      
		      text = text.ReplaceB("l", DayNames(D.DayOfWeek))
		    ElseIf text.InStr("ddd")>0 then
		      text = text.Replace("ddd", DayNames(D.DayOfWeek).Left(3))
		    ElseIf text.InStr("d")>0 then
		      text = text.Replace("d", Format(D.Day, "00"))
		    elseif text.InStr("j")>0 then
		      text = text.Replace("j", str(D.Day))
		    ElseIf text.InStr("mmmm")>0 then
		      text = text.Replace("mmmm", MonthNames(D.Month))
		    elseif text.InStr("mm")>0 then
		      text = text.Replace("mm", Format(D.Month, "00"))
		    elseif text.InStrB("m")>0 then
		      text = text.Replace("m", Format(D.Month, "00"))
		    elseif text.InStrB("n")>0 then
		      text = text.ReplaceB("n", str(D.Month))
		    elseif text.InStrB("N")>0 then
		      text = text.ReplaceB("N", str((D.DayOfWeek+7-1) mod 7))
		    elseif text.InStrB("M")>0 then
		      text = text.ReplaceB("M", MonthNames(D.Month).Left(3))
		    elseif text.InStrB("F")>0 then
		      text = text.ReplaceB("F", MonthNames(D.Month))
		    elseif text.InStrB("w")>0 then
		      text = text.ReplaceB("w", str(D.DayOfWeek))
		    elseif text.InStr("W")>0 then
		      text = text.ReplaceB("W", str(D.WeekOfYear))
		    elseif text.InStr("z")>0 then
		      text = text.Replace("z", str(D.DayOfYear))
		    elseif text.InStr("t")>0 then
		      Dim DD As Date = New Date(D)
		      DD.day = 1
		      DD.Month = DD.Month+1
		      DD.Day = DD.Day-1
		      text = text.Replace("t", str(DD.Day))
		    elseif text.InStr("yyyy")>0 then
		      text = text.Replace("yyyy", str(D.Year))
		    elseif text.InStr("yy")>0 then
		      text = text.Replace("yy", mid(str(D.Year), 3))
		    elseif text.InStrB("Y")>0 then
		      text = text.ReplaceB("Y", str(D.Year))
		    elseif text.InStrB("y")>0 then
		      text = text.ReplaceB("y", str(D.Year))
		    End If
		    
		    Chars(i) = text
		  Next
		  
		  Return Join(Chars(), "")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseTime(D As Date, Format As String, Default As String = "") As String
		  If D is Nil then Return ""
		  
		  If Format = "" then
		    If Default = "" then Return D.ShortTime
		    
		    Format = Default
		  End If
		  
		  Dim text As String = Format
		  Dim AMPM As Boolean
		  Dim Hour As Integer = D.Hour
		  
		  If text.InStr("a")>0 then
		    AMPM = True
		  elseif ForceAM_PM then
		    AMPM = True
		  End If
		  
		  If AMPM then
		    If Hour>12 then
		      Hour = Hour - 12
		    End If
		  End If
		  
		  //Hours
		  If text.InStr("hh")>0 Then
		    text = text.Replace("hh", Format(Hour, "0#"))
		  elseif text.InStr("h")>0 then
		    text = text.Replace("h", str(Hour))
		  End If
		  
		  //Minutes
		  If text.InStr("mm")>0 then
		    text = text.Replace("mm", Format(D.Minute, "0#"))
		  elseif text.InStr("m")>0 then
		    text = text.Replace("m", str(D.Minute))
		  End If
		  
		  //Seconds
		  If text.InStr("ss")>0 then
		    text = text.Replace("ss", Format(D.Second, "0#"))
		  elseif text.InStr("s")>0 then
		    text = text.Replace("s", str(D.Second))
		  End If
		  
		  //AM_PM
		  If text.InStrB("a")>0 then
		    If D.Hour < 12 then
		      text = text.Replace("a", "am")
		    elseif D.Hour>=12 then
		      text = text.Replace("a", "pm")
		    End If
		  elseif text.InStrB("A")>0 then
		    If D.Hour < 12 then
		      text = text.Replace("a", "AM")
		    elseif D.Hour>=12 then
		      text = text.Replace("a", "PM")
		    End If
		  elseif AMPM then
		    If D.Hour < 12 then
		      text = text + "AM"
		    elseif D.Hour>=12 then
		      text = text + "PM"
		    End If
		  End If
		  
		  Return text
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Print(g As Graphics, PrintToday As Boolean = False)
		  FullRefresh = True
		  Dim Unfreeze As Boolean
		  If not Freeze then
		    Unfreeze = True
		    Freeze = True
		  End If
		  EraseBuffers
		  
		  'Dim lastGDIPlus As Boolean = App.UseGDIPlus
		  'App.UseGDIPlus = true
		  
		  If ViewType = TypePicker then
		    
		    If mLastDate is Nil then
		      Call LastDate
		    End If
		    
		    DrawPicker(g)
		    
		    //Displaying entire year
		  ElseIf ViewType = TypeYear then
		    
		    
		    DrawBackgroundYear(g, True, PrintToday)
		    
		    //Displaying entire Month
		  ElseIf ViewType = TypeMonth then
		    
		    If mLastDate is Nil then
		      Call LastDate
		    End If
		    
		    HeaderHeight = 48
		    Dim DayWidth As Single = g.Width / 7
		    Dim DayHeight As Single = (g.Height - HeaderHeight) / WeeksPerMonth
		    
		    
		    //Drawing Background
		    DrawBackgroundMonth(g, WeeksPerMonth, DayWidth, DayHeight, PrintToday)
		    'Next
		    
		    'ms = (Microseconds - ms)/1000
		    'MsgBox(str(ms) + " ms")
		    
		    '//Drawing Background
		    'DrawBackgroundMonth(g, WeeksPerMonth, DayWidth, DayHeight)
		    
		    //Drawing Events
		    DrawEventsMonth(g, WeeksPerMonth, DayWidth, DayHeight)
		    
		    
		    
		  elseif ViewType >= TypeWeek then
		    
		    HeaderHeight = 23
		    Dim DayWidth As Single = (g.Width - TimeWidth) / ViewDays
		    HourHeight = max(minHourHeight, Ceil((g.Height-(HeaderHeight + MyStyle.WEventHeight))/24))
		    
		    //Drawing Background
		    DrawBackgroundWeek(g, DayWidth, PrintToday)
		    
		    //Drawing Events
		    DrawEventsWeek(g, DayWidth)
		    
		    //Draw Time
		    'DrawTime(g, DayWidth)
		    
		    //Drawing Scrollbar
		    'If ShowScrollBar then
		    'DrawScrollBar(g)
		    'End If
		    
		  End If
		  
		  'app.UseGDIPlus = lastGDIPlus
		  
		  FullRefresh = True
		  If unfreeze then
		    Freeze = False
		  End If
		  EraseBuffers
		  
		  
		  
		  
		  #if not DebugBuild and not kOpenSource
		    If not Registered then
		      g.ForeColor = &cFF0000
		      g.Bold = True
		      g.TextSize = 16
		      g.DrawString("Demo Version", (g.Width-g.StringWidth("Demo Version"))\2, g.Height\2)
		    End If
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrintAdvanced(g As Graphics, PrintToday As Boolean = False)
		  //Prints the current view on the passed graphics property.
		  //
		  //Use this function to handle the Print setup window and the printing area.
		  //
		  //If PrintToday is True, the current day will be highlighted.
		  
		  If g <> Nil then
		    
		    Print(g, PrintToday)
		    
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrintSimple(PrintToday As Boolean = False)
		  //Prints the current display on the entire sheet of paper (within the print range)
		  //
		  //If PrintToday is True, the current day will be highlighted
		  
		  #if TargetDesktop
		    Dim g as Graphics
		    
		    Dim p as PrinterSetup
		    
		    p=New PrinterSetup
		    
		    If p.PageSetupDialog then
		      
		      //The greater the value, the smaller the text will be when printed.
		      p.maxHorizontalResolution=120
		      p.maxVerticalResolution=120
		      
		      g=OpenPrinterDialog(p)
		      
		      If g <> Nil then
		        
		        Print(g, PrintToday)
		        
		      End if
		      
		      
		    End if
		    
		  #else
		    #Pragma Unused PrintToday
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Redisplay(FilterEvents As Boolean = False)
		  //Erases the buffer and completely refreshes the CalendarView in 10 ms.
		  //The 10 ms delay prevents multiple refreshes when only one would be necessary.
		  
		  'Dim mp As new MethodProfiler(CurrentMethodName)
		  
		  FullRefresh = True
		  If Freeze then
		    Return
		  End If
		  
		  If me.ViewType = TypeYear or FilterEvents then
		    Redim DisplayEvents(-1)
		  End If
		  
		  #if TargetDesktop
		    'Invalidate()
		    '#else
		    If RefreshTimer <> Nil then
		      RefreshTimer.Period = 10
		    End If
		  #elseif TargetWeb
		    If not ControlAvailableInBrowser then Return
		    
		    Dim js() As String
		    
		    'LoaderShow()
		    
		    Dim container As String = me.ControlID + "_container"
		    
		    If ViewType = TypeYear then
		      If ControlAvailableInBrowser then
		        ExecuteJavaScript("Xojo.get('" + container + "').innerHTML = '" + _
		        ReplaceLineEndings(DrawHTMLYear, "").ReplaceAll("'", "\'") +  "<div id=""" + me.controlID + "_img_container""></div>'")
		        ExecuteJavaScript("Xojo.get('" + container + "').style.overflowX = 'auto'; " + _
		        "Xojo.get('" + container + "').style.overflowY = 'auto'; ")
		        
		        
		      End If
		    Elseif ViewType = TypePicker then
		      
		      If ControlAvailableInBrowser then
		        ExecuteJavaScript("Xojo.get('" + container + "').innerHTML = '" + _
		        ReplaceLineEndings(DrawHTMLPicker, "").ReplaceAll("'", "\'") + "<div id=""" + me.controlID + "_img_container""></div>'")
		        ExecuteJavaScript("Xojo.get('" + container + "').style.overflowX = 'hidden'; " + _
		        "Xojo.get('" + container + "').style.overflowY = 'hidden'; ")
		      End If
		    else
		      
		      
		      'ExecuteJavaScript("Xojo.get('" + me.ControlID + "_loader').style.display = 'block';")
		      
		      myPicture = New WebPicture(me.ExportAsPicture)
		      myPicture.Filename = me.ControlID + ".png"
		      'myPicture.MIMEType = "image/png"
		      'myPicture.Data = me.ExportAsPicture.GetData(Picture.FormatPNG)
		      
		      #if DebugBuild
		        #Pragma BreakOnExceptions False
		      #EndIf
		      try
		        If myPicture.Session is nil then
		          myPicture.Session = App.SessionForControlID(self.ControlID)
		          if myPicture.Session is nil then Return
		        End If
		      Catch
		        Return
		      end try
		      
		      
		      
		      
		      
		      If myPicture.URL <> "" then
		        Dim Data As String
		        Data = "<img src=""" + myPicture.URL + """>"
		        
		        Dim onClick, onScroll As String
		        js.Append "var relObj = Xojo.get(\'" + self.ControlID + "_img_container\');"
		        js.Append "var coordinates = Xojo.input.getCoordinates(relObj, event);"
		        js.Append "Xojo.triggerServerEvent(\'" + me.ControlID + "\',\'MouseDown_\',[coordinates[0].x, coordinates[0].y]); "
		        
		        onClick = Join(Js, " ")
		        
		        Redim js(-1)
		        js.Append "var relObj = Xojo.get(\'" + self.ControlID + "_img_container\');"
		        js.Append "Xojo.triggerServerEvent(\'" + me.ControlID + "\',\'Scroll_\',[relObj.scrollTop]);"
		        
		        onScroll = Join(Js, " ")
		        
		        Dim html As String
		        
		        
		        If ViewType = TypeMonth then
		          html = ReplaceLineEndings(DrawHTMLMonth, "").ReplaceAll("'", "\'")
		        Elseif ViewType >= TypeWeek then
		          html = ReplaceLineEndings(DrawHTMLWeek, "").ReplaceAll("'", "\'")
		        End If
		        
		        
		        'If html <> "" then
		        //onclick=""Xojo.triggerServerEvent('" + Self.ControlID + "','Click',['%value%']); return false;""
		        ExecuteJavascript("var myElem = Xojo.get('" + me.ControlID + "_img');" + _
		        "if (myElem == null) {" + _
		        "Xojo.get('" + container + "').innerHTML = '" + html + "<div id=""" + me.controlId + _
		        "_img_container"" style=""overflow-x: hidden; overflow-y: hidden"" onmousedown=""" + onClick + """ onmouseup=""" + _
		        onClick.Replace("MouseDown", "MouseUp") + """ onscroll=""" + onScroll + """><img id=""" + me.ControlID + _
		        "_img"" style=""-moz-user-select:none;-webkit-user-select:none;"" src=""" + myPicture.URL + """/></div>';" + _
		        "}else{" + _
		        "Xojo.get('" + me.ControlID + "_header').outerHTML = '" + html + "';" + _
		        "myElem.src = '" + myPicture.URL + "';" + _
		        "};")
		         
		        //Overflows
		        ExecuteJavaScript("Xojo.get('" + container +"').style.overflowX = 'hidden'; Xojo.get('" + container +"').style.overflowY = 'hidden'; ")
		        
		        If ViewType >= TypeWeek then
		          ExecuteJavaScript("Xojo.get('" + me.ControlID + "_img_container').style.overflowY = 'auto'; ")
		        Else
		          ExecuteJavaScript("Xojo.get('" + me.ControlID + "_img_container').style.overflowY = 'hidden'; ")
		        End If
		        
		        ExecuteJavaScript("Xojo.get('" + me.ControlID + "_img_container').style.height = '" + str(me.Height-HeaderHeightHTML) + "px';")
		        
		        //End of Overflows
		        
		        
		        'Else
		        '
		        'ExecuteJavascript("var myElem = Xojo.get('" + me.ControlID + "_img');" + _
		        '"if (myElem == null) {" + _
		        '"Xojo.get('" + container + "').innerHTML = '" + html + "<img id=""" + me.ControlID + "_img"" draggable=""false"" style=""-moz-user-select:none;-webkit-user-select:none;"" src=""" + myPicture.URL + """>';" + _
		        '"}else{" + _
		        '"myElem.src = '" + myPicture.URL + "';" + _
		        '"};")
		        '
		        'End If
		        
		        ExecuteJavaScript("Xojo.get('" + me.controlID + "_img').ondragstart = function() { return false; };")
		        'ExecuteJavaScript("Xojo.get('" + me.controlID + "_img').style.height = '" + str(Height-HeaderHeightHTML) + "px';")
		        
		        
		        
		      End If
		      
		    End If
		    
		    'LoaderHide()
		    
		    
		  #endif
		  '#endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveEvent(cEvent As CalendarEvent, RemoveFromDB As Boolean = True)
		  //Removes the passed CalendarEvent from the CalendarView
		  //If RemoveFromDB is True, next time ExportToDB is called, all removed events will also be removed from the Database
		  
		  
		  
		  If RemoveFromDB And Trim(cEvent.ID) <> "" and cEvent.ID.left(4) <> "auto" Then
		    DeletedIDs.Append cEvent.ID
		  End If
		  
		  Dim idx As Integer = Events.IndexOf(cEvent)
		  
		  If idx > -1 then
		    Events.Remove(idx)
		    Redim DisplayEvents(-1)
		    Redisplay
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveEventByID(EventIDs() As String)
		  //Removes the passed CalendarEvent from the CalendarView
		  //If RemoveFromDB is True, next time ExportToDB is called, all removed events will also be removed from the Database
		  
		  
		  Dim uEvents As Integer = UBound(Events)
		  Dim uIDs As Integer = UBound(EventIds)
		  Dim cEvent As CalendarEvent
		  
		  Dim ms As Double = Microseconds
		  
		  Dim i As Integer
		  
		  Freeze = True
		  Dim cnt As Integer
		  
		  Dim dicIDs As New Dictionary
		  For i = 0 to uIDs
		    dicIDs.Value(EventIDs(i)) = ""
		  Next
		  
		  for i = uEvents DownTo 0
		    
		    cEvent = me.Events(i)
		    
		    If dicIDs.HasKey(cEvent.ID) then
		      cnt = cnt + 1
		      RemoveEvent(cEvent)
		      dicIDs.Remove(cEvent.ID)
		      If dicIDs.Count = 0 then Exit for i
		    End If
		  next
		  
		  'For j = uIDs DownTo 0
		  '
		  'For i = 0 to uEvents
		  'cEvent = me.Events(i)
		  '
		  'If cEvent.ID = EventIds(j) then
		  'RemoveEvent(cEvent)
		  'cnt = cnt + 1
		  'uEvents = UBound(Events)
		  'End If
		  'Next
		  'Next
		  System.DebugLog str((Microseconds-ms)/1000) + "ms" + EndOfLine + "Removed: " + str(cnt) + " events"
		  
		  //Now Refresh the view
		  
		  Freeze = False
		  me.Redisplay()
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveEventByID(EventID As String, ParamArray MoreIDs As String)
		  //Removes the passed CalendarEvent from the CalendarView
		  //If RemoveFromDB is True, next time ExportToDB is called, all removed events will also be removed from the Database
		  
		  If MoreIDs is Nil then
		    MoreIds() = Array(EventID)
		  End If
		  
		  MoreIDs.Insert(0, EventID)
		  
		  RemoveEventByID(MoreIDs)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Scroll(deltaX As Integer, deltaY As Integer = 0)
		  //Scrolls the view according to the passed parameters.
		  
		  If deltaX = 0 And deltaY = 0 Then
		    Return
		  End If
		  
		  'If ViewType = TypePicker then
		  'Return
		  'End If
		  
		  If ViewType = TypeYear Then
		    DisplayDate.Day = 1
		    
		    DisplayDate.Year = DisplayDate.Year + deltaX
		    
		    ViewChanged
		    
		    FullRefresh = True
		    
		  Elseif ViewType = TypeMonth or ViewType = TypePicker Then
		    DisplayDate.Day = 1
		    
		    DisplayDate.Month = DisplayDate.Month + deltaX
		    
		    ViewChanged
		    
		    FullRefresh = True
		    
		  Elseif ViewType > TypeMonth Then
		    
		    Dim lastDay As Integer = DisplayDate.Day
		    Dim lastScroll As Double = mScrollPosition
		    
		    If ViewType = TypeOther And ViewDays = 5 Then
		      DisplayDate.Day = DisplayDate.Day + deltaX * 7
		    Else
		      DisplayDate.Day = DisplayDate.Day + deltaX * ViewDays
		    End If
		    
		    If Abs(deltaY) > (Me.Height-ViewHeight)\HourHeight And DeltaY <> 0 Then
		      ScrollPosition = ScrollPosition + Abs(deltaY)/deltaY
		    Elseif deltaY <> 0 then
		      ScrollPosition = ScrollPosition + deltaY
		    End If
		    
		    FullRefresh = True
		    
		    If DisplayDate.Day = lastDay And lastScroll = mScrollPosition Then
		      FullRefresh = False
		      Return
		    Elseif DisplayDate.Day <> lastDay Then
		      ViewChanged
		    End If
		  End If
		  
		  If DragEvent = DragMove and LastMouseOver <> Nil then
		    HandleDragEvent(LastX, LastY)
		  End If
		  
		  If Animate then
		    oldBuffer = Buffer
		    AnimationInProgress = DeltaX
		  End If
		  
		  'Invalidate(False)
		  
		  #if TargetDesktop
		    Refresh(False)
		  #elseif TargetWeb
		    Redisplay()
		  #endif
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(txt As String, setFocus As Boolean = True, FromBeginning As Boolean = False) As CalendarEvent
		  //newinversion 1.4.0
		  //Searches through all events to find the passed txt string in the event
		  //If no CalendarEvent matching the search term is found, Nil is returned
		  
		  Dim dFirst, dLast As Date
		  dFirst = New Date(FirstDate)
		  dLast = New Date(Today.Year + 20)
		  
		  If FromBeginning then
		    LastSearchResult=Nil
		    dFirst = New Date()
		    dFirst.TotalSeconds = 1
		    EventsSorted = False
		  elseif LastSearchResult <> Nil then
		    dFirst = new date(LastSearchResult.StartDate)
		  End If
		  
		  //First we sort events
		  'If not EventsSorted then
		  'LastSearchResult=Nil
		  SortEvents(dFirst, dLast)
		  'EventsSorted = True
		  'End If
		  
		  Dim i As Integer
		  Dim U As Integer = UBound(DisplayEvents)
		  Dim cEvent As CalendarEvent
		  Dim foundID As Integer = -1
		  
		  
		  //Searching through all events
		  For i = 0 to U
		    cEvent = DisplayEvents(i)
		    
		    If LastSearchResult <> Nil and cEvent.StartDate < LastSearchResult.StartDate then
		      Continue
		    End If
		    
		    If cEvent <> LastSearchResult then
		      If cEvent.Title.InStr(txt)>0 then
		        foundID = i
		        exit
		      elseif cEvent.Description.InStr(txt)>0 then
		        foundID = i
		        Exit
		      elseif cEvent.Location.InStr(txt)>0 then
		        foundID = i
		        Exit
		      End If
		    End If
		  Next
		  
		  //If found a match we return the result
		  If foundID > -1 then
		    LastSearchResult = cEvent
		    If setFocus then
		      FocusOn(cEvent)
		    End If
		    
		    Return cEvent
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetDayColor()
		  //In DebugBuild we check performance of drawing
		  #If DebugBuild
		    Dim ms As Double = Microseconds
		  #EndIf
		  
		  //Sets the Day Colors for each day in the year depending on the events
		  
		  Dim DrawDate As New Date(FirstDate)
		  Dim amount As Integer
		  Dim i, j As Integer
		  Dim idx As Integer
		  Dim u As Integer
		  Dim E As CalendarEvent
		  
		  Redim DayColor(-1)
		  Redim DayColor(366)
		  
		  
		  //Heat Map
		  If YearHeatMap Then
		    
		    SortEvents(FirstDate, LastDate)
		    u = UBound(DisplayEvents)
		    
		    Dim EventsPerDay(366) As Integer
		    Dim maxVal As Integer
		    
		    If u > -1 Then
		      For i = 1 To 366
		        amount = 0
		        For j = idx To u
		          
		          E = DisplayEvents(j)
		          
		          If DrawDate.TotalSeconds+86399 < DisplayEvents(j).StartSeconds Then
		            If amount = 0 Then
		              idx = j
		            End If
		            Exit For j
		          Elseif DrawDate.TotalSeconds <= DisplayEvents(j).EndSeconds Then
		            amount = amount + 1
		          End If
		          
		        Next
		        
		        EventsPerDay(i) = amount
		        maxVal = Max(maxVal, amount)
		        DrawDate.Day = DrawDate.Day + 1
		      Next
		    End If
		    
		    For i = 1 To 366
		      
		      If EventsPerDay(i) > 0 Then
		        If EventsPerDay(i) = 1 Then
		          DayColor(i) = New CalendarYearColors(HSV(0.16, 1, 1))
		        Else
		          DayColor(i) = New CalendarYearColors(HSV(0.14-0.14*EventsPerDay(i)/maxVal, 0.5, 1))
		        End If
		      Else
		        'DayColor(i) = &c0
		      End If
		    Next
		    
		  Else //Regular view
		    
		    SortEvents(FirstDate, LastDate, False, Not YearMultipleEvents)
		    u = UBound(DisplayEvents)
		    
		    For i = 1 To 366
		      
		      For j = Idx To U
		        
		        If DrawDate.TotalSeconds+86399 < DisplayEvents(j).StartSeconds Then
		          If YearMultipleEvents = False then
		            Idx = j
		          End If
		          Exit For j
		        Elseif DrawDate.TotalSeconds <= DisplayEvents(j).EndSeconds Then
		          If DayColor(i) is Nil then
		            DayColor(i) = New CalendarYearColors(DisplayEvents(j).EventColor)
		          else
		            DayColor(i).AppendColor(DisplayEvents(j).EventColor)
		          End If
		          'DayColor(i) = DisplayEvents(j).EventColor
		          If YearMultipleEvents = False then
		            Exit For j
		          End If
		        else
		          Idx = j
		          'Exit for j
		        End If
		      Next
		      
		      DrawDate.Day = DrawDate.Day + 1
		    Next
		  End If
		  
		  #If DebugBuild
		    ms = (Microseconds-ms)/1000
		    DrawInfo = Str(ms)
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetStyle(StyleType As Integer)
		  //Sets the StyleType
		  //See the Style constants of the CalendarView for the StyleType accepted values.
		  
		  mStyle = StyleType
		  
		  EraseBuffers()
		  
		  Dim DefaultTextSize As Integer
		  
		  #if TargetDesktop
		    Dim FillColor As Color = FillColor
		    #If TargetMacOS Then
		      FillColor = &cEDEDED
		    #EndIf
		    DefaultTextSize = 0
		  #elseif TargetWeb
		    Dim FillColor As Color = &cFFFFFF
		    Dim HighlightColor As Color = &cA6CAFE
		    DefaultTextSize = 12
		  #endif
		  
		  MyStyle.StringValue(True) = ""
		  
		  //applies to all styles:
		  MyStyle.MTitleTextSize = 20
		  MyStyle.MNumbersTextSize = DefaultTextSize
		  MyStyle.YTitleTextSize = 10
		  MyStyle.YNumbersTextSize = 9
		  MyStyle.WTextSize = DefaultTextSize
		  MyStyle.PTextSize = DefaultTextSize
		  
		  If StyleType = StyleDefault Then
		    MyStyle.MDayTextBold = False
		    MyStyle.MDayTextColor = &c0
		    MyStyle.MDayTransparent = False
		    MyStyle.MDayTransparency = &cAAAAAA
		    MyStyle.MDayRoundRect = True
		    MyStyle.MEventHeight = 12
		    MyStyle.MEventTextSize = 10
		    MyStyle.MLeftOffset = 0
		    MyStyle.MTextOffset = 3
		    MyStyle.MHourBold = True
		    MyStyle.MTextBold = False
		    MyStyle.MDayNumberAlign = AlignRight
		    MyStyle.MDayNameAlign = AlignCenter
		    MyStyle.MNumberXOffset = 3
		    MyStyle.MNumberYOffset = 0
		    
		    MyStyle.WEventHeight = 18
		    MyStyle.MColorOffset1 = 8
		    MyStyle.MColorOffset2 = 40
		    MyStyle.MEventFill = FillGradientHorizontal
		    MyStyle.MBorderSolid = True
		    MyStyle.MDayNumberBackground = False
		    MyStyle.MColorOtherMonth = False
		    MyStyle.MFirstDayOfMonthName = True
		    MyStyle.MFirstDayOfMonthBold = False
		    
		    MyColors.WeekNumber = &cFFFFFF
		    MyColors.WeekNumberBackground = &c7799BB
		    MyColors.Border = &cCCCCCC
		    MyColors.Line = &cCCCCCC
		    MyColors.Title = &c505050
		    MyColors.DayName = &c757575
		    MyColors.DayNumber = &cA9A9A9
		    MyColors.DayNumberActive = &c2B2B2B
		    MyColors.TimeBackground = &cEDEDED
		    MyColors.TimeBackground = FillColor
		    MyColors.Time = &c9B9C9D
		    MyColors.Today = &cEAF0F9
		    MyColors.Header = FillColor
		    MyColors.Selected = &cFFF0F0
		    MyColors.WeekDay = &cFFFFFF
		    MyColors.Weekend = &cF0FAF0
		    MyColors.YBackground = FillColor
		    
		    MyColors.PDayNumber = &cA9A9A9
		    MyColors.PDayNumberActive = &c2B2B2B
		    MyColors.PSelected = &cEEEEEE
		    MyColors.POver = &cEEEEEE
		    MyColors.PBackground = &cFFFFFF
		    MyColors.PArrow = &c505050
		    MyStyle.PDayNumberBold = False
		    MyStyle.PLineHorizontal = LineNone
		    MyStyle.PLineVertical = LineThinDotted
		    
		    MyStyle.WTodayHeader = False
		    MyStyle.WHeaderColorOffset = 0
		    MyStyle.WHeaderHeight = 13 //a corriger
		    MyStyle.WRoundRect = True
		    MyStyle.WHeaderTransparency = &c0
		    MyStyle.WBodyTransparency = &c0
		    MyStyle.WHeaderTextBold = False
		    MyStyle.WHeaderTextSize = 10
		    MyStyle.WHeaderTextFormat = "%Start (%Length)"
		    MyStyle.WTimeVOffset = 0
		    MyStyle.WTimeAlign = AlignRight
		    MyStyle.WBodyTextBold = False
		    MyStyle.WBodyTextSize = 10
		    MyStyle.WBodyColorOffset1 = 8
		    MyStyle.WBodyColorOffset2 = 40
		    MyStyle.WEventFill = FillGradientHorizontal
		    MyStyle.WAutoTextColor = False
		    MyStyle.WTextColor = &c0
		    MyStyle.WHourLineStartX=TimeWidth
		    MyStyle.WHalfHourLineStyle = 1
		    MyStyle.WHalfHourColorOffset = &h10
		    MyColors.WDefaultColor = HighlightColor
		    MyStyle.YLineHorizontal = LineThinSolid
		    MyStyle.YLineVertical = LineThinSolid
		    
		    MyStyle.PDayNamePos = 1
		    MyStyle.PDayNumberPos = 1
		    MyStyle.PDayNameBold = True
		    
		    
		  Elseif StyleType = StyleICal Then //iCal
		    MyStyle.MDayTextBold = False
		    MyStyle.MDayTextColor = &cFFFFFF
		    MyStyle.MDayTransparent = True
		    MyStyle.MDayTransparency = &c868686
		    MyStyle.MDayRoundRect = True
		    MyStyle.MEventHeight = 12
		    MyStyle.MEventTextSize = 10
		    MyStyle.MLeftOffset = 0
		    MyStyle.MTextOffset = 3
		    MyStyle.MHourBold = True
		    MyStyle.MTextBold = False
		    MyStyle.MDayNumberAlign = AlignRight
		    MyStyle.MDayNameAlign = 3
		    MyStyle.MColorOffset1 = 0
		    MyStyle.MColorOffset2 = 0
		    MyStyle.MBorderSolid = False
		    MyStyle.MDayNumberBackground = False
		    MyStyle.MColorOtherMonth = False
		    MyStyle.MFirstDayOfMonthName = False
		    MyStyle.MFirstDayOfMonthBold = False
		    MyStyle.MNumberXOffset = 3
		    MyStyle.MNumberYOffset = 0
		    
		    
		    MyColors.WeekNumber = &cFFFFFF
		    MyColors.WeekNumberBackground = &c777777
		    MyColors.Border = &cCCCCCC
		    MyColors.Line = &cCCCCCC
		    MyColors.Title = &c505050
		    MyColors.DayName = &c757575
		    MyColors.DayNumber = &cA9A9A9
		    MyColors.DayNumberActive = &c2B2B2B
		    MyColors.TimeBackground = FillColor
		    MyColors.Time = &c9B9C9D
		    MyColors.Today = &cEAF0F9
		    MyColors.Header = FillColor
		    MyColors.Selected = &cFFF0F0
		    MyColors.WeekDay = &cFFFFFF
		    MyColors.Weekend = &cF0FAF0
		    MyColors.YBackground = FillColor
		    
		    AdaptWeeksPerMonth = True
		    MyColors.PDayNumber = &cFFFFFF
		    MyColors.PDayNumberActive = &c2B2B2B
		    MyColors.PSelected = &cEEEEEE
		    MyColors.POver = &cEEEEEE
		    MyColors.PBackground = &cFFFFFF
		    MyColors.PArrow = &c505050
		    MyStyle.PDayNumberBold = False
		    MyStyle.PLineHorizontal = LineNone
		    MyStyle.PLineVertical = LineNone
		    
		    MyStyle.WTodayHeader = False
		    MyStyle.WEventHeight = 18
		    MyStyle.WHeaderColorOffset = &hD8
		    MyStyle.WHeaderHeight = 0
		    MyStyle.WRoundRect = True
		    MyStyle.WHeaderTransparency = &c0
		    MyStyle.WBodyTransparency = &c777777
		    MyStyle.WBodyColorOffset1 = 0
		    MyStyle.WBodyColorOffset2 = 0
		    MyStyle.WHeaderTextBold = False
		    MyStyle.WHeaderTextSize = 10
		    MyStyle.WHeaderTextFormat = "%Start"
		    MyStyle.WTimeVOffset = 0
		    MyStyle.WTimeAlign = AlignRight
		    MyStyle.WBodyTextBold = False
		    MyStyle.WBodyTextSize = 11
		    MyStyle.WAutoTextColor = True
		    MyStyle.WHourLineStartX = TimeWidth
		    MyStyle.WHalfHourLineStyle = 0
		    MyStyle.WHalfHourColorOffset = &h10
		    MyColors.WDefaultColor = HighlightColor
		    MyStyle.YLineHorizontal = LineThinSolid
		    MyStyle.YLineVertical = LineThinSolid
		    
		    MyStyle.PDayNamePos = 1
		    MyStyle.PDayNumberPos = 1
		    MyStyle.PDayNameBold = True
		    
		  Elseif StyleType = StyleGoogle Then //Google Calendar
		    MyStyle.MDayTextBold = False
		    MyStyle.MDayTextColor = &c777777
		    MyStyle.MDayTransparent = False
		    MyStyle.MDayTransparency = &c0
		    MyStyle.MDayRoundRect = False
		    MyStyle.MEventHeight = 20
		    MyStyle.MEventTextSize = 12
		    MyStyle.MLeftOffset = 2
		    MyStyle.MTextOffset = 5
		    MyStyle.MHourBold = True
		    MyStyle.MTextBold = False
		    MyStyle.MDayNumberAlign = AlignLeft
		    MyStyle.MDayNameAlign = AlignLeft
		    MyStyle.MColorOffset1 = 0
		    MyStyle.MColorOffset2 = 0
		    MyStyle.MEventFill = FillSolid
		    MyStyle.MBorderSolid = False
		    MyStyle.MDayNumberBackground = False
		    MyStyle.MColorOtherMonth = False
		    MyStyle.MFirstDayOfMonthName = False
		    MyStyle.MFirstDayOfMonthBold = False
		    MyStyle.MNumberXOffset = 3
		    MyStyle.MNumberYOffset = 0
		    
		    MyColors.WeekNumber = &cFFFFFF
		    MyColors.WeekNumberBackground = &c7799BB
		    MyColors.Border = &cCCCCCC
		    MyColors.Line = &cCCCCCC
		    MyColors.Title = &c505050
		    MyColors.DayName = &c757575
		    MyColors.DayNumber = &cA9A9A9
		    MyColors.DayNumberActive = &c2B2B2B
		    MyColors.Time = &c9B9C9D
		    MyColors.TimeBackground = &cFFFFFF
		    MyColors.Today = &cEAF0F9
		    MyColors.Header = FillColor
		    MyColors.Selected = &cFFF0F0
		    MyColors.WeekDay = &cFFFFFF
		    MyColors.Weekend = &cF0FAF0
		    MyColors.YBackground = FillColor
		    
		    MyColors.PSelected = &cEEEEEE
		    MyColors.POver = &cEEEEEE
		    MyColors.PBackground = &cFFFFFF
		    MyColors.PArrow = &c8B8D8A
		    MyColors.PDayNumber = &cA9A9A9
		    MyColors.PDayNumberActive = &c2B2B2B
		    MyStyle.PDayNumberBold = False
		    MyStyle.PLineHorizontal = LineNone
		    MyStyle.PLineVertical = LineNone
		    
		    
		    MyStyle.WEventHeight = 20
		    MyStyle.WHeaderColorOffset = &hD8
		    MyStyle.WHeaderHeight = 0
		    MyStyle.WHeaderTransparency = &c0
		    MyStyle.WBodyColorOffset1 = 0
		    MyStyle.WBodyColorOffset2 = 0
		    MyStyle.WBodyTransparency = &c0
		    MyStyle.WRoundRect = False
		    
		    MyStyle.WTodayHeader = False
		    MyStyle.WHeaderTextBold = True
		    MyStyle.WHeaderTextSize = 10
		    MyStyle.WHeaderTextFormat = "%Start - %End"
		    MyStyle.WTimeVOffset = 10
		    MyStyle.WTimeAlign = AlignRight
		    MyStyle.WBodyTextBold = False
		    MyStyle.WBodyTextSize = DefaultTextSize
		    MyStyle.WAutoTextColor = False
		    MyStyle.WTextColor = &c1D1D1D
		    MyStyle.WHourLineStartX = 1
		    MyStyle.WHalfHourLineStyle = 1
		    MyStyle.WHalfHourColorOffset = &h10
		    MyColors.WDefaultColor = &c4986E7
		    MyStyle.YLineHorizontal = LineThinSolid
		    MyStyle.YLineVertical = LineThinSolid
		    
		    MyStyle.PDayNamePos = 1
		    MyStyle.PDayNumberPos = 1
		    MyStyle.PDayNameBold = False
		    
		  Elseif StyleType = StyleDark Then
		    MyStyle.MDayTextBold = True
		    MyStyle.MDayTextColor = &c999999
		    MyStyle.MDayTransparent = False
		    MyStyle.MDayTransparency = &cAAAAAA
		    MyStyle.MDayRoundRect = True
		    MyStyle.MEventHeight = 12
		    MyStyle.MEventTextSize = 10
		    MyStyle.MLeftOffset = 0
		    MyStyle.MTextOffset = 3
		    MyStyle.MHourBold = True
		    MyStyle.MTextBold = True
		    MyStyle.MDayNumberAlign = AlignRight
		    MyStyle.MDayNameAlign = AlignCenter
		    MyStyle.MNumberXOffset = 3
		    MyStyle.MNumberYOffset = 0
		    
		    MyStyle.WEventHeight = 18
		    MyStyle.MColorOffset1 = 8
		    MyStyle.MColorOffset2 = 40
		    MyStyle.MEventFill = FillGradientHorizontal
		    MyStyle.MBorderSolid = True
		    MyStyle.MDayNumberBackground = False
		    MyStyle.MColorOtherMonth = False
		    MyStyle.MFirstDayOfMonthName = False
		    MyStyle.MFirstDayOfMonthBold = False
		    
		    MyColors.WeekNumber = &cFFFFFF
		    MyColors.WeekNumberBackground = &c7799BB
		    MyColors.Border = &c353535
		    MyColors.Line = &c000000
		    MyColors.Title = &cCCFF35
		    MyColors.DayName = &c999999
		    MyColors.DayNumber = &c323232
		    MyColors.DayNumberActive = &cFEFEFE
		    MyColors.TimeBackground = &c161616
		    MyColors.Time = &c999999
		    MyColors.Today = &c93C400
		    MyColors.Header = &c161616
		    MyColors.Selected = &c2E3614
		    MyColors.WeekDay = &c161616
		    MyColors.Weekend = &c1E1E1E
		    MyColors.YBackground = &cCCCCCC
		    Me.ColorWeekend = False
		    
		    
		    MyColors.PDayNumber = &c323232
		    MyColors.PDayNumberActive = &cFEFEFE
		    MyColors.PSelected = &c2E3614
		    MyColors.POver = &c2E3614
		    MyColors.PBackground = &c161616
		    MyColors.PArrow = &c999999
		    MyColors.line2 = &c2B2B2B
		    MyStyle.PDayNumberBold = True
		    MyStyle.PLineHorizontal = LineNone
		    MyStyle.PLineVertical = LineThinDouble
		    
		    MyStyle.WTodayHeader = False
		    MyStyle.WHeaderColorOffset = 0
		    MyStyle.WHeaderHeight = 13 //a corriger
		    MyStyle.WRoundRect = True
		    MyStyle.WHeaderTransparency = &c0
		    MyStyle.WBodyTransparency = &c0
		    MyStyle.WHeaderTextBold = True
		    MyStyle.WHeaderTextSize = 9
		    MyStyle.WHeaderTextFormat = "%Start (%Length)"
		    MyStyle.WTimeVOffset = 0
		    MyStyle.WBodyTextBold = False
		    MyStyle.WBodyTextSize = 10
		    MyStyle.WBodyColorOffset1 = 8
		    MyStyle.WBodyColorOffset2 = 40
		    MyStyle.WEventFill = FillGradientHorizontal
		    MyStyle.WAutoTextColor = False
		    MyStyle.WTextColor = &c0
		    MyStyle.WHourLineStartX = TimeWidth
		    MyStyle.WHalfHourLineStyle = 1
		    MyStyle.WHalfHourColorOffset = &h10
		    MyColors.WDefaultColor = HighlightColor
		    MyStyle.YLineHorizontal = LineNone
		    MyStyle.YLineVertical = LineThinDouble
		    
		    MyStyle.PDayNamePos = 1
		    MyStyle.PDayNumberPos = 1
		    MyStyle.PDayNameBold = True
		    
		    
		  Elseif StyleType = StyleOutlook2010 Then
		    MyStyle.MDayTextBold = False
		    MyStyle.MDayTextColor = &c3B3B3B
		    MyStyle.MDayTransparent = False
		    MyStyle.MDayTransparency = &c0
		    MyStyle.MDayRoundRect = False
		    MyStyle.MEventHeight = 19
		    MyStyle.MEventTextSize = 10
		    MyStyle.MLeftOffset = 0
		    MyStyle.MTextOffset = 3
		    MyStyle.MHourBold = False
		    MyStyle.MTextBold = False
		    MyStyle.MDayNumberAlign = AlignLeft
		    MyStyle.MDayNameAlign = AlignCenter
		    MyStyle.MNumberXOffset = 3
		    MyStyle.MNumberYOffset = 0
		    
		    MyStyle.WEventHeight = 19
		    MyStyle.MColorOffset1 = 60
		    MyStyle.MColorOffset2 = 8
		    MyStyle.MEventFill = FillGradientVertical
		    MyStyle.MBorderSolid = True
		    MyStyle.MDayNumberBackground = True
		    MyStyle.MFirstDayOfMonthName = False
		    MyStyle.MFirstDayOfMonthBold = False
		    
		    MyColors.WeekNumber = &c3B3B3B
		    MyColors.WeekNumberBackground = &cA5BFE1
		    MyColors.Border = &cCCCCCC
		    MyColors.Line = &cA5BFE1
		    MyColors.Title = &c505050
		    MyColors.DayName = &c3B3B3B
		    MyColors.DayNumber = &c808080
		    MyColors.DayNumberActive = &c3B3B3B
		    MyColors.DayNumberBackground = &cCEDBEF
		    MyColors.Time = &c3B3B3B
		    MyColors.TimeBackground = &cFFFFFF
		    MyColors.Today = &cFFF8BF
		    MyColors.Header = &cA5BFE1
		    MyColors.Selected = &cFFF0F0
		    MyColors.WeekDay = &cFFFFFF
		    MyColors.Weekend = &cE6EDF7
		    MyColors.YBackground = FillColor
		    MyColors.OtherMonth = &cCEDBEF
		    
		    MyColors.PDayNumber = &c808080
		    MyColors.PDayNumberActive = &c3B3B3B
		    MyColors.PSelected = &cEEEEEE
		    MyColors.POver = &cEEEEEE
		    MyColors.PBackground = &cFFFFFF
		    MyColors.PArrow = &c0
		    MyStyle.PDayNumberBold = False
		    MyStyle.PLineHorizontal = LineNone
		    MyStyle.PLineVertical = LineNone
		    
		    MyStyle.WTodayHeader = False
		    MyStyle.WHeaderColorOffset = 0
		    MyStyle.WHeaderHeight = 0
		    MyStyle.WRoundRect = False
		    MyStyle.WHeaderTransparency = &c0
		    MyStyle.WBodyTransparency = &c0
		    MyStyle.WHeaderTextBold = True
		    MyStyle.WHeaderTextSize = 10
		    MyStyle.WHeaderTextFormat = "%Start - %End"
		    MyStyle.WTimeVOffset = 0
		    MyStyle.WTimeAlign = AlignLeft
		    MyStyle.WBodyTextBold = False
		    MyStyle.WBodyTextSize = 10
		    MyStyle.WBodyColorOffset1 = 60
		    MyStyle.WBodyColorOffset2 = 8
		    MyStyle.WEventFill = FillGradientVertical
		    MyStyle.WAutoTextColor = False
		    MyStyle.WTextColor = &c0
		    MyStyle.WHourLineStartX = TimeWidth
		    MyStyle.WHalfHourLineStyle = 0
		    MyStyle.WHalfHourColorOffset = &h49
		    MyColors.WDefaultColor = &c8DAED9
		    MyStyle.MColorOtherMonth = True
		    MyStyle.YLineHorizontal = LineThinSolid
		    MyStyle.YLineVertical = LineThinSolid
		    
		    MyStyle.PDayNamePos = 1
		    MyStyle.PDayNumberPos = 1
		    MyStyle.PDayNameBold = True
		    
		    
		  Elseif StyleType = StyleOutlook2013 Then
		    MyStyle.MDayTextBold = True
		    MyStyle.MDayTextColor = &c444444
		    MyStyle.MDayTransparent = False
		    MyStyle.MDayTransparency = &c0
		    MyStyle.MDayRoundRect = False
		    MyStyle.MEventHeight = 19
		    MyStyle.MEventTextSize = 10
		    MyStyle.MLeftOffset = 1
		    MyStyle.MTextOffset = 13
		    MyStyle.MHourBold = False
		    MyStyle.MTextBold = False
		    MyStyle.MDayNumberAlign = AlignLeft
		    MyStyle.MDayNameAlign = AlignLeft
		    MyStyle.MNumberXOffset = 9
		    MyStyle.MNumberYOffset = 5
		    MyStyle.MHasSelectedTextColor = True
		    MyColors.MSelectedText = &cFFFFFF
		    
		    If MyColors.MainColor = &c0 then
		      MyColors.MainColor = &c99C8E9
		    End If
		    
		    
		    MyStyle.WEventHeight = 19
		    MyStyle.MColorOffset1 = 52
		    MyStyle.MColorOffset2 = 8
		    MyStyle.MEventFill = FillOutlook2013
		    MyStyle.MBorderSolid = False
		    MyStyle.MDayNumberBackground = False
		    MyStyle.MFirstDayOfMonthName = True
		    MyStyle.MFirstDayOfMonthBold = True
		    
		    MyColors.WeekNumber = &c3B3B3B
		    MyColors.WeekNumberBackground = MyColors.MainColor
		    MyColors.Border = &cCCCCCC
		    MyColors.Line = &cE1E1E1
		    MyColors.Title = &c505050
		    MyColors.DayName = &c3B3B3B
		    MyColors.DayNumber = &c444444
		    MyColors.DayNumberActive = &c444444
		    MyColors.DayNumberBackground = &cCEDBEF
		    MyColors.Time = &c3B3B3B
		    MyColors.TimeBackground = &cFFFFFF
		    MyColors.Today = &cFFF8BF
		    MyColors.Header = &cA5BFE1
		    MyColors.Selected = &cFFF0F0
		    MyColors.WeekDay = &cFFFFFF
		    MyColors.Weekend = &cF2F2F2
		    MyColors.YBackground = FillColor
		    MyColors.OtherMonth = &cCEDBEF
		    
		    MyColors.PDayNumber = &c444444
		    MyColors.PDayNumberActive = &c444444
		    MyColors.PSelected = &cCDE6F7
		    MyColors.POver = &c0072C6
		    MyColors.PBackground = &cFFFFFF
		    MyColors.PArrow = &c444444
		    MyStyle.PDayNumberBold = False
		    MyStyle.PLineHorizontal = LineNone
		    MyStyle.PLineVertical = LineNone
		    MyColors.PDayNumberToday = &cFFFFFF
		    
		    MyColors.Today = MyColors.MainColor
		    MyColors.Selected = MyColors.MainColor
		    MyColors.Header = ShiftColor(MyColors.MainColor, MyStyle.MColorOffset1)
		    If ViewType = TypePicker then
		      MyColors.Today = &c0072C6
		      MyColors.Header = &cF0F0F0
		      HeaderHeight = 22
		    End If
		    
		    ColorWeekend = True
		    
		    Dim D As New Date
		    D.Hour = 1
		    If D.ShortTime.InStr("AM")>0 or ForceAM_PM then
		      MyStyle.WTimeFormat = "HH (A)"
		    else
		      MyStyle.WTimeFormat = "HH"
		    End If
		    MyStyle.WTodayHeader = True
		    MyStyle.WHeaderColorOffset = 0
		    MyStyle.WHeaderHeight = 0
		    MyStyle.WRoundRect = False
		    MyStyle.WHeaderTransparency = &c0
		    MyStyle.WBodyTransparency = &c0
		    MyStyle.WHeaderTextBold = True
		    MyStyle.WHeaderTextSize = 10
		    MyStyle.WHeaderTextFormat = ""
		    MyStyle.WTimeVOffset = 10
		    MyStyle.WTimeAlign = AlignLeft
		    MyStyle.WBodyTextBold = True
		    MyStyle.WBodyTextSize = 12
		    MyStyle.WBodyColorOffset1 = 60
		    MyStyle.WBodyColorOffset2 = 8
		    MyStyle.WEventFill = FillOutlook2013
		    MyStyle.WAutoTextColor = False
		    MyStyle.WTextColor = &c0
		    MyStyle.WHourLineStartX = 5
		    MyStyle.WHalfHourLineStyle = LineThinDotted
		    MyStyle.WHalfHourColorOffset = 0
		    MyColors.WDefaultColor = MyColors.MainColor
		    MyStyle.MColorOtherMonth = False
		    MyStyle.YLineHorizontal = LineThinSolid
		    MyStyle.YLineVertical = LineThinSolid
		    
		    MyStyle.PDayNamePos = 1
		    MyStyle.PDayNumberPos = 1
		    MyStyle.PDayNameBold = True
		    
		  End If
		  
		  #if TargetDesktop
		    FullRefresh = True
		    Me.Refresh(False)
		  #elseif TargetWeb
		    me.Redisplay()
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SetupCSS()
		  #if TargetWeb
		    'styles(0).value("visibility") = "visible" // Every WebSDK control needs this
		    
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetupLocaleInfo()
		  #if TargetWin32
		    
		    Dim i, ret As Integer
		    Dim retVal As String
		    Dim mb as new MemoryBlock( 2048 )
		    
		    //Day Names
		    Const LOCALE_SDAYNAME1 = 42'&h0000002A
		    Const LOCALE_SDAYNAME2 = &h0000002B
		    Const LOCALE_SDAYNAME3 = &h0000002C
		    Const LOCALE_SDAYNAME4 = &h0000002D
		    Const LOCALE_SDAYNAME5 = &h0000002E
		    Const LOCALE_SDAYNAME6 = &h0000002F
		    Const LOCALE_SDAYNAME7 = &h00000030
		    dim dayConst( 7 ) as Integer
		    dayConst = Array( LOCALE_SDAYNAME1, LOCALE_SDAYNAME2, LOCALE_SDAYNAME3, _
		    LOCALE_SDAYNAME4, LOCALE_SDAYNAME5, LOCALE_SDAYNAME6, LOCALE_SDAYNAME7 )
		    
		    for i = 0 to 6
		      ret = GetLocaleInfo( dayConst( i ), mb, retVal )
		      DayNames((i+1) mod 7 +1) = Titlecase ( ConvertEncoding(retVal, Encodings.UTF8) )
		    next
		    
		    //Month Names
		    Const LOCALE_SMONTHNAME1 = 56'&h00000038
		    Const LOCALE_SMONTHNAME2 = &h00000039
		    Const LOCALE_SMONTHNAME3 = &h0000003A
		    Const LOCALE_SMONTHNAME4 = &h0000003B
		    Const LOCALE_SMONTHNAME5 = &h0000003C
		    Const LOCALE_SMONTHNAME6 = &h0000003D
		    Const LOCALE_SMONTHNAME7 = &h0000003E
		    Const LOCALE_SMONTHNAME8 = &h0000003F
		    Const LOCALE_SMONTHNAME9 = &h00000040
		    Const LOCALE_SMONTHNAME10 = &h00000041
		    Const LOCALE_SMONTHNAME11 = &h00000042
		    Const LOCALE_SMONTHNAME12 = &h00000043
		    Const LOCALE_SMONTHNAME13 = &h0000100E
		    dim monthConst( 13 ) as Integer
		    monthConst = Array( LOCALE_SMONTHNAME1, LOCALE_SMONTHNAME2, LOCALE_SMONTHNAME3, _
		    LOCALE_SMONTHNAME4, LOCALE_SMONTHNAME5, LOCALE_SMONTHNAME6, LOCALE_SMONTHNAME7, _
		    LOCALE_SMONTHNAME8, LOCALE_SMONTHNAME9, LOCALE_SMONTHNAME10, LOCALE_SMONTHNAME11, _
		    LOCALE_SMONTHNAME12, LOCALE_SMONTHNAME13 )
		    
		    ReDim MonthNames(12)
		    for i = 0 to 11
		      ret = GetLocaleInfo( monthConst( i ), mb, retVal )
		      MonthNames(i+1) = Titlecase( ConvertEncoding(retVal, Encodings.UTF8) )
		    next
		    
		    //Day of Week
		    Const LOCALE_IFIRSTDAYOFWEEK  = &h100C
		    ret = GetLocaleInfo( LOCALE_IFIRSTDAYOFWEEK, mb, retVal )
		    FirstDayOfWeek = (Val( retVal ) + 1) mod 7 + 1
		    
		  #else
		    
		    Dim D As New Date
		    
		    For i as integer = 0 to 6
		      DayNames(D.DayOfWeek) = D.LongDate.NthField(" ", 1).Replace(",", "")
		      D.Day = D.Day + 1
		    Next
		    
		    D.Day = 1
		    D.Month = 1
		    Dim MonthField As Integer
		    If IsNumeric(D.LongDate.NthField(" ", 2)) then
		      MonthField = 3
		    else
		      MonthField = 2
		    End If
		    For i as Integer = 1 to 12
		      MonthNames(i) = TitleCase(D.LongDate.NthField(" ", MonthField)).Replace(",", "")
		      D.Month = D.Month + 1
		    Next
		    
		    FirstDayOfWeek = 1 //Sunday
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ShiftColor(C As Color, Percent As Single) As Color
		  If Percent = 0.0 then Return C
		  If Percent > 1 then
		    Percent = Percent /100
		  elseif Percent < -1 then
		    Percent = Percent / 100
		  End If
		  
		  If Percent > 0 then
		    Return RGB((255-C.Red)*Percent + C.Red, (255-C.Green)*Percent+C.Green, (255-C.Blue)*Percent + C.Blue)
		  else
		    Return RGB((1+Percent) * C.Red, (1+Percent) * C.Green, (1+Percent) * C.Blue)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1021
		Private Function ShiftColor2(c As Color, shiftValue As Integer) As Color
		  
		  Return RGB(c.Red + shiftValue, c.Green + shiftValue, c.Blue + shiftValue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SortEvents(FirstDate As Date, EndDate As Date, NoRedim As Boolean = False, OnePerDay As Boolean = False)
		  //Sorts all events
		  
		  Dim i, j As Integer
		  Dim u As Integer = UBound(Events)
		  Dim E As CalendarEvent
		  Dim RecurE() As CalendarEvent
		  
		  #if DebugBuild
		    Dim ms As Double = Microseconds
		  #endif
		  
		  If NoRedim = False then
		    Redim DisplayEvents(-1)
		  End If
		  
		  If FilterEvents then
		    For i = 0 to u
		      E = Events(i)
		      If (E.StartDate >= FirstDate and E.StartDate < EndDate) or _
		        ( E.StartDate < FirstDate and E.StartSeconds + E.Length >= FirstDate.TotalSeconds) then
		        If CalendarEventFilter(E) then
		          DisplayEvents.Append E
		          
		          If E.Recurrence <> Nil then
		            RecurE = CheckRecurringEvents(E, FirstDate, EndDate)
		            If RecurE is Nil then Continue
		            For j = 0 to UBound(RecurE)
		              DisplayEvents.Append RecurE(j)
		            Next
		          End If
		        End If
		        
		      Elseif E.Recurrence <> Nil and E.StartDate <= EndDate then
		        
		        RecurE = CheckRecurringEvents(E, FirstDate, EndDate)
		        If RecurE is Nil then Continue
		        For j = 0 to UBound(RecurE)
		          DisplayEvents.Append RecurE(j)
		        Next
		        
		      End If
		      
		    Next
		    
		  else //No filtering of Events
		    
		    For i = 0 to u
		      E = Events(i)
		      If (E.StartDate >= FirstDate and E.StartDate < EndDate) or _
		        E.StartDate < FirstDate and E.StartSeconds + E.Length >= FirstDate.TotalSeconds then
		        DisplayEvents.Append E
		        
		        If E.Recurrence <> Nil then
		          RecurE = CheckRecurringEvents(E, FirstDate, EndDate)
		          If RecurE = Nil then Continue
		          For j = 0 to UBound(RecurE)
		            DisplayEvents.Append RecurE(j)
		          Next
		        End If
		        
		      Elseif E.Recurrence <> Nil and E.StartDate.TotalSeconds <= EndDate.TotalSeconds then
		        RecurE = CheckRecurringEvents(E, FirstDate, EndDate)
		        If RecurE = Nil then Continue
		        For j = 0 to UBound(RecurE)
		          DisplayEvents.Append RecurE(j)
		        Next
		      End If
		    Next
		  End If
		  
		  
		  u = UBound(DisplayEvents)
		  
		  
		  
		  
		  If UBound(DisplayEvents) > 1 then
		    
		    CombSort(DisplayEvents)
		    
		  elseif UBound(DisplayEvents) = 1 then
		    //Insertion Sort
		    Dim temp As CalendarEvent
		    
		    temp = DisplayEvents(0)
		    If temp > DisplayEvents(1) then
		      DisplayEvents.Append temp
		      DisplayEvents.Remove(0)
		    End If
		  End If
		  
		  If OnePerDay then
		    For i = u downto 1
		      If DisplayEvents(i).EndSeconds < DisplayEvents(i-1).EndSeconds then
		        DisplayEvents.Remove(i)
		      elseif DisplayEvents(i).StartSeconds = DisplayEvents(i-1).StartSeconds then
		        DisplayEvents.Remove(i)
		      End If
		    Next
		  End If
		  
		  
		  
		  #if DebugBuild
		    ms = (Microseconds - ms) / 1000
		    DrawInfo = str(ms)
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function String2Color(str As String) As Color
		  If str.Left(2) = "&c" then
		    str = str.Mid(3)
		  End If
		  
		  If str.Left(1) = "#" then
		    str = str.Mid(2)
		  End If
		  
		  Dim v As Variant = "&h" + str
		  
		  Return v.ColorValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1021
		Private Sub TimerAction(t As Timer)
		  
		  If t is Nil then Return
		  
		  Dim D As New Date
		  Dim ReferencePeriod As Integer
		  #if TargetDesktop
		    ReferencePeriod = 5000
		  #elseif TargetWeb
		    ReferencePeriod = 30000
		  #endif
		  
		  
		  If HideScrollbar then
		    ShowScrollBar = False
		    HideScrollbar = False
		  End If
		  
		  If t.Period < ReferencePeriod then
		    t.Period = ReferencePeriod
		    #if TargetDesktop
		      FullRefresh = True
		      Refresh(False)
		    #elseif TargetWeb
		      Redisplay()
		    #endif
		    
		    Return
		  End If
		  
		  If mViewType = TypeMonth then
		    If Today.Day <> D.Day then
		      Today = New Date
		      'MethodProfiler.LogMsg("RefreshTimer")
		      #if TargetDesktop
		        Refresh(False)
		      #elseif TargetWeb
		        Redisplay()
		      #endif
		    End If
		  elseif mViewType > TypeMonth then
		    If Today.Minute <> D.Minute then
		      Today = New Date
		      #if TargetDesktop
		        Refresh(False)
		      #elseif TargetWeb
		        Redisplay()
		      #endif
		    End If
		    
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function VDate2SQLDate(VDate As String) As Date
		  
		  
		  Dim D As New Date
		  Dim GMTOffset As Integer = D.GMTOffset
		  If VDate.Right(1) = "Z" then
		    D.GMTOffset = 0
		  End If
		  
		  D.Hour = 0
		  D.Minute = 0
		  D.Second = 0
		  
		  D.Year = val(Left(VDate, 4))
		  D.Month = val(Mid(VDate, 5, 2))
		  D.Day = val(Mid(VDate, 7, 2))
		  
		  D.Hour = val(Mid(VDate, 10, 2))
		  D.Minute = val(Mid(VDate, 12, 2))
		  D.Second = val(Mid(VDate, 14, 2))
		  
		  D.GMTOffset = GMTOffset
		  
		  Return D
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ViewChanged()
		  Dim lastFirstDate, lastLastDate As Date
		  
		  lastFirstDate = New Date(mFirstDate)
		  lastLastDate = New Date(mLastDate)
		  
		  
		  mFirstDate = Nil
		  mLastDate = Nil
		  
		  If LastDate <> Nil and FirstDate <> Nil and (lastFirstDate.TotalSeconds <> FirstDate.TotalSeconds or lastLastDate.TotalSeconds <> LastDate.TotalSeconds) then
		    
		    If ViewType = TypeYear then
		      Redim DayColor(366)
		    End If
		    
		    Redim DisplayEvents(-1)
		    MonthsPopup.Visible = False
		    MoreEventsDate = Nil
		    
		    EraseBuffers()
		    
		    RaiseEvent ViewChange(FirstDate, LastDate)
		    
		  End If
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event CalendarEventFilter(cEvent As CalendarEvent) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Close()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DateSelected(D As Date)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DoubleClick(X As Integer, Y As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DragEvent(cEvent As CalendarEvent)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event EditEvent(cEvent As CalendarEvent) As CalendarEvent
	#tag EndHook

	#tag Hook, Flags = &h0
		Event EditOrDeleteRecurrentEvent(cEvent As CalendarEvent) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event EventClicked(cEvent As CalendarEvent)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event KeyDown(Key As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event MouseWheel(X As Integer, Y As Integer, DeltaX As Integer, DeltaY As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event NewEvent(StartDate As Date, EndDate As Date)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Open()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ShowHelptag(Str As String, cEvent As CalendarEvent) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ShowMoreEvents(D As Date) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TimeGutterClick(ClickDate As Date)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ViewChange(StartDate As Date, EndDate As Date)
	#tag EndHook


	#tag Note, Name = Class Constants
		===Style===
		The following class constants are to be used to specify the Style to use with SetStyle function.
		
		<table width="15;55">
		Class Constant->Description
		StyleDefault->The default style.
		StyleICal->Macintosh iCal style.
		StyleGoogle->Google Calendar style.
		StyleDark->A dark style (black, grey and green).
		StyleOutlook2010->Office Outlook 2010 style.
		StyleOutlook2013->Office Outlook 2013 (beta) style.
		</table>
		
		===ViewType===
		The following class constants are to be used with the ViewType property.
		
		<table width="15;55">
		Class Constant->Description
		TypePicker->Displays a DatePicker.
		TypeYear->Displays a whole year.
		TypeMonth->Displays a Month calendar.
		TypeWeek->Displays a full week.
		TypeDay->Displays one day.
		TypeOther->Use the ViewDays property to set the amount of days to display. If ViewDays=5 days from Monday to Friday are displayed.
		</table>
		
	#tag EndNote

	#tag Note, Name = Description
		Displays a Calendar in several formats (Year, Month, Week, Day, ...) that presents CalendarEvents.<br/>
		This custom control based on a Canvas is similar to iCal on Mac OS and Google Calendar.
	#tag EndNote

	#tag Note, Name = Events
		==CalendarEventFilter==
		newinversion 1.4.0
		Fires if FilterEvents is True.<br>
		Return True from this Event if the passed CalendarEvent must be displayed.<br>
		Filtering events can be done on the Name, the Tag, the Color and any other relevant Property of the CalendarEvent class.
		
		==DateSelected==
		A date has been selected with the mouse.
		
		==DragEvent==
		A CalendarEvent is being dragged.
		
		==EditEvent==
		A CalendarEvent has been double-clicked in order to edit it.
		Editing a CalendarEvent must be handled here. If Nil is returned the CalendarEvent is not changed.
		
		Deleting an event can be handled here by calling:
		<source>
		me.RemoveEvent(cEvent, True)
		Return Nil
		</source>
		
		==NewEvent==
		Adding a CalendarEvent by dragging the mouse must be handled here.
		
		Example:
		<source>
		me.AddEvent( New CalendarEvent("New meeting", StartDate, EndDate)
		</source>
		
		==Open==
		The window is about to open.
		
		==ShowHelptag==
		Enables displaying a custom HelpTag.<br/>
		If True is returned, the system HelpTag is completely bypassed.
		
		==ViewChange==
		The current view has changed.
		StartDate and EndDate represent the date range that is currently displayed.
		Use me.ViewType to retrieve the current view (Picker, Year, Month, Week, Day ...)
		
		==ConstructContextualMenu==
		newinversion 1.1.1
		This event is called when it is appropriate to display a contextual menu for the control.
		
		If you return True, the contextual menu is displayed. The parameters ''x'' and ''y'' are the mouse locations.
		If the event was fired because of a non-mouse event, then x and y are both set to -1.
		If the mouse is over a CalendarEvent when this event is fired, ''cEvent'' hovered CalendarEvent.
	#tag EndNote

	#tag Note, Name = External Links
		Download page:
		http://www.jeremieleroy.com/products.php
	#tag EndNote

	#tag Note, Name = History
		===Version 1.7.0 - Not Released ===
		*New:
		**Compatible with WebApps
		**MonthView: Clicking on the +#, displays a popup with all events of the Day
		*Fix:
		**Better Retina graphics on MacOS compatible devices
		**Event Title is now displayed on events lasting more than a week
		**Repeat Relative monthly is now calculated, exported and imported correctly
		**Crash when dragging an event ouf the CalendarView
		**All events now display correctly when dragging an event in MonthView
		
		===Version 1.6.2 - Not Released ===
		*New:
		*Fix:
		**DrawEventWeek could crash with negative event width.
		**DatePicker reacting to MouseDown instead of MouseUp
		
		===Version 1.6.1 - 2014-06-08 ===
		*New:
		**Improved performance for large amount of CalendarEvents.
		**RemoveEventByID function.
		*Fix:
		**Day name display in Month view was shifted by one day.
		
		===Version 1.6.0 - Released 2014-03-21 ===
		*New:
		**Compatible with Retina displays, the text now looks perfect
		**Recurrent events
		**Date Picker
		**Improved CalendarEvent edit window
		
		
		===Version 1.5.0 - Not released ===
		*New:
		**Changed the DoubleClick event. Return True if you handled the double-click.
		**Improved Reading of ICS (iCal) data
		
		===Version 1.4.1 - Released 2013-06-01 ===
		*New:
		**DayGradient property
		**When creating a new CalendarEvent, a "Cancel" button appears to cancel the creation of the CalendarEvent.
		
		
		===Version 1.4.0 - Released 2013-05-30 ===
		*New:
		**Search function
		**FocusOn function to go to the date of the passed Event.
		**FilterEvents property. If True, the CalendarEventFilter is fired for each event before displaying it.
		**CalendarEventFilter event. Return True if the event should be displayed.
		*Fix:
		**Events not displaying in Week view.
		**Events appearing twice in Week view.
		**Improved drawing performance.
		**Pressing a key used to scroll down. Now only the down arrow scrolls down.
		
		===Version 1.3.1 - Released 2012-11-24 ===
		*New:
		**PrintSimple and PrintAdvanced functions
		**Freeze property to prevent any refresh
		**YearMultipleEvents to display all event colors for each day
		*Fix:
		**WeekHeaderTextFormat doesn't display spaces in the day and MonthNames on Windows
		**Drawing error in MonthView for Sunday
		**Drawing error in MonthView for very long events
		
		===Version 1.2.2 - Released 2012-09-06 ===
		*New:
		**ShowHelptag event. Enables using custom HelpTags or disabling the HelpTag by returning True
		**CalendarEvent now has a Tag property
		*Fix:
		**HelpTag is now displayed in Week and Day view
		**Various demo window fixes
		
		===Version 1.2.1 - Released 2012-08-29 ===
		*New:
		**Double-click on day in Month view changes to week view
		**Scrollwheel / Trackpad can be disabled horizontally
		**TextFont property to change the font of all text in the CalendarView
		**Several TextSize properties in the Style structure.
		*Fix:
		**Events not displaying in 1 day view
		
		===Version 1.2 - Released 2012-08-21 ===
		*New:
		**Adapted display for Retina Macs (not tested on actual Retina Mac)
		**Keyboard arrows to scroll
		**ConstructContextualMenu event has a parameter for the clicked CalendarEvent
		**Edit the CalendarEvent time directly from the EditEvent window
		**Each CalendarEvent has an [[CalendarEvent.Editable|Editable]] property
		**HelpTagFormat property
		**DayEvent display height in Week view can be dragged ([[DayEventsHeight]])
		**StyleOutlook2013 constant
		**Style updates
		**Time format in week view can be edited
		
		*Fix
		**Fixed RemoveEvent bug that deleted the first event with the same date and length
		**Time bar not refreshing properly
		**Simultaneous events do not overlap in Week view (limited to 10 simultaneous events)
		
		===Version 1.1 - Released 2012-05-02===
		*New:
		**TypePicker constant
		**SelStart, SelEnd to set the selected dates in the CalendarPicker
		**DayStartHour, DayEndHour
		**ForceAM_PM
		**Style Property
		**StyleOutlook2010 constant
		**WeekHeaderTextFormat
		**Animate
		
		*Fix:
		**Several graphic enhancements
		**Colors in StyleDark
		**Day names on Mac OS
		
		
		===Version 1.0.3 - Released 2012-04-11===
		*New:
		**StyleDefault, StyleICal, StyleGoogle, StyleDark class constants
		**ImportFromDB function
		**ExportToDB function
		**RemoveEvent now has a RemoveFromDB property.
		
		*Fix:
		**CalendarView not updating after AddEvent
		
		
		
		===Version 1.0.2 - Released 2012-04-03===
		*New:
		**StyleDark
		**DisableDrag is replaced with DragEvents and CreateWithDrag
		
		*Fix:
		**Day background color not filling the box in TypeMonth
		**Time background color not displaying in TypeWeek
		**Resizing event to make a 15 minute event in TypeWeek
		**TypeYear not displaying non**day events
		**OutOfBoundsException in DrawTime on Mac OS
		**Drawing long event in TypeMonth that finishes on last day of week
		
		
		
		===Version 1.0.1 - Released 2012-04-02===
		*New:
		**DisplayWeeknumber As Boolean
		**MyColors.WeekNumber
		**MyColors.WeekNumberBackground
		**Day name is displayed inside the month grid for iCal style.
		**Drag events in Month and Week view to change start date/time
		**Resize event in TypeWeek
		**HeatMap in TypeYear
		**SetLength Function in CalendarEvent
		**VerticalGap and HorizontalGap properties for TypeYear
		**New Event "DragEvent". Fires when a CalendarEvent is dragged or resized
		
		*Fix:
		**Selected background color in month view if MyStyle.MDayNumberAlign=1
		**Day events in TypeWeek not aligned properly
		
		
		
		
		===Version 1.0.0 - Released 2012-03-30===
		First release
	#tag EndNote

	#tag Note, Name = See Also
		 Class.
		[[CalendarEvent]]
	#tag EndNote

	#tag Note, Name = ToDo list
		#Ignore in LR
		
		Month view
		-Setting for Month title position in Month view
		-Select element and delete it with Backspace or Delete ??
		
		Week view
		-limit amount of day events
		-Force AM/PM
		-DayStart time
		-DayEnd time
		-> NightColor
		-minHourHeight <-> DisplayXXHours
		
		Year view
		-Double click on month to display it in month view
		-Color days with amount of events per day (Yellow to red)
		
		
		From MC8sens:
		-drag an event, then tap arrow on keyboard, the event disappears until you move the mouse.
		-Modify dates with a date picker in the EditEvent window.
		-Delete button becomes "Cancel" when creating an event.
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Note
			If True, in ViewType Month and Picker, the CalendarView will automatically calculate how many weeks are needed to display the whole month.
			If False, 6 weeks will always be displayed.
		#tag EndNote
		#tag Getter
			Get
			  return mAdaptWeeksPerMonth
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mAdaptWeeksPerMonth = value
			  
			  ViewChanged
			  
			  Redisplay()
			End Set
		#tag EndSetter
		AdaptWeeksPerMonth As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			If True there is a smooth animation when using the Scroll function.
		#tag EndNote
		Animate As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected AnimationInProgress As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			If true a Border is displayed around the CalendarView.
			The default value is False.
		#tag EndNote
		Border As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Picture on which is drawn all graphics
		#tag EndNote
		Protected Buffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			If True, the Weekend will be colored with MyColors.Weekend color.
		#tag EndNote
		ColorWeekend As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			If True, the user can create a CalendarEvent by dragging the mouse.
		#tag EndNote
		CreateWithDrag As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Color for each day used in ViewType = TypeYear only.
		#tag EndNote
		Protected DayColor() As CalendarYearColors
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			If this property is different than 0.0, the remaining hours from DayEndHour to midnight will be darkened.
			The default value is 18.0
			
			==Example==
			This example sets the DayEndHour to 18:45.
			<source>
			me.DayEndHour=18.75
			</source>
		#tag EndNote
		DayEndHour As Single
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DayEventClicked As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			newinversion 1.2.0
			If the value is -1 the height is automatically calculated depending on the amount of day events.
		#tag EndNote
		Private DayEventsHeight As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The names of each day of Week, starting by Sunday.
			DayNames(1) = Sunday
			DayNames(7) = Saturday
		#tag EndNote
		Shared DayNames(7) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			If this property is different than 0.0, the hours from midnight to DayStartHour will be darkened.
			The default value is 6.0
			
			==Example==
			This example sets the DayStartHour to 8 AM.
			<source>
			me.DayStartHour=8.0
			</source>
		#tag EndNote
		DayStartHour As Single
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 486F6C647320616C6C2043616C656E6461724576656E7420494473207468617420776572652064656C657465642E
		DeletedIDs() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.2.1
			If True, scrolling with the mousewheel or trackpad is disabled for changing the current display date.
			
			However, scrolling the hours in Week/Day view will never be disabled.
		#tag EndNote
		DisableScroll As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			The currently displayed Date.
			Change the DisplayDate to change the current view.
			
			==Notes==
			If you assign a date using
			<source lang="realbasic">
			me.DisplayDate = aDate
			</source>
			There is no need to refresh the CalendarView to show the selected date.
			
			However if you alter DisplayDate without assigning it a value, the CalendarView needs to be refreshed:
			<source lang="realbasic">
			//Change the month to December
			me.DisplayDate.Month = 12
			me.Redisplay() //This refreshes the CalendarView
			</source>
		#tag EndNote
		#tag Getter
			Get
			  return mDisplayDate
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  If mDisplayDate <> Nil and value.SQLDate = mDisplayDate.SQLDate then
			    Return
			  End If
			  
			  If Value is Nil then
			    value = New Date
			  End If
			  
			  mDisplayDate = New Date(value)
			  
			  ViewChanged
			  
			  Redisplay()
			End Set
		#tag EndSetter
		DisplayDate As Date
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected DisplayEvents() As CalendarEvent
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			If True, the week numbers are displayed in Month view, Week view and Day view.
		#tag EndNote
		DisplayWeeknumber As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DragBack As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DragEvent As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			If True, CalendarEvent items can be dragged with the mouse to alter the date or start time.
		#tag EndNote
		DragEvents As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DragOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DragViewHeight As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DrawInfo As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DropObject As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Events() As CalendarEvent
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Set to True when all events are sorted.
			Set to false after loading events, creating an event, dragging an event.
		#tag EndNote
		Protected EventsSorted As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			#newinversion 1.4.0
			
			If True, before refreshing the display, the CalendarView fires the CalendarEventFilter Event 
		#tag EndNote
		FilterEvents As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			The first date displayed in the CalendarView.
		#tag EndNote
		#tag Getter
			Get
			  
			  If mFirstDate is Nil then
			    
			    If DisplayDate is Nil then Return Nil
			    
			    If ViewType = TypeYear then
			      mFirstDate = New Date(DisplayDate)
			      mFirstDate.Day = 1
			      mFirstDate.Month = 1
			      mFirstDate.Hour = 0
			      mFirstDate.Minute = 0
			      mFirstDate.Second = 0
			      
			    ElseIf ViewType = TypeMonth or ViewType = TypePicker then
			      mFirstDate = New Date
			      If ViewType = TypeMonth then
			        mFirstDate.TotalSeconds = DisplayDate.TotalSeconds
			      else
			        mFirstDate.TotalSeconds = DisplayDate.TotalSeconds
			      End If
			      mFirstDate.Day = 1
			      mFirstDate.Hour = 0
			      mFirstDate.Minute = 0
			      mFirstDate.Second = 0
			      If AdaptWeeksPerMonth then
			        
			        If mFirstDate.DayOfWeek - FirstDayOfWeek < 0 then
			          mFirstDate.Day = mFirstDate.Day - (mFirstDate.DayOfWeek - FirstDayOfWeek) - 7
			        else
			          mFirstDate.Day = mFirstDate.Day - (mFirstDate.DayOfWeek - FirstDayOfWeek)
			        End If
			        
			      else
			        
			        WeeksPerMonth = 6
			        
			        If mFirstDate.DayOfWeek - FirstDayOfWeek <= 0 then
			          mFirstDate.Day = mFirstDate.Day - (mFirstDate.DayOfWeek - FirstDayOfWeek) - 7
			        else
			          mFirstDate.Day = mFirstDate.Day - (mFirstDate.DayOfWeek - FirstDayOfWeek)
			        End If
			      End If
			      
			    else
			      
			      mFirstDate = New Date
			      mFirstDate.TotalSeconds = DisplayDate.TotalSeconds
			      
			      
			      If ViewType = TypeWeek then
			        ViewDays = 7
			        
			        If mFirstDate.DayOfWeek - FirstDayOfWeek < 0 then
			          mFirstDate.Day = mFirstDate.Day - (mFirstDate.DayOfWeek - FirstDayOfWeek) - 7
			        else
			          mFirstDate.Day = mFirstDate.Day - (mFirstDate.DayOfWeek - FirstDayOfWeek)
			        End If
			        
			      elseif ViewType = TypeDay then
			        //nothing
			      elseif ViewType = TypeOther then
			        If ViewDays = 5 then
			          mFirstDate.Day = mFirstDate.Day - mFirstDate.DayOfWeek+2
			        elseIf ViewDays > 2 then
			          mFirstDate.Day = mFirstDate.Day - 1
			        End If
			      End If
			      
			      mFirstDate.Hour = 0
			      mFirstDate.Minute = 0
			      mFirstDate.Second = 0
			      
			    End If
			  End If
			  
			  return New Date(mFirstDate)
			End Get
		#tag EndGetter
		FirstDate As Date
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			The first day of week displayed in the CalendarView.
			1 = Sunday
			7 = Saturday
		#tag EndNote
		#tag Getter
			Get
			  return mFirstDayOfWeek
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mFirstDayOfWeek = value
			  
			  ViewChanged
			  
			  Redisplay()
			End Set
		#tag EndSetter
		FirstDayOfWeek As Byte
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			If True, Hours in Week view and Day view will always be displayed with AM and PM.
			If False, the CalendarView tries to get the system default's hour format.
		#tag EndNote
		ForceAM_PM As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			
			snt the CalendarView from refreshing the display.
		#tag EndNote
		Freeze As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected FullRefresh As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HeaderHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HeaderHeightHTML As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.2.0
			Use this property to edit the format of the HelpTag.
			
			<table width="15;55">
			Variable->Description
			%Start->StartDate
			%End->EndDate
			%Length->Event duration
			%Title->Event title
			%Location->Event location
			%Description->Event description
			</table>
			
			
			Default format is:
			%Start - %End<br/>
			%Title - %Location
		#tag EndNote
		HelpTagFormat As String
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			#newinversion: 1.5.0
			
			If True, all hours between DayEndHour and DayStartHour won't be displayed.<br>
			This enables optimizing the view for the Day time / open hours.
		#tag EndNote
		Protected HideNightTime As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HideScrollbar As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			#newinversion 1.4
			If True, the picLockedEvents picture is displayed all non editable CalendarEvent.
		#tag EndNote
		HighlightLockedEvents As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected HourHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastAutoScroll As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			The last date displayed in the CalendarView.
		#tag EndNote
		#tag Getter
			Get
			  If mLastDate is Nil then
			    
			    If DisplayDate is Nil then Return Nil
			    
			    If ViewType = TypeYear then
			      mLastDate = New Date(DisplayDate)
			      mLastDate.Month = 12
			      mLastDate.Day = 31
			      mLastDate.Hour = 0
			      mLastDate.Minute = 0
			      mLastDate.Second = 0
			      mLastDate.Day = mLastDate.Day + 1
			      mLastDate.Second = mLastDate.Second - 1
			      
			    elseIf ViewType = TypeMonth or ViewType = TypePicker then
			      
			      If AdaptWeeksPerMonth then
			        If ViewType = TypeMonth then
			          mLastDate = New Date(DisplayDate)
			        else
			          mLastDate = New Date(DisplayDate)
			        End If
			        mLastDate.Day = 1
			        mLastDate.Month = mLastDate.Month + 1
			        mLastDate.Day = mLastDate.Day - 1
			        mLastDate.Hour = 0
			        mLastDate.Minute  =0
			        mLastDate.Second = 0
			        
			        WeeksPerMonth = Ceil((mLastDate.TotalSeconds - FirstDate.TotalSeconds + 86400) / 604800)
			        
			        mLastDate.TotalSeconds = FirstDate.TotalSeconds
			        mLastDate.Day = mLastDate.Day + WeeksPerMonth * 7
			      else
			        WeeksPerMonth = 6
			        mLastDate = New Date( FirstDate)
			        mLastDate.Day = mLastDate.Day + 42
			        
			        
			      End If
			      mLastDate.Second = mLastDate.Second - 1
			      
			    else
			      mLastDate = New Date(FirstDate)
			      
			      If ViewType = TypeWeek then
			        mLastDate.Day = mLastDate.Day + 6
			      elseif ViewType = TypeDay then
			        //nothing
			      elseif ViewType = TypeOther then
			        If ViewDays > 2 then
			          mLastDate.Day = FirstDate.Day + ViewDays-1
			        else
			          mLastDate.Day = mLastDate.Day + ViewDays-1
			        End If
			      End If
			      
			      mLastDate.Hour = 0
			      mLastDate.Minute = 0
			      mLastDate.Second = 0
			      mLastDate.Day = mLastDate.Day + 1
			      mLastDate.Second = mLastDate.Second - 1
			      
			      
			    End If
			  End If
			  
			  
			  
			  
			  return New Date(mLastDate)
			End Get
		#tag EndGetter
		LastDate As Date
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected LastDayOver As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			Used in TargetWeb to simulate long press.
		#tag EndNote
		Protected lastMouseDown As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected LastMouseOver As CalendarEvent
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			The last result when searching.
			If SortEvents is called again, this goes back to Nil.
		#tag EndNote
		Protected LastSearchResult As CalendarEvent
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastToday As Date
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastX As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastY As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected LoaderVisible As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.2.0
			If True, in Week view, the Day event display's height is fixed.
			
			If false, the user can drag the day event Separator.
		#tag EndNote
		LockDayEventsHeight As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mAdaptWeeksPerMonth As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MaxReccurenceID As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDisplayDate As Date
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDisplayMonth As Date
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFirstDate As Date
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFirstDayOfWeek As Byte
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHiDPI As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			The minimum horizontal Gap in pixels between months in Year view.
		#tag EndNote
		minHGap As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mminHourHeight
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mminHourHeight = value
			  EraseBuffers()
			  Redisplay
			End Set
		#tag EndSetter
		minHourHeight As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		#tag Note
			The minimum vertical Gap in pixels between months in Year view.
		#tag EndNote
		minVGap As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastDate As Date
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			The minimum hour height in pixels for Week and Day view.
		#tag EndNote
		Private mminHourHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Month names from MonthNames(1)=January to MonthNames(12)=December.
			
			On Windows, the MonthNames are automatically retrieved.
			On Macintosh and Linux, the CalendarView will try to retrieve the MonthNames using Date.LongDate.
		#tag EndNote
		MonthNames(12) As String
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			If True, a MonthPopup is displayed for the MoreEventsDate.
		#tag EndNote
		Protected MonthsPopup As MonthPopup
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected MoreEventsDate As Date
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected MouseDownOK As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MovingScrollBar As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollPosition As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mViewType As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Set of Colors used in the CalendarView.
			By using SetStyle method, the colors are changed.
		#tag EndNote
		MyColors As Colors
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mYearHeatMap As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mYearMonthsAmount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			If True, in ViewType = TypeYear, if the day has multiple event colors, all colors will be displayed for that day instead of only the first one.
			
			Note that if YearHeatMap is True, this option has no effect.
		#tag EndNote
		Private mYearMultipleEvents As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mYearPicker As Variant
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected myPicture As WebPicture
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Set of Styles used in the CalendarView.
			By using SetStyle method, the style is changed.
		#tag EndNote
		MyStyle As Styles
	#tag EndProperty

	#tag Property, Flags = &h21
		Private oktobreak As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private oldBuffer As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared picAjaxLoader As WebFile
	#tag EndProperty

	#tag Property, Flags = &h0
		Shared picCloseMonthPopup As Picture
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected PickerView As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			#newinversion 1.4
			This picture is displayed over all Day events if HighlightLockedEvents is True.<br/>
			A Masked picture that is tiled over non Editable events.
		#tag EndNote
		Shared picLockedEvents As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private RefreshTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ScrollBarHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ScrollBarWidth As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			Vertical ScrollPosition used in Week and Day view.
		#tag EndNote
		#tag Getter
			Get
			  return mScrollPosition
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  value = max(0, min(VisibleHours, value))
			  
			  
			  If value = mScrollPosition then Return
			  
			  mScrollPosition = value
			  
			  Redisplay
			End Set
		#tag EndSetter
		ScrollPosition As Double
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			Selection end date.
		#tag EndNote
		SelEnd As Date
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			Selection start Date.
		#tag EndNote
		SelStart As Date
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ShowScrollBar As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mStyle
			End Get
		#tag EndGetter
		StyleType As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.2.1
			The text font to use for all texts in the CalendarView.
		#tag EndNote
		TextFont As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected TimeWidth As Byte
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected tLoader As Timer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Today As Date
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			#newinversion 1.4.1
			
			If True, the background of the CalendarView is transparent. The background area depends on the current View (Year, Month, Week, Picker...)
		#tag EndNote
		TransparentBackground As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			Amount of days to display for ViewType = TypeOther.
		#tag EndNote
		ViewDays As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected ViewHeight As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			Use this property to get or set the type of view currently displayed:
			Picker, Year, Month, Week, Day...
		#tag EndNote
		#tag Getter
			Get
			  return mViewType
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If mViewType <> value then
			    mViewType = value
			    
			    If value = TypeWeek then
			      ViewDays = 7
			    elseif value = TypeDay then
			      ViewDays = 1
			    End If
			    
			    ViewChanged
			    
			    Redisplay
			  End If
			End Set
		#tag EndSetter
		ViewType As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If HideNightTime = False then
			    Return 24
			    
			  else
			    Return DayEndHour-DayStartHour + 2
			  End If
			End Get
		#tag EndGetter
		VisibleHours As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		#tag Note
			newinversion 1.1.0
			Date format to display over each day in Week and Day view.
			
			This string property takes the same format parameters as the PHP Date function:
			http://php.net/manual/en/function.date.php
			
			If a character needs to be escaped, a backslash "\" can be used.
			
			==Examples==
			
			<source>
			//Tuesday 08, February
			me.WeekHeaderTextFormat = "l d, F"
			
			//Feb. 8
			me.WeekHeaderTextFormat = "M. j"
			</source>
		#tag EndNote
		WeekHeaderTextFormat As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected WeeksPerMonth As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			If True, the Year view will display a "heat map" from yellow to red depending on how many [[CalendarEvent|CalendarEvents]] are on each day.
		#tag EndNote
		#tag Getter
			Get
			  return mYearHeatMap
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mYearHeatMap = value
			  
			  Redim DisplayEvents(-1)
			  Redisplay
			End Set
		#tag EndSetter
		YearHeatMap As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Note
			//#newinversion 1.6.1
			Sets the amount of Months to display in YearView.
			
			Minimum is 1, maximum is 12.<br/>
			Default is 12.
		#tag EndNote
		#tag Getter
			Get
			  If mYearMonthsAmount <=0 then
			    mYearMonthsAmount = 12
			  End If
			  
			  return mYearMonthsAmount
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  If value <= 0 then
			    mYearMonthsAmount = 12
			  else
			    mYearMonthsAmount = value
			  End If
			  
			  ViewChanged
			  
			  Redisplay()
			End Set
		#tag EndSetter
		YearMonthsAmount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mYearMultipleEvents
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mYearMultipleEvents = value
			  
			  Redim DisplayEvents(-1)
			  Redisplay
			End Set
		#tag EndSetter
		YearMultipleEvents As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = AlignCenter, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = AlignLeft, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = AlignRight, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = DragMove, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = DragResize, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = DragView, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = FillGradientHorizontal, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FillGradientVertical, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FillOutlook2013, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FillSolid, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = JavascriptNamespace, Type = String, Dynamic = False, Default = \"jly.WebCalendarView", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOpenSource, Type = Boolean, Dynamic = False, Default = \"True", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kpicAjaxLoader, Type = String, Dynamic = False, Default = \"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\nCwg1RAAAOwAAAAAAAAAAAA\x3D\x3D", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPicCloseMonthPopup, Type = String, Dynamic = False, Default = \"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAEJGlDQ1BJQ0MgUHJvZmlsZQAAOBGFVd9v21QUPolvUqQWPyBYR4eKxa9VU1u5GxqtxgZJk6XtShal6dgqJOQ6N4mpGwfb6baqT3uBNwb8AUDZAw9IPCENBmJ72fbAtElThyqqSUh76MQPISbtBVXhu3ZiJ1PEXPX6yznfOec7517bRD1fabWaGVWIlquunc8klZOnFpSeTYrSs9RLA9Sr6U4tkcvNEi7BFffO6+EdigjL7ZHu/k72I796i9zRiSJPwG4VHX0Z+AxRzNRrtksUvwf7+Gm3BtzzHPDTNgQCqwKXfZwSeNHHJz1OIT8JjtAq6xWtCLwGPLzYZi+3YV8DGMiT4VVuG7oiZpGzrZJhcs/hL49xtzH/Dy6bdfTsXYNY+5yluWO4D4neK/ZUvok/17X0HPBLsF+vuUlhfwX4j/rSfAJ4H1H0qZJ9dN7nR19frRTeBt4Fe9FwpwtN+2p1MXscGLHR9SXrmMgjONd1ZxKzpBeA71b4tNhj6JGoyFNp4GHgwUp9qplfmnFW5oTdy7NamcwCI49kv6fN5IAHgD+0rbyoBc3SOjczohbyS1drbq6pQdqumllRC/0ymTtej8gpbbuVwpQfyw66dqEZyxZKxtHpJn+tZnpnEdrYBbueF9qQn93S7HQGGHnYP7w6L+YGHNtd1FJitqPAR+hERCNOFi1i1alKO6RQnjKUxL1GNjwlMsiEhcPLYTEiT9ISbN15OY/jx4SMshe9LaJRpTvHr3C/ybFYP1PZAfwfYrPsMBtnE6SwN9ib7AhLwTrBDgUKcm06FSrTfSj187xPdVQWOk5Q8vxAfSiIUc7Z7xr6zY/+hpqwSyv0I0/QMTRb7RMgBxNodTfSPqdraz/sDjzKBrv4zu2+a2t0/HHzjd2Lbcc2sG7GtsL42K+xLfxtUgI7YHqKlqHK8HbCCXgjHT1cAdMlDetv4FnQ2lLasaOl6vmB0CMmwT/IPszSueHQqv6i/qluqF+oF9TfO2qEGTumJH0qfSv9KH0nfS/9TIp0Wboi/SRdlb6RLgU5u++9nyXYe69fYRPdil1o1WufNSdTTsp75BfllPy8/LI8G7AUuV8ek6fkvfDsCfbNDP0dvRh0CrNqTbV7LfEEGDQPJQadBtfGVMWEq3QWWdufk6ZSNsjG2PQjp3ZcnOWWing6noonSInvi0/Ex+IzAreevPhe+CawpgP1/pMTMDo64G0sTCXIM+KdOnFWRfQKdJvQzV1+Bt8OokmrdtY2yhVX2a+qrykJfMq4Ml3VR4cVzTQVz+UoNne4vcKLoyS+gyKO6EHe+75Fdt0Mbe5bRIf/wjvrVmhbqBN97RD1vxrahvBOfOYzoosH9bq94uejSOQGkVM6sN/7HelL4t10t9F4gPdVzydEOx83Gv+uNxo7XyL/FtFl8z9ZAHF4bBsrEwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAFZJREFUKBW9jlEOADAEQ223dgLH3tKPiiH72yRC6lEi38LMFjIbZn12ALXuwOAQtQOgq6pz3mCAyEsRxry8BPEWh0O+zsXo4gsRJtBp5SXCuB57ur2vGx8QJltMxO09AAAAAElFTkSuQmCC", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPicLockedEvents, Type = String, Dynamic = False, Default = \"iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAEJGlDQ1BJQ0MgUHJvZmlsZQAAOBGFVd9v21QUPolvUqQWPyBYR4eKxa9VU1u5GxqtxgZJk6XtShal6dgqJOQ6N4mpGwfb6baqT3uBNwb8AUDZAw9IPCENBmJ72fbAtElThyqqSUh76MQPISbtBVXhu3ZiJ1PEXPX6yznfOec7517bRD1fabWaGVWIlquunc8klZOnFpSeTYrSs9RLA9Sr6U4tkcvNEi7BFffO6+EdigjL7ZHu/k72I796i9zRiSJPwG4VHX0Z+AxRzNRrtksUvwf7+Gm3BtzzHPDTNgQCqwKXfZwSeNHHJz1OIT8JjtAq6xWtCLwGPLzYZi+3YV8DGMiT4VVuG7oiZpGzrZJhcs/hL49xtzH/Dy6bdfTsXYNY+5yluWO4D4neK/ZUvok/17X0HPBLsF+vuUlhfwX4j/rSfAJ4H1H0qZJ9dN7nR19frRTeBt4Fe9FwpwtN+2p1MXscGLHR9SXrmMgjONd1ZxKzpBeA71b4tNhj6JGoyFNp4GHgwUp9qplfmnFW5oTdy7NamcwCI49kv6fN5IAHgD+0rbyoBc3SOjczohbyS1drbq6pQdqumllRC/0ymTtej8gpbbuVwpQfyw66dqEZyxZKxtHpJn+tZnpnEdrYBbueF9qQn93S7HQGGHnYP7w6L+YGHNtd1FJitqPAR+hERCNOFi1i1alKO6RQnjKUxL1GNjwlMsiEhcPLYTEiT9ISbN15OY/jx4SMshe9LaJRpTvHr3C/ybFYP1PZAfwfYrPsMBtnE6SwN9ib7AhLwTrBDgUKcm06FSrTfSj187xPdVQWOk5Q8vxAfSiIUc7Z7xr6zY/+hpqwSyv0I0/QMTRb7RMgBxNodTfSPqdraz/sDjzKBrv4zu2+a2t0/HHzjd2Lbcc2sG7GtsL42K+xLfxtUgI7YHqKlqHK8HbCCXgjHT1cAdMlDetv4FnQ2lLasaOl6vmB0CMmwT/IPszSueHQqv6i/qluqF+oF9TfO2qEGTumJH0qfSv9KH0nfS/9TIp0Wboi/SRdlb6RLgU5u++9nyXYe69fYRPdil1o1WufNSdTTsp75BfllPy8/LI8G7AUuV8ek6fkvfDsCfbNDP0dvRh0CrNqTbV7LfEEGDQPJQadBtfGVMWEq3QWWdufk6ZSNsjG2PQjp3ZcnOWWing6noonSInvi0/Ex+IzAreevPhe+CawpgP1/pMTMDo64G0sTCXIM+KdOnFWRfQKdJvQzV1+Bt8OokmrdtY2yhVX2a+qrykJfMq4Ml3VR4cVzTQVz+UoNne4vcKLoyS+gyKO6EHe+75Fdt0Mbe5bRIf/wjvrVmhbqBN97RD1vxrahvBOfOYzoosH9bq94uejSOQGkVM6sN/7HelL4t10t9F4gPdVzydEOx83Gv+uNxo7XyL/FtFl8z9ZAHF4bBsrEwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAQ9JREFUOBGtk1kSgjAQRIkFF1Dhx+0Q3v8wLn8uF6BK7I4zqaAJTKrMT4rQPGZ6Om4YhmMlq+/7V9M0Z+fcQ89yO75bQn+AfhFran0ohK2h333DyPL0f8E8UGAXY5vZyrRTBy9awG56kNuhm4WxOJcDxOeArSDepzxTnXR6Gk1IX8Z7AYy2PScrLITdWUgWaPUMNrAyD8sCAWvhydbg2QhGYAg2H7ikMgsseaNGQxHPkjfg87uqkmkmYdQEDwVmiUYWRqBvWdq0VDZ7oxYFsGs8TVaTWjU8sVYWopEC8Yy21YZoTHqmcO30JzYqmJum6rgDFnKbBApsdgAC67Aztz4xoxxSEMEsnnXQb/BZiN8bgevxkKVkxysAAAAASUVORK5CYII\x3D", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kProductKey, Type = String, Dynamic = False, Default = \"CalendarView", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseDate, Type = Double, Dynamic = False, Default = \"20180309", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersion, Type = String, Dynamic = False, Default = \"1.7.4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LayoutEditorIcon, Type = String, Dynamic = False, Default = \"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\x3D\x3D", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineNone, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineThinDotted, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineThinDouble, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineThinSolid, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NavigatorIcon, Type = String, Dynamic = False, Default = \"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", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PickerDay, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PickerDecade, Type = Double, Dynamic = False, Default = \"4", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PickerMonth, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = PickerYear, Type = Double, Dynamic = False, Default = \"2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = StyleDark, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StyleDefault, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StyleGoogle, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StyleICal, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StyleOutlook2010, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = StyleOutlook2013, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeDay, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeMonth, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeOther, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypePicker, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeWeek, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TypeYear, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant


	#tag Structure, Name = Colors, Flags = &h1
		Border As Color
		  Line As Color
		  Title As Color
		  DayName As Color
		  DayNumberActive As Color
		  DayNumber As Color
		  DayNumberBackground As Color
		  Today As Color
		  WDefaultColor As Color
		  Selected As Color
		  Header As Color
		  Weekend As Color
		  WeekDay As Color
		  YBackground As Color
		  WeekNumber As Color
		  WeekNumberBackground As Color
		  TimeBackground As Color
		  Time As Color
		  OtherMonth As Color
		  PBackground As Color
		  PSelected As Color
		  POver As Color
		  PArrow As Color
		  PDayNumber As Color
		  PDayNumberActive As Color
		  Line2 As Color
		  PDayNumberToday As Color
		  MainColor As Color
		  MSelectedText As Color
		  WeekDay2 As Color
		PBackground2 As Color
	#tag EndStructure

	#tag Structure, Name = MonthPopup, Flags = &h1
		Visible As Boolean
		  SQLDate As String*10
		  Left As Integer
		  Top As Integer
		  Width As Integer
		Height As Integer
	#tag EndStructure

	#tag Structure, Name = Styles, Flags = &h1
		MBorderSolid As Boolean
		  MColorOffset1 As Byte
		  MColorOffset2 As Byte
		  MColorOtherMonth As Boolean
		  MDayNameAlign As Byte
		  MDayNumberAlign As Byte
		  MDayNumberBackground As Boolean
		  MDayRoundRect As Boolean
		  MDayTextBold As Boolean
		  MDayTextColor As Color
		  MDayTransparency As Color
		  MDayTransparent As Boolean
		  MEventFill As Byte
		  MEventHeight As Byte
		  MEventTextSize As Byte
		  MFirstDayOfMonthName As Boolean
		  MFirstDayOfMonthBold As Boolean
		  MHasSelectedTextColor As Boolean
		  MHourBold As Boolean
		  MLeftOffset As Byte
		  MNumberXOffset As Byte
		  MNumberYOffset As Byte
		  MTextBold As Boolean
		  MTextOffset As Byte
		  PDayNameBold As Boolean
		  PDayNamePos As Byte
		  PDayNumberBold As Boolean
		  PDayNumberPos As Byte
		  PTextSize As Byte
		  PLineHorizontal As Byte
		  PLineVertical As Byte
		  WAutoTextColor As Boolean
		  WBodyColorOffset1 As Byte
		  WBodyColorOffset2 As Byte
		  WBodyGradientVertical As Boolean
		  WBodyTextBold As Boolean
		  WBodyTextSize As Byte
		  WBodyTransparency As Color
		  WEventFill As Byte
		  WEventHeight As Byte
		  WHalfHourColorOffset As Byte
		  WHalfHourLineStyle As Byte
		  WHeaderColorOffset As Byte
		  WHeaderHeight As Byte
		  WHeaderTextBold As Boolean
		  WHeaderTextFormat As String * 30
		  WHeaderTextSize As Byte
		  WHeaderTransparency As Color
		  WHourLineStartX As Byte
		  WRoundRect As Boolean
		  WTextColor As Color
		  WTimeAlign As Byte
		  WTimeFormat As String*12
		  WTimeVOffset As Int8
		  WTodayHeader As Boolean
		  YLineHorizontal As Byte
		  YLineVertical As Byte
		  YTitleTextSize As Byte
		  YNumbersTextSize As Byte
		  MTitleTextSize As Byte
		  MNumbersTextSize As Byte
		  WTextSize As Byte
		FillGradient As Boolean
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
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
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_OpenEventFired"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Cursor"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Automatic"
				"1 - Standard Pointer"
				"2 - Finger Pointer"
				"3 - IBeam"
				"4 - Wait"
				"5 - Help"
				"6 - Arrow All Directions"
				"7 - Arrow North"
				"8 - Arrow South"
				"9 - Arrow East"
				"10 - Arrow West"
				"11 - Arrow Northeast"
				"12 - Arrow Northwest"
				"13 - Arrow Southeast"
				"14 - Arrow Southwest"
				"15 - Splitter East West"
				"16 - Splitter North South"
				"17 - Progress"
				"18 - No Drop"
				"19 - Not Allowed"
				"20 - Vertical IBeam"
				"21 - Crosshair"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="HorizontalCenter"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabOrder"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="VerticalCenter"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ZIndex"
			Visible=false
			Group="Behavior"
			InitialValue="1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_DeclareLineRendered"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_HorizontalPercent"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_IsEmbedded"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_Locked"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_NeedsRendering"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_OfficialControl"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_VerticalPercent"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AdaptWeeksPerMonth"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Animate"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Border"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColorWeekend"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CreateWithDrag"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DayStartHour"
			Visible=true
			Group="Behavior"
			InitialValue="8"
			Type="Single"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DayEndHour"
			Visible=true
			Group="Behavior"
			InitialValue="18"
			Type="Single"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DisplayWeeknumber"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DragEvents"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ForceAM_PM"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTagFormat"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockDayEventsHeight"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="minHGap"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="minHourHeight"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="minVGap"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScrollPosition"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ViewDays"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ViewType"
			Visible=true
			Group="Behavior"
			InitialValue="2"
			Type="Integer"
			EditorType="Enum"
			#tag EnumValues
				"0 - Picker"
				"1 - Year"
				"2 - Month"
				"3 - Week"
				"4 - Day"
				"5 - Other"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="WeekHeaderTextFormat"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="YearHeatMap"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DisableScroll"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextFont"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Freeze"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="YearMultipleEvents"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FilterEvents"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TransparentBackground"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="VisibleHours"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="YearMonthsAmount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StyleType"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HighlightLockedEvents"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstDayOfWeek"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Byte"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
