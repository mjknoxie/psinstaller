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




for DEVICE in $(find /sys/class/net/* | grep -e "\/eth\|\/en" | grep -v '\.')
do
  INFO=$(udevadm info "$DEVICE")

  if [[ $(grep "ID_NET_NAME_SLOT"<<<"$INFO" ) ]]; then
    PATH_NAME=$(echo "$INFO" | grep ID_NET_NAME_SLOT | cut -f2 -d = )
  else
    PATH_NAME=$(echo "$INFO" | grep ID_NET_NAME_PATH | cut -f2 -d = )
  fi

  DEV=$(echo "$INFO" | grep INTERFACE= | cut -f2 -d = )
  PCI=$(echo "$INFO" | grep ID_PATH= | cut -f2 -d = | cut -c10- )
  #VENDOR=$(echo "$INFO" | grep ID_VENDOR_FROM_DATABASE | cut -f2 -d =  | tr ',' ' ' )
  #MODEL=$(echo "$INFO" | grep ID_MODEL_FROM_DATABASE | cut -f2 -d = | tr ',' ' ')
  VENDOR=$(lspci | grep $PCI  | cut -d ':' -f3 | tr , ' ' )
  MAC=$(echo "$INFO" | grep ID_NET_NAME_MAC | cut -f2 -d = | cut -c4- | sed 's/.\{2\}/&:/g' | sed 's/.$//' )

  echo "device=$DEV,mac=$MAC,pci=$PCI,model=$VENDOR $MODEL,path=$PATH_NAME"
done

