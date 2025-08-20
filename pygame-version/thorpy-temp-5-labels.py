"""
We show here how to labelize elements in an easy way.
NB : you can always access the labeled element as my_label.element.
Also, my_label.get_value() and my_label.set_value() are wrapping the actual labelled element,
so you can call them from the label.
"""

import pygame, random
import thorpy as tp

pygame.init()

screen = pygame.display.set_mode((1200, 700))
tp.init(screen, tp.theme_game1) #bind screen to gui elements and set theme
def refresh():
    screen.fill((255,)*3)

check = tp.Labelled("Checkbox:",tp.Checkbox(True))
radio = tp.Labelled("Radio:",tp.Radio(True))
text_input = tp.Labelled("Text input:",tp.TextInput("", "Type text here"))
slider = tp.SliderWithText("Value:", 10, 80, 30, 100, edit=True) #slider is labelled by default
switch = tp.SwitchButtonWithText("Switch:", ("Foo","Bar")) #switch is labelled by default
ddl = tp.Labelled("DropDownList",tp.DropDownListButton(("Beginner", "Intermediate", "Expert", "Pro"), bck_func=refresh))



group = tp.Box([check,radio,text_input,slider,switch,ddl])
group.center_on(screen)
#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = group.get_updater().launch(refresh)
pygame.quit()

