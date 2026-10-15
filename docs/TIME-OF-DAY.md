# Battle time of day

For Gen 1, Automatic uses the computer's local system time. Day runs from 06:00 through 17:59; night runs from 18:00 through 05:59. The clock refreshes at most once per minute, including while a battle is active.

System Clock explicitly selects the same source. Manual Day and Night override the clock. Outdoor scenes load separate day/night illustrations and matching mounds; there is no simulated night tint. Caves and ordinary interiors keep their environment-specific illumination.

The shared resolver can use native game time for future adapters. The current Gen 1 adapter passes no game clock, so Automatic always falls back to local system time.
