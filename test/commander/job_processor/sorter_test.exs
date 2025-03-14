defmodule Commander.JobProcessor.SorterTest do
  use ExUnit.Case

  alias Commander.JobProcessor.Task
  alias Commander.JobProcessor.Sorter

  test "can sort out list of tasks in topological order" do
    result = Sorter.sort_tasks(long_unsorted_tasks())

    assert result == {:ok, long_sorted_tasks()}
  end

  test "return proper error when a there is a cycle in the dependency tree" do
    tasks = [
      %Task{name: "task-1", command: "", dependencies: ["task-2"]},
      %Task{name: "task-2", command: "", dependencies: ["task-3"]},
      %Task{name: "task-3", command: "", dependencies: ["task-1"]}
    ]

    result = Sorter.sort_tasks(tasks)

    assert result == {:error, {:cycle_detected, ["task-3", "task-2", "task-1"]}}
  end

  test "return proper error when a task depends on itself" do
    tasks = [
      %Task{name: "task-1", command: "", dependencies: ["task-2"]},
      %Task{name: "task-2", command: "", dependencies: ["task-2"]}
    ]

    result = Sorter.sort_tasks(tasks)

    assert result == {:error, {:self_dependency, "task-2"}}
  end

  test "returns proper error when a task depends on a task that does not exist" do
    tasks = [
      %Task{name: "task-1", command: ""},
      %Task{name: "task-2", command: "", dependencies: ["task-1"]},
      %Task{name: "task-3", command: "", dependencies: ["task-2", "task-4", "task-5"]}
    ]

    result = Sorter.sort_tasks(tasks)

    assert result == {:error, {:invalid_dependency, "task-4"}}
  end

  defp long_unsorted_tasks do
    [
      %Task{
        name: "task-23",
        command: "",
        dependencies: ["task-21", "task-12", "task-22", "task-14", "task-3", "task-2", "task-1"]
      },
      %Task{
        name: "task-46",
        command: "",
        dependencies: [
          "task-45",
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-33",
          "task-32",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-43",
        command: "",
        dependencies: [
          "task-42",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34"
        ]
      },
      %Task{
        name: "task-24",
        command: "",
        dependencies: ["task-23", "task-22", "task-21", "task-20", "task-19"]
      },
      %Task{name: "task-9", command: "", dependencies: ["task-8", "task-7", "task-6"]},
      %Task{
        name: "task-42",
        command: "",
        dependencies: [
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-21",
          "task-20",
          "task-19",
          "task-18",
          "task-17"
        ]
      },
      %Task{name: "task-2", command: "", dependencies: ["task-1"]},
      %Task{
        name: "task-14",
        command: "",
        dependencies: [
          "task-13",
          "task-2",
          "task-3",
          "task-12",
          "task-1",
          "task-5",
          "task-8",
          "task-4",
          "task-2"
        ]
      },
      %Task{
        name: "task-25",
        command: "",
        dependencies: [
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-24",
          "task-20",
          "task-18",
          "task-24"
        ]
      },
      %Task{
        name: "task-13",
        command: "",
        dependencies: ["task-12", "task-1", "task-5", "task-8", "task-4", "task-2"]
      },
      %Task{name: "task-3", command: "", dependencies: ["task-2", "task-1"]},
      %Task{
        name: "task-30",
        command: "",
        dependencies: [
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25",
          "task-24",
          "task-23"
        ]
      },
      %Task{name: "task-8", command: "", dependencies: ["task-6", "task-4", "task-7", "task-2"]},
      %Task{
        name: "task-20",
        command: "",
        dependencies: ["task-19", "task-18", "task-17", "task-16"]
      },
      %Task{
        name: "task-6",
        command: "",
        dependencies: ["task-5", "task-4", "task-3", "task-2", "task-1"]
      },
      %Task{
        name: "task-49",
        command: "",
        dependencies: [
          "task-48",
          "task-47",
          "task-46",
          "task-45",
          "task-2",
          "task-3",
          "task-4",
          "task-5",
          "task-6",
          "task-7",
          "task-8",
          "task-9",
          "task-10",
          "task-11"
        ]
      },
      %Task{
        name: "task-31",
        command: "",
        dependencies: [
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25",
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-47",
        command: "",
        dependencies: [
          "task-46",
          "task-45",
          "task-44",
          "task-46",
          "task-20",
          "task-19",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{name: "task-5", command: "", dependencies: ["task-4", "task-3", "task-2", "task-1"]},
      %Task{
        name: "task-38",
        command: "",
        dependencies: ["task-37", "task-36", "task-35", "task-34"]
      },
      %Task{name: "task-33", command: "", dependencies: ["task-32", "task-31", "task-30"]},
      %Task{
        name: "task-45",
        command: "",
        dependencies: [
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-21",
          "task-20",
          "task-19",
          "task-18",
          "task-17"
        ]
      },
      %Task{
        name: "task-15",
        command: "",
        dependencies: ["task-14", "task-13", "task-12", "task-11", "task-10"]
      },
      %Task{name: "task-1", command: "", dependencies: []},
      %Task{
        name: "task-44",
        command: "",
        dependencies: ["task-43", "task-42", "task-41", "task-40", "task-39", "task-38"]
      },
      %Task{
        name: "task-16",
        command: "",
        dependencies: ["task-15", "task-14", "task-13", "task-12"]
      },
      %Task{name: "task-4", command: "", dependencies: ["task-3", "task-2", "task-1"]},
      %Task{
        name: "task-29",
        command: "",
        dependencies: ["task-28", "task-27", "task-26", "task-25"]
      },
      %Task{
        name: "task-17",
        command: "",
        dependencies: ["task-16", "task-15", "task-4", "task-3", "task-2", "task-1"]
      },
      %Task{
        name: "task-48",
        command: "",
        dependencies: [
          "task-47",
          "task-46",
          "task-45",
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-20",
          "task-19",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-36",
        command: "",
        dependencies: ["task-35", "task-34", "task-33", "task-32"]
      },
      %Task{
        name: "task-26",
        command: "",
        dependencies: ["task-25", "task-24", "task-23", "task-22", "task-21"]
      },
      %Task{
        name: "task-22",
        command: "",
        dependencies: ["task-21", "task-20", "task-19", "task-18", "task-17"]
      },
      %Task{
        name: "task-28",
        command: "",
        dependencies: [
          "task-27",
          "task-26",
          "task-25",
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-10",
        command: "",
        dependencies: ["task-9", "task-8", "task-7", "task-6", "task-5"]
      },
      %Task{
        name: "task-11",
        command: "",
        dependencies: ["task-10", "task-9", "task-8", "task-7", "task-6"]
      },
      %Task{
        name: "task-27",
        command: "",
        dependencies: ["task-26", "task-25", "task-24", "task-23", "task-22"]
      },
      %Task{name: "task-7", command: "", dependencies: ["task-6", "task-5", "task-4"]},
      %Task{
        name: "task-19",
        command: "",
        dependencies: [
          "task-16",
          "task-15",
          "task-18",
          "task-2",
          "task-3",
          "task-4",
          "task-5",
          "task-6",
          "task-7",
          "task-8",
          "task-9",
          "task-10",
          "task-11"
        ]
      },
      %Task{
        name: "task-32",
        command: "",
        dependencies: [
          "task-31",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-37",
        command: "",
        dependencies: [
          "task-36",
          "task-35",
          "task-34",
          "task-17",
          "task-13",
          "task-14",
          "task-13",
          "task-12",
          "task-11",
          "task-10"
        ]
      },
      %Task{
        name: "task-39",
        command: "",
        dependencies: [
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-18",
        command: "",
        dependencies: [
          "task-17",
          "task-13",
          "task-14",
          "task-13",
          "task-12",
          "task-11",
          "task-10"
        ]
      },
      %Task{
        name: "task-21",
        command: "",
        dependencies: ["task-20", "task-19", "task-18", "task-17", "task-16"]
      },
      %Task{
        name: "task-12",
        command: "",
        dependencies: [
          "task-2",
          "task-3",
          "task-4",
          "task-5",
          "task-6",
          "task-7",
          "task-8",
          "task-9",
          "task-10",
          "task-11"
        ]
      },
      %Task{
        name: "task-40",
        command: "",
        dependencies: ["task-39", "task-38", "task-37", "task-36", "task-35", "task-34"]
      },
      %Task{
        name: "task-41",
        command: "",
        dependencies: [
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-34",
        command: "",
        dependencies: [
          "task-33",
          "task-32",
          "task-31",
          "task-30",
          "task-29",
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-24",
          "task-20",
          "task-18",
          "task-24"
        ]
      },
      %Task{
        name: "task-50",
        command: "",
        dependencies: [
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-49",
          "task-48",
          "task-47",
          "task-46",
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-21",
          "task-20",
          "task-19",
          "task-18",
          "task-17"
        ]
      },
      %Task{
        name: "task-35",
        command: "",
        dependencies: [
          "task-34",
          "task-33",
          "task-32",
          "task-31",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      }
    ]
  end

  defp long_sorted_tasks do
    [
      %Task{name: "task-1", command: "", dependencies: []},
      %Task{name: "task-2", command: "", dependencies: ["task-1"]},
      %Task{name: "task-3", command: "", dependencies: ["task-2", "task-1"]},
      %Task{name: "task-4", command: "", dependencies: ["task-3", "task-2", "task-1"]},
      %Task{name: "task-5", command: "", dependencies: ["task-4", "task-3", "task-2", "task-1"]},
      %Task{
        name: "task-6",
        command: "",
        dependencies: ["task-5", "task-4", "task-3", "task-2", "task-1"]
      },
      %Task{name: "task-7", command: "", dependencies: ["task-6", "task-5", "task-4"]},
      %Task{name: "task-8", command: "", dependencies: ["task-6", "task-4", "task-7", "task-2"]},
      %Task{name: "task-9", command: "", dependencies: ["task-8", "task-7", "task-6"]},
      %Task{
        name: "task-10",
        command: "",
        dependencies: ["task-9", "task-8", "task-7", "task-6", "task-5"]
      },
      %Task{
        name: "task-11",
        command: "",
        dependencies: ["task-10", "task-9", "task-8", "task-7", "task-6"]
      },
      %Task{
        name: "task-12",
        command: "",
        dependencies: [
          "task-2",
          "task-3",
          "task-4",
          "task-5",
          "task-6",
          "task-7",
          "task-8",
          "task-9",
          "task-10",
          "task-11"
        ]
      },
      %Task{
        name: "task-13",
        command: "",
        dependencies: ["task-12", "task-1", "task-5", "task-8", "task-4", "task-2"]
      },
      %Task{
        name: "task-14",
        command: "",
        dependencies: [
          "task-13",
          "task-2",
          "task-3",
          "task-12",
          "task-1",
          "task-5",
          "task-8",
          "task-4",
          "task-2"
        ]
      },
      %Task{
        name: "task-15",
        command: "",
        dependencies: ["task-14", "task-13", "task-12", "task-11", "task-10"]
      },
      %Task{
        name: "task-16",
        command: "",
        dependencies: ["task-15", "task-14", "task-13", "task-12"]
      },
      %Task{
        name: "task-17",
        command: "",
        dependencies: ["task-16", "task-15", "task-4", "task-3", "task-2", "task-1"]
      },
      %Task{
        name: "task-18",
        command: "",
        dependencies: [
          "task-17",
          "task-13",
          "task-14",
          "task-13",
          "task-12",
          "task-11",
          "task-10"
        ]
      },
      %Task{
        name: "task-19",
        command: "",
        dependencies: [
          "task-16",
          "task-15",
          "task-18",
          "task-2",
          "task-3",
          "task-4",
          "task-5",
          "task-6",
          "task-7",
          "task-8",
          "task-9",
          "task-10",
          "task-11"
        ]
      },
      %Task{
        name: "task-20",
        command: "",
        dependencies: ["task-19", "task-18", "task-17", "task-16"]
      },
      %Task{
        name: "task-21",
        command: "",
        dependencies: ["task-20", "task-19", "task-18", "task-17", "task-16"]
      },
      %Task{
        name: "task-22",
        command: "",
        dependencies: ["task-21", "task-20", "task-19", "task-18", "task-17"]
      },
      %Task{
        name: "task-23",
        command: "",
        dependencies: ["task-21", "task-12", "task-22", "task-14", "task-3", "task-2", "task-1"]
      },
      %Task{
        name: "task-24",
        command: "",
        dependencies: ["task-23", "task-22", "task-21", "task-20", "task-19"]
      },
      %Task{
        name: "task-25",
        command: "",
        dependencies: [
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-24",
          "task-20",
          "task-18",
          "task-24"
        ]
      },
      %Task{
        name: "task-26",
        command: "",
        dependencies: ["task-25", "task-24", "task-23", "task-22", "task-21"]
      },
      %Task{
        name: "task-27",
        command: "",
        dependencies: ["task-26", "task-25", "task-24", "task-23", "task-22"]
      },
      %Task{
        name: "task-28",
        command: "",
        dependencies: [
          "task-27",
          "task-26",
          "task-25",
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-29",
        command: "",
        dependencies: ["task-28", "task-27", "task-26", "task-25"]
      },
      %Task{
        name: "task-30",
        command: "",
        dependencies: [
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25",
          "task-24",
          "task-23"
        ]
      },
      %Task{
        name: "task-31",
        command: "",
        dependencies: [
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25",
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-32",
        command: "",
        dependencies: [
          "task-31",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{name: "task-33", command: "", dependencies: ["task-32", "task-31", "task-30"]},
      %Task{
        name: "task-34",
        command: "",
        dependencies: [
          "task-33",
          "task-32",
          "task-31",
          "task-30",
          "task-29",
          "task-24",
          "task-23",
          "task-22",
          "task-21",
          "task-19",
          "task-24",
          "task-20",
          "task-18",
          "task-24"
        ]
      },
      %Task{
        name: "task-35",
        command: "",
        dependencies: [
          "task-34",
          "task-33",
          "task-32",
          "task-31",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-36",
        command: "",
        dependencies: ["task-35", "task-34", "task-33", "task-32"]
      },
      %Task{
        name: "task-37",
        command: "",
        dependencies: [
          "task-36",
          "task-35",
          "task-34",
          "task-17",
          "task-13",
          "task-14",
          "task-13",
          "task-12",
          "task-11",
          "task-10"
        ]
      },
      %Task{
        name: "task-38",
        command: "",
        dependencies: ["task-37", "task-36", "task-35", "task-34"]
      },
      %Task{
        name: "task-39",
        command: "",
        dependencies: [
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-40",
        command: "",
        dependencies: ["task-39", "task-38", "task-37", "task-36", "task-35", "task-34"]
      },
      %Task{
        name: "task-41",
        command: "",
        dependencies: [
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-42",
        command: "",
        dependencies: [
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-21",
          "task-20",
          "task-19",
          "task-18",
          "task-17"
        ]
      },
      %Task{
        name: "task-43",
        command: "",
        dependencies: [
          "task-42",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34"
        ]
      },
      %Task{
        name: "task-44",
        command: "",
        dependencies: ["task-43", "task-42", "task-41", "task-40", "task-39", "task-38"]
      },
      %Task{
        name: "task-45",
        command: "",
        dependencies: [
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-21",
          "task-20",
          "task-19",
          "task-18",
          "task-17"
        ]
      },
      %Task{
        name: "task-46",
        command: "",
        dependencies: [
          "task-45",
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-33",
          "task-32",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-22",
          "task-21",
          "task-19",
          "task-20",
          "task-18",
          "task-17",
          "task-16",
          "task-30",
          "task-29",
          "task-28",
          "task-27",
          "task-26",
          "task-25"
        ]
      },
      %Task{
        name: "task-47",
        command: "",
        dependencies: [
          "task-46",
          "task-45",
          "task-44",
          "task-46",
          "task-20",
          "task-19",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-48",
        command: "",
        dependencies: [
          "task-47",
          "task-46",
          "task-45",
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-20",
          "task-19",
          "task-18",
          "task-17",
          "task-16"
        ]
      },
      %Task{
        name: "task-49",
        command: "",
        dependencies: [
          "task-48",
          "task-47",
          "task-46",
          "task-45",
          "task-2",
          "task-3",
          "task-4",
          "task-5",
          "task-6",
          "task-7",
          "task-8",
          "task-9",
          "task-10",
          "task-11"
        ]
      },
      %Task{
        name: "task-50",
        command: "",
        dependencies: [
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-49",
          "task-48",
          "task-47",
          "task-46",
          "task-44",
          "task-43",
          "task-42",
          "task-41",
          "task-40",
          "task-41",
          "task-40",
          "task-39",
          "task-38",
          "task-37",
          "task-36",
          "task-35",
          "task-34",
          "task-21",
          "task-20",
          "task-19",
          "task-18",
          "task-17"
        ]
      }
    ]
  end
end
