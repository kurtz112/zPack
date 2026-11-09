unit MantisClient;

interface

uses
  System.SysUtils, System.JSON,
  MantisTypes,
  MantisConnection,
  MantisIssuesEndpoint,
  MantisProjectsEndpoint,
  MantisUsersEndpoint,
  MantisFiltersTagsEndpoint,
  MantisConfigEndpoint;

type
  { TMantisClient è il punto di ingresso unico verso l'API REST di MantisBT.
    Istanziarlo con l'URL base dell'installazione (es. 'https://tracker.softline.it/mantis')
    e il token API dell'utente (creato da Mantis in "Manage My Account > API Tokens").

    Esempio d'uso:

      var LClient := TMantisClient.Create('https://tracker.example.com', 'MIO_TOKEN');
      try
        var LIssue := LClient.Issues.GetById(123);
        try
          WriteLn(LIssue.Summary);
        finally
          LIssue.Free;
        end;
      finally
        LClient.Free;
      end; }
  TMantisClient = class
  private
    FConnection: THTTPMantisConnection;
    FIssues: TMantisIssuesEndpoint;
    FProjects: TMantisProjectsEndpoint;
    FUsers: TMantisUsersEndpoint;
    FFilters: TMantisFiltersEndpoint;
    FTags: TMantisTagsEndpoint;
    FConfig: TMantisConfigEndpoint;
    FLang: TMantisLangEndpoint;
  public
    constructor Create(const ABaseUrl, AApiToken: string; ATimeoutMs: Integer = 30000);
    destructor Destroy; override;

    property Issues: TMantisIssuesEndpoint read FIssues;
    property Projects: TMantisProjectsEndpoint read FProjects;
    property Users: TMantisUsersEndpoint read FUsers;
    property Filters: TMantisFiltersEndpoint read FFilters;
    property Tags: TMantisTagsEndpoint read FTags;
    property Config: TMantisConfigEndpoint read FConfig;
    property Lang: TMantisLangEndpoint read FLang;

    { Verifica rapida della connessione/token: solleva EMantisAPIError se
      autenticazione o raggiungibilità falliscono. }
    procedure TestConnection;

    { --- Helper di onboarding idempotenti per lo scenario multi-cliente ---
      Pensati per essere richiamati dall'exe ad ogni apertura ticket senza
      preoccuparsi se progetto/utente/associazione esistano già. }

    { Cerca un progetto per nome esatto (case-sensitive); se assente lo crea.
      Da usare con un progetto per cliente. }
    function EnsureProjectForClient(const AClientName: string): TMantisProject;

    { Cerca un utente per username o email; se assente lo crea con una
      password casuale (l'utente è solo referenziato come reporter, non
      effettua mai login diretto su Mantis). }
    function EnsureUser(const AUsername, AEmail, ARealName: string;
      AAccessLevel: TMantisEnum = nil): TMantisUser;

    { Garantisce che l'utente sia associato al progetto (v. nota su
      TMantisProjectsEndpoint.AddUserToProject riguardo al path non confermato). }
    procedure EnsureUserInProject(AUserId, AProjectId: Integer; AAccessLevel: TMantisEnum = nil);
  end;

implementation

constructor TMantisClient.Create(const ABaseUrl, AApiToken: string; ATimeoutMs: Integer);
begin
  inherited Create;
  FConnection := THTTPMantisConnection.Create(ABaseUrl, AApiToken);
  FConnection.TimeoutMs := ATimeoutMs;

  FIssues := TMantisIssuesEndpoint.Create(FConnection);
  FProjects := TMantisProjectsEndpoint.Create(FConnection);
  FUsers := TMantisUsersEndpoint.Create(FConnection);
  FFilters := TMantisFiltersEndpoint.Create(FConnection);
  FTags := TMantisTagsEndpoint.Create(FConnection);
  FConfig := TMantisConfigEndpoint.Create(FConnection);
  FLang := TMantisLangEndpoint.Create(FConnection);
end;

destructor TMantisClient.Destroy;
begin
  FIssues.Free;
  FProjects.Free;
  FUsers.Free;
  FFilters.Free;
  FTags.Free;
  FConfig.Free;
  FLang.Free;
  FConnection.Free;
  inherited;
end;

procedure TMantisClient.TestConnection;
var
  LUser: TMantisUser;
begin
  LUser := FUsers.GetCurrentUser;
  LUser.Free;
end;

function TMantisClient.EnsureProjectForClient(const AClientName: string): TMantisProject;
var
  LProjects: TMantisProjectList;
  LProject: TMantisProject;
  LFoundId: Integer;
begin
  LFoundId := 0;
  LProjects := FProjects.GetAll;
  try
    for LProject in LProjects do
      if SameText(LProject.Name, AClientName) then
      begin
        LFoundId := LProject.Id;
        Break;
      end;
  finally
    LProjects.Free;
  end;

  if LFoundId > 0 then
    Result := FProjects.GetById(LFoundId)
  else
    Result := FProjects.Create_(AClientName, '', True);
end;

function TMantisClient.EnsureUser(const AUsername, AEmail, ARealName: string;
  AAccessLevel: TMantisEnum): TMantisUser;
var
  LUsers: TMantisUserList;
  LUser: TMantisUser;
  LFound: TMantisUser;
  LNewUser: TMantisUser;
begin
  LFound := nil;
  LUsers := FUsers.GetAllUsers;
  try
    for LUser in LUsers do
      if SameText(LUser.Name, AUsername) or
         ((AEmail <> '') and SameText(LUser.Email, AEmail)) then
      begin
        LFound := LUser;
        Break;
      end;
    if LFound <> nil then
      LUsers.Extract(LFound); { rimuove dalla lista senza liberarlo: la proprietà passa al chiamante }
  finally
    LUsers.Free;
  end;

  if LFound <> nil then
    Result := LFound
  else
  begin
    LNewUser := TMantisUser.Create;
    try
      LNewUser.Name := AUsername;
      LNewUser.Email := AEmail;
      LNewUser.RealName := ARealName;
      if AAccessLevel <> nil then
        LNewUser.AccessLevel := AAccessLevel;
      Result := FUsers.CreateUser(LNewUser, TGUID.NewGuid.ToString);
    finally
      LNewUser.Free;
    end;
  end;
end;

procedure TMantisClient.EnsureUserInProject(AUserId, AProjectId: Integer; AAccessLevel: TMantisEnum);
var
  LUsers: TMantisUserList;
  LUser: TMantisUser;
  LAlreadyThere: Boolean;
  LResult: TJSONObject;
begin
  LAlreadyThere := False;
  LUsers := FUsers.GetProjectUsers(AProjectId);
  try
    for LUser in LUsers do
      if LUser.Id = AUserId then
      begin
        LAlreadyThere := True;
        Break;
      end;
  finally
    LUsers.Free;
  end;

  if not LAlreadyThere then
  begin
    LResult := FProjects.AddUserToProject(AProjectId, AUserId, AAccessLevel);
    LResult.Free;
  end;
end;

end.
