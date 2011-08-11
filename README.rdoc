vpoker is a rule engine to build poker bot.
It has a prebuilt integration with openholdem.org
You define your rules in one or multiples yaml files. Put them in a directory
and then load the strategy with bot file.

==Examples:

preflop.yaml.vpk:

<code>
rules:
    - Hole Cards. AA; KK: ~check raise late position or bet

    - Hole Cards. QQ; JJ: bet

    - Hole Cards. TT; 99:
        - Position. early: ~limp or call one bet
        - call bet or open

    - Hole Cards. 88; 77:
        - Position. early: ~limp or call one bet
        - ~enough callers limp or call one bet
 
with:
    check raise late position or bet:
        - Preflop Betting. fold to me | Position. button: check raise
        - bet
  
    enough callers limp or call one bet:
        - Action Round. 1 | Player. players before >= 4: ~limp or call one bet
        - Action Round. 2 | Betting. bet; raised: call
  
    enough callers limp:
        - Action Round. 1 | Player. players before >= 4: ~nobet limp
        - Action Round. 2 | Betting. bet: call
  
    nobet limp:
        - limp
        - call bet behind
  
    limp or call one bet:
        - limp
        - call bet
        - call raise behind

  ...etc...

</code>

==Rules
  There are many prefedine rules on:
  * Hole Cards
  * Hand
  * Flop
  * Turn
  * River
  * Bet Round
  * Pot
  
  ....

== Contributing to negative-method
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2010 Vinh Tran. See LICENSE.txt for
further details.
