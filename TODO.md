# TODOS

### BeehiveSystemExtended
- [x] Bienen fxFliegen < 10 Grad aufhören
- [x] Variable Produktion an Honig je nach Monat
- [] Im Winter wird der Verbrauch negativ

### Spec:PlaceableBeehiveExtended
- [x] Nektar soll produziert werden aufgrund der Anzahl der Bienen
    - [x] Nektar wird nur von 2/3 der Bienen generiert
    - [x] Im Schnitt dauert eine Flugphase 20 Minuten
    - [x] Jede Flugbiene sammelt 50ul (Mikroliter) Nektar
- [x] Nektar soll nur produziert werden wenn die flugFX aktiv ist
- [x] Durch Nektar wird Honig nachgelagert produziert
    - [x] Tagsüber sind es nur die restlichen 1/3 Bienen die Honig produzieren
        - [x] Nachts sind es aber volle 3/3
    - [x] Umgewandelt werden auch hier pro Stunde 50ul (Mikroliter) pro Biene
    - [x] Das Verhältnis Nektar zu Honig ist 3:1
- [x] Nektar/Honig wird stündlich konsumiert pro Biene
    - [x] Konsum entspricht etwa 16kg auf 5000 Bienen für 6 Monate. (Für die Winterphase)
        - [x] Aktuelle Umsetzung nochmal prüfen!
    - [] Wenn Nektar=0 muss noch der Verbrauch vom Spawner eingebaut werden
- [x] Honig wird nur im Wirtschaftsvolk produziert
- [x] Reichweite erhöhen, 15m-150m sind zu wenig!

### Spec:BeeCare
- [x] Bienen Anzahl wird dem Hive hinzugefügt
- [x] Bienen können sterben - der Hive muss dann ersetzt werden. Effekt: es kommt kein Honig mehr + Infohud die Info ausgeben
- [x] Zwischen März und Juni muss man einmal pro Period an den Kasten und einen Aktionsknopf drücken = Schwarmkontrolle. Macht man das nicht, wird der `Bees` halbiert für das aktuelle Jahr. Im neuen Jahr wird dieser Wert wieder zurückgesetzt.
    - [x] Halbieren der Bienen
    - [x] Schwarmlustig Wahrscheinlichkeit mit 75% pro Monat
    - [x] Aktionsknopf einbauen
- [] Im Okt muss mit Oxalsäure behandelt werden, sonst sterben die Bienen im März. Name der Oxsalsäure: Oxu SIM 22
    - [x] Sterben der Bienen im März (derzeit deaktiviert)
    - [] Mit Oxalsäure behandeln
- [] Wenn der Honig auf 0 fällt im Winter müssen die Bienen sterben
- [x] Beim platzieren der Bienen soll ein Random-Faktor für die anzahl der Bienen benutzt werden.
- [x] Im ersten Jahr ist es nur ein Ableger? Bedeutet, es gibt das erste Jahr kein Honig. Aufgefüttert muss trotzdem im Okt und im Winter wird Honig verbraucht. Schwärmen tun Jungvölker nicht!
- [x] Jedes neue Jahr wird eine neue Bee-Max population ermittelt, damit es etwas variiert.

### Other
- [x] StoreItemPatcher, damit Preise von storeItems angepasst werden können
- [x] SpecializationPatcher, damit bestehende Hives mit neuer Spezialisierung gepatcht werden
- [x] FilltypePatcher, damit der Grundpreis des Honigs angepasst werden kann
- [x] FruitTypePatcher, um den Früchten neue BeeYields zu geben
- [x] FilltypePatcher, FruitTypePatcher, StoreItemPatcher, SpecializationPatcher sollte alles in eine Art `Bootstrap.lua` (main?) gebaut werden
- [x] HilfeSystem für Real-Bees mod einplanen
- [x] PricePerLiter Honig 13.15€ pro Liter = 15€ pro Kilo
- [x] Im FieldInfo Hud anzeigen wie viel Hives influenced sind und wie viel %Bonus es gibt
	 - Muss irgendwie gecached werden, da es sonst zu oft aufgerufen wird!
	 - oder bei nicht influenced fruits direkt ein defualt raushauen
	 - eventuell wenn man auf dem Feld läuft, alle 10pixel oder so
- [] An den Fruchtkalender könnte man neben dem Fruchtnamen eine kleine Biene einblenden, damit man weiß welche Frucht von Bienen profitiert
- [] Alle Werte aus Tabellen in eine XML auslagern
- [x] Im Info-Hud anzeigen wie viele Hives(Völker) im Beehive drin sind
- [x] Im Info-Hud anzeigen wie viele Bienen im Beehive drin sind
- [] Platzieren von Bienenvölker kann nur zwischen Mar-Sep gemacht werden
- [x] Beim platzieren des Volkes, sollte der currentDay wert mit abgespeichert werden um später zu ermitteln, wie alt das Volk ist. Daran kann ermittelt werden, ob es ein Jungvolk oder Wirtschaftsvolk ist
    - [x] Es wird jetzt 'YXMYD0' - X und Y mit dem current ersetzt.
    - [x] Status des Volkes wird bei onYearChanged immer auf Wirtschaftsvolk gesetzt, so muss nichts berechnet werden
    - [x] Der Status wird mit abgespeichert
- [x] BeeBonus muss eventuell beim ernten neu eingerechnet werden, wegen den Hives/ha. - Muss geprüft werden
- [x] Multiplayer



### Todos gewachsen durch die Entwicklung
- [x] Entfernungsberechnung prüfen
- [] Vor der ersten Stunde, nach aktivieren der Mod, ist der Verkaufspreis-Chart falsch, weil er den alten Wert anzeigt. Hier sollte man mal prüfen ob man ein refresh Table auslösen kann
- [x] Alle Zeichenketten in Singlequotes
- [x] Sollen große Hives (10+) auch das 10 fache an Schwärme haben? - Nein
    - Dann müsste man 10 fach Schwarmkontrolle machen
    - Dann müsste 10 fach behandelt werden
    - Dann könnte auch nur ein einzelnes Volk von 10 sterben, usw..