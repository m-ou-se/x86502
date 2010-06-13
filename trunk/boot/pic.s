# File: pic.s
# Global functions: init_pic, enable_irq, disable_irq
#                   end_of_irq0, end_of_irq1, end_of_irq2, end_of_irq3, end_of_irq4, end_of_irq5, end_of_irq6, end_of_irq7
#                   end_of_irq8, end_of_irq9, end_of_irqA, end_of_irqB, end_of_irqC, end_of_irqD, end_of_irqE, end_of_irqF
# Global variables: -
# Description: Everything related to the Programmable Interrupt Controllers is located in this file.

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


.global init_pic, enable_irq, disable_irq
.global end_of_irq0, end_of_irq1, end_of_irq2, end_of_irq3, end_of_irq4, end_of_irq5, end_of_irq6, end_of_irq7
.global end_of_irq8, end_of_irq9, end_of_irqA, end_of_irqB, end_of_irqC, end_of_irqD, end_of_irqE, end_of_irqF

.text
	
	#--------------------
	# init_pic
	# Initialize the Programmable Interrupt Controllers.
	# IRQs are mapped to interrupts 0x20..0x2F.
	#--------------------
	# Note: See http://wiki.osdev.org/PIC
	init_pic:
		movb $0x11, %al # init command, ICW4 present
		outb %al, $0x20 # PIC1 command port
		outb %al, $0xA0 # PIC2 command port
		
		movb $0x20, %al # interrupt offset
		outb %al, $0x21 # PIC1 data port
		movb $0x28, %al # interrupt offset
		outb %al, $0xA1 # PIC2 data port
		
		movb $0x04, %al # IR4 is connected to a slave (PIC2)
		outb %al, $0x21 # PIC1 data port
		movb $0x02, %al # slave ID 2
		outb %al, $0xA1 # PIC2 data port
		
		movb $0x01, %al # 8086/88 mode
		outb %al, $0x21 # PIC1 data port
		movb $0x01, %al # 8086/88 mode
		outb %al, $0xA1 # PIC2 data port
		
		movb $0xFF, %al # disable all IRQs
		outb %al, $0x21 # PIC1 data port
		movb $0xFF, %al # disable all IRQs
		outb %al, $0xA1 # PIC2 data port
		
		pushl $spurious_interrupt_handler
		pushl $7
		call set_irq_handler
		addl $4, %esp
		pushl $15
		call set_irq_handler
		addl $8, %esp
		
		ret
		
	
	spurious_interrupt_handler:
		iret
	
	#--------------------
	# disable_irq(irq_index)
	# Disable a specific irq.
	#--------------------
	# Note: See http://wiki.osdev.org/PIC
	disable_irq:
		movw $0x21, %dx   # PIC1 data port
		movb 4(%esp), %al # IRQ index
		shlb $4, %al      # \ if the IRQ index ...
		andb $0x80, %al   # |  ... is higher than 8 ...
		addb %al, %dl     # /  ... use 0xA1 (PIC2) instead of 0x21 (PIC1)
		movb 4(%esp), %cl # \ IRQ index ...
		andb $0b0111, %cl # /  ... modulo 8
		movb $1, %bl      # \ create the right mask for this IRQ index
		shlb %cl, %bl     # / (set turn that bit, clear the rest)
		inb %dx, %al      # \ set the selected bit ...
		orb %bl, %al      # |  ... in the data register ...
		outb %al, %dx     # /  ... of the right PIC
		ret
		
	#--------------------
	# enable_irq(irq_index)
	# Enable a specific irq.
	#--------------------
	# Note: See http://wiki.osdev.org/PIC
	enable_irq:
		movw $0x21, %dx   # PIC1 data port
		movb 4(%esp), %al # IRQ index
		shlb $4, %al      # \ if the IRQ index ...
		andb $0x80, %al   # |  ... is higher than 8 ...
		addb %al, %dl     # /  ... use 0xA1 (PIC2) instead of 0x21 (PIC1)
		movb 4(%esp), %cl # \ IRQ index ...
		andb $0b0111, %cl # /  ... modulo 8
		movb $1, %bl      # \ create the right mask for this IRQ index
		shlb %cl, %bl     # / (set turn that bit, clear the rest)
		inb %dx, %al      # \ clear the selected bit ...
		notb %bl          # |  ... in the ...
		andb %bl, %al     # |  ... data register ...
		outb %al, %dx     # /  ... of the right PIC
		ret
		
	#--------------------
	# end_of_irqN
	# Acknowledge a specific irq.
	#--------------------
	# Note: See http://wiki.osdev.org/PIC
	end_of_irq0:
	end_of_irq1:
	end_of_irq2:
	end_of_irq3:
	end_of_irq4:
	end_of_irq5:
	end_of_irq6:
	end_of_irq7:
		# IRQs 0..7 are controlled by PIC1
		pushl %eax
		movb $0x20, %al # end of interrupt command
		outb %al, $0x20 # PIC1 command port
		popl %eax
		iret
	end_of_irq8:
	end_of_irq9:
	end_of_irqA:
	end_of_irqB:
	end_of_irqC:
	end_of_irqD:
	end_of_irqE:
	end_of_irqF:
		# IRQs 8..F are controlled by PIC2 via PIC1
		pushl %eax
		movb $0x20, %al # end of interrupt command
		outb %al, $0xA0 # PIC2 command port
		outb %al, $0x20 # PIC1 command port
		popl %eax
		iret
		
