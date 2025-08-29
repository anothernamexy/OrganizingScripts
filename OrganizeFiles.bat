@echo off
setlocal enabledelayedexpansion

:: Get the path of the directory where the script is located
set "scriptDirectory=%~dp0"

:: Loop through all files in the directory with the naming scheme {str}{int}.{ext}
for %%f in ("%scriptDirectory%*.*") do (
    set "filename=%%~nxf"
    if "!filename!" neq "%~nx0" (
        :: Extract the string, integer, and extension from the filename
        for /F "tokens=1-3 delims=0123456789" %%a in ("!filename!") do (
            set "str=%%a"
            set "int=%%b"
            set "ext=%%c"
        )

        :: Check if the string part is not empty and integer part is numeric
        if "!str!" neq "" (
            if "!int!" geq "0" (
        :: Create the subfolder if it doesn't exist
        set "subfolderPath=%scriptDirectory%!str!"
        if not exist "!subfolderPath!" mkdir "!subfolderPath!"

        :: Move the file to the subfolder
        move "%%f" "!subfolderPath!"
    )
)
)
)

echo Files have been organized into subfolders.
pause