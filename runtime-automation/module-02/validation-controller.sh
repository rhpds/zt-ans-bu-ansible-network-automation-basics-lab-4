#!/bin/bash

cat >/tmp/setup-scripts/check_challenege_2.yml << EOF
---
- name: Check controller config for network use cases
  hosts: localhost
  connection: local
  gather_facts: false
  collections:
    - ansible.controller
  vars:
    aap_hostname: localhost
    aap_username: admin
    aap_password: ansible123!
    aap_validate_certs: false
  tasks:
    - name: Get job templates from Automation Controller
      uri:
        url: https://{{ aap_hostname }}/api/controller/v2/job_templates/
        method: GET
        validate_certs: "{{ aap_validate_certs }}"
        user: "{{ aap_username }}"
        password: "{{ aap_password}}"
        force_basic_auth: yes
      register: job_templates

    - name: Print job template names
      debug:
        msg: "{{ job_templates.json.results | map(attribute='name') | list }}"
    
    - name: Extract job template names
      set_fact:
        template_names: "{{ job_templates.json.results | map(attribute='name') | list }}"

    - name: Fail template Network-Banner is not found
      fail:
        msg: "Job template 'Network-Banner' does not exist in Automation Controller!"
      when: "'Network-Banner' not in template_names"

    - name: Extract job template id
      set_fact:
        template_id: >-
          {{
            (job_templates.json.results
                | selectattr('name', 'equalto', 'Network-Banner')
                | map(attribute='id')
                | first )
          }}

    - name: Print job template id
      debug:
        msg: "Job template id : {{ template_id }}"

    - name: Get job templates survey
      uri:
        url: https://{{ aap_hostname }}/api/controller/v2/job_templates/{{ template_id }}/survey_spec/
        method: GET
        validate_certs: "{{ aap_validate_certs }}"
        user: "{{ aap_username }}"
        password: "{{ aap_password}}"
        force_basic_auth: yes
      register: job_templates_survey

    - name: Print job template survey names
      debug:
        msg: "{{ job_templates_survey.json.spec | map(attribute='question_name') | list }}"

    - name: Extract job template survey names
      set_fact:
        template_survey_names: "{{ job_templates_survey.json.spec | map(attribute='question_name') | list }}"

    - name: Fail template surveys are not found
      fail:
        msg: "Job template survey does not exist in Automation Controller!"
      when:
        - "'Please enter the banner text' not in template_survey_names"
        - "'Please enter the banner type' not in template_survey_names"

EOF

/usr/bin/ansible-playbook /tmp/setup-scripts/check_challenege_2.yml

if [ $? -ne 0 ]; then
    echo "You have not created the 'Network-Banner' job template Surveys"
    exit 1
fi