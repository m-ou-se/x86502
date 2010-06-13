# File: gdt.s
# Global functions: init_gdt
# Global variables: -
# Description: Everything related to the Global Descriptor Table is located in this file.

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


.global init_gdt

.text
	
	gdt: # global descriptor table, see http://wiki.osdev.org/GDT
		.quad 0x0000000000000000   #  0 - unused 'null' section
		.quad 0x00CF9A000000FFFF   #  8 - code section (0x00000000 - 0xFFFFFFFF, executable)
		.quad 0x00CF92000000FFFF   # 16 - data section (0x00000000 - 0xFFFFFFFF, readable, writable)
	gdt_end:
	
	gdt_ptr: # pointer to the GDT
		.short (gdt_end - gdt) - 1 # the size of the GDT, minus one
		.long gdt                  # the location of the GDT
		
	
	#--------------------
	# init_gdt
	# Initialize the Global Descriptor Table.
	#--------------------
	# Note: see http://wiki.osdev.org/GDT
	init_gdt:
		lgdt gdt_ptr
		
		movw $16, %ax          # load the right section (16 for the data section) ...
		movw %ax, %ds          #  ... into DS,
		movw %ax, %es          #  ... ES,
		movw %ax, %fs          #  ... FS,
		movw %ax, %gs          #  ... GS,
		movw %ax, %ss          #  ... and SS. (these are all sections except CS, the code section)
		
		ljmp $8, $init_gdt_end # load the right section (8 for the code section) into CS
		
	init_gdt_end:
		ret
		
