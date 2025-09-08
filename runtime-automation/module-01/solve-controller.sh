#!/bin/bash

# ansible-playbook /tmp/setup-scripts/network-lab-1/solution_challenge_1.yml

tee /tmp/setup-scripts/solve_challenege_1.yml << EOF
---
- name: setup controller for network use cases
  hosts: localhost
  connection: local
  collections:
    - ansible.controller
  vars:
    aap_hostname: localhost
    aap_username: admin
    aap_password: ansible123!
    aap_validate_certs: false
  tasks:

    - name: Create network banner job template
      ansible.controller.job_template:
        name: "Network-Banner"
        job_type: "run"
        organization: "Default"
        inventory: Network Inventory
        project: "Network Toolkit"
        playbook: "playbooks/network_banner.yml"
        credentials:
          - "Network Credential"
        execution_environment: "Default execution environment"
        state: "present"
        controller_username: "{{ aap_username }}"
        controller_password: "{{ aap_password }}"
        controller_host: "https://{{ aap_hostname }}"
        validate_certs: "{{ aap_validate_certs }}"

EOF
sudo su - -c "ANSIBLE_COLLECTIONS_PATH=/root/.ansible/collections/ansible_collections/ /usr/bin/ansible-playbook /tmp/setup-scripts/solve_challenege_1.yml"
