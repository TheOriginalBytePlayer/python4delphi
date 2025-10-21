"""
mediapipe_hands.py
Accepts packed 3-channel RGB image bytes only (width*height*3).
Provides init_hands(), process_frame(frame_bytes, width, height), and close_hands().

Added:
- init_hands(..., model_complexity=1) as the last parameter (default=1).
- Backwards-compatible behavior if the installed mediapipe version does not accept model_complexity.
- process_frame now returns both normalized landmark coordinates and pixel coordinates (when available).
"""

import numpy as np
import mediapipe as mp
from typing import List, Dict, Optional

mp_hands = mp.solutions.hands
drawing_module = mp.solutions.drawing_utils

# Module-level (private) Hands instance reused across frames.
_hands: Optional[mp_hands.Hands] = None

def init_hands(static_image_mode: bool = False,
               max_num_hands: int = 2,
               min_detection_confidence: float = 0.5,
               min_tracking_confidence: float = 0.5,
               model_complexity: int = 1) -> None:
    """
    Initialize the module-level Hands instance (or reinitialize with new params).
    Parameters:
      - static_image_mode: set True for single images, False for video streams (use False for camera).
      - max_num_hands: maximum hands to detect.
      - min_detection_confidence: detector confidence threshold (0..1).
      - min_tracking_confidence: tracker confidence threshold (0..1).
      - model_complexity: (optional) model complexity (higher -> more accurate/slower). Default 1.
        If the installed mediapipe version does not support this keyword, the call will fall back
        to creating Hands without model_complexity (backward-compatible).
    Call once before processing frames (or let process_frame call it lazily).
    """
    global _hands
    # If already initialized, close and re-create with new params
    if _hands is not None:
        try:
            _hands.close()
        except Exception:
            pass
        _hands = None

    # Try to pass model_complexity if available in this mediapipe version.
    try:
        _hands = mp_hands.Hands(static_image_mode=static_image_mode,
                                max_num_hands=max_num_hands,
                                model_complexity=model_complexity,
                                min_detection_confidence=min_detection_confidence,
                                min_tracking_confidence=min_tracking_confidence)
    except TypeError:
        # Older mediapipe may not accept model_complexity keyword; fall back
        print("mediapipe_hands: mediapipe.Hands() does not accept model_complexity; falling back without it.")
        _hands = mp_hands.Hands(static_image_mode=static_image_mode,
                                max_num_hands=max_num_hands,
                                min_detection_confidence=min_detection_confidence,
                                min_tracking_confidence=min_tracking_confidence)

def _ensure_hands() -> None:
    """
    Lazily initialize _hands with sensible defaults if not already done.
    """
    if _hands is None:
        init_hands()

def close_hands() -> None:
    """
    Cleanly close and free the module-level Hands instance.
    Call this when your application is shutting down.
    """
    global _hands
    if _hands is not None:
        try:
            _hands.close()
        finally:
            _hands = None

def _bytes_to_rgb_frame(frame_bytes: (bytes, bytearray, memoryview), width: int, height: int) -> np.ndarray:
    """
    Convert incoming bytes to a height x width x 3 uint8 RGB ndarray.
    Only accepts exactly width*height*3 bytes. Raises ValueError otherwise.
    Ensures a C-contiguous array is returned to avoid 'Reference mode is unavailable' errors.
    """
    if not isinstance(frame_bytes, (bytes, bytearray, memoryview)):
        raise TypeError("frame_bytes must be bytes, bytearray, or memoryview")

    arr = np.frombuffer(frame_bytes, dtype=np.uint8)
    expected = width * height * 3
    if arr.size != expected:
        raise ValueError(f"Expected {expected} bytes for packed RGB (width*height*3). "
                         f"Received {arr.size} bytes. Are you sending 4-channel/bgra data or padded rows?")

    # Make sure the array is C-contiguous and reshape
    if not arr.flags['C_CONTIGUOUS']:
        arr = arr.copy()
    frame = arr.reshape((height, width, 3))
    return frame

def process_frame(frame_bytes: (bytes, bytearray, memoryview), width: int, height: int) -> List[List[Dict[str, float]]]:
    """
    Process a frame supplied as packed RGB bytes (3 bytes per pixel).
    """
    _ensure_hands()
    if _hands is None:
        raise RuntimeError("Hands instance not initialized")

    frame = _bytes_to_rgb_frame(frame_bytes, width, height)

    # MediaPipe expects RGB uint8 images
    results = _hands.process(frame)

    landmarks_list: List[List[Dict[str, float]]] = []
    if not results.multi_hand_landmarks:
        return landmarks_list

    frameWidth = int(width)
    frameHeight = int(height)

    for hand_landmarks in results.multi_hand_landmarks:
        one_hand = []
        for normalizedLandmark in hand_landmarks.landmark:
            # normalized coordinates (0..1)
            nx = float(normalizedLandmark.x)
            ny = float(normalizedLandmark.y)
            nz = float(normalizedLandmark.z)

            # convert to pixel coordinates when possible
            pixelCoordinatesLandmark = drawing_module._normalized_to_pixel_coordinates(nx, ny, frameWidth, frameHeight)
            # pixelCoordinatesLandmark is either (px, py) or None
            if pixelCoordinatesLandmark is not None:
                px, py = int(pixelCoordinatesLandmark[0]), int(pixelCoordinatesLandmark[1])
            else:
                px = float(-1)
                py = float(-1);

            lm_entry = {
                'x': nx,
                'y': ny,
                'z': nz,
                'px': px,
                'py': py
            }
            one_hand.append(lm_entry)
        landmarks_list.append(one_hand)

    return landmarks_list
