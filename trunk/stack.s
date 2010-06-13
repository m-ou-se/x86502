# File: stack.s
# Global functions: push_byte, push_word, pop_byte, pop_word
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


.global push_byte
.global push_word
.global pop_byte
.global pop_word

.text
	
	#--------------------
	# push_byte
	# Push the contents of AL on the 6502 stack. It does not modify EAX.
	#--------------------
	push_byte:
		movzbl S, %ecx                   # load the stack pointer into ECX ...
		movb %al, MEM+0x0100(%ecx)       #  ... store AL at that location on the 6502 stack ...
		decb S                           #  ... and decrease the stack pointer
		ret
		
	
	#--------------------
	# push_word
	# Push the contents of AX on the 6502 stack.
	#--------------------
	push_word:
		movw %ax, %dx                    # /  \ 
		movb %dh, %al                    # |  / -> the byte to be pushed (the high byte of the word)
		call push_byte                   # \ push the byte
		movb %dl, %al                    # /  -> the byte to be pushed (the low byte of the word)
		jmp push_byte                    # \ push the byte
		
	
	#--------------------
	# pop_byte
	# Pop a byte from the stack and return it.
	#--------------------
	pop_byte:
		incb S                           # increase the stack pointer so it points to our to be pushed byte ...
		movzbl S, %ecx                   #  ... load the stack pointer into ECX ...
		movzbl MEM+0x0100(%ecx), %eax    #  ... and move the byte at that location on the 6502 stack into EAX
		ret
		
	
	#--------------------
	# pop_word
	# Pop a word from the stack, in reverse order of pushing it (high byte first), and return it.
	#--------------------
	pop_word:
		call pop_byte                    # \ pop the lower byte ...
		movb %al, %dl                    # / 
		call pop_byte                    # \ pop the higher byte ...
		movb %al, %dh                    # / 
		movzwl %dx, %eax                 # return the word as a whole
		ret
		
