# PackageJanitor

HowTo:
1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
2. Add your package to `site.yml` (see existing packages for options).
3. Adapt `hosts` (only packages listed there will be considered).
4. Execute `ansible-playbook -i hosts site.yml --diff --check` (shorthand: `./check`) to see what would be changed.
5. Execute `ansible-playbook -i hosts site.yml --diff` (shorthand: `./apply`) to actually apply the changes.
