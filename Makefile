OUT = breaknotifyd
CC ?= clang
FRAMEWORKS = -framework Foundation -framework Cocoa -framework AppKit -framework ScriptingBridge -framework Growl
LIBRARIES = -lobjc

CFLAGS := -ObjC -Wall -Werror -O2 $(CFLAGS)
LDFLAGS := $(LIBRARIES) $(FRAMEWORKS) $(LDFLAGS)
SOURCES := $(wildcard *.m */*.m)
OBJECTS := $(foreach file, $(SOURCES), $(basename $(file)).o)

.PHONY: all clean debug install

all: $(OBJECTS) $(OUT)

$(OBJECTS): %.o: %.m
	$(CC) $(CFLAGS) -include Prefix.h -c $< -o $@

$(OUT): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS) $(LDFLAGS)

clean:
	rm -rf $(OUT) $(OBJECTS) *~

debug: CFLAGS += -O0 -g -DDEBUG
debug: all

install: prefix ?= /usr/local
install: all
	install -d $(prefix)/bin
	install -d $(prefix)/share/$(OUT)
	install -m 0755 $(OUT) $(prefix)/bin
	install -m 0644 *.plist $(prefix)/share/$(OUT)
