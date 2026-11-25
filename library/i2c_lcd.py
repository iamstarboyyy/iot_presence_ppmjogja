from lcd_api import LcdApi
from machine import I2C
from time import sleep_ms

class I2cLcd(LcdApi):
    MASK_RS = 0x01
    MASK_RW = 0x02
    MASK_E = 0x04
    SHIFT_BACKLIGHT = 3

    def __init__(self, i2c, i2c_addr, num_lines, num_columns):
        self.i2c = i2c
        self.i2c_addr = i2c_addr
        self.num_lines = num_lines
        self.num_columns = num_columns
        self.backlight = 1
        self._write_byte(0)
        self.init_lcd()

    def _write_byte(self, data):
        self.i2c.writeto(self.i2c_addr, bytes([data | (self.backlight << self.SHIFT_BACKLIGHT)]))

    def hal_write_command(self, cmd):
        self._write_nibble(cmd >> 4)
        self._write_nibble(cmd & 0x0F)
        if cmd <= 3:
            sleep_ms(5)

    def hal_write_data(self, data):
        self._write_nibble(data >> 4, True)
        self._write_nibble(data & 0x0F, True)

    def _write_nibble(self, nibble, rs=False):
        data = (nibble << 4) | (self.MASK_RS if rs else 0)
        self._strobe(data)

    def _strobe(self, data):
        self._write_byte(data | self.MASK_E)
        sleep_ms(1)
        self._write_byte(data & ~self.MASK_E)
        sleep_ms(1)

    def init_lcd(self):
        sleep_ms(20)
        self.hal_write_command(0x33)
        self.hal_write_command(0x32)
        self.hal_write_command(0x28)
        self.hal_write_command(0x0C)
        self.hal_write_command(0x06)
        self.hal_write_command(0x01)
        
    def move_to(self, col, row):
        """Pindahkan posisi kursor ke kolom dan baris tertentu (0-index)."""
        row_offsets = [0x00, 0x40, 0x14, 0x54]
        if row > self.num_lines:
            row = self.num_lines - 1
        self.hal_write_command(0x80 | (col + row_offsets[row]))
