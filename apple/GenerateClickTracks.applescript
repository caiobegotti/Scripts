(*
	This is Caio Begotti's GenerateClickTracks AppleScript. Public Domain FWIW.
	
	Use this to generate click tracks (like a metronome would do) using
	Audacity's plug-ins/clicktrack.ny. Hackish but perfect for www.trilhape.com.br
	
	Get the original from <http://caio.ueberalles.net/svn/scripts/apple/>	
	
	USAGE: osascript ./GenerateClickTracks.applescript <int for checkpoint> <int for steps>
*)

on run argv
	
	# geralmente n‹o passa de 30
	set checkpoint to item 1 of argv
	
	# costuma variar entre 40 e 65
	set meter to item 2 of argv
	
	# esse Ž o tamanho do seu passo duplo
	set bpm to meter * 1.4
	
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
										keystroke "i" using {command down, shift down}
										keystroke "/tmp/" & checkpoint & ".wav"
										repeat 2 times
											keystroke return
										end repeat
										delay 500
										click menu item "Export..." of menu 1 of menu bar item "File" of menu bar 1
										keystroke "/tmp/" & "click" & checkpoint & "-" & bpm & ".wav"
										repeat 3 times
											keystroke return
										end repeat
										delay 5
										tell application "Finder"
											activate
										end tell
									end tell
								end tell
							end tell
						end tell
					end tell
				else
					display dialog "Vai em System Preferences > Universal Access e habilite Enable access for assistive devices:-)" buttons {"OK"} default button 1 with icon 2 giving up after 30
				end if
			end tell
		end if
	end tell
end run