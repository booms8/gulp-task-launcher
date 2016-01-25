# Atom gulp-task-launcher

Automatically locates a gulpfile.[js|coffee] and displays the tasks. Tasks can be hidden from the interactable listing (such as those that should never be started individually). Tasks can be executed manually or a default run-on-launch task can be specified.

Notes:
 - Toggle with 'cmd-alt-g'
 - Stop, restart, run previous, or run default task with the shortcut buttons or keyboard shortcuts (cmd-alt-[s|r|p|d])
 - Executing a task automatically terminates any already running task
 - Uncheck tasks on the settings page to hide them from the task pane
 - Gulp must currently be installed locally in the same directory as the gulpfile ('npm install gulp')
