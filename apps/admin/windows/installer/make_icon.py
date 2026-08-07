from PIL import Image
from pathlib import Path

src = Path(r"C:\Users\excalibur\Desktop\TaxiGo\apps\admin\assets\images\taxigo_logo.png")
ico = Path(r"C:\Users\excalibur\Desktop\TaxiGo\apps\admin\windows\runner\resources\app_icon.ico")
img = Image.open(src).convert("RGBA")
w, h = img.size
side = min(w, h)
left = (w - side) // 2
top = (h - side) // 2
img = img.crop((left, top, left + side, top + side))
sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
img.save(ico, format="ICO", sizes=sizes)
print("ICO written", ico, ico.stat().st_size)
