---
name: Extend app persistence
description: Extends the persistence data model of the app. Use whenever the datamodel of the app should change 
---

## Instructions

The app uses a Sqlite database which is shipped with the sqflite package for flutter. Follow this
flow:

1. Check the folder `/lib/persistence/model` for any existing dart files containing the database
   model and get familiar with the current model
2. Check whether the current model fits the requirements mentioned in the prompt

When any changes are needed for the datamodel first plan the changes and show the sugested changes
to the user. After confirmation implement the changes.

When a new database entity was added, place a corresponding SQL-Command in the
folder `/persistence/sql` and name this file along the name of the entity  (for example the
sql-command for creating a game model in the database defined in the file `game.dart` should be
named `game.sql.dart`). When opening the database ensure that this SQL statement is executed if the
corresponding table is not yet existant.

When an already existing entity was modified, place a corresponding update script inside the file
containing the sql command for this entity and make sure, that this script is executed on opening
the database.

For now always assume that the version of the database is v1.0.0. Inside `persistence` folder there
should be a single database service placed, which serves as the single entry point for the entire
game to perform read and write operations on the database. When creating new methods, always place
them there.