
GBCBASE=..

include ../makefile.inc

CUSTOMNAME=$(shell basename $(PWD))

TARGET=$(DISTBIN)/$(CUSTOMNAME).zip

all: theme/common $(TARGET)

theme/common:
	mkdir -p $@

# Create a symbolic link to our custom gbc files
$(GBCBASE)/gbc-$(PACKVER)/customization/$(CUSTOMNAME): 
	ln -s $(PWD) $@

# Build our custom gbc
$(GBCBASE)/gbc-$(PACKVER)/dist/$(CUSTOMNAME): $(GBCBASE)/gbc-$(PACKVER) $(GBCBASE)/gbc-$(PACKVER)/customization/$(CUSTOMNAME)
	@echo "Building GBC ..."
	@cd $(GBCBASE)/gbc-$(PACKVER) && grunt $(CFG) --customization=customization/$(CUSTOMNAME)  > $(CWD)/$(CUSTOMNAME).out 
	@tail -10 $(CWD)/$(CUSTOMNAME).out

# Package our custom gbc
$(TARGET): $(GBCBASE)/gbc-$(PACKVER)/dist/$(CUSTOMNAME)
	@cd $(GBCBASE)/gbc-$(PACKVER)/dist/customization/$(CUSTOMNAME) && zip -r $@ * > $(CWD)/$(CUSTOMNAME).lst


dev:
	cd $(GBCBASE)/gbc-$(PACKVER) && grunt --customization=customization/$(CUSTOMNAME) dev

deploy:
	cd ../distbin && ./deploy_gbc.sh
