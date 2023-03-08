#include <lunaix/tty/tty.h>
#include <stdint.h>

void _kernel_init() {
    // TODO: init tty
}

void _kernel_main() {
    // TODO:
    tty_set_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    tty_put_string("Hello, world!\n");
}