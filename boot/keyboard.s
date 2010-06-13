# File: keyboard.s
# Global functions: init_keyboard, get_scancode
# Global variables: -
# Description: Everything related to the keyboard is located in this file.

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


.global init_keyboard, get_scancode

.equ keyboard_scancode_queue_size, 64

.bss
	
	keyboard_scancode_queue:
		.skip keyboard_scancode_queue_size
	
.text
	
	#--------------------
	# init_keyboard
	# register the keyboard IRQ handler
	#--------------------
	init_keyboard:
		pushl $keyboard_irq_handler # /  -> the handler routine
		pushl $1                    # |  -> the IRQ index (1 for the keyboard IRQ)
		call set_irq_handler        # \ set/update the IRQ handler
		addl $8, %esp               # (cleanup the stack)
		
		pushl $1                    # /  -> the IRQ index
		call enable_irq             # \ enable the IRQ
		addl $4, %esp               # (cleanup the stack)
		
		ret
		
	
	#--------------------
	# get_scancode
	# get a scancode from the queue and return it
	#--------------------
	get_scancode:
		pushl %esi
		pushl %edi
		movzbl keyboard_scancode_queue, %eax # return value (the scancode)
		leal keyboard_scancode_queue+1, %esi
		leal keyboard_scancode_queue,   %edi
		movl $keyboard_scancode_queue_size - 1, %ecx
		cld
		rep movsb
		popl %edi
		popl %esi
		ret
		
	
	#--------------------
	# keyboard_irq_handler
	# The keboard IRQ handler
	#--------------------
	# Note: See http://wiki.osdev.org/Keyboard
	keyboard_irq_handler:
		pushal
		
	keyboard_irq_handler_wait:
		inb $0x64, %al               # \ wait until ...
		testb $0b00000001, %al       # |  ... the keyboard controller ...
		jz keyboard_irq_handler_wait # /  ... is ready
		
		inb $0x60, %al               # read the scancode
		
		movl $-1, %ecx
	keyboard_irq_handler_find_end_of_buffer:
		incl %ecx
		cmpb $0, keyboard_scancode_queue(%ecx)
		jne keyboard_irq_handler_find_end_of_buffer
		
		cmpl $keyboard_scancode_queue_size-1, %ecx
		je keyboard_irq_handler_buffer_full
		
		movb %al, keyboard_scancode_queue(%ecx)
		jmp keyboard_irq_handler_end
		
	keyboard_irq_handler_buffer_full:
		
		# buffer full, last scancode is lost...
		
	keyboard_irq_handler_end:
		popal
		jmp end_of_irq1
		
