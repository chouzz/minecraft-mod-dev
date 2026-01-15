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
