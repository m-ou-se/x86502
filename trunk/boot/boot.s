# File: boot.s
# Global functions: boot, halt
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


.global boot, halt

.bss
	
		.skip 0x0004000 # 16 KiB stack
	stack:
	
.text
	
	multiboot_header: # this header contains some magic values to let the bootloader (grub/lilo/whatever) find our entrypoint
		.long 0x1BADB002
		.long 0x00000000
		.long 0xE4524FFE
		
	#--------------------
	# boot
	# The entry point.
	#--------------------
	boot:
		
		# Set up our environment, gdt, idt, timers, input, output, etc.
		
		cli                     # turn off interrupts, we don't want to be interrupted while setting up our environment
		
		movl $stack, %esp       # set up the stack
		
		pushl $0                # \ clear ...
		popf                    # /  ... all flags
		
		call init_gdt           # load the GDT
		call init_idt           # load the IDT
		call init_pic           # initialize the PICs
		
		call init_timer         # initialize the timer
		
		sti                     # end of critical section, so interrupts can be enabled again
		
		call color_text_mode    # enter 16-color 80*25 VGA text mode
		call clear_screen       # clear the screen
		call hide_cursor        # hide the VGA text mode cursor
		
		call init_keyboard      # initialize the keyboard interface
		
		call init_6502vga       # initialize 6502 vga
		call init_6502keyboard  # initialize 6502 keyboard
		
		# Everything is set up, now start the 6502.
		
		call init               # initialize the 6502
		
	run:
	.rept 255                     # \
		call step                 # | let the 6502 execute 255 instructions ...
	.endr                         # /
		call execute_timer_events #  ... and execute the timed events (such as the vga update routine)
		jmp run                   # (forever)
		
	
	#--------------------
	# halt
	# Stop the processor.
	#--------------------
	halt:
		cli                     # turn off interrupts, we don't want to be awaken from death
		hlt                     # halt the CPU
		jmp halt                # die, again, if the CPU got out of the halt state (for example, by a NMI)
		
