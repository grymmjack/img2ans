"""
We show here how to group elements inside a common parent.
In the first example, the parent is an invisible element.
In the second example, the parent is an instance of thorpy.Box.
"""


import pygame, random
import thorpy

pygame.init()

W, H = 1200, 700
screen = pygame.display.set_mode((W,H))
thorpy.init(screen, thorpy.theme_classic) #bind screen to gui elements and set theme

## *** Example 1 *** (comment out to try)
## group some elements in an invisible element.
# Mode is "h" (horizontal), "v" (vertical), "grid" (with optionnal args nx and ny) or None
group = thorpy.Group([thorpy.Button("GroupOne "+str(i)) for i in range(6)], "grid")

## *** Example 2 *** (comment out to try) : group some elements in a Box element.
## group some elements in a box. If you want a specific sorting fashing, indicate it afterwards.
group2 = thorpy.Box([thorpy.Button("GroupTwo "+str(i)) for i in range(6)], sort_immediately=False)
group2.sort_children("grid", nx=3, ny=2) #nx and ny are optional


metagroup = thorpy.Group([group, group2], gap=20)

#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = metagroup.get_updater()
player.launch()
pygame.quit()

