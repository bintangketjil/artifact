.PHONY: all index writings notes archives posts assets clean

# CONFIG

SHELL := /usr/bin/bash

BUILD := site
CONTENT := content
DATA_DIR := $(BUILD)/data
SCRIPT := scripts

TEMPLATE := content/assets/templates
TEMPLATE_DEF := -s --template=$(TEMPLATE)/default.html
TEMPLATE_IDX := -s --template=$(TEMPLATE)/index.html
TEMPLATE_WRT := -s --template=$(TEMPLATE)/writings.html

PANDOC := pandoc
PANDOC_COMMON := -s

# COLLECTION
COLLECTIONS := notes essays logs

COLLECTION.notes.src := content/notes
COLLECTION.notes.pattern := *.md
COLLECTION.notes.out := writings/notes
COLLECTION.notes.type := pages
COLLECTION.notes.template := default.html
COLLECTION.notes.title := Notes

COLLECTION.essays.src := content/essays
COLLECTION.essays.pattern := *.md
COLLECTION.essays.out := writings/essays
COLLECTION.essays.type := pages
COLLECTION.essays.template := default.html
COLLECTION.essays.title := Essays

COLLECTION.logs.src := content/dumps
COLLECTION.logs.pattern := log*.md
COLLECTION.logs.out := logs
COLLECTION.logs.type := stream
COLLECTION.logs.template := default.html
COLLECTION.logs.title := Logs

# helper
collection-src = $(COLLECTION.$(1).src)
collection-pattern = $(COLLECTION.$(1).pattern)
collection-out = $(COLLECTION.$(1).out)
collection-type = $(COLLECTION.$(1).type)
collection-template = $(COLLECTION.$(1).template)
collection-template-path = $(TEMPLATE)/$(call collection-template,$(1))
collection-title = $(COLLECTION.$(1).title)

# DERIVED VARIABLES
LISTS := $(addprefix $(DATA_DIR)/,$(addsuffix -list.md,$(COLLECTIONS)))
INDEX_SRC := $(CONTENT)/pages/index.md
INDEX_OUT := $(BUILD)/index.html
WRITINGS_SRC := $(CONTENT)/pages/writings.md
WRITINGS_OUT := $(BUILD)/writings/index.html
ASSETS_SRC := $(CONTENT)/assets/static/*
ASSETS_OUT := $(BUILD)/assets

# MACROS
define GENERATE_LIST

$(DATA_DIR)/$(1)-list.md: $(SCRIPT)/generate-list.sh
	mkdir -p $$(dir $$@)
	$$< \
	$$(call collection-src,$(1)) \
	$$(call collection-out,$(1)) \
	> $$@
endef

$(foreach c,$(COLLECTIONS),$(eval $(call GENERATE_LIST,$(c))))

# Derive collection metadata
define COLLECTION_DERIVE

$(1)_INPUTS := $$(wildcard $(call collection-src,$(1))/$$(call collection-pattern,$(1)))

$(1)_OUTPUTS := $$(patsubst $$(call collection-src,$(1))/%.md, \
		$(BUILD)/$$(call collection-out,$(1))/%.html, \
		$$($(1)_INPUTS))

$(1)_COUNT := $$(words $$($(1)_INPUTS))

endef

$(foreach c,$(COLLECTIONS),$(eval $(call COLLECTION_DERIVE,$(c))))

# counter
COUNT_ARGS := $(foreach c,$(COLLECTIONS),-e "s/{{$(c)_count}}/$($(c)_COUNT)/g")

# TODO:
# Render using collection registry
# renderer
define COLLECTION_RULE

$$($(1)_OUTPUTS): $(BUILD)/$$(call collection-out,$(1))/%.html: $$(call collection-src,$(1))/%.md
	mkdir -p $$(dir $$@)
	$(PANDOC) $(PANDOC_COMMON) \
	--template=$$(call collection-template-path,$(1)) \
	-o $$@
endef

$(foreach c,$(COLLECTIONS),$(eval $(call COLLECTION_RULE,$(c))))

POSTS := $(foreach c,$(COLLECTIONS),$($(c)_OUTPUTS))

print:
	@echo "COLLECTIONS=$(COLLECTIONS)"
	@echo "notes_INPUTS=$(notes_INPUTS)"
	@echo "notes_OUTPUTS=$(notes_OUTPUTS)"
	@echo "essays_INPUTS=$(essays_INPUTS)"
	@echo "essays_OUTPUTS=$(essays_OUTPUTS)"
	@echo "logs_INPUTS=$(logs_INPUTS)"
	@echo "logs_OUTPUTS=$(logs_OUTPUTS)"
	@echo "POSTS=$(POSTS)"

# TARGET
all: index writings archives posts assets

index: $(INDEX_OUT)
writings: $(WRITINGS_OUT)
archives: $(LISTS)
posts: $(POSTS)
assets: $(ASSETS_OUT)

# RULES
$(INDEX_OUT): $(INDEX_SRC)
	mkdir -p $(dir $@)
	$(PANDOC) $(PANDOC_COMMON) \
	$(TEMPLATE_IDX) \
	-o $@
$(WRITINGS_OUT): $(WRITINGS_SRC) $(LISTS)
	mkdir -p $(dir $@)
	sed \
		-e "/{{notes_list}}/r $(DATA_DIR)/notes-list.md" \
		-e "/{{notes_list}}/d" \
		-e "/{{essays_list}}/r $(DATA_DIR)/essays-list.md" \
		-e "/{{essays_list}}/d" \
		$(COUNT_ARGS) \
		$(WRITINGS_SRC) | \
		$(PANDOC) $(PANDOC_COMMON) - \
		$(TEMPLATE_WRT) \
		-o $@

$(ASSETS_OUT): $(ASSETS_SRC)
	mkdir -p $(BUILD)/assets
	cp -r $(ASSETS_SRC) $(ASSETS_OUT)

clean:
	rm -rf $(BUILD)
