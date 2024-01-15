# IMG2ANS

WIP GUI Front-end Conversion for IMG2ANS

![IMG2ANS GUI](img2ans-screenshot.png)

### See:
- [IMG2ANS-25.BAS](IMG2ANS-25.BAS)
- [IMG2ANS-50.BAS](IMG2ANS-50.BAS)
- [IMG2ANS-25-NOICE.BAS](IMG2ANS-25-NOICE.BAS)
- [IMG2ANS-25-RGB.BAS](IMG2ANS-25-RGB.BAS)
- [IMG2ANS-50-RGB.BAS](IMG2ANS-50-RGB.BAS)

## USAGE
- Run the program
- Browse for image files to convert
- Enter sauce information (and optionally include it)
- Choose Font Options
- Choose Color Options
- Click Convert

### 8px Font (80x50 mode)

This is the closest you can get to 1:1 for pixel art conversion. The converted pixel is turned into a 8x8 square character, and intended to be viewed with an 8px font (sauce configuration saved).

### 16px Font (80x25 mode)

In this mode, pixel art can be converted perfectly 1:1 but the versatility required by the 16x8px font helps so it uses full block, and half blocks to convert. It does it's best to minimize the requirement of iCE Colors.

## iCE Colors (High Intensity BG no Blink)

In traditional text mode (SCREEN 0), high intensity background colors are not allowed and will instead cause the text to blink. In iCE Color mode, the blinking is disabled. In QB64 this is the same thing that happens when you use `_NOBLINK` in text screen modes.

## RGB 24 Bit Color

If this is unchecked, the palette to be used will be the DOS CGA/EGA 16 color palette. 

If this is checked, the palette is unrestricted and `CSI;r;g;bt` method of color change is used instead.

In RGB 24 bit, you can convert any pixel art to ANSI text mode 1:1 regardless of the source color palette.

If you are not using RGB 24 bit mode, the source image must use the DOS CGA/EGA 16 color palette, or colors will not map properly for conversion.


### SAUCE Support
Sauce support includes:
- Font size
- iCE Colors ON/OFF
- Canvas Width
- Canvas Height
- Author
- Title
- Group
- Comments
- Date


## COMPILING AND BUILDING / INSTALLATION

You need InForm-PE. I recommend checking out this repo adjacent as a sibling to
IMG2ANS like so:

> If you have checked out img2ans in `~/git/img2ans` ...

`cd ~/git`  
`gh repo clone a740g/InForm-PE`  

> Read the README for setup of InForm-PE: https://github.com/a740g/InForm-PE/blob/master/README.md

> Symlink InForm-PE to `~/git/img2ans`:

`ln -s ../InForm-PE/InForm`

Now you can build it.