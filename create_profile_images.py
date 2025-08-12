from PIL import Image, ImageDraw, ImageFont
import os

# Create directory if it doesn't exist
os.makedirs("icon", exist_ok=True)

# Define profile colors and names
profiles = [
    ("profile_yuki.png", (52, 152, 219), "Yuki"),  # Blue
    ("profile_ren.png", (231, 76, 60), "Ren"),     # Red
    ("profile_keiji.png", (46, 204, 113), "Keiji"), # Green
    ("ic_message.png", (155, 89, 182), "MSG")      # Purple
]

# Create each profile image
for filename, color, name in profiles:
    # Create a new image with a colored background
    img = Image.new('RGB', (200, 200), color)
    draw = ImageDraw.Draw(img)
    
    # Add text (name)
    # Note: Using default font since we can't easily load custom fonts
    draw.text((100, 100), name, fill=(255, 255, 255), anchor="mm")
    
    # Save the image
    img.save(f"icon/{filename}")
    print(f"Created {filename}")