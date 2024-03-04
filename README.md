# WordGame

## How much time was invested
8 hours

## How was the time distributed (concept, model layer, view(s), game mechanics)
- Concept         ->  30 minutes
- Model layer     ->  20 minutes
- View            ->  30 minutes
- Architecture    -> 220 minutes
- Game mechanics  -> 120 minutes
- Tests           ->  60 minutes

## Decisions made to solve certain aspects of the game

- I wrote a word service to request new word pairs and mock it for testing.
- I used a controllable clock to control the limited time to tap an answer button.
- I used The Composable Architecture framework to solve problems such as state management, side effects, testing and data flow


## Decisions made because of restricted time

- Simple layout
- Few tests

## What would be the first thing to improve or add if there had been more time

- Custom confirmation dialog
- Error handling
- Test coverage
- Animations
- Localize strings
- File structure (Micro Modules)
