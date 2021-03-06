/********************************************
* NgControlCpld.v   						*
* 											*
* Requisites								*
*	inblock.v								*
*	board.v									*
*											*
* Requisite to								*
*	<none>									*
*											*
*											*
*											*
* Andreas Gotterba							*
* C0ntact:									*
* a_gotterba at yahoo			 			*
*********************************************

/* Copyright (C) Andreas Gotterba, 2009 */ 

/* 
 * This file is part of the UNSWMPPTNG firmware.
 * 
 * The UNSWMPPTNG firmware is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * The UNSWMPPTNG firmware is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with the UNSWMPPTNG firmware.  If not, see <http://www.gnu.org/licenses/>.
 */

TO DO: **************************************

Adders! (this requires removing the additions from the msp code)

NOTES: **************************************

All the ugliness accocated with the inblock needing extra mspclk cycles
to load has been fixed :-)

Description: ********************************

This is the top level of a Verilog design for 
generating the control signals for one Biel NG power tracker. 

The primary difference from the fpga version is the removal of the 
PLL (and its locked signal)

It is intended for the Altera MaxII family of CPLDs.

Control comes in via an SPI interface (from the MSP430), and goes out
to the gate buffers on the power board.  

This version is designed to be run at 40MHz, controlling a tracker with a 20kHz cycle
(2000 clock units per cycle)

*/

module NgControlCpld (

	//general signals
	clk,					// 40MHz external clock
	
	ste,					// STE from MSP430
	serialin,				// SPI data in from the MSP430
	serialout,				// SPI output to the MSP
	mspclk,					// Slow (~7MHz) clock from the MSP430 for SPI communication
	nchpsel,				// Chip Select (used as a write enable) (active low)
	
	gpio1,					// Three GPIO lines from the MSP430, reserved for future use
	gpio2,	 
	
	LED1, LED2,				//signals to the MSP and the LEDs	

	nSD,					// Fault signal output to the MSP. 
	FSReset,				// Input from the MSP to reset the fault signal
	nFPGAReset,				// Input from the MSP to reset the FPGA
	FPGAEnable,				// Input from the MSP to enable and disable the FPGA
	
	nMSPReset,				// MSP reset pin

	nVoltFault,				// 150V overvoltage signal. Comes from a comparator.  
	nReg15Fault,			// 15V voltage fault. Comes from a comparator. 
	nReg5Fault,				// 5V voltage fault. Comes from the switching regulator. 
	nCurrentFault,			// Input under-current protection. Comes from a comparator. 
	
	aux, main, diode,		// to the FETs
	SD 						// output of shutdown signal to the power board
	);

	//-------------------------------------------------------------------
	output serialout;			
	output LED1, LED2; 	
	output nSD;
	output aux, main, diode, SD;

	//-------------------------------------------------------------------	
	input clk;
	input ste;
	input serialin;
	input mspclk;
	input nchpsel;
	input gpio1, gpio2;
	input FSReset, nFPGAReset, FPGAEnable; 
	input nMSPReset;
	input nVoltFault, nReg15Fault, nReg5Fault, nCurrentFault; 

	//-------------------------------------------------------------------			
	wire [15:0] data; 					// data from inblock. see notes in inblock
	wire countglobal;				 	// sets the value of all counter reset points to the current data, included for reverse compatability
	//board specific:
	wire load, nSDcomp;					// signal for a board to load data specific to itself; a hack to see why a fault was generated, sent to an LED.  when we are done debugging, do we need this at all (to the MSP?) will we do anything differently based on where the fault came from?
	wire enable;
	wire nFS; /* Fault signal */ 

	/* Security logic - note, no latching here*/ 
	and(enable,  nMSPReset, nVoltFault, nReg15Fault, nReg5Fault, nFPGAReset );
	buf(nFS, enable);
	
	//the input block FIXME: my want to modify the protocol.  
	inblock inblock(.data(data[15:0]), .countglobal(countglobal), .load1(load), .clk(clk), 
					.mspclk(mspclk), .serialin(serialin), .nchpsel(nchpsel));

	// the control for the board
	board board(.aux(aux), .main(main), .diode(diode), .clk(clk), .SD(SD),
				.data(data[13:0]), 
				.load(load), .nFS(nFS),
				.FS_Reset(FSReset),  .countglobal(countglobal));
	//			,
	//			.led1(LED1), .led2(LED2)); 
	//FIXME:count_load should be eliminated when inblock is redone. Fixed, but left countglobal for reverse compatability

	// Fault signal to the MSP430 is the inverse of the shutdown signal. 
	// The Shutdown signal is latched. 
	not(nSD, SD);

	//debugging logic, often using LED1 and LED2:
	DFFE (.D(1'b1), .CLK(FSReset), .CLRN(nFPGAReset), .PRN(1'b1), .Q(LED1)); //structure used before
//	DFFE (.D(1'b1), .CLK(FSReset), .CLRN(nReg15Fault), .PRN(1'b1), .Q(LED2)); //structure used before

	// Let the user know if there was a hard fault. 
	and(LED2, nVoltFault, nReg15Fault, nReg5Fault);
		
	// Setting presently un-used outputs to 0. 
	buf (serialout, 1'b0); 
endmodule