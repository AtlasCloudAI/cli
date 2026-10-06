# Run: vhs demo/demo.tape (from the repository root).
# First run submits one image; an existing demo/receipt.json is resumed instead.
Output demo.gif
Require atlas
Require jq
Set Shell "bash"
Set FontSize 20
Set Width 1060
Set Height 700
Set Framerate 10
Set PlaybackSpeed 2
Set WindowBar Rings
Env PS1 "$ "
Env NO_COLOR "1"
Hide
Type "clear"
Enter
Show
Type "bash demo/demo.sh"
Enter
Wait+Screen@3m /DEMO_STOPPED/
Sleep 4s
