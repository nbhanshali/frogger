# Frogger
Implementing the popular arcade game Frogger using MIPS assembly, tested using simulated environment within the MARS application.

This project implements the main goal of the game which is to get a frog from the bottom of the screen to one of the safe areas at the top while avoiding obstacles. This frog is controlled using the WASD input keys, where each key makes the frog move one step in the respective direction. This project uses Keyboard and MMIO simulator to take these keyboard inputs and the Bitmap Display to simulate the game.

This project also implements the following additional features:
 1. Display the number of lives remaining
 2. After final player death, display game over/retry screen. Restart the game if the “retry” option is chosen.
 3. Have objects in different rows move at different speeds.
 4. Randomize the size and/or appearance of the logs and cars in the scene.
 5. Add sound effects for movement, losing lives, collisions, and reaching the goal.
 6. Displaying a pause screen or image when the ‘p’ key is pressed, and returning to the game when ‘p’ is pressed again.
 7. Add a time limit to the game.

Bitmap Display Configuration:
 - Unit width in pixels: 8
 - Unit height in pixels: 8
 - Display width in pixels: 256
 - Display height in pixels: 256
 - Base Address for Display: 0x10008000 ($gp)
