(*
	This is Caio Begotti's GenerateClickTracks AppleScript. Public Domain FWIW.
	Original from <http://caio.ueberalles.net/svn/scripts/apple/>	
	
	USAGE: osascript ./GenerateClickTracks.applescript <int>
*)

on run argv
	set bpm to item 1 of argv
	tell application "Finder"
		if bpm is not "" then
			tell application "System Events"
				if UI elements enabled then
					tell application "System Events"
						tell process "Audacity"
							activate
							click menu item "Click Track..." of menu 1 of menu bar item "Generate" of menu bar 1
							tell application "Audacity"
								activate
								tell application "System Events"
									tell process "Audacity"
										click menu 1 of menu bar item "Audacity" of menu bar 1
										keystroke tab
										keystroke "a" using command down
										keystroke bpm
										click button "OK" of window "Click Track..."
										delay 5
										click menu item "Export..." of menu 1 of menu bar item "File" of menu bar 1
										keystroke "/tmp/" & bpm & ".wav"
										repeat 3 times
											keystroke return
										end repeat
										delay 5
									end tell
								end tell
							end tell
						end tell
					end tell
				else
					display dialog "Ops! Vai em System Preferences > Universal Access e habilite Enable access for assistive devices, a’ tente de novo :-)" buttons {"Foi mal..."} default button 1 with icon 2 giving up after 15
				end if
			end tell
		end if
	end tell
end run