# Turbo Racer Assembly Project

Welcome to Turbo Racer, an exhilarating cars racing game crafted in x86 assembly language. Developed as part of the Microprocessors course at Cairo University, Faculty of Engineering, this project combines creativity and programming expertise to deliver an exciting and enjoyable experience.


## Overview

Turbo Racer offers a thrilling gaming experience where two cars compete on a dynamic track, navigating through obstacles, strategically utilizing powerups, and aiming to cross the finish line first. The game not only tests your racing skills but also challenges your ability to think on your feet.


## Features

- **Dynamic Track Generation:** Experience a fresh challenge every time you play as the track is randomly generated, offering a unique racing environment with each game.
- **Obstacles:** Brace yourself for unpredictable twists and turns! Obstacles are randomly placed on the track, providing an ever-changing landscape to navigate through.
- **PowerUps:** Stay alert as powerups emerge unpredictably throughout the game, with four unique types at your disposal.
   1. **Speed Boost:** Activate the Speed-up powerup to give your car a swift burst of speed, propelling you ahead in the race.
   2. **Speed Reduction:** Deploy the Speed-down powerup to tactically slow down your opponent, adding an extra layer of strategic gameplay.
   3. **Obstacle Generation:** Spice up the competition by utilizing the Obstacle Generation powerup, placing a surprise obstacle behind you for an added challenge.
   4. **Obstacle Pass:** Master the track with finesse using the Pass an Obstacle powerup, allowing you to gracefully navigate past a single obstacle.
- **Dual PC Mode Chatting:** In Dual PC Mode, engage in more than just racing! Switch to a chatting mode for an interactive experience with the other player. Share strategies, discuss the race, or simply enjoy some friendly banter as you navigate through the game.


## Getting Started

1. **Clone the Repository:**
   Begin by cloning the repository to your local machine. Use the following command in your terminal:
   ```
   git clone https://github.com/akramhany/TurboRacer.git
   ```

2. **Assembly using Emulator:**
    Assemble the code using any emulator of your choice. For optimal compatibility, we recommend using the MASM/TASM extension in Visual Studio Code.

3. **Running Modes:**
   - Same Screen Mode: To launch the Same Screen mode, simply run the *Main.asm* file.
   - Dual PC Mode: Run the *Player1.asm* file on one PC, and run the *Player2.asm* on the other one.

**NOTE:** for the Dual PC Mode you would have to link the 2 PCs using an ethernet cable, then configure the connection between them (for more details search on youtube).


## General Guide

1. **Game Modes:**
    - Same Screen: Engage in a shared gaming experience on a single PC, where each player operates with distinct control buttons.
    - Dual PC: Connect to different screens or computers using an Ethernet cable for an extended multiplayer experience.

2. **Controls:**
    - Default Controls: Use the *arrow* keys to move the car, and the *m* key to activate powerups.
    - Same Screen Controls: Player one would use the default controls, and Player two would use *WASD* keys and would activate powerups using *Q* key.