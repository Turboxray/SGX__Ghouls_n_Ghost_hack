

import argparse
import sys
from PIL import Image   # 'pip install pillow' needed to install PIL library

HEXbase = 16
DECbase = 10
INT_MAX = 2**32 - 1
INT_MIN = (INT_MAX) / -2 - 1
OP_RTS  = 0x60
OP_ST1  = 0x13
OP_ST2  = 0x23
SPR_PLANAR = 0
SPR_OPEMB  = 1


class ConvertTMX():

    def __init__(self, args):
        self.args = args

    def process(self):
    # Read image
        args = self.args
        self.img = Image.open(args.filein)
        self.img_arr = self.img.load()


        sprite_planar_array = []
        sprite_opEmb_array  = []
        opEmb_offset = ''

        opEmb_offset += f"    .dw ${hex(len(sprite_opEmb_array)).split('0x')[1]}\n"
        for cell_row in range(runOptions['cellSizeY']):
            for cell_col in range(runOptions['cellSizeX']):
                sprite_cell = self.getSpriteCellData(cell_row, cell_col)
                sprite_planar_array += sprite_cell[SPR_PLANAR]
                sprite_opEmb_array  += sprite_cell[SPR_OPEMB]
        sprite_opEmb_array.append(OP_RTS)


        with open('planar.bin','wb') as fout:
            fout.write(bytearray(sprite_planar_array))

        if self.runOptions['opEmbed']:
            with open('opEmbedded.bin','wb') as fout:
                fout.write(bytearray(sprite_opEmb_array))
            with open('opEmbedded.inc','w') as fout:
                fout.write(opEmb_offset)

        if self.runOptions['outputPal']:
            with open('output.pce.pal','wb') as pout:
                pout.write(bytearray(self.getPal()))
            with open('output.rgb.act','wb') as pout:
                pout.write(bytearray(self.img.getpalette()[0:16]))
            with open('output.riff.pal','wb') as pout:
                pout.write(bytearray(self.getRIFFpal()))

        return True

    def getRIFFpal(self):

        riff_header = [0x52, 0x49, 0x46, 0x46,
                       0x10, 0x04, 0x00, 0x00,
                       0x50, 0x41, 0x4c, 0x20,
                       0x64, 0x61, 0x74, 0x61,
                       0x04, 0x04, 0x00, 0x00,
                       0x00, 0x03, 0x00, 0x01]

        blank_entries = [0] * (256-16) * 4

        rgba_pal = [] + riff_header
        pal = self.img.getpalette()

        for color in range(16):
            rgba_pal.append(pal[(color * 3) + 0])
            rgba_pal.append(pal[(color * 3) + 1])
            rgba_pal.append(pal[(color * 3) + 2])
            rgba_pal.append(0)

        rgba_pal += blank_entries

        return rgba_pal

    def getPal(self):
        pce_pal_arr = []
        pal = self.img.getpalette()
        for color in range(16):
            cRed   = pal[(color * 3) + 0] >> 5
            cGreen = pal[(color * 3) + 1] >> 5
            cBlue  = pal[(color * 3) + 2] >> 5

            pce_GRB_lsb = ((cGreen & 0x03) << 6)  + (cRed << 3) + cBlue
            pce_GRB_msb = (cGreen >> 2)
            pce_pal_arr.append(pce_GRB_lsb)
            pce_pal_arr.append(pce_GRB_msb)

        return pce_pal_arr


    def getSpriteCellData(self, cell_row, cell_col):

        pixel_arr = []
        planar_arr = [0] * 128
        opEmb_arr = []

        # get individual 16x16 cell
        for row_px in range(16):
            for col_px in range(16):
                y_offset = (cell_row * 16) + row_px
                x_offset = (cell_col * 16) + col_px
                pixel_arr.append(self.img_arr[x_offset,y_offset])

        # # convert cell into planar format
        for row in range(16):
            for col in range(16):
                offset = (row*16) + col
                p = pixel_arr[offset]

                byte_offset = ((col>>3) + 1) & 0x01
                planar_arr[(row * 2) + 0 + byte_offset ] <<= 1
                planar_arr[(row * 2) + 0 + byte_offset ] |= p & 0x01
                p >>= 1
                planar_arr[(row * 2) + 32 + byte_offset ] <<= 1
                planar_arr[(row * 2) + 32 + byte_offset ] |= p & 0x01
                p >>= 1
                planar_arr[(row * 2) + 64 + byte_offset ] <<= 1
                planar_arr[(row * 2) + 64 + byte_offset ] |= p & 0x01
                p >>= 1
                planar_arr[(row * 2) + 96 + byte_offset ] <<= 1
                planar_arr[(row * 2) + 96 + byte_offset ] |= p & 0x01
                p >>= 1

        # embedded opcode array
        for i in range(0,128,2):
            lsb = planar_arr[i]
            msb = planar_arr[i+1]

            if self.runOptions['opEmbComp'] and (i > 0):
                if lsb != planar_arr[i-2]:
                    opEmb_arr.append(OP_ST1)
                    opEmb_arr.append(lsb)
            else:
                opEmb_arr.append(OP_ST1)
                opEmb_arr.append(lsb)

            opEmb_arr.append(OP_ST2)
            opEmb_arr.append(msb)


        return (planar_arr, opEmb_arr)


#.....................................
# END CLASS


def auto_int(val):
    val = int(val, (DECbase,HEXbase)['0x' in val])
    return val

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='PCE Sprite sheet converter',
                                      formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    runOptionsGroup = parser.add_argument_group('Run options', 'Run options for Sprite sheet converter')
    runOptionsGroup.add_argument('--filein',
                                 '-in',
                                 required=True,
                                 help='Sprite sheet to convert. PNG, BMP, etc. 8bit palette index format.')
    runOptionsGroup.add_argument('--starting_cell_num',
                                 '-scn',
                                 type=auto_int,
                                 default=0,
                                 help='The first 16x16 cell in the sprite sheet to start conversion.')
    runOptionsGroup.add_argument('--last_cell_num',
                                 '-lcn',
                                 type=auto_int,
                                 default=-1,
                                 help='The last 16x16 cell in the sprite sheet to start conversion.')
    runOptionsGroup.add_argument('--op_embed',
                                 '-op',
                                 action='store_true',
                                 default=False,
                                 help='Output an ST1/ST2 embedded opcode format.')
    runOptionsGroup.add_argument('--op_embed_cmp',
                                 '-opc',
                                 action='store_true',
                                 default=False,
                                 help='Output an ST1/ST2 embedded opcode format with redundant opcode removal.')
    runOptionsGroup.add_argument('--output_pal',
                                 '-pal',
                                 action='store_true',
                                 default=False,
                                 help='Output 16 color PCE formatted pal.')
    args = parser.parse_args()

    runOptions = {}
    runOptions['filein']    = args.filein
    runOptions['startCell'] = args.starting_cell_num
    runOptions['endCell']   = args.last_cell_num
    runOptions['opEmbed']   = args.op_embed
    runOptions['opEmbComp'] = args.op_embed_cmp
    runOptions['outputPal'] = args.output_pal

    sys.exit( ConvertTMX(args).process() == False)
