/*
 * ADS1198.c
 *
 *  Created on: Jan 2, 2014
 *      Author: kakareka
 */

#include "driverlib.h"
#include "ADS1198.h"

enum ADS1198Gain g_ADS1198Gain=GAIN1;
enum ADS1198Mode g_ADS1198Mode=Normal;
bool g_ADS1198_init=false;

extern bool g_interrupt_t;
extern volatile uint32_t g_ulTickCount;


uint8_t ADS1198SPITxRx(uint8_t cmd)
{
	USCI_A_SPI_transmitData(USCI_A0_BASE,cmd);
	uint8_t val = USCI_A_SPI_receiveData(USCI_A0_BASE);
	__delay_cycles(350);
	return val;
}

void ADS1198SendCommand(uint8_t cmd)
{
	uint8_t val=ADS1198SPITxRx(cmd);

}

void ADS1198WriteRegister(uint8_t reg, uint8_t value)
{
	uint8_t opcode1=0x40;
	uint8_t opcode2=0; //value is registers to write -1
	opcode1|=reg;
	ADS1198SendCommand(opcode1);
	ADS1198SendCommand(opcode2);
	ADS1198SendCommand(value);
}

uint8_t ADS1198ReadRegister(uint8_t reg)
{
	uint8_t opcode1=0x20;
	uint8_t opcode2=0; //value is registers to read -1
	uint8_t dummyDataTx=0, value=0;
	opcode1|=reg;
	ADS1198SendCommand(opcode1);
	ADS1198SendCommand(opcode2);
	value=ADS1198SPITxRx(dummyDataTx);

	return value;
}

//Retrieves a time point from the ADS1198 through the SPI interface
//This includes the 24-bit status bits, plus 8-channels of 16-bit data
void ADS1198GetTimePoint(uint8_t* status,uint16_t* data)
{
	uint8_t i;
	uint8_t* dataTmp;
	//statsu bits are not used, but must be collected
	for (i=0;i<3;i++) {
		status[i]=ADS1198SPITxRx(0);
	}

	//collect 8 channels of 16-bit data
	dataTmp=(uint8_t*) data;
	for (i=0;i<8*2;i+=2) {
		dataTmp[i+1]=ADS1198SPITxRx(0);
		dataTmp[i]=ADS1198SPITxRx(0);
	}
}


void ADS1198Init(void)
 {
	 //UpdateStatusBox("Initializing ADS1198");
	 ADS1198SendCommand(RESET_OPCODE);
	 ADS1198SendCommand(SDATAC_OPCODE);
     //Set SPS to 1kHz, disable daisy-chain mode
     ADS1198WriteRegister(1,0x43);
     //Test signals generated internally, default amp and freq
     ADS1198WriteRegister(2,0x30);
     //Enable 2.4V internal reference, no RLD
     ADS1198WriteRegister(3,0xC1);
     //Wait one second for reference to stabilize
     __delay_cycles(1e3);

     ConfigureADS1198Channel(g_ADS1198Gain,(enum ADS1198Mode)g_ADS1198Mode);

     ADS1198SendCommand(START_OPCODE);
     ADS1198SendCommand(RDATAC_OPCODE);

     g_ADS1198_init=true;

 }


void ADS1198Reset(void)
 {

	 ADS1198SendCommand(RESET_OPCODE);
	 ADS1198SendCommand(SDATAC_OPCODE);
	 g_ADS1198_init=false;
 }

//The ADS1198 should be taking out of RDATAC mode before calling this function
 void ConfigureADS1198Channel(enum ADS1198Gain g, enum ADS1198Mode m)
 {

	 int ch;
	 g_ADS1198Gain=g;
	 g_ADS1198Mode=m;


	 //Only Adjust ECG channels, do not change gain on Pressure channels (7-8)
     for (ch=0x05;ch<=0x0A;ch++) {
    	 char byte=0;
    	 byte=byte | ((g_ADS1198Gain<<4) & 0x70) | (g_ADS1198Mode & 0x07);
    	 //UpdateDebugBox("byte=0x%X",byte);
     	 ADS1198WriteRegister(ch,byte);
 	 }
     //Force pressure gains to 1
     for (ch=0x0B;ch<=0x0C;ch++) {
    	 char byte=0;
    	 byte=byte | ((GAIN1 <<4) & 0x70) | (g_ADS1198Mode & 0x07);
    	 //UpdateDebugBox("byte=0x%X",byte);
     	 ADS1198WriteRegister(ch,byte);
 	 }

 }

