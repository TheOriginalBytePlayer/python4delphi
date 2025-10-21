(**************************************************************************)
(*  This unit is part of the Python for Delphi (P4D) library              *)
(*  Project home: https://github.com/pyscripter/python4delphi             *)
(*                                                                        *)
(*  Project Maintainer:  PyScripter (pyscripter@gmail.com)                *)
(*  Original Authors:    Dr. Dietmar Budelsky (dbudelsky@web.de)          *)
(*                       Morgan Martinet (https://github.com/mmm-experts) *)
(*  Core developer:      Lucas Belo (lucas.belo@live.com)                 *)
(*  Contributors:        See contributors.md at project home              *)
(*                                                                        *)
(*  LICENCE and Copyright: MIT (see project home)                         *)
(**************************************************************************)

{$I ..\Definition.Inc}

unit WrapOpenCVCamera;


interface

uses
  System.TypInfo, System.Classes, System.SysUtils, FMX.Media, FMX.Graphics,
  PythonEngine, WrapDelphi, WrapDelphiClasses,
  WrapFmxTypes, WrapFmxControls, WrapFmxActnList, WrapFmxStdActns;

type
  TSampleBufferReadyEventHandler = class(TEventHandler)
  protected
    procedure DoEvent(Sender: TObject; const ATime: TMediaTime);
  public
    constructor Create(PyDelphiWrapper: TPyDelphiWrapper; Component: TObject;
      PropertyInfo: PPropInfo; Callable: PPyObject); override;
    class function GetTypeInfo: PTypeInfo; override;
  end;

  // OpenCV-backed camera component (non-visual TComponent)
  TOpenCVCamera = class(TComponent)
  private
    FPyCapture: PPyObject;
    FPyCv2Module: PPyObject;
    FActive: Boolean;
    FDeviceIndex: Integer;
    procedure SetActive(const Value: Boolean);
    procedure SetDeviceIndex(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CaptureFrame: PPyObject;
    function GetFrameAsBitmap: TBitmap;
  published
    property Active: Boolean read FActive write SetActive;
    property DeviceIndex: Integer read FDeviceIndex write SetDeviceIndex default 0;
  end;

  TPyDelphiOpenCVCamera = class(TPyDelphiComponent)
  private
    function GetDelphiObject: TOpenCVCamera;
    procedure SetDelphiObject(const Value: TOpenCVCamera);
    // Get/Set exposed to Python
    function Get_Active(AContext: Pointer): PPyObject; cdecl;
    function Set_Active(AValue: PPyObject; AContext: Pointer): Integer; cdecl;
    function Get_DeviceIndex(AContext: Pointer): PPyObject; cdecl;
    function Set_DeviceIndex(AValue: PPyObject; AContext: Pointer): Integer; cdecl;
    // Methods exposed to Python
    function CaptureFrame_Wrapper(args: PPyObject): PPyObject; cdecl;
    function GetFrameAsBitmap_Wrapper(args: PPyObject): PPyObject; cdecl;
  public
    class function DelphiObjectClass: TClass; override;
    class procedure RegisterGetSets(PythonType: TPythonType); override;
    class procedure RegisterMethods(PythonType: TPythonType); override;
  public
    property DelphiObject: TOpenCVCamera read GetDelphiObject write SetDelphiObject;
  end;

  //Media player wrappers (unchanged)
  TPyDelphiCustomMediaCodec = class(TPyDelphiObject)
  private
    function GetDelphiObject: TCustomMediaCodec;
    procedure SetDelphiObject(const Value: TCustomMediaCodec);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TCustomMediaCodec read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMedia = class(TPyDelphiObject)
  private
    function GetDelphiObject: TMedia;
    procedure SetDelphiObject(const Value: TMedia);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMedia read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerControl = class(TPyDelphiControl)
  private
    function GetDelphiObject: TMediaPlayerControl;
    procedure SetDelphiObject(const Value: TMediaPlayerControl);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerControl read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayer = class(TPyDelphiFmxObject)
  private
    function GetDelphiObject: TMediaPlayer;
    procedure SetDelphiObject(const Value: TMediaPlayer);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayer read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiCustomMediaPlayerAction = class(TPyDelphiCustomAction)
  private
    function GetDelphiObject: TCustomMediaPlayerAction;
    procedure SetDelphiObject(const Value: TCustomMediaPlayerAction);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TCustomMediaPlayerAction read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerStart = class(TPyDelphiCustomMediaPlayerAction)
  private
    function GetDelphiObject: TMediaPlayerStart;
    procedure SetDelphiObject(const Value: TMediaPlayerStart);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerStart read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerStop = class(TPyDelphiCustomMediaPlayerAction)
  private
    function GetDelphiObject: TMediaPlayerStop;
    procedure SetDelphiObject(const Value: TMediaPlayerStop);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerStop read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerPause = class(TPyDelphiCustomMediaPlayerAction)
  private
    function GetDelphiObject: TMediaPlayerPlayPause;
    procedure SetDelphiObject(const Value: TMediaPlayerPlayPause);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerPlayPause read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerValue = class(TPyDelphiCustomValueRangeAction)
  private
    function GetDelphiObject: TMediaPlayerValue;
    procedure SetDelphiObject(const Value: TMediaPlayerValue);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerValue read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerCurrentTime = class(TPyDelphiMediaPlayerValue)
  private
    function GetDelphiObject: TMediaPlayerCurrentTime;
    procedure SetDelphiObject(const Value: TMediaPlayerCurrentTime);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerCurrentTime read GetDelphiObject
      write SetDelphiObject;
  end;

  TPyDelphiMediaPlayerVolume = class(TPyDelphiMediaPlayerValue)
  private
    function GetDelphiObject: TMediaPlayerVolume;
    procedure SetDelphiObject(const Value: TMediaPlayerVolume);
  public
    class function DelphiObjectClass: TClass; override;
  public
    property DelphiObject: TMediaPlayerVolume read GetDelphiObject
      write SetDelphiObject;
  end;

implementation

uses
  Math, StrUtils, RTLConsts, MethodCallback; // existing helpers

type
  TFMXMediaRegistration = class(TRegisteredUnit)
  public
    function Name: string; override;
    procedure RegisterWrappers(APyDelphiWrapper: TPyDelphiWrapper); override;
    procedure DefineVars(APyDelphiWrapper: TPyDelphiWrapper); override;
  end;

{ TOpenCVCamera }

constructor TOpenCVCamera.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPyCapture := nil;
  FPyCv2Module := nil;
  FActive := False;
  FDeviceIndex := 0;
end;

destructor TOpenCVCamera.Destroy;
begin
  Active := False;
  inherited;
end;

procedure TOpenCVCamera.SetActive(const Value: Boolean);
var
  PyCaptureMethod, PyArgs, PyReleaseMethod, PyResult: PPyObject;
begin
  if FActive = Value then Exit;

  if Value then
  begin
    // Import cv2 and create VideoCapture
    with GetPythonEngine do
    begin
      FPyCv2Module := PyImport_ImportModule('cv2');
      if not Assigned(FPyCv2Module) then
      begin
        PyErr_Print;
        raise Exception.Create('Failed to import cv2 module. Make sure OpenCV is installed in Python.');
      end;

      PyCaptureMethod := PyObject_GetAttrString(FPyCv2Module, 'VideoCapture');
      if Assigned(PyCaptureMethod) then
      try
        PyArgs := PyTuple_New(1);
        PyTuple_SetItem(PyArgs, 0, PyLong_FromLong(FDeviceIndex));
        FPyCapture := PyObject_CallObject(PyCaptureMethod, PyArgs);
        Py_DECREF(PyArgs);

        if not Assigned(FPyCapture) then
        begin
          PyErr_Print;
          raise Exception.Create('Failed to create VideoCapture object.');
        end;
      finally
        Py_DECREF(PyCaptureMethod);
      end;
    end;
    FActive := True;
  end
  else
  begin
    // Release capture
    if Assigned(FPyCapture) then
    begin
      with GetPythonEngine do
      begin
        PyReleaseMethod := PyObject_GetAttrString(FPyCapture, 'release');
        if Assigned(PyReleaseMethod) then
        try
          PyResult := PyObject_CallObject(PyReleaseMethod, nil);
          Py_XDECREF(PyResult);
        finally
          Py_DECREF(PyReleaseMethod);
        end;
        Py_DECREF(FPyCapture);
      end;
      FPyCapture := nil;
    end;

    if Assigned(FPyCv2Module) then
    begin
      GetPythonEngine.Py_DECREF(FPyCv2Module);
      FPyCv2Module := nil;
    end;
    FActive := False;
  end;
end;

procedure TOpenCVCamera.SetDeviceIndex(const Value: Integer);
begin
  if FActive then
    raise Exception.Create('Cannot change device index while camera is active');
  FDeviceIndex := Value;
end;

function TOpenCVCamera.CaptureFrame: PPyObject;
var
  PyReadMethod, PyResult: PPyObject;
begin
  Result := nil;
  if not FActive then Exit;

  with GetPythonEngine do
  begin
    PyReadMethod := PyObject_GetAttrString(FPyCapture, 'read');
    if Assigned(PyReadMethod) then
    try
      PyResult := PyObject_CallObject(PyReadMethod, nil);
      if Assigned(PyResult) then
      begin
        // tuple (ret, frame) -> return frame
        if PyTuple_Check(PyResult) and (PyTuple_Size(PyResult) >= 2) then
        begin
          Result := PyTuple_GetItem(PyResult, 1);
          Py_INCREF(Result);
        end;
        Py_DECREF(PyResult);
      end
      else
        PyErr_Print;
    finally
      Py_DECREF(PyReadMethod);
    end;
  end;
end;

function TOpenCVCamera.GetFrameAsBitmap: TBitmap;
var
  PyFrame, PyCvtColorMethod, PyArgs, PyRGBFrame, PyShape, PyTobytesMethod,
  PyBytesData, PyColorConst: PPyObject;
  Height, Width: Integer;
  DataPtr: PByte;
  DataSize: NativeInt;
  BitmapData: TBitmapData;
  y: Integer;
begin
  Result := nil;
  PyFrame := CaptureFrame;
  if not Assigned(PyFrame) then Exit;

  try
    with GetPythonEngine do
    begin
      // Convert BGR->RGB
      PyCvtColorMethod := PyObject_GetAttrString(FPyCv2Module, 'cvtColor');
      if Assigned(PyCvtColorMethod) then
      try
        PyArgs := PyTuple_New(2);
        Py_INCREF(PyFrame);
        PyTuple_SetItem(PyArgs, 0, PyFrame);

        PyColorConst := PyObject_GetAttrString(FPyCv2Module, 'COLOR_BGR2RGB');
        PyTuple_SetItem(PyArgs, 1, PyColorConst);

        PyRGBFrame := PyObject_CallObject(PyCvtColorMethod, PyArgs);
        Py_DECREF(PyArgs);

        if Assigned(PyRGBFrame) then
        try
          PyShape := PyObject_GetAttrString(PyRGBFrame, 'shape');
          if Assigned(PyShape) and PyTuple_Check(PyShape) and (PyTuple_Size(PyShape) >= 2) then
          begin
            Height := PyLong_AsLong(PyTuple_GetItem(PyShape, 0));
            Width := PyLong_AsLong(PyTuple_GetItem(PyShape, 1));
            Py_DECREF(PyShape);

            Result := TBitmap.Create(Width, Height);

            PyTobytesMethod := PyObject_GetAttrString(PyRGBFrame, 'tobytes');
            if Assigned(PyTobytesMethod) then
            try
              PyBytesData := PyObject_CallObject(PyTobytesMethod, nil);
              if Assigned(PyBytesData) then
              try
                DataPtr := PByte(PyBytes_AsString(PyBytesData));
                DataSize := PyBytes_Size(PyBytesData);

                if Assigned(DataPtr) and (DataSize >= Width * Height * 3) and
                   Result.Map(TMapAccess.Write, BitmapData) then
                try
                  for y := 0 to Height - 1 do
                    Move(DataPtr[y * Width * 3],
                         Pointer(NativeInt(BitmapData.Data) + y * BitmapData.Pitch)^,
                         Width * 3);
                finally
                  Result.Unmap(BitmapData);
                end;
              finally
                Py_DECREF(PyBytesData);
              end;
            finally
              Py_DECREF(PyTobytesMethod);
            end;
          end;
        finally
          Py_DECREF(PyRGBFrame);
        end;
      finally
        Py_DECREF(PyCvtColorMethod);
      end;
    end;
  finally
    GetPythonEngine.Py_DECREF(PyFrame);
  end;
end;

{ TPyDelphiOpenCVCamera }

class function TPyDelphiOpenCVCamera.DelphiObjectClass: TClass;
begin
  Result := TOpenCVCamera;
end;

class procedure TPyDelphiOpenCVCamera.RegisterGetSets(PythonType: TPythonType);
begin
  inherited;
  with PythonType do
  begin
    AddGetSet('Active', @TPyDelphiOpenCVCamera.Get_Active, @TPyDelphiOpenCVCamera.Set_Active,
      'Returns/Sets whether the camera is active', nil);
    AddGetSet('DeviceIndex', @TPyDelphiOpenCVCamera.Get_DeviceIndex, @TPyDelphiOpenCVCamera.Set_DeviceIndex,
      'Returns/Sets the camera device index', nil);
  end;
end;

class procedure TPyDelphiOpenCVCamera.RegisterMethods(PythonType: TPythonType);
begin
  inherited;
  with PythonType do
  begin
    AddMethod('CaptureFrame', @TPyDelphiOpenCVCamera.CaptureFrame_Wrapper,
      'Captures a frame from the camera and returns it as a numpy array');
    AddMethod('GetFrameAsBitmap', @TPyDelphiOpenCVCamera.GetFrameAsBitmap_Wrapper,
      'Captures a frame and returns it as a Delphi TBitmap object');
  end;
end;

function TPyDelphiOpenCVCamera.GetDelphiObject: TOpenCVCamera;
begin
  Result := TOpenCVCamera(inherited DelphiObject);
end;

procedure TPyDelphiOpenCVCamera.SetDelphiObject(const Value: TOpenCVCamera);
begin
  inherited DelphiObject := Value;
end;

// Getter/Setter wrappers

function TPyDelphiOpenCVCamera.Get_Active(AContext: Pointer): PPyObject; cdecl;
begin
  Adjust(@Self);
  if not CheckBound then
    Exit(nil);
  Result := GetPythonEngine.VariantAsPyObject(DelphiObject.Active);
end;

function TPyDelphiOpenCVCamera.Set_Active(AValue: PPyObject; AContext: Pointer): Integer; cdecl;
var
  b: Boolean;
begin
  Adjust(@Self);
  if not CheckBoolAttribute(AValue, 'Active', b) then
    Exit(-1);
  try
    DelphiObject.Active := b;
    Result := 0;
  except
    on E: Exception do
    begin
      with GetPythonEngine do
        PyErr_SetString(PyExc_AttributeError^, PAnsiChar(EncodeString(E.Message)));
      Result := -1;
    end;
  end;
end;

function TPyDelphiOpenCVCamera.Get_DeviceIndex(AContext: Pointer): PPyObject; cdecl;
begin
  Adjust(@Self);
  if not CheckBound then
    Exit(nil);
  Result := GetPythonEngine.PyLong_FromLong(DelphiObject.DeviceIndex);
end;

function TPyDelphiOpenCVCamera.Set_DeviceIndex(AValue: PPyObject; AContext: Pointer): Integer; cdecl;
var
  idx: Integer;
begin
  Adjust(@Self);
  if not CheckIntAttribute(AValue, 'DeviceIndex', idx) then
    Exit(-1);
  try
    DelphiObject.DeviceIndex := idx;
    Result := 0;
  except
    on E: Exception do
    begin
      with GetPythonEngine do
        PyErr_SetString(PyExc_AttributeError^, PAnsiChar(EncodeString(E.Message)));
      Result := -1;
    end;
  end;
end;

// Method wrappers

function TPyDelphiOpenCVCamera.CaptureFrame_Wrapper(args: PPyObject): PPyObject; cdecl;
begin
  Adjust(@Self);
  if not CheckBound then
    Exit(nil);
  // TOpenCVCamera.CaptureFrame returns a PPyObject (numpy frame) already
  Result := DelphiObject.CaptureFrame;
end;

function TPyDelphiOpenCVCamera.GetFrameAsBitmap_Wrapper(args: PPyObject): PPyObject; cdecl;
var
  Bmp: TBitmap;
begin
  Adjust(@Self);
  if not CheckBound then
    Exit(nil);
  Bmp := DelphiObject.GetFrameAsBitmap;
  if not Assigned(Bmp) then
    Result := GetPythonEngine.ReturnNone
  else
    Result := PyDelphiWrapper.Wrap(Bmp, soOwned);
end;

{ TSampleBufferReadyEventHandler }

constructor TSampleBufferReadyEventHandler.Create(PyDelphiWrapper
  : TPyDelphiWrapper; Component: TObject; PropertyInfo: PPropInfo;
  Callable: PPyObject);
var
  Method : TMethod;
begin
  inherited;
  Method.Code := @TSampleBufferReadyEventHandler.DoEvent;
  Method.Data := Self;
  SetMethodProp(Component, PropertyInfo, Method);
end;

procedure TSampleBufferReadyEventHandler.DoEvent(Sender: TObject;
  const ATime: TMediaTime);
var
  PySender, PyTuple, PyResult, PyTime : PPyObject;
begin
  Assert(Assigned(PyDelphiWrapper));
  if Assigned(Callable) and PythonOK then
    with GetPythonEngine do begin
      PySender := PyDelphiWrapper.Wrap(Sender);
      PyTime := PyLong_FromLong(ATime);
      PyTuple := PyTuple_New(2);
      GetPythonEngine.PyTuple_SetItem(PyTuple, 0, PySender);
      GetPythonEngine.PyTuple_SetItem(PyTuple, 1, PyTime);
      try
        PyResult := PyObject_CallObject(Callable, PyTuple);
        Py_XDECREF(PyResult);
      finally
        Py_DECREF(PyTuple);
      end;
      CheckError;
    end;
end;

class function TSampleBufferReadyEventHandler.GetTypeInfo: PTypeInfo;
begin
  Result := System.TypeInfo(TSampleBufferReadyEvent);
end;

{ Existing wrappers' implementations left unchanged (GetDelphiObject/SetDelphiObject methods) }

class function TPyDelphiCustomMediaCodec.DelphiObjectClass: TClass;
begin
  Result := TCustomMediaCodec;
end;

function TPyDelphiCustomMediaCodec.GetDelphiObject: TCustomMediaCodec;
begin
  Result := TCustomMediaCodec(inherited DelphiObject);
end;

procedure TPyDelphiCustomMediaCodec.SetDelphiObject(
  const Value: TCustomMediaCodec);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMedia.DelphiObjectClass: TClass;
begin
  Result := TMedia;
end;

function TPyDelphiMedia.GetDelphiObject: TMedia;
begin
  Result := TMedia(inherited DelphiObject);
end;

procedure TPyDelphiMedia.SetDelphiObject(const Value: TMedia);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerControl.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerControl;
end;

function TPyDelphiMediaPlayerControl.GetDelphiObject: TMediaPlayerControl;
begin
  Result := TMediaPlayerControl(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerControl.SetDelphiObject(
  const Value: TMediaPlayerControl);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayer.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayer;
end;

function TPyDelphiMediaPlayer.GetDelphiObject: TMediaPlayer;
begin
  Result := TMediaPlayer(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayer.SetDelphiObject(const Value: TMediaPlayer);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiCustomMediaPlayerAction.DelphiObjectClass: TClass;
begin
  Result := TCustomMediaPlayerAction;
end;

function TPyDelphiCustomMediaPlayerAction.GetDelphiObject: TCustomMediaPlayerAction;
begin
  Result := TCustomMediaPlayerAction(inherited DelphiObject);
end;

procedure TPyDelphiCustomMediaPlayerAction.SetDelphiObject(
  const Value: TCustomMediaPlayerAction);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerStart.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerStart;
end;

function TPyDelphiMediaPlayerStart.GetDelphiObject: TMediaPlayerStart;
begin
  Result := TMediaPlayerStart(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerStart.SetDelphiObject(
  const Value: TMediaPlayerStart);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerStop.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerStop;
end;

function TPyDelphiMediaPlayerStop.GetDelphiObject: TMediaPlayerStop;
begin
  Result := TMediaPlayerStop(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerStop.SetDelphiObject(
  const Value: TMediaPlayerStop);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerPause.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerPlayPause;
end;

function TPyDelphiMediaPlayerPause.GetDelphiObject: TMediaPlayerPlayPause;
begin
  Result := TMediaPlayerPlayPause(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerPause.SetDelphiObject(
  const Value: TMediaPlayerPlayPause);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerValue.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerValue;
end;

function TPyDelphiMediaPlayerValue.GetDelphiObject: TMediaPlayerValue;
begin
  Result := TMediaPlayerValue(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerValue.SetDelphiObject(
  const Value: TMediaPlayerValue);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerCurrentTime.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerCurrentTime;
end;

function TPyDelphiMediaPlayerCurrentTime.GetDelphiObject: TMediaPlayerCurrentTime;
begin
  Result := TMediaPlayerCurrentTime(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerCurrentTime.SetDelphiObject(
  const Value: TMediaPlayerCurrentTime);
begin
  inherited DelphiObject := Value;
end;

class function TPyDelphiMediaPlayerVolume.DelphiObjectClass: TClass;
begin
  Result := TMediaPlayerVolume;
end;

function TPyDelphiMediaPlayerVolume.GetDelphiObject: TMediaPlayerVolume;
begin
  Result := TMediaPlayerVolume(inherited DelphiObject);
end;

procedure TPyDelphiMediaPlayerVolume.SetDelphiObject(
  const Value: TMediaPlayerVolume);
begin
  inherited DelphiObject := Value;
end;

{ TFMXMediaRegistration }

function TFMXMediaRegistration.Name: string;
begin
  Result := 'Media';
end;

procedure TFMXMediaRegistration.DefineVars(APyDelphiWrapper: TPyDelphiWrapper);
begin
  inherited;
end;

procedure TFMXMediaRegistration.RegisterWrappers(APyDelphiWrapper: TPyDelphiWrapper);
begin
  APyDelphiWrapper.EventHandlers.RegisterHandler(TSampleBufferReadyEventHandler);

  // Register OpenCV camera wrapper instead of the old CameraComponent wrapper
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiOpenCVCamera);

  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiCustomMediaCodec);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerControl);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayer);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMedia);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiCustomMediaPlayerAction);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerStart);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerStop);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerPause);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerValue);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerCurrentTime);
  APyDelphiWrapper.RegisterDelphiWrapper(TPyDelphiMediaPlayerVolume);
end;

initialization

RegisteredUnits.Add(TFMXMediaRegistration.Create());

end.
