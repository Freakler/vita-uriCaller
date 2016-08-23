TITLE_ID = URI000001
TARGET   = uriCaller
OBJS     = main.o

PSVITAIP = 192.168.0.105

LIBS = -lvita2d -lSceKernel_stub -lSceDisplay_stub -lSceGxm_stub -lSceIme_stub \
	-lSceSysmodule_stub -lSceCtrl_stub -lScePgf_stub -lSceAppMgr_stub -lSceAppUtil_stub \
	-lSceCommonDialog_stub -lfreetype -lpng -ljpeg -lz -lm -lc -lSceReg_stub -lSceVshBridge_stub

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
CFLAGS  = -Wl,-q -Wall -O3
ASFLAGS = $(CFLAGS)

all: $(TARGET).vpk

%.vpk: eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE_ID) "$(TARGET)" param.sfo
	vita-pack-vpk -s param.sfo -b eboot.bin \
      -a resource/icon0.png=sce_sys/icon0.png \
      -a resource/template.xml=sce_sys/livearea/contents/template.xml \
      -a resource/startup.png=sce_sys/livearea/contents/startup.png \
      -a resource/bg0.png=sce_sys/livearea/contents/bg0.png \
      $@
	  
eboot.bin: $(TARGET).velf
	vita-make-fself $< $@

%.velf: %.elf
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $^ $(LIBS) -o $@

%.o: %.png
	$(PREFIX)-ld -r -b binary -o $@ $^

clean:
	@rm -rf $(TARGET).vpk $(TARGET).velf $(TARGET).elf $(OBJS) \
		eboot.bin param.sfo

vpksend: $(TARGET).vpk
	curl -T $(TARGET).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."

send: eboot.bin
	curl -T eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent."
