%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/**/*.{ex,exs}", "test/**/*.{ex,exs}"],
        excluded: []
      },
      checks: [
        # Change max nesting depth to 3
        {Credo.Check.Refactor.Nesting, max_nesting: 3}
      ]
    }
  ]
}
