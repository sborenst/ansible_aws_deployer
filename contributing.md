Ansible Lockdown
================

If you're reading this, hopefully you are considering helping out with this project.

Herein lies the contribution guidelines for helping out with this project. Do take the guidelines here literally, if you find issue with any of them or you see room for improvement, please let us know via a GitHub issue submission.



## Rules ##
* The Ansible [Code of Conduct][coc] still applies.
* To contribute, fork and make a pull request against the master branch.
* All tasks should be in YAML literal.

```yml
# This
- name: Create a directory
  file:
      state: directory
      path: /tmp/deletethis

# Not this
- name: Create a directory
  file: state=directory path=/tmpt/deletethis
```

* There should be no space before a task hyphen

```yml
# This
- name: Do something

# Not this
   - name: Do something
```

* Module arguments should be indented two spaces

```yml
# This
- name: Create a directory
  file:
    state: directory
    path: /tmp/deletethis

# Not This
- name: Create a directory
  file:
      state: directory
      path: /tmp/deletethis
```

* There should be a single line break between tasks
    * Descriptive tags to help with granual execution of tasks
* Tags should be in multi-line format and indented two spaces just like module arguments above

```yml
# This
- name: "Good Task"
  stat:
    path: /etc/hosts.equiv
  register: hosts_equiv_audit
  always_run: yes
  tags:
    - correcttag_1
    - correcttag_2

# Not This
- name: "Bad Task"
  stat:
      path: /etc/hosts.equiv
  register: hosts_equiv_audit
  always_run: yes
  tags: [incorrecttask_1, incorrecttask_2]

```

[coc]:http://docs.ansible.com/ansible/community.html#community-code-of-conduct
