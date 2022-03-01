**Data Shifting Command**

- Bit 0 : -ve CLK on write
- Bit 1 : bit mode = 1 else byte mode
- Bit 2 : -ve CLK on read
- Bit 3 : LSB first = 1 else MSB first
- Bit 4 : Do write TDI
- Bit 5 : Do read TDO
- Bit 6 : Do writeTMS
- Bit 7 : 0

**MSB**

|OPCODE |Data IN |Data OUT |BIT/BYTE | IN EDGE |OUT EDGE |
|--     |--      |--       |--       |--       |--       |
|0x10   | -      | YES     | BYTES   | -       | +VE     |
|0x11   |-       | YES     | BYTES   | -       | -VE     |
|0x12   |-       | YES     | BITS    | -       | +VE     |
|0x13   |-       | YES     | BITS    | -       | -VE     |
|0x20   |YES     | -       | BYTES   | +VE     | -       |
|0x24   |YES     | -       | BYTES   | -VE     | -       |
|0x22   |YES     | -       | BITS    | +VE     | -       |
|0x26   |YES     | -       | BITS    | -VE     | -       |
|0x31   |YES     | YES     | BYTES   | +VE     | -VE     |
|0x34   |YES     | YES     | BYTES   | -VE     | +VE     |
|0x33   |YES     | YES     | BITS    | +VE     | -VE     |
|0x36   |YES     | YES     | BITS    | -VE     | +VE     |

**LSB**

|OPCODE |Data IN |Data OUT |BIT/BYTE |IN EDGE |OUT EDGE |
|--     |--      |--       |--       |--      |--       |
|0x18   | -      | YES     | BYTES   | -      | +VE     |
|0x19   | -      | YES     | BYTES   | -      | -VE     |
|0x1A   | -      | YES     | BITS    | -      | +VE     |
|0x1B   | -      | YES     | BITS    | -      | -VE     |
|0x28   | YES    | -       | BYTES   | +VE    | -       |
|0x2C   | YES    | -       | BYTES   | -VE    | -       |
|0x2A   | YES    | -       | BITS    | +VE    | -       |
|0x2E   | YES    | -       | BITS    | -VE    | -       |
|0x39   | YES    | YES     | BYTES   | +VE    | -VE     |
|0x3C   | YES    | YES     | BYTES   | -VE    | +VE     |
|0x3B   | YES    | YES     | BITS    | +VE    | -VE     |
|0x3E   | YES    | YES     | BITS    | -VE    | +VE     |

**TMS COMMANDS**

|OPCODE |Data IN |Data OUT |IN EDGE |OUT EDGE |
|--     |--      |--       |--      |--       |
|0x4A   | -      | YES     | -      | +VE     |
|0x4B   | -      | YES     | -      | -VE     |
|0x6A   | YES    | YES     | +VE    | +VE     |
|0x6B   | YES    | YES     | -VE    | +VE     |
|0x6E   | YES    | YES     | +VE    | -VE     |
|0x6F   | YES    | YES     | -VE    | -VE     |

**Set/Read Data Bits High/Low Bytes**

|OPCODE |Set O/P |Read I/P |High Byte |Low Byte |
|--     |--      |--       |--        |--       |
|0x80   |YES     | -       | -        | YES     |
|0x82   |YES     | -       | YES      | -       |
|0x81   |-       | YES     | -        | YES     |
|0x83   |-       | YES     | YES      | -       |

**Loopback Commands**

|OPCODE |Loopback Enabled |
|--     |--               |
|0x84   | YES             |
|0x85   | NO              |


**Clock Divisor**
Set TCK/SK Divisor (FT2232D)
0x86,
0xValueL,
0xValueH

Set clk divisor (FT232H/FT2232H/FT4232H)
0x86,
0xValueL,
0xValueH,

**Instructions for CPU mode**

|OPCODE |Write |Read |Short Address |Extended Address |
|--     |--    |--   |--            |--               |
|0x90   |-     | YES | YES          | -               |
|0x91   |-     | YES | -            | YES             |
|0x92   |YES   | -   | YES          | -               |
|0x93   |YES   | -   | -            | YES             |


**Instructions for use in both MPSSE and MCU Host Emulation Modes**

|OPCODE |Function         |
|--     |--               |
|0x87   | Send Immediate  |
|0x88   | Wait On I/O High|
|0x89   | Wait On I/O Low |

**FT232H, FT2232H & FT4232H ONLY**

|OPCODE |Function |
|--     |--       |
|0x8A   |Disables the clk divide by 5 to allow for a 60MHz master clock.|
|0x8B   |Enables the clk divide by 5 to allow for backward compatibility with FT2232D|
|0x8C   |Enables 3 phase data clocking. Used by I2C interfaces to allow data on both clock edges.|
|0x8D   |Disables 3 phase data clocking.|
|0x8E   |Allows for a clock to be output without transferring data. Commonly used in the JTAG state machine. Clocks counted in terms of numbers of bit.|
|0x8F   |Allows for a clock to be output without transferring data. Commonly used in the JTAG state machine. Clocks countedin terms of numbers of bytes|
|0x94   |Allows for a clock to be output without transferring data until a logic 1 input on GPIOL1 stops the clock.|
|0x95   |Allows for a clock to be output without transferring data until a logic 0 input on GPIOL1 stops the clock.|
|0x96   |Enable adaptive clocking|
|0x97   |Disable adaptive clocking|
|0x9C   |Allows for a clock to be output without transferring data until a logic 1 input on GPIOL1 stops the clock or a set number of clock pulses are sent. Clocks counted in terms of numbers of bytes|
|0x9D   |Allows for a clock to be output without transferring data until a logic 0 input on GPIOL1 stops the clock or a setnumber of clock pulses are sent. Clocks counted in terms of numbers of bytes|

**FT232H ONLY**
Set I/O to only drive on a ‘0’ and tristate on a ‘1’
0x9E
LowByteEnablesForOnlyDrive0
HighByteEnablesForOnlyDrive0


## 调试笔记
usb2.0 fs 64字节一包，
指令里可能有需要操作回复的，导致必须处理完才能收下一包

4b, TMS bit输出
1b, 输出bits
6b, TMS bit输入输出
19, 输出bytes数据

修改后两包间的时间间隔已经在15~40us, 但是还是烧录失败

xpage时序详见UG290手册（FPGA产品编程配置手册）
表5-8写明了JTAG TCK要求，1~5MHz


4b 03 03 
1b 06 15 
6b 00 01 
4b 01 01 
4b 05 00 
4b 03 03 
1b 06 71 
6b 00 01 
4b 01 01 
4b 05 00 
19 26 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
4b 02 01 
