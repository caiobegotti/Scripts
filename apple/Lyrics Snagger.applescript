(*
	This is Caio Begotti's Lyrics4iPod AppleScript. Public Domain.
	Fetched from <http://caio.ueberalles.net/svn/scripts/apple/>
	
	This was heavily inspired by the original code from Lyrics Snagger
	written by Hendo <http://scriptbuilders.net/files/lyricssnagger1.1.html>
	
	It also uses large parts of the iPod Lyrics To Notes script, by
	Doug Adams <http://dougscripts.com/itunes/pdf/ipodlyricstonotes.pdf>

	If you're looking for more information on iPod Notes features
	you might want to take a look at the updated PDF available at
	<http://developer.apple.com/ipod/iPodNotesFeatureGuideCB.pdf>
	
	The Notes feature supports a maximum of 1,000 notes. If you try to put
	more than that number in your iPodÕs Notes folder hierarchy, only the first
	1,000 will be loaded. The size of any single note is truncated to 4,096
	bytes of text (about 1,000 words)
*)

property section_length : 3950

global ipod_source
global ipod_name
global sel
global theiPod
global ipod_notes_folder
global ipod_lyrics_folder
global any_errors
global lyrics_done

tell application "iTunes"
	if selection is {} then
		set sel to every file track of view of front browser window
		set what_I_chose to " the tracks in the selected playlist on "
	else
		set sel to selection
		set what_I_chose to " the selected tracks on "
	end if
	
	set ipod_source to (container of container of item 1 of sel)
	if kind of ipod_source is not iPod then
		display dialog "Select some iPod tracks or an iPod playlist..." buttons {"Cancel"} default button 1 with icon 2 giving up after 15
	end if
	
	set ipod_name to name of ipod_source
	
	try
		if gave up of result is true then return
	end try
	
	try
		set theiPod to ("/Volumes/" & ipod_name & "/") as POSIX file as alias
	on error m
		display dialog "Error:" & return & return & m buttons {"Cancel"} with icon 0 giving up after 15
		try
			if gave up of result is true then return
		end try
		return
	end try
	
	set ipod_notes_folder to my get_folder("Notes", theiPod)
	set ipod_lyrics_folder to my get_folder("Lyrics", ipod_notes_folder)
	
	set any_errors to 0
	set lyrics_done to 0
	repeat with this_track in sel
		try
			with timeout of 3000 seconds
				tell this_track
					set theSong to (get name)
					set theArtist to (get artist)
					
					set ASTID to AppleScript's text item delimiters
					set AppleScript's text item delimiters to {" "}
					set theSong to text items of theSong
					set theArtist to text items of theArtist
					
					set AppleScript's text item delimiters to {"_"}
					set theSong to theSong as Unicode text
					set theArtist to theArtist as Unicode text
					set AppleScript's text item delimiters to {""}
					
					get "http://lyricwiki.org/" & theArtist & ":" & theSong
					do shell script "/usr/bin/curl --user-agent '' " & quoted form of result
					set theLyrics to result
					
					set AppleScript's text item delimiters to {"<div class='lyricbox' >"}
					set theLyrics to (last text item of theLyrics) as Unicode text
					
					set AppleScript's text item delimiters to {"</div>"}
					set theLyrics to first text item of theLyrics
					
					set AppleScript's text item delimiters to {"<br/>"}
					set theLyrics to text items of theLyrics
					
					set AppleScript's text item delimiters to {return}
					set theLyrics to text 1 thru -1 of (theLyrics as string)
					set AppleScript's text item delimiters to ASTID
					
					set file_name to theArtist & "-" & theSong & ".txt"
					if file_name as string does not end with ".txt" then set file_name to ((file_name as string) & ".txt")
					set {nom, alb, art, comp, lyr} to {get name, get album, get artist, get compilation, theLyrics}
				end tell
				
				if lyr is not "" then
					if alb is "" then set alb to "Unknown Album"
					if art is "" then set alb to "Unknown Artist"
					if comp is true then set art to "Compilations"
					my make_lyricnote(nom, alb, art, lyr)
				end if
			end timeout
		end try
	end repeat
	
	set addenda to ""
	set icon_num to 1
	
	if any_errors is not 0 then
		set icon_num to 2
		set {s, tense} to {"s", "were "}
		if any_errors = 1 then
			set {s, tense} to {"", "was "}
		end if
		set addenda to (return & return & "There " & tense & any_errors & s & " with writing Lyric Notes.")
	end if
	
	if lyrics_done is 0 then
		set icon_num to 2
		set addenda to (addenda & (return & return & "No lyrics were made into Notes.")) as string
	end if
end tell

to get_folder(foldername, folderparent)
	try
		tell application "Finder"
			if not (exists folder foldername of folderparent) then
				make new folder at folderparent with properties {name:foldername}
			end if
			return (folder foldername of folderparent) as alias
		end tell
	on error m
		display dialog "Error:" & return & return & m buttons {"Cancel"} with icon 0 giving up after 15
		try
			if gave up of result is true then error number -128
		end try
		error number -128
	end try
end get_folder

to make_lyricnote(nom, alb, art, lyr)
	set art_folder to my get_folder(art, ipod_lyrics_folder)
	set alb_folder to my get_folder(alb, art_folder)
	set lyric_text to text_to_list(lyr, return)
	
	repeat
		if item 1 of lyric_text is "" then
			set lyric_text to rest of lyric_text
		else
			exit repeat
		end if
	end repeat
	
	set lyric_text to list_to_text(lyric_text, "<br>")
	set new_content to ("<a href=\"song=" & nom & "&artist=" & art & "&album=" & alb & "\">" & nom & "</a>" & "<br><br>" & lyric_text) as Unicode text
	
	if write_note(new_content, ((alb_folder as string) & nom), false) is false then
		set any_errors to any_errors + 1
	else
		set lyrics_done to lyrics_done + 1
	end if
end make_lyricnote

on write_note(this_data, target_file, append_data)
	try
		set the target_file to the target_file as text
		set the open_target_file to Â
			open for access file target_file with write permission
		if append_data is false then Â
			set eof of the open_target_file to 0
		write this_data to the open_target_file starting at eof as string
		close access the open_target_file
		set filter to do shell script "grep -i www.w3.org " & quoted form of POSIX path of target_file
		if filter is not "" then
			do shell script "rm -rf " & quoted form of POSIX path of target_file
		end if
		return true
	on error
		try
			close access file target_file
		end try
		return false
	end try
end write_note

on text_to_list(txt, delim)
	set saveD to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to {delim}
		set theList to every text item of txt
	on error errStr number errNum
		set AppleScript's text item delimiters to saveD
		error errStr number errNum
	end try
	set AppleScript's text item delimiters to saveD
	return (theList)
end text_to_list

on list_to_text(theList, delim)
	set saveD to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to {delim}
		set txt to theList as text
	on error errStr number errNum
		set AppleScript's text item delimiters to saveD
		error errStr number errNum
	end try
	set AppleScript's text item delimiters to saveD
	return (txt)
end list_to_text

(*
to edittext(someText)
	return do shell script "echo " & quoted form of someText & " | /usr/bin/ruby -ne 'print $_.delete(\"^a-z\", \"^A-Z\", \"^0-9\", \"^ \")'"
end edittext

to make_report(file_name, user_text)
	try
		do shell script "rm " & quoted form of POSIX path of file_name
	end try
	
	try
		set fileRefr to (a reference to (open for access file_name with write permission))
		write user_text to fileRefr
		close access fileRefr
	on error errx number errNum from badObj
		try
			close access fileRefr
		end try
		log errNum
		if (errNum is equal to -48) then
			do shell script "rm " & quoted form of POSIX path of file_name
			my make_report()
		else
			display dialog "There has been an error creating the file:" & return & return & (badObj as string) & errx & return & "error number: " & errNum buttons {"Cancel"}
		end if
	end try
end make_report
*)