"""Local native candidates for the deferred Arc firing sound."""
import build_device_audio_audition as audition

audition.RAW = audition.ROOT / 'diagnostics/audio-audition/arc-c421'
audition.OUT = audition.ROOT / 'art/ARC_AUDIO.html'
audition.GROUPS = [
    ('Arc discharge', 'Selected: S1B for firing with pitch variation; S1C for impact. Other candidates remain available for comparison.', ['VehicleRadioZap', 'RadioZap', 'DismantleFailed', 'RadioStatic', 'TuneIn', None]),
]
if __name__ == '__main__':
    audition.main()
    page = audition.OUT.read_text(encoding='utf-8')
    page = page.replace('omhtt-c390-audio', 'omhtt-c421-arc-audio')
    page = page.replace('Native sound audition', 'Arc Emitter sound audition')
    start = page.index('<p>Existing coverage:')
    end = page.index('</p>', start) + 4
    page = page[:start] + '<p>C422 selections: S1B RadioZap firing with subtle pitch variation and S1C DismantleFailed impact. The selected firing sample is included in 0.2.64.1; impact references the native event. Installed gains keep impacts quieter, with a burst limit. Arc retains existing wake and deactivation cues. These original candidate previews do not reproduce the final mix.</p>' + page[end:]
    audition.OUT.write_text(page, encoding='utf-8')
