# Maniaphobia Developer Guide

This project is a **2D narrative horror game in Godot 4.4**. The current flow is:

`Main Menu -> Apartment -> Outside -> Mansion -> Hide and Seek -> Dinner -> (continues via dialogue/scene transitions)`

Core gameplay combines:
- story/dialogue progression,
- top-down movement and interaction,
- AI-driven chase pressure (Maw + Ghosts),
- a hiding minigame (timed breathing input).

---

## 1. High-level architecture

### Runtime composition
- **Scene-driven level progression** (`Transition` autoload + per-scene scripts).
- **JSON-driven dialogue system** (`Scenes/Dialogue.tscn` + `Script/dialogue.gd` + dialogue JSON files).
- **State-machine AI** (generic `State` + `state_machine` reused by Ghost and Maw behaviors).
- **Global autoload services**:
    - `EventBus` for camera ownership + gameplay signals.
    - `Transition` for fade + async scene loading.
    - `SAVE_MANAGER` from addon `simple_save_tool`.

### Main gameplay loop by level
1. **Apartment**: opening dialogue + interactables; coffee machine gating before exit.
2. **Outside**: short narrative bridge.
3. **Mansion**: talk-to-NPC objective, branching/triggered dialogue, transition to challenge.
4. **Hide_And_Seek**: survival/chase with hiding mechanics and enemy FSM.
5. **Dinner**: follow-up narrative scene.

---

## 2. Folder structure (developer-relevant)

| Path | Purpose |
|---|---|
| `Scenes/` | Primary reusable scenes (menu, player, NPC, enemies, transition, dialogue, game over). |
| `Scenes/Levels/` | Playable level scenes and progression anchors. |
| `Script/` | Level logic, interaction logic, enemy logic, FSM states, globals. |
| `Script/Global/` | Autoload/global systems (`Event_Bus`, `SettingsManager`). |
| `Script/States/` | Generic and Maw-specific FSM state scripts. |
| `Script/Interactables/` | Door, stairs, hide spot behavior. |
| `Scenes/Player/` | Player controller + hiding systems. |
| `dialogue-system/` | Dialogue prototype/test scenes/scripts + shipped JSON dialogue content. |
| `addons/simple_save_tool/` | Third-party save/autoload plugin and examples. |
| `Assets/` | Art/audio/fonts/shaders and other content assets (high-level only). |
| `project.godot` | Project config, input map, plugin/autoload registration. |
| `export_presets.cfg` | Export targets (Windows + Web presets). |

---

## 3. Godot components used heavily

- `CharacterBody2D`: player, NPC shell, Maw, Ghost.
- `Area2D`: interactables and proximity triggers.
- `TileMapLayer`: level geometry/floors/shadows.
- `NavigationAgent2D` + `NavigationRegion2D`: Maw path chasing.
- `Path2D` + `PathFollow2D`: Maw patrol route.
- `AnimationPlayer` + Tween: fades, transitions, UI effects.
- `Timer`: cooldowns, typed-text effect, pacing.
- Autoloads (`project.godot`): `EventBus`, `Transition`, `SAVE_MANAGER`.

---

## 4. Scene index (purpose of each `.tscn`)

| Scene | Purpose |
|---|---|
| `Scenes/MainMenu.tscn` | Entry UI; routes to Apartment, Settings, Quit. |
| `Scenes/Levels/Apartment.tscn` | Intro level with dialogue, door interactions, coffee-machine gate. |
| `Scenes/Levels/Outside.tscn` | Bridge level with short dialogue and auto-transition onward. |
| `Scenes/Levels/Mansion.tscn` | NPC conversation hub + stair/floor interactions + trigger to challenge. |
| `Scenes/Levels/Hide_And_Seek.tscn` | Survival gameplay: Maw + Ghosts + hide interactables + timer/end transitions. |
| `Scenes/Levels/Dinner.tscn` | Post-survival narrative scene. |
| `Scenes/GameOver.tscn` | Loss screen with retry/menu actions. |
| `Scenes/Player/Player.tscn` | Player prefab: movement, camera UI, health, hiding manager. |
| `Scenes/Player/hiding_breathing.tscn` | Breathing timing minigame UI. |
| `Scenes/Maw.tscn` | Maw enemy prefab with FSM and chase/patrol/attack states. |
| `Scenes/ghost.tscn` | Ghost enemy prefab with FSM wander/chase/call behavior. |
| `Scenes/Npc.tscn` | Reusable NPC interaction prefab for Mansion conversations. |
| `Scenes/Dialogue.tscn` | Main in-game dialogue UI and parser host. |
| `Scenes/Transition.tscn` | Full-screen fade transition/autoload scene. |
| `Scenes/door.tscn` | Door shadow/visibility interactable prefab. |
| `Scenes/scenedoor.tscn` | Scene-change door prefab with optional gating logic. |
| `dialogue-system/Dialogue.tscn` | Prototype dialogue UI scene. |
| `dialogue-system/test.tscn` / `othertest.tscn` | Dialogue prototype playground scenes. |
| `addons/simple_save_tool/example/example.tscn` | Addon demo/test scene. |

---

## 5. Script index (purpose of each `.gd`)

### Core level flow scripts
| Script | Purpose |
|---|---|
| `Script/main_menu.gd` | Menu button handlers and transition calls. |
| `Script/Apartment.gd` | Apartment level startup dialogue trigger. |
| `Script/outside.gd` | Outside level opening dialogue + auto progression to Mansion. |
| `Script/Mansion_Script.gd` | Mansion conversation progression logic, NPC talk counting, special dialogue trigger, handoff to Hide and Seek. |
| `Script/hide_and_seek.gd` | Hide-and-seek level lifecycle (player death -> game over, timer -> Dinner). |
| `Script/dinner.gd` | Dinner level opening dialogue trigger. |
| `Script/GameOver.gd` | Retry/menu navigation handlers. |
| `Script/Transition.gd` | Fade and threaded scene loading; emits completion signal. |

### Dialogue and content scripts
| Script | Purpose |
|---|---|
| `Script/dialogue.gd` | Main dialogue runtime: JSON parse, node graph traversal, typed text, options, pause behavior, camera switching. |
| `Script/Icons.gd` | Portrait/character-expression texture map used by dialogue system. |

### Player and hiding scripts
| Script | Purpose |
|---|---|
| `Scenes/Player/Player.gd` | Movement, animation, interaction prompt UI, health/damage/death signaling. |
| `Scenes/Player/hiding_manager.gd` | Enter/exit hiding state, cooldown handling, breathing challenge orchestration. |
| `Scenes/Player/hiding_breathing.gd` | Timing minigame UI/logic with graded outcome signaling. |

### Enemy/AI scripts
| Script | Purpose |
|---|---|
| `Script/Enemy.gd` | Maw entity core data (ranges, damage) and movement shell. |
| `Script/GhostWander.gd` | Ghost roam behavior + transition to chase. |
| `Script/GhostChase.gd` | Ghost pursuit behavior + distance-based transitions. |
| `Script/GhostCall.gd` | Ghost signal state that notifies Maw to chase. |
| `Script/States/state.gd` | Base state interface/signals. |
| `Script/States/state_machine.gd` | Generic finite-state-machine controller. |
| `Script/States/MawPatrol.gd` | Maw path patrol with pause cadence; transitions to chase. |
| `Script/States/MawChase.gd` | Maw navigation chase behavior with hide-awareness. |
| `Script/States/MawAttack.gd` | Maw attack resolution and return to chase. |

### Interactable/environment scripts
| Script | Purpose |
|---|---|
| `Script/Npc.gd` | NPC conversation trigger and facing behavior. |
| `Script/coffee_machine.gd` | Apartment interaction gate that unlocks progression. |
| `Script/scenedoor.gd` | Door-based scene transition with optional prerequisite checks. |
| `Script/BrokenDoor.gd` | One-off apartment blocked-door dialogue interaction. |
| `Script/Interactables/door.gd` | Door shadow alpha logic when player crosses thresholds. |
| `Script/Interactables/stairs.gd` | Two-floor movement transition and collision mask swapping. |
| `Script/Interactables/hide_interactable.gd` | Hide spot occupancy logic + displacement on exit + occupied dialogue. |

### Global systems
| Script | Purpose |
|---|---|
| `Script/Global/Event_Bus.gd` | Global signals and active camera arbitration. |
| `Script/Global/SettingsManager.gd` | Resolution/window/audio/UI-scale config persistence and application. |

### Addon/prototype scripts
| Script | Purpose |
|---|---|
| `dialogue-system/dialogue.gd` | Prototype/older dialogue controller variant. |
| `dialogue-system/button.gd` | Simple scene-switch test button for dialogue prototype scenes. |
| `addons/simple_save_tool/saveAutoload.gd` | Editor plugin that registers `SAVE_MANAGER` autoload. |
| `addons/simple_save_tool/tool/save.gd` | Save resource container (`Dictionary DATA`). |
| `addons/simple_save_tool/tool/saveManager.gd` | Save/load/delete API over `.tres` resources. |
| `addons/simple_save_tool/example/*.gd` | Demo scripts for addon usage. |

---

## 6. Dialogue content and narrative data

Primary shipped narrative content is in:
- `dialogue-system/dialogue_system/Apartment.json`
- `dialogue-system/dialogue_system/Outside.json`
- `dialogue-system/dialogue_system/Mansion.json`
- `dialogue-system/dialogue_system/Hide_And_Seek.json`
- `dialogue-system/dialogue_system/Dinner.json`

Each file uses `dialogue_id` + `nodes` with IDs, text, speaker/emotion metadata, and optional branching (`options`, `next_node`).

---

## 7. Third-party addons and external components

### Active addon/integration
- **Simple Save Tool** (`addons/simple_save_tool`)
    - Registered as editor plugin and autoload (`SAVE_MANAGER`).
    - Provides lightweight persistent dictionary save/load through `.tres`.

### Other external traces/artifacts
- `project.godot` includes a **Dialogic-related** config section (`[dialogic]`), suggesting prior/current use of Dialogic ecosystem settings.
- Archived zips in repository:
    - `addons/dialogue_system.zip`
    - `addons/salmon-typewriter-font (2).zip`
    - `Scenes/Abaddon_Fonts_v1.2.zip`

Treat zip artifacts as imported resources/history unless team confirms active usage.

---

## 8. Important patterns and design conventions

1. **Scene script owns level progression**: each level script drives startup dialogue and transition timing.
2. **Transition-first navigation**: scene changes are usually routed through the global `Transition` autoload for visual consistency.
3. **Signal-driven FSM**: states emit `Transitioned`; machine swaps behavior nodes without hard coupling.
4. **Interaction prompt UX**: interactables manage player prompt visibility directly.
5. **Data/content separation**: dialogue text lives in JSON; dialogue runtime is generic.

---

## 9. Onboarding checklist (human + AI agents)

1. Start with `project.godot` (autoloads, input actions, plugins, run scene).
2. Read `Scenes/Levels/*.tscn` in progression order to understand game flow.
3. Trace level scripts in `Script/` for per-level logic and transition points.
4. Read `Scenes/Player/*` + `Script/Interactables/hide_interactable.gd` for hiding gameplay.
5. Read `Scenes/Maw.tscn`, `Scenes/ghost.tscn`, and `Script/States/*` for AI behavior.
6. Read `Script/dialogue.gd`, `Script/Icons.gd`, and dialogue JSON files for narrative systems.
7. Review addon boundary (`addons/simple_save_tool`) and decide if save behavior should be expanded or replaced.

---

## 10. Current cautions for maintainers

- **Possible resource path inconsistency**: `Scenes/Levels/Mansion.tscn` references `res://Scenes/Player.tscn`, while the visible player scene is `res://Scenes/Player/Player.tscn`.
- **Dialogue path consistency check recommended**: in-scene `json_file` properties reference `res://Assets/dialogue_system/*.json`, while repository dialogue JSON files are under `dialogue-system/dialogue_system/`.

Validate these paths in-editor before major refactors or build/export automation changes.
