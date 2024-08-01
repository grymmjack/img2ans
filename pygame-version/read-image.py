import pygame
import sys

# Initialize Pygame
pygame.init()

# Load the image from disk
image_path = "resources/images/fiona-img2pal.png"  # Replace with your image path
image = pygame.image.load(image_path)

# Get the dimensions of the image
width, height = image.get_size()

# Create a Pygame window to display the image
screen = pygame.display.set_mode((width, height))
pygame.display.set_caption('Image RGB Extractor')

# Extract RGB values and store them in a 2D list
rgb_values = []
for y in range(height):
    row = []
    for x in range(width):
        # Get the RGB values of the pixel at (x, y)
        r, g, b, _ = image.get_at((x, y))
        row.append((r, g, b))
    rgb_values.append(row)

# Main loop
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # Display the image
    screen.blit(image, (0, 0))
    pygame.display.flip()

# Print the RGB values (optional)
for row in rgb_values:
    for rgb in row:
        print(rgb)

# Quit Pygame
pygame.quit()
sys.exit()
