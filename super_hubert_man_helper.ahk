#Requires AutoHotkey v2.0
info_gui := Gui(, "Super Hubert Man Joystick Emulator")
info_gui.Opt("-SysMenu")
info_gui.Add("Text",, "-Press R to toggle,`n-WASD to move joystick,`n-T to set the joystick position,`n-Q and E to (inactive) reposition / (active) press buttons,`n-ESCAPE to exit.")
info_gui.Show("NoActivate") ; NoActivate avoids deactivating the currently active window.

x_joystick :=  A_ScreenWidth //2
y_joystick :=  A_ScreenHeight //2
x_button1 := x_joystick
y_button1 := y_joystick
x_button2 := x_joystick
y_button2 := y_joystick

is_active := false
is_button1_ready := false
is_button2_ready := false
is_forward := false
is_backward := false
is_leftward := false
is_rightward := false

move_dist := 100 ; in pixels
move_spd := 3 ; from 0-100, higher means slower, 0 means instant

q::{ ; Button One
    if is_active { ; Press first button
        global is_button1_ready
        is_button1_ready := true
        Sleep(100)
    } else { ; Set first button position
        global x_button1, y_button1
        MouseGetPos &x, &y
        x_button1 := x
        y_button1 := y
    }
}

e::{ ; Button Two
    if is_active { ; Press first button
        global is_button2_ready
        is_button2_ready := true
        Sleep(100)
    } else { ; Set first button position
        global x_button2, y_button2
        MouseGetPos &x, &y
        x_button2 := x
        y_button2 := y
    }
}

r::{ ; Activation toggle
    global is_active
    if is_active {
        is_active := false
    } else {
        is_active := true
    }
    Sleep(50)
}

t::{ ; Set joystick location
    if not is_active {
        global x_joystick, y_joystick
        MouseGetPos &x, &y
        x_joystick := x
        y_joystick := y
    }
}

; Boolean setters for determining
; what direction to move towards.
w::{ ; Forward down
    global is_forward
    is_forward := true
}
w up::{ ; Forward Up
    global is_forward
    is_forward := false
}
a::{ ; Leftward down
    global is_leftward
    is_leftward := true
}
a up::{ ; Leftward up
    global is_leftward
    is_leftward := false
}
s::{ ; Backward down
    global is_backward
    is_backward := true
}
s up::{ ; Backward up
    global is_backward
    is_backward := false
}
d::{ ; Rightward down
    global is_rightward
    is_rightward := true
}
d up::{ ; Rightward up
    global is_rightward
    is_rightward := false
}

; Thread for updating the mouse position dynamically
; according to the booleans that are set with hotkeys.
Update_Mouse_Dynamically(){
    global is_button1_ready, is_button2_ready
    is_pressed := false
    while true { ; While the program is running
        while is_active { ; While the macro is active

            ; Booleans prevent bugs when determining
            ; the correct coordinate offset.
            x_offset := 0
            y_offset := 0
            is_moving := false

            if is_button1_ready or is_button2_ready {
                x := x_button1
                y := y_button1
                if not is_button1_ready {
                    x := x_button2
                    y := y_button2
                }
                SendMode('Event')
                SendEvent('{Click Up}')
                MouseMove(x, y, move_spd)
                SendEvent('{Click}')
                MouseMove(x_joystick, y_joystick, move_spd)
                is_button1_ready := false
                is_button2_ready := false
                is_pressed := false
            } else {
                if is_forward {
                y_offset -= move_dist
                }
                if is_backward {
                    y_offset += move_dist
                }
                if is_leftward {
                    x_offset -= move_dist
                }
                if is_rightward {
                    x_offset += move_dist
                }
                if x_offset != 0 or y_offset != 0 {
                    is_moving := true
                }

                if is_pressed and not is_moving {
                    SendEvent('{Click Up}')
                    is_pressed := false
                }
                if not is_pressed and is_moving {
                    SendEvent('{Click Down}')
                    is_pressed := true
                }

                SendMode('Event')
                MouseMove(x_joystick+x_offset, y_joystick+y_offset, move_spd)
            }
        }
        if is_pressed {
            SendEvent('{Click Up}')
            is_pressed := false
        }
        Sleep(50) ; Wait until is_active
    }
}
Update_Mouse_Dynamically()

Esc::{ ; Exit the program
    if is_active { ; Release held keys
        SendMode("Event")
        SendEvent('{Click Up}')
    }
    ExitApp
}