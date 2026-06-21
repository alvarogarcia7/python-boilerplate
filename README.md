# Python Boilerplate

## Getting started - Local python

This project uses [uv](https://docs.astral.sh/uv/) for Python package and virtual environment management.

To set up the project:

```bash
# Install uv (if not already installed)
# See https://docs.astral.sh/uv/getting-started/installation/

# uv will automatically create a virtual environment and install dependencies
uv sync
make test
```

## Getting started - Docker

```bash
make up
make bash
# development
make down
```

## Testing

Run the full suite (type checks, example-based tests and property-based tests):

```bash
make test
```

This project also uses [Hypothesis](https://hypothesis.readthedocs.io) for
property-based testing. See [docs/property-testing.md](docs/property-testing.md)
for what is covered, how to run it (`make test-hypothesis`,
`make hypothesis-stats`) and how to add new properties.
