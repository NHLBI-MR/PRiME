/*
 * PSA.c
 *
 *  Created on: Apr 12, 2016
 *      Author: kakareka
 */


#include "driverlib.h"
#include "PSA.h"
#include "ADS1198.h"

bool simData=false;
extern uint32_t timer_ms;


//Setup GPIO pin as input connected to nDRDY signal
//nDRDY low indicates a new set of samples are ready
void PSASetupIRQ(void)
{
	//Using P1.6
	GPIO_setAsInputPinWithPullUpResistor(NDRDY_PORT,NDRDY_PIN);

	GPIO_selectInterruptEdge(NDRDY_PORT,NDRDY_PIN,GPIO_HIGH_TO_LOW_TRANSITION);
	GPIO_clearInterrupt(NDRDY_PORT,NDRDY_PIN);
}

//Setup SPI port A to PSA, assume direct connect to ADS1198 chip
//ADS1198 is slave and nCS line is always held low
//Run at 500kHz
void PSASetupSPI(void)
{
	uint8_t returnValue = 0x00;
    GPIO_setAsPeripheralModuleFunctionInputPin(
        GPIO_PORT_P3,
        GPIO_PIN4
        );
    GPIO_setAsPeripheralModuleFunctionOutputPin(
            GPIO_PORT_P3,
            GPIO_PIN3
            );

    GPIO_setAsPeripheralModuleFunctionOutputPin(
            GPIO_PORT_P2,
            GPIO_PIN7
            );

    //Initialize Master
    USCI_A_SPI_initMasterParam param = {0};
    param.selectClockSource = USCI_A_SPI_CLOCKSOURCE_SMCLK;
    param.clockSourceFrequency = UCS_getSMCLK();
    param.desiredSpiClock = 500e3;
    param.msbFirst = USCI_A_SPI_MSB_FIRST;
    param.clockPhase = USCI_A_SPI_PHASE_DATA_CHANGED_ONFIRST_CAPTURED_ON_NEXT;
    param.clockPolarity = USCI_A_SPI_CLOCKPOLARITY_INACTIVITY_LOW;
    returnValue = USCI_A_SPI_initMaster(USCI_A0_BASE, &param);

	if(STATUS_FAIL == returnValue) {
		return;
	}

	//Enable SPI module
	USCI_A_SPI_enable(USCI_A0_BASE);
}

void PSAConfig(void)
{
	PSASetupSPI();
	PSASetupIRQ();
	ADS1198Init();
}

void PSAInit(void)
{
	ADS1198Init();
}

void PSAReset(void)
{
	ADS1198Reset();
}

void PSAEnableTransfer(bool enable)
{
	if (enable) {
		GPIO_enableInterrupt(NDRDY_PORT,NDRDY_PIN);
	} else {
		GPIO_disableInterrupt(NDRDY_PORT,NDRDY_PIN);
	}
}

void PSARead(uint16_t* dataPtr)
{
	uint8_t status[3];

	ADS1198GetTimePoint(status,dataPtr);
}

void PSASetMode(enum PSAMode mode)
{
	enum ADS1198Mode m=Normal;
	enum ADS1198Gain g=GAIN1;
	if (mode==PSANormal) {
		simData=false;
		ADS1198Reset();
		ConfigureADS1198Channel(g,m);
		ADS1198Init();
		PSAEnableTransfer(true);
	} else if (mode==PSATest) {
		simData=false;
		m=Test;
		ADS1198Reset();
		ConfigureADS1198Channel(g,m);
		ADS1198Init();
		PSAEnableTransfer(true);
	}
}
