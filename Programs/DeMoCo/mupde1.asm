; D:\CPEN412\M68K\PROGRAMS\DEMOCO\MUPDE1.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include <string.h>
; #include <ctype.h>
; //IMPORTANT
; //
; // Uncomment one of the two #defines below
; // Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
; // 0B000000 for running programs from dram
; //
; // In your labs, you will initially start by designing a system with SRam and later move to
; // Dram, so these constants will need to be changed based on the version of the system you have
; // building
; //
; // The working 68k system SOF file posted on canvas that you can use for your pre-lab
; // is based around Dram so #define accordingly before building
; //#define StartOfExceptionVectorTable 0x08030000
; #define StartOfExceptionVectorTable 0x0B000000
; /**********************************************************************************************
; **	Parallel port addresses
; **********************************************************************************************/
; #define PortA   *(volatile unsigned char *)(0x00400000)
; #define PortB   *(volatile unsigned char *)(0x00400002)
; #define PortC   *(volatile unsigned char *)(0x00400004)
; #define PortD   *(volatile unsigned char *)(0x00400006)
; #define PortE   *(volatile unsigned char *)(0x00400008)
; /*********************************************************************************************
; **	Hex 7 seg displays port addresses
; *********************************************************************************************/
; #define HEX_A        *(volatile unsigned char *)(0x00400010)
; #define HEX_B        *(volatile unsigned char *)(0x00400012)
; #define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
; #define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only
; /**********************************************************************************************
; **	LCD display port addresses
; **********************************************************************************************/
; #define LCDcommand   *(volatile unsigned char *)(0x00400020)
; #define LCDdata      *(volatile unsigned char *)(0x00400022)
; /********************************************************************************************
; **	Timer Port addresses
; *********************************************************************************************/
; #define Timer1Data      *(volatile unsigned char *)(0x00400030)
; #define Timer1Control   *(volatile unsigned char *)(0x00400032)
; #define Timer1Status    *(volatile unsigned char *)(0x00400032)
; #define Timer2Data      *(volatile unsigned char *)(0x00400034)
; #define Timer2Control   *(volatile unsigned char *)(0x00400036)
; #define Timer2Status    *(volatile unsigned char *)(0x00400036)
; #define Timer3Data      *(volatile unsigned char *)(0x00400038)
; #define Timer3Control   *(volatile unsigned char *)(0x0040003A)
; #define Timer3Status    *(volatile unsigned char *)(0x0040003A)
; #define Timer4Data      *(volatile unsigned char *)(0x0040003C)
; #define Timer4Control   *(volatile unsigned char *)(0x0040003E)
; #define Timer4Status    *(volatile unsigned char *)(0x0040003E)
; /*********************************************************************************************
; **	RS232 port addresses
; *********************************************************************************************/
; #define RS232_Control     *(volatile unsigned char *)(0x00400040)
; #define RS232_Status      *(volatile unsigned char *)(0x00400040)
; #define RS232_TxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_RxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_Baud        *(volatile unsigned char *)(0x00400044)
; /*********************************************************************************************
; **	PIA 1 and 2 port addresses
; *********************************************************************************************/
; #define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
; #define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
; #define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
; #define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)
; #define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
; #define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
; #define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
; #define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)
; //////////////////////////////
; // I2C Controller Registers //
; //////////////////////////////
; #define I2C_CLK_PRESCALE_LOW (*(volatile unsigned char *)(0x00408000))
; #define I2C_CLK_PRESCALE_HIGH (*(volatile unsigned char *)(0x00408002))
; #define I2C_CTRL (*(volatile unsigned char *)(0x00408004))
; #define I2C_TX (*(volatile unsigned char *)(0x00408006))
; #define I2C_RX (*(volatile unsigned char *)(0x00408006))
; #define I2C_CMD (*(volatile unsigned char *)(0x00408008))
; #define I2C_STAT (*(volatile unsigned char *)(0x00408008))
; //////////////////
; // I2C Commands //
; //////////////////
; #define I2C_CMD_Slave_Write_With_Start 0x91 // 1001 0001
; #define I2C_CMD_Slave_Read_With_Start 0xA9  // 1010 1001
; #define I2C_CMD_Slave_Write 0x11            // 0001 0001
; #define I2C_CMD_Slave_Read 0x21             // 0010 0001
; #define I2C_CMD_Slave_Read_Ack 0x29         // 0010 1001
; #define I2C_CMD_Slave_Write_Stop 0x51       // 0101 0001
; #define I2C_CMD_Slave_Read_Stop 0x49        // 0100 1001
; /////////////////////
; // EEPROM Commands //
; /////////////////////
; #define EEPROM_Write_Block_1 0xA2           // 1010 0010
; #define EEPROM_Read_Block_1 0xA3            // 1010 0011
; #define EEPROM_Write_Block_0 0xA0           // 1010 0000
; #define EEPROM_Read_Block_0 0xA1            // 1010 0001
; //////////////////////
; // ADC/DAC Commands //
; //////////////////////
; #define ADC_DAC_Write_Address 0x90          // 1001 0000
; #define ADC_Read_Address 0x91               // 1001 0001
; #define ADC_CMD_Enable 0x44                 // 0100 0100
; #define DAC_CMD_Enable 0x40                 // 0100 0000
; #define Enable_I2C_Controller() I2C_CTRL = 0x80     // 1000 0000
; /*********************************************************************************************
; ** These addresses and definitions were taken from Appendix 7 of the Can Controller
; ** application note and adapted for the 68k assignment
; *********************************************************************************************/
; /*
; ** definition for the SJA1000 registers and bits based on 68k address map areas
; ** assume the addresses for the 2 can controllers given in the assignment
; **
; ** Registers are defined in terms of the following Macro for each Can controller,
; ** where (i) represents an registers number
; */
; #define CAN0_CONTROLLER(i) (*(volatile unsigned char *)(0x00500000 + (i << 1)))
; #define CAN1_CONTROLLER(i) (*(volatile unsigned char *)(0x00500200 + (i << 1)))
; /* Can 0 register definitions */
; #define Can0_ModeControlReg      CAN0_CONTROLLER(0)
; #define Can0_CommandReg          CAN0_CONTROLLER(1)
; #define Can0_StatusReg           CAN0_CONTROLLER(2)
; #define Can0_InterruptReg        CAN0_CONTROLLER(3)
; #define Can0_InterruptEnReg      CAN0_CONTROLLER(4) /* PeliCAN mode */
; #define Can0_BusTiming0Reg       CAN0_CONTROLLER(6)
; #define Can0_BusTiming1Reg       CAN0_CONTROLLER(7)
; #define Can0_OutControlReg       CAN0_CONTROLLER(8)
; /* address definitions of Other Registers */
; #define Can0_ArbLostCapReg       CAN0_CONTROLLER(11)
; #define Can0_ErrCodeCapReg       CAN0_CONTROLLER(12)
; #define Can0_ErrWarnLimitReg     CAN0_CONTROLLER(13)
; #define Can0_RxErrCountReg       CAN0_CONTROLLER(14)
; #define Can0_TxErrCountReg       CAN0_CONTROLLER(15)
; #define Can0_RxMsgCountReg       CAN0_CONTROLLER(29)
; #define Can0_RxBufStartAdr       CAN0_CONTROLLER(30)
; #define Can0_ClockDivideReg      CAN0_CONTROLLER(31)
; /* address definitions of Acceptance Code & Mask Registers - RESET MODE */
; #define Can0_AcceptCode0Reg      CAN0_CONTROLLER(16)
; #define Can0_AcceptCode1Reg      CAN0_CONTROLLER(17)
; #define Can0_AcceptCode2Reg      CAN0_CONTROLLER(18)
; #define Can0_AcceptCode3Reg      CAN0_CONTROLLER(19)
; #define Can0_AcceptMask0Reg      CAN0_CONTROLLER(20)
; #define Can0_AcceptMask1Reg      CAN0_CONTROLLER(21)
; #define Can0_AcceptMask2Reg      CAN0_CONTROLLER(22)
; #define Can0_AcceptMask3Reg      CAN0_CONTROLLER(23)
; /* address definitions Rx Buffer - OPERATING MODE - Read only register*/
; #define Can0_RxFrameInfo         CAN0_CONTROLLER(16)
; #define Can0_RxBuffer1           CAN0_CONTROLLER(17)
; #define Can0_RxBuffer2           CAN0_CONTROLLER(18)
; #define Can0_RxBuffer3           CAN0_CONTROLLER(19)
; #define Can0_RxBuffer4           CAN0_CONTROLLER(20)
; #define Can0_RxBuffer5           CAN0_CONTROLLER(21)
; #define Can0_RxBuffer6           CAN0_CONTROLLER(22)
; #define Can0_RxBuffer7           CAN0_CONTROLLER(23)
; #define Can0_RxBuffer8           CAN0_CONTROLLER(24)
; #define Can0_RxBuffer9           CAN0_CONTROLLER(25)
; #define Can0_RxBuffer10          CAN0_CONTROLLER(26)
; #define Can0_RxBuffer11          CAN0_CONTROLLER(27)
; #define Can0_RxBuffer12          CAN0_CONTROLLER(28)
; /* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
; #define Can0_TxFrameInfo         CAN0_CONTROLLER(16)
; #define Can0_TxBuffer1           CAN0_CONTROLLER(17)
; #define Can0_TxBuffer2           CAN0_CONTROLLER(18)
; #define Can0_TxBuffer3           CAN0_CONTROLLER(19)
; #define Can0_TxBuffer4           CAN0_CONTROLLER(20)
; #define Can0_TxBuffer5           CAN0_CONTROLLER(21)
; #define Can0_TxBuffer6           CAN0_CONTROLLER(22)
; #define Can0_TxBuffer7           CAN0_CONTROLLER(23)
; #define Can0_TxBuffer8           CAN0_CONTROLLER(24)
; #define Can0_TxBuffer9           CAN0_CONTROLLER(25)
; #define Can0_TxBuffer10          CAN0_CONTROLLER(26)
; #define Can0_TxBuffer11          CAN0_CONTROLLER(27)
; #define Can0_TxBuffer12          CAN0_CONTROLLER(28)
; /* read only addresses */
; #define Can0_TxFrameInfoRd       CAN0_CONTROLLER(96)
; #define Can0_TxBufferRd1         CAN0_CONTROLLER(97)
; #define Can0_TxBufferRd2         CAN0_CONTROLLER(98)
; #define Can0_TxBufferRd3         CAN0_CONTROLLER(99)
; #define Can0_TxBufferRd4         CAN0_CONTROLLER(100)
; #define Can0_TxBufferRd5         CAN0_CONTROLLER(101)
; #define Can0_TxBufferRd6         CAN0_CONTROLLER(102)
; #define Can0_TxBufferRd7         CAN0_CONTROLLER(103)
; #define Can0_TxBufferRd8         CAN0_CONTROLLER(104)
; #define Can0_TxBufferRd9         CAN0_CONTROLLER(105)
; #define Can0_TxBufferRd10        CAN0_CONTROLLER(106)
; #define Can0_TxBufferRd11        CAN0_CONTROLLER(107)
; #define Can0_TxBufferRd12        CAN0_CONTROLLER(108)
; /* CAN1 Controller register definitions */
; #define Can1_ModeControlReg      CAN1_CONTROLLER(0)
; #define Can1_CommandReg          CAN1_CONTROLLER(1)
; #define Can1_StatusReg           CAN1_CONTROLLER(2)
; #define Can1_InterruptReg        CAN1_CONTROLLER(3)
; #define Can1_InterruptEnReg      CAN1_CONTROLLER(4) /* PeliCAN mode */
; #define Can1_BusTiming0Reg       CAN1_CONTROLLER(6)
; #define Can1_BusTiming1Reg       CAN1_CONTROLLER(7)
; #define Can1_OutControlReg       CAN1_CONTROLLER(8)
; /* address definitions of Other Registers */
; #define Can1_ArbLostCapReg       CAN1_CONTROLLER(11)
; #define Can1_ErrCodeCapReg       CAN1_CONTROLLER(12)
; #define Can1_ErrWarnLimitReg     CAN1_CONTROLLER(13)
; #define Can1_RxErrCountReg       CAN1_CONTROLLER(14)
; #define Can1_TxErrCountReg       CAN1_CONTROLLER(15)
; #define Can1_RxMsgCountReg       CAN1_CONTROLLER(29)
; #define Can1_RxBufStartAdr       CAN1_CONTROLLER(30)
; #define Can1_ClockDivideReg      CAN1_CONTROLLER(31)
; /* address definitions of Acceptance Code & Mask Registers - RESET MODE */
; #define Can1_AcceptCode0Reg      CAN1_CONTROLLER(16)
; #define Can1_AcceptCode1Reg      CAN1_CONTROLLER(17)
; #define Can1_AcceptCode2Reg      CAN1_CONTROLLER(18)
; #define Can1_AcceptCode3Reg      CAN1_CONTROLLER(19)
; #define Can1_AcceptMask0Reg      CAN1_CONTROLLER(20)
; #define Can1_AcceptMask1Reg      CAN1_CONTROLLER(21)
; #define Can1_AcceptMask2Reg      CAN1_CONTROLLER(22)
; #define Can1_AcceptMask3Reg      CAN1_CONTROLLER(23)
; /* address definitions Rx Buffer - OPERATING MODE - Read only register*/
; #define Can1_RxFrameInfo         CAN1_CONTROLLER(16)
; #define Can1_RxBuffer1           CAN1_CONTROLLER(17)
; #define Can1_RxBuffer2           CAN1_CONTROLLER(18)
; #define Can1_RxBuffer3           CAN1_CONTROLLER(19)
; #define Can1_RxBuffer4           CAN1_CONTROLLER(20)
; #define Can1_RxBuffer5           CAN1_CONTROLLER(21)
; #define Can1_RxBuffer6           CAN1_CONTROLLER(22)
; #define Can1_RxBuffer7           CAN1_CONTROLLER(23)
; #define Can1_RxBuffer8           CAN1_CONTROLLER(24)
; #define Can1_RxBuffer9           CAN1_CONTROLLER(25)
; #define Can1_RxBuffer10          CAN1_CONTROLLER(26)
; #define Can1_RxBuffer11          CAN1_CONTROLLER(27)
; #define Can1_RxBuffer12          CAN1_CONTROLLER(28)
; /* address definitions of the Tx-Buffer - OPERATING MODE - Write only register */
; #define Can1_TxFrameInfo         CAN1_CONTROLLER(16)
; #define Can1_TxBuffer1           CAN1_CONTROLLER(17)
; #define Can1_TxBuffer2           CAN1_CONTROLLER(18)
; #define Can1_TxBuffer3           CAN1_CONTROLLER(19)
; #define Can1_TxBuffer4           CAN1_CONTROLLER(20)
; #define Can1_TxBuffer5           CAN1_CONTROLLER(21)
; #define Can1_TxBuffer6           CAN1_CONTROLLER(22)
; #define Can1_TxBuffer7           CAN1_CONTROLLER(23)
; #define Can1_TxBuffer8           CAN1_CONTROLLER(24)
; #define Can1_TxBuffer9           CAN1_CONTROLLER(25)
; #define Can1_TxBuffer10          CAN1_CONTROLLER(26)
; #define Can1_TxBuffer11          CAN1_CONTROLLER(27)
; #define Can1_TxBuffer12          CAN1_CONTROLLER(28)
; /* read only addresses */
; #define Can1_TxFrameInfoRd       CAN1_CONTROLLER(96)
; #define Can1_TxBufferRd1         CAN1_CONTROLLER(97)
; #define Can1_TxBufferRd2         CAN1_CONTROLLER(98)
; #define Can1_TxBufferRd3         CAN1_CONTROLLER(99)
; #define Can1_TxBufferRd4         CAN1_CONTROLLER(100)
; #define Can1_TxBufferRd5         CAN1_CONTROLLER(101)
; #define Can1_TxBufferRd6         CAN1_CONTROLLER(102)
; #define Can1_TxBufferRd7         CAN1_CONTROLLER(103)
; #define Can1_TxBufferRd8         CAN1_CONTROLLER(104)
; #define Can1_TxBufferRd9         CAN1_CONTROLLER(105)
; #define Can1_TxBufferRd10        CAN1_CONTROLLER(106)
; #define Can1_TxBufferRd11        CAN1_CONTROLLER(107)
; #define Can1_TxBufferRd12        CAN1_CONTROLLER(108)
; /* bit definitions for the Mode & Control Register */
; #define RM_RR_Bit 0x01 /* reset mode (request) bit */
; #define LOM_Bit 0x02 /* listen only mode bit */
; #define STM_Bit 0x04 /* self test mode bit */
; #define AFM_Bit 0x08 /* acceptance filter mode bit */
; #define SM_Bit  0x10 /* enter sleep mode bit */
; /* bit definitions for the Interrupt Enable & Control Register */
; #define RIE_Bit 0x01 /* receive interrupt enable bit */
; #define TIE_Bit 0x02 /* transmit interrupt enable bit */
; #define EIE_Bit 0x04 /* error warning interrupt enable bit */
; #define DOIE_Bit 0x08 /* data overrun interrupt enable bit */
; #define WUIE_Bit 0x10 /* wake-up interrupt enable bit */
; #define EPIE_Bit 0x20 /* error passive interrupt enable bit */
; #define ALIE_Bit 0x40 /* arbitration lost interr. enable bit*/
; #define BEIE_Bit 0x80 /* bus error interrupt enable bit */
; /* bit definitions for the Command Register */
; #define TR_Bit 0x01 /* transmission request bit */
; #define AT_Bit 0x02 /* abort transmission bit */
; #define RRB_Bit 0x04 /* release receive buffer bit */
; #define CDO_Bit 0x08 /* clear data overrun bit */
; #define SRR_Bit 0x10 /* self reception request bit */
; /* bit definitions for the Status Register */
; #define RBS_Bit 0x01 /* receive buffer status bit */
; #define DOS_Bit 0x02 /* data overrun status bit */
; #define TBS_Bit 0x04 /* transmit buffer status bit */
; #define TCS_Bit 0x08 /* transmission complete status bit */
; #define RS_Bit 0x10 /* receive status bit */
; #define TS_Bit 0x20 /* transmit status bit */
; #define ES_Bit 0x40 /* error status bit */
; #define BS_Bit 0x80 /* bus status bit */
; /* bit definitions for the Interrupt Register */
; #define RI_Bit 0x01 /* receive interrupt bit */
; #define TI_Bit 0x02 /* transmit interrupt bit */
; #define EI_Bit 0x04 /* error warning interrupt bit */
; #define DOI_Bit 0x08 /* data overrun interrupt bit */
; #define WUI_Bit 0x10 /* wake-up interrupt bit */
; #define EPI_Bit 0x20 /* error passive interrupt bit */
; #define ALI_Bit 0x40 /* arbitration lost interrupt bit */
; #define BEI_Bit 0x80 /* bus error interrupt bit */
; /* bit definitions for the Bus Timing Registers */
; #define SAM_Bit 0x80                        /* sample mode bit 1 == the bus is sampled 3 times, 0 == the bus is sampled once */
; /* bit definitions for the Output Control Register OCMODE1, OCMODE0 */
; #define BiPhaseMode 0x00 /* bi-phase output mode */
; #define NormalMode 0x02 /* normal output mode */
; #define ClkOutMode 0x03 /* clock output mode */
; /* output pin configuration for TX1 */
; #define OCPOL1_Bit 0x20 /* output polarity control bit */
; #define Tx1Float 0x00 /* configured as float */
; #define Tx1PullDn 0x40 /* configured as pull-down */
; #define Tx1PullUp 0x80 /* configured as pull-up */
; #define Tx1PshPull 0xC0 /* configured as push/pull */
; /* output pin configuration for TX0 */
; #define OCPOL0_Bit 0x04 /* output polarity control bit */
; #define Tx0Float 0x00 /* configured as float */
; #define Tx0PullDn 0x08 /* configured as pull-down */
; #define Tx0PullUp 0x10 /* configured as pull-up */
; #define Tx0PshPull 0x18 /* configured as push/pull */
; /* bit definitions for the Clock Divider Register */
; #define DivBy1 0x07 /* CLKOUT = oscillator frequency */
; #define DivBy2 0x00 /* CLKOUT = 1/2 oscillator frequency */
; #define ClkOff_Bit 0x08 /* clock off bit, control of the CLK OUT pin */
; #define RXINTEN_Bit 0x20 /* pin TX1 used for receive interrupt */
; #define CBP_Bit 0x40 /* CAN comparator bypass control bit */
; #define CANMode_Bit 0x80 /* CAN mode definition bit */
; /*- definition of used constants ---------------------------------------*/
; #define YES 1
; #define NO 0
; #define ENABLE 1
; #define DISABLE 0
; #define ENABLE_N 0
; #define DISABLE_N 1
; #define INTLEVELACT 0
; #define INTEDGEACT 1
; #define PRIORITY_LOW 0
; #define PRIORITY_HIGH 1
; /* default (reset) value for register content, clear register */
; #define ClrByte 0x00
; /* constant: clear Interrupt Enable Register */
; #define ClrIntEnSJA ClrByte
; /* definitions for the acceptance code and mask register */
; #define DontCare 0xFF
; /*  bus timing values for
; **  bit-rate : 100 kBit/s
; **  oscillator frequency : 25 MHz, 1 sample per bit, 0 tolerance %
; **  maximum tolerated propagation delay : 4450 ns
; **  minimum requested propagation delay : 500 ns
; **
; **  https://www.kvaser.com/support/calculators/bit-timing-calculator/
; **  T1 	T2 	BTQ 	SP% 	SJW 	BIT RATE 	ERR% 	BTR0 	BTR1
; **  17	8	25	    68	     1	      100	    0	      04	7f
; */
; #define BTR0 0x04
; #define BTR1 0x7f
; /*********************************************************************************************************************************
; (( DO NOT initialise global variables here, do it main even if you want 0
; (( it's a limitation of the compiler
; (( YOU HAVE BEEN WARNED
; *********************************************************************************************************************************/
; unsigned int i, x, y, z, PortA_Count;
; unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;
; /*******************************************************************************************
; ** Function Prototypes
; *******************************************************************************************/
; void Wait1ms(void);
; void Wait3ms(void);
; void Init_LCD(void) ;
; void LCDOutchar(int c);
; void LCDOutMess(char *theMessage);
; void LCDClearln(void);
; void LCDline1Message(char *theMessage);
; void LCDline2Message(char *theMessage);
; int sprintf(char *out, const char *format, ...) ;
; // initialisation for Can controller 0
; void Init_CanBus_Controller0(void);
; // initialisation for Can controller 1
; void Init_CanBus_Controller1(void);
; // Transmit for sending a message via Can controller 0
; void CanBus0_Transmit(int id, char data);
; // Transmit for sending a message via Can controller 1
; void CanBus1_Transmit(int id, char data);
; // Receive for reading a received message via Can controller 0
; void CanBus0_Receive(void);
; // Receive for reading a received message via Can controller 1
; void CanBus1_Receive(void);
; void CanBusTest(void);
; // I2C prototypes
; void I2C_Init(void);
; void WriteI2CInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB, unsigned char data, int flag);
; void PageWriteI2CInteraction(unsigned int AddressFrom, unsigned int AddressTo, unsigned char data);
; void ReadI2CByteInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB);
; void ReadI2CSequential(int block, int AddressTo, int AddressFrom,  unsigned int ChipAddress);
; void DACWrite(void);
; char ADCRead(int);
; void WriteI2C(void);
; void ReadI2C(void);
; void PageWriteI2C(void);
; void SeqReadI2C(void);
; // converts hex char to 4 bit binary equiv in range 0000-1111 (0-F)
; // char assumed to be a valid hex char 0-9, a-f, A-F
; void FlushKeyboard(void)
; {
       section   code
       xdef      _FlushKeyboard
_FlushKeyboard:
       link      A6,#-4
; char c ;
; while(1)    {
FlushKeyboard_1:
; if(((char)(RS232_Status) & (char)(0x01)) == (char)(0x01))    // if Rx bit in status register is '1'
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       bne.s     FlushKeyboard_4
; c = ((char)(RS232_RxData) & (char)(0x7f)) ;
       move.b    4194370,D0
       and.b     #127,D0
       move.b    D0,-1(A6)
       bra.s     FlushKeyboard_5
FlushKeyboard_4:
; else
; return ;
       bra.s     FlushKeyboard_6
FlushKeyboard_5:
       bra       FlushKeyboard_1
FlushKeyboard_6:
       unlk      A6
       rts
; }
; }
; char xtod(int c)
; {
       xdef      _xtod
_xtod:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; if ((char)(c) <= (char)('9'))
       cmp.b     #57,D2
       bgt.s     xtod_1
; return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
       move.b    D2,D0
       sub.b     #48,D0
       bra.s     xtod_3
xtod_1:
; else if((char)(c) > (char)('F'))    // assume lower case
       cmp.b     #70,D2
       ble.s     xtod_4
; return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
       move.b    D2,D0
       sub.b     #87,D0
       bra.s     xtod_3
xtod_4:
; else
; return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
       move.b    D2,D0
       sub.b     #55,D0
xtod_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get2HexDigits(char *CheckSumPtr)
; {
       xdef      _Get2HexDigits
_Get2HexDigits:
       link      A6,#0
       move.l    D2,-(A7)
; register int i = (xtod(_getch()) << 4) | (xtod(_getch()));
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       and.l     #255,D0
       asl.l     #4,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       __getch
       move.l    (A7)+,D1
       move.l    D0,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D2
; if(CheckSumPtr)
       tst.l     8(A6)
       beq.s     Get2HexDigits_1
; *CheckSumPtr += i ;
       move.l    8(A6),A0
       add.b     D2,(A0)
Get2HexDigits_1:
; return i ;
       move.l    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get4HexDigits(char *CheckSumPtr)
; {
       xdef      _Get4HexDigits
_Get4HexDigits:
       link      A6,#0
; return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get6HexDigits(char *CheckSumPtr)
; {
       xdef      _Get6HexDigits
_Get6HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get8HexDigits(char *CheckSumPtr)
; {
       xdef      _Get8HexDigits
_Get8HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; /*****************************************************************************************
; **	Interrupt service routine for Timers
; **
; **  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
; **  out which timer is producing the interrupt
; **
; *****************************************************************************************/
; void Timer_ISR()
; {
       xdef      _Timer_ISR
_Timer_ISR:
       movem.l   A2/A3,-(A7)
       lea       _CanBus0_Transmit.L,A2
       lea       _ADCRead.L,A3
; if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne       Timer_ISR_1
; CanBus0_Transmit(0, PortA); // every 100ms
       move.b    4194304,D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       jsr       (A2)
       addq.w    #8,A7
; if (Timer1Count % 2 == 0) {
       move.b    _Timer1Count.L,D0
       and.l     #65535,D0
       divu.w    #2,D0
       swap      D0
       tst.b     D0
       bne.s     Timer_ISR_3
; CanBus0_Transmit(1, ADCRead(1)); // read the value of the ADC potentiometer(from Lab 5) every 200ms
       move.l    D0,-(A7)
       pea       1
       jsr       (A3)
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       1
       jsr       (A2)
       addq.w    #8,A7
Timer_ISR_3:
; }
; if (Timer1Count % 5 == 0) {
       move.b    _Timer1Count.L,D0
       and.l     #65535,D0
       divu.w    #5,D0
       swap      D0
       tst.b     D0
       bne.s     Timer_ISR_5
; CanBus0_Transmit(2, ADCRead(2));
       move.l    D0,-(A7)
       pea       2
       jsr       (A3)
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       2
       jsr       (A2)
       addq.w    #8,A7
Timer_ISR_5:
; }
; if (Timer1Count % 20 == 0) {
       move.b    _Timer1Count.L,D0
       and.l     #65535,D0
       divu.w    #20,D0
       swap      D0
       tst.b     D0
       bne.s     Timer_ISR_7
; CanBus0_Transmit(3, ADCRead(0));
       move.l    D0,-(A7)
       clr.l     -(A7)
       jsr       (A3)
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       3
       jsr       (A2)
       addq.w    #8,A7
; Timer1Count = 0;
       clr.b     _Timer1Count.L
Timer_ISR_7:
; }
; Timer1Count++ ;     
       addq.b    #1,_Timer1Count.L
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
Timer_ISR_1:
; }
; if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_9
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
; PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
       move.b    _Timer2Count.L,D0
       addq.b    #1,_Timer2Count.L
       move.b    D0,4194308
Timer_ISR_9:
; }
; if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_11
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
; HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
       move.b    _Timer3Count.L,D0
       addq.b    #1,_Timer3Count.L
       move.b    D0,4194320
Timer_ISR_11:
; }
; if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_13
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
; HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
       move.b    _Timer4Count.L,D0
       addq.b    #1,_Timer4Count.L
       move.b    D0,4194322
Timer_ISR_13:
       movem.l   (A7)+,A2/A3
       rts
; }
; }
; /*****************************************************************************************
; **	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void ACIA_ISR()
; {}
       xdef      _ACIA_ISR
_ACIA_ISR:
       rts
; /***************************************************************************************
; **	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void PIA_ISR()
; {}
       xdef      _PIA_ISR
_PIA_ISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 2 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key2PressISR()
; {}
       xdef      _Key2PressISR
_Key2PressISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 1 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key1PressISR()
; {}
       xdef      _Key1PressISR
_Key1PressISR:
       rts
; /************************************************************************************
; **   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
; ************************************************************************************/
; void Wait1ms(void)
; {
       xdef      _Wait1ms
_Wait1ms:
       move.l    D2,-(A7)
; int  i ;
; for(i = 0; i < 1000; i ++)
       clr.l     D2
Wait1ms_1:
       cmp.l     #1000,D2
       bge.s     Wait1ms_3
       addq.l    #1,D2
       bra       Wait1ms_1
Wait1ms_3:
       move.l    (A7)+,D2
       rts
; ;
; }
; /************************************************************************************
; **  Subroutine to give the 68000 something useless to do to waste 3 mSec
; **************************************************************************************/
; void Wait3ms(void)
; {
       xdef      _Wait3ms
_Wait3ms:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 3; i++)
       clr.l     D2
Wait3ms_1:
       cmp.l     #3,D2
       bge.s     Wait3ms_3
; Wait1ms() ;
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       Wait3ms_1
Wait3ms_3:
       move.l    (A7)+,D2
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
; **  Sets it for parallel port and 2 line display mode (if I recall correctly)
; *********************************************************************************************/
; void Init_LCD(void)
; {
       xdef      _Init_LCD
_Init_LCD:
; LCDcommand = 0x0c ;
       move.b    #12,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDcommand = 0x38 ;
       move.b    #56,4194336
; Wait3ms() ;
       jsr       _Wait3ms
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
; *********************************************************************************************/
; void Init_RS232(void)
; {
       xdef      _Init_RS232
_Init_RS232:
; RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
       move.b    #1,4194372
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level output function to 6850 ACIA
; **  This routine provides the basic functionality to output a single character to the serial Port
; **  to allow the board to communicate with HyperTerminal Program
; **
; **  NOTE you do not call this function directly, instead you call the normal putchar() function
; **  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
; **  call _putch() also
; *********************************************************************************************************/
; int _putch( int c)
; {
       xdef      __putch
__putch:
       link      A6,#0
; while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
_putch_1:
       move.b    4194368,D0
       and.b     #2,D0
       cmp.b     #2,D0
       beq.s     _putch_3
       bra       _putch_1
_putch_3:
; ;
; RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
       move.l    8(A6),D0
       and.l     #127,D0
       move.b    D0,4194370
; return c ;                                              // putchar() expects the character to be returned
       move.l    8(A6),D0
       unlk      A6
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level input function to 6850 ACIA
; **  This routine provides the basic functionality to input a single character from the serial Port
; **  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
; **
; **  NOTE you do not call this function directly, instead you call the normal getchar() function
; **  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
; **  call _getch() also
; *********************************************************************************************************/
; int _getch( void )
; {
       xdef      __getch
__getch:
       link      A6,#-4
; char c ;
; while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
_getch_1:
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     _getch_3
       bra       _getch_1
_getch_3:
; ;
; return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
       move.b    4194370,D0
       and.l     #255,D0
       and.l     #127,D0
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to output a single character to the 2 row LCD display
; **  It is assumed the character is an ASCII code and it will be displayed at the
; **  current cursor position
; *******************************************************************************/
; void LCDOutchar(int c)
; {
       xdef      _LCDOutchar
_LCDOutchar:
       link      A6,#0
; LCDdata = (char)(c);
       move.l    8(A6),D0
       move.b    D0,4194338
; Wait1ms() ;
       jsr       _Wait1ms
       unlk      A6
       rts
; }
; /**********************************************************************************
; *subroutine to output a message at the current cursor position of the LCD display
; ************************************************************************************/
; void LCDOutMessage(char *theMessage)
; {
       xdef      _LCDOutMessage
_LCDOutMessage:
       link      A6,#-4
; char c ;
; while((c = *theMessage++) != 0)     // output characters from the string until NULL
LCDOutMessage_1:
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-1(A6)
       move.b    (A0),D0
       beq.s     LCDOutMessage_3
; LCDOutchar(c) ;
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _LCDOutchar
       addq.w    #4,A7
       bra       LCDOutMessage_1
LCDOutMessage_3:
       unlk      A6
       rts
; }
; /******************************************************************************
; *subroutine to clear the line by issuing 24 space characters
; *******************************************************************************/
; void LCDClearln(void)
; {
       xdef      _LCDClearln
_LCDClearln:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 24; i ++)
       clr.l     D2
LCDClearln_1:
       cmp.l     #24,D2
       bge.s     LCDClearln_3
; LCDOutchar(' ') ;       // write a space char to the LCD display
       pea       32
       jsr       _LCDOutchar
       addq.w    #4,A7
       addq.l    #1,D2
       bra       LCDClearln_1
LCDClearln_3:
       move.l    (A7)+,D2
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 1 and clear that line
; *******************************************************************************/
; void LCDLine1Message(char *theMessage)
; {
       xdef      _LCDLine1Message
_LCDLine1Message:
       link      A6,#0
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 2 and clear that line
; *******************************************************************************/
; void LCDLine2Message(char *theMessage)
; {
       xdef      _LCDLine2Message
_LCDLine2Message:
       link      A6,#0
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /*********************************************************************************************************************************
; **  IMPORTANT FUNCTION
; **  This function install an exception handler so you can capture and deal with any 68000 exception in your program
; **  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
; **  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
; **  Calling this function allows you to deal with Interrupts for example
; ***********************************************************************************************************************************/
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #184549376,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; void Enable_SCL(void){
       xdef      _Enable_SCL
_Enable_SCL:
; I2C_CLK_PRESCALE_LOW = 0x31;
       move.b    #49,4227072
; I2C_CLK_PRESCALE_HIGH = 0x00;
       clr.b     4227074
       rts
; }
; void WaitTIP(void){
       xdef      _WaitTIP
_WaitTIP:
       link      A6,#-4
; int TIP_bit;
; do{
WaitTIP_1:
; TIP_bit = (I2C_STAT >> 1) & 0x01; // this flag represents acknowledge from the addressed slave | ‘1’ = No acknowledge received | ‘0’ = Acknowledge received
       move.b    4227080,D0
       and.l     #255,D0
       lsr.l     #1,D0
       and.l     #1,D0
       move.l    D0,-4(A6)
       move.l    -4(A6),D0
       bne       WaitTIP_1
       unlk      A6
       rts
; }while(TIP_bit != 0);
; }
; void WaitACK(void){
       xdef      _WaitACK
_WaitACK:
       link      A6,#-4
; int ACK;
; do{
WaitACK_1:
; ACK = (I2C_STAT >> 7) & 0x01;
       move.b    4227080,D0
       and.l     #255,D0
       lsr.l     #7,D0
       and.l     #1,D0
       move.l    D0,-4(A6)
       move.l    -4(A6),D0
       bne       WaitACK_1
       unlk      A6
       rts
; }while(ACK != 0);
; }
; ///////////////////////////////////
; // I2C controller initialization //
; ///////////////////////////////////
; void I2C_Init(void){
       xdef      _I2C_Init
_I2C_Init:
; Enable_SCL();
       jsr       _Enable_SCL
; Enable_I2C_Controller();
       move.b    #128,4227076
       rts
; }
; ///////////////////////////////////////////////
; // write a single byte to the EEPROM via I2C //
; ///////////////////////////////////////////////
; void WriteI2CInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB, unsigned char data, int flag){
       xdef      _WriteI2CInteraction
_WriteI2CInteraction:
       link      A6,#0
       movem.l   D2/A2/A3,-(A7)
       lea       _WaitTIP.L,A2
       lea       _WaitACK.L,A3
; unsigned char controlByte;
; // determine the block of interest 
; if (block == 1) {
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     WriteI2CInteraction_1
; controlByte = EEPROM_Write_Block_1;
       move.b    #162,D2
       bra.s     WriteI2CInteraction_2
WriteI2CInteraction_1:
; } 
; else {
; controlByte = EEPROM_Write_Block_0;
       move.b    #160,D2
WriteI2CInteraction_2:
; }
; // wait for TIP
; WaitTIP();
       jsr       (A2)
; // store the data to TX register
; I2C_TX = controlByte;
       move.b    D2,4227078
; // command to generate start condition, write, and clear pending interrupt 
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; //Wait for TIP bit in Status Register
; WaitTIP();
       jsr       (A2)
; //Wait RxACK bit in Status Register
; WaitACK();
       jsr       (A3)
; // send the most significant byte of the address
; I2C_TX = AddressMSB;
       move.b    19(A6),4227078
; // command to write and clear pending interrupt 
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; // send the least significant byte of the address
; I2C_TX = AddressLSB;
       move.b    23(A6),4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; // send data
; I2C_TX = data;
       move.b    27(A6),4227078
; I2C_CMD = I2C_CMD_Slave_Write_Stop;
       move.b    #81,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; if(flag == 0){
       move.l    28(A6),D0
       bne.s     WriteI2CInteraction_3
; printf("\r\nWrote [%x] to Address[%x]", data, Address);
       move.l    12(A6),-(A7)
       move.b    27(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_1.L
       jsr       _printf
       add.w     #12,A7
WriteI2CInteraction_3:
       movem.l   (A7)+,D2/A2/A3
       unlk      A6
       rts
; }
; }
; //////////////////////////////////////////////////
; // write up to 128k bytes to the EEPROM via I2C //
; //////////////////////////////////////////////////
; void PageWriteI2CInteraction(unsigned int AddressFrom, unsigned int AddressTo, unsigned char data){
       xdef      _PageWriteI2CInteraction
_PageWriteI2CInteraction:
       link      A6,#-12
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       move.l    8(A6),D2
       lea       _WaitTIP.L,A2
       lea       _WaitACK.L,A3
       move.b    19(A6),D7
       and.l     #255,D7
       move.l    12(A6),A4
; int flag = 0;
       move.w    #0,A5
; int flag_special = 0;
       clr.l     -10(A6)
; int i = 0;
       clr.l     D3
; unsigned char controlByte;
; unsigned char AddressFromMSB;
; unsigned char AddressFromLSB;
; unsigned char AddressRange;
; unsigned int AddressFrom_Initial;
; AddressFrom_Initial = AddressFrom;
       move.l    D2,-4(A6)
; while(AddressFrom < AddressTo){
PageWriteI2CInteraction_1:
       cmp.l     A4,D2
       bhs       PageWriteI2CInteraction_3
; if (AddressFrom + 128 > AddressTo) {
       move.l    D2,D0
       add.l     #128,D0
       cmp.l     A4,D0
       bls.s     PageWriteI2CInteraction_4
; flag = 1;
       move.w    #1,A5
PageWriteI2CInteraction_4:
; }
; if (AddressFrom > 0xFFFF) {
       cmp.l     #65535,D2
       bls.s     PageWriteI2CInteraction_6
; controlByte = EEPROM_Write_Block_1;
       move.b    #162,D6
; AddressFromMSB = ((AddressFrom - 0x10000) >> 8) & 0xFF;
       move.l    D2,D0
       sub.l     #65536,D0
       lsr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D5
; AddressFromLSB = (AddressFrom - 0x10000) & 0xFF;
       move.l    D2,D0
       sub.l     #65536,D0
       and.l     #255,D0
       move.b    D0,D4
       bra.s     PageWriteI2CInteraction_7
PageWriteI2CInteraction_6:
; }
; else {
; controlByte = EEPROM_Write_Block_0;
       move.b    #160,D6
; AddressFromMSB = (AddressFrom >> 8) & 0xFF;
       move.l    D2,D0
       lsr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D5
; AddressFromLSB = AddressFrom & 0xFF;
       move.l    D2,D0
       and.l     #255,D0
       move.b    D0,D4
PageWriteI2CInteraction_7:
; }
; WaitTIP();
       jsr       (A2)
; I2C_TX = controlByte;
       move.b    D6,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressFromMSB;
       move.b    D5,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressFromLSB;
       move.b    D4,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; if(flag == 0){
       move.l    A5,D0
       bne       PageWriteI2CInteraction_8
; for (i = 0; i < 128; i++){  // limit write to 128 bytes
       clr.l     D3
PageWriteI2CInteraction_10:
       cmp.l     #128,D3
       bge       PageWriteI2CInteraction_12
; I2C_TX = data;
       move.b    D7,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; if((AddressFrom + i) % 128 == 0){
       move.l    D2,D0
       add.l     D3,D0
       move.l    D0,-(A7)
       pea       128
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     PageWriteI2CInteraction_13
; break;
       bra.s     PageWriteI2CInteraction_12
PageWriteI2CInteraction_13:
; }
; // check if need to switch blocks
; if(AddressFrom + i == 0xFFFF){
       move.l    D2,D0
       add.l     D3,D0
       cmp.l     #65535,D0
       bne.s     PageWriteI2CInteraction_15
; break;
       bra.s     PageWriteI2CInteraction_12
PageWriteI2CInteraction_15:
       addq.l    #1,D3
       bra       PageWriteI2CInteraction_10
PageWriteI2CInteraction_12:
       bra       PageWriteI2CInteraction_19
PageWriteI2CInteraction_8:
; }
; }
; }
; else {
; AddressRange = AddressTo - AddressFrom;
       move.l    A4,D0
       sub.l     D2,D0
       move.b    D0,-5(A6)
; for(i = 0; i < AddressRange; i++){                
       clr.l     D3
PageWriteI2CInteraction_17:
       move.b    -5(A6),D0
       and.l     #255,D0
       cmp.l     D0,D3
       bhs       PageWriteI2CInteraction_19
; I2C_TX = data;
       move.b    D7,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; if((AddressFrom + i) % 128 == 0){
       move.l    D2,D0
       add.l     D3,D0
       move.l    D0,-(A7)
       pea       128
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     PageWriteI2CInteraction_20
; break;
       bra.s     PageWriteI2CInteraction_19
PageWriteI2CInteraction_20:
; }
; // check if need to switch blocks
; if(AddressFrom + i == 0xFFFF){
       move.l    D2,D0
       add.l     D3,D0
       cmp.l     #65535,D0
       bne.s     PageWriteI2CInteraction_22
; break;
       bra.s     PageWriteI2CInteraction_19
PageWriteI2CInteraction_22:
       addq.l    #1,D3
       bra       PageWriteI2CInteraction_17
PageWriteI2CInteraction_19:
; }
; }
; }
; I2C_CMD = I2C_CMD_Slave_Write_Stop;
       move.b    #81,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; do {
PageWriteI2CInteraction_24:
; I2C_TX = controlByte;
       move.b    D6,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
       move.b    4227080,D0
       lsr.b     #7,D0
       and.b     #1,D0
       bne       PageWriteI2CInteraction_24
; } while (((I2C_STAT >> 7) & 0x01) != 0); // wait for acknowledgement from the slave
; AddressFrom += (i + 1);
       move.l    D3,D0
       addq.l    #1,D0
       add.l     D0,D2
       bra       PageWriteI2CInteraction_1
PageWriteI2CInteraction_3:
; }
; // special case for end address being the first byte of the next/last page
; if (((AddressFrom + i) % 128 == 0) && (flag == 1)) {
       move.l    D2,D0
       add.l     D3,D0
       move.l    D0,-(A7)
       pea       128
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       PageWriteI2CInteraction_29
       move.l    A5,D0
       cmp.l     #1,D0
       bne       PageWriteI2CInteraction_29
; if((AddressFrom + i) > 0xFFFF){
       move.l    D2,D0
       add.l     D3,D0
       cmp.l     #65535,D0
       bls       PageWriteI2CInteraction_28
; controlByte = EEPROM_Write_Block_1;
       move.b    #162,D6
; AddressFromMSB = (((AddressFrom + i) - 0x10000) >> 8) & 0xFF;
       move.l    D2,D0
       add.l     D3,D0
       sub.l     #65536,D0
       lsr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D5
; AddressFromLSB = ((AddressFrom + i) - 0x10000) & 0xFF;
       move.l    D2,D0
       add.l     D3,D0
       sub.l     #65536,D0
       and.l     #255,D0
       move.b    D0,D4
; WriteI2CInteraction(1, (AddressFrom + i), AddressFromMSB, AddressFromLSB, data, 1);
       pea       1
       and.l     #255,D7
       move.l    D7,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       move.l    D2,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       pea       1
       jsr       _WriteI2CInteraction
       add.w     #24,A7
       bra       PageWriteI2CInteraction_29
PageWriteI2CInteraction_28:
; }
; else {
; controlByte = EEPROM_Write_Block_0;
       move.b    #160,D6
; AddressFromMSB = ((AddressFrom + i) >> 8) & 0xFF;
       move.l    D2,D0
       add.l     D3,D0
       lsr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D5
; AddressFromLSB = (AddressFrom + i) & 0xFF;
       move.l    D2,D0
       add.l     D3,D0
       and.l     #255,D0
       move.b    D0,D4
; WriteI2CInteraction(0, (AddressFrom + i), AddressFromMSB, AddressFromLSB, data, 1);
       pea       1
       and.l     #255,D7
       move.l    D7,-(A7)
       and.l     #255,D4
       move.l    D4,-(A7)
       and.l     #255,D5
       move.l    D5,-(A7)
       move.l    D2,D1
       add.l     D3,D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       jsr       _WriteI2CInteraction
       add.w     #24,A7
PageWriteI2CInteraction_29:
; }
; }
; printf("\r\nWrote [%x] from Address[%x] to Address[%x]", data, AddressFrom_Initial, AddressTo);
       move.l    A4,-(A7)
       move.l    -4(A6),-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @mupde1_2.L
       jsr       _printf
       add.w     #16,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; ///////////////////////////////////////////////
; // read a single byte to the EEPROM via I2C //
; ///////////////////////////////////////////////
; void ReadI2CByteInteraction(int block, unsigned int Address, unsigned char AddressMSB, unsigned char AddressLSB){
       xdef      _ReadI2CByteInteraction
_ReadI2CByteInteraction:
       link      A6,#-4
       movem.l   D2/D3/A2/A3,-(A7)
       lea       _WaitTIP.L,A2
       lea       _WaitACK.L,A3
; unsigned char controleByte_ForWrite;
; unsigned char controlByte_ForRead;
; unsigned char readData;
; if(block == 1){
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     ReadI2CByteInteraction_1
; controleByte_ForWrite= 162;
       move.b    #162,D3
; controlByte_ForRead = 163;
       move.b    #163,D2
       bra.s     ReadI2CByteInteraction_2
ReadI2CByteInteraction_1:
; }else{
; controleByte_ForWrite = 160;
       move.b    #160,D3
; controlByte_ForRead = 161;
       move.b    #161,D2
ReadI2CByteInteraction_2:
; }
; WaitTIP();
       jsr       (A2)
; I2C_TX = controleByte_ForWrite;
       move.b    D3,4227078
; I2C_CMD = 145;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressMSB;
       move.b    19(A6),4227078
; I2C_CMD = 17;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressLSB;
       move.b    23(A6),4227078
; I2C_CMD = 17;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = controlByte_ForRead;
       move.b    D2,4227078
; I2C_CMD = 145;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_CMD = 105;
       move.b    #105,4227080
; WaitTIP();
       jsr       (A2)
; while((I2C_STAT & 0x01) != 0x01) {
ReadI2CByteInteraction_3:
       move.b    4227080,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     ReadI2CByteInteraction_5
; }
       bra       ReadI2CByteInteraction_3
ReadI2CByteInteraction_5:
; I2C_STAT = 0;
       clr.b     4227080
; readData = I2C_RX;
       move.b    4227078,-1(A6)
; printf("\r\nRead [%x] from Address[%x]", readData, Address);
       move.l    12(A6),-(A7)
       move.b    -1(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_3.L
       jsr       _printf
       add.w     #12,A7
; return;
       movem.l   (A7)+,D2/D3/A2/A3
       unlk      A6
       rts
; }
; //////////////////////////////////////////////////
; // read up to 128k bytes to the EEPROM via I2C //
; //////////////////////////////////////////////////
; void ReadI2CSequential(int block, int AddressTo, int AddressFrom,  unsigned int ChipAddress){
       xdef      _ReadI2CSequential
_ReadI2CSequential:
       link      A6,#-8
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _WaitTIP.L,A2
       lea       _WaitACK.L,A3
       move.l    20(A6),D2
; unsigned char controleWriteByte;
; unsigned char controlReadByte;
; unsigned char readData;
; unsigned char AddressLSB;
; unsigned char AddressMSB;
; int i;
; int size;
; int block_change_flag = 0;
       move.w    #0,A4
; int block_address;
; size = AddressTo - AddressFrom;
       move.l    12(A6),D0
       sub.l     16(A6),D0
       move.l    D0,-4(A6)
; AddressMSB = (ChipAddress >> 8) & 0xFF;
       move.l    D2,D0
       lsr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D6
; AddressLSB = ChipAddress & 0xFF;
       move.l    D2,D0
       and.l     #255,D0
       move.b    D0,D5
; if(block == 1){
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     ReadI2CSequential_1
; controleWriteByte = EEPROM_Write_Block_1;
       move.b    #162,D4
; controlReadByte = EEPROM_Read_Block_1;
       move.b    #163,D3
; AddressMSB = ((ChipAddress-0x10000) >> 8) & 0xFF;
       move.l    D2,D0
       sub.l     #65536,D0
       lsr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D6
; AddressLSB = (ChipAddress-0x10000) & 0xFF;
       move.l    D2,D0
       sub.l     #65536,D0
       and.l     #255,D0
       move.b    D0,D5
       bra.s     ReadI2CSequential_2
ReadI2CSequential_1:
; }else{
; controleWriteByte = EEPROM_Write_Block_0;
       move.b    #160,D4
; controlReadByte = EEPROM_Read_Block_0;
       move.b    #161,D3
ReadI2CSequential_2:
; }
; WaitTIP();
       jsr       (A2)
; I2C_TX = controleWriteByte;
       move.b    D4,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressMSB;
       move.b    D6,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressLSB;
       move.b    D5,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = controlReadByte;
       move.b    D3,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; block_address = ChipAddress;
       move.l    D2,D7
; for (i = 0; i < size; i++){
       move.w    #0,A5
ReadI2CSequential_3:
       move.l    A5,D0
       cmp.l     -4(A6),D0
       bge       ReadI2CSequential_5
; if(block_address == 0x10000){ // if need to switch blocks 
       cmp.l     #65536,D7
       bne.s     ReadI2CSequential_6
; I2C_CMD = I2C_CMD_Slave_Read_Ack;
       move.b    #41,4227080
; WaitTIP();
       jsr       (A2)
; while(I2C_STAT & 0x01 == 0x00);
; readData = I2C_RX;
       move.b    4227078,-5(A6)
; I2C_CMD = I2C_CMD_Slave_Read_Stop; // instead of sending a stop command
       move.b    #73,4227080
; // printf("\r\nADDR: %x, DATA: %x\r\n",ChipAddress,readData);
; WaitTIP();
       jsr       (A2)
; block_change_flag = 1;
       move.w    #1,A4
       bra       ReadI2CSequential_7
ReadI2CSequential_6:
; } else {
; I2C_CMD = I2C_CMD_Slave_Read;
       move.b    #33,4227080
; WaitTIP();
       jsr       (A2)
; while((I2C_STAT & 0x01) != 0x01) {
ReadI2CSequential_11:
       move.b    4227080,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     ReadI2CSequential_13
; }
       bra       ReadI2CSequential_11
ReadI2CSequential_13:
; I2C_STAT = 0;
       clr.b     4227080
; readData = I2C_RX;
       move.b    4227078,-5(A6)
; printf("\r\nRead [%x] from Address[%x]", readData, ChipAddress);
       move.l    D2,-(A7)
       move.b    -5(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_3.L
       jsr       _printf
       add.w     #12,A7
; ChipAddress++;
       addq.l    #1,D2
; block_address++;
       addq.l    #1,D7
ReadI2CSequential_7:
; }
; if (block_change_flag) {
       move.l    A4,D0
       beq       ReadI2CSequential_14
; controleWriteByte = EEPROM_Write_Block_1;
       move.b    #162,D4
; controlReadByte = EEPROM_Read_Block_1;
       move.b    #163,D3
; AddressMSB = 0;
       clr.b     D6
; AddressLSB = 0;
       clr.b     D5
; WaitTIP();
       jsr       (A2)
; I2C_TX = controleWriteByte;
       move.b    D4,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressMSB;
       move.b    D6,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = AddressLSB;
       move.b    D5,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = controlReadByte;
       move.b    D3,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; block_change_flag = 0;
       move.w    #0,A4
; block_address = 0;
       moveq     #0,D7
ReadI2CSequential_14:
       addq.w    #1,A5
       bra       ReadI2CSequential_3
ReadI2CSequential_5:
; }
; }
; I2C_CMD = I2C_CMD_Slave_Read_Ack;
       move.b    #41,4227080
; WaitTIP();
       jsr       (A2)
; while(I2C_STAT & 0x01 == 0x00);
; I2C_CMD = I2C_CMD_Slave_Read_Stop;
       move.b    #73,4227080
; printf("\r\nBlock Read operation complete\r\n");
       pea       @mupde1_4.L
       jsr       _printf
       addq.w    #4,A7
; return;
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; ///////////////////////////////////////////////
; // generate a waveform (square wave) via DAC //
; ///////////////////////////////////////////////
; void DACWrite(void) {
       xdef      _DACWrite
_DACWrite:
       movem.l   D2/D3/D4/A2/A3,-(A7)
       lea       _WaitTIP.L,A2
       lea       _WaitACK.L,A3
; int i;
; unsigned int delay = 0xFFFFF;
       move.l    #1048575,D4
; printf("\nI2C DAC Write: Please check LED\n");
       pea       @mupde1_5.L
       jsr       _printf
       addq.w    #4,A7
; WaitTIP();
       jsr       (A2)
; I2C_TX = ADC_DAC_Write_Address;
       move.b    #144,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = DAC_CMD_Enable;
       move.b    #64,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = 0xFF; 
       move.b    #255,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; while(1) { // keep blinking the LED
DACWrite_1:
; unsigned int val = 0xFF; // digital high
       move.l    #255,D3
; I2C_TX = val; 
       move.b    D3,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; for(i = 0; i < delay; i++);
       clr.l     D2
DACWrite_4:
       cmp.l     D4,D2
       bhs.s     DACWrite_6
       addq.l    #1,D2
       bra       DACWrite_4
DACWrite_6:
; val = 0x00; // digital low
       clr.l     D3
; I2C_TX = val;
       move.b    D3,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; for(i = 0; i < delay; i++);
       clr.l     D2
DACWrite_7:
       cmp.l     D4,D2
       bhs.s     DACWrite_9
       addq.l    #1,D2
       bra       DACWrite_7
DACWrite_9:
       bra       DACWrite_1
; }
; }
; ///////////////////////////////////////////////
; // generate a waveform (square wave) via DAC //
; ///////////////////////////////////////////////
; char ADCRead(int arg){
       xdef      _ADCRead
_ADCRead:
       link      A6,#-8
       movem.l   D2/D3/A2/A3,-(A7)
       lea       _WaitTIP.L,A2
       move.l    8(A6),D3
       lea       _WaitACK.L,A3
; unsigned char thermistor_value;
; unsigned char potentiometer_value;
; unsigned char photo_resistor_value;
; unsigned int delay = 0xFFFFF;
       move.l    #1048575,-4(A6)
; unsigned char result;
; WaitTIP();
       jsr       (A2)
; I2C_TX = ADC_DAC_Write_Address;
       move.b    #144,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = ADC_CMD_Enable;
       move.b    #68,4227078
; I2C_CMD = I2C_CMD_Slave_Write;
       move.b    #17,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_TX = ADC_Read_Address;
       move.b    #145,4227078
; I2C_CMD = I2C_CMD_Slave_Write_With_Start;
       move.b    #145,4227080
; WaitTIP();
       jsr       (A2)
; WaitACK();
       jsr       (A3)
; I2C_CMD = I2C_CMD_Slave_Read;
       move.b    #33,4227080
; WaitTIP();
       jsr       (A2)
; // measure thermistor 
; I2C_CMD = I2C_CMD_Slave_Read;
       move.b    #33,4227080
; WaitTIP();
       jsr       (A2)
; thermistor_value = I2C_RX;
       move.b    4227078,-7(A6)
; // measure potentiometer 
; I2C_CMD = I2C_CMD_Slave_Read;
       move.b    #33,4227080
; WaitTIP();
       jsr       (A2)
; potentiometer_value = I2C_RX;
       move.b    4227078,-6(A6)
; // measure photo resistor 
; I2C_CMD = I2C_CMD_Slave_Read;
       move.b    #33,4227080
; WaitTIP();
       jsr       (A2)
; photo_resistor_value = I2C_RX;
       move.b    4227078,-5(A6)
; result = 0;
       clr.b     D2
; if (arg == 0) {
       tst.l     D3
       bne.s     ADCRead_1
; // printf("Value of Thermistor: %d\n", thermistor_value);
; result = thermistor_value;
       move.b    -7(A6),D2
       bra.s     ADCRead_7
ADCRead_1:
; } else if (arg == 1) {
       cmp.l     #1,D3
       bne.s     ADCRead_3
; // printf("Value of Potentiometer: %d\n", potentiometer_value);
; result = potentiometer_value;
       move.b    -6(A6),D2
       bra.s     ADCRead_7
ADCRead_3:
; } else if (arg == 2) {
       cmp.l     #2,D3
       bne.s     ADCRead_5
; // printf("Value of Photo-resister: %d\n", photo_resistor_value);
; result = photo_resistor_value;
       move.b    -5(A6),D2
       bra.s     ADCRead_7
ADCRead_5:
; } else if (arg == 3) {
       cmp.l     #3,D3
       bne.s     ADCRead_7
; // printf("Value of Thermistor: %d Potentiometer: %d Photo-resister: %d\n", thermistor_value, potentiometer_value, photo_resistor_value);
; result = 0xff;
       move.b    #255,D2
ADCRead_7:
; } 
; return result;
       move.b    D2,D0
       movem.l   (A7)+,D2/D3/A2/A3
       unlk      A6
       rts
; }
; // initialisation for Can controller 0
; void Init_CanBus_Controller0(void)
; {
       xdef      _Init_CanBus_Controller0
_Init_CanBus_Controller0:
; // TODO - put your Canbus initialisation code for CanController 0 here
; // See section 4.2.1 in the application note for details (PELICAN MODE)
; /* define interrupt priority & control (level-activated, see chapter 4.2.5) */
; // PX0 = PRIORITY_HIGH; /* CAN HAS A HIGH PRIORITY INTERRUPT */
; // IT0 = INTLEVELACT; /* set interrupt0 to level activated */
; // /* enable the communication interface of the SJA1000 */
; // CS = ENABLE_N; /* Enable the SJA1000 interface */
; // /* disable interrupts, if used (not necessary after power-on) */
; // EA = DISABLE; /* disable all interrupts */
; // SJAIntEn = DISABLE; /* disable external interrupt from SJA1000 */
; // /* set reset mode/request (Note: after power-on SJA1000 is in BasicCAN mode)
; // leave loop after a time out and signal an error */
; while ((Can0_ModeControlReg & RM_RR_Bit) == ClrByte){
Init_CanBus_Controller0_1:
       move.b    5242880,D0
       and.b     #1,D0
       bne.s     Init_CanBus_Controller0_3
; /* other bits than the reset mode/request bit are unchanged */
; Can0_ModeControlReg = Can0_ModeControlReg | RM_RR_Bit;
       move.b    5242880,D0
       or.b      #1,D0
       move.b    D0,5242880
       bra       Init_CanBus_Controller0_1
Init_CanBus_Controller0_3:
; }
; // Set clock divide register to use pelican mode and bypass CAN input comparator (possible only in reset mode)
; Can0_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy2;
       move.b    #192,5242942
; /* disable CAN interrupts, if required (always necessary after power-on)
; (write to SJA1000 Interrupt Enable / Control Register) */
; Can0_InterruptEnReg = ClrIntEnSJA;
       clr.b     5242888
; /* define acceptance code and mask */
; Can0_AcceptCode0Reg = ClrByte;
       clr.b     5242912
; Can0_AcceptCode1Reg = ClrByte;
       clr.b     5242914
; Can0_AcceptCode2Reg = ClrByte;
       clr.b     5242916
; Can0_AcceptCode3Reg = ClrByte;
       clr.b     5242918
; Can0_AcceptMask0Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5242920
; Can0_AcceptMask1Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5242922
; Can0_AcceptMask2Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5242924
; Can0_AcceptMask3Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5242926
; /* configure bus timing */
; /* bit-rate = 100 kbit/s @ 25 MHz, the bus is sampled once */
; Can0_BusTiming0Reg = BTR0;
       move.b    #4,5242892
; Can0_BusTiming1Reg = BTR1;
       move.b    #127,5242894
; /* configure CAN outputs: float on TX1, Push/Pull on TX0, normal output mode */
; Can0_OutControlReg = Tx0Float | Tx0PshPull | NormalMode;
       move.b    #26,5242896
; // Set mode control to clr
; do {
Init_CanBus_Controller0_4:
; Can0_ModeControlReg = ClrByte;
       clr.b     5242880
       move.b    5242880,D0
       and.b     #1,D0
       bne       Init_CanBus_Controller0_4
       rts
; } while ((Can0_ModeControlReg & RM_RR_Bit) != ClrByte);
; }
; // initialisation for Can controller 1
; void Init_CanBus_Controller1(void)
; {
       xdef      _Init_CanBus_Controller1
_Init_CanBus_Controller1:
; // TODO - put your Canbus initialisation code for CanController 1 here
; // See section 4.2.1 in the application note for details (PELICAN MODE)
; while ((Can1_ModeControlReg & RM_RR_Bit) == ClrByte){
Init_CanBus_Controller1_1:
       move.b    5243392,D0
       and.b     #1,D0
       bne.s     Init_CanBus_Controller1_3
; /* other bits than the reset mode/request bit are unchanged */
; Can1_ModeControlReg = Can1_ModeControlReg | RM_RR_Bit;
       move.b    5243392,D0
       or.b      #1,D0
       move.b    D0,5243392
       bra       Init_CanBus_Controller1_1
Init_CanBus_Controller1_3:
; }
; // Set clock divide register to use pelican mode and bypass CAN input comparator (possible only in reset mode)
; Can1_ClockDivideReg = CANMode_Bit | CBP_Bit | DivBy2;
       move.b    #192,5243454
; /* disable CAN interrupts, if required (always necessary after power-on)
; (write to SJA1000 Interrupt Enable / Control Register) */
; Can1_InterruptEnReg = ClrIntEnSJA;
       clr.b     5243400
; /* define acceptance code and mask */
; Can1_AcceptCode0Reg = ClrByte;
       clr.b     5243424
; Can1_AcceptCode1Reg = ClrByte;
       clr.b     5243426
; Can1_AcceptCode2Reg = ClrByte;
       clr.b     5243428
; Can1_AcceptCode3Reg = ClrByte;
       clr.b     5243430
; Can1_AcceptMask0Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5243432
; Can1_AcceptMask1Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5243434
; Can1_AcceptMask2Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5243436
; Can1_AcceptMask3Reg = DontCare; /* every identifier is accepted */
       move.b    #255,5243438
; /* configure bus timing */
; /* bit-rate = 100 kbit/s @ 25 MHz, the bus is sampled once */
; Can1_BusTiming0Reg = BTR0;
       move.b    #4,5243404
; Can1_BusTiming1Reg = BTR1;
       move.b    #127,5243406
; /* configure CAN outputs: float on TX1, Push/Pull on TX0, normal output mode */
; Can1_OutControlReg = Tx0Float | Tx0PshPull | NormalMode;
       move.b    #26,5243408
; // Set mode control to clr
; do {
Init_CanBus_Controller1_4:
; Can1_ModeControlReg = ClrByte;
       clr.b     5243392
       move.b    5243392,D0
       and.b     #1,D0
       bne       Init_CanBus_Controller1_4
       rts
; } while ((Can1_ModeControlReg & RM_RR_Bit) != ClrByte);
; }
; // Transmit for sending a message via Can controller 0
; void CanBus0_Transmit(int id, char data)
; {
       xdef      _CanBus0_Transmit
_CanBus0_Transmit:
       link      A6,#0
; // TODO - put your Canbus transmit code for CanController 0 here
; // See section 4.2.2 in the application note for details (PELICAN MODE)
; /* wait until the Transmit Buffer is released */
; do
; {
CanBus0_Transmit_1:
; /* start a polling timer and run some tasks while waiting
; break the loop and signal an error if time too long */
; } while((Can0_StatusReg & TBS_Bit ) != TBS_Bit );
       move.b    5242884,D0
       and.b     #4,D0
       cmp.b     #4,D0
       bne       CanBus0_Transmit_1
; /* Transmit Buffer is released, a message may be written into the buffer */
; /* in this example a Standard Frame message shall be transmitted */
; Can0_TxFrameInfo = 0x08; /* SFF (data), DLC=8 */
       move.b    #8,5242912
; Can0_TxBuffer1 = 0xA5; /* ID1 = A5, (1010 0101) */
       move.b    #165,5242914
; Can0_TxBuffer2 = 0x20; /* ID2 = 20, (0010 0000) */
       move.b    #32,5242916
; Can0_TxBuffer3 = id; 
       move.l    8(A6),D0
       move.b    D0,5242918
; Can0_TxBuffer4 = data; 
       move.b    15(A6),5242920
; /* Start the transmission */
; Can0_CommandReg = TR_Bit ; /* Set Transmission Request bit */
       move.b    #1,5242882
       unlk      A6
       rts
; }
; // Transmit for sending a message via Can controller 1
; void CanBus1_Transmit(int id, char data)
; {
       xdef      _CanBus1_Transmit
_CanBus1_Transmit:
       link      A6,#0
; // TODO - put your Canbus transmit code for CanController 1 here
; // See section 4.2.2 in the application note for details (PELICAN MODE)
; /* wait until the Transmit Buffer is released */
; do
; {
CanBus1_Transmit_1:
; /* start a polling timer and run some tasks while waiting
; break the loop and signal an error if time too long */
; } while((Can1_StatusReg & TBS_Bit ) != TBS_Bit );
       move.b    5243396,D0
       and.b     #4,D0
       cmp.b     #4,D0
       bne       CanBus1_Transmit_1
; /* Transmit Buffer is released, a message may be written into the buffer */
; /* in this example a Standard Frame message shall be transmitted */
; Can1_TxFrameInfo = 0x08; /* SFF (data), DLC=8 */
       move.b    #8,5243424
; Can1_TxBuffer1 = 0xA5; /* ID1 = A5, (1010 0101) */
       move.b    #165,5243426
; Can1_TxBuffer2 = 0x20; /* ID2 = 20, (0010 0000) */
       move.b    #32,5243428
; Can1_TxBuffer3 = 0x32; /* data1 = 51 */
       move.b    #50,5243430
; Can1_TxBuffer4 = 0x42; /* data2 = 52*/
       move.b    #66,5243432
; Can1_TxBuffer10 = 0x12; /* data8 = 58 */
       move.b    #18,5243444
; /* Start the transmission */
; Can1_CommandReg = TR_Bit ; /* Set Transmission Request bit */
       move.b    #1,5243394
       unlk      A6
       rts
; }
; // Receive for reading a received message via Can controller 0
; void CanBus0_Receive(void)
; {
       xdef      _CanBus0_Receive
_CanBus0_Receive:
       link      A6,#-12
       move.l    A2,-(A7)
       lea       -10(A6),A2
; // TODO - put your Canbus receive code for CanController 0 here
; // See section 4.2.4 in the application note for details (PELICAN MODE)
; unsigned char numArray[2];
; unsigned char dataArray[10];
; do{ }while((Can0_StatusReg & RBS_Bit) != RBS_Bit);
CanBus0_Receive_1:
       move.b    5242884,D0
       and.b     #1,D0
       cmp.b     #1,D0
       bne       CanBus0_Receive_1
; numArray[0] = Can0_RxBuffer1 & 0xff;
       move.b    5242914,D0
       and.w     #255,D0
       and.w     #255,D0
       move.b    D0,-12+0(A6)
; numArray[1] = Can0_RxBuffer2 & 0xff;
       move.b    5242916,D0
       and.w     #255,D0
       and.w     #255,D0
       move.b    D0,-12+1(A6)
; //data bits
; dataArray[0] = Can0_RxBuffer3;
       move.b    5242918,(A2)
; dataArray[1] = Can0_RxBuffer4;
       move.b    5242920,1(A2)
; Can0_CommandReg = RRB_Bit;
       move.b    #4,5242882
; printf("Can0 recieve data at index 0: %d\n", dataArray[0]);
       move.b    (A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_6.L
       jsr       _printf
       addq.w    #8,A7
; printf("Can0 recieve data at index 1: %d\n", dataArray[1]);
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_7.L
       jsr       _printf
       addq.w    #8,A7
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; // Receive for reading a received message via Can controller 1
; void CanBus1_Receive(void)
; {
       xdef      _CanBus1_Receive
_CanBus1_Receive:
       link      A6,#-12
       move.l    A2,-(A7)
       lea       -10(A6),A2
; // TODO - put your Canbus receive code for CanController 0 here
; // See section 4.2.4 in the application note for details (PELICAN MODE)
; unsigned char numArray[2];
; unsigned char dataArray[10];
; do{ }while((Can1_StatusReg & RBS_Bit) != RBS_Bit);
CanBus1_Receive_1:
       move.b    5243396,D0
       and.b     #1,D0
       cmp.b     #1,D0
       bne       CanBus1_Receive_1
; numArray[0] = Can1_RxBuffer1 & 0xff;
       move.b    5243426,D0
       and.w     #255,D0
       and.w     #255,D0
       move.b    D0,-12+0(A6)
; numArray[1] = Can1_RxBuffer2 & 0xff;
       move.b    5243428,D0
       and.w     #255,D0
       and.w     #255,D0
       move.b    D0,-12+1(A6)
; //data bits
; dataArray[0] = Can1_RxBuffer3;
       move.b    5243430,(A2)
; dataArray[1] = Can1_RxBuffer4;
       move.b    5243432,1(A2)
; Can1_CommandReg = RRB_Bit;
       move.b    #4,5243394
; printf("Can1 recieve data at index 0: %d\n", dataArray[0]);
       move.b    (A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_8.L
       jsr       _printf
       addq.w    #8,A7
; printf("Can1 recieve data at index 1: %d\n", dataArray[1]);
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @mupde1_9.L
       jsr       _printf
       addq.w    #8,A7
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; void CanBusTest(void)
; {
       xdef      _CanBusTest
_CanBusTest:
       movem.l   D2/A2,-(A7)
       lea       _printf.L,A2
; int i;
; // initialise the two Can controllers
; Init_CanBus_Controller0();
       jsr       _Init_CanBus_Controller0
; Init_CanBus_Controller1();
       jsr       _Init_CanBus_Controller1
; printf("\r\n\r\n---- CANBUS Test ----\r\n") ;
       pea       @mupde1_10.L
       jsr       (A2)
       addq.w    #4,A7
; // simple application to alternately transmit and receive messages from each of two nodes
; while (1) {
CanBusTest_1:
; for (i = 0; i < 500; i++) {
       clr.l     D2
CanBusTest_4:
       cmp.l     #500,D2
       bge.s     CanBusTest_6
; Wait1ms();
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       CanBusTest_4
CanBusTest_6:
; }
; CanBus0_Transmit(1, 0x10) ;       // transmit a message via Controller 0
       pea       16
       pea       1
       jsr       _CanBus0_Transmit
       addq.w    #8,A7
; CanBus1_Receive() ;        // receive a message via Controller 1 (and display it)
       jsr       _CanBus1_Receive
; printf("\r\n") ;
       pea       @mupde1_11.L
       jsr       (A2)
       addq.w    #4,A7
; for (i = 0; i < 500; i++) {
       clr.l     D2
CanBusTest_7:
       cmp.l     #500,D2
       bge.s     CanBusTest_9
; Wait1ms();
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       CanBusTest_7
CanBusTest_9:
; }
; CanBus1_Transmit(1, 0x11) ;        // transmit a message via Controller 1
       pea       17
       pea       1
       jsr       _CanBus1_Transmit
       addq.w    #8,A7
; CanBus0_Receive() ;         // receive a message via Controller 0 (and display it)
       jsr       _CanBus0_Receive
; printf("\r\n") ;
       pea       @mupde1_11.L
       jsr       (A2)
       addq.w    #4,A7
       bra       CanBusTest_1
; }
; }
; /******************************************************************************************************************************
; * Start of user program
; ******************************************************************************************************************************/
; void main()
; {
       xdef      _main
_main:
       link      A6,#-172
       move.l    A2,-(A7)
       lea       _InstallExceptionHandler.L,A2
; unsigned int row, i=0, count=0, counter1=1;
       clr.l     -168(A6)
       clr.l     -164(A6)
       move.l    #1,-160(A6)
; char c, text[150] ;
; // unsigned int start ;
; // unsigned int end ;
; // char input_char;
; // unsigned long int data;
; // unsigned long int write_data;
; // unsigned long long int *ramptr;
; int PassFailFlag = 1 ;
       move.l    #1,-4(A6)
; i = x = y = z = PortA_Count =0;
       clr.l     _PortA_Count.L
       clr.l     _z.L
       clr.l     _y.L
       clr.l     _x.L
       clr.l     -168(A6)
; Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;
       clr.b     _Timer4Count.L
       clr.b     _Timer3Count.L
       clr.b     _Timer2Count.L
       clr.b     _Timer1Count.L
; InstallExceptionHandler(PIA_ISR, 25) ;          // install interrupt handler for PIAs 1 and 2 on level 1 IRQ
       pea       25
       pea       _PIA_ISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(ACIA_ISR, 26) ;		    // install interrupt handler for ACIA on level 2 IRQ
       pea       26
       pea       _ACIA_ISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 27) ;		// install interrupt handler for Timers 1-4 on level 3 IRQ
       pea       27
       pea       _Timer_ISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Key2PressISR, 28) ;	    // install interrupt handler for Key Press 2 on DE1 board for level 4 IRQ
       pea       28
       pea       _Key2PressISR.L
       jsr       (A2)
       addq.w    #8,A7
; InstallExceptionHandler(Key1PressISR, 29) ;	    // install interrupt handler for Key Press 1 on DE1 board for level 5 IRQ
       pea       29
       pea       _Key1PressISR.L
       jsr       (A2)
       addq.w    #8,A7
; // InstallExceptionHandler(Timer_ISR, 30);
; Timer1Data = 0x25;		// program time delay into timers 1-4
       move.b    #37,4194352
; // Timer2Data = 0x20;
; // Timer3Data = 0x15;
; // Timer4Data = 0x25;
; Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
       move.b    #3,4194354
; Init_CanBus_Controller0();
       jsr       _Init_CanBus_Controller0
; Init_CanBus_Controller1();
       jsr       _Init_CanBus_Controller1
; Init_LCD();             // initialise the LCD display to use a parallel data interface and 2 lines of display
       jsr       _Init_LCD
; Init_RS232() ;          // initialise the RS232 port for use with hyper terminal
       jsr       _Init_RS232
; /*************************************************************************************************
; **  Test of scanf function
; *************************************************************************************************/
; scanflush() ;                       // flush any text that may have been typed ahead
       jsr       _scanflush
; // printf("\r\nEnter Integer: ") ;
; // scanf("%d", &i) ;
; // printf("You entered %d", i) ;
; // sprintf(text, "Hello CPEN 412 Student") ;
; // LCDLine1Message(text) ;
; // printf("\r\nHello CPEN 412 Student\r\nYour LEDs should be Flashing") ;
; // printf("\r\nYour LCD should be displaying") ;
; // while(1)
; //     ;
; // programs should NOT exit as there is nothing to Exit TO !!!!!!
; // There is no OS - just press the reset button to end program and call debug
; /*************************************************************************************************
; **  Test of SPI function
; *************************************************************************************************/
; printf("User program here \r\n");
       pea       @mupde1_12.L
       jsr       _printf
       addq.w    #4,A7
; while(1) {
main_1:
; CanBus1_Receive() ;        // receive a message via Controller 1 (and display it)
       jsr       _CanBus1_Receive
; // for (i = 0; i < 100; i++) {
; //     Wait1ms();
; // }
; printf("\r\n") ;
       pea       @mupde1_11.L
       jsr       _printf
       addq.w    #4,A7
       bra       main_1
; };
; }
       section   const
@mupde1_1:
       dc.b      13,10,87,114,111,116,101,32,91,37,120,93,32
       dc.b      116,111,32,65,100,100,114,101,115,115,91,37
       dc.b      120,93,0
@mupde1_2:
       dc.b      13,10,87,114,111,116,101,32,91,37,120,93,32
       dc.b      102,114,111,109,32,65,100,100,114,101,115,115
       dc.b      91,37,120,93,32,116,111,32,65,100,100,114,101
       dc.b      115,115,91,37,120,93,0
@mupde1_3:
       dc.b      13,10,82,101,97,100,32,91,37,120,93,32,102,114
       dc.b      111,109,32,65,100,100,114,101,115,115,91,37
       dc.b      120,93,0
@mupde1_4:
       dc.b      13,10,66,108,111,99,107,32,82,101,97,100,32
       dc.b      111,112,101,114,97,116,105,111,110,32,99,111
       dc.b      109,112,108,101,116,101,13,10,0
@mupde1_5:
       dc.b      10,73,50,67,32,68,65,67,32,87,114,105,116,101
       dc.b      58,32,80,108,101,97,115,101,32,99,104,101,99
       dc.b      107,32,76,69,68,10,0
@mupde1_6:
       dc.b      67,97,110,48,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,48,58,32,37,100,10,0
@mupde1_7:
       dc.b      67,97,110,48,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,49,58,32,37,100,10,0
@mupde1_8:
       dc.b      67,97,110,49,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,48,58,32,37,100,10,0
@mupde1_9:
       dc.b      67,97,110,49,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,49,58,32,37,100,10,0
@mupde1_10:
       dc.b      13,10,13,10,45,45,45,45,32,67,65,78,66,85,83
       dc.b      32,84,101,115,116,32,45,45,45,45,13,10,0
@mupde1_11:
       dc.b      13,10,0
@mupde1_12:
       dc.b      85,115,101,114,32,112,114,111,103,114,97,109
       dc.b      32,104,101,114,101,32,13,10,0
       section   bss
       xdef      _i
_i:
       ds.b      4
       xdef      _x
_x:
       ds.b      4
       xdef      _y
_y:
       ds.b      4
       xdef      _z
_z:
       ds.b      4
       xdef      _PortA_Count
_PortA_Count:
       ds.b      4
       xdef      _Timer1Count
_Timer1Count:
       ds.b      1
       xdef      _Timer2Count
_Timer2Count:
       ds.b      1
       xdef      _Timer3Count
_Timer3Count:
       ds.b      1
       xdef      _Timer4Count
_Timer4Count:
       ds.b      1
       xref      ULDIV
       xref      _scanflush
       xref      _printf
