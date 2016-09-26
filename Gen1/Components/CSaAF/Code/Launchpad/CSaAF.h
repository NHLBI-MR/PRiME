/*
 * CSaAF.h
 *
 *  Created on: Apr 12, 2016
 *      Author: kakareka
 */

#ifndef GEN1LAUNCHPAD_CSAAF_H_
#define GEN1LAUNCHPAD_CSAAF_H_

#define CSAAF_CLOCK_RATE 500000

#define TEST_SW_PORT GPIO_PORT_P1
#define TEST_SW_PIN GPIO_PIN3
#define RESET_SW_PORT GPIO_PORT_P1
#define RESET_SW_PIN GPIO_PIN2

#define SIMTEST_SW_PORT GPIO_PORT_P1
#define SIMTEST_SW_PIN GPIO_PIN1
#define SIMRESET_SW_PORT GPIO_PORT_P2
#define SIMRESET_SW_PIN GPIO_PIN1

#define SPI_NCS_PORT GPIO_PORT_P2
#define SPI_NCS_PIN GPIO_PIN3

void CSaAFWrite(uint16_t* dataPtr);
void CSaAFConfig(void);
void CSaAFInit(void);
void CSaAFLEDToggle(uint16_t ledPort, uint8_t ledPin);
void CSaAFLEDSet(uint16_t ledPort, uint8_t ledPin, bool onOff);
void WaitForTx(void);


#endif /* GEN1LAUNCHPAD_CSAAF_H_ */
