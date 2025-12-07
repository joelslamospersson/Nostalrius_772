# Nostalrius 7.7 - TFS Server ( Current: TFS 1.2 )

Nostalrius is a 7.7 clone project that has been in development for a long time, it is based on TheForgottenServer 1.2 fork.

- You can find here the most complete 7.72 Tibia replica that has ever been made
- Nostalrius is by 2021, deprecated, and it is far from being a clone to Tibia, only The Violet Project is a true clone.

## Features

### Offline Training System
This server includes a fully functional offline training system that allows players to:
- Select a skill to train while offline (Sword, Axe, Club, Distance, or Magic Level)
- Gain skills automatically while logged out (after sleeping in a bed)
- Train for up to 12 hours offline
- Automatically train Shielding alongside the selected skill
- Minimum offline time: 10 minutes before training applies

**Usage:**
1. Use `/offlinetrain <skill>` command to select a skill (e.g., `/offlinetrain sword` or `/offlinetrain 1`)
2. Click on a bed to start offline training
3. Log out and wait at least 10 minutes
4. Log back in to receive skill gains

## Setup Instructions

### Prerequisites
- CMake 3.5+
- C++ compiler (GCC/Clang)
- MySQL/MariaDB
- LuaJIT

### Configuration

1. Copy the example configuration file:
   ```bash
   cp config.lua.dist config.lua
   ```

2. Edit `config.lua` and configure:
   - MySQL database credentials (mysqlHost, mysqlUser, mysqlPass, mysqlDatabase)
   - Server IP address (ip)
   - Other server settings as needed

3. Run database migrations:
   ```bash
   mysql -u your_user -p your_database < data/migrations/add_offline_training.sql
   ```

### Building

```bash
mkdir build
cd build
cmake ..
make -j$(nproc)
```

The compiled binary will be in the `build/` directory. Copy it to the main directory:
```bash
cp build/tfs ../tfs
```

### Running

```bash
./tfs
```

Or use the provided start script:
```bash
./start.sh
```

## Credits

- Alejandro Mujica (Ezzz in otland) - Main developer and programmer of this game server
- Kevin Luiz (long time friendship, also helped get everything fixed and stable)
- Zakaria Ziady (compromised myself into getting the true formulas of the game server)
- Joriku for continue support on Nostalrius project on this page ( Current github page )

## Tools

- EZItem Editor for Nostalrius https://otland.net/threads/ezitem-editor-for-nostalrius-engine-x64.271823/

## Map Editor

- https://github.com/TwistedScorpio/Map-Editor
