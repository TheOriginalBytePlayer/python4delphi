"""
Simple test script to verify MediaPipe hand tracking works independently
This can be run standalone to test the Python setup before using with Delphi
"""

import numpy as np
import cv2

def test_mediapipe():
    """Test if MediaPipe is properly installed and working"""
    try:
        import mediapipe as mp
        print("✓ MediaPipe imported successfully")
        
        mp_hands = mp.solutions.hands
        hands = mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7
        )
        print("✓ MediaPipe Hands initialized successfully")
        
        # Create a simple test image (300x300, RGBA)
        width, height = 300, 300
        test_image = np.zeros((height, width, 3), dtype=np.uint8)
        test_image[:, :] = [128, 128, 128]  # Gray background
        
        # Process the test image
        results = hands.process(test_image)
        print("✓ Image processing works (no hands expected in gray image)")
        
        hands.close()
        print("✓ MediaPipe Hands closed successfully")
        
        print("\n✓✓✓ All tests passed! MediaPipe is ready to use.")
        return True
    except ImportError as e:
        print(f"✗ Import error: {e}")
        print("  Please install: pip install mediapipe numpy")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

if __name__ == "__main__":
    print("Testing MediaPipe setup...\n")
    test_mediapipe()
