/*
 * Indicators.c
 *
 *  Created on: Apr 11, 2016
 *      Author: kakareka
 */


#include "driverlib.h"
#include "Indicators.h"

void SetupDebugLED(void)
{
	GPIO_setAsOutputPin(DEBUG_LED_PORT,DEBUG_LED_PIN);
	GPIO_setAsOutputPin(DEBUG2_LED_PORT,DEBUG2_LED_PIN);
}

void SetupTransferLED(void)
{
	GPIO_setAsOutputPin(TRANSFER_LED_PORT,TRANSFER_LED_PIN);
}

void SetupTestLED(void)
{
	GPIO_setAsOutputPin(TEST_LED_PORT,TEST_LED_PIN);
}

void ToggleLED(uint16_t ledPort, uint8_t ledPin)
{
	GPIO_toggleOutputOnPin(ledPort,ledPin);
}

void SetLED(uint16_t ledPort, uint8_t ledPin, bool onOff)
{
	if (onOff) {
		GPIO_setOutputHighOnPin(ledPort,ledPin);
	} else {
		GPIO_setOutputLowOnPin(ledPort,ledPin);
	}
}
