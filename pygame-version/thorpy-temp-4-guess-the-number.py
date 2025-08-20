"""Minigame example using some thorpy elements and coupling them with user input."""

import pygame, random
import thorpy as tp

# *** Prepare pygame as usual ***
pygame.init()
screen = pygame.display.set_mode((1200, 700))
bck = pygame.image.load(tp.fn("data/bck.jpg")) #load some background pic for testing
bck = pygame.transform.smoothscale(bck, screen.get_size()) #resize background to screen size

# *** Setting up the default style ***
tp.set_default_font(("arialrounded", "arial", "calibri", "century"), font_size=20) 
tp.init(screen, tp.theme_round2) #bind screen to gui elements and set theme

# *** Declare UI elements ***
guess_slider = tp.SliderWithText("Choose a number",
                                 min_value=1, max_value=100, initial_value=50,
                                  length=300, dragger_size=(50,20))
try_guess_button = tp.Button("This is my guess")
hint_text = tp.Text("Guess a number between 1 and 100!", font_size=30, font_color=(255,)*3)
hint_text.set_font_rich_text_tag("#") #will be used to change the color of some letters only
attempts_text = tp.HeterogeneousTexts([("Remaining attempts: ", {"size":30, "color":(255,)*3}),
                                       ("5/5", {"color":(255,0,0), "size":30})])
attempts_view = tp.TitleBox("Attempts", children=[])
attempts_view.set_invisible(True) #will become visible when attemps isn't empty

# *** Grouping elements ***
group1 = tp.Group([guess_slider, try_guess_button])
group1.sort_children("h")
box = tp.Box([hint_text, attempts_text, group1, attempts_view])
box.center_on(screen)
gui_updater = box.get_updater() #will be used to update gui each frame in the main loop

# *** From now on, this is just the game logic ***
number_to_guess = random.randint(1,100)
attempts_left = 5


def refresh_game(): #meant to be called each frame of the game
    screen.blit(bck, (0,0))
tp.call_before_gui(refresh_game) #tells thorpy to call before_gui() before drawing gui.

def validate_guess():
    global attempts_left
    attempts_left -= 1
    last_guess = guess_slider.get_value()
    attempts_view.set_invisible(False)
    if last_guess == number_to_guess:
        game_ended("victory")
    elif last_guess < number_to_guess:
        hint_text.set_text("The number to guess is #RGB(255,0,0)larger# than "+str(last_guess))
        attempts_view.add_child(tp.Text("> " + str(last_guess)), auto_sort=True)
    else:
        hint_text.set_text("The number to guess is #RGB(0,0,255)smaller# than "+str(last_guess))
        attempts_view.add_child(tp.Text("< " + str(last_guess)), auto_sort=True)
    if attempts_left < 1:
        game_ended("defeat")
    attempts_text.children[-1].set_text(str(attempts_left)+"/5")
try_guess_button.at_unclick = validate_guess #call validate_guess when button clicked

def game_ended(result): #called either when player wins or looses.
    global playing, number_to_guess, attempts_left
    if result == "victory":
        title = "You won !"
        message = "Well done. What do you want to do now ?"
    else:
        title = "You lost"
        message = "What do you want to do now ?"
    choice = tp.AlertWithChoices(title, ("New game", "Quit"), message)
    choice.launch_alone() #wait for the user to make a choice
    if choice.get_value() == "New game": #reinit some variables
        number_to_guess = random.randint(1, 100)
        hint_text.set_text("Guess a number between 1 and 100!")
        guess_slider.set_value(50)
        attempts_left = 5
        attempts_view.remove_all_children(auto_sort=True)
        attempts_view.set_invisible(True)
    else:
        playing = False

#Here is a very standard loop that includes only one line to update UI elements.
clock = pygame.time.Clock()
playing = True
while playing:
    clock.tick(60)
    events = pygame.event.get()
    mouse_rel = pygame.mouse.get_rel()
    for e in events:
        if e.type == pygame.QUIT:
            playing = False
        else:
            ... #do your stuff with events
    refresh_game()
    #update Thorpy elements and draw them
    gui_updater.update(events=events, mouse_rel=mouse_rel)
    pygame.display.flip()
pygame.quit()
