# File: 6502keyboard.s
# Global functions: init_6502keyboard
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


.global init_6502keyboard

.text
	
	#--------------------
	# init_6502keyboard
	# Registers a timer to process the keyboard queue
	#--------------------
	init_6502keyboard:
		pushl $100                  # /  -> the frequency (100Hz)
		pushl $update_6502keyboard  # |  -> the handler routine
		call add_timer_event        # \ add the timer event
		addl $8, %esp               # (cleanup the stack)
		ret
		
	#--------------------
	# update_6502keyboard
	# Check if 6502 is ready to handle a scancode
	# and pass it one if it is
	#--------------------
	update_6502keyboard:
		movb MEM+0xDFFF, %al        # load 6502 keyboard byte in AL ...
		testb %al,  %al             #  ... test ...
		jnz update_6502keyboard_end #  ... and do nothing if byte is not zero
		
		call get_scancode           # (otherwise) get the next scancode ...
		movb %al, MEM+0xDFFF        #  ... and store it in the 6502 memory
	update_6502keyboard_end:
		ret
		