"""Local native candidates for the deferred Arc firing sound."""
import build_device_audio_audition as audition

audition.RAW = audition.ROOT / 'diagnostics/audio-audition/arc-c421'
audition.OUT = audition.ROOT / 'art/ARC_AUDIO.html'
audition.GROUPS = [
    ('Arc discharge', 'Radio zaps are the closest native electrical character. Compare the quieter alternatives; none is installed yet.', ['VehicleRadioZap', 'RadioZap', 'DismantleFailed', 'RadioStatic', 'TuneIn', None]),
]
if __name__ == '__main__':
    audition.main()
    page = audition.OUT.read_text(encoding='utf-8')
    page = page.replace('omhtt-c390-audio', 'omhtt-c421-arc-audio')
    page = page.replace('Native sound audition', 'Arc Emitter sound audition')
    start = page.index('<p>Existing coverage:')
    end = page.index('</p>', start) + 4
    page = page[:start] + '<p>Arc uses the existing wake and deactivation cues. This audition covers the discharge only. Native radio and electrical sounds are approximations, not a dedicated lightning asset. Final firing audio is deferred and these previews are for local use only.</p>' + page[end:]
    audition.OUT.write_text(page, encoding='utf-8')
