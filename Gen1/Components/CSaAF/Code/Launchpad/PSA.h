/*
 * PSA.h
 *
 *  Created on: Apr 12, 2016
 *      Author: kakareka
 */

#ifndef GEN1LAUNCHPAD_PSA_H_
#define GEN1LAUNCHPAD_PSA_H_

#define NDRDY_PORT GPIO_PORT_P1
#define NDRDY_PIN GPIO_PIN6

#define PSA_CLOCK_RATE 500000

enum PSAMode
{
	PSANormal,
	PSATest
};
void PSASetupIRQ(void);
void PSASetupSPI(void);
void PSAInit(void);
void PSAConfig(void);
void PSAReset(void);
void PSAEnableTransfer(bool enable);
void PSARead(uint16_t* dataPtr);
void PSASetMode(enum PSAMode mode);



#endif /* GEN1LAUNCHPAD_PSA_H_ */
