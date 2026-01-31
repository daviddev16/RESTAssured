unit RESTAssured.Types;

interface

uses
  System.Generics.Collections;

type
  TRunnable<D> = reference to procedure(Data: D);

  TRunnableEventHandler<D> = class(TQueue<TRunnable<D>>)
    public
      procedure TriggerOn(Data: D);
    end;

implementation

{ TRunnableEventHandler<D> }

procedure TRunnableEventHandler<D>.TriggerOn;
var
  lRunnable: TRunnable<D>;
begin
  while not IsEmpty do
  begin
    lRunnable := Dequeue();
    if Assigned(lRunnable) then
      lRunnable(Data);
  end;
end;

end.
