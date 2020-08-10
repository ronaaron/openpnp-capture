# makefile for openpnp-captur, macOS

all: mac/libopenpnp-capture.a

CC = clang
CXX = clang++
CFLAGS = -stdlib=libc++ -std=c++11
CFLAGS += -O2 -D__BUILDTYPE__='"release"'
CFLAGS += -pipe -U_FORTIFY_SOURCE -mmacosx-version-min=10.7 -fPIE -I include -I . -D__PLATFORM__='"OSX 64 bit release"'

SRC = 	mac/platformcontext.mm mac/uvcctrl.mm mac/platformstream.mm \
	common/context.cpp common/libmain.cpp common/logging.cpp \
	common/stream.cpp

OBJS = $(subst .cpp,.o,$(subst .mm,.o,$(SRC)))

mac/libopenpnp-capture.a: $(OBJS)
	ar rc $@ $(OBJS)
	@ranlib $@

clean:
	@rm $(OBJS) mac/libopenpnp-capture.a

%.o: %.cpp 
	$(info compiling $<)
	@$(CXX) $(CFLAGS) -c -o $@ $< 
	
%.o: %.mm
	$(info compiling $<)
	@$(CXX) $(CFLAGS) -c -o $@ $< 
