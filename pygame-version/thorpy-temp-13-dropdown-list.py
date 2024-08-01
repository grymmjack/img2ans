"""We show here how to set up a drop down list (list of predefined choices that the user can click)"""

import pygame, thorpy as tp

pygame.init()

W, H = 1200, 700
screen = pygame.display.set_mode((W,H))
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme

bck = pygame.image.load(tp.fn("data/bck.jpg")) #load some background pic for testing
bck = pygame.transform.smoothscale(bck, (W,H))
def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.blit(bck, (0,0)) #blit background pic
tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.

ddl1 = tp.DropDownListButton(("One", "Two", "Three"))
ddl1_labelled = tp.Labelled("First example", ddl1)

ddl2 = tp.DropDownListButton(("One", "Two", "Three"), title="Two", choice_mode="h")
ddl2_labelled = tp.Labelled("Second example", ddl2)

#all the arguments except the first one (the actual choices) are optional:
ddl3 = tp.DropDownListButton(("Beginner", "Intermediate", "Expert", "Pro"),
                                title=None, #by default, will take the first value
                                choice_mode="v", #'v' for vertical or 'h' for horizontal
                                align="left", #how to align choices in the list
                                launch_nonblocking=False, #launch mode
                                size_limit=("auto","auto"), #limit size of the list of options
                                all_same_width=True, #all choices same width
                                generate_shadow=(True, "auto"))#[0] : does generate shadow ? [1] : fast method or accurate method ? you can set [1] = "auto"

ddl3_labelled = tp.Labelled("Third example", ddl3)

#to get the value of any my_ddl, just call my_ddl.get_value()

group = tp.Box([ddl1_labelled, ddl2_labelled, ddl3_labelled])
group.center_on(screen)
group.get_updater().launch()
pygame.quit()

