---
name: Write gridmodel test
description: Writes a test for validating actions on a Gridmodel. Use when tests should be written, which are directly or indirectly calling actions with the GridModel class or making assertions on it.
---

## Instructions

Tests calling or asserting a GridModel should always be written against a sample grid setup which
are collected in the folder `/test/block/math/sample_grids`

1. Check the sample_grid folder whether there is a sample grid file which can be reused in the
   wanted test setup
    1. If it can be used: Use it as the GridModel which gets tested
    2. If it can't be used: Create one and follow the instruction mentioned in caption "Cration of a
       new sample grid model"
2. Create the tests using the sample grid model from the previous steps

### Cration of a new sample grid model

When creating a new sample grid model provide the following:

1. A human readable representation of the GridModel (see an example in sample_grid_7x7)
2. One single method creating the model by calling the helper functions defined in
   sample_grid_suport.dart