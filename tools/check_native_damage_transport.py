"""Pin the installed zombie-health transport findings without launching a server."""
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = Path(os.environ.get("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
JAVAP = Path("C:/Program Files/Java/jdk-17/bin/javap.exe")


def disassemble(name):
    return subprocess.run([str(JAVAP), "-classpath", str(GAME / "projectzomboid.jar"), "-c", "-p", name],
                          capture_output=True, text=True, encoding="utf-8", check=True).stdout


def method(source, signature):
    start = source.index("  " + signature)
    remainder = source[start:]
    following = re.search(r"\n  (?:public|private|protected) ", remainder)
    return remainder[:following.start()] if following else remainder


def main():
    character = disassemble("zombie.characters.NetworkCharacterAI")
    zombie_ai = disassemble("zombie.characters.NetworkZombieAI")
    packer = disassemble("zombie.popman.NetworkZombiePacker")
    actor = disassemble("zombie.characters.IsoGameCharacter")
    zombie = disassemble("zombie.characters.IsoZombie")
    sync = method(character, "public void syncHealth();")
    assert re.findall(r"^\s+\d+: (.*)$", sync, re.M) == ["return"], "syncHealth behavior changed; re-review native transport"
    assert "void syncHealth(" not in zombie_ai, "Zombie-specific syncHealth override now exists"
    apply = method(packer, "private void applyZombie(zombie.characters.IsoZombie);")
    assert "ZombiePacket.health" in apply and "IsoZombie.setHealth:(F)V" in apply
    kill = method(actor, "public final void Kill(zombie.characters.IsoGameCharacter, zombie.inventory.types.HandWeapon, boolean, zombie.characters.CharacterDiedListener);")
    assert kill.index("Method setHealth:") < kill.index("Method onKilled:")
    killed = method(zombie, "public void onKilled(zombie.characters.IsoGameCharacter, zombie.inventory.types.HandWeapon, boolean);")
    assert "String OnZombieDead" in killed
    facts = {
        "jarSha256": hashlib.sha256((GAME / "projectzomboid.jar").read_bytes()).hexdigest(),
        "checks": ["NetworkCharacterAI.syncHealth is a no-op", "NetworkZombieAI does not override syncHealth",
                   "NetworkZombiePacker.applyZombie writes received health", "Kill sets zero health before onKilled",
                   "IsoZombie.onKilled dispatches OnZombieDead"],
        "limitation": "Bytecode inspection only; no live client/server ownership, health or death transport exercised.",
    }
    output = ROOT / "diagnostics/c240-multiplayer/native-damage-transport.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(facts, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps(facts, indent=2))


if __name__ == "__main__":
    main()
