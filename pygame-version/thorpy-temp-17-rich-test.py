"""
Rich text allows you to define a tag that can be used inside strings to modify the text of gui's
elements.

Text properties that can be modified using tags :
    * Color
Text properties that cannot be modified using tags :
    * Font family
    * Font size
Text properties that are modified at the element level :
    * Text-align
    * Max text width

To mix font families or font sizes, you should rather consider to wrap your elements into a parent
that sorts its elements horizontally.
"""

import pygame
import thorpy as tp

pygame.init()

W, H = 1200, 700
screen = pygame.display.set_mode((W,H))
bck = pygame.image.load(tp.fn("data/bck.jpg"))
bck = pygame.transform.smoothscale(bck, (W,H)) #load some background pic
def before_gui(): #add here the things to do before blitting gui elements
    screen.blit(bck, (0,0)) #blit background pic

tp.init(screen, tp.theme_classic)

some_long_text = """Hello, world.
This is a #RGB(255,0,0)rich# text that should #RGB(0,0,255)automatically be cut# in several lines.
I repeat, this is a rich text that should automatically be cut in several lines."""

#let's replace the \n inserted in the str above. Note that you can manually place line breaks, but
#   we do remove them here as we want to illustrate auto line break only, for pedagogic purpose.
some_long_text = some_long_text.replace("\n", " ")

my_button = tp.Button(some_long_text, generate_surfaces=False)
my_button.set_font_auto_multilines_width(300, refresh=False)
#Arbitrarily choosing '#' as the tag here, but you are free to set whatever you like.
my_button.set_font_rich_text_tag("#") #setting a tag automatically enable rich text (disabled by default)
my_button.set_style_attr("font_align", "r") #font_align is either 'l', 'r' or 'c' (left, right and center)
my_button.center_on(screen)


m = tp.Loop(element=my_button)
clock = pygame.time.Clock()
while m.playing:
    clock.tick(m.fps)
    for e in pygame.event.get():
        if e.type == pygame.QUIT:
            m.playing = False
    m.update(before_gui)
    pygame.display.flip()

pygame.quit()

