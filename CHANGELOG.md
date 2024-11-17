# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),

## [Unreleased]
- Added translation for CZ by Maca-LSczechforum - for [#13](https://github.com/Peppie84/FS22_BeesRevamp/issues/13)

## [1.1.0.1] - 2024-11-04
- Fixed Number to string conversion for formatting the nectar info for en and it language - for [#16](https://github.com/Peppie84/FS22_BeesRevamp/issues/16)

## [1.1.0.0] - 2024-10-29
- Reduced load while playing with precision farming and calculating the field info
- Added translation for IT by FirenzeIT - for [#7](https://github.com/Peppie84/FS22_BeesRevamp/issues/7)
- Added multiplayer functionality - for [#5](https://github.com/Peppie84/FS22_BeesRevamp/issues/5)
- Added support for more bee hive mods - for [#9](https://github.com/Peppie84/FS22_BeesRevamp/issues/9)
- Fixed a bug for conversion from TerraLife weeks in stock month for the last week in Feb

## [1.0.0.0] - 2024-10-01
- Initial Release

## [0.0.3.0] - 2024-08-24
- English translation of moddesc and helpline - for [#2](https://github.com/Peppie84/FS22_BeesRevamp/issues/2)
- Added overpopulation info to the field info - for [#1](https://github.com/Peppie84/FS22_BeesRevamp/issues/1)
- Fixed a bug with precision farming mod and showing not correct field infos

## [0.0.2.1] - 2024-08-21
- Fix a bug for saving the `monthlyPressureCheck`

## [0.0.2.0] - 2024-08-02
- Adjust the sell price of honey from 10.20 to 5.42
- Added the ability to `decideToSwarm` when played with multiple days per period. One decision per month
- No nectar to honey production within the winter period if still nectar is in the hive
- Increased the bee nectar consumption from 0.000433 to 0.000453 per month
- Fixed the nectar/honey production and consumption when played with multiple days per period.
- The nectar value on the info hud is now displayed in float,2