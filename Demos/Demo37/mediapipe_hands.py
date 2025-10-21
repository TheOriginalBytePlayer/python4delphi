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
  System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ListBox, FMX.Objects,
  PythonEngine, VarPyth, FMX.Media;

type
  TfrmMain = class(TForm)
    PythonEngine: TPythonEngine;
    PythonInputOutput: TPythonInputOutput;
    Panel1: TPanel;
    Memo1: TMemo;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    memoOutput: TMemo;
    Label2: TLabel;
    ImageControl1: TImageControl;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    CameraComponent1: TCameraComponent;
    LoadTimer: TTimer;
    procedure btnLoadScriptClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure CameraComponent1SampleBufferReady(Sender: TObject; const ATime:
        TMediaTime);
    procedure FormShow(Sender: TObject);
    procedure PythonInputOutputSendUniData(Sender: TObject; const Data: string);
  private
    { Private declarations }
    FScriptLoaded: Boolean;
    InterimBitmap:TBitmap;
    procedure LoadPythonScript;
    function BitmapToRGBBytes(ABitmap: TBitmap): TBytes;
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
end;

{ --- Ensure proper cleanup on form destroy --- }
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if FScriptLoaded then
  begin
    try
      // Ask the Python module to release MediaPipe resources
      // This calls mediapipe_hands.close_hands()
      try
        MainModule.mediapipe_hands.close_hands();
        memoOutput.Lines.Add('mediapipe_hands.close_hands() called.');
      except
        on E: Exception do
          memoOutput.Lines.Add('Warning: close_hands() raised: ' + E.Message);
      end;
    finally
      // Optionally set flag to false
      FScriptLoaded := False;
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

    // Initialize MediaPipe (module-level init_hands)
    // Use the variant interface to call init_hands() so we can control lifecycle
    try
      // You can pass params if you want: init_hands(static_image_mode=True, max_num_hands=2, ...)
      MainModule.mediapipe_hands.init_hands(False, 2, 0.5, 0.5);
      memoOutput.Lines.Add('mediapipe_hands.init_hands() called.');
    except
      on E: Exception do
        memoOutput.Lines.Add('Warning: init_hands() raised: ' + E.Message);
    end;

    FScriptLoaded := True;
    memoOutput.Lines.Add('MediaPipe script loaded and initialized.');
    memoOutput.Lines.Add('MediaPipe Hands initialized.');
    memoOutput.Lines.Add('Ready to process frames.');
    //InterimBitmap
    var CaptureSetting:=CameraComponent1.CaptureSetting;
    CaptureSetting.Width:=640;
    CaptureSetting.Height:=480;
    CameraComponent1.SetCaptureSetting(CaptureSetting);
    ImageControl1.Bitmap.SetSize(CameraComponent1.CaptureSetting.Width,CameraComponent1.CaptureSetting.Height);
    CameraComponent1.Active:=true;

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
  LoadTimer.Enabled:=False;
  LoadPythonScript;
end;

function TfrmMain.BitmapToRGBBytes(ABitmap: TBitmap): TBytes;
var
  BitmapData: TBitmapData;
  Width, Height: Integer;
  x, y: Integer;
  OutIdx: NativeInt;
  SrcScanline: Pointer;
  SrcPitch: Integer;
  PixelPtr: Pointer;
  Color: TAlphaColor;
begin
  SetLength(Result, 0);
  if (ABitmap = nil) or ABitmap.IsEmpty then
    Exit;

  Width := ABitmap.Width;
  Height := ABitmap.Height;
  if (Width <= 0) or (Height <= 0) then
    Exit;

  if not ABitmap.Map(TMapAccess.Read, BitmapData) then
    raise Exception.Create('Unable to map bitmap for reading.');

  try
    SetLength(Result, Width * Height * 3);
    OutIdx := 0;

    // PixelFormatBytes[] comes from FMX.Types; it tells bytes-per-pixel for that format.
    SrcPitch := PixelFormatBytes[BitmapData.PixelFormat];
    if SrcPitch <= 0 then
      raise Exception.Create('Unsupported source pixel format.');

    for y := 0 to Height - 1 do
    begin
      SrcScanline := BitmapData.GetScanline(y);
      // iterate columns and convert each pixel to TAlphaColor (works for all FMX formats)
      for x := 0 to Width - 1 do
      begin
        PixelPtr := Pointer(NativeInt(SrcScanline) + NativeInt(x * SrcPitch));
        Color := PixelToAlphaColor(PixelPtr, BitmapData.PixelFormat);
        // Extract RGB (TAlphaColorRec maps bytes in R,G,B,A fields)
        Result[OutIdx] := TAlphaColorRec(Color).R; Inc(OutIdx);
        Result[OutIdx] := TAlphaColorRec(Color).G; Inc(OutIdx);
        Result[OutIdx] := TAlphaColorRec(Color).B; Inc(OutIdx);
      end;
    end;
  finally
    ABitmap.Unmap(BitmapData);
  end;
end;

Type
  TPointsArray = array of TPointF;

procedure TfrmMain.ProcessFrameWithMediaPipe;
var
  FrameBytes: TBytes;
  PyBytes: PPyObject;
  PyResult: Variant;
  HandIdx: Integer;
  LandmarkData: Variant;
  X, Y, Z: Double;
  ExpectedLen: NativeInt;
  LenHands, LenLandmarks: Integer;
  PixelVar: Variant;
  PixelStr: string;
  Parts: TArray<string>;
  px, py: Integer;
  MemoLinesToAdd:TStringList;
  Pts:Array of TPointsArray;

procedure SmartDrawLine(FromPt,ToPt:TPointF);
begin
   if (FromPt.X < 0) or (FromPt.Y < 0) or (ToPt.X < 0) or (ToPt.Y < 0) then
     exit;
   InterimBitmap.Canvas.DrawLine(FromPt,ToPt,1);

end;

begin
  MemoLinesToAdd:=TStringList.create;
  try
     if not FScriptLoaded then
     begin
       MemoLinesToAdd.Add('Please load the Python script first!');
       Exit;
     end;

     if InterimBitmap.IsEmpty then
     begin
       MemoLinesToAdd.Add('Please load an image first!');
       Exit;
     end;

     try
       MemoLinesToAdd.Add('Processing frame...');

       // Produce packed RGB bytes (3 bytes per pixel)
       FrameBytes := BitmapToRGBBytes(InterimBitmap);

       ExpectedLen := NativeInt(InterimBitmap.Width) * NativeInt(InterimBitmap.Height) * 3;
       if Length(FrameBytes) <> ExpectedLen then
       begin
         MemoLinesToAdd.Add(Format('Error: produced bytes length mismatch. Expected %d, got %d',
           [ExpectedLen, Length(FrameBytes)]));
         Exit;
       end;

       // Create Python bytes object from the contiguous TBytes buffer
       if Length(FrameBytes) = 0 then
       begin
         MemoLinesToAdd.Add('Error: empty frame buffer.');
         Exit;
       end;

       PyBytes := PythonEngine.PyBytes_FromStringAndSize(@FrameBytes[0], Length(FrameBytes));
       if PyBytes = nil then
         raise Exception.Create('Failed to create Python bytes object.');

       try
         // Call the Python function (mediapipe_hands.process_frame expects packed RGB bytes)
         PyResult := MainModule.mediapipe_hands.process_frame(VarPythonCreate(PyBytes),
           InterimBitmap.Width,
           InterimBitmap.Height);

         // Process the results (PyResult is a Python list: list of hands; each hand = list of landmark dicts)
         if VarIsPython(PyResult) then
         begin
           // Convert Python length variants to Delphi integers before formatting
           LenHands := StrToIntDef(VarToStr(BuiltinModule.len(PyResult)), 0);

           if LenHands = 0 then
           begin
             MemoLinesToAdd.Add('No hands detected.');
           end
           else
           begin
             SetLength(Pts,LenHands);
             MemoLinesToAdd.Add(Format('Detected %d hand(s):', [LenHands]));
             for HandIdx := 0 to LenHands - 1 do
             begin
               MemoLinesToAdd.Add(Format('  Hand %d:', [HandIdx + 1]));
               LandmarkData := PyResult.GetItem(HandIdx);

               LenLandmarks := StrToIntDef(VarToStr(BuiltinModule.len(LandmarkData)), 0);
               SetLength(Pts[HandIdx],LenLandMarks);
               // Display a few sample landmarks
               for var LndMarkIdx := 0 to LenLandmarks - 1 do
               begin
                 // LandmarkData[LndMarkIdx] is a dict {'x':..., 'y':..., 'z':..., 'pixel': (px,py) or None}
                 X := LandmarkData.GetItem(LndMarkIdx).GetItem('x');
                 Y := LandmarkData.GetItem(LndMarkIdx).GetItem('y');
                 Z := LandmarkData.GetItem(LndMarkIdx).GetItem('z');
                 px := LandmarkData.GetItem(LndMarkIdx).GetItem('px');
                 py := LandmarkData.GetItem(LndMarkIdx).GetItem('py');
                 Pts[HandIdx][LndMarkIdx]:=PointF(px,py);
               end;
             end;

             MemoLinesToAdd.Add('Frame processing complete!');
             interimBitmap.Canvas.BeginScene;
             interimBitmap.Canvas.Fill.Color:=TAlphaColorRec.Red;
             interimBitmap.Canvas.Fill.Kind:=TBrushKind.None;
             interimBitmap.Canvas.Stroke.Kind:=TBrushKind.Solid;
             interimBitmap.Canvas.Stroke.Thickness:=5;
             for HandIdx := 0 to LenHands - 1 do
              begin
                Case HandIdx of
                 0:interimBitmap.Canvas.Stroke.Color:=TAlphaColorRec.Green;
                 1:interimBitmap.Canvas.Stroke.Color:=TAlphaColorRec.Yellow;
                end;
                var LocalPts:=Pts[HandIdx];
                for var PointIdx:=0 to High(LocalPts) do
                  Case PointIdx of
                    1..4,6..8,10..12,14..16,18..20:
                       SmartDrawLine(LocalPts[PointIdx-1],LocalPts[PointIdx]);
                    5:SmartDrawLine(LocalPts[5],LocalPts[0]);
                    9:SmartDrawLine(LocalPts[9],LocalPts[5]);
                    13:SmartDrawLine(LocalPts[13],LocalPts[9]);
                    17:begin
                        SmartDrawLine(LocalPts[17],LocalPts[0]);
                        SmartDrawLine(LocalPts[17],LocalPts[13]);
                       end;
                   End;
              end;
             interimBitmap.Canvas.Fill.Kind:=TBrushKind.Solid;

             for HandIdx := 0 to LenHands - 1 do
              begin
                Case HandIdx of
                 0:interimBitmap.Canvas.Fill.Color:=TAlphaColorRec.Red;
                 1:interimBitmap.Canvas.Fill.Color:=TAlphaColorRec.Blue;
                end;
                var LocalPts:=Pts[HandIdx];
                for var PointIdx:=0 to High(LocalPts) do
                   if (LocalPts[PointIdx].x >= 0) and (LocalPts[PointIdx].y >= 0) then
                        begin
                          var Rect:=RectF(LocalPts[PointIdx].x-4,LocalPts[PointIdx].y-4,LocalPts[PointIdx].x+4,LocalPts[PointIdx].y+4);
                          interimBitmap.Canvas.FillEllipse(Rect,1);
                        end;
              end;
              InterimBitmap.Canvas.EndScene;
           end;
         end
         else
         begin
           MemoLinesToAdd.Add('Unexpected result from process_frame (not a Python object).');
         end;

       finally
         // release the Python bytes object
         PythonEngine.Py_DECREF(PyBytes);
       end;
     except
       on E: Exception do
         MemoLinesToAdd.Add('Error: ' + E.Message);
     end;
     finally
          if MemoLinesToAdd.Count > 0 then
           begin
                  memoOutput.Lines.BeginUpdate;
                  for var MemoLinesIndex:=0 to MemoLinesToAdd.Count-1 do
                    MemoOutput.Lines.Add(MemoLinesToAdd[MemoLinesIndex]);
                  MemoOutput.Lines.EndUpdate;
           end;
        MemoLinesToAdd.Free;
     end;
end;

procedure TfrmMain.CameraComponent1SampleBufferReady(Sender: TObject; const
    ATime: TMediaTime);
begin
    CameraComponent1.SampleBufferToBitmap(InterimBitmap,true);
    TThread.Synchronize(Nil,procedure()
     begin
        ProcessFrameWithMediaPipe;
     end
     );
     ImageControl1.Bitmap.Assign(InterimBitmap);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  FScriptLoaded := False;
  Memo1.Lines.Add('# MediaPipe Hand Tracking Demo');
  Memo1.Lines.Add('# Click "Load Python Script" to initialize MediaPipe');
  Memo1.Lines.Add('# Then click "Load Image" to load a test image');
  Memo1.Lines.Add('# Finally click "Process Frame" to detect hands');
  InterimBitmap:=TBitmap.Create(640,480);
  LoadTimer.Enabled:=true;
end;

procedure TfrmMain.PythonInputOutputSendUniData(Sender: TObject;
  const Data: string);
begin
  // Display Python output
  if Data <> '' then
    Memo1.Lines.Add(Data);
end;

end.
