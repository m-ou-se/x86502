# File: timer.s
# Global functions: init_timer, add_timer_event, remove_timer_event, execute_timer_events
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


.global init_timer, add_timer_event, remove_timer_event, execute_timer_events

.equ number_of_timer_events, 16

.bss
	
	timer_events:
		.skip 16*number_of_timer_events   # dword handler_address, dword rate, dword counter, dword reserved (flags/mode ?)
	
.text
	
	#--------------------
	# init_timers
	# Initialize the timer interface.
	#--------------------
	init_timer:
		pushl $500                  # /  -> the frequency
		call set_timer_frequency    # \ set/update the timer frequency
		addl $4, %esp               # (cleanup the stack)
		
		pushl $timer_irq_handler    # /  -> the handler routine
		pushl $0                    # |  -> the IRQ index (0 for the timer IRQ)
		call set_irq_handler        # \ set/update the IRQ handler
		addl $8, %esp               # (cleanup the stack)
		
		pushl $0                    # /  -> the IRQ index
		call enable_irq             # \ enable the IRQ
		addl $4, %esp               # (cleanup the stack)
		
		ret
		
	
	#--------------------
	# add_timer_event(handler_address, frequency)
	#--------------------
	add_timer_event:
		movl $number_of_timer_events-1, %ecx
		
	add_timer_event_find_unused_timer:
		movl %ecx, %edx
		shll $4, %edx
		movl timer_events(%edx), %esi
		test %esi, %esi
		loopne add_timer_event_find_unused_timer
		
		jecxz add_timer_event_no_unused_timers_left
		
		movl %edx, %ecx
		
		cli
		movl 4(%esp), %eax
		movl %eax, timer_events(%ecx)
		movl $0, %edx
		movl $500, %eax
		divl 8(%esp)
		movl %eax, timer_events+4(%ecx)
		movl %eax, timer_events+8(%ecx)
		sti
		
		movl $1, %eax
		ret
		
	add_timer_event_no_unused_timers_left:
		movl $0, %eax
		ret
		
	
	#--------------------
	# remove_timer_event(handler_address)
	#--------------------
	remove_timer_event:
		movl $number_of_timer_events-1, %ecx
		
	remove_timer_event_find_timer:
		movl %ecx, %edx
		shll $4, %edx
		movl timer_events(%edx), %esi
		cmpl 4(%esp), %esi
		loopne remove_timer_event_find_timer
		
		movl $0, timer_events(%edx)
		
		ret
		
	
	#--------------------
	# execute_timer_events
	# Execute all timer events that are currently waiting to be executed.
	#--------------------
	execute_timer_events:
		movl $number_of_timer_events-1, %ecx
		
	execute_timer_events_loop:
		movl %ecx, %edx
		shll $4, %edx
		movl timer_events(%edx), %esi
		testl %esi, %esi
		jz execute_timer_events_loop_next
		
		movl timer_events+8(%edx), %ebx
		testl %ebx, %ebx
		jnz execute_timer_events_loop_next
		
		movl timer_events+4(%edx), %eax
		movl %eax, timer_events+8(%edx)
		
		pushl %ecx
		call * %esi
		popl %ecx
		
	execute_timer_events_loop_next:
		loop execute_timer_events_loop
		
		ret
		
	
	#--------------------
	# timer_irq_handler
	# This is the IRQ handler that handles the timer IRQ.
	#--------------------
	timer_irq_handler:
		pushal
		movl $number_of_timer_events-1, %ecx
		
	timer_irq_handler_loop:
		movl %ecx, %edx
		shll $4, %edx
		movl timer_events(%edx), %esi
		testl %esi, %esi
		jz timer_irq_handler_loop_next
		
		movl timer_events+8(%edx), %ebx
		testl %ebx, %ebx
		jz timer_irq_handler_loop_next
		decl %ebx
		movl %ebx, timer_events+8(%edx)
		
	timer_irq_handler_loop_next:
		loop timer_irq_handler_loop
		
		popal
		jmp end_of_irq0
		
