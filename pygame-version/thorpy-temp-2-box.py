"""
We show here how to declare and use a basic Box or TitleBox.
A box is an element that is used to display other elements (children elements).
A TitleBox has a title whereas a Box doesn't.
"""

import pygame
import thorpy as tp

pygame.init()
screen = pygame.display.set_mode((1200, 700))
tp.init(screen, tp.theme_classic) #bind screen to gui elements and set theme

some_buttons = [tp.Button("Button "+str(i)) for i in range(5)]
some_buttons.append(tp.Text("Try moving the bottom right angle of the box to resize it."))

# box = tp.Box(some_buttons) #version without title
box = tp.TitleBox("My titled box", some_buttons) #version with a title
box.sort_children(margins=(40,40)) #use large margin so we can test negative resize easily
box.set_resizable(True, True)
box.center_on(screen)

def at_refresh():
    screen.fill((255,)*3)

box.get_updater().launch(at_refresh)

pygame.quit()