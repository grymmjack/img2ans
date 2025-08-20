"""Quick alert pop up example"""

import pygame, thorpy as tp

pygame.init()

screen = pygame.display.set_mode((1200, 700))
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme

def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.fill((250,)*3)

alert = tp.Alert("Congratulations", "That was a nice click.\nNo, really, you performed well.")
alert.generate_shadow(fast=False) #do some styling (optional)

def my_func():
    alert.launch_alone(click_outside_cancel=True) #tune some options if you like
    print("User has chosen:", alert.choice) #here is how to recover user-chosen value

launcher = tp.Button("Please click here")
launcher.at_unclick = my_func #see _example_launch for more options
launcher.center_on(screen)

tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.
#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = launcher.get_updater().launch()
pygame.quit()

