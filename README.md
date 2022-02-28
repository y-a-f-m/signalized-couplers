# signalized-couplers
Factorio mod: Adds signals to allow stations to couple/uncouple trains automatically.

https://mods.factorio.com/mod/Signalized_Couplers

This is a fork of GotLag's original [Automatic Coupler](https://mods.factorio.com/mod/Automatic%20Coupler) mod which was created with the express intent of preserving the open source MIT license so other mod makers can contribute and expand on this code while adding compatibility for 1.0 and beyond.

[Example usage](https://www.youtube.com/watch?v=oe1bUSDDeKs) combined with [Inventory Sensor](https://mods.factorio.com/mod/Inventory%20Sensor) and [Dispatcher](https://mods.factorio.com/mod/Dispatcher) to create an operational rail yard.

---

## Now you can connect/disconnect trains through the magic of circuits!

This mod adds two new virtual signals, couple and uncouple. When a train stops at a station receiving either (or both!) of these signals, it will attempt to couple and/or uncouple the train accordingly. If a station is receiving both signals, it will attempt to couple first, then uncouple.

Coupling/uncoupling only occurs when a train arrives at a station - if a train is already at the station when you send the signal, nothing will happen.

Note that these signals are only read by stations, and only work for trains under automatic control that stop at a station.
### Coupling

If greater than zero, attempts to connect the train to another train in front of it. If less than zero, attempts to connect behind (I guess it's theoretically possible you could get this to work, with very careful timing)
### Uncoupling

If greater than zero, disconnects that many cars from the front of the train, and if less than zero disconnects that many from the rear of the train. If the uncouple value is greater (positive or negative) than the number of wagons in the train, nothing happens.

---

## Known Issues
- Coupling or decoupling a train that has a line assigned through the Smarter Trains mod, will result in the train losing its line assignment. (Carried over from 0.16)
- Localization needed!

---

## Bug Reports & Feature Requests

I encourage anyone interested in submitting a bug report or feature request to do so on the mod's [GitHub](https://github.com/digital-pet/signalized-couplers/issues) issue tracker.

Please be sure to include in the bug report:
- Factorio version
- a list of any other mods you have installed, including the versions of the mods
- screenshots or OBS captures of the issue (if possible)
- any relevant Factorio logs

---

## Contributors

- GotLag (original author)
- SWATim (Bob's Mods compatibility)
- Timmiej93 (0.16 port)
- BitBased (0.16 port)
- Hopewell (bugfixes)
- Daelin (compatibility & bugfixes)
- digital_pet (1.0 port)
- aSemy (high quality signal graphics)
