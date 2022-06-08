

SRC:=$(patsubst .src//%,%,$(shell find .src/ -name "*.c"))
OBJ:=$(patsubst %.c,build/%.o,$(SRC))

ifneq ($(shell cat build/last),$(notdir $(realpath .src)))
  $(shell rm -rf build && mkdir -p build && echo $(notdir $(realpath .src)) > build/last)
endif

CFLAGS:=$(CFLAGS) -g

include $(wildcard .src/*.mk)

build/%.o: .src/%.c
	mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c -MM $< | sed "s|\(.*\):|build/\1:|g" | sed "s|^.*: \\\\||g" > build/$*.d
	@cat build/$*.d | sed "s|^.*:||g" | sed "s|[ \]*\([^ \][^ \]*\)[ \]*|\1:\n|g" >> build/$*.d
	$(CC) $(CFLAGS) -c -o $@ $<

build/program: $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

clean:
	rm -rf build


include $(shell find build/ -name "*.d")