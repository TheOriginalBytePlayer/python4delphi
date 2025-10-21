"""
Example: Using OpenCV Camera with Python4Delphi

This example demonstrates how to use the TOpenCVCamera component
to capture frames from a camera using OpenCV within a Delphi application.

Requirements:
- Python with opencv-python installed (pip install opencv-python)
- A Delphi application with Python4Delphi and WrapFmxMedia unit

Usage from Python script within P4D application:
"""

# Import the Delphi wrapper module (usually named after your project)
# from spam import MainForm, CreateComponent

# Example 1: Create an OpenCV camera component
# camera = CreateComponent('TOpenCVCamera', MainForm)

# Example 2: Configure and activate the camera
# camera.DeviceIndex = 0  # Use default camera (0)
# camera.Active = True    # Start capturing

# Example 3: Capture a frame as numpy array
# frame = camera.CaptureFrame()
# if frame is not None:
#     print(f"Frame shape: {frame.shape}")
#     print(f"Frame dtype: {frame.dtype}")
#     # Process the frame using OpenCV or numpy
#     import cv2
#     import numpy as np
#     gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
#     print(f"Gray frame shape: {gray.shape}")

# Example 4: Capture a frame and convert to Delphi bitmap
# bitmap = camera.GetFrameAsBitmap()
# if bitmap is not None:
#     # Assign to an Image component
#     # MainForm.Image1.Bitmap = bitmap
#     pass

# Example 5: Stop the camera when done
# camera.Active = False

# Complete example in a function:
def capture_and_display():
    """
    Capture frames from camera and display in Delphi image component.
    This function should be called from within a Delphi application
    with Python4Delphi integration.
    """
    # Note: The actual import will depend on your P4D setup
    # This is a template showing the usage pattern
    
    # from spam import MainForm, CreateComponent
    # import cv2
    
    # Create camera component
    # camera = CreateComponent('TOpenCVCamera', MainForm)
    # camera.DeviceIndex = 0
    # camera.Active = True
    
    # Capture and display frames
    # for i in range(10):  # Capture 10 frames
    #     bitmap = camera.GetFrameAsBitmap()
    #     if bitmap:
    #         MainForm.Image1.Bitmap = bitmap
    #         # Update UI
    #         MainForm.Update()
    
    # Clean up
    # camera.Active = False
    
    pass

# Example with error handling:
def capture_with_error_handling():
    """
    Robust example with proper error handling.
    """
    # from spam import MainForm, CreateComponent
    
    # camera = None
    # try:
    #     camera = CreateComponent('TOpenCVCamera', MainForm)
    #     camera.DeviceIndex = 0
    #     camera.Active = True
    #     
    #     # Capture frames
    #     frame = camera.CaptureFrame()
    #     if frame is not None:
    #         print("Frame captured successfully")
    #         # Process frame here
    #     else:
    #         print("Failed to capture frame")
    # 
    # except Exception as e:
    #     print(f"Error: {e}")
    # 
    # finally:
    #     if camera and camera.Active:
    #         camera.Active = False
    
    pass

if __name__ == "__main__":
    print("This example should be run within a Python4Delphi application.")
    print("See the function definitions above for usage examples.")
