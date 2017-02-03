#!/usr/bin/python
#
# Copyright 2016 Red Hat | Ansible
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# This is a windows documentation stub.  Actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'status': ['preview'],
                    'supported_by': 'core',
                    'version': '1.0'}

DOCUMENTATION = '''
---
module: win_proxy
version_added: "..."
short_description: Manages the Windows web proxy
description:
    - Sets and removes the Windows web proxy settings
options:
    proxy:
        description:
            - The hostname of the proxy server
        required: true
    enabled:
        description:
            - Boolean value, true if the web proxy should be enabled
        required: true
author: "Colin Heinzmann (@DepthDeluxe)"
'''

EXAMPLES = r'''
- name: Install web proxy
  win_proxy:
    proxy: http://proxy.com:8321
    enabled: true
'''
