/*
 * ADS1198.h
 *
 *  Created on: Jan 2, 2014
 *      Author: kakareka
 */

#ifndef GEN1LAUNCHPAD_ADS1198_H_
#define GEN1LAUNCHPAD_ADS1198_H_

extern uint16_t delay;
#define START_OPCODE (uint8_t)(0x08)
#define RESET_OPCODE (uint8_t)(0x06)
#define SDATAC_OPCODE (uint8_t)(0x11)
#define RDATAC_OPCODE (uint8_t)(0x10)

enum ADS1198Gain {
	GAIN6=0,
	GAIN1=1,
	GAIN2=2,
	GAIN3=3,
	GAIN4=4,
	GAIN8=5,
	GAIN12=6
};

enum ADS1198Mode {
	Normal=0,
	Shorted=1,
	RLD=2,
	MVDD=3,
	Temp=4,
	Test=5,
	RLD_DRP=6,
	RLD_DRN=7

};

extern enum ADS1198Gain g_ADS1198Gain;
extern enum ADS1198Mode g_ADS1198Mode;

extern bool g_ADS1198_init;


void EnableADS1198Interrupt(bool enable);
void ADS1198DRDYHandler(void);
void ADS1198GetTimePoint(uint8_t* status,uint16_t* data);
void ADS1198Init(void);
void ADS1198Reset(void);
void ADS1198SendCommand(uint8_t cmd);
void ADS1198WriteRegister(uint8_t reg, uint8_t val);
uint8_t ADS1198ReadRegister(uint8_t reg);
void ConfigureADS1198Channel(enum ADS1198Gain g, enum ADS1198Mode m);


#endif /* GEN1LAUNCHPAD_ADS1198_H_ */
