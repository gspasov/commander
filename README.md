# Commander

Commander is a lightweight service for sorting and executing command-line tasks with dependencies. It provides the flexibility to:

- **Sort tasks** based on execution order, considering dependencies.
- **Execute tasks** sequentially or in parallel (if possible).
- **Generate a Bash script** that executes the tasks in the correct order.

Built with **Elixir** and **Phoenix**, Commander is designed for efficient task execution and dependency management.

## Installation & Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/gspasov/commander.git
   cd commander
   ```

2. **Install dependencies:**

   ```sh
   mix deps.get
   ```

3. **Start the Phoenix server:**
   ```sh
   mix phx.server
   ```
   The API will be available at `http://localhost:4000`.

## Usage

### Request Format

Send a JSON payload with a list of tasks to the API. Each task should have:

- A **name** (string, unique identifier)
- A **command** (the shell command to be executed)
- An optional **dependencies** field (a list of dependent task names)

#### Example Payload

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
      "dependencies": ["task-3"]
    },
    {
      "name": "task-3",
      "command": "echo 'Hello World!' > /tmp/file1",
      "dependencies": ["task-1"]
    },
    {
      "name": "task-4",
      "command": "rm /tmp/file1",
      "dependencies": ["task-2", "task-3"]
    }
  ]
}
```

### API Endpoints

#### **1. Get Ordered Tasks**

Sorts and returns the list of tasks in the correct execution order.

- **Endpoint:** `POST /api/tasks/order`
- **Request Body:** JSON payload with tasks
- **Response:**
  ```json
  {
    "status": "success",
    "data": {
      "tasks": [
        {
          "name": "task-1",
          "command": "touch /tmp/file1"
        },
        {
          "name": "task-3",
          "command": "echo 'Hello World!' > /tmp/file1",
          "dependencies": ["task-1"]
        },
        {
          "name": "task-2",
          "command": "cat /tmp/file1",
          "dependencies": ["task-3"]
        },
        {
          "name": "task-4",
          "command": "rm /tmp/file1",
          "dependencies": ["task-2", "task-3"]
        }
      ]
    }
  }
  ```

#### **2. Get a Bash Script**

Returns a Bash script that executes the tasks in the correct order.

- **Endpoint:** `POST /api/tasks/script`
- **Request Body:** JSON payload with tasks
- **Response:**
  ```sh
  #!/bin/bash
  touch /tmp/file1
  echo 'Hello World!' > /tmp/file1
  cat /tmp/file1
  rm /tmp/file1
  ```

#### **3. Execute Tasks**

Executes the tasks sequentially or in parallel (if possible).

- **Endpoint:** `POST /api/tasks/execute`
- **Request Body:** JSON payload with tasks
- **Query Parameter:** `parallel=true` (optional, if tasks should be executed in parallel)

## Error Handling

Commander returns structured error responses when issues occur. Each error contains:

- `status` → The status of the response.
- `error_code` → A machine-readable identifier for the error.
- `message` → A human-readable description of the error.
- `details` → Additional information about the error.

#### **1. Dependency Cycle Detected**

Returned when a cycle in task dependencies is found.
**Status Code:** `400 Bad Request`

```json
{
  "status": "error",
  "error_code": "DEPENDENCY_CYCLE",
  "message": "A cycle dependency was detected.",
  "details": {
    "cycle": ["task-2", "task-4"]
  }
}
```

#### **2. Invalid Dependency**

Returned when a task references a non-existent dependency.
**Status Code:** `400 Bad Request`

```json
{
  "status": "error",
  "error_code": "INVALID_DEPENDENCY",
  "message": "A task has a dependency that does not exist.",
  "details": {
    "missing_dependency": "task-5"
  }
}
```

#### **3. Validation Failed**

Returned when the input payload is invalid.
**Status Code:** `422 Unprocessable Entity`

```json
{
  "status": "error",
  "error_code": "VALIDATION_FAILED",
  "message": "Input validation failed.",
  "details": {
    "tasks": [
      {
        "field": "name",
        "errors": ["can't be blank"]
      }
    ]
  }
}
```