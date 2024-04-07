.model small
.stack 100h

.data
    usageMsg       db "USAGE: locker.exe <input filename> <output filename> <code>$"
    filenameError  db "Error: Invalid filename. Filenames must be 12 characters or less.$"
    openError      db "Error: Unable to open input file.$"
    createError    db "Error: Unable to create output file.$"
    inputFilename  db 13 dup(0)                                                               ; 12 characters for filename + 1 for null terminator
    outputFilename db 13 dup(0)                                                               ; 12 characters for filename + 1 for null terminator
    code           db 21 dup(0)                                                               ; 20 characters for code + 1 for null terminator

    buffer         db 1 dup(0)
.code
    start:           
                     call splitCommandLine
                     cmp  ax, 0FFFFh
                     je   cl_error
                     cmp  ax, 0FFFEh
                     je   fn_error
    ; Set DS to point to the data segment
                     mov  ax, @data
                     mov  ds, ax
    ; Open input file
                     mov  dx, offset inputFilename
                     mov  ah, 3Dh
                     mov  al, 0
                     int  21h
                     jc   open_error
                     mov  di, ax                       ; Save file handle
    ; Open output file
                     mov  dx, offset outputFilename
                     mov  ah, 3Dh
                     mov  al, 1
                     int  21h
                     jc   create_out_file
                     mov  si, ax                       ; Save file handle
                     jmp  convert_file
    create_out_file: 
                     mov  ah, 3Ch
                     mov  cx, 0                        ; create new file, dx contains file name
                     int  21h
                     jc   create_error
                     mov  si, ax                       ; Save file handle
    convert_file:    
                     call convertFile

    close_files:     
                     mov  ah, 3Eh
                     int  21h
                     mov  bx, si                       ; bx contains the output file handle
                     int  21h

                     jmp  endProgram

    cl_error:        
                     mov  dx, offset usageMsg
                     jmp  display_error
    fn_error:        
                     mov  dx, offset filenameError
                     jmp  display_error
    open_error:      
                     mov  dx, offset openError
                     jmp  display_error
    create_error:    
                     mov  dx, offset createError
                     jmp  display_error
    display_error:   
                     mov  ax, @data
                     mov  ds, ax

                     call displayError
                     mov  al, 1                        ; set errorlevel to 1
    endProgram:      

    ; Exit program
                     mov  ah, 4Ch
                     int  21h

convertFile PROC
                     mov  cx, 0                        ; current position in the code
    convert_loop:    
                     mov  ah, 3Fh
                     mov  bx, di                       ; bx contains the input file handle
                     push cx                           ; save code position
                     mov  cx, 1                        ; read one byte
                     mov  dx, offset buffer            ; buffer to read into
                     int  21h
                     pop  cx                           ; save code position
                     cmp  ax, 0                        ; check for end of file
                     je   end_loop
    ; encode the byte
                     push si                           ; save output file handle
                     mov  si, cx                       ; si contains the current position in the code
                     add  si, offset code              ; point to the next character in the code
                     mov  al, byte ptr [si]            ; get the next character in the code
                     cmp  al, 0                        ; check for end of code
                     jne  code_ok
                     mov  si, offset code              ; reset to the beginning of the code
                     mov  cx, 0                        ; reset the code position
    code_ok:         
                     mov  ah, [buffer]                 ; get the byte from the input file
                     xor  al, ah
                     mov  [buffer], al                 ; store the encoded byte
                     inc  cx                           ; increment the code position
                     pop  si                           ; restore output file handle
    ; write the byte to the output file
                     mov  ah, 40h
                     mov  bx, si                       ; bx contains the output file handle
                     push cx                           ; save code position
                     mov  cx, 1                        ; write one byte
                     mov  dx, offset buffer
                     int  21h
                     pop  cx                           ; restore code position
                     jmp  convert_loop
    end_loop:        
                     ret
convertFile ENDP

    ; Reads command line parameters and splits them into input filename, output filename, and code
    ; Assumes DS points to the PSP segment
splitCommandLine PROC
    ; Split the command line into three parts: input filename, output filename, and code
    ; The command line is in the format: <input filename> <output filename> <code>
    ; The three parts are separated by spaces
                     mov  ax, @data                    ; Load the data segment address into AX
                     mov  es, ax                       ; Set ES to point to the data segment
                     mov  si, 81h                      ; SI points to the start of the command line text in PSP

                     mov  cl, [si-1]                   ; Load command line length into CL from PSP
                     xor  ch, ch                       ; Clear CH, now CX = command line length
                     inc  si                           ; Adjust SI to skip the length byte

                     lea  di, inputFilename            ; DI points to the destination buffer in the data segment
                     mov  bl, 0                        ; counter for input filename length
    loop1:           
                     cmp  bl, 12
                     jg   filename_error
                     cmp  cx, 0
                     je   split_error
                     mov  al, ds:[si]                  ; Load the current character into AL
                     cmp  al, ' '                      ; Compare with space character
                     je   endloop1                     ; If space, end of input filename
                     cmp  al, 0Dh                      ; Compare with carriage return character
                     je   split_error
                     mov  es:[di], al                  ; Copy the character to the input filename buffer
                     inc  bl                           ; Increment the length of the input filename
                     inc  si                           ; Move to the next character
                     inc  di                           ; Move to the next position in the buffer
                     loop loop1                        ; Repeat until the end of the input filename
    endloop1:        
                     mov  byte ptr es:[di], 0          ; Null-terminate the input filename
                     inc  si                           ; Skip the space character
                     dec  cx                           ; Decrement the length of the command line
                     mov  bl, 0                        ; reset the counter for output filename length
                     lea  di, outputFilename           ; DI points to the destination buffer in the data segment
    loop2:           
                     cmp  bl, 12
                     jg   filename_error
                     cmp  cx, 0
                     je   split_error
                     mov  al, ds:[si]                  ; Load the current character into AL
                     cmp  al, ' '                      ; Compare with space character
                     je   endloop2                     ; If space, end of output filename
                     cmp  al, 0Dh                      ; Compare with carriage return character
                     je   split_error
                     mov  es:[di], al                  ; Copy the character to the output filename buffer
                     inc  bl                           ; Increment the length of the output filename
                     inc  si                           ; Move to the next character
                     inc  di                           ; Move to the next position in the buffer
                     loop loop2                        ; Repeat until the end of the output filename
    endloop2:        
                     mov  byte ptr es:[di], 0          ; Null-terminate the output filename
                     inc  si                           ; Skip the space character
                     dec  cx                           ; Decrement the length of the command line
                     lea  di, code                     ; DI points to the destination buffer in the data segment
    copyCode:        
                     cmp  cx, 0
                     je   split_error
                     mov  al, ds:[si]                  ; Load the current character into AL
                     cmp  al, 0Dh                      ; Compare with carriage return character
                     je   endCopyCode                  ; If space, end of code
                     mov  es:[di], al                  ; Copy the character to the code buffer
                     inc  si                           ; Move to the next character
                     inc  di                           ; Move to the next position in the buffer
                     loop copyCode                     ; Repeat until the end of the code
    endCopyCode:     
                     mov  byte ptr es:[di], 0          ; Null-terminate the code
                     jmp  endSplit
    split_error:     
                     mov  ax, 0FFFFh
                     jmp  endSplit
    filename_error:  
                     mov  ax, 0FFFEh
    endSplit:        
                     ret
    
splitCommandLine ENDP

displayError PROC
                     mov  ah, 09h
                     int  21h
                     ret
displayError ENDP

end start