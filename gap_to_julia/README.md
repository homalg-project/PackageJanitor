# GAP to Julia

This directory contains the Ansible playbook and templates used to generate
Julia packages from selected GAP packages in the CAP project, CategoricalTowers,
and HigherHomologicalAlgebra.

The transpiler is not a general GAP-to-Julia compiler. It applies project-specific
syntax transformations and generates Julia package scaffolding, tests, and
documentation for the packages configured in [site.yml](site.yml).

## Prerequisites

- PackageJanitor checked out at `~/.gap/PackageJanitor`
- GAP packages checked out below `~/.gap/pkg/`
- Julia and Ansible available on `PATH`
- A destination monorepo below `~/.julia/dev/`, such as
  `~/.julia/dev/CAP_project.jl`

The configured package's `target` in [site.yml](site.yml) determines its
destination monorepo. The package source is normally expected at
`~/.gap/pkg/<source>/<package>` and falls back to `~/.gap/pkg/<package>`.

## Generate a package

From this directory, generate or update one configured package with:

```sh
ansible-playbook -i hosts site.yml -l CAP --diff
```

Replace `CAP` with an inventory host from [hosts](hosts). On the first full
generation, the destination monorepo directory must already exist; the playbook
creates the Julia package directory when needed.

The generated package includes a `.generate.sh` helper. From its directory, use
the following targets:

```sh
make gen-basic  # Regenerate transpiled source, tests, and documentation only
make gen        # Regenerate the complete Julia package metadata and scaffolding
make test       # Run the Julia test suite
make git-commit # Commit generated changes after a version bump
make uninstall  # Remove the package from the active Julia environment
```

`make gen-basic` preserves package-level files such as `Project.toml` and
`README.md`. `make gen` regenerates everything including the package-level files.

`make git-commit` stages all changes in the package directory and creates a
commit only when `Project.toml` has a newly added `version` entry. Review the
staged changes before running it. `make uninstall` runs `Pkg.rm` for the
package in Julia's active environment; it does not remove the package files.

## Generate monorepo metadata

Each monorepo has a corresponding `<name>_root` host. For example:

```sh
ansible-playbook -i hosts site.yml -l CAP_project_root --diff
```

This generates the monorepo README, root makefile, subsplit scripts, and GitHub
Actions workflow. At the monorepo root, the generated makefile provides:

```sh
make install    # Develop all packages in the active Julia environment
make uninstall  # Remove each package from active Julia environment
make gen        # Regenerate all packages and monorepo metadata
make test       # Test all packages
make git-commit # Run git-commit for every package
```

## Add or update a package configuration

Add the package name to [hosts](hosts), then add a play to [site.yml](site.yml)
that imports `tasks/julia_package.yml`. At minimum, configure the package name,
GAP source directory, target monorepo, Julia dependencies, and test imports.

Dependencies in `site.yml` are maintained manually. Compare them with the
commented GAP dependencies generated in the package's `Project.toml`, and add
any missing package UUIDs to [files/UUIDs](files/UUIDs).

## Split the tests of a package into several CI jobs

Every package has a `.github/ci_test_groups.yml` which determines the CI jobs
of the package's own `.github/workflows/Test.yml`. If the file does not exist,
`make gen` creates a default one with a single group listing all `.md` files
in `docs/src`. To test certain files in dedicated jobs, edit the file in the
package:

```yaml
ci_test_groups:
  - group: StreamVortexSystem
    files:
      - StreamVortexSystem.g.md
      - StreamVortexSystemLinear.g.md
  - group: AutoDocTests
    files:
      - AutoDocTests.tst.autogen.md
```

Every group becomes one CI job per Julia version testing only the listed
files. `make gen` never overwrites the file; it reads it and regenerates
`.github/workflows/Test.yml` accordingly.

The monorepo workflow collects the groups of all its packages when it runs, so
it tests the same groups in the same jobs, named `<package> (<group>)`. Changes
to a package's `.github/ci_test_groups.yml` take effect there without
regenerating anything. A package without this file is not tested by the
monorepo workflow; run `make gen` in the package to create the default one.

Both `make gen` and `make gen-basic` fail at the very end if the groups do not
list exactly the `.md` files in `docs/src`, e.g. after a new test file has been
transpiled. Add the file to a group (or delete `.github/ci_test_groups.yml` to
get a new default) and run `make gen` again. To test the files of a group
locally, run:

```sh
DOCTEST_FILES=StreamVortexSystem.g.md,StreamVortexSystemLinear.g.md make test
```

## Generated files

The playbook regenerates Julia source files under `src/gap/*.autogen.jl` and
transpiled examples under `docs/src/*.autogen.md`. Treat these as generated
artifacts: make project-specific changes in the GAP source or in this
transpiler, then regenerate.
