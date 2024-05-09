# Blossom

This is a personal project to create a Maplestory-like 2D side scrolling mmorpg game using the Godot 3.5 game engine. It is broken up into a game server, authentication server, gateway server and client executable.
The current release (v3.0.0) allows dedicated server hosting of the server, the authentication server and gateway server, (it was designed to run on Docker containers). It is possible to open up multiple
client executables to replicate multiple users logging into the server given the user has access to the login information. The server has two working map that populates monsters and players. You are able to navigate around the maps. 
Basic combat system and experience/character progression works. The death/revive animation currently does not work (have not converted to server authoritative death) but players can lose all their hp (can even go negative). There is a working inventory system
and monster have a chance to drop equipments use items and gold. Health recovery is only possible passively by standing in a position without moving. Possible rubber banding could occur if server de-sync happens. This could happen due to hardware reasons in
addition to Godot 3.5 does not have true deterministic locomotion.

### Prerequisites

Install Godot 3.5 on the running machine

### Installing/Executing
Current release (v3.0.0) is server authoritative model with server reconciliation and client prediction has been implemented. Although it is implemented, it is not true server authoritative because Godot kinematics are not fully deterministic.<br />
<br />
Local Install: <br />
Download the current release (v3.0.0) .zip from the release section. Unzip the executable.<br />
<br />
Run the Authentication executable.<br />
<br />
Run the Gateway executable.<br />
<br />
Run the Server executable.<br />
<br />
Run the Client executable.<br />
<br />

Registering: <br />
On the login screen. Click on the register button and enter in an email and password. When correct information provided you will return to the login screen after two seconds<br />

Logging in: <br />
Enter your log-in credential created on the register screen. <br />
Once server authenticates user info and client is connected to server, create a character by clicking on the create character button. <br />

Creating character:<br />
Follow the on-screen customizable options to create your character. Enter a character name that is at least six characters long. click the verify name button. The server will check for explicit names and if<br />
the display name is taken.If the check pass, click the create character button. You will be redirected back to the character selection screen. Click on your new character and click the select character button.<br />
Character will spawn in and populated into the server<br />

## Controls

CRTL: Attack<br />
ALT:     Jump<br />
Up:      Climb up/ Use Portal<br />
Down:    Climb Down<br />
Left:    Move Left<br />
Right:   Move Right<br />
Z:       Loot Drops<br />

## Built With

* [Godot 3.5](https://godotengine.org/article/godot-3-5-cant-stop-wont-stop/) - Game Engine
* [Firebase Authentication](https://firebase.google.com/products/auth) - Account Management
* [Firestore Database](https://firebase.google.com/products/storage) - Server Database

* **Christopher Nguyen** - [ctopherngoc](https://github.com/ctopherngoc)

