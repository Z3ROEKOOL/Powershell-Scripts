# https://stackoverflow.com/questions/19824799/how-to-send-ctrl-or-alt-any-other-key
Sleep 9180
[System.Windows.Forms.SendKeys]::SendWait("+{F10}") 