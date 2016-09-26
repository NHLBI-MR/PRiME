/*
 * Indicators.h
 *
 *  Created on: Apr 12, 2016
 *      Author: kakareka
 */

#ifndef PSA2CSAAF_INDICATORS_H_
#define PSA2CSAAF_INDICATORS_H_
#include "driverlib.h"


#define TRANSFER_LED_PORT GPIO_PORT_P8
#define TRANSFER_LED_PIN GPIO_PIN1
#define TEST_LED_PORT GPIO_PORT_P8
#define TEST_LED_PIN GPIO_PIN2
#define DEBUG_LED_PORT GPIO_PORT_P1
#define DEBUG_LED_PIN GPIO_PIN0
#define DEBUG2_LED_PORT GPIO_PORT_P4
#define DEBUG2_LED_PIN GPIO_PIN7

void SetupDebugLED(void);
void SetupTransferLED(void);
void SetupTestLED(void);
void ToggleLED(uint16_t ledPort, uint8_t ledPin);
void SetLED(uint16_t ledPort, uint8_t ledPin, bool onOff);

#endif /* PSA2CSAAF_INDICATORS_H_ */
