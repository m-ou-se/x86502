# File: read.s
# Global functions: read
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


.global read

.text
	
	#--------------------
	# read
	# Read the next instruction and its operand. PC, IR, IS, AM, II and OA will be updated.
	# PC will point to the next instruction.
	#--------------------
	
	read:
		# Load the next instruction
		
		movzwl PC, %ecx          # \ load the program counter into ECX
		movb MEM(%ecx), %al      # | load the instruction from the memory ...
		movb %al, IR             # / ... and store it in the instruction register
		
		incw PC                  # increment the program counter
		
		
		# Decode the instruction
		# (results of decoding are stored in IS, AM and II)
		
		# All instructions are in the form of aaabbbcc 
		# (the letters represent binary digits).
		# cc is either 00, 01, or 10 (0, 1 or 2), and
		# determines which set of instructions is used.
		# aaa tells which instruction in the selected set
		# is used. bbb tells which operand mode is
		# being used (also depends on the selected set).
		
		movb %al, %bl         # \ load 'cc' (the rightmost 2 bits of IR) ...
		andb $3, %bl          # |  ... into BL ...
		movb %bl, IS          # /  ... and store it in IS (current instruction set)
		
		movb %al, %bl         # \ load 'bbb'  ...
		shrb $2, %bl          # |  ... (three bits of IR after skipping the first two) ...
		andb $7, %bl          # |  ... into BL ...
		movb %bl, OM          # /  ... and store it in OM (current operand mode)
		
		shrb $5, %al          # \ load 'aaa' (skip the first 5 bits of IR) ...
		movb %al, II          # /  ... into II (current instruction index)
		
		
		# Load the address of the operand into OA.
		# This address will point outside of MEM when
		# the accumulator, the stack pointer or the 
		# branch address is the operand.
		# The PC will be incremented if needed.
		
		call getoperand          # \ get (a pointer to) the operand ...
		movl %eax, OA            # /  ... and store it in OA
		
		ret
		
