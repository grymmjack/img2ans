"""
We show here how to group elements that are themselves groups. Actually, there
is nothing special to do as compared to the example in which we group elements,
but this is comforting to see how it works.

To illustrate grouping, we create here 4 groups of 10 buttons :
1) In the first group, buttons are randomly positionned.
2) In the second group, buttons are vertically sorted.
3) In the third group, buttons are horizontally sorted.
4) In the fourth group, buttons are sorted in 2x5 grid.

At the end, we group the 4 group inside a big group, that is used as the root
of all the app's elements.

Note that instead of grouping elements inside an invisible parent (tp.make_group),
it is also fine to directly put the elements inside another visible element,
such as tp.Box.

For details about how to sort elements, see the examples devoted to sorting.
"""


import pygame, random
import thorpy as tp

pygame.init()

W, H = 1200, 700
screen = pygame.display.set_mode((W,H))
tp.init(screen, tp.theme_classic)

buttons1 = [tp.Button("Group1-"+str(i)) for i in range(10)]
#give random pos for each button, since we did not sort them so far
for b in buttons1:
    b.set_topleft(x=random.randint(0,300), y=random.randint(100,H-100))
group1 = tp.Group(buttons1,None) #group elements without sorting them

#group with vertically sorted elements
group2 = tp.Group([tp.Button("Group2-"+str(i)) for i in range(10)], "v")

#group with horizontally sorted elements
group3 = tp.Group([tp.Button("Group3-"+str(i)) for i in range(10)], "h")
group3.stick_to(screen, "top", "top", delta=(0,5))

#group with a grid of 2x5 elements.
group4 = tp.Group([tp.Button("Group4-"+str(i)) for i in range(10)], None)
group4.sort_children("grid", nx=2, ny=5)
group4.stick_to(screen, "right", "right", delta=(-5,0))

#group the groups.
final_group = tp.Group([group1,group2,group3,group4], None)

#Use the following structure that wraps many non-interesting stuff for you.
player = final_group.get_updater(fps=60)

def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.fill((50,50,50))
tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.

#for the sake of brevity, the main loop is replaced here by a launch over elements
player.launch()
##player.manually_updated = False
pygame.quit()

