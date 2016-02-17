# Atom gulp-task-launcher

Automatically locates a gulpfile.[js|coffee] and displays the tasks. Tasks can be hidden from the interactable listing (such as those that should never be started individually). Tasks can be executed manually or a default run-on-launch task can be specified.

Features:
 - Toggle with `cmd-alt-g`
 - Stop, restart, run previous, or run default task with the shortcut buttons or keyboard shortcuts (`cmd-alt-[s|r|p|d]`)
 - Executing a task automatically terminates any already running task
 - Uncheck tasks on the settings page to hide them from the task pane


Limitations:
 - Settings pane cannot be updated in real time; reload Atom (`ctrl-alt-r`) if the tasks list isn't correct
 - Settings are not project-specific, i.e. using the plugin on a second project will wipe out the configuration for the first (This will hopefully be fixed soon)
 - Gulp must currently be installed locally in the same directory as the gulpfile (`npm install gulp`)
