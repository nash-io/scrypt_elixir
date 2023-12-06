INC_CFG = c_src
INC_LIB = scrypt/lib 
INC_CPU = scrypt/libcperciva/cpusupport
INC_ALG = scrypt/libcperciva/alg
INC_UTIL = scrypt/libcperciva/util
INC_CRYPTO = scrypt/lib/crypto


SRC = scrypt/lib/crypto/crypto_scrypt.c \
      scrypt/lib/crypto/crypto_scrypt_smix.c \
	  scrypt/libcperciva/alg/sha256.c	\
	  scrypt/libcperciva/util/insecure_memzero.c \
	  scrypt/libcperciva/util/warnp.c \
      c_src/scrypt_nif.c 

ERTS_INCLUDE_PATH = $(shell erl -noshell -eval "io:format(\"~s/erts-~s/include/\", [code:root_dir(), erlang:system_info(version)]), halt().")
CFLAGS += -pthread -O3 -std=c99 -pedantic -Wall -g -O0 -I$(INC_CFG) \
			-I$(INC_LIB) \
			-I$(INC_CPU) \
			-I$(INC_ALG) \
			-I$(INC_UTIL) \
			-I$(INC_CRYPTO) \
			-DHAVE_CONFIG_H \
			-D_POSIX_C_SOURCE=200809L \
			-D_XOPEN_SOURCE=700 \
			-I"$(ERTS_INCLUDE_PATH)" 

KERNEL_NAME := $(shell uname -s)
LIB_NAME = priv/scrypt_nif.so

ifneq ($(CROSSCOMPILE),)
	LIB_CFLAGS := -shared -fPIC -fvisibility=hidden
	SO_LDFLAGS := -Wl,-soname,libscrypt.so.0
else
	ifeq ($(KERNEL_NAME), Linux)
		LIB_CFLAGS := -shared -fPIC -fvisibility=hidden
		SO_LDFLAGS := -Wl,-soname,libscrypt.so.0
	endif
	ifeq ($(KERNEL_NAME), Darwin)
		LIB_CFLAGS := -dynamiclib -undefined dynamic_lookup
	endif
	ifeq ($(KERNEL_NAME), $(filter $(KERNEL_NAME),OpenBSD FreeBSD NetBSD))
		LIB_CFLAGS := -shared -fPIC
	endif
endif

all: $(LIB_NAME)

$(LIB_NAME): $(SRC)
	mkdir -p priv
	$(CC) $(CFLAGS) $(LIB_CFLAGS) $(SO_LDFLAGS) $^ -o $@

clean:
	rm -f $(LIB_NAME)

.PHONY: all clean
