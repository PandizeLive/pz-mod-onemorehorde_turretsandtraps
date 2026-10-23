"""Verify the installed game's depth, opacity and camera path used by device effects."""
import json
import subprocess
from pathlib import Path


def check(game, output):
    javap = Path("C:/Program Files/Java/jdk-17/bin/javap.exe")
    names = {
        "chunk": "zombie.iso.fboRenderChunk.FBORenderChunkCamera",
        "drawer": "zombie.core.skinnedmodel.model.WorldItemModelDrawer",
        "renderer": "zombie.core.skinnedmodel.model.ItemModelRenderer",
        "item": "zombie.inventory.InventoryItem",
    }
    code = {}
    for key, name in names.items():
        result = subprocess.run([str(javap), "-classpath", str(game / "projectzomboid.jar"),
                                 "-c", "-p", name], capture_output=True, text=True, check=True)
        code[key] = result.stdout
        (output / ("device-" + key + "-bytecode.txt")).write_text(result.stdout, encoding="utf-8")
    assert "2.44949f" in code["chunk"] and "-1.5f" in code["chunk"]
    assert "-0.48f" not in code["chunk"], "Do not compensate the legacy camera in chunk-render callbacks"
    assert "FBORenderItems.setCamera" in code["drawer"] and "renderThreadCurrent" in code["drawer"]
    assert "InventoryItem.getWorldAlpha" in code["renderer"] and "Shader.setAlpha" in code["renderer"]
    assert "IsoDepthHelper.getSquareDepthData" in code["renderer"]
    assert "setWorldAlpha(float)" in code["item"]
    record = {"chunkOriginHasLegacyOffset": False, "nativeWorldAlpha": True, "nativeDepth": True,
              "renderedClientAcceptance": "pending owner test"}
    (output / "device-render-api.json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
