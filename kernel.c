#include <stdint.h>

void kernel_entry(void) {
    volatile uint16_t* vga = (volatile uint16_t*)0xB8000;
    for (int i = 0; i < 80 * 25; i++) {
        vga[i] = (0x07 << 8) | ' '; // clear screen
    }

    const char* msg = "GooberOSx64 Booted!";
    for (int i = 0; msg[i] != 0; i++) {
        vga[i] = (0x07 << 8) | msg[i];
    }

    while (1) {
        __asm__ volatile ("hlt");
    }
}
