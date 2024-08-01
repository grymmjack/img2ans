"""
We show here how to set up a list view. Please also have a look at togglables pool example, which
is quite similar to a list view.
"""

import pygame
import thorpy as tp

pygame.init()
W,H = 1200, 700
screen = pygame.display.set_mode((W, H))
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme

lv_left = tp.ListView(
                items=["Item "+str(i) for i in range(1,11,2)], #items of the list view
                initial_value=4, #initial value (you can aldo pass its str content, e.g. 'Entry5')
                )

lv_right = tp.ListView(
                items=["Item "+str(i) for i in range(2,12,2)], #items of the list view
                initial_value=0, #initial value (you can aldo pass its str content, e.g. 'Entry5')
                )


#Now, define the logics of list views that can swap elements
move_right_button = tp.Button(">>>")
def move_right():
    if lv_left.get_number_of_items() > 0:
        item = lv_left.remove_item(lv_left.get_selected_item_index())
        lv_right.add_item(item.text)
        lv_right.set_value_str(item.text)
move_right_button.at_unclick = move_right
lv_left_group = tp.Box([lv_left, move_right_button])

move_left_button = tp.Button("<<<")
def move_left():
    if lv_right.get_number_of_items() > 0:
        item = lv_right.remove_item(lv_right.get_selected_item_index())
        lv_left.add_item(item.text)
        lv_left.set_value_str(item.text)
move_left_button.at_unclick = move_left
lv_right_group = tp.Box([lv_right, move_left_button])

lv_group = tp.Group([lv_left_group, lv_right_group], "h")
lv_group.center_on(screen)


#Standard stuff
def refresh():#some function that you call once per frame
    screen.fill((255,255,255))
        
#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = lv_group.get_updater().launch(refresh)
pygame.quit()

