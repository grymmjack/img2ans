' Lotus 123 type bar menu generator by Steve Trace CompuServe ID 70317,2124

' This routine will provide a method to create 123 style menu for programs
' you develop.  The primary subprogram is barmenu.  The following parameters
' are required.
' y = the row you wish the first line of the menu to print on.
'     values of 0 to 24 are valid.
' x = the column of the first menu prompt.  Values must be chosen carefully
'     so your end of line with approiate spacing does not exceed your screen
'     width.
' spacing = the number of spaces between each prompt.  Again values must be
'     choosen carefully as in x above.
' tc = the foreground color for all prompts except the current option which
'     will have this color as it's background color.
' bc = the background color except the current option which will have this
'     color as the foreground.
' prompts$(2) = a two dimential array.  Since lbound and ubound functions
'     are used within the subprogram any option base may be used.  However
'     the second dimention may only have 2 values. (option base 0 value
'     must be 1 - option base 1 value must be 2)
'     (ie redim prompts$(anyvalue,1) for option base 0)
'     assign the short prompt to the first subscript and a more descriptive
'     string to the second subscript.  See example for ideas.
' return$ = the value returned upon exit from the subprogram.  This value
'     could then be used to branch your program to other subprograms.
'     The first character the first subscript of the selected prompts$ is
'     returned in upper case.
' The left and right cursor keys can be used to move one selection at a time
' or the home and end keys can be used to go to the beginning or end of the
' menu.  Pressing enter will return the currently highlighted option.  You
' can also select an item by hitting the first character of any of the top
' row prompts.

' $dynamic

defint a-z

' sample program

dim menudata$(3,1)

menudata$(0,0) = "Go"               'create menu info
menudata$(0,1) = "Run problem"
menudata$(1,0) = "Previous"
menudata$(1,1) = "Previous menu"
menudata$(2,0) = "Next"
menudata$(2,1) = "Next menu"
menudata$(3,0) = "Quit"
menudata$(3,1) = "Exit Program"
width 80
color 15,1,1
cls
call barmenu (24,5,5,14,1,menudata$(),option$)   ' call the menu
cls
if instr("GNP",option$) > 0 then    ' if Go, Next or Previous chosen do
	redim menudata$(1,1)              ' create new menu info
	menudata$(0,0) = "Go"
	menudata$(0,1) = "Run problem"
	menudata$(1,0) = "Previous"
	menudata$(1,1) = "Previous menu"
	call barmenu (4,5,5,12,1,menudata$(),option$)
end if
cls
print option$;  ' just to show you what is returned
end

' meat of routine

function fnUpcase$(char$)
    fnUpcase$ = chr$(asc(char$) + (32 * (char$ => "a" and char$ <= "z")))
end function

sub barmenu (y,x,spacing,tc,bc,prompts$(2),return$) static

	top = lbound(prompts$,1)
	bottom = ubound(prompts$,1)
	prompt = lbound(prompts$,2)
	description = ubound(prompts$,2)
	redim position(bottom)
	okprompt$ = ""
	locate y,x,0
	color tc,bc
	for i = top to bottom
		position (i) = pos(y)
		print prompts$(i,prompt); spc(spacing);
		okprompt$ = okprompt$ + chr$(asc(prompts$(i,prompt)))
	next i
	current = top
	moveto = current
	return$ = ""
	while return$ = ""
	   color bc,tc
	   locate y,position(current)
	   print prompts$(current,prompt);
	   locate y+1,x
	   color tc,bc
	   print prompts$(current,description);
	   while ch$ = ""
		  ch$ = inkey$
	   wend
	   if asc(ch$) = 0 then
		  call specialkey(ch$,moveto,top,bottom)
	   elseif ch$ = chr$(13) then
		  return$ = chr$(asc(prompts$(current,prompt)))
	   elseif instr(okprompt$,fnUpcase$(ch$)) > 0 then
		  return$ = fnUpcase$(ch$)
	   else
		  beep
	   end if
	   if moveto <> current then
		  locate y,position(current)
		  print prompts$(current,prompt);
		  locate y+1,x
		  print space$(80-x);
		  current = moveto
	   end if
	   ch$ = ""
	wend
	erase position
end sub

sub specialkey(ch$,where,low,high) static

	c = asc(right$(ch$,1))
	if c = 71 then
		where = low
	elseif c = 79 then
		where = high
	elseif c = 75 then
		where = where -1
	elseif c = 77 then
		where = where + 1
	else
		beep
	end if
	if where < low then where = high
	if where > high then where = low
end sub
