#!/bin/bash
echo "--- Minecraft Modding Environment Check ---"
if [ -f "gradle.properties" ]; then
    echo "Found gradle.properties:"
    grep -E "minecraft_version|neo_version|fabric_version" gradle.properties
fi

if [ -f "build.gradle" ]; then
    echo "Dependencies Check:"
    grep -E "neoforge|fabric-loader|mezz.jei|appeng|com.simibubi.create" build.gradle
fi
