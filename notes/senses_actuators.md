# Sensors and actuators

## Implementation hiding

The exposed sensors/actuators exposed by KarmaBody hide implementation details of ev3dev devices, presenting them indistinguishably from the simlated devices of KarmaWold

## Function is decoupled from implementation

* Multiple exposed sensors can be implemented by a single physical sensor (e.g. color vs. luminance)
* A exposed sensor can be implemented by a physical actuator (e.g. motor torque)
  
## What is revealed to KarmaAgency

... by KarmaBody and also by KarmaSimulation

A list of exposed sensors and a ist of exposed actuators

Each is described by:

* Type (actuator vs sensor)
* Host (a URL)
* Unique ID
* Affordances
  * Actions (if actuator)
    * Name
  * Senses (if sensor)
    * Name
    * Value domain
  * Refraction (min time between sensing/acting)
