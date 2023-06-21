# 2D MMORPG

This is a personal project to create a Maplestory-like 2D side scrolling mmorpg game using the Godot 3.5 game engine. It is broken up into a game server, authentication server, gateway server and client executable.
Character sprites from Maplestory were used as templates for the player container. The current release allows local host of the game server, authentication server and gateway server. It is possible to open up multiple
client executables to replicate multiple users logging into the server. Currently the server has one working map that populates monsters and players. You are able to navigate around the map and attack/kill/be killed with
the monsters.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Install Godot 3.5 on the running machine

### Installing

Download the current release (v1.0.0) .zip from the repro release section.
Unzip the 4 executables.

Run the executables in the following order:

1. authentication.exe

2. gateway.exe

3. server.exe

4. client.exe

When running the client, test login credentials will be automatically populated
Click on log-in
Select the character and click on select character
Character should connect and populated into the server


## Controls

CRTL: Attack

ALT:     Jump

Up       Climb up/ Use Portal

Down     Climb Down

Left:    Move Left

Right    Move Right

## Built With

* [Godot 3.5](https://godotengine.org/article/godot-3-5-cant-stop-wont-stop/) - Game Engine
* [Firebase Authentication](https://firebase.google.com/products/auth) - Account Management
* [Firestore Database](https://firebase.google.com/products/storage) - Server Database

* **Christopher Nguyen** - *Initial work* - [ctopherngoc](https://github.com/ctopherngoc)

