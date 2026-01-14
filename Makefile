# Define compilers and tools needed
ASM = nasm
LD = ld
ASMFLAGS = -f elf32
LDFLAGS = -m elf_i386

TARGET = calculator
OBJS = calculator.o functions.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJS)

# Compile calculator.asm
calculator.o: calculator.asm
	$(ASM) $(ASMFLAGS) calculator.asm -o calculator.o

# Compile functions.asm
functions.o: functions.asm
	$(ASM) $(ASMFLAGS) functions.asm -o functions.o

clean:
	rm -f $(TARGET) $(OBJS)