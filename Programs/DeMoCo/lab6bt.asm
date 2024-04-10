; D:\CPEN412\M68K\PROGRAMS\DEMOCO\LAB6BT.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; /*
; * EXAMPLE_1.C
; *
; * This is a minimal program to verify multitasking.
; *
; */
; #include <stdio.h>
; #include <Bios.h>
; #include <ucos_ii.h>
; #define STACKSIZE  256
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
; /* 
; ** Stacks for each task are allocated here in the application in this case = 256 bytes
; ** but you can change size if required
; */
; OS_STK Task1Stk[STACKSIZE];
; OS_STK Task2Stk[STACKSIZE];
; OS_STK Task3Stk[STACKSIZE];
; OS_STK Task4Stk[STACKSIZE];
; OS_STK Task5Stk[STACKSIZE];
; OS_STK Task6Stk[STACKSIZE];
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
; void Task1(void *);	/* (void *) means the child task expects no data from parent*/
; void Task2(void *);
; void Task3(void *);
; void Task4(void *);
; void Task5(void *);
; void Enable_SCL(void){
       section   code
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
       pea       @lab6bt_1.L
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
       pea       @lab6bt_2.L
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
       pea       @lab6bt_3.L
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
       pea       @lab6bt_3.L
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
       pea       @lab6bt_4.L
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
       pea       @lab6bt_5.L
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
       pea       @lab6bt_6.L
       jsr       _printf
       addq.w    #8,A7
; printf("Can0 recieve data at index 1: %d\n", dataArray[1]);
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @lab6bt_7.L
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
       pea       @lab6bt_8.L
       jsr       _printf
       addq.w    #8,A7
; printf("Can1 recieve data at index 1: %d\n", dataArray[1]);
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @lab6bt_9.L
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
       pea       @lab6bt_10.L
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
       pea       @lab6bt_11.L
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
       pea       @lab6bt_11.L
       jsr       (A2)
       addq.w    #4,A7
       bra       CanBusTest_1
; }
; }
; /* 
; ** Our main application which has to
; ** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
; ** 2) Call OSInit() to initialise the OS
; ** 3) Create our application task/threads
; ** 4) Call OSStart()
; */
; void main(void)
; {
       xdef      _main
_main:
       move.l    A2,-(A7)
       lea       _OSTaskCreate.L,A2
; // initialise board hardware by calling our routines from the BIOS.C source file
; Init_RS232();
       jsr       _Init_RS232
; Init_LCD();
       jsr       _Init_LCD
; I2C_Init();
       jsr       _I2C_Init
; Init_CanBus_Controller0();
       jsr       _Init_CanBus_Controller0
; Init_CanBus_Controller1();
       jsr       _Init_CanBus_Controller1
; /* display welcome message on LCD display */
; Oline0("Altera DE1/68K");
       pea       @lab6bt_12.L
       jsr       _Oline0
       addq.w    #4,A7
; Oline1("Micrium uC/OS-II RTOS");
       pea       @lab6bt_13.L
       jsr       _Oline1
       addq.w    #4,A7
; OSInit();		// call to initialise the OS
       jsr       _OSInit
; /* 
; ** Now create the 4 child tasks and pass them no data.
; ** the smaller the numerical priority value, the higher the task priority 
; */
; OSTaskCreate(Task1, OS_NULL, &Task1Stk[STACKSIZE], 11);     
       pea       11
       lea       _Task1Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task1.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 13);     // highest priority task
       pea       13
       lea       _Task2Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task2.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 14);
       pea       14
       lea       _Task3Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task3.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 15);	    // lowest priority task
       pea       15
       lea       _Task4Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task4.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task5, OS_NULL, &Task5Stk[STACKSIZE], 12);
       pea       12
       lea       _Task5Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task5.L
       jsr       (A2)
       add.w     #16,A7
; OSStart();  // call to start the OS scheduler, (never returns from this function)
       jsr       _OSStart
       move.l    (A7)+,A2
       rts
; }
; /*
; ** IMPORTANT : Timer 1 interrupts must be started by the highest priority task 
; ** that runs first which is Task2
; */
; void Task1(void *pdata)
; {
       xdef      _Task1
_Task1:
       link      A6,#0
; Timer1_Init() ;      // this function is in BIOS.C and written by us to start timer   
       jsr       _Timer1_Init
; for (;;) {
Task1_1:
; CanBus0_Transmit(0, PortA);
       move.b    4194304,D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       clr.l     -(A7)
       jsr       _CanBus0_Transmit
       addq.w    #8,A7
; OSTimeDly(10);
       pea       10
       jsr       _OSTimeDly
       addq.w    #4,A7
       bra       Task1_1
; }
; }
; /*
; ** Task 2 below was created with the highest priority so it must start timer1
; ** so that it produces interrupts for the 100hz context switches
; */
; void Task2(void *pdata)
; {   
       xdef      _Task2
_Task2:
       link      A6,#0
; for (;;) {
Task2_1:
; CanBus0_Transmit(1, ADCRead(1));
       move.l    D0,-(A7)
       pea       1
       jsr       _ADCRead
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       1
       jsr       _CanBus0_Transmit
       addq.w    #8,A7
; OSTimeDly(20);
       pea       20
       jsr       _OSTimeDly
       addq.w    #4,A7
       bra       Task2_1
; }
; }
; void Task3(void *pdata)
; {
       xdef      _Task3
_Task3:
       link      A6,#0
; for (;;) {
Task3_1:
; CanBus0_Transmit(2, ADCRead(2));
       move.l    D0,-(A7)
       pea       2
       jsr       _ADCRead
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       2
       jsr       _CanBus0_Transmit
       addq.w    #8,A7
; OSTimeDly(50);
       pea       50
       jsr       _OSTimeDly
       addq.w    #4,A7
       bra       Task3_1
; }
; }
; void Task4(void *pdata)
; {
       xdef      _Task4
_Task4:
       link      A6,#0
; for (;;) {
Task4_1:
; CanBus0_Transmit(3, ADCRead(0));
       move.l    D0,-(A7)
       clr.l     -(A7)
       jsr       _ADCRead
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       3
       jsr       _CanBus0_Transmit
       addq.w    #8,A7
; OSTimeDly(200);
       pea       200
       jsr       _OSTimeDly
       addq.w    #4,A7
       bra       Task4_1
; }
; }
; void Task5(void *pdata)
; {
       xdef      _Task5
_Task5:
       link      A6,#0
; for (;;) {
Task5_1:
; CanBus1_Receive();
       jsr       _CanBus1_Receive
       bra       Task5_1
; }
; }
       section   const
@lab6bt_1:
       dc.b      13,10,87,114,111,116,101,32,91,37,120,93,32
       dc.b      116,111,32,65,100,100,114,101,115,115,91,37
       dc.b      120,93,0
@lab6bt_2:
       dc.b      13,10,87,114,111,116,101,32,91,37,120,93,32
       dc.b      102,114,111,109,32,65,100,100,114,101,115,115
       dc.b      91,37,120,93,32,116,111,32,65,100,100,114,101
       dc.b      115,115,91,37,120,93,0
@lab6bt_3:
       dc.b      13,10,82,101,97,100,32,91,37,120,93,32,102,114
       dc.b      111,109,32,65,100,100,114,101,115,115,91,37
       dc.b      120,93,0
@lab6bt_4:
       dc.b      13,10,66,108,111,99,107,32,82,101,97,100,32
       dc.b      111,112,101,114,97,116,105,111,110,32,99,111
       dc.b      109,112,108,101,116,101,13,10,0
@lab6bt_5:
       dc.b      10,73,50,67,32,68,65,67,32,87,114,105,116,101
       dc.b      58,32,80,108,101,97,115,101,32,99,104,101,99
       dc.b      107,32,76,69,68,10,0
@lab6bt_6:
       dc.b      67,97,110,48,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,48,58,32,37,100,10,0
@lab6bt_7:
       dc.b      67,97,110,48,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,49,58,32,37,100,10,0
@lab6bt_8:
       dc.b      67,97,110,49,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,48,58,32,37,100,10,0
@lab6bt_9:
       dc.b      67,97,110,49,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,49,58,32,37,100,10,0
@lab6bt_10:
       dc.b      13,10,13,10,45,45,45,45,32,67,65,78,66,85,83
       dc.b      32,84,101,115,116,32,45,45,45,45,13,10,0
@lab6bt_11:
       dc.b      13,10,0
@lab6bt_12:
       dc.b      65,108,116,101,114,97,32,68,69,49,47,54,56,75
       dc.b      0
@lab6bt_13:
       dc.b      77,105,99,114,105,117,109,32,117,67,47,79,83
       dc.b      45,73,73,32,82,84,79,83,0
       section   bss
       xdef      _Task1Stk
_Task1Stk:
       ds.b      512
       xdef      _Task2Stk
_Task2Stk:
       ds.b      512
       xdef      _Task3Stk
_Task3Stk:
       ds.b      512
       xdef      _Task4Stk
_Task4Stk:
       ds.b      512
       xdef      _Task5Stk
_Task5Stk:
       ds.b      512
       xdef      _Task6Stk
_Task6Stk:
       ds.b      512
       xref      _Init_LCD
       xref      _Timer1_Init
       xref      _Init_RS232
       xref      _Wait1ms
       xref      _OSInit
       xref      _OSStart
       xref      _OSTaskCreate
       xref      _Oline0
       xref      ULDIV
       xref      _Oline1
       xref      _OSTimeDly
       xref      _printf
