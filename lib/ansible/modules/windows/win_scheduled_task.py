#!/usr/bin/python
# -*- coding: utf-8 -*-
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

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'metadata_version': '1.0',
                    'status': ['preview'],
                    'supported_by': 'community'}


DOCUMENTATION = r'''
---
module: win_scheduled_task
author: "Peter Mounce"
version_added: "2.0"
short_description: Manage scheduled tasks
description:
    - Manage scheduled tasks
notes:
    - This module requires Windows Server 2012 or later.
options:
  name:
    description:
      - Name of the scheduled task
    required: true
  description:
    description:
      - The description for the scheduled task
  enabled:
    description:
      - Enable/disable the task
    choices:
      - yes
      - no
    default: yes
  state:
    description:
      - State that the task should become
    required: true
    choices:
      - present
      - absent
  user:
    description:
      - User to run scheduled task as
  executable:
    description:
      - Command the scheduled task should execute
    aliases: [ execute ]
  arguments:
    description:
      - Arguments to provide scheduled task action
    aliases: [ argument ]
  frequency:
    description:
      - The frequency of the command, not idempotent
      - C(interval) added in Ansible 2.4
      - C(hourly) added in Ansible 2.4
    choices:
      - once
      - interval
      - hourly
      - daily
      - weekly
  time:
    description:
      - Time to execute scheduled task, not idempotent
  days_of_week:
    description:
      - Days of the week to run a weekly task, not idempotent
    required: false
  interval:
    description:
      - When frequency is set to interval, time between executions, units are set by "interval_unit"
    required: false
    version_added: "2.4"
  interval_unit:
    description:
      - Unit of time between interval, can be seconds, minutes, hours, days
    default: minutes
    version_added: "2.4"
  path:
    description:
      - Task folder in which this task will be stored - creates a non-existent path when C(state) is C(present),
        and removes an empty path when C(state) is C(absent)
    default: '\'
'''

EXAMPLES = r'''
# Create a scheduled task to open a command prompt
- win_scheduled_task:
    name: TaskName
    description: open command prompt
    executable: cmd
    arguments: -opt1 -opt2
    path: \example
    time: 9am
    frequency: daily
    state: present
    enabled: yes
    user: SYSTEM

# create an interval task to run every 12 minutes starting at 2pm
- win_scheduled_task:
    name: IntervalTask
    execute: cmd
    frequency: interval
    interval: 12
    time: 2pm
    path: example
    enable: yes
    state: present
    user: SYSTEM

'''
