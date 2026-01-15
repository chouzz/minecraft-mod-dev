# Minecraft Mod Development Skill

A Claude Code skill for Minecraft mod development with modern loaders (NeoForge/Fabric) and ecosystem interoperability.

## Features

- **Dynamic Documentation Fetching** - Automatically fetches latest docs for NeoForge/Fabric
- **Inter-mod Integration** - Guides for JEI, AE2, Create, and other popular mods
- **Modern Standards** - Data Components, Data Generation, Convention Tags
- **Environment Detection** - Auto-detects project configuration

## Installation

Place this skill in your Claude Code skills directory:

```bash
~/.claude/skills/minecraft-mod-dev/
```

## Usage Triggers

This skill activates when you:
- Create new blocks, items, or entities
- Integrate with JEI/AE2/Create
- Set up modding environment
- Migrate code to 1.21+
- Work with NeoForge or Fabric loaders

## Example

```
> "Help me create a machine block that works with AE2 storage and shows recipes in JEI"
```

The skill will guide you through:
1. Fetching latest API docs
2. Implementing AE2 Grid integration
3. Registering JEI recipe types
4. Using Data Components for item data

## Resources

- [NeoForge Docs](https://docs.neoforged.net/)
- [Fabric Wiki](https://fabricmc.net/wiki/)
- See `references/mod-links.md` for more API documentation
