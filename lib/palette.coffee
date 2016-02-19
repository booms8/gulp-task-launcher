module.exports =
class Palette
    constructor: (@taskArea) ->

    addTask: (task) ->
        @taskArea.append "<li id='#{task}' class='task'>#{task}</li>"
        return

    buildTaskList: (tasks, watchers) ->
        existingTasks = atom.config.get('gulp-task-launcher.tasks')

        @taskArea.html("")
        @taskArea.append "<li>
                            <div id='Stop' class='task'>Stop</div>
                            <div id='Restart' class='task'>Restart</div>
                            <div id='Previous' class='task'>Previous</div>
                            <div id='Default' class='task'>Default</div>
                          </li>"

        for task in existingTasks
            if tasks.indexOf(task) is -1
                atom.config.unset("gulp-task-launcher.#{task}")
                existingTasks = existingTasks.filter (t) -> t isnt task
                if watchers.indexOf(task) isnt -1
                    watchers[watchers.indexOf(task)].dispose()

        for task in tasks
            if atom.config.get("gulp-task-launcher.#{task}") is undefined
                existingTasks.push task
                atom.config.set("gulp-task-launcher.#{task}", true)
                @addTask(task)
            else if atom.config.get("gulp-task-launcher.#{task}")
                @addTask(task)
        atom.config.set('gulp-task-launcher.tasks', existingTasks)
        return
