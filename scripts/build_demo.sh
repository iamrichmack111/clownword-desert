#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OUTDIR="${2:-$HOME/Downloads/DEMOS}"
mkdir -p "$OUTDIR"
fail(){ echo "ERROR: $*" >&2; exit 1; }
for cmd in python3 curl ffmpeg ffprobe; do command -v "$cmd" >/dev/null 2>&1 || fail "missing required command: $cmd"; done

SHOTS="$ROOT/media/screenshots"
required=(01-start-screen.png 02-live-desert.png 03-spelling-combat.png 04-word-controls.png 05-grade-report.png 06-student-records.png)
for f in "${required[@]}"; do [[ -s "$SHOTS/$f" ]] || fail "missing screenshot: $SHOTS/$f"; done

# Reuse the exact Piper cache that already proved itself on Fraction Food Truck when present.
PROVEN="$HOME/.cache/fraction-food-truck-demo-v3"
OWN="$HOME/.cache/clownword-desert-demo-v1"
if [[ -x "$PROVEN/piper-1.8-venv/bin/python" && -s "$PROVEN/voices/ryan-high/en_US-ryan-high.onnx" ]]; then
  CACHE="$PROVEN"
  echo "Reusing proven Piper/Ryan High cache: $CACHE"
else
  CACHE="$OWN"
fi
VOICE_DIR="$CACHE/voices/ryan-high"
VENV="$CACHE/piper-1.8-venv"
MODEL="$VOICE_DIR/en_US-ryan-high.onnx"
CONFIG="$VOICE_DIR/en_US-ryan-high.onnx.json"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/clownword-desert-demo.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$VOICE_DIR"

MODEL_URL='https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/high/en_US-ryan-high.onnx?download=true'
CONFIG_URL='https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/high/en_US-ryan-high.onnx.json?download=true'

if [[ ! -s "$MODEL" || $(wc -c < "$MODEL" 2>/dev/null || echo 0) -lt 100000000 ]]; then
  echo "Downloading Piper Ryan High model..."
  rm -f "$MODEL" "$MODEL.part"
  curl -fL --retry 5 --retry-all-errors --connect-timeout 20 "$MODEL_URL" -o "$MODEL.part"
  mv "$MODEL.part" "$MODEL"
fi
if [[ ! -s "$CONFIG" ]]; then
  echo "Downloading Piper Ryan High config..."
  rm -f "$CONFIG" "$CONFIG.part"
  curl -fL --retry 5 --retry-all-errors --connect-timeout 20 "$CONFIG_URL" -o "$CONFIG.part"
  mv "$CONFIG.part" "$CONFIG"
fi
[[ -s "$MODEL" ]] || fail "Ryan High model missing"
[[ -s "$CONFIG" ]] || fail "Ryan High config missing"
bytes=$(wc -c < "$MODEL")
(( bytes > 100000000 )) || fail "Ryan High model incomplete: ${bytes} bytes"
python3 - "$CONFIG" <<'PY'
import json,sys
with open(sys.argv[1],encoding='utf-8') as f: d=json.load(f)
assert isinstance(d,dict) and d
print('Ryan High config OK')
PY

if [[ ! -x "$VENV/bin/python" ]] || ! "$VENV/bin/python" -c 'import piper' >/dev/null 2>&1; then
  echo "Installing Piper TTS 1.8.0 in isolated venv..."
  rm -rf "$VENV"
  python3 -m venv "$VENV" || fail "python3-venv is required: sudo apt install python3-venv"
  "$VENV/bin/python" -m pip install --upgrade pip >/dev/null
  "$VENV/bin/python" -m pip install 'piper-tts==1.8.0' || fail "could not install piper-tts 1.8.0"
fi
PIPER="$VENV/bin/python"

piper_synth(){
  local text="$1" out="$2"
  rm -f "$out"
  printf '%s\n' "$text" | "$PIPER" -m piper --model "$MODEL" --config "$CONFIG" --output-file "$out"
  [[ -s "$out" ]] || fail "Piper produced no WAV file: $out"
}

check_audio(){
  local f="$1" label="$2" dur maxv
  dur="$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
  [[ -n "$dur" ]] || fail "$label has no duration"
  python3 - "$dur" <<'PY'
import sys
v=float(sys.argv[1]); assert v >= .40, f'audio too short: {v}'; print(f'duration={v:.2f}s')
PY
  maxv="$(ffmpeg -hide_banner -nostats -i "$f" -af volumedetect -f null - 2>&1 | sed -n 's/.*max_volume: \([^ ]*\) dB.*/\1/p' | tail -n1)"
  [[ -n "$maxv" && "$maxv" != "-inf" ]] || fail "$label is silent"
  python3 - "$maxv" <<'PY'
import sys
v=float(sys.argv[1]); assert v > -55, f'audio too quiet: {v} dBFS'; print(f'max_volume={v:.1f} dBFS')
PY
  echo "AUDIO OK: $label"
}

process_voice(){
  local text="$1" raw="$2" out="$3"
  piper_synth "$text" "$raw"
  check_audio "$raw" "raw Piper voice"
  ffmpeg -hide_banner -loglevel error -y -i "$raw" \
    -af "highpass=f=70,lowpass=f=14000,volume=1.55,acompressor=threshold=-18dB:ratio=2:attack=20:release=220,loudnorm=I=-16:LRA=7:TP=-1.5" \
    -ar 48000 -ac 1 -c:a pcm_s16le "$out"
  check_audio "$out" "processed Piper voice"
}

VOICE_TEST="$OUTDIR/clownword-desert-voice-test.wav"
process_voice "Welcome to ClownWord Desert. This is the high quality Ryan voice test. If you can hear this sentence, narration is working correctly." "$WORK/test-raw.wav" "$VOICE_TEST"
echo "VOICE TEST READY: $VOICE_TEST"

texts=(
"Welcome to ClownWord Desert, a two dimensional open world spelling game where students explore a desert, survive clown hordes, and use correctly spelled sight words as their main defense."
"A session begins by choosing a student name and vocabulary level. Once inside the desert, the player moves through a large scrolling world while circus tents continuously release clown enemies."
"Every active clown carries a sight word. The highlighted target appears in the spelling panel, and the player types the word and presses Enter. Correct spelling clears enemies, builds combos, and helps seal nearby circus tents."
"Teachers and families can change the active word list without leaving the game. Custom vocabulary can be pasted into the word controls, applied immediately, and reused for targeted spelling practice."
"Each session ends with a real grade report that combines spelling accuracy, tent completion, and word mastery. Correct answers, mistakes, combo performance, and elapsed time are all summarized."
"ClownWord Desert also keeps student records in the browser and can export grade data as CSV. The project runs offline, uses no external game engine, and can be installed as a Linux desktop application."
)
images=(
"$SHOTS/01-start-screen.png" "$SHOTS/02-live-desert.png" "$SHOTS/03-spelling-combat.png" "$SHOTS/04-word-controls.png" "$SHOTS/05-grade-report.png" "$SHOTS/06-student-records.png"
)

: > "$WORK/concat.txt"
for i in "${!texts[@]}"; do
  n=$((i+1)); raw="$WORK/voice-$n-raw.wav"; voice="$WORK/voice-$n.wav"; scene="$WORK/scene-$n.mp4"
  process_voice "${texts[$i]}" "$raw" "$voice"
  adur="$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$voice")"
  dur="$(python3 - "$adur" <<'PY'
import sys
print(f'{float(sys.argv[1])+0.55:.3f}')
PY
)"
  vfade="$(python3 - "$dur" <<'PY'
import sys
print(f'{max(0,float(sys.argv[1])-0.30):.3f}')
PY
)"
  afade="$(python3 - "$adur" <<'PY'
import sys
print(f'{max(0,float(sys.argv[1])-0.15):.3f}')
PY
)"
  ffmpeg -hide_banner -loglevel error -y \
    -loop 1 -framerate 30 -i "${images[$i]}" -i "$voice" \
    -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fade=t=in:st=0:d=0.25,fade=t=out:st=${vfade}:d=0.30,format=yuv420p[v];[1:a]afade=t=in:st=0:d=0.05,afade=t=out:st=${afade}:d=0.15,apad=pad_dur=0.55[a]" \
    -map '[v]' -map '[a]' -t "$dur" -c:v libx264 -preset veryfast -crf 18 -r 30 -c:a aac -b:a 192k -ar 48000 -movflags +faststart "$scene"
  ffprobe -v error "$scene" >/dev/null || fail "scene $n is not playable"
  printf "file '%s'\n" "$scene" >> "$WORK/concat.txt"
done

FINAL="$OUTDIR/clownword-desert-demo.mp4"
ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i "$WORK/concat.txt" -c copy -movflags +faststart "$FINAL"
[[ -s "$FINAL" ]] || fail "final MP4 was not created"
video_codec="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$FINAL")"
audio_codec="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$FINAL")"
[[ "$video_codec" == "h264" ]] || fail "final video codec is not H.264"
[[ "$audio_codec" == "aac" ]] || fail "final audio codec is not AAC"
ffmpeg -hide_banner -loglevel error -y -i "$FINAL" -vn -ac 1 -ar 48000 "$WORK/final.wav"
check_audio "$WORK/final.wav" "final MP4 narration"
echo "SUCCESS"
echo "VOICE TEST: $VOICE_TEST"
echo "DEMO READY: $FINAL"
