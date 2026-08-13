# Dialogue System (`src/03_dialogue`)

The dialogue system is designed to work around JSON files with the dialogues between characters in-game.

Dialogues should remain agnostic of the visuals, effects, and scenes. The only in-game information are the emotions and 
sounds associated to a line of dialogue, expressed as strings like "surprised" or "loud scream". The goal is to not
conflate game logic into the JSON files. 

## 1. Key Elements of a Dialogue JSON file

**Speakers** - represent the game characters, narrators and npc who take
part of a dialogue. For each speaker, the system expects a CharacterDefinition resource, that knows the assets used by
that character in the dialogues (images, sounds, display name, etc.).

**Nodes** - managed by the DialogueNode class, represent the lines of dialogue between the character. Each dialogue node is
one single line of dialogue from one specific character. Dialogue Nodes can contain 'options', which can be used to capture
player choices, intentions or even branch the dialogues

**Options** - managed by the DialogueOption class, represent a choice given to the player within a dialogue node. The system
includes hooks to capture the player selection.

**Signals** - the system comes with several signals, to integrate game logic into dialogues using Godot's built-in notification system.  
Also, the system comes with several pre-made scripts to handle common use cases, called Signal Handlers.

**Signal Handlers** - classes that extend from DialogueSignalHandler to facilitate the implementation of common use cases
with dialogues like: loading a scene after choosing a specific option, chaining dialogues or changing the original order
of dialogue nodes. These scripts are just pre-baked listeners of dialogue signals.  

## 2. How to include dialogue into a scene

Use `scenes/dialogue.gd` as the script for your dialogue node. The recommended default is `scenes/Dialogue.tscn`, 
which is a packed scene implementation already configured with the dialogue UI and script, and can be dropped into any scene.

Typical integration flow:
1. Add `res://src/03_dialogue/scenes/Dialogue.tscn` as a child in your scene (drop-in).
2. In Inspector, set `dialogue_source` to a dialogue JSON file (or leave empty to auto-resolve by scene name).
3. Enable `start_on_load` or start it manually from code with `Dialogue.start()`.

If you build a custom UI instead of using `Dialogue.tscn`, add a `Control` node and attach `res://src/03_dialogue/scenes/dialogue.gd`, 
then map required exported node paths/portrait slots in Inspector.

## 3. Workflow

### Loading

1. Reads and validates the dialogue JSON file named as `dialogue_source`.
2. If `dialogue_source` is empty, tries to read a file with the scene name.
3. Loads the dialogue graph from the JSON file using `DialogueLoader`.
4. Depending on the settings, the dialogue text and options are displayed in the scene, and the player can interact with the dialogue by selecting options or advancing the text.

### Settings:

- `start_on_load`: if true, starts the dialogue by entering the first node in the graph, otherwise, waits for the game to call `start` to begin the dialogue.
- `lazy_load`: if true, the dialogue graph is loaded on demand when `start` is called. If false, it will be loaded in `_ready`.

### Dialogue Iteration

For each node, the workflow is as follows:

1. Emits the `on_node_entered` signal.
2. Updates the dialogue text, speaker name, portrait and emotion based on the node's data
3. If the node has options, go to step 4. Otherwise, go to step 5 
4. Process dialogue options:
      1. Emits the `on_before_options_presented` signal 
      2. Adds options as buttons in the scene. 
      3. Emits the `on_after_options_presented` signal and waits for player input.
      4. When the player selects an option: 
         1. Emits the `on_option_selected` signal
         2. Resolves next node using selected option's `next_node_id` and checks if `request_navigation_override` was called.
5. If `auto_next` is true, moves to the next node automatically. Otherwise, waits for player input to advance.
6. If dialogue has a next node, emits `on_node_exited` signal 
7. If it was last node, finishes the dialogue and emits the `on_dialogue_finished` signal.

### Portraits

Portraits are the character's visual representation in the dialogue. Each portrait is associated with a character and can have different emotions.
The dialogue system manages the display of portraits based on the current node's speaker and emotion.
Portraits are defined and managed with the following properties:

- `portrait_names`: String list of portrait names for speakers (e.g. "left", "center", "right")
- `portrait_sprites`: Dictionary mapping portrait names to Sprite2D nodes in the scene.
- `portrait_labels`: Dictionary mapping portrait names to RichTextLabel nodes in the scene.
- `portrait_character`: Dictionary mapping portrait names to character names.

The dialogue system automatically updates the portrait and name label when the speaker changes or when the node's emotion changes.
If a portrait or name label is missing, a warning is logged if `warn_on_missing_portrait` is true.

## 4. Code Details 

### Folders

```text
src/03_dialogue/
├─ core/                         # Runtime data model, loading, and dialogue event handlers
│  └─ handlers/                  # Reusable signal-handler components for flow behaviors
├─ demo/                         # Example scene and sample dialogue JSON files
├─ docs/                         # Module documentation (this file)
├─ editor/                       # Editor-only scripts and assets for dialogue tooling
├─ resources/                    # Dialogue content and resource definitions
│  ├─ character_definitions/     # CharacterDefinition .tres assets
│  └─ dialogues/                 # Dialogue graph JSON files
├─ scenes/                       # Dialogue runtime script + default packed scene UI
├─ schema/                       # Dialogue JSON schema definitions and validators
└─ dialogue_config.gd            # Global dialogue configuration (autoload settings)
```

### Scripts

### `core`
- `dialogue_loader.gd`: Loads JSON files, validates schema, and builds `DialogueGraph` objects.
- `dialogue_graph.gd`: Stores dialogue nodes and resolves next-node flow.
- `dialogue_node.gd`: Dialogue node model (speaker, text, options, overrides, etc.).
- `dialogue_option.gd`: Branch option model for player choices.
- `dialogue_signal_handler.gd`: Base component to hook into dialogue signals with node/option filtering.

`core/handlers`:
- `delay_node_start.gd`: Placeholder handler script (currently no custom behavior).
- `finish_dialogue_early.gd`: Ends dialogue at configurable lifecycle moments.
- `load_scene_after_option_selected.gd`: Loads a `.tscn` after an option is selected.
- `redirect_after_option_selected.gd`: Redirects dialogue flow to a target node after selection.
- `start_chained_dialogue.gd`: Loads/starts another dialogue when one finishes.
- `timed_node.gd`: Adds configurable timing delays on node enter/exit.

### `editor`
- `dialogue_editor_script.gd`: `@tool` editor script that validates all dialogue JSON files from `DialogueConfig.json_base_path`.

### `scenes`
- `dialogue.gd`: Main dialogue runtime component (`class_name Dialogue`) to attach to scene nodes.
- `Dialogue.tscn`: Default packed dialogue UI scene wired to `dialogue.gd`.

### `resources`
- `character_definition.gd`: `Resource` describing character display name, portraits, sounds, and validation helpers.

### `schema`
- `dialogue_schemas.gd`: Required/optional field definitions for graph, node, and option JSON shapes.
- `schema_validator.gd`: Generic schema and JSON parsing validator used by the loader/tooling.

