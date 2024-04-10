/*
 * EXAMPLE_1.C
 *
 * This is a minimal program to verify multitasking.
 *
 */

#include <stdio.h>
#include <Bios.h>
#include <ucos_ii.h>

#define STACKSIZE  256



//////////////////////////////
// I2C Controller Registers //
//////////////////////////////
#define I2C_CLK_PRESCALE_LOW (*(volatile unsigned char *)(0x00408000))
#define I2C_CLK_PRESCALE_HIGH (*(volatile unsigned char *)(0x00408002))
#define I2C_CTRL (*(volatile unsigned char *)(0x00408004))
#define I2C_TX (*(volatile unsigned char *)(0x00408006))
#define I2C_RX (*(volatile unsigned char *)(0x00408006))
#define I2C_CMD (*(volatile unsigned char *)(0x00408008))
#define I2C_STAT (*(volatile unsigned char *)(0x00408008))

//////////////////
// I2C Commands //
//////////////////
#define I2C_CMD_Slave_Write_With_Start 0x91 // 1001 0001
#define I2C_CMD_Slave_Read_With_Start 0xA9  // 1010 1001
#define I2C_CMD_Slave_Write 0x11            // 0001 0001
#define I2C_CMD_Slave_Read 0x21             // 0010 0001
#define I2C_CMD_Slave_Read_Ack 0x29         // 0010 1001
#define I2C_CMD_Slave_Write_Stop 0x51       // 0101 0001
#define I2C_CMD_Slave_Read_Stop 0x49        // 0100 1001

/////////////////////
// EEPROM Commands //
/////////////////////
#define EEPROM_Write_Block_1 0xA2           // 1010 0010
#define EEPROM_Read_Block_1 0xA3            // 1010 0011
#define EEPROM_Write_Block_0 0xA0           // 1010 0000
#define EEPROM_Read_Block_0 0xA1            // 1010 0001

//////////////////////
// ADC/DAC Commands //
//////////////////////
#define ADC_DAC_Write_Address 0x90          // 1001 0000
#define ADC_Read_Address 0x91               // 1001 0001
#define ADC_CMD_Enable 0x44                 // 0100 0100
#define DAC_CMD_Enable 0x40                 // 0100 0000

#define Enable_I2C_Controller() I2C_CTRL = 0x80     // 1000 0000

/*********************************************************************************************
** These addresses and definitions were taken from Appendix 7 of the Can Controller
** application note and adapted for the 68k assignment
*********************************************************************************************/

/*
** definition for the SJA1000 registers and bits based on 68k address map areas
** assume the addresses for the 2 can controllers given in the assignment
**
** Registers are defined in terms of the following Macro for each Can controller,
** where (i) represents an registers number
*/

#define CAN0_CONTROLLER(i) (*(volatile unsigned char *)(0x00500000 + (i << 1)))
#define CAN1_CONTROLLER(i) (*(volatile unsigned char *)(0x00500200 + (i << 1)))

/* Can 0 register definitions */
#define Can0_ModeControlReg      CAN0_CONTROLLER(0)
#define Can0_CommandReg          CAN0_CONTROLLER(1)
#define Can0_StatusReg           CAN0_CONTROLLER(2)
#define Can0_InterruptReg        CAN0_CONTROLLER(3)
#define Can0_InterruptEnReg      CAN0_CONTROLLER(4) /* PeliCAN mode */
#define Can0_BusTiming0Reg       CAN0_CONTROLLER(6)
#define Can0_BusTiming1Reg       CAN0_CONTROLLER(7)
#define Can0_OutControlReg       CAN0_CONTROLLER(8)

/* address definitions of Other Registers */
#define Can0_ArbLostCapReg       CAN0_CONTROLLER(11)
#define Can0_ErrCodeCapReg       CAN0_CONTROLLER(12)
#define Can0_ErrWarnLimitReg     CAN0_CONTROLLER(13)
#define Can0_RxErrCountReg       CAN0_CONTROLLER(14)
#define Can0_TxErrCountReg       CAN0_CONTROLLER(15)
#define Can0_RxMsgCountReg       CAN0_CONTROLLER(29)
#define Can0_RxBufStartAdr       CAN0_CONTROLLER(30)
#define Can0_ClockDivideReg      CAN0_CONTROLLER(31)

/* address definitions of Acceptance Code & Mask Registers - RESET MODE */
#define Can0_AcceptCode0Reg      CAN0_CONTROLLER(16)
#define Can0_AcceptCode1Reg      CAN0_CONTROLLER(17)
#define Can0_AcceptCode2Reg      CAN0_CONTROLLER(18)
#define Can0_AcceptCode3Reg      CAN0_CONTROLLER(19)
#define Can0_AcceptMask0Reg      CAN0_CONTROLLER(20)
#define Can0_AcceptMask1Reg      CAN0_CONTROLLER(21)
#define Can0_AcceptMask2Reg      CAN0_CONTROLLER(22)
#define Can0_AcceptMask3Reg      CAN0_CONTROLLER(23)

/* address definitions Rx Buffer - OPERATING MODE - Read only register*/
#define Can0_RxFrameInfo         CAN0_CONTROLLER(16)
#define Can0_RxBuffer1           CAN0_CONTROLLER(17)
#define Can0_RxBuffer2           CAN0_CONTROLLER(18)
#define Can0_RxBuffer3           CAN0_CONTROLLER(19)
#define Can0_RxBuffer4           CAN0_CONTROLLER(20)
#define Can0_RxBuffer5           CAN0_CONTROLLER(21)
#define Can0_RxBuffer6           CAN0_CONTROLLER(22)
#define Can0_RxBuffer7           CAN0_CONTROLLER(23)
#define Can0_RxBuffer8           CAN0_CONTROLLER(24)
#define Can0_RxBuffer9           CAN0_CONTROLLER(25)
#define Can0_RxBuffer10          CAN0_CONTROLLER(26)
#define Can0_RxBuffer11          CAN0_CONTROLLER(27)
#define Can0_RxBuffer12          CAN0_CONTROLLER(28)

/* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
#define Can0_TxFrameInfo         CAN0_CONTROLLER(16)
#define Can0_TxBuffer1           CAN0_CONTROLLER(17)
#define Can0_TxBuffer2           CAN0_CONTROLLER(18)
#define Can0_TxBuffer3           CAN0_CONTROLLER(19)
#define Can0_TxBuffer4           CAN0_CONTROLLER(20)
#define Can0_TxBuffer5           CAN0_CONTROLLER(21)
#define Can0_TxBuffer6           CAN0_CONTROLLER(22)
#define Can0_TxBuffer7           CAN0_CONTROLLER(23)
#define Can0_TxBuffer8           CAN0_CONTROLLER(24)
#define Can0_TxBuffer9           CAN0_CONTROLLER(25)
#define Can0_TxBuffer10          CAN0_CONTROLLER(26)
#define Can0_TxBuffer11          CAN0_CONTROLLER(27)
#define Can0_TxBuffer12          CAN0_CONTROLLER(28)

/* read only addresses */
#define Can0_TxFrameInfoRd       CAN0_CONTROLLER(96)
#define Can0_TxBufferRd1         CAN0_CONTROLLER(97)
#define Can0_TxBufferRd2         CAN0_CONTROLLER(98)
#define Can0_TxBufferRd3         CAN0_CONTROLLER(99)
#define Can0_TxBufferRd4         CAN0_CONTROLLER(100)
#define Can0_TxBufferRd5         CAN0_CONTROLLER(101)
#define Can0_TxBufferRd6         CAN0_CONTROLLER(102)
#define Can0_TxBufferRd7         CAN0_CONTROLLER(103)
#define Can0_TxBufferRd8         CAN0_CONTROLLER(104)
#define Can0_TxBufferRd9         CAN0_CONTROLLER(105)
#define Can0_TxBufferRd10        CAN0_CONTROLLER(106)
#define Can0_TxBufferRd11        CAN0_CONTROLLER(107)
#define Can0_TxBufferRd12        CAN0_CONTROLLER(108)


/* CAN1 Controller register definitions */
#define Can1_ModeControlReg      CAN1_CONTROLLER(0)
#define Can1_CommandReg          CAN1_CONTROLLER(1)
#define Can1_StatusReg           CAN1_CONTROLLER(2)
#define Can1_InterruptReg        CAN1_CONTROLLER(3)
#define Can1_InterruptEnReg      CAN1_CONTROLLER(4) /* PeliCAN mode */
#define Can1_BusTiming0Reg       CAN1_CONTROLLER(6)
#define Can1_BusTiming1Reg       CAN1_CONTROLLER(7)
#define Can1_OutControlReg       CAN1_CONTROLLER(8)

/* address definitions of Other Registers */
#define Can1_ArbLostCapReg       CAN1_CONTROLLER(11)
#define Can1_ErrCodeCapReg       CAN1_CONTROLLER(12)
#define Can1_ErrWarnLimitReg     CAN1_CONTROLLER(13)
#define Can1_RxErrCountReg       CAN1_CONTROLLER(14)
#define Can1_TxErrCountReg       CAN1_CONTROLLER(15)
#define Can1_RxMsgCountReg       CAN1_CONTROLLER(29)
#define Can1_RxBufStartAdr       CAN1_CONTROLLER(30)
#define Can1_ClockDivideReg      CAN1_CONTROLLER(31)

/* address definitions of Acceptance Code & Mask Registers - RESET MODE */
#define Can1_AcceptCode0Reg      CAN1_CONTROLLER(16)
#define Can1_AcceptCode1Reg      CAN1_CONTROLLER(17)
#define Can1_AcceptCode2Reg      CAN1_CONTROLLER(18)
#define Can1_AcceptCode3Reg      CAN1_CONTROLLER(19)
#define Can1_AcceptMask0Reg      CAN1_CONTROLLER(20)
#define Can1_AcceptMask1Reg      CAN1_CONTROLLER(21)
#define Can1_AcceptMask2Reg      CAN1_CONTROLLER(22)
#define Can1_AcceptMask3Reg      CAN1_CONTROLLER(23)

/* address definitions Rx Buffer - OPERATING MODE - Read only register*/
#define Can1_RxFrameInfo         CAN1_CONTROLLER(16)
#define Can1_RxBuffer1           CAN1_CONTROLLER(17)
#define Can1_RxBuffer2           CAN1_CONTROLLER(18)
#define Can1_RxBuffer3           CAN1_CONTROLLER(19)
#define Can1_RxBuffer4           CAN1_CONTROLLER(20)
#define Can1_RxBuffer5           CAN1_CONTROLLER(21)
#define Can1_RxBuffer6           CAN1_CONTROLLER(22)
#define Can1_RxBuffer7           CAN1_CONTROLLER(23)
#define Can1_RxBuffer8           CAN1_CONTROLLER(24)
#define Can1_RxBuffer9           CAN1_CONTROLLER(25)
#define Can1_RxBuffer10          CAN1_CONTROLLER(26)
#define Can1_RxBuffer11          CAN1_CONTROLLER(27)
#define Can1_RxBuffer12          CAN1_CONTROLLER(28)

/* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
#define Can1_TxFrameInfo         CAN1_CONTROLLER(16)
#define Can1_TxBuffer1           CAN1_CONTROLLER(17)
#define Can1_TxBuffer2           CAN1_CONTROLLER(18)
#define Can1_TxBuffer3           CAN1_CONTROLLER(19)
#define Can1_TxBuffer4           CAN1_CONTROLLER(20)
#define Can1_TxBuffer5           CAN1_CONTROLLER(21)
#define Can1_TxBuffer6           CAN1_CONTROLLER(22)
#define Can1_TxBuffer7           CAN1_CONTROLLER(23)
#define Can1_TxBuffer8           CAN1_CONTROLLER(24)
#define Can1_TxBuffer9           CAN1_CONTROLLER(25)
#define Can1_TxBuffer10          CAN1_CONTROLLER(26)
#define Can1_TxBuffer11          CAN1_CONTROLLER(27)
#define Can1_TxBuffer12          CAN1_CONTROLLER(28)

/* read only addresses */
#define Can1_TxFrameInfoRd       CAN1_CONTROLLER(96)
#define Can1_TxBufferRd1         CAN1_CONTROLLER(97)
#define Can1_TxBufferRd2         CAN1_CONTROLLER(98)
#define Can1_TxBufferRd3         CAN1_CONTROLLER(99)
#define Can1_TxBufferRd4         CAN1_CONTROLLER(100)
#define Can1_TxBufferRd5         CAN1_CONTROLLER(101)
#define Can1_TxBufferRd6         CAN1_CONTROLLER(102)
#define Can1_TxBufferRd7         CAN1_CONTROLLER(103)
#define Can1_TxBufferRd8         CAN1_CONTROLLER(104)
#define Can1_TxBufferRd9         CAN1_CONTROLLER(105)
#define Can1_TxBufferRd10        CAN1_CONTROLLER(106)
#define Can1_TxBufferRd11        CAN1_CONTROLLER(107)
#define Can1_TxBufferRd12        CAN1_CONTROLLER(108)


/* bit definitions for the Mode & Control Register */
#define RM_RR_Bit 0x01 /* reset mode (request) bit */
#define LOM_Bit 0x02 /* listen only mode bit */
#define STM_Bit 0x04 /* self test mode bit */
#define AFM_Bit 0x08 /* acceptance filter mode bit */
#define SM_Bit  0x10 /* enter sleep mode bit */

/* bit definitions for the Interrupt Enable & Control Register */
#define RIE_Bit 0x01 /* receive interrupt enable bit */
#define TIE_Bit 0x02 /* transmit interrupt enable bit */
#define EIE_Bit 0x04 /* error warning interrupt enable bit */
#define DOIE_Bit 0x08 /* data overrun interrupt enable bit */
#define WUIE_Bit 0x10 /* wake-up interrupt enable bit */
#define EPIE_Bit 0x20 /* error passive interrupt enable bit */
#define ALIE_Bit 0x40 /* arbitration lost interr. enable bit*/
#define BEIE_Bit 0x80 /* bus error interrupt enable bit */

/* bit definitions for the Command Register */
#define TR_Bit 0x01 /* transmission request bit */
#define AT_Bit 0x02 /* abort transmission bit */
#define RRB_Bit 0x04 /* release receive buffer bit */
#define CDO_Bit 0x08 /* clear data overrun bit */
#define SRR_Bit 0x10 /* self reception request bit */

/* bit definitions for the Status Register */
#define RBS_Bit 0x01 /* receive buffer status bit */
#define DOS_Bit 0x02 /* data overrun status bit */
#define TBS_Bit 0x04 /* transmit buffer status bit */
#define TCS_Bit 0x08 /* transmission complete status bit */
#define RS_Bit 0x10 /* receive status bit */
#define TS_Bit 0x20 /* transmit status bit */
#define ES_Bit 0x40 /* error status bit */
#define BS_Bit 0x80 /* bus status bit */

/* bit definitions for the Interrupt Register */
#define RI_Bit 0x01 /* receive interrupt bit */
#define TI_Bit 0x02 /* transmit interrupt bit */
#define EI_Bit 0x04 /* error warning interrupt bit */
#define DOI_Bit 0x08 /* data overrun interrupt bit */
#define WUI_Bit 0x10 /* wake-up interrupt bit */
#define EPI_Bit 0x20 /* error passive interrupt bit */
#define ALI_Bit 0x40 /* arbitration lost interrupt bit */
#define BEI_Bit 0x80 /* bus error interrupt bit */


/* bit definitions for the Bus Timing Registers */
#define SAM_Bit 0x80                        /* sample mode bit 1 == the bus is sampled 3 times, 0 == the bus is sampled once */

/* bit definitions for the Output Control Register OCMODE1, OCMODE0 */
#define BiPhaseMode 0x00 /* bi-phase output mode */
#define NormalMode 0x02 /* normal output mode */
#define ClkOutMode 0x03 /* clock output mode */

/* output pin configuration for TX1 */
#define OCPOL1_Bit 0x20 /* output polarity control bit */
#define Tx1Float 0x00 /* configured as float */
#define Tx1PullDn 0x40 /* configured as pull-down */
#define Tx1PullUp 0x80 /* configured as pull-up */
#define Tx1PshPull 0xC0 /* configured as push/pull */

/* output pin configuration for TX0 */
#define OCPOL0_Bit 0x04 /* output polarity control bit */
#define Tx0Float 0x00 /* configured as float */
#define Tx0PullDn 0x08 /* configured as pull-down */
#define Tx0PullUp 0x10 /* configured as pull-up */
#define Tx0PshPull 0x18 /* configured as push/pull */

/* bit definitions for the Clock Divider Register */
#define DivBy1 0x07 /* CLKOUT = oscillator frequency */
#define DivBy2 0x00 /* CLKOUT = 1/2 oscillator frequency */
#define ClkOff_Bit 0x08 /* clock off bit, control of the CLK OUT pin */
#define RXINTEN_Bit 0x20 /* pin TX1 used for receive interrupt */
#define CBP_Bit 0x40 /* CAN comparator bypass control bit */
#define CANMode_Bit 0x80 /* CAN mode definition bit */

/*- definition of used constants ---------------------------------------*/
#define YES 1
#define NO 0
#define ENABLE 1
#define DISABLE 0
#define ENABLE_N 0
#define DISABLE_N 1
#define INTLEVELACT 0
#define INTEDGEACT 1
#define PRIORITY_LOW 0
#define PRIORITY_HIGH 1

/* default (reset) value for register content, clear register */
#define ClrByte 0x00

/* constant: clear Interrupt Enable Register */
#define ClrIntEnSJA ClrByte

/* definitions for the acceptance code and mask register */
#define DontCare 0xFF

/*  bus timing values for
**  bit-rate : 100 kBit/s
**  oscillator frequency : 25 MHz, 1 sample per bit, 0 tolerance %
**  maximum tolerated propagation delay : 4450 ns
**  minimum requested propagation delay : 500 ns
**
**  https://www.kvaser.com/support/calculators/bit-timing-calculator/
**  T1 	T2 	BTQ 	SP% 	SJW 	BIT RATE 	ERR% 	BTR0 	BTR1
**  17	8	25	    68	     1	      100	    0	      04	7f
*/
#define BTR0 0x04
#define BTR1 0x7f


/* 
** Stacks for each task are allocated here in the application in this case = 256 bytes
** but you can change size if required
*/

OS_STK Task1Stk[STACKSIZE];
OS_STK Task2Stk[STACKSIZE];
OS_STK Task3Stk[STACKSIZE];
OS_STK Task4Stk[STACKSIZE];
OS_STK Task5Stk[STACKSIZE];
OS_STK Task6Stk[STACKSIZE];


// initialisation for Can controller 0
void Init_CanBus_Controller0(void);
// initialisation for Can controller 1
void Init_CanBus_Controller1(void);
// Transmit for sending a message via Can controller 0
void CanBus0_Transmit(int id, char data);
// Transmit for sending a message via Can controller 1
void CanBus1_Transmit(int id, char data);
// Receive for reading a received message via Can controller 0
void CanBus0_Receive(void);
// Receive for reading a received message via Can controller 1
void CanBus1_Receive(void);
void CanBusTest(void);

// I2C prototypes
void I2C_Init(void);
void WriteI2CInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB, unsigned char data, int flag);
void PageWriteI2CInteraction(unsigned int AddressFrom, unsigned int AddressTo, unsigned char data);
void ReadI2CByteInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB);
void ReadI2CSequential(int block, int AddressTo, int AddressFrom,  unsigned int ChipAddress);
void DACWrite(void);
char ADCRead(int);
void WriteI2C(void);
void ReadI2C(void);
void PageWriteI2C(void);
void SeqReadI2C(void);

void Task1(void *);	/* (void *) means the child task expects no data from parent*/
void Task2(void *);
void Task3(void *);
void Task4(void *);
void Task5(void *);

void Enable_SCL(void){
    I2C_CLK_PRESCALE_LOW = 0x31;
    I2C_CLK_PRESCALE_HIGH = 0x00;
}

void WaitTIP(void){
    int TIP_bit;
    do{
        TIP_bit = (I2C_STAT >> 1) & 0x01; // this flag represents acknowledge from the addressed slave | ‘1’ = No acknowledge received | ‘0’ = Acknowledge received
    }while(TIP_bit != 0);
}

void WaitACK(void){
    int ACK;
    do{
        ACK = (I2C_STAT >> 7) & 0x01;
    }while(ACK != 0);
}

///////////////////////////////////
// I2C controller initialization //
///////////////////////////////////
void I2C_Init(void){
    Enable_SCL();
    Enable_I2C_Controller();
}

///////////////////////////////////////////////
// write a single byte to the EEPROM via I2C //
///////////////////////////////////////////////
void WriteI2CInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB, unsigned char data, int flag){
    unsigned char controlByte;
    // determine the block of interest 
    if (block == 1) {
        controlByte = EEPROM_Write_Block_1;
    } 
    else {
        controlByte = EEPROM_Write_Block_0;
    }

    // wait for TIP
    WaitTIP();
    // store the data to TX register
    I2C_TX = controlByte;
    // command to generate start condition, write, and clear pending interrupt 
    I2C_CMD = I2C_CMD_Slave_Write_With_Start;

    //Wait for TIP bit in Status Register
    WaitTIP();
    //Wait RxACK bit in Status Register
    WaitACK();

    // send the most significant byte of the address
    I2C_TX = AddressMSB;
    // command to write and clear pending interrupt 
    I2C_CMD = I2C_CMD_Slave_Write;
    
    WaitTIP();
    WaitACK();

    // send the least significant byte of the address
    I2C_TX = AddressLSB;
    I2C_CMD = I2C_CMD_Slave_Write;
    
    WaitTIP();
    WaitACK();
    
    // send data
    I2C_TX = data;
    I2C_CMD = I2C_CMD_Slave_Write_Stop;
    
    WaitTIP();
    WaitACK();

    if(flag == 0){
        printf("\r\nWrote [%x] to Address[%x]", data, Address);
    }
}

//////////////////////////////////////////////////
// write up to 128k bytes to the EEPROM via I2C //
//////////////////////////////////////////////////
void PageWriteI2CInteraction(unsigned int AddressFrom, unsigned int AddressTo, unsigned char data){
    int flag = 0;
    int flag_special = 0;
    int i = 0;
    unsigned char controlByte;
    unsigned char AddressFromMSB;
    unsigned char AddressFromLSB;
    unsigned char AddressRange;
    unsigned int AddressFrom_Initial;
    AddressFrom_Initial = AddressFrom;

    while(AddressFrom < AddressTo){
        if (AddressFrom + 128 > AddressTo) {
            flag = 1;
        }
        if (AddressFrom > 0xFFFF) {
            controlByte = EEPROM_Write_Block_1;
            AddressFromMSB = ((AddressFrom - 0x10000) >> 8) & 0xFF;
            AddressFromLSB = (AddressFrom - 0x10000) & 0xFF;
        }
        else {
            controlByte = EEPROM_Write_Block_0;
            AddressFromMSB = (AddressFrom >> 8) & 0xFF;
            AddressFromLSB = AddressFrom & 0xFF;
        }
        
        WaitTIP();
        
        I2C_TX = controlByte;
        I2C_CMD = I2C_CMD_Slave_Write_With_Start;
        
        WaitTIP();
        WaitACK();
        
        I2C_TX = AddressFromMSB;
        I2C_CMD = I2C_CMD_Slave_Write;
        
        WaitTIP();
        WaitACK();
        
        I2C_TX = AddressFromLSB;
        I2C_CMD = I2C_CMD_Slave_Write;
        
        WaitTIP();
        WaitACK();

        if(flag == 0){
            for (i = 0; i < 128; i++){  // limit write to 128 bytes
                I2C_TX = data;
                I2C_CMD = I2C_CMD_Slave_Write;
                
                WaitTIP();
                WaitACK();
                if((AddressFrom + i) % 128 == 0){
                    break;
                }
                // check if need to switch blocks
                if(AddressFrom + i == 0xFFFF){
                    break;
                }
            }
        }
        else {
            AddressRange = AddressTo - AddressFrom;
            for(i = 0; i < AddressRange; i++){                
                I2C_TX = data;
                I2C_CMD = I2C_CMD_Slave_Write;
                
                WaitTIP();
                WaitACK();
                if((AddressFrom + i) % 128 == 0){
                    break;
                }
                // check if need to switch blocks
                if(AddressFrom + i == 0xFFFF){
                    break;
                }
            }
        }
        
        I2C_CMD = I2C_CMD_Slave_Write_Stop;

        WaitTIP();
        WaitACK();

        do {
            I2C_TX = controlByte;
            I2C_CMD = I2C_CMD_Slave_Write_With_Start;
            WaitTIP();
        } while (((I2C_STAT >> 7) & 0x01) != 0); // wait for acknowledgement from the slave

        AddressFrom += (i + 1);
    }

    // special case for end address being the first byte of the next/last page
    if (((AddressFrom + i) % 128 == 0) && (flag == 1)) {
        if((AddressFrom + i) > 0xFFFF){
            controlByte = EEPROM_Write_Block_1;
            AddressFromMSB = (((AddressFrom + i) - 0x10000) >> 8) & 0xFF;
            AddressFromLSB = ((AddressFrom + i) - 0x10000) & 0xFF;
            WriteI2CInteraction(1, (AddressFrom + i), AddressFromMSB, AddressFromLSB, data, 1);
        }
        else {
            controlByte = EEPROM_Write_Block_0;
            AddressFromMSB = ((AddressFrom + i) >> 8) & 0xFF;
            AddressFromLSB = (AddressFrom + i) & 0xFF;
            WriteI2CInteraction(0, (AddressFrom + i), AddressFromMSB, AddressFromLSB, data, 1);
        }
    }
    printf("\r\nWrote [%x] from Address[%x] to Address[%x]", data, AddressFrom_Initial, AddressTo);
}

///////////////////////////////////////////////
// read a single byte to the EEPROM via I2C //
///////////////////////////////////////////////
void ReadI2CByteInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB){
    unsigned char controleByte_ForWrite;
    unsigned char controlByte_ForRead;
    unsigned char readData;
    if(block == 1){
        controleByte_ForWrite= 162;
        controlByte_ForRead = 163;
    }else{
        controleByte_ForWrite = 160;
        controlByte_ForRead = 161;
    }

    WaitTIP();
    I2C_TX = controleByte_ForWrite;
    I2C_CMD = 145;

    WaitTIP();
    WaitACK();

    I2C_TX = AddressMSB;
    I2C_CMD = 17;

    WaitTIP();
    WaitACK();

    I2C_TX = AddressLSB;
    I2C_CMD = 17;

    WaitTIP();
    WaitACK();

    I2C_TX = controlByte_ForRead;
    I2C_CMD = 145;

    WaitTIP();
    WaitACK();

    I2C_CMD = 105;

    WaitTIP();

    while((I2C_STAT & 0x01) != 0x01) {
    }

    I2C_STAT = 0;

    readData = I2C_RX;

    printf("\r\nRead [%x] from Address[%x]", readData, Address);

    return;
}

//////////////////////////////////////////////////
// read up to 128k bytes to the EEPROM via I2C //
//////////////////////////////////////////////////
void ReadI2CSequential(int block, int AddressTo, int AddressFrom,  unsigned int ChipAddress){
    unsigned char controleWriteByte;
    unsigned char controlReadByte;
    unsigned char readData;
    unsigned char AddressLSB;
    unsigned char AddressMSB;
    int i;
    int size;
    int block_change_flag = 0;
    int block_address;
    size = AddressTo - AddressFrom;

    AddressMSB = (ChipAddress >> 8) & 0xFF;
    AddressLSB = ChipAddress & 0xFF;

    if(block == 1){
        controleWriteByte = EEPROM_Write_Block_1;
        controlReadByte = EEPROM_Read_Block_1;
        AddressMSB = ((ChipAddress-0x10000) >> 8) & 0xFF;
        AddressLSB = (ChipAddress-0x10000) & 0xFF;
    }else{
        controleWriteByte = EEPROM_Write_Block_0;
        controlReadByte = EEPROM_Read_Block_0;
    }

    WaitTIP();

    I2C_TX = controleWriteByte;
    I2C_CMD = I2C_CMD_Slave_Write_With_Start;

    WaitTIP();
    WaitACK();

    I2C_TX = AddressMSB;
    I2C_CMD = I2C_CMD_Slave_Write;

    WaitTIP();
    WaitACK();

    I2C_TX = AddressLSB;
    I2C_CMD = I2C_CMD_Slave_Write;

    WaitTIP();
    WaitACK();

    I2C_TX = controlReadByte;
    I2C_CMD = I2C_CMD_Slave_Write_With_Start;

    WaitTIP();
    WaitACK();
    block_address = ChipAddress;

    for (i = 0; i < size; i++){

        if(block_address == 0x10000){ // if need to switch blocks 
            I2C_CMD = I2C_CMD_Slave_Read_Ack;

            WaitTIP();

            while(I2C_STAT & 0x01 == 0x00);

            readData = I2C_RX;
            I2C_CMD = I2C_CMD_Slave_Read_Stop; // instead of sending a stop command
            
            // printf("\r\nADDR: %x, DATA: %x\r\n",ChipAddress,readData);
            WaitTIP();

            block_change_flag = 1;
        } else {
            I2C_CMD = I2C_CMD_Slave_Read;
            WaitTIP();

            while((I2C_STAT & 0x01) != 0x01) {
            }

            I2C_STAT = 0;

            readData = I2C_RX;

            printf("\r\nRead [%x] from Address[%x]", readData, ChipAddress);
            ChipAddress++;
            block_address++;
        }
        if (block_change_flag) {
            controleWriteByte = EEPROM_Write_Block_1;
            controlReadByte = EEPROM_Read_Block_1;
            AddressMSB = 0;
            AddressLSB = 0;

            WaitTIP();

            I2C_TX = controleWriteByte;
            I2C_CMD = I2C_CMD_Slave_Write_With_Start;

            WaitTIP();
            WaitACK();

            I2C_TX = AddressMSB;
            I2C_CMD = I2C_CMD_Slave_Write;

            WaitTIP();
            WaitACK();

            I2C_TX = AddressLSB;
            I2C_CMD = I2C_CMD_Slave_Write;

            WaitTIP();
            WaitACK();

            I2C_TX = controlReadByte;
            I2C_CMD = I2C_CMD_Slave_Write_With_Start;

            WaitTIP();
            WaitACK();

            block_change_flag = 0;
            block_address = 0;
        }
       
    }

    I2C_CMD = I2C_CMD_Slave_Read_Ack;

    WaitTIP();

    while(I2C_STAT & 0x01 == 0x00);
    I2C_CMD = I2C_CMD_Slave_Read_Stop;

    printf("\r\nBlock Read operation complete\r\n");
    return;
}

///////////////////////////////////////////////
// generate a waveform (square wave) via DAC //
///////////////////////////////////////////////
void DACWrite(void) {
    int i;
    unsigned int delay = 0xFFFFF;

    printf("\nI2C DAC Write: Please check LED\n");

    WaitTIP();

    I2C_TX = ADC_DAC_Write_Address;
    I2C_CMD = I2C_CMD_Slave_Write_With_Start;

    WaitTIP();
    WaitACK();

    I2C_TX = DAC_CMD_Enable;
    I2C_CMD = I2C_CMD_Slave_Write;

    WaitTIP();
    WaitACK();

    I2C_TX = 0xFF; 
    I2C_CMD = I2C_CMD_Slave_Write;

    WaitTIP();
    WaitACK();

    while(1) { // keep blinking the LED
        unsigned int val = 0xFF; // digital high

        I2C_TX = val; 
        I2C_CMD = I2C_CMD_Slave_Write;

        WaitTIP();
        WaitACK();

        for(i = 0; i < delay; i++);

        val = 0x00; // digital low
        I2C_TX = val;
        I2C_CMD = I2C_CMD_Slave_Write;

        WaitTIP();
        WaitACK();

        for(i = 0; i < delay; i++);
    }
}

///////////////////////////////////////////////
// generate a waveform (square wave) via DAC //
///////////////////////////////////////////////
char ADCRead(int arg){
    unsigned char thermistor_value;
    unsigned char potentiometer_value;
    unsigned char photo_resistor_value;
    unsigned int delay = 0xFFFFF;
    unsigned char result;

    WaitTIP();

    I2C_TX = ADC_DAC_Write_Address;
    I2C_CMD = I2C_CMD_Slave_Write_With_Start;

    WaitTIP();
    WaitACK();

    I2C_TX = ADC_CMD_Enable;
    I2C_CMD = I2C_CMD_Slave_Write;

    WaitTIP();
    WaitACK();

    I2C_TX = ADC_Read_Address;
    I2C_CMD = I2C_CMD_Slave_Write_With_Start;

    WaitTIP();
    WaitACK();

    I2C_CMD = I2C_CMD_Slave_Read;

    WaitTIP();

    // measure thermistor 
    I2C_CMD = I2C_CMD_Slave_Read;
    WaitTIP();
    thermistor_value = I2C_RX;

    // measure potentiometer 
    I2C_CMD = I2C_CMD_Slave_Read;
    WaitTIP();
    potentiometer_value = I2C_RX;

    // measure photo resistor 
    I2C_CMD = I2C_CMD_Slave_Read;
    WaitTIP();
    photo_resistor_value = I2C_RX;

    result = 0;

    if (arg == 0) {
        // printf("Value of Thermistor: %d\n", thermistor_value);
        result = thermistor_value;
    } else if (arg == 1) {
        // printf("Value of Potentiometer: %d\n", potentiometer_value);
        result = potentiometer_value;
    } else if (arg == 2) {
        // printf("Value of Photo-resister: %d\n", photo_resistor_value);
        result = photo_resistor_value;
    } else if (arg == 3) {
        // printf("Value of Thermistor: %d Potentiometer: %d Photo-resister: %d\n", thermistor_value, potentiometer_value, photo_resistor_value);
        result = 0xff;
    } 
    return result;
}


// initialisation for Can controller 0
void Init_CanBus_Controller0(void)
{
    // TODO - put your Canbus initialisation code for CanController 0 here
    // See section 4.2.1 in the application note for details (PELICAN MODE)
    /* define interrupt priority & control (level-activated, see chapter 4.2.5) */

    // PX0 = PRIORITY_HIGH; /* CAN HAS A HIGH PRIORITY INTERRUPT */
    // IT0 = INTLEVELACT; /* set interrupt0 to level activated */
    // /* enable the communication interface of the SJA1000 */
    // CS = ENABLE_N; /* Enable the SJA1000 interface */

    // /* disable interrupts, if used (not necessary after power-on) */
    // EA = DISABLE; /* disable all interrupts */
    // SJAIntEn = DISABLE; /* disable external interrupt from SJA1000 */
    // /* set reset mode/request (Note: after power-on SJA1000 is in BasicCAN mode)
    // leave loop after a time out and signal an error */

    while ((Can0_ModeControlReg & RM_RR_Bit) == ClrByte){
    /* other bits than the reset mode/request bit are unchanged */
        Can0_ModeControlReg = Can0_ModeControlReg | RM_RR_Bit;
    }

    // Set clock divide register to use pelican mode and bypass CAN input comparator (possible only in reset mode)
    Can0_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy2;

    /* disable CAN interrupts, if required (always necessary after power-on)
    (write to SJA1000 Interrupt Enable / Control Register) */
    Can0_InterruptEnReg = ClrIntEnSJA;

    /* define acceptance code and mask */
    Can0_AcceptCode0Reg = ClrByte;
    Can0_AcceptCode1Reg = ClrByte;
    Can0_AcceptCode2Reg = ClrByte;
    Can0_AcceptCode3Reg = ClrByte;
    Can0_AcceptMask0Reg = DontCare; /* every identifier is accepted */
    Can0_AcceptMask1Reg = DontCare; /* every identifier is accepted */
    Can0_AcceptMask2Reg = DontCare; /* every identifier is accepted */
    Can0_AcceptMask3Reg = DontCare; /* every identifier is accepted */

    /* configure bus timing */
    /* bit-rate = 100 kbit/s @ 25 MHz, the bus is sampled once */
    Can0_BusTiming0Reg = BTR0;
    Can0_BusTiming1Reg = BTR1;

    /* configure CAN outputs: float on TX1, Push/Pull on TX0, normal output mode */
    Can0_OutControlReg = Tx0Float | Tx0PshPull | NormalMode;

    // Set mode control to clr
    do {
        Can0_ModeControlReg = ClrByte;
    } while ((Can0_ModeControlReg & RM_RR_Bit) != ClrByte);
}

// initialisation for Can controller 1
void Init_CanBus_Controller1(void)
{
    // TODO - put your Canbus initialisation code for CanController 1 here
    // See section 4.2.1 in the application note for details (PELICAN MODE)

    while ((Can1_ModeControlReg & RM_RR_Bit) == ClrByte){
    /* other bits than the reset mode/request bit are unchanged */
        Can1_ModeControlReg = Can1_ModeControlReg | RM_RR_Bit;
    }

    // Set clock divide register to use pelican mode and bypass CAN input comparator (possible only in reset mode)
    Can1_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy2;

    /* disable CAN interrupts, if required (always necessary after power-on)
    (write to SJA1000 Interrupt Enable / Control Register) */
    Can1_InterruptEnReg = ClrIntEnSJA;

    /* define acceptance code and mask */
    Can1_AcceptCode0Reg = ClrByte;
    Can1_AcceptCode1Reg = ClrByte;
    Can1_AcceptCode2Reg = ClrByte;
    Can1_AcceptCode3Reg = ClrByte;
    Can1_AcceptMask0Reg = DontCare; /* every identifier is accepted */
    Can1_AcceptMask1Reg = DontCare; /* every identifier is accepted */
    Can1_AcceptMask2Reg = DontCare; /* every identifier is accepted */
    Can1_AcceptMask3Reg = DontCare; /* every identifier is accepted */

    /* configure bus timing */
    /* bit-rate = 100 kbit/s @ 25 MHz, the bus is sampled once */
    Can1_BusTiming0Reg = BTR0;
    Can1_BusTiming1Reg = BTR1;

    /* configure CAN outputs: float on TX1, Push/Pull on TX0, normal output mode */
    Can1_OutControlReg = Tx0Float | Tx0PshPull | NormalMode;

    // Set mode control to clr
    do {
        Can1_ModeControlReg = ClrByte;
    } while ((Can1_ModeControlReg & RM_RR_Bit) != ClrByte);
}

// Transmit for sending a message via Can controller 0
void CanBus0_Transmit(int id, char data)
{
    // TODO - put your Canbus transmit code for CanController 0 here
    // See section 4.2.2 in the application note for details (PELICAN MODE)

    /* wait until the Transmit Buffer is released */
    do
    {
    /* start a polling timer and run some tasks while waiting
    break the loop and signal an error if time too long */
    } while((Can0_StatusReg & TBS_Bit ) != TBS_Bit );
    /* Transmit Buffer is released, a message may be written into the buffer */
    /* in this example a Standard Frame message shall be transmitted */
    Can0_TxFrameInfo = 0x08; /* SFF (data), DLC=8 */
    Can0_TxBuffer1 = 0xA5; /* ID1 = A5, (1010 0101) */
    Can0_TxBuffer2 = 0x20; /* ID2 = 20, (0010 0000) */
    Can0_TxBuffer3 = id; 
    Can0_TxBuffer4 = data; 
    /* Start the transmission */
    Can0_CommandReg = TR_Bit ; /* Set Transmission Request bit */
}

// Transmit for sending a message via Can controller 1
void CanBus1_Transmit(int id, char data)
{
    // TODO - put your Canbus transmit code for CanController 1 here
    // See section 4.2.2 in the application note for details (PELICAN MODE)

    /* wait until the Transmit Buffer is released */
    do
    {
    /* start a polling timer and run some tasks while waiting
    break the loop and signal an error if time too long */
    } while((Can1_StatusReg & TBS_Bit ) != TBS_Bit );
    /* Transmit Buffer is released, a message may be written into the buffer */
    /* in this example a Standard Frame message shall be transmitted */
    Can1_TxFrameInfo = 0x08; /* SFF (data), DLC=8 */
    Can1_TxBuffer1 = 0xA5; /* ID1 = A5, (1010 0101) */
    Can1_TxBuffer2 = 0x20; /* ID2 = 20, (0010 0000) */
    Can1_TxBuffer3 = 0x32; /* data1 = 51 */
    Can1_TxBuffer4 = 0x42; /* data2 = 52*/
    Can1_TxBuffer10 = 0x12; /* data8 = 58 */
    /* Start the transmission */
    Can1_CommandReg = TR_Bit ; /* Set Transmission Request bit */
}

// Receive for reading a received message via Can controller 0
void CanBus0_Receive(void)
{
    // TODO - put your Canbus receive code for CanController 0 here
    // See section 4.2.4 in the application note for details (PELICAN MODE)
    unsigned char numArray[2];
    unsigned char dataArray[10];

    do{ }while((Can0_StatusReg & RBS_Bit) != RBS_Bit);

    numArray[0] = Can0_RxBuffer1 & 0xff;
    numArray[1] = Can0_RxBuffer2 & 0xff;

    //data bits
    dataArray[0] = Can0_RxBuffer3;
    dataArray[1] = Can0_RxBuffer4;

    Can0_CommandReg = RRB_Bit;
    printf("Can0 recieve data at index 0: %d\n", dataArray[0]);
    printf("Can0 recieve data at index 1: %d\n", dataArray[1]);
}

// Receive for reading a received message via Can controller 1
void CanBus1_Receive(void)
{
    // TODO - put your Canbus receive code for CanController 0 here
    // See section 4.2.4 in the application note for details (PELICAN MODE)
    unsigned char numArray[2];
    unsigned char dataArray[10];

    do{ }while((Can1_StatusReg & RBS_Bit) != RBS_Bit);

    numArray[0] = Can1_RxBuffer1 & 0xff;
    numArray[1] = Can1_RxBuffer2 & 0xff;

    //data bits
    dataArray[0] = Can1_RxBuffer3;
    dataArray[1] = Can1_RxBuffer4;

    Can1_CommandReg = RRB_Bit;
    printf("Can1 recieve data at index 0: %d\n", dataArray[0]);
    printf("Can1 recieve data at index 1: %d\n", dataArray[1]);
}

void CanBusTest(void)
{
    int i;
    // initialise the two Can controllers

    Init_CanBus_Controller0();
    Init_CanBus_Controller1();

    printf("\r\n\r\n---- CANBUS Test ----\r\n") ;

    // simple application to alternately transmit and receive messages from each of two nodes

    while (1) {
        for (i = 0; i < 500; i++) {
            Wait1ms();
        }

        CanBus0_Transmit(1, 0x10) ;       // transmit a message via Controller 0
        CanBus1_Receive() ;        // receive a message via Controller 1 (and display it)

        printf("\r\n") ;

        for (i = 0; i < 500; i++) {
            Wait1ms();
        }

        CanBus1_Transmit(1, 0x11) ;        // transmit a message via Controller 1
        CanBus0_Receive() ;         // receive a message via Controller 0 (and display it)
        printf("\r\n") ;
    }
    
}
/* 
** Our main application which has to
** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
** 2) Call OSInit() to initialise the OS
** 3) Create our application task/threads
** 4) Call OSStart()
*/

void main(void)
{
    // initialise board hardware by calling our routines from the BIOS.C source file

    Init_RS232();
    Init_LCD();
    I2C_Init();
    Init_CanBus_Controller0();
    Init_CanBus_Controller1();

/* display welcome message on LCD display */

    Oline0("Altera DE1/68K");
    Oline1("Micrium uC/OS-II RTOS");

    OSInit();		// call to initialise the OS

/* 
** Now create the 4 child tasks and pass them no data.
** the smaller the numerical priority value, the higher the task priority 
*/

    OSTaskCreate(Task1, OS_NULL, &Task1Stk[STACKSIZE], 11);     
    OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 13);     // highest priority task
    OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 14);
    OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 15);	    // lowest priority task
    OSTaskCreate(Task5, OS_NULL, &Task5Stk[STACKSIZE], 12);

    OSStart();  // call to start the OS scheduler, (never returns from this function)
}

/*
** IMPORTANT : Timer 1 interrupts must be started by the highest priority task 
** that runs first which is Task2
*/

void Task1(void *pdata)
{
    Timer1_Init() ;      // this function is in BIOS.C and written by us to start timer   
    for (;;) {
       CanBus0_Transmit(0, PortA);
       OSTimeDly(10);
    }
}

/*
** Task 2 below was created with the highest priority so it must start timer1
** so that it produces interrupts for the 100hz context switches
*/

void Task2(void *pdata)
{   
    for (;;) {
       CanBus0_Transmit(1, ADCRead(1));
       OSTimeDly(20);
    }
}

void Task3(void *pdata)
{
    for (;;) {
       CanBus0_Transmit(2, ADCRead(2));
       OSTimeDly(50);
    }
}

void Task4(void *pdata)
{
    for (;;) {
       CanBus0_Transmit(3, ADCRead(0));
       OSTimeDly(200);
    }
}

void Task5(void *pdata)
{
    for (;;) {
       CanBus1_Receive();
    }
}
