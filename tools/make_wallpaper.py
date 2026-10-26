"""Generates the Asox default wallpaper (sakura night). Needs: pip install pillow"""
import math, random
from PIL import Image, ImageDraw, ImageFilter

W, H = 2560, 1440
random.seed(7)

def lerp(a, b, t): return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

# Sky gradient: indigo -> purple -> pink glow at the horizon
stops = [(0.0, (22, 14, 56)), (0.45, (74, 36, 120)), (0.75, (255, 158, 207)), (1.0, (255, 214, 196))]
img = Image.new("RGB", (W, H))
px = ImageDraw.Draw(img)
for y in range(H):
    t = y / H
    for i in range(len(stops) - 1):
        if stops[i][0] <= t <= stops[i + 1][0]:
            k = (t - stops[i][0]) / (stops[i + 1][0] - stops[i][0])
            px.line([(0, y), (W, y)], fill=lerp(stops[i][1], stops[i + 1][1], k))
            break

# Stars
for _ in range(220):
    x, y = random.randint(0, W), random.randint(0, int(H * 0.5))
    r = random.choice([1, 1, 2])
    px.ellipse([x - r, y - r, x + r, y + r], fill=(255, 240, 250))

# Big moon with glow
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
cx, cy, R = int(W * 0.68), int(H * 0.34), 190
gd.ellipse([cx - R * 2, cy - R * 2, cx + R * 2, cy + R * 2], fill=(255, 180, 220, 90))
glow = glow.filter(ImageFilter.GaussianBlur(70))
img.paste(glow, (0, 0), glow)
px = ImageDraw.Draw(img)
px.ellipse([cx - R, cy - R, cx + R, cy + R], fill=(255, 238, 246))

# Mountain layers
def ridge(base, amp, color, seed):
    random.seed(seed)
    ph = [random.random() * 6.28 for _ in range(3)]
    pts = [(0, H)]
    for x in range(0, W + 8, 8):
        y = base + amp * (math.sin(x / 260 + ph[0]) * 0.6 + math.sin(x / 110 + ph[1]) * 0.3 + math.sin(x / 47 + ph[2]) * 0.1)
        pts.append((x, y))
    pts.append((W, H))
    px.polygon(pts, fill=color)

ridge(H * 0.70, 90, (150, 90, 170), 1)
ridge(H * 0.78, 80, (96, 58, 140), 2)
ridge(H * 0.86, 70, (52, 32, 92), 3)
ridge(H * 0.94, 50, (28, 18, 58), 4)

# Falling sakura petals
petals = Image.new("RGBA", (W, H), (0, 0, 0, 0))
for _ in range(140):
    x, y = random.randint(0, W), random.randint(0, H)
    w, h = random.randint(8, 20), random.randint(5, 11)
    p = Image.new("RGBA", (w * 2, h * 2), (0, 0, 0, 0))
    ImageDraw.Draw(p).ellipse([0, 0, w * 2 - 1, h * 2 - 1], fill=(255, random.randint(160, 200), 215, random.randint(150, 230)))
    p = p.rotate(random.randint(0, 360), expand=True)
    petals.paste(p, (x, y), p)
img = Image.alpha_composite(img.convert("RGBA"), petals).convert("RGB")
img.save("profile/airootfs/usr/share/backgrounds/asox/sakura-night.png", optimize=True)
print("wallpaper ok")
