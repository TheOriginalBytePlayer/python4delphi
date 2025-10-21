"""
MediaPipe Hand Tracking Demo
Demonstrates processing video frames with MediaPipe and returning hand landmarks to Delphi/FireMonkey
Requires: pip install mediapipe numpy
"""

import mediapipe as mp
import numpy as np

# Initialize MediaPipe Hands
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)
mp_drawing = mp.solutions.drawing_utils

    
def process_frame(frame_bytes, width, height):
    """
    Process a frame and detect hand landmarks
    
    Args:
        frame_bytes: bytes object containing the image data
        width: image width
        height: image height
    
    Returns:
        List of hand landmarks, where each hand is a list of dictionaries with x, y, z coordinates
    """
    # Convert bytes to numpy array
    arr = np.frombuffer(frame_bytes, dtype=np.uint8)
    
    # Reshape the array to the image dimensions
    # Assuming RGBA format (4 channels)
    image = arr.reshape((height, width, 4))
    
    # Drop alpha channel - MediaPipe expects RGB
    image = image[:, :, :3]
   
    # Process the image
    results = hands.process(image)
    
    # Extract landmarks
    landmarks_list = []
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # Each landmark has x, y, z
            one_hand = []
            for lm in hand_landmarks.landmark:
                one_hand.append({'x': lm.x, 'y': lm.y, 'z': lm.z})
            landmarks_list.append(one_hand)
    
    # Return landmarks_list to Delphi
    return landmarks_list


def cleanup():
    """
    Clean up MediaPipe resources
    """
    global hands
    if hands:
        hands.close()
