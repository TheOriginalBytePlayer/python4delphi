unit MainForm;

{
  Demonstrates MediaPipe Hand Tracking with FireMonkey
  
  This demo shows how to:
  - Pass image/frame data from Delphi to Python
  - Process frames with MediaPipe to detect hand landmarks
  - Return structured data (list of dictionaries) from Python to Delphi
  
  Requirements:
    - Python with mediapipe and numpy installed
    - pip install mediapipe numpy
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ListBox, FMX.Objects,
  PythonEngine, VarPyth;

type
  TfrmMain = class(TForm)
    PythonEngine: TPythonEngine;
    PythonInputOutput: TPythonInputOutput;
    Panel1: TPanel;
    btnLoadScript: TButton;
    btnProcessFrame: TButton;
    Memo1: TMemo;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    memoOutput: TMemo;
    Label2: TLabel;
    ImageControl1: TImageControl;
    btnLoadImage: TButton;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    procedure btnLoadScriptClick(Sender: TObject);
    procedure btnProcessFrameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLoadImageClick(Sender: TObject);
    procedure PythonInputOutputSendUniData(Sender: TObject; const Data: string);
  private
    { Private declarations }
    FScriptLoaded: Boolean;
    procedure LoadPythonScript;
    function BitmapToBytes(ABitmap: TBitmap): TBytes;
    procedure ProcessFrameWithMediaPipe;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.IOUtils;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FScriptLoaded := False;
  Memo1.Lines.Add('# MediaPipe Hand Tracking Demo');
  Memo1.Lines.Add('# Click "Load Python Script" to initialize MediaPipe');
  Memo1.Lines.Add('# Then click "Load Image" to load a test image');
  Memo1.Lines.Add('# Finally click "Process Frame" to detect hands');
end;

procedure TfrmMain.btnLoadImageClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    try
      ImageControl1.Bitmap.LoadFromFile(OpenDialog1.FileName);
      memoOutput.Lines.Add('Image loaded: ' + OpenDialog1.FileName);
      memoOutput.Lines.Add(Format('Size: %d x %d', [
        ImageControl1.Bitmap.Width,
        ImageControl1.Bitmap.Height
      ]));
    except
      on E: Exception do
        memoOutput.Lines.Add('Error loading image: ' + E.Message);
    end;
  end;
end;

procedure TfrmMain.LoadPythonScript;
var
  ScriptPath: string;
begin
  // Load the mediapipe_hands.py script
  ScriptPath := ExtractFilePath(ParamStr(0)) + 'mediapipe_hands.py';
  
  if not FileExists(ScriptPath) then
  begin
    // Try current directory
    ScriptPath := 'mediapipe_hands.py';
    if not FileExists(ScriptPath) then
    begin
      memoOutput.Lines.Add('Error: mediapipe_hands.py not found!');
      memoOutput.Lines.Add('Make sure mediapipe_hands.py is in the same directory as the executable.');
      Exit;
    end;
  end;

  try
    PythonEngine.ExecString('import sys');
    PythonEngine.ExecString(Format('sys.path.insert(0, "%s")', 
      [StringReplace(ExtractFilePath(ScriptPath), '\', '/', [rfReplaceAll])]));
    
    memoOutput.Lines.Add('Loading MediaPipe script...');
    PythonEngine.ExecString('import mediapipe_hands');
    
    FScriptLoaded := True;
    memoOutput.Lines.Add('MediaPipe script loaded successfully!');
    memoOutput.Lines.Add('MediaPipe Hands initialized.');
    memoOutput.Lines.Add('Ready to process frames.');
  except
    on E: Exception do
    begin
      memoOutput.Lines.Add('Error loading script: ' + E.Message);
      memoOutput.Lines.Add('Make sure mediapipe and numpy are installed:');
      memoOutput.Lines.Add('  pip install mediapipe numpy');
    end;
  end;
end;

procedure TfrmMain.btnLoadScriptClick(Sender: TObject);
begin
  LoadPythonScript;
end;

function TfrmMain.BitmapToBytes(ABitmap: TBitmap): TBytes;
var
  BitmapData: TBitmapData;
  I: Integer;
begin
  // Map the bitmap to get access to the pixel data
  if ABitmap.Map(TMapAccess.Read, BitmapData) then
  try
    // Calculate the size: width * height * 4 bytes per pixel (RGBA)
    SetLength(Result, ABitmap.Width * ABitmap.Height * 4);
    
    // Copy the data
    Move(BitmapData.Data^, Result[0], Length(Result));
  finally
    ABitmap.Unmap(BitmapData);
  end;
end;

procedure TfrmMain.ProcessFrameWithMediaPipe;
var
  FrameBytes: TBytes;
  PyBytes: PPyObject;
  PyResult: Variant;
  I, J: Integer;
  HandIdx: Integer;
  LandmarkData: Variant;
  X, Y, Z: Double;
begin
  if not FScriptLoaded then
  begin
    memoOutput.Lines.Add('Please load the Python script first!');
    Exit;
  end;

  if ImageControl1.Bitmap.IsEmpty then
  begin
    memoOutput.Lines.Add('Please load an image first!');
    Exit;
  end;

  try
    memoOutput.Lines.Add('Processing frame...');
    
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
      
      // Process the results
      if VarIsPython(PyResult) then
      begin
        if BuiltinModule.len(PyResult) = 0 then
        begin
          memoOutput.Lines.Add('No hands detected.');
        end
        else
        begin
          memoOutput.Lines.Add(Format('Detected %d hand(s):', [BuiltinModule.len(PyResult)]));
          
          // Iterate through each detected hand
          for HandIdx := 0 to BuiltinModule.len(PyResult) - 1 do
          begin
            memoOutput.Lines.Add(Format('  Hand %d:', [HandIdx + 1]));
            LandmarkData := PyResult.GetItem(HandIdx);
            
            // Display a few sample landmarks
            for I := 0 to Min(4, BuiltinModule.len(LandmarkData) - 1) do
            begin
              X := LandmarkData.GetItem(I).GetItem('x');
              Y := LandmarkData.GetItem(I).GetItem('y');
              Z := LandmarkData.GetItem(I).GetItem('z');
              
              memoOutput.Lines.Add(Format('    Landmark %d: x=%.3f, y=%.3f, z=%.3f', 
                [I, X, Y, Z]));
            end;
            
            if BuiltinModule.len(LandmarkData) > 5 then
              memoOutput.Lines.Add(Format('    ... and %d more landmarks', 
                [BuiltinModule.len(LandmarkData) - 5]));
          end;
          
          memoOutput.Lines.Add('Frame processing complete!');
        end;
      end;
    finally
      PythonEngine.Py_DECREF(PyBytes);
    end;
  except
    on E: Exception do
      memoOutput.Lines.Add('Error: ' + E.Message);
  end;
end;

procedure TfrmMain.btnProcessFrameClick(Sender: TObject);
begin
  ProcessFrameWithMediaPipe;
end;

procedure TfrmMain.PythonInputOutputSendUniData(Sender: TObject;
  const Data: string);
begin
  // Display Python output
  if Data <> '' then
    Memo1.Lines.Add(Data);
end;

end.
