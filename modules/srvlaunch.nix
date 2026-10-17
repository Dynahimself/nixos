{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.srvlaunch;

  appModule = types.submodule {
    options = {
      displayName = mkOption { type = types.str; };
      url = mkOption { type = types.str; };
      units = mkOption { type = types.listOf types.str; default = [ ]; };
      color = mkOption { type = types.str; default = "#89b4fa"; };
    };
  };

  panel = pkgs.writers.writePython3Bin "srvlaunch" {
    flakeIgnore = [ "E501" ];
  } ''
import http.server, socketserver, json, subprocess, os

PORT = int(os.environ.get("SRVLAUNCH_PORT", "8300"))
APPS = json.loads(os.environ.get("SRVLAUNCH_APPS", "{}"))

PAGE = """<!doctype html><html><head><meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1">
<title>Services</title><style>
:root{color-scheme:dark}
body{background:#1e1e2e;color:#cdd6f4;font-family:system-ui,sans-serif;max-width:720px;margin:40px auto;padding:0 16px}
h1{font-size:1.4rem}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px}
.card{background:#313244;border-radius:12px;padding:16px;cursor:pointer;transition:transform .1s}
.card:hover{transform:translateY(-2px)}
.dot{width:10px;height:10px;border-radius:50%;display:inline-block;margin-right:8px;background:#6c7086}
.name{font-weight:600}
.sub{font-size:.75rem;color:#a6adc8;margin-top:4px;word-break:break-all}
button.stop{background:none;border:1px solid #585b70;color:#a6adc8;border-radius:8px;padding:2px 10px;font-size:.7rem;margin-top:8px;cursor:pointer}
button.stop:hover{border-color:#f38ba8;color:#f38ba8}
</style></head><body>
<h1>Services</h1><div class=grid id=g></div>
<script>
let APPS=__APPS__;
async function act(name,action,url){
  if(action=="start"&&url)setTimeout(()=>location.href=url,600);
  await fetch("/",{method:"POST",body:JSON.stringify({app:name,action})});
}
for(const [name,a] of Object.entries(APPS)){
  let d=document.createElement("div");d.className="card";
  d.onclick=()=>act(name,"start",a.url);
  let btn=document.createElement("button");btn.className="stop";btn.textContent="stop";
  btn.onclick=(e)=>{e.stopPropagation();act(name,"stop")};
  d.innerHTML='<span class=dot style="background:'+a.color+'"></span><span class=name>'+a.displayName+'</span><div class=sub>'+a.url+'</div>';
  d.appendChild(btn);
  document.getElementById("g").appendChild(d);
}
</script></body></html>"""

class H(http.server.BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="text/html; charset=utf-8"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a): pass

    def do_GET(self):
        if self.path == "/api/apps":
            self._send(200, json.dumps({"apps": list(APPS.keys())}).encode(), "application/json")
            return
        page = PAGE.replace("__APPS__", json.dumps(APPS))
        self._send(200, page.encode())

    def do_POST(self):
        ln = int(self.headers.get("Content-Length", 0))
        data = json.loads(self.rfile.read(ln) or b"{}")
        app = data.get("app")
        act = data.get("action", "start")
        if app not in APPS or act not in ("start", "stop"):
            self._send(400, b'{"error":"bad request"}', "application/json")
            return
        rcs = []
        for u in APPS[app].get("units", []):
            rc = subprocess.run(["systemctl", act, u], capture_output=True)
            rcs.append({"unit": u, "rc": rc.returncode})
        self._send(200, json.dumps({"app": app, "action": act, "results": rcs}).encode(), "application/json")

with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), H) as httpd:
    httpd.serve_forever()
  '';

  appsJson = builtins.toJSON cfg.apps;
in
{
  options.services.srvlaunch = {
    enable = mkEnableOption "srvlaunch service launcher panel";
    http_port = mkOption { type = types.port; default = 8300; };
    apps = mkOption { type = types.attrsOf appModule; default = { }; };
  };

  config = mkIf cfg.enable {
    users.users.srvlaunch = {
      isSystemUser = true;
      group = "srvlaunch";
    };
    users.groups.srvlaunch = { };

    systemd.services.srvlaunch = {
      description = "srvlaunch - service launcher panel";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        SRVLAUNCH_PORT = toString cfg.http_port;
        SRVLAUNCH_APPS = appsJson;
      };
      serviceConfig = {
        ExecStart = "${panel}/bin/srvlaunch";
        User = "srvlaunch";
        Group = "srvlaunch";
        Restart = "always";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };

    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.user == "srvlaunch") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
