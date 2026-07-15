# CONFIG
.PHONY: all archives assets clean

BUILD := site
CONTENT := content
SCRIPT := scripts
TEMPLATE := content/assets/templates
DATA_DIR := $(BUILD)/data

# COLLECTIONS
COLLECTIONS := notes essays

# SOURCE
ASSETS_SRC := $(CONTENT)/assets/static/*
INDEX_SRC := $(wildcard $(CONTENT)/pages/index.md)
WRITINGS_SRC := $(wildcard $(CONTENT)/pages/writings.md)
NOTES_SRC := $(wildcard $(CONTENT)/notes/*.md)
ESSAYS_SRC := $(wildcard $(CONTENT)/essays/*.md)

# LIST
NOTES_LIST := $(DATA_DIR)/notes-list.md
ESSAYS_LIST := $(DATA_DIR)/essays-list.md
LISTS := $(NOTES_LIST) $(ESSAYS_LIST)
# LISTS := $(addprefix $(DATA_DIR)/,$(addsuffix -list.md, $(COLLECTIONS)))

# OUTPUTS
ASSETS_OUT := $(BUILD)/assets
INDEX_OUT := $(patsubst content/pages/index.md,\
		$(BUILD)/index.html,\
		$(INDEX_SRC))
WRITINGS_OUT := $(patsubst content/pages/writings.md,\
		$(BUILD)/writings/index.html,\
		$(WRITINGS_SRC))
NOTES_OUT := $(patsubst $(CONTENT)/notes/%.md,\
		$(BUILD)/writings/notes/%.html,\
		$(NOTES_SRC))
ESSAYS_OUT := $(patsubst $(CONTENT)/essays/%.md,\
		$(BUILD)/writings/essays/%.html,\
		$(ESSAYS_SRC))

# COUNT
NOTES_COUNT := $(words $(NOTES_SRC))
ESSAYS_COUNT := $(words $(ESSAYS_SRC))

# TOP LEVEL PAGE
all: index writings archives assets

archives: $(LISTS) $(NOTES_OUT) $(ESSAYS_OUT)

# GENERATE LIST
$(DATA_DIR)/%-list.md: $(SCRIPT)/generate-list.sh
	@printf "[GEN] %s\n" "$@"
	@mkdir -p $(dir $@)
	$(SCRIPT)/generate-list.sh \
		$(CONTENT)/$* \
		writings/$* \
		> $@


# GENERATE PAGES
# build index
index: $(INDEX_OUT)

$(BUILD)/index.html: $(CONTENT)/pages/index.md
	@printf "[GEN] %s\n" "$@"
	@pandoc $(INDEX_SRC) \
		--template=$(TEMPLATE)/index.html \
		-o $(INDEX_OUT)

# build writings
writings: $(WRITINGS_OUT)

$(BUILD)/writings/index.html: $(CONTENT)/pages/writings.md $(NOTES_LIST) $(ESSAYS_LIST)
	@printf "[GEN] %s\n" "$@"
	@mkdir -p $(dir $@)
	@printf "[REPLACE] {{notes_count}} with $(NOTES_COUNT)\n"
	@printf "[REPLACE] {{essays_count}} with $(ESSAYS_COUNT)\n"
	@printf "[REPLACE] {{notes_list}} with $(NOTES_LIST)\n"
	@printf "[REPLACE] {{essays_list}} with $(ESSAYS_LIST)\n"
	@sed \
	-e "s/{{notes_count}}/$(NOTES_COUNT)/g" \
	-e "s/{{essays_count}}/$(ESSAYS_COUNT)/g" \
	-f scripts/writings.sed \
	$< | pandoc - \
		--template=$(TEMPLATE)/writings.html \
		-o $(WRITINGS_OUT)

# build notes
notes: $(NOTES_OUT) $(NOTES_LIST)


$(BUILD)/writings/notes/%.html: $(CONTENT)/notes/%.md
	@printf "[GEN] %s\n" "$@"
	@mkdir -p $(BUILD)/writings/notes
	@pandoc $< \
		--template=$(TEMPLATE)/default.html \
		-o $@

# build essays
essays: $(ESSAYS_OUT) $(ESSAYS_LIST)

$(BUILD)/writings/essays/%.html: $(CONTENT)/essays/%.md
	@printf "[GEN] %s\n" "$@"
	@mkdir -p $(BUILD)/writings/essays
	@pandoc $< \
		--template=$(TEMPLATE)/default.html \
		-o $@

# build assets
assets:
	@printf "[COPY] %s\n" "$(ASSETS_SRC)"
	@mkdir -p $(BUILD)/assets
	@cp -r $(ASSETS_SRC) $(ASSETS_OUT)

# clean
clean:
	rm -rf $(BUILD)/*
