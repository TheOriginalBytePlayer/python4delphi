# Demo37 - MediaPipe Hand Tracking with FireMonkey

This demo demonstrates how to use MediaPipe hand tracking library from Python in a FireMonkey application.

## Features

- Load and process images with MediaPipe hand detection
- Pass image frame data from Delphi to Python as bytes
- Process frames with MediaPipe to detect hand landmarks
- Return structured data (list of dictionaries) from Python to Delphi
- Display detected hand landmarks with coordinates

## Requirements

### Python Packages
Install the required Python packages:

```bash
pip install mediapipe numpy
```

### Python Environment
Make sure you have Python 3.7 or higher installed and configured with Python4Delphi.

## How It Works

1. **Load Python Script**: Click this button to initialize the MediaPipe library and load the Python script (`mediapipe_hands.py`)

2. **Load Image**: Load a test image containing hands (JPEG, PNG, BMP formats supported)

3. **Process Frame**: Process the loaded image with MediaPipe hand detection
   - The image is converted to bytes
   - Passed to Python using PyBytes
   - MediaPipe processes the frame
   - Hand landmarks are returned as a list of dictionaries
   - Results are displayed in the output panel

## Technical Details

### Frame Data Transfer

The demo shows how to efficiently transfer image data:
- FMX Bitmap is mapped to get pixel data (RGBA format)
- Data is converted to TBytes
- TBytes is converted to Python bytes using `PyBytes_FromStringAndSize`
- Python converts bytes to numpy array
- Numpy array is reshaped to (height, width, 4) for RGBA
- Alpha channel is dropped to get RGB for MediaPipe

### Return Data Structure

MediaPipe returns hand landmarks as:
```python
[
    [  # First hand
        {'x': 0.5, 'y': 0.6, 'z': 0.01},  # Landmark 0
        {'x': 0.52, 'y': 0.61, 'z': 0.012}, # Landmark 1
        # ... 21 landmarks total per hand
    ],
    [  # Second hand (if detected)
        # ... 21 landmarks
    ]
]
```

The Delphi code uses VarPyth to access this nested structure:
- `PyResult.GetItem(HandIdx)` - Get a specific hand
- `LandmarkData.GetItem(I)` - Get a specific landmark
- `Landmark.GetItem('x')` - Get the x coordinate

## Files

- `MediaPipeDemo.dpr` - FireMonkey GUI demo project file
- `SimpleMediaPipeDemo.dpr` - Simple console demo (minimal code example)
- `MainForm.pas` - Main form implementation for GUI demo
- `MainForm.fmx` - FireMonkey form layout
- `mediapipe_hands.py` - Python script with MediaPipe hand tracking
- `example_usage.py` - Standalone Python example showing usage
- `test_mediapipe.py` - Test script to verify MediaPipe installation
- `README.md` - This file

## Getting Started

### Option 1: Simple Console Demo (Recommended for testing)

The `SimpleMediaPipeDemo.dpr` provides the minimal code to call the Python function:

1. Make sure `mediapipe_hands.py` is in the same directory
2. Compile and run `SimpleMediaPipeDemo.dpr`
3. It will create a test frame and process it

### Option 2: GUI Demo with Image Loading

The `MediaPipeDemo.dpr` provides a full GUI to load and process images:

1. Compile and run the FireMonkey application
2. Click "Load Python Script" 
3. Click "Load Image" to select an image
4. Click "Process Frame" to detect hands

## Notes

- The demo uses MediaPipe's Hands solution which can detect up to 2 hands
- Each hand has 21 landmarks (finger joints, palm, etc.)
- Coordinates are normalized (0.0 to 1.0) relative to image dimensions
- The z coordinate represents depth (negative values = closer to camera)

## See Also

- [MediaPipe Hands Documentation](https://google.github.io/mediapipe/solutions/hands.html)
- Demo29 - Using Python Imaging Library (PIL)
- Demo35 - Fast access to numpy arrays using the buffer protocol
