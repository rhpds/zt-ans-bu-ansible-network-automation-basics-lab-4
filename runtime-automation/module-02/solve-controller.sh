#!/bin/bash

tee /tmp/setup-scripts/banner-survey.json << EOF
{
    "name": "",
    "description": "",
    "spec": [
        {
            "question_name": "Please enter the banner text",
            "question_description": "Please type into the text field the desired banner",
            "required": true,
            "type": "textarea",
            "variable": "net_banner",
            "min": 0,
            "max": 1024,
            "default": "",
            "choices": "",
            "new_question": true
        },
        {
            "question_name": "Please enter the banner type",
            "question_description": "Please choose an option",
            "required": true,
            "type": "multiplechoice",
            "variable": "net_type",
            "min": 0,
            "max": 1024,
            "default": "",
            "choices": "login\nmotd",
            "new_question": true
        }
    ]
}

EOF

tee /tmp/setup-scripts/solve_challenege_2.yml << EOF
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
        survey_enabled: yes
        survey_spec: "{{ lookup('file', '/tmp/setup-scripts/banner-survey.json') }}"
        controller_username: "{{ aap_username }}"
        controller_password: "{{ aap_password }}"
        controller_host: "https://{{ aap_hostname }}"
        validate_certs: "{{ aap_validate_certs }}"
EOF
sudo su - -c "ANSIBLE_COLLECTIONS_PATH=/root/.ansible/collections/ansible_collections/ /usr/bin/ansible-playbook /tmp/setup-scripts/solve_challenege_2.yml"
