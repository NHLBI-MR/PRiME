#include "driverlib.h"
#include "CSaAF.h"
#include "Indicators.h"


uint8_t FPGASPITxRx(uint8_t cmd)
{
	uint8_t val=0;

	USCI_B_SPI_transmitData(USCI_B0_BASE,cmd);
	__delay_cycles(350);
	val = USCI_B_SPI_receiveData(USCI_B0_BASE);

	return val;
}

void CSaAFWrite(uint16_t* dataPtr)
{
	uint8_t i;
	uint8_t* dataTmp;
	dataTmp=(uint8_t*)dataPtr;
	GPIO_setOutputLowOnPin(SPI_NCS_PORT,SPI_NCS_PIN);
	for (i=0;i<16;i++) {
		FPGASPITxRx(dataTmp[i]);
	}
	WaitForTx();
	GPIO_setOutputHighOnPin(SPI_NCS_PORT,SPI_NCS_PIN);
}

void CSaAFInit(void)
{
	GPIO_setOutputLowOnPin(SPI_NCS_PORT,SPI_NCS_PIN);
	//Enable SPI module
	USCI_B_SPI_enable(USCI_B0_BASE);
}

void CSaAFConfig(void)
{
	GPIO_setAsOutputPin(DEBUG_LED_PORT,DEBUG_LED_PIN);
	GPIO_setAsOutputPin(TRANSFER_LED_PORT,TRANSFER_LED_PIN);
	GPIO_setAsOutputPin(TEST_LED_PORT,TEST_LED_PIN);

	GPIO_setAsInputPinWithPullDownResistor(RESET_SW_PORT, RESET_SW_PIN);
	GPIO_setAsInputPinWithPullDownResistor(TEST_SW_PORT,TEST_SW_PIN);
	GPIO_setAsInputPinWithPullUpResistor(SIMTEST_SW_PORT,SIMTEST_SW_PIN);
	GPIO_setAsInputPinWithPullUpResistor(SIMRESET_SW_PORT,SIMRESET_SW_PIN);

	GPIO_selectInterruptEdge(RESET_SW_PORT,RESET_SW_PIN,GPIO_HIGH_TO_LOW_TRANSITION);
	GPIO_clearInterrupt(RESET_SW_PORT,RESET_SW_PIN);

	GPIO_selectInterruptEdge(TEST_SW_PORT,TEST_SW_PIN,GPIO_HIGH_TO_LOW_TRANSITION);
	GPIO_clearInterrupt(TEST_SW_PORT,TEST_SW_PIN);

	GPIO_selectInterruptEdge(SIMTEST_SW_PORT,SIMTEST_SW_PIN,GPIO_HIGH_TO_LOW_TRANSITION);
	GPIO_clearInterrupt(SIMTEST_SW_PORT,SIMTEST_SW_PIN);

	GPIO_selectInterruptEdge(SIMRESET_SW_PORT,SIMRESET_SW_PIN,GPIO_HIGH_TO_LOW_TRANSITION);
	GPIO_clearInterrupt(SIMRESET_SW_PORT,SIMRESET_SW_PIN);

	GPIO_enableInterrupt(RESET_SW_PORT,RESET_SW_PIN);
	GPIO_enableInterrupt(TEST_SW_PORT,TEST_SW_PIN);
	GPIO_enableInterrupt(SIMTEST_SW_PORT,SIMTEST_SW_PIN);
	GPIO_enableInterrupt(SIMRESET_SW_PORT,SIMRESET_SW_PIN);


    GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P3,GPIO_PIN1);
    GPIO_setAsPeripheralModuleFunctionOutputPin(GPIO_PORT_P3,GPIO_PIN0 | GPIO_PIN2);
    GPIO_setAsOutputPin(SPI_NCS_PORT,SPI_NCS_PIN);


	//Setup SPI port B to CSaAF FPGA, assume direct connect to USB-7856R
	//USB-7856R is slave, nCS is required
	//Run at 500kHz
    //Initialize Master
    USCI_B_SPI_initMasterParam param = {0};
    param.selectClockSource = USCI_B_SPI_CLOCKSOURCE_SMCLK;
    param.clockSourceFrequency = UCS_getSMCLK();
    param.desiredSpiClock = 500e3;
    param.msbFirst = USCI_B_SPI_MSB_FIRST;
    param.clockPhase = USCI_B_SPI_PHASE_DATA_CHANGED_ONFIRST_CAPTURED_ON_NEXT;
    //param.clockPhase = USCI_B_SPI_PHASE_DATA_CAPTURED_ONFIRST_CHANGED_ON_NEXT;
    param.clockPolarity = USCI_B_SPI_CLOCKPOLARITY_INACTIVITY_LOW;
    USCI_B_SPI_initMaster(USCI_B0_BASE, &param);


}

void CSaAFLEDToggle(uint16_t ledPort, uint8_t ledPin)
{
	GPIO_toggleOutputOnPin(ledPort,ledPin);
}

void CSaAFLEDSet(uint16_t ledPort, uint8_t ledPin, bool onOff)
{
	if (onOff) {
		GPIO_setOutputHighOnPin(ledPort,ledPin);
	} else {
		GPIO_setOutputLowOnPin(ledPort,ledPin);
	}
}

void WaitForTx(void)
{
	/*
    while(!USCI_B_SPI_getInterruptStatus(USCI_B0_BASE,
                                         USCI_B_SPI_TRANSMIT_INTERRUPT))
    {
        ;
    }
    */
	while (USCI_B_SPI_isBusy(USCI_B0_BASE)==USCI_B_SPI_BUSY) {
		;
	}
}

