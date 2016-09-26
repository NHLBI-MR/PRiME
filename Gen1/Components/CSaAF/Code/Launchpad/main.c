#include "driverlib.h"
#include "Indicators.h"
#include "PSA.h"
#include "CSaAF.h"

void initClocks();

// Desired MCLK frequency
#define MCLK_FREQ_KHZ 20000
// On board crystals frequencies (in Hz)
#define XT1_FREQ 32768
#define XT2_FREQ 4000000
// Crystal frequencies in Hz
#define XT1_KHZ XT1_FREQ/1000
#define XT2_KHZ XT2_FREQ/1000
// Ratio used to set DCO (Digitally Controlled Oscillator)
// Using 1 MHz (XT2/4)
#define MCLK_FLLREF_RATIO MCLK_FREQ_KHZ/(XT2_KHZ/4)


#define SIM_AMP 750
#define BADTX_AMP 1000
#define SIM_HALFPERIOD 500
#define BADTX_HALFPERIOD 100
#define BADTX_PULSES 5
void GenPulseData(uint16_t amp);


enum FSM_States
{
	InituProc,
	InitHW,
	Ready,
	ReadFromPSA,
	WriteToCSaAF,
	StartSimIRQ,
	UpdateSimData,
	UpdateBadTXData,
	InitPSATest

};

enum SimType
{
	SimNone,
	SimSW,
	SimHW
};

volatile uint32_t timer_ms=0;

void uProcConfig(void);
void Setup1msTimer(void);
bool testBtn=false, resetBtn=false;
uint16_t psaData[8];

volatile enum FSM_States curState=InituProc;
volatile enum FSM_States nextState=InituProc;
volatile enum SimType simType=SimNone;

bool readyForSimUpdate=false;
bool readyForPSAData=false;
bool readyForBadTXData=false;

bool goodTransfer=false;
uint32_t timer_lastIRQ=0;
#define IRQ_WATCHDOG_MS 250
#define INIT_RETRY_MS 1000

#define LED_CYCLE_MS 2000
#define LED_TOGGLE_MS 250
#define SIMNONE_LEDTEST_LOOPS 0
#define SIMHW_LEDTEST_LOOPS 1
#define SIMSW_LEDTEST_LOOPS 3
#define SIMNONE_LEDTX_LOOPS 1
uint8_t totalTestLEDLoops=0, curTestLEDLoops=0;
uint8_t totalTXLEDLoops=0, curTXLEDLoops=0;
bool ledTestToggle=false;
bool ledTXToggle=false;
bool startLEDcycle=true;

void main(void)
{
	WDT_A_hold(WDT_A_BASE);
	memset(psaData,0,8);

	while (1) {
		switch (nextState) {
		case InituProc:
			curState=InituProc;

			uProcConfig();
			PSAConfig();
			CSaAFConfig();

			nextState=InitHW;
			break;
		case InitHW:
			curState=InitHW;

			simType=SimNone;
			PSAInit();
			CSaAFInit();
			PSASetMode(PSANormal);
			PSAEnableTransfer(true);
			//IRQ handler will set this to true
			goodTransfer=false;
			totalTestLEDLoops=SIMNONE_LEDTEST_LOOPS;
			totalTXLEDLoops=SIMNONE_LEDTX_LOOPS;

			nextState=Ready;
			break;
		case Ready:
			curState=Ready;

			if (startLEDcycle) {
				if (simType==SimNone) {
					SetLED(TEST_LED_PORT, TEST_LED_PIN,false);
					SetLED(TRANSFER_LED_PORT,TRANSFER_LED_PIN,true);
				} else {
					SetLED(TEST_LED_PORT, TEST_LED_PIN,true);
				}
				curTestLEDLoops=0;
				curTXLEDLoops=0;
				ledTestToggle=false;
				startLEDcycle=false;
			}
			if (ledTXToggle) {
				ToggleLED(TRANSFER_LED_PORT, TRANSFER_LED_PIN);
				ledTXToggle=false;
			}


			if (ledTestToggle) {
				ToggleLED(TEST_LED_PORT, TEST_LED_PIN);
				ledTestToggle=false;
			}

			if (!goodTransfer && simType==SimNone) {
				nextState=UpdateBadTXData;
				readyForBadTXData=true;

			} else if (resetBtn) {
				nextState=InitHW;
				resetBtn=false;
			} else if (testBtn) {
				if (simType==SimNone) {
					//next sim type is ADS1198 test signal
					nextState=InitPSATest;
				} else if (simType==SimHW) {
					//next sim type is Launchpad generated signal
					nextState=StartSimIRQ;
				} else {
					nextState=InitHW;
				}
				testBtn=false;
			} else if (readyForSimUpdate) {
				nextState=UpdateSimData;
				readyForSimUpdate=false;
			} else if (readyForPSAData) {
				nextState=ReadFromPSA;
				readyForPSAData=false;
			} else if (readyForBadTXData) {
				nextState=UpdateBadTXData;
				readyForBadTXData=false;
			}

			break;
		case ReadFromPSA:
			curState=ReadFromPSA;

			PSARead(psaData);

			nextState=WriteToCSaAF;
			break;
		case WriteToCSaAF:
			curState=WriteToCSaAF;

			CSaAFWrite(psaData);

			nextState=Ready;
			break;
		case StartSimIRQ:
			curState=StartSimIRQ;

			//1ms "master" clock is resused for simulation
			PSAEnableTransfer(false);
			totalTestLEDLoops=SIMSW_LEDTEST_LOOPS;
			goodTransfer=false;
			simType=SimSW;
			nextState=Ready;
			break;
		case UpdateSimData:
			curState=UpdateSimData;

			static uint32_t last_val_change=0;
			if (timer_ms-last_val_change>=SIM_HALFPERIOD) {
				GenPulseData(SIM_AMP);
				last_val_change=timer_ms;
			}

			nextState=WriteToCSaAF;
			break;
		case UpdateBadTXData:
			curState=UpdateBadTXData;
			static uint32_t last_pulse_change=0;
			static uint32_t last_txval_change=0;
			static bool STAGE_PULSE=true;


			if (timer_ms-last_txval_change>=BADTX_HALFPERIOD) {
				if (STAGE_PULSE) {
					GenPulseData(BADTX_AMP);
				} else{
					//memset only copies uint8
					memset(psaData,0,16);
				}

				last_txval_change=timer_ms;
			}
			if (timer_ms-last_pulse_change>=BADTX_HALFPERIOD*BADTX_PULSES*2) {
				STAGE_PULSE=!STAGE_PULSE;
				last_pulse_change=timer_ms;
			}

			nextState=WriteToCSaAF;
			break;
		case InitPSATest:
			curState=InitPSATest;

			PSASetMode(PSATest);
			PSAEnableTransfer(true);
			simType=SimHW;
			totalTestLEDLoops=SIMHW_LEDTEST_LOOPS;

			nextState=Ready;
			break;
		default:
			break;
		}
	}
}

void GenPulseData(uint16_t amp) {
	static int16_t pulseSign=1;
	int i;

	pulseSign=-pulseSign;
	uint8_t *tmpData=(uint8_t*)psaData;
	for (i=0;i<8;i++) {
		int16_t tmp=pulseSign*amp;
		//Change LA and LL so lead calculations don't cancel
		if (i==1) {
			tmp-=pulseSign*500;
		} else if (i==2) {
			tmp-=pulseSign*250;
		} else if (i>5) {
			tmp*=3;
		}
		//change endianness for transfer to CSaAF
		uint8_t *tmpPtr=(uint8_t*)&tmp;
		tmpData[i*2+1]=tmpPtr[0];
		tmpData[i*2]=tmpPtr[1];
	}
}
void uProcConfig(void)
{
	initClocks();
	Setup1msTimer();

	__bis_SR_register(GIE);
}

//******************************************************************************
//
//This is the PORT1_VECTOR interrupt vector service routine
//
//******************************************************************************
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=PORT1_VECTOR
__interrupt
#elif defined(__GNUC__)
__attribute__((interrupt(PORT1_VECTOR)))
#endif
void Port_1(void)
{
	uint16_t irqStatus=0;
	static uint32_t last_press=0;

	irqStatus=GPIO_getInterruptStatus(GPIO_PORT_P1,
			NDRDY_PIN | TEST_SW_PIN | RESET_SW_PIN |
			SIMTEST_SW_PIN | SIMRESET_SW_PIN);

	if (irqStatus & NDRDY_PIN) {
		readyForPSAData=true;
		timer_lastIRQ=timer_ms;
		goodTransfer=true;
		totalTXLEDLoops=0;
		GPIO_clearInterrupt(NDRDY_PORT,NDRDY_PIN);
	} else if ((irqStatus & TEST_SW_PIN) || (irqStatus & SIMTEST_SW_PIN)) {
		if (timer_ms-last_press>250) {
			testBtn=true;
			last_press=timer_ms;
		}
		GPIO_clearInterrupt(SIMTEST_SW_PORT,SIMTEST_SW_PIN);
		GPIO_clearInterrupt(TEST_SW_PORT,TEST_SW_PIN);
	} else if (irqStatus & RESET_SW_PIN) {
		resetBtn=true;
		GPIO_clearInterrupt(RESET_SW_PORT,RESET_SW_PIN);
	}


}


//******************************************************************************
//
//This is the PORT1_VECTOR interrupt vector service routine
//
//******************************************************************************
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=PORT2_VECTOR
__interrupt
#elif defined(__GNUC__)
__attribute__((interrupt(PORT2_VECTOR)))
#endif
void Port_2(void)
{
	uint16_t irqStatus=0;

	irqStatus=GPIO_getInterruptStatus(GPIO_PORT_P2,SIMRESET_SW_PIN);

	if (irqStatus & SIMRESET_SW_PIN) {
		resetBtn=true;
		GPIO_clearInterrupt(GPIO_PORT_P2,SIMRESET_SW_PIN);
	}

}

void Setup1msTimer(void)
{
    //Start timer in continuous mode sourced by SMCLK
    //Timer_A_initContinuousModeParam initUpParam = {0};
    Timer_A_initUpModeParam initUpParam = {0};

    initUpParam.clockSource = TIMER_A_CLOCKSOURCE_SMCLK;
    initUpParam.clockSourceDivider = TIMER_A_CLOCKSOURCE_DIVIDER_1;
    initUpParam.timerInterruptEnable_TAIE =
    		TIMER_A_TAIE_INTERRUPT_DISABLE;
    initUpParam.timerClear = TIMER_A_DO_CLEAR;
    initUpParam.startTimer = false;
    Timer_A_initUpMode(TIMER_A1_BASE, &initUpParam);

    //Initiaze compare mode
    Timer_A_clearCaptureCompareInterrupt(TIMER_A1_BASE,
    		TIMER_A_CAPTURECOMPARE_REGISTER_0);

    Timer_A_initCompareModeParam initCompParam = {0};
    initCompParam.compareRegister = TIMER_A_CAPTURECOMPARE_REGISTER_0;
    initCompParam.compareInterruptEnable =
    		TIMER_A_CAPTURECOMPARE_INTERRUPT_ENABLE;
    initCompParam.compareOutputMode = TIMER_A_OUTPUTMODE_OUTBITVALUE;
    initCompParam.compareValue = UCS_getSMCLK()/1e3;
    Timer_A_initCompareMode(TIMER_A1_BASE, &initCompParam);

    Timer_A_startCounter(TIMER_A1_BASE,TIMER_A_UP_MODE);
}

void initClocks()
{

	// Set core power mode

	PMM_setVCore(PMM_CORE_LEVEL_3);

    // Configure pins for crystals

    GPIO_setAsPeripheralModuleFunctionInputPin(
	GPIO_PORT_P5,
	GPIO_PIN4+GPIO_PIN2
    );

    GPIO_setAsPeripheralModuleFunctionOutputPin(
	GPIO_PORT_P5,
	GPIO_PIN5+GPIO_PIN3
    );

    // Inform the system of the crystal frequencies

    UCS_setExternalClockSource(
	   XT1_FREQ,  // Frequency of XT1 in Hz.
	   XT2_FREQ   // Frequency of XT2 in Hz.
    );

    // Initialize the crystals

    UCS_turnOnXT2( // used to be UCS_XT2Start in previous driverlib version
	   UCS_XT2_DRIVE_4MHZ_8MHZ
    );

    UCS_turnOnLFXT1( //used to be UCS_LFXT1Start in previous driverlib version
	   UCS_XT1_DRIVE_0,
	   UCS_XCAP_3
    );

	UCS_initClockSignal(
		  UCS_FLLREF,         // The reference for Frequency Locked Loop
	      UCS_XT2CLK_SELECT,  // Select XT2
	      UCS_CLOCK_DIVIDER_4 // The FLL reference will be 1 MHz (4MHz XT2/4)
	);

	// Start the FLL and let it settle
	// This becomes the MCLCK and SMCLK automatically

	UCS_initFLLSettle(
		MCLK_FREQ_KHZ,
		MCLK_FLLREF_RATIO
	);

   // Optional: set SMCLK to something else than full speed

	UCS_initClockSignal(
	   UCS_SMCLK,
	   UCS_DCOCLKDIV_SELECT,
	   UCS_CLOCK_DIVIDER_1
	);

	// Set auxiliary clock

	UCS_initClockSignal(
	   UCS_ACLK,
	   UCS_XT1CLK_SELECT,
	   UCS_CLOCK_DIVIDER_1
	);
}

//******************************************************************************
//
//This is the TIMER1_A3 interrupt vector service routine.
//
//******************************************************************************
#if defined(__TI_COMPILER_VERSION__) || defined(__IAR_SYSTEMS_ICC__)
#pragma vector=TIMER1_A0_VECTOR
__interrupt
#elif defined(__GNUC__)
__attribute__((interrupt(TIMER1_A0_VECTOR)))
#endif
void TIMER1_A0_ISR(void)
{
	static uint32_t timer_led=0, timer_toggleLED=0;
	timer_ms++;
	timer_led++;
	timer_toggleLED++;
	if (simType==SimSW) {
		readyForSimUpdate=true;
	}
	if (timer_led>=LED_CYCLE_MS) {
		startLEDcycle=true;
		timer_led=0;
		timer_toggleLED=0;
	}
	if (timer_toggleLED>LED_TOGGLE_MS) {
		if (curTestLEDLoops<totalTestLEDLoops) {
			ledTestToggle=true;
			curTestLEDLoops++;
		}
		if (curTXLEDLoops<totalTXLEDLoops) {
			ledTXToggle=true;
			curTXLEDLoops++;
		}
		timer_toggleLED=0;
	}

	if (goodTransfer && timer_ms-timer_lastIRQ>IRQ_WATCHDOG_MS) {
		//update the LEDs immediately
		startLEDcycle=true;
		goodTransfer=false;
		nextState=Ready;
	}
	if (!goodTransfer && simType==SimNone && timer_ms-timer_lastIRQ>INIT_RETRY_MS) {
		nextState=InitHW;
	}
}

