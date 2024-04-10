; D:\CPEN412\M68K\PROGRAMS\DEMOCO\CANBUS.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include "canbus.H"
; #include "DM.H"
; // initialisation for Can controller 0
; void Init_CanBus_Controller0(void)
; {
       section   code
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
       pea       @canbus_1.L
       jsr       _printf
       addq.w    #8,A7
; printf("Can0 recieve data at index 1: %d\n", dataArray[1]);
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @canbus_2.L
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
       pea       @canbus_3.L
       jsr       _printf
       addq.w    #8,A7
; printf("Can1 recieve data at index 1: %d\n", dataArray[1]);
       move.b    1(A2),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @canbus_4.L
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
       pea       @canbus_5.L
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
       pea       @canbus_6.L
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
       pea       @canbus_6.L
       jsr       (A2)
       addq.w    #4,A7
       bra       CanBusTest_1
; }
; }
       section   const
@canbus_1:
       dc.b      67,97,110,48,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,48,58,32,37,100,10,0
@canbus_2:
       dc.b      67,97,110,48,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,49,58,32,37,100,10,0
@canbus_3:
       dc.b      67,97,110,49,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,48,58,32,37,100,10,0
@canbus_4:
       dc.b      67,97,110,49,32,114,101,99,105,101,118,101,32
       dc.b      100,97,116,97,32,97,116,32,105,110,100,101,120
       dc.b      32,49,58,32,37,100,10,0
@canbus_5:
       dc.b      13,10,13,10,45,45,45,45,32,67,65,78,66,85,83
       dc.b      32,84,101,115,116,32,45,45,45,45,13,10,0
@canbus_6:
       dc.b      13,10,0
       xref      _Wait1ms
       xref      _printf
