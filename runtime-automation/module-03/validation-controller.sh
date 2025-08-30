#!/bin/bash

tee /home/rhel/check_challenege_2.yml << EOF
---
- hosts: localhost
  vars: 
    desired_job_template: 'Network-Banner'
  tasks:
    - name: retrieve Network-Banner job template
      set_fact: 
        network_banner_exist: "{{ query('awx.awx.controller_api', 'job_templates', query_params={ 'name': desired_job_template }, host='localhost', username='admin', password='ansible123!', verify_ssl=False) }}"
 
    - name: print out network_banner_exist var
      debug: 
        msg: "{{ network_banner_exist }}"
      failed_when: network_banner_exist == []

    - name: fail when survey is not enabled
      debug: 
        msg: "Is a survey enabled for {{ desired_job_template }}? {{ network_banner_exist[0].survey_enabled }}"
      failed_when: not network_banner_exist[0].survey_enabled
EOF

sudo chown rhel:rhel /home/rhel/check_challenege_2.yml

su - rhel -c 'ansible-playbook /home/rhel/check_challenege_2.yml'

if [ $? -eq 0 ]; then
    echo OK
else
    echo "The job 'Network-Banner' does not have the survey enabled"
fi