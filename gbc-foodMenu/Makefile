
GBCBASE=..

include ../makefile.inc

CUSTOMNAME=$(shell basename $(PWD))
TARGET=$(DISTBIN)/$(CUSTOMNAME)-$(GENVER).zip
CUSTOMIZATION=--customization customization/$(CUSTOMNAME)

all: theme/common $(TARGET)

theme/common:
	mkdir -p $@

# Create a symbolic link to our custom gbc files
$(GBCBASE)/gbc-$(PACKVER)/customization/$(CUSTOMNAME): 
	ln -fs $(PWD) $@

# Build our custom gbc
$(GBCBASE)/gbc-$(PACKVER)/dist/$(CUSTOMNAME): $(GBCBASE)/gbc-$(PACKVER) $(GBCBASE)/gbc-$(PACKVER)/customization/$(CUSTOMNAME)
	@echo "Building GBC ..."
	cd $(GBCBASE)/gbc-$(PACKVER) && $(BUILDCMD) $(CFG) $(CUSTOMIZATION) > $(CWD)/$(CUSTOMNAME).out 
	@tail -10 $(CWD)/$(CUSTOMNAME).out

# Package our custom gbc
$(TARGET): $(GBCBASE)/gbc-$(PACKVER)/dist/$(CUSTOMNAME)
	@cd $(GBCBASE)/gbc-$(PACKVER)/dist/customization/$(CUSTOMNAME) && zip -r $@ * > $(CWD)/$(CUSTOMNAME).lst


dev:
	cd $(GBCBASE)/gbc-$(PACKVER) && $(BUILDCMD) $(CUSTOMIZATION) --watch

deploy:
	cd ../distbin && ./deploy_gbc.sh
