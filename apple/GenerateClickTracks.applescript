(*
	-------------------------------------------------------------------------

	This is Caio Begotti's GenerateClickTracks AppleScript. Public Domain FWIW.
	Original from <http://caio.ueberalles.net/svn/scripts/apple/>
	
	INSTALL: copy this file to your folder "Library/Scripts/Applications/iTunes/"
			
	-------------------------------------------------------------------------
*)

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
							click button "OK" of window "Click Track..."
						end tell
					end tell
				end tell
			end tell
		end tell
	end if
end tell