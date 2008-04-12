(*
	-------------------------------------------------------------------------

	This is Caio Begotti's Lyrics2iPod AppleScript. Public Domain FWIW.
	Original from <http://caio.ueberalles.net/svn/scripts/apple/>
	
	INSTALL: copy this file to your folder "Library/Scripts/Applications/iTunes/"

	INSTRUCTIONS: just select a random iPod's playlist with the songs you want
	to fetch the lyrics for. Wait for a while until it's all grabbed from LyricWiki
	
	-------------------------------------------------------------------------
		
	This was heavily inspired by the original code from Lyrics Snagger
	written by Hendo <http://scriptbuilders.net/files/lyricssnagger1.1.html>
	
	It also uses some parts of the iPod Lyrics To Notes script, by
	Doug Adams <http://dougscripts.com/itunes/pdf/ipodlyricstonotes.pdf>

	If you're looking for more information on iPod Notes features
	you might want to take a look at the updated PDF available at
	<http://developer.apple.com/ipod/iPodNotesFeatureGuideCB.pdf>
	
	-------------------------------------------------------------------------
*)

(* Do you want to save the lyrics as .txt for offline reading? *)
set copy_to_desktop to yes

(* Do you want to embed the lyrics into the song's file? *)
set copy_to_itunes to yes

global ipod_source
global ipod_name
global sel
global theiPod
global ipod_notes_folder
global ipod_lyrics_folder

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
		display dialog "You must select an iPod playlist in order to fetch lyrics for its songs." buttons {"Abort"} default button 1 with icon 2 giving up after 15
		return 128
	end if
	
	set ipod_name to name of ipod_source
	set theiPod to ("/Volumes/" & ipod_name & "/") as POSIX file as alias
	
	(* You may change the Lyrics folder but not Notes *)
	set ipod_notes_folder to my get_folder("Notes", theiPod)
	set ipod_lyrics_folder to my get_folder("Lyrics", ipod_notes_folder)
	
	repeat with this_track in sel
		try
			with timeout of 3000 seconds
				tell this_track
					(* Get the track and artist name from iTunes *)
					set theSong to (get name)
					set theArtist to (get artist)
					
					(* The following two blocks normalize the artist and song name *)
					set ASTID to AppleScript's text item delimiters
					set AppleScript's text item delimiters to {" "}
					set theSong to text items of theSong
					set theArtist to text items of theArtist
					
					set AppleScript's text item delimiters to {"_"}
					set theSong to theSong as Unicode text
					set theArtist to theArtist as Unicode text
					set AppleScript's text item delimiters to {""}
					
					(* Fetch the lyrics for the given song and store it inside theLyrics *)
					get "http://lyricwiki.org/" & theArtist & ":" & theSong
					do shell script "/usr/bin/curl --user-agent '' " & quoted form of result
					set theLyrics to result
					
					(* Select the lyrics part of the page dump *)
					set AppleScript's text item delimiters to {"<div class='lyricbox' >"}
					set theLyrics to (last text item of theLyrics) as Unicode text
					
					(* Until the box is closed *)
					set AppleScript's text item delimiters to {"</div>"}
					set theLyrics to first text item of theLyrics
					
					(* Split the lyrics, remove linebreaks *)
					set AppleScript's text item delimiters to {"<br/>"}
					set theLyrics to text items of theLyrics
					
					set AppleScript's text item delimiters to {return}
					set theLyrics to text 1 thru -1 of (theLyrics as string)
					set AppleScript's text item delimiters to ASTID
					
					(* Setting the lyrics filename on disk *)
					set file_name to theArtist & "-" & theSong & ".txt"
					if file_name as string does not end with ".txt" then set file_name to ((file_name as string) & ".txt")
					
					(* Ask iTunes for each song parameter but theLyrics *)
					set {nom, alb, art, comp, lyr} to {get name, get album, get artist, get compilation, theLyrics}
				end tell
				
				if lyr is not "" then
					(* A little bit of sanitizing *)
					if alb is "" then set alb to "Unknown Album"
					if art is "" then set alb to "Unknown Artist"
					if comp is true then set art to "Compilations"
					
					(* Call the function to create the lyrics file *)
					my make_lyricnote(nom, alb, art, lyr)
				end if
			end timeout
		end try
	end repeat
end tell

to get_folder(foldername, folderparent)
	try
		tell application "Finder"
			if not (exists folder foldername of folderparent) then
				make new folder at folderparent with properties {name:foldername}
			end if
			return (folder foldername of folderparent) as alias
		end tell
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
	
	(* Useful for cleaning the iPod-made lyrics: sed 's/<[^>]*>/|/g;s/^|//' theLyrics | tr '|' '\n' *)
	
	(* Function to split paragraphs *)
	set lyric_text to list_to_text(lyric_text, "<br>")
	
	(*
	Assembling everything and writing the whole lyrics plus a clickable title:
	the tag <meta name ÒNowPlayingÓ content=false> does not currently work,
	at least on my iPod Nano 1.1, so it's safer to insert it as part of the link to
	the song file... though it neeeds some testing on other modern iPods
	*)
	set new_content to ("<a href=\"song=" & nom & "&artist=" & art & "&album=" & alb & "&NowPlaying=false\">" & nom & "</a>" & "<br><br>" & lyric_text) as Unicode text
	write_note(new_content, ((alb_folder as string) & nom), false)
end make_lyricnote

on write_note(this_data, target_file, append_data)
	try
		(* This actually writes the lyrics to a file *)
		set the target_file to the target_file as text
		set the open_target_file to Â
			open for access file target_file with write permission
		if append_data is false then Â
			set eof of the open_target_file to 0
		write this_data to the open_target_file starting at eof as string
		close access the open_target_file
		
		(* Does it contain the W3 address? Then it's an empty lyrics page *)
		set filter to do shell script "grep -i www.w3.org " & quoted form of POSIX path of target_file
		if filter is not "" then
			(* We don't wanna store an error page, right? *)
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
