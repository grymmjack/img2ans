"""We show here how to define the behaviour of a button when it is clicked, dragged and hovered by the user."""

import pygame
import thorpy as tp

pygame.init()

screen = pygame.display.set_mode((1200, 700))
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme

button = tp.Button("Standard button")
button.set_draggable() #set the element as draggable to demonstrate also at_drag method
button.center_on(screen)

def my_function_at_unclick(): #dummy function for the test
    print("Clicked !")
button.at_unclick = my_function_at_unclick #defining standard 'click' function (though its technically not a click)

def my_function_at_drag(dx, dy):  #dummy function for the test ; dx and dy are mandatory !
    print("Element dragged:", dx, dy, ("x- and y-axis movement."))
button.at_drag = my_function_at_drag #defining the function to call when we drag the element.

def my_function_at_hover(a, b, c): #dummy function for the test
    print("Testing events handling:", a,b,c)
button.at_hover = my_function_at_hover #defining the function to call when we start hovering the element.
button.at_hover_params = {"a":"(called at hover)", "b":12, "c":15} #parameters to give at hover

#at_unhover, at_cancel and _at_click are also redifinables (though the last one is discouraged - see the doc).

def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.fill((250,)*3)
tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.

#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = button.get_updater().launch()
pygame.quit()

