#!/bin/bash
echo "--- Minecraft Modding Environment Check ---"
if [ -f "gradle.properties" ]; then
    echo "Found gradle.properties:"
    grep -E "minecraft_version|neoforge_version|neo_version|fabric_version|fabric_loader_version|create_version" gradle.properties
fi

echo "Dependencies Check:"
find . -mindepth 1 -maxdepth 4 \( -name "build.gradle" -o -name "build.gradle.kts" \) -not -path "*/build/*" -print0 |
while IFS= read -r -d '' file; do
    matches=$(grep -E "neoforge|fabric-loader|mezz.jei|appeng|com.simibubi.create" "$file")
    if [ -n "$matches" ]; then
        echo "$file:"
        echo "$matches"
    fi
done
