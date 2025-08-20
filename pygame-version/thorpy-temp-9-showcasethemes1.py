"""This code instantiates the most common types of elements one needs when building a GUI. It also
allows the user to browse some of the default themes. See the showcase number 2 to check all the default themes."""

import pygame
import thorpy as tp

pygame.init()

W,H = 1920, 780 #Full HD
screen = pygame.display.set_mode((W,H))
tp.set_default_font("arial", 20)
tp.init(screen)

bck = pygame.image.load(tp.fn("data/bck.jpg")) #load some background pic for testing
bck = pygame.transform.smoothscale(bck, (int(W*1.2),int(H*1.4)))
def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.blit(bck, (-200,-100)) #blit background pic
tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.


def get_group(group_name, box_cls="box"):
    animals = "Dog Cow Cat Horse Donkey Tiger Lion Panther Leopard Cheetah Bear Elephant"
    buttons = [tp.Button(animal) for animal in animals.split(" ")]
    title_box = tp.TitleBox(group_name, buttons, sort_immediately=False)
    title_box.sort_children("grid", margins=(30,30))
    return title_box

tp.theme_round2()
round2 = get_group("Round2")

tp.themes.theme_game2()
game2 = get_group("Game2")

tp.theme_simple()
simple = get_group("Simple")

tp.theme_human()
human = get_group("Human")

tp.theme_text_dark()
textdark = get_group("Dark text")

tp.theme_game1()
game1 = get_group("Game1")

tp.theme_text()
text = get_group("Text")

tp.theme_round_gradient()
rg = get_group("Round gradient")

tp.theme_classic()
classic = get_group("Classic")

tp.theme_text_outlined()
outlined = get_group("Outlined text")

themes = [human, textdark, game1, round2,  game2, rg, simple, text, classic, outlined]
bigbrother = tp.Group(themes, "grid", nx=3, ny=3)

#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
loop = bigbrother.get_updater()
loop.launch(before_gui)

pygame.quit()


