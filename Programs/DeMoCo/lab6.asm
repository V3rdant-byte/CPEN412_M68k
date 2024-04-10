; D:\CPEN412\M68K\PROGRAMS\DEMOCO\LAB6.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
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
; /* 
; ** Stacks for each task are allocated here in the application in this case = 256 bytes
; ** but you can change size if required
; */
; OS_STK Task1Stk[STACKSIZE];
; OS_STK Task2Stk[STACKSIZE];
; OS_STK Task3Stk[STACKSIZE];
; OS_STK Task4Stk[STACKSIZE];
; /* Prototypes for our tasks/threads*/
; void Task1(void *);	/* (void *) means the child task expects no data from parent*/
; void Task2(void *);
; void Task3(void *);
; void Task4(void *);
; void display(int num);
; /* 
; ** Our main application which has to
; ** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
; ** 2) Call OSInit() to initialise the OS
; ** 3) Create our application task/threads
; ** 4) Call OSStart()
; */
; void main(void)
; {
       section   code
       xdef      _main
_main:
       move.l    A2,-(A7)
       lea       _OSTaskCreate.L,A2
; // initialise board hardware by calling our routines from the BIOS.C source file
; Init_RS232();
       jsr       _Init_RS232
; Init_LCD();
       jsr       _Init_LCD
; /* display welcome message on LCD display */
; Oline0("Altera DE1/68K");
       pea       @lab6_1.L
       jsr       _Oline0
       addq.w    #4,A7
; Oline1("Micrium uC/OS-II RTOS");
       pea       @lab6_2.L
       jsr       _Oline1
       addq.w    #4,A7
; OSInit();		// call to initialise the OS
       jsr       _OSInit
; /* 
; ** Now create the 4 child tasks and pass them no data.
; ** the smaller the numerical priority value, the higher the task priority 
; */
; OSTaskCreate(Task1, OS_NULL, &Task1Stk[STACKSIZE], 12);     
       pea       12
       lea       _Task1Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task1.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 11);     // highest priority task
       pea       11
       lea       _Task2Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task2.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 13);
       pea       13
       lea       _Task3Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task3.L
       jsr       (A2)
       add.w     #16,A7
; OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 14);	    // lowest priority task
       pea       14
       lea       _Task4Stk.L,A0
       add.w     #512,A0
       move.l    A0,-(A7)
       clr.l     -(A7)
       pea       _Task4.L
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
       move.l    D2,-(A7)
; unsigned char count = 0;
       clr.b     D2
; for (;;) {
Task1_1:
; printf("This is Task #1 counting up at the rate of 0.1 Hz\n");
       pea       @lab6_3.L
       jsr       _printf
       addq.w    #4,A7
; display(count);
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _display
       addq.w    #4,A7
; count++;
       addq.b    #1,D2
; OSTimeDly(1000);
       pea       1000
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
       move.l    D2,-(A7)
; // must start timer ticker here 
; unsigned char count = 0;
       clr.b     D2
; Timer1_Init() ;      // this function is in BIOS.C and written by us to start timer      
       jsr       _Timer1_Init
; for (;;) {
Task2_1:
; printf("This is Task #2 counting up at the rate of 0.2 Hz\n");
       pea       @lab6_4.L
       jsr       _printf
       addq.w    #4,A7
; display(count);
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _display
       addq.w    #4,A7
; count++;
       addq.b    #1,D2
; OSTimeDly(500);
       pea       500
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
       move.l    D2,-(A7)
; unsigned char count = 0;
       clr.b     D2
; for (;;) {
Task3_1:
; printf("This is Task #3 counting up at the rate of 2 Hz\n");
       pea       @lab6_5.L
       jsr       _printf
       addq.w    #4,A7
; display(count);
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _display
       addq.w    #4,A7
; count++;
       addq.b    #1,D2
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
       move.l    D2,-(A7)
; unsigned char count = 0;
       clr.b     D2
; for (;;) {
Task4_1:
; printf("This is Task #4 counting up at the rate of 0.5 Hz\n");
       pea       @lab6_6.L
       jsr       _printf
       addq.w    #4,A7
; display(count);
       and.l     #255,D2
       move.l    D2,-(A7)
       jsr       _display
       addq.w    #4,A7
; count++;
       addq.b    #1,D2
; OSTimeDly(200);
       pea       200
       jsr       _OSTimeDly
       addq.w    #4,A7
       bra       Task4_1
; }
; }
; void display(int num)
; {
       xdef      _display
_display:
       link      A6,#-24
       movem.l   D2/D3/D4/A2,-(A7)
       lea       -24(A6),A2
       move.l    8(A6),D3
; unsigned int i;
; unsigned char *digits[6];
; unsigned temp_num;
; temp_num = num;
       move.l    D3,D4
; for (i = 0; i < 6; i++) {
       clr.l     D2
display_1:
       cmp.l     #6,D2
       bhs.s     display_3
; digits[i] = temp_num % 16;
       move.l    D4,-(A7)
       pea       16
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D2,D1
       lsl.l     #2,D1
       move.l    D0,0(A2,D1.L)
; temp_num = temp_num / 16;
       move.l    D4,-(A7)
       pea       16
       jsr       ULDIV
       move.l    (A7),D4
       addq.w    #8,A7
       addq.l    #1,D2
       bra       display_1
display_3:
; }
; PortA = num & 0xff; //LED0-7
       move.l    D3,D0
       and.l     #255,D0
       move.b    D0,4194304
; PortB = (num >> 8) & 0x03; //LED8-9
       move.l    D3,D0
       asr.l     #8,D0
       and.l     #3,D0
       move.b    D0,4194306
; HEX_A = ((digits[1] << 4) + (digits[0] & 0x0f));
       move.l    4(A2),D0
       asl.l     #4,D0
       move.l    (A2),D1
       and.l     #15,D1
       add.l     D1,D0
       move.b    D0,4194320
; HEX_B = ((digits[3] << 4) + (digits[2] & 0x0f));
       move.l    12(A2),D0
       asl.l     #4,D0
       move.l    8(A2),D1
       and.l     #15,D1
       add.l     D1,D0
       move.b    D0,4194322
; HEX_C = ((digits[5] << 4) + (digits[4] & 0x0f)); 
       move.l    20(A2),D0
       asl.l     #4,D0
       move.l    16(A2),D1
       and.l     #15,D1
       add.l     D1,D0
       move.b    D0,4194324
       movem.l   (A7)+,D2/D3/D4/A2
       unlk      A6
       rts
; }
       section   const
@lab6_1:
       dc.b      65,108,116,101,114,97,32,68,69,49,47,54,56,75
       dc.b      0
@lab6_2:
       dc.b      77,105,99,114,105,117,109,32,117,67,47,79,83
       dc.b      45,73,73,32,82,84,79,83,0
@lab6_3:
       dc.b      84,104,105,115,32,105,115,32,84,97,115,107,32
       dc.b      35,49,32,99,111,117,110,116,105,110,103,32,117
       dc.b      112,32,97,116,32,116,104,101,32,114,97,116,101
       dc.b      32,111,102,32,48,46,49,32,72,122,10,0
@lab6_4:
       dc.b      84,104,105,115,32,105,115,32,84,97,115,107,32
       dc.b      35,50,32,99,111,117,110,116,105,110,103,32,117
       dc.b      112,32,97,116,32,116,104,101,32,114,97,116,101
       dc.b      32,111,102,32,48,46,50,32,72,122,10,0
@lab6_5:
       dc.b      84,104,105,115,32,105,115,32,84,97,115,107,32
       dc.b      35,51,32,99,111,117,110,116,105,110,103,32,117
       dc.b      112,32,97,116,32,116,104,101,32,114,97,116,101
       dc.b      32,111,102,32,50,32,72,122,10,0
@lab6_6:
       dc.b      84,104,105,115,32,105,115,32,84,97,115,107,32
       dc.b      35,52,32,99,111,117,110,116,105,110,103,32,117
       dc.b      112,32,97,116,32,116,104,101,32,114,97,116,101
       dc.b      32,111,102,32,48,46,53,32,72,122,10,0
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
       xref      _Init_LCD
       xref      _Timer1_Init
       xref      _Init_RS232
       xref      _OSInit
       xref      _OSStart
       xref      _OSTaskCreate
       xref      _Oline0
       xref      ULDIV
       xref      _Oline1
       xref      _OSTimeDly
       xref      _printf
