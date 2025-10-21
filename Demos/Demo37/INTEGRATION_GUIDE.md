# Integration Guide: MediaPipe Hand Tracking in FireMonkey

## Overview

This guide shows how to integrate MediaPipe hand tracking into a FireMonkey application that processes video frames (e.g., from a camera or video file).

## Key Concepts

### 1. Frame Format
- FireMonkey bitmaps are typically RGBA (4 bytes per pixel)
- MediaPipe expects RGB (3 bytes per pixel)
- The conversion happens on the Python side for efficiency

### 2. Data Flow
```
Delphi/FMX → Python → MediaPipe → Python → Delphi/FMX
   (Bitmap)  (bytes)   (process)  (results)  (landmarks)
```

## Complete Integration Example

### Step 1: Add Python Components to Your Form

```pascal
type
  TYourForm = class(TForm)
    PythonEngine: TPythonEngine;
    PythonInputOutput: TPythonInputOutput;
    // ... other components
  private
    FScriptLoaded: Boolean;
  public
    procedure LoadMediaPipeScript;
    function ProcessFrame(ABitmap: TBitmap): Variant;
  end;
```

### Step 2: Initialize MediaPipe

```pascal
procedure TYourForm.LoadMediaPipeScript;
begin
  // Add script directory to Python path
  PythonEngine.ExecString('import sys');
  PythonEngine.ExecString(Format('sys.path.insert(0, "%s")', 
    [ScriptPath]));
  
  // Import the module
  PythonEngine.ExecString('import mediapipe_hands');
  
  FScriptLoaded := True;
end;
```

### Step 3: Convert Bitmap to Bytes

```pascal
function TYourForm.BitmapToBytes(ABitmap: TBitmap): TBytes;
var
  BitmapData: TBitmapData;
begin
  if ABitmap.Map(TMapAccess.Read, BitmapData) then
  try
    SetLength(Result, ABitmap.Width * ABitmap.Height * 4);
    Move(BitmapData.Data^, Result[0], Length(Result));
  finally
    ABitmap.Unmap(BitmapData);
  end;
end;
```

### Step 4: Process Frame

```pascal
function TYourForm.ProcessFrame(ABitmap: TBitmap): Variant;
var
  FrameBytes: TBytes;
  PyBytes: PPyObject;
begin
  FrameBytes := BitmapToBytes(ABitmap);
  
  PyBytes := PythonEngine.PyBytes_FromStringAndSize(
    @FrameBytes[0], 
    Length(FrameBytes)
  );
  
  try
    Result := MainModule.mediapipe_hands.process_frame(
      VarPythonCreate(PyBytes),
      ABitmap.Width,
      ABitmap.Height
    );
  finally
    PythonEngine.Py_DECREF(PyBytes);
  end;
end;
```

### Step 5: Extract and Use Landmarks

```pascal
procedure TYourForm.ProcessAndDisplayLandmarks(ABitmap: TBitmap);
var
  PyResult: Variant;
  HandIdx, LandmarkIdx: Integer;
  Hand, Landmark: Variant;
  X, Y, Z: Double;
  PixelX, PixelY: Single;
begin
  PyResult := ProcessFrame(ABitmap);
  
  // Check if any hands were detected
  if BuiltinModule.len(PyResult) > 0 then
  begin
    // Process each detected hand
    for HandIdx := 0 to BuiltinModule.len(PyResult) - 1 do
    begin
      Hand := PyResult.GetItem(HandIdx);
      
      // Process each landmark (21 per hand)
      for LandmarkIdx := 0 to BuiltinModule.len(Hand) - 1 do
      begin
        Landmark := Hand.GetItem(LandmarkIdx);
        
        // Get normalized coordinates (0.0 to 1.0)
        X := Landmark.GetItem('x');
        Y := Landmark.GetItem('y');
        Z := Landmark.GetItem('z');
        
        // Convert to pixel coordinates
        PixelX := X * ABitmap.Width;
        PixelY := Y * ABitmap.Height;
        
        // Draw or process the landmark
        // Example: Draw a circle at landmark position
        DrawLandmark(Canvas, PixelX, PixelY);
      end;
    end;
  end;
end;
```

## Video/Camera Integration

### Processing Video Frames

```pascal
procedure TYourForm.OnCameraFrame(Sender: TObject; ABitmap: TBitmap);
begin
  // Process the frame
  ProcessAndDisplayLandmarks(ABitmap);
  
  // Display the frame
  ImageControl.Bitmap.Assign(ABitmap);
end;
```

### Performance Considerations

1. **Frame Rate**: MediaPipe can process ~30 FPS on most systems
2. **Threading**: Consider processing frames in a background thread
3. **Frame Skipping**: Process every Nth frame if needed for performance

```pascal
var
  FFrameCounter: Integer = 0;

procedure TYourForm.OnCameraFrame(Sender: TObject; ABitmap: TBitmap);
begin
  Inc(FFrameCounter);
  
  // Process every 3rd frame
  if (FFrameCounter mod 3) = 0 then
    ProcessAndDisplayLandmarks(ABitmap);
    
  ImageControl.Bitmap.Assign(ABitmap);
end;
```

## Hand Landmark Information

MediaPipe Hands provides 21 landmarks per hand:

- 0: WRIST
- 1-4: THUMB (CMC, MCP, IP, TIP)
- 5-8: INDEX_FINGER (MCP, PIP, DIP, TIP)
- 9-12: MIDDLE_FINGER (MCP, PIP, DIP, TIP)
- 13-16: RING_FINGER (MCP, PIP, DIP, TIP)
- 17-20: PINKY (MCP, PIP, DIP, TIP)

### Example: Detect Pointing Gesture

```pascal
function TYourForm.IsPointing(Hand: Variant): Boolean;
var
  IndexTip, IndexPIP: Variant;
  TipY, PIPY: Double;
begin
  // Get landmarks
  IndexTip := Hand.GetItem(8);   // Index finger tip
  IndexPIP := Hand.GetItem(6);   // Index finger PIP joint
  
  // Get Y coordinates
  TipY := IndexTip.GetItem('y');
  PIPY := IndexPIP.GetItem('y');
  
  // Index finger is pointing if tip is above PIP
  Result := TipY < PIPY;
end;
```

## Error Handling

```pascal
procedure TYourForm.ProcessFrameSafe(ABitmap: TBitmap);
begin
  try
    if not FScriptLoaded then
    begin
      LoadMediaPipeScript;
    end;
    
    ProcessAndDisplayLandmarks(ABitmap);
  except
    on E: Exception do
    begin
      // Log error
      ShowMessage('Error processing frame: ' + E.Message);
      
      // Optionally reload script
      FScriptLoaded := False;
    end;
  end;
end;
```

## Resource Cleanup

```pascal
procedure TYourForm.FormDestroy(Sender: TObject);
begin
  if FScriptLoaded then
  begin
    try
      // Call Python cleanup
      MainModule.mediapipe_hands.cleanup();
    except
      // Ignore errors during cleanup
    end;
  end;
end;
```

## Troubleshooting

### Issue: Slow Performance
- Process fewer frames (skip frames)
- Reduce image resolution before processing
- Use `min_detection_confidence` and `min_tracking_confidence` parameters

### Issue: No Hands Detected
- Ensure good lighting
- Check that hands are fully visible
- Adjust confidence thresholds in `mediapipe_hands.py`

### Issue: Memory Leaks
- Make sure to call `Py_DECREF` on PyBytes objects
- Call `cleanup()` when done
- Don't hold references to Python variants longer than needed

## Advanced: Custom Configuration

Modify `mediapipe_hands.py` to adjust MediaPipe settings:

```python
hands = mp_hands.Hands(
    static_image_mode=False,       # False for video, True for images
    max_num_hands=2,                # 1-2 hands
    min_detection_confidence=0.7,   # 0.0-1.0
    min_tracking_confidence=0.7,    # 0.0-1.0
    model_complexity=1              # 0 (lite) or 1 (full)
)
```

## See Also

- [MediaPipe Hands Documentation](https://google.github.io/mediapipe/solutions/hands.html)
- Demo35: Fast access to numpy arrays
- Demo29: Using Python Imaging Library
