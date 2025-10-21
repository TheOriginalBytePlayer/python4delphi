# OpenCV Camera Integration Example

This example demonstrates how to use the new `TOpenCVCamera` component that replaces the FireMonkey `TCameraComponent` with OpenCV-based camera functionality.

## Overview

The `TOpenCVCamera` component provides camera capture functionality using OpenCV (cv2.VideoCapture) instead of FireMonkey's native camera component. This allows for:

- Cross-platform camera support through OpenCV
- Direct access to numpy arrays for image processing
- Seamless integration with Python's computer vision ecosystem
- Conversion to Delphi bitmaps for UI display

## Requirements

1. **Python4Delphi (P4D)** installed and configured in your Delphi application
2. **OpenCV for Python** installed:
   ```bash
   pip install opencv-python
   ```

## Key Features

### TOpenCVCamera Component

- **Properties:**
  - `Active: Boolean` - Start/stop the camera
  - `DeviceIndex: Integer` - Select camera device (default: 0)

- **Methods:**
  - `CaptureFrame(): numpy.ndarray` - Captures a frame and returns it as a numpy array
  - `GetFrameAsBitmap(): TBitmap` - Captures a frame and converts it to a Delphi TBitmap

## Usage Example

See `opencv_camera_example.py` for detailed examples of:
- Creating and configuring the camera
- Capturing frames as numpy arrays
- Converting frames to Delphi bitmaps
- Error handling and resource management

## Differences from TCameraComponent

| Feature | TCameraComponent (FMX) | TOpenCVCamera |
|---------|------------------------|---------------|
| Backend | FireMonkey native | OpenCV (cv2) |
| Frame format | FMX-specific | numpy array |
| Processing | Limited | Full OpenCV/numpy ecosystem |
| Platform support | FMX platforms | OpenCV-supported platforms |

## Migration Guide

To migrate from `TCameraComponent` to `TOpenCVCamera`:

1. Replace component creation:
   ```python
   # Old:
   # camera = CreateComponent('TCameraComponent', MainForm)
   
   # New:
   camera = CreateComponent('TOpenCVCamera', MainForm)
   ```

2. Activate the camera:
   ```python
   camera.DeviceIndex = 0
   camera.Active = True
   ```

3. Capture frames:
   ```python
   # Get as numpy array for processing
   frame = camera.CaptureFrame()
   
   # Or get as Delphi bitmap for display
   bitmap = camera.GetFrameAsBitmap()
   ```

4. Always deactivate when done:
   ```python
   camera.Active = False
   ```

## Notes

- Ensure OpenCV is properly installed in your Python environment
- The camera must be activated before capturing frames
- Always deactivate the camera when done to release resources
- The `GetFrameAsBitmap()` method automatically converts BGR to RGB format
