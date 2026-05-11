from pdf2image import convert_from_path
import os

PDF_FOLDER = "dataset/raw_drawings"
OUTPUT_FOLDER = "dataset/images"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

for file_name in os.listdir(PDF_FOLDER):

    if file_name.lower().endswith(".pdf"):

        pdf_path = os.path.join(PDF_FOLDER, file_name)

        print(f"Converting: {file_name}")

        try:
            pages = convert_from_path(pdf_path, dpi=300)

            for i, page in enumerate(pages):

                image_name = f"{os.path.splitext(file_name)[0]}_page_{i+1}.png"

                image_path = os.path.join(
                    OUTPUT_FOLDER,
                    image_name
                )

                page.save(image_path, "PNG")

                print(f"Saved: {image_name}")

        except Exception as e:
            print(f"Error converting {file_name}: {e}")

print("✅ All PDFs converted successfully")