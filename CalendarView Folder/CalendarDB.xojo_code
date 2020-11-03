#tag Class
Protected Class CalendarDB
	#tag Method, Flags = &h0
		Sub Constructor(control As Auto)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportToDB(DB As Database, TableName As String, ID As String = "ID", StartDate As String = "Start", EndDate As String = "End", Title As String = "Title", EventColor As String = "Color", Location As String = "Location", Description As String = "Description", Recurrence As String = "Recurrence") As Boolean
		  //Exports all CalendarEvents to the passed TableName in the passed Database.
		  
		  #If TargetDesktop
		    Dim cal As CalendarView = CalendarView(control)
		  #ElseIf TargetWeb
		    Dim cal As WebCalendarView = WebCalendarView(control)
		  #EndIf
		  
		  Dim Events() As CalendarEvent = cal.GetEvents
		  
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
		  
		  For each delID as String in cal.DeletedIDs
		    DB.SQLExecute("DELETE FROM " + TableName + " WHERE " + ID + "='" + delID + "'")
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


	#tag Note, Name = About
		
		This helper class is a simple example on how to export CalendarEvents to a MySQL database.
		
		Feel free to edit the ExportToDB function.
	#tag EndNote


	#tag Property, Flags = &h1
		Protected control As Auto
	#tag EndProperty


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
			InitialValue="-2147483648"
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
	#tag EndViewBehavior
End Class
#tag EndClass
