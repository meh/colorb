ColoRB - Colorify your strings
==============================

Just a gay library to colorify strings, used in packo.

    "lol".white.red.bold                        # Get a bold white string with red background
    "lol".white.red.bold.underlined.standout    # Get an underlined dark red with bright white background

The first color is always the foreground, if you pass a second color it becomes the background.

By default it uses default terminal colors, so you won't get black backgrounds on transparent terminals.

To get a string with default color and specific background just do something like this

    "lol".default.blue  # This will output a default color with blue background string

Colors: default, black, red, green, yellow, blue, magenta, cyan, white
Extra:  default, bold, underline, blink, standout
