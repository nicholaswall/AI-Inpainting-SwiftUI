from io import BytesIO
from fastapi import FastAPI
from pydantic import BaseModel
from enum import Enum
import base64
import cv2
from typing import List
import numpy as np
from PIL import Image
import torch
from torchvision import transforms
from diffusers import DiffusionPipeline
from clipseg.models.clipseg import CLIPDensePredT
import matplotlib.pyplot as plt
from dotenv import load_dotenv, find_dotenv
import os

load_dotenv(find_dotenv())


def get_device():
    if torch.cuda.is_available():
        return "cuda"
    elif torch.backends.mps.is_available():
        return "mps"
    else:
        return "cpu"


device = get_device()

auth_token = os.environ.get("API_TOKEN")
print("Using auth token: ", auth_token)
print("Using device: ", device)

logging_flag = os.environ.get("LOGGING_FLAG")
debug_logging = False
if logging_flag == "True":
    debug_logging = True

print("Debug logging enabled: ", debug_logging)

transform = transforms.Compose(
    [
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        transforms.Resize((512, 512)),
    ]
)

pipe = DiffusionPipeline.from_pretrained(
    "runwayml/stable-diffusion-inpainting",
    revision="fp16",
    torch_dtype=torch.float16,
    use_auth_token=auth_token,
).to(device)

model = CLIPDensePredT(version="ViT-B/16", reduce_dim=64)
model.eval()
model.load_state_dict(
    torch.load("./clipseg/weights/rd64-uni.pth", map_location=torch.device(device)),
    strict=False,
)

guidance_scale = 7.5
num_samples = 1
# generator = torch.Generator(device="").manual_seed(0)

app = FastAPI()


class Point(BaseModel):
    x: int
    y: int


class MaskingMethod(str, Enum):
    draw = "Draw"
    prompt = "Prompt"


class InpaintingRequest(BaseModel):
    maskGenerationMethod: MaskingMethod = MaskingMethod.draw
    maskPrompt: str = ""
    image: str = ""
    replacementPrompt: str = ""
    xPoints: List[float] = []
    yPoints: List[float] = []
    brushSize: int = 18
    imageWidth: int = 0
    imageHeight: int = 0
    frameWidth: int = 0
    frameHeight: int = 0


@app.get("/")
async def root():
    return {"message": "MSLC Final Project Server is Running"}


@app.post("/inpaint/")
async def inpaint(request: InpaintingRequest):
    width = request.imageWidth
    height = request.imageHeight
    frameWidth = request.frameWidth
    frameHeight = request.frameHeight
    brushSize = request.brushSize

    print("Recieved prompt: ", request.replacementPrompt)
    print("Recieved image with size: y: ", width, " x:", height)
    print("Recieved frame with size: y: ", frameWidth, " x:", frameHeight)

    # Decode image to jpg from base64
    imageString = request.image
    image = base64.b64decode(imageString)
    with open("unaltered.jpg", "wb") as f:
        f.write(image)

    # Resize image to correct size
    image = Image.open("unaltered.jpg")
    image = image.resize((frameWidth, frameHeight))

    image.save("unaltered.jpg")
    image = image.resize((512, 512))
    image.save("unaltered-resized.jpg")

    if request.maskGenerationMethod == MaskingMethod.prompt:
        print("Prompting user for mask")

        word_masks = [request.maskPrompt]
        img = transform(image).unsqueeze(0)
        init_image = image.convert("RGB")
        mask = np.zeros((512, 512, 3), dtype=np.uint8)
        with torch.no_grad():
            preds = model(img.repeat(len(word_masks), 1, 1, 1), word_masks)[0]

        filename = "generated-mask.png"
        plt.imsave(filename, torch.sigmoid(preds[0][0]))
        img2 = cv2.imread(filename)
        gray_image = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
        (thresh, bw_image) = cv2.threshold(gray_image, 100, 255, cv2.THRESH_BINARY)
        cv2.cvtColor(bw_image, cv2.COLOR_BGR2RGB)
        mask = Image.fromarray(np.uint8(bw_image)).convert("RGB")

    elif request.maskGenerationMethod == MaskingMethod.draw:
        print("Drawing mask")

        mask = np.zeros((frameHeight, frameWidth, 3), dtype=np.uint8)

        point_count = 0

        print("X points: ", request.xPoints)
        print("Y points: ", request.yPoints)

        print("Generating mask...")
        for point in zip(request.xPoints, request.yPoints):
            mask = cv2.circle(
                mask,
                (int(point[0]), int(point[1])),
                radius=0,
                color=(255, 255, 255),
                thickness=brushSize,
            )
            pointCount = point_count + 1
        print("Added ", pointCount, " points to mask")

        cv2.imwrite("mask.jpg", mask)

        mask = Image.open("mask.jpg")
        mask = mask.resize((512, 512))
        mask.save("mask-resized.jpg")

        init_image = image.convert("RGB")

    print("Generating image...")
    output = pipe(
        prompt=request.replacementPrompt,
        image=image,
        mask_image=mask,
        strength=0.8,
        guidance_scale=guidance_scale,
        # generator=generator,
        num_images_per_prompt=num_samples,
    )

    outputImg = output.images[0]
    print(outputImg)
    outputImg.save("augmented.jpg")
    outputImg = outputImg.resize((width, height))
    outputImg.save("augmented-originalsize.jpg")

    buff = BytesIO()
    outputImg.save(buff, format="JPEG")
    b64Output = base64.b64encode(buff.getvalue())
    return {"image": b64Output}
