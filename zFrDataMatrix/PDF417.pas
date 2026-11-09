unit PDF417;
{
  RPDF417
  Copyright (C)

  java4less@Confluencia.net
  All rights reserved

 Adquisition , use and distribution of this code is subject to restriction:
  - You may modify the source code in order to adapt it to your needs.
  - Redistribution of this ( or a modified version) source code is prohibited. You may only redistribute compiled versions.
  - You may redistribute the compiled version as part of your application, not a new component with the same purpose as this one.
  - You may not remove this notice from the source code
  - This notice disclaim all warranties of all material

}

interface

uses
  WinProcs,
  WinTypes,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Dialogs,
  Controls,
  Math; //,QuickRpt;

const
  PDF417_START: Integer = $1FEA8;
const
  PDF417_STOP: Integer = $1FD14;

type
  TVector = array of integer;

type
  TByteVector = array of byte;

type

  {encoding types}
  TEncoding = (PDF_BINARY, PDF_TEXT, PDF_NUMERIC);

  { PDF417 text mode character set }
const
  textCodes: array[0..94, 0..1] of string = ((' ', 'C26'),
    ('!', 'D10'),
    ('\', 'D5'),
    ('#', 'C15'),
    ('$', 'C18'),
    ('%', 'C21'),
    ('&', 'C10'),
    ('''', 'D28'),
    ('(', 'D23'),
    (')', 'D24'),
    ('*', 'C22'),
    ('+', 'C20'),
    (',', 'C13'),
    ('-', 'C16'),
    ('.', 'C17'),
    ('/', 'C19'),
    ('0', 'C0'),
    ('1', 'C1'),
    ('2', 'C2'),
    ('3', 'C3'),
    ('4', 'C4'),
    ('5', 'C5'),
    ('6', 'C6'),
    ('7', 'C7'),
    ('8', 'C8'),
    ('9', 'C9'),
    (':', 'C14'),
    (';', 'D0'),
    ('<', 'D1'),
    ('=', 'C23'),
    ('>', 'D2'),
    ('?', 'D25'),
    ('@', 'D3'),
    ('A', 'A0'),
    ('B', 'A1'),
    ('C', 'A2'),
    ('D', 'A3'),
    ('E', 'A4'),
    ('F', 'A5'),
    ('G', 'A6'),
    ('H', 'A7'),
    ('I', 'A8'),
    ('J', 'A9'),
    ('K', 'A10'),
    ('L', 'A11'),
    ('M', 'A12'),
    ('N', 'A13'),
    ('O', 'A14'),
    ('P', 'A15'),
    ('Q', 'A16'),
    ('R', 'A17'),
    ('S', 'A18'),
    ('T', 'A19'),
    ('U', 'A20'),
    ('V', 'A21'),
    ('W', 'A22'),
    ('X', 'A23'),
    ('Y', 'A24'),
    ('Z', 'A25'),
    ('[', 'D4'),
    ('"', 'D20'),
    (']', 'D6'),
    ('^', 'C24'),
    ('_', 'D7'),
    ('`', 'D8'),
    ('a', 'B0'),
    ('b', 'B1'),
    ('c', 'B2'),
    ('d', 'B3'),
    ('e', 'B4'),
    ('f', 'B5'),
    ('g', 'B6'),
    ('h', 'B7'),
    ('i', 'B8'),
    ('j', 'B9'),
    ('k', 'B10'),
    ('l', 'B11'),
    ('m', 'B12'),
    ('n', 'B13'),
    ('o', 'B14'),
    ('p', 'B15'),
    ('q', 'B16'),
    ('r', 'B17'),
    ('s', 'B18'),
    ('t', 'B19'),
    ('u', 'B20'),
    ('v', 'B21'),
    ('w', 'B22'),
    ('x', 'B23'),
    ('y', 'B24'),
    ('z', 'B25'),
    ('{', 'D26'),
    ('|', 'D21'),
    ('}', 'D27'),
    ('~', 'D9'));

  { PDF417 error correction coeficients }
const
  coef0: array[0..1] of Integer = (27, 917);
const
  coef1: array[0..3] of Integer = (522, 568, 723, 809);
const
  coef2: array[0..7] of Integer = (237, 308, 436, 284, 646, 653, 428, 379);
const
  coef3: array[0..15] of Integer = (274, 562, 232, 755, 599, 524, 801, 132, 295, 116, 442, 428, 295, 42, 176, 65);
const
  coef4: array[0..31] of Integer = (361, 575, 922, 525, 176, 586, 640, 321, 536, 742, 677, 742, 687, 284, 193, 517,
    273, 494, 263, 147, 593, 800, 571, 320, 803, 133, 231, 390, 685, 330, 63, 410);
const
  coef5: array[0..63] of Integer = (539, 422, 6, 93, 862, 771, 453, 106, 610, 287, 107, 505, 733, 877, 381, 612,
    723, 476, 462, 172, 430, 609, 858, 822, 543, 376, 511, 400, 672, 762, 283, 184,
    440, 35, 519, 31, 460, 594, 225, 535, 517, 352, 605, 158, 651, 201, 488, 502,
    648, 733, 717, 83, 404, 97, 280, 771, 840, 629, 4, 381, 843, 623, 264, 543);
const
  coef6: array[0..127] of Integer = (521, 310, 864, 547, 858, 580, 296, 379, 53, 779, 897, 444, 400, 925, 749, 415,
    822, 93, 217, 208, 928, 244, 583, 620, 246, 148, 447, 631, 292, 908, 490, 704,
    516, 258, 457, 907, 594, 723, 674, 292, 272, 96, 684, 432, 686, 606, 860, 569,
    193, 219, 129, 186, 236, 287, 192, 775, 278, 173, 40, 379, 712, 463, 646, 776,
    171, 491, 297, 763, 156, 732, 95, 270, 447, 90, 507, 48, 228, 821, 808, 898,
    784, 663, 627, 378, 382, 262, 380, 602, 754, 336, 89, 614, 87, 432, 670, 616,
    157, 374, 242, 726, 600, 269, 375, 898, 845, 454, 354, 130, 814, 587, 804, 34,
    211, 330, 539, 297, 827, 865, 37, 517, 834, 315, 550, 86, 801, 4, 108, 539);
const
  coef7: array[0..255] of Integer = (524, 894, 75, 766, 882, 857, 74, 204, 82, 586, 708, 250, 905, 786, 138, 720,
    858, 194, 311, 913, 275, 190, 375, 850, 438, 733, 194, 280, 201, 280, 828, 757,
    710, 814, 919, 89, 68, 569, 11, 204, 796, 605, 540, 913, 801, 700, 799, 137,
    439, 418, 592, 668, 353, 859, 370, 694, 325, 240, 216, 257, 284, 549, 209, 884,
    315, 70, 329, 793, 490, 274, 877, 162, 749, 812, 684, 461, 334, 376, 849, 521,
    307, 291, 803, 712, 19, 358, 399, 908, 103, 511, 51, 8, 517, 225, 289, 470,
    637, 731, 66, 255, 917, 269, 463, 830, 730, 433, 848, 585, 136, 538, 906, 90,
    2, 290, 743, 199, 655, 903, 329, 49, 802, 580, 355, 588, 188, 462, 10, 134,
    628, 320, 479, 130, 739, 71, 263, 318, 374, 601, 192, 605, 142, 673, 687, 234,
    722, 384, 177, 752, 607, 640, 455, 193, 689, 707, 805, 641, 48, 60, 732, 621,
    895, 544, 261, 852, 655, 309, 697, 755, 756, 60, 231, 773, 434, 421, 726, 528,
    503, 118, 49, 795, 32, 144, 500, 238, 836, 394, 280, 566, 319, 9, 647, 550,
    73, 914, 342, 126, 32, 681, 331, 792, 620, 60, 609, 441, 180, 791, 893, 754,
    605, 383, 228, 749, 760, 213, 54, 297, 134, 54, 834, 299, 922, 191, 910, 532,
    609, 829, 189, 20, 167, 29, 872, 449, 83, 402, 41, 656, 505, 579, 481, 173,
    404, 251, 688, 95, 497, 555, 642, 543, 307, 159, 924, 558, 648, 55, 497, 10);
const
  coef8: array[0..511] of Integer = (352, 77, 373, 504, 35, 599, 428, 207, 409, 574, 118, 498, 285, 380, 350, 492,
    197, 265, 920, 155, 914, 299, 229, 643, 294, 871, 306, 88, 87, 193, 352, 781,
    846, 75, 327, 520, 435, 543, 203, 666, 249, 346, 781, 621, 640, 268, 794, 534,
    539, 781, 408, 390, 644, 102, 476, 499, 290, 632, 545, 37, 858, 916, 552, 41,
    542, 289, 122, 272, 383, 800, 485, 98, 752, 472, 761, 107, 784, 860, 658, 741,
    290, 204, 681, 407, 855, 85, 99, 62, 482, 180, 20, 297, 451, 593, 913, 142,
    808, 684, 287, 536, 561, 76, 653, 899, 729, 567, 744, 390, 513, 192, 516, 258,
    240, 518, 794, 395, 768, 848, 51, 610, 384, 168, 190, 826, 328, 596, 786, 303,
    570, 381, 415, 641, 156, 237, 151, 429, 531, 207, 676, 710, 89, 168, 304, 402,
    40, 708, 575, 162, 864, 229, 65, 861, 841, 512, 164, 477, 221, 92, 358, 785,
    288, 357, 850, 836, 827, 736, 707, 94, 8, 494, 114, 521, 2, 499, 851, 543,
    152, 729, 771, 95, 248, 361, 578, 323, 856, 797, 289, 51, 684, 466, 533, 820,
    669, 45, 902, 452, 167, 342, 244, 173, 35, 463, 651, 51, 699, 591, 452, 578,
    37, 124, 298, 332, 552, 43, 427, 119, 662, 777, 475, 850, 764, 364, 578, 911,
    283, 711, 472, 420, 245, 288, 594, 394, 511, 327, 589, 777, 699, 688, 43, 408,
    842, 383, 721, 521, 560, 644, 714, 559, 62, 145, 873, 663, 713, 159, 672, 729,
    624, 59, 193, 417, 158, 209, 563, 564, 343, 693, 109, 608, 563, 365, 181, 772,
    677, 310, 248, 353, 708, 410, 579, 870, 617, 841, 632, 860, 289, 536, 35, 777,
    618, 586, 424, 833, 77, 597, 346, 269, 757, 632, 695, 751, 331, 247, 184, 45,
    787, 680, 18, 66, 407, 369, 54, 492, 228, 613, 830, 922, 437, 519, 644, 905,
    789, 420, 305, 441, 207, 300, 892, 827, 141, 537, 381, 662, 513, 56, 252, 341,
    242, 797, 838, 837, 720, 224, 307, 631, 61, 87, 560, 310, 756, 665, 397, 808,
    851, 309, 473, 795, 378, 31, 647, 915, 459, 806, 590, 731, 425, 216, 548, 249,
    321, 881, 699, 535, 673, 782, 210, 815, 905, 303, 843, 922, 281, 73, 469, 791,
    660, 162, 498, 308, 155, 422, 907, 817, 187, 62, 16, 425, 535, 336, 286, 437,
    375, 273, 610, 296, 183, 923, 116, 667, 751, 353, 62, 366, 691, 379, 687, 842,
    37, 357, 720, 742, 330, 5, 39, 923, 311, 424, 242, 749, 321, 54, 669, 316,
    342, 299, 534, 105, 667, 488, 640, 672, 576, 540, 316, 486, 721, 610, 46, 656,
    447, 171, 616, 464, 190, 531, 297, 321, 762, 752, 533, 175, 134, 14, 381, 433,
    717, 45, 111, 20, 596, 284, 736, 138, 646, 411, 877, 669, 141, 919, 45, 780,
    407, 164, 332, 899, 165, 726, 600, 325, 498, 655, 357, 752, 768, 223, 849, 647,
    63, 310, 863, 251, 366, 304, 282, 738, 675, 410, 389, 244, 31, 121, 303, 263);

  { PDF417 bar patterns }
const
  PDF417_BITS: array[0..2, 0..928] of Integer = ((
    $1D5C0, $1EAF0, $1F57C, $1D4E0,
    $1EA78, $1F53E, $1A8C0, $1D470,
    $1A860, $15040, $1A830, $15020,
    $1ADC0, $1D6F0, $1EB7C, $1ACE0,
    $1D678, $1EB3E, $158C0, $1AC70,
    $15860, $15DC0, $1AEF0, $1D77C,
    $15CE0, $1AE78, $1D73E, $15C70,
    $1AE3C, $15EF0, $1AF7C, $15E78,
    $1AF3E, $15F7C, $1F5FA, $1D2E0,
    $1E978, $1F4BE, $1A4C0, $1D270,
    $1E93C, $1A460, $1D238, $14840,
    $1A430, $1D21C, $14820, $1A418,
    $14810, $1A6E0, $1D378, $1E9BE,
    $14CC0, $1A670, $1D33C, $14C60,
    $1A638, $1D31E, $14C30, $1A61C,
    $14EE0, $1A778, $1D3BE, $14E70,
    $1A73C, $14E38, $1A71E, $14F78,
    $1A7BE, $14F3C, $14F1E, $1A2C0,
    $1D170, $1E8BC, $1A260, $1D138,
    $1E89E, $14440, $1A230, $1D11C,
    $14420, $1A218, $14410, $14408,
    $146C0, $1A370, $1D1BC, $14660,
    $1A338, $1D19E, $14630, $1A31C,
    $14618, $1460C, $14770, $1A3BC,
    $14738, $1A39E, $1471C, $147BC,
    $1A160, $1D0B8, $1E85E, $14240,
    $1A130, $1D09C, $14220, $1A118,
    $1D08E, $14210, $1A10C, $14208,
    $1A106, $14360, $1A1B8, $1D0DE,
    $14330, $1A19C, $14318, $1A18E,
    $1430C, $14306, $1A1DE, $1438E,
    $14140, $1A0B0, $1D05C, $14120,
    $1A098, $1D04E, $14110, $1A08C,
    $14108, $1A086, $14104, $141B0,
    $14198, $1418C, $140A0, $1D02E,
    $1A04C, $1A046, $14082, $1CAE0,
    $1E578, $1F2BE, $194C0, $1CA70,
    $1E53C, $19460, $1CA38, $1E51E,
    $12840, $19430, $12820, $196E0,
    $1CB78, $1E5BE, $12CC0, $19670,
    $1CB3C, $12C60, $19638, $12C30,
    $12C18, $12EE0, $19778, $1CBBE,
    $12E70, $1973C, $12E38, $12E1C,
    $12F78, $197BE, $12F3C, $12FBE,
    $1DAC0, $1ED70, $1F6BC, $1DA60,
    $1ED38, $1F69E, $1B440, $1DA30,
    $1ED1C, $1B420, $1DA18, $1ED0E,
    $1B410, $1DA0C, $192C0, $1C970,
    $1E4BC, $1B6C0, $19260, $1C938,
    $1E49E, $1B660, $1DB38, $1ED9E,
    $16C40, $12420, $19218, $1C90E,
    $16C20, $1B618, $16C10, $126C0,
    $19370, $1C9BC, $16EC0, $12660,
    $19338, $1C99E, $16E60, $1B738,
    $1DB9E, $16E30, $12618, $16E18,
    $12770, $193BC, $16F70, $12738,
    $1939E, $16F38, $1B79E, $16F1C,
    $127BC, $16FBC, $1279E, $16F9E,
    $1D960, $1ECB8, $1F65E, $1B240,
    $1D930, $1EC9C, $1B220, $1D918,
    $1EC8E, $1B210, $1D90C, $1B208,
    $1B204, $19160, $1C8B8, $1E45E,
    $1B360, $19130, $1C89C, $16640,
    $12220, $1D99C, $1C88E, $16620,
    $12210, $1910C, $16610, $1B30C,
    $19106, $12204, $12360, $191B8,
    $1C8DE, $16760, $12330, $1919C,
    $16730, $1B39C, $1918E, $16718,
    $1230C, $12306, $123B8, $191DE,
    $167B8, $1239C, $1679C, $1238E,
    $1678E, $167DE, $1B140, $1D8B0,
    $1EC5C, $1B120, $1D898, $1EC4E,
    $1B110, $1D88C, $1B108, $1D886,
    $1B104, $1B102, $12140, $190B0,
    $1C85C, $16340, $12120, $19098,
    $1C84E, $16320, $1B198, $1D8CE,
    $16310, $12108, $19086, $16308,
    $1B186, $16304, $121B0, $190DC,
    $163B0, $12198, $190CE, $16398,
    $1B1CE, $1638C, $12186, $16386,
    $163DC, $163CE, $1B0A0, $1D858,
    $1EC2E, $1B090, $1D84C, $1B088,
    $1D846, $1B084, $1B082, $120A0,
    $19058, $1C82E, $161A0, $12090,
    $1904C, $16190, $1B0CC, $19046,
    $16188, $12084, $16184, $12082,
    $120D8, $161D8, $161CC, $161C6,
    $1D82C, $1D826, $1B042, $1902C,
    $12048, $160C8, $160C4, $160C2,
    $18AC0, $1C570, $1E2BC, $18A60,
    $1C538, $11440, $18A30, $1C51C,
    $11420, $18A18, $11410, $11408,
    $116C0, $18B70, $1C5BC, $11660,
    $18B38, $1C59E, $11630, $18B1C,
    $11618, $1160C, $11770, $18BBC,
    $11738, $18B9E, $1171C, $117BC,
    $1179E, $1CD60, $1E6B8, $1F35E,
    $19A40, $1CD30, $1E69C, $19A20,
    $1CD18, $1E68E, $19A10, $1CD0C,
    $19A08, $1CD06, $18960, $1C4B8,
    $1E25E, $19B60, $18930, $1C49C,
    $13640, $11220, $1CD9C, $1C48E,
    $13620, $19B18, $1890C, $13610,
    $11208, $13608, $11360, $189B8,
    $1C4DE, $13760, $11330, $1CDDE,
    $13730, $19B9C, $1898E, $13718,
    $1130C, $1370C, $113B8, $189DE,
    $137B8, $1139C, $1379C, $1138E,
    $113DE, $137DE, $1DD40, $1EEB0,
    $1F75C, $1DD20, $1EE98, $1F74E,
    $1DD10, $1EE8C, $1DD08, $1EE86,
    $1DD04, $19940, $1CCB0, $1E65C,
    $1BB40, $19920, $1EEDC, $1E64E,
    $1BB20, $1DD98, $1EECE, $1BB10,
    $19908, $1CC86, $1BB08, $1DD86,
    $19902, $11140, $188B0, $1C45C,
    $13340, $11120, $18898, $1C44E,
    $17740, $13320, $19998, $1CCCE,
    $17720, $1BB98, $1DDCE, $18886,
    $17710, $13308, $19986, $17708,
    $11102, $111B0, $188DC, $133B0,
    $11198, $188CE, $177B0, $13398,
    $199CE, $17798, $1BBCE, $11186,
    $13386, $111DC, $133DC, $111CE,
    $177DC, $133CE, $1DCA0, $1EE58,
    $1F72E, $1DC90, $1EE4C, $1DC88,
    $1EE46, $1DC84, $1DC82, $198A0,
    $1CC58, $1E62E, $1B9A0, $19890,
    $1EE6E, $1B990, $1DCCC, $1CC46,
    $1B988, $19884, $1B984, $19882,
    $1B982, $110A0, $18858, $1C42E,
    $131A0, $11090, $1884C, $173A0,
    $13190, $198CC, $18846, $17390,
    $1B9CC, $11084, $17388, $13184,
    $11082, $13182, $110D8, $1886E,
    $131D8, $110CC, $173D8, $131CC,
    $110C6, $173CC, $131C6, $110EE,
    $173EE, $1DC50, $1EE2C, $1DC48,
    $1EE26, $1DC44, $1DC42, $19850,
    $1CC2C, $1B8D0, $19848, $1CC26,
    $1B8C8, $1DC66, $1B8C4, $19842,
    $1B8C2, $11050, $1882C, $130D0,
    $11048, $18826, $171D0, $130C8,
    $19866, $171C8, $1B8E6, $11042,
    $171C4, $130C2, $171C2, $130EC,
    $171EC, $171E6, $1EE16, $1DC22,
    $1CC16, $19824, $19822, $11028,
    $13068, $170E8, $11022, $13062,
    $18560, $10A40, $18530, $10A20,
    $18518, $1C28E, $10A10, $1850C,
    $10A08, $18506, $10B60, $185B8,
    $1C2DE, $10B30, $1859C, $10B18,
    $1858E, $10B0C, $10B06, $10BB8,
    $185DE, $10B9C, $10B8E, $10BDE,
    $18D40, $1C6B0, $1E35C, $18D20,
    $1C698, $18D10, $1C68C, $18D08,
    $1C686, $18D04, $10940, $184B0,
    $1C25C, $11B40, $10920, $1C6DC,
    $1C24E, $11B20, $18D98, $1C6CE,
    $11B10, $10908, $18486, $11B08,
    $18D86, $10902, $109B0, $184DC,
    $11BB0, $10998, $184CE, $11B98,
    $18DCE, $11B8C, $10986, $109DC,
    $11BDC, $109CE, $11BCE, $1CEA0,
    $1E758, $1F3AE, $1CE90, $1E74C,
    $1CE88, $1E746, $1CE84, $1CE82,
    $18CA0, $1C658, $19DA0, $18C90,
    $1C64C, $19D90, $1CECC, $1C646,
    $19D88, $18C84, $19D84, $18C82,
    $19D82, $108A0, $18458, $119A0,
    $10890, $1C66E, $13BA0, $11990,
    $18CCC, $18446, $13B90, $19DCC,
    $10884, $13B88, $11984, $10882,
    $11982, $108D8, $1846E, $119D8,
    $108CC, $13BD8, $119CC, $108C6,
    $13BCC, $119C6, $108EE, $119EE,
    $13BEE, $1EF50, $1F7AC, $1EF48,
    $1F7A6, $1EF44, $1EF42, $1CE50,
    $1E72C, $1DED0, $1EF6C, $1E726,
    $1DEC8, $1EF66, $1DEC4, $1CE42,
    $1DEC2, $18C50, $1C62C, $19CD0,
    $18C48, $1C626, $1BDD0, $19CC8,
    $1CE66, $1BDC8, $1DEE6, $18C42,
    $1BDC4, $19CC2, $1BDC2, $10850,
    $1842C, $118D0, $10848, $18426,
    $139D0, $118C8, $18C66, $17BD0,
    $139C8, $19CE6, $10842, $17BC8,
    $1BDE6, $118C2, $17BC4, $1086C,
    $118EC, $10866, $139EC, $118E6,
    $17BEC, $139E6, $17BE6, $1EF28,
    $1F796, $1EF24, $1EF22, $1CE28,
    $1E716, $1DE68, $1EF36, $1DE64,
    $1CE22, $1DE62, $18C28, $1C616,
    $19C68, $18C24, $1BCE8, $19C64,
    $18C22, $1BCE4, $19C62, $1BCE2,
    $10828, $18416, $11868, $18C36,
    $138E8, $11864, $10822, $179E8,
    $138E4, $11862, $179E4, $138E2,
    $179E2, $11876, $179F6, $1EF12,
    $1DE34, $1DE32, $19C34, $1BC74,
    $1BC72, $11834, $13874, $178F4,
    $178F2, $10540, $10520, $18298,
    $10510, $10508, $10504, $105B0,
    $10598, $1058C, $10586, $105DC,
    $105CE, $186A0, $18690, $1C34C,
    $18688, $1C346, $18684, $18682,
    $104A0, $18258, $10DA0, $186D8,
    $1824C, $10D90, $186CC, $10D88,
    $186C6, $10D84, $10482, $10D82,
    $104D8, $1826E, $10DD8, $186EE,
    $10DCC, $104C6, $10DC6, $104EE,
    $10DEE, $1C750, $1C748, $1C744,
    $1C742, $18650, $18ED0, $1C76C,
    $1C326, $18EC8, $1C766, $18EC4,
    $18642, $18EC2, $10450, $10CD0,
    $10448, $18226, $11DD0, $10CC8,
    $10444, $11DC8, $10CC4, $10442,
    $11DC4, $10CC2, $1046C, $10CEC,
    $10466, $11DEC, $10CE6, $11DE6,
    $1E7A8, $1E7A4, $1E7A2, $1C728,
    $1CF68, $1E7B6, $1CF64, $1C722,
    $1CF62, $18628, $1C316, $18E68,
    $1C736, $19EE8, $18E64, $18622,
    $19EE4, $18E62, $19EE2, $10428,
    $18216, $10C68, $18636, $11CE8,
    $10C64, $10422, $13DE8, $11CE4,
    $10C62, $13DE4, $11CE2, $10436,
    $10C76, $11CF6, $13DF6, $1F7D4,
    $1F7D2, $1E794, $1EFB4, $1E792,
    $1EFB2, $1C714, $1CF34, $1C712,
    $1DF74, $1CF32, $1DF72, $18614,
    $18E34, $18612, $19E74, $18E32,
    $1BEF4), (
    $1F560, $1FAB8, $1EA40, $1F530,
    $1FA9C, $1EA20, $1F518, $1FA8E,
    $1EA10, $1F50C, $1EA08, $1F506,
    $1EA04, $1EB60, $1F5B8, $1FADE,
    $1D640, $1EB30, $1F59C, $1D620,
    $1EB18, $1F58E, $1D610, $1EB0C,
    $1D608, $1EB06, $1D604, $1D760,
    $1EBB8, $1F5DE, $1AE40, $1D730,
    $1EB9C, $1AE20, $1D718, $1EB8E,
    $1AE10, $1D70C, $1AE08, $1D706,
    $1AE04, $1AF60, $1D7B8, $1EBDE,
    $15E40, $1AF30, $1D79C, $15E20,
    $1AF18, $1D78E, $15E10, $1AF0C,
    $15E08, $1AF06, $15F60, $1AFB8,
    $1D7DE, $15F30, $1AF9C, $15F18,
    $1AF8E, $15F0C, $15FB8, $1AFDE,
    $15F9C, $15F8E, $1E940, $1F4B0,
    $1FA5C, $1E920, $1F498, $1FA4E,
    $1E910, $1F48C, $1E908, $1F486,
    $1E904, $1E902, $1D340, $1E9B0,
    $1F4DC, $1D320, $1E998, $1F4CE,
    $1D310, $1E98C, $1D308, $1E986,
    $1D304, $1D302, $1A740, $1D3B0,
    $1E9DC, $1A720, $1D398, $1E9CE,
    $1A710, $1D38C, $1A708, $1D386,
    $1A704, $1A702, $14F40, $1A7B0,
    $1D3DC, $14F20, $1A798, $1D3CE,
    $14F10, $1A78C, $14F08, $1A786,
    $14F04, $14FB0, $1A7DC, $14F98,
    $1A7CE, $14F8C, $14F86, $14FDC,
    $14FCE, $1E8A0, $1F458, $1FA2E,
    $1E890, $1F44C, $1E888, $1F446,
    $1E884, $1E882, $1D1A0, $1E8D8,
    $1F46E, $1D190, $1E8CC, $1D188,
    $1E8C6, $1D184, $1D182, $1A3A0,
    $1D1D8, $1E8EE, $1A390, $1D1CC,
    $1A388, $1D1C6, $1A384, $1A382,
    $147A0, $1A3D8, $1D1EE, $14790,
    $1A3CC, $14788, $1A3C6, $14784,
    $14782, $147D8, $1A3EE, $147CC,
    $147C6, $147EE, $1E850, $1F42C,
    $1E848, $1F426, $1E844, $1E842,
    $1D0D0, $1E86C, $1D0C8, $1E866,
    $1D0C4, $1D0C2, $1A1D0, $1D0EC,
    $1A1C8, $1D0E6, $1A1C4, $1A1C2,
    $143D0, $1A1EC, $143C8, $1A1E6,
    $143C4, $143C2, $143EC, $143E6,
    $1E828, $1F416, $1E824, $1E822,
    $1D068, $1E836, $1D064, $1D062,
    $1A0E8, $1D076, $1A0E4, $1A0E2,
    $141E8, $1A0F6, $141E4, $141E2,
    $1E814, $1E812, $1D034, $1D032,
    $1A074, $1A072, $1E540, $1F2B0,
    $1F95C, $1E520, $1F298, $1F94E,
    $1E510, $1F28C, $1E508, $1F286,
    $1E504, $1E502, $1CB40, $1E5B0,
    $1F2DC, $1CB20, $1E598, $1F2CE,
    $1CB10, $1E58C, $1CB08, $1E586,
    $1CB04, $1CB02, $19740, $1CBB0,
    $1E5DC, $19720, $1CB98, $1E5CE,
    $19710, $1CB8C, $19708, $1CB86,
    $19704, $19702, $12F40, $197B0,
    $1CBDC, $12F20, $19798, $1CBCE,
    $12F10, $1978C, $12F08, $19786,
    $12F04, $12FB0, $197DC, $12F98,
    $197CE, $12F8C, $12F86, $12FDC,
    $12FCE, $1F6A0, $1FB58, $16BF0,
    $1F690, $1FB4C, $169F8, $1F688,
    $1FB46, $168FC, $1F684, $1F682,
    $1E4A0, $1F258, $1F92E, $1EDA0,
    $1E490, $1FB6E, $1ED90, $1F6CC,
    $1F246, $1ED88, $1E484, $1ED84,
    $1E482, $1ED82, $1C9A0, $1E4D8,
    $1F26E, $1DBA0, $1C990, $1E4CC,
    $1DB90, $1EDCC, $1E4C6, $1DB88,
    $1C984, $1DB84, $1C982, $1DB82,
    $193A0, $1C9D8, $1E4EE, $1B7A0,
    $19390, $1C9CC, $1B790, $1DBCC,
    $1C9C6, $1B788, $19384, $1B784,
    $19382, $1B782, $127A0, $193D8,
    $1C9EE, $16FA0, $12790, $193CC,
    $16F90, $1B7CC, $193C6, $16F88,
    $12784, $16F84, $12782, $127D8,
    $193EE, $16FD8, $127CC, $16FCC,
    $127C6, $16FC6, $127EE, $1F650,
    $1FB2C, $165F8, $1F648, $1FB26,
    $164FC, $1F644, $1647E, $1F642,
    $1E450, $1F22C, $1ECD0, $1E448,
    $1F226, $1ECC8, $1F666, $1ECC4,
    $1E442, $1ECC2, $1C8D0, $1E46C,
    $1D9D0, $1C8C8, $1E466, $1D9C8,
    $1ECE6, $1D9C4, $1C8C2, $1D9C2,
    $191D0, $1C8EC, $1B3D0, $191C8,
    $1C8E6, $1B3C8, $1D9E6, $1B3C4,
    $191C2, $1B3C2, $123D0, $191EC,
    $167D0, $123C8, $191E6, $167C8,
    $1B3E6, $167C4, $123C2, $167C2,
    $123EC, $167EC, $123E6, $167E6,
    $1F628, $1FB16, $162FC, $1F624,
    $1627E, $1F622, $1E428, $1F216,
    $1EC68, $1F636, $1EC64, $1E422,
    $1EC62, $1C868, $1E436, $1D8E8,
    $1C864, $1D8E4, $1C862, $1D8E2,
    $190E8, $1C876, $1B1E8, $1D8F6,
    $1B1E4, $190E2, $1B1E2, $121E8,
    $190F6, $163E8, $121E4, $163E4,
    $121E2, $163E2, $121F6, $163F6,
    $1F614, $1617E, $1F612, $1E414,
    $1EC34, $1E412, $1EC32, $1C834,
    $1D874, $1C832, $1D872, $19074,
    $1B0F4, $19072, $1B0F2, $120F4,
    $161F4, $120F2, $161F2, $1F60A,
    $1E40A, $1EC1A, $1C81A, $1D83A,
    $1903A, $1B07A, $1E2A0, $1F158,
    $1F8AE, $1E290, $1F14C, $1E288,
    $1F146, $1E284, $1E282, $1C5A0,
    $1E2D8, $1F16E, $1C590, $1E2CC,
    $1C588, $1E2C6, $1C584, $1C582,
    $18BA0, $1C5D8, $1E2EE, $18B90,
    $1C5CC, $18B88, $1C5C6, $18B84,
    $18B82, $117A0, $18BD8, $1C5EE,
    $11790, $18BCC, $11788, $18BC6,
    $11784, $11782, $117D8, $18BEE,
    $117CC, $117C6, $117EE, $1F350,
    $1F9AC, $135F8, $1F348, $1F9A6,
    $134FC, $1F344, $1347E, $1F342,
    $1E250, $1F12C, $1E6D0, $1E248,
    $1F126, $1E6C8, $1F366, $1E6C4,
    $1E242, $1E6C2, $1C4D0, $1E26C,
    $1CDD0, $1C4C8, $1E266, $1CDC8,
    $1E6E6, $1CDC4, $1C4C2, $1CDC2,
    $189D0, $1C4EC, $19BD0, $189C8,
    $1C4E6, $19BC8, $1CDE6, $19BC4,
    $189C2, $19BC2, $113D0, $189EC,
    $137D0, $113C8, $189E6, $137C8,
    $19BE6, $137C4, $113C2, $137C2,
    $113EC, $137EC, $113E6, $137E6,
    $1FBA8, $175F0, $1BAFC, $1FBA4,
    $174F8, $1BA7E, $1FBA2, $1747C,
    $1743E, $1F328, $1F996, $132FC,
    $1F768, $1FBB6, $176FC, $1327E,
    $1F764, $1F322, $1767E, $1F762,
    $1E228, $1F116, $1E668, $1E224,
    $1EEE8, $1F776, $1E222, $1EEE4,
    $1E662, $1EEE2, $1C468, $1E236,
    $1CCE8, $1C464, $1DDE8, $1CCE4,
    $1C462, $1DDE4, $1CCE2, $1DDE2,
    $188E8, $1C476, $199E8, $188E4,
    $1BBE8, $199E4, $188E2, $1BBE4,
    $199E2, $1BBE2, $111E8, $188F6,
    $133E8, $111E4, $177E8, $133E4,
    $111E2, $177E4, $133E2, $177E2,
    $111F6, $133F6, $1FB94, $172F8,
    $1B97E, $1FB92, $1727C, $1723E,
    $1F314, $1317E, $1F734, $1F312,
    $1737E, $1F732, $1E214, $1E634,
    $1E212, $1EE74, $1E632, $1EE72,
    $1C434, $1CC74, $1C432, $1DCF4,
    $1CC72, $1DCF2, $18874, $198F4,
    $18872, $1B9F4, $198F2, $1B9F2,
    $110F4, $131F4, $110F2, $173F4,
    $131F2, $173F2, $1FB8A, $1717C,
    $1713E, $1F30A, $1F71A, $1E20A,
    $1E61A, $1EE3A, $1C41A, $1CC3A,
    $1DC7A, $1883A, $1987A, $1B8FA,
    $1107A, $130FA, $171FA, $170BE,
    $1E150, $1F0AC, $1E148, $1F0A6,
    $1E144, $1E142, $1C2D0, $1E16C,
    $1C2C8, $1E166, $1C2C4, $1C2C2,
    $185D0, $1C2EC, $185C8, $1C2E6,
    $185C4, $185C2, $10BD0, $185EC,
    $10BC8, $185E6, $10BC4, $10BC2,
    $10BEC, $10BE6, $1F1A8, $1F8D6,
    $11AFC, $1F1A4, $11A7E, $1F1A2,
    $1E128, $1F096, $1E368, $1E124,
    $1E364, $1E122, $1E362, $1C268,
    $1E136, $1C6E8, $1C264, $1C6E4,
    $1C262, $1C6E2, $184E8, $1C276,
    $18DE8, $184E4, $18DE4, $184E2,
    $18DE2, $109E8, $184F6, $11BE8,
    $109E4, $11BE4, $109E2, $11BE2,
    $109F6, $11BF6, $1F9D4, $13AF8,
    $19D7E, $1F9D2, $13A7C, $13A3E,
    $1F194, $1197E, $1F3B4, $1F192,
    $13B7E, $1F3B2, $1E114, $1E334,
    $1E112, $1E774, $1E332, $1E772,
    $1C234, $1C674, $1C232, $1CEF4,
    $1C672, $1CEF2, $18474, $18CF4,
    $18472, $19DF4, $18CF2, $19DF2,
    $108F4, $119F4, $108F2, $13BF4,
    $119F2, $13BF2, $17AF0, $1BD7C,
    $17A78, $1BD3E, $17A3C, $17A1E,
    $1F9CA, $1397C, $1FBDA, $17B7C,
    $1393E, $17B3E, $1F18A, $1F39A,
    $1F7BA, $1E10A, $1E31A, $1E73A,
    $1EF7A, $1C21A, $1C63A, $1CE7A,
    $1DEFA, $1843A, $18C7A, $19CFA,
    $1BDFA, $1087A, $118FA, $139FA,
    $17978, $1BCBE, $1793C, $1791E,
    $138BE, $179BE, $178BC, $1789E,
    $1785E, $1E0A8, $1E0A4, $1E0A2,
    $1C168, $1E0B6, $1C164, $1C162,
    $182E8, $1C176, $182E4, $182E2,
    $105E8, $182F6, $105E4, $105E2,
    $105F6, $1F0D4, $10D7E, $1F0D2,
    $1E094, $1E1B4, $1E092, $1E1B2,
    $1C134, $1C374, $1C132, $1C372,
    $18274, $186F4, $18272, $186F2,
    $104F4, $10DF4, $104F2, $10DF2,
    $1F8EA, $11D7C, $11D3E, $1F0CA,
    $1F1DA, $1E08A, $1E19A, $1E3BA,
    $1C11A, $1C33A, $1C77A, $1823A,
    $1867A, $18EFA, $1047A, $10CFA,
    $11DFA, $13D78, $19EBE, $13D3C,
    $13D1E, $11CBE, $13DBE, $17D70,
    $1BEBC, $17D38, $1BE9E, $17D1C,
    $17D0E, $13CBC, $17DBC, $13C9E,
    $17D9E, $17CB8, $1BE5E, $17C9C,
    $17C8E, $13C5E, $17CDE, $17C5C,
    $17C4E, $17C2E, $1C0B4, $1C0B2,
    $18174, $18172, $102F4, $102F2,
    $1E0DA, $1C09A, $1C1BA, $1813A,
    $1837A, $1027A, $106FA, $10EBE,
    $11EBC, $11E9E, $13EB8, $19F5E,
    $13E9C, $13E8E, $11E5E, $13EDE,
    $17EB0, $1BF5C, $17E98, $1BF4E,
    $17E8C, $17E86, $13E5C, $17EDC,
    $13E4E, $17ECE, $17E58, $1BF2E,
    $17E4C, $17E46, $13E2E, $17E6E,
    $17E2C, $17E26, $10F5E, $11F5C,
    $11F4E, $13F58, $19FAE, $13F4C,
    $13F46, $11F2E, $13F6E, $13F2C,
    $13F26), (
    $1ABE0, $1D5F8, $153C0, $1A9F0,
    $1D4FC, $151E0, $1A8F8, $1D47E,
    $150F0, $1A87C, $15078, $1FAD0,
    $15BE0, $1ADF8, $1FAC8, $159F0,
    $1ACFC, $1FAC4, $158F8, $1AC7E,
    $1FAC2, $1587C, $1F5D0, $1FAEC,
    $15DF8, $1F5C8, $1FAE6, $15CFC,
    $1F5C4, $15C7E, $1F5C2, $1EBD0,
    $1F5EC, $1EBC8, $1F5E6, $1EBC4,
    $1EBC2, $1D7D0, $1EBEC, $1D7C8,
    $1EBE6, $1D7C4, $1D7C2, $1AFD0,
    $1D7EC, $1AFC8, $1D7E6, $1AFC4,
    $14BC0, $1A5F0, $1D2FC, $149E0,
    $1A4F8, $1D27E, $148F0, $1A47C,
    $14878, $1A43E, $1483C, $1FA68,
    $14DF0, $1A6FC, $1FA64, $14CF8,
    $1A67E, $1FA62, $14C7C, $14C3E,
    $1F4E8, $1FA76, $14EFC, $1F4E4,
    $14E7E, $1F4E2, $1E9E8, $1F4F6,
    $1E9E4, $1E9E2, $1D3E8, $1E9F6,
    $1D3E4, $1D3E2, $1A7E8, $1D3F6,
    $1A7E4, $1A7E2, $145E0, $1A2F8,
    $1D17E, $144F0, $1A27C, $14478,
    $1A23E, $1443C, $1441E, $1FA34,
    $146F8, $1A37E, $1FA32, $1467C,
    $1463E, $1F474, $1477E, $1F472,
    $1E8F4, $1E8F2, $1D1F4, $1D1F2,
    $1A3F4, $1A3F2, $142F0, $1A17C,
    $14278, $1A13E, $1423C, $1421E,
    $1FA1A, $1437C, $1433E, $1F43A,
    $1E87A, $1D0FA, $14178, $1A0BE,
    $1413C, $1411E, $141BE, $140BC,
    $1409E, $12BC0, $195F0, $1CAFC,
    $129E0, $194F8, $1CA7E, $128F0,
    $1947C, $12878, $1943E, $1283C,
    $1F968, $12DF0, $196FC, $1F964,
    $12CF8, $1967E, $1F962, $12C7C,
    $12C3E, $1F2E8, $1F976, $12EFC,
    $1F2E4, $12E7E, $1F2E2, $1E5E8,
    $1F2F6, $1E5E4, $1E5E2, $1CBE8,
    $1E5F6, $1CBE4, $1CBE2, $197E8,
    $1CBF6, $197E4, $197E2, $1B5E0,
    $1DAF8, $1ED7E, $169C0, $1B4F0,
    $1DA7C, $168E0, $1B478, $1DA3E,
    $16870, $1B43C, $16838, $1B41E,
    $1681C, $125E0, $192F8, $1C97E,
    $16DE0, $124F0, $1927C, $16CF0,
    $1B67C, $1923E, $16C78, $1243C,
    $16C3C, $1241E, $16C1E, $1F934,
    $126F8, $1937E, $1FB74, $1F932,
    $16EF8, $1267C, $1FB72, $16E7C,
    $1263E, $16E3E, $1F274, $1277E,
    $1F6F4, $1F272, $16F7E, $1F6F2,
    $1E4F4, $1EDF4, $1E4F2, $1EDF2,
    $1C9F4, $1DBF4, $1C9F2, $1DBF2,
    $193F4, $193F2, $165C0, $1B2F0,
    $1D97C, $164E0, $1B278, $1D93E,
    $16470, $1B23C, $16438, $1B21E,
    $1641C, $1640E, $122F0, $1917C,
    $166F0, $12278, $1913E, $16678,
    $1B33E, $1663C, $1221E, $1661E,
    $1F91A, $1237C, $1FB3A, $1677C,
    $1233E, $1673E, $1F23A, $1F67A,
    $1E47A, $1ECFA, $1C8FA, $1D9FA,
    $191FA, $162E0, $1B178, $1D8BE,
    $16270, $1B13C, $16238, $1B11E,
    $1621C, $1620E, $12178, $190BE,
    $16378, $1213C, $1633C, $1211E,
    $1631E, $121BE, $163BE, $16170,
    $1B0BC, $16138, $1B09E, $1611C,
    $1610E, $120BC, $161BC, $1209E,
    $1619E, $160B8, $1B05E, $1609C,
    $1608E, $1205E, $160DE, $1605C,
    $1604E, $115E0, $18AF8, $1C57E,
    $114F0, $18A7C, $11478, $18A3E,
    $1143C, $1141E, $1F8B4, $116F8,
    $18B7E, $1F8B2, $1167C, $1163E,
    $1F174, $1177E, $1F172, $1E2F4,
    $1E2F2, $1C5F4, $1C5F2, $18BF4,
    $18BF2, $135C0, $19AF0, $1CD7C,
    $134E0, $19A78, $1CD3E, $13470,
    $19A3C, $13438, $19A1E, $1341C,
    $1340E, $112F0, $1897C, $136F0,
    $11278, $1893E, $13678, $19B3E,
    $1363C, $1121E, $1361E, $1F89A,
    $1137C, $1F9BA, $1377C, $1133E,
    $1373E, $1F13A, $1F37A, $1E27A,
    $1E6FA, $1C4FA, $1CDFA, $189FA,
    $1BAE0, $1DD78, $1EEBE, $174C0,
    $1BA70, $1DD3C, $17460, $1BA38,
    $1DD1E, $17430, $1BA1C, $17418,
    $1BA0E, $1740C, $132E0, $19978,
    $1CCBE, $176E0, $13270, $1993C,
    $17670, $1BB3C, $1991E, $17638,
    $1321C, $1761C, $1320E, $1760E,
    $11178, $188BE, $13378, $1113C,
    $17778, $1333C, $1111E, $1773C,
    $1331E, $1771E, $111BE, $133BE,
    $177BE, $172C0, $1B970, $1DCBC,
    $17260, $1B938, $1DC9E, $17230,
    $1B91C, $17218, $1B90E, $1720C,
    $17206, $13170, $198BC, $17370,
    $13138, $1989E, $17338, $1B99E,
    $1731C, $1310E, $1730E, $110BC,
    $131BC, $1109E, $173BC, $1319E,
    $1739E, $17160, $1B8B8, $1DC5E,
    $17130, $1B89C, $17118, $1B88E,
    $1710C, $17106, $130B8, $1985E,
    $171B8, $1309C, $1719C, $1308E,
    $1718E, $1105E, $130DE, $171DE,
    $170B0, $1B85C, $17098, $1B84E,
    $1708C, $17086, $1305C, $170DC,
    $1304E, $170CE, $17058, $1B82E,
    $1704C, $17046, $1302E, $1706E,
    $1702C, $17026, $10AF0, $1857C,
    $10A78, $1853E, $10A3C, $10A1E,
    $10B7C, $10B3E, $1F0BA, $1E17A,
    $1C2FA, $185FA, $11AE0, $18D78,
    $1C6BE, $11A70, $18D3C, $11A38,
    $18D1E, $11A1C, $11A0E, $10978,
    $184BE, $11B78, $1093C, $11B3C,
    $1091E, $11B1E, $109BE, $11BBE,
    $13AC0, $19D70, $1CEBC, $13A60,
    $19D38, $1CE9E, $13A30, $19D1C,
    $13A18, $19D0E, $13A0C, $13A06,
    $11970, $18CBC, $13B70, $11938,
    $18C9E, $13B38, $1191C, $13B1C,
    $1190E, $13B0E, $108BC, $119BC,
    $1089E, $13BBC, $1199E, $13B9E,
    $1BD60, $1DEB8, $1EF5E, $17A40,
    $1BD30, $1DE9C, $17A20, $1BD18,
    $1DE8E, $17A10, $1BD0C, $17A08,
    $1BD06, $17A04, $13960, $19CB8,
    $1CE5E, $17B60, $13930, $19C9C,
    $17B30, $1BD9C, $19C8E, $17B18,
    $1390C, $17B0C, $13906, $17B06,
    $118B8, $18C5E, $139B8, $1189C,
    $17BB8, $1399C, $1188E, $17B9C,
    $1398E, $17B8E, $1085E, $118DE,
    $139DE, $17BDE, $17940, $1BCB0,
    $1DE5C, $17920, $1BC98, $1DE4E,
    $17910, $1BC8C, $17908, $1BC86,
    $17904, $17902, $138B0, $19C5C,
    $179B0, $13898, $19C4E, $17998,
    $1BCCE, $1798C, $13886, $17986,
    $1185C, $138DC, $1184E, $179DC,
    $138CE, $179CE, $178A0, $1BC58,
    $1DE2E, $17890, $1BC4C, $17888,
    $1BC46, $17884, $17882, $13858,
    $19C2E, $178D8, $1384C, $178CC,
    $13846, $178C6, $1182E, $1386E,
    $178EE, $17850, $1BC2C, $17848,
    $1BC26, $17844, $17842, $1382C,
    $1786C, $13826, $17866, $17828,
    $1BC16, $17824, $17822, $13816,
    $17836, $10578, $182BE, $1053C,
    $1051E, $105BE, $10D70, $186BC,
    $10D38, $1869E, $10D1C, $10D0E,
    $104BC, $10DBC, $1049E, $10D9E,
    $11D60, $18EB8, $1C75E, $11D30,
    $18E9C, $11D18, $18E8E, $11D0C,
    $11D06, $10CB8, $1865E, $11DB8,
    $10C9C, $11D9C, $10C8E, $11D8E,
    $1045E, $10CDE, $11DDE, $13D40,
    $19EB0, $1CF5C, $13D20, $19E98,
    $1CF4E, $13D10, $19E8C, $13D08,
    $19E86, $13D04, $13D02, $11CB0,
    $18E5C, $13DB0, $11C98, $18E4E,
    $13D98, $19ECE, $13D8C, $11C86,
    $13D86, $10C5C, $11CDC, $10C4E,
    $13DDC, $11CCE, $13DCE, $1BEA0,
    $1DF58, $1EFAE, $1BE90, $1DF4C,
    $1BE88, $1DF46, $1BE84, $1BE82,
    $13CA0, $19E58, $1CF2E, $17DA0,
    $13C90, $19E4C, $17D90, $1BECC,
    $19E46, $17D88, $13C84, $17D84,
    $13C82, $17D82, $11C58, $18E2E,
    $13CD8, $11C4C, $17DD8, $13CCC,
    $11C46, $17DCC, $13CC6, $17DC6,
    $10C2E, $11C6E, $13CEE, $17DEE,
    $1BE50, $1DF2C, $1BE48, $1DF26,
    $1BE44, $1BE42, $13C50, $19E2C,
    $17CD0, $13C48, $19E26, $17CC8,
    $1BE66, $17CC4, $13C42, $17CC2,
    $11C2C, $13C6C, $11C26, $17CEC,
    $13C66, $17CE6, $1BE28, $1DF16,
    $1BE24, $1BE22, $13C28, $19E16,
    $17C68, $13C24, $17C64, $13C22,
    $17C62, $11C16, $13C36, $17C76,
    $1BE14, $1BE12, $13C14, $17C34,
    $13C12, $17C32, $102BC, $1029E,
    $106B8, $1835E, $1069C, $1068E,
    $1025E, $106DE, $10EB0, $1875C,
    $10E98, $1874E, $10E8C, $10E86,
    $1065C, $10EDC, $1064E, $10ECE,
    $11EA0, $18F58, $1C7AE, $11E90,
    $18F4C, $11E88, $18F46, $11E84,
    $11E82, $10E58, $1872E, $11ED8,
    $18F6E, $11ECC, $10E46, $11EC6,
    $1062E, $10E6E, $11EEE, $19F50,
    $1CFAC, $19F48, $1CFA6, $19F44,
    $19F42, $11E50, $18F2C, $13ED0,
    $19F6C, $18F26, $13EC8, $11E44,
    $13EC4, $11E42, $13EC2, $10E2C,
    $11E6C, $10E26, $13EEC, $11E66,
    $13EE6, $1DFA8, $1EFD6, $1DFA4,
    $1DFA2, $19F28, $1CF96, $1BF68,
    $19F24, $1BF64, $19F22, $1BF62,
    $11E28, $18F16, $13E68, $11E24,
    $17EE8, $13E64, $11E22, $17EE4,
    $13E62, $17EE2, $10E16, $11E36,
    $13E76, $17EF6, $1DF94, $1DF92,
    $19F14, $1BF34, $19F12, $1BF32,
    $11E14, $13E34, $11E12, $17E74,
    $13E32, $17E72, $1DF8A, $19F0A,
    $1BF1A, $11E0A, $13E1A, $17E3A,
    $1035C, $1034E, $10758, $183AE,
    $1074C, $10746, $1032E, $1076E,
    $10F50, $187AC, $10F48, $187A6,
    $10F44, $10F42, $1072C, $10F6C,
    $10726, $10F66, $18FA8, $1C7D6,
    $18FA4, $18FA2, $10F28, $18796,
    $11F68, $18FB6, $11F64, $10F22,
    $11F62, $10716, $10F36, $11F76,
    $1CFD4, $1CFD2, $18F94, $19FB4,
    $18F92, $19FB2, $10F14, $11F34,
    $10F12, $13F74, $11F32, $13F72,
    $1CFCA, $18F8A, $19F9A, $10F0A,
    $11F1A, $13F3A, $103AC, $103A6,
    $107A8, $183D6, $107A4, $107A2,
    $10396, $107B6, $187D4, $187D2,
    $10794, $10FB4, $10792, $10FB2,
    $1C7EA));

type
  TPDF417 = class(TGraphicControl) //TQRPrintable)
  private
    preparingMacroPDF: boolean;
    {resize the image when painting on the screen to fit the size of the control}
    FAutoFit: boolean;
    { Private Declarations }
    FCode: string;
    { number of rows of the PDF417 code. If 0 the number will be calculated automatically.}
    FPDFRows: Integer;
    FPDFMaxRows: Integer;
    FRuntimeRows: Integer;
    { number of columns of the PDF417 code. The default is 10}
    FPDFColumns: Integer;
    { PDF417 error correction level. The default is 0.}
    FPDFECLevel: Integer;
    { PDF417 mode. Valid values are PDF_BINARY (default), PDF_TEXT (for ascii data) and PDF_NUMERIC (for numeric data).}
    FPDFMode: TEncoding;
    { PDF Macro }
    { PDF Macro segment }
    FPDFMacroSegment: integer;
    {PDF Macro field id}
    FPDFMacroFileId: string;
    { PDF Macro field name}
    FPDFMacroFileName: string;
    { PDF Macro time stamp }
    FPDFMacroTimeStamp: string;
    { PDF Macro Sender}
    FPDFMacroSender: string;
    { PDF Macro Addresse}
    FPDFMacroAddresse: string;
    {PDF Macro file size}
    FPDFMacroFileSize: integer;
    { number of Macro PDF symbols needed }
    FPDFMacroSegmentCount: integer;
    { internal use }
    FCurrentY: Integer;
    FCurrentX: Integer;
    FOffsetX: integer;
    FOffsetY: integer;

    {During most printing processes, there is a tendency for the ink or toner to spread slightly. This means that when you print a PDF417 symbol, the black modules tend to end up slightly wider than expected, and the white modules slightly narrower. The encoder allows you to compensate for this ink spread by "shaving" the black modules. Choosing a non-zero value for the horizontal "shaving" amount, for example, causes the encoder to lay the symbol out using the specified module width, but then change part of each black module back to white.
The amount of shaving required depends entirely on the printing process and the type of stock being used. With laser printers, this effect is minimal, and can usually be ignored. With inkjet printers, particularly on low-quality paper stock, the amount of ink spread can be significant. You may need to experiment to determine an appropriate setting.
You can determine the appropriate amount of horizontal shaving by printing a symbol with no shaving (zero) and with one pixel's worth of shaving. Look at the black and white vertical bars in the start patterns of both symbols, and choose the value for which the black and white bars are closest to the same width. In the vertical direction, again try with and without one pixel of shaving. If using one pixel's worth of shaving introduces a gap between successive rows of the symbol, go back to zero.
Only in the rarest of cases should you ever need more than one pixel's worth of shaving}
    {pixel shaving}
    FHorizontalPixelShaving: integer;
    FVerticalPixelShaving: integer;

    FTopMargin: Integer;
    FLeftMargin: Integer;
    FBarHeightPixels: Integer;
    FBarWidthPixels: Integer;
    FPDFPointerNextData: TVector;
    FcodeBinary: TByteVector;
    FcurrentCanvas: TCanvas;
    FBackColor: TColor;
    FBarColor: TColor;
    FPDFTruncated: boolean;
    FMacroPDFLastSegment: boolean;
    function right(s: string; l: integer): string;
    procedure fillRect(ca: TCanvas; x: integer; y: integer; w: integer; h: integer);
  protected
    { Protected Declarations }

    procedure addBarWithHeight(pWidth: Integer; black: boolean; Y: Integer; pHeight: Integer);
    procedure paintCharWithHeight(patternColor: string; patternBars: string; Y: integer; Height: integer);
    function toXSecuence(cword: Integer): string;
    procedure paintPDF417(canvas: TCanvas);
    procedure textEncode(s: string; var res: TVector);
    procedure PDF417_compact_binary(var bytes: TByteVector; var controlBlock: TVector; datacols: Integer; var outa: TVector);
    procedure toBase900(ina: string; var outa: TVector);
    procedure PDF417_compact_numeric(var bytes: TByteVector; var controlBlock: TVector; datacols: Integer; var res: TVector);
    procedure PDF417_compact_text(var bytes: TByteVector; var controlBlock: TVector; datacols: Integer; var res: TVector);
    procedure genEC(var data: TVector; len: Integer);
    function findChar(c: string): Integer;
    function getCoef(i: Integer; j: Integer): Integer;
    procedure Paint; override;
    // procedure Print(OfsX,OfsY:Integer);  override;
  public
    { Public Declarations }
    property PDFPointerNextData: TVector read FPDFPointerNextData write FPDFPointerNextData;
    property codeBinary: TByteVector read FcodeBinary write FcodeBinary;
  published
    { Published  Declarations }
    constructor Create(Owner: TComponent); override;
    property AutoFit: boolean read FAutoFit write FAutoFit;
    property offsetX: Integer read FoffsetX write FoffsetX;
    property offsetY: Integer read FoffsetY write FoffsetY;

    property Code: string read FCode write FCode;
    property PDFMacroSegmentCount: integer read FPDFMacroSegmentCount write FPDFMacroSegmentCount; // write FPDFMacroSegmentCount default -1;
    //          property PDFMacroOffset:integer read FPDFMacroOffset write FPDFMacroOffset default 0;
    property PDFTruncated: boolean read FPDFTruncated write FPDFTruncated default false;
    property MacroPDFLastSegment: boolean read FMacroPDFLastSegment write FMacroPDFLastSegment default false;
    property PDFMacroFileName: string read FPDFMacroFileName write FPDFMacroFileName;
    property PDFMode: TEncoding read FPDFMode write FPDFMode default PDF_BINARY;
    property PDFMacroSegment: integer read FPDFMacroSegment write FPDFMacroSegment default -1;
    property PDFMacroFileId: string read FPDFMacroFileId write FPDFMacroFileId;
    property PDFMacroTimeStamp: string read FPDFMacroTimeStamp write FPDFMacroTimeStamp;
    property PDFMacroSender: string read FPDFMacroSender write FPDFMacroSender;
    property PDFMacroAddresse: string read FPDFMacroAddresse write FPDFMacroAddresse;
    property PDFMacroFileSize: integer read FPDFMacroFileSize write FPDFMacroFileSize default 0;
    property PDFMaxRows: integer read FPDFMaxRows write FPDFMaxRows default 4;
    property PDFRows: integer read FPDFRows write FPDFRows default 0;
    property PDFColumns: integer read FPDFColumns write FPDFColumns default 10;
    property PDFECLevel: integer read FPDFECLevel write FPDFECLevel default 0;
    property HorizontalPixelShaving: integer read FHorizontalPixelShaving write FHorizontalPixelShaving default 0;
    property VerticalPixelShaving: integer read FVerticalPixelShaving write FVerticalPixelShaving default 0;
    property TopMargin: integer read FTopMargin write FTopMargin default 0;
    property LeftMargin: integer read FLeftMargin write FLeftMargin default 0;
    property BarWidthPixels: integer read FBarWidthPixels write FBarWidthPixels default 1;
    property BarHeightPixels: integer read FBarHeightPixels write FBarHeightPixels default 7;
    property BackColor: TColor read FBackColor write FBackColor default clWhite;
    property BarColor: TColor read FBarColor write FBarColor default clBlack;
    property CurrentX: integer read FCurrentX;
    property CurrentY: integer read FCurrentY;
    procedure paintBarcode(canvas: TCanvas);
    procedure paintBarcodeAutoSize(c: TCanvas);
    procedure resetMacroPDF();
    procedure prepareMacroPDF();
  end;

procedure Register;

implementation

{procedure TPDF417.Print(OfsX,OfsY:Integer);
begin
     offsetX:=ParentReport.QRPrinter.XPos(OfsX+Size.Left);
     offsety:=ParentReport.QRPrinter.Ypos(OfsY+Size.Top);

     paintBarcode(ParentReport.QRPrinter.Canvas);

     offsetX:= 0;
     offsety:=0;
end;  }

procedure Register;
begin
  RegisterComponents('Barcodes', [TPDF417]);
end;

procedure TPDF417.Paint;
var
  Bitmap: TBitmap;
  src, dest: TRect;
begin

  if (FAutoFit) then
    paintBarcodeAutosize(Canvas)
  else
  begin

    Bitmap := TBitmap.Create; { construct the bitmap object }
    Bitmap.width := Width;
    Bitmap.height := height;
    src := Rect(0, 0, width, height);
    dest := Rect(0, 0, width, height);

    try
      { draw on the bitmap }
      paintBarcode(Bitmap.Canvas);
      { copy the result into the control's canvas }
      Canvas.copyRect(src, Bitmap.Canvas, dest)
    finally
      Bitmap.Free; { destroy the bitmap object }
    end;
  end;
end;

procedure TPDF417.paintBarcodeAutosize(c: TCanvas);
var
  bmp: TBitmap;
  requiredWith: integer;
  requiredHeight: integer;
  rect: TRect;
  rect2: TRect;
begin

  // test paint to find out required size
  bmp := TBitmap.create();
  bmp.width := 100;
  bmp.height := 100;

  paintBarcode(bmp.canvas);

  requiredWith := FcurrentX;
  requiredHeight := FcurrentY;

  bmp.free;
  bmp := nil;

  // paint now on bmp of exact size
  bmp := TBitmap.create();
  bmp.width := requiredWith + leftMargin;
  bmp.height := requiredHeight + topMargin;

  paintBarcode(bmp.canvas);
  rect.top := 0;
  rect.left := 0;
  rect.bottom := height;
  rect.right := width;

  rect2.top := 0;
  rect2.left := 0;
  rect2.bottom := bmp.height;
  rect2.right := bmp.width;

  c.Brush.Color := backColor;
  fillRect(c, rect.left, rect.top, rect.Right, rect.bottom);

  c.copyMode := cmSrcCopy;
  c.copyRect(rect, bmp.canvas, rect2);

  bmp.free;
  bmp := nil;

end;

{ call this before creating a new Macro PDF barcode}

procedure TPDF417.resetMacroPDF();
var
  i: integer;
begin
  setLength(FPDFPointerNextData, 5000);
  for i := 0 to length(FPDFPointerNextData) - 1 do
    FPDFPointerNextData[i] := 0;
end;

{  Only Macro PDF. Call this to calculate the number of symbols needed }

procedure TPDF417.prepareMacroPDF();
var
  i: integer;
  l: Integer;
begin

  i := 0;
  preparingMacroPDF := true;

  if (Length(FcodeBinary) > 0) then
    l := Length(FcodeBinary)
  else
    l := Length(FCode);

  while (FPDFPointerNextData[i] < l) do
  begin
    FPDFMacroSegmentCount := 0;
    FPDFMacroSegment := i;
    paintPDF417(nil);
    i := i + 1;
  end;

  preparingMacroPDF := false;
  FPDFMacroSegmentCount := i;
end;

{ paint a bar}

procedure TPDF417.addBarWithHeight(pWidth: Integer; black: boolean; Y: Integer; pHeight: Integer);
var
  a, b, c, d: TPoint;
  w: integer;
  h: integer;
  //brush:TBrush;
begin

  w := pWidth;
  h := pHeight;

  if (black) and (HorizontalPixelShaving > 0) and (w > 0) then
  begin
    w := w - HorizontalPixelShaving;
    if (w <= 0) then
      w := 1;
  end;

  if (black) and (VerticalPixelShaving > 0) and (h > 0) then
  begin
    h := h - VerticalPixelShaving;
    if (h <= 0) then
      h := 1;
  end;

  if (black) and (FcurrentCanvas <> nil) then
  begin
    FcurrentCanvas.pen.width := 1;
    FcurrentCanvas.pen.Color := FBarColor;
    FcurrentCanvas.brush.color := FBarColor;
    FcurrentCanvas.brush.style := bsSolid;
    //canvas.Brush:=brush;
    a.x := FcurrentX;
    a.y := Y;
    b.x := FcurrentX + w - 1;
    b.y := Y;
    c.x := FcurrentX + w - 1;
    c.y := y + h; //-1;
    d.x := FcurrentX;
    d.y := Y + h; //-1;
    FcurrentCanvas.polygon([a, b, c, d]);
  end;

  { move pointer }
  FcurrentX := FcurrentX + pWidth;

end;

{ paint a character/codeword }

procedure TPDF417.paintCharWithHeight(patternColor: string; patternBars: string; Y: integer; Height: integer);
var
  cColor: char;
  cBar: char;
  i: integer;
begin

  for i := 0 to Length(patternColor) - 1 do
  begin
    cColor := patternColor[i + 1];
    cBar := patternBars[i + 1];

    //if (cBar='n') then addBarWithHeight(narrowBarPixels,(cColor='b'),Y,Height);
    //if (cBar='w') then addBarWithHeight(widthBarPixels,(cColor='b'),Y,Height);

    if (cBar = '1') then
      addBarWithHeight(FBarWidthPixels, (cColor = 'b'), Y, Height);
    if (cBar = '2') then
      addBarWithHeight((FBarWidthPixels * 2), (cColor = 'b'), Y, Height);
    if (cBar = '3') then
      addBarWithHeight((FBarWidthPixels * 3), (cColor = 'b'), Y, Height);
    if (cBar = '4') then
      addBarWithHeight((FBarWidthPixels * 4), (cColor = 'b'), Y, Height);
    if (cBar = '5') then
      addBarWithHeight((FBarWidthPixels * 5), (cColor = 'b'), Y, Height);
    if (cBar = '6') then
      addBarWithHeight((FBarWidthPixels * 6), (cColor = 'b'), Y, Height);
    if (cBar = '7') then
      addBarWithHeight((FBarWidthPixels * 7), (cColor = 'b'), Y, Height);
    if (cBar = '8') then
      addBarWithHeight((FBarWidthPixels * 8), (cColor = 'b'), Y, Height);

  end;
end;

{ convert 01101011100011111 to 12111435 }

function TPDF417.toXSecuence(cword: Integer): string;
var
  count: Integer;
  bit: Integer;
  currentValue: Integer;
  r: string;
  tmp: Integer;
  i: Integer;
  tmpStr: string;
begin

  count := 0;
  bit := 1;
  currentValue := -1;
  r := '';

  for i := 0 to 17 - 1 do
  begin

    if (currentValue = -1) then
    begin
      currentValue := (cword and bit);
      if (currentValue > 0) then
        currentValue := 1;
    end;

    tmp := (cword and bit);
    if (tmp > 0) then
      tmp := 1;

    if (currentValue = tmp) then
      count := count + 1
    else
    begin
      str(count, tmpStr);
      r := '' + tmpStr + r;
      currentValue := (cword and bit);
      if (currentValue > 0) then
        currentValue := 1;
      count := 1;
    end;

    bit := bit * 2;
  end;

  str(count, tmpStr);
  r := '' + tmpStr + r;

  result := r;
end;

procedure TPDF417.fillRect(ca: TCanvas; x: integer; y: integer; w: integer; h: integer);
var
  a, b, c, d: TPoint;
begin
  if (FCurrentCanvas <> nil) then
  begin
    ca.pen.width := 1;
    ca.brush.style := bsSolid;
    a.x := x;
    a.y := y;
    b.x := x + w;
    b.y := y;
    c.x := x + w;
    c.y := y + h;
    d.x := x;
    d.y := y + h;
    ca.polygon([a, b, c, d]);
  end;
end;

{ paints a PDF417 code }

procedure TPDF417.paintPDF417(canvas: TCanvas);
var
  cwords: TVector;
  SegmentIdBytes: TVector;
  fileName: TVector;
  sender: TVector;
  addressee: TVector;
  segmentCountBytes: TVector;
  fileSize: TVector;
  timeStamp: TVector;
  controlBlock: TVector;
  SegmentId: string;
  h: Integer;
  SegmentCountStr: string;
  fileSizeStr: string;
  tmpBlockCount: integer;
  tmpBlock: TVector;
  bytes: TByteVector;
  inp: Integer;
  row: Integer;
  i: Integer;
  v: Integer;
  w: Integer;
  x: Integer;
  z: Integer;
  y: Integer;
begin

  { background color}
  FCurrentCanvas := canvas;
  if (FCurrentCanvas <> nil) then
  begin
    FCurrentCanvas.pen.Color := backColor;
    FCurrentCanvas.Brush.Color := backColor;
    //fillRect(FCurrentCanvas.Cliprect.left,FCurrentCanvas.Cliprect.top,FCurrentCanvas.Cliprect.Right,FCurrentCanvas.Cliprect.bottom);
//        fillRect(leftMargin,topMargin,leftMargin+width,topMargin+height);
    fillRect(FCurrentCanvas, offsetX, offsetY, offsetX + width, offsetY + height);
  end;

  FcurrentY := FTopMargin + offsetY;
  FCurrentX := FLeftMargin + offsetX;

  if (FBarHeightPixels = 0) then
    FBarHeightPixels := 6;
  { calculate cwords }

   {  segmentId }
  if (FPDFMacroSegment > -1) then
  begin
    str(PDFMacroSegment, SegmentId);
    {0 left padding, upt o 5 digits}
    for h := length(SegmentId) to 4 do
      SegmentId := '0' + SegmentId;
    toBase900(SegmentId, SegmentIdBytes);
  end;

  { segmentCount }
  if (PDFMacroSegmentCount > -1) then
  begin
    str(PDFMacroSegmentCount, SegmentCountStr);
    { 0 left padding, upt o 5 digits }
    for h := length(SegmentCountStr) to 4 do
      SegmentCountStr := '0' + SegmentCountStr;
    toBase900(SegmentCountStr, segmentCountBytes);
  end;

  { file size }
  if (PDFMacroFileSize > 0) then
  begin
    str(PDFMacroFileSize, fileSizeStr);
    toBase900(fileSizeStr, fileSize);
  end;

  { time stamp  }
  if (length(PDFMacroTimeStamp) > 0) then
    toBase900(PDFMacroTimeStamp, timeStamp);

  { file name   }
  if (length(PDFMacroFileName) > 0) then
    textEncode(PDFMacroFileName, fileName);

  if (length(PDFMacroSender) > 0) then
    textEncode(PDFMacroSender, sender);

  if (length(FPDFMacroAddresse) > 0) then
    textEncode(FPDFMacroAddresse, addressee);

  if (PDFMacroSegment > -1) then
  begin
    setLength(tmpBlock, 5000);
    tmpBlockCount := 0;

    tmpBlock[tmpBlockCount] := 928;
    tmpBlockCount := tmpBlockCount + 1;

    { segment id }
    for h := 0 to length(SegmentIdBytes) - 1 do
    begin
      tmpBlock[tmpBlockCount] := SegmentIdBytes[h];
      tmpBlockCount := tmpBlockCount + 1;
    end;

    { file id    }
    for h := 0 to length(PDFMacroFileId) - 1 do
    begin
      tmpBlock[tmpBlockCount] := ord(PDFMacroFileId[h + 1]);
      tmpBlockCount := tmpBlockCount + 1;
    end;

    { file name  }
    if (length(PDFMacroFileName) > 0) then
    begin
      tmpBlock[tmpBlockCount] := 923;
      tmpBlockCount := tmpBlockCount + 1;
      tmpBlock[tmpBlockCount] := 0;
      tmpBlockCount := tmpBlockCount + 1;
      for h := 0 to length(fileName) - 1 do
      begin
        tmpBlock[tmpBlockCount] := fileName[h];
        tmpBlockCount := tmpBlockCount + 1;
      end;
    end;

    { Segment count  }
    if (PDFMacroSegmentCount > -1) then
    begin
      tmpBlock[tmpBlockCount] := 923;
      tmpBlockCount := tmpBlockCount + 1;
      tmpBlock[tmpBlockCount] := 1;
      tmpBlockCount := tmpBlockCount + 1;
      for h := 0 to length(segmentCountBytes) - 1 do
      begin
        tmpBlock[tmpBlockCount] := segmentCountBytes[h];
        tmpBlockCount := tmpBlockCount + 1;
      end;
    end;

    if (PDFMacroSegment = 0) then
    begin

      { time stamp }
      if (length(PDFMacroTimeStamp) > 0) then
      begin
        tmpBlock[tmpBlockCount] := 923;
        tmpBlockCount := tmpBlockCount + 1;
        tmpBlock[tmpBlockCount] := 2;
        tmpBlockCount := tmpBlockCount + 1;
        for h := 0 to length(timeStamp) - 1 do
        begin
          tmpBlock[tmpBlockCount] := timeStamp[h];
          tmpBlockCount := tmpBlockCount + 1;
        end;
      end;
      { sender    }
      if (length(PDFMacroSender) > 0) then
      begin
        tmpBlock[tmpBlockCount] := 923;
        tmpBlockCount := tmpBlockCount + 1;
        tmpBlock[tmpBlockCount] := 3;
        tmpBlockCount := tmpBlockCount + 1;
        for h := 0 to length(sender) - 1 do
        begin
          tmpBlock[tmpBlockCount] := sender[h];
          tmpBlockCount := tmpBlockCount + 1;
        end;
      end;
      { addressee  }
      if (length(FPDFMacroAddresse) > 0) then
      begin
        tmpBlock[tmpBlockCount] := 923;
        tmpBlockCount := tmpBlockCount + 1;
        tmpBlock[tmpBlockCount] := 4;
        tmpBlockCount := tmpBlockCount + 1;
        for h := 0 to length(addressee) - 1 do
        begin
          tmpBlock[tmpBlockCount] := ord(addressee[h]);
          tmpBlockCount := tmpBlockCount + 1;
        end;
      end;
      { file size  }
      if (PDFMacroFileSize > 0) then
      begin
        tmpBlock[tmpBlockCount] := 923;
        tmpBlockCount := tmpBlockCount + 1;
        tmpBlock[tmpBlockCount] := 5;
        tmpBlockCount := tmpBlockCount + 1;
        for h := 0 to length(fileSize) - 1 do
        begin
          tmpBlock[tmpBlockCount] := fileSize[h];
          tmpBlockCount := tmpBlockCount + 1;
        end;
      end;

    end; { segment 0 }

    { control block terminator, only in the last segment}
    if (PDFMacroSegmentCount = (PDFMacroSegment + 1)) or (FMacroPDFLastSegment) then
    begin
      tmpBlock[tmpBlockCount] := 922;
      tmpBlockCount := tmpBlockCount + 1;
    end;

    // copy control block }
    setlength(controlBlock, tmpBlockCount);
    for h := 0 to tmpBlockCount - 1 do
      controlBlock[h] := tmpBlock[h];
  end;

  {                if (codeBinary!=null)
                     bytes =codeBinary
                  else}
  setLength(bytes, length(code));
  for h := 0 to length(code) - 1 do
    bytes[h] := ord(code[h + 1]);

  if (PDFMode = PDF_BINARY) then
    PDF417_compact_binary(bytes, controlBlock, PDFColumns, cwords);
  if (PDFMode = PDF_NUMERIC) then
    PDF417_compact_numeric(bytes, controlBlock, PDFColumns, cwords);
  if (PDFMode = PDF_TEXT) then
    PDF417_compact_text(bytes, controlBlock, PDFColumns, cwords);

  // we are not painting, only, counting segments for Macro PDF.
  // ******* if (g==null) return;

  if (cwords = nil) then
    exit;

  inp := 0;

  for row := 0 to FruntimeRows - 1 do
  begin

    { Do each row }
    FCurrentX := FLeftMargin + offsetX;

    v := FPDFColumns - 1;
    w := row mod 3; { cluster}
    x := (row div 3);
    y := ((FruntimeRows - 1) div 3);
    z := ((FPDFECLevel * 3) + ((FruntimeRows - 1) mod 3)); { The 0 is the error correction level }

    { paint start pattern }
    paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_START), FcurrentY, barHeightPixels);

    {left indicator }
    case w of
      0: paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][30 * x + y]), FcurrentY, FbarHeightPixels);
      1: paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][30 * x + z]), FcurrentY, FbarHeightPixels);
      2: paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][30 * x + v]), FcurrentY, FbarHeightPixels);
    end;

    { data }
    for i := 0 to FPDFColumns - 1 do
    begin
      paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][cwords[inp]]), FcurrentY, FbarHeightPixels);
      inp := inp + 1;
    end;

    { right indicator }
    if (not FPDFTruncated) then
    begin
      case w of
        0: paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][30 * x + v]), FcurrentY, FbarHeightPixels);
        1: paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][30 * x + y]), FcurrentY, FbarHeightPixels);
        2: paintCharWithHeight('bwbwbwbw', toXSecuence(PDF417_BITS[w][30 * x + z]), FcurrentY, FbarHeightPixels);
      end;
    end;

    { stop pattern }
    if (FPDFTruncated) then
      paintCharWithHeight('b', '1', FcurrentY, FbarHeightPixels)
    else
      paintCharWithHeight('bwbwbwbwb', '711311121', FcurrentY, FbarHeightPixels);

    FCurrentY := FCurrentY + FBarHeightPixels;
  end;

  {DEMO}
  if (FCurrentCanvas <> nil) then
  begin
    FCurrentCanvas.Brush.Color := backColor;
    FCurrentCanvas.Pen.Color := clRed;
    //  if (random(256)<50) then                 FCurrentCanvas.TextOut(leftmargin,FCurrentY div 2,'TRIAL VERSION');
  end;

end;

{ find a char in a charset table}

function TPDF417.findChar(c: string): Integer;
var
  i: Integer;
begin

  result := -1;

  for i := 0 to length(textCodes) - 1 do
    if (textCodes[i, 0] = c) then
    begin
      result := i;
      exit;
    end;

end;

procedure TPDF417.textEncode(s: string; var res: TVector);
var
  outa: TVector;
  inp: Integer;
  outp: Integer;
  processed: boolean;
  currentSubMode: string;
  newSubMode: string;
  p: Integer;
  code: Integer;
  defaultM: string;
  dummy: integer;
  i: integer;
begin

  { Allocate the codeword array }
  setLength(outa, 1000);

  inp := 0;
  outp := 0;

  currentSubMode := 'A';
  newSubMode := 'A';
  defaultM := 'A';

  while (inp < length(s)) do
  begin

    p := findChar(copy(s, inp + 1, 1));

    inp := inp + 1;

    if (p >= 0) then
    begin
      { if submode B is now default then mode A is active only for one char }
      if ((defaultM = 'B') and (currentSubMode = 'A')) then
        currentSubMode := 'B';

      newSubMode := textCodes[p, 1];

      val(copy(newSubMode, 2, length(newSubMode)), code, dummy);
      newSubMode := '' + newSubMode[1];

      processed := false;

      { we are in right mode }
      if (newSubMode = currentSubMode) then
      begin
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
      end;

      { 29 }
      if ((newSubMode = 'D') and (not processed)) then
      begin
        outa[outp] := 29;
        outp := outp + 1;
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
      end;

      { 28 }
      if ((newSubMode = 'C') and (currentSubMode <> 'C') and (not processed)) then
      begin
        outa[outp] := 28;
        outp := outp + 1;
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
        currentSubMode := 'C';
      end;

      { 27 }
      if ((newSubMode = 'B') and (currentSubMode <> 'B') and (not processed)) then
      begin
        outa[outp] := 27;
        outp := outp + 1;
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
        currentSubMode := 'B';
        defaultM := 'B';
      end;

      { back to default                    }
      if ((newSubMode = 'A') and (currentSubMode <> 'A') and (not processed)) then
      begin
        if (currentSubMode = 'B') then
        begin
          outa[outp] := 27;
          outp := outp + 1;
        end;
        if (currentSubMode = 'C') then
        begin
          outa[outp] := 28;
          defaultM := 'A';
          outp := outp + 1;
        end;
        outa[outp] := code;
        outp := outp + 1;
        //			processed:=true;
        currentSubMode := 'A';
      end;

    end;
  end;

  { add pad char 29 }
  if ((outp mod 2) <> 0) then
  begin
    outa[outp] := 29;
    outp := outp + 1;
  end;

  setLength(res, outp div 2);

  for i := 0 to outp - 1 do
    if ((i mod 2) = 0) then
      res[i div 2] := outa[i]
    else
      res[i div 2] := res[(i - 1) div 2] * 30 + outa[i];

end;

{ paints a 2D code }

procedure TPDF417.paintBarcode(canvas: TCanvas);
begin

  FCurrentX := FLeftMargin + offsetX;

  paintPDF417(canvas);

end;

{ Convert a byte sequence to a sequence of codewords.
   Pass the number of data columns to put in each row (between 1 and 30). }

procedure TPDF417.PDF417_compact_binary(var bytes: TByteVector; var controlBlock: TVector; datacols: integer; var outa: TVector);
var
  lastEncodedValue: integer;
  ECLen: Integer;
  i: integer;
  codeval: int64;
  tmp: Extended;
  outlen: Integer;
  outrows: Integer;
  startOffset: Integer;
  maxData: Integer;
  maxWords: Integer;
  inp: integer;
  tmpByte: integer;
  outp: Integer;
  h: integer;
  strtmp: string;
  blocks: integer;
  dataLen: integer;
  terminatorCount: integer;
begin
  tmp := intPower(2, FPDFECLevel + 1); { Number of codewords for error correction }
  EClen := round(tmp);
  startOffset := 0;

  if (FPDFMacroSegment > 0) then
    startOffset := PDFPointerNextData[FPDFMacroSegment];

  { Check args }
  if ((datacols < 1) or (datacols > 30)) then
    datacols := 1;
  maxWords := 928;
  //    maxData:=928;

  if (PDFMaxRows > 90) then
    FPDFMaxRows := 90;
  if (PDFMaxRows > 0) then
    maxWords := datacols * PDFMaxRows;
  //    maxData:=maxWords-EClen-length(controlBlock);

      { Calculate the length of the eventual sequence }
  outlen := (2 + ((((length(bytes) - startOffset) div 6))) * 5 + (((length(bytes) - startOffset) mod 6)) + EClen + length(controlBlock));
  {blocks=floor((length(bytes) -startOffset) div 6);
  dataLen=(blocks*5);
  dataLen=dataLen+(length(bytes) -startOffset) % 6;
  outlen = ( (2 + ((  ((length(bytes) -startOffset) div 6)))*5 + (((length(bytes)-startOffset) mod 6)) + EClen + length(controlBlock));
  }

  terminatorCount := 0;
  if (preparingMacroPDF) then
  begin
    if (outlen <= maxWords) then
    begin
      outlen := outlen + 1; // if this is going to be the last segment we need to count the macro pdf terminator
      terminatorCount := 1;
    end;
  end;

  if (outlen > maxWords) then
    outlen := maxWords;

  { Pad to an integer number of rows, at least 3 }
  outrows := outlen div datacols;
  if ((outlen mod datacols) <> 0) then
    outrows := outrows + 1;

  // if we are using the macro pdf code , user must provide number of rows.
  if (FPDFMacroSegment >= 0) then
    outrows := FPDFRows;

  if (outrows < 3) then
    outrows := 3;
  if (outrows > 90) then
  begin
    str(outrows, strtmp);
    if (FCurrentCanvas <> nil) then
      FCurrentCanvas.TextOut(20, 20, 'Configuration not posible, rows= ' + strtmp);
    exit;
  end;

  if (outrows < FPDFRows) then
    outrows := FPDFRows;

  FruntimeRows := outrows;

  outlen := outrows * datacols;

  maxData := outlen - EClen - length(controlBlock) - terminatorCount;

  if (maxData <= 0) then
  begin
    if (FCurrentCanvas <> nil) then
      FCurrentCanvas.TextOut(20, 20, 'Configuration not posible, no place for data, increase number of rows or columns');
    exit;
  end;

  { max symbol size }
  if (outlen > 928) then
  begin
    str(outlen, strtmp);
    if (FCurrentCanvas <> nil) then
      FCurrentCanvas.TextOut(20, 20, 'Configuration not posible, length=' + strtmp);
    exit;
  end;

  { Allocate the codeword array }
  setLength(outa, outlen);

  { Map blocks of 6 bytes to block of 5 codewords }
  inp := startOffset;
  outp := 2;

  { if there is more data add latch 901, we assume we don't have groups of 5 bytes }
  outa[1] := 901;

  lastEncodedValue := length(bytes);
  while (((inp + 5) < length(bytes)) and (maxData >= (outp + 5))) do
  begin
    { Treat the 6 bytes as a big-endian base 256 number }
    codeval := 0;
    for i := 0 to 5 do
    begin
      codeval := codeval * 256;
      tmpByte := bytes[inp];
      lastEncodedValue := tmpByte;
      inp := inp + 1;

      if (tmpByte < 0) then
        tmpByte := 256 + tmpByte;

      codeval := codeval + tmpByte;
    end;

    { Convert the number to base 900 }
    for i := 0 to 4 do
    begin
      outa[outp + 4 - i] := codeval mod 900;
      codeval := codeval div 900;
    end;
    outp := outp + 5;

    { if there is more data add latch 904, we have groups *}
    outa[1] := 924;
  end; // while

  { Finish up the data }
  { if there is more data add latch 901 }
  if ((inp < length(bytes)) and (outp < maxData)) then
    outa[1] := 901;

  { Finish up the data *}
  while ((inp < length(bytes)) and (outp < maxData)) do
  begin
    outa[outp] := bytes[inp];
    inp := inp + 1;
    if (outa[outp] < 0) then
      outa[outp] := 256 + outa[outp];

    outp := outp + 1;
  end;

  { The first two codewords are the length and the BC mode latch
     The mode latch is 924 if len is a multiple of 6, 901 otherwise }
  //if (mod(outp,6)!=0) out[1] = 901 ;
  //else out[1]= 924;

  FPDFPointerNextData[FPDFMacroSegment + 1] := inp;

  { Do padding }
  while (outp < (outlen - EClen - length(controlBlock))) do
  begin
    outa[outp] := 900;
    outp := outp + 1;
  end;

  { add control block }
  for h := 0 to length(controlBlock) - 1 do
  begin
    outa[outp] := controlBlock[h];
    outp := outp + 1;
    //out[outp++]=900;
    //System.out.println("" + controlBlock[h]) ;
  end;

  //System.out.println("" + controlBlock.length) ;

  { The first two codewords are the length and the BC mode latch
     The mode latch is 924 if len is a multiple of 6, 901 otherwise }
  outa[0] := outp;

  genEC(outa, outp);

  // debug out
  //String d="";
  //for (int h=0;h<out.length;h++) d=d+";"+out[h];
  //System.out.println(d);

  outp := outp;
end;

{ convert base 10 to base 900 }

procedure TPDF417.toBase900(ina: string; var outa: TVector);
var
  tmpVector: array[0..29] of Integer;
  //o:TVector;
  x: int64;
  i: integer;
  tmplength: Integer;
  dummy: integer;
begin

  ina := '1' + ina;
  val(ina, x, dummy);

  { Convert the number to base 900 }
  tmplength := 0;
  while (x <> 0) do
  begin
    tmpVector[tmplength] := (x mod 900);
    tmplength := tmplength + 1;
    x := x div 900;
  end;

  setLength(outa, tmplength);

  { copy to result array}
  for i := 1 to tmplength do
    outa[i - 1] := tmpVector[tmplength - i];

end;

{ Convert a digit sequence to a sequence of codewords.
   Pass the number of data columns to put in each row (between 1 and 30).}

procedure TPDF417.PDF417_compact_numeric(var bytes: TByteVector; var controlBlock: TVector; datacols: Integer; var res: TVector);
var
  ECLen: integer;
  outrows: integer;
  startOffset: integer;
  maxWords: integer;
  maxData: integer;
  codeval: string;
  j: integer;
  x: int64;
  i: Integer;
  r: TVector;
  inp: integer;
  outp: integer;
  previousINP: integer;
  outlen: integer;
  tmpVector: TVector;
  outa: TVector;
  tmpI: integer;
  tmpLength: Integer;
  dummy: integer;
  h: Integer;
  xCount: Integer;
  x1: int64;
  x2: int64;
  x3: int64;
  x4: int64;
  xs1: string;
  xs2: string;
  xs3: string;
  xs4: string;
  m1: Integer;
  m2: Integer;
  m3: Integer;
  m4: Integer;

begin

  EClen := round(intPower(2, (PDFECLevel + 1))); { Number of codewords for error correction }

  startOffset := 0;

  { Check args }
  if ((datacols < 1) or (datacols > 30)) then
    datacols := 1;

  maxWords := 928;
  maxData := 928;
  if (PDFMacroSegment > 0) then
    startOffset := PDFPointerNextData[PDFMacroSegment];
  if (PDFMaxRows > 90) then
    PDFMaxRows := 90;
  if (PDFMaxRows > 0) then
    maxWords := datacols * PDFMaxRows;

  maxData := maxWords - EClen - length(controlBlock);

  if (datacols < 1) or (datacols > 30) then
    datacols := 1;

  { Calculate the length of the eventual sequence */
  //outlen = (int) (2 + (((int) (bytes.length/44)))*15 + (mod(bytes.length,44)) + EClen);

  /* Pad to an integer number of rows, at least 3 */
  //outrows = outlen / datacols;
  //if (mod(outlen,datacols)!=0) outrows++;
  //if (outrows < 3) outrows = 3;
  //if (outrows > 90) return null;
  //outlen = outrows*datacols;

//PDFRows=outrows;

  // no multipart symbols supported (Macro PDF 417)
  //if (outlen > 928) return null;

  { Allocate the codeword array }
  setlength(outa, length(bytes));
  if (maxWords > length(bytes)) then
    setlength(outa, maxWords);
  setlength(tmpVector, 30);

  { Map blocks of 6 bytes to block of 5 codewords }
  inp := startOffset;
  outp := 2;
  previousINP := inp;
  outlen := 0;

  while inp < length(bytes) do
  begin
    { Treat the 6 bytes as a big-endian base 256 number }
    codeval := '1';
    //          previousINP:=inp;

       { get 44 chars }
    j := 0;
    while ((j < 44) and (inp < length(bytes))) do
    begin
      codeval := codeval + chr(bytes[inp]);
      j := j + 1;
      inp := inp + 1;
    end;

    x1 := 0;
    x2 := 0;
    x3 := 0;
    x4 := 0;

    if (Length(codeval) > 33) then
    begin
      xs1 := copy(codeval, 1, Length(codeval) - 33);
      val(xs1, x1, dummy);
    end;

    if (Length(codeval) > 22) then
    begin
      xs2 := copy(codeval, 1, Length(codeval) - 22);
      xs2 := right(xs2, 11);
      val(xs2, x2, dummy);
    end;

    if (Length(codeval) > 11) then
    begin
      xs3 := Right(copy(codeval, 1, Length(codeval) - 11), 11);
      val(xs3, x3, dummy);
    end;

    if (Length(codeval) > 0) then
    begin
      xs4 := Right(codeval, 11);
      val(xs4, x4, dummy);
    end;

    //      xCount := 4;

        { Convert the number to base 900}

    tmplength := 0;
    while ((x1 <> 0) or (x2 <> 0) or (x3 <> 0) or (x4 <> 0)) do
    begin

      m1 := x1 - (900 * (x1 div 900));
      x1 := x1 div 900;

      x2 := x2 + (m1 * 100000000000);
      m2 := x2 - (900 * (x2 div 900));
      x2 := (x2 div 900);

      x3 := x3 + (m2 * 100000000000);
      m3 := x3 - (900 * (x3 div 900));
      x3 := (x3 div 900);

      x4 := x4 + (m3 * 100000000000);
      m4 := x4 - (900 * (x4 div 900));
      x4 := (x4 div 900);

      str(x1, xs1);
      str(x2, xs2);
      str(x3, xs3);
      str(x4, xs4);

      if Length(xs4) > 11 then
      begin
        xs3 := xs3 + copy(xs4, 1, Length(xs4) - 11);
        xs4 := Right(xs4, 11);
      end;

      if Length(xs3) > 11 then
      begin
        xs2 := xs2 + copy(xs3, 1, Length(xs3) - 11);
        xs3 := Right(xs3, 11);
      end;

      if Length(xs2) > 11 then
      begin
        xs1 := xs1 + copy(xs2, 1, Length(xs2) - 11);
        xs2 := Right(xs2, 11);
      end;

      tmpVector[tmplength] := m4;

      tmplength := tmplength + 1;

    end;

    { copy to result array }
    for i := 1 to tmplength do
    begin
      outa[outp] := tmpVector[tmplength - i];
      outp := outp + 1;
      outlen := outlen + 1;
    end;

  end;

  FPDFPointerNextData[FPDFMacroSegment + 1] := inp;

  outlen := outlen + 2 + EClen + length(controlBlock);

  { Pad to an integer number of rows, at least 3 }
  outrows := outlen div datacols;
  if ((outlen mod datacols) <> 0) then
    outrows := outrows + 1;
  if (outrows < 3) then
    outrows := 3;
  if (outrows > 90) then
    exit;

  if (outrows > FPDFRows) then
    FruntimeRows := outrows
  else
  begin
    outrows := FPDFRows;
    FruntimeRows := FPDFRows;
  end;

  outlen := outrows * datacols;

  { max symbol size }
  if (outlen > 928) then
  begin
    //      System.out.println("Too many codewords on symbol (max. is 928)");
    exit;
  end;

  { Do padding }
  while (outp < (outlen - EClen - length(controlBlock))) do
  begin
    outa[outp] := 900;
    outp := outp + 1;
  end;

  { add control block }
  for h := 0 to length(controlBlock) - 1 do
  begin
    outa[outp] := controlBlock[h];
    outp := outp + 1;
  end;

  { The first two codewords are the length and the BC mode latch}
  outa[0] := outp;
  outa[1] := 902;

  genEC(outa, outp);

  { copy to result array }
  setLength(res, outlen);

  for i := 0 to outlen - 1 do
    res[i] := outa[i];

  // debug out
  //String d="";
  //for (int h=0;h<r.length;h++) d=d+";"+r[h];
  //System.out.println(d);

end;

function TPDF417.right(s: string; l: integer): string;
//var
//tmp:Integer;
begin

  result := s;
  if (length(s) > l) then
    result := copy(s, length(s) + 1 - l, l);

end;

{ Convert a character sequence to a sequence of codewords.
   Pass the number of data columns to put in each row (between 1 and 30). }

procedure TPDF417.PDF417_compact_text(var bytes: TByteVector; var controlBlock: TVector; datacols: Integer; var res: TVector);
var
  ECLen: Integer;
  outlen: Integer;
  outrows: Integer;
  currentSubMode: string;
  newSubMode: string;
  p: Integer;
  code: Integer;
  defaultM: string;
  outa: TVector;
  outp: Integer;
  inp: Integer;
  processed: boolean;
  previousINP: Integer;
  previousOUTP: Integer;
  datalen: Integer;
  padChars: Integer;

  startOffset: Integer;
  maxData: Integer;
  maxWords: Integer;
  dummy: Integer;
  i: Integer;
  h: Integer;
begin

  EClen := round(intPower(2, (PDFECLevel + 1))); { Number of codewords for error correction }
  //      outlen:=0;
  currentSubMode := 'A';
  newSubMode := 'A';
  //      p:=0;
  //      code:=0;
  defaultM := 'A';

  { Check args }
  if (datacols < 1) or (datacols > 30) then
    datacols := 1;

  startOffset := 0;

  maxWords := 928;
  //    maxData:=928;

  if (FPDFMacroSegment > 0) then
    startOffset := FPDFPointerNextData[FPDFMacroSegment];
  if (FPDFMaxRows > 90) then
    FPDFMaxRows := 90;
  if (FPDFMaxRows > 0) then
    maxWords := datacols * FPDFMaxRows;

  maxData := maxWords - EClen - length(controlBlock);

  { Allocate the codeword array }
  setlength(outa, 1000 + (length(bytes) * 3));

  inp := startOffset;
  outp := 0;
  //    processed:=false;
  //    previousINP:=0;
  //    previousOUTP:=0;

  while inp < length(bytes) do
  begin

    previousINP := inp;
    previousOUTP := outp;

    p := findChar('' + chr(bytes[inp]));

    inp := inp + 1;

    if (p >= 0) then
    begin

      { if submode B is now default then mode A is active only for one char }
      if ((defaultM = 'B') and (currentSubMode = 'A')) then
        currentSubMode := 'B';

      newSubMode := textCodes[p, 1];

      val(copy(newSubMode, 2, length(newSubMode)), code, dummy);
      newSubMode := '' + newSubMode[1];

      processed := false;

      { we are in right mode  }
      if (newSubMode = currentSubMode) then
      begin
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
      end;

      { 29     }
      if ((newSubMode = 'D') and (not processed)) then
      begin
        outa[outp] := 29;
        outp := outp + 1;
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
      end;

      { 28 }
      if ((newSubMode = 'C') and (currentSubMode <> 'C') and (not processed)) then
      begin
        outa[outp] := 28;
        outp := outp + 1;
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
        currentSubMode := 'C';
      end;

      { 27    }
      if ((newSubMode = 'B') and (currentSubMode <> 'B') and (not processed)) then
      begin
        outa[outp] := 27;
        outp := outp + 1;
        outa[outp] := code;
        outp := outp + 1;
        processed := true;
        currentSubMode := 'B';
        defaultM := 'B';
      end;

      { back to default}
      if ((newSubMode = 'A') and (currentSubMode <> 'A') and (not processed)) then
      begin
        if (currentSubMode = 'B') then
        begin
          outa[outp] := 27;
          outp := outp + 1;
        end;
        if (currentSubMode = 'C') then
        begin
          outa[outp] := 28;
          outp := outp + 1;
          defaultM := 'A';
        end;
        outa[outp] := code;
        outp := outp + 1;
        //			processed:=true;
        currentSubMode := 'A';
      end;

    end;

    if (ceil((outp / 2) + 1) >= maxData) then
    begin
      inp := previousINP;
      outp := previousOUTP;
      break;
    end;

  end;

  { add pad char 29}
  if ((outp mod 2) <> 0) then
  begin
    outa[outp] := 29;
    outp := outp + 1;
  end;

  { remember pointer}
  FPDFPointerNextData[FPDFMacroSegment + 1] := inp;

  outlen := (outp div 2) + 1 + EClen + length(controlBlock);

  dataLen := (outp div 2) + 1;

  { Pad to an integer number of rows, at least 3 }
  outrows := outlen div datacols;
  if ((outlen mod datacols) <> 0) then
    outrows := outrows + 1;
  if (outrows < 3) then
    outrows := 3;
  if (outrows > 90) then
    exit;

  if (outrows > FPDFRows) then
    FruntimeRows := outrows
  else
  begin
    outrows := FPDFRows;
    FruntimeRows := FPDFRows;
  end;

  outlen := outrows * datacols;

  { max symbol size }
  if (outlen > 928) then
  begin
    //System.out.println("Too many codewords on symbol (max. is 928)");
    exit;
  end;

  { Do padding }
  padChars := (outlen - EClen - length(controlBlock) - dataLen);
  for i := 0 to padChars - 1 do
  begin
    outa[outp] := 30;
    outp := outp + 1;
    outa[outp] := 0;
    outp := outp + 1;
  end;

  { copy to result array }
  setlength(res, outlen);

  { length descriptor}
  res[0] := outlen - EClen;

  for i := 1 to outp do
    if (((i - 1) mod 2) = 0) then
      res[((i - 1) div 2) + 1] := outa[i - 1]
    else
      res[(i div 2)] := (res[((i - 1) div 2) + 1] * 30) + outa[i - 1];

  { add control block }
  for h := 0 to length(controlBlock) - 1 do
    res[outlen - EClen - length(controlBlock) + h] := controlBlock[h];

  genEC(res, length(res) - EClen);

  // debug out
  //String d="";
  //for (int h=0;h<out.length;h++) d=d+";"+out[h];
  //System.out.println(d);

end;

function TPDF417.getCoef(i: Integer; j: Integer): Integer;
begin

  //result:=coef0[j];

  case i of
    0: result := coef0[j];
    1: result := coef1[j];
    2: result := coef2[j];
    3: result := coef3[j];
    4: result := coef4[j];
    5: result := coef5[j];
    6: result := coef6[j];
    7: result := coef7[j];
    8: result := coef8[j];

  end;

end;

{ Calculate the error correction/detection info.  The first len elements
   of data are the data and padding, the next EClen elements are where
   we put the EC info. }

procedure TPDF417.genEC(var data: TVector; len: Integer);
var
  ECLen: Integer;
  i: Integer;
  c: TVector;
  t1, t2, t3: Integer;
  j: Integer;
begin

  ECLen := round(intPower(2, (FPDFECLevel + 1))); { Number of codewords for error correction }
  setlength(c, ECLen);

  { Initialize }
  for i := 0 to ECLen - 1 do
    c[i] := 0;

  { Load up with data }
  for i := 0 to len - 1 do
  begin

    t1 := (data[i] + c[ECLen - 1]) mod 929;

    for j := (ECLen - 1) downto 1 do
    begin
      t2 := (t1 * getCoef(FPDFECLevel, j)) mod 929;
      t3 := 929 - t2;

      c[j] := (c[j - 1] + t3) mod 929;
    end;

    t2 := (t1 * getCoef(FPDFECLevel, 0)) mod 929;
    t3 := 929 - t2;
    c[0] := (t3 mod 929);
  end;

  { complement}
  for j := (ECLen - 1) downto 0 do
    if (c[j] <> 0) then
      c[j] := 929 - c[j];

  { move EC to data array}
  for i := 0 to ECLen - 1 do
    data[len + i] := c[ECLen - (i + 1)];

end;

constructor TPDF417.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  //MessageDlg('RPDF417 for Delphi. Trial Version.', mtInformation, [mbOk], 0);
  resetMacroPDF();
  FPDFRows := 0;
  FMacroPDFLastSegment := false;
  FPDFMaxRows := 0;
  FruntimeRows := 0;
  FPDFColumns := 10;
  FPDFECLevel := 0;
  FPDFMode := PDF_BINARY;
  FPDFMacroSegment := -1;
  FPDFMacroSegmentCount := -1;
  FPDFMacroFileName := '';
  FPDFMacroTimeStamp := '';
  FPDFMacroSender := '';
  FPDFMacroAddresse := '';
  FPDFMacroFileSize := 0;
  FBarColor := clBlack;
  FBackColor := clWhite;
  FCode := 'This is a PDF417 Barcode';
  FTopMargin := 10;
  FLeftMargin := 10;
  FBarWidthPixels := 1;
  FBarHeightPixels := 7;
  FPDFTruncated := false;
  height := 200;
  width := 200;
  OffsetX := 0;
  OffsetY := 0;
  FAutoFit := true;
end;

end.

