# LiveView Scoring App

Live scoring app built with volleyball in mind.

## Scope

Make the management and execution of a volleyball tournament easier for both the organisers and for the scorers / duty team.


### Various Helpers

- Timeouts remaining
- Substitutions remaining
- Timer during timeout
- Who's serving indicator (team and player number?)
- Optional current rotation pop-up


### Scoresheet generation

- Game start / end
- Set start / end
- Player numbers
    - Tracking substitutions
    - Input for teams (player numbers)
- Timeouts
- Violations
- Court-side / serving team
- Signatures at end of game
    - At-a-glance summary of match results

#### Pre-game setup requirements

- Serving side
- Player list confirmation
> The above could potentially be out-of-order

Consider some sort of rotation helper:
- scorer needsd to track serving player
- need to confirm rotation at the start of each set


### Match Generation

#### Required information to start a match / generate a match:

- Name of tournament (optional)
- Teams
    - Player names
    - Associated player numbers
    - Captains
    - Coaches
- Format of match
    - can be configured for full tournament
    - will most likely be something different during semi-finals or finals
- Pre-fill information (optional)
    - Courts
    - Time slots

