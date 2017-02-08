#Include Once "windows.bi"
#Include Once "win/commctrl.bi"
#Include "rsrc.bi"

Declare Function DlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
Declare Function ThreadProcs(ByVal dwReserved As DWORD)As DWORD

	Dim Shared hInstance As HINSTANCE
	Dim Shared status As Integer
	Dim Shared angle As Integer
	InitCommonControls()
	hInstance=GetModuleHandle(NULL)
	DialogBoxParam(hInstance, Cast(ZString Ptr,frmMain), NULL, @DlgProc, NULL)

	ExitProcess(0)
	End

Function ThreadProcs(ByVal dwReserved As DWORD)As DWORD
	Static t As Integer
	Do 
		Sleep 780
		If status = 0 Then 
			t = 0
			Continue Do
		Else			
			mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,XBUTTON1,0)
			mouse_event(MOUSEEVENTF_LEFTUP,0,0,XBUTTON1,0)
			
			Select Case t
				Case 0,1,2,3,4
					mouse_event(MOUSEEVENTF_MOVE,-angle,0,XBUTTON1,0)
				Case 5,6,7,8
					mouse_event(MOUSEEVENTF_MOVE,angle,0,XBUTTON1,0)
				Case 9
					mouse_event(MOUSEEVENTF_MOVE,angle,0,XBUTTON1,0)
					t=-1
					
			End Select
			t+=1
		Endif
	Loop
End Function

Function DlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Select Case uMsg
		Case WM_INITDIALOG
			angle = 20
			CreateThread(NULL,NULL,@ThreadProcs,NULL,NULL,NULL)
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Dim As Long id, Event
			id=LoWord(wParam)
			Event=HiWord(wParam)
			
			Select Case id
				Case cmdReg
					Dim As DWORD key = SendMessage(GetDlgItem(hWin,keyHot),HKM_GETHOTKEY,0,0) 

					Dim As Integer ret = RegisterHotKey(hWin, 2, key Shr 9, key Mod 256)
					If ret = 0 Then
						MessageBox(NULL,"该热键已被占用！",NULL,MB_OK Or MB_ICONINFORMATION)
					Else
						MessageBox(NULL,"热键注册成功！","提示",MB_OK)
						EnableWindow(GetDlgItem(hWin,keyHot),FALSE)
						EnableWindow(GetDlgItem(hwin,cmdReg),FALSE)
					EndIf
				
				Case cmdAngle
					Dim a As Integer
					Dim st As ZString*4
					GetDlgItemText(hWin,txtAngle,@st,3)
					a = CInt(st)
					If a < 0 Then 
						MessageBox(hWin, "你丫的好好写！", NULL, mB_OK Or MB_ICONERROR)
						SetDlgItemText(hWin,txtAngle,"20")
					Else
						angle = a
						SetDlgItemText(hWin,txtAngle,Str(angle))
						MessageBeep(MB_ICONASTERISK)
					EndIf
					
			End Select
				
		Case WM_HOTKEY
			MessageBeep(MB_ICONEXCLAMATION)
			
			If status = 0 Then
				status = 1
				SetWindowText(hWin,"已启动")
			Else
				status = 0
				SetWindowText(hWin,"已关闭")
			EndIf
			
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
