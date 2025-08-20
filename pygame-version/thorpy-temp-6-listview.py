"""
We show here how to set up a list view. Please also have a look at togglables pool example, which
is quite similar to a list view.
"""

import pygame
import thorpy as tp

pygame.init()
W,H = 1200, 700
screen = pygame.display.set_mode((W, H))
# tp.init(screen, tp.theme_simple) #bind screen to gui elements and set theme
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme

# Below is the actual usage of the list view itself ######################################################
lv = tp.ListView(
                items=["Item "+str(i) for i in range(1,11)], #items of the list view
                initial_value=4, #initial value (you can aldo pass its str content, e.g. 'Entry5')
                togglable_type="toggle",  #either 'toggle', 'radio' or 'checkbox'
                # togglable_look="ToggleButton", #uncomment if you want the items to look like buttons
                # all_same_width=True #uncomment if you want to force all the items to have the same width
                )
#TODO: prend toute largeur
lv.add_item("Bonus item 1", i=3, initial_value=True)
lv.add_item("Bonus item 2")


############################################################################################################

choice = tp.Text("Selected: " + lv.get_value())
# choice = tp.Text("Selected: ")
parent = tp.TitleBox("List View Example", [lv, choice]) #you are free to put the listview in any parent Element.
# parent = tp.Box([viewlist]) #you are free to put the listview in any parent
# parent = tp.Group([viewlist]) #you are free to put the listview in any parent - group is like no parent
parent.center_on(screen)

def refresh():#some function that you call once per frame
    choice.set_text("Selected: " + lv.get_value())
    screen.fill((255,255,255))
        
#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = parent.get_updater().launch(refresh)
pygame.quit()

