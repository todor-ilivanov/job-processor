# Job Processor

A web API that takes in tasks, where some are dependant on others, and determines the correct order of execution.

## Deployment

The app is built in a Docker container and deployed on [fly.io](https://fly.io/):

https://joprocessor.fly.dev/

## Endpoints

1. `POST /process` - Accepts a list of tasks in the request body (see *Sample Request and Response* for the format). Returns the correct execution order.
2. `POST /process?chained=true` - 
Adding the query parameter fetches the commands in order ready for execution. Using `curl`, they can be run directly from the shell:

```bash
curl -X POST https://joprocessor.fly.dev/process?chained=true
   -H 'Content-Type: application/json'
   -d @sample-request.json | bash
```

## Implementation details

The workflow is as follows:
### 1. `TaskManager` module
   - Responsible for creating tasks (each represented as a process), keeping a mapping of `task_name => pid`
   - Also maintains a map of dependencies, e.g. `task-3 => [task-2, task-4]`, meaning `task-3` must finish before `task-2` and `task-4` can start
   - Gets notified by each task that's finished, then notifies all dependants
   - stores each finished task to a list that will be the final result
  
### 2. `MyTask` module
   - Maintains the task's properties: `name`, `command`, `unfinished_parents` 
   - receives messages from the task manager to update its list of `unfinished_parents`
   - when `unfinished_parents` becomes empty, the task can now execute
   - notifies the task manager process when it's done

## Development

Using [Mix](https://hexdocs.pm/mix/Mix.html):

- `mix deps.get` - fetch dependencies
- `mix compile` - compile the application
- `mix test` - run tests
- `mix run --no-halt` - starts the application
- `iex -S mix run` - starts the application and an interactive shell, which allows quick recompilation 

## Sample Request and Response

### Request

```json
{
    "tasks": [
        {
            "name": "task-1",
            "command":"echo 'Hello World!' > /tmp/file1",
            "requires": [
                "task-2"
            ]
        },
        {
            "name": "task-2",
            "command": "touch /tmp/file1"
        }
    ]
}
```

### Response

```json
[
    {
        "command": "touch /tmp/file1",
        "name": "task-2"
    },
    {
        "command": "echo 'Hello World!' > /tmp/file1",
        "name": "task-1"
    }
]
```
