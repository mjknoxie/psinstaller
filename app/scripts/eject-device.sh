#!/bin/bash
# Copyright (C) 2025 Maged Mokhtar <mmokhtar <at> petasan.org>
# Copyright (C) 2025 PetaSAN www.petasan.org


# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.




DEVICE=$1
SLEEP_SEC=3

touch /etc/mtab
eject $DEVICE

sleep $SLEEP_SEC







