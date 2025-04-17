#!/usr/bin/env tclsh

package require Tk

wm title . "Braille Builder"

set braille_order {0 1 2 6 3 4 5 7}

proc clear {} {
    global bits
    global braille
    set bits [lrepeat 8 0]
    set braille "⠀"
    display_braille
}

proc to_clipboard {} {
    global braille
    clipboard clear
    clipboard append $braille
}

proc display_braille {} {
    global bits
    global braille
    for {set i 0} {$i < 8} {incr i} {
        if {[lindex $bits $i]} {
            .i.c$i create oval 10 10 30 30 -fill black -outline black
        } else {
            .i.c$i delete all
        }
    }
    .o.l configure -text "Your braille: $braille"
}

proc toggle_bit {bit} {
    global bits
    global braille

    lset bits $bit [expr {![lindex $bits $bit]}]

    set value 0
    for {set i 0} {$i < 8} {incr i} {
        set value [expr {$value | ([lindex $bits $i] << $i)}]
    }

    set char [format %c [expr {0x2800 + $value}]]
    set braille $char

    to_clipboard
    display_braille
}

frame .i
pack .i
for {set col 0} {$col < 2} {incr col} {
    for {set row 0} {$row < 4} {incr row} {
        set idx [expr {$row + $col * 4}]
        set bit [lindex $braille_order $idx]

        button .i.b$bit -text "bit [expr $bit + 1]" -width 6 \
            -command [list toggle_bit $bit]
        grid .i.b$bit -row [expr {$row + 1}] -column [expr $col * 3] -padx 5 -pady 5

        canvas .i.c$bit -width 50 -height 50
        grid .i.c$bit -row [expr {$row + 1}] -column [expr $col + 1]
    }
}

frame .s
pack .s
button .s.clear -text "clear" -bg red -fg white -command {clear}
pack .s.clear

frame .o
pack .o
label .o.l -font "TkDefaultFont 18"
pack .o.l -side left
button .o.copy -text "Copy" -command to_clipboard
pack .o.copy -side left

clear
