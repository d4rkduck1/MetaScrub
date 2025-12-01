# MetaScrub

Remove metadata recursively. Fully rebuilds PDFs for guaranteed cleanup.

## Requirements

- `exiftool`
- `ghostscript` - PDF reconstruction
- `zsh`

## Installation

```bash
git clone https://github.com/d4rkduck1/metascrub.git
cd metascrub
chmod +x metascrub.sh
```

## Usage

```bash
# Process current directory
./metascrub.sh

# Process specific directory
./metascrub.sh /path/to/directory

# Example
./metascrub.sh ~/Downloads/
```

## Supported Formats

200+ file formats via ExifTool:
- Images: JPG, PNG, GIF, TIFF, BMP, WebP, HEIC
- Documents: PDF, DOCX, XLSX, PPTX
- Video: MP4, MOV, AVI, MKV
- Audio: MP3, WAV, FLAC, M4A
- RAW: CR2, NEF, ARW, DNG, ORF
