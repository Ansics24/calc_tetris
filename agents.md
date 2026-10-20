# Purpose of this project

* A game based on flutter flame engine
* core mechanic is based on the classic tetris game
* blocks need to form a valid equation to disappear and earn points

# Coding guidelines

* Make a separate branch before starting your work
* TDD: Always write tests first and show them to me before continuing
* Write the code afterward
* Run `flutter test` to verify all tests pass
* Code, names and comments: Everything in english

# Architecture

* Concerns should be isolated from each other
    * core block mechanic with grid should be independent of solving strategies e.g.
    * Follow clean architecture rules (independence of modules / folders)
    * Use abstractions / interfaces to separate modules from each other
* Use narrowed modules or classes (high cohesive files)
* Open/closed principle: Prefer adding new code instead of changing existing one