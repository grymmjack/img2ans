
"""We show here how to extend a Style class to create a custom one and use it as default style."""

import pygame, math, thorpy as tp

pygame.init()


screen = pygame.display.set_mode((1200, 700))
tp.set_default_font("arialrounded", 15)
tp.init(screen, tp.theme_human) #bind screen to gui elements and set theme


#here we will go from a lower level to make polygonal frame for buttons
class MyStyle(tp.styles.TextStyle):
    bck_color = (150,150,150)
    font_color = (250,250,250)
    margins = (16,16)

    def __init__(self):
        super().__init__()
        self.thickness = 1
        self.border_color = (0,0,0)
        self.nframes = 1
        self.frame_mod = 1 #mandatory frame_mod > 0 for animations
        self.color_variation = 0.2   
    
    def generate_images(self, text, arrow=False):
        surfaces = []
        for i in range(self.nframes):
            tmp = self.bck_color
            self.bck_color = (0,0,0,0)
            surface = tp.styles.TextStyle.generate_images(self, text, arrow)[0]
            self.bck_color = tmp
            if self.nframes > 1:
                v =  (1.-self.color_variation) + self.color_variation * math.sin(i*math.pi/self.nframes)
                bck_color = [v*c for c in self.bck_color]
            else:
                bck_color = self.bck_color
            w,h = surface.get_size()
            mx, my = self.margins
            t = self.thickness
            points = (0, my), (mx,0), (w-1,0), (w-1,h-my), (w-mx, h-1), (0,h-1)
            pygame.draw.polygon(surface, bck_color[0:3], points)
            pygame.draw.polygon(surface, self.border_color, points, t)
            self.reblit_text(surface, text, arrow)
            surfaces.append(surface)
        return surfaces
    
    def copy(self):
        c =  super().copy()
        #the properties that you added should be copied
        c.thickness = self.thickness
        c.border_color = self.border_color
        c.nframes = self.nframes
        c.frame_mod = self.frame_mod
        return c


style_normal = MyStyle()
tp.Button.style_normal = style_normal
tp.Button.style_pressed = style_normal.copy()
tp.Button.style_locked = style_normal.copy()
tp.Button.style_hover = style_normal.copy()
tp.Button.style_hover.nframes = 30
tp.Button.style_hover.font_color = (255,0,0)
tp.Button.style_hover.border_color = (255,0,0)
tp.Button.style_hover.thickness = 5

# au lieu de border litteral, faire 2 polygones enchasses 

# tp.TitleBox.style_normal = style_normal

button1 = tp.Button("Hello, world.\nThis is a useless button using my own style.")
button1.generate_shadow(fast=False)

button2 = tp.Button("A second one")
button2.generate_shadow(fast=False)

group = tp.Group([button1, button2], gap=50)


def before_gui(): #add here the things to do each frame before blitting gui elements
    screen.fill((250,)*3)
tp.call_before_gui(before_gui) #tells thorpy to call before_gui() before drawing gui.

#For the sake of brevity, the main loop is replaced here by a shorter but blackbox-like method
player = group.get_updater().launch()
pygame.quit()

