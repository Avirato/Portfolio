# Re-encodes a video with Blender's sequencer (Blender ships ffmpeg), and grabs a poster frame.
#
#   blender -b --factory-startup --python transcode.py -- <src> <out_dir> <basename> [max_long_side]
#
# Writes <out_dir>/<basename>.mp4 and <out_dir>/<basename>-poster.jpg, and prints
# INFO|<basename>|<width>|<height>|<frames>|<fps> so the caller knows the real size.
import bpy
import os
import sys
import glob

argv = sys.argv[sys.argv.index("--") + 1:]
src, out_dir, base = argv[0], argv[1], argv[2]
max_side = int(argv[3]) if len(argv) > 3 else 1280

scene = bpy.context.scene
scene.sequence_editor_create()
ed = scene.sequence_editor
strips = ed.strips if hasattr(ed, "strips") else ed.sequences   # Blender 5 renamed sequences -> strips

movie = strips.new_movie(name="video", filepath=src, channel=1, frame_start=1)
w = movie.elements[0].orig_width
h = movie.elements[0].orig_height
fps = float(getattr(movie, "fps", 0) or 30.0)
frames = movie.frame_final_duration

has_audio = False
try:
    strips.new_sound(name="audio", filepath=src, channel=2, frame_start=1)
    has_audio = True
except Exception:
    pass

scale = min(1.0, float(max_side) / max(w, h))
r = scene.render
r.resolution_x = int(round(w * scale / 2)) * 2
r.resolution_y = int(round(h * scale / 2)) * 2
r.resolution_percentage = 100
r.fps = max(1, int(round(fps)))
r.fps_base = 1.0
scene.frame_start = 1
scene.frame_end = frames

print("INFO|%s|%d|%d|%d|%.3f" % (base, r.resolution_x, r.resolution_y, frames, fps))

# --- poster frame, a quarter into the clip ---
poster_dir = os.path.join(out_dir, "_poster")
r.image_settings.file_format = 'JPEG'
r.image_settings.quality = 85
r.filepath = os.path.join(poster_dir, "f")
poster_frame = max(1, int(frames * 0.25))
scene.frame_set(poster_frame)
bpy.ops.render.render(write_still=True)
made = sorted(glob.glob(os.path.join(poster_dir, "f*.jpg")))
if made:
    dst = os.path.join(out_dir, base + "-poster.jpg")
    if os.path.exists(dst):
        os.remove(dst)
    os.replace(made[0], dst)
for leftover in glob.glob(os.path.join(poster_dir, "*")):
    os.remove(leftover)

# --- video ---
video_dir = os.path.join(out_dir, "_video")
if hasattr(r.image_settings, 'media_type'):
    r.image_settings.media_type = 'VIDEO'
r.image_settings.file_format = 'FFMPEG'
r.ffmpeg.format = 'MPEG4'
r.ffmpeg.codec = 'H264'
r.ffmpeg.constant_rate_factor = 'MEDIUM'
r.ffmpeg.ffmpeg_preset = 'GOOD'
r.ffmpeg.gopsize = 30
r.ffmpeg.audio_codec = 'AAC' if has_audio else 'NONE'
if has_audio:
    r.ffmpeg.audio_bitrate = 128
r.filepath = os.path.join(video_dir, "v")
bpy.ops.render.render(animation=True)
made = sorted(glob.glob(os.path.join(video_dir, "v*.mp4")))
if made:
    dst = os.path.join(out_dir, base + ".mp4")
    if os.path.exists(dst):
        os.remove(dst)
    os.replace(made[0], dst)
for leftover in glob.glob(os.path.join(video_dir, "*")):
    os.remove(leftover)
print("DONE|%s" % base)
