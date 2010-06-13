# File: idt.s
# Global functions: init_idt, set_interrupt_handler, clear_interrupt_handler, set_irq_handler, clear_irq_handler
# Global variables: -
# Description: Everything related to the Interrupt Descriptor Table is located in this file.

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


.global init_idt, set_interrupt_handler, clear_interrupt_handler, set_irq_handler, clear_irq_handler

.bss
	
	idt:
		.skip 0x800 # 256 entries * 8 bytes per entry
		
	
.text
	
	idt_ptr: # pointer to the IDT
		.short 0x800 - 1           # the size of the IDT, minus one
		.long idt                  # the location of the IDT
		
	
	#--------------------
	# init_idt
	# Initialize the Interrupt Descriptor Table.
	#--------------------
	# Note: see http://wiki.osdev.org/IDT
	init_idt:
		lidt idt_ptr
		ret
		
	
	#--------------------
	# set_interrupt_handler(interrupt_index, handler_address)
	# Create/update an entry in the IDT for an interrupt specified by its index.
	#--------------------
	set_interrupt_handler:
		movl 4(%esp), %ecx           # the interrupt index
		movw 8(%esp), %ax            # \ store the low word of the handler address ...
		movw %ax, 0+idt(,%ecx,8)     # /  ... in the right place of the IDT entry
		movw 10(%esp), %ax           # \ store the high word of the handler address ...
		movw %ax, 6+idt(,%ecx,8)     # /  ... in the right place of the IDT entry
		movw %cs, %ax                # \ store the code segment selector ...
		movw %ax, 2+idt(,%ecx,8)     # /  ... in the right place of the IDT entry
		movw $0x8E00, 4+idt(,%ecx,8) # store the attributes (0x8E00: 32-bit interrupt gate) in the IDT entry
		ret
		
	
	#--------------------
	# clear_interrupt_handler(interrupt_index)
	# Remove an entry in the IDT for an interrupt specified by its index.
	#--------------------
	clear_interrupt_handler:
		movl 4(%esp), %ecx         # the interrupt index
		movw $0, 4+idt(,%ecx,8)    # store the attributes (0: not present) in the IDT entry
		ret
		
	
	#--------------------
	# set_irq_handler(irq_index, handler_address)
	# Create/update an entry in the IDT for an irq specified by its index.
	#--------------------
	set_irq_handler:
		movl 4(%esp), %ecx         # the IRQ index
		movl 8(%esp), %esi         # the handler address
		addl $0x20, %ecx           # IRQs are mapped to interrupts 0x20..0x2F
		pushl %esi                 # /  -> the handler address
		pushl %ecx                 # |  -> the interrupt index
		call set_interrupt_handler # \ set the interrupt handler
		addl $8, %esp              # (cleanup the stack)
		ret
		
	
	#--------------------
	# clear_irq_handler(irq_index)
	# Remove an entry in the IDT for an irq specified by its index.
	#--------------------
	clear_irq_handler:
		movl 4(%esp), %ecx           # the IRQ index
		addl $0x20, %ecx             # IRQs are mapped to interrupts 0x20..0x2F
		pushl %ecx                   # /  -> the interrupt index
		call clear_interrupt_handler # \ clear the interrupt handler
		addl $4, %esp                # (cleanup the stack)
		ret
		
