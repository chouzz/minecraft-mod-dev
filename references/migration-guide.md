# Minecraft Mod Migration and Code Refactoring Protocol (v1.21+)

This guide instructs AI on how to handle code conversion from older versions (e.g., 1.12.2/1.16.5) to modern NeoForge/Fabric environments.

## 1. Core Paradigm Shifts

Before migrating any class, the following paradigm conversion rules must be followed:

| Legacy Concept (1.12.2) | Modern Concept (1.21+) | Migration Strategy |
| --- | --- | --- |
| **Obfuscated Names** | **Mojang Mappings** | Always use official mapped names (e.g., `Level` instead of `World`). |
| **TileEntity** | **BlockEntity** | Remove `update()`, use `BlockEntityTicker` instead. |
| **NBT Data** | **Data Components** | Item properties no longer stored in raw NBT, register `DataComponentType`. |
| **Simple Registry** | **DeferredRegister** | Never register in constructors, must use deferred register mechanism. |
| **Hardcoded JSON** | **Data Generation** | Keep logic in Java, generate JSON via `DataProvider`. |

## 2. Key Architecture Rewrite Guides

### A. Item and Block Data (Data Components)

Since 1.20.5+, NBT has been replaced by **Data Components**.

* **Task:** Identify `stack.getTagCompound()` in old code.
* **Refactoring:**
  1. Define components in `ModComponents` class.
  2. Use `stack.set(COMPONENT_TYPE, value)`.
  3. Use `Codec` for data serialization to ensure type safety.

### B. Machine Logic (BlockEntities)

* **Old Logic:** `TileEntity` implements `ITickable`.
* **New Logic:**
  1. Override `getTicker` method in `Block` class.
  2. Only execute logic on the logical server.
  3. Use `BlockEntity#setChanged()` to trigger saves.

### C. Networking (Networking)

Legacy `SimpleImpl` is obsolete.

* **New Flow:**
  1. Define `CustomPacketPayload` record class.
  2. Register `PayloadRegistrar`.
  3. Strictly separate `handleClient` and `handleServer` to avoid class loading crashes.

## 3. Refactoring Execution Protocol

When you (AI) are asked to migrate a specific class, execute the following steps:

1. **Logic Extraction:** Read the old class (e.g., `TileEntityCondenser.java`), extract its core algorithms (e.g., temperature calculation formulas).
2. **API Matching:**
   - Use `webfetch` to search for NeoForge replacement interfaces for the target version.
   - Check if integration mods like AE2/Create have new Capability interfaces (e.g., `IItemHandler` replaces `IInventory`).
3. **Skeleton Generation:** Create new class structure using modern registration patterns.
4. **Data Mapping:** Write DataGen code to automatically generate models and language files corresponding to the old version.
5. **Compatibility Check:** Verify correct **Convention Tags** are used (e.g., `#c:ores/iron`).

## 4. Common Pitfalls (Anti-Patterns)

* **❌ Wrong:** Store state data in `Block` class.
* **✅ Correct:** State must be stored in `BlockState` (small amount) or `BlockEntity` (large/dynamic).
* **❌ Wrong:** Use `Dist.CLIENT` to mark logic methods.
* **✅ Correct:** Only use physical side markers for rendering, GUI registration, and input handling.

---

## 5. Notes for Minecraft 1.26.1 (Checklist and migration points)

This section contains a conservative checklist of areas to inspect when targeting Minecraft 1.26.1 and the corresponding NeoForge/Fabric loaders. It does not claim to be an exhaustive changelog; instead it highlights the most common sources of breakage and recommended verification steps. Use the NeoForge and Fabric developer docs as the authoritative references:

- NeoForge getting started: https://docs.neoforged.net/docs/gettingstarted/
- Fabric development: https://docs.fabricmc.net/develop/

Checklist (high priority)

- Mappings
  - Confirm which mappings your build and runtime use (Mojang vs Yarn vs intermediary). Update code references and mappings used by the mod loader/loom config.

- Loader / API versions
  - Update NeoForge/Fabric loader and API dependencies in build.gradle/gradle.properties. Check for changed entry point signatures or new lifecycle hooks.

- Registration & registries
  - Ensure all deferred registration (items, blocks, block entities, entities, menus, recipes) uses the loader's recommended DeferredRegister/registration helpers and that registration occurs at the correct lifecycle event.

- Data storage & serialization
  - Re-evaluate any direct NBT usage. If your project already uses Data Components, verify the component API and Codec usage are still compatible. If you still rely on NBT, add clear migration paths.

- BlockEntities & ticking
  - Verify `BlockEntityTicker` signatures and `getTicker` behavior. Ensure tick logic only runs server-side and calls `setChanged()` when state mutates.

- Networking
  - Re-check packet registration (channel names, serializers) and buffer read/write helpers. Keep client/server handler separation strict to avoid class-loading crashes.

- Rendering & client systems
  - Confirm model and render pipeline changes (vertex formats, render types, shader entry points). Avoid referencing client-only classes in common code.

- Entity/Attributes/AI
  - Verify attribute registration APIs and goal/behavior signatures; check spawn and data-driven mob changes.

- Data generation & resource schema
  - Re-run data generators and validate generated JSON (loot tables, recipes, tags, block states). Watch for schema changes that break consumers.

- Inter-mod integration
  - Check that JEI/AE2/Create/Patchouli APIs you depend on have compatible versions for 1.26.1. Replace removed capability interfaces with their modern equivalents.

- Resource & datapack format
  - Confirm whether resource pack or datapack schemas have added required fields or changed namespaces.

- Build tooling
  - Update Loom/NeoForge Gradle plugin, Gradle wrapper, and Java target. Rebuild and resolve compilation errors from removed/deprecated APIs.

- Deprecations promoted to removals
  - Search for previously deprecated APIs in your codebase; these are the most common source of runtime failures after a version jump.

- Client/Server separation
  - Double-check side-only usage. Newer loaders may enforce stricter class loading rules.

Practical repo checks (quick grep patterns)

Run these locally to find legacy usages to prioritize during migration:

- TileEntity / ITickable
  - grep -R "TileEntity\|ITickable" -n

- NBT usage
  - grep -R "getTagCompound\|setTagCompound\|getTag" -n

- Inventory / capabilities
  - grep -R "IInventory\|IItemHandler\|IItemHandlerModifiable" -n

- Networking
  - grep -R "SimpleImpl\|SimpleChannel\|Payload" -n

- Registries / direct registration
  - grep -R "register\(" --include='*.java' -n | grep -E "Item|Block|BlockEntity|EntityType|MenuType|RecipeType"

- Data generation hints
  - grep -R "DataProvider\|DataGenerator\|FabricDataOutput" -n

Recommended migration workflow

1. Update build files to target the new loader and mappings.
2. Rebuild and fix compilation errors — start with IDE fixes for renamed types and changed signatures.
3. Run data generation and validate the produced resources.
4. Start the client with a minimal mod setup and watch logs for ClassNotFound/NoSuchMethod/NoSuchField errors.
5. Iterate: fix one subsystem (e.g., block entities), re-run, and smoke-test.

What I changed in this repo

- I added this "Notes for Minecraft 1.26.1" checklist to the migration guide so you have a concise list of high-impact areas to inspect when migrating from 1.21+ to 1.26.1. The section points to the NeoForge and Fabric developer docs you supplied as authoritative next reads.

What's next (suggested)

- If you want, I can:
  - Run a quick lexical code search in this repository for the grep patterns above and return a prioritized list of files to update.
  - Draft concrete code examples showing how to replace common legacy idioms (TileEntity -> BlockEntity, NBT -> Data Components, old registry code -> DeferredRegister) adapted to NeoForge/Fabric patterns.

If you'd like me to scan the repo for specific legacy usages now, say which patterns to search for and I'll run the search and list the matches.
