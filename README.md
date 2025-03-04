# Extask

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

To sort a job with a list of tasks make a `POST` call to `http://localhost:4000/api/tasks/order` and pass the list of tasks as follows:
```json
{
  "tasks": [
    {
      "name": "task-1",
      "command": "touch /tmp/file1"
    },
    {
      "name": "task-2",
      "command": "cat /tmp/file1",
      "requires": ["task-3"]
    },
    {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "requires": ["task-1"]
    },
    {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "requires": ["task-2", "task-3"]
    }
  ]
}
```

To get the tasks sorted in a bash script make a `POST` call to `http://localhost:4000/api/tasks/script` and pass the list of tasks as shown above.

To execute a job with tasks make a `POST` call to `http://localhost:4000/api/tasks/execute` and pass the list of tasks as shown above.
_The request accepts an optional `parallel` path parameter which will execute the tasks concurrently and in parallel (if possible)._