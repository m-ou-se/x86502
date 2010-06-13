# File: 6502vga.s
# Global functions: init_6502vga
# Global variables: -

# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.


.global init_6502vga, update_6502vga

.equ VGA_6502,            0xD000
.equ VGA_DIRTY_6502,      0xDFFE
.equ VGA_CHAR_INDEX_6502, 0xDFFD
.equ VGA_CHAR_6502,       0xDFA0
.equ vga_memory,          0xB8000

.text
	
	#--------------------
	# init_6502vga
	# Registers a timer to process VGA output
	#--------------------
	init_6502vga:
		pushl $35                   # /  -> the frequency (in Hertz)
		pushl $update_6502vga       # |  -> the handler routine
		call add_timer_event        # \ add the timer event
		addl $8, %esp               # (cleanup the stack)
		ret
		
	
	#--------------------
	# update_6502vga
	# Process VGA outut
	#--------------------
	update_6502vga:
		movzbl MEM+VGA_CHAR_INDEX_6502, %ecx  # read the replace character index
		test %ecx, %ecx                       # test it's value
		jz update_6502vga_no_character        # skip the character replace if it's zero
		
		shll $5, %ecx                         # multiply the index by 32 to get the character offset
		
		# Miscellaneous Graphics Register
		movb $0x06, %al        # select correct graph register
		movw $0x3CE, %dx
		outb %al, %dx
		movb $0b1100, %al
		movw $0x3CF, %dx
		outb %al, %dx
		
		# Sequencer Memory Mode Register
		movb $0x04, %al      # sequencer register index
		movw $0x3C4, %dx     # sequencer address register port
		outb %al, %dx        # output it
		movb $0b0100, %al    # new value
		movw $0x3C5, %dx     # sequencer data register port
		outb %al, %dx        # output it
		
		# Set sequencer register index to 0x02: Map Mask Register
		movb $0x02, %al      # sequencer register index
		movw $0x3C4, %dx     # sequencer address register port
		outb %al, %dx        # output it
		# Select map 2 only
		movb $0b1100, %al    # select map 2 only
		movw $0x3C5, %dx     # sequencer data register port
		outb %al, %dx        # output it
		
		# Write character of 16 pixels high
		leal MEM+VGA_CHAR_6502, %esi
		leal vga_memory(,%ecx), %edi
		movl $16, %ecx
		cld
	update_6502vga_copy_loop:
		movsb
		loop update_6502vga_copy_loop
		
		# Miscellaneous Graphics Register
		movb $0x06, %al        # select correct graph register
		movw $0x3CE, %dx
		outb %al, %dx
		movb $0b1110, %al
		movw $0x3CF, %dx
		outb %al, %dx
		
		# Sequencer Memory Mode Register
		movb $0x04, %al      # sequencer register index
		movw $0x3C4, %dx     # sequencer address register port
		outb %al, %dx        # output it
		movb $0b0000, %al    # new value
		movw $0x3C5, %dx     # sequencer data register port
		outb %al, %dx        # output it
				
		# Set sequencer register index to 0x02: Map Mask Register
		movb $0x02, %al      # sequencer register index
		movw $0x3C4, %dx     # sequencer address register port
		outb %al, %dx        # output it
		# Select map 0 and 1
		movb $0b0011, %al    # select plane 0 and 1
		movw $0x3C5, %dx     # sequencer data register port
		outb %al, %dx        # output it
	
		movb $0, MEM+VGA_CHAR_INDEX_6502 # reset the character index to 0
		ret
		
	update_6502vga_no_character:
		
		testb $0xFF, MEM+VGA_DIRTY_6502  # test the VGA dirty bit ...
		jz update_6502vga_end            #  ... and skip the update if it isn't set
		
		# Wait for vertical retrace to end
		movw $0x3DA, %dx                 # move port address of VGA status register to DX
	update_6502vga_wait_vsync_1:
		inb %dx, %al                     # read the current VGA status register
		test $0b00001000, %al            # check bit 3 ...
		jnz update_6502vga_wait_vsync_1  #  ... and loop until it's 0
		
		# Wait for vertical retrace to start
	update_6502vga_wait_vsync_2:
		inb %dx, %al                     # read the current VGA status register
		test $0b00001000, %al            # check bit 3 ...
		jz update_6502vga_wait_vsync_2   #  ... and loop until it's 1
		
		# Copy the memory
		leal MEM+VGA_6502, %esi          # /  -> the address of the 6502 video memory
		leal 0xB8000, %edi               # |  -> the address of the x86 vga text memory
		movl $25*80, %ecx                # |  -> number of words (80*25: the entire vga text memory)
		cld                              # |  -> clear direction flag
		rep movsw                        # \ copy it
		
		movb $0, MEM+VGA_DIRTY_6502      # set the VGA dirty bit to 0
		
	update_6502vga_end:
		ret
		
