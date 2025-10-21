program SimpleMediaPipeDemo;

{$APPTYPE CONSOLE}

{
  Simple console demo showing MediaPipe hand tracking
  This is the minimal code needed to call the Python function
}

uses
  System.SysUtils,
  System.Variants,
  System.Math,
  PythonEngine,
  VarPyth;

var
  PythonEngine: TPythonEngine;
  PyResult: Variant;
  TestBytes: TBytes;
  PyBytes: PPyObject;
  Width, Height: Integer;
  I, HandIdx: Integer;
  LandmarkData: Variant;
  X, Y, Z: Double;

procedure CreatePyEngine;
begin
  PythonEngine := TPythonEngine.Create(nil);
  PythonEngine.Name := 'PythonEngine';
  PythonEngine.LoadDll;
end;

procedure DestroyEngine;
begin
  PythonEngine.Free;
end;

begin
  try
    WriteLn('MediaPipe Hand Tracking - Simple Console Demo');
    WriteLn('==============================================');
    WriteLn;

    CreatePyEngine;
    try
      // Load the MediaPipe module
      WriteLn('Loading MediaPipe script...');
      PythonEngine.ExecString('import mediapipe_hands');
      WriteLn('MediaPipe loaded successfully!');
      WriteLn;

      // Create a test frame (640x480 RGBA - gray image)
      Width := 640;
      Height := 480;
      SetLength(TestBytes, Width * Height * 4);
      
      // Fill with gray color (128, 128, 128, 255)
      for I := 0 to Length(TestBytes) - 1 do
      begin
        case I mod 4 of
          0, 1, 2: TestBytes[I] := 128;  // RGB
          3: TestBytes[I] := 255;        // Alpha
        end;
      end;

      WriteLn('Created test frame: ', Width, 'x', Height, ' RGBA');
      WriteLn('Processing frame with MediaPipe...');
      WriteLn;

      // Convert to Python bytes
      PyBytes := PythonEngine.PyBytes_FromStringAndSize(@TestBytes[0], Length(TestBytes));
      try
        // Call process_frame function
        PyResult := MainModule.mediapipe_hands.process_frame(
          VarPythonCreate(PyBytes),
          Width,
          Height
        );

        // Display results
        if BuiltinModule.len(PyResult) = 0 then
        begin
          WriteLn('No hands detected (expected with test image).');
        end
        else
        begin
          WriteLn('Detected ', BuiltinModule.len(PyResult), ' hand(s):');
          WriteLn;

          // Process each detected hand
          for HandIdx := 0 to BuiltinModule.len(PyResult) - 1 do
          begin
            WriteLn('Hand ', HandIdx + 1, ':');
            LandmarkData := PyResult.GetItem(HandIdx);
            
            WriteLn('  Total landmarks: ', BuiltinModule.len(LandmarkData));
            
            // Show first 5 landmarks
            for I := 0 to Min(4, BuiltinModule.len(LandmarkData) - 1) do
            begin
              X := LandmarkData.GetItem(I).GetItem('x');
              Y := LandmarkData.GetItem(I).GetItem('y');
              Z := LandmarkData.GetItem(I).GetItem('z');
              
              WriteLn(Format('  Landmark %d: x=%.3f, y=%.3f, z=%.3f', [I, X, Y, Z]));
            end;
            
            if BuiltinModule.len(LandmarkData) > 5 then
              WriteLn('  ... and ', BuiltinModule.len(LandmarkData) - 5, ' more landmarks');
            
            WriteLn;
          end;
        end;

        // Cleanup
        WriteLn('Cleaning up...');
        MainModule.mediapipe_hands.cleanup();
        WriteLn('Done!');

      finally
        PythonEngine.Py_DECREF(PyBytes);
      end;

    finally
      DestroyEngine;
    end;

  except
    on E: Exception do
    begin
      WriteLn('Error: ', E.ClassName, ': ', E.Message);
      WriteLn;
      WriteLn('Make sure:');
      WriteLn('  1. Python is installed and configured');
      WriteLn('  2. MediaPipe and NumPy are installed: pip install mediapipe numpy');
      WriteLn('  3. mediapipe_hands.py is in the same directory as this executable');
    end;
  end;
  
  WriteLn;
  WriteLn('Press Enter to exit...');
  ReadLn;
end.
