# PackageJanitor

## HowTo

1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
2. Add your package to `site.yml` (see existing packages for options).
3. Adapt `hosts` (only packages listed there will be considered).
4. Execute `ansible-playbook -i hosts site.yml --diff --check` (shorthand: `./check`) to see what would be changed.
5. Execute `ansible-playbook -i hosts site.yml --diff` (shorthand: `./apply`) to actually apply the changes.

## Speed up the execution

One can speed up the execution considerably by using the Ansible plugin [Mitogen for Ansible](https://mitogen.networkgenomics.com/ansible_detailed.html).

## FAQ

1. #### Error: `There was an error. Make sure there is a branch named 'doc'.`
   If a package has no release process (and thus no HTML documentation on GitHub Pages), the CI publishes the PDF documentation via a branch named `doc`.
   You have to manually create this branch once.
   If you have activated CircleCI for the repository, create the file `.circleci/config.yml` on the `doc` branch with content
   ```yaml
   version: 2.0
    jobs:
      build:
        branches:
          ignore:
            - doc
   ```
   to disable CircleCI for the `doc` branch.
2. #### Error: `There was an error. Make sure there is a branch named 'gh-pages'.`
   If a package has an automated release process, the CI publishes the release via GitHub Pages and needs a branch named `gh-pages`.
   You have to manually create this branch once.
   If you have activated CircleCI for the repository, create the file `.circleci/config.yml` on the `gh-pages` branch with content
   ```yaml
   version: 2.0
    jobs:
      build:
        branches:
          ignore:
            - gh-pages
   ```
   to disable CircleCI for the `gh-pages` branch.
