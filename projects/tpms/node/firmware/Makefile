#  --------------------------------------------------------------------------                                 
#    TyreNode Firmware
#    File name: Makefile
#    Author: Etienne Le Sueur, David Snowdon
#
#    Copyright (C) Etienne Le Sueur, David Snowdon 2009. 
#    
#    Date: 01-10-2009
#  --------------------------------------------------------------------------
#
# 
#  This file is part of Sunswift TyreNode
# 
#  Sunswift TyreNode is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  Sunswift TyreNode is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with Sunswift TyreNode.  If not, see <http://www.gnu.org/licenses/>.

.PHONY: clean

MAIN_NAME=tyre-node
ARCH=msp430
MCU=msp430x149
BUILD_DIR=.
OUTPUT_DIR=../outputs

AS=msp430-as
CC=msp430-gcc
OBJCOPY=msp430-objcopy
OBJDUMP=msp430-objdump

JTAG=msp430-jtag
#JTAG=jtag.py

CFLAGS=-g -O1 -Wall -mmcu=$(MCU) -I../scandal/include -I. -I.. -I../$(MAIN_NAME)
LDFLAGS=-mmcu=$(MCU) 
ASFLAGS=-mmcu=$(MCU) 

all: $(MAIN_NAME).hex $(MAIN_NAME).lst
	cp $(MAIN_NAME).hex $(OUTPUT_DIR)/$(MAIN_NAME).hex

## Copy the .hex and .elf file
 
$(MAIN_NAME).hex: $(MAIN_NAME).elf
	$(OBJCOPY) -O ihex $< $@

$(MAIN_NAME).lst: $(MAIN_NAME).elf
	$(OBJDUMP) -DS $(MAIN_NAME).elf > ${MAIN_NAME}.lst	

## Link the .o files into the .out (.elf) file. 

$(MAIN_NAME).elf :  $(MAIN_NAME).o serial.o led.o sp12t.o spi_driver.o max6675.o
	$(CC) $^ $(LDFLAGS) -o $(MAIN_NAME).elf

## How to build .o, .s and .o files from .c, .c and .s files respectively. 

%.o : %.c 
	$(CC) -c $(CFLAGS) $< -o $@

%.s : %.c
	$(CC) -S $(CFLAGS) $< -o $@

%.o : %.s
	$(AS) -c $(ASFLAGS) $< -o $@

## How to build individual

$(BUILD_DIR)/scandal_eeprom.o : ../mspenv/scandal_eeprom.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/mcp2510.o : ../mcp2510/mcp2510.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/scandal_error.o : ../scandal/source/scandal_error.c
	$(CC) $(CFLAGS) -c -o $@ $<	

$(BUILD_DIR)/scandal_engine.o : ../scandal/source/scandal_engine.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/scandal_utils.o : ../scandal/source/scandal_utils.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/scandal_message.o : ../scandal/source/scandal_message.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.out *.map *.hex
	rm -f *~
	rm -f $(BUILD_DIR)/*.o
	rm -f $(MAIN_NAME).lst $(MAIN_NAME).elf
	rm -f *.elf
	rm -f *.lst

program: $(MAIN_NAME).hex
	$(JTAG) -eEpvrw $(MAIN_NAME).hex
