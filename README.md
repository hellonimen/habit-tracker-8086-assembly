# Habit tracker in x86 assembly (16-bit DOS)

A console habit tracker written entirely in 16-bit x86 assembly, in one file of about 1,850 lines. All input, output, file access and timing go through DOS `INT 21H` services, and it uses only 16-bit registers. It is coursework from my assembly language module at Asia Pacific University.

## Features

| Key | Feature |
|---|---|
| `1` | Add a habit (up to 10 habits, 15 characters each) |
| `2` | Mark a habit as done: adds one day to its current streak and updates its best streak |
| `3` | View the habit list and the details of one habit (current streak and best streak) |
| `4` | Delete a habit, with a y/n confirmation |
| `5` | Reset one habit's streak, or all of them |
| `6` / `7` | Statistics and analytics, including a completion rate |
| `9` | Ranking of habits by streak (needs at least three habits) |
| `0` | Streak rewards: Rookie badge at 1+ days, Warrior at 5+, Legend at 10+ |
| `M` | Motivational quotes, picked using the system clock |
| `S` / `L` | Save habits to `habits.txt` and load them back |
| `R` | Write a report to `report.txt` |
| `8` | Exit |

The program starts with a masked password prompt (characters are echoed as `*`).

## Build and run

It needs a DOS environment, for example DOSBox. Assemble and link it with TASM or MASM:

```
tasm habit_tracker.asm
tlink habit_tracker.obj
habit_tracker.exe
```

or, with MASM, `masm habit_tracker.asm;` then `link habit_tracker.obj;`. The default password is `admin`.

## How it is put together

- **Data:** habit names sit in a fixed 150 byte table (10 slots of 15 bytes), with one byte per habit for the current streak and one for the best streak.
- **Input and output:** DOS character input (`AH=01H`, `AH=08H` for the masked password), string output (`AH=09H`), file create, open, read, write and close (`AH=3CH` to `40H`), and the system clock (`AH=2CH`).
- **Structure:** one `MAIN` procedure with the menu loop, and separate procedures for ranking, rewards, quotes, saving and loading, report generation and the login.

## Limitations

- The login is a demonstration, not real authentication. The password is checked with a one-byte XOR and rotate hash, so only 256 hash values exist and many different passwords are accepted.
- Marking a habit does not check the date, so the same habit can be marked twice in one day. Streaks stop at 99 and the number of habits is capped at 10.
- The report header date is written into the program as a fixed string.

## Licence

MIT, see [LICENSE](LICENSE).
