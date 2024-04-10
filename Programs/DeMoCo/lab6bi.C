/*
 * EXAMPLE_1.C
 *
 * This is a minimal program to verify multitasking.
 *
 */

#include <stdio.h>
#include <Bios.h>
#include <ucos_ii.h>
#include "canbus.H"
#include "I2C.H"

#define STACKSIZE  256

/* 
** Stacks for each task are allocated here in the application in this case = 256 bytes
** but you can change size if required
*/

OS_STK Task1Stk[STACKSIZE];
// OS_STK Task2Stk[STACKSIZE];
// OS_STK Task3Stk[STACKSIZE];
// OS_STK Task4Stk[STACKSIZE];
// OS_STK Task5Stk[STACKSIZE];
// OS_STK Task6Stk[STACKSIZE];

/* 
** Our main application which has to
** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
** 2) Call OSInit() to initialise the OS
** 3) Create our application task/threads
** 4) Call OSStart()
*/
void Task1(void *);
void main(void)
{
    // initialise board hardware by calling our routines from the BIOS.C source file
    int i;

    // InstallExceptionHandler(Timer_ISR_1, 30);
    

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
    // OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 11);     // highest priority task
    // OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 13);
    // OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 14);	    // lowest priority task
    // OSTaskCreate(Task5, OS_NULL, &Task5Stk[STACKSIZE], 15);
    // OSTaskCreate(Task6, OS_NULL, &Task6Stk[STACKSIZE], 16);

    OSStart();  // call to start the OS scheduler, (never returns from this function)

    
}

/*
** IMPORTANT : Timer 1 interrupts must be started by the highest priority task 
** that runs first which is Task2
*/

void Task1(void *pdata)
{
    Timer1Data = 0x25;		// program 10 hz time delay into timer 1.
    Timer1Control = 3;

    while (1) {
        
        printf("timer data: %d\n", Timer1Data);
        // CanBus1_Receive() ;        // receive a message via Controller 1 (and display it)
        OSTimeDly(100);
        printf("\r\n") ;

    }
}