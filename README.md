# TasksOrdering.Umbrella

## Running the tests

Run `mix deps.get` to get the dependencies locally.
To run the unit tests: Run `mix test --only unittest`
To run the integration tests:
1. Run `docker-compose up --build -d` to run the service in detached mode.
2. Run `mix test --only integrationtests` to run the integrationtests.