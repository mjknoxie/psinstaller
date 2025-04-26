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




#for DEVICE_PATH in $(find /sys/block/* | grep -Ev '\/(ram|ramzswap|loop|zram|fd|sr)'  )
for DEVICE_PATH in $(find /sys/block/* | grep -E '\/(sd|hd|xvd|nvme)'  )
do
  DEVICE=${DEVICE_PATH##*/}
  # size in 512 byte sectors
  SIZE=$(head -n 1 $DEVICE_PATH/size)
  SSD="No"
  ROTATIONAL=$(head -n 1 $DEVICE_PATH/queue/rotational)
  if [ ! -z $ROTATIONAL ] && [ "$ROTATIONAL" -eq "0" ]
  then
    SSD="Yes"
  fi

  FIXED="Yes"
  REMOVABLE=$(head -n 1 $DEVICE_PATH/removable)
  if [ ! -z $REMOVABLE ] && [ "$REMOVABLE" -eq "1" ]
  then
    FIXED="No"
  fi

  # we can query by --path=$DEVICE_PATH or by --name=/dev/$DEVICE
  MODEL=$(udevadm info --query=all --name=/dev/$DEVICE  | grep -oE 'ID_MODEL=.*' | cut -d '=' -f2 )
  if [ -z "$MODEL" ]
  then
    MODEL=$(head -n 1 $DEVICE_PATH/device/model)
  fi

  VENDOR=$(udevadm info --query=all --name=/dev/$DEVICE  | grep -oE 'ID_VENDOR=.*' | cut -d '=' -f2 )
  SERIAL=$(udevadm info --query=all --name=/dev/$DEVICE  | grep -oE 'ID_SERIAL_SHORT=.*' | cut -d '=' -f2 )
  BUS=$(udevadm info --query=all --name=/dev/$DEVICE  | grep -oE 'ID_BUS=.*' | cut -d '=' -f2 )
  if [ ! -z "$BUS" ];
  then
    BUS=$(echo $BUS | tr '[a-z]' '[A-Z]' )
  fi

  echo  device=$DEVICE,size=$SIZE,bus=$BUS,fixed=$FIXED,ssd=$SSD,vendor=$VENDOR,model=$MODEL,serial=$SERIAL
done






