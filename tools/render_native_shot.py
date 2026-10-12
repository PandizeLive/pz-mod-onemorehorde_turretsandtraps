import argparse
import ctypes as C
import json
import os
from pathlib import Path


class Vector(C.Structure):
    _fields_ = [(axis, C.c_float) for axis in ("x", "y", "z")]


class Attributes(C.Structure):
    _fields_ = [(name, Vector) for name in ("position", "velocity", "forward", "up")]


class Parameter(C.Structure):
    _fields_ = [("name", C.c_char_p), ("id", C.c_uint * 2), ("minimum", C.c_float),
                ("maximum", C.c_float), ("default", C.c_float), ("type", C.c_int),
                ("flags", C.c_uint), ("guid", C.c_ubyte * 16)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("event")
    parser.add_argument("output", type=Path)
    parser.add_argument("--updates", type=int, default=750, choices=range(1, 10001), metavar="1..10000")
    parser.add_argument("--game", type=Path, default=Path("C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"))
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    dll_directory = os.add_dll_directory(str(args.game))
    core = C.WinDLL(str(args.game / "fmod.dll"))
    studio = C.WinDLL(str(args.game / "fmodstudio.dll"))
    P = C.c_void_p

    def bind(lib, name, types):
        fn = getattr(lib, name)
        fn.argtypes = types
        fn.restype = C.c_int

        def call(*values):
            result = fn(*values)
            if result:
                raise RuntimeError(f"{name}: FMOD result {result}")
        return call

    create = bind(studio, "FMOD_Studio_System_Create", [C.POINTER(P), C.c_uint])
    get_core = bind(studio, "FMOD_Studio_System_GetCoreSystem", [P, C.POINTER(P)])
    set_output = bind(core, "FMOD_System_SetOutput", [P, C.c_int])
    set_format = bind(core, "FMOD_System_SetSoftwareFormat", [P, C.c_int, C.c_int, C.c_int])
    set_buffer = bind(core, "FMOD_System_SetDSPBufferSize", [P, C.c_uint, C.c_int])
    initialize = bind(studio, "FMOD_Studio_System_Initialize", [P, C.c_int, C.c_uint, C.c_uint, P])
    load_bank = bind(studio, "FMOD_Studio_System_LoadBankFile", [P, C.c_char_p, C.c_uint, C.POINTER(P)])
    get_event = bind(studio, "FMOD_Studio_System_GetEvent", [P, C.c_char_p, C.POINTER(P)])
    load_samples = bind(studio, "FMOD_Studio_EventDescription_LoadSampleData", [P])
    flush = bind(studio, "FMOD_Studio_System_FlushSampleLoading", [P])
    instance_create = bind(studio, "FMOD_Studio_EventDescription_CreateInstance", [P, C.POINTER(P)])
    start = bind(studio, "FMOD_Studio_EventInstance_Start", [P])
    set_listener = bind(studio, "FMOD_Studio_System_SetListenerAttributes", [P, C.c_int, C.POINTER(Attributes), P])
    set_attributes = bind(studio, "FMOD_Studio_EventInstance_Set3DAttributes", [P, C.POINTER(Attributes)])
    count_parameters = bind(studio, "FMOD_Studio_EventDescription_GetParameterDescriptionCount", [P, C.POINTER(C.c_int)])
    get_parameter = bind(studio, "FMOD_Studio_EventDescription_GetParameterDescriptionByIndex", [P, C.c_int, C.POINTER(Parameter)])
    update = bind(studio, "FMOD_Studio_System_Update", [P])
    playback_state = bind(studio, "FMOD_Studio_EventInstance_GetPlaybackState", [P, C.POINTER(C.c_int)])
    release = bind(studio, "FMOD_Studio_System_Release", [P])
    system, low = P(), P()
    create(C.byref(system), 0x00020309)
    try:
        get_core(system, C.byref(low))
        set_output(low, 5)
        set_format(low, 48000, 3, 0)
        set_buffer(low, 512, 4)
        filename = C.create_string_buffer(os.fsencode(args.output.resolve()))
        initialize(system, 128, 4, 3, C.cast(filename, P))
        listener = Attributes(Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 1), Vector(0, 1, 0))
        set_listener(system, 0, C.byref(listener), None)
        for name in ("ZomboidSound.strings.bank", "ZomboidSound.bank"):
            bank = P()
            load_bank(system, os.fsencode(args.game / "media/sound/banks/Desktop" / name), 0, C.byref(bank))
        event, instance = P(), P()
        get_event(system, args.event.encode(), C.byref(event))
        count = C.c_int()
        count_parameters(event, C.byref(count))
        parameters = []
        for index in range(count.value):
            parameter = Parameter()
            get_parameter(event, index, C.byref(parameter))
            parameters.append({"name": parameter.name.decode(), "default": parameter.default,
                               "minimum": parameter.minimum, "maximum": parameter.maximum,
                               "type": parameter.type, "flags": parameter.flags})
        load_samples(event)
        flush(system)
        instance_create(event, C.byref(instance))
        emitter = Attributes(Vector(0, 0, 1), Vector(0, 0, 0), Vector(0, 0, -1), Vector(0, 1, 0))
        set_attributes(instance, C.byref(emitter))
        start(instance)
        for _ in range(args.updates):
            update(system)
        state = C.c_int()
        playback_state(instance, C.byref(state))
        if state.value not in (2, 4):
            raise RuntimeError(f"Event did not stop within capture window: {state.value}")
    finally:
        release(system)
        dll_directory.close()
    metadata = {"event": args.event, "output": str(args.output), "bytes": args.output.stat().st_size,
                "parameters": parameters, "distance": 1, "fmod_version": "2.03.09", "playback_state": state.value}
    args.output.with_suffix(".json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    print(json.dumps(metadata))


if __name__ == "__main__":
    main()
