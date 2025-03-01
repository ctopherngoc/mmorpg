# Blossom

This is a personal project to create a Maplestory-like 2D side scrolling mmorpg game using the Godot 3.5 game engine. It is broken up into a game server, authentication server, gateway server and client executable.
The current release (v4.1.0) allows dedicated server hosting of the server, the authentication server and gateway server, (it was designed to run on Docker containers). It is possible to open up multiple
client executables to replicate multiple users logging into the server given the user has access to the login information. The server has three working map that populates monsters and players. You are able to navigate around the maps. 
Basic combat system and experience/character progression works. The death/revive animation currently does not work (have not converted to server authoritative death) but players can lose all their hp (can even go negative). There is a working inventory system
and monster have a chance to drop equipments use items and gold. Health recovery is possible through idle standing, double clicking items in inventory or pressing set key-binds. Possible rubber banding could occur if server de-sync happens. This could happen due to hardware reasons in
addition to Godot 3.5 does not have true deterministic locomotion.

On level up you get 5 stat points and after level 2 you get 1 ability point. These can be accessed through the stat window and ability windows.

<br />
The game is currently hosted on a VPS server and local play has been discontinued. Local server instance can be hosted through setting up own Firebase project and generating a x509 certificate/x509 key. See directions below.

### Prerequisites

Install Godot 3.5 on the running machine (possibly needed?)

### Installing/Executing
Current release (v4.1.0) is server authoritative model with server reconciliation and client prediction has been implemented. Although it is implemented, it is not true server authoritative because Godot kinematic is not fully deterministic (uses delta:floats for calculations).<br />
<br />
Install: <br />
Download the current release (v4.1.0) .zip and unzip from the release section<br />
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

### Controls

CRTL: Attack<br />
ALT:     Jump<br />
Up:      Climb up/ Use Portal<br />
Down:    Climb Down<br />
Left:    Move Left<br />
Right:   Move Right<br />
Z:       Loot Drops<br />
Backslash: Key-binds<br />
ESC: Options<br /><br />

Preset controls (alterable)<br />
S: Stats<br />
I: Inventory<br />
E: Equipment<br />
K: Abilities<br />

## Hosting Server Instance

1. Download [Godot 3.5](https://godotengine.org/article/godot-3-5-cant-stop-wont-stop/) (this project does not work with Godot 4)<br />
2. Create a [Google Firebase](https://firebase.google.com/) project (record the project name)<br />
3. Navigate to your Firebase console Project Overview and open up the Project Settings (record project API Key)<br />
4. Setup Firebase Authentication and Cloud Firebase within the Firebase Console<br />
5. In Firebase Authentication, create two accounts GameServer and AuthenticationServer<br />
6. Enable email registration and login in Firebase Authentication<br />
7. In Firebase Database, create three collections: users, characters, items (see image below)<br />
![Screenshot of collection struture in Step 7](local_instance/readme_images/database_structure.png)<br />
8. Clone Blossom Repository<br />
9. Navigate and open /local_instance/client/data/server.json<br />
10. Update json with API Key and Project Name <br />
11. Navigate and open /local_instance/authentication/data/server.json<br />
12. Update json with API Key and Project Name <br />
13. Navigate and open /local_instance/server/data/server.json<br />
14. Update json with API Key and Project Name<br />
15. Copy server, client and gateway folders from the local_host directory into the main Blossom repository folder<br />
16. Open four instances of Godot (GameServer, AuthenticationServer, GatewayServer, Client)<br />
17. Run each instance in the following order: GatewayServer, AuthenticationServer, GameServer, then Client (Wait a few seconds after starting then GameServer before logging into the Client. It takes a moment to call to firebase and parse all the saved data. If you login immediately after the GameServer start, it will try to reference data that is not there and crash)<br />

## Built With

* [Godot 3.5](https://godotengine.org/article/godot-3-5-cant-stop-wont-stop/) - Game Engine
* [Firebase Authentication](https://firebase.google.com/products/auth) - Account Management
* [Firestore Database](https://firebase.google.com/products/storage) - Server Database

* **Christopher Nguyen** - [ctopherngoc](https://github.com/ctopherngoc)

