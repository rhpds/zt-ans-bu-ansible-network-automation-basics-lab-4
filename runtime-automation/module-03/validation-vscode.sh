#!/bin/bash

#set -euxo pipefail

if [ ! -f /home/rhel/facts.yml ]; then
    echo "No file was found at /home/rhel/facts.yml"
fi

if ! grep "facts" /home/rhel/facts.yml; then
    echo "The facts.yml playbook doesn't contain the facts module"
fi

if ! grep "debug" /home/rhel/facts.yml; then
    echo "The facts.yml playbook doesn't contain the debug module"
fi