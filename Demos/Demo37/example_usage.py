"""
Example showing how to use the process_frame function from Delphi
This demonstrates the exact interface requested in the problem statement
"""

import mediapipe_hands
import numpy as np

def create_test_frame(width=640, height=480):
    """
    Create a test frame with RGBA data
    Returns bytes that can be passed to process_frame
    """
    # Create a simple test image (gray background)
    image = np.ones((height, width, 4), dtype=np.uint8) * 128
    # Set alpha channel to 255 (opaque)
    image[:, :, 3] = 255
    
    # Convert to bytes
    return image.tobytes()

def example_usage():
    """
    Example of how to use process_frame from Delphi/Python
    """
    print("Creating test frame...")
    width, height = 640, 480
    frame_bytes = create_test_frame(width, height)
    
    print(f"Frame size: {len(frame_bytes)} bytes ({width}x{height} RGBA)")
    print("Processing frame with MediaPipe...")
    
    # Call the process_frame function (same as from Delphi)
    landmarks_list = mediapipe_hands.process_frame(frame_bytes, width, height)
    
    print(f"\nResults: {len(landmarks_list)} hand(s) detected")
    
    if landmarks_list:
        for hand_idx, hand_landmarks in enumerate(landmarks_list):
            print(f"\nHand {hand_idx + 1}:")
            print(f"  Total landmarks: {len(hand_landmarks)}")
            # Show first few landmarks
            for i, lm in enumerate(hand_landmarks[:5]):
                print(f"  Landmark {i}: x={lm['x']:.3f}, y={lm['y']:.3f}, z={lm['z']:.3f}")
            if len(hand_landmarks) > 5:
                print(f"  ... and {len(hand_landmarks) - 5} more landmarks")
    else:
        print("  (No hands detected in test image - expected with gray background)")
    
    # Clean up
    mediapipe_hands.cleanup()
    print("\nDone!")

if __name__ == "__main__":
    print("=" * 60)
    print("MediaPipe Hand Tracking - Example Usage")
    print("=" * 60)
    print()
    
    try:
        example_usage()
    except ImportError as e:
        print(f"Error: {e}")
        print("\nPlease install required packages:")
        print("  pip install mediapipe numpy")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
