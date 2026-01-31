unit RESTAssured.Utils;

interface

uses
  System.SysUtils,
  System.Variants;

type
  ECheckerException = class(Exception);

  TPredicate<T> = reference to function(Value: T): Boolean;

  TVariantConversor = class
    public
      function Convert(Value: Variant): String;
    end;

  TRESTAssuredUtils = class
    public
      class procedure CheckNotEmpty(Content: String; Name: String);
      class procedure CheckNotNull(Value: Variant; Name: String); overload;
      class procedure CheckNotNull(Instance: IInterface; Name: String); overload;
      class procedure CheckNotNull(Clazz: TClass; Name: String); overload;
      class function Replace(Content, FromStr, ToStr: String): String;
      class function First(Arguments: Array of String): String;
      class function TrimPath(Path: String): String;
    end;

implementation

{ TRESTAssuredUtils }

class procedure TRESTAssuredUtils.CheckNotEmpty;
begin
  if not String.IsNullOrWhiteSpace(Content) then
    Exit;
  raise ECheckerException.CreateFmt('"%s" must not be empty.', [Name]);
end;

class function TRESTAssuredUtils.First;
begin
  for var I := 0 to Length(Arguments) - 1 do
    if not String.IsNullOrWhiteSpace(Arguments[I]) then
      Exit(Arguments[I]);
end;

class function TRESTAssuredUtils.Replace;
begin
  Result := StringReplace(Content, FromStr, ToStr, [rfReplaceAll]);
end;

class function TRESTAssuredUtils.TrimPath;
begin
  Result := Path.Trim(['/','\', ' ']);
end;

class procedure TRESTAssuredUtils.CheckNotNull(
  Value: Variant;
  Name: String);
begin
  if not VarIsNull(Value) then
    Exit;
  raise ECheckerException.CreateFmt('"%s" must not be null.', [Name]);
end;

class procedure TRESTAssuredUtils.CheckNotNull(
  Instance: IInterface;
  Name: String);
begin
  if Assigned(Instance) then
    Exit;
  raise ECheckerException.CreateFmt('"%s" must not be null.', [Name]);
end;

class procedure TRESTAssuredUtils.CheckNotNull(
  Clazz: TClass;
  Name: String);
begin
  if Assigned(Clazz) then
    Exit;
  raise ECheckerException.CreateFmt('"%s" must not be null.', [Name]);
end;

{ TVariantConversor }

function TVariantConversor.Convert;
begin
  Result := VarToStr(Value);
end;

end.
