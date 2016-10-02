# Track periodic goals

A simple iPhone app to track recurring periodic goals as an example for the application of functional programming principles in Swift. In particular, it illustrates the following three concepts:

1. The use of value types to define an immutable model.
2. The use of enums with associated types to keep track of UI modes (UI state machine).
3. The use of FRP-ish change streams to propagate updates in a structured manner.

## Scope

The app is quite minimal on purpose. However, the following is a list of improvments that will make it into a more comprehensive example:

* The model needs to be persistent.
* The detail view needs to support editing all properties of a goal.
* It ought to be possible to re-order goals.
* Time needs to elapse (i.e., generate changes from a timer).
* Thread edit steams to the appropriate data sources and make them inaccessible from other parts of the app. (Maybe also distinguish between `Observable` and `Announcable`.)
* Improve the overview screen by displaying completion as an "activity" circle (instead of just a percentage).
* Print frequency in words.
