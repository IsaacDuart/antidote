Mix.install([{:owl, "~> 0.13.1"}])

Code.require_file("lib/ant_colony/ant.ex", __DIR__)
Code.require_file("lib/ant_colony.ex", __DIR__)
Code.require_file("lib/ant_colony/terminal/commands.ex", __DIR__)
Code.require_file("lib/ant_colony/terminal/view.ex", __DIR__)
Code.require_file("lib/ant_colony/terminal.ex", __DIR__)

AntColony.Terminal.run()
