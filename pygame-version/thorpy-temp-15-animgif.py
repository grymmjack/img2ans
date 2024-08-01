"""We load here an animated gif (explosion.gif) and play it on screen.
First version is repeating (loop).
Second version launch once. We also show how to launch it again."""

import sys, pygame, thorpy as tp

pygame.init()

screen = pygame.display.set_mode((1200, 700))
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme

 #we use tp.fn only to refer to internal thorpy path ; use a normal filename !
gif_filename = tp.fn("data/explosion.gif")

my_anim = tp.AnimatedGif(gif_filename, frame_mod=2) #frame_mod controls slowness of the anim

my_anim2 = tp.AnimatedGif(gif_filename,
                            size_factor=(0.5, 0.5), #here we want a small version of the gif
                            loops=1, #number of loops to play ; here we play the gif only once
                            freeze_frame=0) #frame number after loops are finish; None for disappear
my_anim2.hand_cursor = True #show hand cursor when hovering the anim

my_label = tp.Labelled("Click the small image\nto relaunch its animation:", my_anim2, tp.Text)

def launch_gif_again():
    my_anim2.loops = 1
my_anim2.at_unclick = launch_gif_again

def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.fill((150,150,150))
tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.

group = tp.TitleBox("Example of GIF element", [my_anim, my_label])
group.center_on(screen)
#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = group.get_updater().launch()
pygame.quit()

