AddAutoLogon() ; Adds registry keys for computer types that automatically logon. (WORKS)
{
	Progress, 55, Configuring Auto-Login Registry..., Please Wait., Running Configuration
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, AutoAdminLogon, 1
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultDomainName, dcls.org
	aAutoLogon := {1: "esalogon0", 2: "kllogon4", 3: "momlogon3", 4: "mrllogon1", 5: "afllogon2", 6:"johlogon6",7: "evlogon5", 8: "ndlogon8" }
	vAutoLogon := aAutoLogon[vBranchNumber]
	If(vTypeNumber == 2) ; Staff
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName, dcls\%vAutoLogon%
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultPassword, w0nd3rb!@#$
		return
	}
	If(vTypeNumber == 3) ; Patron
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName, dcls\%vLocation%-PATRON
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultPassword, DC4p@tron15
		return
	}
	If(vTypeNumber == 4) ; Catalog
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName, dcls\esacatalog
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultPassword, October21@)!$
		return
	}
	If(vTypeNumber == 5) ; Self-Checkout
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName, dcls\%vLocation%-SELFCHECK
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultPassword, DC4p@tron15
		return
	}
	If(vTypeNumber == 6) ; Kiosk
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName, dcls\envkiosk
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultPassword, DC4p@tron15
		return
	}
	Log("...Auto logon registries updated")
}	

Command(vCommand, vHide := "") ; Runs a configuration command.
{
	If(vIsVerbose == 1)
	{
		Try {
		Log("-- Executing: "vCommand)
		RunWait %vCommand%%vHide%
		} Catch {
		vNumErrors += 1
		Log("!! Error executing "vCommand . "!")
		}
	}
	else
	{
		Try {
		Log("-- Executing: "vCommand, 1)
		RunWait %vCommand%%vHide%
		} Catch {
		vNumErrors += 1
		Log("!! Error executing "vCommand . "!")
		}
	}
	Return
}

ConfirmationWindow() ; Checks that selections are correct before continuing. (WORKS)
{
	Gui +OwnDialogs
	if(vWireless = 1)
		vIsWireless := "This is a Wireless computer."
	else
		vIsWireless := "This is an Ethernet computer."
	if(vComputerName == "")
	{
	MsgBox, 48, Not Named, Please type in a name for the computer.
	Return
	}
	if(StrLen(vComputerName) > 15)
	{
	MsgBox, 48, Large Name, The computer name is too long.`nPlease input a name that fifteen characters or less.
	Return
	}
	if(vLocation == "")
	{
	MsgBox, 48, No Library, Please select a library branch.
	Return
	}
	if(vComputerType == "")
	{
	MsgBox, 48, No Computer, Please select a computer type.
	Return
	}
	MsgBox, 36, Confirm, This will rename the computer to %vComputerName%.`nThis is a %vComputerType% computer at %vLocation%.`n%vIsWireless% `nIs this correct?
	IfMsgBox, Yes
		Gosub __main__
	Return
}

CreateDistinguishedName() ; Creates a distiguished name for moving to OU. (WORKS)
{
	If(vTypeNumber == 1) ; Office
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Offices,OU=Systems,OU=" . vLocation . ",OU=Staff,OU=DCLS,DC=dcls,DC=org"
		return
		}
	If(vTypeNumber == 2) ;Frontline PC
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Frontline,OU=Systems,OU=" . vLocation . ",OU=Staff,OU=DCLS,DC=dcls,DC=org"
		return
		}		
	If(vTypeNumber == 2 and vWireless == 1) ;Staff Laptop
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Laptops,OU=Systems,OU=" . vLocation . ",OU=Staff,OU=DCLS,DC=dcls,DC=org"
		return
		}
	If(vTypeNumber == 3) ;Patron PC
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=" . vLocation . ",OU=Patron,OU=DCLS,DC=dcls,DC=org"
		return
		}
	If(vTypeNumber == 3 and vWireless == 1) ;Patron Laptop
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Laptops,OU=Patron,OU=DCLS,DC=dcls,DC=org"
		return
		}		
	If(vTypeNumber == 4)	;Catalog
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Catalog,OU=Patron,OU=DCLS,DC=dcls,DC=org"
		return
		}
	If(vTypeNumber == 5) ;Self Check
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Self Service,OU=Patron,OU=DCLS,DC=dcls,DC=org"
		return
		}
	If(vTypeNumber == 6)	;Kiosk
		{
		vDistiguishedName := "CN=" . vComputerName . ",OU=Kiosk,OU=Patron,OU=DCLS,DC=dcls,DC=org"
		return
		}		
	Log("Failure to create distinguished name!")
	vNumErrors += 1
}

createOptionsWindow() ; Create the main GUI. 
{
	Gui 2: New, , Computer Deployment
;----This Section contains the Computer Name label and field.----
	Gui 2: Font, Bold s10
	Gui 2: Add, Text,, Type in new computer name:
	Gui 2: Font, Norm
	Gui 2: Add, Edit, Uppercase vvComputerName,
;----This section contains a Radio toggle for Library locations.----
	Gui 2: Font, Bold s10
	Gui 2: Add, GroupBox, Section r8, Select Branch:
	Gui 2: Font, Norm
	Gui 2: Add, Radio, altsubmit vvBranchNumber xp+10 yp+20, East Shore
	Gui 2: Add, Radio, altsubmit, Kline Library
	Gui 2: Add, Radio, altsubmit, Madeline Olewine
	Gui 2: Add, Radio, altsubmit, McCormick Riverfront
	Gui 2: Add, Radio, altsubmit, Alexander Family
	Gui 2: Add, Radio, altsubmit, Johnson Memorial
	Gui 2: Add, Radio, altsubmit, Elizabethville
	Gui 2: Add, Radio, altsubmit, Northern Dauphin
;----This Section contains a Radio toggle for computer type.----
	Gui 2: Font, Bold s10
	Gui 2: Add, GroupBox, Section r4 ys, Select computer type:
	Gui 2: Font, Norm
	Gui 2: Add, Radio, altsubmit vvTypeNumber xp+10 yp+20, Office Staff
	Gui 2: Add, Radio, altsubmit, Frontline Staff
	Gui 2: Add, Radio, altsubmit, Patron Computer
	Gui 2: Add, Radio, altsubmit, Catalog Computer			
	;Gui 2: Add, Radio, altsubmit, Self-Checkout Station		<- To Be Implimented
	;Gui 2: Add, Radio, altsubmit, Print Kiosk				<- To Be Implimented
;----This section contains Checkbox toggles.----
	Gui 2: Font, Bold s10
	Gui 2: Add, Checkbox, Section xs vvWireless, This is a Wireless computer. ; Wireless check toggle.
	Gui 2: Add, Checkbox, vvIsVerbose, Use Verbose logging. ; Verbose logging toggle.
	Gui 2: Font, Norm
;----This Section contains Submit and Exit Buttons.----
	Gui 2: Add, Button, Section gButtonInstall w100, Install
	Gui 2: Add, Button, yp xp+110 gButtonExit w100, Exit
	Gui 2: Show
	Return
}

ExitFunc(ExitReason, ExitCode) ; Checks and logs various unusual program closures.
{
	Gui +OwnDialogs
	if ExitReason in Menu,
    {
        MsgBox, 52, Exiting Deployment, This will end deployment.`nAre you sure you want to exit?
        IfMsgBox, No
            return 1  ; OnExit functions must return non-zero to prevent exit.
		Log("-- User is exiting Deployment`, dying now.")
    }
	if ExitReason in Logoff,Shutdown
	{
		Log("-- System logoff or shutdown in process`, dying now.")
	}
		if ExitReason in Close
	{
		Log("!! The system issued a WM_CLOSE or WM_QUIT`, or some other unusual termination is taking place`, dying now.")
	}
		if ExitReason not in Close,Exit,Logoff,Menu,Shutdown
	{
		Log("!! I am closing unusually`, with ExitReason: " ExitReason ", dying now.")
	}
    ; Do not call ExitApp -- that would prevent other OnExit functions from being called.
}

Log(msg, Type=3) ; 1 logs to file, 2 logs to console, 3 does both, 10 is just a newline to file
{
	global ScriptBasename, AppTitle
	If(Type == 1) {
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%.%A_MSec%%A_Tab%%msg%`n, %ScriptBasename%.log
		}
	If(Type == 2) {
		Message(msg)
		}
	If(Type == 3) {
		FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%.%A_MSec%%A_Tab%%msg%`n, %ScriptBasename%.log
		Message(msg)
		}
	If(Type == 10) {
		FileAppend, `n, %ScriptBasename%.log
		}	

	
	Sleep 50 ; Hopefully gives the filesystem time to write the file before logging again
	;Type += 16
	Return
}

Message(msg)
{
GuiControlGet, Console, 1:
GuiControl, 1:, Console, %Console%%msg%`r`n
}