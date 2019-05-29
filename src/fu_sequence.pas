unit fu_sequence;

{
Copyright (C) 2015 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. 

}

{$mode objfpc}{$H+}

interface

uses
  pu_edittargets, u_ccdconfig, u_global, u_utils, UScaleDPI, indiapi,
  fu_capture, fu_preview, fu_filterwheel, u_translation,
  cu_mount, cu_camera, cu_autoguider, cu_astrometry, cu_rotator,
  cu_targets, cu_plan, cu_planetarium, pu_pause, fu_safety, fu_weather, cu_dome,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Grids;

type

  { Tf_sequence }

  Tf_sequence = class(TFrame)
    BtnReset: TButton;
    BtnEditTargets: TButton;
    BtnStart: TButton;
    BtnStop: TButton;
    BtnNewTargets: TButton;
    BtnLoadTargets: TButton;
    BtnCopy: TButton;
    BtnDelete: TButton;
    led: TShape;
    StatusTimer: TTimer;
    StartTimer: TTimer;
    Unattended: TCheckBox;
    DelayMsg: TLabel;
    StatusMsg: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SaveDialog1: TSaveDialog;
    Title1: TPanel;
    Title2: TPanel;
    Title3: TPanel;
    TargetGrid: TStringGrid;
    PlanGrid: TStringGrid;
    procedure BtnCopyClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditTargetsClick(Sender: TObject);
    procedure BtnResetClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnLoadTargetsClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure PlanGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StartTimerTimer(Sender: TObject);
    procedure StatusTimerTimer(Sender: TObject);
    procedure TargetGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure TargetGridSelection(Sender: TObject; aCol, aRow: Integer);
    procedure TargetsChange(Sender: TObject);
    procedure PlanChange(Sender: TObject);
    procedure UnattendedChange(Sender: TObject);
  private
    { private declarations }
    TargetRow, PlanRow: integer;
    StartingSequence: Boolean;
    Targets: T_Targets;
    FonMsg: TNotifyMsg;
    FConnectAutoguider: TNotifyEvent;
    Fcapture: Tf_capture;
    Fpreview: Tf_preview;
    Ffilter: Tf_filterwheel;
    Fweather: Tf_weather;
    Fsafety: Tf_safety;
    Fdome: T_dome;
    Fmount: T_mount;
    Fcamera: T_camera;
    Frotator: T_rotator;
    Fautoguider: T_autoguider;
    Fastrometry: TAstrometry;
    Fplanetarium: TPlanetarium;
    AutoguiderAlert,AutoguiderStarting: boolean;
    AutoguiderAlertTime,AutoguiderMsgTime: double;
    MountTrackingAlert: boolean;
    MountTrackingAlertTime: double;
    procedure SetPreview(val: Tf_preview);
    procedure SetCapture(val: Tf_capture);
    procedure SetMount(val: T_mount);
    procedure SetCamera(val: T_camera);
    procedure SetRotator(val: T_rotator);
    procedure SetFilter(val: Tf_filterwheel);
    procedure SetWeather(val: Tf_weather);
    procedure SetSafety(val: Tf_safety);
    procedure SetDome(val: T_dome);
    procedure SetAutoguider(val: T_autoguider);
    procedure SetAstrometry(val: TAstrometry);
    procedure SetPlanetarium(val: TPlanetarium);
    function GetRunning: boolean;
    function GetBusy: boolean;
    function GetTargetCoord: boolean;
    function GetTargetRA: double;
    function GetTargetDE: double;
    function GetCurrentPlan: T_Plan;
    procedure SaveTargets(fn,defaultname:string);
    procedure StartSequence;
    procedure ClearTargetGrid;
    procedure ClearPlanGrid;
    procedure LoadPlan(p: T_Plan; plan:string; donelist:TStepDone);
    procedure msg(txt:string; level: integer);
    procedure ShowDelayMsg(txt:string);
    procedure StopSequence;
    procedure EndSequence(Sender: TObject);
    procedure SetEditBtn(onoff:boolean);
    procedure SetLang;
    function GetEndShutdown: boolean;
    procedure SetEndShutdown(value:boolean);
    function GetOnShutdown: TNotifyEvent;
    procedure SetOnShutdown(value:TNotifyEvent);
    function GetPercentComplete: double;
    function GetTargetPercentComplete: double;
    procedure ClearRestartHistory(Confirm:boolean);
  public
    { public declarations }
    StepRepeatCount, StepTotalCount: integer;
    constructor Create(aOwner: TComponent); override;
    destructor  Destroy; override;
    procedure AutoguiderDisconnected;
    procedure AutoguiderIddle;
    procedure MountTrackingStarted;
    procedure MountTrackingStopped;
    procedure ExposureAborted;
    procedure CameraDisconnected;
    procedure LoadTargets(fn: string);
    procedure AbortSequence;
    procedure WeatherChange(value:boolean);
    property Busy: boolean read GetBusy;
    property Running: boolean read GetRunning;
    property PercentComplete: double read GetPercentComplete;
    property TargetPercentComplete: double read GetTargetPercentComplete;
    property TargetCoord: boolean read GetTargetCoord;
    property TargetRA: double read GetTargetRA;
    property TargetDE: double read GetTargetDE;
    property CurrentPlan: T_Plan read GetCurrentPlan;
    property Preview: Tf_preview read Fpreview write SetPreview;
    property Capture: Tf_capture read Fcapture write SetCapture;
    property Mount: T_mount read Fmount write SetMount;
    property Camera: T_camera read Fcamera write SetCamera;
    property Rotator: T_rotator read Frotator write SetRotator;
    property Filter: Tf_filterwheel read Ffilter write SetFilter;
    property Weather: Tf_weather read Fweather write SetWeather;
    property Safety: Tf_safety read Fsafety write SetSafety;
    property Dome: T_dome read Fdome write SetDome;
    property Autoguider: T_autoguider read Fautoguider write SetAutoguider;
    property Astrometry: TAstrometry read Fastrometry write SetAstrometry;
    property Planetarium: TPlanetarium read FPlanetarium write SetPlanetarium;
    property AtEndShutdown: boolean read GetEndShutdown write SetEndShutdown;
    property OnShutdown: TNotifyEvent read GetOnShutdown write SetOnShutdown;
    property onMsg: TNotifyMsg read FonMsg write FonMsg;
    property onConnectAutoguider: TNotifyEvent read FConnectAutoguider write FConnectAutoguider;
  end;

var
  f_sequence: Tf_sequence;

implementation

uses LazFileUtils;

{$R *.lfm}

constructor Tf_sequence.Create(aOwner: TComponent);
begin
 inherited Create(aOwner);
 {$ifdef lclcocoa}
 Title1.Color:=clWindowFrame;
 Title2.Color:=clWindowFrame;
 Title3.Color:=clWindowFrame;
 Panel1.ChildSizing.LeftRightSpacing:=8;
 Panel2.ChildSizing.LeftRightSpacing:=8;
 Panel1.ChildSizing.VerticalSpacing:=4;
 Panel2.ChildSizing.VerticalSpacing:=4;
 TargetGrid.FixedColor := clBackground;
 PlanGrid.FixedColor := clBackground;
 {$endif}
 ScaleDPI(Self);
 SetLang;
 CurrentSeqName:='';
 CurrentTargetName:='';
 CurrentStepName:='';
 StartingSequence:=false;
 Targets:=T_Targets.Create(nil);
 Targets.Preview:=Fpreview;
 Targets.Capture:=Fcapture;
 Targets.Mount:=Fmount;
 Targets.Camera:=Fcamera;
 Targets.Filter:=Ffilter;
 Targets.Autoguider:=Fautoguider;
 Targets.Astrometry:=Fastrometry;
 Targets.Planetarium:=Fplanetarium;
 Targets.onMsg:=@Msg;
 Targets.onEndSequence:=@EndSequence;
 Targets.DelayMsg:=@ShowDelayMsg;
 Targets.onTargetsChange:=@TargetsChange;
 Targets.onPlanChange:=@PlanChange;
 TargetGrid.Cells[0, 0]:=rsObject;
 TargetGrid.Cells[1, 0]:=rsPlan;
 TargetGrid.Cells[2, 0]:=rsBegin;
 TargetGrid.Cells[3, 0]:=rsEnd;
 TargetGrid.ColWidths[2]:=0;
 TargetGrid.ColWidths[3]:=0;
 TargetGrid.Cells[4, 0]:=rsRA;
 TargetGrid.Cells[5,0]:=rsDec;
 PlanGrid.Cells[0, 0]:=rsDesc;
 PlanGrid.Cells[1, 0]:=rsExp2;
 PlanGrid.Cells[2, 0]:=rsCount;
 PlanGrid.Cells[3, 0]:=rsType;
 PlanGrid.Cells[4, 0]:=rsFilter;
 f_EditTargets:=Tf_EditTargets.Create(nil);
 f_EditTargets.Astrometry:=Fastrometry;
end;

destructor  Tf_sequence.Destroy;
begin
 Targets.Free;
 f_EditTargets.Free;
 ClearTargetGrid;
 ClearPlanGrid;
 inherited Destroy;
end;

procedure Tf_sequence.SetLang;
begin
  Title1.Caption:=rsSequence;
  Title2.Caption:=rsCurrentPlan;
  Title3.Caption:=rsTargets;
  BtnEditTargets.Caption:=rsEdit;
  BtnLoadTargets.Caption:=rsLoad;
  BtnNewTargets.Caption:=rsNew;
  BtnStart.Caption:=rsStart;
  BtnStop.Caption:=rsStop;
  Unattended.Caption:=rsRunUnattende;
  BtnCopy.Caption:=rsCopy;
  BtnDelete.Caption:=rsDelete;
  BtnReset.Caption:=rsReset;
end;

procedure Tf_sequence.SetPreview(val: Tf_preview);
begin
  Fpreview:=val;
  Targets.Preview:=Fpreview;
end;

procedure Tf_sequence.SetCapture(val: Tf_capture);
begin
  Fcapture:=val;
  Targets.Capture:=Fcapture;
end;

procedure Tf_sequence.SetMount(val: T_mount);
begin
  Fmount:=val;
  Targets.Mount:=Fmount;
end;

procedure Tf_sequence.SetCamera(val: T_camera);
begin
  Fcamera:=val;
  Targets.Camera:=Fcamera;
end;

procedure Tf_sequence.SetRotator(val: T_rotator);
begin
  Frotator:=val;
  Targets.Rotaror:=Frotator;
end;

procedure Tf_sequence.SetFilter(val: Tf_filterwheel);
begin
  Ffilter:=val;
  Targets.Filter:=Ffilter;
end;

procedure Tf_sequence.SetWeather(val: Tf_weather);
begin
  Fweather:=val;
  Targets.Weather:=Fweather;
end;

procedure Tf_sequence.SetSafety(val: Tf_safety);
begin
  Fsafety:=val;
  Targets.Safety:=Fsafety;
end;

procedure Tf_sequence.SetDome(val: T_dome);
begin
  Fdome:=val;
  Targets.Dome:=Fdome;
end;

procedure Tf_sequence.SetAutoguider(val: T_autoguider);
begin
  Fautoguider:=val;
  Targets.Autoguider:=Fautoguider;
end;

procedure Tf_sequence.SetAstrometry(val: TAstrometry);
begin
  Fastrometry:=val;
  Targets.Astrometry:=Fastrometry;
  f_EditTargets.Astrometry:=Fastrometry;
end;

procedure Tf_sequence.SetPlanetarium(val: TPlanetarium);
begin
  Fplanetarium:=val;
  Targets.Planetarium:=Fplanetarium;
end;

procedure Tf_sequence.ClearTargetGrid;
begin
  TargetGrid.RowCount:=1;
end;

procedure Tf_sequence.ClearPlanGrid;
begin
  PlanGrid.RowCount:=1;
end;

procedure Tf_sequence.msg(txt:string; level: integer);
begin
  StatusMsg.Caption:=txt;
  if Assigned(FonMsg) then FonMsg(txt, level);
end;

procedure Tf_sequence.ShowDelayMsg(txt:string);
begin
  DelayMsg.Caption:=txt;
end;

procedure Tf_sequence.BtnCopyClick(Sender: TObject);
var txt,fn1,fn2: string;
    tfile: TCCDconfig;
begin
  fn1:=CurrentSequenceFile;
  txt:=FormEntry(self, rsCopyTo, '');
  if txt='' then exit;
  fn2:=slash(ConfigDir)+txt+'.targets';
  if FileExistsUTF8(fn2) then begin
     if MessageDlg(Format(rsSequenceAlre, [fn2]), mtConfirmation, mbYesNo, 0)<>
       mrYes then
       exit;
  end;
  if CopyFile(fn1,fn2,false) then begin
    tfile:=TCCDconfig.Create(self);
    tfile.Filename:=fn2;
    tfile.SetValue('/ListName',txt);
    tfile.Flush;
    tfile.Free;
    LoadTargets(fn2);
    ClearRestartHistory(false);
  end;
end;

procedure Tf_sequence.BtnDeleteClick(Sender: TObject);
var fn: string;
begin
   fn:=CurrentSequenceFile;
   if MessageDlg(Format(rsDoYouWantToD, [fn]), mtConfirmation, mbYesNo, 0)=
     mrYes then begin
      DeleteFileUTF8(fn);
      ClearTargetGrid;
      ClearPlanGrid;
      f_EditTargets.TargetList.RowCount:=1;
      Targets.Clear;
   end;
end;

procedure Tf_sequence.BtnResetClick(Sender: TObject);
begin
   ClearRestartHistory(true);
end;

procedure Tf_sequence.BtnEditTargetsClick(Sender: TObject);
var i,j,n:integer;
    t:TTarget;
    defaultname: string;
begin
   f_EditTargets.LoadPlanList;
   f_EditTargets.LoadScriptList;
   if (Sender=BtnEditTargets)and(Targets.Count>0) then begin
      // Edit
      f_EditTargets.TargetName.Caption:=Targets.TargetName;
      f_EditTargets.CheckBoxRestartStatus.Checked:=not Targets.IgnoreRestart;
      f_EditTargets.CheckBoxResetRepeat.Checked:=Targets.ResetRepeat;
      f_EditTargets.TargetsRepeat:=Targets.TargetsRepeat;
      f_EditTargets.TargetList.RowCount:=Targets.Count+1;
      f_EditTargets.SeqStart.Checked:=Targets.SeqStart;
      f_EditTargets.SeqStop.Checked:=Targets.SeqStop;
      f_EditTargets.SeqStartTwilight.Checked:=Targets.SeqStartTwilight;
      f_EditTargets.SeqStopTwilight.Checked:=Targets.SeqStopTwilight;
      f_EditTargets.SeqStartAt.Text:=TimeToStr(Targets.SeqStartAt);
      f_EditTargets.SeqStopAt.Text:=TimeToStr(Targets.SeqStopAt);
      f_EditTargets.cbNone.Checked:=not(Targets.AtEndStopTracking or Targets.AtEndPark or Targets.AtEndCloseDome or Targets.AtEndWarmCamera or Targets.AtEndRunScript);
      f_EditTargets.cbStopTracking.Checked:=Targets.AtEndStopTracking;
      f_EditTargets.cbParkScope.Checked:=Targets.AtEndPark;
      f_EditTargets.cbParkDome.Checked:=Targets.AtEndCloseDome;
      f_EditTargets.cbWarm.Checked:=Targets.AtEndWarmCamera;
      f_EditTargets.cbScript.Checked:=Targets.AtEndRunScript;
      f_EditTargets.cbUnattended.Checked:=Targets.OnErrorRunScript;
      f_EditTargets.BtnEndScript.Hint:=Targets.AtEndScript;
      f_EditTargets.BtnUnattendedScript.Hint:=Targets.OnErrorScript;
      for i:=1 to Targets.Count do begin
        t:=TTarget.Create;
        t.Assign(Targets.Targets[i-1]);
        f_EditTargets.SetTarget(i,t);
        f_EditTargets.TargetList.Objects[colseq,i]:=t;
      end;
    end else begin
      // New
      Targets.Clear;
      CurrentSequenceFile:='';
      CurrentSeqName:='';
      f_EditTargets.TargetName.Caption:='New targets';
      f_EditTargets.CheckBoxRestartStatus.Checked:=true;
      f_EditTargets.CheckBoxResetRepeat.Checked:=true;
      f_EditTargets.TargetsRepeat:=1;
      f_EditTargets.SeqStart.Checked:=false;
      f_EditTargets.SeqStop.Checked:=false;
      f_EditTargets.SeqStartTwilight.Checked:=false;
      f_EditTargets.SeqStopTwilight.Checked:=false;
      f_EditTargets.SeqStartAt.Text:='00:00:00';
      f_EditTargets.SeqStopAt.Text:='00:00:00';
      f_EditTargets.cbNone.Checked:=false;
      f_EditTargets.cbStopTracking.Checked:=true;
      f_EditTargets.cbParkScope.Checked:=false;
      f_EditTargets.cbParkDome.Checked:=false;
      f_EditTargets.cbWarm.Checked:=false;
      f_EditTargets.cbScript.Checked:=false;
      f_EditTargets.cbUnattended.Checked:=false;
      t:=TTarget.Create;
      if (t.planname='')and(f_EditTargets.TargetList.Columns[colplan-1].PickList.Count>0) then
         t.planname:=f_EditTargets.TargetList.Columns[colplan-1].PickList[0];
      f_EditTargets.TargetList.RowCount:=2;
      f_EditTargets.TargetList.Cells[0,1]:='1';
      f_EditTargets.TargetList.Cells[1,1]:=t.objectname;
      f_EditTargets.TargetList.Cells[2,1]:=t.planname;
      f_EditTargets.TargetList.Objects[0,1]:=t;
    end;
    f_EditTargets.DoneWarning:=Targets.CheckDoneCount;
    FormPos(f_EditTargets,mouse.CursorPos.X,mouse.CursorPos.Y);
    if f_EditTargets.ShowModal=mrOK then begin
      n:=f_EditTargets.TargetList.RowCount;
      Targets.Clear;
      defaultname:=FormatDateTime('mmdd',now);
      for i:=1 to n-1 do begin
        if (f_EditTargets.TargetList.Cells[1,i]<>ScriptTxt) and (f_EditTargets.TargetList.Cells[1,i]<>SkyFlatTxt) then
           defaultname:=f_EditTargets.TargetList.Cells[1,i];
        t:=TTarget(f_EditTargets.TargetList.Objects[0,i]);
        t.repeatdone:=0;
        for j:=0 to length(t.DoneList)-1 do
           t.DoneList[j]:=0;
        Targets.Add(t);
        LoadPlan(T_Plan(t.plan), t.planname,t.DoneList);
      end;
      Targets.IgnoreRestart    := not f_EditTargets.CheckBoxRestartStatus.Checked;
      Targets.ResetRepeat      := f_EditTargets.CheckBoxResetRepeat.Checked;
      Targets.TargetsRepeat    := f_EditTargets.TargetsRepeat;
      Targets.SeqStart         := f_EditTargets.SeqStart.Checked;
      Targets.SeqStop          := f_EditTargets.SeqStop.Checked;
      Targets.SeqStartTwilight := f_EditTargets.SeqStartTwilight.Checked;
      Targets.SeqStopTwilight  := f_EditTargets.SeqStopTwilight.Checked;
      Targets.SeqStartAt       := StrToTimeDef(f_EditTargets.SeqStartAt.Text,Targets.SeqStartAt);
      Targets.SeqStopAt        := StrToTimeDef(f_EditTargets.SeqStopAt.Text,Targets.SeqStopAt);
      Targets.AtEndStopTracking := f_EditTargets.cbStopTracking.Checked;
      Targets.AtEndPark         := f_EditTargets.cbParkScope.Checked;
      Targets.AtEndCloseDome    := f_EditTargets.cbParkDome.Checked;
      Targets.AtEndWarmCamera   := f_EditTargets.cbWarm.Checked;
      Targets.AtEndRunScript    := f_EditTargets.cbScript.Checked;
      Targets.OnErrorRunScript  := f_EditTargets.cbUnattended.Checked;
      Targets.AtEndScript       := f_EditTargets.BtnEndScript.Hint;
      Targets.OnErrorScript     := f_EditTargets.BtnUnattendedScript.Hint;
      SaveTargets(CurrentSequenceFile,defaultname);
      LoadTargets(CurrentSequenceFile);
    end else begin
      // look for modified plan
      LoadTargets(CurrentSequenceFile);
    end;
    BtnReset.Enabled:=not Targets.IgnoreRestart;
end;

procedure Tf_sequence.LoadTargets(fn: string);
var tfile: TCCDconfig;
    t:TTarget;
    x:string;
    i,j,m,n: integer;
begin
   tfile:=TCCDconfig.Create(self);
   tfile.Filename:=fn;
   CurrentSeqName:=ExtractFileNameOnly(fn);
   Targets.Clear;
   Targets.TargetName:=CurrentSeqName;
   CurrentSequenceFile:=fn;
   n:=tfile.GetValue('/TargetNum',0);
   Targets.FileVersion      :=tfile.GetValue('/Version',1);
   Targets.TargetsRepeat    :=tfile.GetValue('/RepeatCount',1);
   Targets.IgnoreRestart    := tfile.GetValue('/Targets/IgnoreRestart',true);
   if Targets.IgnoreRestart then
      Targets.TargetsRepeatCount:=0
   else
      Targets.TargetsRepeatCount:=tfile.GetValue('/Targets/RepeatDone',0);
   Targets.ResetRepeat      := tfile.GetValue('/Targets/ResetRepeat',true);
   Targets.SeqStart         := tfile.GetValue('/Startup/SeqStart',false);
   Targets.SeqStop          := tfile.GetValue('/Startup/SeqStop',false);
   Targets.SeqStartTwilight := tfile.GetValue('/Startup/SeqStartTwilight',false);
   Targets.SeqStopTwilight  := tfile.GetValue('/Startup/SeqStopTwilight',false);
   Targets.SeqStartAt       := StrToTimeDef(tfile.GetValue('/Startup/SeqStartAt','00:00:00'),0);
   Targets.SeqStopAt        := StrToTimeDef(tfile.GetValue('/Startup/SeqStopAt','00:00:00'),0);
   Targets.AtEndStopTracking:= tfile.GetValue('/Termination/StopTracking',true);
   Targets.AtEndPark        := tfile.GetValue('/Termination/Park',false);
   Targets.AtEndCloseDome   := tfile.GetValue('/Termination/CloseDome',false);
   Targets.AtEndWarmCamera  := tfile.GetValue('/Termination/WarmCamera',false);
   Targets.AtEndRunScript   := tfile.GetValue('/Termination/RunScript',false);
   Targets.OnErrorRunScript := tfile.GetValue('/Termination/ErrorRunScript',false);
   Targets.AtEndScript      := tfile.GetValue('/Termination/EndScript','');
   Targets.OnErrorScript    := tfile.GetValue('/Termination/ErrorScript','');
   if Targets.FileVersion<3 then begin
     // compatibility with previous version
     if FileExistsUTF8(slash(ScriptDir[1].path)+'end_sequence.script') then begin
        Targets.AtEndStopTracking:=false;
        Targets.AtEndRunScript:=true;
        Targets.AtEndScript:='end_sequence';
     end;
   end;
   if n>0 then begin
     for i:=1 to n do begin
       t:=TTarget.Create;
       t.objectname:=trim(tfile.GetValue('/Targets/Target'+inttostr(i)+'/ObjectName',''));
       t.planname:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/Plan','');
       t.path:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/Path','');
       if Targets.FileVersion>=2 then begin
         t.starttime:=StrToTimeDef(tfile.GetValue('/Targets/Target'+inttostr(i)+'/StartTime',''),-1);
         t.endtime:=StrToTimeDef(tfile.GetValue('/Targets/Target'+inttostr(i)+'/EndTime',''),-1);
       end else begin
         t.starttime:=-1;
         t.endtime:=-1;
       end;
       t.startrise:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/StartRise',false);
       t.endset:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/EndSet',false);
       t.startmeridian:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/StartMeridian',NullCoord);
       t.endmeridian:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/EndMeridian',NullCoord);
       t.darknight:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/DarkNight',false);
       t.skip:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/Skip',false);
       x:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/RA','');
       if x='-' then
         t.ra:=NullCoord
       else
         t.ra:=StrToAR(x);
       x:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/Dec','');
       if x='-' then
         t.de:=NullCoord
       else
         t.de:=StrToDE(x);
       if (Targets.FileVersion<4)and(t.ra<>NullCoord)and(t.de<>NullCoord) then begin
         // previous version, up to 3, store apparent coordinates
         t.ra:=t.ra*15*deg2rad;
         t.de:=t.de*deg2rad;
         ApparentToJ2000(t.ra,t.de);
         t.ra:=rad2deg*t.ra/15;
         t.de:=rad2deg*t.de;
       end;
       x:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/PA','-');
       if x='-' then
         t.pa:=NullCoord
       else
         t.pa:=StrToFloatDef(x,NullCoord);
       t.astrometrypointing:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/AstrometryPointing',false);
       t.updatecoord:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/UpdateCoord',false);
       t.inplaceautofocus:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/InplaceAutofocus',AutofocusInPlace);
       t.previewexposure:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/PreviewExposure',1.0);
       t.preview:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/Preview',false);
       t.repeatcount:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/RepeatCount',1));
       if Targets.IgnoreRestart then
          t.repeatdone:=0
       else
          t.repeatdone:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/RepeatDone',0));
       t.delay:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/Delay',1.0);
       t.FlatCount:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/FlatCount',1));
       t.FlatBinX:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/FlatBinX',1));
       t.FlatBinY:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/FlatBinY',1));
       t.FlatGain:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/FlatGain',0));
       t.FlatFilters:=tfile.GetValue('/Targets/Target'+inttostr(i)+'/FlatFilters','');
       m:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/StepDone/StepCount',0));
       SetLength(t.DoneList,m);
       for j:=0 to m-1 do begin
          if Targets.IgnoreRestart then
             t.DoneList[j]:=0
          else
             t.DoneList[j]:=trunc(tfile.GetValue('/Targets/Target'+inttostr(i)+'/StepDone/Step'+inttostr(j)+'/Done',0));
       end;
       Targets.Add(t);
       LoadPlan(T_Plan(t.plan), t.planname, t.DoneList);
     end;
   end;
   BtnReset.Enabled:=not Targets.IgnoreRestart;
   if Targets.CheckDoneCount then begin
      msg(targets.DoneStatus,2);
      msg(Format(rsThisSequence,['"'+CurrentSeqName+'"']), 2);
   end
   else
      msg('',2);
   tfile.Free;
end;

procedure Tf_sequence.ClearRestartHistory(Confirm:boolean);
begin
   if Targets.CheckDoneCount then begin
     if (not Confirm) or
       (MessageDlg(rsClearTheComp, Format(rsThisSequence2, [crlf, crlf+crlf]),mtConfirmation,mbYesNo,0)=mrYes)
       then begin
        Targets.ClearDoneCount(true);
        SaveTargets(CurrentSequenceFile,'');
        msg('',2);
     end;
   end;
end;

procedure Tf_sequence.LoadPlan(p: T_plan; plan:string; donelist:TStepDone);
var fn,buf: string;
    i,n,m:integer;
    pfile: TCCDconfig;
    s: TStep;
begin
  fn:=slash(ConfigDir)+plan+'.plan';
  if FileExistsUTF8(fn) then begin
     p.Clear;
     p.PlanName:=plan;
     pfile:=TCCDconfig.Create(self);
     pfile.Filename:=fn;
     n:=pfile.GetValue('/StepNum',0);
     m:=Length(donelist);
     if n<>m then begin
       SetLength(donelist,n);
       for i:=m to n-1 do donelist[i]:=0;
     end;
     buf:='';
     for i:=1 to n do begin
       s:=TStep.Create;
       f_EditTargets.ReadStep(pfile,i,s,buf);
       s.donecount:=donelist[i-1];
       p.Add(s);
     end;
     if buf>'' then ShowMessage(buf);
  end;
end;

procedure Tf_sequence.TargetsChange(Sender: TObject);
var i: integer;
begin
   ClearTargetGrid;
   TargetGrid.RowCount:=Targets.count+1;
   Title3.Caption:=rsTargets+': '+Targets.TargetName;
   if Targets.TargetsRepeat>1 then
     Title3.Caption:=Title3.Caption+' x'+inttostr(Targets.TargetsRepeat);
   for i:=1 to Targets.count do begin
     TargetGrid.Cells[0,i]:=Targets.Targets[i-1].objectname;
     if Targets.Targets[i-1].repeatcount>0 then
        TargetGrid.Cells[1,i]:=Targets.Targets[i-1].planname
     else
        TargetGrid.Cells[1,i]:=format(rsSkipTarget,['']);
     TargetGrid.Cells[2,i]:=TimetoStr(Targets.Targets[i-1].starttime);
     TargetGrid.Cells[3,i]:=TimetoStr(Targets.Targets[i-1].endtime);
     TargetGrid.Cells[4,i]:=RAToStr(Targets.Targets[i-1].ra);
     TargetGrid.Cells[5,i]:=DEToStr(Targets.Targets[i-1].de);
   end;
end;

procedure Tf_sequence.PlanChange(Sender: TObject);
var i: integer;
    p: T_plan;
begin
  try
   p:=T_Plan(sender);
   ClearPlanGrid;
   Title2.Caption:=rsPlan+': '+p.PlanName;
   PlanGrid.RowCount:=p.count+1;
   for i:=1 to p.count do begin
     PlanGrid.Cells[0,i]:=T_Plan(sender).Steps[i-1].description_str;
     PlanGrid.Cells[1,i]:=T_Plan(sender).Steps[i-1].exposure_str;
     PlanGrid.Cells[2,i]:=T_Plan(sender).Steps[i-1].count_str;
     PlanGrid.Cells[3,i]:=T_Plan(sender).Steps[i-1].frtype_str;
     PlanGrid.Cells[4,i]:=T_Plan(sender).Steps[i-1].filter_str;
   end;
  except
  end;
end;

procedure Tf_sequence.UnattendedChange(Sender: TObject);
begin
 Targets.Unattended:=Unattended.Checked;
end;

procedure Tf_sequence.BtnLoadTargetsClick(Sender: TObject);
begin
 OpenDialog1.InitialDir:=ConfigDir;
 OpenDialog1.FileName:='*.targets';
 if OpenDialog1.Execute then begin
   LoadTargets(OpenDialog1.FileName);
 end;
end;

procedure Tf_sequence.SaveTargets(fn,defaultname:string);
var tfile: TCCDconfig;
    t:TTarget;
    i,j: integer;
begin
 if TargetGrid.RowCount>1 then begin
    if fn='' then begin
      SaveDialog1.InitialDir:=ConfigDir;
      SaveDialog1.FileName:=slash(ConfigDir)+defaultname+'.targets';
      if SaveDialog1.Execute then begin
        fn:=SaveDialog1.FileName;
      end
      else exit;
    end;
    tfile:=TCCDconfig.Create(self);
    tfile.Filename:=fn;
    tfile.Clear;
    CurrentSequenceFile:=fn;
    CurrentSeqName:=ExtractFileNameOnly(fn);
    Targets.TargetName:=CurrentSeqName;
    tfile.SetValue('/Version',TargetFileVersion);
    tfile.SetValue('/ListName',CurrentSeqName);
    tfile.SetValue('/TargetNum',Targets.Count);
    tfile.SetValue('/RepeatCount',Targets.TargetsRepeat);
    tfile.SetValue('/Targets/IgnoreRestart',Targets.IgnoreRestart);
    if Targets.IgnoreRestart then
       tfile.SetValue('/Targets/RepeatDone',0)
    else
       tfile.SetValue('/Targets/RepeatDone',Targets.TargetsRepeatCount);
    tfile.SetValue('/Targets/ResetRepeat',Targets.ResetRepeat);
    tfile.SetValue('/Startup/SeqStart',Targets.SeqStart);
    tfile.SetValue('/Startup/SeqStop',Targets.SeqStop);
    tfile.SetValue('/Startup/SeqStartTwilight',Targets.SeqStartTwilight);
    tfile.SetValue('/Startup/SeqStopTwilight',Targets.SeqStopTwilight);
    tfile.SetValue('/Startup/SeqStartAt',TimeToStr(Targets.SeqStartAt));
    tfile.SetValue('/Startup/SeqStopAt',TimeToStr(Targets.SeqStopAt));
    tfile.SetValue('/Termination/StopTracking',Targets.AtEndStopTracking);
    tfile.SetValue('/Termination/Park',Targets.AtEndPark);
    tfile.SetValue('/Termination/CloseDome',Targets.AtEndCloseDome);
    tfile.SetValue('/Termination/WarmCamera',Targets.AtEndWarmCamera);
    tfile.SetValue('/Termination/RunScript',Targets.AtEndRunScript);
    tfile.SetValue('/Termination/ErrorRunScript',Targets.OnErrorRunScript);
    tfile.SetValue('/Termination/EndScript',Targets.AtEndScript);
    tfile.SetValue('/Termination/ErrorScript',Targets.OnErrorScript);
    for i:=1 to Targets.Count do begin
      t:=Targets.Targets[i-1];
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/ObjectName',t.objectname);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/Plan',t.planname);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/Path',t.path);
      if t.starttime>=0 then
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/StartTime',TimetoStr(t.starttime))
      else
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/StartTime','');
      if t.endtime>=0 then
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/EndTime',TimetoStr(t.endtime))
      else
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/EndTime','');
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/StartRise',t.startrise);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/EndSet',t.endset);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/StartMeridian',t.startmeridian);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/EndMeridian',t.endmeridian);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/DarkNight',t.darknight);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/Skip',t.skip);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/RA',RAToStr(t.ra));
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/Dec',DEToStr(t.de));
      if t.pa=NullCoord then
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/PA','-')
      else
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/PA',FormatFloat(f1,t.pa));
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/AstrometryPointing',t.astrometrypointing);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/UpdateCoord',t.updatecoord);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/InplaceAutofocus',t.inplaceautofocus);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/PreviewExposure',t.previewexposure);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/Preview',t.preview);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/RepeatCount',t.repeatcount);
      if Targets.IgnoreRestart then
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/RepeatDone',0)
      else
        tfile.SetValue('/Targets/Target'+inttostr(i)+'/RepeatDone',t.repeatdone);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/Delay',t.delay);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/FlatCount',t.FlatCount);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/FlatBinX',t.FlatBinX);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/FlatBinY',t.FlatBinY);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/FlatGain',t.FlatGain);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/FlatFilters',t.FlatFilters);
      tfile.SetValue('/Targets/Target'+inttostr(i)+'/StepDone/StepCount',Length(t.DoneList));
      for j:=0 to Length(t.DoneList)-1 do begin
        if Targets.IgnoreRestart then
           tfile.SetValue('/Targets/Target'+inttostr(i)+'/StepDone/Step'+inttostr(j)+'/Done',0)
        else
           tfile.SetValue('/Targets/Target'+inttostr(i)+'/StepDone/Step'+inttostr(j)+'/Done',t.DoneList[j]);
      end;
    end;
    tfile.Flush;
    tfile.Free;
 end;
end;

procedure Tf_sequence.TargetGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
 if (TargetRow>0)and(aCol=0)and(aRow=TargetRow) then begin
    TargetGrid.Canvas.FillRect(aRect);
    TargetGrid.Canvas.Font.Style:=[fsBold];
    TargetGrid.Canvas.TextOut(aRect.Left,aRect.Top,TargetGrid.Cells[aCol,aRow]);
 end;
end;

procedure Tf_sequence.TargetGridSelection(Sender: TObject; aCol, aRow: Integer);
var p : T_plan;
begin
  if not Running then begin
    p:=T_Plan(Targets.Targets[arow-1].plan);
    if p<>nil then PlanChange(p);
  end;
end;

procedure Tf_sequence.PlanGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
 if (PlanRow>0)and(aCol=0)and(aRow=PlanRow) then begin
    PlanGrid.Canvas.FillRect(aRect);
    PlanGrid.Canvas.Font.Style:=[fsBold];
    PlanGrid.Canvas.TextOut(aRect.Left,aRect.Top,PlanGrid.Cells[aCol,aRow]);
 end;
end;

function Tf_sequence.GetBusy: boolean;
begin
  result:=Targets.Busy;
end;

function Tf_sequence.GetRunning: boolean;
begin
  result:=Targets.Running;
end;

function Tf_sequence.GetTargetCoord: boolean;
begin
  result:=Targets.TargetCoord;
end;

function Tf_sequence.GetTargetRA: double;
begin
  result:=Targets.TargetRA;
end;

function Tf_sequence.GetTargetDE: double;
begin
  result:=Targets.TargetDE;
end;

function Tf_sequence.GetCurrentPlan: T_Plan;
begin
  if (Targets<>nil)and(Targets.CurrentTarget>=0) then
    result:=T_Plan(Targets.Targets[Targets.CurrentTarget].plan)
  else
    result:=nil;
end;

procedure Tf_sequence.SetEditBtn(onoff:boolean);
begin
  BtnLoadTargets.Enabled:=onoff;
  BtnNewTargets.Enabled:=onoff;
  BtnEditTargets.Enabled:=onoff;
  BtnCopy.Enabled:=onoff;
  BtnDelete.Enabled:=onoff;
end;

procedure Tf_sequence.StartTimerTimer(Sender: TObject);
begin
  StartTimer.Enabled:=false;
  if not StartingSequence then exit;
  StartSequence;
end;

procedure Tf_sequence.StartSequence;
var ccdtemp: double;
    i,j: integer;
    isCalibrationSequence, waitcooling: boolean;
    buf: string;
begin
 StartingSequence:=true;
 msg(Format(rsStartingSequ,['']),1);
 led.Brush.Color:=clYellow;
 if Targets.CheckDoneCount then begin
    msg(targets.DoneStatus,2);
    msg(Format(rsThisSequence,['"'+CurrentSeqName+'"']),2);
    msg(rsItWillContin, 2);
 end;
 if preview.Running then begin
     msg(rsStopPreview,2);
     camera.AbortExposure;
     preview.stop;
     StartTimer.Interval:=5000;
     StartTimer.Enabled:=true;
     exit;
 end;
 // check if the sequence contain only calibration
 isCalibrationSequence:=true;
 for j:=0 to Targets.Count-1 do begin
   if Targets.Targets[j].objectname=ScriptTxt then continue;
   if Targets.Targets[j].objectname=SkyFlatTxt then continue;
   for i:=0 to T_Plan(Targets.Targets[j].plan).Count-1 do begin
      if T_Plan(Targets.Targets[j].plan).Steps[i].frtype=LIGHT then begin
         isCalibrationSequence:=false;
         break;
      end;
   end;
   if not isCalibrationSequence then break;
 end;
 if not StartingSequence then exit;
 // check camera cooler
 waitcooling:=config.GetValue('/Cooler/CameraAutoCool',false);
 ccdtemp:=config.GetValue('/Cooler/CameraAutoCoolTemp',0.0);
 if not camera.Cooler then begin
    if waitcooling then begin
       msg(Format(rsCameraNotCoo, [FormatFloat(f1, ccdtemp)]),1);
       ccdtemp:=TempCelsius(TemperatureScale,ccdtemp);
       camera.Temperature:=ccdtemp;
    end;
 end;
 if not StartingSequence then exit;
 // Check dome open and slaving
 if (not isCalibrationSequence)and(dome.Status=devConnected) and
   ((not dome.Shutter)or(dome.hasSlaving and(not dome.Slave)))
   then begin
    buf:='Dome is: ';
    if not dome.Shutter then buf:=buf+'closed, ';
    if dome.hasSlaving and(not dome.Slave) then buf:=buf+'not slaved ';
    f_pause.Caption:='Dome is not ready';
    f_pause.Text:=buf;
    if not f_pause.Wait then begin
      StopSequence;
    end;
 end;
 if not StartingSequence then exit;
 // check mount park
 if mount.Park then begin
    msg(rsTheTelescope, 1);
    mount.Park:=false;
    wait(5);
 end;

 if not StartingSequence then exit;
 // check if autoguider is required and connected
 if (not isCalibrationSequence)and(Autoguider.AutoguiderType<>agNONE)and(Autoguider.State=GUIDER_DISCONNECTED)and(assigned(FConnectAutoguider)) then begin
   if AutoguiderStarting then begin
     f_pause.Caption:=rsAutoguiderNo;
     f_pause.Text:=Format(rsCannotConnec, [crlf]);
     if f_pause.Wait(30) then begin
       msg(rsSequenceWill2,0);
     end
     else begin
       StopSequence;
     end;
   end
   else begin
     msg(rsTryToConnect,1);
     FConnectAutoguider(self);
     AutoguiderStarting:=true;
     StartTimer.Interval:=10000;
     StartTimer.Enabled:=true;
     exit;
   end;
 end;
 if not StartingSequence then exit;
 // initialize sequence
 if not StartingSequence then exit;
 StartingSequence:=false;
 AutoguiderStarting:=false;
 AutoguiderAlert:=false;
 MountTrackingAlert:=false;
 Preview.StackPreview.Checked:=false;
 led.Brush.Color:=clLime;
 SetEditBtn(false);
 StatusTimer.Enabled:=true;
 Targets.Unattended:=Unattended.Checked;
 Targets.Start;
 if not Targets.Running then AbortSequence;
end;

procedure Tf_sequence.StopSequence;
begin
 StartTimer.Enabled:=false;
 StatusTimer.Enabled:=false;
 if StartingSequence then begin
    led.Brush.Color:=clRed;
    msg(Format(rsSequenceStop2,['']),1);
 end;
 StartingSequence:=false;
 if targets.TargetInitializing or targets.WaitStarting or targets.ScriptRunning then begin
   led.Brush.Color:=clRed;
   SetEditBtn(true);
 end;
 if Targets.Running then Targets.Stop;
 TargetRow:=-1;
 PlanRow:=-1;
end;

procedure Tf_sequence.WeatherChange(value: boolean);
begin
  if value then begin
    // good weather, restart the sequence
    Targets.WeatherRestart;
  end
  else begin
    // bad weather, pause the sequence
    Targets.WeatherPause;
  end;
end;

procedure Tf_sequence.AbortSequence;
begin
 StatusTimer.Enabled:=false;
 Targets.Abort;
 TargetRow:=-1;
 PlanRow:=-1;
 led.Brush.Color:=clRed;
 SetEditBtn(true);
 if Unattended.Checked then mount.AbortMotion;
end;

procedure Tf_sequence.EndSequence(Sender: TObject);
begin
 FlatWaitDusk:=false;
 FlatWaitDawn:=false;
 led.Brush.Color:=clRed;
 SetEditBtn(true);
 PlanGrid.Invalidate;
 TargetGrid.Invalidate;
end;

procedure Tf_sequence.BtnStopClick(Sender: TObject);
begin
 StopSequence;
end;

procedure Tf_sequence.BtnStartClick(Sender: TObject);
var tfile:TCCDconfig;
begin
 if (AllDevicesConnected) then begin
   if Targets.Running or Fcapture.Running then begin
     msg(rsCaptureAlrea,0);
   end
   else if Targets.Count=0 then begin
     msg(rsPleaseLoadOr,0);
   end
   else begin
     if Targets.IgnoreRestart then begin
       Targets.ClearDoneCount(true);
       SaveTargets(CurrentSequenceFile,'');
     end;
     tfile:=TCCDconfig.Create(self);
     tfile.Filename:=CurrentSequenceFile;
     Targets.TargetsRepeatCount:=tfile.GetValue('/Targets/RepeatDone',0);
     tfile.Free;
     StartSequence;
   end;
 end
 else msg(rsSomeDefinedD,0);
end;

procedure Tf_sequence.StatusTimerTimer(Sender: TObject);
var buf1,buf2:string;
    i:integer;
    p: T_Plan;
    agAlerttime, trAlerttime, msgtime: integer;
const
    agAlerttimeout=5;
    trAlerttimeout=1;
begin
 try
  StatusTimer.Enabled:=false;
  TargetRow:=Targets.CurrentTarget+1;
  if Targets.Running then begin
   try
   // show plan status
   if (TargetRow>0) then begin
    buf1:=Targets.Targets[Targets.CurrentTarget].planname;
    buf2:=Title2.Caption;
    i:=pos(blank,buf2);
    delete(buf2,1,i);
    buf2:=trim(buf2);
    p:=T_Plan(Targets.Targets[Targets.CurrentTarget].plan);
    if p=nil then exit;
    if buf1<>buf2 then begin
      PlanChange(p);
    end;
    PlanRow:=p.CurrentStep+1;
    TargetGrid.TopRow:=TargetRow;
    PlanGrid.TopRow:=PlanRow;
    TargetGrid.Invalidate;
    PlanGrid.Invalidate;
    Application.ProcessMessages;
   end;
   // process autoguider problem during sequence
   if AutoguiderAlert then begin
    if (Autoguider<>nil)and(Autoguider.State=GUIDER_GUIDING) then begin
      // autoguiding restarted, clear alert
      AutoguiderAlert:=false;
      msg(rsAutoguidingR,1);
    end
    else begin
      agAlerttime:=trunc((now-AutoguiderAlertTime)*minperday);
      msgtime:=trunc((now-AutoguiderMsgTime)*minperday);
      if agAlerttime>=agAlerttimeout then begin
        // timeout
        if (Autoguider=nil)or(Autoguider.State=GUIDER_DISCONNECTED) then begin
           // no more autoguider, stop sequence
           msg(Format(rsSequenceAbor2, [IntToStr(agAlerttime)]),0);
           AbortSequence;
           AutoguiderAlert:=false;
        end
        else begin
           // autoguider connected but not guiding, try next target
           msg(Format(rsAutoguiderWa, [IntToStr(agAlerttime)]),1);
           msg(rsTryNextTarge,1);
           Targets.ForceNextTarget;
           AutoguiderAlert:=false;
        end;
      end
      else begin
       // continue to wait for a restart
       if msgtime>=1 then begin
         // display a message every minute
         AutoguiderMsgTime:=now;
         msg(Format(rsAutoguidingS, [IntToStr(agAlerttime), IntToStr(agAlerttimeout-agAlerttime)]),1);
       end;
      end;
    end;
   end;
   // process mount tracking problem during sequence
   if MountTrackingAlert then begin
    trAlerttime:=trunc((now-MountTrackingAlertTime)*minperday);
    if trAlerttime>=trAlerttimeout then begin
       // timeout, mount still not tracking, try next target
       msg(Format(rsMountWasStil, [IntToStr(trAlerttime)]), 1);
       msg(rsTryNextTarge,1);
       Targets.ForceNextTarget;
       MountTrackingAlert:=false;
    end
    else begin
      // try to restart tracking
      mount.Track;
    end;
   end;
   finally
     StatusTimer.Enabled:=true;
   end;
  end
  else StopSequence;
except
  AbortSequence;
end;
end;


procedure Tf_sequence.AutoguiderDisconnected;
begin
  if Autoguider.AutoguiderType=agNONE then exit;
  if Targets.Running and
    (Targets.CurrentTarget>=0) and
    T_Plan(Targets.Targets[Targets.CurrentTarget].plan).Running and
    (Targets.Targets[Targets.CurrentTarget].autoguiding)
    then begin
    if not AutoguiderAlert then begin
     AutoguiderAlert:=true;
     AutoguiderAlertTime:=now;
     AutoguiderMsgTime:=0;
    end;
  end;
end;

procedure Tf_sequence.AutoguiderIddle;
begin
  if Autoguider.AutoguiderType=agNONE then exit;
  if Targets.Running and
    (Targets.CurrentTarget>=0) and
    T_Plan(Targets.Targets[Targets.CurrentTarget].plan).Running and
    (Targets.Targets[Targets.CurrentTarget].autoguiding) and
    (not Fautoguider.Recovering)
    then begin
    if not AutoguiderAlert then begin
      AutoguiderAlert:=true;
      AutoguiderAlertTime:=now;
      AutoguiderMsgTime:=0;
    end;
  end;
end;

procedure Tf_sequence.MountTrackingStarted;
begin
  if MountTrackingAlert then begin
    MountTrackingAlert:=false;
    msg(rsMountTrackin, 1);
    // maybe we can recenter the target here
    // but as this function is mainly to handle mount limits we not do it for now
    // for very short interruption the autoguider may handle the recenter better
  end;
end;

procedure Tf_sequence.MountTrackingStopped;
begin
  if Targets.Running and
    (Targets.CurrentTarget>=0) and
    (Targets.Targets[Targets.CurrentTarget].objectname<>SkyFlatTxt) and
    (Targets.Targets[Targets.CurrentTarget].objectname<>ScriptTxt) and
    (T_Plan(Targets.Targets[Targets.CurrentTarget].plan).Running) and
    (T_Plan(Targets.Targets[Targets.CurrentTarget].plan).Steps[T_Plan(Targets.Targets[Targets.CurrentTarget].plan).CurrentStep].frtype=LIGHT)
    then begin
       MountTrackingAlert:=true;
       MountTrackingAlertTime:=now;
       msg(Format(rsMountTrackin2, ['1']), 1);
    end;
end;

procedure Tf_sequence.ExposureAborted;
begin
  if Targets.Running and T_Plan(Targets.Targets[Targets.CurrentTarget].plan).Running then begin
    AbortSequence;
  end;
end;

procedure Tf_sequence.CameraDisconnected;
begin
 if Targets.Running then AbortSequence;
end;

function Tf_sequence.GetEndShutdown: boolean;
begin
   result:=Targets.AtEndShutdown;
end;

procedure Tf_sequence.SetEndShutdown(value:boolean);
begin
  Targets.AtEndShutdown:=value;
end;

function Tf_sequence.GetOnShutdown: TNotifyEvent;
begin
   result:=Targets.OnShutdown;
end;

procedure Tf_sequence.SetOnShutdown(value:TNotifyEvent);
begin
  Targets.OnShutdown:=value;
end;

function Tf_sequence.GetPercentComplete: double;
begin
{ TODO : Improve to take account for execution time }
try
  if Targets.Running and (Targets.CurrentTarget>=0) then
     result := (Targets.CurrentTarget)/Targets.Count
  else
     result:=0;
  except
    result:=0;
  end;
end;

function Tf_sequence.GetTargetPercentComplete: double;
begin
{ TODO : Improve to take account for execution time }
try
  if Targets.Running and (T_Plan(Targets.Targets[Targets.CurrentTarget].plan).CurrentStep>=0) then
     result := (T_Plan(Targets.Targets[Targets.CurrentTarget].plan).CurrentStep)/ T_Plan(Targets.Targets[Targets.CurrentTarget].plan).Count
  else
     result:=0;
except
  result:=0;
end;
end;

end.


