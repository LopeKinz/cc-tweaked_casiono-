# Minecraft Casino - ComputerCraft: Tweaked

A complete casino system for Minecraft 1.21.1 with the "All the Mods 10" modpack (Version 5.0).

**[🇩🇪 Deutsche Version](README_DE.md)**

## 🎰 Features

### **16 Different Casino Games!**

#### 🎰 Classic Casino Games:
- **Slot Machine** - 3 reels, 6 symbols, up to 100x win
- **Roulette** - European roulette with all betting options
- **Blackjack** - Hit, Stand, Double Down against dealer
- **Baccarat** - Player, Banker or Tie

#### 🎲 Dice & Coins:
- **Coin Flip** - Heads or tails, simple and fast
- **Dice** - 2 dice with 6 betting options

#### 🃏 Card Games:
- **High/Low** - Guess higher or lower, build streak
- **War** - Classic card war

#### 🚀 Modern Casino Games:
- **Crash** - Multiplier rises, cashout before crash!
- **Mines** - Find safe fields, avoid mines
- **Tower** - Climb the tower, choose the right path

#### 🎪 Special Games:
- **Plinko** - Ball falls through pins, multipliers up to 100x
- **Wheel of Fortune** - Spin the wheel
- **Keno** - Number lottery, choose 3-10 numbers
- **Scratch Cards** - Scratch cards, find 3 matching symbols
- **Horse Racing** - Bet on horses in race

### 🌟 System Features:
- **Automatic Inventory Management** with RS Bridge
- **Complete Touch Control** (no sliders!)
- **Player Detection** with name selection (15 block range)
- **💎 Unlimited Bets** - Bet as many diamonds as you have!
  - Quick select: 1, 5, 10, 25, 50, 100, 500
  - +/- buttons for precise adjustment
  - "ALL IN" button
- **Animations** in all games
- **⚡ One-Click Installation** with automatic installer
- **Auto-Start** on boot

### 🏆 Progression & Rewards:
- **📊 Leaderboard** - Top 10 players in 4 categories (Wins, Level, Biggest Win, Total Won)
- **🎖️ Achievements** - 10 unlockable achievements with notifications
- **💰 Daily Bonus** - Daily diamonds (5 + streak bonus, max 15)
- **📈 Level System** - Collect XP (1 XP per diamond bet), level up
- **🎰 Jackpot** - Progressive jackpot with 0.1% win chance per game
- **📝 Daily Quests** - 3 quests per day with diamond rewards
- **📊 Detailed Statistics** - Track all games, win rates, profit
- **📜 Game History** - Show last 20 games
- **🏅 Player Ranks** - Global leaderboard with position
- **💾 Persistent Data** - All data is saved

## 🏗️ Hardware Setup

### Components:
- **1x Advanced Computer**
- **20x Advanced Monitor** (4x5 arrangement) - **right of computer**
- **1x RS Bridge** - **below computer**
- **1x Player Detector** - **on top of computer**
- **1x Double Chest** - **in front of computer**

### Setup:
```
             [Monitor Monitor Monitor Monitor]
             [Monitor Monitor Monitor Monitor]
[Detector]   [Monitor Monitor Monitor Monitor]
[Computer]   [Monitor Monitor Monitor Monitor]
[RS Bridge]  [Monitor Monitor Monitor Monitor]
  [Chest]
```

## 📥 Installation

### ⚡ Automatic Installation (Recommended):

```bash
# On the Advanced Computer:
wget https://raw.githubusercontent.com/LopeKinz/cc-tweaked_casiono-/main/installer.lua installer.lua
installer
```

Or as one-liner:
```bash
wget run https://raw.githubusercontent.com/LopeKinz/cc-tweaked_casiono-/main/installer.lua
```

The installer automatically downloads all 21 files and sets everything up!

### 📋 Manual Installation:

1. Create games directory: `mkdir games`
2. Copy all 21 files to the computer
3. Start casino: `casino`

### 🔧 Auto-Start Setup:

The `startup.lua` is automatically installed and starts the casino on boot!

## 🎮 Usage

1. System automatically detects players within 15 blocks
2. Player selects their name from list
3. Put diamonds in chest
4. Select game and play!

## 📁 File Structure

```
/
├── casino.lua          # Main program
├── ui.lua              # UI library for touch control
├── inventory.lua       # Inventory management (RS Bridge)
├── database.lua        # Player database & statistics
├── features.lua        # Progression features
└── games/
    ├── slots.lua       # Slot Machine
    ├── roulette.lua    # Roulette
    ├── blackjack.lua   # Blackjack
    ├── baccarat.lua    # Baccarat
    ├── coinflip.lua    # Coin Flip
    ├── dice.lua        # Dice
    ├── highlow.lua     # High/Low
    ├── war.lua         # War
    ├── crash.lua       # Crash
    ├── mines.lua       # Mines
    ├── tower.lua       # Tower
    ├── plinko.lua      # Plinko
    ├── wheel.lua       # Wheel of Fortune
    ├── keno.lua        # Keno
    ├── scratch.lua     # Scratch Cards
    └── horses.lua      # Horse Racing
```

## 🔧 Configuration

Peripheral devices are automatically detected:
- RS Bridge: `bottom` (below computer)
- Player Detector: `top` (on computer)
- Monitor: `right` (right of computer)
- Chest: controlled via RS Bridge

## 💎 Diamond System

- Diamonds are automatically counted from chest
- Bets are collected on loss
- Wins are automatically paid out

## 🎲 Game Details

### 🎰 Slot Machine
- **Bet:** 1-∞ diamonds
- **Win:** Up to 100x with 3x dollar
- 3 reels with 6 different symbols

### 🎡 Roulette
- **Bet:** 1-∞ diamonds
- **Bets:** Red/Black (2x), Even/Odd (2x), Numbers (36x)
- Numbers 0-36

### 🃏 Blackjack
- **Bet:** 1-∞ diamonds
- **Win:** 2x (2.5x on blackjack)
- Hit, Stand, Double Down
- Dealer must draw under 17

### 🎴 Baccarat
- **Bet:** 1-∞ diamonds
- **Bets:** Player (2x), Banker (1.95x), Tie (8x)
- Classic baccarat rules

### 🪙 Coin Flip
- **Bet:** 1-∞ diamonds
- **Win:** 2x
- Heads or tails

### 🎲 Dice
- **Bet:** 1-∞ diamonds
- **Win:** 2x to 5x
- Betting options: 7/11, Even/Odd, High/Low, Doubles

### 🃏 High/Low
- **Bet:** 1-∞ diamonds
- **Win:** +0.5x per correct round
- Guess if next card is higher or lower
- Cashout anytime

### ⚔️ War
- **Bet:** 1-∞ diamonds
- **Win:** 2x
- Card war: Higher card wins

### 💥 Crash
- **Bet:** 1-∞ diamonds
- **Win:** Variable (up to 10x)
- Multiplier rises, cashout before crash!

### 💣 Mines
- **Bet:** 1-∞ diamonds
- **Win:** Exponentially increasing
- 5x5 grid, avoid mines
- 3, 5, 7 or 10 mines selectable

### 🗼 Tower
- **Bet:** 1-∞ diamonds
- **Win:** +0.5x per level
- Climb the tower
- 6, 8 or 10 levels

### 🎯 Plinko
- **Bet:** 1-∞ diamonds
- **Win:** 0.5x to 100x
- Ball falls through pins
- 11 multiplier slots

### 🎡 Wheel of Fortune
- **Bet:** 1-∞ diamonds
- **Win:** 2x to 50x (or bankrupt)
- Spin the wheel
- 12 segments

### 🔢 Keno
- **Bet:** 1-∞ diamonds
- **Win:** 2x to 500x
- Choose 3, 5, 7 or 10 numbers
- 20 numbers are drawn

### 🎫 Scratch Cards
- **Bet:** 1-∞ diamonds
- **Win:** 2x to 100x
- Scratch cards: Find 3 matching symbols
- 9 fields to reveal

### 🐴 Horse Racing
- **Bet:** 1-∞ diamonds
- **Win:** 4x
- 4 horses racing
- Animated race

## 📊 Statistics

- **16 games** total
- **~110 KB** code
- **6000+ lines** of Lua code
- **Unlimited** possibilities! 🎰

## 🏆 Progression System

### Level System:
- Earn 1 XP per diamond bet
- Level up every 100 XP
- Unlimited levels

### Achievements (10 total):
1. First Win - Win your first game
2. 10 Wins - Win 10 games
3. 50 Wins - Win 50 games
4. 100 Wins - Win 100 games
5. 100 Games - Play 100 rounds
6. Big Win - Win 50+ diamonds
7. Mega Win - Win 100+ diamonds
8. Level 5 - Reach level 5
9. Level 10 - Reach level 10
10. Loyal Player - 7 day daily streak

### Daily Bonus:
- Base: 5 diamonds
- +1 per streak day
- Maximum: 15 diamonds (10 day streak)

### Quests (3 daily):
1. Play 10 rounds (10 diamonds)
2. Win 5 games (15 diamonds)
3. Play 3x Slots (5 diamonds)

### Jackpot:
- Starts at 100 diamonds
- Grows by 5% of each bet
- 0.1% win chance per game
- Big animation on win!

## 📝 Developed with

- ComputerCraft: Tweaked
- Advanced Peripherals
- Minecraft 1.21.1
- All the Mods 10 Version 5.0

## 🌐 Languages

- 🇬🇧 **English** (this file)
- 🇩🇪 **German** → [README_DE.md](README_DE.md)

---
**Good luck playing! 🎰💎🍀**
