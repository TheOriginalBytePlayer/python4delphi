# Quick Start: Using MediaPipe Hand Tracking in Your FireMonkey App

## Installation

### 1. Install Python Packages

```bash
pip install mediapipe numpy
```

### 2. Copy Files to Your Project

Copy the following file to your project directory:
- `mediapipe_hands.py`

## Minimal Working Example

### Step 1: Add Components to Your Form

Add these components to your form (drag from palette or create in code):
- `TPythonEngine` - Named `PythonEngine`
- `TPythonInputOutput` - Named `PythonInputOutput` (connect to PythonEngine)

### Step 2: Add This Code to Your Form Unit

```pascal
unit YourForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, 
  System.Variants, System.Math, System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  PythonEngine, VarPyth;

type
  TYourForm = class(TForm)
    PythonEngine: TPythonEngine;
    PythonInputOutput: TPythonInputOutput;
    btnProcess: TButton;
    ImageControl1: TImageControl;
    procedure FormCreate(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
  private
    FScriptLoaded: Boolean;
    function BitmapToBytes(ABitmap: TBitmap): TBytes;
  public
  end;

var
  YourForm: TYourForm;

implementation

{$R *.fmx}

procedure TYourForm.FormCreate(Sender: TObject);
begin
  FScriptLoaded := False;
  
  // Load the MediaPipe script
  try
    PythonEngine.ExecString('import sys');
    PythonEngine.ExecString(Format('sys.path.insert(0, "%s")', 
      [StringReplace(ExtractFilePath(ParamStr(0)), '\', '/', [rfReplaceAll])]));
    PythonEngine.ExecString('import mediapipe_hands');
    FScriptLoaded := True;
  except
    on E: Exception do
      ShowMessage('Error loading MediaPipe: ' + E.Message);
  end;
end;

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

procedure TYourForm.btnProcessClick(Sender: TObject);
var
  FrameBytes: TBytes;
  PyBytes: PPyObject;
  PyResult: Variant;
  HandIdx, LandmarkIdx: Integer;
  Hand, Landmark: Variant;
  X, Y, Z: Double;
begin
  if not FScriptLoaded then
  begin
    ShowMessage('MediaPipe not loaded!');
    Exit;
  end;

  if ImageControl1.Bitmap.IsEmpty then
  begin
    ShowMessage('No image loaded!');
    Exit;
  end;

  try
    // Convert bitmap to bytes
    FrameBytes := BitmapToBytes(ImageControl1.Bitmap);
    
    // Create Python bytes object
    PyBytes := PythonEngine.PyBytes_FromStringAndSize(
      @FrameBytes[0], 
      Length(FrameBytes)
    );
    
    try
      // Call the Python function
      PyResult := MainModule.mediapipe_hands.process_frame(
        VarPythonCreate(PyBytes),
        ImageControl1.Bitmap.Width,
        ImageControl1.Bitmap.Height
      );
      
      // Process results
      if BuiltinModule.len(PyResult) = 0 then
      begin
        ShowMessage('No hands detected.');
      end
      else
      begin
        // Iterate through detected hands
        for HandIdx := 0 to BuiltinModule.len(PyResult) - 1 do
        begin
          Hand := PyResult.GetItem(HandIdx);
          
          // Get first landmark as example
          Landmark := Hand.GetItem(0);  // Wrist
          X := Landmark.GetItem('x');
          Y := Landmark.GetItem('y');
          Z := Landmark.GetItem('z');
          
          ShowMessage(Format('Hand %d detected! Wrist at: x=%.3f, y=%.3f, z=%.3f', 
            [HandIdx + 1, X, Y, Z]));
        end;
      end;
      
    finally
      PythonEngine.Py_DECREF(PyBytes);
    end;
    
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end;

end.
```

## That's It!

You now have a working MediaPipe hand tracking integration!

## Next Steps

1. **Process video frames**: Call `process_frame` in your camera/video callback
2. **Draw landmarks**: Use the x, y coordinates to draw on your image
3. **Detect gestures**: Analyze landmark positions to recognize hand gestures
4. **Optimize performance**: Process every Nth frame if needed

See `INTEGRATION_GUIDE.md` for more advanced examples including:
- Real-time video processing
- Gesture detection
- Performance optimization
- Error handling best practices
