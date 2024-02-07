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
; #define StartOfExceptionVectorTable 0x08030000
; //#define StartOfExceptionVectorTable 0x0B000000
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
; if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_1
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
; PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
       move.b    _Timer1Count.L,D0
       addq.b    #1,_Timer1Count.L
       move.b    D0,4194304
Timer_ISR_1:
; }
; if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_3
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
; PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
       move.b    _Timer2Count.L,D0
       addq.b    #1,_Timer2Count.L
       move.b    D0,4194308
Timer_ISR_3:
; }
; if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_5
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
; HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
       move.b    _Timer3Count.L,D0
       addq.b    #1,_Timer3Count.L
       move.b    D0,4194320
Timer_ISR_5:
; }
; if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_7
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
; HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
       move.b    _Timer4Count.L,D0
       addq.b    #1,_Timer4Count.L
       move.b    D0,4194322
Timer_ISR_7:
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
       move.l    #134414336,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; /******************************************************************************************************************************
; * Start of user program
; ******************************************************************************************************************************/
; void main()
; {
       xdef      _main
_main:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/A2,-(A7)
       lea       _printf.L,A2
; //     unsigned int row, i=0, count=0, counter1=1;
; //     char c, text[150] ;
; unsigned int start ;
; unsigned int end ;
; char input_char;
; unsigned long int data;
; unsigned long int write_data;
; unsigned long long int *ramptr;
; // 	int PassFailFlag = 1 ;
; //     i = x = y = z = PortA_Count =0;
; //     Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;
; // InstallExceptionHandler(PIA_ISR, 25) ;          // install interrupt handler for PIAs 1 and 2 on level 1 IRQ
; // InstallExceptionHandler(ACIA_ISR, 26) ;		    // install interrupt handler for ACIA on level 2 IRQ
; // InstallExceptionHandler(Timer_ISR, 27) ;		// install interrupt handler for Timers 1-4 on level 3 IRQ
; // InstallExceptionHandler(Key2PressISR, 28) ;	    // install interrupt handler for Key Press 2 on DE1 board for level 4 IRQ
; // InstallExceptionHandler(Key1PressISR, 29) ;	    // install interrupt handler for Key Press 1 on DE1 board for level 5 IRQ
; //     Timer1Data = 0x10;		// program time delay into timers 1-4
; //     Timer2Data = 0x20;
; //     Timer3Data = 0x15;
; //     Timer4Data = 0x25;
; //     Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
; //     Timer2Control = 3;
; //     Timer3Control = 3;
; //     Timer4Control = 3;
; //     Init_LCD();             // initialise the LCD display to use a parallel data interface and 2 lines of display
; Init_RS232() ;          // initialise the RS232 port for use with hyper terminal
       jsr       _Init_RS232
; // /*************************************************************************************************
; // **  Test of scanf function
; // *************************************************************************************************/
; //     scanflush() ;                       // flush any text that may have been typed ahead
; //     printf("\r\nEnter Integer: ") ;
; //     scanf("%d", &i) ;
; //     printf("You entered %d", i) ;
; //     sprintf(text, "Hello CPEN 412 Student") ;
; //     LCDLine1Message(text) ;
; //     printf("\r\nHello CPEN 412 Student\r\nYour LEDs should be Flashing") ;
; //     printf("\r\nYour LCD should be displaying") ;
; //     // address input
; //     // word and long input should be aligned to even addresses
; do{
main_1:
; printf("\r\nstart Address from 0x08020000 to 0x08030000): ");
       pea       @mupde1_1.L
       jsr       (A2)
       addq.w    #4,A7
; start = Get8HexDigits(0);
       clr.l     -(A7)
       jsr       _Get8HexDigits
       addq.w    #4,A7
       move.l    D0,D5
       cmp.l     #134348800,D5
       blo       main_1
       cmp.l     #134414336,D5
       bhi       main_1
; } while (0x08020000 > start || 0x08030000 < start);
; do{
main_3:
; printf("\r\nend Address from 0x08020000 to 0x08030000): ");
       pea       @mupde1_2.L
       jsr       (A2)
       addq.w    #4,A7
; end = Get8HexDigits(0);
       clr.l     -(A7)
       jsr       _Get8HexDigits
       addq.w    #4,A7
       move.l    D0,D6
       cmp.l     D6,D5
       bhi       main_3
       cmp.l     #134414336,D6
       bhi       main_3
; } while (start > end || end > 0x08030000);
; // test data pattern
; while(1){
main_5:
; FlushKeyboard();
       jsr       _FlushKeyboard
; printf("\r\nChoose test pattern: \r\na: 55\r\nb: AA\r\nc: FF\r\nd: 00");
       pea       @mupde1_3.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n#");
       pea       @mupde1_4.L
       jsr       (A2)
       addq.w    #4,A7
; input_char = toupper(_getch());
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.b    D0,D4
; if(input_char == 'a'){
       cmp.b     #97,D4
       bne.s     main_8
; data = 0x55;
       moveq     #85,D2
; printf("\r\nData: 0x%x", data);
       move.l    D2,-(A7)
       pea       @mupde1_5.L
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra       main_7
main_8:
; }
; else if(input_char == 'b'){
       cmp.b     #98,D4
       bne.s     main_10
; data = 0xAA;
       move.l    #170,D2
; printf("\r\nData: 0x%x", data);
       move.l    D2,-(A7)
       pea       @mupde1_6.L
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra       main_7
main_10:
; }
; else if(input_char == 'c'){
       cmp.b     #99,D4
       bne.s     main_12
; data = 0xFF;
       move.l    #255,D2
; printf("\r\nData: 0x%x", data);
       move.l    D2,-(A7)
       pea       @mupde1_7.L
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra.s     main_7
main_12:
; }
; else if(input_char == 'd'){
       cmp.b     #100,D4
       bne.s     main_14
; data = 0x00;
       clr.l     D2
; printf("\r\nData: 0x%x", data);
       move.l    D2,-(A7)
       pea       @mupde1_8.L
       jsr       (A2)
       addq.w    #8,A7
; break;
       bra.s     main_7
main_14:
       bra       main_5
main_7:
; }
; }
; // test data size selection
; while(1)    {
main_16:
; FlushKeyboard();
       jsr       _FlushKeyboard
; printf("\r\nEnter 'B', for bytes, 'W' for words, or 'L' for long words: ");
       pea       @mupde1_9.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n#");
       pea       @mupde1_10.L
       jsr       (A2)
       addq.w    #4,A7
; input_char = toupper(_getch());
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _toupper
       addq.w    #4,A7
       move.b    D0,D4
; if(input_char == 'B'){
       cmp.b     #66,D4
       bne.s     main_19
; printf("\r\nBytes");
       pea       @mupde1_11.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       main_18
main_19:
; }
; else if(input_char == 'W'){
       cmp.b     #87,D4
       bne.s     main_21
; printf("\r\nWords");
       pea       @mupde1_12.L
       jsr       (A2)
       addq.w    #4,A7
; data = data | data << 8;
       move.l    D2,D0
       lsl.l     #8,D0
       or.l      D0,D2
; break;
       bra       main_18
main_21:
; }
; else if(input_char == 'L'){
       cmp.b     #76,D4
       bne       main_23
; printf("\r\nLong Words");
       pea       @mupde1_13.L
       jsr       (A2)
       addq.w    #4,A7
; data = data | data << 8 | data << 16 | data << 24;
       move.l    D2,D0
       move.l    D2,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D2,D1
       lsl.l     #8,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D2,D1
       lsl.l     #8,D1
       lsl.l     #8,D1
       lsl.l     #8,D1
       or.l      D1,D0
       move.l    D0,D2
; break;
       bra.s     main_18
main_23:
       bra       main_16
main_18:
; }
; }
; // start writing
; // unsigned int counter = 0x900;
; ramptr = start;
       move.l    D5,D3
; while(1){
main_25:
; if (ramptr > end){
       cmp.l     D6,D3
       bls.s     main_28
; printf("\r\nWrite Finished. Read starts.");
       pea       @mupde1_14.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra.s     main_27
main_28:
; }
; *ramptr = data;
       move.l    D3,A0
       move.l    D2,(A0)
; // counter++;
; // Dont check every time, just check some time incl first time
; // if (counter == 0x901){
; //     printf("\r\nWrite: 0x%x to addr 0x%x", *ramptr, ramptr);
; //     counter = 1;
; // }
; // Increment address
; ramptr++;
       addq.l    #4,D3
       bra       main_25
main_27:
; }
; // start reading
; ramptr = start;
       move.l    D5,D3
; // Reset counter to default
; // counter = 0x900;
; // Read loop
; while(1){
main_30:
; // When end addr is reached
; if (ramptr > end){
       cmp.l     D6,D3
       bls.s     main_33
; printf("\r\nRead complete.");
       pea       @mupde1_15.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nPASS: Mem test completed with no errors.");
       pea       @mupde1_16.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra       main_32
main_33:
; }
; // Read check every address to specified data by user
; if (*ramptr != data){
       move.l    D3,A0
       cmp.l     (A0),D2
       beq.s     main_35
; printf("\r\nERROR: Address 0x%x data is 0x%x but should be 0x%x", ramptr, *ramptr, data);
       move.l    D2,-(A7)
       move.l    D3,A0
       move.l    (A0),-(A7)
       move.l    D3,-(A7)
       pea       @mupde1_17.L
       jsr       (A2)
       add.w     #16,A7
; printf("\r\nFAIL: Mem test did not complete successfully.");
       pea       @mupde1_18.L
       jsr       (A2)
       addq.w    #4,A7
; break;
       bra.s     main_32
main_35:
; }
; // counter++;
; // // Dont check every time, just check some time incl first time
; // if (counter == 0x8cc){
; //     printf("\r\nRead: Address 0x%x data is 0x%x", ramptr, *ramptr);
; //     counter = 1;
; // }
; ramptr++;
       addq.l    #4,D3
       bra       main_30
main_32:
; }
; while(1)
main_37:
       bra       main_37
; ;
; // programs should NOT exit as there is nothing to Exit TO !!!!!!
; // There is no OS - just press the reset button to end program and call debug
; }
       section   const
@mupde1_1:
       dc.b      13,10,115,116,97,114,116,32,65,100,100,114,101
       dc.b      115,115,32,102,114,111,109,32,48,120,48,56,48
       dc.b      50,48,48,48,48,32,116,111,32,48,120,48,56,48
       dc.b      51,48,48,48,48,41,58,32,0
@mupde1_2:
       dc.b      13,10,101,110,100,32,65,100,100,114,101,115
       dc.b      115,32,102,114,111,109,32,48,120,48,56,48,50
       dc.b      48,48,48,48,32,116,111,32,48,120,48,56,48,51
       dc.b      48,48,48,48,41,58,32,0
@mupde1_3:
       dc.b      13,10,67,104,111,111,115,101,32,116,101,115
       dc.b      116,32,112,97,116,116,101,114,110,58,32,13,10
       dc.b      97,58,32,53,53,13,10,98,58,32,65,65,13,10,99
       dc.b      58,32,70,70,13,10,100,58,32,48,48,0
@mupde1_4:
       dc.b      13,10,35,0
@mupde1_5:
       dc.b      13,10,68,97,116,97,58,32,48,120,37,120,0
@mupde1_6:
       dc.b      13,10,68,97,116,97,58,32,48,120,37,120,0
@mupde1_7:
       dc.b      13,10,68,97,116,97,58,32,48,120,37,120,0
@mupde1_8:
       dc.b      13,10,68,97,116,97,58,32,48,120,37,120,0
@mupde1_9:
       dc.b      13,10,69,110,116,101,114,32,39,66,39,44,32,102
       dc.b      111,114,32,98,121,116,101,115,44,32,39,87,39
       dc.b      32,102,111,114,32,119,111,114,100,115,44,32
       dc.b      111,114,32,39,76,39,32,102,111,114,32,108,111
       dc.b      110,103,32,119,111,114,100,115,58,32,0
@mupde1_10:
       dc.b      13,10,35,0
@mupde1_11:
       dc.b      13,10,66,121,116,101,115,0
@mupde1_12:
       dc.b      13,10,87,111,114,100,115,0
@mupde1_13:
       dc.b      13,10,76,111,110,103,32,87,111,114,100,115,0
@mupde1_14:
       dc.b      13,10,87,114,105,116,101,32,70,105,110,105,115
       dc.b      104,101,100,46,32,82,101,97,100,32,115,116,97
       dc.b      114,116,115,46,0
@mupde1_15:
       dc.b      13,10,82,101,97,100,32,99,111,109,112,108,101
       dc.b      116,101,46,0
@mupde1_16:
       dc.b      13,10,80,65,83,83,58,32,77,101,109,32,116,101
       dc.b      115,116,32,99,111,109,112,108,101,116,101,100
       dc.b      32,119,105,116,104,32,110,111,32,101,114,114
       dc.b      111,114,115,46,0
@mupde1_17:
       dc.b      13,10,69,82,82,79,82,58,32,65,100,100,114,101
       dc.b      115,115,32,48,120,37,120,32,100,97,116,97,32
       dc.b      105,115,32,48,120,37,120,32,98,117,116,32,115
       dc.b      104,111,117,108,100,32,98,101,32,48,120,37,120
       dc.b      0
@mupde1_18:
       dc.b      13,10,70,65,73,76,58,32,77,101,109,32,116,101
       dc.b      115,116,32,100,105,100,32,110,111,116,32,99
       dc.b      111,109,112,108,101,116,101,32,115,117,99,99
       dc.b      101,115,115,102,117,108,108,121,46,0
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
       xref      _toupper
       xref      _printf
