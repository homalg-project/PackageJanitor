# PackageMakerAnsible

HowTo:
1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
2. Adapt `pkg_dir` in `site.yml` if necessary.
3. Add your package to `site.yml` (see existing packages for options).
4. Execute `ansible-playbook -i hosts site.yml --diff --check` to see what would be changed.
5. Execute `ansible-playbook -i hosts site.yml --diff` to actually apply the changes.
