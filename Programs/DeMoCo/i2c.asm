; D:\CPEN412\M68K\PROGRAMS\DEMOCO\I2C.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
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
       pea       @i2c_1.L
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
       pea       @i2c_2.L
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
       pea       @i2c_3.L
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
       pea       @i2c_3.L
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
       pea       @i2c_4.L
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
       pea       @i2c_5.L
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
; void ADCWrite(void){
       xdef      _ADCWrite
_ADCWrite:
       link      A6,#-8
       movem.l   A2/A3/A4,-(A7)
       lea       _WaitTIP.L,A2
       lea       _WaitACK.L,A3
       lea       _printf.L,A4
; unsigned char thermistor_value;
; unsigned char potentiometer_value;
; unsigned char photo_resistor_value;
; unsigned int delay = 0xFFFFF;
       move.l    #1048575,-4(A6)
; printf("I2C ADC Read:\n");
       pea       @i2c_6.L
       jsr       (A4)
       addq.w    #4,A7
; printf("\n==============================Measuring==============================\n");
       pea       @i2c_7.L
       jsr       (A4)
       addq.w    #4,A7
; while (1) {
ADCWrite_1:
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
; printf("Value of Thermistor: %d Potentiometer: %d Photo-resister: %d\n", thermistor_value, potentiometer_value, photo_resistor_value);
       move.b    -5(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -6(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -7(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @i2c_8.L
       jsr       (A4)
       add.w     #16,A7
       bra       ADCWrite_1
; }
; }
       section   const
@i2c_1:
       dc.b      13,10,87,114,111,116,101,32,91,37,120,93,32
       dc.b      116,111,32,65,100,100,114,101,115,115,91,37
       dc.b      120,93,0
@i2c_2:
       dc.b      13,10,87,114,111,116,101,32,91,37,120,93,32
       dc.b      102,114,111,109,32,65,100,100,114,101,115,115
       dc.b      91,37,120,93,32,116,111,32,65,100,100,114,101
       dc.b      115,115,91,37,120,93,0
@i2c_3:
       dc.b      13,10,82,101,97,100,32,91,37,120,93,32,102,114
       dc.b      111,109,32,65,100,100,114,101,115,115,91,37
       dc.b      120,93,0
@i2c_4:
       dc.b      13,10,66,108,111,99,107,32,82,101,97,100,32
       dc.b      111,112,101,114,97,116,105,111,110,32,99,111
       dc.b      109,112,108,101,116,101,13,10,0
@i2c_5:
       dc.b      10,73,50,67,32,68,65,67,32,87,114,105,116,101
       dc.b      58,32,80,108,101,97,115,101,32,99,104,101,99
       dc.b      107,32,76,69,68,10,0
@i2c_6:
       dc.b      73,50,67,32,65,68,67,32,82,101,97,100,58,10
       dc.b      0
@i2c_7:
       dc.b      10,61,61,61,61,61,61,61,61,61,61,61,61,61,61
       dc.b      61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
       dc.b      61,77,101,97,115,117,114,105,110,103,61,61,61
       dc.b      61,61,61,61,61,61,61,61,61,61,61,61,61,61,61
       dc.b      61,61,61,61,61,61,61,61,61,61,61,61,10,0
@i2c_8:
       dc.b      86,97,108,117,101,32,111,102,32,84,104,101,114
       dc.b      109,105,115,116,111,114,58,32,37,100,32,80,111
       dc.b      116,101,110,116,105,111,109,101,116,101,114
       dc.b      58,32,37,100,32,80,104,111,116,111,45,114,101
       dc.b      115,105,115,116,101,114,58,32,37,100,10,0
       xref      ULDIV
       xref      _printf
