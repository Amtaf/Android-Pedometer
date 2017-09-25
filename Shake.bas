Type=StaticCode
Version=6.8
ModulesStructureVersion=1
B4A=true
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	Dim tw As TextWriter
	Dim recording As Boolean
	Type AxisData (flipCount As Int, lastPeak As Float,lastValue As Float, timeStamp As Long)
	Dim AxisX As AxisData
	Dim MagnitudeThreshold As Float
	Dim Extime As Int
	Dim TimeThreshold As Int
	MagnitudeThreshold = 3
	TimeThreshold = 500 'milliseconds
	Dim CallBackActivity As String
End Sub
Sub StartRecording(Dir As String, FileName As String)
	tw.Initialize(File.OpenOutput(Dir, FileName, False))
	
	recording = True
End Sub
Sub EndRecording
	tw.Close
	recording = False
End Sub
Sub HandleSensorEvent(values() As Float)
	If recording Then
		tw.Write(values(0) & "," & values(1) & "," & values(2) & Chr(13) & Chr(10)) 'we are not using CRLF as we want the Windows end of line characters
	Else
		CalcAxis(values(0), AxisX)
	End If
End Sub
Sub CalcAxis(v As Float, axis As AxisData)
	Dim difference As Float
	difference = v - axis.lastValue
	axis.lastValue = v
	If Abs(difference) > MagnitudeThreshold Then
		If DateTime.Now - axis.timeStamp > TimeThreshold Then
			axis.Initialize 'reset the data
		End If
		If axis.flipCount < 0 Then 
			Log("Shake.CalcAxis - still waiting")
			Return 'this will happen immediately after a "shake" event.
		End If
		If axis.lastPeak = 0 Or (axis.lastPeak < 0 And difference > 0) Or (axis.lastPeak > 0 And difference < 0) Then
			axis.flipCount = axis.flipCount + 1
			axis.lastPeak = difference
			axis.timeStamp = DateTime.Now
			If axis.flipCount = 2 Then
				CallSub(CallBackActivity, "ShakeEvent")
				'To avoid repetitive events:
				axis.flipCount = -10
			End If
		Else
			axis.timeStamp = DateTime.Now
		End If
	End If
End Sub