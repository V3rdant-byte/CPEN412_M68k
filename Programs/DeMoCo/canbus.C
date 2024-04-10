#include <stdio.h>
#include "canbus.H"
#include "DM.H"

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