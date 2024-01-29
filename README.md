# BlossomStory

This is a personal project to create a Maplestory-like 2D side scrolling mmorpg game using the Godot 3.5 game engine. It is broken up into a game server, authentication server, gateway server and client executable.
Character sprites from Maplestory were used as templates for the player container. The current release allows local host of the game server, authentication server and gateway server. It is possible to open up multiple
client executables to replicate multiple users logging into the server. Currently the server has one working map that populates monsters and players. You are able to navigate around the map and attack/kill/be killed with
the monsters.

### Prerequisites

Install Godot 3.5 on the running machine

### Installing/Executing
Current release is client authoritative. Server authoritative model with server reconciliation and client prediction has been implemented but not released.<br />
<br />
For client-authoritvative Install: <br />
Download the current release (v1.1.0) .zip from the release section.<br />
Unzip the executable.<br />
<br />
Run the client executable.<br />
<br />
When running the client, test login credentials will be automatically populated<br />
Click on log-in<br />
Once server authenticates user info and client is connected to server, select a character and click on select character<br />
Character will spawn in last map and populated into the server<br />

## Controls

CRTL: Attack<br />
ALT:     Jump<br />
Up       Climb up/ Use Portal<br />
Down     Climb Down<br />
Left:    Move Left<br />
Right    Move Right<br />

## Built With

* [Godot 3.5](https://godotengine.org/article/godot-3-5-cant-stop-wont-stop/) - Game Engine
* [Firebase Authentication](https://firebase.google.com/products/auth) - Account Management
* [Firestore Database](https://firebase.google.com/products/storage) - Server Database

* **Christopher Nguyen** - *Initial work* - [ctopherngoc](https://github.com/ctopherngoc)

