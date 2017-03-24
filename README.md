# Track periodic goals

A simple iPhone app to track recurring periodic goals as an example for the application of functional programming principles in Swift. In particular, it illustrates the following three concepts:

1. The use of value types to define an immutable model.
2. The use of enums with associated types to keep track of UI modes (UI state machine).
3. The use of FRP-ish change streams to propagate updates in a structured manner.

## Talks

* This app served as a running example in my talk [A Type is Worth a Thousand Tests](https://speakerdeck.com/mchakravarty/a-type-is-worth-a-thousand-tests). For the version of the app that matches the description and code in that talk, please checkout the tag [one-type-thousand-tests](https://github.com/mchakravarty/goalsapp/tree/one-type-thousand-tests).
* The current version of the app —and especially its use of [functional reactive programmming](https://github.com/mchakravarty/goalsapp/blob/master/Goals/Goals/Changes.swift)— will be discussed in my forthcoming talk at [iOSCon 2017](http://justtesting.org/post/158264281261/do-it-yourself-functional-reactive-programming).

## Scope

The app is quite minimal on purpose. However, the following is a list of improvments that will make it into a more comprehensive example:

* The model needs to be persistent.
* The detail view needs to support editing all properties of a goal.
* It ought to be possible to re-order goals.
* Time needs to elapse (i.e., generate changes from a timer).
* Improve the overview screen by displaying completion as an "activity" circle (instead of just a percentage).
