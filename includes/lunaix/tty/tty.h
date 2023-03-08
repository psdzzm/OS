#ifndef TTY_H
#define TTY_H

#include <stdint.h>

#define VGA_COLOR_BLACK 0
#define VGA_COLOR_BLUE 1
#define VGA_COLOR_GREEN 2
#define VGA_COLOR_CYAN 3
#define VGA_COLOR_RED 4
#define VGA_COLOR_MAGENTA 5
#define VGA_COLOR_BROWN 6
#define VGA_COLOR_DARK_GREY 8
#define VGA_COLOR_LIGHT_GREY 7
#define VGA_COLOR_LIGHT_BLUE 9
#define VGA_COLOR_LIGHT_GREEN 10
#define VGA_COLOR_LIGHT_CYAN 11
#define VGA_COLOR_LIGHT_RED 12
#define VGA_COLOR_LIGHT_MAGENTA 13
#define VGA_COLOR_LIGHT_BROWN 14
#define VGA_COLOR_WHITE 15

#define TTY_WIDTH 80
#define TTY_HEIGHT 25

typedef unsigned short vga_attribute;

void tty_init();
void tty_put_char(char c);
void tty_put_string(const char *s);
void tty_scroll_up();
void tty_scroll_down();
void tty_clear_screen();
void tty_set_color(vga_attribute foreground, vga_attribute background);

#endif