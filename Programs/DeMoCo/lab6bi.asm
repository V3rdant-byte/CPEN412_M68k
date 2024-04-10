; D:\CPEN412\M68K\PROGRAMS\DEMOCO\LAB6BI.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; /*
; * EXAMPLE_1.C
; *
; * This is a minimal program to verify multitasking.
; *
; */
; #include <stdio.h>
; #include <Bios.h>
; #include <ucos_ii.h>
; #include "canbus.H"
; #include "I2C.H"
; #define STACKSIZE  256
; /* 
; ** Stacks for each task are allocated here in the application in this case = 256 bytes
; ** but you can change size if required
; */
; OS_STK Task1Stk[STACKSIZE];
; // OS_STK Task2Stk[STACKSIZE];
; // OS_STK Task3Stk[STACKSIZE];
; // OS_STK Task4Stk[STACKSIZE];
; // OS_STK Task5Stk[STACKSIZE];
; // OS_STK Task6Stk[STACKSIZE];
; /* 
; ** Our main application which has to
; ** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
; ** 2) Call OSInit() to initialise the OS
; ** 3) Create our application task/threads
; ** 4) Call OSStart()
; */
; void Task1(void *);
; void main(void)
; {
       section   code
       xdef      _main
_main:
       link      A6,#-4
; // initialise board hardware by calling our routines from the BIOS.C source file
; int i;
; // InstallExceptionHandler(Timer_ISR_1, 30);
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
       pea       @lab6bi_1.L
       jsr       _Oline0
       addq.w    #4,A7
; Oline1("Micrium uC/OS-II RTOS");
       pea       @lab6bi_2.L
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
       jsr       _OSTaskCreate
       add.w     #16,A7
; // OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 11);     // highest priority task
; // OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 13);
; // OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 14);	    // lowest priority task
; // OSTaskCreate(Task5, OS_NULL, &Task5Stk[STACKSIZE], 15);
; // OSTaskCreate(Task6, OS_NULL, &Task6Stk[STACKSIZE], 16);
; OSStart();  // call to start the OS scheduler, (never returns from this function)
       jsr       _OSStart
       unlk      A6
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
; Timer1Data = 0x25;		// program 10 hz time delay into timer 1.
       move.b    #37,4194352
; Timer1Control = 3;
       move.b    #3,4194354
; while (1) {
Task1_1:
; printf("timer data: %d\n", Timer1Data);
       move.b    4194352,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @lab6bi_3.L
       jsr       _printf
       addq.w    #8,A7
; // CanBus1_Receive() ;        // receive a message via Controller 1 (and display it)
; OSTimeDly(100);
       pea       100
       jsr       _OSTimeDly
       addq.w    #4,A7
; printf("\r\n") ;
       pea       @lab6bi_4.L
       jsr       _printf
       addq.w    #4,A7
       bra       Task1_1
; }
; }
       section   const
@lab6bi_1:
       dc.b      65,108,116,101,114,97,32,68,69,49,47,54,56,75
       dc.b      0
@lab6bi_2:
       dc.b      77,105,99,114,105,117,109,32,117,67,47,79,83
       dc.b      45,73,73,32,82,84,79,83,0
@lab6bi_3:
       dc.b      116,105,109,101,114,32,100,97,116,97,58,32,37
       dc.b      100,10,0
@lab6bi_4:
       dc.b      13,10,0
       section   bss
       xdef      _Task1Stk
_Task1Stk:
       ds.b      512
       xref      _Init_LCD
       xref      _Init_RS232
       xref      _I2C_Init
       xref      _Init_CanBus_Controller0
       xref      _Init_CanBus_Controller1
       xref      _OSInit
       xref      _OSStart
       xref      _OSTaskCreate
       xref      _Oline0
       xref      _Oline1
       xref      _OSTimeDly
       xref      _printf
