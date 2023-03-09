#include <lunaix/tty/tty.h>
#include <stdint.h>

vga_attribute *vga_buffer = (vga_attribute *)0xB8000;
vga_attribute TTY_COLOR = VGA_COLOR_BLACK;

uint32_t TTY_X = 0;
uint16_t TTY_Y = 0;

void tty_init();

void tty_put_char(char c) {
  switch (c) {
    case '\n':
      TTY_X = 0;
      TTY_Y++;
      break;

    case '\t':
      TTY_X += 4;
      break;

    case '\r':
      TTY_X = 0;
      break;

    default:
      *(vga_buffer + TTY_X + TTY_Y * TTY_WIDTH) = c | TTY_COLOR;
      TTY_X++;
      break;
  }

  if (TTY_X >= TTY_WIDTH) {
	TTY_X = 0;
	TTY_Y++;
  }
  if (TTY_Y >= TTY_HEIGHT) {
    tty_scroll_up();
    TTY_Y = TTY_HEIGHT - 1;
  }
}

void tty_put_string(const char *s) {
  while (*s) {
    tty_put_char(*s++);
  }
}

void tty_scroll_up() {
  // TODO: use memcopy
}

void tty_scroll_down();

void tty_clear_screen() {
  for (uint32_t i = 0; i < TTY_WIDTH * TTY_HEIGHT; i++) {
    *(vga_buffer + i) = TTY_COLOR;
  }
}
void tty_set_color(vga_attribute foreground, vga_attribute background) {
  TTY_COLOR = (background << 4 | foreground) << 8;
}