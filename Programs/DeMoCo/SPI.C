/*************************************************************
 ** SPI Controller registers
 *************************************************************/
// SPI Registers
#define SPI_Control (*(volatile unsigned char *)(0x00408020))
#define SPI_Status (*(volatile unsigned char *)(0x00408022))
#define SPI_Data (*(volatile unsigned char *)(0x00408024))
#define SPI_Ext (*(volatile unsigned char *)(0x00408026))
#define SPI_CS (*(volatile unsigned char *)(0x00408028))

// Macros to enable or disable the flash memory chip enable off SSN_O[7..0]
// In this case, we assume there is only 1 device connected to SSN_O[0]
// So we can write hex FE to the SPI_CS to enable it (the enable on the flash chip is active low)
// And write FF to disable it
#define Enable_SPI_CS() SPI_CS = 0xFE
#define Disable_SPI_CS() SPI_CS = 0xFF

/******************************************************************************************
 ** The following code is for the SPI controller
 *******************************************************************************************/
// Return true if the SPI has finished transmitting a byte (to say the Flash chip)
// Return false otherwise
// This can be used in a polling algorithm to know when the controller is busy or idle.
int TestForSPITransmitDataComplete(void) {
    int status_bit = (SPI_Status >> 7) & 0x01; // Used bit-shift to read Bit 7 of the SPI_Status (SPIF)
    if (status_bit == 1) {
        return 1;
    } else if (status_bit == 0) {
        return 0;
    } else {
        return 0;
    }
}

/************************************************************************************
 ** Initializes the SPI controller chip to set speed, interrupt capability, etc.
 ************************************************************************************/
void SPI_Init(void) {
    // Program the SPI Control, EXT, CS, and Status registers to initialize the SPI controller
    // Don't forget to call this routine from main() before you do anything else with SPI

    // Here are some settings we want to create

    // Control Reg - interrupts disabled, core enabled, Master mode, Polarity and Phase of clock = [0,0], speed = divide by 32 = approx 700Khz
    SPI_Control = (unsigned char) 0x53; // 01_1 0011

    // Ext Reg - in conjunction with control reg, sets speed above and also sets interrupt flag after every completed transfer (each byte)
    SPI_Ext = (unsigned char) 0x0; // 00__ __00

    // Status Reg - status of SPI controller chip and used to clear any write collision and interrupt on transmit complete flag
    SPI_Status = (unsigned char) 0xC0; // 1100 0000
}

/************************************************************************************
 ** Return ONLY when the SPI controller has finished transmitting a byte
 ************************************************************************************/
void WaitForSPITransmitComplete(void) {
    // Poll the status register SPIF bit looking for completion of transmission
    // Once transmission is complete, clear the write collision and interrupt on transmit complete flags in the status register (read documentation)
    // Just in case they were set
    int status_bit;
    do {
        status_bit = (SPI_Status >> 7) & 0x01;
    } while (status_bit != 1);
    SPI_Status = (unsigned char) 0xC0; // 1100 0000
}

/************************************************************************************
 ** Write a byte to the SPI flash chip via the controller and returns (reads) whatever was
 ** given back by SPI device at the same time (removes the read byte from the FIFO)
 ************************************************************************************/
unsigned char WriteSPIChar(unsigned char c) {
    // Write the byte in parameter 'c' to the SPI data register, this will start it transmitting to the flash device
    // Wait for completion of transmission
    // Return the received data from Flash chip (which may not be relevant depending upon what we are doing)
    // By reading from the SPI controller Data Register
    // Note however that in order to get data from an SPI slave device (e.g. flash) chip we have to write a dummy byte to it

    SPI_Data = c;
    WaitForSPITransmitComplete();
    return SPI_Data;
}

void EraseSPIFlashChip(void) {
    Enable_SPI_CS();
    WriteSPIChar(0x06); // Enabling the Device for Writing/Erasing
    Disable_SPI_CS();
    Enable_SPI_CS();
    WriteSPIChar(0x60); // Erasing the chip or 0x60?
    Disable_SPI_CS();
    Enable_SPI_CS();
    WriteSPIChar(0x05); // Polling for completion of commands in the Flash Memory chip
    while (WriteSPIChar(0xEE) & 1) {} // Using random data to write and test until we get an idle response back
    Disable_SPI_CS();
}

void WriteSPIFlashData(int FlashAddress, unsigned char *MemoryAddress, int size) {
    int count;
    int w_count;
    for (count = 0; count < 1000; count++) {
        Enable_SPI_CS();
        WriteSPIChar(0x06); // Enabling the Device for Writing/Erasing
        Disable_SPI_CS();
        Enable_SPI_CS();
        WriteSPIChar(0x02);
        WriteSPIChar((FlashAddress >> 16) & 0xFF);
        WriteSPIChar((FlashAddress >> 8) & 0xFF);
        WriteSPIChar(FlashAddress & 0x00);
        for (w_count = 0; w_count < 256; w_count++) {
            WriteSPIChar(*MemoryAddress);
            MemoryAddress++;
        }
        Disable_SPI_CS();
        Enable_SPI_CS();
        WriteSPIChar(0x05);
        while (WriteSPIChar(0xFF));
        Disable_SPI_CS();
        FlashAddress = FlashAddress + 256;
    }
}

void ReadSPIFlashData(int FlashAddress, unsigned char *MemoryAddress, int size) {
    Enable_SPI_CS();
    WriteSPIChar(0x03);
    WriteSPIChar((FlashAddress >> 16) & 0xFF);
    WriteSPIChar((FlashAddress >> 8) & 0xFF);
    WriteSPIChar(FlashAddress & 0xFF);
    unsigned char value = WriteSPIChar(0xFF);
    Disable_SPI_CS();
}

unsigned char ReadSPIFlashByte(int FlashAddress) {
    Enable_SPI_CS();
    WriteSPIChar(0x03);
    WriteSPIChar((FlashAddress >> 16) & 0xFF);
    WriteSPIChar((FlashAddress >> 8) & 0xFF);
    WriteSPIChar(FlashAddress & 0xFF);
    unsigned char value = WriteSPIChar(0xFF);
    Disable_SPI_CS();
    return value;
}


