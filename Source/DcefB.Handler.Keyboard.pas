(*
  Delphi Multi-tab Chromium Browser Frame

  Unit owner : BccSafe
  QQ: 1262807955
  Email: bccsafe5988@gmail.com
  Web site   : http://www.bccsafe.com
  Repository : https://github.com/bccsafe/DcefBrowser
*)

unit DcefB.Handler.Keyboard;

interface

uses
  Winapi.Windows, System.Classes,
  DcefB.Dcef3.CefLib, DcefB.Events, DcefB.res, DcefB.Utils, DcefB.BaseObject;

type
  TDcefBKeyboardHandler = class(TCefKeyboardHandlerOwn)
  private
    FEvents: IDcefBEvents;
  protected
    function OnPreKeyEvent(const browser: ICefBrowser;
      const event: PCefKeyEvent; osEvent: TCefEventHandle;
      out isKeyboardShortcut: Boolean): Boolean; override;
    function OnKeyEvent(const browser: ICefBrowser; const event: PCefKeyEvent;
      osEvent: TCefEventHandle): Boolean; override;
  public
    constructor Create(aDcefBEvents: IDcefBEvents); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TDcefBKeyboardHandler }

constructor TDcefBKeyboardHandler.Create(aDcefBEvents: IDcefBEvents);
begin
  inherited Create;
  FEvents := aDcefBEvents;
end;

destructor TDcefBKeyboardHandler.Destroy;
begin
  FEvents := nil;
  inherited;
end;

function TDcefBKeyboardHandler.OnKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle): Boolean;
{ var
  PArgs: PKeyEventArgs; }
begin
  { New(PArgs);
    PArgs.event := event;
    PArgs.osEvent := osEvent;
    PArgs.Result := False;
    if TDcefBUtils.SendMsg(browser, WM_KeyEvent, LParam(PArgs)) then
    Result := PArgs.Result
    else
    Result := False;
    Dispose(PArgs); }
  Result := False;
  FEvents.doOnKeyEvent(browser, event, osEvent, Result);
end;

function TDcefBKeyboardHandler.OnPreKeyEvent(const browser: ICefBrowser;
  const event: PCefKeyEvent; osEvent: TCefEventHandle;
  out isKeyboardShortcut: Boolean): Boolean;
var
  // PArgs: PPreKeyEventArgs;
  CancelDefaultEvent: Boolean;
begin
  { New(PArgs);
    PArgs.event := event;
    PArgs.osEvent := osEvent;
    PArgs.isKeyboardShortcut := isKeyboardShortcut;
    PArgs.Result := False;
    PArgs.CancelDefaultEvent := False;
    if TDcefBUtils.SendMsg(browser, WM_PreKeyEvent, LParam(PArgs)) then
    Result := PArgs.Result
    else
    Result := False;
    Dispose(PArgs); }
  Result := False;
  CancelDefaultEvent := False;
  FEvents.doOnPreKeyEvent(browser, event, osEvent, isKeyboardShortcut, Result,
    CancelDefaultEvent);
  if Not CancelDefaultEvent then
  begin
    if (event.windows_key_code = 123) and (event.Kind = KEYEVENT_KEYUP) then
      TDcefBUtils.SendMsg(browser, WM_DevTools, 0); // F12

    if (event.windows_key_code = 116) and (event.Kind = KEYEVENT_KEYUP) then
      TDcefBUtils.SendMsg(browser, WM_RefreshIgnoreCache, 0); // F5

    if (event.windows_key_code = 70) and
      (EVENTFLAG_CONTROL_DOWN in event.modifiers) then
      TDcefBUtils.SendMsg(browser, WM_SearchText, 0); // Ctrl+F

    if (event.windows_key_code = 115) and // Alt + F4
      (EVENTFLAG_ALT_DOWN in event.modifiers) then
      Result := True;
  end;

end;

end.