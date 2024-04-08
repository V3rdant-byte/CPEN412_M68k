#include <stdio.h>

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
void ADCWrite(void){
    unsigned char thermistor_value;
    unsigned char potentiometer_value;
    unsigned char photo_resistor_value;
    unsigned int delay = 0xFFFFF;

    printf("I2C ADC Read:\n");
    printf("\n==============================Measuring==============================\n");

    while (1) {

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

        printf("Value of Thermistor: %d Potentiometer: %d Photo-resister: %d\n", thermistor_value, potentiometer_value, photo_resistor_value);
    }
}