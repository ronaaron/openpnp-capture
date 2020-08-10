# makefile for openpnp-captur, macOS

BUILDOS=$(shell uname|cut -c 1-4)
# $(info BUILDOS=$(BUILDOS))

ifeq ($(BUILDOS),MSYS)
MINGW=/c/tdm/bin/
else
MINGW=wine64 c:/tdm-gcc-64/bin/
endif
 

all: win/libopenpnp-capture.a
BITS?=64
PLATFORM="Win $(BITS) bit release"
CC = $(MINGW)gcc
CXX = $(MINGW)g++
AR = $(MINGW)ar
RANLIB = $(MINGW)ranlib
CFLAGS = -std=gnu++11  -Wno-multichar -DMINGW
ifeq ($(BITS),32)
CFLAGS += -m32
else
CFLAGS += -m64
endif

CFLAGS += -O2 -D__BUILDTYPE__='"release"'
CFLAGS += -pipe -U_FORTIFY_SOURCE -DWIN32 -DWIN64 -DUNICODE -D_UNICODE  -DSTRSAFE_NO_DEPRECATE
CFLAGS += -Iinclude -I. -D__PLATFORM__='$(PLATFORM)'
CFLAGS += -falign-functions -falign-loops -msse2 -mwin32

SRC = 	win/platformcontext.cpp win/platformstream.cpp \
	common/context.cpp common/libmain.cpp common/logging.cpp \
	common/stream.cpp

OBJS = $(subst .cpp,.o,$(subst .mm,.o,$(SRC)))

win/libopenpnp-capture.a: $(OBJS)
	$(AR) rc $@ $(OBJS)
	@$(RANLIB) $@

clean:
	@rm $(OBJS) win/libopenpnp-capture.a

%.o: %.cpp 
	$(info compiling $<)
	@$(CXX) $(CFLAGS) -c -o $@ $< 
	
%.o: %.mm
	$(info compiling $<)
	@$(CXX) $(CFLAGS) -c -o $@ $< 
